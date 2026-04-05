-- ==============================================================================
-- 🔴 LIVE FORENSIC SCANNER V1.0 — INTERCEPCIÓN EN TIEMPO REAL
-- Captura TODOS los remotes, movimientos, frutas, skills EN VIVO
-- + Dump inicial de configs completas
-- ==============================================================================

local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local LP = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- ======================== ESTADO ========================
local LiveActive = true
local SpyActive = false
local PosTrackActive = false
local FileName = "LiveScan_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"
local Buffer = {}
local LogOrder = 0
local MAX_GUI_LINES = 300

-- ======================== GUI ========================
local TargetGui = pcall(function() return CoreGui.Name end) and CoreGui or LP:WaitForChild("PlayerGui")
for _, v in pairs(TargetGui:GetChildren()) do if v.Name == "LiveScanner" then pcall(function() v:Destroy() end) end end

local SG = Instance.new("ScreenGui")
SG.Name = "LiveScanner"
SG.ResetOnSpawn = false
SG.Parent = TargetGui

local MF = Instance.new("Frame", SG)
MF.Size = UDim2.new(0, 520, 0, 440)
MF.Position = UDim2.new(0, 10, 0.5, -220)
MF.BackgroundColor3 = Color3.fromRGB(8, 10, 16)
MF.BorderSizePixel = 0
MF.Active = true
MF.Draggable = true
Instance.new("UICorner", MF).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", MF)
stroke.Color = Color3.fromRGB(255, 60, 60)
stroke.Thickness = 1.5

-- Title
local TitleBar = Instance.new("Frame", MF)
TitleBar.Size = UDim2.new(1, 0, 0, 28)
TitleBar.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

local TitleLbl = Instance.new("TextLabel", TitleBar)
TitleLbl.Size = UDim2.new(1, -80, 1, 0)
TitleLbl.Position = UDim2.new(0, 8, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "🔴 LIVE FORENSIC SCANNER"
TitleLbl.TextColor3 = Color3.new(1,1,1)
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextSize = 13
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

local BtnMin = Instance.new("TextButton", TitleBar)
BtnMin.Size = UDim2.new(0, 28, 0, 28)
BtnMin.Position = UDim2.new(1, -28, 0, 0)
BtnMin.BackgroundTransparency = 1
BtnMin.Text = "—"
BtnMin.TextColor3 = Color3.new(1,1,1)
BtnMin.TextSize = 16
BtnMin.Font = Enum.Font.GothamBold

-- Log scroll
local LogScroll = Instance.new("ScrollingFrame", MF)
LogScroll.Size = UDim2.new(1, -10, 1, -100)
LogScroll.Position = UDim2.new(0, 5, 0, 30)
LogScroll.BackgroundColor3 = Color3.fromRGB(4, 5, 10)
LogScroll.BorderSizePixel = 0
LogScroll.ScrollBarThickness = 3
LogScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 80, 80)
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", LogScroll).CornerRadius = UDim.new(0, 4)
local LogLayout = Instance.new("UIListLayout", LogScroll)
LogLayout.Padding = UDim.new(0, 0)
LogLayout.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", LogScroll).PaddingTop = UDim.new(0, 2)

-- Buttons bar
local BtnBar = Instance.new("Frame", MF)
BtnBar.Size = UDim2.new(1, -10, 0, 64)
BtnBar.Position = UDim2.new(0, 5, 1, -68)
BtnBar.BackgroundTransparency = 1

local BtnBarLayout = Instance.new("UIGridLayout", BtnBar)
BtnBarLayout.CellSize = UDim2.new(0, 120, 0, 28)
BtnBarLayout.CellPadding = UDim2.new(0, 4, 0, 4)

local function MakeBtn(text, color)
    local b = Instance.new("TextButton", BtnBar)
    b.BackgroundColor3 = color or Color3.fromRGB(30, 35, 50)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 11
    b.Text = text
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    return b
end

