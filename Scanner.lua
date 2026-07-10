-- ==========================================
-- SCANNER V3 (100% GUI PROTEGIDA)
-- ==========================================
local CoreGui = game:GetService("CoreGui")

-- Limpiar la GUI anterior si existe
if CoreGui:FindFirstChild("ScannerPro") then
    CoreGui.ScannerPro:Destroy()
end

-- 1. CREACIÓN DE LA INTERFAZ
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScannerPro"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 350)
MainFrame.Position = UDim2.new(1, -470, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = " 🕵️ Scanner Pro Activoxx    "
Title.TextSize = 16
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -70)
Scroll.Position = UDim2.new(0, 5, 0, 35)
Scroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Scroll.BorderSizePixel = 0
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y -- Para que baje automáticamente
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.ScrollBarThickness = 6
Scroll.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 2)
UIListLayout.Parent = Scroll

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(1, -10, 0, 25)
SaveBtn.Position = UDim2.new(0, 5, 1, -30)
SaveBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBtn.Text = "Guardar Log en TXT (workspace)"
SaveBtn.Font = Enum.Font.Code
SaveBtn.TextSize = 14
SaveBtn.Parent = MainFrame

-- 2. SISTEMA DE MENSAJES (LOGS)
local Logs = {}

local function AddLog(mensaje, color)
    table.insert(Logs, os.date("%X") .. " - " .. mensaje)
    
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 0, 18)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = color or Color3.fromRGB(0, 255, 100)
    txt.Text = " " .. os.date("%X") .. " | " .. mensaje
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.TextSize = 12
    txt.Font = Enum.Font.Code
    txt.Parent = Scroll
    
    -- Bajar la barra de scroll automáticamente
    task.spawn(function()
        task.wait(0.1)
        Scroll.CanvasPosition = Vector2.new(0, 999999)
    end)
end

-- Funcionalidad del botón de guardado
SaveBtn.MouseButton1Click:Connect(function()
    pcall(function()
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
end)

AddLog("Scanner Iniciado. Esperando a NasiRendang...", Color3.fromRGB(255, 255, 255))

-- ==========================================
-- 3. LOS ESPÍAS (HOOKS PROTEGIDOS)
-- ==========================================

-- A) Buscador activo del texto "Trial:"
task.spawn(function()
    while task.wait(2) do
        pcall(function()
            for _, obj in pairs(game:GetDescendants()) do
                if obj:IsA("TextLabel") and obj.Text then
                    if string.find(string.lower(obj.Text), "trial:") then
                        AddLog("[GUI] Timer capturado: " .. obj.Text, Color3.fromRGB(255, 255, 0))
                    end
                end
            end
        end)
    end
end)

-- B) Espiar las consultas de tiempo del script
pcall(function()
    local oldTime
    oldTime = hookfunction(os.time, function(...)
        if checkcaller() then AddLog("[TIEMPO] Consultó os.time()", Color3.fromRGB(0, 200, 255)) end
        return oldTime(...)
    end)
    AddLog("Espía de os.time: ONLINE", Color3.fromRGB(100, 255, 100))
end)

pcall(function()
    local oldTick
    oldTick = hookfunction(tick, function(...)
        if checkcaller() then AddLog("[TIEMPO] Consultó tick()", Color3.fromRGB(0, 200, 255)) end
        return oldTick(...)
    end)
    AddLog("Espía de tick: ONLINE", Color3.fromRGB(100, 255, 100))
end)

pcall(function()
    local oldClock
    oldClock = hookfunction(os.clock, function(...)
        if checkcaller() then AddLog("[TIEMPO] Consultó os.clock()", Color3.fromRGB(0, 200, 255)) end
        return oldClock(...)
    end)
    AddLog("Espía de os.clock: ONLINE", Color3.fromRGB(100, 255, 100))
end)

-- C) Evitar la expulsión (Anti-Kick)
pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if (method == "Kick" or method == "kick") and self == game:GetService("Players").LocalPlayer then
            AddLog("[ALERTA] ¡El script intentó expulsarte! (Bloqueado)", Color3.fromRGB(255, 50, 50))
            return nil
        end
        return oldNamecall(self, ...)
    end)
    AddLog("Protección Anti-Kick: ONLINE", Color3.fromRGB(100, 255, 100))
end)
