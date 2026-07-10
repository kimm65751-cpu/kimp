-- ==========================================
-- SCANNER V6 + CONGELADOR (ULTRA STEALTH)
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LOG_FILE = "ScannerV6_Log.txt"

local function writeLog(msg)
    local timestamp = os.date("%H:%M:%S")
    local formatMsg = string.format("[%s] %s\n", timestamp, tostring(msg))
    if appendfile then pcall(function() appendfile(LOG_FILE, formatMsg) end)
    elseif writefile then pcall(function() writefile(LOG_FILE, formatMsg) end)
    else print(formatMsg) end
end

if writefile then pcall(function() writefile(LOG_FILE, "=== INICIO V6 ULTRA STEALTH ===\n") end) end

-- ==========================================
-- INTERFAZ MINIMALISTA
-- ==========================================
if CoreGui:FindFirstChild("ScannerPro") then CoreGui.ScannerPro:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScannerPro"
if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end 
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 160) -- Más pequeña ahora
MainFrame.Position = UDim2.new(1, -320, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = " 🕵️ 3Bypass V6 (Ultra Stealth)"
Title.Font = Enum.Font.Code
Title.TextSize = 16

local LblTime = Instance.new("TextLabel", MainFrame)
LblTime.Size = UDim2.new(1, -10, 0, 25)
LblTime.Position = UDim2.new(0, 10, 0, 40)
LblTime.BackgroundTransparency = 1
LblTime.TextColor3 = Color3.fromRGB(0, 255, 100)
LblTime.Text = "Consultas os.time: 0"
LblTime.Font = Enum.Font.Code
LblTime.TextSize = 14
LblTime.TextXAlignment = Enum.TextXAlignment.Left

local BtnFreeze = Instance.new("TextButton", MainFrame)
BtnFreeze.Size = UDim2.new(1, -20, 0, 40)
BtnFreeze.Position = UDim2.new(0, 10, 0, 90)
BtnFreeze.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
BtnFreeze.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnFreeze.Text = "❄️ CONGELAR MINUTOS ❄️"
BtnFreeze.Font = Enum.Font.Code
BtnFreeze.TextSize = 16

-- ==========================================
-- LÓGICA DE BYPASS (SOLO OS.TIME)
-- ==========================================
local timeFrozen = false
local fTime = 0
local callsTime = 0

BtnFreeze.MouseButton1Click:Connect(function()
    timeFrozen = not timeFrozen
    if timeFrozen then
        fTime = os.time()
        BtnFreeze.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        BtnFreeze.Text = "🔴 MINUTOS CONGELADOS 🔴"
        writeLog("❄️ TIEMPO CONGELADO ACTIVADO ❄️")
    else
        BtnFreeze.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        BtnFreeze.Text = "❄️ CONGELAR MINUTOS ❄️"
        writeLog("▶️ TIEMPO DESCONGELADO")
    end
end)

RunService.RenderStepped:Connect(function()
    LblTime.Text = "Consultas os.time: " .. callsTime
end)

task.spawn(function()
    while task.wait(5) do
        writeLog(string.format("Latido - os.time: %d", callsTime))
    end
end)

-- ==========================================
-- HOOK QUIRÚRGICO (INDETECTABLE)
-- ==========================================
writeLog("⚙️ Iniciando Hook Quirúrgico...")

pcall(function()
    local oldTime
    oldTime = hookfunction(os.time, newcclosure(function(...)
        callsTime = callsTime + 1 
        if timeFrozen then 
            return fTime 
        end
        return oldTime(...)
    end))
    writeLog("✅ Hook a os.time (C-Closure) exitoso. tick y os.clock ignorados por seguridad.")
end)

writeLog("🚀 Sistema Stealth Operativo. Ejecuta el trial.")
