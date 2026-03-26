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

local EspiaBtn = Instance.new("TextButton")
EspiaBtn.Size = UDim2.new(0, 200, 0, 30)
EspiaBtn.Position = UDim2.new(0.5, 10, 0.5, -15) -- Derecha
EspiaBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 80)
EspiaBtn.Text = "MODO ESPÍA: OFF"
EspiaBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EspiaBtn.Font = Enum.Font.Code
EspiaBtn.TextSize = 13
EspiaBtn.Parent = BotFrame

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
    
    if autoEspia and input.UserInputType == Enum.UserInputType.MouseButton2 then
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
    local speed = 60
    local time = dist / speed
    if time < 0.1 then time = 0.1 end
    
    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.lookAt(targetPos, targetPos + Vector3.new(0, -1, 0))})
    
    tween:Play()
    tween.Completed:Wait()
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
end

task.spawn(function()
    while task.wait(0.1) do
        if autoFarmPebble and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            
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

autoEspia = false
EspiaBtn.MouseButton1Click:Connect(function()
    autoEspia = not autoEspia
    if autoEspia then
        EspiaBtn.Text = "EXTRACTOR GUI: ON"
        EspiaBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 200)
        AddLog("SISTEMA", "🔍 Extractor de Interfaz activado. Buscando botones vulnerables...", "")
        
        task.spawn(function()
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if not playerGui then return end
            
            local foundCount = 0
            for _, v in pairs(playerGui:GetDescendants()) do
                if v:IsA("TextButton") or v:IsA("ImageButton") or v:IsA("Frame") then
                    local nameLow = string.lower(v.Name)
                    local textLow = v:IsA("TextButton") and string.lower(v.Text) or ""
                    
                    if string.find(nameLow, "equip") or string.find(textLow, "equip") or 
                       string.find(nameLow, "deal") or string.find(textLow, "deal") or 
                       string.find(nameLow, "sell") or string.find(textLow, "sell") or
                       string.find(nameLow, "marbles") then
                        
                        foundCount = foundCount + 1
                        local pText = v:IsA("TextButton") and v.Text or "["..v.ClassName.."]"
                        AddLog("ESPIA", "🎯 GUI Hallada: " .. v.Name .. " | Text: " .. pText, v:GetFullName())
                    end
                end
            end
            
            if foundCount == 0 then
                AddLog("ESPIA", "⚠️ No se hallaron botones clásicos. El juego usa renderizado totalitario.", "")
            else
                AddLog("SISTEMA", "✅ Extracción completada ("..foundCount.." elementos).", "")
            end
            
            -- Apagado automático para usarlo como Radar de Ping
            task.wait(1)
            EspiaBtn.Text = "EXTRACTOR GUI: OFF"
            EspiaBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 80)
            autoEspia = false
        end)
    else
        EspiaBtn.Text = "EXTRACTOR GUI: OFF"
        EspiaBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 80)
    end
end)

-- =====================================================================
-- 6. CONECTOR GITHUB REFRESH
-- =====================================================================
RefreshBtn.MouseButton1Click:Connect(function()
    AddLog("SISTEMA", "Descargando V5.6 Final desde GitHub...", "")
    TrackerRunning = false
    autoFarmPebble = false
    ScreenGui:Destroy()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua?v=" .. tostring(math.random(1000, 9999))))()
end)

AddLog("SISTEMA", "Omni-Tracker V5.6 Recreado Final.", "")
