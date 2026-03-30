-- ==============================================================================
-- 🧪 MINE LIMIT TESTER V1.0 (Laboratorio de Pruebas de Daño)
-- ==============================================================================
-- Propósito: Buscar la roca más dura, volar hacia ella, intentar saltar 
-- las restricciones locales y registrar TODO lo que el juego responda.
-- ==============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local LogService = game:GetService("LogService")
local VIM = game:GetService("VirtualInputManager")

local LP = Players.LocalPlayer

-- ==================== INTERFAZ ====================
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LP:WaitForChild("PlayerGui")
for _, v in pairs(parentUI:GetChildren()) do if v.Name == "LimitTesterUI" then v:Destroy() end end

local SG = Instance.new("ScreenGui")
SG.Name = "LimitTesterUI"
SG.ResetOnSpawn = false
SG.Parent = parentUI

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 350, 0, 400)
Panel.Position = UDim2.new(0.5, -175, 0.5, -200)
Panel.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(255, 100, 50)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = SG

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -30, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
Title.Text = " 🧪 MINE LIMIT TESTER V1.0"
Title.TextColor3 = Color3.fromRGB(255, 200, 150)
Title.Font = Enum.Font.Code
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Panel

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Parent = Panel
CloseBtn.MouseButton1Click:Connect(function() SG:Destroy() end)

local BtnScan = Instance.new("TextButton")
BtnScan.Size = UDim2.new(0.5, -4, 0, 30)
BtnScan.Position = UDim2.new(0, 2, 0, 35)
BtnScan.BackgroundColor3 = Color3.fromRGB(40, 40, 100)
BtnScan.Text = "1. 🔍 BUSCAR ROCAS DURAS"
BtnScan.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnScan.Font = Enum.Font.Code; BtnScan.TextSize = 11
BtnScan.Parent = Panel

local BtnGo = Instance.new("TextButton")
BtnGo.Size = UDim2.new(0.5, -4, 0, 30)
BtnGo.Position = UDim2.new(0.5, 2, 0, 35)
BtnGo.BackgroundColor3 = Color3.fromRGB(100, 40, 100)
BtnGo.Text = "2. ✈️ IR A LA MÁS DURA"
BtnGo.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnGo.Font = Enum.Font.Code; BtnGo.TextSize = 11
BtnGo.Parent = Panel

local BtnHack = Instance.new("TextButton")
BtnHack.Size = UDim2.new(1, -4, 0, 35)
BtnHack.Position = UDim2.new(0, 2, 0, 70)
BtnHack.BackgroundColor3 = Color3.fromRGB(150, 50, 20)
BtnHack.Text = "3. 💥 INYECTAR BYPASS Y PICAR (ANALIZAR ERRORES)"
BtnHack.TextColor3 = Color3.fromRGB(255, 255, 100)
BtnHack.Font = Enum.Font.Code; BtnHack.TextSize = 12
BtnHack.Parent = Panel

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -8, 1, -115)
LogScroll.Position = UDim2.new(0, 4, 0, 110)
LogScroll.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogScroll.ScrollBarThickness = 6
LogScroll.Parent = Panel
Instance.new("UIListLayout", LogScroll).Padding = UDim.new(0, 2)

-- ==================== FUNCIONES BASE ====================
local TargetRock = nil
local EventConnections = {}

local function AddLog(tag, msg, color)
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, -4, 0, 0)
    txt.BackgroundTransparency = 1
    txt.Text = string.format("[%s] %s", tag, msg)
    txt.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    txt.Font = Enum.Font.Code; txt.TextSize = 11
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.TextWrapped = true
    txt.Parent = LogScroll
    
    local ts = game:GetService("TextService"):GetTextSize(
        txt.Text, txt.TextSize, txt.Font, Vector2.new(LogScroll.AbsoluteSize.X - 15, 9999)
    )
    txt.Size = UDim2.new(1, -4, 0, ts.Y + 4)
    LogScroll.CanvasPosition = Vector2.new(0, 999999)
end

