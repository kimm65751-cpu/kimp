-- InvisibilityAudit.local.lua
-- Test-only probe for your own experience

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer

local CFG = {
    AutoStart = false,

    -- Deja nil para auto-detectar una Tool con FruitModel/IsFruitTool
    FruitToolName = nil,

    -- Remote S->C que ya viste en tus logs
    ResponseRemoteName = "FruitPowerResponse",

    -- "tool" = intenta usar la fruta con Tool:Activate()
    -- "remote" = usa un RemoteEvent/RemoteFunction tuyo
    ActivationMode = "tool",

    -- Solo se usa si ActivationMode = "remote"
    ActivateRemotePath = "Remotes.UseFruitPower",
    ActivateRemoteKind = "Event", -- "Event" | "Function"
    ActivateArgs = function()
        -- Ajusta esto solo si usas modo "remote"
        -- Ejemplo:
        -- return table.pack("Invisible", "Z")
        return table.pack("Invisible", "Z")
    end,

    StartTimeout = 8,
    EndTimeout = 24,

    -- Intentos de reactivar durante la invisibilidad
    ReattemptFractions = { 0.50, 0.90, 0.99, 1.05 },

    -- Espera mínima entre casos. Si el server informa cooldown, usa el mayor.
    InterCaseWait = 16,

    InvisiblePartThreshold = 0.70,
    VisiblePartThreshold = 0.25,

    LogFile = "InvisibilityAudit.txt",
}

local function round(n, p)
    local m = 10 ^ (p or 0)
    return math.floor(n * m + 0.5) / m
end

local function resolvePath(root, path)
    local node = root
    for segment in string.gmatch(path, "[^%.]+") do
        node = node and node:FindFirstChild(segment)
    end
    return node
end

local function autoFindRemoteByName(root, name, className)
    local direct = root:FindFirstChild(name, true)
    if direct and (not className or direct:IsA(className)) then
        return direct
    end
    for _, obj in ipairs(root:GetDescendants()) do
        if obj.Name == name and (not className or obj:IsA(className)) then
            return obj
        end
    end
    return nil
end

local function fmt(value, depth, seen)
    depth = depth or 0
    seen = seen or {}
    if depth > 3 then
        return "..."
    end

    local t = typeof(value)
    if t == "string" then
        return string.format("%q", value)
    end
    if t == "number" or t == "boolean" or t == "nil" then
        return tostring(value)
    end
    if t == "Vector3" then
        return string.format("Vector3(%.1f, %.1f, %.1f)", value.X, value.Y, value.Z)
    end
    if t == "Instance" then
        return string.format("Instance(%s)", value:GetFullName())
    end
    if t == "table" then
        if seen[value] then
            return "{<cycle>}"
        end
        seen[value] = true
        local out = {}
        local count = 0
        for k, v in pairs(value) do
            count += 1
            out[#out + 1] = tostring(k) .. "=" .. fmt(v, depth + 1, seen)
            if count >= 10 then
                out[#out + 1] = "..."
                break
            end
        end
        return "{" .. table.concat(out, ", ") .. "}"
    end
    return tostring(value)
end

-- =====================
-- UI
-- =====================

local TargetGui = pcall(function() return CoreGui.Name end) and CoreGui or LP:WaitForChild("PlayerGui")
for _, child in ipairs(TargetGui:GetChildren()) do
    if child.Name == "InvisibilityAuditGui" then
        pcall(function() child:Destroy() end)
    end
end

local SG = Instance.new("ScreenGui")
SG.Name = "InvisibilityAuditGui"
SG.ResetOnSpawn = false
SG.Parent = TargetGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 520, 0, 360)
Main.Position = UDim2.new(0, 20, 0, 20)
Main.BackgroundColor3 = Color3.fromRGB(20, 23, 30)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = SG
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -12, 0, 28)
Title.Position = UDim2.new(0, 8, 0, 6)
Title.BackgroundTransparency = 1
Title.Text = "Invisibility Audit"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextColor3 = Color3.fromRGB(210, 220, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = Main

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -12, 0, 18)
Status.Position = UDim2.new(0, 8, 0, 34)
Status.BackgroundTransparency = 1
Status.Text = "Idle"
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.TextColor3 = Color3.fromRGB(150, 160, 190)
Status.Font = Enum.Font.Gotham
Status.TextSize = 11
Status.Parent = Main

