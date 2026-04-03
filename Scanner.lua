local existing = rawget(_G, "RobloxUniversalAuditScanner")
if existing and existing.stop then
    pcall(function()
        existing.stop("Replaced")
    end)
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local CollectionService = game:GetService("CollectionService")
local LP = Players.LocalPlayer

local function safeGetService(name)
    local ok, service = pcall(game.GetService, game, name)
    if ok then
        return service
    end
    return nil
end

local CONFIG = {
    uiName = "RobloxUniversalAuditScanner",
    filePrefix = "Roblox_Universal_Audit_Scanner_",
    fileExt = ".txt",
    flushInterval = 1,
    workerIdle = 0.12,
    yieldEvery = 140,
    bufferMax = 35,
    maxUiLines = 220,
    maxDescPerPhase = 7000,
    maxRemoteLogs = 260,
    maxScriptLogs = 320,
    maxDeepTargets = 14,
    maxCodePreview = 1200,
    maxCodeSignalLines = 14,
    maxExamplesPerCategory = 8,
    maxExportEntries = 18,
    maxSignalsPerRemote = 3
}

local COMMON_SERVICES = {
    "Players", "Workspace", "ReplicatedStorage", "ReplicatedFirst", "StarterGui",
    "StarterPack", "StarterPlayer", "Lighting", "SoundService", "RunService",
    "UserInputService", "TweenService", "HttpService", "MarketplaceService",
    "Chat", "Teams", "CoreGui", "TextChatService", "CollectionService",
    "ServerStorage", "ServerScriptService", "ScriptContext", "NetworkClient"
}

local FRAMEWORK_SIGNATURES = {
    Knit = { "knit", "controller", "service" },
    Aero = { "aero", "aerogameframework" },
    Fusion = { "fusion" },
    Roact = { "roact" },
    React = { "react", "reactroblox" },
    Matter = { "matter" },
    Flamework = { "flamework" },
    Replica = { "replica", "replicaservice" },
    ProfileService = { "profileservice" },
    Cmdr = { "cmdr" },
    Nevermore = { "nevermore" },
    Adonis = { "adonis" }
}

local SCORE_KEYWORDS = {
    remote = 8, network = 8, reward = 8, loot = 7, drop = 7, damage = 9,
    health = 8, combat = 9, fight = 9, skill = 8, attack = 8, weapon = 7,
    inventory = 8, backpack = 7, bag = 6, item = 5, pickup = 7, egg = 7,
    hatch = 7, pet = 8, companion = 7, mount = 7, monster = 8, mob = 8,
    npc = 7, boss = 8, quest = 7, shop = 6, teleport = 6, portal = 6,
    data = 7, save = 7, load = 7, anti = 10, cheat = 10, detect = 9,
    exploit = 10, honeypot = 11, honey = 8, trap = 7, kick = 9, ban = 9,
    security = 9, admin = 8, currency = 7, coin = 7, cash = 7, gem = 7,
    enchant = 7, craft = 7, forge = 7, dungeon = 7, raid = 7, event = 7,
    island = 7, isla = 7, float = 7, fly = 8, speed = 7, jump = 7,
    reroll = 8, roll = 7, fragment = 8, melee = 7, sword = 7, accessory = 7,
    key = 7, seal = 8, stat = 7, money = 7, upper = 5, moon = 6, slayer = 6
}

local CODE_SIGNAL_KEYWORDS = {
    "fireserver", "invokeserver", "onclientevent", "onclientinvoke", "require",
    "getservice", "damage", "health", "reward", "inventory", "backpack", "item",
    "pet", "monster", "npc", "anti", "kick", "ban", "teleport", "prompt",
    "clickdetector", "tool", "quest", "shop", "dungeon", "raid", "event",
    "island", "isla", "float", "fly", "speed", "jump", "doublejump",
    "reroll", "roll", "fragment", "money", "accessory", "melee", "sword",
    "key", "seal", "stat", "drop", "moon", "slayer"
}

local NETWORK_METHODS = {
    FireServer = true,
    InvokeServer = true
}

local State = {
    active = true,
    file = nil,
    buffer = {},
    uiLines = {},
    connections = {},
    taskQueue = {},
    taskWorker = nil,
    scanRound = 0,
    queueBusy = false,
    liveNetwork = true,
    incomingRemoteCounts = {},
    outgoingRemoteCounts = {},
    hookedIncoming = {},
    findings = {
        frameworks = {},
        services = {},
        remotes = {},
        scripts = {},
        deepTargets = {},
        security = {},
        world = {},
        gui = {},
        mapLinks = {},
        datasets = {}
    },
    ui = {}
}
_G.RobloxUniversalAuditScanner = State

local scheduleFullScan
local scheduleScriptScan
local scheduleWorldScan
local scheduleRemoteScan
local scanScripts
local scanWorld
local scanRemotes
local scanSecurityAndSummary

local function lower(value)
    return string.lower(tostring(value or ""))
end

local function trimText(value, limit)
    local text = tostring(value or "")
    local max = limit or 220
    if #text > max then
        return string.sub(text, 1, max) .. "..."
    end
    return text
end

local function safeTostring(value, depth)
    depth = depth or 0
    if depth > 2 then
        return "..."
    end

    local valueType = typeof(value)
    if valueType == "Instance" then
        return value:GetFullName()
    end
    if valueType == "Vector3" then
        return string.format("%.2f, %.2f, %.2f", value.X, value.Y, value.Z)
    end
    if valueType == "CFrame" then
        local p = value.Position
        return string.format("%.2f, %.2f, %.2f", p.X, p.Y, p.Z)
    end

    if type(value) == "table" then
        local parts = {}
        local count = 0
        for key, inner in pairs(value) do
            count = count + 1
            if count > 8 then
                table.insert(parts, "...")
                break
            end
            table.insert(parts, tostring(key) .. "=" .. safeTostring(inner, depth + 1))
        end
        table.sort(parts)
        return "{" .. table.concat(parts, " | ") .. "}"
    end

    return tostring(value)
end

local function summarizeArray(values, maxItems)
    local out = {}
    local limit = maxItems or 6
    for index, value in ipairs(values or {}) do
        if index > limit then
            table.insert(out, "...")
            break
        end
        table.insert(out, safeTostring(value))
    end
    return out
end

local function addConnection(conn)
    table.insert(State.connections, conn)
    return conn
end

local function cleanupConnections()
    for _, conn in ipairs(State.connections) do
        pcall(function()
            conn:Disconnect()
        end)
    end
    State.connections = {}
end

local function getGuiParent()
    local ok = pcall(function()
        return CoreGui.Name
    end)
    if ok then
        return CoreGui
    end
    return LP:WaitForChild("PlayerGui")
end

local function getCharacterRoot()
    local char = LP.Character
    if not char then
        return nil
    end
    return char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
end

local function getRootPart(root)
    if not root or not root.Parent then
        return nil
    end
    if root:IsA("BasePart") then
        return root
    end
    if root:IsA("Tool") then
        return root:FindFirstChild("Handle") or root:FindFirstChildWhichIsA("BasePart", true)
    end
    if root:IsA("Model") then
        return root.PrimaryPart or root:FindFirstChildWhichIsA("BasePart", true)
    end
    return root:FindFirstChildWhichIsA("BasePart", true)
end

local function getNextFileName()
    if not (writefile and isfile) then
        return nil
    end
    local idx = 1
    while isfile(CONFIG.filePrefix .. idx .. CONFIG.fileExt) do
        idx = idx + 1
    end
    return CONFIG.filePrefix .. idx .. CONFIG.fileExt
end

