-- =====================================================================
-- DELTA OMNI-TRACKER v5.6 (RESTAURADO)
-- Rastreo de Vida Restaurado + Auto-Farm Bot Mejorado VIM + Auto-Fuelle
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
Title.Text = " 🕵️ OMNI-TRACKER V5.6 (RCTRL para ocultar)"
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
BotFrame.Size = UDim2.new(1, -20, 0, 115) -- 3 filas de botones
BotFrame.Position = UDim2.new(0, 10, 1, -120)
BotFrame.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
BotFrame.Parent = MainFrame

local AutoOreBtn = Instance.new("TextButton")
AutoOreBtn.Size = UDim2.new(0.5, -15, 0, 30)
AutoOreBtn.Position = UDim2.new(0, 10, 0, 10) -- Arriba Izquierda
AutoOreBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
AutoOreBtn.Text = "⛏️ FARM ORES: OFF"
AutoOreBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoOreBtn.Font = Enum.Font.Code
AutoOreBtn.TextSize = 13
AutoOreBtn.Parent = BotFrame

local AutoMobBtn = Instance.new("TextButton")
AutoMobBtn.Size = UDim2.new(0.5, -15, 0, 30)
AutoMobBtn.Position = UDim2.new(0.5, 5, 0, 10) -- Arriba Derecha
AutoMobBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 150)
AutoMobBtn.Text = "⚔️ FARM MOBS: OFF"
AutoMobBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoMobBtn.Font = Enum.Font.Code
AutoMobBtn.TextSize = 13
AutoMobBtn.Parent = BotFrame

local ESPBtn = Instance.new("TextButton")
ESPBtn.Size = UDim2.new(1, -20, 0, 28)
ESPBtn.Position = UDim2.new(0, 10, 0, 45)
ESPBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 20)
ESPBtn.Text = "👁️ ESP UNIDADES: OFF"
ESPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPBtn.Font = Enum.Font.Code
ESPBtn.TextSize = 13
ESPBtn.Parent = BotFrame