local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(0, 160, 0, 28)
StartBtn.Position = UDim2.new(0, 8, 0, 58)
StartBtn.BackgroundColor3 = Color3.fromRGB(70, 145, 95)
StartBtn.Text = "Run Audit"
StartBtn.TextColor3 = Color3.new(1, 1, 1)
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextSize = 12
StartBtn.Parent = Main
Instance.new("UICorner", StartBtn).CornerRadius = UDim.new(0, 6)

local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0, 100, 0, 28)
ClearBtn.Position = UDim2.new(0, 176, 0, 58)
ClearBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
ClearBtn.Text = "Clear"
ClearBtn.TextColor3 = Color3.new(1, 1, 1)
ClearBtn.Font = Enum.Font.GothamBold
ClearBtn.TextSize = 12
ClearBtn.Parent = Main
Instance.new("UICorner", ClearBtn).CornerRadius = UDim.new(0, 6)

local LogWrap = Instance.new("ScrollingFrame")
LogWrap.Size = UDim2.new(1, -16, 1, -96)
LogWrap.Position = UDim2.new(0, 8, 0, 92)
LogWrap.BackgroundColor3 = Color3.fromRGB(15, 17, 22)
LogWrap.BorderSizePixel = 0
LogWrap.ScrollBarThickness = 4
LogWrap.CanvasSize = UDim2.new(0, 0, 0, 0)
LogWrap.Parent = Main
Instance.new("UICorner", LogWrap).CornerRadius = UDim.new(0, 6)

local LogList = Instance.new("UIListLayout")
LogList.Padding = UDim.new(0, 2)
LogList.Parent = LogWrap

LogList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    LogWrap.CanvasSize = UDim2.new(0, 0, 0, LogList.AbsoluteContentSize.Y + 8)
    LogWrap.CanvasPosition = Vector2.new(0, math.max(0, LogList.AbsoluteContentSize.Y - LogWrap.AbsoluteWindowSize.Y))
end)

local function addLine(text, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -8, 0, 18)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = color or Color3.fromRGB(210, 210, 220)
    label.Font = Enum.Font.Code
    label.TextSize = 11
    label.Text = text
    label.Parent = LogWrap
end

local function appendFileLine(text)
    local line = string.format("[%s] %s\n", os.date("%H:%M:%S"), text)

    if appendfile then
        pcall(function()
            appendfile(CFG.LogFile, line)
        end)
        return
    end

    if writefile then
        local prev = ""
        pcall(function()
            if readfile and isfile and isfile(CFG.LogFile) then
                prev = readfile(CFG.LogFile)
            end
        end)
        pcall(function()
            writefile(CFG.LogFile, prev .. line)
        end)
    end
end

local function log(text, color)
    local line = string.format("[%s] %s", os.date("%H:%M:%S"), text)
    addLine(line, color)
    print(line)
    appendFileLine(text)
end

local function setStatus(text, color)
    Status.Text = text
    Status.TextColor3 = color or Color3.fromRGB(150, 160, 190)
end