local BtnSpy = MakeBtn("📡 SPY: OFF", Color3.fromRGB(60, 30, 30))
local BtnDump = MakeBtn("📋 DUMP CONFIGS", Color3.fromRGB(30, 45, 70))
local BtnPos = MakeBtn("📍 POS TRACK: OFF", Color3.fromRGB(30, 50, 30))
local BtnSave = MakeBtn("💾 GUARDAR", Color3.fromRGB(20, 70, 40))
local BtnClear = MakeBtn("🗑 LIMPIAR", Color3.fromRGB(80, 20, 20))
local BtnTest = MakeBtn("🧪 TEST MOVE", Color3.fromRGB(50, 30, 60))
local BtnFruit = MakeBtn("🍎 SCAN FRUTAS", Color3.fromRGB(60, 40, 20))
local BtnInventory = MakeBtn("🎒 INVENTARIO", Color3.fromRGB(30, 40, 60))

-- ======================== LOGGER ========================
local function Log(text, color)
    LogOrder = LogOrder + 1
    local ts = os.date("%H:%M:%S")
    local full = "[" .. ts .. "] " .. text
    table.insert(Buffer, full)

    local lbl = Instance.new("TextLabel", LogScroll)
    lbl.Size = UDim2.new(1, -4, 0, 13)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = color or Color3.fromRGB(170, 180, 200)
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 10
    lbl.Text = " " .. full
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.LayoutOrder = LogOrder
    lbl.TextTruncate = Enum.TextTruncate.AtEnd

    -- Limitar lineas GUI
    local children = {}
    for _, c in pairs(LogScroll:GetChildren()) do
        if c:IsA("TextLabel") then table.insert(children, c) end
    end
    if #children > MAX_GUI_LINES then
        for i = 1, #children - MAX_GUI_LINES do
            children[i]:Destroy()
        end
    end

    task.defer(function()
        pcall(function()
            LogScroll.CanvasPosition = Vector2.new(0, LogScroll.AbsoluteCanvasSize.Y)
        end)
    end)

    -- Auto-save cada 50 lineas
    if #Buffer % 50 == 0 then
        pcall(function()
            if writefile then writefile(FileName, table.concat(Buffer, "\n")) end
        end)
    end
end

