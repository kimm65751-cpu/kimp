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
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 40, 50)
Title.Text = " 🕵️ QUEST FORENSICS V1.0"
Title.TextColor3 = Color3.fromRGB(255, 200, 100)
Title.TextSize = 14
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

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

local logCount = 0
local function LogGUI(text, color)
    print(text)
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
    local totalHeight = 0
    for _, child in ipairs(OutputScroll:GetChildren()) do
        if child:IsA("TextLabel") then totalHeight = totalHeight + child.Size.Y.Offset + 2 end
    end
    OutputScroll.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
    OutputScroll.CanvasPosition = Vector2.new(0, totalHeight)
    
    logCount = logCount + 1
    if logCount > 200 then
        for _, child in ipairs(OutputScroll:GetChildren()) do
            if child:IsA("TextLabel") then child:Destroy(); logCount = logCount - 1; break end
        end
    end
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
                
                -- Obtener coordenadas
                local coords = "Sin Coordenadas"
                local rootPart = npcBase:FindFirstChild("HumanoidRootPart") or npcBase:FindFirstChild("Torso") or (prompt.Parent:IsA("BasePart") and prompt.Parent)
                if rootPart then
                    coords = string.format("X: %.1f, Y: %.1f, Z: %.1f", rootPart.Position.X, rootPart.Position.Y, rootPart.Position.Z)
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
                    LogGUI("--------------------------------------------------", Color3.fromRGB(150, 150, 150))
                    LogGUI("🤖 NPC DETECTADO: " .. npcName, Color3.fromRGB(100, 255, 255))
                    LogGUI("📍 Coordenadas: " .. coords, Color3.fromRGB(200, 200, 200))
                    LogGUI("📝 Acción de Prompt: [" .. prompt.ActionText .. "] " .. prompt.ObjectText, Color3.fromRGB(200, 200, 200))
                    LogGUI("❓ Estado de Misión: " .. misionLista, Color3.fromRGB(255, 150, 150))
                    
                    -- Buscar scripts locales (para saber si hay lógica de cliente atada al NPC)
                    local localScripts = {}
                    for _, v in pairs(npcBase:GetDescendants()) do
                        if v:IsA("LocalScript") or v:IsA("ModuleScript") then
                            table.insert(localScripts, v.Name)
                        end
                    end
                    if #localScripts > 0 then
                        LogGUI("📜 Scripts en NPC: " .. table.concat(localScripts, ", "), Color3.fromRGB(150, 150, 255))
                    end
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
    local nameLower = string.lower(nombre)
    for _, k in pairs(RemotosMisiones) do
        if string.find(nameLower, string.lower(k)) then
            return true
        end
    end
    return false
end

local OriginalNamecall
OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
        if EsRemotoDeMision(self.Name) then
            LogGUI("\n========== [ REPORTE DE RED: CLIENTE -> SERVER ] ==========", Color3.fromRGB(255, 100, 100))
            LogGUI("📡 Tipo de Llamada : " .. method, Color3.fromRGB(200, 200, 200))
            LogGUI("🔗 Nombre Remoto   : " .. self.Name, Color3.fromRGB(150, 255, 150))
            LogGUI("📂 Ruta del Remoto : " .. self:GetFullName(), Color3.fromRGB(200, 200, 200))
            LogGUI("📦 Datos Enviados (Argumentos):", Color3.fromRGB(255, 255, 150))
            
            for i, v in ipairs(args) do
                if type(v) == "table" then
                    LogGUI("   ["..i.."] (JSON) = " .. HttpService:JSONEncode(v), Color3.fromRGB(220, 220, 220))
                else
                    LogGUI("   ["..i.."] ("..type(v)..") = " .. tostring(v), Color3.fromRGB(220, 220, 220))
                end
            end
            LogGUI("=========================================================================\n", Color3.fromRGB(255, 100, 100))
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
                    LogGUI("   ["..i.."] (JSON) = " .. HttpService:JSONEncode(v), Color3.fromRGB(220, 220, 220))
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
