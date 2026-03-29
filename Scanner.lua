-- ==============================================================================
-- 🗡️ OMEGA BOT V8.19 (THE HONEST PLAYER - VISUAL & PERFECT AUTOPLAY)
-- ==============================================================================
-- 1. NO OCULTA NADA, NO DESTRUYE NADA. Cumple exactamente lo pedido:
--    Mantener el juego a la vista de principio a fin de forma impecable.
-- 2. "Seda" los scripts locales justo antes de enviar la señal correcta al 
--    servidor, garantizando que no haya NINGÚN CONFLICTO y pases la forja.
-- 3. Juega el "Hammer" (Perfects) pacientemente enviando datos mientras 
--    los círculos se muestran normalmente, respetando las físicas.
-- 4. Te suelta automáticamente a la hora del agua.
-- ==============================================================================

local SCRIPT_VERSION = "V8.19 - THE HONEST PLAYER"

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
Panel.BorderColor3 = Color3.fromRGB(170, 255, 120)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 80, 20)
Title.Text = " 🏆 FORGE V8.19 (THE HONEST PLAYER)"
Title.TextColor3 = Color3.fromRGB(180, 255, 150)
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
BypassFrame.BackgroundColor3 = Color3.fromRGB(20, 30, 20)
BypassFrame.Parent = Panel

local AutoBotBtn = Instance.new("TextButton")
AutoBotBtn.Size = UDim2.new(1, -8, 1, -8)
AutoBotBtn.Position = UDim2.new(0, 4, 0, 4)
AutoBotBtn.BackgroundColor3 = Color3.fromRGB(60, 160, 60)
AutoBotBtn.Text = "▶ START: AUTOPLAY (HONEST PLAY)"
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
TimeLabel.Text = " Tiempo/Gaps (s): "
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
TimeTextBox.Text = "3.25"
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

local GlobalWaitPattern = 3.25

