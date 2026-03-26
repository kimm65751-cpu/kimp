-- =====================================================================
-- DELTA OMNI-TRACKER v5.5 (RESTAURADO)
-- Rastreo de Vida Restaurado + Auto-Farm Bot Mejorado VIM
-- =====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local TrackerRunning = true

-- =====================================================================
-- 1. CREACIÓN DE LA INTERFAZ GRÁFICA (GUI FANTASMA)
-- =====================================================================
if CoreGui:FindFirstChild("OmniTrackerGUI") then CoreGui.OmniTrackerGUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OmniTrackerGUI"
ScreenGui.Parent = CoreGui 

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -25)
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenBtn.BorderSizePixel = 2
OpenBtn.BorderColor3 = Color3.fromRGB(0, 120, 200)
OpenBtn.Text = "👁️"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.TextSize = 25
OpenBtn.Visible = false 
OpenBtn.Draggable = true
OpenBtn.Active = true
OpenBtn.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 430) 
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = " 🕵️ OMNI-TRACKER V5.5 (RCTRL para ocultar)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.Code
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -35, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 50)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.Code
MinimizeBtn.TextSize = 20
MinimizeBtn.Parent = MainFrame

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0, 105, 0, 30)
RefreshBtn.Position = UDim2.new(1, -145, 0, 5) 
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
RefreshBtn.Text = "Refrescar (.lua)"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Font = Enum.Font.Code
RefreshBtn.TextSize = 12
RefreshBtn.Parent = MainFrame

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -20, 1, -110)
LogScroll.Position = UDim2.new(0, 10, 0, 50)
LogScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
LogScroll.ScrollBarThickness = 6
LogScroll.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = LogScroll
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ⚡ Menú BOT (Auto-Farm & Minigames) ⚡
local BotFrame = Instance.new("Frame")
BotFrame.Size = UDim2.new(1, -20, 0, 80) -- Ampliado para dos botones
BotFrame.Position = UDim2.new(0, 10, 1, -85)
BotFrame.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
BotFrame.Parent = MainFrame

local AutoPebbleBtn = Instance.new("TextButton")
AutoPebbleBtn.Size = UDim2.new(0, 200, 0, 30)
AutoPebbleBtn.Position = UDim2.new(0.5, -210, 0.5, -15) -- Izquierda
AutoPebbleBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
AutoPebbleBtn.Text = "BOT AUTO-PEBBLE: OFF"
AutoPebbleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoPebbleBtn.Font = Enum.Font.Code
AutoPebbleBtn.TextSize = 14
AutoPebbleBtn.Parent = BotFrame

local AutoPumpBtn = Instance.new("TextButton")
AutoPumpBtn.Size = UDim2.new(0, 200, 0, 30)
AutoPumpBtn.Position = UDim2.new(0.5, 10, 0.5, -15) -- Derecha
AutoPumpBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 150)
AutoPumpBtn.Text = "AUTO MINIGAME (FUELLE): OFF"
AutoPumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoPumpBtn.Font = Enum.Font.Code
AutoPumpBtn.TextSize = 13
AutoPumpBtn.Parent = BotFrame

local function ToggleMenu()
    if MainFrame.Visible then
        MainFrame.Visible = false
        OpenBtn.Visible = true
    else
        MainFrame.Visible = true
        OpenBtn.Visible = false
    end
end
MinimizeBtn.MouseButton1Click:Connect(ToggleMenu)
OpenBtn.MouseButton1Click:Connect(ToggleMenu)

