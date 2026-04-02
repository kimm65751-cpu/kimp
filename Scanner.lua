local existing = rawget(_G, "OjoDeDiosAnalyzer")
if existing and existing.active then
    warn("[OjoDeDios Analyzer] Ya hay una sesion activa: " .. tostring(existing.file))
    return existing
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local LP = Players.LocalPlayer

local TRACE_PREFIX = "OjoDeDios_Analyzer"
local TRACE_EXT = ".txt"
local SNAPSHOT_INTERVAL = 1

local Analyzer = {
    active = false,
    initialized = false,
    loopStarted = false,
    baselineDumped = false,
    file = nil,
    session = tostring(os.time()) .. "-" .. tostring(math.floor(os.clock() * 1000) % 100000),
    recent = {},
    watched = {}
}

_G.OjoDeDiosAnalyzer = Analyzer

local function announce(msg)
    print("[OjoDeDios Analyzer] " .. msg)
end

local function traceValue(v, depth)
    depth = depth or 0
    local kind = typeof and typeof(v) or type(v)
    if kind == "Instance" then
        local fullName = tostring(v)
        pcall(function()
            fullName = v:GetFullName()
        end)
        local itemName = nil
        pcall(function()
            itemName = v:GetAttribute("ItemName")
        end)
        if itemName and itemName ~= "" then
            return fullName .. "{" .. tostring(itemName) .. "}"
        end
        return fullName
    elseif kind == "table" then
        if depth >= 1 then
            return "{...}"
        end
        local keys = {}
        for k in pairs(v) do
            table.insert(keys, tostring(k))
        end
        table.sort(keys)
        local parts = {}
        for i, key in ipairs(keys) do
            if i > 10 then
                table.insert(parts, "...")
                break
            end
            table.insert(parts, key .. "=" .. traceValue(v[key], depth + 1))
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    elseif kind == "string" then
        local s = v:gsub("[\r\n]", " ")
        if #s > 180 then
            s = string.sub(s, 1, 180) .. "..."
        end
        return s
    else
        return tostring(v)
    end
end

local function traceFileExists(fileName)
    if isfile then
        local ok, result = pcall(isfile, fileName)
        if ok then
            return result == true
        end
    end
    if readfile then
        local ok = pcall(readfile, fileName)
        if ok then
            return true
        end
    end
    if listfiles then
        local ok, files = pcall(listfiles, "")
        if ok and type(files) == "table" then
            local normalized = string.lower(fileName)
            for _, path in ipairs(files) do
                local name = string.lower(tostring(path):match("[^\\/]+$") or tostring(path))
                if name == normalized then
                    return true
                end
            end
        end
    end
    return false
end

local function resolveNextTraceFile()
    local idx = 1
    while traceFileExists(string.format("%s_%d%s", TRACE_PREFIX, idx, TRACE_EXT)) do
        idx = idx + 1
    end
    return string.format("%s_%d%s", TRACE_PREFIX, idx, TRACE_EXT)
end

local function appendTrace(line)
    local targetFile = Analyzer.file
    if not targetFile then
        return
    end
    if appendfile then
        appendfile(targetFile, line .. "\n")
    elseif writefile then
        local old = ""
        if readfile then
            local ok, existing = pcall(readfile, targetFile)
            if ok and existing then
                old = existing
            end
        end
        writefile(targetFile, old .. line .. "\n")
    end
end

local function trace(topic, eventName, payload, force)
    if not (Analyzer.active or force) then
        return
    end
    local suffix = ""
    if type(payload) == "table" then
        local keys = {}
        for k in pairs(payload) do
            table.insert(keys, tostring(k))
        end
        table.sort(keys)
        local parts = {}
        for _, key in ipairs(keys) do
            table.insert(parts, key .. "=" .. traceValue(payload[key]))
        end
        if #parts > 0 then
            suffix = " | " .. table.concat(parts, " | ")
        end
    elseif payload ~= nil then
        suffix = " | value=" .. traceValue(payload)
    end
    local line = string.format("[%s] [%s] [%s] %s%s", os.date("%X"), Analyzer.session, topic, eventName, suffix)
    local dedupeKey = topic .. "|" .. eventName .. "|" .. suffix
    local now = os.clock()
    if not force and Analyzer.recent[dedupeKey] and now - Analyzer.recent[dedupeKey] < 0.2 then
        return
    end
    Analyzer.recent[dedupeKey] = now
    pcall(function()
        appendTrace(line)
    end)
