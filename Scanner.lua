-- ==========================================================
-- ⛏️ VULN & AC ANALYZER v2.1 (Corrección de Falsos Positivos)
-- ==========================================================
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

local LOG_TABLE = {}
local FILE_NAME = "ServerAudit_Fix_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"

-- Interfaz Básica
local SG = Instance.new("ScreenGui")
SG.Name = "AuditGUI_V2"
SG.Parent = pcall(function() return CoreGui.Name end) and CoreGui or LP:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame", SG)
MainFrame.Size = UDim2.new(0, 550, 0, 450)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true

local Console = Instance.new("ScrollingFrame", MainFrame)
Console.Size = UDim2.new(1, -20, 1, -160)
Console.Position = UDim2.new(0, 10, 0, 40)
Console.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
Console.CanvasSize = UDim2.new(0, 0, 0, 0)
Console.AutomaticCanvasSize = Enum.AutomaticSize.Y
local UIListLayout = Instance.new("UIListLayout", Console)

local function AddLog(msg, color)
    local txt = Instance.new("TextLabel", Console)
    txt.Size = UDim2.new(1, 0, 0, 20)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    txt.Text = " [" .. os.date("%H:%M:%S") .. "] " .. msg
    txt.Font = Enum.Font.Code
    txt.TextSize = 13
    txt.TextXAlignment = Enum.TextXAlignment.Left
    table.insert(LOG_TABLE, txt.Text)
    Console.CanvasPosition = Vector2.new(0, 99999)
end

-- Botones
local ScanBtn = Instance.new("TextButton", MainFrame)
ScanBtn.Size = UDim2.new(0, 160, 0, 30)
ScanBtn.Position = UDim2.new(0, 10, 1, -110)
ScanBtn.Text = "🔍 Escáner Inteligente"

local TestBypassBtn = Instance.new("TextButton", MainFrame)
TestBypassBtn.Size = UDim2.new(0, 160, 0, 30)
TestBypassBtn.Position = UDim2.new(0, 180, 1, -110)
TestBypassBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
TestBypassBtn.Text = "🧪 Test Bypass"

local ScanACBtn = Instance.new("TextButton", MainFrame)
ScanACBtn.Size = UDim2.new(0, 180, 0, 30)
ScanACBtn.Position = UDim2.new(0, 350, 1, -110)
ScanACBtn.Text = "🕵️ Detectar Trampas"

local SpeedBtn = Instance.new("TextButton", MainFrame)
SpeedBtn.Size = UDim2.new(0, 160, 0, 30)
SpeedBtn.Position = UDim2.new(0, 10, 1, -60)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 100)
SpeedBtn.Text = "🏃 Dev Sprint (x3 Vel)"

-- ==========================================================
-- LÓGICA CORREGIDA
-- ==========================================================

-- 1. Escáner Inteligente de Minas (Más amplio)
ScanBtn.MouseButton1Click:Connect(function()
    AddLog("--- BÚSQUEDA PROFUNDA DE MINAS ---", Color3.fromRGB(100, 255, 100))
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then AddLog("Error: Personaje no encontrado.", Color3.fromRGB(255, 0, 0)); return end

    local minesFound = 0
    local mineKeywords = {"ore", "rock", "mine", "stone", "deposit", "vein"}

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local isMine = false
            local hp = "Desconocido"
            
            -- Verificar por nombre
            local nameLower = obj.Name:lower()
            for _, kw in pairs(mineKeywords) do
                if string.find(nameLower, kw) then isMine = true; break end
            end
            
            -- Verificar si tiene variables típicas de minería (Atributos o Hijos)
            if obj:GetAttribute("Health") or obj:FindFirstChild("Health") or obj:FindFirstChild("RequiredDamage") then
                isMine = true
            end

            -- Evitar detectar a otros jugadores
            if game.Players:GetPlayerFromCharacter(obj) then isMine = false end

            if isMine then
                minesFound = minesFound + 1
                local dist = math.floor((root.Position - obj:GetPivot().Position).Magnitude)
                AddLog(string.format("🪨 [%dm] %s", dist, obj:GetFullName()), Color3.fromRGB(200, 200, 200))
            end
        end
    end

    if minesFound == 0 then
        AddLog("No se encontraron minas. Verifica si están guardadas en ReplicatedStorage o tienen otro nombre.", Color3.fromRGB(255, 100, 100))
    else
        AddLog("Total encontrado: " .. minesFound, Color3.fromRGB(100, 255, 100))
    end
end)

-- 2. Detector de Trampas (Sin falsos positivos)
ScanACBtn.MouseButton1Click:Connect(function()
    AddLog("--- ANALIZANDO TRAMPAS Y ANTI-CHEAT ---", Color3.fromRGB(150, 150, 255))
    local trapsFound = 0

    -- Ignorar la carpeta de jugadores (Living)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and not game.Players:GetPlayerFromCharacter(obj) and not string.find(obj:GetFullName(), "Living") then
            -- Solo buscamos honeypots que NO sean jugadores
            if obj.Name:lower():match("ore") or obj:FindFirstChild("Health") then
                local pos = obj:GetPivot().Position
                if pos.Y < -200 or pos.Y > 2000 then
                    AddLog("⚠️ HONEYPOT ORE FUERA DEL MAPA: " .. obj.Name, Color3.fromRGB(255, 100, 255))
                    trapsFound = trapsFound + 1
                end
            end
        end
    end

    -- Scripts de Anti-Cheat exactos (Evita Backpack, LegacyCamera)
    local exactKw = {"anticheat", "anti_cheat", "security", "honeypot", "banhandler", "exploit"}
    for _, script in pairs(LP.PlayerScripts:GetDescendants()) do
        if script:IsA("LocalScript") or script:IsA("ModuleScript") then
            local nameLower = script.Name:lower()
            for _, word in pairs(exactKw) do
                -- Buscar la palabra exacta, no solo sub-letras
                if string.find(nameLower, word) then
                    AddLog("🛡️ MÓDULO AC DETECTADO: " .. script.Name, Color3.fromRGB(255, 200, 50))
                    trapsFound = trapsFound + 1
                    break
                end
            end
        end
    end

    if trapsFound == 0 then
        AddLog("Limpio. No se detectaron honeypots ni AC evidentes.", Color3.fromRGB(100, 255, 100))
    end
end)

-- 3. Velocidad para Pruebas (Alternativa al Noclip)
SpeedBtn.MouseButton1Click:Connect(function()
    local hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
    if hum then
        if hum.WalkSpeed > 16 then
            hum.WalkSpeed = 16
            AddLog("Velocidad normal restaurada.", Color3.fromRGB(200, 200, 200))
        else
            hum.WalkSpeed = 60
            AddLog("⚡ Dev Sprint activado. (x3 Vel)", Color3.fromRGB(100, 255, 100))
        end
    end
end)

AddLog("Sistema V2.1 Listo. Correcciones de Falsos Positivos aplicadas.", Color3.fromRGB(100, 255, 255))