local function SaveLog()
    pcall(function()
        if writefile then
            writefile(FileName, table.concat(Buffer, "\n"))
            Log(">>> GUARDADO: " .. FileName .. " (" .. #Buffer .. " lineas)", Color3.fromRGB(90, 255, 90))
        end
    end)
end

-- ======================== SERIALIZE ARGS ========================
local function SerializeValue(v, depth)
    depth = depth or 0
    if depth > 4 then return "..." end
    local t = typeof(v)
    if t == "string" then return '"' .. v:sub(1, 100) .. '"'
    elseif t == "number" then return tostring(v)
    elseif t == "boolean" then return tostring(v)
    elseif t == "nil" then return "nil"
    elseif t == "Vector3" then return string.format("V3(%.1f,%.1f,%.1f)", v.X, v.Y, v.Z)
    elseif t == "CFrame" then return string.format("CF(%.1f,%.1f,%.1f)", v.Position.X, v.Position.Y, v.Position.Z)
    elseif t == "Instance" then return v:GetFullName()
    elseif t == "EnumItem" then return tostring(v)
    elseif t == "table" then
        local parts = {}
        local count = 0
        for k2, v2 in pairs(v) do
            count = count + 1
            if count > 10 then table.insert(parts, "...+" .. (count) .. " more"); break end
            table.insert(parts, tostring(k2) .. "=" .. SerializeValue(v2, depth + 1))
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    else
        return t .. ":" .. tostring(v)
    end
end

local function SerializeArgs(args)
    local parts = {}
    for i, v in ipairs(args) do
        table.insert(parts, SerializeValue(v))
    end
    return table.concat(parts, ", ")
end

-- ======================== REMOTE SPY ========================
local OldNamecall = nil
local function StartSpy()
    if not hookmetamethod then
        Log("WARN: hookmetamethod no disponible, usando listeners", Color3.fromRGB(255, 200, 100))
        -- Fallback: listeners on known fruit/movement remotes
        pcall(function()
            local importantRemotes = {}
            for _, obj in pairs(game:GetDescendants()) do
                if obj:IsA("RemoteEvent") then
                    local n = obj.Name:lower()
                    if n:match("fruit") or n:match("drop") or n:match("reroll") or n:match("hit") or n:match("combat") or n:match("dash") or n:match("jump") or n:match("sprint") or n:match("teleport") or n:match("equip") or n:match("ability") or n:match("power") or n:match("spin") or n:match("purchase") or n:match("buy") or n:match("shop") or n:match("merchant") then
                        table.insert(importantRemotes, obj)
                    end
                end
            end
            Log("Monitoreando " .. #importantRemotes .. " remotes con listeners", Color3.fromRGB(200, 200, 100))
            for _, re in pairs(importantRemotes) do
                pcall(function()
                    re.OnClientEvent:Connect(function(...)
                        if not SpyActive then return end
                        local args = {...}
                        Log("[S->C] " .. re:GetFullName() .. " | " .. SerializeArgs(args), Color3.fromRGB(100, 200, 255))
                    end)
                end)
            end
        end)
        return
    end
    
    OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if SpyActive and (method == "FireServer" or method == "InvokeServer") then
            local args = {...}
            local name = ""
            pcall(function() name = self:GetFullName() end)
            local argStr = SerializeArgs(args)
            
            -- Color-code por tipo
            local color = Color3.fromRGB(200, 200, 130)
            local nl = name:lower()
            if nl:match("fruit") or nl:match("drop") or nl:match("reroll") then
                color = Color3.fromRGB(255, 150, 50) -- Naranja = frutas
            elseif nl:match("hit") or nl:match("combat") or nl:match("damage") or nl:match("ability") then
                color = Color3.fromRGB(255, 80, 80) -- Rojo = combate
            elseif nl:match("dash") or nl:match("jump") or nl:match("sprint") or nl:match("move") or nl:match("teleport") then
                color = Color3.fromRGB(80, 255, 80) -- Verde = movimiento
            elseif nl:match("equip") or nl:match("purchase") or nl:match("buy") or nl:match("shop") or nl:match("merchant") then
                color = Color3.fromRGB(180, 130, 255) -- Morado = compras
            end

            pcall(function()
                Log("[" .. method .. "] " .. name .. "(" .. argStr .. ")", color)
            end)
        end
        return OldNamecall(self, ...)
    end)
    Log("hookmetamethod OK - interceptando TODOS los remotes", Color3.fromRGB(90, 255, 90))
end

-- ======================== POSITION TRACKER ========================
local LastPos = nil
local LastState = nil
task.spawn(function()
    while task.wait(0.5) do
        if PosTrackActive then
            pcall(function()
                local char = LP.Character
                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                    local hrp = char.HumanoidRootPart
                    local hum = char.Humanoid
                    local pos = hrp.Position
                    local state = tostring(hum:GetState())
                    local vel = hrp.Velocity
                    local speed = Vector3.new(vel.X, 0, vel.Z).Magnitude
                    
                    -- Solo logear si cambió significativamente
                    local moved = LastPos and (pos - LastPos).Magnitude or 999
                    local stateChanged = state ~= LastState
                    
                    if moved > 2 or stateChanged then
                        Log(string.format("POS(%.0f,%.0f,%.0f) SPD=%.1f STATE=%s HP=%.0f/%.0f",
                            pos.X, pos.Y, pos.Z, speed, state,
                            hum.Health, hum.MaxHealth),
                            Color3.fromRGB(100, 180, 255))
                        LastPos = pos
                        LastState = state
                    end
                end
            end)
        end
    end
end)

-- ======================== HUMANOID STATE MONITOR ========================
local function MonitorCharacter(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    
    hum.StateChanged:Connect(function(old, new)
        if not LiveActive then return end
        Log("STATE: " .. tostring(old) .. " -> " .. tostring(new), Color3.fromRGB(130, 200, 255))
    end)
    
    hum.Died:Connect(function()
        Log(">>> MUERTO <<<", Color3.fromRGB(255, 50, 50))
    end)
    
    -- Tool equip/unequip
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            Log("EQUIP: " .. child.Name, Color3.fromRGB(200, 255, 130))
            for _, v in pairs(child:GetDescendants()) do
                if v:IsA("ValueBase") then
                    Log("  VAL: " .. v.Name .. " = " .. tostring(v.Value), Color3.fromRGB(180, 200, 130))
                end
            end
        end
    end)
    char.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") then
            Log("UNEQUIP: " .. child.Name, Color3.fromRGB(255, 200, 130))
        end
    end)