-- =====================================================================
-- 2. MOTOR DE LOGS
-- =====================================================================
local function AddLog(category, message, copiableData)
    local LogEntry = Instance.new("Frame")
    LogEntry.Size = UDim2.new(1, -10, 0, 40)
    LogEntry.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    LogEntry.Parent = LogScroll
    
    local TextPrefix = Instance.new("TextLabel")
    TextPrefix.Size = UDim2.new(0, 80, 1, 0)
    TextPrefix.BackgroundTransparency = 1
    TextPrefix.Text = "["..category.."]"
    if category == "RED" then TextPrefix.TextColor3 = Color3.fromRGB(200, 100, 100)
    elseif category == "COMBATE" then TextPrefix.TextColor3 = Color3.fromRGB(255, 80, 80)
    elseif category == "FISICA" then TextPrefix.TextColor3 = Color3.fromRGB(100, 200, 100)
    elseif category == "STAT" then TextPrefix.TextColor3 = Color3.fromRGB(255, 215, 0)
    else TextPrefix.TextColor3 = Color3.fromRGB(200, 200, 200) end
    TextPrefix.Font = Enum.Font.Code
    TextPrefix.TextSize = 14
    TextPrefix.Parent = LogEntry
    
    local LogMessage = Instance.new("TextLabel")
    LogMessage.Size = UDim2.new(1, -150, 1, 0)
    LogMessage.Position = UDim2.new(0, 85, 0, 0)
    LogMessage.BackgroundTransparency = 1
    LogMessage.Text = message
    LogMessage.TextColor3 = Color3.fromRGB(220, 220, 220)
    LogMessage.TextXAlignment = Enum.TextXAlignment.Left
    LogMessage.TextWrapped = true
    LogMessage.Font = Enum.Font.Code
    LogMessage.TextSize = 12
    LogMessage.Parent = LogEntry
    
    if copiableData then
        local CopyBtn = Instance.new("TextButton")
        CopyBtn.Size = UDim2.new(0, 45, 0, 25)
        CopyBtn.Position = UDim2.new(1, -50, 0, 7)
        CopyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        CopyBtn.Text = "Copy"
        CopyBtn.TextColor3 = Color3.fromRGB(255,255,255)
        CopyBtn.Font = Enum.Font.Code
        CopyBtn.TextSize = 12
        CopyBtn.Parent = LogEntry
        
        CopyBtn.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(copiableData)
                CopyBtn.Text = "OK"
                task.wait(1)
                CopyBtn.Text = "Copy"
            end
        end)
    end
    LogScroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
    LogScroll.CanvasPosition = Vector2.new(0, LogScroll.CanvasSize.Y.Offset)
end

-- =====================================================================
-- 3. MÓDULOS DE RASTREO (RED Y FÍSICA)
-- =====================================================================
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    if TrackerRunning and not checkcaller() then
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            local args = {...}
            task.spawn(function()
                local success, selfName = pcall(function() return self.Name end)
                if not success then selfName = "Remote_Unk" end
                local argStr = ""
                for i,v in pairs(args) do argStr = argStr .. typeof(v).. ":" ..tostring(v).." | " end
                AddLog("RED", tostring(selfName), argStr)
            end)
        end
    end
    return oldNamecall(self, ...)
end))

local lastPos = nil
RunService.Heartbeat:Connect(function()
    if not TrackerRunning then return end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        if not lastPos or (pos - lastPos).Magnitude > 15 then
            lastPos = pos
            AddLog("FISICA", string.format("Ruta: X:%.1f Y:%.1f Z:%.1f", pos.X, pos.Y, pos.Z), string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z))
        end
    end
end)

-- =====================================================================
-- 4. MOTOR DE SALUD Y COMBATE (RESTAURADO COMPLETO)
-- =====================================================================
local function GetHealthInfo(obj)
    local target = obj
    local loopCount = 0
    while target and target ~= workspace and loopCount < 4 do
        local hum = target:FindFirstChildOfClass("Humanoid")
        if hum then return "❤️ Vida: " .. math.floor(hum.Health), hum, target.Name end
        
        for _, child in pairs(target:GetChildren()) do
            if child:IsA("NumberValue") or child:IsA("IntValue") then
                local name = string.lower(child.Name)
                if name == "health" or name == "hp" or name == "vida" then
                    return "❤️ " .. child.Name .. ": " .. math.floor(child.Value), child, target.Name
                end
            end
        end
        local attr = target:GetAttribute("HP") or target:GetAttribute("Health")
        if attr then return "❤️ Atributo Vida: " .. math.floor(attr), target, target.Name end
        
        target = target.Parent
        loopCount = loopCount + 1
    end
    
    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in pairs(playerGui:GetDescendants()) do
            if gui:IsA("TextLabel") and gui.Visible and gui.TextTransparency < 1 then
                local text = string.lower(gui.Text)
                if string.find(text, "hp") and string.match(text, "[%d%.]+") and not string.find(text, "<font") and string.len(text) < 30 then
                    return "❤️ ScreenGui HP: " .. gui.Text, gui, "Pebble (Visual)"
                end
            end
        end
    end
    return "❓ Sin vida interna/visual descubierta", nil, obj.Name
end

local Mouse = LocalPlayer:GetMouse()
local dmgDebounce = {}
local touchedDebounce = {}

-- RASTREO TACTIL
local function SetupTouchSpy(character)
    local root = character:WaitForChild("HumanoidRootPart", 5)
    if root then
        root.Touched:Connect(function(hit)
            if TrackerRunning and hit.Parent ~= character and not touchedDebounce[hit] then
                touchedDebounce[hit] = true
                if hit.Name == "Baseplate" or string.find(string.lower(hit.Name), "terrain") then 
                    task.delay(1, function() touchedDebounce[hit] = nil end); return 
                end
                local hpString, _, objName = GetHealthInfo(hit)
                AddLog("FISICA", "Tocaste: " .. objName .. " ("..hit.Name..") | " .. hpString, hit:GetFullName())
                task.delay(5, function() touchedDebounce[hit] = nil end)
            end
        end)
    end
