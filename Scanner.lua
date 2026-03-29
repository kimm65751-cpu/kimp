-- 🗡️ OMNI-FARM V3.2 (PISO DINÁMICO)
-- ==============================================================================

local SCRIPT_URL = "https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- REFERENCIA CRÍTICA DEL SERVIDOR (Knit ToolService)
-- ==========================================
local ToolRF = ReplicatedStorage.Shared.Packages.Knit.Services.ToolService.RF.ToolActivated

-- ==========================================
-- VARIABLES DE ESTADO
-- ==========================================
local NoclipActivo = false
local ShieldActivo = false
local KiteActivo = false
local MineActivo = false
local FarmTask = nil
local MyShield = nil
local FullbrightActivo = false
local OriginalLighting = nil

-- ANTI-STUCK MINING: Lista negra de minerales que no se pueden picar
local OreBlacklist = {} -- {[ore] = tick() cuando fue baneado}
local MiningTracker = {ore = nil, startHP = nil, startTime = nil}
local MINE_TIMEOUT = 4 -- Segundos sin bajar HP antes de saltar al siguiente
local GlobalMineIdleTracker = {lastHitTime = tick(), isIdle = false} -- Anti-Atasco Global 5s
local BLACKLIST_EXPIRE = 60 -- Segundos antes de reintentar un mineral baneado

-- SELECTOR DE OBJETIVOS: Qué tipos de mobs y minas farmear
-- Clave = nombre base (lowercase, sin números), Valor = true/false
local SelectedMobs = {} -- Se llena con el Scanner
local SelectedOres = {} -- Se llena con el Scanner

-- LÍMITE DE PISO DINÁMICO (Safe Floor)
local SafeFloorY = -50 -- Límite base (Se actualiza con el botón)-- ==========================================
-- FUNCIÓN PARA OBTENER EL NIVEL DEL JUGADOR
-- ==========================================
local function GetMyLevel()
    local lvl = 1
    pcall(function()
        -- Buscar en leaderstats
        local ls = LocalPlayer:FindFirstChild("leaderstats")
        if ls then
            local lv = ls:FindFirstChild("Level") or ls:FindFirstChild("Lvl") or ls:FindFirstChild("Nivel")
            if lv then lvl = tonumber(lv.Value) or 1 end
        end
        -- Buscar como atributo directo del jugador
        local attrLvl = LocalPlayer:GetAttribute("Level") or LocalPlayer:GetAttribute("Lvl")
        if attrLvl then lvl = tonumber(attrLvl) or lvl end
        -- Buscar en carpeta Data/Profile/Stats
        for _, folderName in pairs({"Data", "Profile", "Stats"}) do
            local f = LocalPlayer:FindFirstChild(folderName)
            if f then
                local lv = f:FindFirstChild("Level") or f:FindFirstChild("Lvl")
                if lv and lv:IsA("ValueBase") then lvl = tonumber(lv.Value) or lvl end
            end
        end
    end)
    return lvl
end

-- ==========================================
-- FUNCIÓN PARA OBTENER EL NIVEL DEL ZOMBIE
-- ==========================================
local function GetMobLevel(mob)
    local lvl = 0
    pcall(function()
        -- 1. Buscar atributo "Level"
        local attrLvl = mob:GetAttribute("Level") or mob:GetAttribute("Lvl")
        if attrLvl then lvl = tonumber(attrLvl) or 0; return end
        -- 2. Buscar NumberValue/IntValue hijo
        for _, v in pairs(mob:GetChildren()) do
            if (v:IsA("NumberValue") or v:IsA("IntValue")) and (v.Name == "Level" or v.Name == "Lvl") then
                lvl = tonumber(v.Value) or 0; return
            end
        end
        -- 3. Buscar en BillboardGui texto "[Lvl. X]"
        for _, gui in pairs(mob:GetDescendants()) do
            if gui:IsA("TextLabel") then
                local text = gui.Text or ""
                local match = string.match(text, "%[Lvl%.%s*(%d+)%]")
                if match then lvl = tonumber(match) or 0; return end
            end
        end
    end)
    return lvl
end

-- ==========================================
-- GUI PRINCIPAL (COMPACTA)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OmniFarmUI"
ScreenGui.ResetOnSpawn = false
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "OmniFarmUI" then v:Destroy() end end
ScreenGui.Parent = parentUI

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 280, 0, 400)
Panel.Position = UDim2.new(0.5, -140, 0.5, -155)
Panel.BackgroundColor3 = Color3.fromRGB(10, 15, 10)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(0, 200, 100)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(0, 80, 40)
Title.Text = " 🗡️ OMNI-FARM V3.2"
Title.TextColor3 = Color3.fromRGB(0, 255, 100)
Title.TextSize = 13
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Panel

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.Code
CloseBtn.TextSize = 16
CloseBtn.Parent = Panel

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 40, 0, 30)
MinBtn.Position = UDim2.new(1, -80, 0, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(180, 150, 0)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.Code
MinBtn.TextSize = 16
MinBtn.Parent = Panel

local ReloadBtn = Instance.new("TextButton")
ReloadBtn.Size = UDim2.new(1, -8, 0, 28)
ReloadBtn.Position = UDim2.new(0, 4, 0, 34)
ReloadBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 120)
ReloadBtn.Text = "🔄 RECARGAR SCRIPT"
ReloadBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
ReloadBtn.Font = Enum.Font.Code
ReloadBtn.TextSize = 11
ReloadBtn.Parent = Panel

local OpenIcon = Instance.new("ImageButton")
OpenIcon.Size = UDim2.new(0, 50, 0, 50)
OpenIcon.Position = UDim2.new(0.5, -25, 0, 20)
OpenIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
OpenIcon.Image = "rbxassetid://10886105073"
OpenIcon.Visible = false
OpenIcon.Active = true
OpenIcon.Draggable = true
OpenIcon.Parent = ScreenGui
Instance.new("UICorner", OpenIcon).CornerRadius = UDim.new(1, 0)

-- ==========================================
-- BOTONES (SIN AIMBOT)
-- ==========================================
local NoclipBtn = Instance.new("TextButton")
NoclipBtn.Size = UDim2.new(0.5, -6, 0, 35)
NoclipBtn.Position = UDim2.new(0, 4, 0, 68)
NoclipBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
NoclipBtn.Text = "👻 NOCLIP: OFF"
NoclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NoclipBtn.Font = Enum.Font.Code
NoclipBtn.TextSize = 11
NoclipBtn.Parent = Panel