-- 1. Buscar Rocas Duras
BtnScan.MouseButton1Click:Connect(function()
    AddLog("SCAN", "Buscando rocas con la mayor cantidad de Health...", Color3.fromRGB(100, 200, 255))
    local rocks = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local hp = obj:GetAttribute("Health")
            if hp and hp > 0 then
                -- Guardar
                table.insert(rocks, {obj = obj, hp = hp, name = obj.Name})
            end
        end
    end
    
    -- Ordenar de mayor a menor HP
    table.sort(rocks, function(a, b) return a.hp > b.hp end)
    
    if #rocks > 0 then
        TargetRock = rocks[1].obj
        AddLog("SCAN", string.format("✅ Encontrada roca más dura: %s (HP: %d)", TargetRock.Name, rocks[1].hp), Color3.fromRGB(0, 255, 100))
        for i = 1, math.min(3, #rocks) do
            AddLog("INFO", string.format("  #%d -> %s | HP: %d", i, rocks[i].name, rocks[i].hp), Color3.fromRGB(150, 150, 150))
        end
    else
        AddLog("ERR", "❌ No se encontraron rocas con vida.", Color3.fromRGB(255, 50, 50))
    end
end)

-- 2. Volar a la roca
BtnGo.MouseButton1Click:Connect(function()
    if not TargetRock or not TargetRock.Parent then
        AddLog("ERR", "Primero escanea para buscar la roca.", Color3.fromRGB(255, 100, 100))
        return
    end
    
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local tarRoot = TargetRock:FindFirstChild("HumanoidRootPart") or TargetRock:FindFirstChild("Torso") or TargetRock:FindFirstChildWhichIsA("BasePart")
    
    if root and tarRoot then
        AddLog("NAV", "Volando hacia " .. TargetRock.Name .. " con Noclip...", Color3.fromRGB(200, 150, 255))
        -- Teleport rápido pero seguro
        root.CFrame = CFrame.new(tarRoot.Position) * CFrame.new(0, 0, 4)
        root.CFrame = CFrame.lookAt(root.Position, tarRoot.Position)
        
        -- Fijar en el aire si está volando
        local bg = Instance.new("BodyVelocity")
        bg.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bg.Velocity = Vector3.zero
        bg.Parent = root
        task.delay(1.5, function() pcall(function() bg:Destroy() end) end)
    else
        AddLog("ERR", "No se encontró el RootPart de la roca.", Color3.fromRGB(255, 50, 50))
    end
end)

-- 3. Inyectar Bypass y Picar (MONITOREAR TODO)
local isTesting = false
BtnHack.MouseButton1Click:Connect(function()
    if isTesting then return end
    isTesting = true
    BtnHack.Text = "⏳ ANALIZANDO GOLPES..."
    
    AddLog("TEST", "====================", Color3.fromRGB(255, 150, 50))
    AddLog("TEST", "INICIANDO INYECCIÓN Y ANÁLISIS", Color3.fromRGB(255, 200, 100))
    
    -- Limpiar logs anteriores
    for _, c in pairs(EventConnections) do pcall(function() c:Disconnect() end) end
    EventConnections = {}
    
    -- === HACK 1: Sobreescribir Tabla de Ores ===
    pcall(function()
        local oreModule = RS.Shared.Data:FindFirstChild("Ore")
        if oreModule then
            local oreData = require(oreModule)
            if type(oreData) == "table" then
                for k, v in pairs(oreData) do
                    if type(v) == "table" then
                        -- Forzamos a que pida Tier 1 de Tool y bajamos la dureza requerida
                        if v.RequiredTier then v.RequiredTier = 0 end
                        if v.Hardness then v.Hardness = 1 end
                        if v.Health then v.Health = 1 end
                        if v.DamageRequired then v.DamageRequired = 0 end
                    end
                end
                AddLog("HACK", "✅ Módulo 'Shared.Data.Ore' modificado localmente (Requisitos eliminados)", Color3.fromRGB(0, 255, 100))
            end
        end
    end)
    
    -- === HACK 2: Sobreescribir Stats del Pickaxe ===
    pcall(function()
        local char = LP.Character
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                tool:SetAttribute("MinePower", 999999)
                tool:SetAttribute("Tier", 99)
                tool:SetAttribute("Damage", 999999)
                AddLog("HACK", "✅ Atributos del Tool '"..tool.Name.."' subidos a nivel Dios.", Color3.fromRGB(0, 255, 100))
            end
        end
    end)

    -- === MONITOR: Capturar errores de consola (Lo que dice el ToolController) ===
    local logConn = LogService.MessageOut:Connect(function(message, type)
        local msgLower = string.lower(message)
        if string.find(msgLower, "mine") or string.find(msgLower, "damage") or string.find(msgLower, "power") or string.find(msgLower, "tier") or type == Enum.MessageType.MessageWarning or type == Enum.MessageType.MessageError then
            -- Solo loguear si parece de minería o si es un Warning/Error
            local color = Color3.fromRGB(200, 200, 200)
            if type == Enum.MessageType.MessageWarning then color = Color3.fromRGB(255, 200, 50) end
            if type == Enum.MessageType.MessageError then color = Color3.fromRGB(255, 50, 50) end
            
            AddLog("CONSOLE", message, color)
        end
    end)
    table.insert(EventConnections, logConn)
    
    -- === MONITOR: Capturar Remotos (Si el servidor nos manda un error visual o aviso) ===
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local rConn = obj.OnClientEvent:Connect(function(...)
                local args = {...}
                -- Solo nos interesa si nos devuelve algo de "mining", "insufficient", "damage"
                local argsStr = ""
                for _, a in pairs(args) do argsStr = argsStr .. tostring(a) .. " " end
                
                local s = string.lower(argsStr)
                if string.find(s, "insufficient") or string.find(s, "damage") or string.find(s, "power") or string.find(s, "error") then
                    AddLog("SERVER_REJECT", "[Remote: "..obj.Name.."] -> " .. argsStr, Color3.fromRGB(255, 0, 150))
                end
            end)
            table.insert(EventConnections, rConn)
        end
    end

    AddLog("SYS", "👀 Monitores encendidos. Simulando click de minado en 2 segundos...", Color3.fromRGB(150, 150, 150))
    
    task.wait(2)
    
    -- === PICAR CON VIRTUAL INPUT MANAGER ===
    if TargetRock and TargetRock.Parent then
        local tarRoot = TargetRock:FindFirstChild("HumanoidRootPart") or TargetRock:FindFirstChild("Torso") or TargetRock:FindFirstChildWhichIsA("BasePart")
        if tarRoot then
            local char = LP.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                -- Apuntar exactamente
                root.CFrame = CFrame.lookAt(root.Position, tarRoot.Position)
                task.wait(0.2)
                
                -- Obtener vida antes del golpe
                local hpPrev = TargetRock:GetAttribute("Health") or "N/A"
                AddLog("MINE", string.format("Vida de la roca antes del golpe: %s", tostring(hpPrev)), Color3.fromRGB(200, 255, 100))
                
                -- Dar click humano (Center of viewport)
                local vp = workspace.CurrentCamera.ViewportSize
                VIM:SendMouseButtonEvent(vp.X/2, vp.Y/2, 0, true, game, 0)
                task.wait(0.05)
                VIM:SendMouseButtonEvent(vp.X/2, vp.Y/2, 0, false, game, 0)
                
                AddLog("MINE", "🔨 CLIC ENVIADO! Esperando reacción del servidor...", Color3.fromRGB(0, 200, 255))
                
                -- Esperar 3 segundos para ver resultados
                task.wait(3)
                
                local hpPost = TargetRock:GetAttribute("Health") or "N/A"
                AddLog("RESULT", string.format("Vida de la roca DESPUÉS del golpe: %s", tostring(hpPost)), Color3.fromRGB(200, 255, 100))
                
                if tostring(hpPrev) == tostring(hpPost) then
                    AddLog("RESULT", "❌ RESULTADO: La vida NO BAJÓ. El servidor bloqueó tu daño.", Color3.fromRGB(255, 50, 50))
                    AddLog("RESULT", "Causa Probable: ReplicaService valida el poder real de tu pico en el Backend.", Color3.fromRGB(255, 100, 100))
                else
                    AddLog("RESULT", "✅ RESULTADO: ¡LA VIDA BAJÓ! El Bypass Cliente funcionó.", Color3.fromRGB(0, 255, 100))
                end
            end
        end
    end
    
    task.wait(1)
    for _, c in pairs(EventConnections) do pcall(function() c:Disconnect() end) end
    EventConnections = {}
    LogService.MessageOut:Disconnect() -- Por si acaso
    BtnHack.Text = "3. 💥 INYECTAR BYPASS Y PICAR (ANALIZAR ERRORES)"
    isTesting = false
end)
