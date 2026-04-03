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
-- GUI
-- ==============================================================================
local TargetGui = pcall(function() return CoreGui.Name end) and CoreGui or LP:WaitForChild("PlayerGui")
for _, v in pairs(TargetGui:GetChildren()) do if v.Name == "OmniAutoFarm" then pcall(function() v:Destroy() end) end end

local SG = Instance.new("ScreenGui")
SG.Name = "OmniAutoFarm"
SG.ResetOnSpawn = false
SG.Parent = TargetGui

local MF = Instance.new("Frame", SG)
MF.Size = UDim2.new(0, 300, 0, 440)
MF.Position = UDim2.new(0.05, 0, 0.4, 0)
MF.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MF.BorderSizePixel = 2
MF.BorderColor3 = Color3.fromRGB(255, 0, 100)
MF.Active = true
MF.Draggable = true

local BtnFloat = Instance.new("TextButton", SG)
BtnFloat.Size = UDim2.new(0, 45, 0, 45)
BtnFloat.Position = UDim2.new(0, 20, 0, 20)
BtnFloat.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
BtnFloat.BorderColor3 = Color3.fromRGB(255, 0, 100)
BtnFloat.BorderSizePixel = 2
BtnFloat.Text = "💎"
BtnFloat.TextSize = 20
BtnFloat.Active = true
BtnFloat.Draggable = true

local Title = Instance.new("TextLabel", MF)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(50, 10, 20)
Title.Text = " ⚔️ AURA-FARM (HOVER MODE)"
Title.TextColor3 = Color3.fromRGB(255, 150, 150)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local BtnMin = Instance.new("TextButton", MF)
BtnMin.Size = UDim2.new(0, 30, 0, 30)
BtnMin.Position = UDim2.new(1, -30, 0, 0)
BtnMin.BackgroundTransparency = 1
BtnMin.Text = "➖"
BtnMin.TextColor3 = Color3.new(1, 1, 1)
BtnMin.TextSize = 16
BtnMin.Font = Enum.Font.GothamBold

local StatusLabel = Instance.new("TextLabel", MF)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0, 35)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: INACTIVO"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.Font = Enum.Font.Gotham

local BtnToggle = Instance.new("TextButton", MF)
BtnToggle.Size = UDim2.new(0.9, 0, 0, 40)
BtnToggle.Position = UDim2.new(0.05, 0, 0, 70)
BtnToggle.BackgroundColor3 = Color3.fromRGB(100, 20, 30)
BtnToggle.TextColor3 = Color3.new(1,1,1)
BtnToggle.Font = Enum.Font.GothamBold
BtnToggle.TextSize = 16
BtnToggle.Text = "► INICIAR AUTO-FARM"

local BtnHeight = Instance.new("TextButton", MF)
BtnHeight.Size = UDim2.new(0.9, 0, 0, 30)
BtnHeight.Position = UDim2.new(0.05, 0, 0, 120)
BtnHeight.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
BtnHeight.TextColor3 = Color3.new(1,1,1)
BtnHeight.Font = Enum.Font.Gotham
BtnHeight.TextSize = 12
BtnHeight.Text = "Posición Segura: ☁️ ARRIBA"

local BtnCodes = Instance.new("TextButton", MF)
BtnCodes.Size = UDim2.new(0.9, 0, 0, 35)
BtnCodes.Position = UDim2.new(0.05, 0, 0, 160)
BtnCodes.BackgroundColor3 = Color3.fromRGB(20, 60, 90)
BtnCodes.TextColor3 = Color3.new(1,1,1)
BtnCodes.Font = Enum.Font.GothamBold
BtnCodes.TextSize = 12
BtnCodes.Text = "📋 ABRIR GESTOR DE CÓDIGOS"

local BtnMagnet = Instance.new("TextButton", MF)
BtnMagnet.Size = UDim2.new(0.42, 0, 0, 35)
BtnMagnet.Position = UDim2.new(0.05, 0, 0, 200)
BtnMagnet.BackgroundColor3 = Color3.fromRGB(50, 20, 60)
BtnMagnet.TextColor3 = Color3.new(1,1,1)
BtnMagnet.Font = Enum.Font.GothamBold
BtnMagnet.TextSize = 11
BtnMagnet.Text = "🧲 IMÁN MOBS"

