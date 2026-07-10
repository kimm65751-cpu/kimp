-- EVOMON SCANNER - Estructura IDENTICA al script original que SI funciona
-- Usa el mismo writeLog/appendfile que ya demostro funcionar

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local fileName = "EvomonQA_ScanData.txt"

-- IDENTICO AL ORIGINAL - esto es lo que funciona
if writefile then pcall(function() writefile(fileName, "=== EVOMON SCANNER INICIADO: " .. os.date("%H:%M:%S") .. " ===\n") end) end

local function writeLog(msg)
    local fullMsg = "[" .. os.date("%H:%M:%S") .. "] " .. msg
    print("[SCAN] " .. fullMsg)
    if appendfile then
        pcall(function() appendfile(fileName, fullMsg .. "\n") end)
    elseif writefile and isfile then
        pcall(function()
            local current = isfile(fileName) and readfile(fileName) or ""
            writefile(fileName, current .. fullMsg .. "\n")
        end)
    end
end

-- GUI - igual que el original
local SG = Instance.new("ScreenGui")
SG.Name = "EvoScanGui"
SG.ResetOnSpawn = false
if pcall(function() SG.Parent = CoreGui end) then else SG.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 200)
MainFrame.Position = UDim2.new(0, 10, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = SG
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Title.BackgroundTransparency = 0
Title.Text = "EVOMON SCANNER -> " .. fileName
Title.TextColor3 = Color3.fromRGB(100, 220, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 11
Title.BorderSizePixel = 0
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

local BtnContainer = Instance.new("Frame")
BtnContainer.Size = UDim2.new(1, -10, 1, -35)
BtnContainer.Position = UDim2.new(0, 5, 0, 33)
BtnContainer.BackgroundTransparency = 1
BtnContainer.Parent = MainFrame
local layout = Instance.new("UIListLayout", BtnContainer)
layout.Padding = UDim.new(0, 4)

local StatusLbl = Instance.new("TextLabel")
StatusLbl.Size = UDim2.new(1, 0, 0, 20)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text = "Listo. Presiona un boton."
StatusLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLbl.Font = Enum.Font.Code
StatusLbl.TextSize = 10
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
StatusLbl.Parent = BtnContainer

local function mkBtn(txt, r, g, b)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(r, g, b)
    btn.Text = txt
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    btn.Parent = BtnContainer
    return btn
end

local BtnScanNPC    = mkBtn("1. ESCANEAR NPCs/EVOMONS", 41, 128, 185)
local BtnScanBtns   = mkBtn("2. ESCANEAR BOTONES GUI", 142, 68, 173)
local BtnScanRemote = mkBtn("3. ESCANEAR REMOTEEVENTS", 192, 57, 43)
local BtnScanPP     = mkBtn("4. ESCANEAR PROXIMITYPROMPTS", 39, 174, 96)

writeLog("Script cargado OK - archivo creado")

-- =====================================================
-- BOTON 1: NPCs
-- =====================================================
BtnScanNPC.MouseButton1Click:Connect(function()
    BtnScanNPC.Text = "Escaneando..."
    StatusLbl.Text = "Buscando NPCs..."
    writeLog("=== SCAN: NPCs EN WORKSPACE ===")

    local playerNames = {}
    pcall(function()
        for _, p in ipairs(Players:GetPlayers()) do
            playerNames[p.Name] = true
            writeLog("JUGADOR_FILTRADO|" .. p.Name)
        end
    end)

    local count = 0
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and not playerNames[obj.Name] then
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                local hum = obj:FindFirstChildOfClass("Humanoid")
                if hrp and hum then
                    local dist = -1
                    pcall(function()
                        local c = LocalPlayer.Character
                        if c and c:FindFirstChild("HumanoidRootPart") then
                            dist = math.floor((hrp.Position - c.HumanoidRootPart.Position).Magnitude)
                        end
                    end)
                    writeLog("NPC|" .. obj.Name .. "|dist=" .. dist .. "|path=" .. obj:GetFullName())
                    count += 1
                    task.wait(0)
                end
            end
        end
    end)

    writeLog("TOTAL_NPCS=" .. count)
    BtnScanNPC.Text = "1. ESCANEAR NPCs/EVOMONS"
    BtnScanNPC.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
    StatusLbl.Text = "NPCs escritos: " .. count .. " -> " .. fileName
end)

-- =====================================================
-- BOTON 2: Botones GUI
-- =====================================================
BtnScanBtns.MouseButton1Click:Connect(function()
    BtnScanBtns.Text = "Escaneando..."
    StatusLbl.Text = "Buscando botones..."
    writeLog("=== SCAN: BOTONES EN PLAYERGUI ===")

    pcall(function()
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if pg then
            local count = 0
            for _, obj in ipairs(pg:GetDescendants()) do
                if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                    local vis = obj.Visible and "VIS" or "HID"
                    local txt = ""
                    pcall(function() if obj:IsA("TextButton") then txt = obj.Text end end)
                    writeLog("BTN|" .. vis .. "|" .. obj.Name .. "|" .. txt .. "|" .. obj:GetFullName())
                    count += 1
                    task.wait(0)
                end
            end
            writeLog("TOTAL_BTNS=" .. count)
            StatusLbl.Text = "Botones escritos: " .. count .. " -> " .. fileName
        else
            writeLog("ERROR: PlayerGui no encontrado")
            StatusLbl.Text = "ERROR: Sin PlayerGui"
        end
    end)

    BtnScanBtns.Text = "2. ESCANEAR BOTONES GUI"
    BtnScanBtns.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
end)

-- =====================================================
-- BOTON 3: RemoteEvents
-- =====================================================
BtnScanRemote.MouseButton1Click:Connect(function()
    BtnScanRemote.Text = "Escaneando..."
    StatusLbl.Text = "Buscando RemoteEvents..."
    writeLog("=== SCAN: REMOTEEVENTS EN RS ===")

    pcall(function()
        local count = 0
        local kw = {"battle","catch","escape","flee","pity","summon","monster",
                    "capture","operate","enter","settle","result","wild","npc"}
        for _, obj in ipairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local low = string.lower(obj.Name)
                for _, k in ipairs(kw) do
                    if string.find(low, k) then
                        writeLog("REMOTE|" .. obj.ClassName .. "|" .. obj.Name .. "|" .. obj:GetFullName())
                        count += 1
                        task.wait(0)
                        break
                    end
                end
            end
        end
        writeLog("TOTAL_REMOTES=" .. count)
        StatusLbl.Text = "Remotes escritos: " .. count .. " -> " .. fileName
    end)

    BtnScanRemote.Text = "3. ESCANEAR REMOTEEVENTS"
    BtnScanRemote.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
end)

-- =====================================================
-- BOTON 4: ProximityPrompts
-- =====================================================
BtnScanPP.MouseButton1Click:Connect(function()
    BtnScanPP.Text = "Escaneando..."
    StatusLbl.Text = "Buscando ProximityPrompts..."
    writeLog("=== SCAN: PROXIMITYPROMPTS ===")

    pcall(function()
        local count = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                writeLog("PP|" .. obj.ActionText .. "|enabled=" .. tostring(obj.Enabled) .. "|" .. obj:GetFullName())
                count += 1
                task.wait(0)
            end
        end
        -- Valores del jugador tambien
        writeLog("=== SCAN: VALORES DEL JUGADOR ===")
        local function scanVals(folder, prefix)
            for _, v in ipairs(folder:GetChildren()) do
                if v:IsA("ValueBase") then
                    writeLog("VAL|" .. prefix .. v.Name .. "=" .. tostring(v.Value))
                elseif v:IsA("Folder") then
                    scanVals(v, prefix .. v.Name .. "/")
                end
            end
        end
        scanVals(LocalPlayer, "")
        writeLog("TOTAL_PP=" .. count)
        StatusLbl.Text = "PP escritos: " .. count .. " -> " .. fileName
    end)

    BtnScanPP.Text = "4. ESCANEAR PROXIMITYPROMPTS"
    BtnScanPP.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
end)
