-- ==============================================================================
-- 🗡️ FORGE OMNI-ANALYZER V3.0 (GOD-BOT: INTERCEPTACIÓN Y AUTO-QUALITY)
-- Intercepta el arranque legítimo, destruye la UI local y completa matemáticamente la forja.
-- ==============================================================================

local SCRIPT_VERSION = "V3.0 - DIOS DE LA FORJA"

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
Title.BackgroundColor3 = Color3.fromRGB(80, 20, 100)
Title.Text = " 📡 FORGE V3.0 (GOD-BOT MATHEMATICS)"
Title.TextColor3 = Color3.fromRGB(255, 150, 255)
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
-- BOTON DE CONTROL MULTI-HILO (V3.0)
-- ==========================================
local BypassFrame = Instance.new("Frame")
BypassFrame.Size = UDim2.new(1, -8, 0, 45)
BypassFrame.Position = UDim2.new(0, 4, 0, 35)
BypassFrame.BackgroundColor3 = Color3.fromRGB(30, 10, 30)
BypassFrame.Parent = Panel
Instance.new("UICorner", BypassFrame).CornerRadius = UDim.new(0, 4)

local AutoBotBtn = Instance.new("TextButton")
AutoBotBtn.Size = UDim2.new(1, -8, 1, -8)
AutoBotBtn.Position = UDim2.new(0, 4, 0, 4)
AutoBotBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
AutoBotBtn.Text = "🤖 START: HABILITAR AUTO-BOT DE CALIDAD PERFECTA"
AutoBotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoBotBtn.Font = Enum.Font.Code
AutoBotBtn.TextSize = 13
AutoBotBtn.Parent = BypassFrame

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
-- SISTEMA DE LOGS Y MEMÓRIA A ARCHIVO
-- ==========================================
local MasterLogList = {}
local ModosBypass = {BotActivo = false}
local BotJugandoAhoraMismo = false

