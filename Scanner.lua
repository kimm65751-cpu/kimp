-- 🗡️ FORGE OMNI-ANALYZER V1.7 (FULL GUI & RETURN ANALYZER)
-- Analiza cómo el servidor maneja los minijuegos y permite probar saltos o Auto-Rhythm.
-- ==============================================================================

local SCRIPT_VERSION = "V1.7 - ANALISTA TOTAL"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "ForgeAnalyzerUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ForgeAnalyzerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 560, 0, 420)
Panel.Position = UDim2.new(1, -580, 0.5, -210)
Panel.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(255, 200, 50) -- Oro V1.6
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(100, 40, 60)
Title.Text = " 📡 FORGE ANALYZER V1.7 (GUI, RED & BOT)"
Title.TextColor3 = Color3.fromRGB(255, 150, 150)
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

-- ==========================================
-- BOTONES DE TESTEO (DUAL BYPASS)
-- ==========================================
local BypassFrame = Instance.new("Frame")
BypassFrame.Size = UDim2.new(1, -8, 0, 45)
BypassFrame.Position = UDim2.new(0, 4, 0, 35)
BypassFrame.BackgroundColor3 = Color3.fromRGB(30, 20, 10)
BypassFrame.Parent = Panel
Instance.new("UICorner", BypassFrame).CornerRadius = UDim.new(0, 4)

local FastSkipBtn = Instance.new("TextButton")
FastSkipBtn.Size = UDim2.new(0.5, -6, 1, -8)
FastSkipBtn.Position = UDim2.new(0, 4, 0, 4)
FastSkipBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 50)
FastSkipBtn.Text = "1️⃣ TEST: SALTAR MINIJUEGOS (INSTANT)"
FastSkipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FastSkipBtn.Font = Enum.Font.Code
FastSkipBtn.TextSize = 11
FastSkipBtn.Parent = BypassFrame

local PerfectAutoBtn = Instance.new("TextButton")
PerfectAutoBtn.Size = UDim2.new(0.5, -6, 1, -8)
PerfectAutoBtn.Position = UDim2.new(0.5, 2, 0, 4)
PerfectAutoBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
PerfectAutoBtn.Text = "2️⃣ TEST: AUTO-JUGAR PERFECTO (MATH)"
PerfectAutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PerfectAutoBtn.Font = Enum.Font.Code
PerfectAutoBtn.TextSize = 11
PerfectAutoBtn.Parent = BypassFrame

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -8, 1, -125)
LogScroll.Position = UDim2.new(0, 4, 0, 85)
LogScroll.BackgroundColor3 = Color3.fromRGB(10, 15, 10)
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogScroll.ScrollBarThickness = 6
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.Parent = Panel
local ListLayout = Instance.new("UIListLayout", LogScroll)
ListLayout.Padding = UDim.new(0, 2)

local ControlsFrame = Instance.new("Frame")
ControlsFrame.Size = UDim2.new(1, -8, 0, 35)
ControlsFrame.Position = UDim2.new(0, 4, 1, -38)
ControlsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ControlsFrame.Parent = Panel

local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0.5, -2, 1, 0)
ClearBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ClearBtn.Text = "🗑️ LIMPIAR LOGS"
ClearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearBtn.Font = Enum.Font.Code
ClearBtn.TextSize = 12
ClearBtn.Parent = ControlsFrame

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0.5, -2, 1, 0)
CopyBtn.Position = UDim2.new(0.5, 2, 0, 0)
CopyBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 150)
CopyBtn.Text = "📋 COPIAR AL PORTAPAPELES"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.Code
CopyBtn.TextSize = 12
CopyBtn.Parent = ControlsFrame

-- ==========================================
-- SISTEMA DE LOGS Y .TXT (SIN LÍMITES)
-- ==========================================
local MasterLogList = {}
local ModosBypass = {Fast = false, Auto = false}
local LastOresDetected = {} 

local function SaveLogToFile(message)
    task.spawn(function()
        pcall(function()
            local filename = "ForgeAnalyzerLogs_V16.txt"
            if appendfile then
                appendfile(filename, message .. "\n")
            elseif readfile and writefile then
                local current = ""
                pcall(function() current = readfile(filename) end)
                writefile(filename, current .. message .. "\n")
            elseif writefile then
                writefile(filename, message .. "\n")
            end
        end)
    end)