local function flushFile()
    if not State.file or #State.buffer == 0 then
        return
    end
    local chunk = table.concat(State.buffer, "\n") .. "\n"
    State.buffer = {}
    if appendfile then
        pcall(function()
            appendfile(State.file, chunk)
        end)
        return
    end
    if readfile and writefile then
        pcall(function()
            local old = ""
            if isfile and isfile(State.file) then
                old = readfile(State.file)
            end
            writefile(State.file, old .. chunk)
        end)
    end
end

local function ensureFile()
    if State.file or not writefile then
        return
    end
    local fileName = getNextFileName()
    if not fileName then
        return
    end
    State.file = fileName
    local header = table.concat({
        "============================================================",
        " ROBLOX UNIVERSAL AUDIT SCANNER",
        " Date: " .. os.date("%Y-%m-%d %H:%M:%S"),
        " PlaceId=" .. tostring(game.PlaceId) .. " | JobId=" .. tostring(game.JobId),
        " Player=" .. tostring(LP and LP.Name or "unknown"),
        "============================================================",
        ""
    }, "\n")
    pcall(function()
        writefile(fileName, header)
    end)
end

local function updateCanvas()
    local list = State.ui.list
    local scroll = State.ui.logScroll
    if list and scroll then
        scroll.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 8)
        scroll.CanvasPosition = Vector2.new(0, math.max(0, scroll.CanvasSize.Y.Offset))
    end
end

local function addUiLine(text, color)
    local scroll = State.ui.logScroll
    if not scroll then
        return
    end
    local line = Instance.new("TextLabel")
    line.BackgroundTransparency = 1
    line.Size = UDim2.new(1, -8, 0, 18)
    line.AutomaticSize = Enum.AutomaticSize.Y
    line.TextXAlignment = Enum.TextXAlignment.Left
    line.TextYAlignment = Enum.TextYAlignment.Top
    line.TextWrapped = true
    line.Font = Enum.Font.Code
    line.TextSize = 12
    line.TextColor3 = color or Color3.fromRGB(220, 220, 220)
    line.Text = "[" .. os.date("%X") .. "] " .. text
    line.Parent = scroll

    table.insert(State.uiLines, line)
    if #State.uiLines > CONFIG.maxUiLines then
        local removeCount = #State.uiLines - CONFIG.maxUiLines
        for _ = 1, removeCount do
            local old = table.remove(State.uiLines, 1)
            if old then
                old:Destroy()
            end
        end
    end
    updateCanvas()
end

local function writeLine(kind, action, payload, color)
    ensureFile()
    local line = os.date("%H:%M:%S") .. " | " .. tostring(kind) .. " | " .. tostring(action)
    if payload ~= nil then
        line = line .. " | " .. trimText(safeTostring(payload), 700)
    end
    table.insert(State.buffer, line)
    if #State.buffer >= CONFIG.bufferMax then
        flushFile()
    end
    addUiLine(line, color)
end

State.logLine = writeLine

local function startSection(title)
    writeLine("SECTION", title, "------------------------------------------------------------", Color3.fromRGB(255, 230, 140))
end

local function setStatus(text)
    if State.ui.status then
        State.ui.status.Text = "Status: " .. tostring(text)
    end
end

local function yieldMaybe(counter)
    if counter % CONFIG.yieldEvery == 0 then
        task.wait()
    end
end

local function summarizeHierarchy(inst)
    local chain = {}
    local cursor = inst
    local count = 0
    while cursor and count < 12 do
        table.insert(chain, 1, cursor.Name)
        cursor = cursor.Parent
        count = count + 1
    end
    return chain
end

local function makeButton(parent, text, xOffset, width)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, width, 0, 22)
    button.Position = UDim2.new(1, xOffset, 0, 4)
    button.BackgroundColor3 = Color3.fromRGB(70, 95, 120)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 11
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.Parent = parent
    return button
end

local function resetFindings()
    State.findings = {
        frameworks = {},
        services = {},
        remotes = {},
        scripts = {},
        deepTargets = {},
        security = {},
        world = {},
        gui = {},
        mapLinks = {},
        datasets = {}
    }
    State.incomingRemoteCounts = {}
    State.outgoingRemoteCounts = {}
end

local function scoreInterest(name, path, className)
    local probe = lower(name .. " " .. path .. " " .. className)
    local score = 0
    local reasons = {}
    for keyword, weight in pairs(SCORE_KEYWORDS) do
        if string.find(probe, keyword, 1, true) then
            score = score + weight
            table.insert(reasons, keyword)
        end
    end
    if className == "RemoteEvent" or className == "RemoteFunction" then
        score = score + 2
    end
    if string.find(path, "ReplicatedStorage.ClientLogic", 1, true) then
        score = score + 4
        table.insert(reasons, "ClientLogic")
    elseif string.find(path, "PlayerScripts", 1, true) then
        score = score + 3
        table.insert(reasons, "PlayerScripts")
    elseif string.find(path, "ServerScriptService", 1, true) then
        score = score + 4
        table.insert(reasons, "ServerScriptService")
    elseif string.find(path, "ServerStorage", 1, true) then
        score = score + 3
        table.insert(reasons, "ServerStorage")
    end
    table.sort(reasons)
    return score, reasons
end

local function getExecutorCapabilities()
    return {
        identifyexecutor = type(rawget(_G, "identifyexecutor")) == "function",
        getgc = type(rawget(_G, "getgc")) == "function",
        getloadedmodules = type(rawget(_G, "getloadedmodules")) == "function",
        getscripts = type(rawget(_G, "getscripts")) == "function",
        getsenv = type(rawget(_G, "getsenv")) == "function",
        getgenv = type(rawget(_G, "getgenv")) == "function",
        decompile = type(rawget(_G, "decompile")) == "function",
        writefile = type(rawget(_G, "writefile")) == "function",
        appendfile = type(rawget(_G, "appendfile")) == "function",
        readfile = type(rawget(_G, "readfile")) == "function",
        setclipboard = type(rawget(_G, "setclipboard")) == "function",
        hookmetamethod = type(rawget(_G, "hookmetamethod")) == "function",
        hookfunction = type(rawget(_G, "hookfunction")) == "function",
        fireclickdetector = type(rawget(_G, "fireclickdetector")) == "function",
        fireproximityprompt = type(rawget(_G, "fireproximityprompt")) == "function"
    }
end

local function getLoadedModuleSet()
    local set = {}
    if not getloadedmodules then
        return set
    end
    local ok, modules = pcall(getloadedmodules)
    if not ok or type(modules) ~= "table" then
        return set
    end
    for _, inst in ipairs(modules) do
        set[inst] = true
    end
    return set
end

local function getRuntimeGetter(name)
    local debugTable = rawget(_G, "debug")
    if type(debugTable) == "table" and type(debugTable[name]) == "function" then
        return debugTable[name]
    end
    local globalFn = rawget(_G, name)
    if type(globalFn) == "function" then
        return globalFn
    end
    return nil
end

local function getDebugInfo(fn, mask)
    local getter = getRuntimeGetter("getinfo")
    if not getter or type(fn) ~= "function" then
        return nil
    end
    local ok, info = pcall(getter, fn, mask or "Snu")
    if ok and type(info) == "table" then
        return info
    end
    return nil
end

local function extractFunctionConstants(fn)
    local getter = getRuntimeGetter("getconstants")
    if not getter then
        return {}
    end
    local ok, constants = pcall(getter, fn)
    if not ok or type(constants) ~= "table" then
        return {}
    end
    local out = {}
    for _, value in ipairs(constants) do
        local valueType = type(value)
        if valueType == "string" or valueType == "number" or valueType == "boolean" then
            table.insert(out, trimText(safeTostring(value), 80))
        end
        if #out >= 10 then
            break
        end
    end
    return out
