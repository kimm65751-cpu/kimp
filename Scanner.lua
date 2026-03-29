-- ==============================================================================
-- 🗡️ FORGE OMNI-ANALYZER V8.6 (NO-NAMECALL FINAL PATCH)
-- ==============================================================================
-- 🚨 SOLUCIÓN AL BUG DEL BOTÓN "¡FORJAR!":
-- Delta Executor rompe internamente la UI del juego (Eventos/ProximityPrompt)
-- si usamos `hookmetamethod(__namecall)`. En V8.6 se ELIMINÓ por completo.
-- Ahora interceptamos limpiamente los Módulos de Lua (como en V4.0).
-- ==============================================================================

local SCRIPT_VERSION = "V8.6 - NO-NAMECALL OMEGA"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local InputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local BotActivo = false
local BotEnFaseSalida = false
local TiempMelt = 7.55
local TiempPour = 3.55
local TiempWtr = 3.55
local TiempHmmr = 7.60
local InterceptMode = false

-- ==============================================
-- LIMPIEZA TOTAL PARA EL ANTI-FREEZE
-- ==============================================
local function DesaparecerForjaUIDelJuego()
    task.spawn(function()
        pcall(function()
            if LocalPlayer.PlayerGui:FindFirstChild("Forge") then
                LocalPlayer.PlayerGui.Forge.Enabled = false
            end
            if LocalPlayer.PlayerGui:FindFirstChild("ForgeRecipes") then
                LocalPlayer.PlayerGui.ForgeRecipes.Enabled = false
            end
        end)
    end)
end

local function ForceUnfreezeCharacter()
    pcall(function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Anchored = false
            for _, v in pairs(hrp:GetChildren()) do
                if v:IsA("BodyPosition") or v:IsA("BodyVelocity") or v:IsA("BodyGyro") then
                    v:Destroy()
                end
            end
        end
    end)
end

-- ==============================================
-- UI PRINCIPAL DEL BOT V8.6
-- ==============================================
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "ForgeAnalyzerUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ForgeAnalyzerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 560, 0, 420)
Panel.Position = UDim2.new(0, 5, 0, 5)
Panel.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
Panel.BorderSizePixel = 3
Panel.BorderColor3 = Color3.fromRGB(0, 255, 100)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 0, 28)
Title.BackgroundColor3 = Color3.fromRGB(0, 50, 20)
Title.Text = " " .. SCRIPT_VERSION
Title.TextColor3 = Color3.fromRGB(0, 255, 100)
Title.TextSize = 13
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Panel

local InterceptToggle = Instance.new("TextButton")
InterceptToggle.Size = UDim2.new(0, 110, 0, 26)
InterceptToggle.Position = UDim2.new(1, -170, 0, 1)
InterceptToggle.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
InterceptToggle.Text = "HOOK: OFF"
InterceptToggle.TextColor3 = Color3.new(1,1,1)
InterceptToggle.Font = Enum.Font.Code
InterceptToggle.Parent = Panel
InterceptToggle.MouseButton1Click:Connect(function()
    InterceptMode = not InterceptMode
    InterceptToggle.BackgroundColor3 = InterceptMode and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    InterceptToggle.Text = InterceptMode and "HOOK: ON" or "HOOK: OFF"
end)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 28)
MinimizeBtn.Position = UDim2.new(1, -60, 0, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.new(1,1,1)
MinimizeBtn.Font = Enum.Font.Code
MinimizeBtn.Parent = Panel

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 28)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.Code
CloseBtn.Parent = Panel
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -28)
Content.Position = UDim2.new(0, 0, 0, 28)
Content.BackgroundTransparency = 1
Content.Parent = Panel

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -10, 1, -80)
LogScroll.Position = UDim2.new(0, 5, 0, 5)
LogScroll.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.ScrollBarThickness = 6
LogScroll.Parent = Content

local UIList = Instance.new("UIListLayout")
UIList.Parent = LogScroll
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    LogScroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 10)
end)

local LogCount = 0
local function Log(texto, color)
    local t = os.date("%H:%M:%S")
    local line = Instance.new("TextLabel")
    line.Size = UDim2.new(1, -10, 0, 14)
    line.BackgroundTransparency = 1
    line.Text = "["..t.."] " .. texto
    line.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    line.TextSize = 11
    line.Font = Enum.Font.Code
    line.TextXAlignment = Enum.TextXAlignment.Left
    line.TextWrapped = true
    line.Parent = LogScroll
    line.Size = UDim2.new(1, -10, 0, line.TextBounds.Y + 2)
    LogScroll.CanvasPosition = Vector2.new(0, 99999)
    LogCount = LogCount + 1
    if LogCount > 250 then
        for _, v in pairs(LogScroll:GetChildren()) do
            if v:IsA("TextLabel") then v:Destroy() break end
        end
    end
end

