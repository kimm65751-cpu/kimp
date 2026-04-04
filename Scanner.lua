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
    bg       = Color3.fromRGB(22, 24, 30),
    sidebar  = Color3.fromRGB(28, 30, 38),
    panel    = Color3.fromRGB(30, 33, 42),
    accent   = Color3.fromRGB(100, 130, 255),
    accentOn = Color3.fromRGB(90, 210, 140),
    accentOff= Color3.fromRGB(60, 65, 80),
    red      = Color3.fromRGB(200, 80, 90),
    title    = Color3.fromRGB(180, 190, 230),
    text     = Color3.fromRGB(200, 205, 220),
    muted    = Color3.fromRGB(110, 115, 135),
    card     = Color3.fromRGB(38, 42, 55),
    border   = Color3.fromRGB(55, 60, 80),
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
            ScannedTargetPos = ScannedTargetPos and {X=ScannedTargetPos.X, Y=ScannedTargetPos.Y, Z=ScannedTargetPos.Z} or nil,
            PanicThreshold = PanicThreshold,
            ReturnHealthThreshold = ReturnHealthThreshold,
            MobMagnetEnabled = MobMagnetEnabled,
            AutoSkillEnabled = AutoSkillEnabled,
            TargetBosses = TargetBosses,
            FarmMode = FarmMode
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
    tb.TextColor3 = Color3.new(1,1,1)
    tb.LayoutOrder = order
    tb.BorderSizePixel = 0
    tb.Name = "Tab_" .. tabName
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)
    return tb
end

local TabFarm = MakeTabBtn("⚔️", "Farm", 1)
local TabTP   = MakeTabBtn("🗺️", "Teleport", 2)

-- ======================== PANEL DE CONTENIDO ========================
local ContentPanel = Instance.new("Frame", MF)
ContentPanel.Size = UDim2.new(1, -62, 1, -60)
ContentPanel.Position = UDim2.new(0, 60, 0, 58)
ContentPanel.BackgroundColor3 = C.panel
ContentPanel.BorderSizePixel = 0
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
TabTP.MouseButton1Click:Connect(function() SwitchTab("Teleport") end)

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
local BtnToggle = ToggleButton(FarmPage, "► Iniciar Auto-Farm", 2, C.red)
BtnToggle.TextSize = 15
BtnToggle.Font = Enum.Font.GothamBold
local BtnHeight = ToggleButton(FarmPage, "Posición: ☁️ Arriba", 3)
local BtnMagnet = ToggleButton(FarmPage, "🧲 Imán de Mobs", 4)
local BtnSkill  = ToggleButton(FarmPage, "🔥 Auto Skill (X)", 5)
local BtnBoss   = ToggleButton(FarmPage, "🎯 Cazar Bosses: Normal", 6)

SectionLabel(FarmPage, "ESCÁNER OBJETIVO", 7)
local BtnScan = Instance.new("TextButton", FarmPage)
BtnScan.Size = UDim2.new(0.95, 0, 0, 30)
BtnScan.BackgroundColor3 = C.accent
BtnScan.TextColor3 = Color3.new(1,1,1)
BtnScan.Font = Enum.Font.GothamBold
BtnScan.TextSize = 12
BtnScan.Text = "  🔍 Escanear Mobs/Bosses del Mapa"
BtnScan.TextXAlignment = Enum.TextXAlignment.Left
BtnScan.LayoutOrder = 8
BtnScan.BorderSizePixel = 0
Instance.new("UICorner", BtnScan).CornerRadius = UDim.new(0, 5)

local ScanScroll = Instance.new("ScrollingFrame", FarmPage)
ScanScroll.Size = UDim2.new(0.95, 0, 0, 100)
ScanScroll.BackgroundColor3 = C.card
ScanScroll.BorderSizePixel = 0
ScanScroll.LayoutOrder = 9
ScanScroll.ScrollBarThickness = 3
Instance.new("UICorner", ScanScroll).CornerRadius = UDim.new(0, 5)
local ScanLayout = Instance.new("UIListLayout", ScanScroll)

local StatusScan = Instance.new("TextLabel", FarmPage)
StatusScan.Size = UDim2.new(0.95, 0, 0, 16)
StatusScan.BackgroundTransparency = 1
StatusScan.TextColor3 = C.muted
StatusScan.Font = Enum.Font.Gotham
StatusScan.TextSize = 11
StatusScan.Text = "  📌 Objetivo Libre (Todo)"
StatusScan.TextXAlignment = Enum.TextXAlignment.Left
StatusScan.LayoutOrder = 10

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
-- ========== TAB 2: TELEPORT ==========
-- =======================================================================================
local TPPage = MakeScrollPage("Teleport")

local IsTraveling = false
local AutoSnipeFruit = false