local ExaminarBtn = Instance.new("TextButton")
ExaminarBtn.Size = UDim2.new(1, -20, 0, 28)
ExaminarBtn.Position = UDim2.new(0, 10, 0, 80)
ExaminarBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 100)
ExaminarBtn.Text = "🔍 EXAMINAR MOB CERCANO"
ExaminarBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExaminarBtn.Font = Enum.Font.Code
ExaminarBtn.TextSize = 13
ExaminarBtn.Parent = BotFrame

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
-- 3. MÓDULOS DE RASTREO (RED Y FÍSICA) - HOOK C++ (NIVEL 7)
-- =====================================================================
task.spawn(function()
    pcall(function()
        local originalFire
        originalFire = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(self, ...)
            if TrackerRunning then
                local args = {...}
                task.spawn(function()
                    local name = tostring(self.Name)
                    local lowN = string.lower(name)
                    if not string.find(lowN, "mouse") and not string.find(lowN, "move") then
                        local argStr = ""
                        pcall(function() for i,v in pairs(args) do argStr = argStr..typeof(v)..":"..tostring(v).." | " end end)
                        AddLog("RED", "[F_EVT] " .. name, argStr)
                    end
                end)
            end
            return originalFire(self, ...)
        end))
        
        local originalInvoke
        originalInvoke = hookfunction(Instance.new("RemoteFunction").InvokeServer, newcclosure(function(self, ...)
            if TrackerRunning then
                local args = {...}
                task.spawn(function()
                    local name = tostring(self.Name)
                    local lowN = string.lower(name)
                    if not string.find(lowN, "mouse") and not string.find(lowN, "move") then
                        local argStr = ""
                        pcall(function() for i,v in pairs(args) do argStr = argStr..typeof(v)..":"..tostring(v).." | " end end)
                        AddLog("RED", "[F_INV] " .. name, argStr)
                    end
                end)
            end
            return originalInvoke(self, ...)
        end))
    end)
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local methodStr = string.lower(tostring(getnamecallmethod()))
    if TrackerRunning and (methodStr == "fireserver" or methodStr == "invokeserver") then
        local args = {...}
        task.spawn(function()
            local success, selfName = pcall(function() return self.Name end)
            if not success or not selfName then selfName = "Remote_Anónimo" end
            local nLow = string.lower(selfName)
            if not string.find(nLow, "mouse") and not string.find(nLow, "camera") and not string.find(nLow, "movement") then
                local argStr = ""
                pcall(function() for i,v in pairs(args) do argStr = argStr .. typeof(v).. ":" ..tostring(v).." | " end end)
                AddLog("RED", "[NM_CALL] " .. tostring(selfName), argStr)
            end
        end)
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

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not TrackerRunning then return end
    
    if false and input.UserInputType == Enum.UserInputType.MouseButton2 then
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        local foundGuis = playerGui and playerGui:GetGuiObjectsAtPosition(Mouse.X, Mouse.Y) or {}
        
        -- Si hizo Clic Derecho sobre un DIÁLOGO UI (Botones, Cajas de texto, Deals)
        if #foundGuis > 0 then
            local ui = foundGuis[1]
            local text = (ui:IsA("TextLabel") or ui:IsA("TextButton")) and string.sub(ui.Text, 1, 20) or "Contenedor"
            local info = "Text: [" .. text .. "] | Path: " .. ui:GetFullName()
            AddLog("ESPIA", "👁️ Diálogo UI: " .. ui.Name, info)
            
            if getconnections and ui:IsA("TextButton") then
                pcall(function()
                    for _, conn in pairs(getconnections(ui.MouseButton1Click)) do
                        if conn.Function then
                            local src = debug.getinfo(conn.Function).source
                            AddLog("ESPIA", "🔗 Código conectado a: " .. ui.Name, src)
                        end
                    end
                end)
            end
            return
        end
        
        -- Si hizo Clic Derecho sobre un NPC en el mundo 3D
        local target = Mouse.Target
        if target then
            local model = target:FindFirstAncestorOfClass("Model") or target
            AddLog("ESPIA", "🧍 NPC/Part 3D: " .. model.Name, model:GetFullName())
            
            local intel = ""
            for _, v in pairs(model:GetDescendants()) do
                if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("BindableEvent") or v:IsA("ModuleScript") then
                    intel = intel .. "["..v.ClassName.."] "..v.Name.." | "
                end
            end
            if intel ~= "" then AddLog("ESPIA", "📂 Datos del NPC: Hallazgos Críticos", intel) end
            
            local attrStr = ""
            for k, val in pairs(model:GetAttributes()) do attrStr = attrStr .. k .. "=" .. tostring(val) .. " | " end
            if attrStr ~= "" then AddLog("ESPIA", "🏷️ Atributos del NPC", attrStr) end
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
local autoFarmOres = false
local autoFarmMobs = false
local noclipConn
local healConn  -- Auto-Heal para combate

local function StartAutoHeal()
    if healConn then healConn:Disconnect() end
    healConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health < hum.MaxHealth then
            pcall(function() hum.Health = hum.MaxHealth end)
        end
    end)
end

local function StopAutoHeal()
    if healConn then healConn:Disconnect(); healConn = nil end
end

local function ToggleNoclip(state)
    if state then
        if not noclipConn then
            noclipConn = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("BasePart") then
                            if v.CanCollide then v.CanCollide = false end
                        end
                    end
                end
            end)
        end
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    end
end

local function TweenToPosition(targetPos, facePos)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    local dist = (hrp.Position - targetPos).Magnitude
    local speed = 60
    local time = dist / speed
    if time < 0.1 then time = 0.1 end
    
    -- Mirar exactamente hacia la cara del zombie (y hacia abajo si facePos está en el suelo)
    local lookCFrame = facePos and CFrame.lookAt(targetPos, facePos) or CFrame.lookAt(targetPos, targetPos + Vector3.new(0, -1, 0))
    
    -- Cancelar la gravedad puramente durante el vuelo para deslizarse como mantequilla
    local bv = hrp:FindFirstChild("TweenForce")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "TweenForce"
        bv.MaxForce = Vector3.new(100000, 100000, 100000)
        bv.Velocity = Vector3.zero
        bv.Parent = hrp
    end
    
    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = lookCFrame})
    
    tween:Play()
    tween.Completed:Wait()
    
    if bv then bv:Destroy() end
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
end