end

local function extractFunctionUpvalues(fn)
    local getter = getRuntimeGetter("getupvalues")
    if not getter then
        return {}
    end
    local ok, upvalues = pcall(getter, fn)
    if not ok or type(upvalues) ~= "table" then
        return {}
    end
    local out = {}
    local count = 0
    for key, value in pairs(upvalues) do
        count = count + 1
        table.insert(out, tostring(key) .. "=" .. trimText(safeTostring(value), 100))
        if count >= 10 then
            break
        end
    end
    table.sort(out)
    return out
end

local function summarizeExportValue(value)
    if type(value) ~= "table" then
        return {
            valueType = type(value),
            preview = trimText(safeTostring(value), 140)
        }
    end

    local entries = {}
    local count = 0
    for key, inner in pairs(value) do
        count = count + 1
        local innerType = type(inner)
        local preview = innerType
        if innerType == "function" then
            local info = getDebugInfo(inner, "Snu")
            preview = "function@" .. tostring(info and info.linedefined or "?")
        elseif innerType == "table" then
            local innerCount = 0
            for _ in pairs(inner) do
                innerCount = innerCount + 1
            end
            preview = "table(" .. innerCount .. ")"
        elseif innerType == "string" or innerType == "number" or innerType == "boolean" then
            preview = trimText(safeTostring(inner), 60)
        end
        table.insert(entries, tostring(key) .. "=" .. preview)
        if #entries >= CONFIG.maxExportEntries then
            break
        end
    end
    table.sort(entries)
    return {
        valueType = "table",
        size = count,
        entries = entries
    }
end

local function collectRuntimeKeys(container)
    local matches = {}
    if type(container) ~= "table" then
        return matches
    end
    for key, value in pairs(container) do
        local probe = lower(tostring(key))
        if probe:find("attack", 1, true)
            or probe:find("skill", 1, true)
            or probe:find("health", 1, true)
            or probe:find("reward", 1, true)
            or probe:find("remote", 1, true)
            or probe:find("pet", 1, true)
            or probe:find("monster", 1, true)
            or probe:find("inventory", 1, true)
            or probe:find("quest", 1, true)
            or probe:find("boss", 1, true)
            or probe:find("map", 1, true)
            or probe:find("city", 1, true) then
            table.insert(matches, tostring(key) .. "=" .. trimText(safeTostring(value), 90))
        end
    end
    table.sort(matches)
    while #matches > CONFIG.maxExportEntries do
        table.remove(matches)
    end
    return matches
end

local function recordMapLink(sourcePath, linkType, target, extra)
    table.insert(State.findings.mapLinks, {
        source = sourcePath,
        type = linkType,
        target = target,
        extra = extra
    })
end

local function addDatasetHint(category, sourcePath, hint)
    if not State.findings.datasets[category] then
        State.findings.datasets[category] = {}
    end
    local bucket = State.findings.datasets[category]
    if #bucket < 24 then
        table.insert(bucket, {
            source = sourcePath,
            hint = hint
        })
    end
end

local function tryDecompileScript(scriptInst)
    if type(rawget(_G, "decompile")) ~= "function" then
        return nil, "decompile_unavailable"
    end
    local ok, code = pcall(decompile, scriptInst)
    if ok and type(code) == "string" and code ~= "" then
        return code, nil
    end
    return nil, trimText(code, 180)
end

local function extractCodeSignals(code, remoteIndex, sourcePath)
    local lines = {}
    local requireHints = {}
    local remoteMentions = {}
    local lowerCode = lower(code)
    local seenRequire = {}
    local seenRemote = {}

    for line in string.gmatch(code, "[^\r\n]+") do
        local probe = lower(line)
        local matched = false
        for _, keyword in ipairs(CODE_SIGNAL_KEYWORDS) do
            if string.find(probe, keyword, 1, true) then
                matched = true
                break
            end
        end
        if matched and #lines < CONFIG.maxCodeSignalLines then
            table.insert(lines, trimText(line, 180))
        end
        if string.find(probe, "require", 1, true) and #requireHints < 10 then
            local trimmed = trimText(line, 180)
            if not seenRequire[trimmed] then
                seenRequire[trimmed] = true
                table.insert(requireHints, trimmed)
                recordMapLink(sourcePath, "require", trimmed, nil)
            end
        end

        local dataLine = string.find(probe, "quest", 1, true)
            or string.find(probe, "boss", 1, true)
            or string.find(probe, "mob", 1, true)
            or string.find(probe, "monster", 1, true)
            or string.find(probe, "pet", 1, true)
            or string.find(probe, "weapon", 1, true)
            or string.find(probe, "gem", 1, true)
            or string.find(probe, "race", 1, true)
            or string.find(probe, "city", 1, true)
            or string.find(probe, "island", 1, true)
            or string.find(probe, "isla", 1, true)
            or string.find(probe, "zone", 1, true)
            or string.find(probe, "map", 1, true)
            or string.find(probe, "event", 1, true)
            or string.find(probe, "shop", 1, true)
            or string.find(probe, "fly", 1, true)
            or string.find(probe, "float", 1, true)
            or string.find(probe, "speed", 1, true)
            or string.find(probe, "jump", 1, true)
            or string.find(probe, "doublejump", 1, true)
            or string.find(probe, "reroll", 1, true)
            or string.find(probe, "roll", 1, true)
            or string.find(probe, "fragment", 1, true)
            or string.find(probe, "money", 1, true)
            or string.find(probe, "accessory", 1, true)
            or string.find(probe, "melee", 1, true)
            or string.find(probe, "sword", 1, true)
            or string.find(probe, "key", 1, true)
            or string.find(probe, "seal", 1, true)
            or string.find(probe, "stat", 1, true)
            or string.find(probe, "drop", 1, true)
            or string.find(probe, "moon slayer", 1, true)
            or string.find(probe, "moonslayer", 1, true)
        if dataLine then
            if string.find(probe, "quest", 1, true) then
                addDatasetHint("quests", sourcePath, trimText(line, 140))
            end
            if string.find(probe, "boss", 1, true) then
                addDatasetHint("bosses", sourcePath, trimText(line, 140))
            end
            if string.find(probe, "monster", 1, true) or string.find(probe, "mob", 1, true) then
                addDatasetHint("mobs", sourcePath, trimText(line, 140))
            end
            if string.find(probe, "pet", 1, true) then
                addDatasetHint("pets", sourcePath, trimText(line, 140))
            end
            if string.find(probe, "weapon", 1, true) then
                addDatasetHint("weapons", sourcePath, trimText(line, 140))
            end
            if string.find(probe, "gem", 1, true) then
                addDatasetHint("gems", sourcePath, trimText(line, 140))
            end
            if string.find(probe, "race", 1, true) then
                addDatasetHint("races", sourcePath, trimText(line, 140))
            end
            if string.find(probe, "city", 1, true) or string.find(probe, "zone", 1, true) or string.find(probe, "map", 1, true) then
                addDatasetHint("places", sourcePath, trimText(line, 140))
            end
            if string.find(probe, "island", 1, true) or string.find(probe, "isla", 1, true) then
                addDatasetHint("islands", sourcePath, trimText(line, 140))
            end
            if string.find(probe, "event", 1, true) then
                addDatasetHint("events", sourcePath, trimText(line, 140))
            end
            if string.find(probe, "shop", 1, true) then
                addDatasetHint("shops", sourcePath, trimText(line, 140))
            end
            if string.find(probe, "fly", 1, true) or string.find(probe, "float", 1, true)
                or string.find(probe, "speed", 1, true) or string.find(probe, "jump", 1, true)
                or string.find(probe, "doublejump", 1, true) then
                addDatasetHint("movement", sourcePath, trimText(line, 140))
            end
            if string.find(probe, "reroll", 1, true) or string.find(probe, "roll", 1, true) then
                addDatasetHint("rolls", sourcePath, trimText(line, 140))
            end
            if string.find(probe, "fragment", 1, true) then
                addDatasetHint("fragments", sourcePath, trimText(line, 140))
            end
            if string.find(probe, "money", 1, true) or string.find(probe, "coin", 1, true)
                or string.find(probe, "cash", 1, true) then
                addDatasetHint("currencies", sourcePath, trimText(line, 140))
            end
            if string.find(probe, "accessory", 1, true) then
                addDatasetHint("accessories", sourcePath, trimText(line, 140))
            end
            if string.find(probe, "melee", 1, true) or string.find(probe, "sword", 1, true) then
                addDatasetHint("weapons", sourcePath, trimText(line, 140))
            end
            if string.find(probe, "key", 1, true) then
                addDatasetHint("keys", sourcePath, trimText(line, 140))
            end
            if string.find(probe, "seal", 1, true) then
                addDatasetHint("seals", sourcePath, trimText(line, 140))
            end
            if string.find(probe, "stat", 1, true) then
                addDatasetHint("stats", sourcePath, trimText(line, 140))
            end
            if string.find(probe, "drop", 1, true) then
                addDatasetHint("drops", sourcePath, trimText(line, 140))
            end
            if string.find(probe, "moon slayer", 1, true) or string.find(probe, "moonslayer", 1, true) then
                addDatasetHint("named_systems", sourcePath, trimText(line, 140))
            end
        end
    end

    if type(remoteIndex) == "table" then
        for remoteName, remotePath in pairs(remoteIndex) do
            if #remoteMentions >= 12 then
                break
            end
            if #remoteName >= 3 and string.find(lowerCode, remoteName, 1, true) then
                local signature = remoteName .. "@" .. remotePath
                if not seenRemote[signature] then
                    seenRemote[signature] = true
                    table.insert(remoteMentions, signature)
                    recordMapLink(sourcePath, "remote", remotePath, remoteName)
                end
            end
        end
        table.sort(remoteMentions)
    end

    local lineCount = 1
    for _ in string.gmatch(code, "\n") do
        lineCount = lineCount + 1
    end

    return {
        lines = lineCount,
        chars = #code,
        requireHints = requireHints,
        remoteMentions = remoteMentions,
        keyLines = lines,
        preview = trimText(code, CONFIG.maxCodePreview)
    }