end

local function AddUILog(logType, message, color)
    local fullString = "[" .. os.date("%H:%M:%S") .. "] [" .. logType .. "] " .. message
    SaveLogToFile(fullString)
    
    table.insert(MasterLogList, fullString)
    if #MasterLogList > 500 then table.remove(MasterLogList, 1); local f = LogScroll:FindFirstChildWhichIsA("TextLabel"); if f then f:Destroy() end end
    
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, -4, 0, 0)
    txt.BackgroundTransparency = 1
    txt.Text = fullString
    txt.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    txt.Font = Enum.Font.Code
    txt.TextSize = 11
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.TextWrapped = true
    txt.Parent = LogScroll
    
    local ts = game:GetService("TextService"):GetTextSize(txt.Text, txt.TextSize, txt.Font, Vector2.new(LogScroll.AbsoluteSize.X - 15, math.huge))
    txt.Size = UDim2.new(1, -4, 0, ts.Y + 4)
    LogScroll.CanvasPosition = Vector2.new(0, 999999)
end

ClearBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(LogScroll:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
    MasterLogList = {}
end)

CopyBtn.MouseButton1Click:Connect(function()
    local result = "=== REPORTE TOTAL SIN FILTROS (V1.7) ===\n\n"
    for i, _ in ipairs(MasterLogList) do result = result .. MasterLogList[i] .. "\n" end
    if setclipboard then setclipboard(result); CopyBtn.Text = "✅ ¡COPIADO!" else CopyBtn.Text = "❌ ERROR" end
    task.delay(2, function() CopyBtn.Text = "📋 COPIAR AL PORTAPAPELES" end)
end)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- ==========================================
-- ESCANEO DE GUI (PlayerGui)
-- ==========================================
local function ScanLocalForgeGUI()
    AddUILog("GUI_SCAN", "Revisando PlayerGui del Cliente para buscar Minijuegos Ocultos...", Color3.fromRGB(200, 150, 255))
    for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
        if string.find(string.lower(v.Name), "forge") or string.find(string.lower(v.Name), "minigame") then
            AddUILog("GUI_DETECTED", "Se detectó interfaz: " .. v.Name, Color3.fromRGB(255,100,200))
            for _, child in pairs(v:GetChildren()) do
                AddUILog("GUI_CHILD", " -> " .. child.Name .. " (" .. child.ClassName .. ")", Color3.fromRGB(200,80,180))
            end
        end
    end
end

-- ==========================================
-- ESCANEO DEL SERVIDOR (Incoming Events)
-- ==========================================
local function CatchServerResponses()
    local RS = game:GetService("ReplicatedStorage")
    for _, v in pairs(RS:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            -- Solo nos interesan los Eventos del servidor hacia el cliente (Knit)
            if string.find(string.lower(v:GetFullName()), "knit") or string.find(string.lower(v.Name), "forge") then
                v.OnClientEvent:Connect(function(...)
                    local args = {...}
                    local dump = ""
                    for i, val in ipairs(args) do dump = dump .. "Arg["..i.."]="..tostring(val).." " end
                    if dump ~= "" then
                        AddUILog("SERVER_SAYS", v.Name .. " >> " .. dump, Color3.fromRGB(100, 255, 100))
                    end
                end)
            end
        end
    end
    AddUILog("SISTEMA", "Escuchando respuestas del servidor activado.", Color3.fromRGB(150, 255, 150))
end
CatchServerResponses()

-- ==========================================
-- EL HOOK BESTIAL V1.6 (Cliente -> Servidor)
-- ==========================================
local DumpTableDeep
DumpTableDeep = function(tbl, depth)
    depth = depth or 0
    if depth > 5 then return "{MAX_DEPTH}" end
    local str = "{"
    for k, v in pairs(tbl) do
        local vt = typeof(v)
        if vt == "table" then str = str .. "["..tostring(k).."]=" .. DumpTableDeep(v, depth + 1) .. ", "
        else str = str .. "["..tostring(k).."]=" .. tostring(v) .. ", " end
    end
    return str .. "}"
end

local function GetForgeRF()
    local RS = game:GetService("ReplicatedStorage")
    local success, res = pcall(function() return RS.Shared.Packages.Knit.Services.ForgeService.RF.ChangeSequence end)
    return success and res or nil
end

local OriginalNamecall
OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
        task.spawn(function()
            pcall(function()
                local fullName = self.GetFullName(self)
                local nameLower = string.lower(fullName)
                
                -- INTERCEPTAMOS EL BOTON "GO" DEL MINIJUEGO
                if string.find(nameLower, "changesequence") and tostring(args[1]) == "Melt" then
                    -- Guardamos las Ores si están presentes (Robamos la configuración de la Olla)
                    if typeof(args[2]) == "table" and args[2].Ores then
                        LastOresDetected = {}
                        for k,v in pairs(args[2].Ores) do LastOresDetected[k] = v end
                        AddUILog("MEMORIA", "¡Ores copiados a memoria RAM! " .. DumpTableDeep(LastOresDetected), Color3.fromRGB(255,255,50))
                        ScanLocalForgeGUI() -- Analizamos qué GUi se abrió
                    end
                end
                
                local BlacklistWords = {"move", "mouse", "camera", "ping", "update", "render", "step", "chat", "character", "root", "position", "look"}
                local skip = false
                for _, w in pairs(BlacklistWords) do if string.find(nameLower, w) then skip = true; break end end
                
                if not skip then
                    local argDump = ""
                    for i, v in ipairs(args) do
                        local vt = typeof(v)
                        if vt == "table" then
                            local s, r = pcall(function() return DumpTableDeep(v) end)
                            argDump = argDump .. "Arg["..i.."]=" .. (s and r or "ERR") .. " "
                        else pcall(function() argDump = argDump .. "Arg["..i.."]="..tostring(v).." " end) end
                    end
                    AddUILog("NET_OUT:"..method, fullName .. "\n >> " .. argDump, Color3.fromRGB(200, 200, 200))
                end
            end)
        end)
    end
    return OriginalNamecall(self, ...)
end)