end

local function markWatch(instance, category)
    if not instance then
        return true
    end
    local state = Analyzer.watched[instance]
    if not state then
        state = {}
        Analyzer.watched[instance] = state
    end
    if state[category] then
        return true
    end
    state[category] = true
    return false
end

local function isTrackedItem(itemName)
    local n = string.lower(tostring(itemName or ""))
    return string.find(n, "spirit box")
        or string.find(n, "laser projector")
        or string.find(n, "thermometer")
        or string.find(n, "emf")
        or string.find(n, "blacklight")
        or string.find(n, "video camera")
        or string.find(n, "spirit book")
        or string.find(n, "flower")
        or string.find(n, "plant")
        or string.find(n, "vase")
end

local function isWitherCandidate(obj)
    local n = string.lower(obj.Name or "")
    return string.find(n, "flower")
        or string.find(n, "plant")
        or string.find(n, "vase")
        or string.find(n, "wilt")
        or string.find(n, "wither")
        or string.find(n, "paint")
        or string.find(n, "picture")
        or string.find(n, "frame")
        or string.find(n, "canvas")
        or string.find(n, "metal")
        or string.find(n, "rust")
        or string.find(n, "corrod")
end

local function buildEvidenceReverseMap()
    local reverse = {}
    pcall(function()
        local modules = ReplicatedStorage:FindFirstChild("Modules")
        local evidenceModule = modules and modules:FindFirstChild("EvidenceTypes")
        if evidenceModule then
            local ok, evidenceTypes = pcall(require, evidenceModule)
            if ok and type(evidenceTypes) == "table" then
                for name, value in pairs(evidenceTypes) do
                    reverse[value] = name
                end
                trace("MODULES", "EvidenceTypesLoaded", evidenceTypes, true)
            end
        end
    end)
    return reverse
end

local function dumpGhostTypeModules()
    if Analyzer.baselineDumped then
        return
    end
    Analyzer.baselineDumped = true
    local reverseEvidence = buildEvidenceReverseMap()
    pcall(function()
        local modules = ReplicatedStorage:FindFirstChild("Modules")
        local ghostTypes = modules and modules:FindFirstChild("GhostTypes")
        if not ghostTypes then
            return
        end
        for _, moduleScript in ipairs(ghostTypes:GetChildren()) do
            if moduleScript:IsA("ModuleScript") then
                local ok, ghostInfo = pcall(require, moduleScript)
                if ok and type(ghostInfo) == "table" then
                    local evidence = {}
                    for _, ev in ipairs(ghostInfo.Evidence or {}) do
                        table.insert(evidence, reverseEvidence[ev] or tostring(ev))
                    end
                    trace("MODULES", "GhostTypeLoaded", {
                        ghost = moduleScript.Name,
                        evidence = table.concat(evidence, ", "),
                        fakeGhostOrb = ghostInfo.FakeGhostOrb,
                        headless = ghostInfo.Headless,
                        invisibleOnLIDAR = ghostInfo.InvisibleOnLIDAR,
                        onlyFavoriteRoom = ghostInfo.CanOnlyHuntInFavoriteRoom
                    }, true)
                else
                    trace("MODULES", "GhostTypeRequireFailed", {
                        ghost = moduleScript.Name,
                        ok = ok,
                        result = ghostInfo
                    }, true)
                end
            end
        end
    end)
end

