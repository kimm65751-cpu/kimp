-- =====================================================================
-- DELTA OMNI-TRACKER v5.0 (TRACKER + AUTO-FARM BOT TÁCTICO)
-- Incluye algoritmos de Noclip, Vuelo-Tween y Búsqueda Espacial.
-- =====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local TrackerRunning = true

-- =====================================================================
-- 1. CREACIÓN DE LA INTERFAZ GRÁFICA (Añadido Menú BOT)
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
MainFrame.Size = UDim2.new(0, 500, 0, 430) -- Más grande para el BOT
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = " 🕵️ OMNI-TRACKER V5.0 (RCTRL para ocultar)"
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
LogScroll.Size = UDim2.new(1, -20, 1, -110) -- Achicado para dar espacio
LogScroll.Position = UDim2.new(0, 10, 0, 50)
LogScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
LogScroll.ScrollBarThickness = 6
LogScroll.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = LogScroll
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ⚡ Menú BOT (Auto-Farm) ⚡
local BotFrame = Instance.new("Frame")
BotFrame.Size = UDim2.new(1, -20, 0, 50)
BotFrame.Position = UDim2.new(0, 10, 1, -55)
BotFrame.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
BotFrame.Parent = MainFrame

local AutoPebbleBtn = Instance.new("TextButton")
AutoPebbleBtn.Size = UDim2.new(0, 200, 0, 30)
AutoPebbleBtn.Position = UDim2.new(0.5, -100, 0.5, -15)
AutoPebbleBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
AutoPebbleBtn.Text = "BOT AUTO-PEBBLE: OFF"
AutoPebbleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoPebbleBtn.Font = Enum.Font.Code
AutoPebbleBtn.TextSize = 14
AutoPebbleBtn.Parent = BotFrame

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
-- 3. ALGORITMOS DE MOVIMIENTO TÁCTICO PARA BOT (PATHFINDING / NOCLIP)
-- =====================================================================
local autoFarmPebble = false
local noclipConn

-- Activa modo fantasma: Atraviesa paredes y puertas mágicamente.
local function ToggleNoclip(state)
    if state then
        if not noclipConn then
            noclipConn = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("BasePart") and v.CanCollide then
                            v.CanCollide = false
                        end
                    end
                end
            end)
        end
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    end
end

-- Algoritmo de vuelo suave. Interpolación anti-caídas (TweenService).
local function TweenToPosition(targetPos)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    local dist = (hrp.Position - targetPos).Magnitude
    local speed = 40 -- Studs por segundo (Velocidad prudente Anti-Baneo)
    local time = dist / speed
    if time < 0.1 then time = 0.1 end
    
    -- Ajuste: Anulamos la gravedad localmente flotando
    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.lookAt(targetPos, targetPos + Vector3.new(0, -1, 0))})
    
    tween:Play()
    tween.Completed:Wait()
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
end

-- Táctico del Auto-Pebble
task.spawn(function()
    while task.wait(0.2) do
        if autoFarmPebble and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            
            -- 1. Radar Geológico: Buscar la piedra más cercana viva
            local bestPebble = nil
            local minDist = math.huge
            
            for _, obj in pairs(workspace:GetDescendants()) do
                -- Buscar el modelo Pebble
                if obj.Name == "Pebble" then
                    local hp = obj:GetAttribute("Health") or obj:GetAttribute("HP")
                    -- Si tiene más de 0 vida, es minable
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
            
            -- 2. Algoritmo de Caza y Minería
            if bestPebble then
                ToggleNoclip(true) -- Apagar choques
                
                -- Posicionarse estratégicamente 3 aros arriba de la piedra para no caer al vacío
                local atackPos = bestPebble.Position + Vector3.new(0, 4, 0)
                
                -- Volar hacia ella si estamos a más de 5 studs
                if (hrp.Position - atackPos).Magnitude > 5 then
                    TweenToPosition(atackPos)
                end
                
                -- Detener el cuerpo justo encima de la piedra
                hrp.CFrame = CFrame.lookAt(atackPos, bestPebble.Position)
                hrp.AssemblyLinearVelocity = Vector3.zero
                
                -- 3. Equipar y Golpear (Aimbot + Virtual Click)
                -- Buscamos cualquier tipo de herramienta, sin importar el nombre ("Wooden Pickaxe", "Basic", etc)
                local tool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool") 
                             or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
                
                if tool and tool.Parent == LocalPlayer.Backpack then
                    tool.Parent = LocalPlayer.Character
                end
                
                -- Giramos el cuello humano (Cámara) forzosamente hacia la piedra
                local camera = workspace.CurrentCamera
                if camera then
                    camera.CFrame = CFrame.lookAt(camera.CFrame.Position, bestPebble.Position)
                end
                
                -- Ejecución de Clic Múltiple
                if tool then tool:Activate() end
                
                -- Inyección de Clic Falso Nivel Kernel (Engaña al Raycast apuntando al centro)
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:Button1Down(Vector2.new(0,0))
                task.wait(0.05)
                VirtualUser:Button1Up(Vector2.new(0,0))
                
                -- Inyección por Delta (Capa Externa)
                if mouse1click then mouse1click() end
                
                task.wait(0.2) -- Esperar cooldown del golpe
            else
                -- Ya no hay piedras vivas (Descanzar y tocar el suelo)
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
        AddLog("SISTEMA", "Iniciando algoritmo de vuelo y cacería de rocas...", "")
    else
        AutoPebbleBtn.Text = "BOT AUTO-PEBBLE: OFF"
        AutoPebbleBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        ToggleNoclip(false)
    end
end)

-- =====================================================================
-- 4. Tracker Network
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

-- =====================================================================
-- 5. CONECTOR GITHUB REFRESH
-- =====================================================================
RefreshBtn.MouseButton1Click:Connect(function()
    AddLog("SISTEMA", "Descargando actualización desde GitHub...", "")
    TrackerRunning = false
    autoFarmPebble = false
    ScreenGui:Destroy()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua?v=" .. tostring(math.random(1000, 9999))))()
end)

AddLog("SISTEMA", "Omni-Tracker V5.0 (BotEdition) En línea.", "")
