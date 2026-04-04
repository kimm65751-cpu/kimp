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
local TargetBosses = "Normal" -- "Normal", "Ignorar", "SoloBoss"
local SpyEnabled = false
local SpyFileName = ""
local PanicThreshold = 0.20
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
local TabLogs = MakeTabBtn("📋", "Logs", 3)

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
TabLogs.MouseButton1Click:Connect(function() SwitchTab("Logs") end)

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

SectionLabel(FarmPage, "DEFENSA", 10)
local PanicLabel = Instance.new("TextLabel", FarmPage)
PanicLabel.Size = UDim2.new(0.95, 0, 0, 16)
PanicLabel.BackgroundTransparency = 1
PanicLabel.TextColor3 = C.muted
PanicLabel.Font = Enum.Font.Gotham
PanicLabel.TextSize = 12
PanicLabel.Text = "  🛡️ Escudo Pánico — Escapa al " .. math.floor(PanicThreshold * 100) .. "%"
PanicLabel.TextXAlignment = Enum.TextXAlignment.Left
PanicLabel.LayoutOrder = 11

local SliderBg = Instance.new("TextButton", FarmPage)
SliderBg.Size = UDim2.new(0.95, 0, 0, 12)
SliderBg.BackgroundColor3 = Color3.fromRGB(40, 42, 55)
SliderBg.Text = ""
SliderBg.LayoutOrder = 12
SliderBg.BorderSizePixel = 0
Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(0, 6)

local SliderFill = Instance.new("Frame", SliderBg)
SliderFill.Size = UDim2.new(PanicThreshold, 0, 1, 0)
SliderFill.BackgroundColor3 = C.accentOn
SliderFill.BorderSizePixel = 0
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 6)

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
                        StatusLabel.Text = "🏁 Llegada a " .. destinationName
                        char:PivotTo(CFrame.new(targetVector3))
                    else
                        local step = math.clamp(30 / dist, 0, 1)
                        local wave = math.sin(os.clock() * 6) * 2
                        local targetLerp = hrp.CFrame:Lerp(CFrame.new(targetVector3), step)
                        char:PivotTo(targetLerp * CFrame.new(0, wave, 0))
                    end
                end
            end)
            task.wait(0.2)
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
                btn.BackgroundColor3 = C.accentOn; btn.Text = "  🍏 Auto-Recolector: ACTIVO"
            else
                btn.BackgroundColor3 = C.card; btn.Text = "  🍏 Auto-Recolector (Sniper): OFF"
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
    goBtn.MouseButton1Click:Connect(function() SafeTravel(pos, npcName) end)
end

-- —————————— ISLAS ——————————
TPSection("🌍 ISLAS")
TPButton("🌀 Starter Island", Color3.fromRGB(35,45,65), "V3", Vector3.new(-71,-2,-299))
TPButton("🏖️ Sand Island", Color3.fromRGB(65,55,35), "V3", Vector3.new(17,-6,-305))
TPButton("🌴 Jungle Island", Color3.fromRGB(30,65,35), "V3", Vector3.new(-392,-2,407))
TPButton("🐪 Desert Island", Color3.fromRGB(75,55,30), "V3", Vector3.new(-688,-1,-287))
TPButton("❄️ Snow Island", Color3.fromRGB(55,65,85), "V3", Vector3.new(-182,-1,-998))
TPButton("⚓ Sailor Island", Color3.fromRGB(35,45,75), "V3", Vector3.new(182,5,669))
TPButton("👻 Hollow Island", Color3.fromRGB(55,35,65), "V3", Vector3.new(-542,-1,872))
TPButton("⛩️ Shibuya Island", Color3.fromRGB(50,45,55), "V3", Vector3.new(1269,13,233))
TPButton("🏙️ Shinjuku Island", Color3.fromRGB(55,40,45), "V3", Vector3.new(189,-1,-1643))
TPButton("🏫 Academy Island", Color3.fromRGB(55,55,35), "V3", Vector3.new(962,-2,1053))
TPButton("🗡️ Lawless Island", Color3.fromRGB(40,40,60), "V3", Vector3.new(209,-4,1673))
TPButton("🧪 Slime Island", Color3.fromRGB(35,60,60), "V3", Vector3.new(-982,-2,275))
TPButton("🥷 Ninja Island", Color3.fromRGB(55,35,50), "V3", Vector3.new(-1621,10,-575))

-- —————————— DUNGEONS ——————————
TPSection("🔥 DUNGEONS & EVENTOS")
TPButton("👹 Boss Rush", Color3.fromRGB(75,35,35), "V3", Vector3.new(106,6,840))
TPButton("⚖️ Judgement", Color3.fromRGB(60,30,45), "V3", Vector3.new(-1029,-2,-989))
TPButton("🗼 Infinite Tower", Color3.fromRGB(65,50,30), "V3", Vector3.new(1276,-4,-1474))
TPButton("🕳️ Dungeon", Color3.fromRGB(50,40,60), "V3", Vector3.new(1272,5,-897))
TPButton("💀 Boss Más Fuerte", Color3.fromRGB(80,30,30), "V3", Vector3.new(593,-2,-1052))

-- —————————— NPCs TELEPORT DIRECTO ——————————
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

-- —————————— FRUTAS ——————————
TPSection("🍎 FRUTAS")
TPButton("💎 Vendedor Frutas (Gemas) — Sailor", Color3.fromRGB(55, 35, 45), "V3", Vector3.new(400,2,752))
TPButton("🪙 Vendedor Frutas (Monedas) — Sailor", Color3.fromRGB(55, 45, 35), "V3", Vector3.new(408,2,802))
TPButton("🍏 Auto-Recolector (Sniper): OFF", Color3.fromRGB(30, 60, 40), "Snipe", "")
TPButton("🛑 DETENER VUELO", C.red, "Cancel", "")

-- —————————— MINI-GUÍA DE NPCs ——————————
TPSection("📖 MINI-GUÍA — NPCs IMPORTANTES")

