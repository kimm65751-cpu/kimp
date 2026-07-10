-- Evomon QA - Versión 2.0 (Enfoque en Caminata Humana, Pity, y Anti-Honeypots)
-- Guarda registros en tiempo real en "EvomonQA_LiveReport.txt"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local fileName = "EvomonQA_LiveReport.txt"

-- ==========================================
-- SISTEMA DE ARCHIVOS (ANTI-CRASH)
-- ==========================================
if writefile then pcall(function() writefile(fileName, "=== EVOMON QA v2 INICIADO ===\n") end) end

local function writeLog(level, msg)
    local timeStr = os.date("%H:%M:%S")
    local fullMsg = string.format("[%s] [%s] %s", timeStr, level, msg)
    print("[EvomonQA] " .. fullMsg)
    
    if appendfile then
        pcall(function() appendfile(fileName, fullMsg .. "\n") end)
    elseif writefile and isfile then
        pcall(function()
            local current = isfile(fileName) and readfile(fileName) or ""
            writefile(fileName, current .. fullMsg .. "\n")
        end)
    end
end

-- ==========================================
-- INTERFAZ GRÁFICA (UI BUILDER)
-- ==========================================
local SG = Instance.new("ScreenGui")
SG.Name = "EvomonQAGui"
SG.ResetOnSpawn = false
if pcall(function() SG.Parent = CoreGui end) then else SG.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 350)
MainFrame.Position = UDim2.new(1, -470, 1, -370)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = SG
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = " Evomon QA: Auto-Farm Seguro"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local BtnContainer = Instance.new("Frame")
BtnContainer.Size = UDim2.new(0, 140, 1, -50)
BtnContainer.Position = UDim2.new(0, 10, 0, 40)
BtnContainer.BackgroundTransparency = 1
BtnContainer.Parent = MainFrame
Instance.new("UIListLayout", BtnContainer).Padding = UDim.new(0, 5)

