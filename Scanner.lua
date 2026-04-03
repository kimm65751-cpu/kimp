local existing = rawget(_G, "CatchAMonsterAnalyzer")
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
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer

local FILE_PREFIX = "CatchAMonster_Analyzer_"
local FILE_EXT = ".txt"
local SNAPSHOT_INTERVAL = 2
local MAX_ENTITY_ROWS = 12
local MAX_OBJECT_ROWS = 12

local INTEREST_KEYWORDS = {
    "pet",
    "mascota",
    "monster",
    "mob",
    "npc",
    "boss",
    "egg",
    "huevo",
    "reward",
    "gift",
    "drop",
    "loot",
    "pickup",
    "pick",
    "collect",
    "claim",
    "bag",
    "inventory",
    "incub",
    "incubacion",
    "hatch",
    "hatchery",
    "machine",
    "time",
    "tiempo",
    "origin",
    "origen",
    "feed",
    "food",
    "heal",
    "damage",
    "attack",
    "skill",
    "fight",
    "exp",
    "level",
    "rango",
    "rank"
}

local NOISE_MODEL_NAMES = {
    shower = true
}

local VALUE_KEYWORDS = {
    hp = true,
    health = true,
    maxhealth = true,
    level = true,
    lvl = true,
    rarity = true,
    rank = true,
    damage = true,
    atk = true,
    attack = true,
    exp = true,
    owneruserid = true,
    monsterid = true,
    npcid = true,
    reward = true,
    egg = true,
    hatch = true,
    incub = true
}

local Analyzer = {
    active = false,
    session = tostring(os.time()) .. "-" .. tostring(math.floor(os.clock() * 1000) % 100000),
    file = nil,
    ui = {},
    hooksInstalled = false,
    seen = {},
    remotesHooked = {},
    connections = {},
    lastSnapshotAt = 0,
    recentActivity = {},
    trackedModels = {},
    trackedPrompts = {},
    trackedValues = {},
    trackedGui = {},
    modelSyncDefs = {},
    targetScripts = {
        "ClientStarter",
        "PlayerAttack",
        "HookButtonClick",
        "AvatarAbilitiesInterface",
        "TeleportClient",
        "NameTagMonitor"
    }
}

_G.CatchAMonsterAnalyzer = Analyzer

local function getGuiParent()
    local ok = pcall(function()
        return CoreGui.Name
    end)
    if ok then
        return CoreGui
    end
    return LP:WaitForChild("PlayerGui")
end

local function nextFileName()
    if not (isfile and writefile) then
        return nil
    end
    local idx = 1
    while isfile(FILE_PREFIX .. idx .. FILE_EXT) do
        idx = idx + 1
    end
    return FILE_PREFIX .. idx .. FILE_EXT
end

local function safeTostring(value)
    local kind = typeof(value)
    if kind == "Instance" then
        return value:GetFullName()
    end
    if kind == "Vector3" then
        return string.format("%.2f, %.2f, %.2f", value.X, value.Y, value.Z)
    end
    if kind == "CFrame" then
        local p = value.Position
        return string.format("%.2f, %.2f, %.2f", p.X, p.Y, p.Z)
    end
    if kind == "Color3" then
        return string.format("%.3f, %.3f, %.3f", value.R, value.G, value.B)
    end
    if kind == "table" then
        local parts = {}
        local count = 0
        for k, v in pairs(value) do
            count = count + 1
            if count > 10 then
                table.insert(parts, "...")
                break
            end
            table.insert(parts, tostring(k) .. "=" .. safeTostring(v))
        end
        table.sort(parts)
        return "{" .. table.concat(parts, " | ") .. "}"
    end
    return tostring(value)
end

local function lowerOrEmpty(value)
    return string.lower(tostring(value or ""))
end

local function containsKeyword(text)
    local lower = lowerOrEmpty(text)
    for _, keyword in ipairs(INTEREST_KEYWORDS) do
        if string.find(lower, keyword, 1, true) then
            return true, keyword
        end
    end
    return false, nil
end

local function hasInterestingValueName(name)
    local lower = lowerOrEmpty(name)
    if VALUE_KEYWORDS[lower] then
        return true
    end
    for keyword in pairs(VALUE_KEYWORDS) do
        if string.find(lower, keyword, 1, true) then
            return true
        end
    end
    return false
end

local function safeGetTags(instance)
    if not CollectionService then
        return nil
    end
    local ok, tags = pcall(CollectionService.GetTags, CollectionService, instance)
    if not ok or type(tags) ~= "table" or #tags == 0 then
        return nil
    end
    table.sort(tags)
    return table.concat(tags, ",")
end

local function summarizeAttributes(instance, limit)
    local ok, attrs = pcall(instance.GetAttributes, instance)
    if not ok or type(attrs) ~= "table" then
        return nil
    end
    local parts = {}
    local count = 0
    for key, value in pairs(attrs) do
        count = count + 1
        if count > (limit or 10) then
            table.insert(parts, "...")
            break
        end
        table.insert(parts, tostring(key) .. "=" .. safeTostring(value))
    end
    if #parts == 0 then
        return nil
    end
    table.sort(parts)
    return table.concat(parts, " | ")
end

local function writeLine(topic, action, payload)
    local chunks = {
        "[" .. os.date("%X") .. "]",
        "[" .. Analyzer.session .. "]",
        "[" .. topic .. "]",
        action
    }
    if payload then
        local payloadParts = {}
        for key, value in pairs(payload) do
            if value ~= nil and value ~= "" then
                table.insert(payloadParts, tostring(key) .. "=" .. safeTostring(value))
            end
        end
        table.sort(payloadParts)
        if #payloadParts > 0 then
            table.insert(chunks, table.concat(payloadParts, " | "))
        end
    end
    local line = table.concat(chunks, " ")
    print(line)
    if Analyzer.file and appendfile then
        pcall(function()
            appendfile(Analyzer.file, line .. "\n")
        end)
    end
end

local function addConnection(conn)
    table.insert(Analyzer.connections, conn)
    return conn
end

local function rememberActivity(kind, name, details)
    local entry = {
        t = os.clock(),
        kind = kind,
        name = name,
        details = details
    }
    table.insert(Analyzer.recentActivity, entry)
    while #Analyzer.recentActivity > 20 do
        table.remove(Analyzer.recentActivity, 1)
    end