local g = 9000
NPCGuideEntry("🥋 Haki Master", "Te enseña Haki. Debes tener nivel suficiente. Ubicado en Snow Island. Te da el poder de Haki para golpear usuarios de Logia.", Vector3.new(-499,23,-1253), g+1)
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
NPCGuideEntry("🏪 Boss Rush Shop", "Tienda de Boss Rush. Compra recompensas con tokens de Boss Rush.", Vector3.new(104,6,826), g+13)
NPCGuideEntry("💎 Gems Fruit Dealer", "Compra frutas con Gemas. Sailor Island, cerca del puerto.", Vector3.new(400,2,752), g+14)
NPCGuideEntry("🪙 Coins Fruit Dealer", "Compra frutas con Monedas. Sailor Island, junto al Gem Dealer.", Vector3.new(408,2,802), g+15)
NPCGuideEntry("😈 Demonite Quest (Anos)", "Quest especial del Demonite. Academy Island.", Vector3.new(727,-2,1273), g+16)
NPCGuideEntry("💠 Hogyoku Quest", "Quest especial del Hogyoku. Lawless Island, zona oculta.", Vector3.new(-380,8,1529), g+17)

-- =======================================================================================
-- ========== TAB 3: LOGS — OMNI-ANALYZER (NPCs + ROLLS + GUIs) ==========
-- =======================================================================================
local LogsPage = MakeScrollPage("Logs")
SectionLabel(LogsPage, "🔬 OMNI-ANALYZER — NPCs, Rolls & GUIs", 1)

local AnalyzerFileName = "OmniAnalyzer_" .. tostring(math.floor(os.clock())) .. ".txt"
local AnalyzerActive = false
local AnalyzerConns = {}
local ALogCount = 0
local WriteBuf = {} -- Buffer para escritura batched (anti-lag)

local ALogScroll = Instance.new("ScrollingFrame", LogsPage)
ALogScroll.Size = UDim2.new(0.95, 0, 0, 240)
ALogScroll.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
ALogScroll.BorderSizePixel = 0
ALogScroll.ScrollBarThickness = 3
ALogScroll.ScrollBarImageColor3 = C.accent
ALogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ALogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ALogScroll.LayoutOrder = 2
Instance.new("UICorner", ALogScroll).CornerRadius = UDim.new(0, 6)
local ALogLayout = Instance.new("UIListLayout", ALogScroll)
ALogLayout.Padding = UDim.new(0, 2)
ALogLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function ALog(text, color)
    ALogCount = ALogCount + 1
    local l = Instance.new("TextLabel", ALogScroll)
    l.Size = UDim2.new(1, -8, 0, 18)
    l.BackgroundTransparency = 1
    l.TextColor3 = color or C.text
    l.TextSize = 11
    l.Font = Enum.Font.Code
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = "  " .. text
    l.TextWrapped = true
    l.LayoutOrder = ALogCount
    task.defer(function() ALogScroll.CanvasPosition = Vector2.new(0, 99999) end)
    if ALogCount > 250 then
        local first = ALogScroll:FindFirstChildWhichIsA("TextLabel")
        if first then first:Destroy() end
    end
end

-- === SISTEMA DE ESCRITURA BATCHED (Anti-Lag) ===
-- Acumula lineas en buffer y las escribe cada 3 segundos
local function QueueWrite(line)
    table.insert(WriteBuf, line)
end

local function FlushBuf()
    if #WriteBuf == 0 then return end
    local chunk = table.concat(WriteBuf, "\n") .. "\n"
    WriteBuf = {}
    pcall(function()
        if appendfile then
            appendfile(AnalyzerFileName, chunk)
        elseif writefile then
            local prev = ""
            pcall(function() prev = readfile(AnalyzerFileName) end)
            writefile(AnalyzerFileName, prev .. chunk)
        end
    end)
end

-- === SERIALIZACIÓN PROFUNDA ===
local function Ser(v, depth)
    depth = depth or 0
    if depth > 3 then return "..." end
    local t = typeof(v)
    if t == "table" then
        local sub = {}
        local count = 0
        for k2, v2 in pairs(v) do
            count = count + 1
            if count > 20 then table.insert(sub, "..+" .. (count) .. " más") break end
            table.insert(sub, tostring(k2) .. "=" .. Ser(v2, depth + 1))
        end
        return "{" .. table.concat(sub, ", ") .. "}"
    elseif t == "Instance" then
        return v.ClassName .. ":" .. v:GetFullName()
    elseif t == "Vector3" then
        return string.format("V3(%.0f,%.0f,%.0f)", v.X, v.Y, v.Z)
    elseif t == "CFrame" then
        return string.format("CF(%.0f,%.0f,%.0f)", v.X, v.Y, v.Z)
    elseif t == "EnumItem" then
        return tostring(v)
    else
        return tostring(v)
    end
end

local function SerArgs(...)
    local args = {...}
    local parts = {}
    for _, v in ipairs(args) do table.insert(parts, Ser(v)) end
    return table.concat(parts, " | ")
end

-- === BOTONES ===
local BtnAnalyzer = Instance.new("TextButton", LogsPage)
BtnAnalyzer.Size = UDim2.new(0.95, 0, 0, 40)
BtnAnalyzer.BackgroundColor3 = Color3.fromRGB(55, 35, 80)
BtnAnalyzer.TextColor3 = C.text
BtnAnalyzer.Font = Enum.Font.GothamBold
BtnAnalyzer.TextSize = 14
BtnAnalyzer.Text = "  🔬 INICIAR OMNI-ANALYZER"
BtnAnalyzer.TextXAlignment = Enum.TextXAlignment.Left
BtnAnalyzer.LayoutOrder = 3
BtnAnalyzer.BorderSizePixel = 0
Instance.new("UICorner", BtnAnalyzer).CornerRadius = UDim.new(0, 6)

local BtnDump = Instance.new("TextButton", LogsPage)
BtnDump.Size = UDim2.new(0.95, 0, 0, 34)
BtnDump.BackgroundColor3 = Color3.fromRGB(40, 55, 70)
BtnDump.TextColor3 = C.text
BtnDump.Font = Enum.Font.GothamMedium
BtnDump.TextSize = 12
BtnDump.Text = "  📊 DUMP CONFIGS (Fruit, Rarity, Rolls, Settings)"
BtnDump.TextXAlignment = Enum.TextXAlignment.Left
BtnDump.LayoutOrder = 4
BtnDump.BorderSizePixel = 0
Instance.new("UICorner", BtnDump).CornerRadius = UDim.new(0, 6)

SectionLabel(LogsPage, "📋 QUÉ CAPTURA EL ANALYZER", 5)

