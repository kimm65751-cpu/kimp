-- ==============================================================================
-- 🎰 RACE SPIN FORENSIC ANALYZER V1.1
-- Captura perfecta del Reroll, filtro de ruido, y guardado .TXT en Delta.
-- ==============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "RaceAnalyzerUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RaceAnalyzerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 620, 0, 500)
Panel.Position = UDim2.new(0, 20, 0.5, -250)
Panel.BackgroundColor3 = Color3.fromRGB(10, 5, 20)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(200, 100, 255)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(80, 20, 120)
Title.Text = " 🎰 RACE SPIN ANALYZER V1.2 (JERÁRQUICO)"
Title.TextColor3 = Color3.fromRGB(255, 180, 255)
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

local ScanBtn = Instance.new("TextButton")
ScanBtn.Size = UDim2.new(0.5, -6, 0, 35)
ScanBtn.Position = UDim2.new(0, 4, 0, 35)
ScanBtn.BackgroundColor3 = Color3.fromRGB(120, 50, 200)
ScanBtn.Text = "🔍 FASE 1: ESCANEAR REMOTOS"
ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanBtn.Font = Enum.Font.Code
ScanBtn.TextSize = 11
ScanBtn.Parent = Panel

local InterceptBtn = Instance.new("TextButton")
InterceptBtn.Size = UDim2.new(0.5, -6, 0, 35)
InterceptBtn.Position = UDim2.new(0.5, 2, 0, 35)
InterceptBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
InterceptBtn.Text = "📡 FASE 2: ACTIVAR INTERCEPTOR"
InterceptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
InterceptBtn.Font = Enum.Font.Code
InterceptBtn.TextSize = 11
InterceptBtn.Parent = Panel

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
LogScroll.Size = UDim2.new(1, -8, 1, -110)
LogScroll.Position = UDim2.new(0, 4, 0, 75)
LogScroll.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogScroll.ScrollBarThickness = 6
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.Parent = Panel
Instance.new("UIListLayout", LogScroll).Padding = UDim.new(0, 2)

-- ==========================================
-- SISTEMA DE LOGS Y ARCHIVO
-- ==========================================
local MasterLogList = {}
local LOG_FILENAME = "RaceSpinLog.txt"

local function SmartDump(val, depth)
    depth = depth or 0
    if depth > 6 then return "{...}" end
    local t = typeof(val)
    if t == "Instance" then
        return "<Instance:" .. val:GetFullName() .. ">"
    elseif t == "table" then
        local parts = {}
        local seen = {}
        for k, v in pairs(val) do
            if seen[tostring(k)] then table.insert(parts, "[DUP]") 
            else
                seen[tostring(k)] = true
                table.insert(parts, "[" .. tostring(k) .. "]=" .. SmartDump(v, depth + 1))
            end
        end
        return "{\n" .. string.rep("  ", depth+1) .. table.concat(parts, ",\n" .. string.rep("  ", depth+1)) .. "\n" .. string.rep("  ", depth) .. "}"
    elseif t == "string" then
        return '"' .. val .. '"'
    else
        return tostring(val)
    end
end

local function WriteToFile(text)
    pcall(function()
        if writefile then
            local ok, existing = pcall(readfile, LOG_FILENAME)
            if ok then
                writefile(LOG_FILENAME, existing .. text .. "\n")
            else
                writefile(LOG_FILENAME, text .. "\n")
            end
        end
    end)
end

local function AddLog(logType, message, color)
    local ts = "[" .. os.date("%H:%M:%S") .. "." .. string.format("%03d", math.floor(tick()*1000)%1000) .. "]"
    local fullString = ts .. " [" .. logType .. "] " .. message
    table.insert(MasterLogList, fullString)
    WriteToFile(fullString)
    if #MasterLogList > 800 then table.remove(MasterLogList, 1) end
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
            local ts2 = game:GetService("TextService"):GetTextSize(txt.Text, txt.TextSize, txt.Font, Vector2.new(LogScroll.AbsoluteSize.X - 15, math.huge))
            txt.Size = UDim2.new(1, -4, 0, ts2.Y + 4)
            LogScroll.CanvasPosition = Vector2.new(0, 999999)
        end)
    end)
end

ClearBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(LogScroll:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
    MasterLogList = {}
end)
CopyBtn.MouseButton1Click:Connect(function()
    local r = "=== RACE SPIN ANALYZER V1.1 ===\n\n"
    for _, l in ipairs(MasterLogList) do r = r .. l .. "\n" end
    if setclipboard then setclipboard(r); CopyBtn.Text = "✅ OK" else CopyBtn.Text = "❌" end
    task.delay(2, function() CopyBtn.Text = "📋 COPIAR" end)
end)
SaveTxtBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local r = "=== RACE SPIN ANALYZER - FORENSE ===\nFecha: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\nLineas: " .. #MasterLogList .. "\n===\n\n"
        for _, l in ipairs(MasterLogList) do r = r .. l .. "\n" end
        writefile(LOG_FILENAME, r)
        SaveTxtBtn.Text = "✅ GUARDADO"
        AddLog("FILE", "💾 Guardado: " .. LOG_FILENAME, Color3.fromRGB(100, 255, 100))
    end)
    task.delay(3, function() SaveTxtBtn.Text = "💾 GUARDAR .TXT" end)
end)

-- ==========================================
-- FASE 1: ESCANEO
-- ==========================================
local RaceRemotes = {}

ScanBtn.MouseButton1Click:Connect(function()
    AddLog("SCAN", "══════════════════════════════════", Color3.fromRGB(255, 200, 100))
    AddLog("SCAN", "INICIANDO ESCANEO...", Color3.fromRGB(255, 200, 100))
    
    local keywords = {"race", "spin", "reroll", "slot", "raza", "reincarnate", "rebirth", "class"}
    local foundCount = 0
    
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        pcall(function()
            if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
                local fullLower = string.lower(obj:GetFullName())
                for _, kw in pairs(keywords) do
                    if string.find(fullLower, kw) then
                        foundCount = foundCount + 1
                        local tp = obj:IsA("RemoteFunction") and "RF" or "RE"
                        RaceRemotes[obj.Name] = obj
                        AddLog("FOUND", "🎯 [" .. tp .. "] " .. obj:GetFullName(), Color3.fromRGB(0, 255, 200))
                        
                        if obj:IsA("RemoteEvent") then
                            obj.OnClientEvent:Connect(function(...)
                                local args = {...}
                                local dump = ""
                                for i, val in ipairs(args) do dump = dump .. " Arg[" .. i .. "]=" .. SmartDump(val) end
                                AddLog("RE_IN", "📥 " .. obj.Name .. " >>" .. dump, Color3.fromRGB(0, 255, 100))
                            end)
                        end
                        break
                    end
                end
            end
        end)
    end
    
    -- Buscar GUI de Raza para monitorear cambios
    pcall(function()
        local raceUI = LocalPlayer.PlayerGui:FindFirstChild("Sell")
        if raceUI then
            raceUI = raceUI:FindFirstChild("RaceUI")
            if raceUI then
                local currentRace = raceUI:FindFirstChild("CurrentRace")
                if currentRace and currentRace:IsA("TextLabel") then
                    AddLog("GUI_WATCH", "👁️ Vigilando cambios en CurrentRace: " .. currentRace.Text, Color3.fromRGB(255, 255, 0))
                    currentRace:GetPropertyChangedSignal("Text"):Connect(function()
                        AddLog("RACE_CHANGED", "🎲 ¡¡¡RAZA CAMBIÓ EN PANTALLA!!! Nuevo: " .. currentRace.Text, Color3.fromRGB(255, 50, 255))
                    end)
                end
                local spinsLabel = raceUI:FindFirstChild("Reroll")
                if spinsLabel then
                    spinsLabel = spinsLabel:FindFirstChild("Spins")
                    if spinsLabel and spinsLabel:IsA("TextLabel") then
                        AddLog("GUI_WATCH", "👁️ Vigilando Spins: " .. spinsLabel.Text, Color3.fromRGB(255, 255, 0))
                        spinsLabel:GetPropertyChangedSignal("Text"):Connect(function()
                            AddLog("SPINS_CHANGED", "🎰 Spins cambió: " .. spinsLabel.Text, Color3.fromRGB(255, 200, 0))
                        end)
                    end
                end
            end
        end
    end)
    
    AddLog("SCAN", "✅ " .. foundCount .. " remotos encontrados.", Color3.fromRGB(0, 255, 0))
    AddLog("SCAN", "Ahora activa FASE 2 y presiona Reiniciar.", Color3.fromRGB(255, 255, 0))
end)

-- ==========================================
-- FASE 2: INTERCEPTOR (Mejorado V2)
-- ==========================================
local InterceptorActivo = false
local GlobalOriginalNamecall = nil