local function CancelTravel()
    IsTraveling = false
    StatusLabel.Text = "Status: Inactivo"
end

local function SafeTravel(targetVector3, destinationName)
    CancelTravel()
    task.wait(0.1)
    IsTraveling = true
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    AutoFarm = false
    BtnToggle.BackgroundColor3 = C.red
    BtnToggle.Text = "  ► Iniciar Auto-Farm"
    StatusLabel.Text = "✈️ Viajando a: " .. destinationName
    task.spawn(function()
        while IsTraveling do
            pcall(function()
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (hrp.Position - targetVector3).Magnitude
                    if dist <= 15 then
                        IsTraveling = false
                        StatusLabel.Text = "✅ Llegada a " .. destinationName
                        char:PivotTo(CFrame.new(targetVector3))
                    else
                        -- Vuelo ultrarrápido y dinámico al límite pre-band (150 m/s)
                        local step = math.clamp(150 / dist, 0, 1) 
                        local wave = math.sin(os.clock() * 6) * 2
                        local tLerp = hrp.CFrame:Lerp(CFrame.new(targetVector3), step)
                        char:PivotTo(tLerp * CFrame.new(0, wave, 0))
                    end
                end
            end)
            task.wait(0.05) -- Actualiza rapidísimo para un viaje smooth
        end
    end)
end


local tpOrder = 0
local function TPSection(text)
    tpOrder = tpOrder + 1
    SectionLabel(TPPage, text, tpOrder * 100)
end

local function TPButton(text, color, mode, target)
    tpOrder = tpOrder + 1
    local btn = Instance.new("TextButton", TPPage)
    btn.Size = UDim2.new(0.95, 0, 0, 32)
    btn.BackgroundColor3 = color or C.card
    btn.TextColor3 = C.text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.Text = "  " .. text
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = tpOrder * 100
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    btn.MouseButton1Click:Connect(function()
        if mode == "V3" then
            SafeTravel(target, text)
        elseif mode == "NPC" then
            local obj = nil
            for _, v in pairs(Workspace:GetDescendants()) do
                if v.Name:lower():match(target:lower()) then
                    if v:IsA("Model") and (v.PrimaryPart or v:FindFirstChild("HumanoidRootPart")) then obj = v break end
                end
            end
            if obj then
                local p = obj.PrimaryPart and obj.PrimaryPart.Position or obj:FindFirstChild("HumanoidRootPart").Position
                SafeTravel(p, text)
            else StatusLabel.Text = "❌ NPC no cargado aún." end
        elseif mode == "Cancel" then CancelTravel()
        elseif mode == "Snipe" then
            AutoSnipeFruit = not AutoSnipeFruit
            if AutoSnipeFruit then
                btn.BackgroundColor3 = C.accentOn; btn.Text = "  ✅ Auto-Recolector: ACTIVO"
            else
                btn.BackgroundColor3 = C.card; btn.Text = "  ✅ Auto-Recolector (Sniper): OFF"
            end
        end
    end)
    return btn
end

local function NPCGuideEntry(npcName, desc, pos, order)
    local card = Instance.new("Frame", TPPage)
    card.Size = UDim2.new(0.95, 0, 0, 52)
    card.BackgroundColor3 = Color3.fromRGB(32, 36, 48)
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
    
    local nameL = Instance.new("TextLabel", card)
    nameL.Size = UDim2.new(0.65, 0, 0, 22)
    nameL.Position = UDim2.new(0, 10, 0, 4)
    nameL.BackgroundTransparency = 1
    nameL.Text = npcName
    nameL.TextColor3 = Color3.fromRGB(170, 200, 255)
    nameL.Font = Enum.Font.GothamBold
    nameL.TextSize = 12
    nameL.TextXAlignment = Enum.TextXAlignment.Left
    
    local descL = Instance.new("TextLabel", card)
    descL.Size = UDim2.new(1, -16, 0, 20)
    descL.Position = UDim2.new(0, 10, 0, 28)
    descL.BackgroundTransparency = 1
    descL.Text = desc
    descL.TextColor3 = C.muted
    descL.Font = Enum.Font.Gotham
    descL.TextSize = 11
    descL.TextXAlignment = Enum.TextXAlignment.Left
    descL.TextWrapped = true
    
    local goBtn = Instance.new("TextButton", card)
    goBtn.Size = UDim2.new(0, 46, 0, 24)
    goBtn.Position = UDim2.new(1, -54, 0, 4)
    goBtn.BackgroundColor3 = C.accent
    goBtn.Text = "IR"
    goBtn.TextColor3 = Color3.new(1,1,1)
    goBtn.Font = Enum.Font.GothamBold
    goBtn.TextSize = 12
    goBtn.BorderSizePixel = 0
    Instance.new("UICorner", goBtn).CornerRadius = UDim.new(0, 4)
    goBtn.MouseButton1Click:Connect(function() 
        SafeTravel(pos, npcName)
    end)
