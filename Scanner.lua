-- ==============================================================================
-- 🗡️ OMNI-FARM V2.0 (PURGADO: SOLO COMBATE INTELIGENTE + MURO CRISTAL)
-- Sin Aimbot, Sin Minería de Rocks, Con Filtro de Nivel Anti-Suicidio.
-- ==============================================================================

local SCRIPT_URL = "https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
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
local FarmTask = nil
local MyShield = nil

-- ==========================================
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
Panel.Size = UDim2.new(0, 280, 0, 310)
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
Title.Text = " 🗡️ OMNI-FARM V2 (INTELIGENTE)"
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
-- BOTONES (SIN AIMBOT, SIN FARM MINAS)
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
KiteBtn.Size = UDim2.new(1, -8, 0, 45)
KiteBtn.Position = UDim2.new(0, 4, 0, 110)
KiteBtn.BackgroundColor3 = Color3.fromRGB(180, 80, 40)
KiteBtn.Text = "🗡️ FARM MOBS (SOLO TU NIVEL O MENOR)"
KiteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
KiteBtn.Font = Enum.Font.Code
KiteBtn.TextSize = 12
KiteBtn.Parent = Panel

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -8, 0, 140)
StatusLabel.Position = UDim2.new(0, 4, 0, 162)
StatusLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
StatusLabel.Text = "Estado: Inactivo.\n\n🛡️ MURO CRISTAL: Cuadro de cristal que atasca zombis.\n👻 NOCLIP: Atraviesas paredes.\n🗡️ FARM MOBS: Camina y mata solo zombis de TU nivel o menor. Ignora zombis más fuertes que tú.\n\n⚠️ Sin minería de Rocks (aún no puedes).\n⚠️ Sin Aimbot (no funciona en este juego)."
StatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 11
StatusLabel.TextWrapped = true
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
StatusLabel.Parent = Panel

-- ==========================================
-- EVENTOS DE INTERFAZ
-- ==========================================
local Minimizado = false
MinBtn.MouseButton1Click:Connect(function()
    Minimizado = not Minimizado
    if Minimizado then
        Panel.Size = UDim2.new(0, 200, 0, 30)
        OpenIcon.Visible = false
    else
        Panel.Size = UDim2.new(0, 280, 0, 310)
    end
end)

OpenIcon.MouseButton1Click:Connect(function()
    Panel.Visible = true
    OpenIcon.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    KiteActivo = false; ShieldActivo = false; NoclipActivo = false
    if MyShield then pcall(function() MyShield:Destroy() end) MyShield = nil end
    ScreenGui:Destroy()
end)

ReloadBtn.MouseButton1Click:Connect(function()
    KiteActivo = false; ShieldActivo = false; NoclipActivo = false
    if MyShield then pcall(function() MyShield:Destroy() end) MyShield = nil end
    pcall(function() ScreenGui:Destroy(); loadstring(game:HttpGet(SCRIPT_URL .. "?r=" .. math.random(11,99)))() end)
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
    if not KiteActivo then
        if FarmTask then task.cancel(FarmTask); FarmTask = nil end
        pcall(function()
            local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if r then r.Anchored = false end
        end)
        StatusLabel.Text = "Estado: Inactivo"
    end
end

local function IniciarFarm()
    if FarmTask then return end
    
    FarmTask = task.spawn(function()
        local loopTick = 0
        local zTarget = nil
        local zDist = math.huge

        while KiteActivo do
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local currentHum = char:FindFirstChild("Humanoid")
                local myRoot = char:FindFirstChild("HumanoidRootPart")
                if not myRoot or not currentHum then return end

                loopTick = loopTick + 1
                local myLevel = GetMyLevel()

                -- ESCANEO CON FILTRO DE NIVEL
                if loopTick % 10 == 0 or not zTarget or (zTarget and not zTarget:FindFirstChildWhichIsA("Humanoid")) then
                    zTarget, zDist = findNearest(function(o)
                        if o:IsA("Model") and o ~= char then
                            local h = o:FindFirstChildWhichIsA("Humanoid")
                            if h and h.Health > 0 and o:GetAttribute("IsNpc") == true then
                                -- FILTRO DE NIVEL: Solo atacar zombis de tu nivel o menor
                                local mobLvl = GetMobLevel(o)
                                if mobLvl > 0 and mobLvl > myLevel then
                                    return false -- ¡MUY FUERTE! Ignorar este zombie
                                end
                                return true
                            end
                        end
                        return false
                    end)
                else
                    if zTarget and zTarget.Parent then
                        local zPart = zTarget:FindFirstChild("HumanoidRootPart") or zTarget:FindFirstChild("Torso")
                        if zPart then zDist = (myRoot.Position - zPart.Position).Magnitude else zTarget = nil end
                    else zTarget = nil end
                end

                if zTarget then
                    local targetPart = zTarget:FindFirstChild("HumanoidRootPart") or zTarget:FindFirstChild("Torso") or zTarget:FindFirstChildWhichIsA("BasePart")
                    if not targetPart then return end
                    
                    local dist = zDist
                    local targetDist = ShieldActivo and 4 or 7

                    -- == 1. EQUIPO DE ARMA ==
                    local isEquipped = false
                    for _, t in pairs(char:GetChildren()) do
                        if t:IsA("Tool") and string.find(string.lower(t.Name), "weapon") then
                            isEquipped = true; break
                        end
                    end

                    if not isEquipped then
                        local bpTools = LocalPlayer.Backpack:GetChildren()
                        for _, t in pairs(bpTools) do
                            if string.find(string.lower(t.Name), "weapon") then
                                currentHum:EquipTool(t); break
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
                            local speed = currentHum.WalkSpeed or 16
                            local dir = (targetPart.Position - myRoot.Position).Unit
                            bv.Velocity = dir * speed * 2.5
                            myRoot.CFrame = CFrame.new(myRoot.Position, myRoot.Position + Vector3.new(dir.X, 0, dir.Z))
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
                    local lookTarget = Vector3.new(targetPart.Position.X, myRoot.Position.Y, targetPart.Position.Z)
                    myRoot.CFrame = CFrame.lookAt(myRoot.Position, lookTarget)

                    if dist <= targetDist + 1.5 then
                        ToolRF:InvokeServer("Weapon")
                        local mobLvl = GetMobLevel(zTarget)
                        StatusLabel.Text = "🗡️ Atacando: " .. zTarget.Name .. " (Lvl " .. tostring(mobLvl) .. ") | Dist: " .. tostring(math.floor(dist)) .. "m | Tu Lvl: " .. tostring(myLevel)
                    else
                        StatusLabel.Text = "🏃 Cazando a: " .. zTarget.Name .. " (" .. tostring(math.floor(dist)) .. "m) | Tu Lvl: " .. tostring(myLevel)
                    end
                else
                    StatusLabel.Text = "🗡️ Buscando zombis de Lvl " .. tostring(myLevel) .. " o menor..."
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
        KiteBtn.Text = "🗡️ FARM MOBS: ON (Lvl " .. tostring(GetMyLevel()) .. ")"
        KiteBtn.BackgroundColor3 = Color3.fromRGB(220, 130, 40)
        IniciarFarm()
    else
        KiteBtn.Text = "🗡️ FARM MOBS (SOLO TU NIVEL O MENOR)"
        KiteBtn.BackgroundColor3 = Color3.fromRGB(180, 80, 40)
        DetenerFarm()
    end
end)
