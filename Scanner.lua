-- ==============================================================================
-- 🗡️ FORGE OMNI-ANALYZER V8.4 (UNFROZEN PATCH)
-- FIX: Ya no te deja pegado después de forjar.
-- - Fases 1-3: Bot las ejecuta rápido (skip animaciones)
-- - Fase 4 (Water): Bot la ejecuta pero permite animación de salida
-- - Showcase/EndForge: Permite UI nativa + fuerza descongelamiento
-- ==============================================================================

local SCRIPT_VERSION = "V8.4 - UNFROZEN PATCH"

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
Panel.BorderColor3 = Color3.fromRGB(150, 255, 255)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(10, 80, 50)
Title.Text = " 📡 FORGE V8.4 (UNFROZEN PATCH)"
Title.TextColor3 = Color3.fromRGB(150, 255, 200)
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

local BypassFrame = Instance.new("Frame")
BypassFrame.Size = UDim2.new(1, -8, 0, 40)
BypassFrame.Position = UDim2.new(0, 4, 0, 35)
BypassFrame.BackgroundColor3 = Color3.fromRGB(30, 10, 30)
BypassFrame.Parent = Panel
Instance.new("UICorner", BypassFrame).CornerRadius = UDim.new(0, 4)

local AutoBotBtn = Instance.new("TextButton")
AutoBotBtn.Size = UDim2.new(1, -8, 1, -8)
AutoBotBtn.Position = UDim2.new(0, 4, 0, 4)
AutoBotBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
AutoBotBtn.Text = "🤖 START: HABILITAR OMEGA BOT"
AutoBotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoBotBtn.Font = Enum.Font.Code
AutoBotBtn.TextSize = 13
AutoBotBtn.Parent = BypassFrame

local TimeControlFrame = Instance.new("Frame")
TimeControlFrame.Size = UDim2.new(1, -8, 0, 30)
TimeControlFrame.Position = UDim2.new(0, 4, 0, 80)
TimeControlFrame.BackgroundColor3 = Color3.fromRGB(20, 30, 40)
TimeControlFrame.Parent = Panel

local TimeLabel = Instance.new("TextLabel")
TimeLabel.Size = UDim2.new(0, 150, 1, 0)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Text = " Tiempo de Forja (s): "
TimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TimeLabel.Font = Enum.Font.Code
TimeLabel.TextSize = 13
TimeLabel.TextXAlignment = Enum.TextXAlignment.Left
TimeLabel.Parent = TimeControlFrame

local TimeTextBox = Instance.new("TextBox")
TimeTextBox.Size = UDim2.new(0, 100, 1, -4)
TimeTextBox.Position = UDim2.new(0, 160, 0, 2)
TimeTextBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TimeTextBox.TextColor3 = Color3.fromRGB(0, 255, 255)
TimeTextBox.Text = "7.55"
TimeTextBox.Font = Enum.Font.Code
TimeTextBox.TextSize = 14
TimeTextBox.ClearTextOnFocus = false
TimeTextBox.Parent = TimeControlFrame
Instance.new("UICorner", TimeTextBox).CornerRadius = UDim.new(0, 4)

local SubBtn = Instance.new("TextButton")
SubBtn.Size = UDim2.new(0, 30, 1, -4)
SubBtn.Position = UDim2.new(0, 270, 0, 2)
SubBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
SubBtn.Text = "-"
SubBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubBtn.Parent = TimeControlFrame

local AddBtn = Instance.new("TextButton")
AddBtn.Size = UDim2.new(0, 30, 1, -4)
AddBtn.Position = UDim2.new(0, 305, 0, 2)
AddBtn.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
AddBtn.Text = "+"
AddBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AddBtn.Parent = TimeControlFrame

local GlobalDynamicTime = 7.55

TimeTextBox:GetPropertyChangedSignal("Text"):Connect(function()
    local val = tonumber(TimeTextBox.Text)
    if val then GlobalDynamicTime = val end
end)

