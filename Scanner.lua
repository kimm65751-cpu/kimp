-- ==============================================================================
-- OMNI-AUTO FARMER V3.0 - [ROUND ROBIN + FEEDBACK + CODE PANEL]
-- Basado en RequestHit, CombatFeedback y CombatConfig detectados por los scans.
-- ==============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local TargetGui = (pcall(function() return CoreGui.Name end) and CoreGui) or LP:WaitForChild("PlayerGui")
local VirtualInputManager = nil
pcall(function()
    VirtualInputManager = game:GetService("VirtualInputManager")
end)

local SETTINGS = {
    MaxTargetDistance = 85,
    MagnetDistance = 95,
    MaxMagnetTargets = 3,
    RepositionInterval = 0.10,
    ZeroVelocity = true,
    AutoAdaptPosition = true,
    AutoEquip = true,
    SkillInterval = 1.75,
    ZeroHitRotateThreshold = 3,
    DefaultCadence = {
        GlobalCooldown = 0.10,
        HitCooldown = 0.35,
        ComboResetTime = 0.90,
    },
    ModeOrder = { "Detras", "Arriba", "Abajo" },
    ModeOffsets = {
        Detras = Vector3.new(0, 2.5, 3.75),
        Arriba = Vector3.new(0, 4.5, 2.25),
        Abajo = Vector3.new(0, -4.25, 2.50),
    },
}

local State = {
    AutoFarm = false,
    FarmMode = "Detras",
    MobMagnetEnabled = false,
    AutoSkillEnabled = false,
    CurrentTarget = nil,
    RoundRobinIndex = 1,
    RequestHitAttempts = 0,
    FeedbackPackets = 0,
    LandedBursts = 0,
    TotalHitCount = 0,
    ZeroHitPackets = 0,
    ConsecutiveZeroHit = 0,
    LastRequestAt = 0,
    LastFeedbackAt = 0,
    LastRepositionAt = 0,
    LastSkillAt = 0,
    LastSuccessfulHitAt = 0,
    LogLines = {},
    LogFile = nil,
    ModeStats = {
        Detras = { req = 0, hits = 0, zero = 0 },
        Arriba = { req = 0, hits = 0, zero = 0 },
        Abajo = { req = 0, hits = 0, zero = 0 },
    },
    CodeListText = "",
}

local StatusLabel
local StatsLabel
local ModeStatsLabel

local function nextFileName(prefix)
    local index = 1
    if isfile then
        while isfile(prefix .. "_" .. index .. ".txt") do
            index = index + 1
        end
    end
    return prefix .. "_" .. index .. ".txt"
end

local function writeHeaderFile(prefix, header)
    if not writefile then
        return nil
    end
    local fileName = nextFileName(prefix)
    pcall(function()
        writefile(fileName, header .. "\n")
    end)
    return fileName
end

local function appendLine(fileName, line)
    if not fileName or not appendfile then
        return
    end
    pcall(function()
        appendfile(fileName, line .. "\n")
    end)
end

State.LogFile = writeHeaderFile("Omni_AutoFarmer_V3", "=== OMNI AUTO FARMER V3 ===\nCreated: " .. os.date())

local function logLine(message)
    local line = "[" .. os.date("%X") .. "] " .. message
    table.insert(State.LogLines, line)
    if #State.LogLines > 300 then
        table.remove(State.LogLines, 1)
    end
    appendLine(State.LogFile, line)
    return line
end

local function findDescendantByName(root, className, targetName)
    for _, obj in ipairs(root:GetDescendants()) do
        if obj:IsA(className) and obj.Name == targetName then
            return obj
        end
    end
    return nil
end

local function safeRequire(moduleScript)
    local ok, result = pcall(require, moduleScript)
    if ok then
        return result
    end
    return nil
end