end

local function buildRemoteRoots()
    local roots = {
        ReplicatedStorage,
        safeGetService("ReplicatedFirst"),
        Workspace
    }
    local filtered = {}
    for _, root in ipairs(roots) do
        if root then
            table.insert(filtered, root)
        end
    end
    return filtered
end

local function buildScriptRoots()
    local roots = {
        { name = "ReplicatedStorage", root = ReplicatedStorage },
        { name = "ReplicatedFirst", root = safeGetService("ReplicatedFirst") },
        { name = "PlayerScripts", root = LP:FindFirstChild("PlayerScripts") },
        { name = "PlayerGui", root = LP:FindFirstChild("PlayerGui") },
        { name = "StarterPlayer", root = safeGetService("StarterPlayer") },
        { name = "StarterGui", root = safeGetService("StarterGui") },
        { name = "StarterPack", root = safeGetService("StarterPack") },
        { name = "Workspace", root = Workspace },
        { name = "ServerScriptService", root = safeGetService("ServerScriptService") },
        { name = "ServerStorage", root = safeGetService("ServerStorage") }
    }
    local filtered = {}
    for _, item in ipairs(roots) do
        if item.root then
            table.insert(filtered, item)
        end
    end
    return filtered
end

local function findFrameworks()
    local results = {}
    local seen = {}
    local scanned = 0
    local roots = {
        ReplicatedStorage,
        safeGetService("ReplicatedFirst"),
        LP:FindFirstChild("PlayerScripts"),
        LP:FindFirstChild("PlayerGui")
    }

    for _, root in ipairs(roots) do
        if root then
            for _, desc in ipairs(root:GetDescendants()) do
                scanned = scanned + 1
                if scanned > CONFIG.maxDescPerPhase then
                    break
                end
                local path = lower(desc:GetFullName())
                for framework, signatures in pairs(FRAMEWORK_SIGNATURES) do
                    if not seen[framework] then
                        for _, sig in ipairs(signatures) do
                            if string.find(path, sig, 1, true) then
                                seen[framework] = true
                                table.insert(results, {
                                    framework = framework,
                                    hit = sig,
                                    path = desc:GetFullName()
                                })
                                break
                            end
                        end
                    end
                end
                yieldMaybe(scanned)
            end
        end
    end

    table.sort(results, function(a, b)
        return a.framework < b.framework
    end)
    return results
end

local function classifyWorldInstance(inst)
    local name = lower(inst.Name)
    local path = lower(inst:GetFullName())
    local attrs = {}
    local okAttrs, rawAttrs = pcall(inst.GetAttributes, inst)
    if okAttrs and type(rawAttrs) == "table" then
        attrs = rawAttrs
    end

    local prompt = inst:FindFirstChildWhichIsA("ProximityPrompt", true)
    local click = inst:FindFirstChildWhichIsA("ClickDetector", true)

    if string.find(name, "egg", 1, true) or string.find(name, "huevo", 1, true) then
        return "Egg", attrs
    end
    if string.find(path, "pet", 1, true) or attrs.PetItemId ~= nil or attrs.OwnerUserId ~= nil then
        return "Pet", attrs
    end
    if string.find(path, "boss", 1, true) or string.find(name, "boss", 1, true) then
        return "Boss", attrs
    end
    if string.find(path, "monster", 1, true) or string.find(path, "mob", 1, true) or attrs.MonsterId ~= nil then
        return "Monster", attrs
    end
    if string.find(path, "npc", 1, true) or string.find(name, "merchant", 1, true) or string.find(name, "shop", 1, true) or string.find(name, "quest", 1, true) then
        return "NPC", attrs
    end
    if string.find(name, "event", 1, true) or string.find(path, "event", 1, true) then
        return "Event", attrs
    end
    if string.find(name, "quest", 1, true) or string.find(path, "quest", 1, true) then
        return "Quest", attrs
    end
    if string.find(name, "city", 1, true) or string.find(name, "town", 1, true) or string.find(name, "village", 1, true) or string.find(name, "zone", 1, true) or string.find(name, "island", 1, true) or string.find(name, "isla", 1, true) then
        return "Place", attrs
    end
    if string.find(name, "portal", 1, true) or string.find(name, "teleport", 1, true) or string.find(name, "warp", 1, true) or string.find(name, "gate", 1, true) then
        return "Portal", attrs
    end
    if string.find(name, "weapon", 1, true) or string.find(name, "sword", 1, true) or string.find(name, "gun", 1, true) or string.find(name, "staff", 1, true) or inst:IsA("Tool") then
        return "Weapon", attrs
    end
    if string.find(name, "accessory", 1, true) or inst:IsA("Accessory") then
        return "Accessory", attrs
    end
    if string.find(name, "key", 1, true) then
        return "Key", attrs
    end
    if string.find(name, "seal", 1, true) then
        return "Seal", attrs
    end
    if string.find(name, "money", 1, true) or string.find(name, "coin", 1, true) or string.find(name, "cash", 1, true) then
        return "Currency", attrs
    end
    if string.find(name, "gem", 1, true) or string.find(name, "crystal", 1, true) or string.find(name, "ore", 1, true) then
        return "Resource", attrs
    end
    if string.find(name, "chest", 1, true) or string.find(name, "loot", 1, true) or string.find(name, "reward", 1, true) or string.find(name, "pickup", 1, true) or string.find(path, "pickup", 1, true) then
        return "Pickup", attrs
    end
    if string.find(name, "shop", 1, true) or string.find(name, "forge", 1, true) or string.find(name, "craft", 1, true) or string.find(name, "enchant", 1, true) then
        return "Station", attrs
    end
    if prompt or click then
        return "Interactive", attrs
    end
    if inst:IsA("Model") and (inst:FindFirstChildWhichIsA("Humanoid", true) or inst:FindFirstChildWhichIsA("AnimationController", true)) then
        return "CharacterLike", attrs
    end
    return nil, attrs