end

-- ———————————————— ISLAS ————————————————
TPSection("🌍 ISLAS")
TPButton("🌀 Starter Island", Color3.fromRGB(35,45,65), "V3", Vector3.new(-71,-2,-299))
TPButton("🏖️ Sand Island", Color3.fromRGB(65,55,35), "V3", Vector3.new(17,-6,-305))
TPButton("🌴 Jungle Island", Color3.fromRGB(30,65,35), "V3", Vector3.new(-392,-2,407))
TPButton("🌵 Desert Island", Color3.fromRGB(75,55,30), "V3", Vector3.new(-688,-1,-287))
TPButton("❄️ Snow Island", Color3.fromRGB(55,65,85), "V3", Vector3.new(-182,-1,-998))
TPButton("⚓ Sailor Island", Color3.fromRGB(35,45,75), "V3", Vector3.new(182,5,669))
TPButton("👻 Hollow Island", Color3.fromRGB(55,35,65), "V3", Vector3.new(-542,-1,872))
TPButton("🏔️ Shibuya Island", Color3.fromRGB(50,45,55), "V3", Vector3.new(1269,13,233))
TPButton("🏙️ Shinjuku Island", Color3.fromRGB(55,40,45), "V3", Vector3.new(189,-1,-1643))
TPButton("🏫 Academy Island", Color3.fromRGB(55,55,35), "V3", Vector3.new(962,-2,1053))
TPButton("🗡️ Lawless Island", Color3.fromRGB(40,40,60), "V3", Vector3.new(209,-4,1673))
TPButton("🧪 Slime Island", Color3.fromRGB(35,60,60), "V3", Vector3.new(-982,-2,275))
TPButton("🥷 Ninja Island", Color3.fromRGB(55,35,50), "V3", Vector3.new(-1621,10,-575))

-- ———————————————— DUNGEONS ————————————————
TPSection("🔥 DUNGEONS & EVENTOS")
TPButton("👹 Boss Rush", Color3.fromRGB(75,35,35), "V3", Vector3.new(106,6,840))
TPButton("⚖️ Judgement", Color3.fromRGB(60,30,45), "V3", Vector3.new(-1029,-2,-989))
TPButton("🧱 Infinite Tower", Color3.fromRGB(65,50,30), "V3", Vector3.new(1276,-4,-1474))
TPButton("⏳ Dungeon", Color3.fromRGB(50,40,60), "V3", Vector3.new(1272,5,-897))
TPButton("💀 Boss Más Fuerte", Color3.fromRGB(80,30,30), "V3", Vector3.new(593,-2,-1052))

-- ———————————————— NPCs TELEPORT DIRECTO ————————————————
TPSection("🤖 NPCs — TELEPORT DIRECTO")
TPButton("📜 Quest 1 (Lvl 0-99)", C.card, "V3", Vector3.new(171,16,-215))
TPButton("📜 Quest 2 (Lvl 100-249)", C.card, "V3", Vector3.new(-8,-3,-203))
TPButton("📜 Quest 3 (Lvl 250-499)", C.card, "V3", Vector3.new(-520,-2,434))
TPButton("📜 Quest 4 (Lvl 500-749)", C.card, "V3", Vector3.new(-468,18,480))
TPButton("📜 Quest 5 (Lvl 750-999)", C.card, "V3", Vector3.new(-688,-3,-461))
TPButton("📜 Quest 6 (Lvl 1000-1499)", C.card, "V3", Vector3.new(-864,-5,-386))
TPButton("📜 Quest 7 (Lvl 1500-1999)", C.card, "V3", Vector3.new(-389,-2,-946))
TPButton("📜 Quest 8 (Lvl 2000-2999)", C.card, "V3", Vector3.new(-551,22,-1026))
TPButton("📜 Quest 9 (Lvl 3000-3999)", C.card, "V3", Vector3.new(1419,8,372))
TPButton("📜 Quest 10 (Lvl 4000-5000)", C.card, "V3", Vector3.new(1604,8,429))
TPButton("📜 Quest 11 (Lvl 5000-6250)", C.card, "V3", Vector3.new(-286,-4,1038))
TPButton("📜 Quest 12 (Lvl 6250-7000)", C.card, "V3", Vector3.new(626,1,-1610))
TPButton("📜 Quest 13 (Lvl 7000-8000)", C.card, "V3", Vector3.new(-20,1,-1986))
TPButton("📜 Quest 14 (Lvl 8000-9000)", C.card, "V3", Vector3.new(-1188,17,338))
TPButton("📜 Quest 15 (Lvl 9000-10000)", C.card, "V3", Vector3.new(1028,1,1241))
TPButton("📜 Quest 18 (Lvl 11500-12000)", C.card, "V3", Vector3.new(-1787,6,-745))
TPButton("📜 Quest 19 (Lvl 12000+)", C.card, "V3", Vector3.new(67,-2,1758))