local InfoBox = Instance.new("TextLabel", LogsPage)
InfoBox.Size = UDim2.new(0.95, 0, 0, 130)
InfoBox.BackgroundColor3 = C.card
InfoBox.TextColor3 = C.muted
InfoBox.Font = Enum.Font.Code
InfoBox.TextSize = 10
InfoBox.Text = "Al activar, captura EN VIVO sin lag:\n" ..
    "🤖 NPC TOUCH — Detecta ProximityPrompt al hablar\n" ..
    "📺 GUI OPEN — Detecta ventanas nuevas en PlayerGui\n" ..
    "📡 REMOTES — 60+ RemoteEvents (Rolls, Traits,\n" ..
    "   Powers, Stats, Fruits, Quests, Shop, Artifacts,\n" ..
    "   Haki, Blessing, Trade, Skills, Ascension...)\n" ..
    "💾 AUTO-SAVE cada 3s en .txt (batched)\n" ..
    "Abre NPCs, haz Rolls, compra — todo queda capturado.\n" ..
    "Clanes: Voldigoat, Pride, Monarch • Razas: Epic+Leg"
InfoBox.TextWrapped = true
InfoBox.TextXAlignment = Enum.TextXAlignment.Left
InfoBox.TextYAlignment = Enum.TextYAlignment.Top
InfoBox.LayoutOrder = 6
InfoBox.BorderSizePixel = 0
Instance.new("UICorner", InfoBox).CornerRadius = UDim.new(0, 6)
Instance.new("UIPadding", InfoBox).PaddingLeft = UDim.new(0, 8)

-- === LISTA COMPLETA DE REMOTES A HOOKEAR ===
local AllRemotes = {
    -- Rolls / Rerolls / Spins
    "TraitReroll", "TraitConfirm", "TraitUpdateFilters", "TraitUpdateAutoSkip",
    "TraitGetData", "TraitDataUpdate", "TraitAutoReroll", "OpenTraitUI",
    "PowerReroll", "PowerConfirm", "PowerUpdateAutoSkip", "PowerDataUpdate",
    "PowerGetData", "PowerUnlock", "OpenPowerUI", "PowerShowConfirm",
    "PowerToggleAutoRoll", "PowerUpdateFilters",
    "StatRerollUpdate", "StatRerollUpdateAutoSkip", "StatRerollAutoRoll",
    "OpenStatRerollUI", "StatUpdateAutoSkip",
    "SpecPassiveReroll", "SpecPassiveConfirm", "SpecPassiveUpdateAutoSkip",
    "SpecPassiveDataUpdate", "OpenSpecPassiveUI", "SpecPassiveShowConfirm",
    "SpecPassiveUnlock", "SpecPassiveGetData", "SpecPassiveToggleAutoRoll",
    -- Frutas
    "FruitReroll", "FruitAction", "DropFruit", "FruitPowerRemote", "FruitPowerResponse",
    "FruitClearWarning",
    -- Stats / Perfil
    "UpdatePlayerStats", "DataChanged", "ProfileLoaded", "AllocateStat",
    "ResetStats", "ToggleStatsPanel", "LevelUp", "UpdateCurrency", "GetPlayerStats",
    -- Quests
    "QuestAccept", "QuestAbandon", "QuestProgress", "QuestComplete", "QuestUIUpdate",
    "QuestRepeat",
    -- Haki
    "HakiRemote", "HakiStateUpdate", "HakiQuestUpdate", "HakiProgressionUpdate",
    "ObservationHakiRemote", "ObservationHakiStateUpdate",
    "ConquerorHakiRemote",
    -- Artefactos
    "ArtifactUpgrade", "ArtifactEquip", "ArtifactUnequip", "ArtifactDataSync",
    "ArtifactOpenUI", "ArtifactCloseUI", "ArtifactUnlockSystem",
    "ArtifactMilestoneOpenUI", "ArtifactMilestoneDataSync",
    -- Shop / Compras
    "OpenBossRushShop", "BossRushShopSync",
    "OpenInfiniteTowerShop", "InfiniteTowerShopSync",
    -- Skills / Ascension
    "OpenSkillTreeUI", "SkillTreeUnlock", "SkillTreeUpgrade", "SkillTreeReset",
    "SkillTreeUpdate", "GetSkillTreeData",
    "OpenAscendUI", "GetAscendData", "RequestAscend", "AscendDataUpdate",
    -- Títulos / Settings
    "TitleEquip", "TitleUnequip", "TitleUnlocked", "TitleDataSync",
    "SettingsToggle", "SettingsSync",
    -- Loadouts / Storage
    "LoadoutSave", "LoadoutLoad", "LoadoutSync",
    "OpenStorageUI",
    -- NPCs / Rewards
    "NPCReward", "SetSpawnEvent",
    -- Codes
    "CodeRedeem",
    -- Especiales (F Moves)
    "CheckShadowFUnlocked", "ShadowFUnlockUpdate",
    "CheckSukunaFUnlocked", "SukunaFUnlockUpdate",
    "CheckGojoFUnlocked", "GojoFUnlockUpdate",
    "CheckBlessedMaidenFUnlocked", "BlessedMaidenFUnlockUpdate",
    "CheckSaberAlterFUnlocked", "SaberAlterFUnlockUpdate",
    "CheckAtomicFUnlocked", "AtomicFUnlockUpdate",
    "CheckMoonSlayerFUnlocked", "MoonSlayerFUnlockUpdate",
    "CheckStrongestShinobiFUnlocked", "StrongestShinobiFUnlockUpdate",
    "CheckRimuruFUnlocked", "RimuruFUnlockUpdate",
    "CheckShadowMonarchFUnlocked", "ShadowMonarchFUnlockUpdate",
    "CheckAizenFUnlocked", "AizenFUnlockUpdate",
    -- Bosses invocables
    "RequestSpawnRimuru", "RimuruBossResult",
    "RequestSpawnTrueAizen", "TrueAizenBossResult",
    "RequestSpawnAtomic", "AtomicBossResult",
    -- Slime / Craft
    "OpenSlimeCraftUI", "SlimeCraftUpdate",
    "OpenGrailCraftUI",
    -- Dungeon
    "DungeonPortalSpawn", "DungeonUIUpdate",
}

