local existing = rawget(_G, "CAMQAHarness")
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
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local LP = Players.LocalPlayer

local CONFIG = {
    uiName = "CAM_QA_Harness",
    filePrefix = "CAM_QA_Harness_",
    fileExt = ".txt",
    snapshotInterval = 3,
    espUpdateInterval = 0.25,
    flushInterval = 1,
    maxUiLines = 180,
    bufferMax = 30,
    recoverTraceRadius = 22,
    recoverTraceCooldown = 1.25,
    runtimeTraceCooldown = 8,
    runtimeGcScanLimit = 2200,
    runtimeMaxFunctionsPerTarget = 18,
    runtimeMaxConstantsPerFunc = 12,
    runtimeMaxUpvaluesPerFunc = 10,
    runtimeMaxExportKeys = 18,
    runtimeMaxRemoteEntries = 48,
    runtimeMaxExportWalkDepth = 2,
    runtimeMaxExportFunctionLogs = 18,
    runtimeMaxTableLogs = 18
}

local IMPORTANT_MESSAGE_KINDS = {
    FightSkillStart = true,
    FightSkillEnd = true,
    FightLogicPlayerCreate = true,
    FightLogicPlayerDestroy = true,
    MonsterHurtInfo = true,
    PetHurtInfo = true,
    PetHealthSync = true,
    MonsterCatch = true,
    FightPlayerDie = true,
    ObjectPointSyncAdd = true,
    ObjectPointSyncRemove = true
}

local IMPORTANT_INPUT = {
    E = true,
    F = true,
    Q = true,
    R = true
}

local PROBE_MODES = {
    { id = "NONE", label = "NONE" },
    { id = "HOVER", label = "HOVER" },
    { id = "UNDERFOOT", label = "UNDERFOOT" },
    { id = "UNDERGROUND", label = "UNDERGROUND" },
    { id = "PET_NEUTRAL", label = "PET NEUTRAL" },
    { id = "MONSTER_MASK", label = "MONSTER MASK" }
}

local MISSING_ATTR = {}

local State = {
    active = true,
    espEnabled = true,
    auditEnabled = true,
    recoverTraceEnabled = true,
    probeMode = "NONE",
    file = nil,
    connections = {},
    trackedEsp = {},
    uiLines = {},
    buffer = {},
    petOriginals = {},
    monsterOriginals = {},
    petHealth = {},
    recoverGuiObserved = {},
    recoverGuiState = {},
    recoverLastTraceByPet = {},
    runtimeTraceEnabled = true,
    idleTraceEnabled = true,
    runtimeTraceLastAt = 0,
    runtimeTraceSeen = {},
    combatActors = {},
    lastRecoverGuiAt = 0,
    lastSnapshotAt = 0,
    lastEspAt = 0,
    lastFlushAt = 0,
    ui = {}
}

_G.CAMQAHarness = State

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

local function lower(value)
    return string.lower(tostring(value or ""))
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
    if kind == "table" then
        local parts = {}
        local count = 0
        for k, v in pairs(value) do
            count = count + 1
            if count > 8 then
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

local function trimText(value, limit)
    local text = tostring(value or "")
    local max = limit or 220
    if #text > max then
        return string.sub(text, 1, max) .. "..."
    end
    return text
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
    if root:IsA("Model") then
        return root.PrimaryPart or root:FindFirstChildWhichIsA("BasePart", true)
    end
    return root:FindFirstChildWhichIsA("BasePart", true)
end

local function getNextFileName()
    if not (isfile and writefile) then
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
        " CAM QA HARNESS",
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
        line = line .. " | " .. trimText(safeTostring(payload), 500)
    end
    table.insert(State.buffer, line)
    if #State.buffer >= CONFIG.bufferMax then
        flushFile()
    end
    addUiLine(line, color)
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

local function setStatus(text)
    if State.ui.status then
        State.ui.status.Text = "Status: " .. text
    end
end

local function setToggleAppearance(button, enabled, onText, offText)
    if not button then
        return
    end
    button.Text = enabled and onText or offText
    button.BackgroundColor3 = enabled and Color3.fromRGB(90, 170, 90) or Color3.fromRGB(170, 80, 80)
end