SubBtn.MouseButton1Click:Connect(function()
    local val = tonumber(TimeTextBox.Text) or 7.55
    TimeTextBox.Text = string.format("%.2f", val - 0.1)
    GlobalDynamicTime = tonumber(TimeTextBox.Text) or 7.55
end)
AddBtn.MouseButton1Click:Connect(function()
    local val = tonumber(TimeTextBox.Text) or 7.55
    TimeTextBox.Text = string.format("%.2f", val + 0.1)
    GlobalDynamicTime = tonumber(TimeTextBox.Text) or 7.55
end)

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -8, 1, -165)
LogScroll.Position = UDim2.new(0, 4, 0, 120)
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

local MasterLogList = {}
local ModosBypass = {BotActivo = false}
local BotJugandoAhoraMismo = false
local BotBypassingNetwork = false
-- NUEVO: Bandera para la fase de salida - NO bloquear señales nativas
local BotEnFaseSalida = false

local DumpTableDeep
DumpTableDeep = function(tbl, depth)
    depth = depth or 0
    if type(tbl) ~= "table" then return tostring(tbl) end
    if depth > 5 then return "{MAX_DEPTH}" end
    local str = "{"
    for k, v in pairs(tbl) do
        local vt = typeof(v)
        if vt == "table" then str = str .. "["..tostring(k).."]=" .. DumpTableDeep(v, depth + 1) .. ", "
        else str = str .. "["..tostring(k).."]=" .. tostring(v) .. ", " end
    end
    return str .. "}"
end

