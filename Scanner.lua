-- ==========================================
-- SCANNER V9 - CENTINELA DE DATOS (MÁXIMA OBSERVACIÓN)
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local LOG_FILE = "ScannerV9_Centinela.txt"

local function writeLog(msg)
    local timestamp = os.date("%H:%M:%S")
    local formatMsg = string.format("[%s] %s\n", timestamp, tostring(msg))
    if appendfile then pcall(function() appendfile(LOG_FILE, formatMsg) end)
    elseif writefile then pcall(function() writefile(LOG_FILE, formatMsg) end)
    else print(formatMsg) end
end

if writefile then pcall(function() writefile(LOG_FILE, "=== INICIO CENTINELA V9 ===\n") end) end
writeLog("🛡️ Centinela activado. Escaneando lectura de datos y castigos...")

-- ==========================================
-- 1. DETECCIÓN DE LECTURA DE HWID (SERIAL DE PC)
-- ==========================================
if gethwid then
    local oldHwid
    oldHwid = hookfunction(gethwid, newcclosure(function()
        writeLog("🛑 [ALERTA MÁXIMA] El script acaba de leer tu HWID (Serial de tu PC). Podría estar intentando bloquear tu computadora.")
        return oldHwid()
    end))
end

-- ==========================================
-- 2. VIGILANCIA DE RED (ENVÍO DE DATOS)
-- ==========================================
local oldRequest = (request or http_request or syn and syn.request)
if oldRequest then
    hookfunction(oldRequest, newcclosure(function(reqData)
        if type(reqData) == "table" and reqData.Url then
            writeLog("🌐 [RED] Intentó enviar/recibir datos ocultos de: " .. tostring(reqData.Url))
        end
        return oldRequest(reqData)
    end))
end

-- ==========================================
-- 3. INTERCEPTOR DE ACCIONES (__namecall y __index)
-- ==========================================
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
local oldIndex = mt.__index
setreadonly(mt, false)

-- Variables para no hacer spam en el log si lee tu ID 1000 veces
local yaLeidoID, yaLeidoNombre = false, false

mt.__index = newcclosure(function(self, key)
    -- Si el ofuscador intenta leer tus datos personales:
    if checkcaller() and self == LocalPlayer then
        if key == "UserId" and not yaLeidoID then
            yaLeidoID = true
            writeLog("🔍 [RASTREO] El script acaba de leer tu UserId (ID de cuenta Roblox).")
        elseif key == "Name" and not yaLeidoNombre then
            yaLeidoNombre = true
            writeLog("🔍 [RASTREO] El script acaba de leer tu Nombre de Usuario.")
        end
    end
    return oldIndex(self, key)
end)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- Castigo de Expulsión
    if method == "Kick" or method == "kick" then
        writeLog("⚠️ [CASTIGO] ¡Trial intentó EXPULSARTE! Razón enviada: " .. tostring(args[1]))
        writeLog("   -> Kick bloqueado. Sigues en el juego.")
        return coroutine.yield()
    end
    
    -- Castigo de Teletransporte
    if method == "Teleport" or method == "TeleportToPlaceInstance" then
        writeLog("⚠️ [CASTIGO] Trial intentó teletransportarte. (ID: " .. tostring(args[1]) .. ")")
        return coroutine.yield()
    end

    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- GUI Visual Minimalista
local GUI = Instance.new("ScreenGui", CoreGui)
local Alerta = Instance.new("TextLabel", GUI)
Alerta.Size = UDim2.new(0, 300, 0, 30)
Alerta.Position = UDim2.new(1, -320, 0, 20)
Alerta.BackgroundColor3 = Color3.fromRGB(15, 10, 10)
Alerta.TextColor3 = Color3.fromRGB(255, 150, 0)
Alerta.Text = "🛡️ Centinela V9: Rastreando Datos"
Alerta.Font = Enum.Font.Code
Alerta.TextSize = 14

writeLog("🚀 Todas las trampas instaladas. Juega y espera tranquilo a que se acabe el tiempo.")