local CombatSystem = ReplicatedStorage:FindFirstChild("CombatSystem")
local CombatRemotes = CombatSystem and CombatSystem:FindFirstChild("Remotes")
local CombatRemote = CombatRemotes and CombatRemotes:FindFirstChild("RequestHit")
local CombatFeedback = CombatRemotes and CombatRemotes:FindFirstChild("CombatFeedback")
local NPCsFolder = Workspace:FindFirstChild("NPCs")
local CombatConfigModule = findDescendantByName(ReplicatedStorage, "ModuleScript", "CombatConfig")
local CombatConfig = CombatConfigModule and safeRequire(CombatConfigModule) or nil
local CodesConfigModule = findDescendantByName(ReplicatedStorage, "ModuleScript", "CodesConfig")

local function setStatus(text, color)
    if StatusLabel then
        StatusLabel.Text = text
        if color then
            StatusLabel.TextColor3 = color
        end
    end
end

local function formatModeStats(mode)
    local bucket = State.ModeStats[mode]
    if not bucket then
        return mode .. ": 0/0"
    end
    return string.format("%s R=%d H=%d Z=%d", mode, bucket.req, bucket.hits, bucket.zero)
end

local function refreshStats()
    if StatsLabel then
        StatsLabel.Text = string.format(
            "Req=%d | Fb=%d | Bursts=%d | HitCount=%d | Zero=%d",
            State.RequestHitAttempts,
            State.FeedbackPackets,
            State.LandedBursts,
            State.TotalHitCount,
            State.ZeroHitPackets
        )
    end
    if ModeStatsLabel then
        ModeStatsLabel.Text =
            formatModeStats("Detras") .. "\n" ..
            formatModeStats("Arriba") .. "\n" ..
            formatModeStats("Abajo")
    end
end

local function getCadenceForTool(tool)
    local cadence = {
        GlobalCooldown = SETTINGS.DefaultCadence.GlobalCooldown,
        HitCooldown = SETTINGS.DefaultCadence.HitCooldown,
        ComboResetTime = SETTINGS.DefaultCadence.ComboResetTime,
        Label = tool and tool.Name or "Combat",
    }

    if type(CombatConfig) ~= "table" then
        return cadence
    end

    if type(CombatConfig.GlobalCooldown) == "number" then
        cadence.GlobalCooldown = CombatConfig.GlobalCooldown
    end

    local weaponName = tool and tool.Name or "Combat"
    local config = CombatConfig[weaponName]

    if type(config) ~= "table" then
        if weaponName:lower():find("moon") and type(CombatConfig.MoonSlayer) == "table" then
            config = CombatConfig.MoonSlayer
            cadence.Label = "MoonSlayer"
        elseif weaponName:lower():find("katana") and type(CombatConfig.Katana) == "table" then
            config = CombatConfig.Katana
            cadence.Label = "Katana"
        elseif type(CombatConfig.Combat) == "table" then
            config = CombatConfig.Combat
            cadence.Label = "Combat"
        end
    end

    if type(config) == "table" then
        if type(config.HitCooldown) == "number" then
            cadence.HitCooldown = config.HitCooldown
        end
        if type(config.ComboResetTime) == "number" then
            cadence.ComboResetTime = config.ComboResetTime
        end
    end

    return cadence
end

local function resolveMobRoot(mob)
    return mob and (mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart) or nil
end

local function resolveHumanoid(model)
    return model and model:FindFirstChildOfClass("Humanoid") or nil
end

local function getSortedTargets()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not NPCsFolder then
        return {}
    end

    local candidates = {}
    for _, mob in ipairs(NPCsFolder:GetChildren()) do
        if mob:IsA("Model") then
            local humanoid = resolveHumanoid(mob)
            local root = resolveMobRoot(mob)
            if humanoid and root and humanoid.Health > 0 then
                local distance = (root.Position - hrp.Position).Magnitude
                if distance <= SETTINGS.MagnetDistance then
                    candidates[#candidates + 1] = {
                        mob = mob,
                        root = root,
                        humanoid = humanoid,
                        distance = distance,
                    }
                end
            end
        end
    end

    table.sort(candidates, function(a, b)
        return a.distance < b.distance
    end)

    return candidates
