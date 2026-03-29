-- ==============================================================================
-- 🕵️ ANALIZADOR FORENSE DE MISIONES Y NPCs (QUEST TRACKER V1.0)
-- ==============================================================================
-- Este script realiza dos tareas principales:
-- 1. Escanea todo el mapa para identificar qué NPCs dan misiones, sus coordenadas
--    y qué sistemas de interacción tienen (ProximityPrompts).
-- 2. Rastrea e intercepta los Remotes (Knit / DialogueEvents) para descubrir:
--    - Qué datos pide el NPC para dar la misión.
--    - Qué opciones de diálogo existen.
--    - Cómo se acepta y se completa una misión a nivel de red (Server-Client).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- GUI EN PANTALLA
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "QuestAnalyzerUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QuestAnalyzerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 350)
MainFrame.Position = UDim2.new(1, -460, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(200, 150, 50)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -170, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 40, 50)
Title.Text = " 🕵️ QUEST FORENSICS V1.0"
Title.TextColor3 = Color3.fromRGB(255, 200, 100)
Title.TextSize = 14
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0, 100, 0, 30)
CopyBtn.Position = UDim2.new(1, -170, 0, 0)
CopyBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
CopyBtn.Text = "📥 COPIAR"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.Code
CopyBtn.TextSize = 11
CopyBtn.Parent = MainFrame

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 35, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(180, 150, 0)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.Code
MinBtn.TextSize = 16
MinBtn.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.Code
CloseBtn.TextSize = 16
CloseBtn.Parent = MainFrame

local OutputScroll = Instance.new("ScrollingFrame")
OutputScroll.Size = UDim2.new(1, -10, 1, -40)
OutputScroll.Position = UDim2.new(0, 5, 0, 35)
OutputScroll.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
OutputScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
OutputScroll.ScrollBarThickness = 5
OutputScroll.Parent = MainFrame

local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 450, 0, 30)
        OutputScroll.Visible = false
    else
        MainFrame.Size = UDim2.new(0, 450, 0, 350)
        OutputScroll.Visible = true
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local FullLogText = "=== REPORTE DE MISIONES (QUEST FORENSICS) ===\n\n"
CopyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(FullLogText)
        CopyBtn.Text = "¡COPIADO!"
        task.delay(2, function() CopyBtn.Text = "📥 COPIAR" end)
    end
end)

local OutputScroll = Instance.new("ScrollingFrame")
OutputScroll.Size = UDim2.new(1, -10, 1, -40)
OutputScroll.Position = UDim2.new(0, 5, 0, 35)
OutputScroll.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
OutputScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
OutputScroll.ScrollBarThickness = 5
OutputScroll.Parent = MainFrame
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = OutputScroll
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 2)

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    OutputScroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 15)
end)

local logCount = 0

local function LogGUI(text, color)
    print(text)
    FullLogText = FullLogText .. text .. "\n"
    
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, -10, 0, 20)
    msg.BackgroundTransparency = 1
    msg.Text = text
    msg.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    msg.TextSize = 12
    msg.Font = Enum.Font.Code
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.TextWrapped = true
    msg.Parent = OutputScroll
    
    -- Ajustar altura dinámica
    msg.Size = UDim2.new(1, -10, 0, msg.TextBounds.Y + 8)
    OutputScroll.CanvasPosition = Vector2.new(0, 99999) -- Auto-scroll hacia abajo
    
    logCount = logCount + 1
    if logCount > 200 then
        for _, child in ipairs(OutputScroll:GetChildren()) do
            if child:IsA("TextLabel") or child:IsA("Frame") then child:Destroy(); logCount = logCount - 1; break end
        end
    end
end

local function PcallJSON(tbl)
    local success, res = pcall(function() return HttpService:JSONEncode(tbl) end)
    if success then return res end
    local str = "{"
    for i, v in pairs(tbl) do
        str = str .. tostring(i) .. ": " .. tostring(v) .. ", "
    end
    return str .. "}"
end

local isFlyingTo = false
local noclipConnection = nil

local function IrHaciaNPC(targetPos)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if root:FindFirstChild("_NoclipAnalyzer") then root._NoclipAnalyzer:Destroy() end
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = "_NoclipAnalyzer"
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Parent = root
    
    isFlyingTo = true
    
    -- Hacer que el personaje atraviese todas las paredes (NOCLIP FISICO Y REAL)
    if noclipConnection then noclipConnection:Disconnect() end
    noclipConnection = game:GetService("RunService").Stepped:Connect(function()
        if not isFlyingTo then
            if noclipConnection then noclipConnection:Disconnect() end
            return
        end
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end)
    
    task.spawn(function()
        while isFlyingTo and bv.Parent and root.Parent do
            local dist = (root.Position - targetPos).Magnitude
            if dist < 5 then
                bv:Destroy()
                isFlyingTo = false
                break
            end
            
            local hDist = (Vector2.new(root.Position.X, root.Position.Z) - Vector2.new(targetPos.X, targetPos.Z)).Magnitude
            local flyPos = targetPos
            if hDist > 15 then
                flyPos = Vector3.new(targetPos.X, math.max(targetPos.Y + 20, root.Position.Y), targetPos.Z)
            end
            
            local dir = (flyPos - root.Position).Unit
            bv.Velocity = dir * 65 -- Vuelo noclip seguro y rápido
            task.wait(0.05)
        end
    end)
