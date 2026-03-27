-- ==============================================================================
-- 🗡️ FORGE OMNI-ANALYZER V5.0 (THE OMEGA BOT)
-- Calculador Anticheat Activo, Control Tolerante y Evasor de Cámaras Locales.
-- ==============================================================================

local SCRIPT_VERSION = "V5.0 - OMEGA BOT"

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
Title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Title.Text = " 📡 FORGE V5.0 (THE OMEGA BOT)"
Title.TextColor3 = Color3.fromRGB(255, 255, 0)
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
local BotBypassingNetwork = false
local DEFAULT_SAFE_DELAY = 8.50

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
    if #MasterLogList > 500 then 
        table.remove(MasterLogList, 1)
        task.defer(function()
            local f = LogScroll:FindFirstChildWhichIsA("TextLabel")
            if f then pcall(function() f:Destroy() end) end
        end)
    end
    
    -- PREVENIR CRASHEO DEL EXECUTOR AL CREAR UI TRAS UN YIELD DE RED
    task.defer(function()
        pcall(function()
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
        end)
    end)
end

AutoBotBtn.MouseButton1Click:Connect(function()
    ModosBypass.BotActivo = not ModosBypass.BotActivo
    if ModosBypass.BotActivo then
        AutoBotBtn.Text = "🛑 STOP: BOT HABILITADO (Esperando que prestiones GO)"
        AutoBotBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        AddUILog("SISTEMA", "V3.1 Bot ARMADO. Juega normal (presiona GO) y yo haré el resto.", Color3.fromRGB(100,255,100))
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
            if v.Name ~= "ForgeAnalyzerUI" and v:IsA("ScreenGui") then
                v:Destroy()
            end
        end
    end
end

-- ==========================================
-- TÚNEL SEGURO DE RED CON ANTI-FREEZE (V5)
-- ==========================================
local function SafeInvoke(forgeRF, phase, clientTimeParam)
    local s, r = false, nil
    local completed = false
    BotBypassingNetwork = true
    task.spawn(function()
        local _s, _r = pcall(function() 
            if clientTimeParam then
                return forgeRF:InvokeServer(phase, {ClientTime = clientTimeParam})
            else
                return forgeRF:InvokeServer(phase, {})
            end
        end)
        s, r = _s, _r
        completed = true
    end)
    
    local timeout = os.clock()
    while not completed and (os.clock() - timeout) < 5 do task.wait() end
    BotBypassingNetwork = false
    
    if not completed then AddUILog("TIMEOUT", "El servidor silenció (" .. phase .. ")", Color3.fromRGB(255,100,0)) end
    return s, r
end

local function WaitUntilServerTime(targetTime)
    local maxWait = targetTime + 2.0 -- Safety cap
    while workspace:GetServerTimeNow() < targetTime do
        if workspace:GetServerTimeNow() > maxWait then break end
        task.wait()
    end
    return workspace:GetServerTimeNow()
}