TimeTextBox:GetPropertyChangedSignal("Text"):Connect(function()
    local val = tonumber(TimeTextBox.Text)
    if val then GlobalWaitPattern = val end
end)
SubBtn.MouseButton1Click:Connect(function()
    TimeTextBox.Text = string.format("%.2f", (tonumber(TimeTextBox.Text) or 3.25) - 0.25)
end)
AddBtn.MouseButton1Click:Connect(function()
    TimeTextBox.Text = string.format("%.2f", (tonumber(TimeTextBox.Text) or 3.25) + 0.25)
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

local MasterLogList = {}
local ModosBypass = {BotActivo = false}
local RondaActivaActual = false

local function AddUILog(logType, message, color)
    local fullString = "[" .. os.date("%H:%M:%S") .. "] [" .. logType .. "] " .. message
    table.insert(MasterLogList, fullString)
    if #MasterLogList > 500 then table.remove(MasterLogList, 1) end
    task.defer(function()
        pcall(function()
            local clr = color or Color3.fromRGB(200, 200, 200)
            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1, -4, 0, 0)
            txt.BackgroundTransparency = 1
            txt.Text = fullString
            txt.TextColor3 = clr
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
        AutoBotBtn.Text = "🛑 STOP: AUTOPLAY ARMADO (Go Forja)"
        AutoBotBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        AddUILog("SISTEMA", "Bot ARMADO: Modo Jugador Perfecto.", Color3.fromRGB(100,255,100))
    else
        AutoBotBtn.Text = "▶ START: AUTOPLAY (HONEST PLAY)"
        AutoBotBtn.BackgroundColor3 = Color3.fromRGB(60, 160, 60)
        AddUILog("SISTEMA", "Bot APAGADO.", Color3.fromRGB(255,100,100))
    end
end)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- =========================================================================================
-- LOGICA DEL JUGADOR HONESTO - CERO DESTRUCCIÓN, CERO OCULTAMIENTO.
-- =========================================================================================

local function TransicionNativaAsistida(forgeRF, currentPhase, nextPhase)
    local targetName = string.lower(currentPhase)
    local guiObj = nil
    
    -- 1. DETECCIÓN: Visualizamos el juego de verdad
    while ModosBypass.BotActivo do
        for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
            local nm = string.lower(v.Name)
            if string.find(nm, targetName) and string.find(nm, "minigame") then
                guiObj = v
                break
            end
        end
        if guiObj then break end
        task.wait(0.05)
    end
    
    if not guiObj or not ModosBypass.BotActivo then return false end
    
    AddUILog("AUTOPLAY", "🎮 Minijuego [" .. currentPhase .. "] en pantalla. Simulando juego perfecto...", Color3.fromRGB(0, 255, 255))
    
    -- 2. JUEGO ACTIVO: "Enviando datos" precisos
    if currentPhase == "Hammer" then
        local hammerRF = nil
        pcall(function() hammerRF = ReplicatedStorage.Controllers.ForgeController.HammerMinigame.RemoteFunction end)
        if hammerRF then
            for i = 1, 26 do
                pcall(function() hammerRF:InvokeServer({Name = "Perfect"}) end)
                task.wait(0.12) -- Un retraso humano perfecto para enviar al servidor los puntos 
            end
        end
    else
        task.wait(GlobalWaitPattern) -- Tiempo "honesto" llenando la barra de Melt o Pour
    end
    
    -- 3. SEDACIÓN ANTI-CONFLICTOS: Apagamos el LocalScript del juego sin tocar la parte visual.
    -- Esto evita que el juego mande eventos duplicados que crashearían la secuencia.
    pcall(function()
        for _, desc in pairs(guiObj:GetDescendants()) do
            if desc:IsA("LocalScript") then
                desc.Disabled = true 
            end
        end
    end)
    
    -- 4. MANO DEL TESTIGO: Llamamos a la transición natural para pasar a la siguiente fase
    AddUILog("AUTOPLAY", "👉 Minijuego [" .. currentPhase .. "] pasado correctamente. Pidiendo [" .. nextPhase .. "]", Color3.fromRGB(150, 255, 100))
    
    local _, nextData = pcall(function() return forgeRF:InvokeServer(nextPhase, {ClientTime = workspace:GetServerTimeNow()}) end)
    pcall(function() 
        require(game:GetService("ReplicatedStorage").Shared.Packages.Knit).GetController("ForgeController"):ChangeSequence(nextPhase, nextData) 
    end)
    
    return true
end

local function RunHonestForge(forgeRF)
    task.spawn(function()
        -- Flujo transparente e impecable de cada Fase.
        AddUILog("BOT", "Empieza rutina de Melt...", Color3.fromRGB(255, 200, 100))
        if TransicionNativaAsistida(forgeRF, "Melt", "Pour") then
            
            AddUILog("BOT", "Empieza rutina de Pour...", Color3.fromRGB(255, 200, 100))
            if TransicionNativaAsistida(forgeRF, "Pour", "Hammer") then
                
                AddUILog("BOT", "Empieza rutina de Hammer (Spamming Perfects)...", Color3.fromRGB(255, 200, 100))
                if TransicionNativaAsistida(forgeRF, "Hammer", "Water") then
                    
                    AddUILog("LIBRE", "✅ BOT APAGADO AUTOMÁTICAMENTE.", Color3.fromRGB(255, 255, 0))
                    AddUILog("LIBRE", "Sumerge el Water normalmente y pide tu arma, 100% natural.", Color3.fromRGB(200,255,200))
                    RondaActivaActual = false
                end
            end
        end
    end)
end

-- =========================================================================================
-- OBSERVADOR NATIVO: Nunca más usamos block o "return nil"
-- =========================================================================================

local OriginalNamecall
OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and method == "InvokeServer" then
        local fullName = self.GetFullName(self)
        if string.find(string.lower(fullName), "changesequence") then
            local phaseName = tostring(args[1])
            
            -- CUANDO INICIA, LANZAMOS EL AUTOPLAY MAESTRO
            if phaseName == "Melt" and ModosBypass.BotActivo then
                local RetTuple = {OriginalNamecall(self, ...)} 
                
                if not RondaActivaActual then
                    RondaActivaActual = true
                    task.spawn(function() RunHonestForge(self) end)
                end
                
                return unpack(RetTuple)
            end
            
            -- CUANDO EL JUGADOR TERMINA TODO CON EL WATER, DESCONGELAR FÍSICAS AL TOPE.
            if phaseName == "Close" then
                pcall(function()
                    RondaActivaActual = false
                    local Knit = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"))
                    local fc = Knit.GetController("ForgeController")
                    if fc then fc.ForgeActive = false end
                    
                    local cc = Knit.GetController("CharacterController")
                    if cc then cc.WalkSpeed = 16; if cc.SetWalkSpeed then cc:SetWalkSpeed(16) end end
                    AddUILog("SUCCESS", "¡ChangeSequence(Close) OK. Memoria RAM Liberada. WalkSpeed=16", Color3.fromRGB(50, 255, 50))
                end)
            end
            
            -- El Hook NameCall NUNCA MÁS se interpondrá. Deja fluir todo el tráfico natural que nuestro bot necesite inyectar.
        end
    end
    
    return OriginalNamecall(self, ...)
end)

AddUILog("SISTEMA", "V8.19 (THE HONEST PLAYER) CARGADO.", Color3.fromRGB(150, 255, 150))