end

local function getTargetPool()
    local sorted = getSortedTargets()
    if not State.MobMagnetEnabled then
        if sorted[1] then
            return { sorted[1] }
        end
        return {}
    end

    local pool = {}
    for i = 1, math.min(SETTINGS.MaxMagnetTargets, #sorted) do
        pool[#pool + 1] = sorted[i]
    end
    return pool
end

local function cycleMode()
    local currentIndex = table.find(SETTINGS.ModeOrder, State.FarmMode) or 1
    local nextIndex = currentIndex + 1
    if nextIndex > #SETTINGS.ModeOrder then
        nextIndex = 1
    end
    State.FarmMode = SETTINGS.ModeOrder[nextIndex]
    logLine("Mode -> " .. State.FarmMode)
    refreshStats()
    return State.FarmMode
end

local function getTargetCFrame(root)
    local offset = SETTINGS.ModeOffsets[State.FarmMode] or SETTINGS.ModeOffsets.Detras
    local targetPosition = (root.CFrame * CFrame.new(offset)).Position
    local lookAtPosition = Vector3.new(root.Position.X, targetPosition.Y, root.Position.Z)
    return CFrame.new(targetPosition, lookAtPosition)
end

local function equipTool()
    local char = LP.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not humanoid then
        return nil
    end

    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool then
        return currentTool
    end

    if SETTINGS.AutoEquip then
        local backpackTool = LP.Backpack:FindFirstChildOfClass("Tool")
        if backpackTool then
            pcall(function()
                humanoid:EquipTool(backpackTool)
            end)
        end
    end

    return char:FindFirstChildOfClass("Tool")
end

local function updateMainButtonText()
    if not BtnToggle then
        return
    end
    if State.AutoFarm then
        BtnToggle.Text = "DETENER AUTO-FARM"
        BtnToggle.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
    else
        BtnToggle.Text = "INICIAR AUTO-FARM"
        BtnToggle.BackgroundColor3 = Color3.fromRGB(100, 20, 30)
    end
end

local function updateModeButton()
    if not BtnMode then
        return
    end
    local labels = {
        Detras = "Posicion: DETRAS",
        Arriba = "Posicion: ARRIBA",
        Abajo = "Posicion: ABAJO",
    }
    BtnMode.Text = labels[State.FarmMode] or ("Posicion: " .. State.FarmMode)
end

local function updateToggleButtons()
    if BtnMagnet then
        BtnMagnet.Text = State.MobMagnetEnabled and "MAGNET: ON" or "MAGNET: OFF"
        BtnMagnet.BackgroundColor3 = State.MobMagnetEnabled and Color3.fromRGB(150, 40, 180) or Color3.fromRGB(50, 20, 60)
    end
    if BtnSkill then
        BtnSkill.Text = State.AutoSkillEnabled and "SKILL X: ON" or "SKILL X: OFF"
        BtnSkill.BackgroundColor3 = State.AutoSkillEnabled and Color3.fromRGB(200, 80, 40) or Color3.fromRGB(80, 40, 20)
    end
    if BtnAdapt then
        BtnAdapt.Text = SETTINGS.AutoAdaptPosition and "AUTO ADAPT: ON" or "AUTO ADAPT: OFF"
        BtnAdapt.BackgroundColor3 = SETTINGS.AutoAdaptPosition and Color3.fromRGB(40, 90, 40) or Color3.fromRGB(90, 40, 40)
    end
end

local function maybeUseSkill()
    if not State.AutoSkillEnabled or not VirtualInputManager then
        return
    end
    if tick() - State.LastSuccessfulHitAt > 0.80 then
        return
    end
    if tick() - State.LastSkillAt < SETTINGS.SkillInterval then
        return
    end
    State.LastSkillAt = tick()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.X, false, game)
        task.wait(0.02)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.X, false, game)
    end)
    logLine("SkillX -> fired")