local function SaveLogToFile(message)
    task.spawn(function()
        pcall(function()
            local filename = "ForgeAnalyzerLogs_V8.txt"
            if appendfile then appendfile(filename, message .. "\n")
            elseif writefile then
                local current = ""
                pcall(function() current = readfile(filename) end)
                writefile(filename, current .. message .. "\n")
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
        AutoBotBtn.Text = "🛑 STOP: BOT HABILITADO (Presiona GO en Forja)"
        AutoBotBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        AddUILog("SISTEMA", "Bot ARMADO usando el tiempo de " .. TimeTextBox.Text .. "s.", Color3.fromRGB(100,255,100))
    else
        AutoBotBtn.Text = "🤖 START: HABILITAR OMEGA BOT"
        AutoBotBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        AddUILog("SISTEMA", "Bot APAGADO.", Color3.fromRGB(255,100,100))
    end
end)

ClearBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(LogScroll:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
    MasterLogList = {}
end)
CopyBtn.MouseButton1Click:Connect(function()
    local result = "=== REPORTE TOTAL SIN FILTROS (V8.4) ===\n\n"
    for i, _ in ipairs(MasterLogList) do result = result .. MasterLogList[i] .. "\n" end
    if setclipboard then setclipboard(result); CopyBtn.Text = "✅ ¡COPIADO!" else CopyBtn.Text = "❌ ERROR" end
    task.delay(2, function() CopyBtn.Text = "📋 COPIAR AL PORTAPAPELES" end)
end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local function CatchServerResponses()
    local RS = game:GetService("ReplicatedStorage")
    for _, v in pairs(RS:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            if string.find(string.lower(v:GetFullName()), "knit") or string.find(string.lower(v.Name), "forge") then
                v.OnClientEvent:Connect(function(...)
                    local args = {...}
                    local dump = ""
                    for i, val in ipairs(args) do dump = dump .. "Arg["..i.."]="..tostring(val).." " end
                    if dump ~= "" then AddUILog("SERVER_SAYS", v.Name .. " >> " .. dump, Color3.fromRGB(0, 255, 0)) end
                end)
            end
        end
    end
end
CatchServerResponses()

local function ExtractTimes(tbl)
    local req, start = nil, nil
    local seen = {}
    local function search(t)
        if type(t) ~= "table" or seen[t] then return end
        seen[t] = true
        for k, v in pairs(t) do
            if type(k) == "string" and k == "RequiredTime" then req = v end
            if type(k) == "string" and k == "StartTime" then start = v end
            if type(v) == "table" then search(v) end
        end
    end
    search(tbl)
    return req, start
end

-- CAMBIADO: Ahora OCULTA en vez de destruir, y solo durante fases 1-3
local function HideNativeMinigames()
    for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name ~= "ForgeAnalyzerUI" then
            if string.find(string.lower(v.Name), "forge") or string.find(string.lower(v.Name), "minigame") then
                v.Enabled = false
            end
        end
    end
end

-- NUEVO: Restaurar UI nativa para la animación de salida
local function ShowNativeMinigames()
    for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name ~= "ForgeAnalyzerUI" then
            if string.find(string.lower(v.Name), "forge") or string.find(string.lower(v.Name), "minigame") then
                v.Enabled = true
            end
        end
    end
end

-- NUEVO: Forzar descongelamiento del personaje
local function ForceUnfreezeCharacter()
    local char = LocalPlayer.Character
    if not char then return end
    
    -- Desanclar todas las partes
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = false
        end
    end
    
    -- Restaurar movimiento del Humanoid
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    
    -- Limpiar cualquier BodyMover que te tenga pegado
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        for _, child in pairs(root:GetChildren()) do
            if child:IsA("BodyPosition") or child:IsA("BodyGyro") or child:IsA("AlignPosition") or child:IsA("AlignOrientation") then
                child:Destroy()
            end
        end
    end
end

local function SafeInvoke(forgeRF, phase, clientTimeParam)
    local s, r = false, nil
    local completed = false
    BotBypassingNetwork = true
    task.spawn(function()
        local _s, _r = pcall(function() 
            if clientTimeParam then return forgeRF:InvokeServer(phase, {ClientTime = clientTimeParam})
            else return forgeRF:InvokeServer(phase, {}) end
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
    local maxWait = targetTime + 2.0
    while workspace:GetServerTimeNow() < targetTime do
        if workspace:GetServerTimeNow() > maxWait then break end
        task.wait()
    end
    return workspace:GetServerTimeNow()
end

local function ExecutePerfectSequence(forgeRF, primerMeltReturn)
    task.spawn(function()
        xpcall(function()
            BotJugandoAhoraMismo = true
            BotEnFaseSalida = false
            HideNativeMinigames() -- OCULTAR en vez de destruir
            
            local DYNAMIC_TIME = GlobalDynamicTime
            if type(DYNAMIC_TIME) ~= "number" or DYNAMIC_TIME <= 0 then DYNAMIC_TIME = 7.55 end
            
            -- ═══ FASE 1: MELT (ya fue, datos en primerMeltReturn) ═══
            AddUILog("BOT_V8", ">> Fase 1: Sincronizando Melt...", Color3.fromRGB(50,255,200))
            local req1, start1 = ExtractTimes(primerMeltReturn)
            req1 = req1 or 2.15
            start1 = start1 or workspace:GetServerTimeNow()
            local trueTime1 = WaitUntilServerTime(start1 + req1)
            
            -- ═══ FASE 2: POUR (barra amarilla - SKIP) ═══
            AddUILog("BOT_V8", ">> Fase 2: Pour (SKIP animación)...", Color3.fromRGB(50,255,200))
            HideNativeMinigames()
            local s2, r2 = SafeInvoke(forgeRF, "Pour", trueTime1)
            local req2, start2 = ExtractTimes(r2)
            req2 = req2 or 4.50
            start2 = start2 or workspace:GetServerTimeNow()
            local trueTime2 = WaitUntilServerTime(start2 + req2)
            
            -- ═══ FASE 3: HAMMER (golpear - SKIP) ═══
            AddUILog("BOT_V8", ">> Fase 3: Hammer (SKIP animación)...", Color3.fromRGB(50,255,200))
            HideNativeMinigames()
            local s3, r3 = SafeInvoke(forgeRF, "Hammer", trueTime2)
            local req3, start3 = ExtractTimes(r3)
            req3 = req3 or DYNAMIC_TIME
            start3 = start3 or workspace:GetServerTimeNow()
            AddUILog("BOT_V8", "⏳ Hammer Delay: " .. string.format("%.2f", req3) .. "s...", Color3.fromRGB(200, 150, 0))
            local trueTime3 = WaitUntilServerTime(start3 + req3)
            
            -- ═══ FASE 4: WATER (círculos - SKIP pero preparar salida) ═══
            AddUILog("BOT_V8", ">> Fase 4: Water (SKIP animación)...", Color3.fromRGB(50,255,200))
            local s4, r4 = SafeInvoke(forgeRF, "Water", trueTime3)
            local req4, start4 = ExtractTimes(r4)
            req4 = req4 or DYNAMIC_TIME
            start4 = start4 or workspace:GetServerTimeNow()
            AddUILog("BOT_V8", "⏳ Water Delay: " .. string.format("%.2f", req4) .. "s...", Color3.fromRGB(255, 50, 50))
            WaitUntilServerTime(start4 + req4)
            
            -- ═══════════════════════════════════════════════════
            -- FASE DE SALIDA: Dejar de bloquear ANTES de Showcase
            -- ═══════════════════════════════════════════════════
            AddUILog("BOT_V8", ">> 🔓 DESBLOQUEANDO señales nativas para salida...", Color3.fromRGB(255,255,50))
            BotEnFaseSalida = true  -- Ya NO bloquear señales nativas
            ShowNativeMinigames()   -- Restaurar UI para animación de salida
            
            AddUILog("BOT_V8", ">> 🗡️ Enviando Showcase (ver arma en balde)...", Color3.fromRGB(255,255,50))
            SafeInvoke(forgeRF, "Showcase", nil)
            task.wait(3) -- Dejar que la animación del arma en balde se vea
            
            AddUILog("BOT_V8", ">> Enviando EndForge...", Color3.fromRGB(255,100,50))
            SafeInvoke(forgeRF, "EndForge", nil)
            task.wait(1)
            
            -- ═══════════════════════════════════════════════════
            -- DESCONGELAMIENTO FORZADO
            -- ═══════════════════════════════════════════════════
            AddUILog("BOT_V8", ">> 🧊 Forzando descongelamiento del personaje...", Color3.fromRGB(100, 200, 255))
            ForceUnfreezeCharacter()
            task.wait(0.5)
            ForceUnfreezeCharacter() -- Doble por si acaso
            
            BotJugandoAhoraMismo = false
            BotEnFaseSalida = false
            AddUILog("BOT_V8", "=== ✅ ESPADA CREADA - PERSONAJE LIBRE ===", Color3.fromRGB(0,255,0))
            
            -- Último intento de limpieza 2 segundos después
            task.delay(2, function()
                ForceUnfreezeCharacter()
                -- Limpiar UIs de forja que quedaron
                for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
                    if v:IsA("ScreenGui") and v.Name ~= "ForgeAnalyzerUI" then
                        if string.find(string.lower(v.Name), "forge") or string.find(string.lower(v.Name), "minigame") then
                            pcall(function() v:Destroy() end)
                        end
                    end
                end
            end)
            
        end, function(err)
            BotJugandoAhoraMismo = false
            BotEnFaseSalida = false
            ForceUnfreezeCharacter() -- Descongelar incluso si hay error
            AddUILog("FATAL_ERROR", "ERROR: " .. tostring(err), Color3.fromRGB(255, 0, 0))
        end)
    end)
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
            
            -- Si el bot está bypasseando (enviando sus propios datos), dejar pasar
            if BotBypassingNetwork then return OriginalNamecall(self, ...) end
            
            -- NUEVO: Si estamos en fase de salida, dejar pasar TODO (no bloquear)
            if BotEnFaseSalida then
                return OriginalNamecall(self, ...)
            end
            
            -- Bloquear señales nativas SOLO durante las fases de minigame (1-4)
            if phaseName ~= "Melt" and ModosBypass.BotActivo and BotJugandoAhoraMismo then
                task.spawn(function() AddUILog("BLOCK", "Señal NATIVA Anulada [" .. phaseName .. "].", Color3.fromRGB(255, 50, 50)) end)
                return nil 
            end
            
            local RetTuple = {OriginalNamecall(self, ...)}
            local returnVal = RetTuple[1]
            task.spawn(function()
                if phaseName == "Melt" then
                    AddUILog("INTERCEPT", "Melt detectado. ¡El Omega Bot toma el control!", Color3.fromRGB(255,100,255))
                    if ModosBypass.BotActivo and not BotJugandoAhoraMismo then ExecutePerfectSequence(self, returnVal) end
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
                for _, w in pairs(BlacklistWords) do if string.find(nameLower, w) then skip = true break end end
                
                if not skip and not string.find(nameLower, "changesequence") then
                    local argDump = ""
                    for i, v in ipairs(args) do
                        if typeof(v) == "table" then
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

AddUILog("SISTEMA", SCRIPT_VERSION .. " INICIADA. Fix anti-congelamiento ACTIVO.", Color3.fromRGB(150, 255, 150))