local function watchTrackedTool(tool)
    if not tool then
        return
    end
    local itemName = tostring(tool:GetAttribute("ItemName") or tool.Name)
    if not isTrackedItem(itemName) then
        return
    end
    if markWatch(tool, "TrackedTool") then
        return
    end
    pcall(function()
        tool.AttributeChanged:Connect(function(attr)
            if attr == "Enabled" or attr == "Power" or attr == "PhotoRewardType" or attr == "Withered" then
                trace("ITEM", "AttributeChanged", {
                    tool = tool,
                    item = itemName,
                    attribute = attr,
                    value = tool:GetAttribute(attr),
                    parent = tool.Parent
                })
            end
        end)
    end)
    pcall(function()
        tool.AncestryChanged:Connect(function()
            trace("ITEM", "AncestryChanged", {
                tool = tool,
                item = itemName,
                parent = tool.Parent
            })
        end)
    end)
    pcall(function()
        local handle = tool:FindFirstChild("Handle") or tool:WaitForChild("Handle", 5)
        local tone = handle and handle:FindFirstChild("Tone")
        if tone and tone:IsA("Sound") then
            tone.Changed:Connect(function(prop)
                if prop == "Volume" or prop == "PlaybackSpeed" or prop == "Playing" or prop == "TimePosition" or prop == "SoundId" then
                    local value = nil
                    pcall(function()
                        value = tone[prop]
                    end)
                    trace("ITEM", "ToneChanged", {
                        tool = tool,
                        item = itemName,
                        property = prop,
                        value = value,
                        volume = tone.Volume,
                        playbackSpeed = tone.PlaybackSpeed,
                        playing = tone.Playing
                    })
                end
            end)
        end
    end)
end

local function watchPhotoRewardItem(item)
    if not item then
        return
    end
    local itemName = tostring(item:GetAttribute("ItemName") or "")
    local currentValue = tostring(item:GetAttribute("PhotoRewardType") or "")
    if itemName == "" and currentValue == "" then
        return
    end
    if markWatch(item, "PhotoReward") then
        return
    end
    pcall(function()
        item:GetAttributeChangedSignal("PhotoRewardType"):Connect(function()
            local value = tostring(item:GetAttribute("PhotoRewardType") or "")
            if value ~= "" then
                local topic = value == "WitheredFlowers" and "WITHER" or "PHOTO_REWARD"
                trace(topic, "PhotoRewardTypeChanged", {
                    item = item,
                    value = value,
                    parent = item.Parent
                })
            end
        end)
    end)
end

local function watchWitherObject(obj)
    if not obj or not isWitherCandidate(obj) then
        return
    end
    if markWatch(obj, "WitherObject") then
        return
    end
    pcall(function()
        obj.AttributeChanged:Connect(function(attr)
            if attr == "Withered" or attr == "PhotoRewardType" then
                trace("WITHER", "AttributeChanged", {
                    object = obj,
                    attribute = attr,
                    value = obj:GetAttribute(attr)
                })
            end
        end)
    end)
    if obj:IsA("BasePart") then
        pcall(function()
            obj:GetPropertyChangedSignal("Color"):Connect(function()
                trace("WITHER", "ColorChanged", {
                    object = obj,
                    color = obj.Color,
                    material = obj.Material
                })
            end)
        end)
        pcall(function()
            obj:GetPropertyChangedSignal("Material"):Connect(function()
                trace("WITHER", "MaterialChanged", {
                    object = obj,
                    material = obj.Material,
                    color = obj.Color
                })
            end)
        end)
    elseif obj:IsA("Decal") then
        pcall(function()
            obj:GetPropertyChangedSignal("Texture"):Connect(function()
                trace("WITHER", "TextureChanged", {
                    object = obj,
                    texture = obj.Texture,
                    transparency = obj.Transparency
                })
            end)
        end)
    elseif obj:IsA("ImageLabel") then
        pcall(function()
            obj:GetPropertyChangedSignal("Image"):Connect(function()
                trace("WITHER", "ImageChanged", {
                    object = obj,
                    image = obj.Image,
                    transparency = obj.ImageTransparency
                })
            end)
        end)
    end
end