end

local function fireAttack(tool)
    if not CombatRemote then
        setStatus("Status: RequestHit no encontrado", Color3.fromRGB(255, 120, 120))
        return false
    end

    local ok = pcall(function()
        CombatRemote:FireServer()
        if tool then
            tool:Activate()
        end
    end)

    if ok then
        State.RequestHitAttempts = State.RequestHitAttempts + 1
        State.ModeStats[State.FarmMode].req = State.ModeStats[State.FarmMode].req + 1
        State.LastRequestAt = tick()
        refreshStats()
    end
    return ok
end

local function parseCombatFeedback(args)
    local payload
    for _, arg in ipairs(args) do
        if type(arg) == "table" then
            payload = arg
            break
        end
    end
    payload = payload or {}
    local hitCount = tonumber(payload.HitCount) or 0
    local comboIndex = tostring(payload.ComboIndex or "?")
    local weaponName = tostring(payload.WeaponName or "Unknown")
    return payload, hitCount, comboIndex, weaponName
end

for _, ui in ipairs(TargetGui:GetChildren()) do
    if ui.Name == "OmniAutoFarmV3" then
        pcall(function()
            ui:Destroy()
        end)
    end
end

local SG = Instance.new("ScreenGui")
SG.Name = "OmniAutoFarmV3"
SG.ResetOnSpawn = false
SG.Parent = TargetGui

local MF = Instance.new("Frame", SG)
MF.Size = UDim2.new(0, 330, 0, 410)
MF.Position = UDim2.new(0.05, 0, 0.35, 0)
MF.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MF.BorderSizePixel = 2
MF.BorderColor3 = Color3.fromRGB(255, 0, 100)
MF.Active = true
MF.Draggable = true

local Title = Instance.new("TextLabel", MF)
Title.Size = UDim2.new(1, 0, 0, 28)
Title.BackgroundColor3 = Color3.fromRGB(50, 10, 20)
Title.Text = " OMNI AURA PROBE V3"
Title.TextColor3 = Color3.fromRGB(255, 170, 170)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

local FileLabel = Instance.new("TextLabel", MF)
FileLabel.Size = UDim2.new(1, -10, 0, 18)
FileLabel.Position = UDim2.new(0, 5, 0, 30)
FileLabel.BackgroundTransparency = 1
FileLabel.Text = "Log: " .. tostring(State.LogFile or "writefile no disponible")
FileLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
FileLabel.Font = Enum.Font.Code
FileLabel.TextSize = 10
FileLabel.TextXAlignment = Enum.TextXAlignment.Left

StatusLabel = Instance.new("TextLabel", MF)
StatusLabel.Size = UDim2.new(1, -10, 0, 18)
StatusLabel.Position = UDim2.new(0, 5, 0, 50)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: INACTIVO"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

StatsLabel = Instance.new("TextLabel", MF)
StatsLabel.Size = UDim2.new(1, -10, 0, 20)
StatsLabel.Position = UDim2.new(0, 5, 0, 72)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "Req=0 | Fb=0 | Bursts=0 | HitCount=0 | Zero=0"
StatsLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
StatsLabel.Font = Enum.Font.Code
StatsLabel.TextSize = 11
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left

ModeStatsLabel = Instance.new("TextLabel", MF)
ModeStatsLabel.Size = UDim2.new(1, -10, 0, 44)
ModeStatsLabel.Position = UDim2.new(0, 5, 0, 92)
ModeStatsLabel.BackgroundTransparency = 1
ModeStatsLabel.Text = ""
ModeStatsLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
ModeStatsLabel.Font = Enum.Font.Code
ModeStatsLabel.TextSize = 11
ModeStatsLabel.TextXAlignment = Enum.TextXAlignment.Left
ModeStatsLabel.TextYAlignment = Enum.TextYAlignment.Top