local ShieldBtn = Instance.new("TextButton")
ShieldBtn.Size = UDim2.new(0.5, -6, 0, 35)
ShieldBtn.Position = UDim2.new(0.5, 2, 0, 68)
ShieldBtn.BackgroundColor3 = Color3.fromRGB(20, 100, 160)
ShieldBtn.Text = "🛡️ MURO CRISTAL"
ShieldBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ShieldBtn.Font = Enum.Font.Code
ShieldBtn.TextSize = 11
ShieldBtn.Parent = Panel

local KiteBtn = Instance.new("TextButton")
KiteBtn.Size = UDim2.new(0.5, -6, 0, 45)
KiteBtn.Position = UDim2.new(0, 4, 0, 110)
KiteBtn.BackgroundColor3 = Color3.fromRGB(180, 80, 40)
KiteBtn.Text = "🗡️ FARM MOBS"
KiteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
KiteBtn.Font = Enum.Font.Code
KiteBtn.TextSize = 12
KiteBtn.Parent = Panel

local MineBtn = Instance.new("TextButton")
MineBtn.Size = UDim2.new(0.5, -6, 0, 45)
MineBtn.Position = UDim2.new(0.5, 2, 0, 110)
MineBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 40)
MineBtn.Text = "⛏️ FARM MINAS"
MineBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MineBtn.Font = Enum.Font.Code
MineBtn.TextSize = 12
MineBtn.Parent = Panel

local ScannerBtn = Instance.new("TextButton")
ScannerBtn.Size = UDim2.new(0.5, -6, 0, 30)
ScannerBtn.Position = UDim2.new(0, 4, 0, 160)
ScannerBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
ScannerBtn.Text = "🔍 SCANNER"
ScannerBtn.TextColor3 = Color3.fromRGB(255, 220, 255)
ScannerBtn.Font = Enum.Font.Code
ScannerBtn.TextSize = 11
ScannerBtn.Parent = Panel

local SetFloorBtn = Instance.new("TextButton")
SetFloorBtn.Size = UDim2.new(0.5, -6, 0, 30)
SetFloorBtn.Position = UDim2.new(0.5, 2, 0, 160)
SetFloorBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 50)
SetFloorBtn.Text = "📍 FIJAR PISO"
SetFloorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SetFloorBtn.Font = Enum.Font.Code
SetFloorBtn.TextSize = 11
SetFloorBtn.Parent = Panel

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -8, 0, 150)
StatusLabel.Position = UDim2.new(0, 4, 0, 195)
StatusLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
StatusLabel.Text = "Estado: Inactivo.\n\n🛡️ MURO CRISTAL: Atasca zombis.\n👻 NOCLIP: Atraviesas paredes.\n🗡️ FARM MOBS: Mata mobs seleccionados.\n⛏️ FARM MINAS: Pica minas seleccionadas.\n🔍 SCANNER: Detecta y selecciona objetivos.\n\nUsa el SCANNER primero para elegir qué farmear."
StatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 11
StatusLabel.TextWrapped = true
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
StatusLabel.Parent = Panel

-- ==========================================
-- BOTÓN FULLBRIGHT (VISIÓN NOCTURNA)
-- ==========================================
local FullbrightBtn = Instance.new("TextButton")
FullbrightBtn.Size = UDim2.new(1, -8, 0, 28)
FullbrightBtn.Position = UDim2.new(0, 4, 0, 350)
FullbrightBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 40)
FullbrightBtn.Text = "🔦 VISIÓN NOCTURNA: OFF"
FullbrightBtn.TextColor3 = Color3.fromRGB(255, 255, 200)
FullbrightBtn.Font = Enum.Font.Code
FullbrightBtn.TextSize = 11
FullbrightBtn.Parent = Panel

FullbrightBtn.MouseButton1Click:Connect(function()
    FullbrightActivo = not FullbrightActivo
    if FullbrightActivo then
        FullbrightBtn.Text = "🔦 VISIÓN NOCTURNA: ON ✅"
        FullbrightBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 50)
        -- Guardar valores originales
        OriginalLighting = {
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            FogEnd = Lighting.FogEnd,
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            GlobalShadows = Lighting.GlobalShadows,
        }
        -- Aplicar fullbright
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1e9
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        Lighting.GlobalShadows = false
        -- Eliminar efectos de oscuridad (Atmosphere, ColorCorrection, etc.)
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") then
                v.Enabled = false
            end
        end
        StatusLabel.Text = "🔦 Visión Nocturna ACTIVADA. Todo se ve claro."
    else
        FullbrightBtn.Text = "🔦 VISIÓN NOCTURNA: OFF"
        FullbrightBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 40)
        -- Restaurar valores originales
        if OriginalLighting then
            Lighting.Brightness = OriginalLighting.Brightness
            Lighting.ClockTime = OriginalLighting.ClockTime
            Lighting.FogEnd = OriginalLighting.FogEnd
            Lighting.Ambient = OriginalLighting.Ambient
            Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
            Lighting.GlobalShadows = OriginalLighting.GlobalShadows
        end
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") then
                v.Enabled = true
            end
        end
        StatusLabel.Text = "🔦 Visión Nocturna APAGADA."
    end
end)

-- ==========================================
-- SCANNER PANEL (Panel Flotante de Selección)
-- ==========================================
local ScannerPanel = Instance.new("Frame")
ScannerPanel.Size = UDim2.new(0, 320, 0, 420)
ScannerPanel.Position = UDim2.new(0.5, 160, 0.5, -210)
ScannerPanel.BackgroundColor3 = Color3.fromRGB(15, 10, 25)
ScannerPanel.BorderSizePixel = 2
ScannerPanel.BorderColor3 = Color3.fromRGB(150, 80, 255)
ScannerPanel.Active = true
ScannerPanel.Draggable = true
ScannerPanel.Visible = false
ScannerPanel.Parent = ScreenGui

local ScanTitle = Instance.new("TextLabel")
ScanTitle.Size = UDim2.new(1, -40, 0, 30)
ScanTitle.BackgroundColor3 = Color3.fromRGB(80, 30, 120)
ScanTitle.Text = " 🔍 SELECTOR DE OBJETIVOS"
ScanTitle.TextColor3 = Color3.fromRGB(220, 180, 255)
ScanTitle.TextSize = 13
ScanTitle.Font = Enum.Font.Code
ScanTitle.TextXAlignment = Enum.TextXAlignment.Left
ScanTitle.Parent = ScannerPanel

local ScanCloseBtn = Instance.new("TextButton")
ScanCloseBtn.Size = UDim2.new(0, 40, 0, 30)
ScanCloseBtn.Position = UDim2.new(1, -40, 0, 0)
ScanCloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ScanCloseBtn.Text = "X"
ScanCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanCloseBtn.Font = Enum.Font.Code
ScanCloseBtn.TextSize = 16
ScanCloseBtn.Parent = ScannerPanel
ScanCloseBtn.MouseButton1Click:Connect(function() ScannerPanel.Visible = false end)