local function refreshProbeUi()
    if State.ui.probeLabel then
        State.ui.probeLabel.Text = "Probe: " .. tostring(State.probeMode)
    end
    if not State.ui.probeButtons then
        return
    end
    for _, mode in ipairs(PROBE_MODES) do
        local button = State.ui.probeButtons[mode.id]
        if button then
            local active = State.probeMode == mode.id
            button.BackgroundColor3 = active and Color3.fromRGB(225, 170, 75) or Color3.fromRGB(65, 80, 95)
            button.TextColor3 = active and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(255, 255, 255)
        end
    end
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
    frame.Size = UDim2.new(0, 540, 0, 410)
    frame.Position = UDim2.new(0.57, 0, 0.38, 0)
    frame.BackgroundColor3 = Color3.fromRGB(16, 22, 28)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screen

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(30, 46, 60)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Text = "  CAM QA HARNESS - Pickup ESP + Combat Audit"
    title.Parent = frame

    local espButton = makeButton(title, "ESP ON", -88, 70)
    local auditButton = makeButton(title, "AUDIT ON", -164, 70)
    local recoverButton = makeButton(title, "RECOVER ON", -254, 86)
    local scanButton = makeButton(title, "SCAN", -344, 64)
    local clearButton = makeButton(title, "CLEAR", -414, 64)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -12, 0, 18)
    status.Position = UDim2.new(0, 6, 0, 34)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(160, 220, 255)
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Font = Enum.Font.Code
    status.TextSize = 12
    status.Parent = frame

    local idleButton = Instance.new("TextButton")
    idleButton.Size = UDim2.new(0, 78, 0, 18)
    idleButton.Position = UDim2.new(1, -164, 0, 34)
    idleButton.BackgroundColor3 = Color3.fromRGB(70, 95, 120)
    idleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    idleButton.TextSize = 10
    idleButton.Font = Enum.Font.GothamBold
    idleButton.Text = "IDLE ON"
    idleButton.Parent = frame

    local runtimeButton = Instance.new("TextButton")
    runtimeButton.Size = UDim2.new(0, 96, 0, 18)
    runtimeButton.Position = UDim2.new(1, -264, 0, 34)
    runtimeButton.BackgroundColor3 = Color3.fromRGB(70, 95, 120)
    runtimeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    runtimeButton.TextSize = 10
    runtimeButton.Font = Enum.Font.GothamBold
    runtimeButton.Text = "RUNTIME ON"
    runtimeButton.Parent = frame

    local fileLabel = Instance.new("TextLabel")
    fileLabel.Size = UDim2.new(1, -12, 0, 18)
    fileLabel.Position = UDim2.new(0, 6, 0, 52)
    fileLabel.BackgroundTransparency = 1
    fileLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    fileLabel.TextXAlignment = Enum.TextXAlignment.Left
    fileLabel.Font = Enum.Font.Code
    fileLabel.TextSize = 12
    fileLabel.Parent = frame

    local probeLabel = Instance.new("TextLabel")
    probeLabel.Size = UDim2.new(1, -12, 0, 18)
    probeLabel.Position = UDim2.new(0, 6, 0, 70)
    probeLabel.BackgroundTransparency = 1
    probeLabel.TextColor3 = Color3.fromRGB(255, 210, 120)
    probeLabel.TextXAlignment = Enum.TextXAlignment.Left
    probeLabel.Font = Enum.Font.Code
    probeLabel.TextSize = 12
    probeLabel.Text = "Probe: NONE"
    probeLabel.Parent = frame

    local probeBar = Instance.new("Frame")
    probeBar.Size = UDim2.new(1, -12, 0, 42)
    probeBar.Position = UDim2.new(0, 6, 0, 88)
    probeBar.BackgroundTransparency = 1
    probeBar.Parent = frame

    local probeList = Instance.new("UIListLayout")
    probeList.FillDirection = Enum.FillDirection.Horizontal
    probeList.HorizontalAlignment = Enum.HorizontalAlignment.Left
    probeList.Padding = UDim.new(0, 4)
    probeList.Parent = probeBar

    local probeButtons = {}
    for _, mode in ipairs(PROBE_MODES) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 84, 0, 22)
        button.BackgroundColor3 = Color3.fromRGB(65, 80, 95)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Font = Enum.Font.GothamBold
        button.TextSize = 10
        button.TextWrapped = true
        button.Text = mode.label
        button.Parent = probeBar
        probeButtons[mode.id] = button
    end

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -12, 1, -136)
    scroll.Position = UDim2.new(0, 6, 0, 132)
    scroll.BackgroundColor3 = Color3.fromRGB(7, 10, 12)
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 6
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Parent = frame

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 2)
    list.Parent = scroll

    addConnection(list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas))

    State.ui.screen = screen
    State.ui.frame = frame
    State.ui.status = status
    State.ui.fileLabel = fileLabel
    State.ui.probeLabel = probeLabel
    State.ui.probeButtons = probeButtons
    State.ui.logScroll = scroll
    State.ui.list = list
    State.ui.espButton = espButton
    State.ui.auditButton = auditButton
    State.ui.idleButton = idleButton
    State.ui.recoverButton = recoverButton
    State.ui.runtimeButton = runtimeButton
    State.ui.scanButton = scanButton
    State.ui.clearButton = clearButton
    State.ui.espFolder = Instance.new("Folder")
    State.ui.espFolder.Name = "CAM_QA_ESP"
    State.ui.espFolder.Parent = screen

    espButton.MouseButton1Click:Connect(function()
        State.espEnabled = not State.espEnabled
        espButton.Text = State.espEnabled and "ESP ON" or "ESP OFF"
        espButton.BackgroundColor3 = State.espEnabled and Color3.fromRGB(90, 170, 90) or Color3.fromRGB(170, 80, 80)
        writeLine("UI", "ToggleESP", { enabled = State.espEnabled }, Color3.fromRGB(200, 220, 120))
    end)

    auditButton.MouseButton1Click:Connect(function()
        State.auditEnabled = not State.auditEnabled
        setToggleAppearance(auditButton, State.auditEnabled, "AUDIT ON", "AUDIT OFF")
        writeLine("UI", "ToggleAudit", { enabled = State.auditEnabled }, Color3.fromRGB(200, 220, 120))
    end)

    idleButton.MouseButton1Click:Connect(function()
        State.idleTraceEnabled = not State.idleTraceEnabled
        setToggleAppearance(idleButton, State.idleTraceEnabled, "IDLE ON", "IDLE OFF")
        writeLine("UI", "ToggleIdleTrace", { enabled = State.idleTraceEnabled }, Color3.fromRGB(200, 220, 120))
    end)

    recoverButton.MouseButton1Click:Connect(function()
        State.recoverTraceEnabled = not State.recoverTraceEnabled
        setToggleAppearance(recoverButton, State.recoverTraceEnabled, "RECOVER ON", "RECOVER OFF")
        writeLine("UI", "ToggleRecoverTrace", { enabled = State.recoverTraceEnabled }, Color3.fromRGB(200, 220, 120))
    end)

    runtimeButton.MouseButton1Click:Connect(function()
        State.runtimeTraceEnabled = not State.runtimeTraceEnabled
        setToggleAppearance(runtimeButton, State.runtimeTraceEnabled, "RUNTIME ON", "RUNTIME OFF")
        writeLine("UI", "ToggleRuntimeTrace", { enabled = State.runtimeTraceEnabled }, Color3.fromRGB(200, 220, 120))
    end)

    clearButton.MouseButton1Click:Connect(function()
        for _, line in ipairs(State.uiLines) do
            line:Destroy()
        end
        State.uiLines = {}
        updateCanvas()
    end)

    setToggleAppearance(auditButton, State.auditEnabled, "AUDIT ON", "AUDIT OFF")
    setToggleAppearance(idleButton, State.idleTraceEnabled, "IDLE ON", "IDLE OFF")
    setToggleAppearance(recoverButton, State.recoverTraceEnabled, "RECOVER ON", "RECOVER OFF")
    setToggleAppearance(runtimeButton, State.runtimeTraceEnabled, "RUNTIME ON", "RUNTIME OFF")
end

local function saveAttr(storeTable, instance, key)
    local store = storeTable[instance]
    if not store then
        store = { attrs = {} }
        storeTable[instance] = store
    end
    if store.attrs[key] ~= nil then
        return
    end
    local current = instance:GetAttribute(key)
    if current == nil then
        store.attrs[key] = MISSING_ATTR
    else
        store.attrs[key] = current
    end
end

local function saveCFrame(storeTable, instance, part)
    local store = storeTable[instance]
    if not store then
        store = { attrs = {} }
        storeTable[instance] = store
    end
    if store.cframe == nil then
        store.cframe = part.CFrame
    end
end

local function restoreStore(storeTable)
    for instance, store in pairs(storeTable) do
        if instance and instance.Parent then
            if store.attrs then
                for key, value in pairs(store.attrs) do
                    pcall(function()
                        if value == MISSING_ATTR then
                            instance:SetAttribute(key, nil)
                        else
                            instance:SetAttribute(key, value)
                        end
                    end)
                end
            end
            if store.cframe then
                local part = getRootPart(instance)
                if part then
                    pcall(function()
                        part.CFrame = store.cframe
                    end)
                end
            end
        end
    end
    table.clear(storeTable)
end

local function getOwnedPetRoots()
    local roots = {}
    local suffixes = {}
    local myId = tonumber(LP.UserId)

    local pets = Workspace:FindFirstChild("Pets")
    if pets then
        for _, pet in ipairs(pets:GetChildren()) do
            local playerId = tonumber(pet:GetAttribute("PlayerId"))
            if playerId == myId then
                table.insert(roots, pet)
                local suffix = tostring(pet.Name):match("^Pet_%d+_(%d+)$")
                if suffix then
                    suffixes[suffix] = true
                end
            end
        end
    end

    local clientPets = Workspace:FindFirstChild("ClientPets")
    if clientPets then
        for _, pet in ipairs(clientPets:GetChildren()) do
            local suffix = tostring(pet.Name):match("^Pet_(%d+)$")
            if suffix and suffixes[suffix] then
                table.insert(roots, pet)
            end
        end
    end

    return roots
end

local function getGuiReadableText(inst)
    if not inst then
        return nil
    end
    if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
        return inst.Text
    end
    return inst.Name
end

local function isRecoverGuiCandidate(inst)
    if not inst or not inst:IsDescendantOf(LP:WaitForChild("PlayerGui")) then
        return false
    end
    local probe = lower(inst.Name .. " " .. tostring(getGuiReadableText(inst) or ""))
    return probe:find("recover", 1, true)
        or probe:find("imgrecover", 1, true)
        or probe:find("volver", 1, true)
        or probe:find("return", 1, true)
        or probe:find("teleport", 1, true)
        or probe:find("back", 1, true)
end