local function makeButton(text, y, height, color)
    local button = Instance.new("TextButton", MF)
    button.Size = UDim2.new(0.90, 0, 0, height)
    button.Position = UDim2.new(0.05, 0, 0, y)
    button.BackgroundColor3 = color
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.Text = text
    return button
end

BtnToggle = makeButton("INICIAR AUTO-FARM", 145, 36, Color3.fromRGB(100, 20, 30))
BtnMode = makeButton("Posicion: DETRAS", 188, 30, Color3.fromRGB(30, 30, 40))
BtnAdapt = makeButton("AUTO ADAPT: ON", 223, 30, Color3.fromRGB(40, 90, 40))
BtnMagnet = makeButton("MAGNET: OFF", 258, 30, Color3.fromRGB(50, 20, 60))
BtnSkill = makeButton("SKILL X: OFF", 293, 30, Color3.fromRGB(80, 40, 20))
BtnCodes = makeButton("ABRIR GESTOR DE CODIGOS", 328, 32, Color3.fromRGB(20, 60, 90))
BtnAudit = makeButton("AUDITAR SISTEMA DE CODIGOS", 365, 30, Color3.fromRGB(90, 70, 20))

local CodesFrame = Instance.new("Frame", SG)
CodesFrame.Size = UDim2.new(0, 330, 0, 390)
CodesFrame.Position = UDim2.new(0.05, 0, 0.35, 0)
CodesFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
CodesFrame.BorderSizePixel = 2
CodesFrame.BorderColor3 = Color3.fromRGB(0, 200, 255)
CodesFrame.Active = true
CodesFrame.Draggable = true
CodesFrame.Visible = false

local CodesTitle = Instance.new("TextLabel", CodesFrame)
CodesTitle.Size = UDim2.new(1, 0, 0, 28)
CodesTitle.BackgroundColor3 = Color3.fromRGB(10, 40, 60)
CodesTitle.Text = " CODIGOS DESCUBIERTOS"
CodesTitle.TextColor3 = Color3.fromRGB(150, 200, 255)
CodesTitle.Font = Enum.Font.GothamBold
CodesTitle.TextSize = 14

local CodesScroll = Instance.new("ScrollingFrame", CodesFrame)
CodesScroll.Size = UDim2.new(1, -8, 0, 310)
CodesScroll.Position = UDim2.new(0, 4, 0, 34)
CodesScroll.BackgroundTransparency = 1
CodesScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
CodesScroll.ScrollBarThickness = 4

local CodesList = Instance.new("UIListLayout", CodesScroll)
CodesList.SortOrder = Enum.SortOrder.LayoutOrder
CodesList.Padding = UDim.new(0, 4)

local BackBtn = Instance.new("TextButton", CodesFrame)
BackBtn.Size = UDim2.new(0.42, 0, 0, 28)
BackBtn.Position = UDim2.new(0.05, 0, 0, 350)
BackBtn.BackgroundColor3 = Color3.fromRGB(100, 20, 30)
BackBtn.TextColor3 = Color3.new(1, 1, 1)
BackBtn.Font = Enum.Font.Gotham
BackBtn.TextSize = 12
BackBtn.Text = "Cerrar"

local CopyAllBtn = Instance.new("TextButton", CodesFrame)
CopyAllBtn.Size = UDim2.new(0.42, 0, 0, 28)
CopyAllBtn.Position = UDim2.new(0.53, 0, 0, 350)
CopyAllBtn.BackgroundColor3 = Color3.fromRGB(20, 100, 40)
CopyAllBtn.TextColor3 = Color3.new(1, 1, 1)
CopyAllBtn.Font = Enum.Font.Gotham
CopyAllBtn.TextSize = 12
CopyAllBtn.Text = "Copiar Todos"