end

-- Monitor current + future characters
if LP.Character then MonitorCharacter(LP.Character) end
LP.CharacterAdded:Connect(function(char)
    Log(">>> RESPAWN <<<", Color3.fromRGB(255, 255, 80))
    MonitorCharacter(char)
end)

-- Backpack monitor
LP.Backpack.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        Log("BACKPACK+: " .. child.Name, Color3.fromRGB(130, 255, 200))
        for _, v in pairs(child:GetDescendants()) do
            if v:IsA("ValueBase") then
                Log("  VAL: " .. v.Name .. " = " .. tostring(v.Value), Color3.fromRGB(130, 200, 170))
            end
        end
    end
end)
LP.Backpack.ChildRemoved:Connect(function(child)
    if child:IsA("Tool") then
        Log("BACKPACK-: " .. child.Name, Color3.fromRGB(255, 180, 130))
    end
end)

-- ======================== DUMP CONFIGS ========================
local function DumpConfigs()
    Log("========== DUMP CONFIGS ==========", Color3.fromRGB(100, 200, 255))
    
    -- CombatConfig require
    pcall(function()
        local cs = RS:FindFirstChild("CombatSystem")
        if cs then
            local cc = cs:FindFirstChild("CombatConfig")
            if cc then
                Log("--- CombatConfig ---", Color3.fromRGB(255, 200, 100))
                local mod = pcall(function() return require(cc) end) and require(cc) or nil
                if mod then
                    if mod.Settings then
                        Log("Settings:", Color3.fromRGB(200, 200, 100))
                        for k, v in pairs(mod.Settings) do
                            Log("  " .. tostring(k) .. " = " .. tostring(v), Color3.fromRGB(200, 220, 180))
                        end
                    end
                    if mod.Weapons then
                        Log("Weapons:", Color3.fromRGB(200, 200, 100))
                        for wName, wData in pairs(mod.Weapons) do
                            local info = "HitCD=" .. tostring(wData.HitCooldown or "?")
                            if wData.HitDelay then info = info .. " Delay=" .. wData.HitDelay end
                            if wData.Range then info = info .. " Range=" .. wData.Range end
                            if wData.Damage then info = info .. " DMG=" .. wData.Damage end
                            Log("  " .. tostring(wName) .. ": " .. info, Color3.fromRGB(255, 200, 160))
                        end
                    end
                    -- Dump EVERYTHING
                    for k, v in pairs(mod) do
                        if k ~= "Settings" and k ~= "Weapons" then
                            if type(v) == "table" then
                                Log(tostring(k) .. ":", Color3.fromRGB(200, 200, 100))
                                for k2, v2 in pairs(v) do
                                    if type(v2) == "table" then
                                        local parts = {}
                                        for k3, v3 in pairs(v2) do
                                            table.insert(parts, tostring(k3) .. "=" .. tostring(v3))
                                        end
                                        Log("  " .. tostring(k2) .. ": " .. table.concat(parts, ", "), Color3.fromRGB(190, 200, 180))
                                    else
                                        Log("  " .. tostring(k2) .. " = " .. tostring(v2), Color3.fromRGB(190, 200, 180))
                                    end
                                end
                            elseif type(v) ~= "function" then
                                Log(tostring(k) .. " = " .. tostring(v), Color3.fromRGB(200, 200, 180))
                            end
                        end
                    end
                end
            end
        end
    end)
    
    -- FruitPowerConfig require
    pcall(function()
        local fps = RS:FindFirstChild("FruitPowerSystem")
        if fps then
            local fpc = fps:FindFirstChild("FruitPowerConfig")
            if fpc then
                Log("--- FruitPowerConfig ---", Color3.fromRGB(255, 150, 50))
                local mod = pcall(function() return require(fpc) end) and require(fpc) or nil
                if mod then
                    for fruitName, fruitData in pairs(mod) do
                        if type(fruitData) == "table" then
                            Log("FRUIT: " .. tostring(fruitName), Color3.fromRGB(255, 200, 100))
                            if type(fruitData) == "table" then
                                for skillKey, skillData in pairs(fruitData) do
                                    if type(skillData) == "table" then
                                        local parts = {}
                                        for k, v in pairs(skillData) do
                                            table.insert(parts, tostring(k) .. "=" .. tostring(v))
                                        end
                                        Log("  " .. tostring(skillKey) .. ": " .. table.concat(parts, ", "), Color3.fromRGB(255, 220, 150))
                                    else
                                        Log("  " .. tostring(skillKey) .. " = " .. tostring(skillData), Color3.fromRGB(255, 220, 150))
                                    end
                                end
                            end
                        elseif type(fruitData) ~= "function" then
                            Log(tostring(fruitName) .. " = " .. tostring(fruitData), Color3.fromRGB(255, 220, 150))
                        end
                    end
                end
            end
        end
    end)
    
    -- AbilityConfig require
    pcall(function()
        local abSys = RS:FindFirstChild("AbilitySystem")
        if abSys then
            local abCfg = abSys:FindFirstChild("AbilityConfig")
            if abCfg then
                Log("--- AbilityConfig ---", Color3.fromRGB(200, 130, 255))
                local mod = pcall(function() return require(abCfg) end) and require(abCfg) or nil
                if mod then
                    for specName, specData in pairs(mod) do
                        if type(specData) == "table" then
                            Log("SPEC: " .. tostring(specName), Color3.fromRGB(200, 160, 255))
                            for skillKey, skillData in pairs(specData) do
                                if type(skillData) == "table" then
                                    local parts = {}
                                    for k, v in pairs(skillData) do
                                        if type(v) ~= "table" and type(v) ~= "function" then
                                            table.insert(parts, tostring(k) .. "=" .. tostring(v))
                                        end
                                    end
                                    Log("  " .. tostring(skillKey) .. ": " .. table.concat(parts, ", "), Color3.fromRGB(200, 180, 240))
                                elseif type(skillData) ~= "function" then
                                    Log("  " .. tostring(skillKey) .. " = " .. tostring(skillData), Color3.fromRGB(200, 180, 240))
                                end
                            end
                        elseif type(specData) ~= "function" then
                            Log(tostring(specName) .. " = " .. tostring(specData), Color3.fromRGB(200, 180, 240))
                        end
                    end
                end
            end
        end
    end)
    
    -- DashModule + MultiJumpModule require
    pcall(function()
        Log("--- Movement Modules ---", Color3.fromRGB(80, 255, 80))
        local dm = RS:FindFirstChild("DashModule")
        if dm then
            local mod = pcall(function() return require(dm) end) and require(dm) or nil
            if mod and type(mod) == "table" then
                Log("DashModule:", Color3.fromRGB(100, 255, 100))
                for k, v in pairs(mod) do
                    if type(v) ~= "function" then
                        Log("  " .. tostring(k) .. " = " .. tostring(v), Color3.fromRGB(130, 230, 130))
                    end
                end
            end
        end
        local mj = RS:FindFirstChild("MultiJumpModule")
        if mj then
            local mod = pcall(function() return require(mj) end) and require(mj) or nil
            if mod and type(mod) == "table" then
                Log("MultiJumpModule:", Color3.fromRGB(100, 255, 100))
                for k, v in pairs(mod) do
                    if type(v) ~= "function" then
                        Log("  " .. tostring(k) .. " = " .. tostring(v), Color3.fromRGB(130, 230, 130))
                    end
                end
            end
        end
    end)
    
    -- Fruit dealer NPCs
    pcall(function()
        Log("--- FRUIT DEALERS ---", Color3.fromRGB(255, 200, 100))
        for _, obj in pairs(WS:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:match("Dealer") or obj.Name:match("Fruit")) then
                local hrpN = obj:FindFirstChild("HumanoidRootPart")
                local posStr = hrpN and string.format("(%.0f,%.0f,%.0f)", hrpN.Position.X, hrpN.Position.Y, hrpN.Position.Z) or "?"
                Log("NPC: " .. obj.Name .. " @ " .. posStr, Color3.fromRGB(255, 220, 130))
                for _, c in pairs(obj:GetDescendants()) do
                    if c:IsA("ProximityPrompt") then
                        Log("  PROMPT: Action='" .. c.ActionText .. "' Object='" .. c.ObjectText .. "' Hold=" .. c.HoldDuration .. "s MaxDist=" .. c.MaxActivationDistance, Color3.fromRGB(255, 200, 100))
                    end
                end
            end
        end
    end)
    
    -- Fruit rate modules
    pcall(function()
        Log("--- FRUIT RATE/CHANCE MODULES ---", Color3.fromRGB(255, 150, 50))
        local keywords = {"fruitconfig", "fruitrate", "fruitchance", "spinconfig", "fruitlist", "fruitdata", "dealerconfig", "rewardconfig", "gachaconfig", "lootconfig", "rollconfig", "fruitinfo", "fruittable"}
        for _, obj in pairs(RS:GetDescendants()) do
            if obj:IsA("ModuleScript") then
                local n = obj.Name:lower()
                for _, kw in pairs(keywords) do
                    if n:match(kw) or (n:match("fruit") and (n:match("config") or n:match("data") or n:match("rate") or n:match("list") or n:match("info"))) then
                        Log("MODULE: " .. obj:GetFullName(), Color3.fromRGB(255, 180, 100))
                        local mod = pcall(function() return require(obj) end) and require(obj) or nil
                        if mod and type(mod) == "table" then
                            for k, v in pairs(mod) do
                                if type(v) == "table" then
                                    local parts = {}
                                    for k2, v2 in pairs(v) do
                                        if type(v2) ~= "table" and type(v2) ~= "function" then
                                            table.insert(parts, tostring(k2) .. "=" .. tostring(v2))
                                        end
                                    end
                                    Log("  " .. tostring(k) .. ": " .. table.concat(parts, ", "), Color3.fromRGB(255, 200, 130))
                                elseif type(v) ~= "function" then
                                    Log("  " .. tostring(k) .. " = " .. tostring(v), Color3.fromRGB(255, 200, 130))
                                end
                            end
                        end
                        break
                    end
                end
            end
        end
        
        -- Also search ServerStorage configs that might be replicated
        Log("--- BUSCANDO CONFIGS DE RATES EN TODO EL JUEGO ---", Color3.fromRGB(255, 150, 50))
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("ModuleScript") and not obj:GetFullName():match("CorePackages") then
                local n = obj.Name:lower()
                if (n:match("rate") or n:match("chance") or n:match("rarity") or n:match("weight") or n:match("probability")) and (n:match("fruit") or n:match("spin") or n:match("gacha") or n:match("roll")) then
                    Log("FOUND: " .. obj:GetFullName(), Color3.fromRGB(255, 130, 50))
                    local mod = pcall(function() return require(obj) end) and require(obj) or nil
                    if mod and type(mod) == "table" then
                        for k, v in pairs(mod) do
                            Log("  " .. tostring(k) .. " = " .. SerializeValue(v), Color3.fromRGB(255, 200, 130))
                        end
                    end
                end
            end
        end
    end)
    
    Log("========== FIN DUMP ==========", Color3.fromRGB(100, 200, 255))
    SaveLog()