end

local function getRecentActivitySummary(maxAgeSeconds, maxItems)
    local now = os.clock()
    local items = {}
    for i = #Analyzer.recentActivity, 1, -1 do
        local row = Analyzer.recentActivity[i]
        if now - row.t <= maxAgeSeconds then
            table.insert(items, 1, string.format("%s:%s", tostring(row.kind), tostring(row.name)))
            if #items >= maxItems then
                break
            end
        end
    end
    return table.concat(items, " <- ")
end

local function disconnectAll()
    for _, conn in ipairs(Analyzer.connections) do
        pcall(function()
            conn:Disconnect()
        end)
    end
    Analyzer.connections = {}
end

local function markSeen(instance, tag)
    local key = tostring(instance:GetDebugId()) .. "::" .. tag
    if Analyzer.seen[key] then
        return true
    end
    Analyzer.seen[key] = true
    return false
end

local function summarizeArgs(args)
    local parts = {}
    for i = 1, math.min(#args, 6) do
        table.insert(parts, "arg" .. i .. "=" .. safeTostring(args[i]))
    end
    if #args > 6 then
        table.insert(parts, "more=" .. tostring(#args - 6))
    end
    return table.concat(parts, " | ")
end

local function isSpawnAnnouncement(text)
    local value = string.lower(tostring(text or ""))
    return string.find(value, " appear ")
        or string.find(value, " appear at ")
        or string.find(value, " aparea ")
        or string.find(value, " aparece ")
        or string.find(value, " aparecio ")
        or string.find(value, " apareci")
        or string.find(value, " monster")
        or string.find(value, " pet")
        or string.find(value, " mascota")
        or string.find(value, " companion")
        or string.find(value, " volc")
        or string.find(value, " isla")
        or string.find(value, " bosque")
        or string.find(value, " tierra")
end

local function isPlayerCharacter(model)
    return model and model:IsA("Model") and Players:GetPlayerFromCharacter(model) ~= nil
end

local function getPrimaryPart(model)
    if not model then
        return nil
    end
    return model.PrimaryPart
        or model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChildWhichIsA("BasePart", true)
end

local function getDistanceFromPlayer(part)
    local char = LP.Character
    local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
    if not root or not part then
        return nil
    end
    return (root.Position - part.Position).Magnitude
end

local function isNoiseModel(model)
    if not model or not model:IsA("Model") then
        return false
    end
    local lower = lowerOrEmpty(model.Name)
    if NOISE_MODEL_NAMES[lower] then
        return true
    end
    local path = lowerOrEmpty(model:GetFullName())
    if string.find(path, "gpartcachefolder", 1, true) then
        return true
    end
    return false
end

local function getRootInterestingInstance(instance)
    local current = instance
    local candidate = instance
    while current and current ~= Workspace do
        if current:IsA("Model") or current:IsA("BasePart") then
            candidate = current
        end
        current = current.Parent
    end
    return candidate
end

local function getPromptSummary(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then
        return nil
    end
    return {
        action = prompt.ActionText,
        object = prompt.ObjectText,
        key = prompt.KeyboardKeyCode ~= Enum.KeyCode.Unknown and prompt.KeyboardKeyCode.Name or nil,
        hold = prompt.HoldDuration,
        maxDistance = prompt.MaxActivationDistance,
        enabled = prompt.Enabled,
        style = tostring(prompt.Style),
        parent = prompt.Parent and prompt.Parent:GetFullName() or nil
    }
end

local function classifyInstance(instance)
    if not instance then
        return nil
    end

    local path = lowerOrEmpty(instance:GetFullName())
    local name = lowerOrEmpty(instance.Name)
    local kinds = {}
    local clientPets = Workspace:FindFirstChild("ClientPets")

    if (clientPets and instance:IsDescendantOf(clientPets)) or string.find(path, "clientpets", 1, true) then
        table.insert(kinds, "Pet")
    end
    if string.find(path, "clientmonsters", 1, true) or string.find(name, "monster", 1, true) then
        table.insert(kinds, "Monster")
    end
    if string.find(path, ".npc", 1, true) or string.find(name, "npc", 1, true) then
        table.insert(kinds, "NPC")
    end
    if string.find(name, "boss", 1, true) or string.find(path, "boss", 1, true) then
        table.insert(kinds, "Boss")
    end
    if string.find(name, "egg", 1, true) or string.find(name, "huevo", 1, true) or string.find(path, "egg", 1, true) then
        table.insert(kinds, "Egg")
    end
    if string.find(path, "areapickup", 1, true) or string.find(name, "pickup", 1, true) or string.find(name, "reward", 1, true)
        or string.find(name, "gift", 1, true) or string.find(name, "loot", 1, true) or string.find(name, "drop", 1, true) then
        table.insert(kinds, "Pickup")
    end
    if string.find(name, "incub", 1, true) or string.find(name, "hatch", 1, true) or string.find(path, "incub", 1, true)
        or string.find(path, "machine", 1, true) or string.find(path, "hatch", 1, true) then
        table.insert(kinds, "Incubator")
    end

    local prompt = instance:IsA("ProximityPrompt") and instance or instance:FindFirstChildWhichIsA("ProximityPrompt", true)
    local click = instance:IsA("ClickDetector") and instance or instance:FindFirstChildWhichIsA("ClickDetector", true)
    if prompt or click then
        table.insert(kinds, "Interactive")
    end

    local hit, keyword = containsKeyword(path)
    if hit and keyword then
        table.insert(kinds, "Keyword:" .. keyword)
    end

    if #kinds == 0 then
        return nil
    end

    local unique = {}
    local ordered = {}
    for _, kind in ipairs(kinds) do
        if not unique[kind] then
            unique[kind] = true
            table.insert(ordered, kind)
        end
    end
    return table.concat(ordered, ",")
end

local function isWorldObjectCandidate(instance)
    if not instance or instance.Parent == nil then
        return false
    end
    if instance:IsA("Model") and isNoiseModel(instance) then
        return false
    end
    if instance:IsA("ProximityPrompt") or instance:IsA("ClickDetector") then
        return true
    end
    if instance:IsA("Model") or instance:IsA("BasePart") then
        return classifyInstance(instance) ~= nil
    end
    return false
end

local function isEntityCandidate(model)
    if not model or not model:IsA("Model") or isPlayerCharacter(model) then
        return false
    end
    if model.Parent == nil then
        return false
    end
    if isNoiseModel(model) then
        return false
    end

    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local controller = model:FindFirstChildOfClass("AnimationController")
    local name = string.lower(model.Name)

    if humanoid or controller then
        return true
    end
    if string.find(name, "mob") or string.find(name, "monster") or string.find(name, "pet") or string.find(name, "boss") then
        return true
    end
    if model:GetAttribute("OwnerUserId") ~= nil or model:GetAttribute("MonsterId") ~= nil or model:GetAttribute("NpcId") ~= nil then
        return true
    end
    return false
end

local function collectEntityRows()
    local rows = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and isEntityCandidate(obj) then
            local part = getPrimaryPart(obj)
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local dist = getDistanceFromPlayer(part)
            table.insert(rows, {
                model = obj,
                name = obj.Name,
                path = obj:GetFullName(),
                dist = dist or 999999,
                pos = part and part.Position or nil,
                health = hum and hum.Health or nil,
                maxHealth = hum and hum.MaxHealth or nil,
                owner = obj:GetAttribute("OwnerUserId"),
                monsterId = obj:GetAttribute("MonsterId"),
                npcId = obj:GetAttribute("NpcId"),
                level = obj:GetAttribute("Level"),
                rarity = obj:GetAttribute("Rarity")
            })
        end
    end

    table.sort(rows, function(a, b)
        return (a.dist or 999999) < (b.dist or 999999)
    end)

    local out = {}
    for i = 1, math.min(#rows, MAX_ENTITY_ROWS) do
        local row = rows[i]
        out["entity" .. i] = string.format(
            "%s | dist=%s | hp=%s/%s | pos=%s | owner=%s | monsterId=%s | npcId=%s | level=%s | rarity=%s",
            row.name,
            row.dist and string.format("%.1f", row.dist) or "n/a",
            tostring(row.health),
            tostring(row.maxHealth),
            safeTostring(row.pos),
            tostring(row.owner),
            tostring(row.monsterId),
            tostring(row.npcId),
            tostring(row.level),
            tostring(row.rarity)
        )
    end
    out.entityCount = #rows
    return out
end

local function collectObjectRows()
    local rows = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("BasePart")) and isWorldObjectCandidate(obj) then
            local root = getRootInterestingInstance(obj)
            if root == obj then
                local part = root:IsA("BasePart") and root or getPrimaryPart(root)
                table.insert(rows, {
                    name = root.Name,
                    kind = classifyInstance(root),
                    path = root:GetFullName(),
                    dist = getDistanceFromPlayer(part) or 999999,
                    pos = part and part.Position or nil,
                    attrs = summarizeAttributes(root, 8),
                    tags = safeGetTags(root),
                    prompt = root:FindFirstChildWhichIsA("ProximityPrompt", true),
                    click = root:FindFirstChildWhichIsA("ClickDetector", true)
                })
            end
        end
    end

    table.sort(rows, function(a, b)
        return (a.dist or 999999) < (b.dist or 999999)
    end)

    local out = {}
    for i = 1, math.min(#rows, MAX_OBJECT_ROWS) do
        local row = rows[i]
        out["object" .. i] = string.format(
            "%s | kind=%s | dist=%s | pos=%s | prompt=%s | click=%s | attrs=%s | tags=%s",
            row.name,
            tostring(row.kind),
            row.dist and string.format("%.1f", row.dist) or "n/a",
            safeTostring(row.pos),
            row.prompt and row.prompt.Name or "nil",
            row.click and row.click.Name or "nil",
            tostring(row.attrs),
            tostring(row.tags)
        )
    end
    out.objectCount = #rows
    return out
end

local function collectSyncState()
    local payload = {
        syncDefs = 0
    }
    local count = 0
    for syncId, meta in pairs(Analyzer.modelSyncDefs) do
        count = count + 1
        if count <= 10 then
            payload["sync" .. count] = string.format(
                "%s | model=%s | tag=%s | syncName=%s | nodes=%s",
                tostring(syncId),
                tostring(meta.ModelName),
                tostring(meta.SysTag),
                tostring(meta.ModelSyncName),
                tostring(meta.NodeCount)
            )
        end
    end
    payload.syncDefs = count
    return payload
end

local function collectInventoryState()
    local payload = {
        backpackCount = LP:FindFirstChild("Backpack") and #LP.Backpack:GetChildren() or 0,
        equippedObject = LP:GetAttribute("EquippedObject"),
        placeId = game.PlaceId,
        gameId = game.GameId,
        jobId = game.JobId
    }

    local leaderstats = LP:FindFirstChild("leaderstats")
    if leaderstats then
        for _, child in ipairs(leaderstats:GetChildren()) do
            if child:IsA("IntValue") or child:IsA("NumberValue") or child:IsA("StringValue") then
                payload["leader_" .. child.Name] = child.Value
            end
        end
    end

    local backpack = LP:FindFirstChild("Backpack")
    if backpack then
        local idx = 0
        for _, child in ipairs(backpack:GetChildren()) do
            if child:IsA("Tool") or child:IsA("Model") then
                idx = idx + 1
                payload["backpack" .. idx] = child.Name
                if idx >= 12 then
                    break
                end
            end
        end
    end

    local char = LP.Character
    if char then
        local idx = 0
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") or child:IsA("Model") then
                idx = idx + 1
                payload["character" .. idx] = child.Name
                if idx >= 8 then
                    break
                end
            end
        end
    end

    return payload
end

local function findTargetScripts()
    local results = {}
    local playerScripts = LP:FindFirstChild("PlayerScripts")
    if not playerScripts then
        return results
    end

    for _, targetName in ipairs(Analyzer.targetScripts) do
        local found = playerScripts:FindFirstChild(targetName, true)
        if found then
            local payload = {
                path = found:GetFullName(),
                class = found.ClassName,
                enabled = found:IsA("LocalScript") and found.Enabled or nil,
                running = nil
            }
            if getsenv and found:IsA("LocalScript") then
                local ok, env = pcall(getsenv, found)
                if ok and type(env) == "table" then
                    local envCount = 0
                    for _ in pairs(env) do
                        envCount = envCount + 1
                    end
                    payload.running = true
                    payload.envKeys = envCount
                end
            end
            results[targetName] = payload
        end
    end
    return results
end

local function logTargetScripts()
    local scripts = findTargetScripts()
    for name, payload in pairs(scripts) do
        writeLine("SCRIPT", "Found", {
            name = name,
            path = payload.path,
            class = payload.class,
            enabled = payload.enabled,
            running = payload.running,
            envKeys = payload.envKeys
        })
    end
end

local function logRelevantAssets()
    local roots = {
        LP:FindFirstChild("PlayerScripts"),
        ReplicatedStorage,
        Workspace
    }

    for _, root in ipairs(roots) do
        if root then
            local emitted = 0
            for _, obj in ipairs(root:GetDescendants()) do
                if obj:IsA("ModuleScript") or obj:IsA("LocalScript") or obj:IsA("Folder") or obj:IsA("Model") then
                    local hit = containsKeyword(obj:GetFullName())
                    if hit then
                        emitted = emitted + 1
                        writeLine("ASSET", "Relevant", {
                            root = root.Name,
                            class = obj.ClassName,
                            name = obj.Name,
                            path = obj:GetFullName()
                        })
                        if emitted >= 150 then
                            writeLine("ASSET", "Truncated", {
                                root = root.Name,
                                emitted = emitted
                            })
                            break
                        end
                    end
                end
            end
        end
    end
end

local function dumpRemoteTree()
    local roots = {
        ReplicatedStorage:FindFirstChild("CommonLibrary"),
        ReplicatedStorage:FindFirstChild("Commander Remotes")
    }

    for _, root in ipairs(roots) do
        if root then
            local events = 0
            local funcs = 0
            for _, obj in ipairs(root:GetDescendants()) do
                if obj:IsA("RemoteEvent") then
                    events = events + 1
                    writeLine("REMOTE_TREE", "RemoteEvent", {
                        path = obj:GetFullName()
                    })
                elseif obj:IsA("RemoteFunction") then
                    funcs = funcs + 1
                    writeLine("REMOTE_TREE", "RemoteFunction", {
                        path = obj:GetFullName()
                    })
                end
            end
            writeLine("REMOTE_TREE", "Summary", {
                root = root:GetFullName(),
                remoteEvents = events,
                remoteFunctions = funcs
            })
        end
    end
end

local function watchValueObject(valueObj, ownerPath)
    if not valueObj or Analyzer.trackedValues[valueObj] then
        return
    end
    Analyzer.trackedValues[valueObj] = true

    local valueName = valueObj.Name
    if not hasInterestingValueName(valueName) then
        return
    end

    writeLine("VALUE", "Observed", {
        owner = ownerPath,
        name = valueName,
        class = valueObj.ClassName,
        value = valueObj.Value
    })

    addConnection(valueObj:GetPropertyChangedSignal("Value"):Connect(function()
        writeLine("VALUE", "Changed", {
            owner = ownerPath,
            name = valueName,
            class = valueObj.ClassName,
            value = valueObj.Value
        })
    end))
end

local function watchModelSignals(model, source)
    if not model or not model:IsA("Model") or Analyzer.trackedModels[model] then
        return
    end
    Analyzer.trackedModels[model] = true

    local hum = model:FindFirstChildOfClass("Humanoid")
    local rootPart = getPrimaryPart(model)
    writeLine("ENTITY_TRACE", "Observed", {
        source = source,
        name = model.Name,
        path = model:GetFullName(),
        kind = classifyInstance(model),
        pos = rootPart and rootPart.Position or nil,
        distance = getDistanceFromPlayer(rootPart),
        attrs = summarizeAttributes(model, 10),
        tags = safeGetTags(model),
        hasHumanoid = hum ~= nil,
        hasAnimator = model:FindFirstChildOfClass("AnimationController") ~= nil
    })

    addConnection(model.AttributeChanged:Connect(function(attr)
        writeLine("ENTITY_TRACE", "AttributeChanged", {
            name = model.Name,
            path = model:GetFullName(),
            attribute = attr,
            value = model:GetAttribute(attr)
        })
    end))

    if hum then
        writeLine("COMBAT", "HealthBaseline", {
            name = model.Name,
            path = model:GetFullName(),
            health = hum.Health,
            maxHealth = hum.MaxHealth
        })
        addConnection(hum.HealthChanged:Connect(function(value)
            writeLine("COMBAT", "HealthChanged", {
                name = model.Name,
                path = model:GetFullName(),
                health = value,
                maxHealth = hum.MaxHealth
            })
        end))
        addConnection(hum:GetPropertyChangedSignal("MaxHealth"):Connect(function()
            writeLine("COMBAT", "MaxHealthChanged", {
                name = model.Name,
                path = model:GetFullName(),
                health = hum.Health,
                maxHealth = hum.MaxHealth
            })
        end))
    end

    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("IntValue") or desc:IsA("NumberValue") or desc:IsA("StringValue") or desc:IsA("BoolValue") then
            watchValueObject(desc, model:GetFullName())
        end
    end

    addConnection(model.DescendantAdded:Connect(function(desc)
        if desc:IsA("IntValue") or desc:IsA("NumberValue") or desc:IsA("StringValue") or desc:IsA("BoolValue") then
            watchValueObject(desc, model:GetFullName())
        elseif desc:IsA("Humanoid") then
            writeLine("COMBAT", "HumanoidAdded", {
                name = model.Name,
                path = model:GetFullName(),
                health = desc.Health,
                maxHealth = desc.MaxHealth
            })
        elseif desc:IsA("AnimationTrack") or desc:IsA("Animator") then
            writeLine("ENTITY_TRACE", "AnimationNodeAdded", {
                name = model.Name,
                path = model:GetFullName(),
                child = desc.ClassName,
                childName = desc.Name
            })
        end
    end))
end

local function logWorldObject(instance, action, extra)
    local root = getRootInterestingInstance(instance)
    if not root or not isWorldObjectCandidate(root) then
        return
    end

    local part = root:IsA("BasePart") and root or getPrimaryPart(root)
    local prompt = root:FindFirstChildWhichIsA("ProximityPrompt", true)
    local click = root:FindFirstChildWhichIsA("ClickDetector", true)
    local payload = {
        action = action,
        name = root.Name,
        class = root.ClassName,
        path = root:GetFullName(),
        kind = classifyInstance(root),
        pos = part and part.Position or nil,
        distance = getDistanceFromPlayer(part),
        attrs = summarizeAttributes(root, 10),
        tags = safeGetTags(root),
        prompt = prompt and prompt.Name or nil,
        click = click and click.Name or nil
    }
    if extra then
        for key, value in pairs(extra) do
            payload[key] = value
        end
    end
    writeLine("OBJECT", action, payload)
end

local function watchPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") or Analyzer.trackedPrompts[prompt] then
        return
    end
    Analyzer.trackedPrompts[prompt] = true

    local summary = getPromptSummary(prompt) or {}
    summary.kind = classifyInstance(getRootInterestingInstance(prompt))
    writeLine("PROMPT", "Observed", summary)

    addConnection(prompt:GetPropertyChangedSignal("Enabled"):Connect(function()
        local payload = getPromptSummary(prompt) or {}
        payload.kind = classifyInstance(getRootInterestingInstance(prompt))
        writeLine("PROMPT", "EnabledChanged", payload)
    end))
end

local function watchGuiObject(guiObject)
    if not guiObject or Analyzer.trackedGui[guiObject] then
        return
    end
    Analyzer.trackedGui[guiObject] = true

    local function emit(action)
        local text
        if guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") or guiObject:IsA("TextBox") then
            text = guiObject.Text
        else
            text = guiObject.Name
        end
        local interesting = select(1, containsKeyword(text)) or select(1, containsKeyword(guiObject:GetFullName()))
        if interesting then
            writeLine("GUI_TRACE", action, {
                class = guiObject.ClassName,
                name = guiObject.Name,
                path = guiObject:GetFullName(),
                text = text,
                visible = guiObject:IsA("GuiObject") and guiObject.Visible or nil
            })
        end
    end

    emit("Observed")

    if guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") or guiObject:IsA("TextBox") then
        addConnection(guiObject:GetPropertyChangedSignal("Text"):Connect(function()
            emit("TextChanged")
        end))
    end
    if guiObject:IsA("GuiObject") then
        addConnection(guiObject:GetPropertyChangedSignal("Visible"):Connect(function()
            emit("VisibleChanged")
        end))
    end
end

local function hookIncomingRemotes()
    local roots = {
        ReplicatedStorage:FindFirstChild("CommonLibrary"),
        ReplicatedStorage:FindFirstChild("Commander Remotes")
    }

    for _, root in ipairs(roots) do
        if root then
            for _, obj in ipairs(root:GetDescendants()) do
                if obj:IsA("RemoteEvent") and not Analyzer.remotesHooked[obj] then
                    Analyzer.remotesHooked[obj] = true
                    addConnection(obj.OnClientEvent:Connect(function(...)
                        if not Analyzer.active then
                            return
                        end
                        local args = { ... }
                        local argsText = summarizeArgs(args)
                        rememberActivity("IN", obj.Name, argsText)
                        writeLine("REMOTE_IN", "OnClientEvent", {
                            remote = obj:GetFullName(),
                            argc = #args,
                            args = argsText
                        })

                        if obj.Name == "ModelSync" and type(args[2]) == "table" then
                            local syncId = tostring(args[1])
                            Analyzer.modelSyncDefs[syncId] = {
                                ModelName = args[2].ModelName,
                                ModelSyncName = args[2].ModelSyncName,
                                NodeCount = args[2].NodeCount,
                                SysTag = args[2].SysTag
                            }
                            writeLine("SYNC_DEF", "Registered", {
                                syncId = syncId,
                                modelName = args[2].ModelName,
                                modelSyncName = args[2].ModelSyncName,
                                nodeCount = args[2].NodeCount,
                                sysTag = args[2].SysTag
                            })
                        elseif obj.Name == "Message" and typeof(args[1]) == "string" then
                            local messageKind = tostring(args[1])
                            if messageKind == "StreamingAddData" or messageKind == "StreamingUpdateData" or messageKind == "StreamingRemoveData" then
                                local syncId = args[2] ~= nil and tostring(args[2]) or nil
                                local meta = syncId and Analyzer.modelSyncDefs[syncId] or nil
                                writeLine("SYNC_EVENT", messageKind, {
                                    syncId = syncId,
                                    modelName = meta and meta.ModelName or nil,
                                    modelSyncName = meta and meta.ModelSyncName or nil,
                                    sysTag = meta and meta.SysTag or nil,
                                    updateKind = args[3],
                                    payload = args[4]
                                })
                            elseif messageKind == "AreaInitComplete" or messageKind == "ServerSetPlayerCFrame" or messageKind == "ClientAreaShowerBeforeInitedResponse" then
                                writeLine("AREA", messageKind, {
                                    arg2 = args[2],
                                    arg3 = args[3],
                                    arg4 = args[4]
                                })
                            end
                        elseif obj.Name == "NotificationEvent" and args[1] == "ServerMessage" then
                            writeLine("ANNOUNCE", "ServerMessage", {
                                subtype = args[2],
                                template = args[3],
                                payload = args[4]
                            })
                        end

                        local lowerRemote = string.lower(obj.Name)
                        if string.find(lowerRemote, "message") or string.find(lowerRemote, "notify") or string.find(lowerRemote, "chat") then
                            for i = 1, #args do
                                local arg = args[i]
                                if typeof(arg) == "string" and isSpawnAnnouncement(arg) then
                                    writeLine("CHAT_TRIGGER", "RemoteCandidate", {
                                        remote = obj:GetFullName(),
                                        text = arg,
                                        recent = getRecentActivitySummary(6, 6)
                                    })
                                end
                            end
                        end
                    end))
                elseif obj:IsA("RemoteFunction") and not Analyzer.remotesHooked[obj] then
                    Analyzer.remotesHooked[obj] = true
                    writeLine("REMOTE_IN", "RemoteFunctionSeen", {
                        remote = obj:GetFullName()
                    })
                end
            end
        end
    end
end

local function installNamecallHook()
    if Analyzer.hooksInstalled or not (hookmetamethod and getnamecallmethod) then
        return
    end

    Analyzer.hooksInstalled = true
    local old
    old = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = { ... }

        if Analyzer.active and typeof(self) == "Instance" then
            if method == "FireServer" or method == "InvokeServer" then
                local fullName = self.GetFullName and self:GetFullName() or tostring(self)
                local lower = string.lower(fullName)
                if string.find(lower, "commonlibrary") or string.find(lower, "commander remotes") or string.find(lower, "postie") then
                    local argsText = summarizeArgs(args)
                    rememberActivity("OUT", self.Name, argsText)
                    writeLine("REMOTE_OUT", method, {
                        remote = fullName,
                        argc = #args,
                        args = argsText
                    })
                end
            elseif method == "SetCore" and self == StarterGui then
                local key = tostring(args[1] or "")
                if key == "ChatMakeSystemMessage" then
                    local messageData = args[2]
                    local text = type(messageData) == "table" and (messageData.Text or messageData.text) or safeTostring(messageData)
                    writeLine("CHAT_TRIGGER", "SetCoreSystemMessage", {
                        key = key,
                        text = text,
                        payload = safeTostring(messageData),
                        recent = getRecentActivitySummary(6, 6)
                    })
                end
            elseif method == "DisplaySystemMessage" then
                local text = tostring(args[1] or "")
                writeLine("CHAT_TRIGGER", "DisplaySystemMessage", {
                    channel = self:GetFullName(),
                    text = text,
                    recent = getRecentActivitySummary(6, 6)
                })
            end
        end

        return old(self, ...)
    end)
end

local function watchChatSystems()
    pcall(function()
        if TextChatService.MessageReceived then
            addConnection(TextChatService.MessageReceived:Connect(function(message)
                local text = message and message.Text or ""
                local payload = {
                    text = text,
                    prefix = message and message.PrefixText or nil,
                    metadata = message and message.Metadata or nil,
                    status = message and message.Status or nil,
                    recent = getRecentActivitySummary(6, 6)
                }
                writeLine("CHAT", "TextChatService", payload)
                if isSpawnAnnouncement(text) then
                    writeLine("CHAT_TRIGGER", "SpawnAnnouncementSeen", payload)
                end
            end))
        end
    end)

    pcall(function()
        local channels = TextChatService:FindFirstChild("TextChannels")
        if channels then
            for _, channel in ipairs(channels:GetChildren()) do
                if channel:IsA("TextChannel") and channel.MessageReceived then
                    addConnection(channel.MessageReceived:Connect(function(message)
                        local text = message and message.Text or ""
                        local payload = {
                            channel = channel.Name,
                            text = text,
                            prefix = message and message.PrefixText or nil,
                            recent = getRecentActivitySummary(6, 6)
                        }
                        writeLine("CHAT", "ChannelMessage", payload)
                        if isSpawnAnnouncement(text) then
                            writeLine("CHAT_TRIGGER", "ChannelSpawnAnnouncement", payload)
                        end
                    end))
                end
            end
        end
    end)

    pcall(function()
        local legacy = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if legacy then
            local filtered = legacy:FindFirstChild("OnMessageDoneFiltering")
            if filtered and filtered:IsA("RemoteEvent") then
                addConnection(filtered.OnClientEvent:Connect(function(messageData)
                    local text = ""
                    local from = ""
                    if type(messageData) == "table" then
                        text = tostring(messageData.Message or messageData.message or "")
                        from = tostring(messageData.FromSpeaker or messageData.fromSpeaker or "")
                    else
                        text = safeTostring(messageData)
                    end
                    local payload = {
                        from = from,
                        text = text,
                        raw = safeTostring(messageData),
                        recent = getRecentActivitySummary(6, 6)
                    }
                    writeLine("CHAT", "LegacyFiltered", payload)
                    if isSpawnAnnouncement(text) then
                        writeLine("CHAT_TRIGGER", "LegacySpawnAnnouncement", payload)
                    end
                end))
            end
        end
    end)
end

local function probeRemoteFunction(path)
    local current = ReplicatedStorage
    for chunk in string.gmatch(path, "[^/]+") do
        current = current and current:FindFirstChild(chunk)
    end
    if not current or not current:IsA("RemoteFunction") then
        writeLine("PROBE", "Missing", { path = path })
        return
    end

    local ok, result = pcall(function()
        return current:InvokeServer()
    end)

    if ok then
        writeLine("PROBE", "InvokeSuccess", {
            path = current:GetFullName(),
            result = safeTostring(result)
        })
    else
        writeLine("PROBE", "InvokeFailed", {
            path = current:GetFullName(),
            error = tostring(result)
        })
    end
end

local function probeDataFunctions()
    probeRemoteFunction("CommonLibrary/Tool/RemoteManager/Funcs/DataPullFunc")
    probeRemoteFunction("CommonLibrary/Tool/RemoteManager/Funcs/GetGamePlayerFunc")
end

local function watchPlayerState()
    local attrs = {
        "EquippedObject",
        "Dead",
        "Energy",
        "Level",
        "Exp"
    }

    for _, attr in ipairs(attrs) do
        pcall(function()
            addConnection(LP:GetAttributeChangedSignal(attr):Connect(function()
                writeLine("PLAYER", "AttributeChanged", {
                    attribute = attr,
                    value = LP:GetAttribute(attr)
                })
            end))
        end)
    end

    local backpack = LP:FindFirstChild("Backpack")
    if backpack then
        addConnection(backpack.ChildAdded:Connect(function(child)
            writeLine("INVENTORY", "BackpackAdded", {
                child = child.Name,
                class = child.ClassName
            })
            logWorldObject(child, "BackpackChild")
        end))
        addConnection(backpack.ChildRemoved:Connect(function(child)
            writeLine("INVENTORY", "BackpackRemoved", {
                child = child.Name,
                class = child.ClassName
            })
        end))
    end

    local function watchCharacter(char)
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            writeLine("PLAYER", "HumanoidObserved", {
                health = hum.Health,
                maxHealth = hum.MaxHealth
            })
            addConnection(hum.HealthChanged:Connect(function(value)
                writeLine("PLAYER", "HealthChanged", {
                    health = value,
                    maxHealth = hum.MaxHealth
                })
            end))
        end

        addConnection(char.ChildAdded:Connect(function(child)
            writeLine("PLAYER", "CharacterChildAdded", {
                child = child.Name,
                class = child.ClassName
            })
            logWorldObject(child, "CharacterChild")
        end))
        addConnection(char.ChildRemoved:Connect(function(child)
            writeLine("PLAYER", "CharacterChildRemoved", {
                child = child.Name,
                class = child.ClassName
            })
        end))
    end

    if LP.Character then
        watchCharacter(LP.Character)
    end
    addConnection(LP.CharacterAdded:Connect(function(char)
        writeLine("PLAYER", "CharacterAdded", {
            path = char:GetFullName()
        })
        watchCharacter(char)
    end))
end

local function watchGuiState()
    local playerGui = LP:FindFirstChild("PlayerGui")
    if not playerGui then
        return
    end

    for _, obj in ipairs(playerGui:GetDescendants()) do
        if obj:IsA("GuiObject") then
            watchGuiObject(obj)
        end
    end

    addConnection(playerGui.DescendantAdded:Connect(function(obj)
        if obj:IsA("GuiObject") then
            watchGuiObject(obj)
        end
    end))
end

local function watchPromptSystems()
    pcall(function()
        addConnection(ProximityPromptService.PromptShown:Connect(function(prompt)
            watchPrompt(prompt)
            local payload = getPromptSummary(prompt) or {}
            payload.kind = classifyInstance(getRootInterestingInstance(prompt))
            payload.recent = getRecentActivitySummary(6, 6)
            writeLine("PROMPT", "Shown", payload)
        end))
    end)

    pcall(function()
        addConnection(ProximityPromptService.PromptHidden:Connect(function(prompt)
            local payload = getPromptSummary(prompt) or {}
            payload.kind = classifyInstance(getRootInterestingInstance(prompt))
            payload.recent = getRecentActivitySummary(6, 6)
            writeLine("PROMPT", "Hidden", payload)
        end))
    end)

    pcall(function()
        addConnection(ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
            local payload = getPromptSummary(prompt) or {}
            payload.kind = classifyInstance(getRootInterestingInstance(prompt))
            payload.player = player and player.Name or nil
            payload.recent = getRecentActivitySummary(6, 6)
            writeLine("PROMPT", "Triggered", payload)
        end))
    end)
end

local function watchInputState()
    addConnection(UserInputService.InputBegan:Connect(function(input, processed)
        if processed then
            return
        end
        writeLine("INPUT", "Began", {
            key = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode.Name or nil,
            userInputType = tostring(input.UserInputType),
            recent = getRecentActivitySummary(4, 6)
        })
    end))

    addConnection(UserInputService.InputEnded:Connect(function(input, processed)
        if processed then
            return
        end
        writeLine("INPUT", "Ended", {
            key = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode.Name or nil,
            userInputType = tostring(input.UserInputType),
            recent = getRecentActivitySummary(4, 6)
        })
    end))
end

local function watchWorkspaceEntities()
    addConnection(Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Model") and isEntityCandidate(obj) and not markSeen(obj, "Entity") then
            local part = getPrimaryPart(obj)
            writeLine("ENTITY", "Added", {
                name = obj.Name,
                path = obj:GetFullName(),
                kind = classifyInstance(obj),
                pos = part and part.Position or nil,
                distance = getDistanceFromPlayer(part),
                owner = obj:GetAttribute("OwnerUserId"),
                monsterId = obj:GetAttribute("MonsterId"),
                npcId = obj:GetAttribute("NpcId"),
                level = obj:GetAttribute("Level"),
                attrs = summarizeAttributes(obj, 8),
                tags = safeGetTags(obj)
            })
            watchModelSignals(obj, "Workspace")
        elseif isWorldObjectCandidate(obj) and not markSeen(getRootInterestingInstance(obj), "WorldObject") then
            logWorldObject(obj, "Added")
            if obj:IsA("ProximityPrompt") then
                watchPrompt(obj)
            end
        end
    end))

    addConnection(Workspace.DescendantRemoving:Connect(function(obj)
        if obj:IsA("Model") and isEntityCandidate(obj) then
            writeLine("ENTITY", "Removing", {
                name = obj.Name,
                path = obj:GetFullName()
            })
        elseif isWorldObjectCandidate(obj) then
            logWorldObject(obj, "Removing")
        end
    end))

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and isEntityCandidate(obj) then
            watchModelSignals(obj, "Initial")
        elseif obj:IsA("ProximityPrompt") then
            watchPrompt(obj)
        elseif (obj:IsA("Model") or obj:IsA("BasePart")) and isWorldObjectCandidate(obj) and not markSeen(getRootInterestingInstance(obj), "InitialWorldObject") then
            logWorldObject(obj, "Initial")
        end
    end
end

local function snapshot()
    local payload = collectInventoryState()
    local entities = collectEntityRows()
    local objects = collectObjectRows()
    local syncState = collectSyncState()
    for key, value in pairs(entities) do
        payload[key] = value
    end
    for key, value in pairs(objects) do
        payload[key] = value
    end
    for key, value in pairs(syncState) do
        payload[key] = value
    end
    writeLine("SNAPSHOT", "Tick", payload)
end

local function updateGui()
    local ui = Analyzer.ui
    if not ui.statusLabel then
        return
    end

    local entities = collectEntityRows()
    local objects = collectObjectRows()
    local inventory = collectInventoryState()
    ui.statusLabel.Text = Analyzer.active and "Status: ACTIVE" or "Status: STOPPED"
    ui.fileLabel.Text = "File: " .. tostring(Analyzer.file or "n/a")
    ui.placeLabel.Text = "Place: " .. tostring(game.PlaceId) .. " | Players: " .. tostring(#Players:GetPlayers())
    ui.inventoryLabel.Text = "Backpack: " .. tostring(inventory.backpackCount) .. " | Equipped: " .. tostring(inventory.equippedObject)
    ui.entityLabel.Text = "Entities: " .. tostring(entities.entityCount or 0) .. " | Objects: " .. tostring(objects.objectCount or 0)
end

local function createGui()
    local parent = getGuiParent()
    local old = parent:FindFirstChild("CatchAMonsterAnalyzerUI")
    if old then
        old:Destroy()
    end

    local sg = Instance.new("ScreenGui")
    sg.Name = "CatchAMonsterAnalyzerUI"
    sg.ResetOnSpawn = false
    sg.Parent = parent

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 340, 0, 165)
    frame.Position = UDim2.new(1, -355, 0, 24)
    frame.BackgroundColor3 = Color3.fromRGB(14, 18, 22)
    frame.BorderColor3 = Color3.fromRGB(60, 170, 220)
    frame.Active = true
    frame.Draggable = true
    frame.Parent = sg

    local function makeLabel(y)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -16, 0, 18)
        lbl.Position = UDim2.new(0, 8, 0, y)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(220, 230, 240)
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = frame
        return lbl
    end

    local title = makeLabel(6)
    title.Text = "Catch a Monster Analyzer"
    title.TextColor3 = Color3.fromRGB(160, 230, 255)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 22)
    closeBtn.Position = UDim2.new(1, -28, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.Code
    closeBtn.TextSize = 12
    closeBtn.Parent = frame
    closeBtn.MouseButton1Click:Connect(function()
        if Analyzer.stop then
            Analyzer.stop("GUI")
        end
    end)

    Analyzer.ui = {
        screenGui = sg,
        frame = frame,
        statusLabel = makeLabel(30),
        fileLabel = makeLabel(50),
        placeLabel = makeLabel(70),
        inventoryLabel = makeLabel(90),
        entityLabel = makeLabel(110)
    }

    local startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(0, 72, 0, 24)
    startBtn.Position = UDim2.new(0, 8, 1, -32)
    startBtn.BackgroundColor3 = Color3.fromRGB(30, 110, 90)
    startBtn.Text = "Restart"
    startBtn.TextColor3 = Color3.new(1, 1, 1)
    startBtn.Font = Enum.Font.Code
    startBtn.TextSize = 12
    startBtn.Parent = frame
    startBtn.MouseButton1Click:Connect(function()
        if Analyzer.stop then
            Analyzer.stop("Restart")
        end
        task.wait(0.1)
        if Analyzer.start then
            Analyzer.start("GUI")
        end
    end)

    local scanBtn = Instance.new("TextButton")
    scanBtn.Size = UDim2.new(0, 72, 0, 24)
    scanBtn.Position = UDim2.new(0, 86, 1, -32)
    scanBtn.BackgroundColor3 = Color3.fromRGB(70, 90, 140)
    scanBtn.Text = "Scan now"
    scanBtn.TextColor3 = Color3.new(1, 1, 1)
    scanBtn.Font = Enum.Font.Code
    scanBtn.TextSize = 12
    scanBtn.Parent = frame
    scanBtn.MouseButton1Click:Connect(function()
        snapshot()
        logTargetScripts()
        updateGui()
    end)

    local probeBtn = Instance.new("TextButton")
    probeBtn.Size = UDim2.new(0, 72, 0, 24)
    probeBtn.Position = UDim2.new(0, 164, 1, -32)
    probeBtn.BackgroundColor3 = Color3.fromRGB(120, 90, 40)
    probeBtn.Text = "Probe data"
    probeBtn.TextColor3 = Color3.new(1, 1, 1)
    probeBtn.Font = Enum.Font.Code
    probeBtn.TextSize = 12
    probeBtn.Parent = frame
    probeBtn.MouseButton1Click:Connect(function()
        probeDataFunctions()
    end)

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 88, 0, 24)
    copyBtn.Position = UDim2.new(0, 242, 1, -32)
    copyBtn.BackgroundColor3 = Color3.fromRGB(50, 80, 140)
    copyBtn.Text = "Copy file"
    copyBtn.TextColor3 = Color3.new(1, 1, 1)
    copyBtn.Font = Enum.Font.Code
    copyBtn.TextSize = 12
    copyBtn.Parent = frame
    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard and Analyzer.file then
            pcall(function()
                setclipboard(Analyzer.file)
            end)
            copyBtn.Text = "Copied"
            task.delay(1.5, function()
                if copyBtn.Parent then
                    copyBtn.Text = "Copy file"
                end
            end)
        end
    end)

    updateGui()
