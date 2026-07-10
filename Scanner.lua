-- ==========================================
-- SCANNER V4 + CONGELADOR + LOGGER (.txt)
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LOG_FILE = "ScannerV4_Log.txt"

-- ==========================================
-- 1. SISTEMA DE LOGS (ESCRITURA EN .TXT)
-- ==========================================
local function writeLog(msg)
    local timestamp = os.date("%H:%M:%S")
    local formatMsg = string.format("[%s] %s\n", timestamp, tostring(msg))
    
    -- Intenta escribir en el archivo (Requiere un ejecutor que soporte file system)
    if appendfile then
        pcall(function() appendfile(LOG_FILE, formatMsg) end)
    elseif writefile then 
        -- Fallback si solo tiene writefile (menos óptimo pero funciona)
        pcall(function() writefile(LOG_FILE, formatMsg) end)
    else
        print(formatMsg) -- Si el ejecutor no soporta archivos, usa la consola F9
    end
end

-- Reiniciamos el archivo de log al ejecutar el script
if writefile then
    pcall(function() writefile(LOG_FILE, "=== INICIO SCANNER V4 ===\n") end)
end
writeLog("✅ Interfaz Iniciada Exitosamente.")

-- ==========================================
-- 2. CREACIÓN DE INTERFAZ (GUI)
-- ==========================================
if CoreGui:FindFirstChild("ScannerPro") then 
    CoreGui.ScannerPro:Destroy() 
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScannerPro"
-- Protección básica para la GUI
if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end 
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 220)
MainFrame.Position = UDim2.new(1, -320, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = " 🕵️ Scanner & Bypass"
Title.Font = Enum.Font.Code
Title.TextSize = 16

local function createLabel(yPos, text)
    local lbl = Instance.new("TextLabel", MainFrame)
    lbl.Size = UDim2.new(1, -10, 0, 25)
    lbl.Position = UDim2.new(0, 10, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(0, 255, 100)
    lbl.Text = text
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

local LblTime = createLabel(40, "Consultas os.time: 0")
local LblTick = createLabel(70, "Consultas tick: 0")
local LblClock = createLabel(100, "Consultas os.clock: 0")

local BtnFreeze = Instance.new("TextButton", MainFrame)
BtnFreeze.Size = UDim2.new(1, -20, 0, 40)
BtnFreeze.Position = UDim2.new(0, 10, 0, 150)
BtnFreeze.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
BtnFreeze.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnFreeze.Text = "❄️ CONGELAR TIEMPO ❄️"
BtnFreeze.Font = Enum.Font.Code
BtnFreeze.TextSize = 16

-- ==========================================
-- 3. LÓGICA DE BYPASS Y OPTIMIZACIÓN
-- ==========================================
local timeFrozen = false
local fTime, fTick, fClock = 0, 0, 0
local callsTime, callsTick, callsClock = 0, 0, 0

BtnFreeze.MouseButton1Click:Connect(function()
    timeFrozen = not timeFrozen
    if timeFrozen then
        fTime = os.time()
        fTick = tick()
        fClock = os.clock()
        BtnFreeze.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        BtnFreeze.Text = "🔴 TIEMPO CONGELADO 🔴"
        writeLog("❄️ TIEMPO CONGELADO ACTIVADO ❄️ (Valores capturados)")
    else
        BtnFreeze.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        BtnFreeze.Text = "❄️ CONGELAR TIEMPO ❄️"
        writeLog("▶️ TIEMPO DESCONGELADO")
    end
end)

-- Actualización visual suave (ligada a los frames para evitar lag en UI)
RunService.RenderStepped:Connect(function()
    LblTime.Text = "Consultas os.time: " .. callsTime
    LblTick.Text = "Consultas tick: " .. callsTick
    LblClock.Text = "Consultas os.clock: " .. callsClock
end)

-- Monitoreo de fondo (Heartbeat para el .txt)
task.spawn(function()
    local lastCallsTick = 0
    while task.wait(1) do
        -- Si tick sube más de 10,000 veces en 1 segundo, hay un bucle infinito bloqueando el juego.
        local tickDiff = callsTick - lastCallsTick
        if tickDiff > 10000 then
            writeLog("⚠️ ADVERTENCIA: Posible Bucle Infinito detectado (" .. tickDiff .. " llamadas a tick en 1 seg)")
        end
        lastCallsTick = callsTick
        
        -- Guardar estado para saber cuándo se congela el juego
        writeLog(string.format("Latido - Activo | os.time: %d | tick: %d | os.clock: %d", callsTime, callsTick, callsClock))
    end
end)

-- ==========================================
-- 4. HOOKS SEGUROS (ANTI-CRASH)
-- ==========================================
writeLog("⚙️ Iniciando Hooks...")

pcall(function()
    local oldTime
    oldTime = hookfunction(os.time, function(...)
        if checkcaller() then 
            callsTime = callsTime + 1 
            if timeFrozen then return fTime end -- os.time no crashea si es exacto
        end
        return oldTime(...)
    end)
    writeLog("✅ Hook a os.time exitoso.")
end)

pcall(function()
    local oldTick
    oldTick = hookfunction(tick, function(...)
        if checkcaller() then 
            callsTick = callsTick + 1 
            if timeFrozen then 
                -- Micro-spoofing: Evita división por cero y anti-tampers
                fTick = fTick + 0.000001
                return fTick 
            end
        end
        return oldTick(...)
    end)
    writeLog("✅ Hook a tick exitoso.")
end)

pcall(function()
    local oldClock
    oldClock = hookfunction(os.clock, function(...)
        if checkcaller() then 
            callsClock = callsClock + 1 
            if timeFrozen then 
                -- Micro-spoofing: Evita romper las mates del ofuscador
                fClock = fClock + 0.000001
                return fClock 
            end
        end
        return oldClock(...)
    end)
    writeLog("✅ Hook a os.clock exitoso.")
end)

writeLog("🚀 Sistema 100% Operativo. Esperando al trial...")