end

local function LogNPCWithButton(npcName, coords, targetPos, detailText)
    FullLogText = FullLogText .. "🤖 NPC DETECTADO: " .. npcName .. "\n📍 Coordenadas: " .. coords .. "\n" .. detailText .. "\n--------------------\n"
    
    local msgFrame = Instance.new("Frame")
    msgFrame.Size = UDim2.new(1, -10, 0, 75)
    msgFrame.BackgroundTransparency = 1
    msgFrame.Parent = OutputScroll
    
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, -60, 1, 0)
    msg.BackgroundTransparency = 1
    msg.Text = "🤖 NPC: " .. npcName .. "\n📍 Dir: " .. coords .. "\n" .. detailText
    msg.TextColor3 = Color3.fromRGB(150, 255, 255)
    msg.TextSize = 11
    msg.Font = Enum.Font.Code
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.TextWrapped = true
    msg.Parent = msgFrame
    msg.Size = UDim2.new(1, -60, 0, msg.TextBounds.Y + 8)
    msgFrame.Size = UDim2.new(1, -10, 0, msg.Size.Y.Offset)
    
    if targetPos then
        local goBtn = Instance.new("TextButton")
        goBtn.Size = UDim2.new(0, 45, 0, 25)
        goBtn.Position = UDim2.new(1, -45, 0.5, -12)
        goBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
        goBtn.Text = "✈️ IR"
        goBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        goBtn.TextSize = 11
        goBtn.Font = Enum.Font.Code
        goBtn.Parent = msgFrame
        
        goBtn.MouseButton1Click:Connect(function()
            if isFlyingTo then
                isFlyingTo = false
                if noclipConnection then noclipConnection:Disconnect() end
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root and root:FindFirstChild("_NoclipAnalyzer") then root._NoclipAnalyzer:Destroy() end
                goBtn.Text = "✈️ IR"
                goBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
            else
                LogGUI("[✈️] Volando TRASPASANDO PAREDES hacia " .. npcName .. "...", Color3.fromRGB(100, 255, 255))
                goBtn.Text = "🛑 STOP"
                goBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                IrHaciaNPC(targetPos)
                task.spawn(function()
                    repeat task.wait(0.5) until not isFlyingTo
                    if goBtn.Parent then 
                        goBtn.Text = "✈️ IR"
                        goBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
                    end
                end)
            end
        end)
    end
    
    logCount = logCount + 1
end

LogGUI("============================================================\n  🚀 INICIANDO ESCÁNER DE MISIONES Y NPCs\n============================================================", Color3.fromRGB(100, 255, 100))

-- ==========================================
-- FASE 1: ESCANEO ESTÁTICO DE NPCs EN EL MAPA
-- ==========================================
LogGUI("[*] Buscando NPCs interactuables en todo el mapa...", Color3.fromRGB(255, 200, 50))

local NPCsEncontrados = {}

