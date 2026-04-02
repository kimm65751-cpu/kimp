local existing = rawget(_G, "OjoDeDiosAnalyzer")
if existing and existing.active then
    pcall(function()
        if existing.stop then
            existing.stop("Replaced")
        end
    end)
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local CoreGui = game:GetService("CoreGui")

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
    watched = {},
    ui = {}
}

_G.OjoDeDiosAnalyzer = Analyzer

local function announce(msg)
    print("[OjoDeDios Analyzer] " .. msg)
end

local function warnMsg(msg)
    warn("[OjoDeDios Analyzer] " .. msg)
end

local start
local stop

local function getGuiParent()
    local ok = pcall(function()
        return CoreGui.Name
    end)
    if ok then
        return CoreGui
    end
    return LP:WaitForChild("PlayerGui")
end

local function updateGui()
    local ui = Analyzer.ui
    if not ui or not ui.statusLabel then
        return
    end
    ui.statusLabel.Text = Analyzer.active and "Estado: ACTIVO" or "Estado: DETENIDO"
    ui.statusLabel.TextColor3 = Analyzer.active and Color3.fromRGB(120, 255, 140) or Color3.fromRGB(255, 160, 120)
    ui.fileLabel.Text = "Archivo: " .. tostring(Analyzer.file or "sin archivo")
    ui.sessionLabel.Text = "Sesion: " .. tostring(Analyzer.session or "n/a")
    ui.startBtn.Text = Analyzer.active and "Reiniciar" or "Iniciar"
    ui.stopBtn.Text = Analyzer.active and "Detener" or "Detenido"
    ui.stopBtn.AutoButtonColor = Analyzer.active
    ui.stopBtn.TextTransparency = Analyzer.active and 0 or 0.35
end

local function createGui()
    local parent = getGuiParent()
    local old = parent:FindFirstChild("OjoDeDiosAnalyzerUI")
    if old then
        old:Destroy()
    end

    local sg = Instance.new("ScreenGui")
    sg.Name = "OjoDeDiosAnalyzerUI"
    sg.ResetOnSpawn = false
    sg.Parent = parent

    local frame = Instance.new("Frame")
    frame.Name = "Panel"
    frame.Size = UDim2.new(0, 300, 0, 130)
    frame.Position = UDim2.new(1, -315, 0, 25)
    frame.BackgroundColor3 = Color3.fromRGB(10, 18, 16)
    frame.BorderColor3 = Color3.fromRGB(40, 150, 130)
    frame.BorderSizePixel = 1
    frame.Active = true
    frame.Draggable = true
    frame.Parent = sg

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -70, 0, 24)
    title.Position = UDim2.new(0, 8, 0, 4)
    title.BackgroundTransparency = 1
    title.Text = "OjoDeDios Analyzer"
    title.TextColor3 = Color3.fromRGB(170, 255, 240)
    title.Font = Enum.Font.Code
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 26, 0, 22)
    closeBtn.Position = UDim2.new(1, -30, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.Code
    closeBtn.TextSize = 12
    closeBtn.Parent = frame
    closeBtn.MouseButton1Click:Connect(function()
        sg:Destroy()
    end)

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -16, 0, 20)
    statusLabel.Position = UDim2.new(0, 8, 0, 32)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Estado: iniciando..."
    statusLabel.TextColor3 = Color3.fromRGB(120, 255, 140)
    statusLabel.Font = Enum.Font.Code
    statusLabel.TextSize = 12
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = frame

    local fileLabel = Instance.new("TextLabel")
    fileLabel.Size = UDim2.new(1, -16, 0, 20)
    fileLabel.Position = UDim2.new(0, 8, 0, 52)
    fileLabel.BackgroundTransparency = 1
    fileLabel.Text = "Archivo: pendiente"
    fileLabel.TextColor3 = Color3.fromRGB(200, 230, 230)
    fileLabel.Font = Enum.Font.Code
    fileLabel.TextSize = 12
    fileLabel.TextXAlignment = Enum.TextXAlignment.Left
    fileLabel.Parent = frame

    local sessionLabel = Instance.new("TextLabel")
    sessionLabel.Size = UDim2.new(1, -16, 0, 20)
    sessionLabel.Position = UDim2.new(0, 8, 0, 72)
    sessionLabel.BackgroundTransparency = 1
    sessionLabel.Text = "Sesion: pendiente"
    sessionLabel.TextColor3 = Color3.fromRGB(200, 230, 230)
    sessionLabel.Font = Enum.Font.Code
    sessionLabel.TextSize = 12
    sessionLabel.TextXAlignment = Enum.TextXAlignment.Left
    sessionLabel.Parent = frame

    local startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(0, 88, 0, 28)
    startBtn.Position = UDim2.new(0, 8, 1, -36)
    startBtn.BackgroundColor3 = Color3.fromRGB(30, 110, 90)
    startBtn.Text = "Iniciar"
    startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    startBtn.Font = Enum.Font.Code
    startBtn.TextSize = 12
    startBtn.Parent = frame

    local stopBtn = Instance.new("TextButton")
    stopBtn.Size = UDim2.new(0, 88, 0, 28)
    stopBtn.Position = UDim2.new(0, 104, 1, -36)
    stopBtn.BackgroundColor3 = Color3.fromRGB(120, 70, 20)
    stopBtn.Text = "Detener"
    stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopBtn.Font = Enum.Font.Code
    stopBtn.TextSize = 12
    stopBtn.Parent = frame

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 88, 0, 28)
    copyBtn.Position = UDim2.new(0, 200, 1, -36)
    copyBtn.BackgroundColor3 = Color3.fromRGB(40, 70, 130)
    copyBtn.Text = "Copiar nombre"
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.Font = Enum.Font.Code
    copyBtn.TextSize = 12
    copyBtn.Parent = frame

    startBtn.MouseButton1Click:Connect(function()
        if start then
            start("GUI")
        end
    end)

    stopBtn.MouseButton1Click:Connect(function()
        if Analyzer.active and stop then
            stop("GUI")
        end
    end)

    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard and Analyzer.file then
            pcall(function()
                setclipboard(Analyzer.file)
            end)
            copyBtn.Text = "Copiado"
            task.delay(1.5, function()
                if copyBtn.Parent then
                    copyBtn.Text = "Copiar nombre"
                end
            end)
        end
    end)

    Analyzer.ui = {
        screenGui = sg,
        frame = frame,
        statusLabel = statusLabel,
        fileLabel = fileLabel,
        sessionLabel = sessionLabel,
        startBtn = startBtn,
        stopBtn = stopBtn
    }

    updateGui()
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