local MobsHeader = Instance.new("TextLabel")
MobsHeader.Size = UDim2.new(1, 0, 0, 22)
MobsHeader.Position = UDim2.new(0, 0, 0, 32)
MobsHeader.BackgroundColor3 = Color3.fromRGB(120, 50, 30)
MobsHeader.Text = " 🧟 MOBS DETECTADOS (Click para ON/OFF)"
MobsHeader.TextColor3 = Color3.fromRGB(255, 200, 180)
MobsHeader.TextSize = 11
MobsHeader.Font = Enum.Font.Code
MobsHeader.TextXAlignment = Enum.TextXAlignment.Left
MobsHeader.Parent = ScannerPanel

local MobScroll = Instance.new("ScrollingFrame")
MobScroll.Size = UDim2.new(1, -8, 0, 140)
MobScroll.Position = UDim2.new(0, 4, 0, 56)
MobScroll.BackgroundColor3 = Color3.fromRGB(20, 15, 15)
MobScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
MobScroll.ScrollBarThickness = 5
MobScroll.Parent = ScannerPanel
Instance.new("UIListLayout", MobScroll).Padding = UDim.new(0, 2)

local OresHeader = Instance.new("TextLabel")
OresHeader.Size = UDim2.new(1, 0, 0, 22)
OresHeader.Position = UDim2.new(0, 0, 0, 200)
OresHeader.BackgroundColor3 = Color3.fromRGB(30, 80, 50)
OresHeader.Text = " ⛏️ MINAS/PIEDRAS DETECTADAS (Click ON/OFF)"
OresHeader.TextColor3 = Color3.fromRGB(180, 255, 200)
OresHeader.TextSize = 11
OresHeader.Font = Enum.Font.Code
OresHeader.TextXAlignment = Enum.TextXAlignment.Left
OresHeader.Parent = ScannerPanel

local OreScroll = Instance.new("ScrollingFrame")
OreScroll.Size = UDim2.new(1, -8, 0, 140)
OreScroll.Position = UDim2.new(0, 4, 0, 224)
OreScroll.BackgroundColor3 = Color3.fromRGB(15, 20, 15)
OreScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
OreScroll.ScrollBarThickness = 5
OreScroll.Parent = ScannerPanel
Instance.new("UIListLayout", OreScroll).Padding = UDim.new(0, 2)

local ScanStatusLabel = Instance.new("TextLabel")
ScanStatusLabel.Size = UDim2.new(1, -8, 0, 45)
ScanStatusLabel.Position = UDim2.new(0, 4, 0, 370)
ScanStatusLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
ScanStatusLabel.Text = "Presiona el botón Scanner para detectar."
ScanStatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ScanStatusLabel.TextSize = 10
ScanStatusLabel.Font = Enum.Font.Code
ScanStatusLabel.TextWrapped = true
ScanStatusLabel.TextYAlignment = Enum.TextYAlignment.Top
ScanStatusLabel.Parent = ScannerPanel

-- Función para extraer nombre base (sin números del final)
local function GetBaseName(name)
    return string.gsub(name, "%d+$", "")
end

-- Función para crear un botón toggle en un scroll
local function CreateToggleRow(parent, displayName, selectionTable, key, defaultOn)
    if selectionTable[key] ~= nil then return end -- Ya existe, no duplicar
    selectionTable[key] = defaultOn
    
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, -4, 0, 24)
    row.BackgroundColor3 = defaultOn and Color3.fromRGB(30, 100, 30) or Color3.fromRGB(80, 30, 30)
    row.Text = (defaultOn and "  ✅ " or "  ❌ ") .. displayName
    row.TextColor3 = Color3.fromRGB(255, 255, 255)
    row.TextXAlignment = Enum.TextXAlignment.Left
    row.Font = Enum.Font.Code
    row.TextSize = 11
    row.Parent = parent
    
    row.MouseButton1Click:Connect(function()
        selectionTable[key] = not selectionTable[key]
        if selectionTable[key] then
            row.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
            row.Text = "  ✅ " .. displayName
        else
            row.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
            row.Text = "  ❌ " .. displayName
        end
    end)
end

-- Función de escaneo del mundo
local function RunScanner()
    -- Limpiar listas visuales
    for _, v in pairs(MobScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, v in pairs(OreScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    
    local mobTypes = {} -- {baseName = {count, sampleHP, sampleLvl}}
    local oreTypes = {} -- {baseName = {count, sampleHP}}
    local char = LocalPlayer.Character
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Model") and obj ~= char then
                local hum = obj:FindFirstChildWhichIsA("Humanoid")
                -- Es un MOB (NPC con Humanoid e IsNpc)
                if hum and hum.Health > 0 and obj:GetAttribute("IsNpc") == true then
                    local baseName = GetBaseName(obj.Name)
                    if not mobTypes[baseName] then
                        local mobLvl = GetMobLevel(obj)
                        mobTypes[baseName] = {count = 1, hp = math.floor(hum.MaxHealth), lvl = mobLvl}
                    else
                        mobTypes[baseName].count = mobTypes[baseName].count + 1
                    end
                end
                -- Es una MINA/PIEDRA (Tiene Health como atributo)
                local oreHP = obj:GetAttribute("Health")
                if oreHP and oreHP > 0 and not hum then
                    local baseName = GetBaseName(obj.Name)
                    if not oreTypes[baseName] then
                        oreTypes[baseName] = {count = 1, hp = math.floor(oreHP)}
                    else
                        oreTypes[baseName].count = oreTypes[baseName].count + 1
                    end
                end
            end
        end)
    end
    
    -- Crear toggle rows para mobs
    local mobCount = 0
    for baseName, data in pairs(mobTypes) do
        mobCount = mobCount + 1
        local display = baseName .. " (x" .. data.count .. " | HP:" .. data.hp
        if data.lvl > 0 then display = display .. " | Lvl:" .. data.lvl end
        display = display .. ")"
        -- Por defecto ON si no existía antes
        local defaultVal = true
        if SelectedMobs[baseName] ~= nil then defaultVal = SelectedMobs[baseName] end
        SelectedMobs[baseName] = nil -- Reset para que CreateToggleRow lo cree
        CreateToggleRow(MobScroll, display, SelectedMobs, baseName, defaultVal)
    end
    
    -- Crear toggle rows para minas
    local oreCount = 0
    for baseName, data in pairs(oreTypes) do
        oreCount = oreCount + 1
        local display = baseName .. " (x" .. data.count .. " | HP:" .. data.hp .. ")"
        local defaultVal = true
        if SelectedOres[baseName] ~= nil then defaultVal = SelectedOres[baseName] end
        SelectedOres[baseName] = nil
        CreateToggleRow(OreScroll, display, SelectedOres, baseName, defaultVal)
    end
    
    ScanStatusLabel.Text = "✅ Detectados: " .. mobCount .. " tipos de mobs, " .. oreCount .. " tipos de minas. Click para activar/desactivar."
end

ScannerBtn.MouseButton1Click:Connect(function()
    ScannerPanel.Visible = not ScannerPanel.Visible
    if ScannerPanel.Visible then
        RunScanner()
    end
end)

-- ==========================================


-- ==========================================
-- EVENTOS DE INTERFAZ
-- ==========================================
local Minimizado = false
MinBtn.MouseButton1Click:Connect(function()
    Minimizado = true
    Panel.Visible = false
    ScannerPanel.Visible = false
    OpenIcon.Visible = true
end)

OpenIcon.MouseButton1Click:Connect(function()
    Minimizado = false
    Panel.Visible = true
    OpenIcon.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    KiteActivo = false; MineActivo = false; ShieldActivo = false; NoclipActivo = false
    if MyShield then pcall(function() MyShield:Destroy() end) MyShield = nil end
    ScreenGui:Destroy()
end)

ReloadBtn.MouseButton1Click:Connect(function()
    KiteActivo = false; MineActivo = false; ShieldActivo = false; NoclipActivo = false
    if MyShield then pcall(function() MyShield:Destroy() end) MyShield = nil end
    pcall(function() ScreenGui:Destroy(); loadstring(game:HttpGet(SCRIPT_URL .. "?r=" .. math.random(11,99)))() end)
end)

-- ==========================================
-- ANTI-AFK (Evita el kick por inactividad de 20 min)
-- ==========================================
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

-- ==========================================
-- MOTOR NOCLIP
-- ==========================================
RunService.Stepped:Connect(function()
    if not NoclipActivo then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false end
    end
end)

NoclipBtn.MouseButton1Click:Connect(function()
    NoclipActivo = not NoclipActivo
    if NoclipActivo then
        NoclipBtn.Text = "👻 NOCLIP: ON"
        NoclipBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 180)
    else
        NoclipBtn.Text = "👻 NOCLIP: OFF"
        NoclipBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        pcall(function()
            local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if r then r.Anchored = false end
        end)
    end
end)

