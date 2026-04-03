-- ==============================================================================
-- 🦖 CATCH A MONSTER: V6.0 — ESCÁNER DE MEMORIA + ONE-SHOT BOOSTER
-- Si IsServerLogic=false, el CLIENTE calcula el daño.
-- Boosteamos Atk en memoria → mascotas one-shot → mobs mueren antes de atacar.
-- ==============================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

local UI_Name = "CAM_MemHack"
if CoreGui:FindFirstChild(UI_Name) then CoreGui[UI_Name]:Destroy() end

local SG = Instance.new("ScreenGui")
SG.Name = UI_Name
SG.ResetOnSpawn = false
SG.Parent = pcall(function() return CoreGui.Name end) and CoreGui or LP:WaitForChild("PlayerGui")

local MF = Instance.new("Frame", SG)
MF.Size = UDim2.new(0, 460, 0, 340)
MF.Position = UDim2.new(0.5, 0, 0.3, 0)
MF.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MF.BorderSizePixel = 2
MF.BorderColor3 = Color3.fromRGB(200, 0, 255)
MF.Active = true
MF.Draggable = true

local Title = Instance.new("TextLabel", MF)
Title.Size = UDim2.new(1, 0, 0, 26)
Title.BackgroundColor3 = Color3.fromRGB(60, 0, 80)
Title.Text = " 🧠 MEMORY SCANNER + ONE-SHOT BOOSTER"
Title.TextColor3 = Color3.fromRGB(220, 180, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left

local LogFrame = Instance.new("ScrollingFrame", MF)
LogFrame.Size = UDim2.new(1, -12, 0, 170)
LogFrame.Position = UDim2.new(0, 6, 0, 30)
LogFrame.BackgroundColor3 = Color3.fromRGB(3, 3, 3)
LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LogFrame.ScrollBarThickness = 4
LogFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", LogFrame).SortOrder = Enum.SortOrder.LayoutOrder

local lc = 0
local function Log(t, c)
    lc = lc + 1
    local m = Instance.new("TextLabel", LogFrame)
    m.Size = UDim2.new(1, 0, 0, 15)
    m.BackgroundTransparency = 1
    m.Text = "["..os.date("%X").."] "..t
    m.TextXAlignment = Enum.TextXAlignment.Left
    m.TextColor3 = c or Color3.fromRGB(170, 170, 170)
    m.Font = Enum.Font.Code; m.TextSize = 10
    m.TextWrapped = true; m.AutomaticSize = Enum.AutomaticSize.Y
    m.LayoutOrder = lc
    LogFrame.CanvasPosition = Vector2.new(0, 99999)
end

-- Botones
local function MkBtn(txt, py)
    local b = Instance.new("TextButton", MF)
    b.Size = UDim2.new(0.92, 0, 0, 30)
    b.Position = UDim2.new(0.04, 0, 0, py)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamSemibold; b.TextSize = 12
    b.Text = txt
    return b
end

local btnScan    = MkBtn("🔍 ESCANEAR MEMORIA (getgc)", 206)
local btnBoost   = MkBtn("⚡ BOOST x100 ATK (One-Shot Mobs)", 240)
local btnFarm    = MkBtn("⚔️ AUTO-FARM (Click + Auto-Catch)", 274)
local btnHP      = MkBtn("❤️ BOOST HP x100 (Tanque Infinito)", 308)

-- ==========================================================
-- 1. ESCÁNER PROFUNDO DE getgc()
-- ==========================================================
-- Busca TODAS las tablas con claves de stats de combate
local statKeys = {
    "Atk", "atk", "ATK", "Attack", "attack",
    "Damage", "damage", "Dmg", "dmg",
    "MaxHp", "maxHp", "MaxHP", "MAXHP", "Hp", "hp", "HP",
    "Def", "def", "DEF", "Defense", "defense",
    "CritRate", "CritDmg", "Speed", "AtkSpeed",
    "AttackRange", "CatchRange",
    "BaseAtk", "BaseDmg", "BaseHp",
    "AtkRatio", "DmgRatio", "HpRatio",
    "AtkAdd", "HpAdd", "DefAdd",
    "AtkMul", "HpMul", "DefMul",
    "SkillDmg", "SkillAtk",
    "DmgAttrRatio", "HurtAttrRatio",
}
local statSet = {}
for _, k in pairs(statKeys) do statSet[k] = true end

local foundTables = {} -- {table, keys_found}

btnScan.MouseButton1Click:Connect(function()
    Log("Escaneando getgc()...", Color3.fromRGB(0, 200, 255))
    foundTables = {}
    local count = 0
    
    pcall(function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and not foundTables[v] then
                local hits = {}
                for key, val in pairs(v) do
                    if type(key) == "string" and statSet[key] then
                        table.insert(hits, key .. "=" .. tostring(val))
                    end
                end
                if #hits > 0 then
                    foundTables[v] = hits
                    count = count + 1
                    local preview = table.concat(hits, " | ")
                    if #preview > 120 then preview = preview:sub(1, 120) .. "..." end
                    Log("📦 Tabla #"..count..": "..preview, Color3.fromRGB(255, 200, 0))
                end
            end
        end
    end)
    
    Log("✅ Escaneo completo: "..count.." tablas con stats encontradas", Color3.fromRGB(0, 255, 0))
end)

-- ==========================================================
-- 2. BOOSTER DE ATAQUE (x100)
-- ==========================================================
btnBoost.MouseButton1Click:Connect(function()
    Log("⚡ Inyectando ATK x100...", Color3.fromRGB(255, 100, 0))
    local boosted = 0
    
    pcall(function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" then
                -- Boost cualquier campo de ataque/daño
                for _, key in pairs({"Atk", "atk", "ATK", "Attack", "attack", "BaseAtk",
                                      "Damage", "damage", "Dmg", "dmg", "BaseDmg",
                                      "AtkAdd", "AtkMul", "DmgAttrRatio", "SkillDmg", "SkillAtk"}) do
                    local val = rawget(v, key)
                    if type(val) == "number" and val > 0 and val < 999999999 then
                        rawset(v, key, val * 100)
                        boosted = boosted + 1
                        Log("  ⬆️ "..key..": "..tostring(val).." → "..tostring(val*100), Color3.fromRGB(255, 150, 50))
                    end
                end
            end
        end
    end)
    
    Log("✅ Boosted "..boosted.." campos de daño", Color3.fromRGB(0, 255, 0))
    btnBoost.BackgroundColor3 = Color3.fromRGB(200, 80, 0)
    btnBoost.Text = "⚡ BOOSTED ("..boosted.." campos)"
end)

-- ==========================================================
-- 3. BOOSTER DE HP (x100)
-- ==========================================================
btnHP.MouseButton1Click:Connect(function()
    Log("❤️ Inyectando HP x100...", Color3.fromRGB(255, 50, 50))
    local boosted = 0
    
    pcall(function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" then
                for _, key in pairs({"MaxHp", "maxHp", "MaxHP", "MAXHP", "Hp", "hp", "HP",
                                      "BaseHp", "HpAdd", "HpMul", "Def", "def", "DEF",
                                      "Defense", "defense", "DefAdd", "DefMul"}) do
                    local val = rawget(v, key)
                    if type(val) == "number" and val > 0 and val < 999999999 then
                        rawset(v, key, val * 100)
                        boosted = boosted + 1
                        Log("  ⬆️ "..key..": "..tostring(val).." → "..tostring(val*100), Color3.fromRGB(255, 100, 100))
                    end
                end
            end
        end
    end)
    
    Log("✅ Boosted "..boosted.." campos de vida/def", Color3.fromRGB(0, 255, 0))
    btnHP.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    btnHP.Text = "❤️ BOOSTED ("..boosted.." campos)"
end)

-- ==========================================================
-- 4. AUTO-FARM (ClickDetector + Auto-Catch)
-- ==========================================================
local farmActive = false

btnFarm.MouseButton1Click:Connect(function()
    farmActive = not farmActive
    btnFarm.BackgroundColor3 = farmActive and Color3.fromRGB(40, 130, 40) or Color3.fromRGB(35, 35, 40)
    btnFarm.Text = farmActive and "⚔️ FARMING ACTIVO..." or "⚔️ AUTO-FARM (Click + Auto-Catch)"
    Log(farmActive and "Auto-Farm ON" or "Auto-Farm OFF", Color3.fromRGB(100, 255, 100))
end)

-- Auto-click en mobs cercanos
task.spawn(function()
    while true do
        if farmActive then
            pcall(function()
                if not LP.Character or not LP.Character.PrimaryPart then return end
                local myPos = LP.Character.PrimaryPart.Position
                local best, bestDist = nil, 60
                
                local cm = Workspace:FindFirstChild("ClientMonsters")
                if cm then
                    for _, mob in pairs(cm:GetChildren()) do
                        if mob:IsA("Model") then
                            local cd = mob:FindFirstChildWhichIsA("ClickDetector", true)
                            if cd then
                                local p = mob.PrimaryPart or mob:FindFirstChildWhichIsA("BasePart")
                                if p then
                                    local d = (p.Position - myPos).Magnitude
                                    if d < bestDist then bestDist = d; best = cd end
                                end
                            end
                        end
                    end
                end
                
                if best then
                    fireclickdetector(best)
                    Log("🖱️ Click mob ["..math.floor(bestDist).."m]", Color3.fromRGB(100, 200, 255))
                end
            end)
        end
        task.wait(2.5)
    end
end)

-- Auto-catch: monitorear PushRewardEvent y presionar E
task.spawn(function()
    pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        for _, desc in pairs(rs:GetDescendants()) do
            if desc:IsA("RemoteEvent") then
                desc.OnClientEvent:Connect(function(...)
                    local args = {...}
                    local name = tostring(args[1] or "")
                    
                    if farmActive and name == "PushRewardEvent" then
                        Log("💀 MOB MUERTO → Auto-Catch E", Color3.fromRGB(255, 255, 0))
                        task.delay(0.3, function()
                            pcall(function()
                                local vim = game:GetService("VirtualInputManager")
                                vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                task.wait(0.15)
                                vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            end)
                        end)
                    end
                end)
            end
        end
    end)
end)

-- ==========================================================
-- 5. LOOP: Mantener rangos altos + re-boost periódico
-- ==========================================================
task.spawn(function()
    while true do
        pcall(function()
            for _, v in pairs(getgc(true)) do
                if type(v) == "table" then
                    if rawget(v, "AttackRange") and v.AttackRange < 150 then v.AttackRange = 300 end
                    if rawget(v, "CatchRange") and v.CatchRange < 150 then v.CatchRange = 300 end
                end
            end
        end)
        task.wait(10)
    end
end)

Log("Listo. Pasos:", Color3.fromRGB(255, 255, 255))
Log("1) Pulsa ESCANEAR para ver qué stats hay en memoria", Color3.fromRGB(200, 200, 200))
Log("2) Pulsa BOOST ATK para multiplicar el daño x100", Color3.fromRGB(200, 200, 200))
Log("3) Pulsa BOOST HP para tanquear x100", Color3.fromRGB(200, 200, 200))
Log("4) Activa AUTO-FARM y acércate a un mob", Color3.fromRGB(200, 200, 200))
