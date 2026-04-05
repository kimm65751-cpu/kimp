-- ==============================================================================
-- ⚔️ OMNI-AUTO FARMER V1.0 - [AURA KILL + HOVER NOCLIP]
-- Diseñado para explotar: ReplicatedStorage.CombatSystem.Remotes.RequestHit
-- ==============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local AutoFarm = false
local FarmMode = "Arriba" -- "Arriba", "Detras", "Abajo"
local OfsY, OfsZ = 10, 0
local BlinkAttackEnabled = false

local MobMagnetEnabled = false
local AutoSkillEnabled = false
local TargetBosses = "Normal"
local ScannedTargetName = nil
local ScannedTargetPos = nil
local SpyEnabled = false
local SpyFileName = ""
local PanicThreshold = 0.20
local ReturnHealthThreshold = 0.95
local IsInPanicRecovery = false
local GlobalMagnetTarget = nil
local MemoryPoint = nil
local ForceMemoryReturn = false
local IsWalkingToMemory = false
local LastRealDamageTime = os.clock()
local VIM = game:GetService("VirtualInputManager")

-- Endpoints Críticos (Sacados del Scanner)
local CombatRemote = ReplicatedStorage:WaitForChild("CombatSystem"):WaitForChild("Remotes"):WaitForChild("RequestHit")
local NPCsFolder = Workspace:WaitForChild("NPCs")

-- ==============================================================================
-- GUI V2.0 — DISEÑO PREMIUM TABBED (COLORES SUAVES, MINIMALISTA)
-- ==============================================================================
local TargetGui = pcall(function() return CoreGui.Name end) and CoreGui or LP:WaitForChild("PlayerGui")
for _, v in pairs(TargetGui:GetChildren()) do if v.Name == "OmniAutoFarm" then pcall(function() v:Destroy() end) end end

local SG = Instance.new("ScreenGui")
SG.Name = "OmniAutoFarm"
SG.ResetOnSpawn = false
SG.Parent = TargetGui

-- ======================== PALETA DE COLORES SUAVES ========================
local C = {
    bg        = Color3.fromRGB(22, 24, 30),
    sidebar   = Color3.fromRGB(28, 30, 38),
    panel     = Color3.fromRGB(30, 33, 42),
    accent    = Color3.fromRGB(100, 130, 255),
    accentOn  = Color3.fromRGB(90, 210, 140),
    accentOff = Color3.fromRGB(60, 65, 80),
    red       = Color3.fromRGB(200, 80, 90),
    title     = Color3.fromRGB(180, 190, 230),
    text      = Color3.fromRGB(200, 205, 220),
    muted     = Color3.fromRGB(110, 115, 135),
    card      = Color3.fromRGB(38, 42, 55),
    border    = Color3.fromRGB(55, 60, 80),
}

-- ======================== CONTENEDOR PRINCIPAL ========================
local uis = game:GetService("UserInputService")
local MF = Instance.new("Frame", SG)
MF.Name = "MainFrame"
MF.Size = UDim2.new(0, 560, 0, 520)
MF.Position = UDim2.new(0.5, -280, 0.5, -260)
MF.BackgroundColor3 = C.bg
MF.BorderSizePixel = 0
MF.Active = true
MF.Draggable = true
Instance.new("UICorner", MF).CornerRadius = UDim.new(0, 10)

local MFStroke = Instance.new("UIStroke", MF)
MFStroke.Color = C.border
MFStroke.Thickness = 1.5

-- ========== GUARDAR/CARGAR CONFIGURACIÓN ==========
local function SaveConfig()
    if writefile then
        local data = {
            ScannedTargetName = ScannedTargetName,
            ScannedTargetPos = ScannedTargetPos and { X = ScannedTargetPos.X, Y = ScannedTargetPos.Y, Z =
            ScannedTargetPos.Z } or nil,
            PanicThreshold = PanicThreshold,
            ReturnHealthThreshold = ReturnHealthThreshold,
            MobMagnetEnabled = MobMagnetEnabled,
            AutoSkillEnabled = AutoSkillEnabled,
            TargetBosses = TargetBosses,
            FarmMode = FarmMode,
            BlinkAttackEnabled = BlinkAttackEnabled,
            MemoryPoint = MemoryPoint and { X = MemoryPoint.X, Y = MemoryPoint.Y, Z = MemoryPoint.Z } or nil
        }
        pcall(function() writefile("OmniAutoFarmConfig.json", game:GetService("HttpService"):JSONEncode(data)) end)
    end
end

-- ========== BOTÓN FLOTANTE ==========
local BtnFloat = Instance.new("TextButton", SG)
BtnFloat.Size = UDim2.new(0, 40, 0, 40)
BtnFloat.Position = UDim2.new(0, 15, 0, 15)
BtnFloat.BackgroundColor3 = C.sidebar
BtnFloat.Text = "⚔️"
BtnFloat.TextSize = 18
BtnFloat.Active = true
BtnFloat.Draggable = true
BtnFloat.BorderSizePixel = 0
Instance.new("UICorner", BtnFloat).CornerRadius = UDim.new(0, 20)
Instance.new("UIStroke", BtnFloat).Color = C.accent

-- ========== BARRA DE TÍTULO ==========
local TitleBar = Instance.new("Frame", MF)
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = C.sidebar
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚔️  SAILOR PIECE — AUTO FARM"
Title.TextColor3 = C.title
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left

local BtnMin = Instance.new("TextButton", TitleBar)
BtnMin.Size = UDim2.new(0, 36, 0, 36)
BtnMin.Position = UDim2.new(1, -36, 0, 0)
BtnMin.BackgroundTransparency = 1
BtnMin.Text = "—"
BtnMin.TextColor3 = C.muted
BtnMin.TextSize = 18
BtnMin.Font = Enum.Font.GothamBold

-- ========== STATUS BAR ==========
local StatusLabel = Instance.new("TextLabel", MF)
StatusLabel.Size = UDim2.new(1, -20, 0, 18)
StatusLabel.Position = UDim2.new(0, 10, 0, 38)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Inactivo"
StatusLabel.TextColor3 = C.muted
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 13
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ======================== SIDEBAR (PESTAÑAS) ========================
local Sidebar = Instance.new("Frame", MF)
Sidebar.Size = UDim2.new(0, 56, 1, -60)
Sidebar.Position = UDim2.new(0, 0, 0, 58)
Sidebar.BackgroundColor3 = C.sidebar
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 4)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 8)

local ActiveTab = "Farm"
local TabFrames = {}

local function MakeTabBtn(icon, tabName, order)
    local tb = Instance.new("TextButton", Sidebar)
    tb.Size = UDim2.new(0, 44, 0, 44)
    tb.BackgroundColor3 = (tabName == "Farm") and C.accent or C.accentOff
    tb.Text = icon
    tb.TextSize = 20
    tb.Font = Enum.Font.GothamBold
    tb.TextColor3 = Color3.new(1, 1, 1)
    tb.LayoutOrder = order
    tb.BorderSizePixel = 0
    tb.Name = "Tab_" .. tabName
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)
    return tb
end

local TabFarm = MakeTabBtn("⚔️", "Farm", 1)
local TabMem = MakeTabBtn("📍", "Memoria", 2)
local TabExtras = MakeTabBtn("🍎", "Extras", 3)
local TabCalib = MakeTabBtn("🎯", "Calibrar", 4)

-- ======================== PANEL DE CONTENIDO ========================
local ContentPanel                                  = Instance.new("Frame", MF)
ContentPanel.Size                                   = UDim2.new(1, -62, 1, -60)
ContentPanel.Position                               = UDim2.new(0, 60, 0, 58)
ContentPanel.BackgroundColor3                       = C.panel
ContentPanel.BorderSizePixel                        = 0
Instance.new("UICorner", ContentPanel).CornerRadius = UDim.new(0, 8)

-- ======================== UTILIDADES DE UI ========================
local function MakeScrollPage(name)
    local page = Instance.new("ScrollingFrame", ContentPanel)
    page.Name = name
    page.Size = UDim2.new(1, -10, 1, -10)
    page.Position = UDim2.new(0, 5, 0, 5)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = C.accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = (name == "Farm")
    local lay = Instance.new("UIListLayout", page)
    lay.Padding = UDim.new(0, 5)
    lay.HorizontalAlignment = Enum.HorizontalAlignment.Center
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    Instance.new("UIPadding", page).PaddingTop = UDim.new(0, 4)
    TabFrames[name] = page
    return page