-- ==========================================
-- BOTON TEST 1: FAST SKIP
-- ==========================================
FastSkipBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        if not next(LastOresDetected) then AddUILog("TEST_1", "ERROR: Olla vacía. Mete minerales y presiona el boton GO verde del juego primero.", Color3.fromRGB(255,50,50)); return end
        if ModosBypass.Fast then return end
        ModosBypass.Fast = true
        
        AddUILog("TEST_1", "== INICIANDO BYPASS INSTANTÁNEO ==", Color3.fromRGB(255,100,100))
        local forgeRF = GetForgeRF()
        if not forgeRF then AddUILog("TEST_1", "ERROR: No se halló el RF", Color3.fromRGB(255,0,0)); return end
        
        local mArgs = {FastForge = true, ItemType = "Weapon", Ores = LastOresDetected}
        AddUILog("TEST_1", "1. Enviando Melt(FastForge=true)...", Color3.fromRGB(255,150,150))
        local s1, r1 = pcall(function() return forgeRF:InvokeServer("Melt", mArgs) end)
        AddUILog("TEST_1", "  -> Respuesta: " .. tostring(r1), s1 and Color3.fromRGB(150,255,150) or Color3.fromRGB(255,50,50))
        
        AddUILog("TEST_1", "2. Forzando cierre (Showcase)...", Color3.fromRGB(255,150,150))
        local s2, r2 = pcall(function() return forgeRF:InvokeServer("Showcase", {}) end)
        AddUILog("TEST_1", "  -> Respuesta: " .. tostring(r2), s2 and Color3.fromRGB(150,255,150) or Color3.fromRGB(255,50,50))
        
        AddUILog("TEST_1", "== PRUEBA FINALIZADA. REVISA INVENTARIO ==", Color3.fromRGB(255,100,100))
        ModosBypass.Fast = false
    end)
end)