start = function(origin)
    if not (appendfile or writefile) then
        warnMsg("Tu entorno no expone appendfile/writefile.")
        updateGui()
        return false
    end
    if Analyzer.active then
        return true
    end
    Analyzer.active = true
    Analyzer.file = resolveNextTraceFile()
    Analyzer.session = tostring(os.time()) .. "-" .. tostring(math.floor(os.clock() * 1000) % 100000)
    if writefile then
        pcall(writefile, Analyzer.file, "")
    end
    appendTrace(string.format("[%s] [BOOT] Archivo creado | origin=%s", os.date("%X"), tostring(origin)))
    local okInit, errInit = pcall(initialize)
    if not okInit then
        appendTrace(string.format("[%s] [BOOT] ERROR initialize | %s", os.date("%X"), tostring(errInit)))
        warnMsg("Fallo initialize: " .. tostring(errInit))
    end
    local okLoop, errLoop = pcall(startLoop)
    if not okLoop then
        appendTrace(string.format("[%s] [BOOT] ERROR startLoop | %s", os.date("%X"), tostring(errLoop)))
        warnMsg("Fallo startLoop: " .. tostring(errLoop))
    end
    trace("TRACE", "SessionStarted", {
        file = Analyzer.file,
        origin = origin,
        placeId = game.PlaceId,
        jobId = game.JobId
    }, true)
    local okDump, errDump = pcall(dumpGhostTypeModules)
    if not okDump then
        appendTrace(string.format("[%s] [BOOT] ERROR dumpGhostTypeModules | %s", os.date("%X"), tostring(errDump)))
        warnMsg("Fallo dumpGhostTypeModules: " .. tostring(errDump))
    end
    local okSnap, errSnap = pcall(function()
        trace("SNAPSHOT", "InitialState", collectEvidenceSnapshot(), true)
    end)
    if not okSnap then
        appendTrace(string.format("[%s] [BOOT] ERROR initialSnapshot | %s", os.date("%X"), tostring(errSnap)))
        warnMsg("Fallo initialSnapshot: " .. tostring(errSnap))
    end
    updateGui()
    announce("Activo -> " .. Analyzer.file)
    return true
end

stop = function(origin)
    if not Analyzer.active then
        updateGui()
        return
    end
    trace("TRACE", "SessionStopped", {
        file = Analyzer.file,
        origin = origin
    }, true)
    Analyzer.active = false
    updateGui()
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

createGui()
start("AutoStart")