end

local function SwitchTab(tabName)
    ActiveTab = tabName
    for name, frame in pairs(TabFrames) do
        frame.Visible = (name == tabName)
    end
    for _, btn in pairs(Sidebar:GetChildren()) do
        if btn:IsA("TextButton") then
            btn.BackgroundColor3 = btn.Name == ("Tab_" .. tabName) and C.accent or C.accentOff
        end
    end
end

TabFarm.MouseButton1Click:Connect(function() SwitchTab("Farm") end)
TabMem.MouseButton1Click:Connect(function() SwitchTab("Memoria") end)
TabExtras.MouseButton1Click:Connect(function() SwitchTab("Extras") end)
TabCalib.MouseButton1Click:Connect(function() SwitchTab("Calibrar") end)

local function SectionLabel(parent, text, order)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(1, -10, 0, 26)
    l.BackgroundTransparency = 1
    l.TextColor3 = C.accent
    l.Font = Enum.Font.GothamBold
    l.TextSize = 13
    l.Text = "  " .. text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.LayoutOrder = order or 0
end

local function ToggleButton(parent, text, order, defaultColor)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 36)
    btn.BackgroundColor3 = defaultColor or C.card
    btn.TextColor3 = C.text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.Text = "  " .. text
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = order or 0
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

-- =======================================================================================
-- ========== TAB 1: FARM ==========
-- =======================================================================================
local FarmPage = MakeScrollPage("Farm")

SectionLabel(FarmPage, "COMBATE", 1)
local BtnToggle    = ToggleButton(FarmPage, "► Iniciar Auto-Farm", 2, C.red)
BtnToggle.TextSize = 15
BtnToggle.Font     = Enum.Font.GothamBold
local BtnHeight    = ToggleButton(FarmPage, "Posición: ☁️ Arriba", 3)
local BtnMagnet    = ToggleButton(FarmPage, "🧲 Imán de Mobs", 4)
local BtnSkill     = ToggleButton(FarmPage, "🔥 Auto Skill (X)", 5)
local BtnBoss      = ToggleButton(FarmPage, "🎯 Cazar Bosses: Normal", 6)
local BtnBlink     = ToggleButton(FarmPage, "⚡ Blink Fx (Sniper 45 studs)", 7, C.card)
SectionLabel(FarmPage, "DEFENSA", 11)
local PanicLabel = Instance.new("TextLabel", FarmPage)
PanicLabel.Size = UDim2.new(0.95, 0, 0, 16)
PanicLabel.BackgroundTransparency = 1
PanicLabel.TextColor3 = C.muted
PanicLabel.Font = Enum.Font.Gotham
PanicLabel.TextSize = 12
PanicLabel.Text = "  🛡️ Escudo Pánico — Escapa al " .. math.floor(PanicThreshold * 100) .. "%"
PanicLabel.TextXAlignment = Enum.TextXAlignment.Left
PanicLabel.LayoutOrder = 12

local SliderBg = Instance.new("TextButton", FarmPage)
SliderBg.Size = UDim2.new(0.95, 0, 0, 12)
SliderBg.BackgroundColor3 = Color3.fromRGB(40, 42, 55)
SliderBg.Text = ""
SliderBg.LayoutOrder = 13
SliderBg.BorderSizePixel = 0
Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(0, 6)

local SliderFill = Instance.new("Frame", SliderBg)
SliderFill.Size = UDim2.new(PanicThreshold, 0, 1, 0)
SliderFill.BackgroundColor3 = C.accentOn
SliderFill.BorderSizePixel = 0
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 6)

local ReturnHealthLabel = Instance.new("TextLabel", FarmPage)
ReturnHealthLabel.Size = UDim2.new(0.95, 0, 0, 16)
ReturnHealthLabel.BackgroundTransparency = 1
ReturnHealthLabel.TextColor3 = C.muted
ReturnHealthLabel.Font = Enum.Font.Gotham
ReturnHealthLabel.TextSize = 12
ReturnHealthLabel.Text = "  💚 Vida para Volver — " .. math.floor(ReturnHealthThreshold * 100) .. "%"
ReturnHealthLabel.TextXAlignment = Enum.TextXAlignment.Left
ReturnHealthLabel.LayoutOrder = 14

local ReturnSliderBg = Instance.new("TextButton", FarmPage)
ReturnSliderBg.Size = UDim2.new(0.95, 0, 0, 12)
ReturnSliderBg.BackgroundColor3 = Color3.fromRGB(40, 42, 55)
ReturnSliderBg.Text = ""
ReturnSliderBg.LayoutOrder = 15
ReturnSliderBg.BorderSizePixel = 0
Instance.new("UICorner", ReturnSliderBg).CornerRadius = UDim.new(0, 6)

local ReturnSliderFill = Instance.new("Frame", ReturnSliderBg)
ReturnSliderFill.Size = UDim2.new(ReturnHealthThreshold, 0, 1, 0)
ReturnSliderFill.BackgroundColor3 = Color3.fromRGB(80, 255, 120)
ReturnSliderFill.BorderSizePixel = 0
Instance.new("UICorner", ReturnSliderFill).CornerRadius = UDim.new(0, 6)

SectionLabel(FarmPage, "UTILIDADES", 20)
local BtnCodes = ToggleButton(FarmPage, "📋 Gestor de Códigos", 21, Color3.fromRGB(35, 55, 75))

-- =======================================================================================
-- ========== TAB 2: MEMORIA (PUNTO DE RETORNO) ==========
-- =======================================================================================
local MemPage = MakeScrollPage("Memoria")

SectionLabel(MemPage, "PUNTO DE RETORNO", 1)

local MemStatusLabel = Instance.new("TextLabel", MemPage)
MemStatusLabel.Size = UDim2.new(0.95, 0, 0, 22)
MemStatusLabel.BackgroundTransparency = 1
MemStatusLabel.TextColor3 = C.muted
MemStatusLabel.Font = Enum.Font.GothamMedium
MemStatusLabel.TextSize = 12
MemStatusLabel.Text = "  📍 Sin punto guardado"
MemStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
MemStatusLabel.LayoutOrder = 2

local MemInfoLabel = Instance.new("TextLabel", MemPage)
MemInfoLabel.Size = UDim2.new(0.95, 0, 0, 50)
MemInfoLabel.BackgroundTransparency = 1
MemInfoLabel.TextColor3 = Color3.fromRGB(90, 95, 110)
MemInfoLabel.Font = Enum.Font.Gotham
MemInfoLabel.TextSize = 11
MemInfoLabel.Text =
"  Presiona M para guardar tu posición actual.\n  Si mueres y no hay mobs por 10s, caminarás\n  lento hasta ese punto automáticamente."
MemInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
MemInfoLabel.TextWrapped = true
MemInfoLabel.LayoutOrder = 3

local BtnClearMem = ToggleButton(MemPage, "🗑️ Borrar Punto Guardado", 4, C.red)

BlinkStepValue = 45
local blinkOptions = {45, 25, 15, 5}
local currentBlinkIdx = 1

local BtnBlinkSpeed = ToggleButton(MemPage, "⚡ Velocidad de Regreso: 45 Studs", 5, C.card)
BtnBlinkSpeed.MouseButton1Click:Connect(function()
    currentBlinkIdx = currentBlinkIdx + 1
    if currentBlinkIdx > #blinkOptions then
        currentBlinkIdx = 1
    end
    BlinkStepValue = blinkOptions[currentBlinkIdx]
    BtnBlinkSpeed.Text = "⚡ Velocidad de Regreso: " .. BlinkStepValue .. " Studs"
end)

-- =======================================================================================
-- ========== TAB 3: EXTRAS (AUTO FRUIT BUYER) ==========
-- =======================================================================================
local ExtrasPage = MakeScrollPage("Extras")

SectionLabel(ExtrasPage, "AUTO COMPRA DE FRUTAS", 1)

local FruitStatusLabel = Instance.new("TextLabel", ExtrasPage)
FruitStatusLabel.Size = UDim2.new(0.95, 0, 0, 40)
FruitStatusLabel.BackgroundTransparency = 1
FruitStatusLabel.TextColor3 = C.muted
FruitStatusLabel.Font = Enum.Font.GothamMedium
FruitStatusLabel.TextSize = 11
FruitStatusLabel.Text =
"  Compra frutas con monedas hasta obtener Quake o Light.\n  Las frutas que no sirven se tiran automáticamente."
FruitStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
FruitStatusLabel.TextWrapped = true
FruitStatusLabel.LayoutOrder = 2

