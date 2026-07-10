-- ==========================================
-- SCANNER V5 + CONGELADOR + LOGGER (.txt)
-- MODO STEALTH (Bypass de Ofuscadores Agresivos)
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LOG_FILE = "ScannerV5_Log.txt"

-- ==========================================
-- 1. SISTEMA DE LOGS (ESCRITURA EN .TXT)
-- ==========================================
local function writeLog(msg)
    local timestamp = os.date("%H:%M:%S")
    local formatMsg = string.format("[%s] %s\n", timestamp, tostring(msg))
    
    if appendfile then
        pcall(function() appendfile(LOG_FILE, formatMsg) end)
    elseif writefile then 
        pcall(function() writefile(LOG_FILE, formatMsg) end)
    else
        print(formatMsg) 
    end
end

if writefile then
    pcall(function() writefile(LOG_FILE, "=== INICIO DE SESION SCANNER V5 (STEALTH) ===\n") end)
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
Title.Text = " 🕵️ Scanner & Bypass V5"
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
-- Dejamos la etiqueta de os.clock visualmente, pero ya no la hookeamos
local LblClock = createLabel(100, "os.clock: (Ignorado por Seguridad)")

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
local fTime, fTick = 0, 0
local callsTime, callsTick = 0, 0

BtnFreeze.MouseButton1Click:Connect(function()
    timeFrozen = not timeFrozen
    if timeFrozen then
        fTime = os.time()
        fTick = tick()
        BtnFreeze.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        BtnFreeze.Text = "🔴 TIEMPO CONGELADO 🔴"
        writeLog("❄️ TIEMPO CONGELADO ACTIVADO ❄️")
    else
        BtnFreeze.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        BtnFreeze.Text = "❄️ CONGELAR TIEMPO ❄️"
        writeLog("▶️ TIEMPO DESCONGELADO")
    end
end)

-- Actualización visual
RunService.RenderStepped:Connect(function()
    LblTime.Text = "Consultas os.time: " .. callsTime
    LblTick.Text = "Consultas tick: " .. callsTick
end)

-- Latido para el log
task.spawn(function()
    local lastCallsTick = 0
    while task.wait(1) do
        local tickDiff = callsTick - lastCallsTick
        if tickDiff > 5000 then
            writeLog("⚠️ CRITICO: Posible Bucle Infinito detectado (" .. tickDiff .. " llamadas a tick).")
        end
        lastCallsTick = callsTick
        writeLog(string.format("Latido - os.time: %d | tick: %d", callsTime, callsTick))
    end
end)

-- ==========================================
-- 4. HOOKS INDETECTABLES (MODO STEALTH)
-- ==========================================
writeLog("⚙️ Iniciando Hooks Stealth...")

pcall(function()
    local oldTime
    oldTime = hookfunction(os.time, newcclosure(function(...)
        callsTime = callsTime + 1 
        if timeFrozen then 
            return fTime 
        end
        return oldTime(...)
    end))
    writeLog("✅ Hook a os.time aplicado globalmente.")
end)

pcall(function()
    local oldTick
    oldTick = hookfunction(tick, newcclosure(function(...)
        callsTick = callsTick + 1 
        if timeFrozen then 
            fTick = fTick + 0.000001
            return fTick 
        end
        return oldTick(...)
    end))
    writeLog("✅ Hook a tick aplicado globalmente.")
end)

writeLog("🚀 Sistema Stealth 100% Operativo. Ejecuta el trial ahora.")