-- ==========================================
-- MURO CRISTAL (FUNCIONAL DEL BACKUP)
-- ==========================================
ShieldBtn.MouseButton1Click:Connect(function()
    ShieldActivo = not ShieldActivo
    if ShieldActivo then
        ShieldBtn.Text = "🛡️ CRISTAL: ON ✅"
        ShieldBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 180)
        
        MyShield = Instance.new("Part")
        MyShield.Name = "MuroDefensivo"
        MyShield.Size = Vector3.new(12, 12, 2)
        MyShield.Transparency = 0.5
        MyShield.Material = Enum.Material.ForceField
        MyShield.BrickColor = BrickColor.new("Cyan")
        MyShield.Anchored = true
        MyShield.CanCollide = true
        MyShield.Parent = Workspace
        
        task.spawn(function()
            while ShieldActivo and MyShield do
                pcall(function()
                    local char = LocalPlayer.Character
                    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
                    if myRoot then
                        for _, v in pairs(char:GetDescendants()) do
                            if v:IsA("BasePart") then
                                local cName = "NCC_" .. v.Name
                                if not MyShield:FindFirstChild(cName) then
                                    local nc = Instance.new("NoCollisionConstraint")
                                    nc.Name = cName
                                    nc.Part0 = v
                                    nc.Part1 = MyShield
                                    nc.Parent = MyShield
                                end
                            end
                        end
                        MyShield.CFrame = myRoot.CFrame * CFrame.new(0, 0, -3.5)
                    end
                end)
                task.wait()
            end
        end)
        StatusLabel.Text = "🛡️ Muro Cristal activo. Los Zombis se atoran en él."
    else
        ShieldBtn.Text = "🛡️ MURO CRISTAL"
        ShieldBtn.BackgroundColor3 = Color3.fromRGB(20, 100, 160)
        if MyShield then MyShield:Destroy(); MyShield = nil end
    end
end)

-- ==========================================
-- FUNCIONES DE FARM (CON FILTRO DE NIVEL)
-- ==========================================
local function findNearest(condFn)
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local closest, closestDist = nil, math.huge
    for _, obj in pairs(Workspace:GetDescendants()) do
        if condFn(obj) then
            local p = nil
            pcall(function()
                local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChildWhichIsA("BasePart")
                if hrp then p = hrp.Position end
            end)
            if p then
                local d = (root.Position - p).Magnitude
                if d < closestDist then closestDist = d; closest = obj end
            end
        end
    end
    return closest, closestDist
end

local function DetenerFarm()
    if not KiteActivo and not MineActivo then
        if FarmTask then task.cancel(FarmTask); FarmTask = nil end
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local r = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if r then
                r.Anchored = false
                -- LIMPIAR BodyVelocity para que deje de volar
                local bv = r:FindFirstChild("_NoclipBV")
                if bv then bv:Destroy() end
            end
            -- Detener caminata
            if hum then hum:Move(Vector3.zero) end
        end)
        StatusLabel.Text = "Estado: Inactivo"
    end
end

SetFloorBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        local r = char and char:FindFirstChild("HumanoidRootPart")
        if r then
            SafeFloorY = r.Position.Y
            StatusLabel.Text = "📍 LÍMITE DE PISO FIJADO\nY = " .. tostring(math.floor(SafeFloorY)) .. " studs.\n\nEl bot NO bajará más de 15 studs debajo de este nivel al buscar minas."
        end
    end)
end)