local function findOwnedPetByItemId(petItemId)
    if petItemId == nil then
        return nil, nil
    end
    local pets = Workspace:FindFirstChild("Pets")
    if pets then
        for _, pet in ipairs(pets:GetChildren()) do
            if tonumber(pet:GetAttribute("PetItemId")) == tonumber(petItemId) then
                return pet, "Workspace.Pets"
            end
        end
    end

    local suffix = nil
    local owned = getOwnedPetRoots()
    for _, pet in ipairs(owned) do
        if tonumber(pet:GetAttribute("PetItemId")) == tonumber(petItemId) then
            suffix = tostring(pet.Name):match("^Pet_%d+_(%d+)$")
            break
        end
    end
    if suffix then
        local clientPets = Workspace:FindFirstChild("ClientPets")
        local renderPet = clientPets and clientPets:FindFirstChild("Pet_" .. suffix)
        if renderPet then
            return renderPet, "Workspace.ClientPets"
        end
    end
    return nil, nil
end

local function collectNearbyRecoverContext(position)
    local radius = CONFIG.recoverTraceRadius
    local areaRoot = Workspace:FindFirstChild("Area")
    local searchRoot = areaRoot and areaRoot:FindFirstChild("Root")
    searchRoot = searchRoot and searchRoot:FindFirstChild("Area") or searchRoot or areaRoot
    if not searchRoot then
        return {}
    end

    local seen = {}
    local nearest = {}
    local scanned = 0
    for _, desc in ipairs(searchRoot:GetDescendants()) do
        scanned = scanned + 1
        if scanned > 1400 then
            break
        end
        local root = desc
        if desc:IsA("BasePart") and desc.Parent and desc.Parent:IsA("Model") then
            root = desc.Parent
        end
        if (root:IsA("Model") or root:IsA("BasePart")) and not seen[root] then
            seen[root] = true
            local adornee = findAdornee(root)
            if adornee then
                local dist = (adornee.Position - position).Magnitude
                if dist <= radius then
                    local name = tostring(root.Name)
                    local path = lower(root:GetFullName())
                    local prompt = root:FindFirstChildWhichIsA("ProximityPrompt", true)
                    local click = root:FindFirstChildWhichIsA("ClickDetector", true)
                    local include = prompt ~= nil
                        or click ~= nil
                        or path:find("npc", 1, true)
                        or path:find("teleport", 1, true)
                        or path:find("heal", 1, true)
                        or path:find("recover", 1, true)
                        or path:find("base", 1, true)
                        or path:find("altar", 1, true)
                        or path:find("machine", 1, true)
                        or path:find("platform", 1, true)
                        or path:find("pad", 1, true)
                    if include then
                        table.insert(nearest, {
                            name = name,
                            dist = math.floor(dist * 10) / 10,
                            prompt = prompt and prompt.ActionText or nil,
                            click = click ~= nil,
                            path = root:GetFullName()
                        })
                    end
                end
            end
        end
    end

    table.sort(nearest, function(a, b)
        return a.dist < b.dist
    end)
    while #nearest > 6 do
        table.remove(nearest)
    end
    return nearest
end

local function getVisibleRecoverGui()
    local visible = {}
    for inst in pairs(State.recoverGuiObserved) do
        if inst and inst.Parent then
            local okVisible = true
            if inst:IsA("GuiObject") then
                okVisible = inst.Visible
            end
            if okVisible then
                table.insert(visible, {
                    name = inst.Name,
                    text = getGuiReadableText(inst),
                    path = inst:GetFullName()
                })
            end
        end
    end
    return visible
end

local function traceRecoverContext(reason, petItemId, oldHealth, newHealth)
    if not State.recoverTraceEnabled then
        return
    end
    local now = os.clock()
    local key = tostring(petItemId or "global")
    local last = State.recoverLastTraceByPet[key]
    if last and now - last < CONFIG.recoverTraceCooldown then
        return
    end
    State.recoverLastTraceByPet[key] = now

    local rootPart = getCharacterRoot()
    local pet, source = findOwnedPetByItemId(petItemId)
    local petPart = getRootPart(pet)
    local payload = {
        reason = reason,
        petItemId = petItemId,
        old = oldHealth,
        new = newHealth,
        source = source,
        visibleGui = getVisibleRecoverGui()
    }

    if rootPart then
        payload.playerPos = rootPart.Position
    end
    if petPart then
        payload.pet = pet and pet.Name or nil
        payload.petPos = petPart.Position
        payload.petPlayerDist = rootPart and (math.floor((petPart.Position - rootPart.Position).Magnitude * 10) / 10) or nil
        payload.nearby = collectNearbyRecoverContext(petPart.Position)
    elseif rootPart then
        payload.nearby = collectNearbyRecoverContext(rootPart.Position)
    end

    writeLine("RECOVER", reason, payload, Color3.fromRGB(120, 255, 200))
end

local function hookRecoverGuiObject(inst)
    if not isRecoverGuiCandidate(inst) or State.recoverGuiObserved[inst] then
        return
    end
    State.recoverGuiObserved[inst] = true

    local function emit(action)
        if not State.recoverTraceEnabled or not State.active then
            return
        end
        local payload = {
            class = inst.ClassName,
            name = inst.Name,
            text = getGuiReadableText(inst),
            path = inst:GetFullName()
        }
        if inst:IsA("GuiObject") then
            payload.visible = inst.Visible
        end
        writeLine("GUI_TRACE", action, payload, Color3.fromRGB(180, 220, 255))
        if payload.visible ~= false then
            traceRecoverContext("GuiSignal", nil, nil, nil)
        end
    end

    emit("Tracked")
    if inst:IsA("GuiObject") then
        addConnection(inst:GetPropertyChangedSignal("Visible"):Connect(function()
            emit("VisibleChanged")
        end))
        if inst.Visible then
            State.lastRecoverGuiAt = os.clock()
        end
    end
    if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
        addConnection(inst:GetPropertyChangedSignal("Text"):Connect(function()
            emit("TextChanged")
        end))
    end
    if inst:IsA("GuiButton") then
        addConnection(inst.Activated:Connect(function()
            emit("Activated")
        end))
    end
end

local function installRecoverGuiAudit()
    local playerGui = LP:WaitForChild("PlayerGui")
    for _, desc in ipairs(playerGui:GetDescendants()) do
        hookRecoverGuiObject(desc)
    end
    addConnection(playerGui.DescendantAdded:Connect(function(desc)
        task.defer(function()
            if State.active then
                hookRecoverGuiObject(desc)
            end
        end)
    end))
end

local function findScriptByName(scriptName)
    local roots = {
        LP:FindFirstChild("PlayerScripts"),
        LP:FindFirstChild("PlayerGui"),
        ReplicatedStorage
    }
    for _, root in ipairs(roots) do
        if root then
            local found = root:FindFirstChild(scriptName, true)
            if found and (found:IsA("LocalScript") or found:IsA("ModuleScript")) then
                return found
            end
        end
    end
    return nil
end

local RUNTIME_TARGETS = {
    "AutoAttackUtil",
    "MgrPetClient",
    "MgrMonsterClient",
    "MonsterCatchUtil",
    "PlayerAttack",
    "HookButtonClick"
}

local function interestingRuntimeText(text)
    local probe = lower(text)
    return probe:find("attack", 1, true)
        or probe:find("auto", 1, true)
        or probe:find("target", 1, true)
        or probe:find("cooldown", 1, true)
        or probe:find("skill", 1, true)
        or probe:find("catch", 1, true)
        or probe:find("pet", 1, true)
        or probe:find("monster", 1, true)
        or probe:find("fight", 1, true)
        or probe:find("remote", 1, true)
end

local function collectRuntimeKeys(container)
    local matches = {}
    if type(container) ~= "table" then
        return matches
    end
    for key, value in pairs(container) do
        local keyText = tostring(key)
        if interestingRuntimeText(keyText) then
            table.insert(matches, keyText .. "=" .. trimText(safeTostring(value), 90))
        end
    end
    table.sort(matches)
    while #matches > CONFIG.runtimeMaxExportKeys do
        table.remove(matches)
    end
    return matches
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

