-- ==========================================
-- SCANNER V4 + CONGELADOR + LOGGER (.txt)
-- OPTIMIZADO PARA DELTA Y BYPASS DE OFUSCADORES
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
    
    -- Manejo seguro para escritura de archivos en Delta
    if appendfile then
        pcall(function() appendfile(LOG_FILE, formatMsg) end)
    elseif writefile then 
        pcall(function() writefile(LOG_FILE, formatMsg) end)
    else
        print(formatMsg) 
    end
end

-- Limpiamos e iniciamos el archivo de texto
if writefile then
    pcall(function() writefile(LOG_FILE, "=== INICIO DE SESION SCANNER V4 ===\n") end)
end
writeLog("✅ Interfaz y Logger Iniciados Exitosamente.")

-- ==========================================
-- 2. CREACIÓN DE INTERFAZ (GUI)
-- ==========================================
if CoreGui:FindFirstChild("ScannerPro") then 
    CoreGui.ScannerPro:Destroy() 
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScannerPro"
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
Title.Text = " 🕵️ aa Scanner & Bypass V4"
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
-- 3. LÓGICA DE BYPASS Y MONITOREO
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

-- Actualización visual sin causar lag
RunService.RenderStepped:Connect(function()
    LblTime.Text = "Consultas os.time: " .. callsTime
    LblTick.Text = "Consultas tick: " .. callsTick
    LblClock.Text = "Consultas os.clock: " .. callsClock
end)

-- Latido para verificar si el juego se congela (se guarda en el .txt)
task.spawn(function()
    local lastCallsTick = 0
    while task.wait(1) do
        local tickDiff = callsTick - lastCallsTick
        if tickDiff > 5000 then
            writeLog("⚠️ CRITICO: Posible Bucle Infinito detectado (" .. tickDiff .. " llamadas a tick en 1 seg). ¡El trial detectó manipulación!")
        end
        lastCallsTick = callsTick
        writeLog(string.format("Latido - os.time: %d | tick: %d | os.clock: %d", callsTime, callsTick, callsClock))
    end
end)

-- ==========================================
-- 4. HOOKS INDETECTABLES (C-CLOSURES)
-- ==========================================
writeLog("⚙️ Iniciando Hooks indetectables...")

pcall(function()
    local oldTime
    -- newcclosure evita que el ofuscador vea que alteramos la función original
    oldTime = hookfunction(os.time, newcclosure(function(...)
        if checkcaller() then 
            callsTime = callsTime + 1 
            if timeFrozen then return fTime end 
        end
        return oldTime(...)
    end))
    writeLog("✅ Hook a os.time (C-Closure) exitoso.")
end)

pcall(function()
    local oldTick
    oldTick = hookfunction(tick, newcclosure(function(...)
        if checkcaller() then 
            callsTick = callsTick + 1 
            if timeFrozen then 
                fTick = fTick + 0.000001 -- Avance milimétrico para no romper matemáticas
                return fTick 
            end
        end
        return oldTick(...)
    end))
    writeLog("✅ Hook a tick (C-Closure) exitoso.")
end)

pcall(function()
    local oldClock
    oldClock = hookfunction(os.clock, newcclosure(function(...)
        if checkcaller() then 
            callsClock = callsClock + 1 
            if timeFrozen then 
                fClock = fClock + 0.000001 -- Avance milimétrico
                return fClock 
            end
        end
        return oldClock(...)
    end))
    writeLog("✅ Hook a os.clock (C-Closure) exitoso.")
end)

writeLog("🚀 Sistema 100% Operativo. Esperando al trial...")