local function EscanearModelo(modelo)
    -- Buscar ProximityPrompts que indiquen diálogo o interacción
    for _, prompt in pairs(modelo:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local actionText = string.lower(prompt.ActionText)
            local objectText = string.lower(prompt.ObjectText)
            
            -- Si parece un NPC con el que se puede hablar
            if string.find(actionText, "talk") or string.find(actionText, "interact") or string.find(actionText, "quest") or string.find(objectText, "npc") then
                
                local npcBase = prompt:FindFirstAncestorWhichIsA("Model") or prompt.Parent
                local npcName = npcBase and npcBase.Name or "Desconocido"
                
                local coords = "Sin Coordenadas"
                local targetPos = nil
                local rootPart = npcBase:FindFirstChild("HumanoidRootPart") or npcBase:FindFirstChild("Torso") or (prompt.Parent:IsA("BasePart") and prompt.Parent)
                if rootPart then
                    targetPos = rootPart.Position
                    coords = string.format("X: %.1f, Y: %.1f, Z: %.1f", targetPos.X, targetPos.Y, targetPos.Z)
                end
                
                -- Analizar si tiene algún indicador visual de misión ( BillboardGui con exclamación, interrogación, etc. )
                local misionLista = "Desconocido"
                for _, gui in pairs(npcBase:GetDescendants()) do
                    if gui:IsA("TextLabel") or gui:IsA("ImageLabel") then
                        if gui:IsA("TextLabel") and (string.find(gui.Text, "!") or string.find(gui.Text, "?")) then
                            misionLista = "¡Misión Disponible / O indicador visual detectado!"
                        end
                    end
                end

                if not NPCsEncontrados[npcName] then
                    NPCsEncontrados[npcName] = true
                    local detailText = "📝 Acción: [" .. prompt.ActionText .. "] " .. prompt.ObjectText .. "\n❓ Misión: " .. misionLista
                    
                    local localScripts = {}
                    for _, v in pairs(npcBase:GetDescendants()) do
                        if v:IsA("LocalScript") or v:IsA("ModuleScript") then
                            table.insert(localScripts, v.Name)
                        end
                    end
                    if #localScripts > 0 then
                        detailText = detailText .. "\n📜 Scripts: " .. table.concat(localScripts, ", ")
                    end
                    
                    LogNPCWithButton(npcName, coords, targetPos, detailText)
                end
            end
        end
    end
end

for _, obj in pairs(Workspace:GetDescendants()) do
    if obj:IsA("Model") and (obj:FindFirstChild("Humanoid") or obj:FindFirstChild("ProximityPrompt", true)) then
        EscanearModelo(obj)
    end
end
LogGUI("--------------------------------------------------\n", Color3.fromRGB(150, 150, 150))

-- ==========================================
-- FASE 2: SNIFFER DE RED (REMOTE INTERCEPTION)
-- ==========================================
LogGUI("[*] Inyectando Sniffer de Red para Diálogos y Misiones...", Color3.fromRGB(255, 200, 50))
LogGUI("[*] ¡Ve y habla con un NPC ahora para capturar la misión!\n", Color3.fromRGB(255, 100, 100))

local RemotosMisiones = {
    "DialogueRemote",
    "DialogueEvent",
    "Dialogue",
    "ProgressDataChanged",
    "EquipAchievement",
    "Quest",
    "Mission",
    "Accept",
    "Complete",
    "Claim"
}

local function EsRemotoDeMision(nombre)
    local success, res = pcall(function()
        local nameLower = string.lower(tostring(nombre))
        for _, k in pairs(RemotosMisiones) do
            if string.find(nameLower, string.lower(k)) then
                return true
            end
        end
        return false
    end)
    return success and res
end

local OriginalNamecall
OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
        local successName, rName = pcall(function() return self.Name end)
        local successPath, rPath = pcall(function() return self:GetFullName() end)
        
        if successName and EsRemotoDeMision(rName) then
            -- Usar task.spawn para sacar toda la carga pesada (como Inyectar GUIs y Logs) fuera
            -- del hilo principal de C, evitando que se trabe el juego al interactuar.
            task.spawn(function()
                LogGUI("\n========== [ REPORTE DE RED: CLIENTE -> SERVER ] ==========", Color3.fromRGB(255, 100, 100))
                LogGUI("📡 Tipo de Llamada : " .. method, Color3.fromRGB(200, 200, 200))
                LogGUI("🔗 Nombre Remoto   : " .. rName, Color3.fromRGB(150, 255, 150))
                LogGUI("📂 Ruta del Remoto : " .. (successPath and rPath or "Desconocida"), Color3.fromRGB(200, 200, 200))
                LogGUI("📦 Datos Enviados (Argumentos):", Color3.fromRGB(255, 255, 150))
                
                for i, v in ipairs(args) do
                    if type(v) == "table" then
                        LogGUI("   ["..i.."] (JSON) = " .. PcallJSON(v), Color3.fromRGB(220, 220, 220))
                    else
                        LogGUI("   ["..i.."] ("..type(v)..") = " .. tostring(v), Color3.fromRGB(220, 220, 220))
                    end
                end
                LogGUI("=========================================================================\n", Color3.fromRGB(255, 100, 100))
            end)
        end
    end
    
    return OriginalNamecall(self, ...)
end)

-- Intentar capturar eventos del SERVIDOR al CLIENTE
local conexionesOnClientEvent = {}
for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") and EsRemotoDeMision(obj.Name) then
        local c = obj.OnClientEvent:Connect(function(...)
            local args = {...}
            LogGUI("\n========== [ REPORTE DE RED: SERVER -> CLIENTE ] ==========", Color3.fromRGB(100, 150, 255))
            LogGUI("📡 Evento Recibido : OnClientEvent", Color3.fromRGB(200, 200, 200))
            LogGUI("🔗 Nombre Remoto   : " .. obj.Name, Color3.fromRGB(150, 255, 150))
            
            LogGUI("📦 Datos Recibidos (Posibles misiones/diálogos):", Color3.fromRGB(255, 255, 150))
            for i, v in ipairs(args) do
                if type(v) == "table" then
                    LogGUI("   ["..i.."] (JSON) = " .. PcallJSON(v), Color3.fromRGB(220, 220, 220))
                else
                    LogGUI("   ["..i.."] ("..type(v)..") = " .. tostring(v), Color3.fromRGB(220, 220, 220))
                end
            end
            LogGUI("=========================================================================\n", Color3.fromRGB(100, 150, 255))
        end)
        table.insert(conexionesOnClientEvent, c)
    end
end

LogGUI("[✔] Sniffer y HUD inyectados correctamente.", Color3.fromRGB(100, 255, 100))
LogGUI("[!] Ve e interactúa con los NPCs, el proceso aparecerá aquí.", Color3.fromRGB(255, 200, 50))