local function getLoadedModuleSet()
    local loadedSet = {}
    if not getloadedmodules then
        return loadedSet
    end
    local ok, modules = pcall(getloadedmodules)
    if not ok or type(modules) ~= "table" then
        return loadedSet
    end
    for _, moduleInst in ipairs(modules) do
        loadedSet[moduleInst] = true
    end
    return loadedSet
end

local function getScriptHierarchy(inst)
    local children = {}
    for _, child in ipairs(inst:GetChildren()) do
        table.insert(children, child.ClassName .. ":" .. child.Name)
        if #children >= 10 then
            break
        end
    end
    return {
        class = inst.ClassName,
        path = inst:GetFullName(),
        parent = inst.Parent and inst.Parent:GetFullName() or nil,
        children = children,
        descendantCount = #inst:GetDescendants()
    }
end

local function summarizeExportValue(value)
    local valueType = type(value)
    if valueType ~= "table" then
        return {
            valueType = valueType,
            preview = trimText(safeTostring(value), 140)
        }
    end

    local entries = {}
    local count = 0
    for key, inner in pairs(value) do
        count = count + 1
        local innerType = type(inner)
        local preview = innerType
        if innerType == "table" then
            local innerCount = 0
            for _ in pairs(inner) do
                innerCount = innerCount + 1
            end
            preview = "table(" .. innerCount .. ")"
        elseif innerType == "function" then
            local info = getDebugInfo(inner, "Sn")
            preview = "function@" .. tostring(info and info.linedefined or "?")
        elseif innerType == "string" or innerType == "number" or innerType == "boolean" then
            preview = trimText(safeTostring(inner), 80)
        end
        table.insert(entries, tostring(key) .. "=" .. preview)
        if #entries >= CONFIG.runtimeMaxExportKeys then
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

local function summarizeMetatable(value)
    local ok, mt = pcall(getmetatable, value)
    if not ok or type(mt) ~= "table" then
        return nil
    end
    local entries = {}
    local count = 0
    for key, inner in pairs(mt) do
        count = count + 1
        local innerType = type(inner)
        local preview = innerType
        if innerType == "function" then
            local info = getDebugInfo(inner, "Sn")
            preview = "function@" .. tostring(info and info.linedefined or "?")
        elseif innerType == "table" then
            preview = "table"
        else
            preview = trimText(safeTostring(inner), 80)
        end
        table.insert(entries, tostring(key) .. "=" .. preview)
        if #entries >= 10 then
            break
        end
    end
    table.sort(entries)
    return {
        size = count,
        entries = entries
    }
end

local function collectRemoteIndex()
    local index = {}
    local summary = {}
    local roots = {
        ReplicatedStorage:FindFirstChild("CommonLibrary"),
        ReplicatedStorage:FindFirstChild("Commander Remotes")
    }

    for _, root in ipairs(roots) do
        if root then
            for _, desc in ipairs(root:GetDescendants()) do
                if desc:IsA("RemoteEvent") or desc:IsA("RemoteFunction") then
                    index[lower(desc.Name)] = desc:GetFullName()
                    table.insert(summary, desc.ClassName .. ":" .. desc:GetFullName())
                    if #summary >= CONFIG.runtimeMaxRemoteEntries then
                        break
                    end
                end
            end
        end
        if #summary >= CONFIG.runtimeMaxRemoteEntries then
            break
        end
    end

    table.sort(summary)
    return index, summary
end

local function traceScriptEnv(scriptInst, label)
    if not scriptInst or not getsenv or not scriptInst:IsA("LocalScript") then
        return
    end
    local ok, env = pcall(getsenv, scriptInst)
    if not ok or type(env) ~= "table" then
        writeLine("MODULE", "ScriptEnvMiss", {
            script = label,
            path = scriptInst:GetFullName()
        }, Color3.fromRGB(255, 180, 120))
        return
    end
    local keys = collectRuntimeKeys(env)
    writeLine("MODULE", "ScriptEnv", {
        script = label,
        path = scriptInst:GetFullName(),
        keys = keys
    }, Color3.fromRGB(180, 220, 255))
end

local function extractFunctionConstants(fn)
    local getter = getRuntimeGetter("getconstants")
    if not getter then
        return {}
    end
    local ok, values = pcall(getter, fn)
    if not ok or type(values) ~= "table" then
        return {}
    end
    local out = {}
    for _, value in ipairs(values) do
        local valueType = type(value)
        if valueType == "string" or valueType == "number" or valueType == "boolean" then
            table.insert(out, trimText(safeTostring(value), 80))
        end
        if #out >= CONFIG.runtimeMaxConstantsPerFunc then
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
    local ok, values = pcall(getter, fn)
    if not ok or type(values) ~= "table" then
        return {}
    end
    local out = {}
    local count = 0
    for key, value in pairs(values) do
        count = count + 1
        table.insert(out, tostring(key) .. "=" .. trimText(safeTostring(value), 80))
        if count >= CONFIG.runtimeMaxUpvaluesPerFunc then
            break
        end
    end
    table.sort(out)
    return out
end

local function findLinkedRemotes(constants, remoteIndex)
    local linked = {}
    local seen = {}
    for _, constant in ipairs(constants or {}) do
        local probe = lower(constant)
        for remoteName, remotePath in pairs(remoteIndex) do
            if probe == remoteName or probe:find(remoteName, 1, true) then
                local signature = remoteName .. "@" .. remotePath
                if not seen[signature] then
                    seen[signature] = true
                    table.insert(linked, signature)
                end
            end
        end
    end
    table.sort(linked)
    while #linked > 8 do
        table.remove(linked)
    end
    return linked
end

local function traceExportFunction(scriptName, exportPath, fn, remoteIndex, counters)
    if counters.functionLogs >= CONFIG.runtimeMaxExportFunctionLogs then
        return
    end
    counters.functionLogs = counters.functionLogs + 1

    local info = getDebugInfo(fn, "Snu")
    local constants = extractFunctionConstants(fn)
    local upvalues = extractFunctionUpvalues(fn)
    local linkedRemotes = findLinkedRemotes(constants, remoteIndex)
    writeLine("MODULE", "ExportFunc", {
        script = scriptName,
        path = exportPath,
        line = info and info.linedefined or nil,
        lastLine = info and info.lastlinedefined or nil,
        params = info and info.nparams or nil,
        vararg = info and info.isvararg or nil,
        source = info and (info.source or info.short_src) or nil,
        constants = constants,
        upvalues = upvalues,
        linkedRemotes = linkedRemotes
    }, Color3.fromRGB(255, 220, 150))
end

local function traceExportTable(scriptName, exportPath, tbl, counters)
    if counters.tableLogs >= CONFIG.runtimeMaxTableLogs then
        return
    end
    counters.tableLogs = counters.tableLogs + 1

    local summary = summarizeExportValue(tbl)
    local metatableSummary = summarizeMetatable(tbl)
    writeLine("MODULE", "ExportTable", {
        script = scriptName,
        path = exportPath,
        summary = summary,
        metatable = metatableSummary
    }, Color3.fromRGB(190, 235, 255))
end

local function walkExportValue(scriptName, exportPath, value, remoteIndex, depth, seen, counters)
    if depth > CONFIG.runtimeMaxExportWalkDepth then
        return
    end
    local valueType = type(value)
    if valueType == "function" then
        traceExportFunction(scriptName, exportPath, value, remoteIndex, counters)
        return
    end
    if valueType ~= "table" then
        return
    end
    if seen[value] then
        return
    end
    seen[value] = true

    traceExportTable(scriptName, exportPath, value, counters)

    local walked = 0
    for key, child in pairs(value) do
        walked = walked + 1
        if walked > CONFIG.runtimeMaxExportKeys then
            break
        end
        local childType = type(child)
        if childType == "function" or childType == "table" then
            walkExportValue(scriptName, exportPath .. "." .. tostring(key), child, remoteIndex, depth + 1, seen, counters)
        end
    end
