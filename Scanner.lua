-- Evomon QA Scanner - Versión Unificada (Single Script)
-- Funciona en Roblox Studio y en Ejecutores Externos
-- Soporta escritura en tiempo real (.txt) para evitar pérdida por crasheos.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- ==========================================
-- SISTEMA DE ARCHIVOS (ANTI-CRASH)
-- ==========================================
-- Si el juego crashea, todo lo registrado hasta el momento ya estará en el .txt
local fileName = "EvomonQA_LiveReport.txt"

-- Inicializar archivo
if writefile then
    pcall(function() writefile(fileName, "=== EVOMON QA REPORT - INICIADO ===\n") end)
end

local function writeLog(level, msg)
    local timeStr = os.date("%H:%M:%S")
    local fullMsg = string.format("[%s] [%s] %s", timeStr, level, msg)
    
    print("[EvomonQA] " .. fullMsg)
    
    -- Escribir en tiempo real en el disco (Soporte para Ejecutores)
    if appendfile then
        pcall(function() appendfile(fileName, fullMsg .. "\n") end)
    elseif writefile and isfile then
        pcall(function()
            local current = ""
            if isfile(fileName) then
                current = readfile(fileName)
            end
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

-- Intentar proteger la UI poniéndola en CoreGui (si hay permisos)
if pcall(function() SG.Parent = CoreGui end) then
    -- Injector mode
else
    SG.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 300)
MainFrame.Position = UDim2.new(1, -470, 1, -320)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = SG

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = " Evomon QA Scanner (Unificado)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local BtnContainer = Instance.new("Frame")
BtnContainer.Size = UDim2.new(0, 120, 1, -50)
BtnContainer.Position = UDim2.new(0, 10, 0, 40)
BtnContainer.BackgroundTransparency = 1
BtnContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = BtnContainer

local function createButton(name, text, color)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    btn.Parent = BtnContainer
    return btn
end

local BtnScan = createButton("BtnScan", "SCAN GENERAL", Color3.fromRGB(41, 128, 185))
local BtnLive = createButton("BtnLive", "LIVE MONITOR", Color3.fromRGB(39, 174, 96))
local BtnStop = createButton("BtnStop", "STOP", Color3.fromRGB(192, 57, 43))
local BtnHide = createButton("BtnHide", "MINIMIZAR", Color3.fromRGB(142, 68, 173))

local ConsoleBox = Instance.new("ScrollingFrame")
ConsoleBox.Size = UDim2.new(1, -150, 1, -60)
ConsoleBox.Position = UDim2.new(0, 140, 0, 40)
ConsoleBox.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
ConsoleBox.BorderSizePixel = 0
ConsoleBox.ScrollBarThickness = 4
ConsoleBox.Parent = MainFrame

local ConsoleLayout = Instance.new("UIListLayout")
ConsoleLayout.SortOrder = Enum.SortOrder.LayoutOrder
ConsoleLayout.Parent = ConsoleBox

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
    
    -- Escribir al .txt físico en tiempo real
    writeLog(level, msg)
end

-- ==========================================
-- ANALIZADORES
-- ==========================================
local function AnalyzeEvomon(obj)
    local name = string.lower(obj.Name)
    if string.find(name, "capture") or string.find(name, "pokeball") then printUI("INFO", "Sistema de Captura: " .. obj.Name) end
    if string.find(name, "battle") or string.find(name, "combat") then printUI("INFO", "Sistema de Batalla: " .. obj.Name) end
    if string.find(name, "evomon") or string.find(name, "monster") then printUI("INFO", "Dato de Criatura: " .. obj.Name) end
    if string.find(name, "inventory") or string.find(name, "item") then printUI("INFO", "Sistema de Inventario: " .. obj.Name) end
end

local function AnalyzeSecurity(obj)
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        if not obj:IsDescendantOf(ReplicatedStorage) then
            printUI("WARNING", "RemoteObject fuera de ReplicatedStorage: " .. obj:GetFullName())
        end
        local name = string.lower(obj.Name)
        if string.find(name, "admin") or string.find(name, "money") then
            printUI("CRITICAL", "Remote sensible detectado: " .. obj:GetFullName())
        end
    end