end

if LocalPlayer.Character then SetupTouchSpy(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(char) SetupTouchSpy(char) end)

-- RASTREO COMBATE Y DAÑO LOCAL (Cualquier Tipo de Click)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not TrackerRunning then return end
    
    -- MODO ESCÁNER DE MINIJUEGOS (Botón Derecho)
    if autoPump and input.UserInputType == Enum.UserInputType.MouseButton2 then
        local target = Mouse.Target
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            local foundGuis = playerGui:GetGuiObjectsAtPosition(Mouse.X, Mouse.Y)
            if foundGuis and #foundGuis > 0 then
                local ui = foundGuis[1]
                -- Extraer datos cruciales de límites
                local Limits = "SizeY: "..math.floor(ui.AbsoluteSize.Y).." PosY: "..math.floor(ui.AbsolutePosition.Y)
                AddLog("SISTEMA", "🔍 UI Detectada: " .. ui.Name .. " | " .. Limits, ui:GetFullName())
                return -- Prevenir que también lance daño de combate
            end
        end
    end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        task.delay(0.1, function()
            local target = Mouse.Target
            if target and LocalPlayer.Character and not target:IsDescendantOf(LocalPlayer.Character) then
                local hpString, healthObj, objName = GetHealthInfo(target)
                if healthObj and not dmgDebounce[healthObj] then
                    dmgDebounce[healthObj] = true
                    AddLog("COMBATE", "Apuntando a: " .. objName .. " | " .. hpString, target:GetFullName())
                    
                    local startHp = 0
                    local conn
                    if healthObj:IsA("Humanoid") or healthObj:IsA("ValueBase") then
                        startHp = healthObj:IsA("Humanoid") and healthObj.Health or healthObj.Value
                        conn = (healthObj:IsA("Humanoid") and healthObj.HealthChanged or healthObj.Changed):Connect(function()
                            local newHp = healthObj:IsA("Humanoid") and healthObj.Health or healthObj.Value
                            if typeof(newHp) == "number" and newHp < startHp then
                                local damage = startHp - newHp
                                AddLog("COMBATE", "💥 Daño Real: " .. string.format("%.1f", damage) .. " | ❤️ Quedan: " .. string.format("%.1f", newHp), "Daño: " .. damage)
                            end
                            startHp = newHp
                        end)
                    elseif healthObj:GetAttribute("Health") or healthObj:GetAttribute("HP") then
                        local attrName = healthObj:GetAttribute("Health") and "Health" or "HP"
                        startHp = healthObj:GetAttribute(attrName)
                        conn = healthObj:GetAttributeChangedSignal(attrName):Connect(function()
                            local newHp = healthObj:GetAttribute(attrName)
                            if typeof(newHp) == "number" and newHp < startHp then
                                local damage = startHp - newHp
                                AddLog("COMBATE", "💥 Daño Atributo: " .. string.format("%.1f", damage) .. " | ❤️ Quedan: " .. string.format("%.2f", newHp), "Daño: " .. damage)
                            end
                            startHp = newHp
                        end)
                    elseif healthObj:IsA("TextLabel") then
                        startHp = tonumber(string.match(healthObj.Text, "[%d%.]+")) or 0
                        conn = healthObj:GetPropertyChangedSignal("Text"):Connect(function()
                            local newHp = tonumber(string.match(healthObj.Text, "[%d%.]+")) or 0
                            if newHp > 0 and newHp < startHp then
                                local damage = startHp - newHp
                                AddLog("COMBATE", "💥 Daño Visual: " .. string.format("%.1f", damage) .. " | ❤️ Quedan: " .. string.format("%.2f", newHp), "Daño: " .. damage)
                            end
                            startHp = newHp
                        end)
                    end
                    if conn then task.delay(5, function() conn:Disconnect() end) end
                    task.delay(1, function() dmgDebounce[healthObj] = nil end)
                end
            end
        end)
    end
end)

local leaderstats = LocalPlayer:WaitForChild("leaderstats", 5)
if leaderstats then
    leaderstats.DescendantChanged:Connect(function(stat)
        if TrackerRunning and (stat:IsA("IntValue") or stat:IsA("NumberValue")) then
            AddLog("STAT", "Economía: " .. stat.Name .. " = " .. tostring(stat.Value), stat.Name)
        end
    end)
end

-- =====================================================================
-- 5. ALGORITMOS DE MOVIMIENTO TÁCTICO PARA BOT (PATHFINDING / NOCLIP)
-- =====================================================================
local autoFarmPebble = false
local noclipConn