end

-- ======================== SCAN FRUTAS ========================
local function ScanFrutas()
    Log("========== SCAN FRUTAS ==========", Color3.fromRGB(255, 150, 50))
    pcall(function()
        -- Backpack tools con FruitPowerType
        Log("--- FRUTAS EN BACKPACK ---", Color3.fromRGB(255, 200, 100))
        for _, tool in pairs(LP.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local fpt = tool:FindFirstChild("FruitPowerType")
                if fpt then
                    Log("  FRUTA: " .. tool.Name .. " | FruitPowerType=" .. fpt.Value .. " | CanDrop=" .. tostring(tool.CanBeDropped), Color3.fromRGB(255, 200, 130))
                end
            end
        end
        local char = LP.Character
        if char then
            for _, tool in pairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    local fpt = tool:FindFirstChild("FruitPowerType")
                    if fpt then
                        Log("  FRUTA [EQUIPPED]: " .. tool.Name .. " | FruitPowerType=" .. fpt.Value, Color3.fromRGB(255, 255, 130))
                    end
                end
            end
        end
        
        -- All fruit remotes
        Log("--- REMOTES PARA FRUTAS ---", Color3.fromRGB(255, 200, 100))
        for _, obj in pairs(game:GetDescendants()) do
            if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) and not obj:GetFullName():match("CorePackages") then
                local n = obj.Name:lower()
                if n:match("fruit") or n:match("reroll") or n:match("spin") or n:match("drop") then
                    Log("  " .. obj:GetFullName() .. " [" .. obj.ClassName .. "]", Color3.fromRGB(255, 180, 100))
                end
            end
        end
    end)
    SaveLog()
