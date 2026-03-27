-- ==============================================================================
-- 🗡️ FORGE OMNI-ANALYZER V1.6 (DUAL-BYPASS & SERVER COMMS)
-- Analiza cómo el servidor maneja los minijuegos y permite probar saltos o Auto-Rhythm.
-- ==============================================================================

local SCRIPT_VERSION = "V1.6 - ANALISTA TOTAL .TXT"

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
Title.BackgroundColor3 = Color3.fromRGB(100, 80, 20)
Title.Text = " 📡 FORGE ANALYZER V1.6 (GUI, RED & AUTO-BOT)"
Title.TextColor3 = Color3.fromRGB(255, 255, 150)
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
-- BOTON TEST 2: AUTO-PLAY (MATH PERFECT)
-- ==========================================
PerfectAutoBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        if not next(LastOresDetected) then AddUILog("TEST_2", "ERROR: Olla vacía. Mete minerales y presiona el boton GO verde del juego primero.", Color3.fromRGB(255,50,50)); return end
        if ModosBypass.Auto then return end
        ModosBypass.Auto = true
        
        AddUILog("TEST_2", "== INICIANDO BOT MATEMÁTICO (PERFECT SCORE) ==", Color3.fromRGB(100,200,255))
        local forgeRF = GetForgeRF()
        if not forgeRF then return end
        
        local t0 = os.clock()
        AddUILog("TEST_2", "Fase 1/5: Arrancando (Melt) - 0.00s", Color3.fromRGB(150,200,255))
        local s1, r1 = pcall(function() return forgeRF:InvokeServer("Melt", {FastForge = false, ItemType = "Weapon", Ores = LastOresDetected}) end)
        AddUILog("TEST_2", " -> Resp: " .. tostring(r1), Color3.fromRGB(100,150,200))
        
        -- TIEMPOS BASADOS EN TU REPORTE FORENSE (Para que el servidor crea que somos perfectos)
        -- Melt -> Pour (Inflador) tarda ~11 a 12 seg
        task.wait(2)
        AddUILog("TEST_2", "Fase 2/5: Inflador superado simulado. "..(os.clock()-t0), Color3.fromRGB(150,200,255))
        pcall(function() forgeRF:InvokeServer("Pour", {ClientTime = t0 + 11.45}) end)
        
        task.wait(2)
        AddUILog("TEST_2", "Fase 3/5: Barra amarilla superada simulada. "..(os.clock()-t0), Color3.fromRGB(150,200,255))
        pcall(function() forgeRF:InvokeServer("Hammer", {ClientTime = t0 + (11.45 + 5.03)}) end)
        
        task.wait(2)
        AddUILog("TEST_2", "Fase 4/5: Yunque superado simulado. "..(os.clock()-t0), Color3.fromRGB(150,200,255))
        pcall(function() forgeRF:InvokeServer("Water", {ClientTime = t0 + (11.45 + 5.03 + 8.10)}) end)
        
        task.wait(2)
        AddUILog("TEST_2", "Fase 5/5: Secuencia terminando (Showcase)...", Color3.fromRGB(150,200,255))
        pcall(function() forgeRF:InvokeServer("Showcase", {}) end)
        
        AddUILog("TEST_2", "== RUTINA AUTOMÁTICA FINALIZADA ==", Color3.fromRGB(100,200,255))
        ModosBypass.Auto = false
    end)
end)

AddUILog("SISTEMA", "V1.6 INICIADA. LOGS A .TXT ACTIVADOS (ForgeAnalyzerLogs_V16.txt).", Color3.fromRGB(150, 255, 150))
AddUILog("AYUDA", "Inicia en Test: Mete items, presiona GO, espera a que el Inflador aparezca, e INMEDIATAMENTE aprieta el boton ROJO(Instant) o el boton AZUL(Perfect) de mi ventana. El archivo .txt guardará errores, respuestas y componentes.", Color3.fromRGB(255, 200, 100))
