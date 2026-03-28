-- ==============================================================================
-- 🎰 RACE SPIN FORENSIC ANALYZER V1.3 (INVESTIGADOR PROFUNDO)
-- SIN HOOK. Llamamos Reroll DIRECTAMENTE para investigar el flujo.
-- ==============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- REFERENCIA DIRECTA AL REMOTE DE REROLL
-- ==========================================
local RerollRF = ReplicatedStorage.Shared.Packages.Knit.Services.RaceService.RF.Reroll
local SwitchSlotRF = ReplicatedStorage.Shared.Packages.Knit.Services.RaceService.RF.SwitchSlot

-- ==========================================
-- GUI
-- ==========================================
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "RaceAnalyzerUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RaceAnalyzerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 620, 0, 520)
Panel.Position = UDim2.new(0, 20, 0.5, -260)
Panel.BackgroundColor3 = Color3.fromRGB(10, 5, 20)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(255, 200, 50)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(120, 80, 0)
Title.Text = " 🎰 RACE ANALYZER V1.3 (INVESTIGADOR PROFUNDO)"
Title.TextColor3 = Color3.fromRGB(255, 230, 150)
Title.TextSize = 13
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Panel

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.Code
CloseBtn.TextSize = 16
CloseBtn.Parent = Panel
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- BOTÓN 1: TEST REROLL (Llamada directa, sin tocar el juego)
local TestRerollBtn = Instance.new("TextButton")
TestRerollBtn.Size = UDim2.new(0.5, -6, 0, 40)
TestRerollBtn.Position = UDim2.new(0, 4, 0, 35)
TestRerollBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 200)
TestRerollBtn.Text = "🎲 TEST REROLL (Llamada Directa)"
TestRerollBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TestRerollBtn.Font = Enum.Font.Code
TestRerollBtn.TextSize = 11
TestRerollBtn.Parent = Panel

-- BOTÓN 2: ESCANEAR PASIVAMENTE
local ScanBtn = Instance.new("TextButton")
ScanBtn.Size = UDim2.new(0.5, -6, 0, 40)
ScanBtn.Position = UDim2.new(0.5, 2, 0, 35)
ScanBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
ScanBtn.Text = "🔍 OBSERVAR GUI + EVENTOS"
ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanBtn.Font = Enum.Font.Code
ScanBtn.TextSize = 11
ScanBtn.Parent = Panel

-- BOTÓN 3: MULTI-SPIN hasta encontrar raza
local AutoSpinBtn = Instance.new("TextButton")
AutoSpinBtn.Size = UDim2.new(1, -8, 0, 35)
AutoSpinBtn.Position = UDim2.new(0, 4, 0, 80)
AutoSpinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AutoSpinBtn.Text = "⚡ AUTO-SPIN (Primero investiga con TEST REROLL)"
AutoSpinBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
AutoSpinBtn.Font = Enum.Font.Code
AutoSpinBtn.TextSize = 11
AutoSpinBtn.Parent = Panel

-- Controles inferiores
local ControlsFrame = Instance.new("Frame")
ControlsFrame.Size = UDim2.new(1, -8, 0, 30)
ControlsFrame.Position = UDim2.new(0, 4, 1, -34)
ControlsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ControlsFrame.Parent = Panel

local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0.33, -2, 1, 0)
ClearBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ClearBtn.Text = "🗑️ LIMPIAR"
ClearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearBtn.Font = Enum.Font.Code
ClearBtn.TextSize = 11
ClearBtn.Parent = ControlsFrame

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0.33, -2, 1, 0)
CopyBtn.Position = UDim2.new(0.33, 2, 0, 0)
CopyBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 150)
CopyBtn.Text = "📋 COPIAR"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.Code
CopyBtn.TextSize = 11
CopyBtn.Parent = ControlsFrame