-- ———————————————— FRUTAS ————————————————
TPSection("🍇 FRUTAS")
TPButton("💎 Vendedor Frutas (Gemas) — Sailor", Color3.fromRGB(55, 35, 45), "V3", Vector3.new(400,2,752))
TPButton("🪙 Vendedor Frutas (Monedas) — Sailor", Color3.fromRGB(55, 45, 35), "V3", Vector3.new(408,2,802))
TPButton("🎯 Auto-Recolector (Sniper): OFF", Color3.fromRGB(30, 60, 40), "Snipe", "")
TPButton("🚫 DETENER VUELO", C.red, "Cancel", "")

-- ———————————————— MINI-GUÍA DE NPCs ————————————————
TPSection("📖 MINI-GUÍA — NPCs IMPORTANTES")

local g = 9000
NPCGuideEntry("🥊 Haki Master", "Te enseña Haki. Debes tener nivel suficiente. Ubicado en Snow Island. Te da el poder de Haki para golpear usuarios de Logia.", Vector3.new(-499,23,-1253), g+1)
NPCGuideEntry("🐉 Dragon Slayer Master", "Questline de Ragna. Desbloquea buffs de Dragon Slayer al completar sus misiones. Snow Island.", Vector3.new(-273,-5,-1354), g+2)
NPCGuideEntry("👤 Shadow Master", "Questline Shadow. Desbloquea buffs de Shadow. Se encuentra en Starter Island.", Vector3.new(335,25,-378), g+3)
NPCGuideEntry("👑 Shadow Monarch Master", "Buff avanzado de Shadow Monarch. Starter Island, zona alta.", Vector3.new(243,26,-84), g+4)
NPCGuideEntry("🧬 Manipulator Master", "Questline Aizen. Desbloquea buffs de Manipulator. Hollow Island, zona lejana.", Vector3.new(-893,24,1229), g+5)
NPCGuideEntry("⚡ Atomic Master", "Questline Atomic. Desbloquea buffs atómicos. Lawless Island.", Vector3.new(216,-6,2126), g+6)
NPCGuideEntry("🌙 Moon Slayer F Move", "Mastery de movimiento F de Moon Slayer. Zona de Boss (isla principal).", Vector3.new(831,57,-984), g+7)
NPCGuideEntry("✨ Blessed Maiden F Move", "Mastery de movimiento F de Blessed Maiden. Cerca del Portal Boss.", Vector3.new(940,5,-1067), g+8)
NPCGuideEntry("⚔️ Corrupted Excalibur F Move", "Mastery de Saber Alter. Zona profunda de Boss Island.", Vector3.new(694,1,-1227), g+9)
NPCGuideEntry("♾️ Strongest Of Today Domain", "Dominio de Gojo. Requiere arma específica. Shinjuku Island.", Vector3.new(55,41,-2067), g+10)
NPCGuideEntry("👹 Strongest In History Domain", "Dominio de Sukuna. Requiere arma específica. Shinjuku Island.", Vector3.new(598,30,-2055), g+11)
NPCGuideEntry("🥷 Strongest Shinobi F Move", "Mastery de Shinobi. Ninja Island, zona más profunda.", Vector3.new(-1981,25,-374), g+12)
NPCGuideEntry("📦 Boss Rush Shop", "Tienda de Boss Rush. Compra recompensas con tokens de Boss Rush.", Vector3.new(104,6,826), g+13)
NPCGuideEntry("💎 Gems Fruit Dealer", "Compra frutas con Gemas. Sailor Island, cerca del puerto.", Vector3.new(400,2,752), g+14)
NPCGuideEntry("🪙 Coins Fruit Dealer", "Compra frutas con Monedas. Sailor Island, junto al Gem Dealer.", Vector3.new(408,2,802), g+15)
NPCGuideEntry("😈 Demonite Quest (Anos)", "Quest especial del Demonite. Academy Island.", Vector3.new(727,-2,1273), g+16)
NPCGuideEntry("🔮 Hogyoku Quest", "Quest especial del Hogyoku. Lawless Island, zona oculta.", Vector3.new(-380,8,1529), g+17)