-- ==========================================
-- BOTON TEST 2: AUTO-PLAY (AUTO-FORGE A.I.)
-- ==========================================
PerfectAutoBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        if not next(LastOresDetected) then AddUILog("TEST_2", "ERROR: Olla vacía. Mete minerales y presiona el boton GO verde del juego primero.", Color3.fromRGB(255,50,50)); return end
        if ModosBypass.Auto then return end
        ModosBypass.Auto = true
        
        AddUILog("BOT_AI", "== INICIANDO BOT MATEMÁTICO (PERFECT 100% SCORE) ==", Color3.fromRGB(100,255,255))
        local forgeRF = GetForgeRF()
        if not forgeRF then return end
        
        -- FASE 1 (Arranca Inflador)
        AddUILog("BOT_AI", "Fase 1: Enviando Datos de Metales (Melt)...", Color3.fromRGB(150,200,255))
        local s1, r1 = pcall(function() return forgeRF:InvokeServer("Melt", {FastForge = false, ItemType = "Weapon", Ores = LastOresDetected}) end)
        
        local req1 = (type(r1)=="table" and r1.MinigameData and r1.MinigameData.RequiredTime) or 3
        local start1 = (type(r1)=="table" and r1.MinigameData and r1.MinigameData.StartTime) or os.clock()
        AddUILog("BOT_AI", ">> El Server ha exigido un tiempo exacto de " .. string.format("%.2f", req1) .. "s. Esperando...", Color3.fromRGB(255,255,50))
        task.wait(req1)
        
        -- FASE 2 (Arranca Barra Amarilla)
        AddUILog("BOT_AI", "Fase 2: Evadiendo Inflador y pidiendo fase Barra Amarilla (Pour)...", Color3.fromRGB(150,200,255))
        local s2, r2 = pcall(function() return forgeRF:InvokeServer("Pour", {ClientTime = start1 + req1}) end)
        
        local req2 = (type(r2)=="table" and r2.MinigameData and r2.MinigameData.RequiredTime) or 3
        local start2 = (type(r2)=="table" and r2.MinigameData and r2.MinigameData.StartTime) or (start1 + req1)
        AddUILog("BOT_AI", ">> El Server ha exigido un tiempo exacto de " .. string.format("%.2f", req2) .. "s. Esperando...", Color3.fromRGB(255,255,50))
        task.wait(req2)

        -- FASE 3 (Arranca Círculos / Yunque)
        AddUILog("BOT_AI", "Fase 3: Evadiendo Barra Amarilla y pidiendo fase Yunque (Hammer)...", Color3.fromRGB(150,200,255))
        local s3, r3 = pcall(function() return forgeRF:InvokeServer("Hammer", {ClientTime = start2 + req2}) end)
        
        local req3 = (type(r3)=="table" and r3.MinigameData and r3.MinigameData.RequiredTime) or 3
        local start3 = (type(r3)=="table" and r3.MinigameData and r3.MinigameData.StartTime) or (start2 + req2)
        AddUILog("BOT_AI", ">> El Server ha exigido un tiempo exacto de " .. string.format("%.2f", req3) .. "s. Esperando...", Color3.fromRGB(255,255,50))
        task.wait(req3)
        
        -- FASE 4 (Termina Círculos)
        AddUILog("BOT_AI", "Fase 4: Evadiendo Yunque y pidiendo fase de Círculos (Water)...", Color3.fromRGB(150,200,255))
        local s4, r4 = pcall(function() return forgeRF:InvokeServer("Water", {ClientTime = start3 + req3}) end)
        
        local req4 = (type(r4)=="table" and r4.MinigameData and r4.MinigameData.RequiredTime) or 3
        local start4 = (type(r4)=="table" and r4.MinigameData and r4.MinigameData.StartTime) or (start3 + req3)
        AddUILog("BOT_AI", ">> El Server ha exigido un tiempo exacto de " .. string.format("%.2f", req4) .. "s. Esperando...", Color3.fromRGB(255,255,50))
        task.wait(req4)
        
        -- SHOWCASE
        AddUILog("BOT_AI", "Fase 5: Círculos evadidos completando forja 100% Quality (Showcase)...", Color3.fromRGB(150,200,255))
        pcall(function() forgeRF:InvokeServer("Showcase", {}) end)
        
        AddUILog("BOT_AI", "== AUTO-FORGE A.I. COMPLETADO. DISFRUTA TU ARMA ==", Color3.fromRGB(100,255,100))
        ModosBypass.Auto = false
    end)
end)

AddUILog("SISTEMA", "V1.6 INICIADA. LOGS A .TXT ACTIVADOS (ForgeAnalyzerLogs_V16.txt).", Color3.fromRGB(150, 255, 150))
AddUILog("AYUDA", "Inicia en Test: Mete items, presiona GO, espera a que el Inflador aparezca, e INMEDIATAMENTE aprieta el boton ROJO(Instant) o el boton AZUL(Perfect) de mi ventana. El archivo .txt guardará errores, respuestas y componentes.", Color3.fromRGB(255, 200, 100))