local BtnSkill = Instance.new("TextButton", MF)
BtnSkill.Size = UDim2.new(0.42, 0, 0, 35)
BtnSkill.Position = UDim2.new(0.53, 0, 0, 200)
BtnSkill.BackgroundColor3 = Color3.fromRGB(80, 40, 20)
BtnSkill.TextColor3 = Color3.new(1,1,1)
BtnSkill.Font = Enum.Font.GothamBold
BtnSkill.TextSize = 11
BtnSkill.Text = "🔥 AUTO SKILL (X)"

local BtnBoss = Instance.new("TextButton", MF)
BtnBoss.Size = UDim2.new(0.9, 0, 0, 30)
BtnBoss.Position = UDim2.new(0.05, 0, 0, 245)
BtnBoss.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
BtnBoss.TextColor3 = Color3.new(1,1,1)
BtnBoss.Font = Enum.Font.GothamBold
BtnBoss.TextSize = 11
BtnBoss.Text = "🎯 CAZAR BOSSES: ON"

local BtnTravelMenu = Instance.new("TextButton", MF)
BtnTravelMenu.Size = UDim2.new(0.9, 0, 0, 30)
BtnTravelMenu.Position = UDim2.new(0.05, 0, 0, 280)
BtnTravelMenu.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
BtnTravelMenu.TextColor3 = Color3.new(1,1,1)
BtnTravelMenu.Font = Enum.Font.GothamBold
BtnTravelMenu.TextSize = 11
BtnTravelMenu.Text = "🧭 ABRIR MENÚ DE VIAJE SEGURO (NOCLIP)"

local BtnSpy = Instance.new("TextButton", MF)
BtnSpy.Size = UDim2.new(0.9, 0, 0, 30)
BtnSpy.Position = UDim2.new(0.05, 0, 0, 320)
BtnSpy.BackgroundColor3 = Color3.fromRGB(30, 60, 40)
BtnSpy.TextColor3 = Color3.new(1,1,1)
BtnSpy.Font = Enum.Font.GothamBold
BtnSpy.TextSize = 10
BtnSpy.Text = "📡 INICIAR ESCANEAR CONTINUO DE MAPA"

local BtnAutoTour = Instance.new("TextButton", MF)
BtnAutoTour.Size = UDim2.new(0.9, 0, 0, 30)
BtnAutoTour.Position = UDim2.new(0.05, 0, 0, 360)
BtnAutoTour.BackgroundColor3 = Color3.fromRGB(120, 40, 150)
BtnAutoTour.TextColor3 = Color3.new(1,1,1)
BtnAutoTour.Font = Enum.Font.GothamBold
BtnAutoTour.TextSize = 10
BtnAutoTour.Text = "🤖 INICIAR AUTO-EXPLORADOR (TOUR GLOBAL)"

local LogFrame = Instance.new("Frame", SG)
LogFrame.Size = UDim2.new(0, 300, 0, 400)
LogFrame.Position = UDim2.new(1, -320, 0.5, -200)
LogFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
LogFrame.BorderSizePixel = 2
LogFrame.BorderColor3 = Color3.fromRGB(120, 40, 150)
LogFrame.Visible = false

local LogTitle = Instance.new("TextLabel", LogFrame)
LogTitle.Size = UDim2.new(1, 0, 0, 30)
LogTitle.BackgroundColor3 = Color3.fromRGB(80, 20, 100)
LogTitle.Text = "📡 LOG BOT CARTÓGRAFO"
LogTitle.TextColor3 = Color3.new(1,1,1)
LogTitle.Font = Enum.Font.GothamBold

local LogScroll = Instance.new("ScrollingFrame", LogFrame)
LogScroll.Size = UDim2.new(1, -10, 1, -40)
LogScroll.Position = UDim2.new(0, 5, 0, 35)
LogScroll.BackgroundTransparency = 1
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.ScrollBarThickness = 3
local LogLayout = Instance.new("UIListLayout", LogScroll)
LogLayout.Padding = UDim.new(0, 3)

