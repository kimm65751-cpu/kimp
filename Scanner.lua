-- ==============================================================================
-- 🛡️ AUTO-DEFENDER V1.2 (SAFE RENDER FULL BUGTRACKER)
-- Minimalista sin adornos complejos para evitar crasheos de ejecutor.
-- ==============================================================================
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Paso 1: Limpiar cualquier GUI anterior bugeada
for _, obj in pairs(CoreGui:GetChildren()) do
    if obj.Name == "AutoDefender_V2" then
        obj:Destroy()
    end
end
if LocalPlayer:FindFirstChild("PlayerGui") then
    for _, obj in pairs(LocalPlayer.PlayerGui:GetChildren()) do
        if obj.Name == "AutoDefender_V2" then
            obj:Destroy()
        end
    end
end

-- Paso 2: Crear el GUI Secuencialmente sin "xpcall" que puede silenciar errores en Delta
local gui = Instance.new("ScreenGui")
gui.Name = "AutoDefender_V2"
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 320, 0, 200)
main.Position = UDim2.new(0.5, -160, 0.5, -100)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.BorderSizePixel = 2
main.BorderColor3 = Color3.fromRGB(255, 0, 0)
main.Active = true
-- Usamos "Draggable = true" directo. Es obsoleto en Gui modernas pero 100% seguro contra crasheos de scripts custom de Touch
main.Draggable = true
main.Parent = gui

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(0, 255, 128)
title.Text = "🛡️ BUG TRACKER V1.2"
title.Font = Enum.Font.Code
title.TextSize = 18
title.Parent = main

-- Estado
local statusInfo = Instance.new("TextLabel")
statusInfo.Size = UDim2.new(1, -20, 0, 40)
statusInfo.Position = UDim2.new(0, 10, 0, 40)
statusInfo.BackgroundTransparency = 1
statusInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
statusInfo.Text = "Estado: Esperando..."
statusInfo.Font = Enum.Font.Code
statusInfo.TextSize = 14
statusInfo.TextWrapped = true
statusInfo.Parent = main

-- Botón
local btnToggle = Instance.new("TextButton")
btnToggle.Size = UDim2.new(0.8, 0, 0, 40)
btnToggle.Position = UDim2.new(0.1, 0, 0, 90)
btnToggle.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
btnToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
btnToggle.Text = "INICIAR INTERCEPTOR (OFF)"
btnToggle.Font = Enum.Font.Code
btnToggle.TextSize = 14
btnToggle.BorderSizePixel = 2
btnToggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
btnToggle.Parent = main

-- Logging de Fallos
local debugLog = Instance.new("TextLabel")
debugLog.Size = UDim2.new(1, -20, 0, 40)
debugLog.Position = UDim2.new(0, 10, 0, 140)
debugLog.BackgroundTransparency = 1
debugLog.TextColor3 = Color3.fromRGB(255, 255, 100)
debugLog.Text = "Log: Ninguno"
debugLog.Font = Enum.Font.Code
debugLog.TextSize = 12
debugLog.TextWrapped = true
debugLog.Parent = main

----------------------------------------------------
-- LÓGICA DEL HACK TRACKER
----------------------------------------------------
local AutoActive = false
local TargetButton = nil
local TargetTimerText = nil

local function FindInteractiveCircle()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local myPos = char.HumanoidRootPart.Position

    TargetButton = nil
    TargetTimerText = nil
    local closestDist = 150
    local found = false

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("TextLabel") then
            local txt = tostring(obj.Text)
            -- Busca el famoso texto "56s" de tu captura de pantalla
            if string.match(txt, "%d+s") then
                local guiObj = obj:FindFirstAncestorWhichIsA("BillboardGui") or obj:FindFirstAncestorWhichIsA("SurfaceGui")
                local part = nil
                if guiObj then
                    if guiObj.Adornee then part = guiObj.Adornee end
                    if not part and guiObj.Parent and guiObj.Parent:IsA("BasePart") then part = guiObj.Parent end
                end

                if part then
                    local dist = (part.Position - myPos).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        TargetButton = part
                        TargetTimerText = obj
                        found = true
                    end
                end
            end
        end
    end
    return found
end

btnToggle.MouseButton1Click:Connect(function()
    AutoActive = not AutoActive
    if AutoActive then
        btnToggle.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
        btnToggle.Text = "AUTO-BLOCK (ON)"
    else
        btnToggle.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        btnToggle.Text = "DETENER INTERCEPTOR (OFF)"
        TargetButton = nil
    end
end)

task.spawn(function()
    while task.wait(0.25) do
        if not AutoActive then continue end
        
        -- Si perdimos el objetivo, buscar de nuevo
        if not TargetButton or not TargetButton.Parent then
            statusInfo.Text = "📡 Buscando tu círculo amarillo de la base..."
            local found = FindInteractiveCircle()
            if not found then
                debugLog.Text = "❌ Párate cerca del timer de los egundos ('s')"
                continue
            end
        end
        
        -- Ejecutar ataque automatizado simulado si lo vemos
        if TargetButton and TargetTimerText then
            statusInfo.Text = "🛑 Círculo Encontrado Visto!"
            local currentText = tostring(TargetTimerText.Text)
            debugLog.Text = "⏱️ Timer: " .. currentText
            
            local numStr = string.match(currentText, "%d+")
            local num = tonumber(numStr)
            
            -- CUANDO LLEGUE A 0 o 1, DISPARAMOS
            if num and num <= 1 then
                statusInfo.Text = "⚡ [ACCION] ¡Colision Fantasma Enviada!"
                pcall(function()
                    if firetouchinterest and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
                        -- Enviar pisada fantasma remota
                        firetouchinterest(LocalPlayer.Character.PrimaryPart, TargetButton, 0)
                        task.wait(0.05)
                        firetouchinterest(LocalPlayer.Character.PrimaryPart, TargetButton, 1)
                    else
                        -- Si el exploit no tiene firetouchinterest, empujar el personaje al boton
                        if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
                            LocalPlayer.Character.PrimaryPart.CFrame = TargetButton.CFrame
                        end
                    end
                end)
                TargetButton = nil
                task.wait(2)
            end
        else
            TargetButton = nil
        end
    end
end)
print("[AutoDefender] GUI Cargada con Éxito")