local function IniciarFarm()
    if FarmTask then return end
    
    FarmTask = task.spawn(function()
        local loopTick = 0
        local zTarget, oreTarget = nil, nil
        local zDist, oDist = math.huge, math.huge

        while KiteActivo or MineActivo do
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local currentHum = char:FindFirstChild("Humanoid")
                local myRoot = char:FindFirstChild("HumanoidRootPart")
                if not myRoot or not currentHum then return end

                loopTick = loopTick + 1
                local myLevel = GetMyLevel()

                -- 1. ESCANEO DE ZOMBIES (CONSTANTE, PORQUE SE MUEVEN)
                if KiteActivo or MineActivo then
                    if loopTick % 10 == 0 or not zTarget or not zTarget.Parent or not zTarget:FindFirstChildWhichIsA("Humanoid") then
                        zTarget, zDist = findNearest(function(o)
                            if o:IsA("Model") and o ~= char then
                                local h = o:FindFirstChildWhichIsA("Humanoid")
                                if h and h.Health > 0 and o:GetAttribute("IsNpc") == true then
                                    local baseName = GetBaseName(o.Name)
                                    if next(SelectedMobs) ~= nil and SelectedMobs[baseName] == false then return false end
                                    if KiteActivo and not MineActivo then
                                        local mobLvl = GetMobLevel(o)
                                        if mobLvl > 0 and mobLvl > myLevel then return false end
                                    end
                                    local root = o:FindFirstChild("HumanoidRootPart")
                                    if root and root.Position.Y < (SafeFloorY - 15) then return false end
                                    return true
                                end
                            end
                            return false
                        end)
                    else
                        -- Actualiza distancia del zombi actual
                        local zp = zTarget:FindFirstChild("HumanoidRootPart") or zTarget:FindFirstChild("Torso")
                        if zp then
                            zDist = (myRoot.Position - zp.Position).Magnitude
                        else
                            zTarget = nil
                        end
                    end
                end

                -- 2. ESCANEO ESP DE MINAS (INTELIGENTE Y CON BLOQUEO HASTA EXTRACCIÓN)
                if MineActivo then
                    -- Limpieza de blacklist cada 30 ticks (aprox 1s)
                    if loopTick % 30 == 0 then
                        local now = tick()
                        for bOre, bTime in pairs(OreBlacklist) do
                            if now - bTime > BLACKLIST_EXPIRE then OreBlacklist[bOre] = nil end
                        end
                    end

                    -- Chequea si la mina actualigue viva, no expiro, y completamos el target
                    local oreIsAlive = false
                    if oreTarget and oreTarget.Parent and not OreBlacklist[oreTarget] then
                        local oHP = oreTarget:GetAttribute("Health")
                        if oHP and oHP > 0 then
                            local op = oreTarget:FindFirstChild("HumanoidRootPart") or oreTarget:FindFirstChild("Torso") or oreTarget:FindFirstChildWhichIsA("BasePart")
                            if op then
                                oDist = (myRoot.Position - op.Position).Magnitude
                                oreIsAlive = true
                            end
                        end
                    end
                    
                    if not oreIsAlive then
                        oreTarget = nil
                        oDist = math.huge
                    end

                    -- BÚSQUEDA ESP INTELIGENTE (Solo cuando no tenemos mina asignada)
                    if not oreTarget then
                        local bestScore = math.huge
                        local bestObj = nil
                        
                        -- PRE-CACHÉ DE ZOMBIES (Para evitar LAG EXTREMO anidado)
                        local liveZombiesPos = {}
                        for _, mob in pairs(Workspace:GetDescendants()) do
                            if mob:IsA("Model") and mob:GetAttribute("IsNpc") == true then
                                local mh = mob:FindFirstChildWhichIsA("Humanoid")
                                if mh and mh.Health > 0 then
                                    local mRoot = mob:FindFirstChild("HumanoidRootPart")
                                    if mRoot then
                                        table.insert(liveZombiesPos, mRoot.Position)
                                    end
                                end
                            end
                        end
                        
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if obj:IsA("Model") and obj ~= char and not OreBlacklist[obj] then
                                local h = obj:GetAttribute("Health")
                                if h and h > 0 then
                                    local baseName = GetBaseName(obj.Name)
                                    local selected = true
                                    
                                    -- Aplicar filtro del gui scanner si se configuro
                                    if next(SelectedOres) ~= nil and SelectedOres[baseName] == false then
                                        selected = false
                                    end
                                    
                                    if selected then
                                        local op = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChildWhichIsA("BasePart")
                                        if op then
                                            -- ANTI-UNDERGROUND (Dinámico)
                                            if op.Position.Y >= (SafeFloorY - 15) then
                                                local distToOre = (myRoot.Position - op.Position).Magnitude
                                                
                                                -- INTELIGENCIA: Contar zombies usando caché (0 LAG)
                                                local mobsCerca = 0
                                                for _, zp in pairs(liveZombiesPos) do
                                                    if (zp - op.Position).Magnitude < 35 then
                                                        mobsCerca = mobsCerca + 1
                                                    end
                                                end
                                                
                                                -- SCORE ESP: Distancia base + (200 de penalidad por cada Mob cerca)
                                                local penalidadMobs = mobsCerca * 200
                                                local totalScore = distToOre + penalidadMobs
                                                
                                                if totalScore < bestScore then
                                                    bestScore = totalScore
                                                    bestObj = obj
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        
                        if bestObj then
                            oreTarget = bestObj
                            local op = bestObj:FindFirstChild("HumanoidRootPart") or bestObj:FindFirstChild("Torso") or bestObj:FindFirstChildWhichIsA("BasePart")
                            oDist = (myRoot.Position - op.Position).Magnitude
                        end
                    end
                end

                local targetObj = nil
                local dist = 0
                local targetDist = 7
                local mode = "Combat"
                local toolId = "weapon"

                -- PRIORIDAD 1: COMBATE (Caza pura, o Auto-Defensa SOLO si el mob está MUY cerca mientras mineas)
                if zTarget and (KiteActivo or (MineActivo and zDist < 15)) then
                    targetObj = zTarget
                    dist = zDist
                    targetDist = ShieldActivo and 4 or 7
                    mode = "Combat"
                    toolId = "weapon"
                -- PRIORIDAD 2: MINADO
                elseif oreTarget and MineActivo then
                    targetObj = oreTarget
                    dist = oDist
                    targetDist = 4
                    mode = "Mining"
                    toolId = "pickaxe"

                    -- ANTI-STUCK: Detectar si el mineral no baja de vida
                    local oreHP = oreTarget:GetAttribute("Health") or 0
                    if MiningTracker.ore ~= oreTarget then
                        -- Nuevo objetivo, resetear tracker
                        MiningTracker.ore = oreTarget
                        MiningTracker.startHP = oreHP
                        MiningTracker.startTime = tick()
                    else
                        if dist > targetDist + 1.5 then
                            -- Aún viajando a la mina (en el aire). Pausar el reloj Anti-Stuck para que no caduque en el camino.
                            MiningTracker.startTime = tick()
                            MiningTracker.startHP = oreHP
                        else
                            -- Mismo objetivo y estamos pegando, checar si bajó de vida
                            if tick() - MiningTracker.startTime > MINE_TIMEOUT then
                                if oreHP >= MiningTracker.startHP then
                                    -- NO BAJÓ. Blacklistear y forzar rescan
                                    OreBlacklist[oreTarget] = tick()
                                    StatusLabel.Text = "⚠️ " .. oreTarget.Name .. " NO se puede picar. Saltando..."
                                    oreTarget = nil
                                    MiningTracker.ore = nil
                                    targetObj = nil
                                else
                                    -- Sí bajó, resetear timer con el nuevo HP
                                    MiningTracker.startHP = oreHP
                                    MiningTracker.startTime = tick()
                                end
                            end
                        end
                    end
                end

                if targetObj then
                    local targetPart = targetObj:FindFirstChild("HumanoidRootPart") or targetObj:FindFirstChild("Torso") or targetObj:FindFirstChildWhichIsA("BasePart")
                    if not targetPart then return end
                    
                    dist = (myRoot.Position - targetPart.Position).Magnitude
                    -- dist ya fue calculado arriba
                    -- targetDist ya fue calculado arriba

                    -- == 1. EQUIPO DE ARMA ==
                    local isEquipped = false
                    for _, t in pairs(char:GetChildren()) do
                        if t:IsA("Tool") and string.find(string.lower(t.Name), toolId) then
                            isEquipped = true; break
                        end
                    end

                    if not isEquipped then
                        local bpTools = LocalPlayer.Backpack:GetChildren()
                        local equippedCorrectly = false
                        for _, t in pairs(bpTools) do
                            if string.find(string.lower(t.Name), toolId) then
                                currentHum:EquipTool(t); equippedCorrectly = true; break
                            end
                        end
                        if not equippedCorrectly and #bpTools > 0 then
                            if toolId == "pickaxe" then
                                currentHum:EquipTool(bpTools[1])
                            elseif #bpTools >= 2 then
                                currentHum:EquipTool(bpTools[2])
                            else
                                currentHum:EquipTool(bpTools[1])
                            end
                        end
                    end

                    -- == 2. MOVIMIENTO ==
                    if dist > targetDist then
                        if NoclipActivo then
                            myRoot.Anchored = false
                            local bv = myRoot:FindFirstChild("_NoclipBV")
                            if not bv then
                                bv = Instance.new("BodyVelocity")
                                bv.Name = "_NoclipBV"
                                bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                                bv.Parent = myRoot
                            end
                            
                            local speed = (currentHum.WalkSpeed or 16) * 2.5
                            local targetPos = targetPart.Position
                            local curPos = myRoot.Position
                            
                            -- SKY PATHING (Evitar chocar montañas y activar Anti-Wallhack)
                            local hDist = (Vector2.new(curPos.X, curPos.Z) - Vector2.new(targetPos.X, targetPos.Z)).Magnitude
                            local safeY = targetPos.Y + 60 -- 60 studs por encima del objetivo para volar a salvo
                            
                            local flightWaypoint
                            if hDist > 20 then
                                if curPos.Y < safeY then
                                    -- Fase 1: Subir (Ascensor) para evitar chocar de frente con el terreno
                                    flightWaypoint = Vector3.new(curPos.X, safeY + 15, curPos.Z)
                                else
                                    -- Fase 2: Volar directo en el aire (seguro, sin suelo)
                                    flightWaypoint = Vector3.new(targetPos.X, curPos.Y, targetPos.Z)
                                end
                            else
                                -- Fase 3: Ya estamos encima del objetivo, bajamos en picada PERO frenamos 3.5 studs antes
                                -- Esto evita que tus pies atraviesen el suelo real y el juego te mande al spawn.
                                flightWaypoint = Vector3.new(targetPos.X, targetPos.Y + 3.5, targetPos.Z)
                            end
                            
                            local dir = (flightWaypoint - curPos).Unit
                            bv.Velocity = dir * speed
                        else
                            local bv = myRoot:FindFirstChild("_NoclipBV")
                            if bv then bv:Destroy() end
                            myRoot.Anchored = false
                            currentHum:MoveTo(targetPart.Position)
                        end
                    else
                        local bv = myRoot:FindFirstChild("_NoclipBV")
                        if bv then bv.Velocity = Vector3.zero end
                        myRoot.Anchored = false
                        currentHum:MoveTo(myRoot.Position)
                    end

                    -- == 3. GOLPE ==
                    if dist <= targetDist + 1.5 then
                        -- SNAP de puntería SOLO al golpear (un frame, no dispara anti-cheat)
                        local lookTarget = Vector3.new(targetPart.Position.X, myRoot.Position.Y, targetPart.Position.Z)
                        myRoot.CFrame = CFrame.lookAt(myRoot.Position, lookTarget)
                        
                        local serverArg = mode == "Mining" and "Pickaxe" or "Weapon"
                        ToolRF:InvokeServer(serverArg)
                        
                        -- ANTI-ATASCO GLOBAL: Registrar que estamos golpeando
                        if mode == "Mining" then
                            GlobalMineIdleTracker.lastHitTime = tick()
                        end
                        
                        if mode == "Combat" then
                            local mobLvl = GetMobLevel(targetObj)
                            StatusLabel.Text = "🗡️ Atacando: " .. targetObj.Name .. " (Lvl " .. tostring(mobLvl) .. ") | Tu Lvl: " .. tostring(myLevel)
                            
                            -- KITING: Después de golpear, retroceder un paso para esquivar
                            local retreatDir = (myRoot.Position - targetPart.Position)
                            local flatRetreat = Vector3.new(retreatDir.X, 0, retreatDir.Z)
                            if flatRetreat.Magnitude > 0.1 then
                                currentHum:Move(flatRetreat.Unit, false)
                                task.wait(0.15)
                                currentHum:Move(Vector3.zero, false)
                            end
                        else
                            StatusLabel.Text = "⛏️ Picando: " .. targetObj.Name .. " (" .. tostring(math.floor(dist)) .. "m)"
                        end
                    else
                        StatusLabel.Text = (mode == "Mining" and "🏃 Acercándose a Mina: " or "🏃 Cazando a: ") .. targetObj.Name .. " (" .. tostring(math.floor(dist)) .. "m)"
                    end
                else
                    StatusLabel.Text = "🗡️/⛏️ Buscando objetivo (Tu Lvl: " .. tostring(myLevel) .. ")..."
                end
            end)
            task.wait()
        end
        DetenerFarm()
    end)