local function ToggleNoclip(state)
    if state then
        if not noclipConn then
            noclipConn = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
                    end
                end
            end)
        end
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    end
end

local function TweenToPosition(targetPos)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    local dist = (hrp.Position - targetPos).Magnitude
    local speed = 60 -- Aceleramos un poco la trayectoria
    local time = dist / speed
    if time < 0.1 then time = 0.1 end
    
    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.lookAt(targetPos, targetPos + Vector3.new(0, -1, 0))})
    
    tween:Play()
    tween.Completed:Wait()
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
end

-- Táctico del Auto-Pebble
task.spawn(function()
    while task.wait(0.1) do
        if autoFarmPebble and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            
            -- Radar
            local bestPebble = nil
            local minDist = math.huge
            
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == "Pebble" then
                    local hp = obj:GetAttribute("Health") or obj:GetAttribute("HP")
                    if hp and hp > 0 then
                        local hitbox = obj:FindFirstChild("Hitbox") or obj:FindFirstChildWhichIsA("BasePart")
                        if hitbox then
                            local dist = (hrp.Position - hitbox.Position).Magnitude
                            if dist < minDist then
                                minDist = dist
                                bestPebble = hitbox
                            end
                        end
                    end
                end
            end
            
            if bestPebble then
                ToggleNoclip(true)
                local atackPos = bestPebble.Position + Vector3.new(0, 3.5, 0)
                
                if (hrp.Position - atackPos).Magnitude > 3 then
                    TweenToPosition(atackPos)
                end
                
                hrp.CFrame = CFrame.lookAt(atackPos, bestPebble.Position)
                hrp.AssemblyLinearVelocity = Vector3.zero
                
                -- RUTINA DE GOLPEO RÁPIDO Y PRECISO (Paso 1 - Finalizado)
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                local tool = LocalPlayer.Backpack:FindFirstChild("Pickaxe") or LocalPlayer.Character:FindFirstChild("Pickaxe") or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
                
                if tool and hum and tool.Parent ~= LocalPlayer.Character then
                    hum:EquipTool(tool)
                    task.wait(0.1) -- Tiempo de animación de equipar
                end
                
                local camera = workspace.CurrentCamera
                if camera then camera.CFrame = CFrame.lookAt(camera.CFrame.Position, bestPebble.Position) end
                
                -- Virtual Input Manager (Fuego Rápido - Metralleta)
                local cx = camera.ViewportSize.X / 2
                local cy = camera.ViewportSize.Y / 2
                VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
                task.wait() -- Milisegundo mínimo
                VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
                
                if tool then pcall(function() tool:Activate() end) end
                
                -- PROBANDO VULNERABILIDAD: Cero Cooldown (De 0.25 a 0.01)
                task.wait()
            else
                ToggleNoclip(false)
            end
        end
    end
end)

AutoPebbleBtn.MouseButton1Click:Connect(function()
    autoFarmPebble = not autoFarmPebble
    if autoFarmPebble then
        AutoPebbleBtn.Text = "BOT AUTO-PEBBLE: ON"
        AutoPebbleBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
        AddLog("SISTEMA", "Bot Auto-Farm activado...", "")
    else
        AutoPebbleBtn.Text = "BOT AUTO-PEBBLE: OFF"
        AutoPebbleBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        ToggleNoclip(false)
        AddLog("SISTEMA", "Bot Auto-Farm apagado.", "")
    end
end)

-- Herramienta de Escaneo UI Avanzado (Detector de Minijuegos)
AutoPumpBtn.MouseButton1Click:Connect(function()
    autoPump = not autoPump
    if autoPump then
        AutoPumpBtn.Text = "MODO ESCANER UI: ON"
        AutoPumpBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 180)
        AddLog("SISTEMA", "🔍 Modo Escáner Activado: Haz CLIC DERECHO sobre la flecha verde y luego sobre la barra.", "")
    else
        AutoPumpBtn.Text = "MODO ESCANER UI: OFF"
        AutoPumpBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 80)
        AddLog("SISTEMA", "Escáner desactivado.", "")
    end
end)

-- =====================================================================
-- 6. CONECTOR GITHUB REFRESH
-- =====================================================================
RefreshBtn.MouseButton1Click:Connect(function()
    AddLog("SISTEMA", "Descargando V5.5 desde GitHub...", "")
    TrackerRunning = false
    autoFarmPebble = false
    ScreenGui:Destroy()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua?v=" .. tostring(math.random(1000, 9999))))()
end)

AddLog("SISTEMA", "Omni-Tracker V5.5 Inyectado. Clic manual Restaurado.", "")