end

-- ======================== SCAN INVENTARIO ========================
local function ScanInventario()
    Log("========== INVENTARIO ==========", Color3.fromRGB(130, 200, 255))
    pcall(function()
        Log("--- BACKPACK ---", Color3.fromRGB(200, 220, 255))
        for i, tool in pairs(LP.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                Log("  [" .. i .. "] " .. tool.Name .. " | Tip='" .. tool.ToolTip .. "' | Drop=" .. tostring(tool.CanBeDropped) .. " | Handle=" .. tostring(tool.RequiresHandle), Color3.fromRGB(180, 210, 240))
                for _, v in pairs(tool:GetDescendants()) do
                    if v:IsA("ValueBase") then
                        Log("      " .. v.Name .. " = " .. tostring(v.Value) .. " [" .. v.ClassName .. "]", Color3.fromRGB(160, 190, 220))
                    end
                end
            end
        end
        local char = LP.Character
        if char then
            Log("--- EN MANO ---", Color3.fromRGB(200, 220, 255))
            for _, tool in pairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    Log("  [EQ] " .. tool.Name, Color3.fromRGB(255, 230, 160))
                    for _, v in pairs(tool:GetDescendants()) do
                        if v:IsA("ValueBase") then
                            Log("      " .. v.Name .. " = " .. tostring(v.Value), Color3.fromRGB(230, 210, 150))
                        end
                    end
                end
            end
        end
    end)
    SaveLog()
end

-- ======================== TEST MOVEMENT ========================
local function TestMovement()
    Log("========== TEST MOVIMIENTO ==========", Color3.fromRGB(80, 255, 80))
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then Log("Sin personaje"); return end
    local hrp = char.HumanoidRootPart
    local hum = char.Humanoid
    
    Log("WalkSpeed=" .. hum.WalkSpeed .. " JumpHeight=" .. hum.JumpHeight .. " HP=" .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth), Color3.fromRGB(130, 255, 130))
    Log("Pos=" .. string.format("%.1f,%.1f,%.1f", hrp.Position.X, hrp.Position.Y, hrp.Position.Z), Color3.fromRGB(130, 255, 130))
    
    -- Test PivotTo
    local p1 = hrp.Position
    pcall(function() char:PivotTo(hrp.CFrame * CFrame.new(0, 0, -3)) end)
    task.wait(0.15)
    local d1 = (hrp.Position - p1).Magnitude
    Log("PivotTo(-3z): " .. string.format("%.2f", d1) .. " studs " .. (d1 > 1 and "✅" or "❌"), d1 > 1 and Color3.fromRGB(90, 255, 90) or Color3.fromRGB(255, 90, 90))
    pcall(function() char:PivotTo(CFrame.new(p1)) end)
    task.wait(0.1)
    
    -- Test MoveTo
    local p2 = hrp.Position
    pcall(function() hum:MoveTo(p2 + Vector3.new(5, 0, 0)) end)
    task.wait(0.5)
    local d2 = (hrp.Position - p2).Magnitude
    Log("MoveTo(+5x): " .. string.format("%.2f", d2) .. " studs " .. (d2 > 1 and "✅" or "❌"), d2 > 1 and Color3.fromRGB(90, 255, 90) or Color3.fromRGB(255, 90, 90))
    pcall(function() char:PivotTo(CFrame.new(p1)) end)
    task.wait(0.1)
    
    -- Test large distance PivotTo
    local p3 = hrp.Position
    pcall(function() char:PivotTo(hrp.CFrame * CFrame.new(0, 0, -50)) end)
    task.wait(0.2)
    local d3 = (hrp.Position - p3).Magnitude
    Log("PivotTo(-50z): " .. string.format("%.2f", d3) .. " studs " .. (d3 > 10 and "✅" or "❌ ANTI-TP?"), d3 > 10 and Color3.fromRGB(90, 255, 90) or Color3.fromRGB(255, 90, 90))
    pcall(function() char:PivotTo(CFrame.new(p1)) end)
    
    -- Body movers check
    Log("--- BODY MOVERS ---", Color3.fromRGB(200, 200, 100))
    for _, c in pairs(hrp:GetChildren()) do
        Log("  " .. c.Name .. " [" .. c.ClassName .. "]", Color3.fromRGB(200, 200, 160))
    end
    
    SaveLog()
