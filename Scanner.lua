-- ==============================================================================
-- 🗡️ OMEGA BOT V8.18 (THE GOD RELEASE - THE PASSIVE ASSISTANT)
-- ==============================================================================
-- 1. Los contadores (3, 2, 1) y los focos de cámara se MANTIENEN VISIBLES intactos.
-- 2. Los juegos (Melt, Pour, Hammer) se OCULTAN visualmente en lugar de destruirse.
-- 3. AL LLEGAR A "WATER", EL BOT SE APAGA TEMPORALMENTE: "Suelta todo". 
-- 4. El jugador debe hacer el minijuego de Agua de forma natural. 
-- 5. Como el final es puramente nativo, la variable ForgeActive regresará 
--    a "false" como está programada en el juego, ¡ELIMINANDO EL FREEZE FINAL DE RAÍZ!
-- ==============================================================================

local SCRIPT_VERSION = "V8.18 - THE GOD RELEASE"

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
Title.Text = " 📡 FORGE V8.18 (NATIVE SYNC)"
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
AutoBotBtn.Text = "🤖 START: HABILITAR OMEGA BOT (PACIENTE)"
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
TimeTextBox.Text = "2.50"
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

local GlobalWaitPattern = 2.50

TimeTextBox:GetPropertyChangedSignal("Text"):Connect(function()
    local val = tonumber(TimeTextBox.Text)
    if val then GlobalWaitPattern = val end
end)

SubBtn.MouseButton1Click:Connect(function()
    local val = tonumber(TimeTextBox.Text) or 2.50
    TimeTextBox.Text = string.format("%.2f", val - 0.1)
    GlobalWaitPattern = tonumber(TimeTextBox.Text) or 2.50
end)
AddBtn.MouseButton1Click:Connect(function()
    local val = tonumber(TimeTextBox.Text) or 2.50
    TimeTextBox.Text = string.format("%.2f", val + 0.1)
    GlobalWaitPattern = tonumber(TimeTextBox.Text) or 2.50
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
local BotBypassingNetwork = false
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
        AutoBotBtn.Text = "🛑 STOP: BOT PACIENTE (Go Forja)"
        AutoBotBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        AddUILog("SISTEMA", "Bot ARMADO. Ignorará el agua al final.", Color3.fromRGB(100,255,100))
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
    if setclipboard then setclipboard(table.concat(MasterLogList, "\n")); CopyBtn.Text = "✅ ¡COPIADO!" end
    task.delay(2, function() CopyBtn.Text = "📋 COPIAR AL PORTAPAPELES" end)
end)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local function SafeInvoke(forgeRF, phase)
    local s, r = false, nil
    BotBypassingNetwork = true
    local _s, _r = pcall(function() 
        return forgeRF:InvokeServer(phase, {ClientTime = workspace:GetServerTimeNow()})
    end)
    s, r = _s, _r
    BotBypassingNetwork = false
    return s, r
end

-- Detector de Lanzamiento Milimétrico: No adivina los tiempos.
-- Escanea constantemente hasta que el juego genera la UI del minijuego (después de "GO").
local function EsperarLanzamientoDeJuego(faseName)
    local targetName = string.lower(faseName)
    local activeGui = nil
    
    -- Esperamos infaliblemente a que el juego nativo decida instanciar/mostrar el minijuego
    while ModosBypass.BotActivo do
        for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
            local vName = string.lower(v.Name)
            if string.find(vName, targetName) and string.find(vName, "minigame") then
               if v:IsA("ScreenGui") then
                   if v.Enabled then activeGui = v break end
               elseif v:IsA("GuiObject") then
                   if v.Visible then activeGui = v break end
               else
                   -- Si es un Frame o Folder instanciado invisiblemente, si existe lo atacamos.
                   activeGui = v
                   break
               end
            end
        end
        if activeGui then break end
        task.wait(0.05)
    end
    
    if activeGui then
        -- LO OCULTAMOS, PERO JAMÁS LO DESTRUIMOS.
        -- Como dijiste en el audio "no los destruyas, ocúltalos".
        -- Si destruimos el gui, el juego nativo piensa que se completó y corrompe nuestra inyección.
        pcall(function()
            if activeGui:IsA("ScreenGui") then 
                activeGui.Enabled = false 
            elseif activeGui:IsA("GuiObject") then 
                activeGui.Visible = false
                activeGui.Position = UDim2.new(99, 0, 99, 0)
            else 
                -- Si es un modelo o frame suelto
                pcall(function() activeGui.Visible = false end)
                pcall(function() activeGui.Transparency = 1 end)
            end
        end)
        AddUILog("UI_KILL", "Juego [" .. faseName .. "] detectado y OCULTADO de pantalla.", Color3.fromRGB(250,150,50))
    end
end

