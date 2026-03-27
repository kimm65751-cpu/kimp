-- ==============================================================================
-- 🔍 ZERO-DAY ARCHITECTURE SCANNER (AUDITOR LOCAL PARA DELTA)
-- Escanea la exposición del Cliente-Servidor en busca de vulnerabilidades
-- ==============================================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function LogWarning(category, riskLevel, message)
    warn("[" .. category .. "] [" .. riskLevel .. "] " .. message)
end

print("\n=======================================================")
print("🛡️ INICIANDO AUDITORÍA DE VULNERABILIDADES DEL CLIENTE...")
print("=======================================================\n")

-- ==============================================================================
-- 1. ESCÁNER DE REMOTE EVENTS (El vector de ataque #1)
-- ==============================================================================
print("📡 ANALIZANDO COMUNICACIONES (Remotes)...")
local remotesFound = 0
for _, obj in pairs(game:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        -- Ignorar los remotes predeterminados de Roblox
        if not string.find(obj:GetFullName(), "RobloxReplicatedStorage") and not string.find(obj:GetFullName(), "DefaultChat") then
            LogWarning("REMOTES", "CRÍTICO", "Remote Expuesto: " .. obj:GetFullName())
            remotesFound = remotesFound + 1
        end
    end
end
if remotesFound == 0 then
    print("✅ No se encontraron RemoteEvents expuestos. (Excelente).")
end

-- ==============================================================================
-- 2. ESCÁNER DE FÍSICAS (NETWORK OWNERSHIP & FLING ABUSE)
-- ==============================================================================
print("\n🌪️ ANALIZANDO FÍSICAS Y OBJETOS SUELTOS (Riesgo de Fling)...")
local unanchoredParts = 0
for _, obj in pairs(Workspace:GetDescendants()) do
    if obj:IsA("BasePart") and not obj.Anchored then
        -- Ignorar partes de personajes
        if not obj.Parent:FindFirstChild("Humanoid") then
            LogWarning("FÍSICAS", "ALTO", "Parte Suelta Encontrada: " .. obj:GetFullName() .. " | Un hacker puede usar esto como proyectil (Fling/Telekinesis).")
            unanchoredParts = unanchoredParts + 1
        end
    end
end
if unanchoredParts == 0 then
    print("✅ No hay piezas sueltas en el mapa. Inmune a ataques Fling con entorno.")
end

-- ==============================================================================
-- 3. ESCÁNER DE HITBOXES Y SENSORES (SPOOFING DE DAÑO)
-- ==============================================================================
print("\n🖐️ ANALIZANDO SENSORES TÁCTILES (Riesgo de Hitbox Spoofing)...")
local touchSensors = 0
for _, obj in pairs(Workspace:GetDescendants()) do
    if obj:IsA("TouchTransmitter") then
        LogWarning("HITBOX", "MEDIO-ALTO", "Sensor .Touched activo en: " .. obj.Parent:GetFullName() .. " | El cliente puede falsificar colisiones aquí.")
        touchSensors = touchSensors + 1
    end
end
if touchSensors == 0 then
    print("✅ No se detectaron TouchTransmitters. El daño no depende de colisiones físicas.")
end

-- ==============================================================================
-- 4. ESCÁNER DE VARIABLES DEL JUGADOR (GODMODE / STAT MANIPULATION)
-- ==============================================================================
print("\n👤 ANALIZANDO VARIABLES EXPUESTAS EN EL PERSONAJE...")
local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
for _, obj in pairs(char:GetDescendants()) do
    if obj:IsA("ValueBase") then
        LogWarning("VARIABLES", "MEDIO", "Valor Expuesto en Personaje: " .. obj.Name .. " (" .. obj.ClassName .. ") | Valor actual: " .. tostring(obj.Value))
    end
end

print("\n=======================================================")
print("🛑 AUDITORÍA FINALIZADA. REVISA LA CONSOLA (F9).")
print("=======================================================")