end

local function sourceMatchesTarget(source, targetInst, targetName)
    local probe = lower(source or "")
    if probe == "" then
        return false
    end
    if probe:find(lower(targetName), 1, true) then
        return true
    end
    if targetInst then
        local full = lower(targetInst:GetFullName())
        if probe:find(full, 1, true) then
            return true
        end
    end
    return false
end

local function scanGcFunctionsForTarget(targetInst, targetName, remoteIndex)
    if not getgc then
        return 0
    end
    local ok, gcList = pcall(getgc, true)
    if not ok or type(gcList) ~= "table" then
        return 0
    end

    local found = 0
    local scanned = 0
    for _, value in ipairs(gcList) do
        scanned = scanned + 1
        if scanned > CONFIG.runtimeGcScanLimit then
            break
        end
        if type(value) == "function" then
            local info = getDebugInfo(value, "Snu")
            local source = (info and (info.source or info.short_src)) or ""
            if sourceMatchesTarget(source, targetInst, targetName) and not lower(source):find("cam_qa_harness", 1, true) then
                local signature = table.concat({
                    targetName,
                    tostring(source),
                    tostring(info and info.linedefined or "?"),
                    tostring(info and info.name or "?")
                }, "|")
                if not State.runtimeTraceSeen[signature] then
                    State.runtimeTraceSeen[signature] = true
                    local constants = extractFunctionConstants(value)
                    local upvalues = extractFunctionUpvalues(value)
                    local linkedRemotes = findLinkedRemotes(constants, remoteIndex)
                    writeLine("MODULE", "GCFunc", {
                        script = targetName,
                        source = source,
                        name = info and info.name or nil,
                        line = info and info.linedefined or nil,
                        lastLine = info and info.lastlinedefined or nil,
                        params = info and info.nparams or nil,
                        vararg = info and info.isvararg or nil,
                        constants = constants,
                        upvalues = upvalues,
                        linkedRemotes = linkedRemotes
                    }, Color3.fromRGB(255, 220, 150))
                    found = found + 1
                    if found >= CONFIG.runtimeMaxFunctionsPerTarget then
                        break
                    end
                end
            end
        end
    end
    return found
end

local function scanRuntimeCandidates(force)
    if not State.runtimeTraceEnabled then
        return
    end
    local now = os.clock()
    if not force and now - State.runtimeTraceLastAt < CONFIG.runtimeTraceCooldown then
        return
    end
    State.runtimeTraceLastAt = now

    local loadedSet = getLoadedModuleSet()
    local remoteIndex, remoteSummary = collectRemoteIndex()
    writeLine("MODULE", "RemoteTree", {
        entries = remoteSummary
    }, Color3.fromRGB(170, 220, 255))

    local foundCount = 0
    local scanned = 0

    for _, scriptName in ipairs(RUNTIME_TARGETS) do
        local found = findScriptByName(scriptName)
        if found then
            writeLine("MODULE", "Target", {
                script = scriptName,
                hierarchy = getScriptHierarchy(found),
                loaded = loadedSet[found] == true
            }, Color3.fromRGB(170, 220, 255))

            traceScriptEnv(found, scriptName)

            if found:IsA("ModuleScript") then
                if loadedSet[found] then
                    local okRequire, exported = pcall(require, found)
                    if okRequire then
                        writeLine("MODULE", "Export", {
                            script = scriptName,
                            summary = summarizeExportValue(exported)
                        }, Color3.fromRGB(180, 255, 200))
                        walkExportValue(scriptName, scriptName, exported, remoteIndex, 0, {}, {
                            functionLogs = 0,
                            tableLogs = 0
                        })
                    else
                        writeLine("MODULE", "ExportMiss", {
                            script = scriptName,
                            error = trimText(exported, 160)
                        }, Color3.fromRGB(255, 180, 120))
                    end
                else
                    writeLine("MODULE", "ExportSkipped", {
                        script = scriptName,
                        reason = "not_loaded"
                    }, Color3.fromRGB(255, 200, 120))
                end
            end

            foundCount = foundCount + scanGcFunctionsForTarget(found, scriptName, remoteIndex)
        else
            writeLine("MODULE", "ScriptMissing", { script = scriptName }, Color3.fromRGB(255, 180, 120))
        end
        scanned = scanned + 1
    end

    writeLine("MODULE", "ScanSummary", {
        targets = scanned,
        gcFunctions = foundCount
    }, Color3.fromRGB(160, 220, 255))
end

local function extractCombatTokens(value, bucket, depth)
    depth = depth or 0
    if depth > 3 then
        return
    end
    local kind = type(value)
    if kind == "string" then
        for token in string.gmatch(value, "[LMOP]%d+") do
            bucket[token] = true
        end
    elseif kind == "table" then
        for k, v in pairs(value) do
            extractCombatTokens(k, bucket, depth + 1)
            extractCombatTokens(v, bucket, depth + 1)
        end
    elseif kind == "userdata" or kind == "number" or kind == "boolean" then
        return
    end
end

local function traceIdleGap(kind, args)
    if not State.idleTraceEnabled then
        return
    end
    local tokens = {}
    extractCombatTokens(args, tokens, 0)
    local now = os.clock()

    for token in pairs(tokens) do
        local actor = State.combatActors[token] or {}
        if kind == "FightSkillEnd" or kind == "FightLogicPlayerDestroy" then
            actor.lastEnd = now
            State.combatActors[token] = actor
        elseif kind == "FightSkillStart" or kind == "FightLogicPlayerCreate" then
            if actor.lastEnd then
                writeLine("IDLE", "GapAfterEnd", {
                    actor = token,
                    nextKind = kind,
                    gap = math.floor((now - actor.lastEnd) * 1000 + 0.5) / 1000
                }, Color3.fromRGB(255, 220, 140))
                actor.lastEnd = nil
            end
            actor.lastStart = now
            State.combatActors[token] = actor
        end
    end
end