local function watchHandprintVisuals()
    pcall(function()
        local folder = Workspace:FindFirstChild("Handprints")
        if not folder or markWatch(folder, "HandprintsFolder") then
            return
        end
        local function hookPrint(obj)
            if markWatch(obj, "HandprintObject") then
                return
            end
            local gui = obj:FindFirstChildOfClass("SurfaceGui")
            local img = gui and gui:FindFirstChildOfClass("ImageLabel")
            if img then
                img:GetPropertyChangedSignal("ImageTransparency"):Connect(function()
                    trace("HANDPRINTS", "VisibilityChanged", {
                        object = obj,
                        transparency = img.ImageTransparency
                    })
                end)
            end
        end
        for _, child in ipairs(folder:GetChildren()) do
            hookPrint(child)
        end
        folder.ChildAdded:Connect(function(child)
            trace("HANDPRINTS", "PrintAdded", {
                object = child,
                parent = child.Parent
            })
            hookPrint(child)
        end)
    end)
end

local function watchRelevantRemoteEvents()
    pcall(function()
        local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
        if not eventsFolder then
            return
        end
        local function shouldTraceRemote(remoteName)
            local n = string.lower(remoteName or "")
            return string.find(n, "therm")
                or string.find(n, "emf")
                or string.find(n, "ghost")
                or string.find(n, "spirit")
                or string.find(n, "laser")
                or string.find(n, "orb")
                or string.find(n, "print")
                or string.find(n, "photo")
                or string.find(n, "journal")
                or string.find(n, "subtitle")
                or string.find(n, "objective")
                or string.find(n, "wither")
                or string.find(n, "lidar")
                or string.find(n, "lobby")
        end
        local function hookRemote(remote)
            if not remote:IsA("RemoteEvent") then
                return
            end
            if not shouldTraceRemote(remote.Name) then
                return
            end
            if markWatch(remote, "RemoteEventTrace") then
                return
            end
            remote.OnClientEvent:Connect(function(...)
                local args = { ... }
                local preview = {}
                for i = 1, math.min(#args, 4) do
                    preview["arg" .. i] = args[i]
                end
                trace("REMOTE", "OnClientEvent", {
                    remote = remote.Name,
                    argc = #args,
                    args = preview
                })
            end)
        end
        for _, remote in ipairs(eventsFolder:GetDescendants()) do
            hookRemote(remote)
        end
        eventsFolder.DescendantAdded:Connect(hookRemote)
    end)
end

local function watchGhostLifecycle()
    pcall(function()
        local function hookGhost(ghost)
            if not ghost or not ghost:IsA("Model") then
                return
            end
            if markWatch(ghost, "GhostLifecycle") then
                return
            end
            trace("GHOST", "GhostObserved", {
                ghost = ghost,
                favoriteRoom = ghost:GetAttribute("FavoriteRoom"),
                headless = ghost:GetAttribute("Headless"),
                invisibleOnLIDAR = ghost:GetAttribute("InvisibleOnLIDAR")
            }, true)
            ghost.AttributeChanged:Connect(function(attr)
                trace("GHOST", "AttributeChanged", {
                    ghost = ghost,
                    attribute = attr,
                    value = ghost:GetAttribute(attr)
                })
            end)
            ghost.AncestryChanged:Connect(function()
                trace("GHOST", "AncestryChanged", {
                    ghost = ghost,
                    parent = ghost.Parent
                })
            end)
        end
        local ghost = Workspace:FindFirstChild("Ghost")
        if ghost then
            hookGhost(ghost)
        end
        Workspace.ChildAdded:Connect(function(child)
            if child.Name == "Ghost" and child:IsA("Model") then
                hookGhost(child)
            elseif child.Name == "GhostOrb" then
                trace("ORB", "GhostOrbAdded", {
                    object = child,
                    parent = child.Parent
                }, true)
            end
        end)
    end)
end

local function watchPlayerState()
    pcall(function()
        local trackedAttrs = {
            "EquippedObject",
            "InvSlot1",
            "InvSlot2",
            "InvSlot3",
            "InvSlot4",
            "SpiritBoxUI",
            "Dead"
        }
        for _, attr in ipairs(trackedAttrs) do
            LP:GetAttributeChangedSignal(attr):Connect(function()
                trace("PLAYER", "AttributeChanged", {
                    attribute = attr,
                    value = LP:GetAttribute(attr)
                })
            end)
        end
    end)
end

local function collectVisibleHandprints()
    local visible = 0
    local folder = Workspace:FindFirstChild("Handprints")
    if not folder then
        return visible
    end
    for _, hp in ipairs(folder:GetChildren()) do
        local gui = hp:FindFirstChildOfClass("SurfaceGui")
        local img = gui and gui:FindFirstChildOfClass("ImageLabel")
        if img and img.ImageTransparency < 1 then
            visible = visible + 1
        end
    end
    return visible
end

local function collectTrackedItemStates()
    local result = {}
    local idx = 0
    local pools = {}
    local itemsFolder = Workspace:FindFirstChild("Items")
    if itemsFolder then
        table.insert(pools, itemsFolder:GetChildren())
    end
    if LP.Character then
        table.insert(pools, LP.Character:GetChildren())
    end
    for _, pool in ipairs(pools) do
        for _, obj in ipairs(pool) do
            local itemName = nil
            pcall(function()
                itemName = obj:GetAttribute("ItemName")
            end)
            if itemName and isTrackedItem(itemName) then
                idx = idx + 1
                if idx > 12 then
                    return result
                end
                local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
                result["item" .. idx] = string.format(
                    "%s | enabled=%s | power=%s | parent=%s | pos=%s",
                    tostring(itemName),
                    tostring(obj:GetAttribute("Enabled")),
                    tostring(obj:GetAttribute("Power")),
                    tostring(obj.Parent),
                    part and tostring(part.Position) or "n/a"
                )
            end
        end
    end
    return result
end

local function collectEvidenceSnapshot()
    local ghost = Workspace:FindFirstChild("Ghost")
    local orb = Workspace:FindFirstChild("GhostOrb")
    local photoTagged = {}
    local photoIdx = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local reward = nil
        pcall(function()
            reward = obj:GetAttribute("PhotoRewardType")
        end)
        if reward and reward ~= "" then
            photoIdx = photoIdx + 1
            if photoIdx > 8 then
                break
            end
            photoTagged["photo" .. photoIdx] = tostring(reward) .. " @ " .. traceValue(obj)
        end
    end
    local snapshot = {
        ghostPresent = ghost ~= nil,
        favoriteRoom = ghost and ghost:GetAttribute("FavoriteRoom") or nil,
        headless = ghost and ghost:GetAttribute("Headless") or nil,
        invisibleOnLIDAR = ghost and ghost:GetAttribute("InvisibleOnLIDAR") or nil,
        orbPresent = orb ~= nil,
        orbY = orb and ((orb:IsA("BasePart") and orb.Position.Y) or (orb.PrimaryPart and orb.PrimaryPart.Position.Y)) or nil,
        handprintsVisible = collectVisibleHandprints(),
        equippedObject = LP:GetAttribute("EquippedObject"),
        invSlot1 = LP:GetAttribute("InvSlot1"),
        invSlot2 = LP:GetAttribute("InvSlot2"),
        invSlot3 = LP:GetAttribute("InvSlot3"),
        invSlot4 = LP:GetAttribute("InvSlot4")
    }
    for key, value in pairs(photoTagged) do
        snapshot[key] = value
    end
    local tracked = collectTrackedItemStates()
    for key, value in pairs(tracked) do
        snapshot[key] = value
    end
    return snapshot
end

local function startLoop()
    if Analyzer.loopStarted then
        return
    end
    Analyzer.loopStarted = true
    task.spawn(function()
        while true do
            if Analyzer.active then
                trace("SNAPSHOT", "Tick", collectEvidenceSnapshot(), true)
            end
            task.wait(SNAPSHOT_INTERVAL)
        end
    end)
end

local function initialize()
    if Analyzer.initialized then
        return
    end
    Analyzer.initialized = true

    watchRelevantRemoteEvents()
    watchGhostLifecycle()
    watchPlayerState()
    watchHandprintVisuals()

    pcall(function()
        for _, item in ipairs(CollectionService:GetTagged("Item")) do
            watchTrackedTool(item)
            watchPhotoRewardItem(item)
        end
        CollectionService:GetInstanceAddedSignal("Item"):Connect(function(item)
            watchTrackedTool(item)
            watchPhotoRewardItem(item)
        end)
    end)

    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            watchTrackedTool(obj)
            watchWitherObject(obj)
            watchPhotoRewardItem(obj)
        end
        Workspace.DescendantAdded:Connect(function(obj)
            watchTrackedTool(obj)
            watchWitherObject(obj)
            watchPhotoRewardItem(obj)
            local dn = string.lower(obj.Name or "")
            if obj:IsA("Model") and (string.find(dn, "silhouette") or string.find(dn, "laserghost") or string.find(dn, "dots")) then
                trace("LASER", "PossibleVisualSpawn", {
                    object = obj,
                    parent = obj.Parent
                })
            elseif isWitherCandidate(obj) then
                trace("WITHER", "CandidateSpawned", {
                    object = obj,
                    parent = obj.Parent
                })
            end
        end)
    end)

    if hookmetamethod and getnamecallmethod then
        pcall(function()
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                if method == "FireServer" or method == "InvokeServer" then
                    local remoteName = string.lower(tostring(self.Name))
                    local args = { ... }
                    if string.find(remoteName, "askspiritboxfromui") then
                        trace("SPIRIT_BOX", "RemoteQuestion", {
                            remote = self.Name,
                            method = method,
                            question = args[1]
                        })
                    elseif string.find(remoteName, "toggleitemstate") then
                        local target = args[1]
                        local itemName = typeof(target) == "Instance" and (target:GetAttribute("ItemName") or target.Name) or target
                        if isTrackedItem(itemName) then
                            trace("ITEM", "ToggleItemStateSent", {
                                remote = self.Name,
                                method = method,
                                item = itemName,
                                target = target
                            })
                        end
                    elseif string.find(remoteName, "blacklighthoveredprint") or string.find(remoteName, "blacklightleftprint") then
                        trace("HANDPRINTS", "BlacklightRemote", {
                            remote = self.Name,
                            method = method,
                            target = args[1]
                        })
                    elseif string.find(remoteName, "evidencemarkedinjournal") then
                        trace("JOURNAL", "EvidenceMarked", {
                            method = method,
                            evidence = args[1]
                        })
                    elseif string.find(remoteName, "requestreturntolobby") then
                        trace("MATCH", "ReturnToLobbySent", {
                            method = method
                        })
                    elseif string.find(remoteName, "togglejournal") then
                        trace("JOURNAL", "ToggleJournalSent", {
                            method = method
                        })
                    elseif string.find(remoteName, "detectedghostwithlidar") then
                        trace("LIDAR", "ObjectiveSignalSent", {
                            method = method
                        })
                    end
                end
                return oldNamecall(self, ...)
            end)
        end)
    end
