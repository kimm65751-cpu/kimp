-- ==========================================================
-- ⛏️ VULN & AC ANALYZER v2.0 (Localhost Penetration Testing)
-- ==========================================================
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

local LOG_TABLE = {}
local FILE_NAME = "ServerAudit_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"

-- ==========================================================
-- 1. CREACIÓN DE LA INTERFAZ (Consola Negra)
-- ==========================================================
local SG = Instance.new("ScreenGui")
SG.Name = "AuditGUI"
SG.Parent = pcall(function() return CoreGui.Name end) and CoreGui or LP:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame", SG)
MainFrame.Size = UDim2.new(0, 550, 0, 450)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = " 🛡️ Advanced Server Audit (PoC)"
Title.Font = Enum.Font.Code
Title.TextSize = 16

local Console = Instance.new("ScrollingFrame", MainFrame)
Console.Size = UDim2.new(1, -20, 1, -160)
Console.Position = UDim2.new(0, 10, 0, 40)
Console.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
Console.CanvasSize = UDim2.new(0, 0, 0, 0)
Console.AutomaticCanvasSize = Enum.AutomaticSize.Y
Console.ScrollBarThickness = 6

local UIListLayout = Instance.new("UIListLayout", Console)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

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

-- ==========================================================
-- 2. BOTONES DE ANÁLISIS
-- ==========================================================
-- Fila 1
local ScanBtn = Instance.new("TextButton", MainFrame)
ScanBtn.Size = UDim2.new(0, 160, 0, 30)
ScanBtn.Position = UDim2.new(0, 10, 1, -110)
ScanBtn.Text = "🔍 Escanear Minas"

local TestBypassBtn = Instance.new("TextButton", MainFrame)
TestBypassBtn.Size = UDim2.new(0, 160, 0, 30)
TestBypassBtn.Position = UDim2.new(0, 180, 1, -110)
TestBypassBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
TestBypassBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TestBypassBtn.Text = "🧪 Test Bypass (No Clic)"

local ScanACBtn = Instance.new("TextButton", MainFrame)
ScanACBtn.Size = UDim2.new(0, 180, 0, 30)
ScanACBtn.Position = UDim2.new(0, 350, 1, -110)
ScanACBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 150)
ScanACBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanACBtn.Text = "🕵️ Detectar Honeypots/AC"

-- Fila 2
local CopyBtn = Instance.new("TextButton", MainFrame)
CopyBtn.Size = UDim2.new(0, 120, 0, 30)
CopyBtn.Position = UDim2.new(0, 10, 1, -60)
CopyBtn.Text = "📋 Copiar Logs"

local SaveBtn = Instance.new("TextButton", MainFrame)
SaveBtn.Size = UDim2.new(0, 120, 0, 30)
SaveBtn.Position = UDim2.new(0, 140, 1, -60)
SaveBtn.Text = "💾 Guardar .txt"

-- ==========================================================
-- 3. LÓGICA DE FUNCIONES
-- ==========================================================