local function getProbeOffsets(index)
    local offsets = {
        Vector3.new(-5, 0, -2),
        Vector3.new(0, 0, -4),
        Vector3.new(5, 0, -2),
        Vector3.new(-8, 0, 2),
        Vector3.new(8, 0, 2)
    }
    return offsets[((index - 1) % #offsets) + 1]
end

local function applyPetPositionProbe(mode)
    local rootPart = getCharacterRoot()
    if not rootPart then
        return
    end

    local ownedPets = getOwnedPetRoots()
    for index, pet in ipairs(ownedPets) do
        local part = getRootPart(pet)
        if part then
            saveCFrame(State.petOriginals, pet, part)
            local offset = getProbeOffsets(index)
            local yOffset = 0
            if mode == "HOVER" then
                yOffset = 10
            elseif mode == "UNDERFOOT" then
                yOffset = -2.5
            elseif mode == "UNDERGROUND" then
                yOffset = -8
            end
            local target = rootPart.Position + Vector3.new(offset.X, yOffset, offset.Z)
            pcall(function()
                part.CFrame = CFrame.new(target)
            end)
        end
    end
end

local function applyPetNeutralProbe()
    local pets = Workspace:FindFirstChild("Pets")
    if not pets then
        return
    end
    local myId = tonumber(LP.UserId)
    for _, pet in ipairs(pets:GetChildren()) do
        local playerId = tonumber(pet:GetAttribute("PlayerId"))
        if playerId == myId then
            if pet:GetAttribute("PlayerId") ~= nil then
                saveAttr(State.petOriginals, pet, "PlayerId")
                pcall(function()
                    pet:SetAttribute("PlayerId", 0)
                end)
            end
            if pet:GetAttribute("OwnerUserId") ~= nil then
                saveAttr(State.petOriginals, pet, "OwnerUserId")
                pcall(function()
                    pet:SetAttribute("OwnerUserId", 0)
                end)
            end
        end
    end
end

local function applyMonsterMaskProbe()
    local roots = {
        Workspace:FindFirstChild("Monsters"),
        Workspace:FindFirstChild("ClientMonsters")
    }
    local myIdText = tostring(LP.UserId)

    for _, folder in ipairs(roots) do
        if folder then
            for _, monster in ipairs(folder:GetChildren()) do
                local ok, attrs = pcall(monster.GetAttributes, monster)
                if ok and type(attrs) == "table" then
                    for key, value in pairs(attrs) do
                        local lowerKey = lower(key)
                        local remove = false
                        if string.find(lowerKey, "battleplayer_", 1, true) and string.find(lowerKey, myIdText, 1, true) then
                            remove = true
                        elseif string.find(lowerKey, "catchplayerid_", 1, true) and string.find(lowerKey, myIdText, 1, true) then
                            remove = true
                        elseif lowerKey == "catchtakenplayerid" and tostring(value) == myIdText then
                            remove = true
                        end
                        if remove then
                            saveAttr(State.monsterOriginals, monster, key)
                            pcall(function()
                                monster:SetAttribute(key, nil)
                            end)
                        end
                    end
                end
            end
        end
    end
end

local function setProbeMode(mode)
    if State.probeMode == mode then
        return
    end
    restoreStore(State.petOriginals)
    restoreStore(State.monsterOriginals)
    State.probeMode = mode
    refreshProbeUi()
    writeLine("PROBE", "ModeChanged", { mode = mode }, Color3.fromRGB(255, 210, 120))
end

local function applyProbeMode()
    if State.probeMode == "NONE" then
        return
    elseif State.probeMode == "HOVER" or State.probeMode == "UNDERFOOT" or State.probeMode == "UNDERGROUND" then
        applyPetPositionProbe(State.probeMode)
    elseif State.probeMode == "PET_NEUTRAL" then
        applyPetNeutralProbe()
    elseif State.probeMode == "MONSTER_MASK" then
        applyMonsterMaskProbe()
    end
end

local function findAdornee(root)
    if not root or not root.Parent then
        return nil
    end
    if root:IsA("BasePart") then
        return root
    end
    if root:IsA("Model") then
        return root.PrimaryPart or root:FindFirstChildWhichIsA("BasePart", true)
    end
    return root:FindFirstChildWhichIsA("BasePart", true)
end

local function readInterestingAttributes(root)
    local attrs = {}
    local function pull(inst)
        if not inst then
            return
        end
        local ok, values = pcall(inst.GetAttributes, inst)
        if not ok or type(values) ~= "table" then
            return
        end
        for key, value in pairs(values) do
            local lowerKey = lower(key)
            if lowerKey == "rewardres" or lowerKey == "reward" or lowerKey == "tmplid"
                or lowerKey == "monsterid" or lowerKey == "npcid" or lowerKey == "level"
                or lowerKey == "owneruserid" or lowerKey == "playerid" or lowerKey == "petitemid" or lowerKey == "systag"
                or lowerKey == "catchendtick" or lowerKey == "catchtakenplayerid"
                or string.find(lowerKey, "battleplayer", 1, true)
                or string.find(lowerKey, "catchplayerid", 1, true) then
                attrs[key] = value
            end
        end
    end

    pull(root)
    local count = 0
    for _, desc in ipairs(root:GetDescendants()) do
        count = count + 1
        if count > 40 then
            break
        end
        pull(desc)
    end
    return attrs
end

local function extractRewardInfo(attrs)
    local rewardRes = attrs.RewardRes
    local tmplId = attrs.TmplId
    local reward = attrs.Reward

    if type(reward) == "table" then
        rewardRes = rewardRes or reward.RewardRes
        tmplId = tmplId or reward.TmplId
    elseif type(reward) == "string" then
        rewardRes = rewardRes
            or reward:match('"RewardRes"%s*:%s*"([^"]+)"')
            or reward:match("RewardRes%s*[=:]%s*\"?([%w_]+)\"?")
        local nestedTmplId = reward:match('"TmplId"%s*:%s*(%d+)')
            or reward:match("TmplId%s*[=:]%s*(%d+)")
        if tmplId == nil and nestedTmplId then
            tmplId = tonumber(nestedTmplId)
        end
    end

    return rewardRes, tmplId
end

local function classifyRoot(root)
    if not root then
        return "Unknown", {}
    end
    local path = lower(root:GetFullName())
    local name = lower(root.Name)
    local attrs = readInterestingAttributes(root)
    local rewardRes = extractRewardInfo(attrs)
    local rewardText = lower(rewardRes or attrs.RewardRes or attrs.Reward)

    if string.find(path, "areapickup", 1, true) or attrs.RewardRes ~= nil or attrs.Reward ~= nil then
        if rewardText == "egg"
            or string.find(rewardText, "egg", 1, true)
            or string.find(name, "egg", 1, true)
            or string.find(name, "huevo", 1, true) then
            return "Egg", attrs
        end
        return "Pickup", attrs
    end
    if string.find(path, "clientmonsters", 1, true) or string.find(path, "workspace.monsters", 1, true)
        or attrs.MonsterId ~= nil or string.find(name, "monster", 1, true) then
        return "Monster", attrs
    end
    if string.find(path, "clientpets", 1, true) or string.find(path, "workspace.pets", 1, true)
        or attrs.PetItemId ~= nil or attrs.OwnerUserId ~= nil or attrs.PlayerId ~= nil or string.find(name, "pet", 1, true) then
        return "Pet", attrs
    end
    return "Object", attrs
end

local function getBattleSummary(attrs)
    local battle = false
    local caught = false
    for key in pairs(attrs) do
        local lowerKey = lower(key)
        if string.find(lowerKey, "battleplayer", 1, true) then
            battle = true
        elseif string.find(lowerKey, "catchplayerid", 1, true) or lowerKey == "catchtakenplayerid" or lowerKey == "catchendtick" then
            caught = true
        end
    end
    return battle, caught
end

local function formatPickupLabel(kind, root, attrs)
    local label = kind
    local rewardRes, tmplId = extractRewardInfo(attrs)
    if rewardRes then
        label = label .. " | " .. tostring(rewardRes)
    else
        label = label .. " | " .. tostring(root.Name)
    end
    if tmplId then
        label = label .. " #" .. tostring(tmplId)
    end
    return label
end

local function removeTrackedEsp(root)
    local tracked = State.trackedEsp[root]
    if not tracked then
        return
    end
    if tracked.gui then
        tracked.gui:Destroy()
    end
    State.trackedEsp[root] = nil
end

local function registerPickupEsp(root, kind, attrs, source)
    if State.trackedEsp[root] then
        return
    end
    local adornee = findAdornee(root)
    if not adornee then
        return
    end

    local gui = Instance.new("BillboardGui")
    gui.Name = "ESP_" .. root.Name
    gui.AlwaysOnTop = true
    gui.Size = UDim2.new(0, 170, 0, 42)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.Adornee = adornee
    gui.Enabled = State.espEnabled
    gui.Parent = State.ui.espFolder

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextScaled = true
    text.TextStrokeTransparency = 0
    text.Font = Enum.Font.GothamBold
    text.TextColor3 = kind == "Egg" and Color3.fromRGB(255, 235, 80) or Color3.fromRGB(100, 255, 140)
    text.Parent = gui

    State.trackedEsp[root] = {
        root = root,
        kind = kind,
        attrs = attrs,
        gui = gui,
        text = text
    }

    local rewardRes, tmplId = extractRewardInfo(attrs)
    writeLine("WORLD", source, {
        kind = kind,
        path = root:GetFullName(),
        rewardRes = rewardRes,
        tmplId = tmplId,
        reward = attrs.Reward
    }, kind == "Egg" and Color3.fromRGB(255, 235, 80) or Color3.fromRGB(120, 255, 170))
end

local function inspectRoot(root, source)
    if not root or not root.Parent then
        return
    end
    local kind, attrs = classifyRoot(root)
    local prompt = root:FindFirstChildWhichIsA("ProximityPrompt", true)
    local click = root:FindFirstChildWhichIsA("ClickDetector", true)

    if kind == "Egg" or kind == "Pickup" then
        registerPickupEsp(root, kind, attrs, source)
        return
    end

    if kind == "Monster" or kind == "Pet" then
        local battle, caught = getBattleSummary(attrs)
        writeLine("ENTITY", source, {
            kind = kind,
            path = root:GetFullName(),
            monsterId = attrs.MonsterId,
            petItemId = attrs.PetItemId,
            level = attrs.Level,
            playerId = attrs.PlayerId,
            ownerUserId = attrs.OwnerUserId,
            battle = battle,
            caught = caught,
            click = click ~= nil,
            prompt = prompt ~= nil
        }, kind == "Monster" and Color3.fromRGB(255, 180, 110) or Color3.fromRGB(130, 220, 255))
    end
end

local function scanInterestingRoots()
    local roots = {
        Workspace:FindFirstChild("AreaPickUp"),
        Workspace:FindFirstChild("Monsters"),
        Workspace:FindFirstChild("Pets"),
        Workspace:FindFirstChild("ClientMonsters"),
        Workspace:FindFirstChild("ClientPets")
    }

    for _, folder in ipairs(roots) do
        if folder then
            for _, child in ipairs(folder:GetChildren()) do
                inspectRoot(child, "Scan")
            end
        end
    end
end

local function watchFolder(folder)
    if not folder then
        return
    end
    for _, child in ipairs(folder:GetChildren()) do
        inspectRoot(child, "Initial")
    end
    addConnection(folder.ChildAdded:Connect(function(child)
        task.delay(0.1, function()
            if State.active then
                inspectRoot(child, "Added")
            end
        end)
    end))
    addConnection(folder.ChildRemoved:Connect(function(child)
        removeTrackedEsp(child)
    end))
end

local function updateEsps()
    if not State.espEnabled then
        for _, tracked in pairs(State.trackedEsp) do
            tracked.gui.Enabled = false
        end
        return
    end

    local rootPart = getCharacterRoot()
    for root, tracked in pairs(State.trackedEsp) do
        if not root.Parent then
            removeTrackedEsp(root)
        else
            local adornee = findAdornee(root)
            if not adornee then
                removeTrackedEsp(root)
            else
                tracked.gui.Adornee = adornee
                tracked.gui.Enabled = true
                local distText = "?"
                if rootPart then
                    distText = tostring(math.floor((adornee.Position - rootPart.Position).Magnitude))
                end
                tracked.text.Text = formatPickupLabel(tracked.kind, root, tracked.attrs) .. "\n[" .. distText .. "m]"
            end
        end
    end
end

local function mergeAttributes(primary, secondary)
    local merged = {}
    for _, attrs in ipairs({ primary, secondary }) do
        if type(attrs) == "table" then
            for key, value in pairs(attrs) do
                if merged[key] == nil then
                    merged[key] = value
                end
            end
        end
    end
    return merged
end

local function collectMonsterEntries()
    local entries = {}

    local function attach(folder, field)
        if not folder then
            return
        end
        for _, child in ipairs(folder:GetChildren()) do
            local _, attrs = classifyRoot(child)
            local key = tostring(attrs.MonsterId or child.Name)
            local entry = entries[key]
            if not entry then
                entry = { key = key }
                entries[key] = entry
            end
            entry[field] = child
            entry[field .. "Attrs"] = attrs
        end
    end

    attach(Workspace:FindFirstChild("Monsters"), "logic")
    attach(Workspace:FindFirstChild("ClientMonsters"), "render")

    local list = {}
    for _, entry in pairs(entries) do
        entry.attrs = mergeAttributes(entry.logicAttrs, entry.renderAttrs)
        entry.adornee = findAdornee(entry.render or entry.logic)
        table.insert(list, entry)
    end
    return list
end

local function collectPetEntries()
    local entries = {}

    local function getPetEntryKey(child, attrs)
        local fullSuffix = tostring(child.Name):match("^Pet_%d+_(%d+)$")
        local shortSuffix = tostring(child.Name):match("^Pet_(%d+)$")
        if fullSuffix then
            return "suffix:" .. tostring(fullSuffix)
        end
        if shortSuffix then
            return "suffix:" .. tostring(shortSuffix)
        end
        if attrs.PetItemId ~= nil then
            return "item:" .. tostring(attrs.PetItemId)
        end
        return "name:" .. tostring(child.Name)
    end

    local function attach(folder, field)
        if not folder then
            return
        end
        for _, child in ipairs(folder:GetChildren()) do
            local _, attrs = classifyRoot(child)
            local key = getPetEntryKey(child, attrs)
            local entry = entries[key]
            if not entry then
                entry = { key = key }
                entries[key] = entry
            end
            entry[field] = child
            entry[field .. "Attrs"] = attrs
        end
    end

    attach(Workspace:FindFirstChild("Pets"), "logic")
    attach(Workspace:FindFirstChild("ClientPets"), "render")

    local count = 0
    for _ in pairs(entries) do
        count = count + 1
    end
    return count
end

local function snapshotProbeState(rootPart)
    if State.probeMode == "NONE" or not rootPart then
        return
    end

    local probePets = getOwnedPetRoots()
    if #probePets == 0 then
        for pet in pairs(State.petOriginals) do
            if pet and pet.Parent then
                table.insert(probePets, pet)
            end
        end
    end

    local samples = {}
    for index, pet in ipairs(probePets) do
        if index > 3 then
            break
        end
        local part = getRootPart(pet)
        if part then
            local attrs = readInterestingAttributes(pet)
            table.insert(samples, {
                pet = pet.Name,
                dist = math.floor((part.Position - rootPart.Position).Magnitude),
                dy = math.floor((part.Position.Y - rootPart.Position.Y) * 10) / 10,
                playerId = attrs.PlayerId,
                ownerUserId = attrs.OwnerUserId
            })
        end
    end

    writeLine("PROBE", "PetState", {
        mode = State.probeMode,
        samples = samples
    }, Color3.fromRGB(255, 210, 120))
end

local function snapshotWorld()
    local rootPart = getCharacterRoot()
    local areaPickUp = Workspace:FindFirstChild("AreaPickUp")

    local eggCount, pickupCount, monsterCount, petCount = 0, 0, 0, 0
    local nearest = {}

    if areaPickUp then
        for _, child in ipairs(areaPickUp:GetChildren()) do
            local kind = classifyRoot(child)
            if kind == "Egg" then
                eggCount = eggCount + 1
            else
                pickupCount = pickupCount + 1
            end
        end
    end

    local monsterEntries = collectMonsterEntries()
    monsterCount = #monsterEntries
    if rootPart then
        table.sort(monsterEntries, function(a, b)
            local aDist = a.adornee and (a.adornee.Position - rootPart.Position).Magnitude or math.huge
            local bDist = b.adornee and (b.adornee.Position - rootPart.Position).Magnitude or math.huge
            return aDist < bDist
        end)
        for _, entry in ipairs(monsterEntries) do
            if #nearest >= 4 then
                break
            end
            if entry.adornee then
                local battle, caught = getBattleSummary(entry.attrs)
                table.insert(nearest, {
                    id = entry.attrs.MonsterId or entry.key,
                    level = entry.attrs.Level,
                    dist = math.floor((entry.adornee.Position - rootPart.Position).Magnitude),
                    battle = battle,
                    caught = caught
                })
            end
        end
    end

    petCount = collectPetEntries()

    writeLine("SNAPSHOT", "World", {
        eggs = eggCount,
        pickups = pickupCount,
        monsters = monsterCount,
        pets = petCount,
        nearestMonsters = nearest
    }, Color3.fromRGB(160, 200, 255))
    snapshotProbeState(rootPart)
end

local function hookRemoteEvent(remote, callback)
    if not remote or not remote:IsA("RemoteEvent") then
        return
    end
    addConnection(remote.OnClientEvent:Connect(function(...)
        if not State.active or not State.auditEnabled then
            return
        end
        callback(...)
    end))
end

local function installRemoteAudit()
    local common = ReplicatedStorage:FindFirstChild("CommonLibrary")
    local tool = common and common:FindFirstChild("Tool")
    local manager = tool and tool:FindFirstChild("RemoteManager")
    local events = manager and manager:FindFirstChild("Events")
    if not events then
        writeLine("SYSTEM", "RemoteManagerMissing", nil, Color3.fromRGB(255, 120, 120))
        return
    end

    hookRemoteEvent(events:FindFirstChild("NotificationEvent"), function(...)
        local args = { ... }
        writeLine("ANNOUNCE", "NotificationEvent", {
            subtype = args[1],
            a2 = args[2],
            a3 = args[3],
            a4 = args[4]
        }, Color3.fromRGB(255, 235, 120))
    end)

    hookRemoteEvent(events:FindFirstChild("PushRewardEvent"), function(...)
        writeLine("REWARD", "PushRewardEvent", { ... }, Color3.fromRGB(120, 255, 170))
    end)

    hookRemoteEvent(events:FindFirstChild("Message"), function(...)
        local args = { ... }
        local kind = tostring(args[1] or "")
        if IMPORTANT_MESSAGE_KINDS[kind] then
            traceIdleGap(kind, args)
            if kind == "PetHealthSync" then
                local petItemId = tonumber(args[2])
                local healthPayload = args[3]
                local newHealth = tonumber(healthPayload)
                if newHealth == nil and type(healthPayload) == "table" then
                    newHealth = tonumber(healthPayload.v or healthPayload.Value or healthPayload.Health)
                end
                local oldHealth = petItemId and State.petHealth[petItemId] or nil
                if petItemId and newHealth then
                    State.petHealth[petItemId] = newHealth
                    if oldHealth and newHealth > oldHealth then
                        writeLine("HEAL", "PetHealthUp", {
                            petItemId = petItemId,
                            old = oldHealth,
                            new = newHealth,
                            delta = newHealth - oldHealth
                        }, Color3.fromRGB(120, 255, 170))
                        traceRecoverContext("PetHealthUp", petItemId, oldHealth, newHealth)
                    elseif newHealth <= 0 then
                        writeLine("HEAL", "PetDown", {
                            petItemId = petItemId,
                            new = newHealth
                        }, Color3.fromRGB(255, 130, 130))
                        traceRecoverContext("PetDown", petItemId, oldHealth, newHealth)
                    elseif oldHealth and newHealth < oldHealth then
                        writeLine("HEAL", "PetHealthDown", {
                            petItemId = petItemId,
                            old = oldHealth,
                            new = newHealth,
                            delta = newHealth - oldHealth
                        }, Color3.fromRGB(255, 190, 130))
                    end
                end
            end
            writeLine("COMBAT", kind, { ... }, Color3.fromRGB(255, 190, 130))
        elseif kind == "StreamingAddData" or kind == "StreamingRemoveData" then
            local updateKind = tostring(args[3] or "")
            if updateKind ~= "MovePath" then
                writeLine("SYNC", kind, { ... }, Color3.fromRGB(160, 210, 255))
            end
        end
    end)
end

local function installInputAudit()
    addConnection(UserInputService.InputBegan:Connect(function(input, processed)
        if not State.active or not State.auditEnabled or processed then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            writeLine("INPUT", "MouseButton1", nil, Color3.fromRGB(210, 210, 210))
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            writeLine("INPUT", "MouseButton2", nil, Color3.fromRGB(210, 210, 210))
        elseif input.UserInputType == Enum.UserInputType.Keyboard then
            local key = input.KeyCode.Name
            if IMPORTANT_INPUT[key] then
                writeLine("INPUT", key, nil, Color3.fromRGB(210, 210, 210))
            end
        end
    end))

    addConnection(ProximityPromptService.PromptShown:Connect(function(prompt)
        if not State.active or not State.auditEnabled then
            return
        end
        writeLine("PROMPT", "Shown", {
            path = prompt:GetFullName(),
            action = prompt.ActionText,
            object = prompt.ObjectText,
            key = prompt.KeyboardKeyCode.Name
        }, Color3.fromRGB(180, 220, 255))
    end))

    addConnection(ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
        if not State.active or not State.auditEnabled then
            return
        end
        writeLine("PROMPT", "Triggered", {
            path = prompt:GetFullName(),
            action = prompt.ActionText,
            object = prompt.ObjectText,
            player = player and player.Name or nil
        }, Color3.fromRGB(180, 255, 180))
    end))
end

local function installLoops()
    addConnection(RunService.Heartbeat:Connect(function()
        if not State.active then
            return
        end

        local now = os.clock()
        if now - State.lastEspAt >= CONFIG.espUpdateInterval then
            State.lastEspAt = now
            updateEsps()
            applyProbeMode()
        end
        if now - State.lastSnapshotAt >= CONFIG.snapshotInterval then
            State.lastSnapshotAt = now
            snapshotWorld()
        end
        if now - State.lastFlushAt >= CONFIG.flushInterval then
            State.lastFlushAt = now
            flushFile()
        end
    end))
end

local function installUiActions()
    State.ui.scanButton.MouseButton1Click:Connect(function()
        writeLine("UI", "ManualScan", nil, Color3.fromRGB(220, 220, 120))
        scanInterestingRoots()
        snapshotWorld()
        scanRuntimeCandidates(true)
    end)

    if State.ui.probeButtons then
        for _, mode in ipairs(PROBE_MODES) do
            local button = State.ui.probeButtons[mode.id]
            if button then
                button.MouseButton1Click:Connect(function()
                    setProbeMode(mode.id)
                end)
            end
        end
    end
end

function State.stop(reason)
    State.active = false
    flushFile()
    cleanupConnections()
    restoreStore(State.petOriginals)
    restoreStore(State.monsterOriginals)
    for root in pairs(State.trackedEsp) do
        removeTrackedEsp(root)
    end
    if State.ui.screen then
        State.ui.screen:Destroy()
    end
    rawset(_G, "CAMQAHarness", nil)
end

buildGui()
ensureFile()
if State.ui.fileLabel then
    State.ui.fileLabel.Text = "File: " .. tostring(State.file or "writefile unavailable")
end
setStatus("Running")
refreshProbeUi()
writeLine("SYSTEM", "Started", {
    placeId = game.PlaceId,
    jobId = game.JobId,
    player = LP and LP.Name or "unknown"
}, Color3.fromRGB(120, 255, 200))

watchFolder(Workspace:FindFirstChild("AreaPickUp"))
watchFolder(Workspace:FindFirstChild("Monsters"))
watchFolder(Workspace:FindFirstChild("Pets"))
watchFolder(Workspace:FindFirstChild("ClientMonsters"))
watchFolder(Workspace:FindFirstChild("ClientPets"))
installRecoverGuiAudit()
installRemoteAudit()
installInputAudit()
installLoops()
installUiActions()
scanInterestingRoots()
snapshotWorld()
task.defer(function()
    if State.active then
        scanRuntimeCandidates(true)
    end
end)
