-- ==========================================
-- SCANNER V4 + CONGELADOR DE TIEMPO
-- ==========================================
local CoreGui = game:GetService("CoreGui")

if CoreGui:FindFirstChild("ScannerPro") then 
    CoreGui.ScannerPro:Destroy() 
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScannerPro"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 220)
MainFrame.Position = UDim2.new(1, -320, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = " 🕵️ Scanner & Bypass"
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

local LblTick = Instance.new("TextLabel", MainFrame)
LblTick.Size = UDim2.new(1, -10, 0, 25)
LblTick.Position = UDim2.new(0, 10, 0, 70)
LblTick.BackgroundTransparency = 1
LblTick.TextColor3 = Color3.fromRGB(0, 255, 100)
LblTick.Text = "Consultas tick: 0"
LblTick.Font = Enum.Font.Code
LblTick.TextSize = 14
LblTick.TextXAlignment = Enum.TextXAlignment.Left

local LblClock = Instance.new("TextLabel", MainFrame)
LblClock.Size = UDim2.new(1, -10, 0, 25)
LblClock.Position = UDim2.new(0, 10, 0, 100)
LblClock.BackgroundTransparency = 1
LblClock.TextColor3 = Color3.fromRGB(0, 255, 100)
LblClock.Text = "Consultas os.clock: 0"
LblClock.Font = Enum.Font.Code
LblClock.TextSize = 14
LblClock.TextXAlignment = Enum.TextXAlignment.Left

local BtnFreeze = Instance.new("TextButton", MainFrame)
BtnFreeze.Size = UDim2.new(1, -20, 0, 40)
BtnFreeze.Position = UDim2.new(0, 10, 0, 150)
BtnFreeze.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
BtnFreeze.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnFreeze.Text = "❄️ CONGELAR TIEMPO ❄️"
BtnFreeze.Font = Enum.Font.Code
BtnFreeze.TextSize = 16

-- ==========================================
-- LÓGICA DE BYPASS
-- ==========================================
local timeFrozen = false
local fTime, fTick, fClock = 0, 0, 0
local callsTime, callsTick, callsClock = 0, 0, 0

BtnFreeze.MouseButton1Click:Connect(function()
    if not timeFrozen then
        timeFrozen = true
        fTime = os.time()
        fTick = tick()
        fClock = os.clock()
        BtnFreeze.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        BtnFreeze.Text = "🔴 TIEMPO CONGELADO 🔴"
    else
        timeFrozen = false
        BtnFreeze.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        BtnFreeze.Text = "❄️ CONGELAR TIEMPO ❄️"
    end
end)

-- Actualizar los textos cada 0.2 segundos (evita el lag)
task.spawn(function()
    while task.wait(0.2) do
        LblTime.Text = "Consultas os.time: " .. tostring(callsTime)
        LblTick.Text = "Consultas tick: " .. tostring(callsTick)
        LblClock.Text = "Consultas os.clock: " .. tostring(callsClock)
    end
end)

-- Hooks invisibles que no congelan el juego
pcall(function()
    local oldTime
    oldTime = hookfunction(os.time, function(...)
        if checkcaller() then 
            callsTime = callsTime + 1 
            if timeFrozen then return fTime end
        end
        return oldTime(...)
    end)
end)

pcall(function()
    local oldTick
    oldTick = hookfunction(tick, function(...)
        if checkcaller() then 
            callsTick = callsTick + 1 
            if timeFrozen then return fTick end
        end
        return oldTick(...)
    end)
end)

pcall(function()
    local oldClock
    oldClock = hookfunction(os.clock, function(...)
        if checkcaller() then 
            callsClock = callsClock + 1 
            if timeFrozen then return fClock end
        end
        return oldClock(...)
    end)
end)
