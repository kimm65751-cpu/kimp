-- ==============================================================================
-- 🛡️ REVERSE ENG: DEEP ANALYZER V3.0 (ROOT CAUSE)
-- Creado para escanear a fondo el Botón Amarillo y descubrir CÓMO y DÓNDE 
-- se comunican las verificaciones de tu base.
-- ==============================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Paso 1: Limpieza Total
pcall(function()
    for _, obj in pairs(CoreGui:GetChildren()) do
        if obj.Name == "NetworkAnalyzerV2" or obj.Name == "DeepAnalyzerV3" or obj.Name == "AutoDefender_V2" then 
            obj:Destroy() 
        end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeepAnalyzerV3"
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 440, 0, 380)
MainFrame.Position = UDim2.new(0.5, -220, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 150)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Text = "🛡️ DEEP ANALYZER V3.0 (AUTORIDAD)"
Title.Font = Enum.Font.Code
Title.TextSize = 15
Title.Parent = MainFrame

-- Botones interactivos
local BtnScan = Instance.new("TextButton")
BtnScan.Size = UDim2.new(0.45, 0, 0, 35)
BtnScan.Position = UDim2.new(0.025, 0, 0, 40)
BtnScan.BackgroundColor3 = Color3.fromRGB(60, 60, 150)
BtnScan.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnScan.Text = "1. ESCANEAR BOTÓN"
BtnScan.Font = Enum.Font.Code
BtnScan.TextSize = 14
BtnScan.Parent = MainFrame

local BtnAttack = Instance.new("TextButton")
BtnAttack.Size = UDim2.new(0.45, 0, 0, 35)
BtnAttack.Position = UDim2.new(0.525, 0, 0, 40)
BtnAttack.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
BtnAttack.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnAttack.Text = "2. FORZAR BARRERA"
BtnAttack.Font = Enum.Font.Code
BtnAttack.TextSize = 14
BtnAttack.Parent = MainFrame

local LogHolder = Instance.new("ScrollingFrame")
LogHolder.Size = UDim2.new(0.95, 0, 0, 280)
LogHolder.Position = UDim2.new(0.025, 0, 0, 85)
LogHolder.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
LogHolder.BorderSizePixel = 1
LogHolder.BorderColor3 = Color3.fromRGB(0, 255, 150)
LogHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
LogHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogHolder.BottomImage = ""
LogHolder.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout", LogHolder)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

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
    lbl.TextSize = 12
    lbl.LayoutOrder = logCount
    lbl.Parent = LogHolder
    LogHolder.CanvasPosition = Vector2.new(0, 99999) -- Auto Scroll
end

AddLog("✅ V3.0 Lista. Párate junto al botón amarillo.", Color3.fromRGB(100, 255, 100))

-- Metamétodo pasivo para escuchar remotos por si acaso
task.spawn(function()
    pcall(function()
        local mt = getrawmetatable(game)
        if setreadonly and mt then
            setreadonly(mt, false)
            local oldNC = mt.__namecall
            mt.__namecall = newcclosure(function(self, ...)
                local m = getnamecallmethod()
                if m == "FireServer" or m == "InvokeServer" then
                    local n = tostring(self.Name)
                    if not n:match("Mouse") and not n:match("Move") then
                        task.spawn(AddLog, "📡 REMOTO INTENTÓ ENVIAR: " .. n, Color3.fromRGB(255, 100, 0))
                    end
                end
                return oldNC(self, ...)
            end)
            setreadonly(mt, true)
        end
    end)
end)

-- Variables globales
local TargetButton = nil
local TargetTimerText = nil

local function FindYellowButton()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local myPos = char.HumanoidRootPart.Position

    TargetButton = nil
    TargetTimerText = nil
    local closestDist = 150

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("TextLabel") and (string.match(obj.Text, "%d+s") or obj.Text:match("LockBase") or obj.Text:match("Locked")) then
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
    return TargetButton ~= nil
end