local SaveTxtBtn = Instance.new("TextButton")
SaveTxtBtn.Size = UDim2.new(0.34, -2, 1, 0)
SaveTxtBtn.Position = UDim2.new(0.66, 2, 0, 0)
SaveTxtBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
SaveTxtBtn.Text = "💾 GUARDAR .TXT"
SaveTxtBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveTxtBtn.Font = Enum.Font.Code
SaveTxtBtn.TextSize = 11
SaveTxtBtn.Parent = ControlsFrame

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -8, 1, -155)
LogScroll.Position = UDim2.new(0, 4, 0, 120)
LogScroll.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogScroll.ScrollBarThickness = 6
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.Parent = Panel
Instance.new("UIListLayout", LogScroll).Padding = UDim.new(0, 2)

-- ==========================================
-- SISTEMA DE LOGS
-- ==========================================
local MasterLogList = {}
local LOG_FILENAME = "RaceSpinLog.txt"

local function SmartDump(val, depth)
    depth = depth or 0
    if depth > 6 then return "{...}" end
    local t = typeof(val)
    if t == "Instance" then
        return "<Inst:" .. val:GetFullName() .. ">"
    elseif t == "table" then
        local parts = {}
        local count = 0
        for k, v in pairs(val) do
            count = count + 1
            if count > 30 then table.insert(parts, "...(+" .. (count) .. " más)"); break end
            table.insert(parts, "[" .. tostring(k) .. "]=" .. SmartDump(v, depth + 1))
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    elseif t == "string" then
        return '"' .. tostring(val) .. '"'
    else
        return tostring(val)
    end
end

local function WriteToFile(text)
    pcall(function()
        if writefile then
            local ok, existing = pcall(readfile, LOG_FILENAME)
            if ok and type(existing) == "string" then
                writefile(LOG_FILENAME, existing .. text .. "\n")
            else
                writefile(LOG_FILENAME, text .. "\n")
            end
        end
    end)
end

local function AddLog(logType, message, color)
    local ts = "[" .. os.date("%H:%M:%S") .. "]"
    local fullString = ts .. " [" .. logType .. "] " .. message
    table.insert(MasterLogList, fullString)
    WriteToFile(fullString)
    if #MasterLogList > 500 then table.remove(MasterLogList, 1) end
    task.defer(function()
        pcall(function()
            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1, -4, 0, 0)
            txt.BackgroundTransparency = 1
            txt.Text = fullString
            txt.TextColor3 = color or Color3.fromRGB(200, 200, 200)
            txt.Font = Enum.Font.Code
            txt.TextSize = 10
            txt.TextXAlignment = Enum.TextXAlignment.Left
            txt.TextWrapped = true
            txt.Parent = LogScroll
            local tsz = game:GetService("TextService"):GetTextSize(txt.Text, txt.TextSize, txt.Font, Vector2.new(LogScroll.AbsoluteSize.X - 15, math.huge))
            txt.Size = UDim2.new(1, -4, 0, tsz.Y + 4)
            LogScroll.CanvasPosition = Vector2.new(0, 999999)
        end)
    end)
end

-- ==========================================
-- BOTONES DE CONTROL
-- ==========================================
ClearBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(LogScroll:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
    MasterLogList = {}
end)

CopyBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local r = "=== RACE ANALYZER V1.3 LOG ===\n\n"
        for _, l in ipairs(MasterLogList) do r = r .. l .. "\n" end
        if setclipboard then
            setclipboard(r)
            CopyBtn.Text = "✅ OK"
        end
    end)
    task.delay(2, function() pcall(function() CopyBtn.Text = "📋 COPIAR" end) end)
end)

SaveTxtBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local r = "=== RACE ANALYZER V1.3 FORENSE ===\n" .. os.date("%Y-%m-%d %H:%M:%S") .. "\n\n"
        for _, l in ipairs(MasterLogList) do r = r .. l .. "\n" end
        writefile(LOG_FILENAME, r)
        SaveTxtBtn.Text = "✅ OK"
        AddLog("FILE", "Guardado: " .. LOG_FILENAME, Color3.fromRGB(100, 255, 100))
    end)
    task.delay(3, function() pcall(function() SaveTxtBtn.Text = "💾 GUARDAR .TXT" end) end)
