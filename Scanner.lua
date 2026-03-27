-- ==============================================================================
-- 🛡️ AUTO-DEFENDER & BUG TRACKER V1.1 (ANTI-CRASH CATCHER)
-- ==============================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoDefenderGUI"
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

-- Funcionalidad Drag
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

-- Sistema de manejo de errores
local function ShowError(errText, trace)
    local ErrLbl = Instance.new("TextLabel")
    ErrLbl.Size = UDim2.new(1, -10, 1, -10)
    ErrLbl.Position = UDim2.new(0, 5, 0, 5)
    ErrLbl.BackgroundTransparency = 1
    ErrLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
    ErrLbl.TextWrapped = true
    ErrLbl.TextXAlignment = Enum.TextXAlignment.Left
    ErrLbl.TextYAlignment = Enum.TextYAlignment.Top
    ErrLbl.Font = Enum.Font.Code
    ErrLbl.TextSize = 12
    ErrLbl.Text = "🛑 CRASH EN LA GUI 🛑\n\nERROR:\n" .. tostring(errText) .. "\n\nTRACE:\n" .. tostring(trace)
    ErrLbl.Parent = MainFrame
end

-- ENVOLVEMOS TODO EN UN XPCALL PARA PODER LEER LOS ERRORES
xpcall(function()
    
    -- Construcción de UI (Segura)
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 80, 80)
    Title.Text = "🛡️ REVERSE ENG: DEFENDER"
    Title.Font = Enum.Font.Code
    Title.TextSize = 16
    -- NOTA: Se ha eliminado Title.FontWeight = ... porque causaba un error fatal en TextLabel en algunas versiones.
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

    -- Logica de Hack/Test
    local AutoActive = false
    local TargetButton = nil
    local TargetTimerGui = nil

    local function FindYellowButtonAndTimer()
        -- Escanea el espacio alrededor del jugador buscando el "56s" de tu captura
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
        local myPos = char.HumanoidRootPart.Position

        TargetButton = nil
        TargetTimerGui = nil
        local closestDist = 150

        -- Buscar cualquier texto flotante que tenga una "s" de segundos ("12s", "56s")
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Text:match("%d+s") then
                local gui = obj:FindFirstAncestorWhichIsA("BillboardGui") or obj:FindFirstAncestorWhichIsA("SurfaceGui")
                
                local part = nil
                if gui and gui.Adornee then
                    part = gui.Adornee
                elseif gui and gui.Parent and gui.Parent:IsA("BasePart") then
                    part = gui.Parent
                end
                
                if part then
                    local dist = (part.Position - myPos).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        TargetButton = part
                        TargetTimerGui = obj
                    end
                end
            end
        end
        return TargetButton ~= nil
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

    task.spawn(function()
        while task.wait(0.25) do
            if not AutoActive then continue end
            
            if not TargetButton then
                Status.Text = "📡 Buscando círculo de botón amarillo..."
                FindYellowButtonAndTimer()
                if not TargetButton then
                    DebugText.Text = "Acércate al botón que muestra 's' (segundos)."
                    continue
                end
            end
            
            if TargetButton and TargetTimerGui then
                Status.Text = "🛑 Círculo interceptado: " .. TargetButton.Name
                local currentText = TargetTimerGui.Text
                DebugText.Text = "⏱️ Captura Local: " .. currentText
                
                -- Extrae los numeros de "56s"
                local numStr = currentText:match("%d+")
                local num = tonumber(numStr)
                if num and num <= 1 then
                    Status.Text = "⚡ [ACCION] ¡Colision Fantasma en Botón!"
                    pcall(function()
                        if firetouchinterest and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
                            -- Simula físicamente "pisar" el botón (amarillo)
                            firetouchinterest(LocalPlayer.Character.PrimaryPart, TargetButton, 0)
                            task.wait(0.05)
                            firetouchinterest(LocalPlayer.Character.PrimaryPart, TargetButton, 1)
                        else
                            -- Si tu ejecutor no tiene firetouchinterest, tp instantaneo
                            if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
                                LocalPlayer.Character.PrimaryPart.CFrame = TargetButton.CFrame * CFrame.new(0, 1.5, 0)
                            end
                        end
                    end)
                    TargetButton = nil -- Resetea para no spamearlo eternamente
                    task.wait(2)
                end
            else
                TargetButton = nil
            end
        end
    end)

end, function(err)
    ShowError(err, debug.traceback())
end)