-- === COLORES POR CATEGORÍA ===
local function RemoteColor(name)
    local n = name:lower()
    if n:match("trait") or n:match("race") then return Color3.fromRGB(255, 180, 100) end
    if n:match("power") then return Color3.fromRGB(180, 130, 255) end
    if n:match("stat") or n:match("reroll") then return Color3.fromRGB(100, 200, 255) end
    if n:match("spec") or n:match("passive") then return Color3.fromRGB(255, 150, 200) end
    if n:match("fruit") then return Color3.fromRGB(150, 255, 150) end
    if n:match("quest") then return Color3.fromRGB(255, 255, 130) end
    if n:match("haki") or n:match("conqueror") then return Color3.fromRGB(200, 100, 100) end
    if n:match("artifact") then return Color3.fromRGB(180, 220, 255) end
    if n:match("shop") or n:match("purchase") then return Color3.fromRGB(255, 200, 50) end
    if n:match("skill") or n:match("ascend") then return Color3.fromRGB(200, 255, 200) end
    if n:match("title") then return Color3.fromRGB(220, 200, 255) end
    if n:match("unlock") or n:match("check") then return Color3.fromRGB(255, 180, 180) end
    return Color3.fromRGB(180, 190, 210)
end

-- === LÓGICA PRINCIPAL DEL ANALYZER ===
BtnAnalyzer.MouseButton1Click:Connect(function()
    AnalyzerActive = not AnalyzerActive
    if AnalyzerActive then
        BtnAnalyzer.BackgroundColor3 = C.accentOn
        BtnAnalyzer.Text = "  🛑 DETENER OMNI-ANALYZER"
        
        AnalyzerFileName = "OmniAnalyzer_" .. tostring(math.floor(os.clock())) .. ".txt"
        pcall(function()
            if writefile then
                writefile(AnalyzerFileName, "=== OMNI-ANALYZER — " .. os.date() .. " ===\n" ..
                    "Captura: NPCs, GUIs, RemoteEvents, Rolls, Shops\n\n")
            end
        end)
        
        local ts = function() return os.date("%H:%M:%S") end
        local hookCount = 0
        
        -- ========== HOOK 1: TODOS LOS REMOTE EVENTS ==========
        local RE_Folder = ReplicatedStorage:FindFirstChild("RemoteEvents")
        if RE_Folder then
            for _, remoteName in ipairs(AllRemotes) do
                local remote = RE_Folder:FindFirstChild(remoteName)
                if remote and remote:IsA("RemoteEvent") then
                    local conn = remote.OnClientEvent:Connect(function(...)
                        local data = SerArgs(...)
                        local line = "[" .. ts() .. "] 📡 " .. remoteName .. " → " .. data
                        ALog(line, RemoteColor(remoteName))
                        QueueWrite(line)
                    end)
                    table.insert(AnalyzerConns, conn)
                    hookCount = hookCount + 1
                end
            end
        end
        
        -- También hookear Remotes (carpeta secundaria)
        pcall(function()
            local Remotes2 = ReplicatedStorage:FindFirstChild("Remotes")
            if Remotes2 then
                for _, remote in pairs(Remotes2:GetDescendants()) do
                    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                        if remote:IsA("RemoteEvent") then
                            local conn = remote.OnClientEvent:Connect(function(...)
                                local data = SerArgs(...)
                                local line = "[" .. ts() .. "] 📡 R/" .. remote.Name .. " → " .. data
                                ALog(line, Color3.fromRGB(200, 180, 150))
                                QueueWrite(line)
                            end)
                            table.insert(AnalyzerConns, conn)
                            hookCount = hookCount + 1
                        end
                    end
                end
            end
        end)
        
        -- ========== HOOK 2: PROXIMTY PROMPT (NPC INTERACT) ==========
        -- Detecta cuando el jugador habla con un NPC
        local promptsHooked = {}
        local function HookPrompt(prompt)
            if promptsHooked[prompt] then return end
            promptsHooked[prompt] = true
            local conn = prompt.Triggered:Connect(function(playerWhoTriggered)
                if playerWhoTriggered ~= LP then return end
                local parent = prompt.Parent
                local npcName = parent and parent.Name or "?"
                local objText = prompt.ObjectText or ""
                local actionText = prompt.ActionText or ""
                local pos = "?"
                pcall(function()
                    if parent:IsA("Model") and parent.PrimaryPart then
                        local p = parent.PrimaryPart.Position
                        pos = string.format("%.0f,%.0f,%.0f", p.X, p.Y, p.Z)
                    elseif parent.Parent and parent.Parent:IsA("Model") then
                        local pp = parent.Parent
                        npcName = pp.Name
                        if pp.PrimaryPart then
                            local p = pp.PrimaryPart.Position
                            pos = string.format("%.0f,%.0f,%.0f", p.X, p.Y, p.Z)
                        end
                    end
                end)
                local line = "[" .. ts() .. "] 🤖 NPC INTERACT: " .. npcName ..
                    " | Acción: " .. actionText ..
                    " | Texto: " .. objText ..
                    " | Pos: " .. pos ..
                    " | Ruta: " .. prompt:GetFullName()
                ALog(line, Color3.fromRGB(255, 220, 100))
                QueueWrite(line)
            end)
            table.insert(AnalyzerConns, conn)
        end
        
        -- Hookear prompts existentes
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then HookPrompt(v) end
        end
        -- Hookear prompts nuevos (streaming)
        local conn_pp = Workspace.DescendantAdded:Connect(function(v)
            if v:IsA("ProximityPrompt") then task.wait(0.1) HookPrompt(v) end
        end)
        table.insert(AnalyzerConns, conn_pp)
        
        -- ========== HOOK 3: GUI CHANGES (PlayerGui) ==========
        -- Detecta cuando se abren nuevas ventanas (Reroll UI, Shop, etc.)
        local guiLogged = {}
        local conn_gui = LP.PlayerGui.DescendantAdded:Connect(function(child)
            task.wait(0.05) -- Deja que se complete el render
            if not child or not child.Parent then return end
            -- Solo logear Frames/ScrollingFrames que sean pantallas grandes
            if child:IsA("Frame") or child:IsA("ScrollingFrame") then
                local fullName = child:GetFullName()
                -- Filtrar: ignorar nuestro propio GUI y cosas muy chicas
                if fullName:match("OmniAutoFarm") then return end
                -- Solo logear pantallas "raíz" (hijos directos de ScreenGui)
                if child.Parent and child.Parent:IsA("ScreenGui") then
                    local key = child.Parent.Name .. "/" .. child.Name
                    if guiLogged[key] then return end
                    guiLogged[key] = true
                    -- Analizar contenido de la GUI
                    local childInfo = {}
                    for _, sub in pairs(child:GetDescendants()) do
                        if sub:IsA("TextLabel") and sub.Text ~= "" and #sub.Text < 100 then
                            table.insert(childInfo, sub.Name .. "='" .. sub.Text .. "'")
                        elseif sub:IsA("TextButton") and sub.Text ~= "" then
                            table.insert(childInfo, "BTN:" .. sub.Name .. "='" .. sub.Text .. "'")
                        end
                        if #childInfo >= 15 then break end
                    end
                    local line = "[" .. ts() .. "] 📺 GUI OPEN: " .. key ..
                        " | Size: " .. tostring(child.Size) ..
                        " | Contenido: " .. table.concat(childInfo, " • ")
                    ALog(line, Color3.fromRGB(100, 220, 255))
                    QueueWrite(line)
                    -- Resetear para capturar reaperturas después de 2s
                    task.delay(2, function() guiLogged[key] = nil end)
                end
            end
        end)
        table.insert(AnalyzerConns, conn_gui)
        
        -- ========== HOOK 4: VISIBILITY CHANGES (detecta UIs que se muestran) ==========
        local visLogged = {}
        pcall(function()
            for _, sg in pairs(LP.PlayerGui:GetChildren()) do
                if sg:IsA("ScreenGui") and sg.Name ~= "OmniAutoFarm" then
                    for _, frame in pairs(sg:GetChildren()) do
                        if (frame:IsA("Frame") or frame:IsA("ScrollingFrame")) then
                            pcall(function()
                                local conn_vis = frame:GetPropertyChangedSignal("Visible"):Connect(function()
                                    if not frame.Visible then return end
                                    local key = sg.Name .. "/" .. frame.Name
                                    if visLogged[key] then return end
                                    visLogged[key] = true
                                    local labels = {}
                                    for _, sub in pairs(frame:GetDescendants()) do
                                        if sub:IsA("TextLabel") and sub.Text ~= "" and #sub.Text < 80 then
                                            table.insert(labels, sub.Name .. "='" .. sub.Text .. "'")
                                        end
                                        if #labels >= 10 then break end
                                    end
                                    local line = "[" .. ts() .. "] 👁️ GUI SHOW: " .. key .. " | " .. table.concat(labels, " • ")
                                    ALog(line, Color3.fromRGB(150, 200, 255))
                                    QueueWrite(line)
                                    task.delay(1.5, function() visLogged[key] = nil end)
                                end)
                                table.insert(AnalyzerConns, conn_vis)
                            end)
                        end
                    end
                end
            end
        end)
        
        -- ========== AUTO-FLUSH TIMER (cada 3 segundos) ==========
        local flushConn = game:GetService("RunService").Heartbeat:Connect(function()
            -- Flush cada ~3 segundos (180 frames aprox a 60fps)
        end)
        table.insert(AnalyzerConns, flushConn)
        task.spawn(function()
            while AnalyzerActive do
                task.wait(3)
                FlushBuf()
            end
        end)
        
        ALog("🟢 OMNI-ANALYZER ACTIVO — " .. hookCount .. " remotes + NPC prompts + GUIs", C.accentOn)
        QueueWrite("[INICIO] " .. hookCount .. " hooks conectados — " .. os.date())
        QueueWrite("[INFO] Captura: RemoteEvents, ProximityPrompts, GUI changes")
        FlushBuf()
    else
        -- DETENER
        BtnAnalyzer.BackgroundColor3 = Color3.fromRGB(55, 35, 80)
        BtnAnalyzer.Text = "  🔬 INICIAR OMNI-ANALYZER"
        for _, conn in pairs(AnalyzerConns) do pcall(function() conn:Disconnect() end) end
        AnalyzerConns = {}
        FlushBuf()
        ALog("🔴 OMNI-ANALYZER DETENIDO — Archivo: " .. AnalyzerFileName, C.red)
        QueueWrite("[FIN] Detenido — " .. os.date())
        FlushBuf()
    end
end)

