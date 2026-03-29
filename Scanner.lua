-- ==============================================================================
-- 🗡️ FORGE OMNI-ANALYZER V8.8 (THE ARCHITECT PERFECTED)
-- ==============================================================================
-- ¡La obra maestra final! Utilizando tu código base (V8.3) que era el único que 
-- hacía la sincronización de tiempo inteligente y dejaba pasar el primer clic de 
-- inicio (Melt), he inyectado los tres descubrimientos masivos:
-- 1. "Hide" en vez de "Destroy" (Para no crashear tu cliente)
-- 2. Tormenta de Perfects al remote escondido del Martillo ("Perfect Overflow")
-- 3. Llamada final al remote genuino de EndForge para evitar el freeze.
-- ==============================================================================

local SCRIPT_VERSION = "V8.8 - THE ARCHITECT PERFECTED"

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
Title.Text = " 📡 FORGE V8.8 (ARCHITECT PERFECTED)"
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
TimeLabel.Text = " Tiempo Failsafe (s): "
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

local GlobalDynamicTime = 7.55
TimeTextBox:GetPropertyChangedSignal("Text"):Connect(function()
    local val = tonumber(TimeTextBox.Text)
    if val then GlobalDynamicTime = val end
end)

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -8, 1, -125)
LogScroll.Position = UDim2.new(0, 4, 0, 120)
LogScroll.BackgroundColor3 = Color3.fromRGB(10, 15, 10)
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogScroll.ScrollBarThickness = 6
LogScroll.Parent = Panel
local ListLayout = Instance.new("UIListLayout", LogScroll)
ListLayout.Padding = UDim.new(0, 2)

local MasterLogList = {}
local ModosBypass = {BotActivo = false}
local BotJugandoAhoraMismo = false
local BotBypassingNetwork = false

local function AddUILog(logType, message, color)
    local fullString = "[" .. os.date("%H:%M:%S") .. "] [" .. logType .. "] " .. message
    table.insert(MasterLogList, fullString)
    if #MasterLogList > 200 then 
        table.remove(MasterLogList, 1)
        local f = LogScroll:FindFirstChildWhichIsA("TextLabel")
        if f then pcall(function() f:Destroy() end) end
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
        AutoBotBtn.Text = "🛑 STOP: BOT HABILITADO (Presiona FORJAR)"
        AutoBotBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        AddUILog("SISTEMA", "Bot ARMADO. Ve y pon los minerales.", Color3.fromRGB(100,255,100))
    else
        AutoBotBtn.Text = "🤖 START: HABILITAR OMEGA BOT"
        AutoBotBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        AddUILog("SISTEMA", "Bot APAGADO.", Color3.fromRGB(255,100,100))
    end
end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

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

local function HideNativeMinigames()
    for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
        if string.find(string.lower(v.Name), "forge") or string.find(string.lower(v.Name), "minigame") then
            if v.Name ~= "ForgeAnalyzerUI" and v:IsA("ScreenGui") then
                pcall(function() v.Enabled = false end)
            end
        end
    end
end

