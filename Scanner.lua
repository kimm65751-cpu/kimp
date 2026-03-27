-- ==============================================================================
-- 🛡️ AUTO-DEFENDER & REVERSE ENGINEERING BUG TRACKER V1.0
-- Diseñado para testear la mecánica del botón de bloqueo en localhost.
-- Busca el botón en tu base y simula interacciones automáticas para
-- auditar vulnerabilidades (spam de remotes, desbordamiento, etc).
-- ==============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. GUI Setup (Segura y Dragable)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoDefenderGUI"
-- Pcall por si el ejecutor bloquea CoreGui
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 190)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -95)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(200, 50, 50)
Stroke.Thickness = 2

-- Draggable Logic (Input moderno)
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 80, 80)
Title.Text = "🛡️ REVERSE ENG: BASE DEFENDER"
Title.Font = Enum.Font.Code
Title.TextSize = 16
Title.FontWeight = Enum.FontWeight.Bold
Title.Parent = MainFrame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 40)
Status.Position = UDim2.new(0, 10, 0, 40)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(200, 200, 200)
Status.Text = "Estado: Esperando activación..."
Status.TextWrapped = true
Status.Font = Enum.Font.Code
Status.TextSize = 13
Status.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.8, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.1, 0, 0, 95)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "INICIAR INTERCEPTOR (OFF)"
ToggleBtn.Font = Enum.Font.Code
ToggleBtn.TextSize = 14
ToggleBtn.Parent = MainFrame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)
local BtnStroke = Instance.new("UIStroke", ToggleBtn)
BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
BtnStroke.Color = Color3.fromRGB(150, 40, 40)

local DebugText = Instance.new("TextLabel")
DebugText.Size = UDim2.new(1, -20, 0, 30)
DebugText.Position = UDim2.new(0, 10, 0, 145)
DebugText.BackgroundTransparency = 1
DebugText.TextColor3 = Color3.fromRGB(255, 255, 100)
DebugText.Text = "Timer local detectado: Ninguno"
DebugText.Font = Enum.Font.Code
DebugText.TextSize = 12
DebugText.Parent = MainFrame

-- ==========================================
-- 2. Lógica de Auditoría de Base
-- ==========================================
local AutoActive = false
local TargetButton = nil
local TargetPrompt = nil

local function FindBaseButton()
    local plotsFolder = Workspace:FindFirstChild("Plots")
    if not plotsFolder then return false end

    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local myPos = char.HumanoidRootPart.Position

    local closestDist = 200 -- Rango máximo para considerar que es "tu base"
    local found = false
    
    -- Escanear la carpeta Plots en busca de prompts de la base
    for _, plot in pairs(plotsFolder:GetChildren()) do
        for _, desc in pairs(plot:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                local action = string.lower(desc.ActionText)
                local parentName = string.lower(desc.Parent.Name)
                
                -- Busca el prompt de bloqueo o la pieza "main" del reporte forense
                if string.find(action, "unlock") or string.find(action, "lock") or string.find(action, "friend") or parentName == "main" then
                    if desc.Parent and desc.Parent:IsA("BasePart") then
                        local dist = (desc.Parent.Position - myPos).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            TargetButton = desc.Parent
                            TargetPrompt = desc
                            found = true
                        end
                    end
                end
            end
        end
    end
    return found
end

local function ReadVisualTimer()
    if not TargetButton then return nil end
    -- Buscar algún TextLabel cercano al botón rojo que indique los segundos
    for _, desc in pairs(TargetButton:GetDescendants()) do
        if desc:IsA("TextLabel") or desc:IsA("TextButton") then
            local txt = tostring(desc.Text)
            -- Extrae dígitos (ej: "10", "Cooldown: 5", "00:02")
            local digits = string.match(txt, "%d+")
            if digits then return digits end
        end
    end
    -- Buscar parientes cercanos en modelo
    if TargetButton.Parent then
        for _, desc in pairs(TargetButton.Parent:GetDescendants()) do
            if desc:IsA("TextLabel") and string.match(tostring(desc.Text), "%d+") then
                return string.match(tostring(desc.Text), "%d+")
            end
        end
    end
    return nil
end

ToggleBtn.MouseButton1Click:Connect(function()
    AutoActive = not AutoActive
    if AutoActive then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
        BtnStroke.Color = Color3.fromRGB(0, 255, 128)
        ToggleBtn.Text = "AUTO-BLOCK (ON)"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        BtnStroke.Color = Color3.fromRGB(150, 40, 40)
        ToggleBtn.Text = "INICIAR INTERCEPTOR (OFF)"
        TargetButton = nil
    end
end)

-- Loop Analizador
task.spawn(function()
    while task.wait(0.25) do
        if not AutoActive then continue end
        
        if not TargetButton or not TargetButton.Parent then
            Status.Text = "📡 Escaneando Workspace por tu base..."
            local found = FindBaseButton()
            if not found then
                DebugText.Text = "Párate dentro de tu base primero."
                continue
            end
        end
        
        if TargetButton and TargetPrompt then
            Status.Text = "🛑 Botón Lock interceptado: " .. TargetButton.Name
            
            local currentTimer = ReadVisualTimer()
            if currentTimer then
                DebugText.Text = "⏱️ Timer: " .. currentTimer .. "s"
                local num = tonumber(currentTimer)
                
                -- Si el timer visual cuenta 0 o 1, o si la GUI cambia
                if num and num <= 1 then
                    Status.Text = "⚡ [ACCION] ¡Disparando exploit preventivo!"
                    
                    pcall(function()
                        -- Inyección 1: Disparo de Prompts invisible
                        if fireproximityprompt then
                            fireproximityprompt(TargetPrompt)
                        end
                        -- Inyección 2: Simulación Touched/Colisión fantasma
                        if firetouchinterest and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, TargetButton, 0)
                            task.wait(0.05)
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, TargetButton, 1)
                        end
                    end)
                    
                    TargetButton = nil -- Reiniciar búsqueda para evitar stunlock
                    task.wait(2) -- Cooldown seguro de la GUI
                end
            else
                DebugText.Text = "⏱️ Timer invisible. Disparando al azar..."
                -- Si no lee timer, lo acciona si el prompt está Enabled
                if TargetPrompt.Enabled then
                    pcall(function()
                        if fireproximityprompt then fireproximityprompt(TargetPrompt) end
                        if firetouchinterest and LocalPlayer.Character then
                            firetouchinterest(LocalPlayer.Character.PrimaryPart, TargetButton, 0)
                            task.wait(0.05)
                            firetouchinterest(LocalPlayer.Character.PrimaryPart, TargetButton, 1)
                        end
                    end)
                    task.wait(2)
                end
            end
        end
    end
end)