-- ========== VARIABLES OCULTAS PARA COMPATIBILIDAD BACKEND ==========
local BtnSpy = Instance.new("TextButton")
BtnSpy.Visible = false
local BtnAutoTour = Instance.new("TextButton")
BtnAutoTour.Visible = false
local BtnTravelMenu = Instance.new("TextButton")
BtnTravelMenu.Visible = false
local TravelFrame = Instance.new("Frame")
TravelFrame.Visible = false
local TBtnClose = Instance.new("TextButton")
TBtnClose.Visible = false
local LogFrame = Instance.new("Frame")
LogFrame.Visible = false
local LogScroll = Instance.new("ScrollingFrame")
local LogLayout = Instance.new("UIListLayout", LogScroll)
LogLayout.Padding = UDim.new(0, 3)
local function AddLog(text, color) end
local TScroll = Instance.new("ScrollingFrame")

-- ========== HOTKEY: Tecla * para Toggle GUI ==========
uis.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.KeypadMultiply or input.KeyCode == Enum.KeyCode.Eight then
        -- KeypadMultiply = tecla * del numpad, Eight+Shift = * en teclado normal
        if input.KeyCode == Enum.KeyCode.Eight and not uis:IsKeyDown(Enum.KeyCode.LeftShift) and not uis:IsKeyDown(Enum.KeyCode.RightShift) then return end
        MF.Visible = not MF.Visible
        if not MF.Visible then
            if CodesFrame then pcall(function() CodesFrame.Visible = false end) end
        end
    end
end)

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
CodeBackBtn.TextColor3 = Color3.new(1,1,1)
CodeBackBtn.Font = Enum.Font.Gotham
CodeBackBtn.TextSize = 12
CodeBackBtn.Text = "Cerrar"

