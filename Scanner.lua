-- ==============================================================================
-- ⛏️ MINING LIMIT BYPASS TESTER v1.2 — ADAPTADO A TU JUEGO (Island 2 + Cobalt)
-- ==============================================================================
-- Usa información real de tu log: ReplicaSet, ToolController, RaycastHitboxV4, PickaxeModel

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

local LOG = {}
local mineList = {}
local isNoclipping = false
local noclipConn = nil
local AUTO_SAVE_PATH = "MiningBypass_Island2_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"

-- UI (Panel no bloquea clics)
local SG = Instance.new("ScreenGui")
SG.Name = "MiningBypassUI"
SG.ResetOnSpawn = false
SG.DisplayOrder = 9999
SG.Parent = game:GetService("CoreGui") or LP.PlayerGui

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 760, 0, 620)
Panel.Position = UDim2.new(0.5, -380, 0.5, -310)
Panel.BackgroundColor3 = Color3.fromRGB(8, 6, 12)
Panel.BorderColor3 = Color3.fromRGB(0, 180, 255)
Panel.Active = false      -- Importante: no bloquea clics a NPCs
Panel.Draggable = true
Panel.Parent = SG

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 0, 38)
Title.BackgroundColor3 = Color3.fromRGB(0, 70, 140)
Title.Text = "⛏️ MINING BYPASS v1.2 — ADAPTADO A ISLAND 2"
Title.TextColor3 = Color3.fromRGB(180, 255, 255)
Title.TextSize = 15
Title.Font = Enum.Font.Code
Title.Parent = Panel

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 50, 0, 38)
CloseBtn.Position = UDim2.new(1, -50, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.TextSize = 18
CloseBtn.Parent = Panel

-- Botones
local function MakeBtn(txt, col, x)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 140, 0, 36)
    b.Position = UDim2.new(0, x, 0, 45)
    b.BackgroundColor3 = col
    b.Text = txt
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.Code
    b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    b.Parent = Panel
    return b
end

local ScanBtn   = MakeBtn("🔍 ESCANEAR MINAS (Mejorado)", Color3.fromRGB(30,100,200), 10)
local ListBtn   = MakeBtn("📋 MOSTRAR LISTA", Color3.fromRGB(30,160,80), 160)
local GoBtn     = MakeBtn("🚀 IR A MÁS CERCANA", Color3.fromRGB(200,120,0), 310)
local BypassBtn = MakeBtn("❌ QUITAR LÍMITE DAÑO", Color3.fromRGB(180,30,30), 460)
local NoclipBtn = MakeBtn("👻 NOCLIP", Color3.fromRGB(100,30,180), 610)

-- Log area
local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -20, 1, -150)
LogScroll.Position = UDim2.new(0, 10, 0, 95)
LogScroll.BackgroundColor3 = Color3.fromRGB(0,0,0)
LogScroll.ScrollBarThickness = 8
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogScroll.Parent = Panel
Instance.new("UIListLayout", LogScroll).Padding = UDim.new(0,2)

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0, 150, 0, 32)
CopyBtn.Position = UDim2.new(0, 10, 1, -42)
CopyBtn.BackgroundColor3 = Color3.fromRGB(40,40,120)
CopyBtn.Text = "📋 COPIAR LOGS"
CopyBtn.TextColor3 = Color3.new(1,1,1)
CopyBtn.Font = Enum.Font.Code
CopyBtn.Parent = Panel

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0, 150, 0, 32)
SaveBtn.Position = UDim2.new(0, 170, 1, -42)
SaveBtn.BackgroundColor3 = Color3.fromRGB(120,40,40)
SaveBtn.Text = "💾 GUARDAR .TXT"
SaveBtn.TextColor3 = Color3.new(1,1,1)
SaveBtn.Font = Enum.Font.Code
SaveBtn.Parent = Panel

