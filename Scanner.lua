-- ==========================================
-- SCANNER PARA ANALIZAR TIMERS OFUSCADOS
-- ==========================================

local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- 1. Crear la GUI del Scanner
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScannerPro"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(1, -420, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = " 🕵️ Scanner Activo - Esperando Script..."
Title.TextSize = 16
Title.Font = Enum.Font.Code
Title.Parent = MainFrame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -70)
Scroll.Position = UDim2.new(0, 5, 0, 35)
Scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.UIListLayout = Instance.new("UIListLayout", Scroll)
Scroll.Parent = MainFrame

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(1, -10, 0, 25)
SaveBtn.Position = UDim2.new(0, 5, 1, -30)
SaveBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBtn.Text = "Guardar Log en TXT (workspace)"
SaveBtn.Font = Enum.Font.Code
SaveBtn.TextSize = 14
SaveBtn.Parent = MainFrame

-- 2. Sistema de Logs
local Logs = {}

local function AddLog(mensaje)
    table.insert(Logs, os.date("%X") .. " - " .. mensaje)
    
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 0, 20)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.fromRGB(0, 255, 100)
    txt.Text = os.date("%X") .. " | " .. mensaje
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.TextSize = 12
    txt.Font = Enum.Font.Code
    txt.Parent = Scroll
    
    Scroll.CanvasSize = UDim2.new(0, 0, 0, #Scroll:GetChildren() * 20)
    Scroll.CanvasPosition = Vector2.new(0, Scroll.CanvasSize.Y.Offset)
end

-- Botón para guardar a archivo TXT
SaveBtn.MouseButton1Click:Connect(function()
    if writefile then
        local content = table.concat(Logs, "\n")
        local filename = "ScannerLogs_Evomon_" .. tostring(os.time()) .. ".txt"
        writefile(filename, content)
        SaveBtn.Text = "¡Guardado como " .. filename .. "!"
        task.wait(2)
        SaveBtn.Text = "Guardar Log en TXT (workspace)"
    else
        SaveBtn.Text = "Tu ejecutor no soporta writefile"
    end
end)

AddLog("Scanner Iniciado. Ejecuta el script de NasiRendang ahora.")

-- ==========================================
-- 3. HOOKS (LOS ESPÍAS)
-- ==========================================

-- Espiar si el script pide la hora local (os.time)
local oldTime
oldTime = hookfunction(os.time, function(...)
    if checkcaller() then 
        AddLog("[TIEMPO] El script ha consultado os.time()")
    end
    return oldTime(...)
end)

local oldTick
oldTick = hookfunction(tick, function(...)
    if checkcaller() then 
        AddLog("[TIEMPO] El script ha consultado tick()")
    end
    return oldTick(...)
end)

-- Espiar si programa una expulsión a futuro (task.delay)
local oldDelay
oldDelay = hookfunction(task.delay, function(t, func, ...)
    if checkcaller() and type(t) == "number" then
        if t > 10 then -- Si retrasa una acción por más de 10 segundos, es sospechoso
            AddLog("[DELAY] Acción retrasada por " .. tostring(t) .. " segundos.")
        end
    end
    return oldDelay(t, func, ...)
end)

-- Espiar cambios en la GUI (Busca el texto del temporizador)
local oldNewIndex
oldNewIndex = hookmetamethod(game, "__newindex", function(self, index, value)
    if checkcaller() then
        if index == "Text" and type(value) == "string" then
            -- Filtramos si el texto tiene formato de tiempo "MM:SS" o palabras clave
            if string.match(value, "%d+:%d+") or string.match(string.lower(value), "trial") or string.match(string.lower(value), "time") then
                AddLog("[GUI TIMER] Texto detectado: " .. value)
            end
        end
    end
    return oldNewIndex(self, index, value)
end)

-- Espiar si intenta kickearte
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if (method == "Kick" or method == "kick") and self == game:GetService("Players").LocalPlayer then
        AddLog("[ALERTA] ¡El script intentó expulsarte! (KICK BLOQUEADO)")
        return nil -- Bloqueamos el kick para que sigas en el juego
    end
    return oldNamecall(self, ...)
end)
