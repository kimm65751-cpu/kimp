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
local ScannedTargetNames = {} -- tabla para multi-selección de objetivos
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
local GhostProtocolEnabled = false
local GhostBlocksDisabled = 0
local VIM = game:GetService("VirtualInputManager")
local BlinkStepValue = 45  -- Studs por paso en vuelo (default, ajustable en UI)
local ArenaAnchor = nil
local ArenaRadius = 25
local ArenaStatusLabel = nil

-- Smart Combat (definidos aqui para que SaveConfig no crashee si se llama temprano)
local SmartCombatEnabled = false
local SmartUseSword = true
local SmartUseFruit = false
local SmartUseMelee = false
local SmartCurrentWeapon = "Melee"
local LastSmartSwap = nil
local SmartCalib_Sword_Y = 3
local SmartCalib_Sword_Z = 4
local SmartCalib_Fruit_Y = 8
local SmartCalib_Fruit_Z = 10
local SmartCalib_Melee_Y = 3
local SmartCalib_Melee_Z = 4
local SmartSwordName = nil
local SmartFruitName = nil
local SmartMeleeName = nil

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
            PanicThreshold = PanicThreshold,
            ReturnHealthThreshold = ReturnHealthThreshold,
            MobMagnetEnabled = MobMagnetEnabled,
            AutoSkillEnabled = AutoSkillEnabled,
            TargetBosses = TargetBosses,
            FarmMode = FarmMode,
            BlinkAttackEnabled = BlinkAttackEnabled,
            SmartCombatEnabled = SmartCombatEnabled,
            SmartUseSword = SmartUseSword,
            SmartUseFruit = SmartUseFruit,
            SmartUseMelee = SmartUseMelee,
            SmartCalib_Sword_Y = SmartCalib_Sword_Y,
            SmartCalib_Sword_Z = SmartCalib_Sword_Z,
            SmartCalib_Fruit_Y = SmartCalib_Fruit_Y,
            SmartCalib_Fruit_Z = SmartCalib_Fruit_Z,
            SmartCalib_Melee_Y = SmartCalib_Melee_Y,
            SmartCalib_Melee_Z = SmartCalib_Melee_Z,
            SmartSwordName = SmartSwordName,
            SmartFruitName = SmartFruitName,
            SmartMeleeName = SmartMeleeName,
            AutoSkillKeys = _G.AutoSkillKeys
        }
        pcall(function()
            -- MemoryPoint es Vector3, no serializable directo — guardar como tabla
            local memData = nil
            if MemoryPoint then
                memData = { X = MemoryPoint.X, Y = MemoryPoint.Y, Z = MemoryPoint.Z }
            end
            data.MemoryPoint = memData
            writefile("OmniAutoFarmConfig.json", game:GetService("HttpService"):JSONEncode(data))
        end)
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

local TabFarm                                       = MakeTabBtn("⚔️", "Farm", 1)
local TabMem                                        = MakeTabBtn("📍", "Memoria", 2)
local TabExtras                                     = MakeTabBtn("🍎", "Extras", 3)
local TabCalib                                      = MakeTabBtn("🎯", "Calibrar", 4)
local TabCazador                                    = MakeTabBtn("👁️", "Cazador", 5)
local TabAnalista                                   = MakeTabBtn("🔎", "Analizador", 6)
local TabInjector                                   = MakeTabBtn("💉", "Inyector", 7)

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
TabCazador.MouseButton1Click:Connect(function() SwitchTab("Cazador") end)
TabAnalista.MouseButton1Click:Connect(function() SwitchTab("Analizador") end)
TabInjector.MouseButton1Click:Connect(function() SwitchTab("Inyector") end)

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
local BtnSkill     = ToggleButton(FarmPage, "🔥 Auto Skill (Teclas)", 5)
_G.AutoSkillKeys = {"Z", "X", "C", "V"}
local SkillKeysBox = Instance.new("TextBox", FarmPage)
SkillKeysBox.Size = UDim2.new(0.95, 0, 0, 32)
SkillKeysBox.BackgroundColor3 = C.bg
SkillKeysBox.TextColor3 = C.text
SkillKeysBox.PlaceholderText = "Escribe teclas (Ej: Z, X, C)"
SkillKeysBox.Text = "Z, X, C, V"
SkillKeysBox.Font = Enum.Font.Gotham
SkillKeysBox.TextSize = 12
SkillKeysBox.LayoutOrder = 5.5
Instance.new("UICorner", SkillKeysBox).CornerRadius = UDim.new(0, 4)

SkillKeysBox.FocusLost:Connect(function()
    _G.AutoSkillKeys = {}
    for letter in SkillKeysBox.Text:gmatch("%a") do
        table.insert(_G.AutoSkillKeys, letter:upper())
    end
    if #_G.AutoSkillKeys == 0 then
        SkillKeysBox.Text = "Z, X, C, V"
        _G.AutoSkillKeys = {"Z", "X", "C", "V"}
    else
        SkillKeysBox.Text = table.concat(_G.AutoSkillKeys, ", ")
    end
    if AutoSkillEnabled then
        BtnSkill.Text = "  🔥 Skills: ON (" .. SkillKeysBox.Text .. ")"
    end
    SaveConfig()
end)
local BtnBoss      = ToggleButton(FarmPage, "🎯 Cazar Bosses: Normal", 6)
local BtnBlink     = ToggleButton(FarmPage, "⚡ Blink Fx (Sniper 45 studs)", 7, C.card)
local BtnGhost     = ToggleButton(FarmPage, "👻 Ghost Protocol (Mazmorra): OFF", 8, C.card)
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
"  [M] Guardar punto (caminata).\n  [P] Marcar ANCLA ARENA (Dungeons).\n  El Ancla te atrapa a 25 studs y no te deja salir."
MemInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
MemInfoLabel.TextWrapped = true
MemInfoLabel.LayoutOrder = 3

ArenaStatusLabel = Instance.new("TextLabel", MemPage)
ArenaStatusLabel.Size = UDim2.new(0.95, 0, 0, 22)
ArenaStatusLabel.BackgroundTransparency = 1
ArenaStatusLabel.TextColor3 = Color3.fromRGB(200, 150, 255)
ArenaStatusLabel.Font = Enum.Font.GothamMedium
ArenaStatusLabel.TextSize = 12
ArenaStatusLabel.Text = "  ⭕ Ancla Arena: OFF (Presiona P)"
ArenaStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
ArenaStatusLabel.LayoutOrder = 4

local BtnClearMem = ToggleButton(MemPage, "🗑️ Borrar Punto Guardado", 5, C.red)
BtnClearMem.MouseButton1Click:Connect(function()
    MemoryPoint = nil
    IsWalkingToMemory = false
    MemStatusLabel.Text = "  📍 Sin punto guardado"
    BtnClearMem.BackgroundColor3 = C.card
    BtnClearMem.Text = "  ✅ Punto borrado"
    
    -- También limpiamos el ancla de combate por si acaso
    ArenaAnchor = nil
    if ArenaStatusLabel then ArenaStatusLabel.Text = "  ⭕ Ancla Arena: OFF (Presiona P)" end

    SaveConfig()
    task.delay(1.5, function()
        BtnClearMem.BackgroundColor3 = C.red
        BtnClearMem.Text = "  🗑️ Borrar Punto Guardado"
    end)
end)

-- BlinkStepValue ya inicializado al tope del script (= 45 por defecto)
local blinkOptions = { 45, 25, 15, 5 }
local currentBlinkIdx = 1

local BtnBlinkSpeed = ToggleButton(MemPage, "⚡ Velocidad de Regreso: 45 Studs", 6, C.card)
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
        if AutoFruitBuying then
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
        end -- if AutoFruitBuying
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
CalibStatus.Text =
"  Usa tus ataques al hacer click. El bot medirá cuántos studs bajan hacia los pies del enemigo para ajustar tu Hit & Run dinámico."
CalibStatus.TextXAlignment = Enum.TextXAlignment.Left
CalibStatus.TextWrapped = true
CalibStatus.LayoutOrder = 2

SmartCalib_Sword_Y = SmartCalib_Sword_Y or 3
SmartCalib_Sword_Z = SmartCalib_Sword_Z or 4
SmartCalib_Fruit_Y = SmartCalib_Fruit_Y or 8
SmartCalib_Fruit_Z = SmartCalib_Fruit_Z or 10
SmartCalib_Melee_Y = SmartCalib_Melee_Y or 3
SmartCalib_Melee_Z = SmartCalib_Melee_Z or 4
SmartSwordName = SmartSwordName or nil
SmartFruitName = SmartFruitName or nil
SmartMeleeName = SmartMeleeName or nil
local CurrentlyCalibrating = "None"
local CalibrationEndTime = 0
local TempCalibMaxY = 3
local TempCalibMaxZ = 4

SmartCombatEnabled = SmartCombatEnabled or false
SmartUseSword = SmartUseSword == nil and true or SmartUseSword
SmartUseFruit = SmartUseFruit or false
SmartUseMelee = SmartUseMelee or false

local BtnSmartHitRun = ToggleButton(CalibPage, "🧠 Activar Smart Farm (Hit & Run)", 3, C.card)
BtnSmartHitRun.MouseButton1Click:Connect(function()
    SmartCombatEnabled = not SmartCombatEnabled
    if SmartCombatEnabled then
        BtnSmartHitRun.BackgroundColor3 = C.accentOn
        BtnSmartHitRun.Text = "  🧠 Smart Farm: ON"
        BtnSmartHitRun.TextColor3 = Color3.new(1, 1, 1)
    else
        BtnSmartHitRun.BackgroundColor3 = C.card
        BtnSmartHitRun.Text = "  🧠 Activar Smart Farm (Hit & Run)"
        BtnSmartHitRun.TextColor3 = C.text
    end
end)

local WeaponSelectFrame = Instance.new("Frame", CalibPage)
WeaponSelectFrame.Size = UDim2.new(0.95, 0, 0, 115)
WeaponSelectFrame.BackgroundTransparency = 1
WeaponSelectFrame.LayoutOrder = 3.5

local uiList = Instance.new("UIListLayout", WeaponSelectFrame)
uiList.Padding = UDim.new(0, 4)
uiList.SortOrder = Enum.SortOrder.LayoutOrder

local BtnUseMelee = ToggleButton(WeaponSelectFrame, "👊 Rotar Combate (Melee): " .. (SmartUseMelee and "SÍ" or "NO"), 1, SmartUseMelee and C.accentOn or C.card)
local BtnUseSword = ToggleButton(WeaponSelectFrame, "⚔️ Rotar Espada (Sword): " .. (SmartUseSword and "SÍ" or "NO"), 2, SmartUseSword and C.accentOn or C.card)
local BtnUseFruit = ToggleButton(WeaponSelectFrame, "🍎 Rotar Fruta (Fruit): " .. (SmartUseFruit and "SÍ" or "NO"), 3, SmartUseFruit and C.accentOn or C.card)

BtnUseMelee.MouseButton1Click:Connect(function()
    SmartUseMelee = not SmartUseMelee
    BtnUseMelee.BackgroundColor3 = SmartUseMelee and Color3.fromRGB(180, 80, 50) or C.card
    BtnUseMelee.Text = "  👊 Rotar Combate (Melee): " .. (SmartUseMelee and "SÍ" or "NO")
    SaveConfig()
end)

BtnUseSword.MouseButton1Click:Connect(function()
    SmartUseSword = not SmartUseSword
    BtnUseSword.BackgroundColor3 = SmartUseSword and Color3.fromRGB(40, 150, 200) or C.card
    BtnUseSword.Text = "  ⚔️ Rotar Espada (Sword): " .. (SmartUseSword and "SÍ" or "NO")
    SaveConfig()
end)

BtnUseFruit.MouseButton1Click:Connect(function()
    SmartUseFruit = not SmartUseFruit
    BtnUseFruit.BackgroundColor3 = SmartUseFruit and Color3.fromRGB(150, 40, 200) or C.card
    BtnUseFruit.Text = "  🍎 Rotar Fruta (Fruit): " .. (SmartUseFruit and "SÍ" or "NO")
    SaveConfig()
end)

local BtnCalibMelee = ToggleButton(CalibPage, "👊 Calibrar Combate [Y: -" .. SmartCalib_Melee_Y .. " | Z: " .. SmartCalib_Melee_Z .. "]", 4, C.card)
local BtnCalibSword = ToggleButton(CalibPage, "⚔️ Calibrar Espada [Y: -" .. SmartCalib_Sword_Y .. " | Z: " .. SmartCalib_Sword_Z .. "]", 5, C.card)
local BtnCalibFruit = ToggleButton(CalibPage, "🍎 Calibrar Fruta [Y: -" .. SmartCalib_Fruit_Y .. " | Z: " .. SmartCalib_Fruit_Z .. "]", 6, C.card)

