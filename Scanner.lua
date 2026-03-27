-- ==============================================================================
-- 👁️ VISUALIZADOR DE RAYOS X (AUDITOR VISUAL PARA DELTA)
-- Pinta en pantalla los vectores de ataque invisibles
-- ==============================================================================

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

-- Limpiar escaneos anteriores
for _, v in pairs(game.CoreGui:GetChildren()) do
    if v.Name == "VanguardXRay" then v:Destroy() end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VanguardXRay"
pcall(function() screenGui.Parent = game.CoreGui end)
if not screenGui.Parent then screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

local function CreateHighlight(targetPart, color, textLabel)
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.AlwaysOnTop = true
    billboard.Adornee = targetPart
    
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text = textLabel
    txt.TextColor3 = color
    txt.TextStrokeTransparency = 0
    txt.Font = Enum.Font.Code
    txt.TextSize = 10
    txt.Parent = billboard
    
    local highlight = Instance.new("BoxHandleAdornment")
    highlight.Size = targetPart.Size + Vector3.new(0.1, 0.1, 0.1)
    highlight.Color3 = color
    highlight.Transparency = 0.5
    highlight.AlwaysOnTop = true
    highlight.ZIndex = 10
    highlight.Adornee = targetPart
    
    billboard.Parent = screenGui
    highlight.Parent = screenGui
end

local unanchoredCount = 0
local hitboxCount = 0

-- Escanear todo el mapa en busca de vulnerabilidades visuales
for _, obj in pairs(Workspace:GetDescendants()) do
    if obj:IsA("BasePart") then
        -- 1. Buscar armas u objetos con "TouchTransmitter" (Riesgo de Hitbox falso)
        if obj:FindFirstChildWhichIsA("TouchTransmitter") then
            CreateHighlight(obj, Color3.fromRGB(255, 0, 0), "⚠️ SENSOR TÁCTIL")
            hitboxCount = hitboxCount + 1
        -- 2. Buscar piezas sueltas que un hacker pueda lanzar de forma invisible
        elseif not obj.Anchored and not obj.Parent:FindFirstChild("Humanoid") then
            CreateHighlight(obj, Color3.fromRGB(255, 150, 0), "🧱 PARTE SUELTA (Riesgo Fling)")
            unanchoredCount = unanchoredCount + 1
        end
    end
end

-- Mostrar un pequeño panel con el resumen
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 250, 0, 80)
panel.Position = UDim2.new(0, 10, 0, 10)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
panel.Parent = screenGui

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -10, 1, -10)
info.Position = UDim2.new(0, 5, 0, 5)
info.BackgroundTransparency = 1
info.TextColor3 = Color3.fromRGB(255, 255, 255)
info.TextXAlignment = Enum.TextXAlignment.Left
info.Font = Enum.Font.Code
info.TextSize = 14
info.Text = "🔍 RAYOS X ACTIVO\nPartes sueltas (Naranjas): " .. unanchoredCount .. "\nSensores táctiles (Rojos): " .. hitboxCount
info.Parent = panel