local function AddLog(text, color)
    local l = Instance.new("TextLabel", LogScroll)
    l.Size = UDim2.new(1, 0, 0, 15)
    l.BackgroundTransparency = 1
    l.TextColor3 = color or Color3.new(1,1,1)
    l.TextSize = 11
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = text
    LogScroll.CanvasSize = UDim2.new(0, 0, 0, LogLayout.AbsoluteContentSize.Y)
    LogScroll.CanvasPosition = Vector2.new(0, LogScroll.CanvasSize.Y.Offset)
end

local PanicLabel = Instance.new("TextLabel", MF)
PanicLabel.Size = UDim2.new(0.9, 0, 0, 15)
PanicLabel.Position = UDim2.new(0.05, 0, 0, 400)
PanicLabel.BackgroundTransparency = 1
PanicLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PanicLabel.Font = Enum.Font.GothamBold
PanicLabel.TextSize = 10
PanicLabel.Text = "🛡️ ESCUDO PÁNICO (ESCAPA AL " .. math.floor(PanicThreshold * 100) .. "%)"

local SliderBg = Instance.new("TextButton", MF)
SliderBg.Size = UDim2.new(0.9, 0, 0, 15)
SliderBg.Position = UDim2.new(0.05, 0, 0, 380)
SliderBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SliderBg.Text = ""