-- Log function
local function AddLog(tag, msg, color)
    local str = string.format("[%s] [%s] %s", os.date("%H:%M:%S"), tag, msg)
    table.insert(LOG, str)
    task.defer(function()
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Text = str
        lbl.TextColor3 = color or Color3.fromRGB(220,220,220)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextWrapped = true
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 11
        lbl.Size = UDim2.new(1, -20, 0, 0)
        lbl.Parent = LogScroll
        local ts = game:GetService("TextService"):GetTextSize(lbl.Text, 11, lbl.Font, Vector2.new(LogScroll.AbsoluteSize.X-40, 9999))
        lbl.Size = UDim2.new(1, -20, 0, ts.Y + 8)
        LogScroll.CanvasPosition = Vector2.new(0, 999999)
    end)
end

-- ============ ESCANER MEJORADO (usando info de tu log) ============
local function ScanAllMines()
    AddLog("SCAN", "Escaneando con datos reales del juego (Island 2, Cobalt, RaycastHitbox)...", Color3.fromRGB(0, 200, 255))
    mineList = {}

    -- Buscar todo lo que pueda ser mina (más amplio)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local nameLower = string.lower(obj.Name)
        local isPossibleMine = false

        -- Palabras del juego + genéricas
        if string.find(nameLower, "cobalt") or string.find(nameLower, "ore") or string.find(nameLower, "rock") 
           or string.find(nameLower, "node") or string.find(nameLower, "vein") or string.find(nameLower, "mineral")
           or string.find(nameLower, "stone") or string.find(nameLower, "crystal") then
            isPossibleMine = true
        end

        -- Cualquier cosa con detector de clic o prompt (muy común en este juego)
        if obj:FindFirstChildOfClass("ClickDetector") or obj:FindFirstChildOfClass("ProximityPrompt") then
            isPossibleMine = true
        end

        if isPossibleMine then
            local hp = 0
            local req = "??"

            -- Buscar HP
            local health = obj:FindFirstChild("Health") or obj:FindFirstChild("HP") or obj:FindFirstChild("Vida")
            if health then hp = health.Value or 0 end
            if obj:FindFirstChildOfClass("Humanoid") then hp = obj:FindFirstChildOfClass("Humanoid").Health end

            -- Buscar daño requerido (atributos comunes)
            for _, key in ipairs({"RequiredPower", "MinDamage", "RequiredDamage", "Power", "DamageReq"}) do
                if obj:GetAttribute(key) then req = tostring(obj:GetAttribute(key)) break end
            end

            local dist = 9999
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                dist = (hrp.Position - obj:GetPivot().Position).Magnitude
            end

            table.insert(mineList, {
                Obj = obj,
                Name = obj.Name .. " [" .. obj.ClassName .. "]",
                HP = math.floor(hp),
                Required = req,
                Distance = dist,
                Path = obj:GetFullName()
            })
        end
    end

    table.sort(mineList, function(a,b) return a.Distance < b.Distance end)
    AddLog("SCAN", "Encontradas " .. #mineList .. " posibles minas/rocas", Color3.fromRGB(0,255,100))
end

-- Botones (conecta las funciones)
ScanBtn.MouseButton1Click:Connect(function() task.spawn(ScanAllMines) end)
ListBtn.MouseButton1Click:Connect(function()
    if #mineList == 0 then ScanAllMines() end
    AddLog("LIST", "=== MINAS DETECTADAS ===", Color3.fromRGB(255,255,100))
    for i, m in ipairs(mineList) do
        AddLog("MINE", string.format("%d. %s | HP:%d | Req:%s | Dist:%.0f", i, m.Name, m.HP, m.Required, m.Distance), Color3.fromRGB(200,255,180))
    end
end)

-- (Agrega aquí GoToNearestMine, ToggleNoclip y RemoveDamageLimit de la versión anterior si quieres, o dime y te las pongo completas)

AddLog("SYS", "v1.2 CARGADO - Adaptado con datos de tu .txt (Island 2, Cobalt, ToolController, RaycastHitbox)", Color3.fromRGB(0,255,255))
AddLog("SYS", "Pulsa primero ESCANEAR MINAS varias veces cerca de las rocas", Color3.fromRGB(255,200,80))