-- === DUMP ESTÁTICO DE CONFIGS ===
BtnDump.MouseButton1Click:Connect(function()
    ALog("📊 Dumpeando módulos...", Color3.fromRGB(255, 200, 100))
    local dumpFile = "ConfigDump_" .. tostring(math.floor(os.clock())) .. ".txt"
    local d = "=== CONFIG DUMP — " .. os.date() .. " ===\n\n"
    
    pcall(function()
        local fc = require(ReplicatedStorage:WaitForChild("FruitConfig", 3))
        if fc then
            d = d .. "[FRUIT CONFIG]\n"
            if fc.Rarities then for r, w in pairs(fc.Rarities) do d = d .. "  " .. r .. " = " .. w .. "%\n" end end
            if fc.Fruits then for _, f in ipairs(fc.Fruits) do d = d .. "  - " .. f.Name .. " [" .. f.Rarity .. "]\n" end end
            ALog("✅ FruitConfig", C.accentOn)
        end
    end)
    pcall(function()
        local irc = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ItemRarityConfig", 3))
        if irc and irc.RarityOrder then
            d = d .. "\n[ITEM RARITY ORDER]\n"
            for i, r in ipairs(irc.RarityOrder) do d = d .. "  " .. i .. ". " .. r .. "\n" end
            ALog("✅ ItemRarity", C.accentOn)
        end
    end)
    pcall(function()
        local sc = require(ReplicatedStorage:WaitForChild("SettingsConfig", 3))
        if sc and sc.Settings then
            d = d .. "\n[SETTINGS — ROLL/REROLL]\n"
            for _, s in ipairs(sc.Settings) do
                local cat = s.Category or ""
                if cat:match("Reroll") or cat:match("Filter") or cat:match("Clan") or cat:match("Race") or cat:match("Skill") or cat:match("Haki") then
                    d = d .. "  [" .. cat .. "] " .. (s.Key or "?") .. " = " .. (s.Label or "?") .. "\n"
                end
            end
            if sc.CategoryOrder then
                d = d .. "  Categorías:\n"
                for cat, ord in pairs(sc.CategoryOrder) do d = d .. "    " .. cat .. " = " .. ord .. "\n" end
            end
            ALog("✅ SettingsConfig", C.accentOn)
        end
    end)
    
    -- Dump TODOS los RemoteEvents
    d = d .. "\n[TODOS LOS REMOTE EVENTS]\n"
    pcall(function()
        local RE = ReplicatedStorage:FindFirstChild("RemoteEvents")
        if RE then for _, c in pairs(RE:GetChildren()) do d = d .. "  " .. c.ClassName .. ": " .. c.Name .. "\n" end end
    end)
    pcall(function()
        local R2 = ReplicatedStorage:FindFirstChild("Remotes")
        if R2 then for _, c in pairs(R2:GetDescendants()) do
            if c:IsA("RemoteEvent") or c:IsA("RemoteFunction") then d = d .. "  " .. c.ClassName .. ": " .. c:GetFullName() .. "\n" end
        end end
    end)
    
    -- Dump NPCs con ProximityPrompt en la zona actual
    d = d .. "\n[NPCs CON PROXIMITY PROMPT (ZONA CARGADA)]\n"
    pcall(function()
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                local p = v.Parent
                local pp = p and p.Parent
                local npcName = (pp and pp:IsA("Model") and pp.Name) or (p and p.Name) or "?"
                local objText = v.ObjectText or ""
                local actionText = v.ActionText or ""
                d = d .. "  🤖 " .. npcName .. " | Action: " .. actionText .. " | Text: " .. objText .. " | Path: " .. v:GetFullName() .. "\n"
            end
        end
    end)
    
    pcall(function() if writefile then writefile(dumpFile, d) end end)
    ALog("💾 " .. dumpFile, Color3.fromRGB(255, 255, 100))
end)

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
        
        CopyAllBtn.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(allCodesStr)
                CopyAllBtn.Text = "Completado!"
                task.wait(1.5)
                CopyAllBtn.Text = "Copiar Todos"
            end
        end)
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