end

-- ==========================================
-- CONEXIÓN DEL BOTÓN DE FARM
-- ==========================================
KiteBtn.MouseButton1Click:Connect(function()
    KiteActivo = not KiteActivo
    if KiteActivo then
        KiteBtn.Text = "🗡️ MOBS: ON (Lvl " .. tostring(GetMyLevel()) .. ")"
        KiteBtn.BackgroundColor3 = Color3.fromRGB(220, 130, 40)
        IniciarFarm()
    else
        KiteBtn.Text = "🗡️ FARM MOBS"
        KiteBtn.BackgroundColor3 = Color3.fromRGB(180, 80, 40)
        DetenerFarm()
    end
end)

MineBtn.MouseButton1Click:Connect(function()
    MineActivo = not MineActivo
    if MineActivo then
        MineBtn.Text = "⛏️ MINAS: ON"
        MineBtn.BackgroundColor3 = Color3.fromRGB(120, 220, 40)
        GlobalMineIdleTracker.lastHitTime = tick()
        IniciarFarm()
    else
        MineBtn.Text = "⛏️ FARM MINAS"
        MineBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 40)
        DetenerFarm()
    end
end)

-- ==========================================
-- ANTI-ATASCO GLOBAL: Si Farm Minas está ON y lleva 5s sin picar, se auto-reinicia
-- ==========================================
task.spawn(function()
    while true do
        task.wait(1)
        if MineActivo and (tick() - GlobalMineIdleTracker.lastHitTime) > 5 then
            GlobalMineIdleTracker.lastHitTime = tick()
            -- Auto-reinicio: apagar y prender farm minas
            MineActivo = false
            DetenerFarm()
            task.wait(0.3)
            MineActivo = true
            MineBtn.Text = "⛏️ MINAS: ON"
            MineBtn.BackgroundColor3 = Color3.fromRGB(120, 220, 40)
            StatusLabel.Text = "🔄 Anti-Atasco: Reiniciando Farm Minas..."
            IniciarFarm()
        end
    end
end)