end

-- ======================== BUTTON CONNECTIONS ========================
BtnSpy.MouseButton1Click:Connect(function()
    SpyActive = not SpyActive
    if SpyActive then
        BtnSpy.Text = "📡 SPY: ON"
        BtnSpy.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        Log(">>> REMOTE SPY ACTIVADO <<<", Color3.fromRGB(90, 255, 90))
        StartSpy()
    else
        BtnSpy.Text = "📡 SPY: OFF"
        BtnSpy.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
        Log(">>> REMOTE SPY DESACTIVADO <<<", Color3.fromRGB(255, 130, 130))
        SaveLog()
    end
end)

BtnPos.MouseButton1Click:Connect(function()
    PosTrackActive = not PosTrackActive
    if PosTrackActive then
        BtnPos.Text = "📍 POS: ON"
        BtnPos.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        Log(">>> POSITION TRACKING ON <<<", Color3.fromRGB(90, 255, 90))
    else
        BtnPos.Text = "📍 POS: OFF"
        BtnPos.BackgroundColor3 = Color3.fromRGB(30, 50, 30)
        Log(">>> POSITION TRACKING OFF <<<", Color3.fromRGB(255, 200, 100))
    end
end)

BtnDump.MouseButton1Click:Connect(function() task.spawn(DumpConfigs) end)
BtnSave.MouseButton1Click:Connect(function() SaveLog() end)
BtnFruit.MouseButton1Click:Connect(function() task.spawn(ScanFrutas) end)
BtnInventory.MouseButton1Click:Connect(function() task.spawn(ScanInventario) end)
BtnTest.MouseButton1Click:Connect(function() task.spawn(TestMovement) end)