-- ==============================================
-- LÓGICA DEL OMEGA BOT (INYECCIÓN DE REMOTES)
-- ==============================================
local function IniciarForjaAutomatica()
    if BotActivo then return end
    BotActivo = true
    BotEnFaseSalida = false
    Log("[SISTEMA] Iniciando Forja Automática Omega V8.6...", Color3.fromRGB(0, 255, 255))
    DesaparecerForjaUIDelJuego()
    
    task.spawn(function()
        pcall(function()
            local knit = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services")
            local changeSeqRF = knit:WaitForChild("ForgeService"):WaitForChild("RF"):WaitForChild("ChangeSequence")
            local endForgeRF = knit.ForgeService.RF:WaitForChild("EndForge")
            
            -- El martillo tiene su propio remote en Controllers (no en Knit)
            local controllersFolder = ReplicatedStorage:WaitForChild("Controllers")
            local forgeControllerFolder = controllersFolder:WaitForChild("ForgeController")
            local hammerRF = forgeControllerFolder:WaitForChild("HammerMinigame"):WaitForChild("RemoteFunction")

            local meltTime = 120.5
            local otherTime = 100.0

            local function SafeChangeSequence(fase, clientTimeParam)
                pcall(function()
                    if clientTimeParam then 
                        changeSeqRF:InvokeServer(fase, {ClientTime = clientTimeParam})
                    else 
                        changeSeqRF:InvokeServer(fase, {}) 
                    end
                end)
            end

            -- 1️⃣ MELT (SKIP)
            Log(">> Fase 1: Sincronizando Melt...", Color3.fromRGB(255, 165, 0))
            SafeChangeSequence("Melt", meltTime)
            task.wait(TiempMelt)

            -- 2️⃣ POUR (SKIP)
            Log(">> Fase 2: Pour (SKIP animación)...", Color3.fromRGB(240, 230, 140))
            SafeChangeSequence("Pour", otherTime)
            task.wait(TiempPour)

            -- 3️⃣ HAMMER (PERFECT OVERFLOW x25)
            Log(">> Fase 3: Hammer (Acelerado Perfect x25)...", Color3.fromRGB(0, 255, 0))
            SafeChangeSequence("Hammer", nil)
            task.wait(1.5)
            for i = 1, 25 do
                pcall(function() hammerRF:InvokeServer({Name = "Perfect"}) end)
                task.wait(TiempHmmr / 25)
            end
            task.wait(0.5)

            -- 4️⃣ WATER (SKIP)
            Log(">> Fase 4: Sincronizando Water...", Color3.fromRGB(0, 150, 255))
            SafeChangeSequence("Water", otherTime)
            task.wait(TiempWtr)

            -- 5️⃣ SHOWCASE Y SALIDA (END FORGE REAL)
            BotEnFaseSalida = true
            Log(">> Fase 5: Showcase (Forzando Cierre).", Color3.fromRGB(200, 0, 255))
            SafeChangeSequence("Showcase", nil)
            task.wait(2.5)
            
            Log(">> Fase 6: Llamando END FORGE REAL (Anti-Freeze)...", Color3.fromRGB(255, 0, 50))
            pcall(function() endForgeRF:InvokeServer() end)
            
            task.wait(1)
            DesaparecerForjaUIDelJuego()
            ForceUnfreezeCharacter()
            
            Log("✅ FORJA OMEGA V8.6 COMPLETADA. ERES LIBRE.", Color3.fromRGB(0, 255, 0))
            BotActivo = false
        end)
    end)
end

-- ==============================================
-- HOOK DIRECTO A LOS MÓDULOS DEL JUEGO (EL FIX DEL BOTÓN "¡FORJAR!")
-- ==============================================
local function AplicarHookDeModulos()
    local ForgeController
    pcall(function()
        ForgeController = require(ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("ForgeController"))
    end)

    if not ForgeController then
        Log("❌ ERROR CRÍTICO: No se pudo obtener ForgeController.", Color3.fromRGB(255, 0, 0))
        return
    end

    local OldChangeSequence = ForgeController.ChangeSequence

    -- Reemplazar la función principal local para capturar transiciones sin romper interacciones de red
    ForgeController.ChangeSequence = function(self, fase, data, ...)
        if InterceptMode then
            local faseStr = tostring(fase)
            task.spawn(function() Log(">> [HOOK] ChangeSequence intentó cargar: " .. faseStr, Color3.fromRGB(150, 150, 150)) end)
            
            if not BotActivo and fase == "Melt" then
                task.spawn(function()
                    Log("[V8.6] ¡Botón FORJAR detectado! Tomando el control...", Color3.fromRGB(255, 255, 0))
                    IniciarForjaAutomatica()
                end)
                return -- Aborta la carga del UI/minijuegos visuales localmente para dejarle paso al bot
            end
        end
        
        -- Si el BotOmega está corriendo, silenciar los intentos del servidor por actualizar nuestro UI
        if BotActivo and (fase == "Melt" or fase == "Pour" or fase == "Hammer" or fase == "Water" or fase == "Showcase") then
            return -- La UI nunca renderiza las fases, evitando lags o interrupciones
        end

        -- Para cualquier otra cosa (ej. si el modo intercept está apagado) dejar que fluya normal
        return OldChangeSequence(self, fase, data, ...)
    end
end

task.spawn(AplicarHookDeModulos)

-- LOOP PROTECTOR DE WALK SPEED
task.spawn(function()
    while task.wait(0.5) do
        if BotActivo and BotEnFaseSalida then
            ForceUnfreezeCharacter()
        end
    end
end)

Log("[SISTEMA] V8.6 - NO-NAMECALL OMAAAAEGA INICIADO.", Color3.fromRGB(0, 255, 100))
Log("[SISTEMA] hookmetamethod ELIMINADO. Tu botón FORJAR ahora funciona.", Color3.fromRGB(255, 255, 0))
Log("1️⃣ Pon los minerales.\n2️⃣ Activa 'HOOK: ON'.\n3️⃣ Dale click a ¡FORJAR!.", Color3.fromRGB(200, 200, 200))