local function ForceUnfreezeCharacter()
    pcall(function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Anchored = false end
    end)
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
    if not completed then AddUILog("TIMEOUT", "Server retrasó: " .. phase, Color3.fromRGB(255,100,0)) end
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
            HideNativeMinigames()
            
            local DYNAMIC_TIME = GlobalDynamicTime
            if type(DYNAMIC_TIME) ~= "number" or DYNAMIC_TIME <= 0 then DYNAMIC_TIME = 7.55 end
            
            AddUILog("BOT_V8", ">> Fase 1: Sincronizando Melt...", Color3.fromRGB(50,255,200))
            local req1, start1 = ExtractTimes(primerMeltReturn)
            req1 = req1 or 2.15
            start1 = start1 or workspace:GetServerTimeNow()
            local trueTime1 = WaitUntilServerTime(start1 + req1)
            
            AddUILog("BOT_V8", ">> Ejecutando fase 2: Pour...", Color3.fromRGB(50,255,200))
            local s2, r2 = SafeInvoke(forgeRF, "Pour", trueTime1)
            local req2, start2 = ExtractTimes(r2)
            req2 = req2 or 4.50
            start2 = start2 or workspace:GetServerTimeNow()
            local trueTime2 = WaitUntilServerTime(start2 + req2)
            
            AddUILog("BOT_V8", ">> Ejecutando fase 3: Hammer...", Color3.fromRGB(50,255,200))
            local s3, r3 = SafeInvoke(forgeRF, "Hammer", trueTime2)
            local req3, start3 = ExtractTimes(r3)
            req3 = req3 or DYNAMIC_TIME
            start3 = start3 or workspace:GetServerTimeNow()
            AddUILog("BOT_V8", "⏳ Overflow de 25 Perfects inyectados en: " .. string.format("%.2f", req3) .. "s...", Color3.fromRGB(200, 150, 0))
            
            -- INYECTAR PERFECTS SIN PARAR
            task.spawn(function()
                local hammerRF = nil
                pcall(function() hammerRF = ReplicatedStorage.Controllers.ForgeController.HammerMinigame.RemoteFunction end)
                if hammerRF then
                    for i=1, 25 do
                        BotBypassingNetwork = true
                        pcall(function() hammerRF:InvokeServer({Name = "Perfect"}) end)
                        BotBypassingNetwork = false
                        task.wait(req3 / 25)
                    end
                end
            end)
            
            local trueTime3 = WaitUntilServerTime(start3 + req3)
            
            AddUILog("BOT_V8", ">> Ejecutando fase 4: Water...", Color3.fromRGB(50,255,200))
            local s4, r4 = SafeInvoke(forgeRF, "Water", trueTime3)
            local req4, start4 = ExtractTimes(r4)
            req4 = req4 or DYNAMIC_TIME
            start4 = start4 or workspace:GetServerTimeNow()
            WaitUntilServerTime(start4 + req4)
            
            AddUILog("BOT_V8", ">> Finalizando... Enviando Showcase.", Color3.fromRGB(255,255,50))
            SafeInvoke(forgeRF, "Showcase", nil)
            task.wait(2.5) 
            
            AddUILog("BOT_V8", ">> 🚀 Enviando el verdadero END_FORGE.", Color3.fromRGB(255,100,50))
            pcall(function()
                local endForgeRF = forgeRF.Parent:FindFirstChild("EndForge")
                if endForgeRF then
                    BotBypassingNetwork = true
                    endForgeRF:InvokeServer()
                    BotBypassingNetwork = false
                end
            end)
            
            AddUILog("BOT_V8", "✅ ESPADA OMEGA FORJADA. Personaje Desbloqueado.", Color3.fromRGB(0,255,0))
            ForceUnfreezeCharacter()
            BotJugandoAhoraMismo = false
            HideNativeMinigames()
            
        end, function(err)
            BotJugandoAhoraMismo = false
            AddUILog("FATAL_ERROR", "ERROR DEL SISTEMA: " .. tostring(err), Color3.fromRGB(255, 0, 0))
            ForceUnfreezeCharacter()
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
        
        -- Si el bot es quien está mandando señales, dejamos que pasen como fantasma
        if BotBypassingNetwork then return OriginalNamecall(self, ...) end
        
        if string.find(nameLower, "changesequence") then
            local phaseName = tostring(args[1])
            
            -- Bloquea a la interfaz real de seguir avanzando y crashearte
            if phaseName ~= "Melt" and ModosBypass.BotActivo and BotJugandoAhoraMismo then
                return nil 
            end
            
            -- EJECUTA LA SEÑAL ORIGINAL DE MELT PARA QUE EL SERVIDOR SÍ EMPIECE!
            local RetTuple = {OriginalNamecall(self, ...)}
            local returnVal = RetTuple[1]
            
            task.spawn(function()
                if phaseName == "Melt" then
                    AddUILog("INTERCEPT", "Se conectó el Inicio. Bot tomando control.", Color3.fromRGB(255,100,255))
                    if ModosBypass.BotActivo and not BotJugandoAhoraMismo then 
                        ExecutePerfectSequence(self, returnVal) 
                    end
                end
            end)
            return unpack(RetTuple)
        end
    end
    
    return OriginalNamecall(self, ...)
end)

AddUILog("SISTEMA", "V8.8 ARCHITECT PERFECTED. Solucionado el 'Fantasma' del clic.", Color3.fromRGB(150, 255, 150))