local function startCalib(mode, btn, text)
    CurrentlyCalibrating = mode
    TempCalibMaxY = 3
    TempCalibMaxZ = 4
    CalibrationEndTime = os.clock() + 12
    btn.BackgroundColor3 = Color3.fromRGB(150, 100, 30)
end

BtnCalibMelee.MouseButton1Click:Connect(function() startCalib("Melee", BtnCalibMelee, "👊") end)
BtnCalibSword.MouseButton1Click:Connect(function() startCalib("Sword", BtnCalibSword, "⚔️") end)
BtnCalibFruit.MouseButton1Click:Connect(function() startCalib("Fruit", BtnCalibFruit, "🍎") end)

local function ProcessCalibrationObj(obj)
    if CurrentlyCalibrating ~= "None" and os.clock() <= CalibrationEndTime then
        task.delay(0.05, function()
            pcall(function()
                local pos = nil
                local size = nil

                if obj:IsA("BasePart") then
                    pos = obj.Position
                    size = obj.Size
                elseif obj:IsA("Model") and obj.PrimaryPart then
                    pos = obj.PrimaryPart.Position
                    size = obj.PrimaryPart.Size
                end

                if pos and size then
                    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end

                    if obj:IsDescendantOf(LP.Character) or (pos - hrp.Position).Magnitude < 150 then
                        local maxD = math.max(size.X, size.Y, size.Z)

                        if maxD >= 0.5 then
                            local charY = hrp.Position.Y
                            local objY = pos.Y
                            local diffX = pos.X - hrp.Position.X
                            local diffZ = pos.Z - hrp.Position.Z
                            
                            local botY = objY - (size.Y / 2)
                            local distAbajo = math.floor(math.abs(charY - botY))
                            local distHorizontal = math.floor(math.sqrt(diffX^2 + diffZ^2))

                            if distAbajo < 3 then distAbajo = 3 end
                            if distHorizontal < 4 then distHorizontal = 4 end
                            if distHorizontal > 100 then distHorizontal = 100 end

                            if distAbajo > TempCalibMaxY then TempCalibMaxY = distAbajo end
                            if distHorizontal > TempCalibMaxZ then TempCalibMaxZ = distHorizontal end

                            local equippedTool = LP.Character:FindFirstChildOfClass("Tool")
                            if CurrentlyCalibrating == "Melee" and equippedTool then
                                SmartMeleeName = equippedTool.Name
                            elseif CurrentlyCalibrating == "Sword" and equippedTool then
                                SmartSwordName = equippedTool.Name
                            elseif CurrentlyCalibrating == "Fruit" and equippedTool then
                                SmartFruitName = equippedTool.Name
                            end
                        end
                    end
                end
            end)
        end)
    end
end

task.spawn(function()
    Workspace.DescendantAdded:Connect(ProcessCalibrationObj)
    pcall(function()
        Workspace.CurrentCamera.DescendantAdded:Connect(ProcessCalibrationObj)
    end)
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if CurrentlyCalibrating ~= "None" then
            local timeLeft = CalibrationEndTime - os.clock()
            local btn = nil
            local icon = ""
            if CurrentlyCalibrating == "Melee" then btn = BtnCalibMelee; icon = "👊"
            elseif CurrentlyCalibrating == "Sword" then btn = BtnCalibSword; icon = "⚔️"
            elseif CurrentlyCalibrating == "Fruit" then btn = BtnCalibFruit; icon = "🍎" end

            if btn then
                if timeLeft > 0 then
                    btn.Text = string.format("  %s Midiendo radar... (%.1fs) [Y: -%d | Z: %d]", icon, timeLeft, TempCalibMaxY, TempCalibMaxZ)
                else
                    if CurrentlyCalibrating == "Melee" then
                        SmartCalib_Melee_Y = TempCalibMaxY
                        SmartCalib_Melee_Z = TempCalibMaxZ
                        btn.Text = "  👊 Calibrado COMBATE [Y: -" .. SmartCalib_Melee_Y .. " | Z: " .. SmartCalib_Melee_Z .. "]"
                    elseif CurrentlyCalibrating == "Sword" then
                        SmartCalib_Sword_Y = TempCalibMaxY
                        SmartCalib_Sword_Z = TempCalibMaxZ
                        btn.Text = "  ⚔️ Calibrado ESPADA [Y: -" .. SmartCalib_Sword_Y .. " | Z: " .. SmartCalib_Sword_Z .. "]"
                    elseif CurrentlyCalibrating == "Fruit" then
                        SmartCalib_Fruit_Y = TempCalibMaxY
                        SmartCalib_Fruit_Z = TempCalibMaxZ
                        btn.Text = "  🍎 Calibrado FRUTA [Y: -" .. SmartCalib_Fruit_Y .. " | Z: " .. SmartCalib_Fruit_Z .. "]"
                    end
                    btn.BackgroundColor3 = Color3.fromRGB(30, 150, 80)
                    CurrentlyCalibrating = "None"
                    SaveConfig()
                end
            end
        end
    end
end)


-- =======================================================================================
-- ========== TAB 5: CAZADOR (SCANNER) ==========
-- =======================================================================================
local CazadorPage = MakeScrollPage("Cazador")

SectionLabel(CazadorPage, "RADAR DE MOBS/BOSSES", 1)