end)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- ==========================================
-- OBSERVADOR PASIVO (Sin hook, sin interferir)
-- ==========================================
ScanBtn.MouseButton1Click:Connect(function()
    AddLog("SCAN", "══════════════════════════════════", Color3.fromRGB(255, 200, 100))
    AddLog("SCAN", "Conectando observadores PASIVOS...", Color3.fromRGB(255, 200, 100))
    
    -- Vigilar GUI de Raza
    pcall(function()
        local raceUI = LocalPlayer.PlayerGui:FindFirstChild("Sell")
        if raceUI then
            raceUI = raceUI:FindFirstChild("RaceUI")
            if raceUI then
                local cr = raceUI:FindFirstChild("CurrentRace")
                if cr and cr:IsA("TextLabel") then
                    AddLog("GUI", "👁️ Vigilando CurrentRace: " .. cr.Text, Color3.fromRGB(255, 255, 0))
                    cr:GetPropertyChangedSignal("Text"):Connect(function()
                        AddLog("RACE_GUI", "🎲 RAZA EN PANTALLA: " .. cr.Text, Color3.fromRGB(255, 50, 255))
                    end)
                end
                local rr = raceUI:FindFirstChild("Reroll")
                if rr then
                    local sp = rr:FindFirstChild("Spins")
                    if sp and sp:IsA("TextLabel") then
                        AddLog("GUI", "👁️ Vigilando Spins: " .. sp.Text, Color3.fromRGB(255, 255, 0))
                        sp:GetPropertyChangedSignal("Text"):Connect(function()
                            AddLog("SPINS_GUI", "🎰 Spins: " .. sp.Text, Color3.fromRGB(255, 200, 0))
                        end)
                    end
                end
            end
        end
    end)
    
    -- Escuchar TODOS los RemoteEvents de Knit
    local evtCount = 0
    pcall(function()
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                local fLower = string.lower(v:GetFullName())
                if string.find(fLower, "knit") then
                    evtCount = evtCount + 1
                    v.OnClientEvent:Connect(function(...)
                        local args = {...}
                        local dump = ""
                        for i, val in ipairs(args) do dump = dump .. " [" .. i .. "]=" .. SmartDump(val) end
                        AddLog("EVT", "📢 " .. v.Name .. " >>" .. dump, Color3.fromRGB(255, 255, 100))
                    end)
                end
            end
        end
    end)
    
    AddLog("SCAN", "✅ " .. evtCount .. " eventos Knit conectados.", Color3.fromRGB(0, 255, 0))
    AddLog("SCAN", "Ahora usa TEST REROLL o Reiniciar del juego.", Color3.fromRGB(255, 255, 0))
end)