local function SaveLogToFile(message)
    task.spawn(function()
        pcall(function()
            local filename = "ForgeAnalyzerLogs_V3.txt"
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

AutoBotBtn.MouseButton1Click:Connect(function()
    ModosBypass.BotActivo = not ModosBypass.BotActivo
    if ModosBypass.BotActivo then
        AutoBotBtn.Text = "🛑 STOP: BOT HABILITADO (Esperando que prestiones GO)"
        AutoBotBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        AddUILog("SISTEMA", "V3.0 Bot ARMADO. Juega normal (presiona GO) y yo haré el resto.", Color3.fromRGB(100,255,100))
    else
        AutoBotBtn.Text = "🤖 START: HABILITAR AUTO-BOT DE CALIDAD PERFECTA"
        AutoBotBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        AddUILog("SISTEMA", "Bot APAGADO.", Color3.fromRGB(255,100,100))
    end
end)

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
-- BUSCADOR RECURSIVO DEL SANTO GRIAL (Tiempos)
-- ==========================================
local function ExtractTimes(tbl)
    local req, start = nil, nil
    local function search(t)
        if type(t) ~= "table" then return end
        for k, v in pairs(t) do
            if type(k) == "string" and k == "RequiredTime" then req = v end
            if type(k) == "string" and k == "StartTime" then start = v end
            if type(v) == "table" then search(v) end
        end
    end
    search(tbl)
    return req, start
end

-- ==========================================
-- DESTRUCTOR DE MINIJUEGOS NATIVOS
-- ==========================================
local function DestroyNativeMinigames()
    for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
        if string.find(string.lower(v.Name), "forge") or string.find(string.lower(v.Name), "minigame") then
            -- Para no borrar nuestra interfaz:
            if v.Name ~= "ForgeAnalyzerUI" and v:IsA("ScreenGui") then
                v:Destroy()
                AddUILog("HACK", "UI de Minijuego Local ELIMINADA. Liberando el mouse.", Color3.fromRGB(255,100,50))
            end
        end
    end
end

-- ==========================================
-- EXECUCIÓN AUTOMATIZADA MATEMÁTICA EN HILO SEPARADO
-- ==========================================
local function ExecutePerfectSequence(forgeRF, primerMeltReturn)
    task.spawn(function()
        BotJugandoAhoraMismo = true
        DestroyNativeMinigames()
        
        AddUILog("BOT_V3", ">> Calculando matemática fase 1 (Melt a Pour)...", Color3.fromRGB(150,255,150))
        local req1, start1 = ExtractTimes(primerMeltReturn)
        req1 = req1 or 2.12
        start1 = start1 or os.clock()
        
        AddUILog("BOT_V3", string.format("Durmiento %.2fs EXACTOS.", req1), Color3.fromRGB(200,200,200))
        task.wait(req1)
        
        AddUILog("BOT_V3", ">> Ejecutando fase 2: Pour...", Color3.fromRGB(150,255,150))
        local s2, r2 = pcall(function() return forgeRF:InvokeServer("Pour", {ClientTime = start1 + req1}) end)
        
        local req2, start2 = ExtractTimes(r2)
        req2 = req2 or 3.00
        start2 = start2 or (start1 + req1)
        AddUILog("BOT_V3", string.format("Durmiento %.2fs EXACTOS.", req2), Color3.fromRGB(200,200,200))
        task.wait(req2)
        
        AddUILog("BOT_V3", ">> Ejecutando fase 3: Hammer...", Color3.fromRGB(150,255,150))
        local s3, r3 = pcall(function() return forgeRF:InvokeServer("Hammer", {ClientTime = start2 + req2}) end)
        
        local req3, start3 = ExtractTimes(r3)
        req3 = req3 or 3.00
        start3 = start3 or (start2 + req2)
        AddUILog("BOT_V3", string.format("Durmiento %.2fs EXACTOS.", req3), Color3.fromRGB(200,200,200))
        task.wait(req3)
        
        AddUILog("BOT_V3", ">> Ejecutando fase 4: Water (Círculos)...", Color3.fromRGB(150,255,150))
        local s4, r4 = pcall(function() return forgeRF:InvokeServer("Water", {ClientTime = start3 + req3}) end)
        
        local req4, start4 = ExtractTimes(r4)
        req4 = req4 or 3.00
        start4 = start4 or (start3 + req3)
        AddUILog("BOT_V3", string.format("Durmiento %.2fs EXACTOS.", req4), Color3.fromRGB(200,200,200))
        task.wait(req4)
        
        AddUILog("BOT_V3", ">> Completado con éxito! Enviando reclamación de material (Showcase)", Color3.fromRGB(255,255,50))
        pcall(function() forgeRF:InvokeServer("Showcase", {}) end)
        AddUILog("BOT_V3", "=== FIN DEL CRAFTEO PERFECTO EN LA SOMBRA ===", Color3.fromRGB(0,255,0))
        
        BotJugandoAhoraMismo = false
    end)
end

-- ==========================================
-- EL HOOK BESTIAL V3.0 (Cliente -> Servidor)
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
    
    if not checkcaller() and method == "InvokeServer" then
        local fullName = self.GetFullName(self)
        local nameLower = string.lower(fullName)
        
        -- INTERCEPTAMOS EL INICIO DEL JUEGO DIRECTO DEL USUARIO Y LO RETENEMOS!
        if string.find(nameLower, "changesequence") then
            -- OJO: ESTO BLOQUEARÁ EL HILO HASTA RECIBIR RESPUESTA, PERMITIENDO ROBARLA
            local returnVal = OriginalNamecall(self, ...)
            
            task.spawn(function()
                if tostring(args[1]) == "Melt" then
                    AddUILog("INTERCEPT", "Has presionado GO legalmente. Obteniendo respuesta del servidor...", Color3.fromRGB(255,100,255))
                    local dumpRet = (type(returnVal) == "table" and DumpTableDeep(returnVal) or tostring(returnVal))
                    AddUILog("INTERCEPT", "Resp: " .. dumpRet, Color3.fromRGB(200,200,200))
                    
                    if ModosBypass.BotActivo and not BotJugandoAhoraMismo then
                        ExecutePerfectSequence(self, returnVal)
                    end
                else
                    -- Si el usuario presiona algo manualmente y el Bot está activo, bloquemos su spam de red
                    if ModosBypass.BotActivo and BotJugandoAhoraMismo then
                        AddUILog("BLOCK", "Ignorando tu click porque el BOT está jugando la fase " .. tostring(args[1]), Color3.fromRGB(150,150,150))
                    end
                end
            end)
            
            return returnVal -- Devolvemos normalmente para que el juego no haga crash
        end
    end
    
    -- LOGEO DE RED EXCLUYÉNDONOS PARA NO LLENAR LA PANTALLA
    if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
        task.spawn(function()
            pcall(function()
                local nameLower = string.lower(self.GetFullName(self))
                local BlacklistWords = {"move", "mouse", "camera", "ping", "update", "render", "step", "chat", "character", "root", "position", "look"}
                local skip = false
                for _, w in pairs(BlacklistWords) do if string.find(nameLower, w) then skip = true; break end end
                
                if not skip and not string.find(nameLower, "changesequence") then
                    local argDump = ""
                    for i, v in ipairs(args) do
                        local vt = typeof(v)
                        if vt == "table" then
                            local s, r = pcall(function() return DumpTableDeep(v) end)
                            argDump = argDump .. "Arg["..i.."]=" .. (s and r or "ERR") .. " "
                        else pcall(function() argDump = argDump .. "Arg["..i.."]="..tostring(v).." " end) end
                    end
                    AddUILog("NET_OUT:"..method, self.Name .. " >> " .. argDump, Color3.fromRGB(100, 100, 100))
                end
            end)
        end)
    end
    return OriginalNamecall(self, ...)
end)

AddUILog("SISTEMA", "V3.0 INICIADA. LOGS A ForgeAnalyzerLogs_V3.txt.", Color3.fromRGB(150, 255, 150))
AddUILog("AYUDA", "Ya no necesitas botones mágicos. Solo activa el Auto-Bot y presiona 'GO' desde el propio juego y miralo trabajar.", Color3.fromRGB(255, 200, 100))