local FruitLogLabel = Instance.new("TextLabel", ExtrasPage)
FruitLogLabel.Size = UDim2.new(0.95, 0, 0, 20)
FruitLogLabel.BackgroundTransparency = 1
FruitLogLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
FruitLogLabel.Font = Enum.Font.Code
FruitLogLabel.TextSize = 11
FruitLogLabel.Text = "  Estado: Inactivo"
FruitLogLabel.TextXAlignment = Enum.TextXAlignment.Left
FruitLogLabel.LayoutOrder = 3

local AutoFruitBuying = false
local DesiredFruits = { ["Quake"] = true, ["Light"] = true }

local BtnAutoFruit = ToggleButton(ExtrasPage, "🍎 Comprar Frutas (Monedas)", 4, Color3.fromRGB(60, 40, 20))
local BtnStopFruit = ToggleButton(ExtrasPage, "⏹ Detener", 5, C.red)

SectionLabel(ExtrasPage, "FRUTAS DESEADAS", 6)
local FruitDesireInfo = Instance.new("TextLabel", ExtrasPage)
FruitDesireInfo.Size = UDim2.new(0.95, 0, 0, 60)
FruitDesireInfo.BackgroundColor3 = C.card
FruitDesireInfo.TextColor3 = C.text
FruitDesireInfo.Font = Enum.Font.Code
FruitDesireInfo.TextSize = 11
FruitDesireInfo.Text =
"  Buscando: Quake, Light\n  Rates: Common=50% Uncommon=30% Rare=13% Epic=5% Legendary=2%\n  Ambos dealers tienen las MISMAS frutas"
FruitDesireInfo.TextXAlignment = Enum.TextXAlignment.Left
FruitDesireInfo.TextWrapped = true
FruitDesireInfo.LayoutOrder = 7
Instance.new("UICorner", FruitDesireInfo).CornerRadius = UDim.new(0, 4)

SectionLabel(ExtrasPage, "NPC DEALERS", 10)
local DealerInfo = Instance.new("TextLabel", ExtrasPage)
DealerInfo.Size = UDim2.new(0.95, 0, 0, 40)
DealerInfo.BackgroundColor3 = C.card
DealerInfo.TextColor3 = C.text
DealerInfo.Font = Enum.Font.Code
DealerInfo.TextSize = 11
DealerInfo.Text = "  CoinDealer @ (408,3,803) = 15,000 Coins\n  GemDealer  @ (401,3,752) = 50 Gems"
DealerInfo.TextXAlignment = Enum.TextXAlignment.Left
DealerInfo.TextWrapped = true
DealerInfo.LayoutOrder = 11
Instance.new("UICorner", DealerInfo).CornerRadius = UDim.new(0, 4)

-- ========== AUTO FRUIT BUYER LOGIC ==========
local function FindCoinDealer()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "CoinFruitDealer" then
            return obj
        end
    end
    return nil
end

local function GetFruitPrompt(dealer)
    if dealer then
        for _, c in pairs(dealer:GetDescendants()) do
            if c:IsA("ProximityPrompt") then return c end
        end
    end
    return nil
end

local function DropFruitTool(fruitTool)
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end

    -- Try remote drop
    pcall(function()
        local dropRemote = ReplicatedStorage:FindFirstChild("RemoteEvents") and
        ReplicatedStorage.RemoteEvents:FindFirstChild("DropFruit")
        if dropRemote then
            local fruitData = fruitTool:FindFirstChild("FruitData")
            if fruitData then
                dropRemote:FireServer(fruitData.Value)
            end
        end
    end)
    task.wait(0.3)

    -- If still in backpack, equip and try dropping again
    if fruitTool.Parent == LP.Backpack then
        hum:EquipTool(fruitTool)
        task.wait(0.3)
        pcall(function()
            local dropRemote = ReplicatedStorage.RemoteEvents:FindFirstChild("DropFruit")
            if dropRemote then
                local fruitData = fruitTool:FindFirstChild("FruitData")
                if fruitData then dropRemote:FireServer(fruitData.Value) end
            end
        end)
        task.wait(0.3)
        hum:UnequipTools()
    end
end