-- ================== MÉTODO 1: DESCUBRIMIENTO ==================
BtnScan.MouseButton1Click:Connect(function()
    AddLog("\n🔍 [ESTADO] Escaneando interior del botón...", Color3.fromRGB(200, 200, 255))
    if FindYellowButton() then
        AddLog("🎯 Botón Identificado: " .. TargetButton.Name, Color3.fromRGB(0, 255, 150))
        AddLog("📄 Ruta Absoluta: " .. TargetButton:GetFullName(), Color3.fromRGB(150, 150, 255))
        
        -- Diseccionar la comunicación
        local hasClick = TargetButton:FindFirstChildWhichIsA("ClickDetector")
        local hasPrompt = TargetButton:FindFirstChildWhichIsA("ProximityPrompt")
        local scripts = 0
        local localScripts = 0
        local remotes = 0
        
        for _, desc in pairs(TargetButton:GetChildren()) do
            if desc:IsA("Script") then scripts = scripts + 1 end
            if desc:IsA("LocalScript") then localScripts = localScripts + 1 end
            if desc:IsA("RemoteEvent") then remotes = remotes + 1 end
        end
        
        if hasClick then AddLog("⚙️ Hallazgo: Tiene 'ClickDetector' (Se activa con el Mouse)", Color3.fromRGB(255, 255, 100)) end
        if hasPrompt then AddLog("⚙️ Hallazgo: Tiene 'ProximityPrompt' (Se activa con E)", Color3.fromRGB(255, 255, 100)) end
        if not hasClick and not hasPrompt then
            AddLog("⚙️ Hallazgo: Se basa 100% en colisión física (El .Touched te engaña).", Color3.fromRGB(255, 100, 100))
        end
        
        AddLog("🧾 Arquitectura: ["..scripts.."] ServerScripts | ["..localScripts.."] LocalScripts | ["..remotes.."] Remotes.", Color3.fromRGB(255, 150, 255))
        
        -- Veredicto preliminar
        if localScripts > 0 and scripts == 0 then
            AddLog("❌ ERROR CRÍTICO: ¡Vulnerabilidad de cliente detectada! Tienes un LocalScript adentro manejando visuales sin validarse en el server.", Color3.fromRGB(255, 50, 50))
        end
    else
        AddLog("⚠️ No se encontró el círculo de la base cerca.", Color3.fromRGB(255, 50, 50))
    end
end)

-- ================== MÉTODO 2: FORZAR COMUNICACIÓN ==================
BtnAttack.MouseButton1Click:Connect(function()
    if not TargetButton then
        AddLog("❌ Primero debes presionar [1. ESCANEAR BOTÓN]", Color3.fromRGB(255, 50, 50))
        return
    end
    
    AddLog("\n⚔️ INYECTANDO TODOS LOS MÉTODOS SIMULTÁNEAMENTE...", Color3.fromRGB(255, 60, 60))
    pcall(function()
        -- Inyección 1: Click Detector nativo
        local cd = TargetButton:FindFirstChildWhichIsA("ClickDetector")
        if cd and fireclickdetector then
            AddLog("▶️ ByPass 1: Ejecutando ClickDetector", Color3.fromRGB(100, 255, 100))
            fireclickdetector(cd)
        end
        
        -- Inyección 2: Prompts nativos invisibles
        local pr = TargetButton:FindFirstChildWhichIsA("ProximityPrompt")
        if pr and fireproximityprompt then
            AddLog("▶️ ByPass 2: Ejecutando ProximityPrompt", Color3.fromRGB(100, 255, 100))
            fireproximityprompt(pr)
        end
        
        -- Inyección 3: Touched Físico C++ API
        if firetouchinterest and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
            AddLog("▶️ ByPass 3: Ejecutando OnTouch (C++)", Color3.fromRGB(100, 255, 100))
            firetouchinterest(LocalPlayer.Character.PrimaryPart, TargetButton, 0)
            task.wait(0.05)
            firetouchinterest(LocalPlayer.Character.PrimaryPart, TargetButton, 1)
        end
        
        AddLog("✅ Pruebas enviadas al motor. Si la puerta no se cerró, es un error de los ServerScripts.", Color3.fromRGB(0, 255, 255))
    end)
end)