InterceptBtn.MouseButton1Click:Connect(function()
    InterceptorActivo = not InterceptorActivo
    if InterceptorActivo then
        InterceptBtn.Text = "📡 INTERCEPTOR: ON 🔴"
        InterceptBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        AddLog("INTERCEPT", "🔴 INTERCEPTOR ACTIVADO.", Color3.fromRGB(255, 100, 100))
        
        if not GlobalOriginalNamecall then
            GlobalOriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                
                if not InterceptorActivo then
                    return GlobalOriginalNamecall(self, ...)
                end
                
                if not checkcaller() and (method == "InvokeServer" or method == "FireServer") then
                    local selfName = ""
                    local fullName = ""
                    pcall(function() selfName = self.Name; fullName = self:GetFullName() end)
                    local fullLower = string.lower(fullName)
                    
                    -- FILTRO DURO: ruido
                    local hardBlock = {"move", "mouse", "camera", "ping", "render", "step", "chat", "position", "look", "heartbeat"}
                    local isBlocked = false
                    for _, nw in pairs(hardBlock) do
                        if string.find(fullLower, nw) then isBlocked = true break end
                    end
                    if selfName == "Event" and method == "FireServer" then
                        local firstArg = args[1]
                        if type(firstArg) == "table" then isBlocked = true end
                    end
                    
                    if not isBlocked then
                        local raceKW = {"race", "spin", "reroll", "slot", "raza"}
                        local isRace = false
                        for _, kw in pairs(raceKW) do
                            if string.find(fullLower, kw) then isRace = true break end
                        end
                        
                        -- PASO CRÍTICO: Si es Reroll o SwitchSlot, NO TOCAR el flujo.
                        -- Solo loguear en hilo aparte y dejar pasar LIMPIO.
                        if isRace and method == "InvokeServer" then
                            local argDump = ""
                            for i, v in ipairs(args) do argDump = argDump .. " Arg[" .. i .. "]=" .. SmartDump(v) end
                            if argDump == "" then argDump = " (sin args)" end
                            task.spawn(function()
                                AddLog("OUT:InvokeServer", "🎯 " .. selfName .. argDump, Color3.fromRGB(255, 50, 255))
                                AddLog("FLOW", "⚡ Dejando pasar " .. selfName .. " SIN INTERFERIR al servidor...", Color3.fromRGB(255, 255, 0))
                            end)
                            -- RETORNO LIMPIO: No tocamos nada
                            return GlobalOriginalNamecall(self, ...)
                        end
                        
                        -- Para otros InvokeServer NO de raza, capturar normalmente
                        local argDump = ""
                        for i, v in ipairs(args) do argDump = argDump .. " Arg[" .. i .. "]=" .. SmartDump(v) end
                        if argDump == "" then argDump = " (sin args)" end
                        
                        local color = isRace and Color3.fromRGB(255, 50, 255) or Color3.fromRGB(130, 130, 130)
                        local tag = isRace and "🎯 " or ""
                        task.spawn(function() AddLog("OUT:" .. method, tag .. selfName .. argDump, color) end)
                    end
                end
                
                return GlobalOriginalNamecall(self, ...)
            end)
        end
    else
        InterceptBtn.Text = "📡 FASE 2: ACTIVAR INTERCEPTOR"
        InterceptBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        AddLog("INTERCEPT", "⚪ INTERCEPTOR APAGADO.", Color3.fromRGB(150, 150, 150))
    end
end)

-- ==========================================
-- LISTENER PASIVO: Escuchar TODOS los eventos Knit de datos
-- ==========================================
task.spawn(function()
    pcall(function()
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                local nLower = string.lower(v.Name)
                local fLower = string.lower(v:GetFullName())
                if string.find(fLower, "knit") and (
                    string.find(nLower, "notify") or
                    string.find(nLower, "progress") or
                    string.find(nLower, "data") or
                    string.find(nLower, "race") or
                    string.find(nLower, "spin") or
                    string.find(nLower, "changed")
                ) then
                    v.OnClientEvent:Connect(function(...)
                        local args = {...}
                        local dump = ""
                        for i, val in ipairs(args) do dump = dump .. " Arg[" .. i .. "]=" .. SmartDump(val) end
                        AddLog("KNIT_EVT", "📢 " .. v.Name .. " >>" .. dump, Color3.fromRGB(255, 255, 100))
                    end)
                end
            end
        end
    end)
end)

pcall(function() writefile(LOG_FILENAME, "=== RACE SPIN ANALYZER V1.1 - LOG INICIADO ===\n") end)

AddLog("SISTEMA", "🎰 V1.1 CARGADO. Reroll pasa LIMPIO, observación por GUI.", Color3.fromRGB(150, 255, 150))
AddLog("SISTEMA", "1) FASE 1 → 2) FASE 2 → 3) REINICIAR en el juego.", Color3.fromRGB(255, 255, 200))
AddLog("SISTEMA", "La raza se captura desde el cambio en pantalla (CurrentRace).", Color3.fromRGB(255, 255, 200))