task.spawn(function()
    while task.wait(0.1) do
        if (autoFarmOres or autoFarmMobs) and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            
            local bestOre = nil
            local bestOreDist = math.huge
            local bestMob = nil
            local bestMobDist = math.huge
            local pService = game:GetService("Players")
            
            -- SCAN DE MAPA: Dos loops separados (sin anidamiento, sin freeze)
            -- Loop 1: Buscar Ores
            if autoFarmOres then
                for _, obj in pairs(workspace:GetDescendants()) do
                    local nLC = string.lower(obj.Name)
                    if string.find(nLC, "pebble") or string.find(nLC, "flatrock") or string.find(nLC, "rock") or string.find(nLC, "stone") or string.find(nLC, "ore") then
                        local hp = obj:GetAttribute("Health") or obj:GetAttribute("HP")
                        if hp and hp > 0 then
                            local posNode = obj:FindFirstChild("Hitbox") or obj:FindFirstChildWhichIsA("BasePart") or obj
                            if posNode and posNode:IsA("BasePart") then
                                local dist = (hrp.Position - posNode.Position).Magnitude
                                if dist < bestOreDist then bestOreDist = dist; bestOre = posNode end
                            end
                        end
                    end
                end
            end
            
            -- Loop 2: Buscar Mobs en workspace.Living (carpeta confirmada)
            if autoFarmMobs or autoFarmOres then
                local livingFolder = workspace:FindFirstChild("Living")
                local scanList = livingFolder and livingFolder:GetChildren() or workspace:GetDescendants()
                for _, obj in pairs(scanList) do
                    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                        -- FILTRO ENEMIGOS REALES: Ignorar jugadores, tiendas (NPCs amistosos) y mascotas
                        local nLC = string.lower(obj.Name)
                        if (string.find(nLC, "zomb") or string.find(nLC, "enem") or string.find(nLC, "delver") or string.find(nLC, "boss")) then
                            if obj ~= LocalPlayer.Character and obj.Name ~= LocalPlayer.Name and not pService:GetPlayerFromCharacter(obj) and obj.Humanoid.Health > 0 then
                                local posNode = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                                if posNode then
                                    local dist = (hrp.Position - posNode.Position).Magnitude
                                    if dist < bestMobDist then bestMobDist = dist; bestMob = posNode end
                                end
                            end
                        end
                    end
                end
            end
            
            -- LÓGICA DE PRIORIDAD TÁCTICA Y AUTODEFENSA
            local bestTarget = nil
            local targetType = nil
            
            -- Priorizar Autodefensa: Si estamos picando piedras, pero un zombi se acerca demasiado (<50 studs), priorizar matarlo.
            if bestMob and (autoFarmMobs or (autoFarmOres and bestMobDist < 50)) then
                bestTarget = bestMob
                targetType = "Mob"
            elseif bestOre and autoFarmOres then
                bestTarget = bestOre
                targetType = "Ore"
            end
            
            if bestTarget then
                ToggleNoclip(true)
                
                if targetType == "Mob" then
                    -- ⚔️ AURA KILL DEFINITIVO (Hitbox Expander)
                    -- Distancia ultra-lejana (15 studs): El zombie nunca jamás te podrá tocar.
                    local diff = hrp.Position - bestTarget.Position
                    local flatDir = Vector3.new(diff.X, 0, diff.Z)
                    if flatDir.Magnitude < 0.1 then flatDir = Vector3.new(15, 0, 0) end
                    
                    local attackPos = bestTarget.Position + (flatDir.Unit * 15)
                    
                    if (hrp.Position - attackPos).Magnitude > 2 then
                        TweenToPosition(attackPos, bestTarget.Position)
                    end
                    
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    
                    -- Equipar Arma
                    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    local targetTool = LocalPlayer.Character:FindFirstChild("Weapon")
                    if not targetTool then
                        for _, t in pairs(LocalPlayer.Character:GetChildren()) do
                            if t:IsA("Tool") and not string.find(string.lower(t.Name), "pickaxe") then targetTool = t; break end
                        end
                        if not targetTool then
                            for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do
                                if t:IsA("Tool") and not string.find(string.lower(t.Name), "pickaxe") then targetTool = t; break end
                            end
                        end
                    end
                    if targetTool and hum and LocalPlayer.Character:FindFirstChild(targetTool.Name) == nil then
                        hum:UnequipTools(); hum:EquipTool(targetTool)
                    end
                    
                    -- 🔥 INFLAR ZOMBIE LOCALMENTE (HITBOX EXPANDER MAGIA) 🔥
                    local originalSizes = {}
                    pcall(function()
                        for _, part in pairs(bestTarget:GetChildren()) do
                            if part:IsA("BasePart") and (part.Name == "HumanoidRootPart" or part.Name == "Head" or part.Name == "Torso") then
                                originalSizes[part] = part.Size
                                -- Un cuadrado de 25x25 studs es inmenso. Y el servidor lo aprueba porque el centro del zombie no se ha movido
                                part.Size = Vector3.new(25, 25, 25)
                                part.Transparency = 0.8 -- Semi-invisible pero con colisión letal
                                part.CanCollide = false
                            end
                        end
                    end)
                    
                    local camera = workspace.CurrentCamera
                    if camera then camera.CFrame = CFrame.lookAt(camera.CFrame.Position, bestTarget.Position) end
                    
                    local activeTool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
                    if activeTool then pcall(function() activeTool:Activate() end) end
                    
                    local cx = camera.ViewportSize.X / 2
                    local cy = camera.ViewportSize.Y / 2
                    for _ = 1, 3 do
                        VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
                        task.wait()
                        VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
                        task.wait(0.05)
                    end
                    
                    -- Regresarlo a la normalidad para no glitchearlo
                    pcall(function()
                        for part, oSize in pairs(originalSizes) do
                            part.Size = oSize
                            part.Transparency = 0 -- O si el bicho era transparente por base, no es tan vital
                        end
                    end)
                    -- MODO MINERÍA: TweenService suave para ores
                    local offset = Vector3.new(0, 3.5, 0)
                    local attackPos = bestTarget.Position + offset
                    if (hrp.Position - attackPos).Magnitude > 3 then
                        TweenToPosition(attackPos)
                    end
                    hrp.CFrame = CFrame.lookAt(attackPos, bestTarget.Position)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    
                    -- Equipar Pico
                    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    local targetTool = nil
                    local invItems = LocalPlayer.Backpack:GetChildren()
                    for _, t in pairs(LocalPlayer.Character:GetChildren()) do
                        if t:IsA("Tool") then table.insert(invItems, t) end
                    end
                    for _, t in pairs(invItems) do
                        if t:IsA("Tool") and string.find(string.lower(t.Name), "pickaxe") then
                            targetTool = t; break
                        end
                    end
                    if not targetTool then targetTool = LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool") end
                    if targetTool and hum and LocalPlayer.Character:FindFirstChild(targetTool.Name) == nil then
                        hum:UnequipTools(); task.wait(0.05); hum:EquipTool(targetTool); task.wait(0.1)
                    end
                    
                    local camera = workspace.CurrentCamera
                    if camera then camera.CFrame = CFrame.lookAt(camera.CFrame.Position, bestTarget.Position) end
                    local cx = camera.ViewportSize.X / 2
                    local cy = camera.ViewportSize.Y / 2
                    VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
                    task.wait()
                    VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
                    local activeTool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
                    if activeTool then pcall(function() activeTool:Activate() end) end
                    task.wait()
                end
            else
                ToggleNoclip(false)
            end
        end
    end
end)