local function renderCodesPanel()
    for _, child in ipairs(CodesScroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local allCodes = ""
    local configValue = CodesConfigModule and safeRequire(CodesConfigModule) or nil
    local codeTable = type(configValue) == "table" and (configValue.Codes or configValue.codes or configValue.ValidCodes or configValue)

    if type(codeTable) ~= "table" then
        local fail = Instance.new("TextLabel", CodesScroll)
        fail.Size = UDim2.new(1, -8, 0, 40)
        fail.BackgroundTransparency = 1
        fail.Text = "No se pudo obtener CodesConfig."
        fail.TextColor3 = Color3.fromRGB(255, 120, 120)
        fail.Font = Enum.Font.Gotham
        fail.TextSize = 12
        fail.TextWrapped = true
        State.CodeListText = ""
        CodesScroll.CanvasSize = UDim2.new(0, 0, 0, 45)
        return
    end

    local rowCount = 0
    for codeName in pairs(codeTable) do
        rowCount = rowCount + 1
        allCodes = allCodes .. tostring(codeName) .. "\n"

        local row = Instance.new("Frame", CodesScroll)
        row.Size = UDim2.new(1, -8, 0, 32)
        row.BackgroundTransparency = 1
        row.LayoutOrder = rowCount

        local label = Instance.new("TextLabel", row)
        label.Size = UDim2.new(0.68, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = tostring(codeName)
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Font = Enum.Font.Code
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left

        local copyButton = Instance.new("TextButton", row)
        copyButton.Size = UDim2.new(0.28, 0, 0.76, 0)
        copyButton.Position = UDim2.new(0.72, 0, 0.12, 0)
        copyButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        copyButton.TextColor3 = Color3.new(1, 1, 1)
        copyButton.Font = Enum.Font.Gotham
        copyButton.TextSize = 11
        copyButton.Text = "Copiar"
        copyButton.MouseButton1Click:Connect(function()
            if setclipboard then
                pcall(function()
                    setclipboard(tostring(codeName))
                end)
                copyButton.Text = "Copiado"
                task.delay(1, function()
                    if copyButton.Parent then
                        copyButton.Text = "Copiar"
                    end
                end)
            end
        end)
    end

    State.CodeListText = allCodes
    CodesScroll.CanvasSize = UDim2.new(0, 0, 0, rowCount * 36)
end

CopyAllBtn.MouseButton1Click:Connect(function()
    if setclipboard and State.CodeListText ~= "" then
        pcall(function()
            setclipboard(State.CodeListText)
        end)
        CopyAllBtn.Text = "Copiado"
        task.delay(1.2, function()
            if CopyAllBtn.Parent then
                CopyAllBtn.Text = "Copiar Todos"
            end
        end)
    end
end)

BtnCodes.MouseButton1Click:Connect(function()
    MF.Visible = false
    CodesFrame.Visible = true
    renderCodesPanel()
end)

BackBtn.MouseButton1Click:Connect(function()
    CodesFrame.Visible = false
    MF.Visible = true
end)

local function collectCodeAudit()
    local lines = {
        "=== CODE SYSTEM AUDIT ===",
        "Created: " .. os.date(),
        "",
        "[1] REMOTES",
    }

    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local lower = obj.Name:lower()
            if lower:find("code") or lower:find("redeem") or lower:find("claim") or lower:find("reward") or lower:find("promo") then
                lines[#lines + 1] = string.format("%s | %s", obj.ClassName, obj:GetFullName())
            end
        end
    end

    lines[#lines + 1] = ""
    lines[#lines + 1] = "[2] MODULES"
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("ModuleScript") then
            local lower = obj.Name:lower()
            if lower:find("code") or lower:find("redeem") or lower:find("gift") then
                lines[#lines + 1] = obj:GetFullName()
            end
        end
    end

    lines[#lines + 1] = ""
    lines[#lines + 1] = "[3] CONFIG SAMPLE"
    local cfg = CodesConfigModule and safeRequire(CodesConfigModule) or nil
    local tbl = type(cfg) == "table" and (cfg.Codes or cfg.codes or cfg.ValidCodes or cfg)
    if type(tbl) == "table" then
        local count = 0
        for codeName in pairs(tbl) do
            count = count + 1
            lines[#lines + 1] = tostring(codeName)
            if count >= 25 then
                break
            end
        end
    end

    return table.concat(lines, "\n")
end

BtnAudit.MouseButton1Click:Connect(function()
    local report = collectCodeAudit()
    local fileName = writeHeaderFile("Code_System_Audit", report)
    if fileName then
        BtnAudit.Text = "OK: " .. fileName
        logLine("CodeAudit -> " .. fileName)
    elseif setclipboard then
        pcall(function()
            setclipboard(report)
        end)
        BtnAudit.Text = "OK: copiado"
    else
        BtnAudit.Text = "ERROR: sin writefile"
    end
    task.delay(3, function()
        if BtnAudit.Parent then
            BtnAudit.Text = "AUDITAR SISTEMA DE CODIGOS"
        end
    end)
end)

BtnToggle.MouseButton1Click:Connect(function()
    State.AutoFarm = not State.AutoFarm
    updateMainButtonText()
    if State.AutoFarm then
        setStatus("Status: buscando objetivos", Color3.fromRGB(0, 255, 100))
        logLine("AutoFarm -> ON")
    else
        setStatus("Status: inactivo", Color3.fromRGB(150, 150, 150))
        State.CurrentTarget = nil
        logLine("AutoFarm -> OFF")
    end
end)

BtnMode.MouseButton1Click:Connect(function()
    cycleMode()
    updateModeButton()
end)

BtnAdapt.MouseButton1Click:Connect(function()
    SETTINGS.AutoAdaptPosition = not SETTINGS.AutoAdaptPosition
    logLine("AutoAdapt -> " .. tostring(SETTINGS.AutoAdaptPosition))
    updateToggleButtons()
end)

BtnMagnet.MouseButton1Click:Connect(function()
    State.MobMagnetEnabled = not State.MobMagnetEnabled
    State.RoundRobinIndex = 1
    logLine("Magnet -> " .. tostring(State.MobMagnetEnabled))
    updateToggleButtons()
end)

BtnSkill.MouseButton1Click:Connect(function()
    State.AutoSkillEnabled = not State.AutoSkillEnabled
    logLine("SkillX -> " .. tostring(State.AutoSkillEnabled))
    updateToggleButtons()
end)

if CombatFeedback and CombatFeedback:IsA("RemoteEvent") then
    CombatFeedback.OnClientEvent:Connect(function(...)
        local payload, hitCount, comboIndex, weaponName = parseCombatFeedback({ ... })
        State.FeedbackPackets = State.FeedbackPackets + 1
        State.LastFeedbackAt = tick()

        if hitCount > 0 then
            State.LandedBursts = State.LandedBursts + 1
            State.TotalHitCount = State.TotalHitCount + hitCount
            State.ConsecutiveZeroHit = 0
            State.LastSuccessfulHitAt = tick()
            State.ModeStats[State.FarmMode].hits = State.ModeStats[State.FarmMode].hits + hitCount
            setStatus(
                string.format("Status: HIT x%d | %s | Combo %s", hitCount, weaponName, comboIndex),
                Color3.fromRGB(120, 255, 120)
            )
        else
            State.ZeroHitPackets = State.ZeroHitPackets + 1
            State.ConsecutiveZeroHit = State.ConsecutiveZeroHit + 1
            State.ModeStats[State.FarmMode].zero = State.ModeStats[State.FarmMode].zero + 1
            setStatus(
                string.format("Status: zero hit | %s | Combo %s", weaponName, comboIndex),
                Color3.fromRGB(255, 180, 100)
            )
            if SETTINGS.AutoAdaptPosition and State.ConsecutiveZeroHit >= SETTINGS.ZeroHitRotateThreshold then
                cycleMode()
                updateModeButton()
                State.ConsecutiveZeroHit = 0
            end
        end

        logLine(
            string.format(
                "CombatFeedback -> HitCount=%s | Weapon=%s | Combo=%s | Pos=%s | PayloadKeys=%d",
                tostring(hitCount),
                weaponName,
                comboIndex,
                State.FarmMode,
                type(payload) == "table" and (function()
                    local n = 0
                    for _ in pairs(payload) do
                        n = n + 1
                    end
                    return n
                end)() or 0
            )
        )
        refreshStats()
    end)
end

RunService.Stepped:Connect(function()
    if not State.AutoFarm then
        return
    end

    local char = LP.Character
    if not char then
        return
    end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    if SETTINGS.ZeroVelocity then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.zero
            hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end
end)

task.spawn(function()
    while task.wait(0.03) do
        if not State.AutoFarm then
            continue
        end

        local char = LP.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not char or not humanoid or not hrp then
            setStatus("Status: esperando personaje", Color3.fromRGB(180, 180, 180))
            continue
        end

        if humanoid.Health <= 0 then
            setStatus("Status: reviviendo...", Color3.fromRGB(255, 180, 120))
            State.CurrentTarget = nil
            task.wait(1)
            continue
        end

        local tool = equipTool()
        local cadence = getCadenceForTool(tool)
        local attackInterval = math.max(cadence.GlobalCooldown, cadence.HitCooldown)
        local targetPool = getTargetPool()

        if #targetPool == 0 then
            State.CurrentTarget = nil
            setStatus("Status: sin mobs validos", Color3.fromRGB(180, 180, 180))
            continue
        end

        local selectedIndex = State.RoundRobinIndex
        if selectedIndex > #targetPool then
            selectedIndex = 1
            State.RoundRobinIndex = 1
        end

        local target = targetPool[selectedIndex]
        State.RoundRobinIndex = State.RoundRobinIndex + 1
        if State.RoundRobinIndex > #targetPool then
            State.RoundRobinIndex = 1
        end

        if State.CurrentTarget ~= target.mob then
            State.CurrentTarget = target.mob
            State.ConsecutiveZeroHit = 0
            logLine(
                string.format(
                    "TargetLock -> %s | Dist=%.2f | Pool=%d | Mode=%s",
                    target.mob.Name,
                    target.distance,
                    #targetPool,
                    State.FarmMode
                )
            )
        end

        if tick() - State.LastRepositionAt >= SETTINGS.RepositionInterval then
            pcall(function()
                char:PivotTo(getTargetCFrame(target.root))
            end)
            State.LastRepositionAt = tick()
        end

        if tick() - State.LastRequestAt >= attackInterval then
            local success = fireAttack(tool)
            if success then
                setStatus(
                    string.format(
                        "Status: RequestHit -> %s | %s | %.2fs | pool=%d",
                        target.mob.Name,
                        cadence.Label,
                        attackInterval,
                        #targetPool
                    ),
                    Color3.fromRGB(0, 255, 100)
                )
                maybeUseSkill()
            end
        end
    end
end)

updateMainButtonText()
updateModeButton()
updateToggleButtons()
refreshStats()
logLine("Boot -> CombatRemote=" .. tostring(CombatRemote and CombatRemote:GetFullName() or "nil"))
logLine("Boot -> CombatFeedback=" .. tostring(CombatFeedback and CombatFeedback:GetFullName() or "nil"))
logLine("Boot -> CombatConfig=" .. tostring(CombatConfigModule and CombatConfigModule:GetFullName() or "nil"))
logLine("Boot -> CodesConfig=" .. tostring(CodesConfigModule and CodesConfigModule:GetFullName() or "nil"))