local function GetNearestMob()
    local nearestDist = math.huge
    local nearestMob = nil
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = char.HumanoidRootPart

    for _, mob in pairs(NPCsFolder:GetChildren()) do
        if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
            if not mob.Name:lower():match("dummy") then
                local isBoss = mob.Name:lower():match("boss")
                local allow = false
                
                if TargetBosses == "SoloBoss" then
                    if isBoss then allow = true end
                elseif TargetBosses == "Ignorar" then
                    if not isBoss then allow = true end
                else
                    allow = true
                end
                
                if allow and mob.Humanoid.Health > 0 then
                    local dist = (hrp.Position - mob.HumanoidRootPart.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
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
                        elseif IsInPanicRecovery and hpRatio >= 0.95 then
                            IsInPanicRecovery = false -- Completamente sano
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
                            for _, m in pairs(NPCsFolder:GetChildren()) do
                                if m:IsA("Model") and m:FindFirstChild("Humanoid") and m.Humanoid.Health > 0 and m:FindFirstChild("HumanoidRootPart") then
                                    local isDummy = m.Name:lower():match("dummy")
                                    local isBoss = m.Name:lower():match("boss")
                                    
                                    local allow = false
                                    if TargetBosses == "SoloBoss" then
                                        if isBoss then allow = true end
                                    elseif TargetBosses == "Ignorar" then
                                        if not isBoss then allow = true end
                                    else
                                        allow = true
                                    end
                                    
                                    if not isDummy and allow then
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
                                if TargetBosses == "SoloBoss" then
                                    currentFarmMode = "Arriba"
                                    OfsY = 10
                                    OfsZ = 0
                                end
                                
                                local TargetCF
                                if currentFarmMode == "Arriba" then
                                    TargetCF = flatMobCFrame * CFrame.new(0, OfsY, 0)
                                elseif currentFarmMode == "Detras" then
                                    TargetCF = flatMobCFrame * CFrame.new(0, 0, OfsZ)
                                elseif currentFarmMode == "Abajo" then
                                    TargetCF = tHrp.CFrame * CFrame.new(0, OfsY, OfsZ)
                                end
                                
                                pcall(function()
                                    local flyDist = (hrp.Position - TargetCF.Position).Magnitude
                                    if TargetBosses == "SoloBoss" and flyDist > 15 then
                                        -- FLY CLIP: Vuelo suave constante (apróx 100 studs/seg) para moverse largo sin teleports
                                        local flyStep = math.clamp(20 / flyDist, 0, 1)
                                        char:PivotTo(hrp.CFrame:Lerp(TargetCF, flyStep))
                                    else
                                        -- Cerca o Modalidad Normal: Anchored Pivot
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
                                    
                                    -- Aimbot para Skills
                                    if AutoSkillEnabled then
                                        pcall(function()
                                            hrp.CFrame = CFrame.lookAt(hrp.Position, tHrp.Position)
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
end)

BtnBoss.MouseButton1Click:Connect(function()
    if TargetBosses == "Normal" then
        TargetBosses = "Ignorar"
        BtnBoss.BackgroundColor3 = C.accentOff
        BtnBoss.Text = "  🛑 Ignorar Bosses"
    elseif TargetBosses == "Ignorar" then
        TargetBosses = "SoloBoss"
        BtnBoss.BackgroundColor3 = Color3.fromRGB(130, 80, 180)
        BtnBoss.Text = "  👹 Solo Boss (Fly Air)"
    else
        TargetBosses = "Normal"
        BtnBoss.BackgroundColor3 = C.card
        BtnBoss.Text = "  🎯 Cazar Bosses: Normal"
    end
end)

-- ==============================================
-- OMNI-RECON : AUTO-DUMPER CONTINUO (CERO LAG)
-- ==============================================
local ReconActive = false
local LoggedEntities = {}
local ReconConnections = {}
local SpyFileName = "OmniLiveMapDump.txt"
        
local TourActive = false
local TourIslands = {
    {Name = "Starter Island", Pos = Vector3.new(-71, -2, -299)},
    {Name = "Sand Island", Pos = Vector3.new(17, -6, -305)},
    {Name = "Jungle Island", Pos = Vector3.new(-392, -2, 407)},
    {Name = "Desert Island", Pos = Vector3.new(-688, -1, -287)},
    {Name = "Snow Island", Pos = Vector3.new(-182, -1, -998)},
    {Name = "Sailor Island", Pos = Vector3.new(182, 5, 669)},
    {Name = "Hollow Island", Pos = Vector3.new(-542, -1, 872)},
    {Name = "Shibuya Island", Pos = Vector3.new(1269, 13, 233)},
    {Name = "Shinjuku Island", Pos = Vector3.new(189, -1, -1643)},
    {Name = "Academy Island", Pos = Vector3.new(962, -2, 1053)},
    {Name = "Lawless Island", Pos = Vector3.new(209, -4, 1673)},
    {Name = "Slime Island", Pos = Vector3.new(-982, -2, 275)},
    {Name = "Ninja Island", Pos = Vector3.new(-1621, 10, -575)}
}

local function ProcessEntity(obj)
    if not ReconActive then return end
    pcall(function()
        local fullName = obj:GetFullName()
        if LoggedEntities[fullName] then return end
        
        local n = obj.Name:lower()
        local isPortal = n:match("portal") or n:match("teleport") or n:match("island") or obj:IsA("SpawnLocation")
        local isNPC = obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj.Name ~= LP.Name and (n:match("dealer") or n:match("fruit") or n:match("quest") or n:match("shop") or obj:FindFirstChild("ProximityPrompt", true))
        
        if isPortal then
            local p = "N/A"
            if obj:IsA("Model") and obj.PrimaryPart then p = math.floor(obj.PrimaryPart.Position.X)..","..math.floor(obj.PrimaryPart.Position.Y)..","..math.floor(obj.PrimaryPart.Position.Z)
            elseif obj:IsA("BasePart") then p = math.floor(obj.Position.X)..","..math.floor(obj.Position.Y)..","..math.floor(obj.Position.Z) end
            
            if p ~= "N/A" then 
                local txt = "[PORTAL/ISLA] -> " .. obj.Name .. " | Pos: " .. p .. "\n"
                LoggedEntities[fullName] = true
                print("🗺️ [RECON STREAMING] Isla/Portal Materializado: " .. obj.Name)
                if TourActive then AddLog("✓ " .. obj.Name, Color3.fromRGB(150, 150, 255)) end
                if appendfile then pcall(function() appendfile(SpyFileName, txt) end)
                elseif writefile then pcall(function() writefile(SpyFileName, readfile(SpyFileName) .. txt) end) end
            end
        elseif isNPC then
            local realName = obj.Name
            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt and prompt.ObjectText and prompt.ObjectText ~= "" then
                realName = realName .. " ('" .. prompt.ObjectText .. "')"
            end
            
            local p = obj.HumanoidRootPart.Position
            local txt = "[NPC/DEALER] -> " .. realName .. " | Pos: " .. math.floor(p.X)..","..math.floor(p.Y)..","..math.floor(p.Z) .. "\n"
            LoggedEntities[fullName] = true
            print("🤖 [RECON STREAMING] NPC Materializado: " .. realName)
            if TourActive then AddLog("✓ " .. realName, Color3.fromRGB(100, 255, 100)) end
            if appendfile then pcall(function() appendfile(SpyFileName, txt) end)
            elseif writefile then pcall(function() writefile(SpyFileName, readfile(SpyFileName) .. txt) end) end
        end
    end)
end

BtnAutoTour.MouseButton1Click:Connect(function()
    TourActive = not TourActive
    if TourActive then
        LogFrame.Visible = true
        BtnAutoTour.Text = "🛑 DETENER AUTO-EXPLORADOR"
        BtnAutoTour.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        
        -- Verificar que ReconActive esté encendido obligatoriamente
        if not ReconActive then
            AddLog("⚠️ PRENDIENDO ESCÁNER AUTOMÁTICAMENTE...", Color3.fromRGB(255, 255, 50))
            BtnSpy.BackgroundColor3 = Color3.fromRGB(200, 100, 20)
            BtnSpy.Text = "📡 RECON ACTIVO (MANEJADO POR TOUR)"
            ReconActive = true
            SpyFileName = "OmniLiveMapDump_" .. tostring(math.floor(os.clock())) .. ".txt"
            if writefile then pcall(function() writefile(SpyFileName, "=== BITÁCORA EVENT-DRIVEN (BOT TOUR) ===\n\n") end) end
            
            task.spawn(function()
                table.insert(ReconConnections, Workspace.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("Model") then
                        task.spawn(function() task.wait(2); ProcessEntity(descendant) end)
                    elseif descendant:IsA("ProximityPrompt") then
                        task.spawn(function() task.wait(0.5); local pm = descendant:FindFirstAncestorWhichIsA("Model"); if pm then ProcessEntity(pm) end end)
                    else ProcessEntity(descendant) end
                end))
            end)
        end
        
        AddLog("► INICIANDO VUELO A LAS "..#TourIslands.." ISLAS...", Color3.fromRGB(50, 150, 255))
        task.spawn(function()
            for i, island in ipairs(TourIslands) do
                if not TourActive then break end
                AddLog("-------------------------", Color3.fromRGB(100, 100, 100))
                AddLog("✈️ Vuelo Orbital Hacia: " .. island.Name, Color3.fromRGB(255, 200, 50))
                
                SafeTravel(island.Pos, "Tour: " .. island.Name)
                
                -- Esperar Físicamente la Llegada
                while TourActive and IsTraveling and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") do
                    local dist = (LP.Character.HumanoidRootPart.Position - island.Pos).Magnitude
                    if dist < 50 then break end
                    task.wait(0.5)
                end
                if not TourActive then break end
                
                AddLog("⬇️ " .. island.Name .. " Alcanzada. Esperando 8s a RED de Streaming...", Color3.fromRGB(100, 200, 255))
                for tick = 1, 8 do
                    if not TourActive then break end
                    task.wait(1)
                end
                
                if TourActive then AddLog("✅ " .. island.Name .. " Mapeada al .TXT", Color3.fromRGB(50, 255, 50)) end
            end
            
            if TourActive then
                AddLog("🎉 AUTO-TOUR COMPLETADO.", Color3.fromRGB(255, 50, 255))
                AddLog("Revisa tu carpeta por " .. SpyFileName, Color3.new(1,1,1))
                TourActive = false
                BtnAutoTour.Text = "🤖 INICIAR AUTO-EXPLORADOR (TOUR GLOBAL)"
                BtnAutoTour.BackgroundColor3 = Color3.fromRGB(120, 40, 150)
            end
        end)
    else
        BtnAutoTour.Text = "🤖 INICIAR AUTO-EXPLORADOR (TOUR GLOBAL)"
        BtnAutoTour.BackgroundColor3 = Color3.fromRGB(120, 40, 150)
        LogFrame.Visible = false
        CancelTravel() -- Stop flight on cancel
    end
end)

BtnSpy.MouseButton1Click:Connect(function()
    ReconActive = not ReconActive
    if ReconActive then
        BtnSpy.BackgroundColor3 = Color3.fromRGB(200, 100, 20)
        BtnSpy.Text = "📡 RECON ACTIVO: ESPERANDO STREAMING..."
        
        SpyFileName = "OmniLiveMapDump_" .. tostring(math.floor(os.clock())) .. ".txt"
        if writefile then
            pcall(function() writefile(SpyFileName, "=== BITÁCORA EVENT-DRIVEN (MÁXIMO RENDIMIENTO) ===\n\n") end)
        end
        
        task.spawn(function()
            for _, obj in pairs(Workspace:GetDescendants()) do ProcessEntity(obj) end
            
            table.insert(ReconConnections, Workspace.DescendantAdded:Connect(function(descendant)
                if descendant:IsA("Model") then
                    task.spawn(function()
                        task.wait(2)
                        ProcessEntity(descendant)
                    end)
                elseif descendant:IsA("ProximityPrompt") then
                    task.spawn(function()
                        task.wait(0.5)
                        local parentModel = descendant:FindFirstAncestorWhichIsA("Model")
                        if parentModel then ProcessEntity(parentModel) end
                    end)
                else
                    ProcessEntity(descendant)
                end
            end))
        end)
    else
        BtnSpy.BackgroundColor3 = Color3.fromRGB(30, 60, 40)
        BtnSpy.Text = "📡 INICIAR ESCANEAR CONTINUO DE MAPA"
        for _, conn in pairs(ReconConnections) do conn:Disconnect() end
        ReconConnections = {}
    end
end)

-- Sistema de interaccion Slider
local sliderCon = nil

SliderBg.MouseButton1Down:Connect(function()
    local Mouse = LP:GetMouse()
    if sliderCon then sliderCon:Disconnect() end
    sliderCon = game:GetService("RunService").RenderStepped:Connect(function()
        local relativeX = Mouse.X - SliderBg.AbsolutePosition.X
        local pos = math.clamp(relativeX / SliderBg.AbsoluteSize.X, 0.01, 1)
        PanicThreshold = pos
        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
        PanicLabel.Text = "  🛡️ Escudo Pánico — Escapa al " .. math.floor(pos * 100) .. "%"
    end)
end)

uis.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and sliderCon then
        sliderCon:Disconnect()
        sliderCon = nil
    end
end)

BtnHeight.MouseButton1Click:Connect(function()
    if FarmMode == "Arriba" then
        FarmMode = "Detras"
        OfsY = 0
        OfsZ = 6
        BtnHeight.Text = "  Posición: 🥷 Por la Espalda"
    elseif FarmMode == "Detras" then
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
end)

-- Lógica para Ocultar/Mostrar (Minimizar)
local function ToggleUI()
    MF.Visible = not MF.Visible
    if not MF.Visible then
        if CodesFrame then CodesFrame.Visible = false end
    end
end
BtnMin.MouseButton1Click:Connect(ToggleUI)
BtnFloat.MouseButton1Click:Connect(ToggleUI)

-- ==============================================================================
-- [SISTEMA] FRUIT ESP GLOBAL (EXTRA SENSORY PERCEPTION)
-- Se ejecuta de fondo para marcar frutas nacidas sin generar Lag en tu UI
-- ==============================================================================
task.spawn(function()
    while task.wait(3) do
        pcall(function()
            local CoreGUI = pcall(function() return game:GetService("CoreGui").Name end) and game:GetService("CoreGui") or LP:WaitForChild("PlayerGui")
            local ESPFolder = CoreGUI:FindFirstChild("OmniESPFolder")
            if not ESPFolder then
                ESPFolder = Instance.new("Folder", CoreGUI)
                ESPFolder.Name = "OmniESPFolder"
            end
            
            -- Limpiar ESPs viejos si la fruta desapareció o alguien la levantó
            for _, esp in pairs(ESPFolder:GetChildren()) do
                if not esp.Adornee or esp.Adornee.Parent == nil then
                    esp:Destroy()
                end
            end
            
            -- Buscar frutas frescas en Workspace MUNDIAL
            for _, obj in pairs(Workspace:GetDescendants()) do
                local n = obj.Name:lower()
                if (n:match("fruit") or n:match("akuma")) and not obj:IsDescendantOf(LP.Character) then
                    -- Nos aseguramos que no sea la fruta que sostiene el vendedor ni servicios raros
                    if not obj.Parent.Name:lower():match("dealer") and not obj.Parent.Name:lower():match("servicenpc") then
                        -- Filtramos Modelos VAMP, Herramientas, etc...
                        local pPart = obj:IsA("Model") and obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart") or (obj:IsA("BasePart") and obj) or obj:FindFirstChild("HumanoidRootPart")
                        if pPart then
                            -- Crear ESP si no está etiquetada
                            local exists = false
                            for _, esp in pairs(ESPFolder:GetChildren()) do
                                if esp.Adornee == pPart then exists = true break end
                            end
                            
                            if not exists then
                                local bbg = Instance.new("BillboardGui", ESPFolder)
                                bbg.Adornee = pPart
                                bbg.Size = UDim2.new(0, 150, 0, 50)
                                bbg.AlwaysOnTop = true
                                bbg.StudsOffset = Vector3.new(0, 5, 0)
                                
                                local txt = Instance.new("TextLabel", bbg)
                                txt.Size = UDim2.new(1, 0, 1, 0)
                                txt.BackgroundTransparency = 1
                                txt.Text = "🍏 " .. obj.Name .. " ALERTA"
                                txt.TextColor3 = Color3.new(0, 1, 0.2)
                                txt.TextStrokeTransparency = 0.1
                                txt.TextStrokeColor3 = Color3.new(0,0,0)
                                txt.Font = Enum.Font.GothamBlack
                                txt.TextSize = 14
                                
                                -- Alerta por Chat para el Bot!
                                print("¡ALERTA GLOBAL! EN LA ISLA ACABA DE CAER: ", obj.Name)
                            end
                            
                            -- AUTO-SNIPER DISPARADOR
                            if AutoSnipeFruit and not IsTraveling then
                                print("🍏 [AUTO-SNIPE FRUIT] Robando Controles para recoger: " .. obj.Name)
                                SafeTravel(pPart.Position, "¡FRUTA RECIÉN CARGADA! ("..obj.Name..")")
                            end
                        end
                    end
                end
            end
        end)
    end
end)
