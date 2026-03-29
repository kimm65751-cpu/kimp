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

print("\n============================================================")
print("  🚀 INICIANDO ESCÁNER DE MISIONES Y NPCs (QUEST FORENSICS)")
print("============================================================\n")

-- ==========================================
-- FASE 1: ESCANEO ESTÁTICO DE NPCs EN EL MAPA
-- ==========================================
print("[*] Buscando NPCs interactuables en todo el mapa...")

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
                    print("--------------------------------------------------")
                    print("🤖 NPC DETECTADO: " .. npcName)
                    print("📍 Coordenadas: " .. coords)
                    print("📝 Acción de Prompt: [" .. prompt.ActionText .. "] " .. prompt.ObjectText)
                    print("❓ Estado de Misión: " .. misionLista)
                    
                    -- Buscar scripts locales (para saber si hay lógica de cliente atada al NPC)
                    local localScripts = {}
                    for _, v in pairs(npcBase:GetDescendants()) do
                        if v:IsA("LocalScript") or v:IsA("ModuleScript") then
                            table.insert(localScripts, v.Name)
                        end
                    end
                    if #localScripts > 0 then
                        print("📜 Scripts/Módulos encontrados en el NPC: " .. table.concat(localScripts, ", "))
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
print("--------------------------------------------------\n")

-- ==========================================
-- FASE 2: SNIFFER DE RED (REMOTE INTERCEPTION)
-- ==========================================
print("[*] Inyectando Sniffer de Red para Diálogos y Misiones...")
print("[*] ¡Ve y habla con un NPC ahora para capturar la misión!\n")

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
            print("\n================= [ REPORTE DE RED: CLIENTE -> SERVIDOR ] =================")
            print("📡 Tipo de Llamada : " .. method)
            print("🔗 Nombre Remoto   : " .. self.Name)
            print("📂 Ruta del Remoto : " .. self:GetFullName())
            print("📦 Datos Enviados (Argumentos):")
            
            for i, v in ipairs(args) do
                if type(v) == "table" then
                    print("   ["..i.."] (Tabla JSON) = " .. HttpService:JSONEncode(v))
                else
                    print("   ["..i.."] ("..type(v)..") = " .. tostring(v))
                end
            end
            print("=========================================================================\n")
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
            print("\n================= [ REPORTE DE RED: SERVIDOR -> CLIENTE ] =================")
            print("📡 Evento Recibido : OnClientEvent")
            print("🔗 Nombre Remoto   : " .. obj.Name)
            
            print("📦 Datos Recibidos (Posibles misiones, requisitos, opciones de diálogo):")
            for i, v in ipairs(args) do
                if type(v) == "table" then
                    print("   ["..i.."] (Tabla JSON) = " .. HttpService:JSONEncode(v))
                else
                    print("   ["..i.."] ("..type(v)..") = " .. tostring(v))
                end
            end
            print("=========================================================================\n")
        end)
        table.insert(conexionesOnClientEvent, c)
    end
end

print("[✔] Sniffer inyectado correctamente. Todo el tráfico de misiones y NPCs será impreso en la consola (F9).")
print("[!] Ve e interactúa con los NPCs, acepta misiones y complétalas para registrar todo el proceso.")