-- ==========================================
-- TEST REROLL: Llamada DIRECTA (sin hook, desde nuestro hilo)
-- ==========================================
TestRerollBtn.MouseButton1Click:Connect(function()
    AddLog("TEST", "══════════════════════════════════", Color3.fromRGB(255, 100, 255))
    AddLog("TEST", "🎲 Llamando Reroll:InvokeServer() DIRECTAMENTE...", Color3.fromRGB(255, 100, 255))
    AddLog("TEST", "⏳ Esperando respuesta del servidor...", Color3.fromRGB(255, 200, 0))
    
    task.spawn(function()
        local t0 = tick()
        local success, result = pcall(function()
            return RerollRF:InvokeServer()
        end)
        local elapsed = tick() - t0
        
        AddLog("TEST", "⏱️ Tiempo de respuesta: " .. string.format("%.3f", elapsed) .. "s", Color3.fromRGB(200, 200, 200))
        
        if success then
            AddLog("TEST", "✅ RESPUESTA EXITOSA del servidor:", Color3.fromRGB(0, 255, 0))
            AddLog("TEST", "   Tipo: " .. typeof(result), Color3.fromRGB(0, 255, 200))
            AddLog("TEST", "   Valor: " .. SmartDump(result), Color3.fromRGB(0, 255, 200))
            
            -- Si es tabla, desglosar cada campo
            if type(result) == "table" then
                AddLog("TEST", "   === DESGLOSE DE TABLA ===", Color3.fromRGB(255, 255, 0))
                for k, v in pairs(result) do
                    AddLog("TEST", "   [" .. tostring(k) .. "] = " .. SmartDump(v), Color3.fromRGB(255, 200, 100))
                end
            elseif type(result) == "string" then
                AddLog("TEST", "   🎯 RAZA RECIBIDA: " .. result, Color3.fromRGB(255, 50, 255))
            end
        else
            AddLog("TEST", "❌ ERROR: " .. tostring(result), Color3.fromRGB(255, 0, 0))
        end
        
        -- Verificar estado POST-reroll
        AddLog("TEST", "── POST-REROLL ESTADO ──", Color3.fromRGB(200, 200, 200))
        pcall(function()
            local raceUI = LocalPlayer.PlayerGui:FindFirstChild("Sell")
            if raceUI then
                raceUI = raceUI:FindFirstChild("RaceUI")
                if raceUI then
                    local cr = raceUI:FindFirstChild("CurrentRace")
                    if cr then AddLog("TEST", "   GUI CurrentRace: " .. cr.Text, Color3.fromRGB(255, 200, 255)) end
                    local rr = raceUI:FindFirstChild("Reroll")
                    if rr then
                        local sp = rr:FindFirstChild("Spins")
                        if sp then AddLog("TEST", "   GUI Spins: " .. sp.Text, Color3.fromRGB(255, 200, 0)) end
                    end
                end
            end
        end)
        
        -- Verificar atributos del jugador
        pcall(function()
            local race = LocalPlayer:GetAttribute("Race")
            if race then AddLog("TEST", "   Atributo Race: " .. tostring(race), Color3.fromRGB(0, 255, 255)) end
            local spins = LocalPlayer:GetAttribute("Spins")
            if spins then AddLog("TEST", "   Atributo Spins: " .. tostring(spins), Color3.fromRGB(0, 255, 255)) end
        end)
        
        AddLog("TEST", "══════════════════════════════════", Color3.fromRGB(255, 100, 255))
        AddLog("TEST", "Ahora verifica: ¿Cambió tu raza? ¿Se gastó un giro?", Color3.fromRGB(255, 255, 0))
        AddLog("TEST", "Si NO cambió y NO se gastó = podemos explotar esto.", Color3.fromRGB(255, 255, 0))
    end)
end)

-- ==========================================
-- AUTO-SPIN PLACEHOLDER (Se activa después de investigar)
-- ==========================================
AutoSpinBtn.MouseButton1Click:Connect(function()
    AddLog("INFO", "⚡ Primero usa TEST REROLL para confirmar el comportamiento.", Color3.fromRGB(255, 200, 0))
    AddLog("INFO", "Necesitamos saber qué devuelve el servidor antes de automatizar.", Color3.fromRGB(255, 200, 0))
end)

-- ==========================================
-- INICIALIZACIÓN
-- ==========================================
pcall(function() writefile(LOG_FILENAME, "=== RACE ANALYZER V1.3 INICIADO " .. os.date("%Y-%m-%d %H:%M:%S") .. " ===\n") end)

AddLog("SISTEMA", "🎰 V1.3 INVESTIGADOR PROFUNDO cargado.", Color3.fromRGB(150, 255, 150))
AddLog("SISTEMA", "SIN HOOK. No se interferirá con el juego.", Color3.fromRGB(150, 255, 150))
AddLog("SISTEMA", "══════════════════════════════════", Color3.fromRGB(255, 200, 100))
AddLog("SISTEMA", "PASO 1: Presiona 🔍 OBSERVAR para conectar listeners.", Color3.fromRGB(255, 255, 200))
AddLog("SISTEMA", "PASO 2: Presiona 🎲 TEST REROLL para llamar directo al servidor.", Color3.fromRGB(255, 255, 200))
AddLog("SISTEMA", "PASO 3: Revisa si cambió tu raza y si se gastó un giro.", Color3.fromRGB(255, 255, 200))
AddLog("SISTEMA", "══════════════════════════════════", Color3.fromRGB(255, 200, 100))
AddLog("SISTEMA", "HIPÓTESIS: Si el Reroll directo NO guarda la raza,", Color3.fromRGB(255, 200, 0))
AddLog("SISTEMA", "podemos girar GRATIS hasta encontrar Arcángel.", Color3.fromRGB(255, 200, 0))