-- Función: Escanear Minas Cercanas
ScanBtn.MouseButton1Click:Connect(function()
    AddLog("--- ESCANEANDO MINAS ---", Color3.fromRGB(100, 255, 100))
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then AddLog("Error: Personaje no encontrado.", Color3.fromRGB(255, 0, 0)); return end

    local mines = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Health") and obj:FindFirstChild("RequiredDamage") then
            local dist = (root.Position - obj:GetPivot().Position).Magnitude
            table.insert(mines, {Name = obj.Name, HP = obj.Health.Value, ReqDmg = obj.RequiredDamage.Value, Dist = dist})
        end
    end

    table.sort(mines, function(a, b) return a.Dist < b.Dist end)
    for i=1, math.min(#mines, 10) do
        local m = mines[i]
        AddLog(string.format("[%dm] 🪨 %s | Vida: %d | ReqDaño: %d", m.Dist, m.Name, m.HP, m.ReqDmg), Color3.fromRGB(200, 200, 200))
    end
end)

-- Función: Test de Evasión de Daño (Bypass)
TestBypassBtn.MouseButton1Click:Connect(function()
    AddLog("--- INICIANDO TEST DE BYPASS ---", Color3.fromRGB(255, 100, 100))
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local closestMine, minDist = nil, math.huge
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Health") and obj:FindFirstChild("RequiredDamage") then
            local dist = (root.Position - obj:GetPivot().Position).Magnitude
            if dist < minDist then minDist = dist; closestMine = obj end
        end
    end

    if not closestMine then AddLog("No hay minas cerca.", Color3.fromRGB(255, 0, 0)); return end

    -- Buscar evento de minería en ReplicatedStorage
    local remote = nil
    for _, rem in pairs(ReplicatedStorage:GetDescendants()) do
        if rem:IsA("RemoteEvent") and (rem.Name:lower():match("mine") or rem.Name:lower():match("hit")) then
            remote = rem; break
        end
    end

    if not remote then AddLog("RemoteEvent de ataque no encontrado.", Color3.fromRGB(255, 0, 0)); return end

    local initialHP = closestMine.Health.Value
    AddLog(string.format("Atacando a nivel de red: %s (HP: %d)", closestMine.Name, initialHP), Color3.fromRGB(255, 150, 0))
    
    pcall(function() remote:FireServer(closestMine) end)
    task.wait(1)
    
    local currentHP = closestMine.Health.Value
    if currentHP < initialHP then
        AddLog("🚨 VULNERABLE: El servidor restó vida ("..initialHP.." -> "..currentHP..")", Color3.fromRGB(255, 50, 50))
    else
        AddLog("✅ SEGURO: El servidor bloqueó el paquete de ataque.", Color3.fromRGB(50, 255, 50))
    end
end)

-- Función: Detección de Honeypots y Anti-Cheat
ScanACBtn.MouseButton1Click:Connect(function()
    AddLog("--- ANALIZANDO TRAMPAS Y ANTI-CHEAT ---", Color3.fromRGB(150, 150, 255))
    local trapsFound = 0

    -- 1. Buscar Honeypots Geográficos / Minas Falsas
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Health") then
            local pos = obj:GetPivot().Position
            local isInvisible = false
            
            for _, part in pairs(obj:GetDescendants()) do
                if part:IsA("BasePart") and part.Transparency >= 1 then isInvisible = true end
            end

            if pos.Y < -200 or pos.Y > 2000 then
                AddLog("⚠️ HONEYPOT DETECTADO: Mina fuera de los límites en Y="..math.floor(pos.Y).." ("..obj:GetFullName()..")", Color3.fromRGB(255, 100, 255))
                trapsFound = trapsFound + 1
            elseif isInvisible then
                AddLog("⚠️ HONEYPOT DETECTADO: Mina invisible encontrada ("..obj:GetFullName()..")", Color3.fromRGB(255, 100, 255))
                trapsFound = trapsFound + 1
            end
        end
    end

    -- 2. Buscar Scripts de Monitoreo (Anti-Cheat)
    local kw = {"anticheat", "ac", "security", "trap", "detect", "ban"}
    for _, script in pairs(LP.PlayerScripts:GetDescendants()) do
        if script:IsA("LocalScript") or script:IsA("ModuleScript") then
            local nameLower = script.Name:lower()
            for _, word in pairs(kw) do
                if string.find(nameLower, word) then
                    AddLog("🛡️ MÓDULO AC DETECTADO: " .. script:GetFullName(), Color3.fromRGB(255, 200, 50))
                    trapsFound = trapsFound + 1
                    break
                end
            end
        end
    end

    if trapsFound == 0 then
        AddLog("No se encontraron trampas evidentes ni honeypots en el cliente.", Color3.fromRGB(100, 255, 100))
    else
        AddLog("Se detectaron " .. trapsFound .. " posibles vectores de seguridad.", Color3.fromRGB(255, 150, 0))
    end
end)

-- Copiar y Guardar
CopyBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard(table.concat(LOG_TABLE, "\n")) end)
    AddLog("Logs copiados al portapapeles.", Color3.fromRGB(200, 200, 200))
end)

local function SaveData()
    pcall(function()
        writefile(FILE_NAME, table.concat(LOG_TABLE, "\n"))
        AddLog("Guardado en: " .. FILE_NAME, Color3.fromRGB(100, 200, 100))
    end)
end
SaveBtn.MouseButton1Click:Connect(SaveData)

task.spawn(function() while task.wait(60) do SaveData() end end)
AddLog("Consola inicializada. Listo para auditoría.", Color3.fromRGB(100, 255, 255))
