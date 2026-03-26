-- =====================================================================
-- DELTA OMNI-TRACKER v4.0 (GUI FORENSE EN VIVO)
-- Registra Coordenadas, Físicas, Combate Global y Atributos.
-- Supera Armas Falsas (No-Tools) y Caché de GitHub.
-- =====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local TrackerRunning = true

-- =====================================================================
-- 1. CREACIÓN DE LA INTERFAZ GRÁFICA
-- =====================================================================
if CoreGui:FindFirstChild("OmniTrackerGUI") then
    CoreGui.OmniTrackerGUI:Destroy()
end

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
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = " 🕵️ OMNI-TRACKER V4.0 (RCTRL para ocultar)"
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

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -20, 1, -60)
LogScroll.Position = UDim2.new(0, 10, 0, 50)
LogScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
LogScroll.ScrollBarThickness = 6
LogScroll.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = LogScroll
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

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
-- 2. MOTOR DE REGISTRO (LOGGING ENGINE)
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
                if not success then selfName = "Remote_Desconocido" end
                local argStr = ""
                for i,v in pairs(args) do
                    local strVal = typeof(v) == "Instance" and v.Name or tostring(v)
                    argStr = argStr .. "Arg" .. i .. ":" .. strVal .. " | "
                end
                AddLog("RED", "Paquete: " .. tostring(selfName), "Remote: " .. tostring(selfName) .. "\nArgs: " .. argStr)
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
-- 4. MOTOR DE SALUD Y COMBATE GLOBAL (LECTOR MULTI-CAPA)
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
        
        for _, child in pairs(target:GetDescendants()) do
            if child:IsA("TextLabel") and (string.find(string.lower(child.Text), "hp") or string.match(child.Text, "%d+/%d+")) then
                return "❤️ UI Vida: " .. child.Text, child, target.Name
            end
        end
        
        target = target.Parent
        loopCount = loopCount + 1
    end
    
    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in pairs(playerGui:GetDescendants()) do
            if gui:IsA("TextLabel") and gui.Visible and gui.TextTransparency < 1 then
                local text = string.lower(gui.Text)
                if string.find(text, "hp") and string.match(text, "[%d%.]+") then
                    return "❤️ ScreenGui HP: " .. gui.Text, gui, "Objetivo en Pantalla"
                end
            end
        end
    end
    
    return "❓ Sin vida interna/visual", nil, obj.Name
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

-- RASTREO COMBATE GLOBAL (Supera armas falsas que no usan clase "Tool")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not TrackerRunning then return end
    
    -- Manejo del Panel
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then ToggleMenu() end
    
    -- Clic de Combate (Izquierdo)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        task.delay(0.1, function() -- Dejar que la interfaz del juego cargue
            local target = Mouse.Target
            local targetName = target and target.Name or "Aire"
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
                                AddLog("COMBATE", "💥 Daño Numérico: " .. string.format("%.1f", damage), "Daño: " .. damage)
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
                                AddLog("COMBATE", "💥 Daño Atributo: " .. string.format("%.1f", damage), "Daño: " .. damage)
                            end
                            startHp = newHp
                        end)
                        
                    elseif healthObj:IsA("TextLabel") then
                        startHp = tonumber(string.match(healthObj.Text, "[%d%.]+")) or 0
                        conn = healthObj:GetPropertyChangedSignal("Text"):Connect(function()
                            local newHp = tonumber(string.match(healthObj.Text, "[%d%.]+")) or 0
                            if newHp > 0 and newHp < startHp then
                                local damage = startHp - newHp
                                AddLog("COMBATE", "💥 Daño Visual GUI: " .. string.format("%.2f", damage), "Daño: " .. damage)
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

AddLog("SISTEMA", "Omni-Tracker V4.0 en vivo. Clic Izquierdo = Rastreo de Atributos/Salud", "Tracker V4")