AutoOreBtn.MouseButton1Click:Connect(function()
    autoFarmOres = not autoFarmOres
    if autoFarmOres then
        AutoOreBtn.Text = "⛏️ FARM ORES: ON"
        AutoOreBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
        AddLog("SISTEMA", "Bot Piedras encendido. Autodefensa lista.", "")
    else
        AutoOreBtn.Text = "⛏️ FARM ORES: OFF"
        AutoOreBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        if not autoFarmMobs then ToggleNoclip(false) end
    end
end)

AutoMobBtn.MouseButton1Click:Connect(function()
    autoFarmMobs = not autoFarmMobs
    if autoFarmMobs then
        AutoMobBtn.Text = "⚔️ FARM MOBS: ON"
        AutoMobBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
        AddLog("SISTEMA", "Bot Mobs + Auto-Heal activo.", "")
        StartAutoHeal()
    else
        AutoMobBtn.Text = "⚔️ FARM MOBS: OFF"
        AutoMobBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 150)
        StopAutoHeal()
        if not autoFarmOres then ToggleNoclip(false) end
    end
end)

-- =====================================================================
-- 6. EXAMINAR MOB: Forense Completo
-- =====================================================================
ExaminarBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        AddLog("EXAMEN", "❌ Sin personaje cargado.", "")
        return
    end
    local hrp = char.HumanoidRootPart
    local pService = game:GetService("Players")
    
    -- ===================== ANÁLISIS DEL ARMA EQUIPADA =====================
    local equippedTool = char:FindFirstChildWhichIsA("Tool")
    if not equippedTool then
        for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do
            if t:IsA("Tool") and not string.find(string.lower(t.Name), "pickaxe") then
                equippedTool = t; break
            end
        end
    end
    
    if equippedTool then
        AddLog("EXAMEN", "🗡️ ARMA: " .. equippedTool.Name, equippedTool:GetFullName())
        local toolScripts = ""
        for _, v in pairs(equippedTool:GetDescendants()) do
            if v:IsA("LocalScript") or v:IsA("Script") or v:IsA("ModuleScript") then
                toolScripts = toolScripts .. "[" .. v.ClassName .. "] " .. v.Name .. " | "
            end
        end
        AddLog("EXAMEN", "📜 Scripts del Arma", toolScripts ~= "" and toolScripts or "Sin scripts")
        local partsStr = ""
        for _, v in pairs(equippedTool:GetDescendants()) do
            if v:IsA("BasePart") then
                local sz = v.Size
                partsStr = partsStr .. v.Name .. "(Size:" .. string.format("%.1f,%.1f,%.1f", sz.X, sz.Y, sz.Z) .. " CanTouch:" .. tostring(v.CanTouch) .. ") | "
            end
        end
        AddLog("EXAMEN", "🔷 Parts/Hitbox del Arma", partsStr ~= "" and partsStr or "Sin parts")
        local toolAttr = ""
        for k, v in pairs(equippedTool:GetAttributes()) do toolAttr = toolAttr .. k .. "=" .. tostring(v) .. " | " end
        AddLog("EXAMEN", "🏷️ Atributos del Arma", toolAttr ~= "" and toolAttr or "Sin atributos")
        local expanded = 0
        pcall(function()
            for _, v in pairs(equippedTool:GetDescendants()) do
                if v:IsA("BasePart") and v.CanTouch then
                    local oldSz = v.Size
                    v.Size = Vector3.new(15, 15, 15)
                    expanded += 1
                    AddLog("EXAMEN", "✅ Hitbox expandido: " .. v.Name .. " " .. tostring(oldSz) .. "→15x15", v:GetFullName())
                end
            end
        end)
        if expanded == 0 then AddLog("EXAMEN", "⚠️ Hitbox protegido por servidor", "") end
    else
        AddLog("EXAMEN", "⚠️ Sin arma en personaje ni mochila", "")
    end
    
    -- ===================== ESCANEO workspace.Proximity =====================
    local proximity = workspace:FindFirstChild("Proximity")
    if proximity then
        AddLog("EXAMEN", "🔴 workspace.Proximity encontrado - sistema de daño server", "")
        local proxStr = ""
        for _, obj in pairs(proximity:GetDescendants()) do
            if obj:IsA("Script") or obj:IsA("LocalScript") then
                proxStr = proxStr .. "[" .. obj.ClassName .. "] " .. obj.Name .. " @ " .. obj:GetFullName() .. " | "
            end
        end
        AddLog("EXAMEN", "📡 Scripts Proximity", proxStr ~= "" and proxStr or "Sin scripts visibles")
    end
    -- ===================== SCAN ReplicatedStorage (Remotes de Combate) =====================
    local rs = game:GetService("ReplicatedStorage")
    local rsRemotes = ""
    for _, v in pairs(rs:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local n = string.lower(v.Name)
            if string.find(n, "attack") or string.find(n, "damage") or string.find(n, "item") or
               string.find(n, "use") or string.find(n, "weapon") or string.find(n, "hit") or
               string.find(n, "mob") or string.find(n, "combat") or string.find(n, "kill") then
                rsRemotes = rsRemotes .. "[" .. v.ClassName .. "] " .. v.Name .. " @ " .. v:GetFullName() .. " | "
            end
        end
    end
    if rsRemotes ~= "" then
        AddLog("EXAMEN", "🎯 Remotes COMBATE en RS", rsRemotes)
    else
        -- Listar TODOS los remotes si no hay específicos de combate
        local allRemotes = ""
        for _, v in pairs(rs:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                allRemotes = allRemotes .. v.Name .. " | "
            end
        end
        AddLog("EXAMEN", "📡 TODOS los Remotes RS", allRemotes ~= "" and allRemotes or "Sin remotes en RS")
    end
    AddLog("EXAMEN", "─────────────────────────────", "")
    
    -- ===================== ANÁLISIS DEL MOB MÁS CERCANO =====================
    local bestMob, bestDist = nil, math.huge
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not pService:GetPlayerFromCharacter(obj) then
            local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
            if root then
                local d = (root.Position - hrp.Position).Magnitude
                if d < bestDist then bestDist = d; bestMob = obj end
            end
        end
    end
    if not bestMob then AddLog("EXAMEN", "❌ No hay mobs cerca.", ""); return end
    AddLog("EXAMEN", "🎯 Mob: " .. bestMob.Name .. " a " .. math.floor(bestDist) .. "m", bestMob:GetFullName())
    local hum = bestMob:FindFirstChildOfClass("Humanoid")
    if hum then
        AddLog("EXAMEN", "❤️ Stats: " .. string.format("HP:%.0f/%.0f | Speed:%.1f | Jump:%.1f", hum.Health, hum.MaxHealth, hum.WalkSpeed, hum.JumpPower), "")
    end
    local attrStr = ""
    for k, v in pairs(bestMob:GetAttributes()) do attrStr = attrStr .. k .. "=" .. tostring(v) .. " | " end
    AddLog("EXAMEN", "🏷️ Atributos Mob", attrStr ~= "" and attrStr or "Sin atributos")
    local scriptStr, remoteStr = "", ""
    for _, v in pairs(bestMob:GetDescendants()) do
        if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
            scriptStr = scriptStr .. "[" .. v.ClassName .. "] " .. v.Name .. " @ " .. v:GetFullName() .. " | "
        end
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("BindableEvent") then
            remoteStr = remoteStr .. "[" .. v.ClassName .. "] " .. v.Name .. " @ " .. v:GetFullName() .. " | "
        end
    end
    AddLog("EXAMEN", "📜 Scripts en Mob", scriptStr ~= "" and scriptStr or "Sin scripts")
    AddLog("EXAMEN", "📡 Remotes en Mob", remoteStr ~= "" and remoteStr or "Sin remotes")
    if getconnections and hum then
        pcall(function()
            AddLog("EXAMEN", "🔗 HealthChanged: " .. #getconnections(hum.HealthChanged) .. " conexiones", "")
        end)
    end
    AddLog("EXAMEN", "✅ Examen completo. Equipa tu arma antes de examinar.", "")
end)

local EspElements = {}
local autoESP = false

local function ClearESP()
    for _, e in pairs(EspElements) do
        if e and e.Parent then e:Destroy() end
    end
    table.clear(EspElements)
end

local function ScanForESP()
    ClearESP()
    local pService = game:GetService("Players")
    for _, obj in pairs(workspace:GetDescendants()) do
        local isTarget = false
        local color = Color3.fromRGB(255, 255, 255)
        local n = string.lower(obj.Name)
        
        -- Detección de Minerales Críticos
        if string.find(n, "pebble") or string.find(n, "flatrock") or string.find(n, "rock") or string.find(n, "stone") or string.find(n, "ore") then
            if obj:IsA("Model") or obj:IsA("BasePart") then
                isTarget = true
                color = Color3.fromRGB(170, 170, 170) -- Grid/Cobre
            end
        end
        
        -- Detección de Mobs y NPCs (Tienen Humanoid, pero NO son jugadores)
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
            if not pService:GetPlayerFromCharacter(obj) then
                isTarget = true
                if string.find(n, "zomb") or string.find(n, "enem") or string.find(n, "boss") then
                    color = Color3.fromRGB(255, 50, 50) -- Enemigos Peligrosos Rojos
                else
                    color = Color3.fromRGB(255, 200, 50) -- NPCs Neutros (Tiendas) Amarillos
                end
            end
        end
        
        -- Generación del Adhesivo Visual
        if isTarget then
            local root = obj:IsA("Model") and (obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
            if root and root:IsA("BasePart") then
                local bill = Instance.new("BillboardGui")
                bill.Name = "OmniESP"
                bill.AlwaysOnTop = true
                bill.Size = UDim2.new(0, 150, 0, 30)
                bill.StudsOffset = Vector3.new(0, 2, 0)
                bill.Adornee = root
                bill.Parent = root
                
                local txt = Instance.new("TextLabel")
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.BackgroundTransparency = 1
                local char = LocalPlayer.Character
                local hrpPos = (char and char:FindFirstChild("HumanoidRootPart")) and char.HumanoidRootPart.Position or root.Position
                txt.Text = obj.Name .. " ["..math.floor((root.Position - hrpPos).Magnitude).."m]"
                txt.TextColor3 = color
                txt.TextStrokeTransparency = 0
                txt.Font = Enum.Font.Code
                txt.TextSize = 13
                txt.Parent = bill
                
                table.insert(EspElements, bill)
            end
        end
    end
end

ESPBtn.MouseButton1Click:Connect(function()
    autoESP = not autoESP
    if autoESP then
        ESPBtn.Text = "ESP UNIDADES: ON"
        ESPBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 40)
        AddLog("SISTEMA", "👁️ Radar de Unidades Activo (Ores/NPCs marcados).", "")
        task.spawn(function()
            while autoESP do
                ScanForESP()
                task.wait(2) -- Loop pacífico para no sobrecargar el CPU
            end
            ClearESP()
        end)
    else
        ESPBtn.Text = "ESP UNIDADES: OFF"
        ESPBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 20)
        AddLog("SISTEMA", "Radar Apagado.", "")
        ClearESP()
    end
end)

-- =====================================================================
-- 8. CONECTOR GITHUB REFRESH
-- =====================================================================
RefreshBtn.MouseButton1Click:Connect(function()
    AddLog("SISTEMA", "Descargando Actualización desde GitHub...", "")
    TrackerRunning = false
    autoFarmOres = false
    autoFarmMobs = false
    autoESP = false
    ScreenGui:Destroy()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua?v=" .. tostring(math.random(1000, 9999))))()
end)

AddLog("SISTEMA", "Omni-Tracker V5.6 Recreado Final.", "")