local SliderFill = Instance.new("Frame", SliderBg)
SliderFill.Size = UDim2.new(PanicThreshold, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
SliderFill.BorderSizePixel = 0

-- ==============================================================================
-- PESTAÑA VIAJE SEGURO (FLY NOCLIP)
-- ==============================================================================
local TravelFrame = Instance.new("Frame", SG)
TravelFrame.Size = UDim2.new(0, 250, 0, 360)
TravelFrame.Position = UDim2.new(0.05, 310, 0.4, 0)
TravelFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
TravelFrame.BorderSizePixel = 2
TravelFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
TravelFrame.Active = true
TravelFrame.Draggable = true
TravelFrame.Visible = false

local TTitle = Instance.new("TextLabel", TravelFrame)
TTitle.Size = UDim2.new(1, 0, 0, 30)
TTitle.BackgroundColor3 = Color3.fromRGB(10, 40, 80)
TTitle.Text = " ✈️ MENU NAVEGACIÓN"
TTitle.TextColor3 = Color3.new(1,1,1)
TTitle.Font = Enum.Font.GothamBold
TTitle.TextSize = 13

local TBtnClose = Instance.new("TextButton", TravelFrame)
TBtnClose.Size = UDim2.new(0, 30, 0, 30)
TBtnClose.Position = UDim2.new(1, -30, 0, 0)
TBtnClose.BackgroundTransparency = 1
TBtnClose.Text = "❌"
TBtnClose.TextColor3 = Color3.new(1,1,1)

local TScroll = Instance.new("ScrollingFrame", TravelFrame)
TScroll.Size = UDim2.new(1, 0, 1, -30)
TScroll.Position = UDim2.new(0, 0, 0, 30)
TScroll.BackgroundTransparency = 1
TScroll.ScrollBarThickness = 4
TScroll.CanvasSize = UDim2.new(0, 0, 0, 700)

local IsTraveling = false
local AutoSnipeFruit = false

local function CancelTravel()
    IsTraveling = false
    StatusLabel.Text = "Status: INACTIVO"
end

local function SafeTravel(targetVector3, destinationName)
    CancelTravel()
    task.wait(0.1)
    IsTraveling = true
    
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    -- Frenar AutoFarm para que no entre en dilema
    AutoFarm = false
    BtnToggle.BackgroundColor3 = Color3.fromRGB(100, 20, 30)
    BtnToggle.Text = "► INICIAR AUTO-FARM"
    
    StatusLabel.Text = "✈️ Viajando a: " .. destinationName
    
    task.spawn(function()
        while IsTraveling do
            pcall(function()
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (hrp.Position - targetVector3).Magnitude
                    if dist <= 15 then
                        IsTraveling = false
                        StatusLabel.Text = "Status: 🏁 Llegada a " .. destinationName
                        char:PivotTo(CFrame.new(targetVector3))
                    else
                        local step = math.clamp(30 / dist, 0, 1) -- ~150 studs/s
                        
                        -- VUELO RECTO CAMUFLADO (Ondulación):
                        -- Usamos math.sin para mover el personaje arriba/abajo de forma sinusoidal natural
                        -- Esto engaña al ojo humano para que parezca que presiona 'Space' para saltar repetidamente
                        local ondulateBase = math.sin(os.clock() * 6) * 2 -- Sube y baja 2 Studs de forma suave
                        local targetLerp = hrp.CFrame:Lerp(CFrame.new(targetVector3), step)
                        char:PivotTo(targetLerp * CFrame.new(0, ondulateBase, 0))
                    end
                end
            end)
            task.wait(0.2)
        end
    end)
end

local travelList = Instance.new("UIListLayout", TScroll)
travelList.Padding = UDim.new(0, 5)
travelList.HorizontalAlignment = Enum.HorizontalAlignment.Center
travelList.SortOrder = Enum.SortOrder.LayoutOrder

local function LabelTitle(text)
    local l = Instance.new("TextLabel", TScroll)
    l.Size = UDim2.new(1, 0, 0, 20)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.fromRGB(150, 150, 200)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.Text = text
end

local function CreateDynamicTravelBtn(color, text, mode, vectorOrName)
    local btn = Instance.new("TextButton", TScroll)
    btn.Size = UDim2.new(0.95, 0, 0, 30)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 10
    btn.Text = " " .. text
    btn.TextXAlignment = Enum.TextXAlignment.Left
    
    btn.MouseButton1Click:Connect(function()
        if mode == "Vector3" then
            SafeTravel(vectorOrName, text)
        elseif mode == "FindNPC" then
            local obj = nil
            local searchName = tostring(vectorOrName):lower()
            -- Búsqueda agresiva ignorando carpetas estructurales
            for _, v in pairs(Workspace:GetDescendants()) do
                if v.Name:lower():match(searchName) then
                    if v:IsA("Model") and v.PrimaryPart then obj = v break end
                    if v:FindFirstChild("HumanoidRootPart") then obj = v break end
                end
            end
            
            if obj then
                local tPos = obj.PrimaryPart and obj.PrimaryPart.Position or obj:FindFirstChild("HumanoidRootPart").Position
                SafeTravel(tPos, text)
            else
                StatusLabel.Text = "Status: ❌ VENDEDOR NO NACE EN EL MAPA AÚN."
            end
        elseif mode == "Cancel" then
            CancelTravel()
        elseif mode == "FruitSnipe" then
            AutoSnipeFruit = not AutoSnipeFruit
            if AutoSnipeFruit then
                btn.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
                btn.TextColor3 = Color3.fromRGB(0, 0, 0)
                btn.Text = " 🍏 AUTO-RECOLECTOR: ACTIVADO"
                StatusLabel.Text = "Status: 🍏 Cazando (Vuela por las islas...)"
            else
                btn.BackgroundColor3 = Color3.fromRGB(20, 200, 50)
                btn.TextColor3 = Color3.new(1,1,1)
                btn.Text = " 🍏 AUTO-RECOLECTOR (SNIPER): OFF"
                StatusLabel.Text = "Status: ❌ Auto-Cazador de Frutas Apagado."
            end
        end
    end)
end

LabelTitle("🌍 ISLAS Y PORTALES GLOBALES")
CreateDynamicTravelBtn(Color3.fromRGB(30,50,80), "🌀 Starter Island", "Vector3", Vector3.new(-71, -2, -299))
CreateDynamicTravelBtn(Color3.fromRGB(80,70,30), "🏜️ Sand Island", "Vector3", Vector3.new(17, -6, -305))
CreateDynamicTravelBtn(Color3.fromRGB(30,100,30), "🌴 Jungle Island", "Vector3", Vector3.new(-392, -2, 407))
CreateDynamicTravelBtn(Color3.fromRGB(150,100,30), "🐫 Desert Island", "Vector3", Vector3.new(-688, -1, -287))
CreateDynamicTravelBtn(Color3.fromRGB(150,150,200), "❄️ Snow Island", "Vector3", Vector3.new(-182, -1, -998))
CreateDynamicTravelBtn(Color3.fromRGB(50,50,150), "⚓ Sailor Island", "Vector3", Vector3.new(182, 5, 669))
CreateDynamicTravelBtn(Color3.fromRGB(100,30,100), "👻 Hollow Island", "Vector3", Vector3.new(-542, -1, 872))
CreateDynamicTravelBtn(Color3.fromRGB(60,60,60), "⛩️ Shibuya Island", "Vector3", Vector3.new(1269, 13, 233))
CreateDynamicTravelBtn(Color3.fromRGB(80,40,40), "🏙️ Shinjuku Island", "Vector3", Vector3.new(189, -1, -1643))
CreateDynamicTravelBtn(Color3.fromRGB(100,100,30), "🏫 Academy Island", "Vector3", Vector3.new(962, -2, 1053))
CreateDynamicTravelBtn(Color3.fromRGB(40,40,100), "🗡️ Lawless Island", "Vector3", Vector3.new(209, -4, 1673))
CreateDynamicTravelBtn(Color3.fromRGB(10,100,100), "🧪 Portal Slime", "Vector3", Vector3.new(-982, -2, 275))
CreateDynamicTravelBtn(Color3.fromRGB(100,20,50), "⚔️ Portal Ninja", "Vector3", Vector3.new(-1621, 10, -575))

LabelTitle("🔥 EVENTOS ESPECIALES Y DUNGEONS")
CreateDynamicTravelBtn(Color3.fromRGB(200,50,50), "👹 Boss Rush Portal", "Vector3", Vector3.new(106, 6, 840))
CreateDynamicTravelBtn(Color3.fromRGB(100,20,20), "⚖️ Portal Judgement", "Vector3", Vector3.new(-1029, -2, -989))
CreateDynamicTravelBtn(Color3.fromRGB(150,80,20), "🗼 Infinite Tower Portal", "Vector3", Vector3.new(1276, -4, -1474))
CreateDynamicTravelBtn(Color3.fromRGB(80,50,80), "🕳️ Dungeon Portal", "Vector3", Vector3.new(1272, 5, -897))
CreateDynamicTravelBtn(Color3.fromRGB(250,50,50), "💀 Strongest Boss Portal", "Vector3", Vector3.new(593, -2, -1052))

LabelTitle("🤖 MISIONES IMPORTANTES")
CreateDynamicTravelBtn(Color3.fromRGB(30,80,30), "📜 Quest Starter (Lvl 0-249)", "Vector3", Vector3.new(171, 16, -215))
CreateDynamicTravelBtn(Color3.fromRGB(80,30,80), "👑 Shadow Monarch", "Vector3", Vector3.new(243, 26, -84))
CreateDynamicTravelBtn(Color3.fromRGB(80,30,80), "🥊 Quest Haki (Nieve)", "Vector3", Vector3.new(-499, 23, -1253))
CreateDynamicTravelBtn(Color3.fromRGB(80,30,80), "👑 Quest Ragna (Nieve)", "Vector3", Vector3.new(-273, -5, -1354))

LabelTitle("🍎 FRUTAS Y MERCADOS")
CreateDynamicTravelBtn(Color3.fromRGB(200,80,80), "💎 Vendedor (Gemas)", "FindNPC", "GemFruitDealer")
CreateDynamicTravelBtn(Color3.fromRGB(200,80,80), "🪙 Vendedor (Monedas)", "FindNPC", "CoinFruitDealer")
CreateDynamicTravelBtn(Color3.fromRGB(20,200,50), "🍏 AUTO-RECOLECTOR (SNIPER): OFF", "FruitSnipe", "")

LabelTitle("🚨 EMERGENCIAS")
CreateDynamicTravelBtn(Color3.fromRGB(150,20,20), "🛑 DETENER VUELO", "Cancel", "")

BtnTravelMenu.MouseButton1Click:Connect(function() TravelFrame.Visible = not TravelFrame.Visible end)
TBtnClose.MouseButton1Click:Connect(function() TravelFrame.Visible = false end)

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
        BtnToggle.Text = "◼ DETENER AUTO-FARM"
        BtnToggle.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        StatusLabel.Text = "Status: BUSCANDO OBJETIVOS"
        
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:FindFirstChildOfClass("BodyVelocity") then
            hrp:FindFirstChildOfClass("BodyVelocity"):Destroy()
        end
    else
        BtnToggle.Text = "► INICIAR AUTO-FARM"
        BtnToggle.BackgroundColor3 = Color3.fromRGB(100, 20, 30)
        StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        StatusLabel.Text = "Status: INACTIVO"
        
        -- Anti-Caída del Map al Detenerse: 
        -- Te teletransporta 15 studs hacia arriba (a la superficie) antes de devolverte la gravedad
        pcall(function()
            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Sube 15 metros en seco para asegurarte de pisar la hierba y no caer al vacío infinito
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
        BtnMagnet.BackgroundColor3 = Color3.fromRGB(150, 40, 180)
        BtnMagnet.Text = "🧲 IMÁN: ON"
    else
        BtnMagnet.BackgroundColor3 = Color3.fromRGB(50, 20, 60)
        BtnMagnet.Text = "🧲 IMÁN MOBS"
    end
end)

BtnSkill.MouseButton1Click:Connect(function()
    AutoSkillEnabled = not AutoSkillEnabled
    if AutoSkillEnabled then
        BtnSkill.BackgroundColor3 = Color3.fromRGB(200, 80, 40)
        BtnSkill.Text = "🔥 SKILL (X): ON"
    else
        BtnSkill.BackgroundColor3 = Color3.fromRGB(80, 40, 20)
        BtnSkill.Text = "🔥 AUTO SKILL (X)"
    end
end)

BtnBoss.MouseButton1Click:Connect(function()
    if TargetBosses == "Normal" then
        TargetBosses = "Ignorar"
        BtnBoss.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        BtnBoss.Text = "🛑 IGNORAR BOSSES: OFF"
    elseif TargetBosses == "Ignorar" then
        TargetBosses = "SoloBoss"
        BtnBoss.BackgroundColor3 = Color3.fromRGB(200, 20, 150)
        BtnBoss.Text = "👹 SOLO BOSS (FLY AIR)"
    else
        TargetBosses = "Normal"
        BtnBoss.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
        BtnBoss.Text = "🎯 CAZAR BOSSES: ON"
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
local uis = game:GetService("UserInputService")

SliderBg.MouseButton1Down:Connect(function()
    local Mouse = LP:GetMouse()
    if sliderCon then sliderCon:Disconnect() end
    sliderCon = game:GetService("RunService").RenderStepped:Connect(function()
        local relativeX = Mouse.X - SliderBg.AbsolutePosition.X
        local pos = math.clamp(relativeX / SliderBg.AbsoluteSize.X, 0.01, 1)
        PanicThreshold = pos
        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
        PanicLabel.Text = "🛡️ ESCUDO PÁNICO (ESCAPA AL " .. math.floor(pos * 100) .. "%)"
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
        OfsZ = 6 -- 6 studs a la espalda
        BtnHeight.Text = "Posición Segura: 🥷 POR LA ESPALDA"
    elseif FarmMode == "Detras" then
        FarmMode = "Abajo"
        OfsY = -8 -- Exactamente 8 studs bajo tierra
        OfsZ = 6  -- 6 studs a la espalda
        BtnHeight.Text = "Posición Segura: 🕳️ SUBTERRÁNEO TRASERO"
    else
        FarmMode = "Arriba"
        OfsY = 10 -- 10 studs directamente sobre su cabeza
        OfsZ = 0  -- Eje Z nulo para evitar diagonales que te acerquen
        BtnHeight.Text = "Posición Segura: ☁️ ARRIBA"
    end
end)

-- Lógica para Ocultar/Mostrar (Minimizar)
local function ToggleUI()
    MF.Visible = not MF.Visible
    if not MF.Visible then
        if CodesFrame then CodesFrame.Visible = false end
        if TravelFrame then TravelFrame.Visible = false end
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