end

local function RunScanner()
    printUI("INFO", "INICIANDO ESCANEO PROFUNDO...")
    local objectsScanned = 0
    local function scan(parent)
        for _, obj in ipairs(parent:GetChildren()) do
            objectsScanned += 1
            if objectsScanned % 500 == 0 then task.wait() end -- Anti-lag
            
            if obj:IsA("Script") or obj:IsA("LocalScript") then
                if obj.Disabled then printUI("WARNING", "Script Deshabilitado: " .. obj:GetFullName()) end
            elseif obj:IsA("ObjectValue") and obj.Value == nil then
                printUI("WARNING", "Referencia Rota en: " .. obj:GetFullName())
            end
            
            AnalyzeEvomon(obj)
            AnalyzeSecurity(obj)
            scan(obj)
        end
    end
    
    local targets = {workspace, ReplicatedStorage}
    for _, t in ipairs(targets) do scan(t) end
    printUI("INFO", "ESCANEO FINALIZADO. (" .. objectsScanned .. " objetos)")
end

-- ==========================================
-- LIVE MONITOR
-- ==========================================
local liveConnections = {}
local isLive = false

local function StartLive()
    isLive = true
    BtnLive.Text = "LIVE: ON"
    BtnLive.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    printUI("LIVE", "--- LIVE MONITOR ACTIVADO ---")
    
    -- Monitorear Interfaz de Usuario
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    table.insert(liveConnections, pg.ChildAdded:Connect(function(ui)
        printUI("LIVE", "[GUI] Abrió interfaz: " .. ui.Name)
    end))
    table.insert(liveConnections, pg.ChildRemoved:Connect(function(ui)
        printUI("LIVE", "[GUI] Cerró interfaz: " .. ui.Name)
    end))
    
    -- Monitorear Mochila (Inventario)
    local bp = LocalPlayer:WaitForChild("Backpack", 5)
    if bp then
        table.insert(liveConnections, bp.ChildAdded:Connect(function(item)
            printUI("LIVE", "[INVENTARIO] Agregó item: " .. item.Name)
        end))
        table.insert(liveConnections, bp.ChildRemoved:Connect(function(item)
            printUI("LIVE", "[INVENTARIO] Removió item: " .. item.Name)
        end))
    end
    
    -- Monitorear Movimiento y Teleport
    if LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local lastPos = hrp.Position
            local t = task.spawn(function()
                while task.wait(1) do
                    if not hrp or not hrp.Parent then break end
                    local dist = (hrp.Position - lastPos).Magnitude
                    if dist > 30 then
                        printUI("LIVE", "[MAPA] Teleport o velocidad extrema detectada (" .. math.floor(dist) .. " studs)")
                    end
                    lastPos = hrp.Position
                end
            end)
            table.insert(liveConnections, t)
        end
    end
end

local function StopLive()
    isLive = false
    BtnLive.Text = "LIVE MONITOR"
    BtnLive.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
    printUI("INFO", "--- LIVE MONITOR DETENIDO ---")
    
    for _, conn in ipairs(liveConnections) do
        if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
        if type(conn) == "thread" then task.cancel(conn) end
    end
    liveConnections = {}
end

-- ==========================================
-- BOTONES
-- ==========================================
BtnScan.MouseButton1Click:Connect(function()
    task.spawn(RunScanner)
end)

BtnLive.MouseButton1Click:Connect(function()
    if isLive then StopLive() else StartLive() end
end)

BtnStop.MouseButton1Click:Connect(function()
    StopLive()
end)

local hidden = false
BtnHide.MouseButton1Click:Connect(function()
    hidden = not hidden
    BtnContainer.Visible = not hidden
    ConsoleBox.Visible = not hidden
    MainFrame.Size = hidden and UDim2.new(0, 120, 0, 40) or UDim2.new(0, 450, 0, 300)
    BtnHide.Text = hidden and "MAXIMIZAR" or "MINIMIZAR"
end)

printUI("INFO", "Herramienta Inyectada con éxito. Listo para operar.")
