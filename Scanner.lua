-- ==============================================================================
-- 🛡️ REVERSE ENG: NETWORK ANALYZER V2.0 (GUI V2)
-- Analiza la desincronización entre lo "Visual" y el "Servidor".
-- Intercepta las llamadas de Red (RemoteEvents) para ver por qué falla la puerta.
-- ==============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Paso 1: Limpieza
for _, obj in pairs(CoreGui:GetChildren()) do
    if obj.Name == "AutoDefender_V2" or obj.Name == "NetworkAnalyzerV2" then
        obj:Destroy()
    end
end
if LocalPlayer:FindFirstChild("PlayerGui") then
    for _, obj in pairs(LocalPlayer.PlayerGui:GetChildren()) do
        if obj.Name == "AutoDefender_V2" or obj.Name == "NetworkAnalyzerV2" then
            obj:Destroy()
        end
    end
end

-- Paso 2: Creación de GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NetworkAnalyzerV2"
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 320)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 150, 255)
Title.Text = "🛡️ NETWORK ANALYZER V2.0"
Title.Font = Enum.Font.Code
Title.TextSize = 18
Title.Parent = MainFrame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 30)
Status.Position = UDim2.new(0, 10, 0, 35)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(200, 200, 200)
Status.Text = "Estado: Localizando Botón..."
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Font = Enum.Font.Code
Status.TextSize = 13
Status.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 35)
ToggleBtn.Position = UDim2.new(0.05, 0, 0, 70)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Text = "INICIAR AUTO-BLOCK + SNIFFER (OFF)"
ToggleBtn.Font = Enum.Font.Code
ToggleBtn.TextSize = 14
ToggleBtn.BorderSizePixel = 1
ToggleBtn.Parent = MainFrame

-- Zona de Log de Red (Para capturar los RemoteEvents)
local LogHolder = Instance.new("ScrollingFrame")
LogHolder.Size = UDim2.new(0.9, 0, 0, 180)
LogHolder.Position = UDim2.new(0.05, 0, 0, 120)
LogHolder.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
LogHolder.BorderSizePixel = 1
LogHolder.BorderColor3 = Color3.fromRGB(0, 150, 255)
LogHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
LogHolder.ScrollBarThickness = 6
LogHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogHolder.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout", LogHolder)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 2)

local logCount = 0
local function AddLog(msg, color)
    logCount = logCount + 1
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    lbl.Text = "[" .. os.date("%H:%M:%S") .. "] " .. msg
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 11
    lbl.LayoutOrder = -logCount -- Los nuevos aparecen arriba
    lbl.Parent = LogHolder
end

AddLog("✅ GUI V2.0 Cargada exitosamente sin caché.", Color3.fromRGB(100, 255, 100))
AddLog("📡 Sniffer listo. Parate en el botón para ver qué pasa en el servidor.", Color3.fromRGB(0, 200, 255))

-- ========================================================================
-- NETWORK HOOK DETECTOR (SNIFFER)
-- intercepta los datos Cliente -> Servidor (Para descubrir el fallo visual)
-- ========================================================================
task.spawn(function()
    pcall(function()
        local mt = getrawmetatable(game)
        if setreadonly and mt then
            local oldNamecall = mt.__namecall
            setreadonly(mt, false)

            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                
                if method == "FireServer" or method == "InvokeServer" then
                    if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") then
                        local name = tostring(self.Name)
                        -- Filtramos eventos irrelevantes de mouse/update para no causar lag
                        if not name:match("Mouse") and not name:match("Move") and not name:match("Update") then
                            local argStr = ""
                            for _, v in pairs(args) do
                                argStr = argStr .. tostring(v) .. ", "
                            end
                            if argStr == "" then argStr = "Vacío" end
                            
                            -- Enviar el evento capturado a la GUI
                            task.spawn(AddLog, "📤 ENVIADO: ["..name.."] Args: {"..argStr.."}", Color3.fromRGB(255, 170, 0))
                        end
                    end
                end
                
                return oldNamecall(self, ...)
            end)
            setreadonly(mt, true)
            AddLog("🔌 Interceptor de Red Anclado.", Color3.fromRGB(200, 100, 255))
        else
            AddLog("⚠️ Tu ejecutor prohíbe el análisis de red (getrawmetatable bloqueado).", Color3.fromRGB(255, 50, 50))
        end
    end)
end)

-- ========================================================================
-- DETECTAR RESPUESTAS DEL SERVIDOR
-- Loggea todo lo que el Servidor nos responde de PlotService
-- ========================================================================
task.spawn(function()
    local netFolder = ReplicatedStorage:FindFirstChild("Packages")
    if netFolder then
        for _, desc in pairs(netFolder:GetDescendants()) do
            if desc:IsA("RemoteEvent") and (desc.Name:match("Plot") or desc.Name:match("Toggle") or desc.Name:match("Lock")) then
                desc.OnClientEvent:Connect(function(...)
                    local args = {...}
                    local argStr = ""
                    for _, v in pairs(args) do argStr = argStr .. tostring(v) .. ", " end
                    AddLog("📥 SERVIDOR RESPONDE ["..desc.Name.."]: " .. argStr, Color3.fromRGB(50, 255, 150))
                end)
            end
        end
    end
end)

-- ========================================================================
-- LOGICA DEL AUTO BOTON
-- ========================================================================
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

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("TextLabel") then
            local txt = tostring(obj.Text)
            -- Identifica timers como "56s", "0s", "Lock Base"
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
                    end
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
        ToggleBtn.Text = "AUTO-BLOCK + SNIFFER (ON)"
        AddLog("⚡ Modo prueba iniciado. Esperando a que el timer decaiga...", Color3.fromRGB(200, 200, 200))
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        ToggleBtn.Text = "INICIAR AUTO-BLOCK + SNIFFER (OFF)"
        TargetButton = nil
    end
end)

task.spawn(function()
    while task.wait(0.25) do
        if not AutoActive then continue end
        
        if not TargetButton then
            Status.Text = "📡 Buscando botón..."
            FindInteractiveCircle()
            continue
        end
        
        if TargetButton and TargetTimerText then
            local currentText = tostring(TargetTimerText.Text)
            Status.Text = "🛑 Apuntando a: " .. TargetButton.Name .. " | Timer: " .. currentText
            
            local numStr = string.match(currentText, "%d+")
            local num = tonumber(numStr)
            
            if num and num <= 1 then
                Status.Text = "⚡ [ACCION] Pisando botón..."
                AddLog("¡Timer 0s verificado! Simulando pisada. Observando la red...", Color3.fromRGB(255, 255, 50))
                
                pcall(function()
                    if firetouchinterest and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
                        firetouchinterest(LocalPlayer.Character.PrimaryPart, TargetButton, 0)
                        task.wait(0.05)
                        firetouchinterest(LocalPlayer.Character.PrimaryPart, TargetButton, 1)
                    else
                        if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
                            LocalPlayer.Character.PrimaryPart.CFrame = TargetButton.CFrame
                        end
                    end
                end)
                TargetButton = nil
                task.wait(3) -- Cooldown largo para leer el log tranquilo
            end
        else
            TargetButton = nil
        end
    end
end)