local ScanStatusLabel = Instance.new("TextLabel", CazadorPage)
ScanStatusLabel.Size = UDim2.new(0.95, 0, 0, 20)
ScanStatusLabel.BackgroundTransparency = 1
ScanStatusLabel.TextColor3 = C.muted
ScanStatusLabel.Font = Enum.Font.Gotham
ScanStatusLabel.TextSize = 12
ScanStatusLabel.Text = "  Objetivo: " ..
    (#ScannedTargetNames > 0 and table.concat(ScannedTargetNames, " + ") or "Ninguno")
ScanStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
ScanStatusLabel.LayoutOrder = 2

local BtnScan = ToggleButton(CazadorPage, "📡 Escanear Entidades Cercanas", 3, C.accentOff)
local BtnClearScan = ToggleButton(CazadorPage, "❌ Borrar Objetivo", 4, C.red)

local MobListContainer = Instance.new("Frame", CazadorPage)
MobListContainer.Size = UDim2.new(0.95, 0, 0, 200)
MobListContainer.BackgroundColor3 = C.card
MobListContainer.BorderSizePixel = 0
MobListContainer.LayoutOrder = 5
Instance.new("UICorner", MobListContainer).CornerRadius = UDim.new(0, 8)

local MobScroll = Instance.new("ScrollingFrame", MobListContainer)
MobScroll.Size = UDim2.new(1, -10, 1, -10)
MobScroll.Position = UDim2.new(0, 5, 0, 5)
MobScroll.BackgroundTransparency = 1
MobScroll.ScrollBarThickness = 3
MobScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
MobScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
local MobListLay = Instance.new("UIListLayout", MobScroll)
MobListLay.Padding = UDim.new(0, 2)
MobListLay.SortOrder = Enum.SortOrder.LayoutOrder

BtnScan.MouseButton1Click:Connect(function()
    BtnScan.Text = "📡 Escaneando..."
    for _, child in pairs(MobScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local found = {}
    local cache = GetMobCache()
    for _, m in ipairs(cache) do
        if m:FindFirstChild("Humanoid") and m:FindFirstChild("HumanoidRootPart") then
            local n = m.Name
            if not found[n] and not n:lower():match("npc") and not n:lower():match("dummy") then
                found[n] = true
                local isBoss = n:lower():match("boss")

                local b = Instance.new("TextButton", MobScroll)
                b.Size = UDim2.new(1, 0, 0, 30)
                b.BackgroundColor3 = isBoss and Color3.fromRGB(130, 80, 180) or C.bg
                b.TextColor3 = C.text
                b.Font = Enum.Font.GothamMedium
                b.TextSize = 12
                b.Text = (isBoss and "👺 " or "🦇 ") .. n
                b.BorderSizePixel = 0
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)

                b.MouseButton1Click:Connect(function()
                    -- Toggle: si ya está en la lista lo quita, si no lo agrega
                    local alreadyIn = false
                    for i, sn in ipairs(ScannedTargetNames) do
                        if sn == n then
                            table.remove(ScannedTargetNames, i); alreadyIn = true; break
                        end
                    end
                    if not alreadyIn then table.insert(ScannedTargetNames, n) end
                    b.BackgroundColor3 = (not alreadyIn) and C.accentOn or
                        (isBoss and Color3.fromRGB(130, 80, 180) or C.bg)
                    b.TextColor3 = (not alreadyIn) and Color3.new(0, 0, 0) or C.text
                    ScanStatusLabel.Text = "  Objetivos: " ..
                        (#ScannedTargetNames > 0 and table.concat(ScannedTargetNames, " + ") or "Ninguno")
                end)
            end
        end
    end
    BtnScan.Text = "📡 Escanear Entidades Cercanas"
end)

BtnClearScan.MouseButton1Click:Connect(function()
    ScannedTargetNames = {}
    ScanStatusLabel.Text = "  Objetivo: Ninguno"
end)

-- =================  MODO GRABACION DE RUTA (REC) =================
SectionLabel(CazadorPage, "AUTO-CAZA: GRABADOR LIVE", 6)

local RecStatusLabel = Instance.new("TextLabel", CazadorPage)
RecStatusLabel.Size = UDim2.new(0.95, 0, 0, 35)
RecStatusLabel.BackgroundTransparency = 1
RecStatusLabel.TextColor3 = C.muted
RecStatusLabel.Font = Enum.Font.Gotham
RecStatusLabel.TextSize = 11
RecStatusLabel.Text =
"  Usa esto para grabar cómo vas de isla en isla.\n  Capturará portales usados y teleports automáticamente."
RecStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
RecStatusLabel.LayoutOrder = 7

local BtnRecord = ToggleButton(CazadorPage, "⏺️ Iniciar Grabación de Ruta", 8, Color3.fromRGB(150, 40, 40))

local IsRecordingRoute = false
local RouteLogs = {}
local LastPos = Vector3.new()
local RecThread = nil
local PromptConn = nil

local oldNamecall
pcall(function()
    if hookmetamethod then
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if IsRecordingRoute and not checkcaller() then
                if method == "FireServer" or method == "InvokeServer" then
                    local sName = tostring(self):lower()
                    if sName:match("teleport") or sName:match("travel") or sName:match("island") or sName:match("map") or sName:match("dungeon") or sName:match("door") or sName:match("portal") then
                        local args = { ... }
                        local argStr = ""
                        for i, v in ipairs(args) do argStr = argStr .. tostring(v) .. (i < #args and ", " or "") end

                        -- Set context for Route Builder
                        if args[1] and type(args[1]) == "string" then
                            _G.CurrentIslandContext = args[1]
                        end

                        table.insert(RouteLogs,
                            "[REC-SPY] Remote Call: " ..
                            tostring(self.Name) .. " (" .. method .. ") | Args: [" .. argStr .. "]")
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
    end
end)

BtnRecord.MouseButton1Click:Connect(function()
    IsRecordingRoute = not IsRecordingRoute
    if IsRecordingRoute then
        BtnRecord.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
        BtnRecord.Text = "⏹️ Detener y Guardar Grabación"
        RouteLogs = {
            "===============================================",
            " GRABACION DE RUTA AUTO-CAZA - " .. os.date(),
            "==============================================="
        }

        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then LastPos = hrp.Position end

        -- 1. Capturar interacciones de Portales/Prompts
        pcall(function()
            local PPS = game:GetService("ProximityPromptService")
            PromptConn = PPS.PromptTriggered:Connect(function(prompt, player)
                if player == LP then
                    table.insert(RouteLogs,
                        "[REC] Accionaste Prompt: " .. tostring(prompt.ActionText) .. " | Obj: " .. prompt:GetFullName())
                    table.insert(RouteLogs,
                        "      Coords: " ..
                        tostring(prompt.Parent and prompt.Parent:IsA("BasePart") and prompt.Parent.Position or "N/A"))
                    BtnRecord.Text = "⏹️ GRABANDO... (Interacción Capturada)"
                end
            end)
        end)

        -- 2. Detectar Teleports o saltos de coordenadas (Dungeons / Islas)
        RecThread = task.spawn(function()
            while IsRecordingRoute do
                task.wait(1)
                local currentHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if currentHrp then
                    local dist = (currentHrp.Position - LastPos).Magnitude
                    if dist > 800 then -- Teleport grande detectado
                        table.insert(RouteLogs, "[REC] Teleport Detectado! Distancia: " .. math.floor(dist) .. " studs")
                        table.insert(RouteLogs, "      Nueva Coordenada: " .. tostring(currentHrp.Position))

                        -- Auto escanear bosses en esta nueva zona
                        task.wait(1.5) -- esperar que cargue el entorno
                        local bossesEnArea = 0
                        local c = GetMobCache()
                        for _, m in pairs(c) do
                            if m.Name:lower():match("boss") and m:FindFirstChild("HumanoidRootPart") then
                                bossesEnArea = bossesEnArea + 1
                                local hp = m:FindFirstChild("Humanoid") and m.Humanoid.Health or "N/A"
                                table.insert(RouteLogs,
                                    "      -> Boss Encontrado: " ..
                                    m.Name ..
                                    " (HP: " .. tostring(hp) .. ") en " .. tostring(m.HumanoidRootPart.Position))
                            end
                        end
                        if bossesEnArea == 0 then
                            table.insert(RouteLogs, "      -> No se detectaron Bosses en radar actual.")
                        end
                    end
                    LastPos = currentHrp.Position
                end
            end
        end)
    else
        BtnRecord.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        BtnRecord.Text = "⏺️ Iniciar Grabación de Ruta"
        if PromptConn then
            PromptConn:Disconnect(); PromptConn = nil
        end
        if RecThread then
            task.cancel(RecThread); RecThread = nil
        end

        -- Guardar el log
        table.insert(RouteLogs, "================ FIN DE GRABACION ================")
        local filename = "AutoHuntRecord_" .. tostring(os.time()) .. ".txt"
        pcall(function()
            if writefile then
                writefile(filename, table.concat(RouteLogs, "\n"))
                RecStatusLabel.Text = "  ✅ Ruta básica txt guardada: " .. filename
            else
                RecStatusLabel.Text = "  ⚠️ Sin writefile. F9 para ver ruta."
                for _, log in ipairs(RouteLogs) do print(log) end
            end
        end)
    end
end)

-- =================  ADMINISTRADOR DE AUTO-CAZA  =================
SectionLabel(CazadorPage, "RUTAS: AUTO-CAZADOR DE BOSSES", 9)

_G.AutoHuntActive = false
_G.AutoHuntRoute = {}
_G.CurrentIslandContext = "Desconocido"

local HuntStatusInfo = Instance.new("TextLabel", CazadorPage)
HuntStatusInfo.Size = UDim2.new(0.95, 0, 0, 40)
HuntStatusInfo.BackgroundTransparency = 1
HuntStatusInfo.TextColor3 = C.muted
HuntStatusInfo.Font = Enum.Font.GothamMedium
HuntStatusInfo.TextSize = 12
HuntStatusInfo.Text = "  Estado Cacería: Apagada"
HuntStatusInfo.TextXAlignment = Enum.TextXAlignment.Left
HuntStatusInfo.LayoutOrder = 10

local RouteDashboard = Instance.new("ScrollingFrame", CazadorPage)
RouteDashboard.Size = UDim2.new(0.95, 0, 0, 130)
RouteDashboard.BackgroundTransparency = 0.5
RouteDashboard.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
RouteDashboard.BorderSizePixel = 0
RouteDashboard.ScrollBarThickness = 4
RouteDashboard.LayoutOrder = 11

local DashLayout = Instance.new("UIListLayout", RouteDashboard)
DashLayout.SortOrder = Enum.SortOrder.LayoutOrder
DashLayout.Padding = UDim.new(0, 2)

task.spawn(function()
    local cachedWidgets = {}
    while true do
        task.wait(0.5)
        local targetNum = #_G.AutoHuntRoute

        -- Quitar frames sobrantes
        while #cachedWidgets > targetNum do
            cachedWidgets[#cachedWidgets]:Destroy()
            table.remove(cachedWidgets, #cachedWidgets)
        end

        -- Añadir frames faltantes
        while #cachedWidgets < targetNum do
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 0, 24)
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.GothamMedium
            lbl.TextSize = 11
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = RouteDashboard
            table.insert(cachedWidgets, lbl)
        end

        -- Actualizar Data Visual
        local currentClock = os.time()

        -- Autodetectar Isla Inicial sin necesidad de viajar
        pcall(function()
            if _G.CurrentIslandContext == "Desconocido" or _G.CurrentIslandContext == "" then
                local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local nearestPortal = nil
                    local shortestDist = math.huge
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") and (obj.ActionText:lower():match("map") or obj.Name:lower():match("portal") or obj.ActionText:lower():match("teleport")) then
                            local pPart = obj.Parent
                            if pPart and pPart:IsA("BasePart") then
                                local dist = (pPart.Position - hrp.Position).Magnitude
                                if dist < shortestDist then
                                    shortestDist = dist
                                    nearestPortal = obj
                                end
                            end
                        end
                    end
                    if nearestPortal then
                        local nameStr = nearestPortal.Parent.Name
                        if nameStr:match("Portal_") then
                            _G.CurrentIslandContext = nameStr:gsub("Portal_", "")
                        elseif nearestPortal.Parent.Parent and nearestPortal.Parent.Parent ~= workspace then
                            _G.CurrentIslandContext = nearestPortal.Parent.Parent.Name
                        end
                    end
                end
            end
        end)

        for i, step in ipairs(_G.AutoHuntRoute) do
            local lbl = cachedWidgets[i]
            -- Lógica estricta de Timer y Estado de Vida
            local dt = step.DeadTime or 0
            local cd = step.Cooldown or 300
            local timeRemaining = cd - (currentClock - dt)

            -- Detectar boss localmente
            local isAliveHere = false
            local hpStr = ""
            pcall(function()
                for _, m in pairs(GetMobCache()) do
                    if m.Name == step.Boss and m:FindFirstChild("Humanoid") then
                        if m.Humanoid.Health > 0 then
                            hpStr = "Hp: " .. math.floor(m.Humanoid.Health)
                            isAliveHere = true
                        end
                        break
                    end
                end
            end)

            -- Monitoreo Global de Muerte
            if _G.CurrentIslandContext == step.Island then
                if isAliveHere then
                    step.WasAlive = true
                    -- Si está vivo, reseteamos el dead time para que siempre mantenga 0 el timer mientras lo vemos vivo
                    step.DeadTime = 0
                    timeRemaining = 0
                elseif not isAliveHere then
                    if step.WasAlive then
                        -- Acaba de morir frente a nosotros
                        step.WasAlive = false
                        step.DeadTime = currentClock
                        timeRemaining = cd
                    elseif timeRemaining <= 0 then
                        -- Estamos en su isla, NO ESTA VIVO, y su timer dice que Debería Estarlo. Alguien lo mató o aun no reaparece.
                        -- Forzamos inicio del contador de 5 mins
                        step.DeadTime = currentClock
                        timeRemaining = cd
                    end
                end
            end

            local statusStr = ""
            if timeRemaining > 0 then
                statusStr = "⏳ Revive en " .. timeRemaining .. "s"
                lbl.TextColor3 = Color3.fromRGB(200, 100, 100) -- Rojo (Muerto)
            else
                if isAliveHere then
                    statusStr = "🟢 VIVO AQUI! " .. hpStr
                    lbl.TextColor3 = Color3.fromRGB(100, 200, 100) -- Verde (Atacar!)
                else
                    statusStr = "🟣 LISTO / Viajar a Isla"
                    lbl.TextColor3 = Color3.fromRGB(160, 100, 200) -- Morado (Listo para ir)
                end
            end

            lbl.Text = string.format("  [%d] %s (Isla: %s) -> %s", i, step.Boss, step.Island, statusStr)
        end

        -- Sync de la caja de texto visual en caso de que cambie internamente o por el network spy
        if IslandContextBox and not IslandContextBox:IsFocused() and IslandContextBox.Text ~= _G.CurrentIslandContext then
            IslandContextBox.Text = _G.CurrentIslandContext
        end
        RouteDashboard.CanvasSize = UDim2.new(0, 0, 0, #cachedWidgets * 26)
    end
end)

local RouteNameBox = Instance.new("TextBox", CazadorPage)
RouteNameBox.Size = UDim2.new(0.95, 0, 0, 32)
RouteNameBox.BackgroundColor3 = C.bg
RouteNameBox.TextColor3 = C.text

local IslandContextBox = Instance.new("TextBox", CazadorPage)
IslandContextBox.Size = UDim2.new(0.95, 0, 0, 24)
IslandContextBox.BackgroundColor3 = C.bg
IslandContextBox.TextColor3 = Color3.fromRGB(150, 200, 150)
IslandContextBox.LayoutOrder = 11.2
IslandContextBox.PlaceholderText = "📝 Nombre de Isla Actual (Auto/Manual)"
IslandContextBox.Text = _G.CurrentIslandContext
IslandContextBox.Font = Enum.Font.Gotham
IslandContextBox.TextSize = 11

IslandContextBox.FocusLost:Connect(function()
    if IslandContextBox.Text ~= "" then
        _G.CurrentIslandContext = IslandContextBox.Text
    else
        IslandContextBox.Text = _G.CurrentIslandContext
    end
end)

local BtnAddBoss = ToggleButton(CazadorPage, "➕ [REC] Guardar Objetivo(s) del Radar a Ruta", 11.5,
    Color3.fromRGB(150, 100, 40))
BtnAddBoss.MouseButton1Click:Connect(function()
    if #ScannedTargetNames == 0 then
        HuntStatusInfo.Text = "  Estado: ⚠️ Selecciona primero un Objetivo usando el RADAR arriba."
        return
    end
    if _G.CurrentIslandContext == "Desconocido" or _G.CurrentIslandContext == "" then
        HuntStatusInfo.Text = "  Estado: ⚠️ VIAJA por un portal O escribe el nombre de la isla en la caja verde."
        return
    end

    local agregados = 0
    for _, targetName in ipairs(ScannedTargetNames) do
        local existe = false
        for _, step in ipairs(_G.AutoHuntRoute) do
            if step.Boss == targetName and step.Island == _G.CurrentIslandContext then
                existe = true
                break
            end
        end
        if not existe then
            -- Insertamos con el timer reseteado (5 mins listos para contar)
            table.insert(_G.AutoHuntRoute,
                { Island = _G.CurrentIslandContext, Boss = targetName, DeadTime = os.time(), Cooldown = 300, WasAlive = false })
            agregados = agregados + 1
        end
    end

    if agregados > 0 then
        HuntStatusInfo.Text = "  ✅ " .. agregados .. " Objetivos añadidos a Ruta (" .. _G.CurrentIslandContext .. ")"
    else
        HuntStatusInfo.Text = "  Estado: ⚠️ Ninguno añadido. (Ya existen o error)"
    end
end)
RouteNameBox.PlaceholderText = "💾 Nombre de tu Ruta (Ej: RutaDiaria)"
RouteNameBox.Font = Enum.Font.Gotham
RouteNameBox.TextSize = 12
RouteNameBox.Text = ""
RouteNameBox.LayoutOrder = 12
local uc = Instance.new("UICorner", RouteNameBox); uc.CornerRadius = UDim.new(0, 4)

local BtnSaveRoute = ToggleButton(CazadorPage, "💾 Guardar Perfil de Ruta", 13, C.bg)
BtnSaveRoute.MouseButton1Click:Connect(function()
    pcall(function()
        local name = RouteNameBox.Text
        if name == "" then name = "RutaDefault" end
        name = name .. ".json"

        local hs = game:GetService("HttpService")
        local json = hs:JSONEncode(_G.AutoHuntRoute)
        if writefile then writefile(name, json) end
        _G.AutoHopRouteName = name
        HuntStatusInfo.Text = "  ✅ Perfil exportado exitosamente a:\n  " .. name
    end)
end)

local BtnLoadRoute = ToggleButton(CazadorPage, "📂 Cargar Perfil", 14, C.bg)
BtnLoadRoute.MouseButton1Click:Connect(function()
    pcall(function()
        local name = RouteNameBox.Text
        if name == "" then name = "RutaDefault" end
        name = name .. ".json"

        local hs = game:GetService("HttpService")
        local data = ""
        if readfile then data = readfile(name) end
        local parsed = hs:JSONDecode(data)
        if type(parsed) == "table" then
            _G.AutoHuntRoute = parsed
            _G.AutoHopRouteName = name
            HuntStatusInfo.Text = "  ✅ Perfil " .. name .. " cargado."
        else
            HuntStatusInfo.Text = "  ⚠️ Error al cargar " .. name
        end
    end)
end)

local BtnClearRuta = ToggleButton(CazadorPage, "🗑️ Limpiar Memoria de Ruta Visual", 15, Color3.fromRGB(120, 50, 50))
BtnClearRuta.MouseButton1Click:Connect(function()
    _G.AutoHuntRoute = {}
    HuntStatusInfo.Text = "  🛑 Memoria Visual de Rutas vaciada."
end)

local BtnStartHunt = ToggleButton(CazadorPage, "▶️ Iniciar Auto-Caza Múltiple", 16, C.card)
BtnStartHunt.MouseButton1Click:Connect(function()
    _G.AutoHuntActive = not _G.AutoHuntActive
    BtnStartHunt.Text = _G.AutoHuntActive and "⏹️ Detener Auto-Caza Múltiple" or "▶️ Iniciar Auto-Caza Múltiple"
    BtnStartHunt.BackgroundColor3 = _G.AutoHuntActive and C.accentOn or C.card
    BtnStartHunt.TextColor3 = _G.AutoHuntActive and Color3.new(0, 0, 0) or C.text
    if not _G.AutoHuntActive then
        HuntStatusInfo.Text = "  Estado Cacería: Detenida manualmente. Memoria Limpia."
        -- Limpiar Scanner y Memoria para que el AutoFarm normal quede liberado
        ScannedTargetNames = {}
        MemoryPoint = nil
        IsWalkingToMemory = false
        pcall(function() if ScanStatusLabel then ScanStatusLabel.Text = "  Objetivo: Ninguno" end end)
        pcall(function() if MemStatusLabel then MemStatusLabel.Text = "  📍 Sin punto guardado" end end)
    else
        HuntStatusInfo.Text = "  Estado Cacería: Iniciando motores..."
    end
end)

-- ===================== AUTO-HOP (Cambio de Servidor) =====================
_G.AutoHopEnabled = false
_G.AutoHopWithRoute = false
_G.AutoHopRouteName = ""

local BtnAutoHop = ToggleButton(CazadorPage, "🔄 Auto-Hop (Cambiar Servidor): OFF", 17, C.card)
BtnAutoHop.MouseButton1Click:Connect(function()
    _G.AutoHopEnabled = not _G.AutoHopEnabled
    BtnAutoHop.Text = _G.AutoHopEnabled and "🔄 Auto-Hop: ON" or "🔄 Auto-Hop (Cambiar Servidor): OFF"
    BtnAutoHop.BackgroundColor3 = _G.AutoHopEnabled and Color3.fromRGB(60, 120, 180) or C.card
    BtnAutoHop.TextColor3 = _G.AutoHopEnabled and Color3.new(1, 1, 1) or C.text
end)

local BtnHopRoute = ToggleButton(CazadorPage, "🔗 Vincular Hop + Auto-Ruta: OFF", 18, C.card)
BtnHopRoute.MouseButton1Click:Connect(function()
    _G.AutoHopWithRoute = not _G.AutoHopWithRoute
    BtnHopRoute.Text = _G.AutoHopWithRoute and "🔗 Vincular Hop + Auto-Ruta: ON" or "🔗 Vincular Hop + Auto-Ruta: OFF"
    BtnHopRoute.BackgroundColor3 = _G.AutoHopWithRoute and Color3.fromRGB(120, 60, 180) or C.card
    BtnHopRoute.TextColor3 = _G.AutoHopWithRoute and Color3.new(1, 1, 1) or C.text
end)

-- ===================== LISTADO DE RUTAS GUARDADAS =====================
SectionLabel(CazadorPage, "📁 RUTAS GUARDADAS", 19)

local RouteListFrame = Instance.new("ScrollingFrame", CazadorPage)
RouteListFrame.Size = UDim2.new(0.95, 0, 0, 90)
RouteListFrame.BackgroundTransparency = 0.5
RouteListFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
RouteListFrame.BorderSizePixel = 0
RouteListFrame.ScrollBarThickness = 4
RouteListFrame.LayoutOrder = 20

local RouteListLayout = Instance.new("UIListLayout", RouteListFrame)
RouteListLayout.SortOrder = Enum.SortOrder.LayoutOrder
RouteListLayout.Padding = UDim.new(0, 2)

local function RefreshRouteFileList()
    for _, child in pairs(RouteListFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    pcall(function()
        if listfiles then
            local files = listfiles(".")
            local order = 0
            for _, fpath in ipairs(files) do
                local fname = fpath:match("([^/\\]+)$") or fpath
                if fname:match("%.json$") and fname ~= "OmniAutoFarmConfig.json" and fname ~= "AutoHopState.json" then
                    order = order + 1
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, 0, 0, 22)
                    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
                    btn.TextColor3 = Color3.fromRGB(180, 180, 220)
                    btn.Font = Enum.Font.GothamMedium
                    btn.TextSize = 11
                    btn.TextXAlignment = Enum.TextXAlignment.Left
                    btn.Text = "  📄 " .. fname
                    btn.LayoutOrder = order
                    btn.Parent = RouteListFrame
                    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
                    btn.MouseButton1Click:Connect(function()
                        pcall(function()
                            local hs = game:GetService("HttpService")
                            local data = readfile(fname)
                            local parsed = hs:JSONDecode(data)
                            if type(parsed) == "table" then
                                _G.AutoHuntRoute = parsed
                                RouteNameBox.Text = fname:gsub("%.json$", "")
                                _G.AutoHopRouteName = fname
                                HuntStatusInfo.Text = "  ✅ Ruta '" .. fname .. "' cargada."
                            end
                        end)
                    end)
                end
            end
            RouteListFrame.CanvasSize = UDim2.new(0, 0, 0, order * 24)
            if order == 0 then
                HuntStatusInfo.Text = "  ⚠️ No se encontraron rutas .json guardadas."
            else
                HuntStatusInfo.Text = "  📁 " .. order .. " rutas encontradas."
            end
        end
    end)
end

local BtnRefreshRoutes = ToggleButton(CazadorPage, "🔍 Refrescar Lista de Rutas", 19.5, C.bg)
BtnRefreshRoutes.MouseButton1Click:Connect(function()
    RefreshRouteFileList()
end)

-- Cargar lista al inicio (tras breve delay para dar tiempo al executor)
task.delay(2, RefreshRouteFileList)

-- =======================================================================================
-- =========================================================================================
-- ========== TAB 6: ANALIZADOR MITM Y SPOOF NPC ==========
-- =========================================================================================
local AnalistaPage = MakeScrollPage("Analizador")

SectionLabel(AnalistaPage, "ESCÁNER EN VIVO: DAÑO Y NPC", 1)

local AnalistaInfo = Instance.new("TextLabel", AnalistaPage)
AnalistaInfo.Size = UDim2.new(0.95, 0, 0, 45)
AnalistaInfo.BackgroundTransparency = 1
AnalistaInfo.TextColor3 = C.muted
AnalistaInfo.Font = Enum.Font.GothamMedium
AnalistaInfo.TextSize = 11
AnalistaInfo.Text = "  Espía la comunicación exacta entre cliente y servidor.\n  Captura cómo se calcula el daño y qué piden los NPC."
AnalistaInfo.TextXAlignment = Enum.TextXAlignment.Left
AnalistaInfo.TextWrapped = true
AnalistaInfo.LayoutOrder = 2

local BtnSpyDamage = ToggleButton(AnalistaPage, "⚠️ Ver Tráfico de Dap�o", 3, Color3.fromRGB(150, 40, 40))
local BtnSpyNPC = ToggleButton(AnalistaPage, "[SPY] Ver Peticiones a NPCs", 4, Color3.fromRGB(40, 150, 40))
local BtnSpoofNPC = ToggleButton(AnalistaPage, "[HACK] Fingir que tengo items (Hackear NPC)", 5, Color3.fromRGB(180, 140, 20))

local AnalistaLog = Instance.new("TextLabel", AnalistaPage)
AnalistaLog.Size = UDim2.new(0.95, 0, 0, 20)
AnalistaLog.BackgroundTransparency = 1
AnalistaLog.TextColor3 = Color3.fromRGB(120, 255, 120)
AnalistaLog.Font = Enum.Font.Code
AnalistaLog.TextSize = 12
AnalistaLog.Text = "  Status: Esperando..."
AnalistaLog.TextXAlignment = Enum.TextXAlignment.Left
AnalistaLog.LayoutOrder = 6

local function dumpTable(tbl, indent, maxDepth)
    if not indent then indent = "  " end
    if not maxDepth then maxDepth = 6 end
    
    if type(tbl) ~= "table" then return tostring(tbl) end
    if maxDepth <= 0 then return "{ ... max depth ... }" end

    local s = "{\n"
    local seenKeys = {}
    for k, v in pairs(tbl) do
        if typeof(k) == "Instance" then k = k:GetFullName() end
        
        if typeof(v) == "table" and not seenKeys[v] then
            seenKeys[v] = true
            s = s .. indent .. "  " .. tostring(k) .. " = " .. dumpTable(v, indent .. "  ", maxDepth - 1) .. ",\n"
        elseif typeof(v) == "function" then
            s = s .. indent .. "  " .. tostring(k) .. " = [function],\n"
        elseif typeof(v) == "Instance" then
            s = s .. indent .. "  " .. tostring(k) .. " = [Instance: " .. v.ClassName .. "],\n"
        elseif type(v) == "userdata" or typeof(v) == "userdata" then
            s = s .. indent .. "  " .. tostring(k) .. " = [userdata: " .. typeof(v) .. "],\n"
        else
            s = s .. indent .. "  " .. tostring(k) .. " = " .. tostring(v) .. ",\n"
        end
    end
    s = s .. indent .. "}"
    return s
end

local function saveLogToFile(category, name, dataStr)
    pcall(function()
        if not writefile then return end
        local filename = "Captured_Data_Analyst.txt"
        local timestamp = tostring(os.date("%Y-%m-%d %H:%M:%S"))
        local entry = "=========================\n" ..
                      "[" .. timestamp .. "] " .. category .. ": " .. name .. "\n" ..
                      dataStr .. "\n\n"
        
        if isfile and readfile and isfile(filename) then
            local old = readfile(filename)
            writefile(filename, old .. entry)
        else
            writefile(filename, entry)
        end
    end)
end

-- SPY Combat:
BtnSpyDamage.MouseButton1Click:Connect(function()
    if _G.SpyingCombat then
        _G.SpyingCombat = false
        if _G.ClientEventHooks then
            for _, conn in ipairs(_G.ClientEventHooks) do
                conn:Disconnect()
            end
            _G.ClientEventHooks = nil
        end
        AnalistaLog.Text = "  ⛔ Spy de Combate DETENIDO."
        return
    end
    
    _G.SpyingCombat = true
    AnalistaLog.Text = "  [!] Interceptando llamadas de ataque... (ABRE F9)"
    print("------- INICIANDO SPY DE COMBATE -------")
    
    pcall(function()
        if not _G.OldNamecallCombat then
            _G.OldNamecallCombat = hookmetamethod(game, "__namecall", function(self, ...)
                if not _G.SpyingCombat then return _G.OldNamecallCombat(self, ...) end
                
                local method = getnamecallmethod()
                if not checkcaller() and method == "FireServer" and typeof(self) == "Instance" then
                    local name = tostring(self.Name)
                    if name:find("Combat") or name:find("Hit") or name:find("Damage") or name:find("M1") then
                        print("[SPY DAÑO OUT]: " .. name)
                        local args = {...}
                        local dumpStr = dumpTable(args, "  ")
                        print(dumpStr)
                        saveLogToFile("DAÑO", name, dumpStr)
                    end
                end
                return _G.OldNamecallCombat(self, ...)
            end)
        end
        
        -- Hookear de vuelta la respuesta del servidor (Daño Validado / Recibido)
        if not _G.ClientEventHooks then
            _G.ClientEventHooks = {}
            for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                if v:IsA("RemoteEvent") and (v.Name:find("Combat") or v.Name:find("Hit") or v.Name:find("Damage") or v.Name:find("M1") or v.Name:find("Effect")) then
                    table.insert(_G.ClientEventHooks, v.OnClientEvent:Connect(function(...)
                        if not _G.SpyingCombat then return end
                        print("[SPY DAÑO IN (DEL SERVER)]: " .. v.Name)
                        local args = {...}
                        local dumpStr = dumpTable(args, "  ")
                        print(dumpStr)
                        saveLogToFile("DAÑO_RECIBIDO", v.Name, dumpStr)
                    end))
                end
            end
        end
        
    end)
end)

-- SPY NPC:
BtnSpyNPC.MouseButton1Click:Connect(function()
    if _G.SpyingNPC then
        _G.SpyingNPC = false
        AnalistaLog.Text = "  ⛔ Spy de NPC DETENIDO."
        return
    end
    
    _G.SpyingNPC = true
    AnalistaLog.Text = "  [!] Habla con un NPC y abre el F9..."
    print("------- INICIANDO SPY DE NPCs -------")
    
    pcall(function()
        if not _G.OldNamecallNPCHook then
            _G.OldNamecallNPCHook = hookmetamethod(game, "__namecall", function(self, ...)
                if not _G.SpyingNPC then return _G.OldNamecallNPCHook(self, ...) end
                
                local method = getnamecallmethod()
                if not checkcaller() and (method == "InvokeServer" or method == "FireServer") and typeof(self) == "Instance" then
                    local name = tostring(self.Name)
                    local nl = name:lower()
                    
                    -- Blacklist de remotes spam por movimiento, mouse, o combate (que ya escaneamos por separado)
                    local isSpam = nl:find("mouse") or nl:find("camera") or nl:find("move") or nl:find("walk") or nl:find("jump")
                                or nl:find("combat") or nl:find("hit") or nl:find("damage") or nl:find("m1") or nl:find("step")
                                or nl:find("update") or nl:find("hover") or nl:find("ping")
                                
                    if not isSpam then
                        print(string.format("[SPY NETWORK %s]: %s", method, name))
                        local args = {...}
                        local dumpStr = dumpTable(args, "  ")
                        print(dumpStr)
                        saveLogToFile("TRAFICO_" .. method:upper(), name, dumpStr)
                    end
                end
                return _G.OldNamecallNPCHook(self, ...)
            end)
        end
    end)
end)

-- SPOOF INV (HACK NPC):
BtnSpoofNPC.MouseButton1Click:Connect(function()
    if _G.SpoofingNPC then
        _G.SpoofingNPC = false
        AnalistaLog.Text = "  ⛔ Spoof de Inventario DETENIDO."
        return
    end
    
    _G.SpoofingNPC = true
    AnalistaLog.Text = "  [!] Spoof activado: El juego creerá que tienes los items."
    print("------- INICIANDO SPOOF DE INVENTARIO -------")
    
    pcall(function()
        if not _G.OldNamecallInv7 then
            _G.OldNamecallInv7 = hookmetamethod(game, "__namecall", function(self, ...)
                if not _G.SpoofingNPC then return _G.OldNamecallInv7(self, ...) end
                
                local method = getnamecallmethod()
                if not checkcaller() and method == "InvokeServer" and typeof(self) == "Instance" then
                    local name = tostring(self.Name)
                    local nl = name:lower()
                    
                    if nl:find("check") or nl:find("has") or nl:find("requirement") then
                        print("[SPOOF] Falsificando respuesta VERDADERA a: " .. name)
                        return true
                    end
                    
                    if name == "GetItems" or name == "GetStorageData" or name == "GetInventory" then
                        print("[SPOOF] Advertencia: El NPC intentó leer el inventario completo mediante " .. name)
                    end
                end
                return _G.OldNamecallInv7(self, ...)
            end)
        end
    end)
end)


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

function GetMobCache()
    if os.clock() - LastCacheTime > 2.5 then
        LastCacheTime = os.clock()
        local newCache = {}

        pcall(function()
            for _, mob in pairs(Workspace:GetDescendants()) do
                if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
                    if mob.Humanoid.Health > 0 then
                        local n = mob.Name:lower()
                        -- Filtro 1: Nombre contiene palabras clave de NPC
                        local isNPC = n:match("npc") or n:match("dummy") or n:match("merchant") or n:match("vendor")
                            or n:match("shop") or n:match("quest") or n:match("guard") or n:match("villager")

                        -- Filtro 2: Tiene ProximityPrompt o Dialog (interactivos = NPC)
                        if not isNPC then
                            isNPC = mob:FindFirstChildWhichIsA("ProximityPrompt", true) ~= nil
                                or mob:FindFirstChildOfClass("Dialog") ~= nil
                                or mob:FindFirstChildWhichIsA("ClickDetector", true) ~= nil
                        end

                        -- Filtro 3: No sea un Jugador
                        if not isNPC and not game.Players:GetPlayerFromCharacter(mob) then
                            table.insert(newCache, mob)
                        end
                    end
                end
            end
        end)

        TargetMobsCache = newCache
    end
    return TargetMobsCache
end

function GetNearestMob()
    local nearestDist = math.huge
    local nearestMob = nil
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = char.HumanoidRootPart

    local cache = GetMobCache()
    for _, mob in ipairs(cache) do
        local allow = false
        local isBoss = mob.Name:lower():match("boss")

        if #ScannedTargetNames > 0 then
            for _, sn in ipairs(ScannedTargetNames) do
                if mob.Name == sn then
                    allow = true; break
                end
            end
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
                
                -- RESTRICCIÓN DE ISLA / ÁREA LOCAL (Para que no cruce el océano buscando otro Boss/Mob)
                local isValidDistance = true
                if #ScannedTargetNames == 0 then
                    local maxRadius = 1500 -- Studs maximos de una isla
                    if MemoryPoint then
                        local memDist = (MemoryPoint - tHrp.Position).Magnitude
                        if memDist > maxRadius then isValidDistance = false end
                    else
                        if dist > maxRadius then isValidDistance = false end
                    end
                end

                if isValidDistance and dist < nearestDist then
                    nearestDist = dist
                    nearestMob = mob
                end
            end
        end
    end
    -- DEFENSA: si hay objetivos marcados pero ninguno cerca, atacar cualquier mob muy cercano (<25s)
    if nearestMob == nil and #ScannedTargetNames > 0 then
        local defenseDist = math.huge
        for _, mob in ipairs(cache) do
            if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                local tHrp = mob:FindFirstChild("HumanoidRootPart")
                if tHrp then
                    local dist = (hrp.Position - tHrp.Position).Magnitude
                    if dist < 25 and dist < defenseDist then
                        defenseDist = dist
                        nearestMob = mob
                    end
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

-- ==============================================================================
-- 👻 GHOST PROTOCOL — Desactiva bloques invisibles CanCollide en mazmorras
-- Solo activo cuando GhostProtocolEnabled = true
-- No toca la lógica de combate ni el noclip del personaje
-- ==============================================================================
BtnGhost.MouseButton1Click:Connect(function()
    GhostProtocolEnabled = not GhostProtocolEnabled
    if GhostProtocolEnabled then
        BtnGhost.BackgroundColor3 = Color3.fromRGB(80, 40, 140)
        BtnGhost.Text = "  👻 Ghost Protocol (Mazmorra): ON"
        BtnGhost.TextColor3 = Color3.new(1, 1, 1)
    else
        BtnGhost.BackgroundColor3 = C.card
        BtnGhost.Text = "  👻 Ghost Protocol (Mazmorra): OFF"
        BtnGhost.TextColor3 = C.text
        GhostBlocksDisabled = 0
    end
end)

-- Loop independiente: busca bloques invisibles CanCollide=true y los desactiva
task.spawn(function()
    while true do
        task.wait(3) -- corre cada 3 segundos, no afecta FPS
        if GhostProtocolEnabled then
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local count = 0
                for _, obj in pairs(Workspace:GetDescendants()) do
                    -- Solo bloques invisibles CanCollide sin TouchTransmitter (seguros de desactivar)
                    if obj:IsA("BasePart")
                        and obj.Transparency >= 0.99
                        and obj.CanCollide == true
                        and not obj:FindFirstChildOfClass("TouchTransmitter")
                        and not obj:IsDescendantOf(LP.Character)
                    then
                        local dist = (obj.Position - hrp.Position).Magnitude
                        if dist < 800 then
                            obj.CanCollide = false
                            count = count + 1
                        end
                    end
                end
                GhostBlocksDisabled = count
                if count > 0 then
                    BtnGhost.Text = "  👻 Ghost: ON — " .. count .. " bloques quitados"
                else
                    BtnGhost.Text = "  👻 Ghost: ON — Buscando..."
                end
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
                        -- PRIORIDAD 1: Nombre exacto calibrado por el usuario
                        if reqType == "Melee" and SmartMeleeName and SmartMeleeName ~= "" then
                            local t = char:FindFirstChild(SmartMeleeName) or LP.Backpack:FindFirstChild(SmartMeleeName)
                            if t then return t end
                        end
                        if reqType == "Sword" and SmartSwordName and SmartSwordName ~= "" then
                            local t = char:FindFirstChild(SmartSwordName) or LP.Backpack:FindFirstChild(SmartSwordName)
                            if t then return t end
                        end
                        if reqType == "Fruit" and SmartFruitName and SmartFruitName ~= "" then
                            local t = char:FindFirstChild(SmartFruitName) or LP.Backpack:FindFirstChild(SmartFruitName)
                            if t then return t end
                        end

                        -- PRIORIDAD 2: Coincidencia por keywords en el nombre de la tool
                        -- (funciona sin calibración explícita de nombres)
                        local function strictMatch(t)
                            local n = t.Name:lower()
                            if reqType == "Sword" then
                                return (n:match("katana") or n:match("sword") or n:match("blade") or n:match("saber") or n:match("cutlass") or n:match("yoru")) ~= nil
                            elseif reqType == "Fruit" then
                                return (n:match("fruit") or n:match("devil") or n:match("mera") or n:match("gura") or n:match("ito")) ~= nil
                            elseif reqType == "Melee" then
                                return (n:match("combat") or n:match("melee") or n:match("fist") or n:match("style") or n:match("kick") or n:match("taijutsu") or n:match("black")) ~= nil
                            end
                            return false
                        end

                        for _, t in pairs(char:GetChildren()) do
                            if t:IsA("Tool") and strictMatch(t) then return t end
                        end
                        for _, t in pairs(LP.Backpack:GetChildren()) do
                            if t:IsA("Tool") and strictMatch(t) then return t end
                        end

                        -- PRIORIDAD 3: Fallback — sólo si hay AL MENOS UN nombre calibrado
                        -- para poder saber qué excluir. Si no hay nombres, NO devolver nada
                        -- al azar (eso causaba que siempre se devolviera la Espada)
                        local hasCalibration = (SmartMeleeName and SmartMeleeName ~= "")
                            or (SmartSwordName and SmartSwordName ~= "")
                            or (SmartFruitName and SmartFruitName ~= "")

                        if hasCalibration then
                            local function isForbiddenByName(t)
                                if SmartSwordName and SmartSwordName ~= "" and t.Name == SmartSwordName and reqType ~= "Sword" then return true end
                                if SmartMeleeName and SmartMeleeName ~= "" and t.Name == SmartMeleeName and reqType ~= "Melee" then return true end
                                if SmartFruitName and SmartFruitName ~= "" and t.Name == SmartFruitName and reqType ~= "Fruit" then return true end
                                return false
                            end
                            for _, t in pairs(char:GetChildren()) do
                                if t:IsA("Tool") and not isForbiddenByName(t) then return t end
                            end
                            for _, t in pairs(LP.Backpack:GetChildren()) do
                                if t:IsA("Tool") and not isForbiddenByName(t) then return t end
                            end
                        end

                        return nil -- Sin calibración de nombres + sin match de keywords = no devolver nada
                    end

                    local tool = char:FindFirstChildOfClass("Tool")
                    if SmartCombatEnabled then
                        if not LastSmartSwap then LastSmartSwap = os.clock() end
                        if not SmartCurrentWeapon then SmartCurrentWeapon = "Melee" end

                        local activeWeapons = {}
                        if SmartUseMelee then table.insert(activeWeapons, "Melee") end
                        if SmartUseSword then table.insert(activeWeapons, "Sword") end
                        if SmartUseFruit then table.insert(activeWeapons, "Fruit") end

                        if #activeWeapons == 0 then table.insert(activeWeapons, "Melee") end

                        if not table.find(activeWeapons, SmartCurrentWeapon) then
                            SmartCurrentWeapon = activeWeapons[1]
                            LastSmartSwap = os.clock()
                        end

                        if #activeWeapons > 1 and os.clock() - LastSmartSwap > 4 then
                            LastSmartSwap = os.clock()
                            local idx = table.find(activeWeapons, SmartCurrentWeapon) or 1
                            idx = idx + 1
                            if idx > #activeWeapons then idx = 1 end
                            SmartCurrentWeapon = activeWeapons[idx]
                        end

                        local wTool = GetSmartTool(SmartCurrentWeapon)
                        -- Si no encontro el arma actual, intentar con la siguiente en rotación
                        if not wTool and #activeWeapons > 1 then
                            local idx = table.find(activeWeapons, SmartCurrentWeapon) or 1
                            for attempt = 1, #activeWeapons - 1 do
                                idx = idx + 1
                                if idx > #activeWeapons then idx = 1 end
                                wTool = GetSmartTool(activeWeapons[idx])
                                if wTool then
                                    SmartCurrentWeapon = activeWeapons[idx]
                                    LastSmartSwap = os.clock()
                                    break
                                end
                            end
                        end

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
                        -- Usar FindFirstChild (no WaitForChild) — el mob ya fue validado en GetNearestMob
                                        local mobHrp = mob:FindFirstChild("HumanoidRootPart")

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
                                            if #ScannedTargetNames > 0 then
                                                for _, sn in ipairs(ScannedTargetNames) do
                                                    if m.Name == sn then
                                                        allow = true; break
                                                    end
                                                end
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
                                        local currentFarmMode = FarmMode
                                        local mobPos = tHrp.Position

                                        -- Distancia horizontal actual entre jugador y mob
                                        local actualHorizVec = Vector3.new(hrp.Position.X - mobPos.X, 0, hrp.Position.Z - mobPos.Z)
                                        local actualHorizDist = actualHorizVec.Magnitude

                                        -- Dirección horizontal desde el MOB hacia el JUGADOR
                                        local toPlayerFlat = actualHorizDist > 0.5 and actualHorizVec.Unit or Vector3.new(0, 0, 1)

                                        local myTargetPos

                                        if SmartCombatEnabled then
                                            local currentOffsetY = SmartCalib_Melee_Y
                                            local currentOffsetZ = SmartCalib_Melee_Z
                                            if SmartCurrentWeapon == "Sword" then
                                                currentOffsetY = SmartCalib_Sword_Y
                                                currentOffsetZ = SmartCalib_Sword_Z
                                            elseif SmartCurrentWeapon == "Fruit" then
                                                currentOffsetY = SmartCalib_Fruit_Y
                                                currentOffsetZ = SmartCalib_Fruit_Z
                                            end
                                            local targetHoriz = math.max(currentOffsetZ, 4)

                                            if currentFarmMode == "Arriba" then
                                                -- EXACTAMENTE encima para golpear desde arriba de cabeza
                                                myTargetPos = Vector3.new(mobPos.X, mobPos.Y + currentOffsetY, mobPos.Z)
                                            elseif currentFarmMode == "Abajo" then
                                                if actualHorizDist <= targetHoriz then
                                                    myTargetPos = Vector3.new(hrp.Position.X, mobPos.Y - currentOffsetY, hrp.Position.Z)
                                                else
                                                    myTargetPos = mobPos + Vector3.new(0, -currentOffsetY, 0) + toPlayerFlat * targetHoriz
                                                end
                                            elseif currentFarmMode == "Mazmorra" then
                                                -- ESTÁTICO: quedarse donde está, solo apuntar al boss
                                                myTargetPos = Vector3.new(hrp.Position.X, mobPos.Y, hrp.Position.Z)
                                            else -- Detras
                                                myTargetPos = mobPos + toPlayerFlat * (currentOffsetZ + 2)
                                            end
                                        else
                                            local targetHoriz = math.max(math.abs(OfsZ), 4)
                                            if currentFarmMode == "Arriba" then
                                                -- EXACTAMENTE encima a distancia corta (Cuerpo echado)
                                                myTargetPos = Vector3.new(mobPos.X, mobPos.Y + math.abs(OfsY), mobPos.Z)
                                            elseif currentFarmMode == "Abajo" then
                                                if actualHorizDist <= targetHoriz then
                                                    myTargetPos = Vector3.new(hrp.Position.X, mobPos.Y - math.abs(OfsY), hrp.Position.Z)
                                                else
                                                    myTargetPos = mobPos + Vector3.new(0, -math.abs(OfsY), 0) + toPlayerFlat * targetHoriz
                                                end
                                            elseif currentFarmMode == "Mazmorra" then
                                                -- ESTÁTICO: quedarse donde está, solo apuntar al boss
                                                myTargetPos = Vector3.new(hrp.Position.X, mobPos.Y, hrp.Position.Z)
                                            else -- Detras
                                                myTargetPos = mobPos + toPlayerFlat * math.abs(OfsZ)
                                            end
                                        end

                                        -- Construir CFrame mirando directamente al mob
                                        local TargetCF
                                        if myTargetPos then
                                            local lookDir = mobPos - myTargetPos
                                            -- Mazmorra: myTargetPos.Y == mobPos.Y, lookDir puede ser (0,0,0) si XZ también coinciden
                                            -- En ese caso usar la orientacion actual del HRP para no perder el aim
                                            if lookDir.Magnitude > 0.1 then
                                                if currentFarmMode == "Arriba" then
                                                    -- Posición de Pájaro (Cuerpo echado paralelo al piso, cara viendo abajo)
                                                    TargetCF = CFrame.lookAt(myTargetPos, mobPos, Vector3.new(0, 0, 1))
                                                else
                                                    TargetCF = CFrame.lookAt(myTargetPos, mobPos, Vector3.new(0, 1, 0))
                                                end
                                            elseif currentFarmMode == "Mazmorra" then
                                                -- Mismo punto: mantener orientacion actual del jugador
                                                TargetCF = hrp.CFrame
                                            else
                                                TargetCF = CFrame.new(myTargetPos)
                                            end
                                        end
                                        if not TargetCF then TargetCF = CFrame.new(mobPos) end

                                        pcall(function()
                                            local rootCF = TargetCF
                                            if BlinkAttackEnabled then
                                                rootCF = TargetCF *
                                                    CFrame.new(0, FarmMode == "Abajo" and 0 or 5,
                                                        FarmMode == "Abajo" and -12 or 45)
                                            end
                                            if currentFarmMode == "Mazmorra" then
                                                -- En Mazmorra: FORZAR Y minimo. Clamp X/Z si hay ArenaAnchor.
                                                local safeY = math.max(hrp.Position.Y, mobPos.Y + 1.5)
                                                local finalX = hrp.Position.X
                                                local finalZ = hrp.Position.Z
                                                
                                                if ArenaAnchor then
                                                    local currentFlat = Vector3.new(finalX, 0, finalZ)
                                                    local anchorFlat = Vector3.new(ArenaAnchor.X, 0, ArenaAnchor.Z)
                                                    local d = (currentFlat - anchorFlat).Magnitude
                                                    if d > ArenaRadius then
                                                        local clamped = anchorFlat + (currentFlat - anchorFlat).Unit * ArenaRadius
                                                        finalX = clamped.X
                                                        finalZ = clamped.Z
                                                    end
                                                end
                                                
                                                hrp.CFrame = CFrame.lookAt(Vector3.new(finalX, safeY, finalZ), mobPos, Vector3.new(0, 1, 0))
                                            else
                                                local flyDist = (hrp.Position - rootCF.Position).Magnitude
                                                if (TargetBosses == "SoloBoss" or #ScannedTargetNames > 0 or flyDist > 100) and flyDist > 15 then
                                                    local flyStep = math.clamp(BlinkStepValue / flyDist, 0, 1)
                                                    char:PivotTo(hrp.CFrame:Lerp(rootCF, flyStep))
                                                else
                                                    char:PivotTo(rootCF)
                                                end
                                            end
                                        end)

                                        -- Cámara fija siempre en el jugador
                                        pcall(function()
                                            local cam = Workspace.CurrentCamera
                                            if cam and cam.CameraSubject ~= char:FindFirstChild("Humanoid") then
                                                cam.CameraSubject = char:FindFirstChild("Humanoid")
                                            end
                                        end)

                                        local actualLoc = BlinkAttackEnabled and
                                            (TargetCF * CFrame.new(0, FarmMode == "Abajo" and 0 or 5, FarmMode == "Abajo" and -12 or 45)) or
                                            TargetCF
                                        local distFinal = (hrp.Position - actualLoc.Position).Magnitude
                                        if distFinal <= 20 then
                                            pcall(function()
                                                if BlinkAttackEnabled then
                                                    char:PivotTo(TargetCF)
                                                    CombatRemote:FireServer()
                                                    if tool then tool:Activate() end
                                                    char:PivotTo(actualLoc)
                                                else
                                                    CombatRemote:FireServer()
                                                    if tool then tool:Activate() end
                                                end
                                            end)

                                            -- Aimbot: re-apuntar HRP directo al mob en 3D antes de lanzar skills
                                            -- (TargetCF ya apunta al mob, esto refuerza el aim justo antes de cada key)
                                            if AutoSkillEnabled then
                                                pcall(function()
                                                    hrp.CFrame = CFrame.lookAt(hrp.Position, mobPos, Vector3.new(0, 1, 0))

                                                    local scanKeys = _G.AutoSkillKeys or {"Z", "X", "C", "V"}
                                                    for _, keyStr in ipairs(scanKeys) do
                                                        local ok, keyCode = pcall(function() return Enum.KeyCode[keyStr] end)
                                                        if ok and keyCode then
                                                            VIM:SendKeyEvent(true, keyCode, false, game)
                                                            task.wait(0.01)
                                                            VIM:SendKeyEvent(false, keyCode, false, game)
                                                            task.wait(0.01)
                                                        end
                                                    end
                                                end)
                                            end
                                        end

                                        task.wait(0.05)
                                    end
                                end -- for targetMob
                            end     -- else IsInPanicRecovery
                        end         -- if mobHrp
                    else            -- else for mob and not ForceMemoryReturn
                        GlobalMagnetTarget = nil
                        StatusLabel.Text = "Buscando Mobs vivos..."
                    end -- if mob and not ForceMemoryReturn
                end     -- if char.Humanoid.Health <= 0
            else        -- else for char and char:FindFirstChild
                GlobalMagnetTarget = nil
                StatusLabel.Text = "Esperando al Personaje..."
            end -- if char and char:FindFirstChild
        else    -- else for AutoFarm
            GlobalMagnetTarget = nil
        end     -- if AutoFarm
    end         -- while task.wait()
end)            -- task.spawn

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
    if input.KeyCode == Enum.KeyCode.P then
        local char = LP.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            if ArenaAnchor then
                ArenaAnchor = nil
                StatusLabel.Text = "🛑 Ancla de Arena Desactivada"
                if ArenaStatusLabel then ArenaStatusLabel.Text = "  ⭕ Ancla Arena: OFF (Presiona P)" end
            else
                ArenaAnchor = char.HumanoidRootPart.Position
                StatusLabel.Text = "⚔️ Ancla Activada (Radio: " .. ArenaRadius .. " studs)"
                if ArenaStatusLabel then 
                    ArenaStatusLabel.Text = "  ⭕ Ancla Arena: ON (" .. math.floor(ArenaAnchor.X) .. ", " .. math.floor(ArenaAnchor.Z) .. ")" 
                end
            end
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
        BtnSkill.Text = "  🔥 Skills: ON (" .. (SkillKeysBox and SkillKeysBox.Text or "Z, X, C, V") .. ")"
    else
        BtnSkill.BackgroundColor3 = C.card
        BtnSkill.Text = "  🔥 Auto Skill (Teclas)"
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
        BtnBlink.TextColor3 = Color3.new(1, 1, 1)
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
        OfsY = -25; OfsZ = 0 -- 25 studs debajo del mob (subterráneo profundo)
        BtnHeight.Text = "  Posición: 🕳️ Subterráneo"
        -- Auto-activar Ghost Protocol para quitar bloques invisibles
        GhostProtocolEnabled = true
        BtnGhost.BackgroundColor3 = Color3.fromRGB(80, 40, 140)
        BtnGhost.Text = "  👻 Ghost: ON — (auto-activado)"
        BtnGhost.TextColor3 = Color3.new(1, 1, 1)
    elseif FarmMode == "Abajo" then
        FarmMode = "Mazmorra"
        OfsY = 0; OfsZ = -3 -- Detras ultra-pegado a nivel de piso
        BtnHeight.Text = "  Posición: 🏰 Mazmorra (Estático)"
        -- En mazmorra apagamos ghost por defecto pero si lo ocupa lo activa manual
        GhostProtocolEnabled = false
        BtnGhost.BackgroundColor3 = C.card
        BtnGhost.Text = "  👻 Ghost Protocol (Mazmorra): OFF"
        BtnGhost.TextColor3 = C.text
    else
        FarmMode = "Arriba"
        OfsY = 10; OfsZ = 0
        BtnHeight.Text = "  Posición: ☁️ Arriba"
        -- Desactivar Ghost al volver arriba
        GhostProtocolEnabled = false
        BtnGhost.BackgroundColor3 = C.card
        BtnGhost.Text = "  👻 Ghost Protocol (Mazmorra): OFF"
        BtnGhost.TextColor3 = C.text
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
                    if data.PanicThreshold ~= nil then PanicThreshold = data.PanicThreshold end
                    if data.ReturnHealthThreshold ~= nil then ReturnHealthThreshold = data.ReturnHealthThreshold end
                    if data.MobMagnetEnabled ~= nil then MobMagnetEnabled = data.MobMagnetEnabled end
                    if data.AutoSkillEnabled ~= nil then AutoSkillEnabled = data.AutoSkillEnabled end
                    if data.TargetBosses ~= nil then TargetBosses = data.TargetBosses end
                    if data.FarmMode ~= nil then FarmMode = data.FarmMode end
                    if data.BlinkAttackEnabled ~= nil then BlinkAttackEnabled = data.BlinkAttackEnabled end

                    if data.SmartCombatEnabled ~= nil then SmartCombatEnabled = data.SmartCombatEnabled end
                    if data.SmartUseSword ~= nil then SmartUseSword = data.SmartUseSword end
                    if data.SmartUseFruit ~= nil then SmartUseFruit = data.SmartUseFruit end
                    if data.SmartUseMelee ~= nil then SmartUseMelee = data.SmartUseMelee end
                    if data.SmartCalib_Sword_Y ~= nil then SmartCalib_Sword_Y = data.SmartCalib_Sword_Y end
                    if data.SmartCalib_Sword_Z ~= nil then SmartCalib_Sword_Z = data.SmartCalib_Sword_Z end
                    if data.SmartCalib_Fruit_Y ~= nil then SmartCalib_Fruit_Y = data.SmartCalib_Fruit_Y end
                    if data.SmartCalib_Fruit_Z ~= nil then SmartCalib_Fruit_Z = data.SmartCalib_Fruit_Z end
                    if data.SmartCalib_Melee_Y ~= nil then SmartCalib_Melee_Y = data.SmartCalib_Melee_Y end
                    if data.SmartCalib_Melee_Z ~= nil then SmartCalib_Melee_Z = data.SmartCalib_Melee_Z end
                    if data.SmartSwordName ~= nil then SmartSwordName = data.SmartSwordName end
                    if data.SmartFruitName ~= nil then SmartFruitName = data.SmartFruitName end
                    if data.SmartMeleeName ~= nil then SmartMeleeName = data.SmartMeleeName end
                    if data.AutoSkillKeys ~= nil and type(data.AutoSkillKeys) == "table" then
                        _G.AutoSkillKeys = data.AutoSkillKeys
                        SkillKeysBox.Text = table.concat(_G.AutoSkillKeys, ", ")
                        if AutoSkillEnabled then
                            BtnSkill.Text = "  🔥 Skills: ON (" .. SkillKeysBox.Text .. ")"
                        end
                    end

                    if FarmMode == "Abajo" then
                        OfsY = -25; OfsZ = 0; BtnHeight.Text = "  Posición: 🕳️ Subterráneo"
                    elseif FarmMode == "Mazmorra" then
                        OfsY = 0; OfsZ = -3; BtnHeight.Text = "  Posición: 🏰 Mazmorra (Estático)"
                    else
                        OfsY = 10; OfsZ = 0; BtnHeight.Text = "  Posición: ☁️ Arriba"
                    end
                    if MobMagnetEnabled then
                        BtnMagnet.BackgroundColor3 = C.accentOn; BtnMagnet.Text = "  🧲 Imán: ACTIVO"
                    end
                    if AutoSkillEnabled then
                        BtnSkill.BackgroundColor3 = C.accentOn; BtnSkill.Text = "  🔥 Skills: ON (" .. table.concat(_G.AutoSkillKeys or {"Z","X","C","V"}, ", ") .. ")"
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
                                    -- Restaurar UI de Smart Combat
                                    pcall(function()
                                        if SmartCombatEnabled then
                                            BtnSmartHitRun.BackgroundColor3 = C.accentOn
                                            BtnSmartHitRun.Text = "  🧠 Smart Farm: ON"
                                            BtnSmartHitRun.TextColor3 = Color3.new(1, 1, 1)
                                        end
                                        BtnUseMelee.BackgroundColor3 = SmartUseMelee and Color3.fromRGB(180, 80, 50) or C.card
                                        BtnUseMelee.Text = "  👊 Rotar Combate (Melee): " .. (SmartUseMelee and "SI" or "NO")
                                        BtnUseSword.BackgroundColor3 = SmartUseSword and Color3.fromRGB(40, 150, 200) or C.card
                                        BtnUseSword.Text = "  ⚔️ Rotar Espada (Sword): " .. (SmartUseSword and "SI" or "NO")
                                        BtnUseFruit.BackgroundColor3 = SmartUseFruit and Color3.fromRGB(150, 40, 200) or C.card
                                        BtnUseFruit.Text = "  🍎 Rotar Fruta (Fruit): " .. (SmartUseFruit and "SI" or "NO")
                                        BtnCalibMelee.Text = "  👊 Calibrado COMBATE [Y: -" .. SmartCalib_Melee_Y .. " | Z: " .. SmartCalib_Melee_Z .. "]"
                                        BtnCalibSword.Text = "  ⚔️ Calibrado ESPADA [Y: -" .. SmartCalib_Sword_Y .. " | Z: " .. SmartCalib_Sword_Z .. "]"
                                        BtnCalibFruit.Text = "  🍎 Calibrado FRUTA [Y: -" .. SmartCalib_Fruit_Y .. " | Z: " .. SmartCalib_Fruit_Z .. "]"
                                        BtnCalibMelee.BackgroundColor3 = Color3.fromRGB(30, 150, 80)
                                        BtnCalibSword.BackgroundColor3 = Color3.fromRGB(30, 150, 80)
                                        if SmartCalib_Fruit_Y > 3 then BtnCalibFruit.BackgroundColor3 = Color3.fromRGB(30, 150, 80) end
                                        if BlinkAttackEnabled then
                                            BtnBlink.Text = "  ⚡ Blink Fx (Sniper 45s): ON"
                                            BtnBlink.BackgroundColor3 = C.accentOn
                                        end
                                        if data.MemoryPoint and type(data.MemoryPoint) == "table" then
                                            MemoryPoint = Vector3.new(
                                                data.MemoryPoint.X or 0,
                                                data.MemoryPoint.Y or 0,
                                                data.MemoryPoint.Z or 0)
                                            MemStatusLabel.Text = "  📍 Punto: " ..
                                                math.floor(MemoryPoint.X) .. ", " ..
                                                math.floor(MemoryPoint.Y) .. ", " ..
                                                math.floor(MemoryPoint.Z)
                                        end
                                    end)
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
            if AutoFarm and not IsInPanicRecovery then
                local targetPoint = MemoryPoint
                local isScanner = false

                if not targetPoint and #ScannedTargetNames > 0 then
                    for _, m in pairs(GetMobCache()) do
                        for _, sn in ipairs(ScannedTargetNames) do
                            if m.Name == sn and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 and m:FindFirstChild("HumanoidRootPart") then
                                targetPoint = m.HumanoidRootPart.Position
                                isScanner = true
                                break
                            end
                        end
                        if isScanner then break end
                    end
                end

                if targetPoint then
                    local mob = GetNearestMob()
                    if ForceMemoryReturn then mob = nil end

                    if isScanner then
                        -- ===== SCANNER: VOLAR DIRECTO AL OBJETIVO =====
                        -- Independiente de si GetNearestMob lo encuentra o no.
                        -- Actualizar targetPoint con posicion live del mob en cache
                        for _, m in pairs(GetMobCache()) do
                            local matched = false
                            for _, sn in ipairs(ScannedTargetNames) do
                                if m.Name == sn and m:FindFirstChild("HumanoidRootPart") and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 then
                                    targetPoint = m.HumanoidRootPart.Position
                                    matched = true
                                    break
                                end
                            end
                            if matched then break end
                        end

                        local hrpW = char.HumanoidRootPart
                        local distToTarget = (hrpW.Position - targetPoint).Magnitude

                        if distToTarget > 15 then
                            StatusLabel.Text = "🔫 Volando a Objetivo... (" .. math.floor(distToTarget) .. "m)"
                            local dir = (targetPoint - hrpW.Position).Unit
                            local stepSize = math.min(BlinkStepValue or 45, distToTarget)
                            -- Auto-Ruta: SIEMPRE volar por encima (+15), nunca bajo tierra
                            local flyHeight = _G.AutoHuntActive and 15 or math.abs(OfsY)
                            local nextPos = hrpW.Position + dir * stepSize + Vector3.new(0, flyHeight, 0)
                            pcall(function() char:PivotTo(CFrame.lookAt(nextPos, nextPos + dir)) end)
                        else
                            StatusLabel.Text = "🎯 En posicion: " .. table.concat(ScannedTargetNames, "+")
                        end
                    else
                        -- ===== MEMORIA: lógica original =====
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
                            local distToMem = (hrpW.Position - targetPoint).Magnitude

                            if distToMem <= 15 then
                                IsWalkingToMemory = false
                                StatusLabel.Text = "📍 Llegamos al punto guardado"
                                LastRealDamageTime = os.clock()
                            else
                                StatusLabel.Text = "🏃 Volviendo a Marca... (" .. math.floor(distToMem) .. "m)"
                                local dir = (targetPoint - hrpW.Position).Unit
                                local stepSize = math.min(BlinkStepValue or 45, distToMem)
                                local nextPos = hrpW.Position + dir * stepSize
                                pcall(function() char:PivotTo(CFrame.lookAt(nextPos, nextPos + dir)) end)
                                pcall(function()
                                    if hrpW:FindFirstChildOfClass("BodyVelocity") then
                                        hrpW:FindFirstChildOfClass("BodyVelocity").Velocity = Vector3.new(0, 0, 0)
                                    end
                                end)
                            end
                        end
                    end -- end else (no isScanner)
                end     -- end if targetPoint
            else
                if IsWalkingToMemory then
                    IsWalkingToMemory = false
                end
            end
        end
    end
end)

task.spawn(LoadConfig)

-- =========================================================================
-- DETECCIÓN DE AUTO-HOP AL ARRANCAR
-- Si venimos de un server hop con ruta vinculada, auto-cargar y activar.
-- =========================================================================
task.delay(4, function()
    pcall(function()
        if readfile and isfile and isfile("AutoHopState.json") then
            local hs = game:GetService("HttpService")
            local raw = readfile("AutoHopState.json")
            local state = hs:JSONDecode(raw)
            if type(state) == "table" and state.RouteName and state.AutoStart then
                -- Cargar la ruta guardada
                local routeRaw = readfile(state.RouteName)
                local parsedRoute = hs:JSONDecode(routeRaw)
                if type(parsedRoute) == "table" then
                    _G.AutoHuntRoute = parsedRoute
                    -- Resetear todos los DeadTime para empezar fresco en nuevo servidor
                    for _, step in ipairs(_G.AutoHuntRoute) do
                        step.DeadTime = 0
                        step.WasAlive = false
                    end
                    _G.AutoHuntActive = true
                    _G.AutoHopEnabled = true
                    _G.AutoHopWithRoute = true
                    _G.AutoHopRouteName = state.RouteName
                    BtnStartHunt.Text = "⏹️ Detener Auto-Caza Múltiple"
                    BtnStartHunt.BackgroundColor3 = C.accentOn
                    BtnAutoHop.Text = "🔄 Auto-Hop: ON"
                    BtnAutoHop.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
                    BtnHopRoute.Text = "🔗 Vincular Hop + Auto-Ruta: ON"
                    BtnHopRoute.BackgroundColor3 = Color3.fromRGB(120, 60, 180)
                    HuntStatusInfo.Text = "  🔄 Auto-Hop: Ruta '" .. state.RouteName .. "' cargada automáticamente."
                end
            end
            -- Borrar el archivo para no repetir en caso de crash
            pcall(function() delfile("AutoHopState.json") end)
        end
    end)
end)

-- =========================================================================
-- MOTOR INTELIGENTE DE AUTO-CAZA
-- =========================================================================
task.spawn(function()
    while true do
        task.wait(1)
        if _G.AutoHuntActive and _G.AutoHuntRoute and #_G.AutoHuntRoute > 0 then
            local currentClock = os.time()
            local targetStep = nil

            -- 1. Identificar Boss listo (cooldown 5 mins superado)
            -- PASADA 1: Priorizar bosses EN LA ISLA ACTUAL (evita viajar innecesariamente)
            for _, step in ipairs(_G.AutoHuntRoute) do
                local dt = step.DeadTime or 0
                local cd = step.Cooldown or 300
                if (currentClock - dt) >= cd and step.Island == _G.CurrentIslandContext then
                    targetStep = step
                    break
                end
            end
            -- PASADA 2: Si no hay boss local disponible, buscar en OTRAS islas
            if not targetStep then
                for _, step in ipairs(_G.AutoHuntRoute) do
                    local dt = step.DeadTime or 0
                    local cd = step.Cooldown or 300
                    if (currentClock - dt) >= cd then
                        targetStep = step
                        break
                    end
                end
            end

            if targetStep then
                local bossAlive = false
                local bossChar = nil

                -- Chequeo visual en el server/isla actual
                for _, m in pairs(GetMobCache()) do
                    if m.Name == targetStep.Boss and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 and m:FindFirstChild("HumanoidRootPart") then
                        bossAlive = true
                        bossChar = m
                        break
                    end
                end

                if bossAlive then
                    -- ================== FASE 4: COMBATE / AutoFarm Nativo ==================
                    -- El AutoFarm nativo ya maneja el vuelo/movimiento al mob. Solo configuramos el objetivo.
                    while #ScannedTargetNames > 0 do table.remove(ScannedTargetNames, 1) end
                    table.insert(ScannedTargetNames, targetStep.Boss)

                    -- Prevenir el glitch de "vuelta a memoria" forzando reseteo
                    LastRealDamageTime = os.clock()
                    IsWalkingToMemory = false
                    if bossChar and bossChar:FindFirstChild("HumanoidRootPart") then
                        MemoryPoint = bossChar.HumanoidRootPart.Position
                    end

                    if not AutoFarm then pcall(ToggleAutoFarm) end

                    -- Esperamos hasta que muera el boss
                    while bossAlive and _G.AutoHuntActive do
                        task.wait(1.5)
                        bossAlive = false
                        for _, m in pairs(GetMobCache()) do
                            if m.Name == targetStep.Boss and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 then
                                bossAlive = true
                                break
                            end
                        end
                    end

                    -- Murió (O apagaron el cazador)
                    if not bossAlive then
                        targetStep.DeadTime = os.time()
                        if AutoFarm then pcall(ToggleAutoFarm) end -- Apagamos el Autofarm estándar en transición
                        task.wait(1)

                        -- ======= ATERRIZAR EN EL SUELO =======
                        -- Buscar el piso debajo del personaje y pararse encima
                        pcall(function()
                            local charLand = LP.Character
                            local hrpLand = charLand and charLand:FindFirstChild("HumanoidRootPart")
                            if hrpLand then
                                local rayParams = RaycastParams.new()
                                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                                rayParams.FilterDescendantsInstances = {charLand}
                                -- Raycast hacia abajo para encontrar el suelo
                                local rayResult = Workspace:Raycast(hrpLand.Position, Vector3.new(0, -300, 0), rayParams)
                                if rayResult then
                                    -- Pararse 3 studs encima del punto de colisión
                                    local groundPos = rayResult.Position + Vector3.new(0, 3, 0)
                                    charLand:PivotTo(CFrame.new(groundPos))
                                    -- Restaurar cámara al personaje
                                    pcall(function()
                                        Workspace.CurrentCamera.CameraSubject = charLand:FindFirstChild("Humanoid")
                                    end)
                                end
                            end
                        end)
                        task.wait(2)
                    end
                else
                    -- Boss no visible en el mob cache. ¿Necesitamos viajar?
                    local needTravel = true

                    -- Detectar si ya estamos en la isla del boss
                    if targetStep.Island and targetStep.Island ~= "" then
                        if _G.CurrentIslandContext == targetStep.Island then
                            -- Ya estamos en esta isla, no viajar
                            needTravel = false
                        elseif _G.CurrentIslandContext == "Desconocido" or _G.CurrentIslandContext == "" then
                            -- Isla desconocida: buscar si el modelo del boss existe en workspace
                            -- (aunque esté muerto). Si existe, estamos en la isla correcta.
                            pcall(function()
                                for _, obj in pairs(Workspace:GetDescendants()) do
                                    if obj:IsA("Model") and obj.Name == targetStep.Boss then
                                        needTravel = false
                                        -- Bonus: auto-detectar la isla
                                        _G.CurrentIslandContext = targetStep.Island
                                        break
                                    end
                                end
                            end)
                        end
                    end

                    if not needTravel then
                        -- Ya estamos en la isla correcta, boss muerto o fuera de rango
                        targetStep.DeadTime = os.time()
                    else
                    -- ================== FASE 2: Navegación Viajera ==================
                    -- Solo viajamos si confirmamos que el boss está en OTRA isla
                    local nearestPortal = nil
                    local shortestDist = math.huge
                    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

                    if hrp then
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj:IsA("ProximityPrompt") and (obj.ActionText:lower():match("map") or obj.Name:lower():match("portal") or obj.ActionText:lower():match("teleport")) then
                                local pPart = obj.Parent
                                if pPart and pPart:IsA("BasePart") then
                                    local dist = (pPart.Position - hrp.Position).Magnitude
                                    if dist < shortestDist then
                                        shortestDist = dist
                                        nearestPortal = obj
                                    end
                                end
                            end
                        end
                    end

                    if nearestPortal and nearestPortal.Parent then
                        -- Volamos suavemente con NoClip hasta el Portal
                        _G.GhostProtocolEnabled = true
                        GhostProtocolEnabled = true  -- sincronizar con variable local del Ghost loop
                        local targetCF = nearestPortal.Parent.CFrame * CFrame.new(0, 3, 0)

                        while hrp and (hrp.Position - targetCF.Position).Magnitude > 6 and _G.AutoHuntActive do
                            task.wait()
                            hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local flyDist = (hrp.Position - targetCF.Position).Magnitude
                                local flyStep = math.clamp(50 / flyDist, 0, 1) -- 50 studs de velocidad suave
                                LP.Character:PivotTo(hrp.CFrame:Lerp(targetCF, flyStep))
                                if hrp:FindFirstChildOfClass("BodyVelocity") then
                                    hrp:FindFirstChildOfClass("BodyVelocity").Velocity = Vector3.new(0, 0, 0)
                                end
                            end
                        end

                        task.wait(0.5)
                        -- Al estar físicamente en el Portal, accionamos el Prompt para abrir la UI como una persona real
                        -- Quitamos la duración de mantener pulsado ('E') para accionar instantáneamente
                        if nearestPortal:IsA("ProximityPrompt") then
                            local oldHold = nearestPortal.HoldDuration
                            nearestPortal.HoldDuration = 0
                            task.wait(0.1)
                            pcall(function() fireproximityprompt(nearestPortal) end)
                            task.wait(0.1)
                            nearestPortal.HoldDuration = oldHold
                        else
                            pcall(function() fireproximityprompt(nearestPortal) end)
                        end
                        task.wait(1.5) -- Esperamos que la ventana visual de las islas cargue en nuestra pantalla

                        -- Simulamos el clic a la UI dándole a la Isla seleccionada (Validado desde el portal)
                        local rs = game:GetService("ReplicatedStorage")
                        pcall(function()
                            if rs:FindFirstChild("Remotes") and rs.Remotes:FindFirstChild("TeleportToPortal") then
                                rs.Remotes.TeleportToPortal:FireServer(targetStep.Island)
                            end
                        end)
                    else
                        -- Fallback si el creador esconde el portal pero estamos en la isla (muy raro)
                        local rs = game:GetService("ReplicatedStorage")
                        pcall(function()
                            if rs:FindFirstChild("Remotes") and rs.Remotes:FindFirstChild("TeleportToPortal") then
                                rs.Remotes.TeleportToPortal:FireServer(targetStep.Island)
                            end
                        end)
                    end
                    task.wait(3) -- Esperamos pantalla de carga

                    -- Forzamos ocultación de un submenú "Cancelar" o "X" por si la UI se queda bug visualmente al viajar
                    pcall(function()
                        local playerGui = LP.PlayerGui
                        for _, btn in pairs(playerGui:GetDescendants()) do
                            if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                                local btnText = (btn:IsA("TextButton") and btn.Text:lower()) or btn.Name:lower()
                                if btnText:match("cancel") or btnText:match("close") or btnText:match("cerrar") or btnText == "x" then
                                    local parent = btn
                                    while parent and parent.ClassName ~= "ScreenGui" do
                                        if type(parent) == "userdata" and parent:IsA("Frame") then parent.Visible = false end
                                        parent = parent.Parent
                                    end
                                end
                            end
                        end
                    end)

                    -- Espera OBLIGATORIA de 5 SEGUNDOS al lado del portal recién llegados a la nueva isla
                    task.wait(5)

                    -- Re-Chequeo tras espera por si recién spawnearon los modelos
                    local postAlive = false
                    local postBossModel = nil
                    for _, m in pairs(GetMobCache()) do
                        if m.Name == targetStep.Boss and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 then
                            postAlive = true
                            if m:FindFirstChild("HumanoidRootPart") then postBossModel = m end
                            break
                        end
                    end

                    if postAlive and postBossModel and postBossModel:FindFirstChild("HumanoidRootPart") then
                        -- ========= FASE 3: Acercamiento Segmentado (post-viaje) =========
                        -- Volar en tramos de ~80 studs con pausa de 2s en el piso entre cada uno
                        local hrpA = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                        if hrpA then
                            local bossPos = postBossModel.HumanoidRootPart.Position
                            local totalDist = (hrpA.Position - bossPos).Magnitude
                            local segmentSize = 80

                            while totalDist > 35 and _G.AutoHuntActive do
                                local dir = (bossPos - hrpA.Position).Unit
                                local hopLen = math.min(segmentSize, totalDist - 25)
                                local nextPt = hrpA.Position + dir * hopLen
                                local dest = CFrame.new(nextPt + Vector3.new(0, 8, 0))

                                -- Vuelo corto con NoClip
                                _G.GhostProtocolEnabled = true
                                GhostProtocolEnabled = true
                                while hrpA and (hrpA.Position - dest.Position).Magnitude > 6 and _G.AutoHuntActive do
                                    task.wait()
                                    hrpA = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                                    pcall(function() workspace.CurrentCamera.CameraSubject = LP.Character.Humanoid end)
                                    if hrpA then
                                        local fd = (hrpA.Position - dest.Position).Magnitude
                                        local fs = math.clamp(40 / fd, 0, 1)
                                        LP.Character:PivotTo(hrpA.CFrame:Lerp(dest, fs))
                                        if hrpA:FindFirstChildOfClass("BodyVelocity") then
                                            hrpA:FindFirstChildOfClass("BodyVelocity").Velocity = Vector3.new(0, 0, 0)
                                        end
                                    end
                                end

                                -- Aterrizar y pausar 2 segundos (simular humano)
                                _G.GhostProtocolEnabled = false
                                GhostProtocolEnabled = false
                                task.wait(2)

                                -- Recalcular distancia con posición live del boss
                                hrpA = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                                if not hrpA then break end
                                pcall(function()
                                    if postBossModel and postBossModel:FindFirstChild("HumanoidRootPart") then
                                        bossPos = postBossModel.HumanoidRootPart.Position
                                    end
                                end)
                                totalDist = (hrpA.Position - bossPos).Magnitude
                            end
                            _G.GhostProtocolEnabled = false
                            GhostProtocolEnabled = false
                        end
                    elseif not postAlive then
                        -- Si NO está después de viajar, otra persona en el servidor lo mató antes
                        targetStep.DeadTime = os.time()
                    end
                    end
                end
            end
        end

        -- ============ AUTO-HOP: INDEPENDIENTE (funciona con o sin Auto-Caza) ============
        if _G.AutoHopEnabled and _G.AutoHuntRoute and #_G.AutoHuntRoute > 0 then
            local hopClock = os.time()
            local allOnCooldown = true
            for _, step in ipairs(_G.AutoHuntRoute) do
                local dt = step.DeadTime or 0
                local cd = step.Cooldown or 300
                if (hopClock - dt) >= cd then
                    allOnCooldown = false
                    break
                end
            end

            if allOnCooldown then
                HuntStatusInfo.Text = "  🔄 Todos en cooldown. Cambiando de servidor en 5s..."
                task.wait(5)

                pcall(function()
                    -- Guardar estado para el próximo servidor
                    if _G.AutoHopWithRoute and writefile then
                        local hs = game:GetService("HttpService")
                        local routeName = _G.AutoHopRouteName
                        if routeName == "" then routeName = "RutaDefault.json" end
                        if not routeName:match("%.json$") then routeName = routeName .. ".json" end
                        local state = { RouteName = routeName, AutoStart = true }
                        writefile("AutoHopState.json", hs:JSONEncode(state))
                    end

                    -- Re-ejecutar script tras teleport (si el executor lo soporta)
                    if queue_on_teleport then
                        queue_on_teleport('-- Auto-Hop re-exec placeholder')
                    end

                    -- Teleport a nuevo servidor del mismo juego
                    local TS = game:GetService("TeleportService")
                    TS:Teleport(game.PlaceId)
                end)
            end
        end
    end
end)