end

local function start(origin)
    if not (appendfile or writefile) then
        warn("[OjoDeDios Analyzer] Tu entorno no expone appendfile/writefile.")
        return false
    end
    initialize()
    startLoop()
    if Analyzer.active then
        return true
    end
    Analyzer.active = true
    Analyzer.file = resolveNextTraceFile()
    Analyzer.session = tostring(os.time()) .. "-" .. tostring(math.floor(os.clock() * 1000) % 100000)
    if writefile then
        pcall(writefile, Analyzer.file, "")
    end
    trace("TRACE", "SessionStarted", {
        file = Analyzer.file,
        origin = origin,
        placeId = game.PlaceId,
        jobId = game.JobId
    }, true)
    dumpGhostTypeModules()
    trace("SNAPSHOT", "InitialState", collectEvidenceSnapshot(), true)
    announce("Activo -> " .. Analyzer.file)
    return true
end

local function stop(origin)
    if not Analyzer.active then
        return
    end
    trace("TRACE", "SessionStopped", {
        file = Analyzer.file,
        origin = origin
    }, true)
    Analyzer.active = false
    announce("Detenido -> " .. tostring(Analyzer.file))
end

Analyzer.start = start
Analyzer.stop = stop

_G.StartOjoDeDiosAnalyzer = function()
    return start("Manual")
end

_G.StopOjoDeDiosAnalyzer = function()
    return stop("Manual")
end

start("AutoStart")

return Analyzer