-- ==============================================================================
-- 💰 MÓDULO AUTO-VENDER (COMPLETO Y REPARADO)
-- ==============================================================================

-- Remotos de la tienda
local RF_RunCommand_Sell, RF_ForceDialogue_Sell, RE_DialogueEvent_Sell, SeyNPC_Sell = nil, nil, nil, nil

for _, obj in pairs(Workspace:GetDescendants()) do
    if obj:IsA("Model") and string.find(string.lower(obj.Name), "cey") then
        SeyNPC_Sell = obj; break
    end
end
for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteFunction") then
        if obj.Name == "RunCommand" then RF_RunCommand_Sell = obj end
        if obj.Name == "ForceDialogue" then RF_ForceDialogue_Sell = obj end
    elseif obj:IsA("RemoteEvent") then
        if obj.Name == "DialogueEvent" then RE_DialogueEvent_Sell = obj end
    end
end

-- Items a vender automáticamente (Nombres Forenses Correctos)
local ITEMS_AUTO_VENDER = {
    ["Tiny Essence"] = true,
    ["Medium Essence"] = true,
    ["Cobalt"] = true,
    ["Boneite"] = true,
    ["Titanium"] = true,
    ["Amethyst"] = true,
    ["Lapis Lazuli"] = true,
    ["Silver"] = true,
    ["Gold"] = true,
}

local ITEMS_SCAN_NAMES = {
    {es="esencia pequeña", exact="Esencia pequeña", en="Tiny Essence"},
    {es="esencia mediana", exact="Esencia mediana", en="Medium Essence"},
    {es="cobalto",         exact="Cobalto",         en="Cobalt"},
    {es="boneita",         exact="Boneita",         en="Boneite"},
    {es="titánico",        exact="Titánico",        en="Titanium"},
    {es="ametista",        exact="Ametista",        en="Amethyst"},
    {es="lapis lazuli",    exact="Lapis Lazuli",    en="Lapis Lazuli"},
    {es="plata",           exact="Plata",           en="Silver"},
    {es="oro",             exact="Oro",             en="Gold"},
}

local AutoVenderActivo = false

-- UI: Botón AUTOVENDER en el panel principal
local AutoVenderBtn = Instance.new("TextButton")
AutoVenderBtn.Size = UDim2.new(0.5, -6, 0, 28)
AutoVenderBtn.Position = UDim2.new(0, 4, 0, 415)
AutoVenderBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
AutoVenderBtn.Text = "💰 AUTOVENDER: OFF"
AutoVenderBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoVenderBtn.Font = Enum.Font.Code
AutoVenderBtn.TextSize = 10
AutoVenderBtn.Parent = Panel

-- UI: Label de capacidad del inventario
local InvLabel = Instance.new("TextLabel")
InvLabel.Size = UDim2.new(0.5, -6, 0, 28)
InvLabel.Position = UDim2.new(0.5, 2, 0, 415)
InvLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
InvLabel.Text = "📦 Items: ?/?"
InvLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
InvLabel.Font = Enum.Font.Code
InvLabel.TextSize = 10
InvLabel.Parent = Panel

AutoVenderBtn.MouseButton1Click:Connect(function()
    AutoVenderActivo = not AutoVenderActivo
    if AutoVenderActivo then
        AutoVenderBtn.Text = "💰 AUTOVENDER: ON ✅"
        AutoVenderBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    else
        AutoVenderBtn.Text = "💰 AUTOVENDER: OFF"
        AutoVenderBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
    end
end)

-- Función: Leer capacidad del inventario
local InvController_Sell = nil
pcall(function() InvController_Sell = require(ReplicatedStorage.Controllers.UIController.Inventory) end)

local function LeerCapacidadInventario()
    local cur, maxm = nil, nil
    if InvController_Sell then
        pcall(function() maxm = InvController_Sell:GetBagCapacity() end)
    end
    if not maxm then maxm = 144 end
    pcall(function()
        for _, obj in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Visible then
                local x, y = string.match(obj.Text, "(%d+)/(%d+)")
                if x and y then
                    local valY = tonumber(y)
                    if valY == maxm then
                        cur = tonumber(x)
                        return
                    end
                end
            end
        end
    end)
    return cur, maxm
end