-- ==========================================
-- EXECUCIÓN AUTOMATIZADA CON CAÍDAS HEURÍSTICAS OMEGA
-- ==========================================
local function ExecutePerfectSequence(forgeRF, primerMeltReturn)
    task.spawn(function()
        BotJugandoAhoraMismo = true
        DestroyNativeMinigames()
        
        AddUILog("BOT_V5", ">> Fase 1: Sincronizando Melt...", Color3.fromRGB(150,255,150))
        local req1, start1 = ExtractTimes(primerMeltReturn)
        req1 = req1 or DEFAULT_SAFE_DELAY
        start1 = start1 or workspace:GetServerTimeNow()
        
        local trueTime1 = WaitUntilServerTime(start1 + req1)
        AddUILog("BOT_V5", string.format("Fase 1 completada. Duración: %.2fs", req1), Color3.fromRGB(200,200,200))
        
        AddUILog("BOT_V5", ">> Ejecutando fase 2: Pour...", Color3.fromRGB(150,255,150))
        local s2, r2 = SafeInvoke(forgeRF, "Pour", trueTime1)
        
        local req2, start2 = ExtractTimes(r2)
        req2 = req2 or DEFAULT_SAFE_DELAY
        start2 = start2 or workspace:GetServerTimeNow()
        local trueTime2 = WaitUntilServerTime(start2 + req2)
        AddUILog("BOT_V5", string.format("Fase 2 completada. Duración: %.2fs", req2), Color3.fromRGB(200,200,200))
        
        AddUILog("BOT_V5", ">> Ejecutando fase 3: Hammer...", Color3.fromRGB(150,255,150))
        local s3, r3 = SafeInvoke(forgeRF, "Hammer", trueTime2)
        
        local req3, start3 = ExtractTimes(r3)
        req3 = req3 or DEFAULT_SAFE_DELAY
        start3 = start3 or workspace:GetServerTimeNow()
        local trueTime3 = WaitUntilServerTime(start3 + req3)
        AddUILog("BOT_V5", string.format("Fase 3 completada. Duración: %.2fs", req3), Color3.fromRGB(200,200,200))
        
        AddUILog("BOT_V5", ">> Ejecutando fase 4: Water (Círculos)...", Color3.fromRGB(150,255,150))
        local s4, r4 = SafeInvoke(forgeRF, "Water", trueTime3)
        
        local req4, start4 = ExtractTimes(r4)
        req4 = req4 or DEFAULT_SAFE_DELAY
        start4 = start4 or workspace:GetServerTimeNow()
        WaitUntilServerTime(start4 + req4)
        AddUILog("BOT_V5", string.format("Fase 4 completada. Duración: %.2fs", req4), Color3.fromRGB(200,200,200))
        
        AddUILog("BOT_V5", ">> ¡Se completó la orquestración de red! Enviando Showcase...", Color3.fromRGB(255,255,50))
        SafeInvoke(forgeRF, "Showcase", nil)
        AddUILog("BOT_V5", "=== ESPADA CREADA Y RECIBIDA ===", Color3.fromRGB(0,255,0))
        
        task.wait(1)
        PlayerCleanup()
        BotJugandoAhoraMismo = false
    end)
}

-- ==========================================
-- EL HOOK BESTIAL V5.0 (Cliente -> Servidor)
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

local OriginalNamecall
OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and method == "InvokeServer" then
        local fullName = self.GetFullName(self)
        local nameLower = string.lower(fullName)
        
        if string.find(nameLower, "changesequence") then
            local phaseName = tostring(args[1])
            
            if BotBypassingNetwork then
                return OriginalNamecall(self, ...)
            end
            
            -- ==========================================
            -- BLOQUEO VERDADERO AL SCRIPT NATIVO DE ROBLOX
            -- ==========================================
            if phaseName ~= "Melt" and ModosBypass.BotActivo and BotJugandoAhoraMismo then
                task.spawn(function() AddUILog("BLOCK", "Señal NATIVA Anulada [" .. phaseName .. "].", Color3.fromRGB(255, 50, 50)) end)
                return nil 
            end
            
            local RetTuple = {OriginalNamecall(self, ...)}
            local returnVal = RetTuple[1]
            
            task.spawn(function()
                if phaseName == "Melt" then
                    AddUILog("INTERCEPT", "Señal Legal Interceptada. Calculando Rutina OMEGA.", Color3.fromRGB(255,100,255))
                    if ModosBypass.BotActivo and not BotJugandoAhoraMismo then
                        ExecutePerfectSequence(self, returnVal)
                    end
                end
            end)
            
            return unpack(RetTuple)
        end
    end
    
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

AddUILog("SISTEMA", "V5.0 INICIADA. THE OMEGA BOT ACTIVO.", Color3.fromRGB(150, 255, 150))
AddUILog("AVISO", "El script te devolverá la cámara al finalizar, y calculará tolerancias humanas extremas. ¡A por la Perfección!", Color3.fromRGB(200, 255, 100))