end

local function startLoops()
    task.spawn(function()
        while Analyzer.active do
            if os.clock() - Analyzer.lastSnapshotAt >= SNAPSHOT_INTERVAL then
                Analyzer.lastSnapshotAt = os.clock()
                snapshot()
                updateGui()
            end
            task.wait(0.25)
        end
    end)
end

function Analyzer.stop(origin)
    if not Analyzer.active then
        return
    end
    Analyzer.active = false
    writeLine("TRACE", "Stopped", {
        origin = origin or "unknown",
        file = Analyzer.file
    })
    disconnectAll()
    pcall(function()
        if Analyzer.ui.screenGui then
            Analyzer.ui.screenGui:Destroy()
        end
    end)
end

function Analyzer.start(origin)
    Analyzer.active = true
    Analyzer.session = tostring(os.time()) .. "-" .. tostring(math.floor(os.clock() * 1000) % 100000)
    Analyzer.file = nextFileName()
    Analyzer.seen = {}
    Analyzer.remotesHooked = {}
    Analyzer.recentActivity = {}
    Analyzer.lastSnapshotAt = 0
    Analyzer.trackedModels = {}
    Analyzer.trackedPrompts = {}
    Analyzer.trackedValues = {}
    Analyzer.trackedGui = {}
    Analyzer.modelSyncDefs = {}

    if Analyzer.file and writefile then
        pcall(function()
            writefile(Analyzer.file, "[BOOT] File created | origin=" .. tostring(origin or "AutoStart") .. "\n")
        end)
    end

    createGui()
    dumpRemoteTree()
    logTargetScripts()
    logRelevantAssets()
    hookIncomingRemotes()
    installNamecallHook()
    watchChatSystems()
    watchPlayerState()
    watchGuiState()
    watchPromptSystems()
    watchInputState()
    watchWorkspaceEntities()
    probeDataFunctions()

    writeLine("TRACE", "Started", {
        origin = origin or "AutoStart",
        file = Analyzer.file,
        placeId = game.PlaceId,
        gameId = game.GameId,
        jobId = game.JobId,
        player = LP and LP.Name or "n/a"
    })

    snapshot()
    startLoops()
end

Analyzer.start("AutoStart")