local function createBtn(text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.Parent = BtnContainer
    return btn
end

local BtnScanSecurity = createBtn("1. ESCANEAR HONEYPOTS", Color3.fromRGB(192, 57, 43))
local BtnFindEvomon = createBtn("2. CAMINAR A EVOMON", Color3.fromRGB(41, 128, 185))
local BtnCapture = createBtn("3. INTENTAR CAPTURA", Color3.fromRGB(39, 174, 96))
local BtnFlee = createBtn("4. HUIR (FLEE)", Color3.fromRGB(243, 156, 18))
local BtnPity = createBtn("RASTREAR PITY RATE", Color3.fromRGB(142, 68, 173))
local BtnHide = createBtn("MINIMIZAR", Color3.fromRGB(52, 73, 94))

local ConsoleBox = Instance.new("ScrollingFrame")
ConsoleBox.Size = UDim2.new(1, -160, 1, -60)
ConsoleBox.Position = UDim2.new(0, 150, 0, 40)
ConsoleBox.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
ConsoleBox.BorderSizePixel = 0
ConsoleBox.ScrollBarThickness = 4
ConsoleBox.Parent = MainFrame
Instance.new("UIListLayout", ConsoleBox).SortOrder = Enum.SortOrder.LayoutOrder

local logCount = 0
local function printUI(level, msg)
    logCount += 1
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = msg
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    if level == "CRITICAL" then lbl.TextColor3 = Color3.fromRGB(255, 100, 100)
    elseif level == "WARNING" then lbl.TextColor3 = Color3.fromRGB(255, 200, 100)
    elseif level == "LIVE" then lbl.TextColor3 = Color3.fromRGB(150, 255, 150)
    else lbl.TextColor3 = Color3.fromRGB(200, 200, 200) end
    
    lbl.Parent = ConsoleBox
    ConsoleBox.CanvasSize = UDim2.new(0, 0, 0, logCount * 16)
    ConsoleBox.CanvasPosition = Vector2.new(0, logCount * 16)
    
    writeLog(level, msg)
end

-- ==========================================
-- 🛡️ ESCÁNER DE HONEYPOTS / ANTI-CHEAT
-- ==========================================
BtnScanSecurity.MouseButton1Click:Connect(function()
    printUI("INFO", "--- ESCANEANDO TRAMPAS Y SEGURIDAD ---")
    local dangerWords = {"ban", "kick", "anticheat", "loghack", "exploit", "speedhack", "teleport", "detect"}
    local flags = 0
    
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("Script") or obj:IsA("LocalScript") then
            local name = string.lower(obj.Name)
            for _, word in ipairs(dangerWords) do
                if string.find(name, word) then
                    flags += 1
                    printUI("CRITICAL", "[ALERTA] Posible Anti-Cheat: " .. obj:GetFullName())
                    break
                end
            end
        end
    end
    printUI("INFO", "Escaneo finalizado. Trampas detectadas: " .. flags)
end)

-- ==========================================
-- 🚶 CAMINATA HUMANA (SIN TELEPORT)
-- ==========================================
local isWalking = false
BtnFindEvomon.MouseButton1Click:Connect(function()
    if isWalking then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Humanoid") then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char.Humanoid
    
    local nearest = nil
    local minDist = 999999
    
    -- Buscar monstruos basado en los nombres vistos en el log
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and (string.find(obj.Name, "Monster") or string.find(obj.Name, "Npc")) then
            if obj:FindFirstChild("HumanoidRootPart") then
                local dist = (obj.HumanoidRootPart.Position - hrp.Position).Magnitude
                -- Ignorar si está demasiado lejos o es el propio jugador
                if dist > 5 and dist < minDist and dist < 1500 and obj.Name ~= LocalPlayer.Name then
                    minDist = dist
                    nearest = obj
                end
            end
        end
    end
    
    if nearest then
        isWalking = true
        printUI("LIVE", "Caminando humanamente hacia: " .. nearest.Name .. " (Dist: " .. math.floor(minDist) .. ")")
        humanoid:MoveTo(nearest.HumanoidRootPart.Position)
        
        -- Esperar a que llegue
        local moveConn
        moveConn = humanoid.MoveToFinished:Connect(function(reached)
            isWalking = false
            moveConn:Disconnect()
            if reached then
                printUI("LIVE", "¡Llegamos al Evomon!")
            else
                printUI("WARNING", "Camino bloqueado o no se pudo llegar.")
            end
        end)
    else
        printUI("WARNING", "No se encontraron Evomons cercanos.")
    end
end)

-- ==========================================
-- 🎯 LÓGICA DE BATALLA (CAPTURA Y HUIDA)
-- ==========================================
-- La batalla es automática como mencionaste, pero forzaremos los clics en la interfaz para Capturar o Huir
local function ClickButtonByName(btnName)
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local found = false
    for _, obj in pairs(pg:GetDescendants()) do
        if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and string.find(string.lower(obj.Name), string.lower(btnName)) then
            if obj.Visible and obj.AbsolutePosition.X > 0 then -- Solo clickear si está en pantalla
                -- Simulamos el Fire de los eventos de Roblox UI
                pcall(function()
                    -- Hay juegos que usan eventos propios o Active
                    if getinstances then
                        for _, connection in pairs(getconnections(obj.MouseButton1Click)) do
                            connection:Function()
                        end
                    end
                end)
                printUI("INFO", "[BATALLA] Se presionó: " .. obj.Name)
                found = true
            end
        end
    end
    if not found then printUI("WARNING", "No se encontró el botón: " .. btnName .. " en pantalla.") end
end

BtnCapture.MouseButton1Click:Connect(function()
    printUI("LIVE", "Intentando seleccionar Pokebola...")
    -- Nombres basados en el log del escáner: "BattleCatchOption1", "BattleCatchConfirm", "Ball1CaptureEffect"
    -- Primero abrimos el menú de captura
    ClickButtonByName("Catch")
    task.wait(0.5)
    -- Seleccionamos la bola 1 (la básica)
    ClickButtonByName("Option1") 
    task.wait(0.5)
    -- Confirmamos
    ClickButtonByName("Confirm")
end)

BtnFlee.MouseButton1Click:Connect(function()
    printUI("LIVE", "Intentando Huir de la Batalla...")
    -- Nombre basado en el log del escáner: "BattleEscape"
    ClickButtonByName("Escape")
    task.wait(0.5)
    ClickButtonByName("Confirm") -- Por si pide confirmación
end)

-- ==========================================
-- 🌟 RASTREADOR DE PITY (OBTAIN RATE)
-- ==========================================
local trackingPity = false
BtnPity.MouseButton1Click:Connect(function()
    if trackingPity then return end
    trackingPity = true
    BtnPity.Text = "PITY TRACKER: ON"
    BtnPity.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    printUI("INFO", "--- MONITOREO DE PITY ACTIVADO ---")
    
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Función para revisar textos
    local function CheckText(text)
        local t = string.lower(text)
        if string.find(t, "prismatic:") or string.find(t, "shiny:") then
            printUI("LIVE", "[PITY RATE] " .. text)
        end
    end
    
    -- Escuchar todos los TextLabels actuales y futuros
    for _, obj in pairs(pg:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextBox") then
            CheckText(obj.Text)
            obj:GetPropertyChangedSignal("Text"):Connect(function() CheckText(obj.Text) end)
        end
    end
    
    pg.DescendantAdded:Connect(function(obj)
        if obj:IsA("TextLabel") or obj:IsA("TextBox") then
            obj:GetPropertyChangedSignal("Text"):Connect(function() CheckText(obj.Text) end)
        end
    end)
end)

-- Botón Minimizar
local hidden = false
BtnHide.MouseButton1Click:Connect(function()
    hidden = not hidden
    BtnContainer.Visible = not hidden
    ConsoleBox.Visible = not hidden
    MainFrame.Size = hidden and UDim2.new(0, 140, 0, 40) or UDim2.new(0, 450, 0, 350)
    BtnHide.Text = hidden and "MAXIMIZAR" or "MINIMIZAR"
end)

printUI("INFO", "Herramienta V2 Inyectada. Listo para pruebas seguras.")