task.spawn(function()
    while true do
        task.wait(0.5)
        local foundDesired = false
        -- REVISAR INVENTARIO
        for _, tool in pairs(LP.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local isFruit = tool:FindFirstChild("IsFruitTool")
                local fruitModel = tool:FindFirstChild("FruitModel")
                if isFruit and fruitModel then
                    local fname = fruitModel.Value
                    local rarity = tool:FindFirstChild("Rarity")
                    local rarStr = rarity and rarity.Value or "?"

                    if DesiredFruits[fname] then
                        foundDesired = true
                        FruitLogLabel.Text = "  ENCONTRADA: " .. fname .. " (" .. rarStr .. ") - DETENIENDO"
                        FruitLogLabel.TextColor3 = Color3.fromRGB(90, 255, 90)
                        AutoFruitBuying = false
                        BtnAutoFruit.BackgroundColor3 = Color3.fromRGB(60, 40, 20)
                        BtnAutoFruit.Text = "  🍎 Comprar Frutas (Monedas)"
                    else
                        FruitLogLabel.Text = "  Tirando: " .. tool.Name .. " (" .. rarStr .. ")"
                        DropFruitTool(tool)
                        task.wait(0.5)
                    end
                end
            end
        end

        -- REVISAR HERRAMIENTA EN MANO
        if not foundDesired and LP.Character then
            for _, tool in pairs(LP.Character:GetChildren()) do
                if tool:IsA("Tool") then
                    local isFruit = tool:FindFirstChild("IsFruitTool")
                    local fruitModel = tool:FindFirstChild("FruitModel")
                    if isFruit and fruitModel then
                        local fname = fruitModel.Value
                        if DesiredFruits[fname] then
                            foundDesired = true
                            FruitLogLabel.Text = "  ENCONTRADA: " .. fname .. " - DETENIENDO"
                            FruitLogLabel.TextColor3 = Color3.fromRGB(90, 255, 90)
                            AutoFruitBuying = false
                            BtnAutoFruit.BackgroundColor3 = Color3.fromRGB(60, 40, 20)
                            BtnAutoFruit.Text = "  🍎 Comprar Frutas (Monedas)"
                        else
                            FruitLogLabel.Text = "  Tirando: " .. tool.Name
                            DropFruitTool(tool)
                            task.wait(0.5)
                        end
                    end
                end
            end
        end

        task.wait(1)
    end
end)

BtnAutoFruit.MouseButton1Click:Connect(function()
    AutoFruitBuying = not AutoFruitBuying
    if AutoFruitBuying then
        BtnAutoFruit.BackgroundColor3 = C.accentOn
        BtnAutoFruit.Text = "  🍎 Comprando..."
        FruitLogLabel.Text = "  Iniciando compra automática..."
        FruitLogLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    else
        BtnAutoFruit.BackgroundColor3 = Color3.fromRGB(60, 40, 20)
        BtnAutoFruit.Text = "  🍎 Comprar Frutas (Monedas)"
        FruitLogLabel.Text = "  Detenido"
    end
end)

BtnStopFruit.MouseButton1Click:Connect(function()
    AutoFruitBuying = false
    BtnAutoFruit.BackgroundColor3 = Color3.fromRGB(60, 40, 20)
    BtnAutoFruit.Text = "  🍎 Comprar Frutas (Monedas)"
    FruitLogLabel.Text = "  Detenido"
    FruitLogLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
end)

-- =======================================================================================
-- ========== TAB 4: RADAR FORENSE DE BATALLA (BOSS ESP & AOE) ==========
-- =======================================================================================
local CalibPage = MakeScrollPage("Calibrar")

SectionLabel(CalibPage, "SISTEMA SMART COMBAT", 1)

local CalibStatus = Instance.new("TextLabel", CalibPage)
CalibStatus.Size = UDim2.new(0.95, 0, 0, 45)
CalibStatus.BackgroundTransparency = 1
CalibStatus.TextColor3 = C.muted
CalibStatus.Font = Enum.Font.GothamMedium
CalibStatus.TextSize = 11
CalibStatus.Text = "  Usa tus ataques al hacer click. El bot medirá cuántos studs bajan hacia los pies del enemigo para ajustar tu Hit & Run dinámico."
CalibStatus.TextXAlignment = Enum.TextXAlignment.Left
CalibStatus.TextWrapped = true
CalibStatus.LayoutOrder = 2

SmartCalib_Sword = 3
SmartCalib_Fruit = 8
SmartSwordName = nil
SmartFruitName = nil
local CurrentlyCalibrating = "None"
SmartCombatEnabled = false
SmartUseFruit = false

local BtnSmartHitRun = ToggleButton(CalibPage, "🧠 Activar Smart Farm (Hit & Run)", 3, C.card)
BtnSmartHitRun.MouseButton1Click:Connect(function()
    SmartCombatEnabled = not SmartCombatEnabled
    if SmartCombatEnabled then
        BtnSmartHitRun.BackgroundColor3 = C.accentOn
        BtnSmartHitRun.Text = "  🧠 Smart Farm: ON"
        BtnSmartHitRun.TextColor3 = Color3.new(1,1,1)
    else
        BtnSmartHitRun.BackgroundColor3 = C.card
        BtnSmartHitRun.Text = "  🧠 Activar Smart Farm (Hit & Run)"
        BtnSmartHitRun.TextColor3 = C.text
    end
end)

local BtnUseFruit = ToggleButton(CalibPage, "🍎 Usar Fruta en Farm: NO (Solo Espada)", 3, C.card)
BtnUseFruit.MouseButton1Click:Connect(function()
    SmartUseFruit = not SmartUseFruit
    if SmartUseFruit then
        BtnUseFruit.BackgroundColor3 = Color3.fromRGB(100, 30, 150)
        BtnUseFruit.Text = "  🍎 Usar Fruta en Farm: SÍ (Rotando Espada + Fruta)"
        BtnUseFruit.TextColor3 = Color3.new(1,1,1)
    else
        BtnUseFruit.BackgroundColor3 = C.card
        BtnUseFruit.Text = "  🍎 Usar Fruta en Farm: NO (Solo Espada)"
        BtnUseFruit.TextColor3 = C.text
    end
end)

local BtnCalibSword = ToggleButton(CalibPage, "⚔️ Calibrar Rango de Espada [Actual: -" .. SmartCalib_Sword .. "]", 4, C.card)
local BtnCalibFruit = ToggleButton(CalibPage, "🍎 Calibrar Rango de Fruta [Actual: -" .. SmartCalib_Fruit .. "]", 5, C.card)

BtnCalibSword.MouseButton1Click:Connect(function()
    CurrentlyCalibrating = "Sword"
    BtnCalibSword.Text = "  Esperando ataque de ESPADA en vivo..."
    BtnCalibSword.BackgroundColor3 = Color3.fromRGB(150, 100, 30)
end)

BtnCalibFruit.MouseButton1Click:Connect(function()
    CurrentlyCalibrating = "Fruit"
    BtnCalibFruit.Text = "  Esperando ataque de FRUTA en vivo..."
    BtnCalibFruit.BackgroundColor3 = Color3.fromRGB(100, 30, 150)
end)

-- Motor silencioso de Calibración
task.spawn(function()
    Workspace.DescendantAdded:Connect(function(obj)
        if CurrentlyCalibrating ~= "None" then
            task.delay(0.05, function()
                if obj:IsA("BasePart") then
                    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end
                    
                    if obj:IsDescendantOf(LP.Character) or (obj.Position - hrp.Position).Magnitude < 10 then
                        local size = obj.Size
                        local maxD = math.max(size.X, size.Y, size.Z)
                        
                        if maxD >= 1 then
                            local charY = hrp.Position.Y
                            local objY = obj.Position.Y
                            local botY = objY - (size.Y/2)
                            local distAbajo = math.floor(charY - botY)
                            
                            -- Mínimo de 3 para asegurar colisión con pies aunque el vfx estalle arriba
                            if distAbajo < 3 then distAbajo = 3 end
                            
                            local equippedTool = LP.Character:FindFirstChildOfClass("Tool")
                            
                            if CurrentlyCalibrating == "Sword" then
                                SmartCalib_Sword = distAbajo
                                if equippedTool then SmartSwordName = equippedTool.Name end
                                BtnCalibSword.Text = "  ⚔️ Calibrado ESPADA: -" .. distAbajo .. " studs"
                                BtnCalibSword.BackgroundColor3 = Color3.fromRGB(30, 150, 80)
                            elseif CurrentlyCalibrating == "Fruit" then
                                SmartCalib_Fruit = distAbajo
                                if equippedTool then SmartFruitName = equippedTool.Name end
                                BtnCalibFruit.Text = "  🍎 Calibrado FRUTA: -" .. distAbajo .. " studs"
                                BtnCalibFruit.BackgroundColor3 = Color3.fromRGB(30, 150, 80)
                            end
                            CurrentlyCalibrating = "None"
                        end
                    end
                end
            end)
        end
    end)
end)


-- =======================================================================================
-- ========== VARIABLES COMPATIBILIDAD EXTERNA ==========
-- =======================================================================================
local function AddLog(text, color) end
local TScroll = Instance.new("ScrollingFrame")

-- ========== HOTKEY: Tecla * para Toggle GUI, K para Toggle Farm ==========
-- (La conexión de K se registra más abajo, después de definir ToggleAutoFarm)

-- ==============================================================================
-- PESTAÑA DE CÓDIGOS (NUEVA UI)
-- ==============================================================================
local CodesFrame = Instance.new("Frame", SG)
CodesFrame.Size = UDim2.new(0, 300, 0, 350)
CodesFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
CodesFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
CodesFrame.BorderSizePixel = 2
CodesFrame.BorderColor3 = Color3.fromRGB(0, 200, 255)
CodesFrame.Active = true
CodesFrame.Draggable = true
CodesFrame.Visible = false

local CodesTitle = Instance.new("TextLabel", CodesFrame)
CodesTitle.Size = UDim2.new(1, 0, 0, 30)
CodesTitle.BackgroundColor3 = Color3.fromRGB(10, 40, 60)
CodesTitle.Text = " 💎 CÓDIGOS DESCUBIERTOS"
CodesTitle.TextColor3 = Color3.fromRGB(150, 200, 255)
CodesTitle.Font = Enum.Font.GothamBold
CodesTitle.TextSize = 14

local CodeBackBtn = Instance.new("TextButton", CodesFrame)
CodeBackBtn.Size = UDim2.new(0.4, 0, 0, 25)
CodeBackBtn.Position = UDim2.new(0.05, 0, 0, 315)
CodeBackBtn.BackgroundColor3 = Color3.fromRGB(100, 20, 30)
CodeBackBtn.TextColor3 = Color3.new(1, 1, 1)
CodeBackBtn.Font = Enum.Font.Gotham
CodeBackBtn.TextSize = 12
CodeBackBtn.Text = "Cerrar"

local CopyAllBtn = Instance.new("TextButton", CodesFrame)
CopyAllBtn.Size = UDim2.new(0.4, 0, 0, 25)
CopyAllBtn.Position = UDim2.new(0.55, 0, 0, 315)
CopyAllBtn.BackgroundColor3 = Color3.fromRGB(20, 100, 40)
CopyAllBtn.TextColor3 = Color3.new(1, 1, 1)
CopyAllBtn.Font = Enum.Font.Gotham
CopyAllBtn.TextSize = 11
CopyAllBtn.Text = "Copiar Todos"

local CodesScroll = Instance.new("ScrollingFrame", CodesFrame)
CodesScroll.Size = UDim2.new(1, 0, 0, 275)
CodesScroll.Position = UDim2.new(0, 0, 0, 35)
CodesScroll.BackgroundTransparency = 1
CodesScroll.ScrollBarThickness = 4
CodesScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
local CodesList = Instance.new("UIListLayout", CodesScroll)

local AllCodesString_Global = ""
CopyAllBtn.MouseButton1Click:Connect(function()
    if setclipboard and AllCodesString_Global ~= "" then
        setclipboard(AllCodesString_Global)
        CopyAllBtn.Text = "Completado!"
        task.wait(1.5)
        CopyAllBtn.Text = "Copiar Todos"
    end
end)

BtnCodes.MouseButton1Click:Connect(function()
    MF.Visible = false
    CodesFrame.Visible = true

    for _, child in pairs(CodesScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local ok, conf = pcall(function() return require(ReplicatedStorage:WaitForChild("CodesConfig", 2)) end)
    local allCodesStr = ""
    if ok and conf and conf.Codes then
        local num = 0
        for codeName, data in pairs(conf.Codes) do
            num = num + 1
            allCodesStr = allCodesStr .. codeName .. "\n"

            local cFrame = Instance.new("Frame", CodesScroll)
            cFrame.Size = UDim2.new(1, 0, 0, 35)
            cFrame.BackgroundTransparency = 1

            local cLabel = Instance.new("TextLabel", cFrame)
            cLabel.Size = UDim2.new(0.7, 0, 1, 0)
            cLabel.BackgroundTransparency = 1
            cLabel.Text = " " .. codeName
            cLabel.TextColor3 = Color3.new(1, 1, 1)
            cLabel.Font = Enum.Font.Code
            cLabel.TextSize = 12
            cLabel.TextXAlignment = Enum.TextXAlignment.Left

            local cCopy = Instance.new("TextButton", cFrame)
            cCopy.Size = UDim2.new(0.25, 0, 0.7, 0)
            cCopy.Position = UDim2.new(0.7, 0, 0.15, 0)
            cCopy.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            cCopy.TextColor3 = Color3.new(1, 1, 1)
            cCopy.Font = Enum.Font.Gotham
            cCopy.TextSize = 11
            cCopy.Text = "Copiar"

            cCopy.MouseButton1Click:Connect(function()
                if setclipboard then
                    setclipboard(codeName)
                    cCopy.Text = "Copiado!"
                    task.wait(1)
                    cCopy.Text = "Copiar"
                end
            end)
        end
        CodesScroll.CanvasSize = UDim2.new(0, 0, 0, num * 35)
        AllCodesString_Global = allCodesStr
    else
        local err = Instance.new("TextLabel", CodesScroll)
        err.Size = UDim2.new(1, 0, 0, 50)
        err.BackgroundTransparency = 1
        err.TextColor3 = Color3.new(1, 0, 0)
        err.Text = "No se pudieron obtener los códigos."
    end
end)

CodeBackBtn.MouseButton1Click:Connect(function()
    CodesFrame.Visible = false
    MF.Visible = true
end)

-- ==============================================================================
-- LOGICA DEL AUTO FARM (Aura Kill + Vuelo hacia el mob)
-- ==============================================================================


local TargetMobsCache = {}
local LastCacheTime = 0

local function GetMobCache()
    if os.clock() - LastCacheTime > 2.5 then
        LastCacheTime = os.clock()
        local folders = {}
        if NPCsFolder then table.insert(folders, NPCsFolder) end
        pcall(function()
            for _, child in pairs(Workspace:GetChildren()) do
                if child:IsA("Folder") or child:IsA("Model") then
                    local n = child.Name:lower()
                    if n:match("mob") or n:match("enem") or n:match("monster") or n:match("living") or n:match("spawn") or n:match("boss") then
                        if child ~= NPCsFolder then
                            table.insert(folders, child)
                        end
                    end
                end
            end
        end)

        local newCache = {}
        for _, folder in pairs(folders) do
            pcall(function()
                for _, mob in pairs(folder:GetDescendants()) do
                    if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
                        if not mob.Name:lower():match("dummy") and not mob.Name:lower():match("npc") and not mob:FindFirstChildOfClass("ProximityPrompt", true) then
                            table.insert(newCache, mob)
                        end
                    end
                end
            end)
        end
        TargetMobsCache = newCache
    end
    return TargetMobsCache
end

local function GetNearestMob()
    local nearestDist = math.huge
    local nearestMob = nil
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = char.HumanoidRootPart

    local cache = GetMobCache()
    for _, mob in ipairs(cache) do
        local allow = false
        local isBoss = mob.Name:lower():match("boss")

        if ScannedTargetName then
            if mob.Name == ScannedTargetName then allow = true end
        else
            if TargetBosses == "SoloBoss" then
                if isBoss then allow = true end
            elseif TargetBosses == "Ignorar" then
                if not isBoss then allow = true end
            else
                allow = true
            end
        end

        if allow and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            local tHrp = mob:FindFirstChild("HumanoidRootPart")
            if tHrp then
                local dist = (hrp.Position - tHrp.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearestMob = mob
                end
            end
        end
    end
    return nearestMob
end

-- Anti Caídas y NoClip: Para volar libremente y atravesar paredes
RunService.Stepped:Connect(function()
    if (AutoFarm or IsWalkingToMemory) and LP.Character then
        -- 1. Noclip: Apagar CanCollide para atravesar todo
        for _, part in pairs(LP.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end

        -- 2. Anti Gravedad solo en AutoFarm (no durante caminata)
        if AutoFarm and not IsWalkingToMemory then
            local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

-- Motor de ataque y persecución
task.spawn(function()
    local LastMobTracker = nil
    local CurrentMobHealth = -1
    local MobHitTimer = os.clock()

    while task.wait() do
        if AutoFarm then
            local char = LP.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                -- Check si el jugador murió para reiniciar
                if char.Humanoid.Health <= 0 then
                    StatusLabel.Text = "Status: Reviviendo..."
                    GlobalMagnetTarget = nil
                    ForceMemoryReturn = true
                    task.wait(2)
                else
                    -- Funciliaridad Helper para Smart Weapon
                local function GetSmartTool(reqType)
                    -- Prioridad Cero: Nombres Exactos Calibrados
                    if reqType == "Sword" and SmartSwordName then
                        local t = char:FindFirstChild(SmartSwordName) or LP.Backpack:FindFirstChild(SmartSwordName)
                        if t then return t end
                    end
                    if reqType == "Fruit" and SmartFruitName then
                        local t = char:FindFirstChild(SmartFruitName) or LP.Backpack:FindFirstChild(SmartFruitName)
                        if t then return t end
                    end

                    local function isForbidden(t)
                        if reqType == "Sword" and SmartFruitName and t.Name == SmartFruitName then return true end
                        if reqType == "Fruit" and SmartSwordName and t.Name == SmartSwordName then return true end
                        if t.Name:lower():match("combat") then return true end
                        return false
                    end

                    -- Primer intento: Nombres comunes (fallback estándar)
                    local function strictMatch(t)
                        if isForbidden(t) then return false end
                        local n = t.Name:lower()
                        if reqType == "Sword" and (n:match("katana") or n:match("sword") or n:match("blade")) then return true end
                        if reqType == "Fruit" and (n:match("fruit") or n:match("devil")) then return true end
                        return false
                    end

                    for _, t in pairs(char:GetChildren()) do if t:IsA("Tool") and strictMatch(t) then return t end end
                    for _, t in pairs(LP.Backpack:GetChildren()) do if t:IsA("Tool") and strictMatch(t) then return t end end
                    
                    -- Segundo Intento: Cualquier cosa que NO esté prohibida (último recurso)
                    for _, t in pairs(char:GetChildren()) do if t:IsA("Tool") and not isForbidden(t) then return t end end
                    for _, t in pairs(LP.Backpack:GetChildren()) do if t:IsA("Tool") and not isForbidden(t) then return t end end

                    return nil -- Si no hay literalmente nada seguro, mejor retornar nil para que el char no haga locuras.
                end

                local tool = char:FindFirstChildOfClass("Tool")
                if SmartCombatEnabled then
                    if not LastSmartSwap then LastSmartSwap = os.clock() end
                    if not SmartCurrentWeapon then SmartCurrentWeapon = "Sword" end
                    
                    -- Corrección al instante si el usuario apaga la fruta en medio de un ataque
                    if not SmartUseFruit and SmartCurrentWeapon == "Fruit" then
                        SmartCurrentWeapon = "Sword"
                        LastSmartSwap = os.clock()
                    end

                    -- Rotación Cada 4s solo si la fruta está permitida
                    if SmartUseFruit and os.clock() - LastSmartSwap > 4 then 
                        LastSmartSwap = os.clock()
                        SmartCurrentWeapon = (SmartCurrentWeapon == "Sword") and "Fruit" or "Sword"
                    end

                    local wTool = GetSmartTool(SmartCurrentWeapon)
                    if wTool then 
                        -- Si el arma asignada no está en la mano principal (no equipped)
                        if not char:FindFirstChild(wTool.Name) then
                            char.Humanoid:UnequipTools()
                            char.Humanoid:EquipTool(wTool) 
                        end
                        tool = wTool
                    end
                else
                    -- Normal Equip
                    if not tool then
                        for _, t in pairs(LP.Backpack:GetChildren()) do
                            if t:IsA("Tool") and (t.Name:lower():match("katana") or t.Name:lower():match("sword") or t.Name:lower():match("blade")) then
                                tool = t
                                break
                            end
                        end
                        if not tool then
                            for _, t in pairs(LP.Backpack:GetChildren()) do
                                if t:IsA("Tool") and not t.Name:lower():match("combat") then
                                    tool = t
                                    break
                                end
                            end
                        end
                        if not tool then tool = LP.Backpack:FindFirstChildOfClass("Tool") end
                        if tool then char.Humanoid:EquipTool(tool) end
                    end
                end

                local mob = GetNearestMob()

                -- ====== SISTEMA DE RETORNO A MEMORIA ======
                -- (Manejado en loop independiente más abajo)
                -- ====== FIN SISTEMA DE RETORNO ======

                if ForceMemoryReturn then
                     if MemoryPoint then
                         local d = (char.HumanoidRootPart.Position - MemoryPoint).Magnitude
                         if d <= 15 then 
                              ForceMemoryReturn = false
                         else
                              StatusLabel.Text = "🏃 Forzando retorno a Memoria..."
                              -- Saltar lógica de mob dejando que el AutoWalk nos mueva
                              mob = nil 
                         end
                     else
                         -- Si no hay MemoryPoint guardado, no podemos forzar retorno. Apágalo.
                         ForceMemoryReturn = false
                     end
                end

                if mob and not ForceMemoryReturn then
                    -- ==============================================
                    -- DETECTOR DE ATASCO DE DAÑO (Despertador Físico)
                    -- ==============================================
                    if not IsInPanicRecovery then
                        if LastMobTracker ~= mob then
                            LastMobTracker = mob
                            CurrentMobHealth = mob.Humanoid.Health
                            MobHitTimer = os.clock()
                            LastRealDamageTime = os.clock()

                            -- ARRANCADOR INMEDIATO: Primer Click Físico al atrapar un Nuevo Mob
                            pcall(function()
                                VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                                task.wait(0.05)
                                VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                            end)
                        else
                            if mob.Humanoid.Health < CurrentMobHealth then
                                -- Confirmamos que hubo daño real, reseteamos el reloj
                                CurrentMobHealth = mob.Humanoid.Health
                                MobHitTimer = os.clock()
                                LastRealDamageTime = os.clock()
                                IsWalkingToMemory = false
                            elseif os.clock() - MobHitTimer >= 5.0 then
                                -- Han pasado 5 Segundos SIN dañar al Mob. Forzamos un Click Físico en Pantalla
                                pcall(function()
                                    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                                    task.wait(0.05)
                                    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                                end)
                                MobHitTimer = os.clock() -- Refrescamos para intentar de nuevo
                            end
                        end
                    else
                        -- Si estamos en pánico, mantener el reloj fresco para que no tire click apenas bajemos
                        MobHitTimer = os.clock()
                    end

                    StatusLabel.Text = "Cazando: " .. mob.Name
                    local hrp = char.HumanoidRootPart
                    local mobHrp = mob:WaitForChild("HumanoidRootPart", 1)

                    if mobHrp then
                        GlobalMagnetTarget = mobHrp.Position

                        -- ==============================================
                        -- INTERCEPTOR: PROTOCOLO DE PÁNICO (HUÍDA Y CURA)
                        -- ==============================================
                        local hpRatio = char.Humanoid.Health / char.Humanoid.MaxHealth
                        if hpRatio <= PanicThreshold and char.Humanoid.Health > 0 and not IsInPanicRecovery then
                            IsInPanicRecovery = true
                            hrp:SetAttribute("PanicPos", hrp.Position)
                        elseif IsInPanicRecovery and hpRatio >= ReturnHealthThreshold then
                            IsInPanicRecovery = false -- Vuelve al combate
                            hrp:SetAttribute("PanicPos", nil)
                        end

                        if IsInPanicRecovery then
                            StatusLabel.Text = "Status: 🛡️ PÁNICO (CURANDO " .. math.floor(hpRatio * 100) .. "%)"

                            -- Guardamos ancla estática para no subir infinitamente ni seguir mobs
                            local savedPos = hrp:GetAttribute("PanicPos") or hrp.Position
                            local escapeCF = CFrame.new(savedPos) * CFrame.new(0, 50, 0)

                            pcall(function()
                                local d = (hrp.Position - escapeCF.Position).Magnitude
                                if d > 1 then
                                    local step = math.clamp(20 / d, 0, 1)
                                    char:PivotTo(hrp.CFrame:Lerp(escapeCF, step))
                                else
                                    char:PivotTo(escapeCF)
                                end
                            end)

                            -- Quita la cámara del Mob y la devuelve al personaje para frenar mareos visuales
                            pcall(function()
                                local cam = Workspace.CurrentCamera
                                if cam.CameraSubject ~= char:FindFirstChild("Humanoid") then
                                    cam.CameraSubject = char:FindFirstChild("Humanoid")
                                end
                            end)

                            task.wait(0.05)
                        else
                            -- ==============================================
                            -- Generar Lista de Multi-Targets (Para Juntar Mobs mediante IA Aggro)
                        local mobsToHit = {}
                        if MobMagnetEnabled then
                            local sorted = {}
                            local cache = GetMobCache()
                            for _, m in ipairs(cache) do
                                if m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 and m:FindFirstChild("HumanoidRootPart") then
                                    local isBoss = m.Name:lower():match("boss")
                                    local allow = false
                                    if ScannedTargetName then
                                        if m.Name == ScannedTargetName then allow = true end
                                    else
                                        if TargetBosses == "SoloBoss" then
                                            if isBoss then allow = true end
                                        elseif TargetBosses == "Ignorar" then
                                            if not isBoss then allow = true end
                                        else
                                            allow = true
                                        end
                                    end

                                    if allow then
                                        local dist = (hrp.Position - m.HumanoidRootPart.Position).Magnitude
                                        if dist < 150 then
                                            table.insert(sorted, { m, dist })
                                        end
                                    end
                                end
                            end
                            table.sort(sorted, function(a, b) return a[2] < b[2] end)
                            -- Agarra hasta a los 4 más cercanos
                            for i = 1, math.min(4, #sorted) do
                                table.insert(mobsToHit, sorted[i][1])
                            end
                        else
                            table.insert(mobsToHit, mob)
                        end

                        -- Ataque Dinámico / Multi-Golpe para Juntar
                        for _, targetMob in pairs(mobsToHit) do
                            local tHrp = targetMob:FindFirstChild("HumanoidRootPart")
                            if tHrp then
                                -- Calculamos una postura 100% erguida copiando EXACTAMENTE a dónde mira el monstruo.
                                -- Esto evita el bug "echado" de raíz sin corromper los ángulos X, Z.
                                local flatLookDir = Vector3.new(tHrp.CFrame.LookVector.X, 0, tHrp.CFrame.LookVector.Z)
                                if flatLookDir.Magnitude < 0.001 then flatLookDir = Vector3.new(1,0,0) end
                                flatLookDir = flatLookDir.Unit
                                local flatMobCFrame = CFrame.lookAt(tHrp.Position, tHrp.Position + flatLookDir)

                                local currentFarmMode = FarmMode
                                local TargetCF
                                
                                if SmartCombatEnabled then
                                    local currentOffset = (SmartCurrentWeapon == "Sword") and SmartCalib_Sword or SmartCalib_Fruit
                                    if currentFarmMode == "Arriba" then
                                        TargetCF = flatMobCFrame * CFrame.new(0, currentOffset + 2, 0)
                                    elseif currentFarmMode == "Detras" then
                                        TargetCF = flatMobCFrame * CFrame.new(0, 0, currentOffset + 2)
                                    else
                                        -- Abajo por defecto si usa otra cosa
                                        TargetCF = flatMobCFrame * CFrame.new(0, -(currentOffset + 2), 0)
                                    end
                                else
                                    if currentFarmMode == "Arriba" then
                                        TargetCF = flatMobCFrame * CFrame.new(0, OfsY, 0)
                                    elseif currentFarmMode == "Detras" then
                                        TargetCF = flatMobCFrame * CFrame.new(0, 0, OfsZ)
                                    elseif currentFarmMode == "Abajo" then
                                        TargetCF = flatMobCFrame * CFrame.new(0, OfsY, OfsZ)
                                    end
                                end

                                pcall(function()
                                    local rootCF = TargetCF
                                    if BlinkAttackEnabled then
                                        rootCF = TargetCF * CFrame.new(0, FarmMode == "Abajo" and 0 or 5, FarmMode == "Abajo" and -12 or 45) 
                                        -- Si está abajo queda enterrado pero movido atras/abajo. Si está arriba se empuja 45 studs atras
                                    end
                                    local flyDist = (hrp.Position - rootCF.Position).Magnitude
                                    if TargetBosses == "SoloBoss" and flyDist > 15 then
                                        -- FLY CLIP: Vuelo suave constante (aprox 100 studs/seg) para moverse largo sin teleports
                                        local flyStep = math.clamp(20 / flyDist, 0, 1)
                                        char:PivotTo(hrp.CFrame:Lerp(rootCF, flyStep))
                                    else
                                        -- Cerca o Modalidad Normal: Anchored Pivot
                                        char:PivotTo(rootCF)
                                    end
                                end)

                                pcall(function()
                                    local cam = Workspace.CurrentCamera
                                    if cam and cam.CameraSubject ~= targetMob:FindFirstChild("Humanoid") then
                                        cam.CameraSubject = targetMob:FindFirstChild("Humanoid") or tHrp
                                    end
                                end)

                                -- PREVENIR ATAQUE SI AUN ESTÁ EN VUELO LARGO:
                                local actualLoc = BlinkAttackEnabled and (TargetCF * CFrame.new(0, FarmMode == "Abajo" and 0 or 5, FarmMode == "Abajo" and -12 or 45)) or TargetCF
                                local distFinal = (hrp.Position - actualLoc.Position).Magnitude
                                if distFinal <= 20 then
                                    pcall(function()
                                        if BlinkAttackEnabled then
                                            -- Modifica CFrame Instantáneamente para el RequestHit (Blink Strike)
                                            char:PivotTo(TargetCF)
                                            CombatRemote:FireServer()
                                            if tool then tool:Activate() end
                                            char:PivotTo(actualLoc)
                                        else
                                            CombatRemote:FireServer()
                                            if tool then tool:Activate() end
                                        end
                                    end)

                                    -- Aimbot para Skills (ANTI-POP SUBTERRÁNEO)
                                    if AutoSkillEnabled then
                                        pcall(function()
                                            -- Calculamos rotación estrictamente horizontal (evita que el PJ mire hacia arriba y su cabeza traspase el piso)
                                            local flatAimPos = Vector3.new(tHrp.Position.X, hrp.Position.Y,
                                                tHrp.Position.Z)
                                            hrp.CFrame = CFrame.lookAt(hrp.Position, flatAimPos)

                                            VIM:SendKeyEvent(true, Enum.KeyCode.X, false, game)
                                            task.wait(0.01)
                                            VIM:SendKeyEvent(false, Enum.KeyCode.X, false, game)
                                        end)
                                    end
                                end

                                -- Una minúscula pausa entre saltos
                                task.wait(0.05)
                            end
                        end -- for targetMob
                    end -- else IsInPanicRecovery
                end -- if mobHrp
            else -- else for mob and not ForceMemoryReturn
                GlobalMagnetTarget = nil
                StatusLabel.Text = "Buscando Mobs vivos..."
            end -- if mob and not ForceMemoryReturn
        end -- if char.Humanoid.Health <= 0
    else -- else for char and char:FindFirstChild
        GlobalMagnetTarget = nil
        StatusLabel.Text = "Esperando al Personaje..."
    end -- if char and char:FindFirstChild
else -- else for AutoFarm
    GlobalMagnetTarget = nil
end -- if AutoFarm
end -- while task.wait()
end) -- task.spawn

-- ==============================================================================
-- CONEXIONES GUI
-- ==============================================================================
local function ToggleAutoFarm()
    AutoFarm = not AutoFarm
    if AutoFarm then
        BtnToggle.Text = "  ◼ Detener Auto-Farm"
        BtnToggle.BackgroundColor3 = C.accentOn
        StatusLabel.TextColor3 = C.accentOn
        StatusLabel.Text = "Status: Buscando objetivos..."
        LastRealDamageTime = os.clock()
        IsWalkingToMemory = false

        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:FindFirstChildOfClass("BodyVelocity") then
            hrp:FindFirstChildOfClass("BodyVelocity"):Destroy()
        end
    else
        BtnToggle.Text = "  ► Iniciar Auto-Farm"
        BtnToggle.BackgroundColor3 = C.red
        StatusLabel.TextColor3 = C.muted
        StatusLabel.Text = "Status: Inactivo"

        pcall(function()
            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                char:PivotTo(hrp.CFrame * CFrame.new(0, 15, 0))
            end
            if char and char:FindFirstChild("Humanoid") then
                Workspace.CurrentCamera.CameraSubject = char.Humanoid
            end
        end)
    end
end

BtnToggle.MouseButton1Click:Connect(ToggleAutoFarm)

uis.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.K then ToggleAutoFarm() end
    if input.KeyCode == Enum.KeyCode.M then
        local char = LP.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            MemoryPoint = char.HumanoidRootPart.Position
            IsWalkingToMemory = false
            MemStatusLabel.Text = "  📍 Punto: " ..
            math.floor(MemoryPoint.X) .. ", " .. math.floor(MemoryPoint.Y) .. ", " .. math.floor(MemoryPoint.Z)
            StatusLabel.Text = "📍 Punto guardado!"
            SaveConfig()
        end
    end
    if input.KeyCode == Enum.KeyCode.KeypadMultiply or input.KeyCode == Enum.KeyCode.Eight then
        if input.KeyCode == Enum.KeyCode.Eight and not uis:IsKeyDown(Enum.KeyCode.LeftShift) and not uis:IsKeyDown(Enum.KeyCode.RightShift) then return end
        MF.Visible = not MF.Visible
        if not MF.Visible then
            if CodesFrame then pcall(function() CodesFrame.Visible = false end) end
        end
    end
end)

BtnMagnet.MouseButton1Click:Connect(function()
    MobMagnetEnabled = not MobMagnetEnabled
    if MobMagnetEnabled then
        BtnMagnet.BackgroundColor3 = C.accentOn
        BtnMagnet.Text = "  🧲 Imán: ACTIVO"
    else
        BtnMagnet.BackgroundColor3 = C.card
        BtnMagnet.Text = "  🧲 Imán de Mobs"
    end
    SaveConfig()
end)

BtnSkill.MouseButton1Click:Connect(function()
    AutoSkillEnabled = not AutoSkillEnabled
    if AutoSkillEnabled then
        BtnSkill.BackgroundColor3 = C.accentOn
        BtnSkill.Text = "  🔥 Skill (X): ACTIVO"
    else
        BtnSkill.BackgroundColor3 = C.card
        BtnSkill.Text = "  🔥 Auto Skill (X)"
    end
    SaveConfig()
end)

BtnBoss.MouseButton1Click:Connect(function()
    if TargetBosses == "Normal" then
        TargetBosses = "Ignorar"
        BtnBoss.BackgroundColor3 = C.accentOff
        BtnBoss.Text = "  🛑 Ignorar Bosses"
    elseif TargetBosses == "Ignorar" then
        TargetBosses = "SoloBoss"
        BtnBoss.BackgroundColor3 = Color3.fromRGB(130, 80, 180)
        BtnBoss.Text = "  👹 Solo Boss"
    else
        TargetBosses = "Normal"
        BtnBoss.BackgroundColor3 = C.card
        BtnBoss.Text = "  🎯 Cazar Bosses: Normal"
    end
    SaveConfig()
end)

-- ==============================================================================
-- CONEXIONES DE INTERFAZ RECONSTRUIDAS (ALTURA Y DEFENSA)
-- ==============================================================================
local uis_local = game:GetService("UserInputService")

BtnBlink.MouseButton1Click:Connect(function()
    BlinkAttackEnabled = not BlinkAttackEnabled
    if BlinkAttackEnabled then
        BtnBlink.Text = "  ⚡ Blink Fx (Sniper 45s): ON"
        BtnBlink.BackgroundColor3 = C.accentOn
        BtnBlink.TextColor3 = Color3.new(1,1,1)
    else
        BtnBlink.Text = "  ⚡ Blink Fx (Sniper 45s): OFF"
        BtnBlink.BackgroundColor3 = C.card
        BtnBlink.TextColor3 = C.text
    end
    SaveConfig()
end)

BtnHeight.MouseButton1Click:Connect(function()
    if FarmMode == "Arriba" then
        FarmMode = "Abajo"
        OfsY = -8; OfsZ = 6
        BtnHeight.Text = "  Posición: 🕳️ Subterráneo"
    else
        FarmMode = "Arriba"
        OfsY = 10; OfsZ = 0
        BtnHeight.Text = "  Posición: ☁️ Arriba"
    end
    SaveConfig()
end)

local isDraggingPanic = false
SliderBg.MouseButton1Down:Connect(function() isDraggingPanic = true end)
uis_local.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then isDraggingPanic = false end end)
uis_local.InputChanged:Connect(function(input)
    if isDraggingPanic and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = uis_local:GetMouseLocation().X
        local framePos = SliderBg.AbsolutePosition.X
        local frameSize = SliderBg.AbsoluteSize.X
        local rel = math.clamp((mousePos - framePos) / frameSize, 0.01, 1)
        PanicThreshold = rel
        SliderFill.Size = UDim2.new(rel, 0, 1, 0)
        PanicLabel.Text = "  🛡️ Escudo Pánico — Escapa al " .. math.floor(rel * 100) .. "%"
        SaveConfig()
    end
end)

local isDraggingReturn = false
ReturnSliderBg.MouseButton1Down:Connect(function() isDraggingReturn = true end)
uis_local.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then isDraggingReturn = false end end)
uis_local.InputChanged:Connect(function(input)
    if isDraggingReturn and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = uis_local:GetMouseLocation().X
        local framePos = ReturnSliderBg.AbsolutePosition.X
        local frameSize = ReturnSliderBg.AbsoluteSize.X
        local rel = math.clamp((mousePos - framePos) / frameSize, 0.01, 1)
        ReturnHealthThreshold = rel
        ReturnSliderFill.Size = UDim2.new(rel, 0, 1, 0)
        ReturnHealthLabel.Text = "  💚 Vida para Volver — " .. math.floor(rel * 100) .. "%"
        SaveConfig()
    end
end)

BtnClearMem.MouseButton1Click:Connect(function()
    MemoryPoint = nil
    IsWalkingToMemory = false
    MemStatusLabel.Text = "  📍 Sin punto guardado"
    BtnClearMem.BackgroundColor3 = C.card
    BtnClearMem.Text = "  ✅ Punto borrado"
    SaveConfig()
    task.delay(1.5, function()
        BtnClearMem.BackgroundColor3 = C.red
        BtnClearMem.Text = "  🗑️ Borrar Punto Guardado"
    end)
end)

BtnMin.MouseButton1Click:Connect(function()
    MF.Visible = false
    if CodesFrame then pcall(function() CodesFrame.Visible = false end) end
end)

BtnFloat.MouseButton1Click:Connect(function()
    MF.Visible = not MF.Visible
    if not MF.Visible and CodesFrame then pcall(function() CodesFrame.Visible = false end) end
end)

local function LoadConfig()
    if readfile then
        local success, raw = pcall(function() return readfile("OmniAutoFarmConfig.json") end)
        if success and raw then
            pcall(function()
                local data = game:GetService("HttpService"):JSONDecode(raw)
                if type(data) == "table" then
                    if data.ScannedTargetName ~= nil then ScannedTargetName = data.ScannedTargetName end
                    if data.ScannedTargetPos ~= nil then ScannedTargetPos = Vector3.new(data.ScannedTargetPos.X,
                            data.ScannedTargetPos.Y, data.ScannedTargetPos.Z) end
                    if data.PanicThreshold ~= nil then PanicThreshold = data.PanicThreshold end
                    if data.ReturnHealthThreshold ~= nil then ReturnHealthThreshold = data.ReturnHealthThreshold end
                    if data.MobMagnetEnabled ~= nil then MobMagnetEnabled = data.MobMagnetEnabled end
                    if data.AutoSkillEnabled ~= nil then AutoSkillEnabled = data.AutoSkillEnabled end
                    if data.TargetBosses ~= nil then TargetBosses = data.TargetBosses end
                    if data.FarmMode ~= nil then FarmMode = data.FarmMode end
                    if data.BlinkAttackEnabled ~= nil then BlinkAttackEnabled = data.BlinkAttackEnabled end
                    if data.MemoryPoint ~= nil then
                        MemoryPoint = Vector3.new(data.MemoryPoint.X, data.MemoryPoint.Y, data.MemoryPoint.Z)
                        MemStatusLabel.Text = "  📍 Punto: " ..
                        math.floor(MemoryPoint.X) ..
                        ", " .. math.floor(MemoryPoint.Y) .. ", " .. math.floor(MemoryPoint.Z)
                    end

                    if FarmMode == "Abajo" then
                        OfsY = -8; OfsZ = 6; BtnHeight.Text = "  Posición: 🕳️ Subterráneo"
                    else
                        OfsY = 10; OfsZ = 0; BtnHeight.Text = "  Posición: ☁️ Arriba"
                    end
                    if MobMagnetEnabled then
                        BtnMagnet.BackgroundColor3 = C.accentOn; BtnMagnet.Text = "  🧲 Imán: ACTIVO"
                    end
                    if AutoSkillEnabled then
                        BtnSkill.BackgroundColor3 = C.accentOn; BtnSkill.Text = "  🔥 Auto Skill (X): ACTIVO"
                    end
                    if TargetBosses == "SoloBoss" then
                        BtnBoss.BackgroundColor3 = Color3.fromRGB(130, 80, 180); BtnBoss.Text = "  👹 Solo Boss"
                    elseif TargetBosses == "Ignorar" then
                        BtnBoss.BackgroundColor3 = C.accentOff; BtnBoss.Text = "  🙈 Ignorar Bosses"
                    end

                    PanicLabel.Text = "  🛡️ Escudo Pánico — Escapa al " .. math.floor(PanicThreshold * 100) .. "%"
                    SliderFill.Size = UDim2.new(math.clamp(PanicThreshold, 0.01, 1), 0, 1, 0)
                    ReturnHealthLabel.Text = "  💚 Vida para Volver — " .. math.floor(ReturnHealthThreshold * 100) .. "%"
                    ReturnSliderFill.Size = UDim2.new(math.clamp(ReturnHealthThreshold, 0.01, 1), 0, 1, 0)
                end
            end)
        end
    end
end

-- ==============================================================================
-- SISTEMA DE CAMINATA A MEMORIA (INDEPENDIENTE)
-- Funciona SIEMPRE que haya MemoryPoint
-- ==============================================================================
task.spawn(function()
    while true do
        task.wait(0.1)

        local char = LP.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            if MemoryPoint and not IsInPanicRecovery then
            local mob = GetNearestMob()
            
            if ForceMemoryReturn then
                mob = nil -- Finge que no hay mobs para forzar el retorno
            end

            if mob then
                if IsWalkingToMemory then
                    IsWalkingToMemory = false
                    LastRealDamageTime = os.clock()
                end
            else
                if os.clock() - LastRealDamageTime > 10 then
                    IsWalkingToMemory = true
                end
            end

            if IsWalkingToMemory and not mob then
                local hrpW = char.HumanoidRootPart
                local distToMem = (hrpW.Position - MemoryPoint).Magnitude

                if distToMem <= 15 then
                    IsWalkingToMemory = false
                    StatusLabel.Text = "📍 Llegamos al punto guardado"
                    LastRealDamageTime = os.clock()
                else
                    StatusLabel.Text = "🏃 Volviendo a Marca... (" .. math.floor(distToMem) .. "m)"

                    local dir = (MemoryPoint - hrpW.Position).Unit
                    -- Pasos grandes configurables (Movimiento tipo Blink/Sniper)
                    local stepSize = math.min(BlinkStepValue or 45, distToMem) 
                    local nextPos = hrpW.Position + dir * stepSize
                    
                    -- Teletransportación forzada por tramos (Super Carga Rápida sin Kicks)
                    pcall(function() char:PivotTo(CFrame.new(nextPos)) end)
                    
                    pcall(function()
                        if hrpW:FindFirstChildOfClass("BodyVelocity") then
                             hrpW:FindFirstChildOfClass("BodyVelocity").Velocity = Vector3.new(0, 0, 0)
                        end
                    end)
                end
            end
        else
                if IsWalkingToMemory then
                    IsWalkingToMemory = false
                end
            end
        end
    end
end)

task.spawn(LoadConfig)