local function RunPassiveForgeAssist(forgeRF, initialMeltData)
    task.spawn(function()
        local Knit = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"))
        local ForgeController = Knit.GetController("ForgeController")
        
        -- ========== FASE MELT ==========
        AddUILog("BOT", ">> FASE 1: MELT. Esperando a que termine el contador...", Color3.fromRGB(0,255,255))
        EsperarLanzamientoDeJuego("Melt")
        
        local s1, pourData = SafeInvoke(forgeRF, "Pour")
        if s1 and pourData then
            AddUILog("BOT", "Avanzando NATIVAMENTE a POUR...", Color3.fromRGB(0,255,100))
            pcall(function() ForgeController:ChangeSequence("Pour", pourData) end)
            
            -- ========== FASE POUR ==========
            AddUILog("BOT", ">> FASE 2: POUR. Esperando a que termine el contador...", Color3.fromRGB(0,255,255))
            EsperarLanzamientoDeJuego("Pour")
            
            local s2, hammerData = SafeInvoke(forgeRF, "Hammer")
            if s2 and hammerData then
                AddUILog("BOT", "Avanzando NATIVAMENTE a HAMMER...", Color3.fromRGB(0,255,100))
                pcall(function() ForgeController:ChangeSequence("Hammer", hammerData) end)
                
                -- ========== FASE HAMMER (PERFECTS) ==========
                AddUILog("BOT", ">> FASE 3: HAMMER. Esperando a que termine el contador...", Color3.fromRGB(0,255,255))
                EsperarLanzamientoDeJuego("Hammer")
                
                local hammerRF = nil
                pcall(function() hammerRF = ReplicatedStorage.Controllers.ForgeController.HammerMinigame.RemoteFunction end)
                if hammerRF then
                    AddUILog("BOT", "Spammeando 25 Perfects (Hammer)...", Color3.fromRGB(150,0,255))
                    for i=1, 25 do
                        pcall(function() hammerRF:InvokeServer({Name = "Perfect"}) end)
                        task.wait(0.05)
                    end
                else
                    task.wait(1.5)
                end
                
                -- ========== FASE WATER ==========
                local s3, waterData = SafeInvoke(forgeRF, "Water")
                if s3 and waterData then
                    AddUILog("BOT", "Avanzando NATIVAMENTE a WATER...", Color3.fromRGB(0,255,100))
                    pcall(function() ForgeController:ChangeSequence("Water", waterData) end)
                    
                    AddUILog("LIBRE", "✅ BOT SUELTA EL CONTROL. ¡Sumérgelo naturalmente!", Color3.fromRGB(255,255,0))
                end
            end
        end
    end)
end

local OriginalNamecall
OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and method == "InvokeServer" then
        local fullName = self.GetFullName(self)
        if string.find(string.lower(fullName), "changesequence") then
            local phaseName = tostring(args[1])
            
            if phaseName == "Melt" and ModosBypass.BotActivo then
                local RetTuple = {OriginalNamecall(self, ...)} 
                
                if not RondaActivaActual then
                    RondaActivaActual = true
                    task.spawn(function() RunPassiveForgeAssist(self, RetTuple[1]) end)
                end
                
                return unpack(RetTuple)
            end
            
            -- Bloquear ChangeSequence fantasmas del script local rezagado, para "Pour", "Hammer" y "Water"
            if RondaActivaActual and (phaseName == "Pour" or phaseName == "Hammer" or phaseName == "Water") then
                if BotBypassingNetwork then 
                    return OriginalNamecall(self, ...)
                else
                    pcall(function() AddUILog("BLOCK", "Native Lento Anulado [" .. phaseName .. "].", Color3.fromRGB(150, 50, 50)) end)
                    return nil
                end
            end
            
            -- Cuando el jugador complete el juego nativamente (pasando el agua) se registrará "Showcase" o "Close"
            if phaseName == "Close" then
                RondaActivaActual = false
                pcall(function()
                    -- APLICAMOS EL "SANTO GRIAL" QUE ENCONTRAMOS EN EL DUMP:
                    local Knit = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"))
                    local fc = Knit.GetController("ForgeController")
                    if fc then fc.ForgeActive = false end
                    
                    local cc = Knit.GetController("CharacterController")
                    if cc then cc.WalkSpeed = 16; if cc.SetWalkSpeed then cc:SetWalkSpeed(16) end end

                    AddUILog("SUCCESS", "¡ChangeSequence(Close) Ejecutado Nativamente!", Color3.fromRGB(50, 255, 50))
                    AddUILog("SUCCESS", "La variable ForgeActive ha sido destruida. Libre.", Color3.fromRGB(50, 255, 50))
                end)
            end
        end
    end
    
    return OriginalNamecall(self, ...)
end)

AddUILog("SISTEMA", "V8.18 (THE GOD RELEASE) CARGADO. Flujo Paciente Activado.", Color3.fromRGB(150, 255, 150))