BtnClear.MouseButton1Click:Connect(function()
    for _, c in pairs(LogScroll:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end
    LogOrder = 0
    Log("Log limpiado", Color3.fromRGB(200, 200, 200))
end)

-- Minimize
local Minimized = false
BtnMin.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    LogScroll.Visible = not Minimized
    BtnBar.Visible = not Minimized
    MF.Size = Minimized and UDim2.new(0, 520, 0, 28) or UDim2.new(0, 520, 0, 440)
end)

-- Hotkey L = toggle GUI
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.L then
        MF.Visible = not MF.Visible
    end
end)

-- ======================== INICIO ========================
Log("🔴 Live Scanner activo — Hotkey L para toggle", Color3.fromRGB(255, 255, 100))
Log("1. Activa SPY → haz acciones → captura args en vivo", Color3.fromRGB(200, 200, 200))
Log("2. DUMP CONFIGS → extrae tablas de CombatConfig/FruitPower/Ability", Color3.fromRGB(200, 200, 200))
Log("3. POS TRACK → monitorea tu posición y estados", Color3.fromRGB(200, 200, 200))
Log("Colores: 🟠Frutas 🔴Combate 🟢Movimiento 🟣Compras", Color3.fromRGB(200, 200, 200))
Log("", Color3.fromRGB(100, 100, 100))