end

local function enqueueTask(label, fn)
    table.insert(State.taskQueue, {
        label = label,
        fn = fn
    })
end

local function scanEnvironment()
    startSection("Environment")
    local executor = nil
    if identifyexecutor then
        local ok, value = pcall(identifyexecutor)
        if ok then
            executor = value
        end
    end
    writeLine("ENV", "Session", {
        placeId = game.PlaceId,
        gameId = game.GameId,
        jobId = game.JobId,
        player = LP and LP.Name or "unknown",
        userId = LP and LP.UserId or nil,
        executor = executor,
        time = os.date("%Y-%m-%d %H:%M:%S")
    }, Color3.fromRGB(120, 255, 200))

    local playerGui = LP:FindFirstChild("PlayerGui")
    local backpack = LP:FindFirstChild("Backpack")
    local leaderstats = LP:FindFirstChild("leaderstats")
    local stats = {}
    if leaderstats then
        for _, child in ipairs(leaderstats:GetChildren()) do
            if child:IsA("ValueBase") then
                table.insert(stats, child.Name .. "=" .. safeTostring(child.Value))
            end
        end
    end

    writeLine("ENV", "PlayerState", {
        character = LP.Character and LP.Character.Name or nil,
        root = getCharacterRoot(),
        playerGuiChildren = playerGui and #(playerGui:GetChildren()) or nil,
        backpackItems = backpack and #(backpack:GetChildren()) or nil,
        leaderstats = stats
    }, Color3.fromRGB(170, 230, 255))
    writeLine("ENV", "Capabilities", getExecutorCapabilities(), Color3.fromRGB(170, 230, 255))
end

local function scanServices()
    startSection("Services")
    local results = {}
    for _, serviceName in ipairs(COMMON_SERVICES) do
        local svc = safeGetService(serviceName)
        local item = {
            service = serviceName,
            available = svc ~= nil,
            class = svc and svc.ClassName or nil,
            children = svc and #(svc:GetChildren()) or nil
        }
        table.insert(results, item)
        writeLine("SERVICE", serviceName, item, item.available and Color3.fromRGB(160, 230, 180) or Color3.fromRGB(255, 180, 120))
    end
    State.findings.services = results
end

local function scanFrameworks()
    startSection("Framework Detection")
    local frameworks = findFrameworks()
    State.findings.frameworks = frameworks
    if #frameworks == 0 then
        writeLine("FRAMEWORK", "NoneDetected", nil, Color3.fromRGB(255, 200, 120))
        return
    end
    for _, item in ipairs(frameworks) do
        writeLine("FRAMEWORK", item.framework, item, Color3.fromRGB(180, 220, 255))
    end
end

local function collectRemoteInventory()
    local remotes = {}
    local remoteIndex = {}
    local counts = {
        RemoteEvent = 0,
        RemoteFunction = 0
    }
    local scanned = 0

    for _, root in ipairs(buildRemoteRoots()) do
        for _, desc in ipairs(root:GetDescendants()) do
            scanned = scanned + 1
            if scanned > CONFIG.maxDescPerPhase then
                break
            end
            if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") then
                local score, reasons = scoreInterest(desc.Name, desc:GetFullName(), desc.ClassName)
                local item = {
                    instance = desc,
                    name = desc.Name,
                    class = desc.ClassName,
                    path = desc:GetFullName(),
                    parent = desc.Parent and desc.Parent:GetFullName() or nil,
                    score = score,
                    reasons = reasons
                }
                table.insert(remotes, item)
                counts[desc.ClassName] = (counts[desc.ClassName] or 0) + 1
                remoteIndex[lower(desc.Name)] = desc:GetFullName()
            end
            yieldMaybe(scanned)
        end
    end

    table.sort(remotes, function(a, b)
        if a.score ~= b.score then
            return a.score > b.score
        end
        return a.path < b.path
    end)

    return remotes, remoteIndex, counts
end

local function hookIncomingRemote(remote)
    if not remote or not remote:IsA("RemoteEvent") or State.hookedIncoming[remote] then
        return
    end
    State.hookedIncoming[remote] = true
    addConnection(remote.OnClientEvent:Connect(function(...)
        if not State.active or not State.liveNetwork then
            return
        end
        local path = remote:GetFullName()
        local count = (State.incomingRemoteCounts[path] or 0) + 1
        State.incomingRemoteCounts[path] = count
        if count <= CONFIG.maxSignalsPerRemote then
            writeLine("NET_IN", remote.Name, {
                path = path,
                count = count,
                args = summarizeArray({ ... })
            }, Color3.fromRGB(170, 230, 255))
        end
    end))
end

local function installOutgoingHook()
    local hookState = rawget(_G, "RobloxUniversalAuditScannerHook")
    if not hookState then
        hookState = {
            installed = false,
            state = nil
        }
        rawset(_G, "RobloxUniversalAuditScannerHook", hookState)
    end
    hookState.state = State

    if hookState.installed then
        writeLine("NET", "OutgoingHookReady", { reused = true }, Color3.fromRGB(170, 230, 255))
        return
    end

    if not hookmetamethod or not getnamecallmethod or not newcclosure then
        writeLine("NET", "OutgoingHookUnavailable", {
            hookmetamethod = type(rawget(_G, "hookmetamethod")) == "function",
            getnamecallmethod = type(rawget(_G, "getnamecallmethod")) == "function",
            newcclosure = type(rawget(_G, "newcclosure")) == "function"
        }, Color3.fromRGB(255, 180, 120))
        return
    end

    local old
    old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local global = rawget(_G, "RobloxUniversalAuditScannerHook")
        local activeState = global and global.state or nil
        if activeState and activeState.active and activeState.liveNetwork then
            if NETWORK_METHODS[method] and typeof(self) == "Instance" then
                local isRemote = self:IsA("RemoteEvent") or self:IsA("RemoteFunction")
                if isRemote then
                    local path = self:GetFullName()
                    local count = (activeState.outgoingRemoteCounts[path] or 0) + 1
                    activeState.outgoingRemoteCounts[path] = count
                    if count <= CONFIG.maxSignalsPerRemote and activeState.logLine then
                        activeState.logLine("NET_OUT", method, {
                            path = path,
                            count = count,
                            args = summarizeArray({ ... })
                        }, Color3.fromRGB(255, 220, 140))
                    end
                end
            end
        end
        return old(self, ...)
    end))

    hookState.installed = true
    writeLine("NET", "OutgoingHookInstalled", nil, Color3.fromRGB(170, 230, 255))
end