local CopyAllBtn = Instance.new("TextButton", CodesFrame)
CopyAllBtn.Size = UDim2.new(0.4, 0, 0, 25)
CopyAllBtn.Position = UDim2.new(0.55, 0, 0, 315)
CopyAllBtn.BackgroundColor3 = Color3.fromRGB(20, 100, 40)
CopyAllBtn.TextColor3 = Color3.new(1,1,1)
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
            cLabel.TextColor3 = Color3.new(1,1,1)
            cLabel.Font = Enum.Font.Code
            cLabel.TextSize = 12
            cLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local cCopy = Instance.new("TextButton", cFrame)
            cCopy.Size = UDim2.new(0.25, 0, 0.7, 0)
            cCopy.Position = UDim2.new(0.7, 0, 0.15, 0)
            cCopy.BackgroundColor3 = Color3.fromRGB(40,40,60)
            cCopy.TextColor3 = Color3.new(1,1,1)
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
        err.TextColor3 = Color3.new(1,0,0)
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
    if AutoFarm and LP.Character then
        -- 1. Noclip: Apagar CanCollide para atravesar todo
        for _, part in pairs(LP.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        
        -- 2. Anti Gravedad: Para que no caigas al suelo mientras estás flotando arriba del mob
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(0,0,0)
        end
        
        -- El Imán Magnético Lerp fue eliminado por buguear las físicas. 
        -- Ahora se usa el Aggro IA en el Motor de Ataque.
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
                    task.wait(2)
                    continue
                end

                -- Equipar espada/arma si no tenemos nada en las manos
                local tool = char:FindFirstChildOfClass("Tool")
                if not tool then
                    -- Buscamos prioridad de espadas
                    for _, t in pairs(LP.Backpack:GetChildren()) do
                        if t:IsA("Tool") and (t.Name:lower():match("katana") or t.Name:lower():match("sword") or t.Name:lower():match("blade")) then
                            tool = t
                            break
                        end
                    end
                    -- Si no hay espadas, agarramos la primera herramienta que NO sea 'Combat' o 'Puños'
                    if not tool then
                        for _, t in pairs(LP.Backpack:GetChildren()) do
                            if t:IsA("Tool") and not t.Name:lower():match("combat") then
                                tool = t
                                break
                            end
                        end
                    end
                    -- Último recurso
                    if not tool then tool = LP.Backpack:FindFirstChildOfClass("Tool") end
                    
                    if tool then char.Humanoid:EquipTool(tool) end
                end

                local mob = GetNearestMob()
                
                if not mob and ScannedTargetName and ScannedTargetPos and not IsInPanicRecovery then
                    -- MOB NO CARGADO, VOLAR A SUS COORDENADAS PARA QUE EL SERVIDOR LO ACTIVE!
                    StatusLabel.Text = " Status: Volando a Radar..."
                    local d = (char.HumanoidRootPart.Position - ScannedTargetPos).Magnitude
                    if d > 10 then
                        local step = math.clamp(120 / d, 0, 1)
                        char:PivotTo(char.HumanoidRootPart.CFrame:Lerp(CFrame.new(ScannedTargetPos), step))
                    end
                end
                
                if mob then
                    -- ==============================================
                    -- DETECTOR DE ATASCO DE DAÑO (Despertador Físico)
                    -- ==============================================
                    if not IsInPanicRecovery then
                        if LastMobTracker ~= mob then
                            LastMobTracker = mob
                            CurrentMobHealth = mob.Humanoid.Health
                            MobHitTimer = os.clock()
                            
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
                        if hpRatio <= PanicThreshold and char.Humanoid.Health > 0 then
                            IsInPanicRecovery = true
                        elseif IsInPanicRecovery and hpRatio >= ReturnHealthThreshold then
                            IsInPanicRecovery = false -- Vuelve al combate
                        end
                        
                        if IsInPanicRecovery then
                            StatusLabel.Text = "Status: 🛡️ PÁNICO (CURANDO " .. math.floor(hpRatio*100) .. "%)"
                            local escapeCF = CFrame.new(mobHrp.Position) * CFrame.new(0, 50, 0)
                            
                            pcall(function()
                                local d = (hrp.Position - escapeCF.Position).Magnitude
                                local step = math.clamp(20 / d, 0, 1)
                                char:PivotTo(hrp.CFrame:Lerp(escapeCF, step))
                            end)
                            
                            pcall(function()
                                local cam = Workspace.CurrentCamera
                                if cam and cam.CameraSubject ~= mob:FindFirstChild("Humanoid") then
                                    cam.CameraSubject = mob:FindFirstChild("Humanoid") or mobHrp
                                end
                            end)
                            
                            task.wait(0.05)
                            continue -- Salta todo el ataque sin afectar la retención del Mob!
                        end
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
                                            table.insert(sorted, {m, dist})
                                        end
                                    end
                                end
                            end
                            table.sort(sorted, function(a,b) return a[2] < b[2] end)
                            -- Agarra hasta a los 4 más cercanos
                            for i=1, math.min(4, #sorted) do
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
                                local flatLookDir = Vector3.new(tHrp.CFrame.LookVector.X, 0, tHrp.CFrame.LookVector.Z).Unit
                                local flatMobCFrame = CFrame.lookAt(tHrp.Position, tHrp.Position + flatLookDir)
                                
                                local currentFarmMode = FarmMode
                                                                
                                local TargetCF
                                if currentFarmMode == "Arriba" then
                                    TargetCF = flatMobCFrame * CFrame.new(0, OfsY, 0)
                                elseif currentFarmMode == "Detras" then
                                    TargetCF = flatMobCFrame * CFrame.new(0, 0, OfsZ)
                                elseif currentFarmMode == "Abajo" then
                                    TargetCF = flatMobCFrame * CFrame.new(0, OfsY, OfsZ)
                                end
                                
                                pcall(function()
                                    local flyDist = (hrp.Position - TargetCF.Position).Magnitude
                                    if flyDist > 15 then
                                        -- FLY CLIP UNIVERSAL: Vuelo noclip constante para evitar bloqueo del mapa
                                        local flyStep = math.clamp(120 / flyDist, 0, 1)
                                        char:PivotTo(hrp.CFrame:Lerp(TargetCF, flyStep))
                                    else
                                        -- Cerca: Anchored Pivot perfecto
                                        char:PivotTo(TargetCF)
                                    end
                                end)
                                
                                pcall(function()
                                    local cam = Workspace.CurrentCamera
                                    if cam and cam.CameraSubject ~= targetMob:FindFirstChild("Humanoid") then
                                        cam.CameraSubject = targetMob:FindFirstChild("Humanoid") or tHrp
                                    end
                                end)
                                
                                -- PREVENIR ATAQUE SI AUN ESTÁ EN VUELO LARGO:
                                local distFinal = (hrp.Position - TargetCF.Position).Magnitude
                                if distFinal <= 20 then
                                    pcall(function()
                                        CombatRemote:FireServer()
                                        if tool then tool:Activate() end
                                    end)
                                    
                                    -- Aimbot para Skills (ANTI-POP SUBTERRÁNEO)
                                    if AutoSkillEnabled then
                                        pcall(function()
                                            -- Calculamos rotación estrictamente horizontal (evita que el PJ mire hacia arriba y su cabeza traspase el piso)
                                            local flatAimPos = Vector3.new(tHrp.Position.X, hrp.Position.Y, tHrp.Position.Z)
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
                        end
                    end
                else
                    GlobalMagnetTarget = nil
                    StatusLabel.Text = "Buscando Mobs vivos..."
                end
            else
                GlobalMagnetTarget = nil
                StatusLabel.Text = "Esperando al Personaje..."
            end
        else
            GlobalMagnetTarget = nil
        end
    end
end)

-- ==============================================================================
-- CONEXIONES GUI
-- ==============================================================================
BtnToggle.MouseButton1Click:Connect(function()
    AutoFarm = not AutoFarm
    if AutoFarm then
        BtnToggle.Text = "  ◼ Detener Auto-Farm"
        BtnToggle.BackgroundColor3 = C.accentOn
        StatusLabel.TextColor3 = C.accentOn
        StatusLabel.Text = "Status: Buscando objetivos..."
        
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
-- ESCÁNER DE MOBS/BOSSES
-- ==============================================================================
BtnScan.MouseButton1Click:Connect(function()
    BtnScan.Text = "  🔄 Escaneando..."
    for _, c in pairs(ScanScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    
    local found = {}
    local folders = {}
    -- Buscar en NPCsFolder principal
    if NPCsFolder then table.insert(folders, NPCsFolder) end
    -- Buscar carpetas alternativas comunes
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
    
    for _, folder in pairs(folders) do
        pcall(function()
            for _, mob in pairs(folder:GetDescendants()) do
                if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
                    if not mob.Name:lower():match("dummy") and not mob.Name:lower():match("npc") and not mob:FindFirstChildOfClass("ProximityPrompt", true) then
                        local isBoss = mob.Name:lower():match("boss")
                        local hp = mob.Humanoid.Health
                        local maxHp = mob.Humanoid.MaxHealth
                        local key = mob.Name
                        if not found[key] then
                            found[key] = {
                                Name = mob.Name,
                                Pos = mob.HumanoidRootPart.Position,
                                Count = 1,
                                IsBoss = isBoss and true or false,
                                Alive = hp > 0 and 1 or 0,
                                MaxHP = maxHp
                            }
                        else
                            found[key].Count = found[key].Count + 1
                            if hp > 0 then
                                found[key].Alive = found[key].Alive + 1
                                found[key].Pos = mob.HumanoidRootPart.Position
                            end
                        end
                    end
                end
            end
        end)
    end
    
    local n = 0
    for key, data in pairs(found) do
        n = n + 1
        local btn = Instance.new("TextButton", ScanScroll)
        btn.Size = UDim2.new(1, 0, 0, 28)
        btn.BackgroundColor3 = data.IsBoss and Color3.fromRGB(55, 30, 30) or Color3.fromRGB(30, 35, 50)
        btn.BorderSizePixel = 0
        btn.TextColor3 = data.IsBoss and Color3.fromRGB(255, 130, 130) or Color3.fromRGB(200, 210, 230)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Text = "  " .. (data.IsBoss and "👹 " or "🐾 ") .. key .. " (x" .. data.Count .. " | vivos:" .. data.Alive .. " | HP:" .. math.floor(data.MaxHP) .. ")"
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        btn.MouseButton1Click:Connect(function()
            ScannedTargetName = data.Name
            ScannedTargetPos = data.Pos
            StatusScan.Text = "  🎯 Fijado en: " .. data.Name
            StatusScan.TextColor3 = data.IsBoss and Color3.fromRGB(255, 130, 130) or Color3.fromRGB(90, 210, 140)
            SaveConfig()
        end)
    end
    
    -- Botón para limpiar
    local btnClear = Instance.new("TextButton", ScanScroll)
    btnClear.Size = UDim2.new(1, 0, 0, 28)
    btnClear.BackgroundColor3 = Color3.fromRGB(30, 50, 35)
    btnClear.BorderSizePixel = 0
    btnClear.TextColor3 = Color3.fromRGB(100, 230, 130)
    btnClear.Font = Enum.Font.GothamBold
    btnClear.TextSize = 11
    btnClear.Text = "  ❌ Limpiar Objetivo (Atacar a Todos)"
    btnClear.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btnClear).CornerRadius = UDim.new(0, 4)
    btnClear.MouseButton1Click:Connect(function()
        ScannedTargetName = nil
        ScannedTargetPos = nil
        StatusScan.Text = "  📌 Objetivo Libre (Todo)"
        StatusScan.TextColor3 = C.muted
        SaveConfig()
    end)
    
    ScanScroll.CanvasSize = UDim2.new(0, 0, 0, (n + 1) * 28)
    BtnScan.Text = "  🔍 Escanear Mobs/Bosses (" .. n .. " tipos)"
end)

-- ==============================================================================
-- SLIDERS DE DEFENSA
-- ==============================================================================
local sliderCon = nil
SliderBg.MouseButton1Down:Connect(function()
    local Mouse = LP:GetMouse()
    if sliderCon then sliderCon:Disconnect() end
    sliderCon = game:GetService("RunService").RenderStepped:Connect(function()
        local relativeX = Mouse.X - SliderBg.AbsolutePosition.X
        local pos = math.clamp(relativeX / SliderBg.AbsoluteSize.X, 0.05, 1)
        PanicThreshold = pos
        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
        PanicLabel.Text = "  🛡️ Escudo Pánico — Escapa al " .. math.floor(pos * 100) .. "%"
    end)
end)

BtnHeight.MouseButton1Click:Connect(function()
    if FarmMode == "Arriba" then
        FarmMode = "Abajo"
        OfsY = -8
        OfsZ = 6
        BtnHeight.Text = "  Posición: 🕳️ Subterráneo"
    else
        FarmMode = "Arriba"
        OfsY = 10
        OfsZ = 0
        BtnHeight.Text = "  Posición: ☁️ Arriba"
    end
    SaveConfig()
end)

local retSliderCon = nil
ReturnSliderBg.MouseButton1Down:Connect(function()
    local Mouse = LP:GetMouse()
    if retSliderCon then retSliderCon:Disconnect() end
    retSliderCon = game:GetService("RunService").RenderStepped:Connect(function()
        local relativeX = Mouse.X - ReturnSliderBg.AbsolutePosition.X
        local pos = math.clamp(relativeX / ReturnSliderBg.AbsoluteSize.X, 0.05, 1)
        ReturnHealthThreshold = pos
        ReturnSliderFill.Size = UDim2.new(pos, 0, 1, 0)
        ReturnHealthLabel.Text = "  💚 Vida para Volver — " .. math.floor(pos * 100) .. "%"
    end)
end)

uis.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local saved = false
        if sliderCon then sliderCon:Disconnect(); sliderCon = nil; saved = true end
        if retSliderCon then retSliderCon:Disconnect(); retSliderCon = nil; saved = true end
        if saved then SaveConfig() end
    end
end)


-- Logica para Ocultar/Mostrar (Minimizar)
local function ToggleUI()
    MF.Visible = not MF.Visible
    if not MF.Visible then
        if CodesFrame then CodesFrame.Visible = false end
    end
end
BtnMin.MouseButton1Click:Connect(ToggleUI)
BtnFloat.MouseButton1Click:Connect(ToggleUI)

local function LoadConfig()
    if readfile then
        local success, raw = pcall(function() return readfile("OmniAutoFarmConfig.json") end)
        if success and raw then
            pcall(function()
                local data = game:GetService("HttpService"):JSONDecode(raw)
                if type(data) == "table" then
                    if data.ScannedTargetName ~= nil then ScannedTargetName = data.ScannedTargetName end
                    if data.ScannedTargetPos ~= nil then ScannedTargetPos = Vector3.new(data.ScannedTargetPos.X, data.ScannedTargetPos.Y, data.ScannedTargetPos.Z) end
                    if data.PanicThreshold ~= nil then PanicThreshold = data.PanicThreshold end
                    if data.ReturnHealthThreshold ~= nil then ReturnHealthThreshold = data.ReturnHealthThreshold end
                    if data.MobMagnetEnabled ~= nil then MobMagnetEnabled = data.MobMagnetEnabled end
                    if data.AutoSkillEnabled ~= nil then AutoSkillEnabled = data.AutoSkillEnabled end
                    if data.TargetBosses ~= nil then TargetBosses = data.TargetBosses end
                    if data.FarmMode ~= nil then FarmMode = data.FarmMode end
                    
                    if FarmMode == "Abajo" then
                        OfsY = -8; OfsZ = 6; BtnHeight.Text = "  Posición: 🕳️ Subterráneo"
                    else
                        OfsY = 10; OfsZ = 0; BtnHeight.Text = "  Posición: ☁️ Arriba"
                    end
                    if MobMagnetEnabled then BtnMagnet.BackgroundColor3 = C.accentOn; BtnMagnet.Text = "  🧲 Imán: ACTIVO" end
                    if AutoSkillEnabled then BtnSkill.BackgroundColor3 = C.accentOn; BtnSkill.Text = "  🔥 Skill (X): ACTIVO" end
                    if TargetBosses == "SoloBoss" then
                        BtnBoss.BackgroundColor3 = Color3.fromRGB(130, 80, 180); BtnBoss.Text = "  👹 Solo Boss"
                    elseif TargetBosses == "Ignorar" then
                        BtnBoss.BackgroundColor3 = C.accentOff; BtnBoss.Text = "  🛑 Ignorar Bosses"
                    end
                    
                    if ScannedTargetName then
                        StatusScan.Text = "  🎯 Fijado en: " .. ScannedTargetName
                    end
                    
                    PanicLabel.Text = "  🛡️ Escudo Pánico — Escapa al " .. math.floor(PanicThreshold * 100) .. "%"
                    SliderFill.Size = UDim2.new(math.clamp(PanicThreshold,0.01,1), 0, 1, 0)
                    
                    ReturnHealthLabel.Text = "  💚 Vida para Volver — " .. math.floor(ReturnHealthThreshold * 100) .. "%"
                    ReturnSliderFill.Size = UDim2.new(math.clamp(ReturnHealthThreshold,0.01,1), 0, 1, 0)
                end
            end)
        end
    end
end
task.spawn(LoadConfig)