-- Función: Escanear cuántos de cada mineral tienes (Regex Seguro sin falsos positivos de UI)
local function EscanearMinerales()
    local dir = {}
    pcall(function()
        for _, obj in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if obj:IsA("TextLabel") then
                local txt = string.lower(obj.Text)
                for _, item in ipairs(ITEMS_SCAN_NAMES) do
                    if txt == item.es or obj.Text == item.exact or txt == string.lower(item.en) then
                        local padre = obj.Parent
                        if padre then
                            for _, child in pairs(padre:GetDescendants()) do
                                if child:IsA("TextLabel") then
                                    local mx = string.match(child.Text, "[xX](%d+)")
                                    if mx then
                                        local n = tonumber(mx)
                                        if n > (dir[item.en] or 0) then dir[item.en] = n end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    return dir
end

-- Escudo __newindex para evitar paralisis de NPCs
if not getgenv().InmunidadV11Activa then
    getgenv().InmunidadV11Activa = true
    local OriginalNewIndex
    OriginalNewIndex = hookmetamethod(game, "__newindex", function(t, k, v)
        if not checkcaller() then
            if t:IsA("BasePart") and t.Name == "HumanoidRootPart" and k == "Anchored" and v == true then return end
            if t:IsA("Camera") and k == "CameraType" and v ~= Enum.CameraType.Custom then return end
            if t:IsA("Humanoid") and (k == "WalkSpeed" and v < 16) then return end
        end
        return OriginalNewIndex(t, k, v)
    end)
end

-- Función: Vuelo Anti-Kicks (Viaja físicamente hacia una posición con Timeout)
local function FlyToPos(targetPos)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local currentHum = char and char:FindFirstChild("Humanoid")
    if not root or not currentHum then return end
    
    root.Anchored = false
    local bv = root:FindFirstChild("_NoclipBV")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "_NoclipBV"
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bv.Parent = root
    end
    
    local speed = (currentHum.WalkSpeed or 16) * 3
    local timeout = tick() + 15
    
    while char and root and currentHum and currentHum.Health > 0 and tick() < timeout do
        local curPos = root.Position
        local hDist = (Vector2.new(curPos.X, curPos.Z) - Vector2.new(targetPos.X, targetPos.Z)).Magnitude
        local vDist = math.abs(curPos.Y - targetPos.Y)
        
        if hDist < 5 and vDist < 8 then
            break
        end
        
        local safeY = targetPos.Y + 45
        local flightWaypoint
        if hDist > 20 then
            if curPos.Y < safeY then
                flightWaypoint = Vector3.new(curPos.X, safeY + 15, curPos.Z)
            else
                flightWaypoint = Vector3.new(targetPos.X, curPos.Y, targetPos.Z)
            end
        else
            flightWaypoint = Vector3.new(targetPos.X, targetPos.Y, targetPos.Z)
        end
        
        local dir = (flightWaypoint - curPos).Unit
        bv.Velocity = dir * speed
        task.wait(0.05)
    end
    if bv then bv.Velocity = Vector3.zero end
end

-- Función: Ejecutar venta segura (evita colisiones al aterrizar)
local function VenderAutomaticamente(miBasket)
    if not RF_RunCommand_Sell or not RF_ForceDialogue_Sell or not RE_DialogueEvent_Sell then return end
    
    local npcActual = nil
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and string.find(string.lower(obj.Name), "cey") then
            npcActual = obj; break
        end
    end
    if not npcActual then return end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local paqueteFinal = { Basket = miBasket }
    local oldPos = root.Position
    local npcRoot = npcActual:FindFirstChild("HumanoidRootPart") or npcActual:FindFirstChild("Torso") or npcActual:FindFirstChildWhichIsA("BasePart")
    
    -- Pausar farmeo
    local oldKite = KiteActivo
    local oldMine = MineActivo
    if KiteActivo then KiteBtn.Text = "🗡️ FARM MOBS"; KiteActivo = false; KiteBtn.BackgroundColor3 = Color3.fromRGB(180, 80, 40) end
    if MineActivo then MineBtn.Text = "⛏️ FARM MINAS"; MineActivo = false; MineBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 40) end
    DetenerFarm()
    task.wait(0.2)
    
    local oldNoclip = NoclipActivo
    NoclipActivo = true
    
    if npcRoot then
        local dest = npcRoot.Position
        StatusLabel.Text = "✈️ Volando hacia el NPC Cey (Timeout 15s)..."
        FlyToPos(dest)
        
        NoclipActivo = false
        pcall(function()
            local xbv = root:FindFirstChild("_NoclipBV")
            if xbv then xbv:Destroy() end
        end)
        
        if (root.Position - dest).Magnitude > 8 then
            root.CFrame = CFrame.new(dest) * CFrame.new(0,0,-3)
        end
        task.wait(0.5)
    end
    
    StatusLabel.Text = "💰 Negociando con el NPC..."
    -- SECUENCIA DE COMPRA EXACTA V8
    pcall(function() RF_ForceDialogue_Sell:InvokeServer(npcActual, "SellConfirmMisc") end)
    task.wait(0.2)
    pcall(function() RE_DialogueEvent_Sell:FireServer("Opened") end)
    
    pcall(function() RF_RunCommand_Sell:InvokeServer("SellConfirm", paqueteFinal) end)
    task.wait(0.5)
    
    pcall(function()
        for _, obj in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if obj:IsA("TextButton") and obj.Visible then
                local t = string.lower(obj.Text)
                if string.find(t, "adi") or string.find(t, "bye") or string.find(t, "2.") or string.find(t, "2%]") then
                    pcall(function() firesignal(obj.MouseButton1Click) end)
                    pcall(function() for _, c in pairs(getconnections(obj.MouseButton1Click)) do c:Fire() end end)
                end
            end
        end
    end)
    pcall(function() RE_DialogueEvent_Sell:FireServer("Closed") end)
    
    -- REGRESO
    StatusLabel.Text = "✈️ Venta lista. Regresando a zona de farmeo..."
    NoclipActivo = true
    FlyToPos(oldPos)
    
    if (root.Position - oldPos).Magnitude > 8 then
        root.CFrame = CFrame.new(oldPos)
    end
    task.wait(0.2)
    
    NoclipActivo = oldNoclip
    pcall(function()
        local bv = root:FindFirstChild("_NoclipBV")
        if not oldNoclip and bv then bv:Destroy() end
    end)
    
    -- Reanudar
    if oldKite then
        KiteBtn.Text = "🗡️ MOBS: ON"
        KiteBtn.BackgroundColor3 = Color3.fromRGB(220, 130, 40)
        KiteActivo = true
        IniciarFarm()
    end
    if oldMine then
        MineBtn.Text = "⛏️ MINAS: ON"
        MineBtn.BackgroundColor3 = Color3.fromRGB(120, 220, 40)
        MineActivo = true
        IniciarFarm()
    end
end

-- Bucle: Vender Automáticamente
task.spawn(function()
    while true do
        task.wait(5)
        pcall(function()
            local cur, maxm = LeerCapacidadInventario()
            if cur and maxm then
                InvLabel.Text = "📦 Items: " .. cur .. "/" .. maxm
            end
        end)
        
        if AutoVenderActivo then
            pcall(function()
                local cur, maxm = LeerCapacidadInventario()
                if cur and maxm and cur >= (maxm - 5) then
                    local stock = EscanearMinerales()
                    local autoBasket = {}
                    local count = 0
                    for itemEN, _ in pairs(ITEMS_AUTO_VENDER) do
                        local cant = stock[itemEN] or 0
                        if cant > 0 then
                            autoBasket[itemEN] = cant
                            count = count + 1
                        end
                    end
                    if count > 0 then
                        StatusLabel.Text = "💰 INV LLENO → Vendiendo " .. count .. " minerales..."
                        VenderAutomaticamente(autoBasket)
                        StatusLabel.Text = "💰 Venta automática completada."
                    end
                end
            end)
        end
    end
end)
