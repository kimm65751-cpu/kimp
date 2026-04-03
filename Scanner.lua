local success, errorMessage = pcall(function()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")

    local LP = Players.LocalPlayer
    local PlayerGui = LP:WaitForChild("PlayerGui")

    local oldGui = PlayerGui:FindFirstChild("CAM_Injector_V10")
    if oldGui then
        oldGui:Destroy()
    end
    local oldErr = PlayerGui:FindFirstChild("CAM_ErrorGui")
    if oldErr then
        oldErr:Destroy()
    end

    local existing = rawget(_G, "CAMInjectorV10")
    if existing and existing.stop then
        pcall(function()
            existing.stop("Replaced")
        end)
    end

    local State = {
        active = true,
        fileName = nil,
        modules = {
            MgrMonsterClient = nil,
            MgrPetClient = nil,
            MgrFightClient = nil,
            MonsterCatchUtil = nil,
            PushRewardEvent = nil
        },
        rewardConn = nil,
        fightConns = {},
        autoClick = false,
        burstLoop = false,
        autoClickTask = nil,
        log = {},
        ui = {},
        lastNearestMonsterId = nil,
        lastCatchSignature = nil,
        hookedFightAck = false
    }
    _G.CAMInjectorV10 = State

    local function getLogFileName()
        local base = "CAM_Injector_V10_" .. os.date("%Y%m%d_%H%M%S")
        local ext = ".txt"
        if not isfile then
            return base .. ext
        end

        local candidate = base .. ext
        local idx = 2
        while isfile(candidate) do
            candidate = base .. "_" .. tostring(idx) .. ext
            idx = idx + 1
        end
        return candidate
    end

    local function ensureLogFile()
        if State.fileName or not writefile then
            return
        end

        State.fileName = getLogFileName()
        local header = table.concat({
            "============================================================",
            " CAM INJECTOR V10",
            " Date: " .. os.date("%Y-%m-%d %H:%M:%S"),
            " PlaceId=" .. tostring(game.PlaceId) .. " | JobId=" .. tostring(game.JobId),
            " Player=" .. tostring(LP and LP.Name or "unknown"),
            "============================================================",
            ""
        }, "\n")

        pcall(function()
            writefile(State.fileName, header)
        end)
    end

    local function appendLogFile(line)
        ensureLogFile()
        if not State.fileName then
            return
        end

        if appendfile then
            pcall(function()
                appendfile(State.fileName, line .. "\n")
            end)
            return
        end

        if readfile and writefile then
            pcall(function()
                local old = ""
                if isfile and isfile(State.fileName) then
                    old = readfile(State.fileName)
                end
                writefile(State.fileName, old .. line .. "\n")
            end)
        end
    end

    local function summarize(value, depth)
        depth = depth or 0
        if depth > 2 then
            return "..."
        end

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

        local luaKind = type(value)
        if luaKind == "table" then
            local parts = {}
            local count = 0
            for k, v in pairs(value) do
                count = count + 1
                if count > 8 then
                    table.insert(parts, "...")
                    break
                end
                table.insert(parts, tostring(k) .. "=" .. summarize(v, depth + 1))
            end
            table.sort(parts)
            return "{" .. table.concat(parts, " | ") .. "}"
        end
        return tostring(value)
    end

    local function addLog(text, color)
        local fullLine = "[" .. os.date("%X") .. "] " .. text
        table.insert(State.log, fullLine)
        appendLogFile(fullLine)

        local logFrame = State.ui.logFrame
        if not logFrame then
            return
        end

        local line = Instance.new("TextLabel")
        line.BackgroundTransparency = 1
        line.Size = UDim2.new(1, -8, 0, 16)
        line.AutomaticSize = Enum.AutomaticSize.Y
        line.TextWrapped = true
        line.TextXAlignment = Enum.TextXAlignment.Left
        line.TextYAlignment = Enum.TextYAlignment.Top
        line.Font = Enum.Font.Code
        line.TextSize = 11
        line.TextColor3 = color or Color3.fromRGB(210, 210, 210)
        line.Text = fullLine
        line.Parent = logFrame

        logFrame.CanvasSize = UDim2.new(0, 0, 0, (State.ui.list and State.ui.list.AbsoluteContentSize.Y or 0) + 10)
        logFrame.CanvasPosition = Vector2.new(0, math.max(0, logFrame.CanvasSize.Y.Offset))

        local max = 180
        while #logFrame:GetChildren() > max + 1 do
            for _, child in ipairs(logFrame:GetChildren()) do
                if child:IsA("TextLabel") then
                    child:Destroy()
                    break
                end
            end
        end
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
        return nil
    end

    local function getMonsterId(monster)
        if not monster then
            return nil
        end
        local attrId = monster:GetAttribute("MonsterId")
        if attrId ~= nil then
            return attrId
        end
        local id = tostring(monster.Name):match("^Monster_(%d+)$")
        if id then
            return tonumber(id)
        end
        return nil
    end

    local function getBattleFlags(monster)
        local battle = false
        local caught = false
        local ok, attrs = pcall(monster.GetAttributes, monster)
        if ok and type(attrs) == "table" then
            for key in pairs(attrs) do
                local lowerKey = string.lower(tostring(key))
                if string.find(lowerKey, "battleplayer", 1, true) then
                    battle = true
                elseif string.find(lowerKey, "catchplayerid", 1, true) or lowerKey == "catchtakenplayerid" or lowerKey == "catchendtick" then
                    caught = true
                end
            end
        end
        return battle, caught
    end

    local function findNearestMonster()
        local root = getCharacterRoot()
        local monsters = Workspace:FindFirstChild("Monsters")
        if not root or not monsters then
            return nil
        end

        local bestMonster, bestPart, bestDist
        bestDist = math.huge
        for _, monster in ipairs(monsters:GetChildren()) do
            local part = getRootPart(monster)
            if part then
                local dist = (part.Position - root.Position).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestMonster = monster
                    bestPart = part
                end
            end
        end
        return bestMonster, bestPart, bestDist
    end

    local function findNearestClickable()
        local root = getCharacterRoot()
        local monsters = Workspace:FindFirstChild("ClientMonsters")
        if not root or not monsters then
            return nil, nil, nil
        end

        local bestDetector, bestMonster, bestDist
        bestDist = math.huge
        for _, monster in ipairs(monsters:GetChildren()) do
            local detector = monster:FindFirstChildWhichIsA("ClickDetector", true)
            local part = getRootPart(monster)
            if detector and part then
                local dist = (part.Position - root.Position).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestDetector = detector
                    bestMonster = monster
                end
            end
        end
        return bestDetector, bestMonster, bestDist
    end

    local function collectTeamPets()
        local pets = Workspace:FindFirstChild("Pets")
        local out = {}
        if not pets then
            return out
        end

        local myId = tostring(LP.UserId)
        for _, pet in ipairs(pets:GetChildren()) do
            local playerId = tostring(pet:GetAttribute("PlayerId") or "")
            local ownerUserId = tostring(pet:GetAttribute("OwnerUserId") or "")
            if playerId == myId or ownerUserId == myId then
                table.insert(out, {
                    name = pet.Name,
                    petItemId = pet:GetAttribute("PetItemId"),
                    level = pet:GetAttribute("Level"),
                    playerId = pet:GetAttribute("PlayerId"),
                    ownerUserId = pet:GetAttribute("OwnerUserId")
                })
            end
        end
        return out
    end

    local function clearFightWatch()
        for _, conn in ipairs(State.fightConns) do
            pcall(function()
                conn:Disconnect()
            end)
        end
        State.fightConns = {}
    end

    local function installFightWatch()
        clearFightWatch()

        local commonLibrary = ReplicatedStorage:FindFirstChild("CommonLibrary")
        local toolFolder = commonLibrary and commonLibrary:FindFirstChild("Tool")
        local remoteManager = toolFolder and toolFolder:FindFirstChild("RemoteManager")
        local events = remoteManager and remoteManager:FindFirstChild("Events")
        local messageRemote = events and events:FindFirstChild("Message")

        if messageRemote and messageRemote:IsA("RemoteEvent") then
            table.insert(State.fightConns, messageRemote.OnClientEvent:Connect(function(...)
                local args = { ... }
                local kind = tostring(args[1] or "")
                if kind == "FightSkillStart"
                    or kind == "FightSkillEnd"
                    or kind == "FightLogicPlayerCreate"
                    or kind == "FightLogicPlayerDestroy"
                    or kind == "MonsterHurtInfo"
                    or kind == "PetHurtInfo"
                    or kind == "MonsterCatch" then
                    addLog("FightEvent[" .. kind .. "] -> " .. summarize(args), Color3.fromRGB(255, 220, 150))
                end
            end))
            addLog("Fight watch ON", Color3.fromRGB(120, 255, 160))
        else
            addLog("No se encontro RemoteManager.Events.Message", Color3.fromRGB(255, 120, 120))
        end
    end

    local function hookFightAck()
        if State.hookedFightAck then
            return
        end

        local mgrFight = State.modules.MgrFightClient
        if not mgrFight or type(mgrFight) ~= "table" then
            return
        end

        if type(mgrFight._onUseSkillAck) == "function" then
            local original = mgrFight._onUseSkillAck
            mgrFight._onUseSkillAck = function(...)
                addLog("_onUseSkillAck -> " .. summarize({ ... }), Color3.fromRGB(150, 220, 255))
                return original(...)
            end
            State.hookedFightAck = true
            addLog("Hook _onUseSkillAck OK", Color3.fromRGB(120, 255, 160))
        end
    end

    local function getFightStatus()
        local mgrFight = State.modules.MgrFightClient
        if not mgrFight then
            return {}
        end

        local payload = {}
        if type(mgrFight.GetSelfUsingSkill) == "function" then
            local ok, result = pcall(mgrFight.GetSelfUsingSkill, mgrFight)
            payload.selfUsingSkill = ok and result or ("ERR: " .. tostring(result))
        end
        return payload
    end

    local function buildSkillArgs(monster, part)
        local args = {}
        local monsterId = getMonsterId(monster)
        if monster then
            table.insert(args, { label = "monsterModel", value = monster })
        end
        if part then
            table.insert(args, { label = "monsterPart", value = part })
        end
        if monsterId ~= nil then
            table.insert(args, { label = "monsterId", value = monsterId })
        end
        return args
    end

    local function tryUseSkillOnce(monster, part)
        local mgrFight = State.modules.MgrFightClient
        if not mgrFight or type(mgrFight.TryUseSkill) ~= "function" then
            return false, "MgrFightClient.TryUseSkill no disponible"
        end

        local tried = {}
        for _, candidate in ipairs(buildSkillArgs(monster, part)) do
            local ok, result = pcall(mgrFight.TryUseSkill, mgrFight, candidate.value)
            table.insert(tried, {
                mode = "self",
                arg = candidate.label,
                ok = ok,
                result = ok and result or tostring(result)
            })
            if ok then
                return true, tried
            end

            local ok2, result2 = pcall(mgrFight.TryUseSkill, candidate.value)
            table.insert(tried, {
                mode = "plain",
                arg = candidate.label,
                ok = ok2,
                result = ok2 and result2 or tostring(result2)
            })
            if ok2 then
                return true, tried
            end
        end
        return false, tried
    end

    local function runBurstTest(attempts)
        local monster, part, dist = findNearestMonster()
        if not monster or not part then
            addLog("No hay monster cercano para burst", Color3.fromRGB(255, 120, 120))
            return
        end

        if not State.modules.MgrFightClient then
            addLog("Primero haz Hook Modules", Color3.fromRGB(255, 120, 120))
            return
        end

        local before = getFightStatus()
        local okCount = 0
        local failCount = 0
        local lastResult = nil

        for _ = 1, attempts do
            local ok, result = tryUseSkillOnce(monster, part)
            if ok then
                okCount = okCount + 1
            else
                failCount = failCount + 1
            end
            lastResult = result
        end

        local after = getFightStatus()
        addLog("BurstTest -> " .. summarize({
            monster = monster.Name,
            dist = math.floor(dist or 0),
            attempts = attempts,
            ok = okCount,
            fail = failCount,
            before = before,
            after = after,
            last = lastResult
        }), Color3.fromRGB(255, 200, 120))
    end

    local function hookModules()
        local clientLogic = ReplicatedStorage:FindFirstChild("ClientLogic")
        local commonLibrary = ReplicatedStorage:FindFirstChild("CommonLibrary")

        if not clientLogic or not commonLibrary then
            addLog("No se encontró ClientLogic/CommonLibrary", Color3.fromRGB(255, 120, 120))
            return
        end

        local monsterFolder = clientLogic:FindFirstChild("Monster")
        local petFolder = clientLogic:FindFirstChild("Pet")
        local fightFolder = clientLogic:FindFirstChild("Fight")
        local toolFolder = commonLibrary:FindFirstChild("Tool")
        local remoteManager = toolFolder and toolFolder:FindFirstChild("RemoteManager")
        local events = remoteManager and remoteManager:FindFirstChild("Events")

        local mgrMonster = monsterFolder and monsterFolder:FindFirstChild("MgrMonsterClient")
        local mgrPet = petFolder and petFolder:FindFirstChild("MgrPetClient")
        local mgrFight = fightFolder and fightFolder:FindFirstChild("MgrFightClient")
        local catchUtil = monsterFolder and monsterFolder:FindFirstChild("MonsterCatchUtil")
        local rewardRemote = events and events:FindFirstChild("PushRewardEvent")

        if mgrMonster and mgrMonster:IsA("ModuleScript") then
            local ok, mod = pcall(require, mgrMonster)
            if ok and type(mod) == "table" then
                State.modules.MgrMonsterClient = mod
                addLog("MgrMonsterClient OK", Color3.fromRGB(120, 255, 160))
            else
                addLog("MgrMonsterClient falló: " .. tostring(mod), Color3.fromRGB(255, 120, 120))
            end
        end

        if mgrPet and mgrPet:IsA("ModuleScript") then
            local ok, mod = pcall(require, mgrPet)
            if ok and type(mod) == "table" then
                State.modules.MgrPetClient = mod
                addLog("MgrPetClient OK", Color3.fromRGB(120, 255, 160))
            else
                addLog("MgrPetClient falló: " .. tostring(mod), Color3.fromRGB(255, 120, 120))
            end
        end

        if mgrFight and mgrFight:IsA("ModuleScript") then
            local ok, mod = pcall(require, mgrFight)
            if ok and type(mod) == "table" then
                State.modules.MgrFightClient = mod
                addLog("MgrFightClient OK", Color3.fromRGB(120, 255, 160))
                addLog("Fight API -> " .. summarize({
                    TryUseSkill = type(mod.TryUseSkill),
                    GetSelfUsingSkill = type(mod.GetSelfUsingSkill),
                    GetUnitUsingSkill = type(mod.GetUnitUsingSkill),
                    TryUseRush = type(mod.TryUseRush)
                }), Color3.fromRGB(150, 220, 255))
                hookFightAck()
            else
                addLog("MgrFightClient fallo: " .. tostring(mod), Color3.fromRGB(255, 120, 120))
            end
        else
            addLog("No se encontro MgrFightClient", Color3.fromRGB(255, 120, 120))
        end

        if catchUtil and catchUtil:IsA("ModuleScript") then
            local ok, mod = pcall(require, catchUtil)
            if ok and type(mod) == "table" then
                State.modules.MonsterCatchUtil = mod
                addLog("MonsterCatchUtil OK", Color3.fromRGB(120, 255, 160))
            else
                addLog("MonsterCatchUtil falló: " .. tostring(mod), Color3.fromRGB(255, 120, 120))
            end
        end

        if rewardRemote and rewardRemote:IsA("RemoteEvent") then
            State.modules.PushRewardEvent = rewardRemote
            addLog("PushRewardEvent OK", Color3.fromRGB(120, 255, 160))
        else
            addLog("No se encontró PushRewardEvent", Color3.fromRGB(255, 120, 120))
        end
    end

    local function scanNearestMonster()
        local monster, part, dist = findNearestMonster()
        if not monster or not part then
            addLog("No hay monstruo cercano", Color3.fromRGB(255, 140, 140))
            return
        end

        local battle, caught = getBattleFlags(monster)
        local monsterId = getMonsterId(monster)
        local payload = {
            name = monster.Name,
            monsterId = monsterId,
            dist = math.floor(dist),
            battle = battle,
            caught = caught,
            pos = part.Position
        }
        addLog("Monster cercano -> " .. summarize(payload), Color3.fromRGB(255, 220, 120))

        local mgrMonster = State.modules.MgrMonsterClient
        if not mgrMonster then
            addLog("Primero haz Hook Modules", Color3.fromRGB(255, 120, 120))
            return
        end

        if type(mgrMonster.GetMonsterIdByPart) == "function" then
            local ok, result = pcall(mgrMonster.GetMonsterIdByPart, part)
            addLog("GetMonsterIdByPart -> " .. summarize(ok and result or ("ERR: " .. tostring(result))), Color3.fromRGB(160, 220, 255))
        end

        if monsterId ~= nil and type(mgrMonster.GetMonsterInfo) == "function" then
            local ok, info = pcall(mgrMonster.GetMonsterInfo, monsterId)
            addLog("GetMonsterInfo(" .. tostring(monsterId) .. ") -> " .. summarize(ok and info or ("ERR: " .. tostring(info))), Color3.fromRGB(160, 220, 255))
        end

        if monsterId ~= nil and type(mgrMonster.GetMonsterBoundingBox) == "function" then
            local ok, cf, size = pcall(mgrMonster.GetMonsterBoundingBox, monsterId)
            if ok then
                addLog("GetMonsterBoundingBox(" .. tostring(monsterId) .. ") -> center=" .. summarize(cf) .. " size=" .. summarize(size), Color3.fromRGB(160, 220, 255))
            else
                addLog("GetMonsterBoundingBox error -> " .. tostring(cf), Color3.fromRGB(255, 120, 120))
            end
        end
    end

    local function scanPets()
        local pets = collectTeamPets()
        addLog("Pets -> " .. summarize(pets), Color3.fromRGB(140, 220, 255))
    end

    local function installRewardWatch()
        if State.rewardConn then
            addLog("Reward watch ya estaba activo", Color3.fromRGB(200, 220, 120))
            return
        end
        local rewardRemote = State.modules.PushRewardEvent
        if not rewardRemote then
            addLog("Primero haz Hook Modules", Color3.fromRGB(255, 120, 120))
            return
        end

        State.rewardConn = rewardRemote.OnClientEvent:Connect(function(...)
            local args = { ... }
            addLog("PushRewardEvent -> " .. summarize(args), Color3.fromRGB(120, 255, 160))
        end)
        addLog("Reward watch ON", Color3.fromRGB(120, 255, 160))
    end

    local function toggleAutoClick(button)
        State.autoClick = not State.autoClick
        button.BackgroundColor3 = State.autoClick and Color3.fromRGB(180, 80, 80) or Color3.fromRGB(35, 35, 40)
        button.Text = State.autoClick and "🛑 AUTO CLICK NEAREST: ON" or "🖱️ AUTO CLICK NEAREST: OFF"
        addLog(State.autoClick and "Auto click ON" or "Auto click OFF", Color3.fromRGB(255, 180, 200))
    end

    local function buildGui()
        local sg = Instance.new("ScreenGui")
        sg.Name = "CAM_Injector_V10"
        sg.ResetOnSpawn = false
        sg.Parent = PlayerGui

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 500, 0, 465)
        frame.Position = UDim2.new(0.44, 0, 0.18, 0)
        frame.BackgroundColor3 = Color3.fromRGB(20, 16, 22)
        frame.BorderSizePixel = 2
        frame.BorderColor3 = Color3.fromRGB(0, 255, 170)
        frame.Active = true
        frame.Draggable = true
        frame.Parent = sg

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 28)
        title.BackgroundColor3 = Color3.fromRGB(10, 60, 42)
        title.Text = "  CAM V10 - Loader Limpio Basado En Logs"
        title.TextColor3 = Color3.fromRGB(170, 255, 210)
        title.TextSize = 12
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = frame

        local fileLabel = Instance.new("TextLabel")
        fileLabel.Size = UDim2.new(1, -12, 0, 16)
        fileLabel.Position = UDim2.new(0, 6, 0, 30)
        fileLabel.BackgroundTransparency = 1
        fileLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        fileLabel.TextSize = 10
        fileLabel.Font = Enum.Font.Code
        fileLabel.TextXAlignment = Enum.TextXAlignment.Left
        fileLabel.Text = "TXT: " .. tostring(State.fileName or "writefile no disponible")
        fileLabel.Parent = frame

        local logFrame = Instance.new("ScrollingFrame")
        logFrame.Size = UDim2.new(1, -12, 0, 210)
        logFrame.Position = UDim2.new(0, 6, 0, 48)
        logFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
        logFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        logFrame.ScrollBarThickness = 4
        logFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        logFrame.Parent = frame

        local list = Instance.new("UIListLayout")
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = logFrame

        local function mkBtn(text, y)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0.92, 0, 0, 30)
            b.Position = UDim2.new(0.04, 0, 0, y)
            b.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            b.TextColor3 = Color3.new(1, 1, 1)
            b.Font = Enum.Font.GothamSemibold
            b.TextSize = 11
            b.Text = text
            b.Parent = frame
            return b
        end

        local hookBtn = mkBtn("⚙️ HOOK MODULES CONFIRMADOS", 255)
        local scanMonsterBtn = mkBtn("🔍 SCAN MONSTER CERCANO", 290)
        local scanPetsBtn = mkBtn("🐾 SCAN PETS DEL TEAM", 325)
        local autoClickBtn = mkBtn("🖱️ AUTO CLICK NEAREST: OFF", 360)

        local rewardBtn = Instance.new("TextButton")
        rewardBtn.Size = UDim2.new(0.44, 0, 0, 26)
        rewardBtn.Position = UDim2.new(0.04, 0, 0, 395)
        rewardBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 80)
        rewardBtn.TextColor3 = Color3.new(1, 1, 1)
        rewardBtn.Font = Enum.Font.GothamSemibold
        rewardBtn.TextSize = 11
        rewardBtn.Text = "🎁 WATCH REWARDS"
        rewardBtn.Parent = frame

        local copyBtn = Instance.new("TextButton")
        copyBtn.Size = UDim2.new(0.44, 0, 0, 26)
        copyBtn.Position = UDim2.new(0.52, 0, 0, 395)
        copyBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 80)
        copyBtn.TextColor3 = Color3.new(1, 1, 1)
        copyBtn.Font = Enum.Font.GothamSemibold
        copyBtn.TextSize = 11
        copyBtn.Text = "📋 COPIAR LOG"
        copyBtn.Parent = frame

        local burstBtn = Instance.new("TextButton")
        burstBtn.Size = UDim2.new(0.44, 0, 0, 26)
        burstBtn.Position = UDim2.new(0.04, 0, 0, 430)
        burstBtn.BackgroundColor3 = Color3.fromRGB(95, 55, 35)
        burstBtn.TextColor3 = Color3.new(1, 1, 1)
        burstBtn.Font = Enum.Font.GothamSemibold
        burstBtn.TextSize = 11
        burstBtn.Text = "💥 BURST TEST x10"
        burstBtn.Parent = frame

        local loopBtn = Instance.new("TextButton")
        loopBtn.Size = UDim2.new(0.44, 0, 0, 26)
        loopBtn.Position = UDim2.new(0.52, 0, 0, 430)
        loopBtn.BackgroundColor3 = Color3.fromRGB(65, 45, 85)
        loopBtn.TextColor3 = Color3.new(1, 1, 1)
        loopBtn.Font = Enum.Font.GothamSemibold
        loopBtn.TextSize = 11
        loopBtn.Text = "🔥 BURST LOOP: OFF"
        loopBtn.Parent = frame

        hookBtn.MouseButton1Click:Connect(hookModules)
        scanMonsterBtn.MouseButton1Click:Connect(scanNearestMonster)
        scanPetsBtn.MouseButton1Click:Connect(scanPets)
        autoClickBtn.MouseButton1Click:Connect(function()
            toggleAutoClick(autoClickBtn)
        end)
        rewardBtn.MouseButton1Click:Connect(installRewardWatch)
        burstBtn.MouseButton1Click:Connect(function()
            runBurstTest(10)
        end)
        loopBtn.MouseButton1Click:Connect(function()
            State.burstLoop = not State.burstLoop
            loopBtn.BackgroundColor3 = State.burstLoop and Color3.fromRGB(180, 70, 70) or Color3.fromRGB(65, 45, 85)
            loopBtn.Text = State.burstLoop and "🛑 BURST LOOP: ON" or "🔥 BURST LOOP: OFF"
            addLog(State.burstLoop and "Burst loop ON" or "Burst loop OFF", Color3.fromRGB(255, 180, 200))
        end)
        copyBtn.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(table.concat(State.log, "\n"))
                addLog("Log copiado", Color3.fromRGB(120, 255, 160))
            else
                addLog("setclipboard no disponible", Color3.fromRGB(255, 120, 120))
            end
        end)

        State.ui = {
            screen = sg,
            frame = frame,
            fileLabel = fileLabel,
            logFrame = logFrame,
            list = list,
            autoClickBtn = autoClickBtn,
            burstBtn = burstBtn,
            loopBtn = loopBtn
        }
    end

    local function installLoops()
        task.spawn(function()
            while State.active do
                if State.autoClick then
                    local detector, monster, dist = findNearestClickable()
                    if detector and fireclickdetector then
                        pcall(function()
                            fireclickdetector(detector)
                        end)
                        addLog("Click -> " .. tostring(monster and monster.Name or "?") .. " @ " .. tostring(math.floor(dist or 0)), Color3.fromRGB(255, 200, 130))
                    end
                end
                task.wait(1.5)
            end
        end)

        task.spawn(function()
            while State.active do
                if State.burstLoop then
                    runBurstTest(5)
                end
                task.wait(1)
            end
        end)

        task.spawn(function()
            while State.active do
                local monster = findNearestMonster()
                local nearest = monster and monster.Name or nil
                if nearest and nearest ~= State.lastNearestMonsterId then
                    State.lastNearestMonsterId = nearest
                    addLog("Nearest monster -> " .. nearest, Color3.fromRGB(160, 220, 255))
                end
                task.wait(1)
            end
        end)
    end

    function State.stop()
        State.active = false
        if State.rewardConn then
            State.rewardConn:Disconnect()
            State.rewardConn = nil
        end
        clearFightWatch()
        if State.ui.screen then
            State.ui.screen:Destroy()
        end
        rawset(_G, "CAMInjectorV10", nil)
    end

    buildGui()
    ensureLogFile()
    if State.ui.fileLabel then
        State.ui.fileLabel.Text = "TXT: " .. tostring(State.fileName or "writefile no disponible")
    end
    addLog("GUI lista", Color3.fromRGB(120, 255, 160))
    addLog("Usa HOOK MODULES primero", Color3.fromRGB(220, 220, 120))
    addLog("TXT -> " .. tostring(State.fileName or "writefile no disponible"), Color3.fromRGB(160, 220, 255))
    installFightWatch()
    installLoops()
end)

if not success then
    pcall(function()
        local Players = game:GetService("Players")
        local LP = Players.LocalPlayer
        local sg = Instance.new("ScreenGui")
        sg.Name = "CAM_ErrorGui"
        sg.Parent = LP:WaitForChild("PlayerGui")

        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(110, 0, 0)
        bg.Parent = sg

        local msg = Instance.new("TextLabel")
        msg.Size = UDim2.new(0.84, 0, 0.84, 0)
        msg.Position = UDim2.new(0.08, 0, 0.08, 0)
        msg.BackgroundTransparency = 1
        msg.TextColor3 = Color3.new(1, 1, 1)
        msg.TextWrapped = true
        msg.TextScaled = true
        msg.Font = Enum.Font.Code
        msg.Text = "ERROR AL CARGAR CAM_Injector_V10.lua\n\n" .. tostring(errorMessage)
        msg.Parent = bg
    end)
end