ClearBtn.MouseButton1Click:Connect(function()
    for _, child in ipairs(LogWrap:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
end)

-- =====================
-- Discovery
-- =====================

local ResponseRemote = autoFindRemoteByName(ReplicatedStorage, CFG.ResponseRemoteName, "RemoteEvent")
local ActivateRemote = nil
if CFG.ActivationMode == "remote" then
    ActivateRemote = resolvePath(ReplicatedStorage, CFG.ActivateRemotePath)
end

local HookedTools = {}

local currentCase = nil
local running = false

local windowSeq = 0
local activeWindow = nil
local completedWindows = {}
local localInvisible = false
local lastKnownCooldown = nil

local function looksLikeFruitTool(tool)
    if not tool or not tool:IsA("Tool") then
        return false
    end
    if CFG.FruitToolName and tool.Name == CFG.FruitToolName then
        return true
    end
    if tool:FindFirstChild("IsFruitTool") then
        return true
    end
    if tool:FindFirstChild("FruitModel") then
        return true
    end
    local n = tool.Name:lower()
    return n:find("fruit") ~= nil
        or n:find("shadow") ~= nil
        or n:find("invis") ~= nil
        or n:find("cloak") ~= nil
end

local function findFruitTool()
    local char = LP.Character
    if char then
        for _, obj in ipairs(char:GetChildren()) do
            if looksLikeFruitTool(obj) then
                return obj
            end
        end
    end
    for _, obj in ipairs(LP.Backpack:GetChildren()) do
        if looksLikeFruitTool(obj) then
            return obj
        end
    end
    return nil
end

local function pushEvent(kind, data)
    if not currentCase then
        return
    end
    local now = os.clock()
    local row = {
        t = now,
        dt = round(now - currentCase.startedAt, 2),
        kind = kind,
        data = data,
    }
    table.insert(currentCase.events, row)
    log(string.format("[%s] %s %s", currentCase.name, kind, data and fmt(data) or ""), Color3.fromRGB(200, 210, 230))
end

local function hookTool(tool)
    if not tool or HookedTools[tool] then
        return
    end
    HookedTools[tool] = true

    tool.Equipped:Connect(function()
        pushEvent("tool_equipped", { tool = tool.Name })
    end)

    tool.Activated:Connect(function()
        pushEvent("tool_activated", { tool = tool.Name })
    end)

    tool.Unequipped:Connect(function()
        pushEvent("tool_unequipped", { tool = tool.Name })
    end)
end

local function hookCurrentTools()
    local char = LP.Character
    if char then
        for _, obj in ipairs(char:GetChildren()) do
            if obj:IsA("Tool") then
                hookTool(obj)
            end
        end
        char.ChildAdded:Connect(function(obj)
            if obj:IsA("Tool") then
                hookTool(obj)
            end
        end)
    end
    LP.Backpack.ChildAdded:Connect(function(obj)
        if obj:IsA("Tool") then
            hookTool(obj)
        end
    end)
    for _, obj in ipairs(LP.Backpack:GetChildren()) do
        if obj:IsA("Tool") then
            hookTool(obj)
        end
    end
end

local function ensureEquipped(tool)
    if not tool then
        return false
    end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hum then
        return false
    end

    if tool.Parent == char then
        return true
    end

    hum:EquipTool(tool)
    task.wait(0.15)
    return tool.Parent == char
end

local function fireActivation(reason)
    pushEvent("attempt_activation", { reason = reason, mode = CFG.ActivationMode })

    if CFG.ActivationMode == "tool" then
        local tool = findFruitTool()
        if not tool then
            pushEvent("activation_failed", { why = "no fruit tool found" })
            return false
        end
        hookTool(tool)
        ensureEquipped(tool)
        local ok, err = pcall(function()
            tool:Activate()
        end)
        if not ok then
            pushEvent("activation_failed", { why = tostring(err) })
            return false
        end
        return true
    end

    if CFG.ActivationMode == "remote" then
        if not ActivateRemote then
            pushEvent("activation_failed", { why = "activate remote not found" })
            return false
        end
        local args = CFG.ActivateArgs()
        local ok, err = pcall(function()
            if CFG.ActivateRemoteKind == "Function" then
                ActivateRemote:InvokeServer(table.unpack(args, 1, args.n or #args))
            else
                ActivateRemote:FireServer(table.unpack(args, 1, args.n or #args))
            end
        end)
        if not ok then
            pushEvent("activation_failed", { why = tostring(err) })
            return false
        end
        return true
    end

    pushEvent("activation_failed", { why = "unknown activation mode" })
    return false
end

local function getVisibilityRatio()
    local char = LP.Character
    if not char then
        return 0, 0
    end

    local invisibleParts = 0
    local totalParts = 0

    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
            totalParts += 1
            local localT = 0
            pcall(function() localT = obj.LocalTransparencyModifier end)
            local finalT = math.max(obj.Transparency, localT)
            if finalT >= 0.85 then
                invisibleParts += 1
            end
        end
    end

    if totalParts == 0 then
        return 0, 0
    end

    return invisibleParts / totalParts, totalParts
end

RunService.Heartbeat:Connect(function()
    if not currentCase then
        return
    end

    local ratio, count = getVisibilityRatio()

    if not localInvisible and count > 0 and ratio >= CFG.InvisiblePartThreshold then
        localInvisible = true
        pushEvent("local_invisible", { ratio = round(ratio, 2), parts = count })
    elseif localInvisible and (count == 0 or ratio <= CFG.VisiblePartThreshold) then
        localInvisible = false
        pushEvent("local_visible", { ratio = round(ratio, 2), parts = count })
    end
end)

if ResponseRemote then
    ResponseRemote.OnClientEvent:Connect(function(...)
        local args = table.pack(...)
        local kind = nil
        local data = nil

        if type(args[1]) == "string" then
            kind = args[1]
            data = args[2]
        elseif type(args[1]) == "table" then
            data = args[1]
            kind = data.Type or data.Action or data.State or data.Name
        end

        if type(data) == "table" and data.Player and data.Player ~= LP then
            return
        end

        if kind == "PlayerInvisible" then
            pushEvent("server_invisible", data)

            if not activeWindow then
                windowSeq += 1
                activeWindow = {
                    id = windowSeq,
                    startedAt = os.clock(),
                    serverDuration = type(data) == "table" and data.Duration or nil,
                    cooldown = nil,
                    refreshes = 0,
                }
            else
                activeWindow.refreshes += 1
            end
        elseif kind == "CooldownStarted" then
            pushEvent("server_cooldown", data)
            local dur = type(data) == "table" and data.Duration or nil
            if dur then
                lastKnownCooldown = dur
            end
            if activeWindow then
                activeWindow.cooldown = dur
            end
        elseif kind == "PlayerVisible" then
            pushEvent("server_visible", data)
            if activeWindow then
                activeWindow.endedAt = os.clock()
                activeWindow.measured = activeWindow.endedAt - activeWindow.startedAt
                completedWindows[activeWindow.id] = activeWindow
                activeWindow = nil
            end
        else
            pushEvent("server_other", { raw = fmt(args) })
        end
    end)
else
    log("No encontre ResponseRemote '" .. CFG.ResponseRemoteName .. "'", Color3.fromRGB(255, 160, 160))
end

local function waitUntil(predicate, timeout)
    local started = os.clock()
    while os.clock() - started <= timeout do
        if predicate() then
            return true
        end
        task.wait(0.05)
    end
    return false
end

local function beginCase(name)
    currentCase = {
        name = name,
        startedAt = os.clock(),
        events = {},
    }
    localInvisible = false
end

local function endCase()
    local c = currentCase
    currentCase = nil
    return c
end

local function analyzeCase(caseData, targetWindowId, baselineDuration, attemptDt)
    local win = completedWindows[targetWindowId]
    local result = {
        case = caseData.name,
        windowId = targetWindowId,
        baseline = baselineDuration,
        measured = win and round(win.measured or 0, 2) or nil,
        serverDuration = win and win.serverDuration or nil,
        cooldown = win and win.cooldown or lastKnownCooldown,
        refreshes = win and (win.refreshes or 0) or 0,
        verdict = "indeterminate",
    }

    local firstInvisibleDt = nil
    local serverVisibleDt = nil
    local secondInvisibleAfterAttempt = false
    local localVisibleBeforeServer = false
    local activationObserved = false

    for _, evt in ipairs(caseData.events) do
        if evt.kind == "tool_activated" then
            activationObserved = true
        elseif evt.kind == "server_invisible" then
            if not firstInvisibleDt then
                firstInvisibleDt = evt.dt
            elseif attemptDt and evt.dt > attemptDt - 0.05 then
                secondInvisibleAfterAttempt = true
            end
        elseif evt.kind == "server_visible" then
            serverVisibleDt = serverVisibleDt or evt.dt
        elseif evt.kind == "local_visible" and firstInvisibleDt and not serverVisibleDt then
            localVisibleBeforeServer = true
        end
    end

    if caseData.name == "baseline" then
        if result.measured then
            result.verdict = "baseline_ok"
        else
            result.verdict = activationObserved and "baseline_no_server_window" or "baseline_activation_not_observed"
        end
        return result
    end

    local extended = false
    if baselineDuration and result.measured then
        extended = result.measured > (baselineDuration + 0.75)
    end

    if secondInvisibleAfterAttempt or result.refreshes > 0 or extended then
        result.verdict = "reapply_accepted_or_extended"
    elseif localVisibleBeforeServer then
        result.verdict = "client_module_restored_visibility"
    elseif baselineDuration and result.measured and math.abs(result.measured - baselineDuration) <= 0.75 then
        result.verdict = "server_fixed_duration"
    elseif not activationObserved then
        result.verdict = "activation_path_not_observed"
    else
        result.verdict = "blocked_or_unknown"
    end

    return result
end

local function runSingleCase(name, fraction, baselineDuration)
    beginCase(name)
    setStatus("Running " .. name, Color3.fromRGB(180, 210, 255))

    local preWindowSeq = windowSeq
    local ok = fireActivation("case_start")
    if not ok then
        local ended = endCase()
        return {
            case = name,
            verdict = "activation_failed",
        }
    end

    local started = waitUntil(function()
        return windowSeq > preWindowSeq
    end, CFG.StartTimeout)

    if not started then
        local ended = endCase()
        return analyzeCase(ended, -1, baselineDuration, nil)
    end

    local targetWindowId = windowSeq
    local targetWindow = activeWindow
    local attemptDt = nil

    if fraction then
        local refDuration = baselineDuration or (targetWindow and targetWindow.serverDuration) or 0
        local delay = math.max(0, refDuration * fraction)

        local okWait = waitUntil(function()
            return activeWindow == nil or (os.clock() - targetWindow.startedAt) >= delay
        end, math.max(1, delay + 1.5))

        if okWait then
            attemptDt = round(os.clock() - currentCase.startedAt, 2)
            fireActivation("reattempt_" .. tostring(fraction))
        end
    end

    waitUntil(function()
        return completedWindows[targetWindowId] ~= nil
    end, CFG.EndTimeout)

    local ended = endCase()
    return analyzeCase(ended, targetWindowId, baselineDuration, attemptDt)
end

local function runAudit()
    if running then
        return
    end
    running = true

    log("===== AUDIT START =====", Color3.fromRGB(120, 255, 160))
    log("ResponseRemote = " .. tostring(ResponseRemote and ResponseRemote:GetFullName() or "nil"))
    log("ActivationMode = " .. CFG.ActivationMode)
    log("FruitTool = " .. tostring(findFruitTool() and findFruitTool().Name or "nil"))
    if CFG.ActivationMode == "remote" then
        log("ActivateRemote = " .. tostring(ActivateRemote and ActivateRemote:GetFullName() or "nil"))
    end

    if not ResponseRemote then
        setStatus("Missing FruitPowerResponse", Color3.fromRGB(255, 150, 150))
        running = false
        return
    end

    hookCurrentTools()

    local results = {}

    local baseline = runSingleCase("baseline", nil, nil)
    table.insert(results, baseline)
    log("BASELINE => " .. fmt(baseline), Color3.fromRGB(255, 220, 140))

    local baselineDuration = baseline.measured or baseline.serverDuration
    local interWait = math.max(CFG.InterCaseWait, tonumber(baseline.cooldown) or 0)

    if not baselineDuration then
        log("No pude medir ventana baseline. Si tu fruta no usa Tool:Activate(), cambia a ActivationMode='remote'.", Color3.fromRGB(255, 160, 160))
        setStatus("Baseline failed", Color3.fromRGB(255, 160, 160))
        running = false
        return
    end

    task.wait(interWait + 0.5)

    for _, fraction in ipairs(CFG.ReattemptFractions) do
        local name = "reapply_" .. tostring(fraction)
        local res = runSingleCase(name, fraction, baselineDuration)
        table.insert(results, res)
        log(name .. " => " .. fmt(res), Color3.fromRGB(180, 220, 255))
        task.wait(interWait + 0.5)
    end

    log("===== SUMMARY =====", Color3.fromRGB(120, 255, 160))
    for _, res in ipairs(results) do
        log(string.format(
            "%s | verdict=%s | measured=%s | server=%s | cooldown=%s | refreshes=%s",
            tostring(res.case),
            tostring(res.verdict),
            tostring(res.measured),
            tostring(res.serverDuration),
            tostring(res.cooldown),
            tostring(res.refreshes)
        ), Color3.fromRGB(220, 220, 220))
    end

    setStatus("Audit complete", Color3.fromRGB(120, 255, 160))
    running = false
end

StartBtn.MouseButton1Click:Connect(runAudit)

LP.CharacterAdded:Connect(function()
    task.wait(1)
    hookCurrentTools()
end)

hookCurrentTools()
log("Probe loaded. Run Audit cuando tengas equipada la fruta.", Color3.fromRGB(180, 210, 255))

if CFG.AutoStart then
    task.delay(2, runAudit)
end
