-- ==============================================================================
-- 🎰 RACE SPIN FORENSIC ANALYZER V1.0
-- Interceptor Total del Sistema de Carreras/Razas y Giros (Spins).
-- Captura TODO: Red, GUI, Scripts, Módulos, Datos del Servidor.
-- ==============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- GUI FORENSE
-- ==========================================
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
Title.Text = " 🎰 RACE SPIN ANALYZER V1.0 (FORENSE TOTAL)"
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

-- Fase 1: Botón de Escaneo Profundo
local ScanBtn = Instance.new("TextButton")
ScanBtn.Size = UDim2.new(0.5, -6, 0, 35)
ScanBtn.Position = UDim2.new(0, 4, 0, 35)
ScanBtn.BackgroundColor3 = Color3.fromRGB(120, 50, 200)
ScanBtn.Text = "🔍 FASE 1: ESCANEAR REMOTOS DE RAZA"
ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanBtn.Font = Enum.Font.Code
ScanBtn.TextSize = 11
ScanBtn.Parent = Panel

-- Fase 2: Activar Interceptor
local InterceptBtn = Instance.new("TextButton")
InterceptBtn.Size = UDim2.new(0.5, -6, 0, 35)
InterceptBtn.Position = UDim2.new(0.5, 2, 0, 35)
InterceptBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
InterceptBtn.Text = "📡 FASE 2: ACTIVAR INTERCEPTOR"
InterceptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
InterceptBtn.Font = Enum.Font.Code
InterceptBtn.TextSize = 11
InterceptBtn.Parent = Panel

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

-- Log Scroll
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
-- SISTEMA DE LOGS
-- ==========================================
local MasterLogList = {}

local DumpTableDeep
DumpTableDeep = function(tbl, depth)
    depth = depth or 0
    if type(tbl) ~= "table" then return tostring(tbl) end
    if depth > 8 then return "{MAX_DEPTH}" end
    local seen_check = {}
    local str = "{\n"
    for k, v in pairs(tbl) do
        if seen_check[k] then str = str .. string.rep("  ", depth+1) .. "[CIRCULAR_REF], "
        else
            seen_check[k] = true
            local prefix = string.rep("  ", depth + 1) .. "[" .. tostring(k) .. "]="
            if type(v) == "table" then
                str = str .. prefix .. DumpTableDeep(v, depth + 1) .. ",\n"
            else
                str = str .. prefix .. tostring(v) .. ",\n"
            end
        end
    end
    return str .. string.rep("  ", depth) .. "}"
end

local LOG_FILENAME = "RaceSpinAnalyzer_ForenseCompleto_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"

local function SaveLogToFile(message)
    task.spawn(function()
        pcall(function()
            if appendfile then 
                appendfile(LOG_FILENAME, message .. "\n")
            elseif writefile then
                local current = ""
                pcall(function() current = readfile(LOG_FILENAME) end)
                writefile(LOG_FILENAME, current .. message .. "\n")
            end
        end)
    end)
end

local function AddLog(logType, message, color)
    local fullString = "[" .. os.date("%H:%M:%S.") .. string.format("%03d", math.floor(tick() * 1000) % 1000) .. "] [" .. logType .. "] " .. message
    SaveLogToFile(fullString)
    table.insert(MasterLogList, fullString)
    if #MasterLogList > 1000 then table.remove(MasterLogList, 1) end
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
            local ts = game:GetService("TextService"):GetTextSize(txt.Text, txt.TextSize, txt.Font, Vector2.new(LogScroll.AbsoluteSize.X - 15, math.huge))
            txt.Size = UDim2.new(1, -4, 0, ts.Y + 4)
            LogScroll.CanvasPosition = Vector2.new(0, 999999)
        end)
    end)
end

ClearBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(LogScroll:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
    MasterLogList = {}
end)
CopyBtn.MouseButton1Click:Connect(function()
    local result = "=== RACE SPIN ANALYZER - REPORTE FORENSE ===\n\n"
    for _, line in ipairs(MasterLogList) do result = result .. line .. "\n" end
    if setclipboard then setclipboard(result); CopyBtn.Text = "✅ COPIADO" else CopyBtn.Text = "❌ ERROR" end
    task.delay(2, function() CopyBtn.Text = "📋 COPIAR" end)
end)

SaveTxtBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local result = "=== RACE SPIN ANALYZER - REPORTE FORENSE COMPLETO ===\n"
        result = result .. "Fecha: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
        result = result .. "Total Lineas: " .. tostring(#MasterLogList) .. "\n"
        result = result .. "============================================\n\n"
        for _, line in ipairs(MasterLogList) do result = result .. line .. "\n" end
        if writefile then
            writefile(LOG_FILENAME, result)
            SaveTxtBtn.Text = "✅ GUARDADO!"
            AddLog("ARCHIVO", "💾 Guardado exitoso: workspace/" .. LOG_FILENAME .. " (" .. tostring(#result) .. " bytes)", Color3.fromRGB(100, 255, 100))
        else
            SaveTxtBtn.Text = "❌ SIN ACCESO"
        end
    end)
    task.delay(3, function() SaveTxtBtn.Text = "💾 GUARDAR .TXT" end)
end)

-- ==========================================
-- FASE 1: ESCANEO DE REMOTOS RELACIONADOS CON RAZA/SPIN
-- ==========================================
local RaceRemotes = {} -- {name = instance}

ScanBtn.MouseButton1Click:Connect(function()
    AddLog("SCAN", "═══════════════════════════════════════", Color3.fromRGB(255, 200, 100))
    AddLog("SCAN", "INICIANDO ESCANEO PROFUNDO DE REMOTOS...", Color3.fromRGB(255, 200, 100))
    
    local keywords = {"race", "spin", "reroll", "carrera", "reiniciar", "slot", "raza", "reincarnate", "rebirth", "class"}
    local foundCount = 0
    
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        pcall(function()
            if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
                local nameLower = string.lower(obj.Name)
                local fullPath = obj:GetFullName()
                local fullLower = string.lower(fullPath)
                
                local matched = false
                for _, kw in pairs(keywords) do
                    if string.find(nameLower, kw) or string.find(fullLower, kw) then
                        matched = true
                        break
                    end
                end
                
                if matched then
                    foundCount = foundCount + 1
                    local typeStr = obj:IsA("RemoteFunction") and "RF" or "RE"
                    RaceRemotes[obj.Name] = obj
                    AddLog("FOUND_" .. typeStr, "🎯 " .. fullPath, Color3.fromRGB(0, 255, 200))
                    
                    -- Si es RemoteEvent, escuchar respuestas
                    if obj:IsA("RemoteEvent") then
                        obj.OnClientEvent:Connect(function(...)
                            local args = {...}
                            local dump = ""
                            for i, val in ipairs(args) do
                                if type(val) == "table" then
                                    dump = dump .. "Arg[" .. i .. "]=" .. DumpTableDeep(val) .. " "
                                else
                                    dump = dump .. "Arg[" .. i .. "]=" .. tostring(val) .. " "
                                end
                            end
                            AddLog("SERVER→CLIENT", "📥 " .. obj.Name .. " >> " .. dump, Color3.fromRGB(0, 255, 100))
                        end)
                        AddLog("LISTENER", "👂 Escuchando respuestas de: " .. obj.Name, Color3.fromRGB(150, 150, 255))
                    end
                end
            end
        end)
    end
    
    -- Escanear TODOS los servicios Knit para encontrar servicios ocultos
    AddLog("SCAN", "───────────────────────────────────────", Color3.fromRGB(255, 200, 100))
    AddLog("SCAN", "Buscando en Knit Services...", Color3.fromRGB(255, 200, 100))
    
    pcall(function()
        local knitServices = ReplicatedStorage:FindFirstChild("Shared")
        if knitServices then
            knitServices = knitServices:FindFirstChild("Packages")
            if knitServices then
                knitServices = knitServices:FindFirstChild("Knit")
                if knitServices then
                    knitServices = knitServices:FindFirstChild("Services")
                    if knitServices then
                        for _, service in pairs(knitServices:GetChildren()) do
                            local sName = string.lower(service.Name)
                            local isRelevant = false
                            for _, kw in pairs(keywords) do
                                if string.find(sName, kw) then isRelevant = true break end
                            end
                            
                            if isRelevant then
                                AddLog("KNIT_SERVICE", "🏢 SERVICIO ENCONTRADO: " .. service:GetFullName(), Color3.fromRGB(255, 255, 0))
                                for _, child in pairs(service:GetDescendants()) do
                                    if child:IsA("RemoteFunction") or child:IsA("RemoteEvent") then
                                        RaceRemotes[child.Name] = child
                                        foundCount = foundCount + 1
                                        AddLog("KNIT_RF", "  └─ " .. child.Name .. " (" .. child.ClassName .. ")", Color3.fromRGB(255, 200, 0))
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    
    -- Buscar en PlayerGui los elementos de UI de razas
    AddLog("SCAN", "───────────────────────────────────────", Color3.fromRGB(255, 200, 100))
    AddLog("SCAN", "Buscando GUIs de Razas en pantalla...", Color3.fromRGB(255, 200, 100))
    
    pcall(function()
        for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
            local nLower = string.lower(gui.Name)
            for _, kw in pairs(keywords) do
                if string.find(nLower, kw) then
                    local info = gui.Name .. " (" .. gui.ClassName .. ") en " .. gui:GetFullName()
                    if gui:IsA("TextLabel") or gui:IsA("TextButton") then
                        info = info .. " [Text=\"" .. (gui.Text or "") .. "\"]"
                    end
                    AddLog("GUI_RACE", "🖥️ " .. info, Color3.fromRGB(200, 150, 255))
                    break
                end
            end
        end
    end)
    
    AddLog("SCAN", "═══════════════════════════════════════", Color3.fromRGB(255, 200, 100))
    AddLog("SCAN", "✅ ESCANEO COMPLETO. " .. foundCount .. " remotos de Raza encontrados.", Color3.fromRGB(0, 255, 0))
    AddLog("SCAN", "Ahora presiona FASE 2 y luego dale a REINICIAR en el juego.", Color3.fromRGB(255, 255, 0))
end)

-- ==========================================
-- FASE 2: INTERCEPTOR GLOBAL (__namecall hook)
-- ==========================================
local InterceptorActivo = false
local GlobalOriginalNamecall = nil

InterceptBtn.MouseButton1Click:Connect(function()
    InterceptorActivo = not InterceptorActivo
    if InterceptorActivo then
        InterceptBtn.Text = "📡 INTERCEPTOR: ON 🔴"
        InterceptBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        AddLog("INTERCEPT", "═══════════════════════════════════════", Color3.fromRGB(255, 100, 100))
        AddLog("INTERCEPT", "🔴 INTERCEPTOR ACTIVADO. Ahora presiona REINICIAR en el juego.", Color3.fromRGB(255, 100, 100))
        AddLog("INTERCEPT", "Capturando TODA la comunicación cliente↔servidor...", Color3.fromRGB(255, 100, 100))
        
        if not GlobalOriginalNamecall then
            GlobalOriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                
                if not InterceptorActivo then
                    return GlobalOriginalNamecall(self, ...)
                end
                
                if not checkcaller() and (method == "InvokeServer" or method == "FireServer") then
                    local fullName = ""
                    local selfName = ""
                    pcall(function() fullName = self:GetFullName() end)
                    pcall(function() selfName = self.Name end)
                    local fullLower = string.lower(fullName)
                    
                    -- Filtrar ruido (movimiento, cámara, etc.)
                    local noiseWords = {"move", "mouse", "camera", "ping", "render", "step", "chat", "position", "look", "heartbeat"}
                    local isNoise = false
                    for _, nw in pairs(noiseWords) do
                        if string.find(fullLower, nw) then isNoise = true break end
                    end
                    
                    if not isNoise then
                        -- Construir dump de argumentos
                        local argDump = ""
                        for i, v in ipairs(args) do
                            if type(v) == "table" then
                                argDump = argDump .. "\n  Arg[" .. i .. "]=" .. DumpTableDeep(v)
                            else
                                argDump = argDump .. "\n  Arg[" .. i .. "]=" .. tostring(v)
                            end
                        end
                        if argDump == "" then argDump = " (sin argumentos)" end
                        
                        -- Detectar si es relacionado con Raza/Spin
                        local raceKeywords = {"race", "spin", "reroll", "slot", "raza", "reiniciar", "reincarnate"}
                        local isRaceRelated = false
                        for _, kw in pairs(raceKeywords) do
                            if string.find(fullLower, kw) then isRaceRelated = true break end
                        end
                        
                        local color = isRaceRelated and Color3.fromRGB(255, 50, 255) or Color3.fromRGB(100, 100, 100)
                        local prefix = isRaceRelated and "🎯 " or ""
                        
                        AddLog("CLIENT→SERVER:" .. method, prefix .. selfName .. argDump, color)
                        
                        -- Si es InvokeServer, capturar la RESPUESTA del servidor
                        if method == "InvokeServer" then
                            local retValues = {GlobalOriginalNamecall(self, ...)}
                            
                            -- Loguear la respuesta
                            local retDump = ""
                            for i, rv in ipairs(retValues) do
                                if type(rv) == "table" then
                                    retDump = retDump .. "\n  Return[" .. i .. "]=" .. DumpTableDeep(rv)
                                else
                                    retDump = retDump .. "\n  Return[" .. i .. "]=" .. tostring(rv)
                                end
                            end
                            if retDump == "" then retDump = " (vacío)" end
                            
                            local retColor = isRaceRelated and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(80, 150, 80)
                            AddLog("SERVER→CLIENT:Return", prefix .. selfName .. " RESPONDIÓ:" .. retDump, retColor)
                            
                            return unpack(retValues)
                        end
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
-- ESCUCHAR EVENTOS GLOBALES DE KNIT (Para replicaciones del servidor)
-- ==========================================
task.spawn(function()
    pcall(function()
        local RS = ReplicatedStorage
        for _, v in pairs(RS:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                local nLower = string.lower(v.Name)
                local fLower = string.lower(v:GetFullName())
                -- Escuchar TODOS los eventos Knit que contengan notify, progress, data, race, spin
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
                        for i, val in ipairs(args) do
                            if type(val) == "table" then
                                dump = dump .. "\nArg[" .. i .. "]=" .. DumpTableDeep(val)
                            else
                                dump = dump .. "\nArg[" .. i .. "]=" .. tostring(val)
                            end
                        end
                        AddLog("KNIT_EVENT", "📢 " .. v.Name .. " >>" .. dump, Color3.fromRGB(255, 255, 100))
                    end)
                end
            end
        end
    end)
end)

AddLog("SISTEMA", "🎰 RACE SPIN ANALYZER V1.0 CARGADO.", Color3.fromRGB(150, 255, 150))
AddLog("SISTEMA", "PASO 1: Presiona '🔍 FASE 1' para escanear remotos de Raza.", Color3.fromRGB(255, 255, 200))
AddLog("SISTEMA", "PASO 2: Presiona '📡 FASE 2' para activar el interceptor.", Color3.fromRGB(255, 255, 200))
AddLog("SISTEMA", "PASO 3: Ve al menú de Carreras y presiona REINICIAR.", Color3.fromRGB(255, 255, 200))
AddLog("SISTEMA", "El analizador capturará TODO lo que pase entre tu cliente y el servidor.", Color3.fromRGB(255, 255, 200))