scanRemotes = function()
    startSection("Remote Inventory")
    local remotes, remoteIndex, counts = collectRemoteInventory()
    State.findings.remotes = remotes
    State.findings.remoteIndex = remoteIndex

    writeLine("REMOTE", "Summary", {
        counts = counts,
        total = #remotes
    }, Color3.fromRGB(170, 230, 255))

    for _, item in ipairs(remotes) do
        if item.instance:IsA("RemoteEvent") then
            hookIncomingRemote(item.instance)
        end
    end

    local toLog = math.min(#remotes, CONFIG.maxRemoteLogs)
    if #remotes > toLog then
        writeLine("REMOTE", "Truncated", {
            logged = toLog,
            total = #remotes
        }, Color3.fromRGB(255, 200, 120))
    end

    for index = 1, toLog do
        local item = remotes[index]
        writeLine("REMOTE", "Item", {
            class = item.class,
            name = item.name,
            path = item.path,
            score = item.score,
            reasons = item.reasons
        }, item.score >= 12 and Color3.fromRGB(255, 225, 140) or Color3.fromRGB(170, 230, 255))
        yieldMaybe(index)
    end

    installOutgoingHook()
end

local function collectScriptInventory()
    local loadedSet = getLoadedModuleSet()
    local items = {}
    local counts = {
        Script = 0,
        LocalScript = 0,
        ModuleScript = 0
    }
    local scanned = 0

    for _, rootInfo in ipairs(buildScriptRoots()) do
        for _, desc in ipairs(rootInfo.root:GetDescendants()) do
            scanned = scanned + 1
            if scanned > CONFIG.maxDescPerPhase then
                break
            end
            if desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("ModuleScript") then
                local score, reasons = scoreInterest(desc.Name, desc:GetFullName(), desc.ClassName)
                table.insert(items, {
                    instance = desc,
                    name = desc.Name,
                    class = desc.ClassName,
                    path = desc:GetFullName(),
                    root = rootInfo.name,
                    loaded = loadedSet[desc] == true,
                    hierarchy = summarizeHierarchy(desc),
                    score = score,
                    reasons = reasons
                })
                counts[desc.ClassName] = (counts[desc.ClassName] or 0) + 1
            end
            yieldMaybe(scanned)
        end
    end

    table.sort(items, function(a, b)
        if a.score ~= b.score then
            return a.score > b.score
        end
        if a.loaded ~= b.loaded then
            return a.loaded
        end
        return a.path < b.path
    end)

    return items, counts
end

local function deepScanScriptItem(item)
    writeLine("DEEP", "Target", {
        class = item.class,
        path = item.path,
        score = item.score,
        loaded = item.loaded,
        reasons = item.reasons,
        hierarchy = item.hierarchy
    }, Color3.fromRGB(255, 225, 140))

    if item.instance:IsA("LocalScript") and getsenv then
        local ok, env = pcall(getsenv, item.instance)
        if ok and type(env) == "table" then
            writeLine("DEEP", "Env", {
                path = item.path,
                keys = collectRuntimeKeys(env)
            }, Color3.fromRGB(180, 230, 255))
        else
            writeLine("DEEP", "EnvMiss", { path = item.path }, Color3.fromRGB(255, 180, 120))
        end
    end

    if item.instance:IsA("ModuleScript") and item.loaded then
        local ok, exported = pcall(require, item.instance)
        if ok then
            writeLine("DEEP", "ModuleExport", {
                path = item.path,
                summary = summarizeExportValue(exported)
            }, Color3.fromRGB(180, 255, 200))
            if type(exported) == "table" then
                local count = 0
                for key, value in pairs(exported) do
                    count = count + 1
                    if count > CONFIG.maxExportEntries then
                        break
                    end
                    if type(value) == "function" then
                        local info = getDebugInfo(value, "Snu")
                        writeLine("DEEP", "ExportFunction", {
                            path = item.path,
                            key = tostring(key),
                            line = info and info.linedefined or nil,
                            lastLine = info and info.lastlinedefined or nil,
                            constants = extractFunctionConstants(value),
                            upvalues = extractFunctionUpvalues(value)
                        }, Color3.fromRGB(255, 235, 170))
                    elseif type(value) == "table" then
                        writeLine("DEEP", "ExportTable", {
                            path = item.path,
                            key = tostring(key),
                            summary = summarizeExportValue(value)
                        }, Color3.fromRGB(180, 230, 255))
                    end
                end
            end
        else
            writeLine("DEEP", "ModuleExportError", {
                path = item.path,
                error = trimText(exported, 180)
            }, Color3.fromRGB(255, 180, 120))
        end
    end

    local code, err = tryDecompileScript(item.instance)
    if code then
        writeLine("DEEP", "Code", {
            path = item.path,
            signals = extractCodeSignals(code, State.findings.remoteIndex, item.path)
        }, Color3.fromRGB(220, 230, 255))
    else
        writeLine("DEEP", "CodeMiss", {
            path = item.path,
            error = err
        }, Color3.fromRGB(255, 180, 120))
    end
end

scanScripts = function()
    startSection("Scripts And Modules")
    local items, counts = collectScriptInventory()
    State.findings.scripts = items

    writeLine("SCRIPT", "Summary", {
        counts = counts,
        total = #items
    }, Color3.fromRGB(170, 230, 255))

    local toLog = math.min(#items, CONFIG.maxScriptLogs)
    if #items > toLog then
        writeLine("SCRIPT", "Truncated", {
            logged = toLog,
            total = #items
        }, Color3.fromRGB(255, 200, 120))
    end

    for index = 1, toLog do
        local item = items[index]
        writeLine("SCRIPT", "Item", {
            class = item.class,
            name = item.name,
            root = item.root,
            path = item.path,
            loaded = item.loaded,
            score = item.score,
            reasons = item.reasons
        }, item.score >= 12 and Color3.fromRGB(255, 225, 140) or Color3.fromRGB(170, 230, 255))
        yieldMaybe(index)
    end

    local deepTargets = {}
    local seen = {}
    for _, item in ipairs(items) do
        if (item.score >= 10 or item.loaded) and not seen[item.instance] then
            seen[item.instance] = true
            table.insert(deepTargets, item)
            if #deepTargets >= CONFIG.maxDeepTargets then
                break
            end
        end
    end
    State.findings.deepTargets = deepTargets

    writeLine("SCRIPT", "DeepTargets", {
        count = #deepTargets,
        paths = (function()
            local out = {}
            for _, item in ipairs(deepTargets) do
                table.insert(out, item.path)
            end
            return out
        end)()
    }, Color3.fromRGB(255, 225, 140))

    for _, item in ipairs(deepTargets) do
        enqueueTask("Deep:" .. item.name, function()
            deepScanScriptItem(item)
        end)
    end

    enqueueTask("Security/Summary", scanSecurityAndSummary)
end

local function scanGui()
    startSection("GUI Inventory")
    local playerGui = LP:FindFirstChild("PlayerGui")
    if not playerGui then
        writeLine("GUI", "MissingPlayerGui", nil, Color3.fromRGB(255, 180, 120))
        return
    end

    local interesting = {}
    local scanned = 0
    for _, desc in ipairs(playerGui:GetDescendants()) do
        scanned = scanned + 1
        if scanned > CONFIG.maxDescPerPhase then
            break
        end
        if desc:IsA("GuiObject") then
            local text = (desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox")) and desc.Text or ""
            local score, reasons = scoreInterest(desc.Name .. " " .. tostring(text), desc:GetFullName(), desc.ClassName)
            if score >= 6 or desc.Visible then
                table.insert(interesting, {
                    class = desc.ClassName,
                    name = desc.Name,
                    path = desc:GetFullName(),
                    visible = desc.Visible,
                    text = trimText(text, 80),
                    score = score,
                    reasons = reasons
                })
            end
        end
        yieldMaybe(scanned)
    end

    table.sort(interesting, function(a, b)
        if a.score ~= b.score then
            return a.score > b.score
        end
        if a.visible ~= b.visible then
            return a.visible
        end
        return a.path < b.path
    end)

    State.findings.gui = interesting
    writeLine("GUI", "Summary", {
        interesting = #interesting,
        total = #(playerGui:GetDescendants())
    }, Color3.fromRGB(170, 230, 255))

    for index = 1, math.min(#interesting, 100) do
        writeLine("GUI", "Item", interesting[index], Color3.fromRGB(180, 220, 255))
        yieldMaybe(index)
    end
end

scanWorld = function()
    startSection("World Inventory")
    local counts = {}
    local examples = {}
    local scanned = 0

    local topChildren = {}
    for _, child in ipairs(Workspace:GetChildren()) do
        table.insert(topChildren, {
            name = child.Name,
            class = child.ClassName,
            path = child:GetFullName(),
            children = #(child:GetChildren())
        })
        if #topChildren >= 50 then
            break
        end
    end
    writeLine("WORLD", "TopChildren", topChildren, Color3.fromRGB(170, 230, 255))

    for _, desc in ipairs(Workspace:GetDescendants()) do
        scanned = scanned + 1
        if scanned > CONFIG.maxDescPerPhase then
            break
        end
        local category, attrs = classifyWorldInstance(desc)
        if category then
            counts[category] = (counts[category] or 0) + 1
            if not examples[category] then
                examples[category] = {}
            end
            if #examples[category] < CONFIG.maxExamplesPerCategory then
                local part = getRootPart(desc)
                local root = getCharacterRoot()
                table.insert(examples[category], {
                    name = desc.Name,
                    class = desc.ClassName,
                    path = desc:GetFullName(),
                    distance = (part and root) and math.floor((part.Position - root.Position).Magnitude) or nil,
                    attrs = attrs
                })
            end

            local pathLower = lower(desc:GetFullName())
            if category == "Monster" then
                addDatasetHint("mobs", desc:GetFullName(), desc.Name)
            elseif category == "Boss" then
                addDatasetHint("bosses", desc:GetFullName(), desc.Name)
            elseif category == "Pet" then
                addDatasetHint("pets", desc:GetFullName(), desc.Name)
            elseif category == "Event" then
                addDatasetHint("events", desc:GetFullName(), desc.Name)
            elseif category == "Quest" then
                addDatasetHint("quests", desc:GetFullName(), desc.Name)
            elseif category == "Place" or string.find(pathLower, "city", 1, true) or string.find(pathLower, "town", 1, true) then
                addDatasetHint("places", desc:GetFullName(), desc.Name)
                if string.find(pathLower, "island", 1, true) or string.find(pathLower, "isla", 1, true) then
                    addDatasetHint("islands", desc:GetFullName(), desc.Name)
                end
            elseif category == "Weapon" then
                addDatasetHint("weapons", desc:GetFullName(), desc.Name)
            elseif category == "Accessory" then
                addDatasetHint("accessories", desc:GetFullName(), desc.Name)
            elseif category == "Key" then
                addDatasetHint("keys", desc:GetFullName(), desc.Name)
            elseif category == "Seal" then
                addDatasetHint("seals", desc:GetFullName(), desc.Name)
            elseif category == "Currency" then
                addDatasetHint("currencies", desc:GetFullName(), desc.Name)
            elseif category == "Resource" then
                addDatasetHint("gems", desc:GetFullName(), desc.Name)
            elseif category == "Station" then
                addDatasetHint("stations", desc:GetFullName(), desc.Name)
            end
        end
        yieldMaybe(scanned)
    end

    local tags = {}
    if CollectionService and CollectionService.GetAllTags then
        local ok, allTags = pcall(function()
            return CollectionService:GetAllTags()
        end)
        if ok and type(allTags) == "table" then
            for _, tag in ipairs(allTags) do
                local tagged = CollectionService:GetTagged(tag)
                table.insert(tags, {
                    tag = tag,
                    count = #tagged
                })
                if #tags >= 40 then
                    break
                end
            end
        end
    end

    State.findings.world = {
        counts = counts,
        examples = examples,
        tags = tags
    }

    writeLine("WORLD", "Counts", counts, Color3.fromRGB(170, 230, 255))
    if #tags > 0 then
        writeLine("WORLD", "Tags", tags, Color3.fromRGB(170, 230, 255))
    end

    local ordered = {}
    for category in pairs(examples) do
        table.insert(ordered, category)
    end
    table.sort(ordered)
    for _, category in ipairs(ordered) do
        writeLine("WORLD", category, examples[category], Color3.fromRGB(180, 220, 255))
    end
end

scanSecurityAndSummary = function()
    startSection("Security And Summary")

    local antiScripts = {}
    local clientTrust = {}
    for _, item in ipairs(State.findings.scripts or {}) do
        local probe = lower(item.path)
        if probe:find("anti", 1, true)
            or probe:find("detect", 1, true)
            or probe:find("exploit", 1, true)
            or probe:find("honeypot", 1, true)
            or probe:find("trap", 1, true)
            or probe:find("kick", 1, true)
            or probe:find("ban", 1, true) then
            table.insert(antiScripts, item.path)
        end
        if probe:find("reward", 1, true)
            or probe:find("damage", 1, true)
            or probe:find("health", 1, true)
            or probe:find("inventory", 1, true)
            or probe:find("currency", 1, true)
            or probe:find("pet", 1, true)
            or probe:find("monster", 1, true)
            or probe:find("fight", 1, true)
            or probe:find("quest", 1, true)
            or probe:find("shop", 1, true) then
            table.insert(clientTrust, item.path)
        end
        if #antiScripts >= 20 and #clientTrust >= 20 then
            break
        end
    end

    local riskyRemotes = {}
    for _, item in ipairs(State.findings.remotes or {}) do
        local probe = lower(item.name)
        if probe:find("reward", 1, true)
            or probe:find("damage", 1, true)
            or probe:find("health", 1, true)
            or probe:find("give", 1, true)
            or probe:find("cash", 1, true)
            or probe:find("coin", 1, true)
            or probe:find("exp", 1, true)
            or probe:find("summon", 1, true)
            or probe:find("hatch", 1, true)
            or probe:find("pet", 1, true)
            or probe:find("inventory", 1, true)
            or probe:find("save", 1, true)
            or probe:find("load", 1, true)
            or probe:find("admin", 1, true)
            or probe:find("kick", 1, true)
            or probe:find("ban", 1, true) then
            table.insert(riskyRemotes, item.path)
        end
        if #riskyRemotes >= 24 then
            break
        end
    end

    State.findings.security = {
        antiScripts = antiScripts,
        clientTrust = clientTrust,
        riskyRemotes = riskyRemotes
    }

    writeLine("SECURITY", "AntiCheatCandidates", antiScripts, Color3.fromRGB(255, 210, 140))
    writeLine("SECURITY", "ClientTrustSurfaces", clientTrust, Color3.fromRGB(255, 210, 140))
    writeLine("SECURITY", "RiskyRemoteNames", riskyRemotes, Color3.fromRGB(255, 210, 140))

    local datasetSummary = {}
    for key, bucket in pairs(State.findings.datasets or {}) do
        table.insert(datasetSummary, key .. "=" .. tostring(#bucket))
    end
    table.sort(datasetSummary)

    local mapPreview = {}
    for index, item in ipairs(State.findings.mapLinks or {}) do
        if index > 30 then
            break
        end
        table.insert(mapPreview, item.source .. " -> " .. item.type .. " -> " .. tostring(item.target))
    end

    writeLine("SUMMARY", "Counts", {
        frameworks = #State.findings.frameworks,
        remotes = #(State.findings.remotes or {}),
        scripts = #(State.findings.scripts or {}),
        deepTargets = #(State.findings.deepTargets or {}),
        worldCounts = State.findings.world and State.findings.world.counts or nil,
        datasets = datasetSummary
    }, Color3.fromRGB(170, 255, 180))
    writeLine("SUMMARY", "MapPreview", mapPreview, Color3.fromRGB(170, 255, 180))
    writeLine("SUMMARY", "OutputFile", { file = State.file }, Color3.fromRGB(170, 255, 180))

    for index, item in ipairs(State.findings.mapLinks or {}) do
        if index > 80 then
            break
        end
        writeLine("MAP", item.type, item, Color3.fromRGB(200, 230, 255))
    end

    local orderedDatasets = {}
    for key in pairs(State.findings.datasets or {}) do
        table.insert(orderedDatasets, key)
    end
    table.sort(orderedDatasets)
    for _, key in ipairs(orderedDatasets) do
        writeLine("DATASET", key, State.findings.datasets[key], Color3.fromRGB(180, 230, 255))
    end
end

local function runTaskWorker()
    if State.taskWorker then
        return
    end
    State.taskWorker = task.spawn(function()
        while State.active do
            local taskItem = table.remove(State.taskQueue, 1)
            if taskItem then
                State.queueBusy = true
                setStatus("Running " .. taskItem.label)
                local started = os.clock()
                writeLine("TASK", "Start", { label = taskItem.label }, Color3.fromRGB(255, 230, 140))
                local ok, err = pcall(taskItem.fn)
                if ok then
                    writeLine("TASK", "Done", {
                        label = taskItem.label,
                        elapsed = math.floor((os.clock() - started) * 1000 + 0.5) / 1000
                    }, Color3.fromRGB(170, 255, 180))
                else
                    writeLine("TASK", "Error", {
                        label = taskItem.label,
                        error = trimText(err, 240)
                    }, Color3.fromRGB(255, 180, 120))
                end
                State.queueBusy = false
                setStatus("Idle")
            else
                task.wait(CONFIG.workerIdle)
            end
        end
    end)
end

scheduleFullScan = function(reason)
    State.scanRound = State.scanRound + 1
    State.taskQueue = {}
    resetFindings()
    startSection("Full Scan #" .. tostring(State.scanRound) .. " | " .. tostring(reason or "manual"))
    enqueueTask("Environment", scanEnvironment)
    enqueueTask("Services", scanServices)
    enqueueTask("Frameworks", scanFrameworks)
    enqueueTask("Remotes", scanRemotes)
    enqueueTask("GUI", scanGui)
    enqueueTask("World", scanWorld)
    enqueueTask("Scripts", scanScripts)
end

scheduleScriptScan = function()
    enqueueTask("Scripts", scanScripts)
end

scheduleWorldScan = function()
    enqueueTask("World", scanWorld)
    enqueueTask("Security/Summary", scanSecurityAndSummary)
end

scheduleRemoteScan = function()
    enqueueTask("Remotes", scanRemotes)
    enqueueTask("Security/Summary", scanSecurityAndSummary)
end

local function buildGui()
    local old = getGuiParent():FindFirstChild(CONFIG.uiName)
    if old then
        old:Destroy()
    end

    local screen = Instance.new("ScreenGui")
    screen.Name = CONFIG.uiName
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen.Parent = getGuiParent()

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 620, 0, 430)
    frame.Position = UDim2.new(0.54, 0, 0.36, 0)
    frame.BackgroundColor3 = Color3.fromRGB(16, 20, 26)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screen

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(32, 45, 58)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Text = "  Roblox Universal Audit Scanner"
    title.Parent = frame

    local fullButton = makeButton(title, "FULL SCAN", -104, 92)
    local scriptsButton = makeButton(title, "SCRIPTS", -204, 90)
    local worldButton = makeButton(title, "WORLD", -298, 88)
    local remotesButton = makeButton(title, "REMOTES", -396, 92)
    local copyButton = makeButton(title, "COPY FILE", -492, 92)
    local stopButton = makeButton(title, "STOP", -572, 72)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -12, 0, 18)
    status.Position = UDim2.new(0, 6, 0, 36)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(160, 220, 255)
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Font = Enum.Font.Code
    status.TextSize = 12
    status.Text = "Status: Idle"
    status.Parent = frame

    local fileLabel = Instance.new("TextLabel")
    fileLabel.Size = UDim2.new(1, -12, 0, 18)
    fileLabel.Position = UDim2.new(0, 6, 0, 54)
    fileLabel.BackgroundTransparency = 1
    fileLabel.TextColor3 = Color3.fromRGB(190, 190, 190)
    fileLabel.TextXAlignment = Enum.TextXAlignment.Left
    fileLabel.Font = Enum.Font.Code
    fileLabel.TextSize = 12
    fileLabel.Parent = frame

    local help = Instance.new("TextLabel")
    help.Size = UDim2.new(1, -12, 0, 18)
    help.Position = UDim2.new(0, 6, 0, 72)
    help.BackgroundTransparency = 1
    help.TextColor3 = Color3.fromRGB(255, 220, 150)
    help.TextXAlignment = Enum.TextXAlignment.Left
    help.Font = Enum.Font.Code
    help.TextSize = 11
    help.Text = "AutoStart: env, services, framework, remotes, gui, world, scripts, deep targets, security"
    help.Parent = frame

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -12, 1, -102)
    scroll.Position = UDim2.new(0, 6, 0, 96)
    scroll.BackgroundColor3 = Color3.fromRGB(8, 11, 14)
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 6
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Parent = frame

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 2)
    list.Parent = scroll

    addConnection(list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas))

    State.ui = {
        screen = screen,
        frame = frame,
        status = status,
        fileLabel = fileLabel,
        logScroll = scroll,
        list = list
    }

    fullButton.MouseButton1Click:Connect(function()
        scheduleFullScan("Manual")
    end)
    scriptsButton.MouseButton1Click:Connect(function()
        scheduleScriptScan()
    end)
    worldButton.MouseButton1Click:Connect(function()
        scheduleWorldScan()
    end)
    remotesButton.MouseButton1Click:Connect(function()
        scheduleRemoteScan()
    end)
    copyButton.MouseButton1Click:Connect(function()
        if setclipboard and State.file then
            setclipboard(State.file)
            writeLine("UI", "CopiedFilePath", { file = State.file }, Color3.fromRGB(170, 255, 180))
        else
            writeLine("UI", "CopyUnavailable", {
                setclipboard = type(rawget(_G, "setclipboard")) == "function",
                file = State.file
            }, Color3.fromRGB(255, 180, 120))
        end
    end)
    stopButton.MouseButton1Click:Connect(function()
        if State.stop then
            State.stop("UserStop")
        end
    end)
end

function State.stop(reason)
    State.active = false
    flushFile()
    cleanupConnections()
    if State.ui.screen then
        State.ui.screen:Destroy()
    end
    rawset(_G, "RobloxUniversalAuditScanner", nil)
end

buildGui()
ensureFile()
if State.ui.fileLabel then
    State.ui.fileLabel.Text = "File: " .. tostring(State.file or "writefile unavailable")
end
writeLine("SYSTEM", "Started", {
    placeId = game.PlaceId,
    jobId = game.JobId,
    player = LP and LP.Name or "unknown"
}, Color3.fromRGB(170, 255, 180))
setStatus("Queueing initial scan")
runTaskWorker()
scheduleFullScan("AutoStart")

addConnection(RunService.Heartbeat:Connect(function()
    if State.active then
        flushFile()
    end
end))
