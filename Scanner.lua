-- ==============================================================================
-- 🦖 CAM V11 — PET ROTATION SYSTEM
-- Opción A: Rota entre los 3 pets activos (los que caminan contigo)
-- Opción B: Rota pets desde la mochila (PetBag swap)
-- ==============================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-- Limpieza
for _, v in pairs(PlayerGui:GetChildren()) do
    if v.Name:find("CAM_") then pcall(function() v:Destroy() end) end
end

local SG = Instance.new("ScreenGui")
SG.Name = "CAM_V11"
SG.ResetOnSpawn = false
SG.Parent = PlayerGui

local MF = Instance.new("Frame", SG)
MF.Size = UDim2.new(0, 500, 0, 480)
MF.Position = UDim2.new(0.38, 0, 0.1, 0)
MF.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MF.BorderSizePixel = 2
MF.BorderColor3 = Color3.fromRGB(0, 200, 255)
MF.Active = true
MF.Draggable = true

local Title = Instance.new("TextLabel", MF)
Title.Size = UDim2.new(1, 0, 0, 26)
Title.BackgroundColor3 = Color3.fromRGB(0, 50, 70)
Title.Text = "  🔄 PET ROTATION V11 — A:Activos  B:Mochila"
Title.TextColor3 = Color3.fromRGB(100, 220, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left

local LogFrame = Instance.new("ScrollingFrame", MF)
LogFrame.Size = UDim2.new(1, -10, 0, 190)
LogFrame.Position = UDim2.new(0, 5, 0, 28)
LogFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LogFrame.ScrollBarThickness = 4
LogFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", LogFrame).SortOrder = Enum.SortOrder.LayoutOrder

local lc = 0
local logBuffer = {}
local function Log(t, c)
    lc = lc + 1
    local line = "["..os.date("%X").."] "..t
    table.insert(logBuffer, line)
    local m = Instance.new("TextLabel", LogFrame)
    m.Size = UDim2.new(1, 0, 0, 14)
    m.BackgroundTransparency = 1
    m.Text = line
    m.TextXAlignment = Enum.TextXAlignment.Left
    m.TextColor3 = c or Color3.fromRGB(200, 200, 200)
    m.Font = Enum.Font.Code
    m.TextSize = 11
    m.TextWrapped = true
    m.AutomaticSize = Enum.AutomaticSize.Y
    m.LayoutOrder = lc
    LogFrame.CanvasPosition = Vector2.new(0, 99999)
end

local function MkBtn(txt, py, bw, bx)
    local b = Instance.new("TextButton", MF)
    b.Size = UDim2.new(bw or 0.92, 0, 0, 28)
    b.Position = UDim2.new(bx or 0.04, 0, 0, py)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 11
    b.Text = txt
    return b
end

local btnScan    = MkBtn("🔍 ESCANEAR: Encontrar pets activos en Workspace", 228)
local btnOptA    = MkBtn("🔄 OPCIÓN A: Rotación entre 3 pets activos", 261)
local btnOptB    = MkBtn("🎒 OPCIÓN B: Swap rápido desde mochila (PetBag)", 294)
local btnFarm    = MkBtn("⚔️ AUTO-FARM básico (Click + Auto-E)", 327)
local btnCopy    = MkBtn("📋 COPIAR LOG", 360, 0.43, 0.04)
local btnExport  = MkBtn("💾 EXPORTAR .TXT", 360, 0.45, 0.51)

btnCopy.MouseButton1Click:Connect(function()
    pcall(function()
        if setclipboard then setclipboard(table.concat(logBuffer,"\n"))
            Log("📋 Copiado!", Color3.fromRGB(0,255,0))
        else Log("❌ setclipboard no disponible", Color3.fromRGB(255,100,100)) end
    end)
end)
btnExport.MouseButton1Click:Connect(function()
    local fn = "CAM_PetRot_"..os.date("%Y%m%d_%H%M%S")..".txt"
    pcall(function() writefile(fn, table.concat(logBuffer,"\n")) end)
    Log("💾 Exportado: "..fn, Color3.fromRGB(0,255,200))
end)

-- ==============================================================================
-- DETECCIÓN DE PETS ACTIVOS
-- ==============================================================================
-- Los pets siguen al jugador. Buscamos modelos cerca del jugador
-- que NO sean mobs (no tienen ClickDetector) y tienen PrimaryPart
local activePets = {}

local function ScanPets()
    activePets = {}
    if not LP.Character or not LP.Character.PrimaryPart then
        Log("❌ Tu personaje no está cargado", Color3.fromRGB(255,100,100))
        return
    end
    local myPos = LP.Character.PrimaryPart.Position

    -- Método 1: Buscar en carpeta ClientPets o similar
    local petFolder = nil
    for _, name in pairs({"ClientPets", "Pets", "PetModels", "PlayerPets"}) do
        petFolder = Workspace:FindFirstChild(name)
        if petFolder then
            Log("📁 Carpeta de pets: Workspace."..name, Color3.fromRGB(100,255,200))
            break
        end
    end

    if petFolder then
        for _, child in pairs(petFolder:GetChildren()) do
            if child:IsA("Model") and child.PrimaryPart then
                table.insert(activePets, child)
                Log("  🐾 Pet: "..child.Name, Color3.fromRGB(100,200,255))
            end
        end
    else
        -- Método 2: Buscar modelos cerca del jugador SIN ClickDetector
        Log("⚠️ No hay carpeta ClientPets. Escaneando por proximidad...", Color3.fromRGB(255,200,0))
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.PrimaryPart then
                local cd = obj:FindFirstChildWhichIsA("ClickDetector", true)
                if not cd then -- No es un mob
                    local d = (obj.PrimaryPart.Position - myPos).Magnitude
                    if d < 30 and obj ~= LP.Character then -- Cerca y no eres tú
                        table.insert(activePets, obj)
                        Log("  🐾 Posible pet: "..obj.Name.." ["..math.floor(d).."m]", Color3.fromRGB(100,200,255))
                    end
                end
            end
        end
    end

    -- Método 3: Revisar getgc por objetos con Source=Evolution ACTIVOS
    if #activePets == 0 then
        Log("⚠️ Sin pets encontrados. Intentando getgc...", Color3.fromRGB(255,200,0))
        pcall(function()
            for _, v in pairs(getgc(true)) do
                if type(v) == "table" then
                    local src = rawget(v,"Source")
                    local name = rawget(v,"Name")
                    local model = rawget(v,"Model")
                    -- Pet activo en el juego tiene Source=Evolution y un modelo cargado
                    if src == "Evolution" and name and model then
                        Log("  🐾 Pet en GC: "..tostring(name).." (model:"..tostring(model)..")", Color3.fromRGB(150,255,100))
                    end
                end
            end
        end)
    end

    Log("✅ Scan completo. Pets encontrados: "..#activePets, Color3.fromRGB(0,255,0))
end

btnScan.MouseButton1Click:Connect(function()
    Log("🔍 Escaneando pets activos...", Color3.fromRGB(0,200,255))
    ScanPets()
end)

-- ==============================================================================
-- OPCIÓN A: ROTACIÓN ENTRE PETS ACTIVOS (los 3 que caminan contigo)
-- Estrategia: Cada X seg, cliqueamos UN pet diferente al mob
-- para que el juego asigne ese pet como el atacante activo
-- ==============================================================================
local optAActive = false
local petIndex = 1

btnOptA.MouseButton1Click:Connect(function()
    if #activePets == 0 then
        Log("❌ Primero escanea los pets (botón 🔍)", Color3.fromRGB(255,100,100))
        return
    end
    optAActive = not optAActive
    btnOptA.BackgroundColor3 = optAActive and Color3.fromRGB(0,100,150) or Color3.fromRGB(40,40,55)
    btnOptA.Text = optAActive and "🔄 ROTACIÓN ACTIVA (Pulsa para parar)" or "🔄 OPCIÓN A: Rotación entre 3 pets activos"
    Log(optAActive and ("✅ Rotación ON — "..#activePets.." pets") or "🛑 Rotación OFF", Color3.fromRGB(100,220,255))
end)

task.spawn(function()
    while true do
        task.wait(1.5) -- Rotar cada 1.5 segundos
        if not optAActive or #activePets == 0 then continue end
        if not LP.Character or not LP.Character.PrimaryPart then continue end

        pcall(function()
            -- Seleccionar siguiente pet en rotación
            petIndex = (petIndex % #activePets) + 1
            local currentPet = activePets[petIndex]

            if not currentPet or not currentPet.Parent then
                -- Pet ya no existe, rescanear
                Log("⚠️ Pet "..petIndex.." no existe, rescaneando...", Color3.fromRGB(255,200,0))
                ScanPets()
                return
            end

            -- Buscar mob más cercano
            local myPos = LP.Character.PrimaryPart.Position
            local targetMob, targetCd, targetDist = nil, nil, 100

            local cm = Workspace:FindFirstChild("ClientMonsters")
            if cm then
                for _, mob in pairs(cm:GetChildren()) do
                    local cd = mob:FindFirstChildWhichIsA("ClickDetector", true)
                    if cd and mob.PrimaryPart then
                        local d = (mob.PrimaryPart.Position - myPos).Magnitude
                        if d < targetDist then
                            targetDist = d
                            targetMob = mob
                            targetCd = cd
                        end
                    end
                end
            end

            if not targetCd then return end

            -- Clickear el mob con el pet actual como "atacante"
            -- El juego usa el pet más cercano al mob al hacer click
            fireclickdetector(targetCd)

            -- Intentar mover el pet hacia el mob para forzar que ESTE pet ataque
            -- (el juego asigna el ataque al pet más cercano al mob)
            local petPart = currentPet.PrimaryPart or currentPet:FindFirstChildWhichIsA("BasePart")
            if petPart and targetMob.PrimaryPart then
                -- Teletransportar brevemente el pet al mob (fuerza ataque)
                local origCF = petPart.CFrame
                pcall(function()
                    petPart.CFrame = targetMob.PrimaryPart.CFrame + Vector3.new(0, 0, 3)
                end)
                task.wait(0.1)
                pcall(function()
                    petPart.CFrame = origCF -- Devolver a posición original
                end)
            end

            Log("🔄 Pet["..petIndex.."] "..currentPet.Name.." → "..targetMob.Name.." ["..math.floor(targetDist).."m]", Color3.fromRGB(100,255,200))
        end)
    end
end)

-- ==============================================================================
-- OPCIÓN B: SWAP DESDE MOCHILA (PetBag)
-- Estrategia: Interceptar el RemoteEvent de swap de pets
-- y rotarlos rápidamente desde el inventario
-- ==============================================================================
local optBActive = false
local petBagRemote = nil

-- Buscar el remote de swap de pets usando hookmetamethod
local swapCaptured = false
local lastSwapRemote = nil
local lastSwapArgs = nil

btnOptB.MouseButton1Click:Connect(function()
    optBActive = not optBActive
    btnOptB.BackgroundColor3 = optBActive and Color3.fromRGB(120,80,0) or Color3.fromRGB(40,40,55)
    btnOptB.Text = optBActive and "🎒 SWAP MOCHILA ACTIVO (Pulsa para parar)" or "🎒 OPCIÓN B: Swap rápido desde mochila (PetBag)"
    Log(optBActive and "✅ Swap de mochila ON" or "🛑 Swap de mochila OFF", Color3.fromRGB(255,200,100))

    if optBActive and not swapCaptured then
        swapCaptured = true
        -- Instalar hook para capturar el remote de swap
        local ok, err = pcall(function()
            if type(hookmetamethod) ~= "function" then
                error("hookmetamethod no disponible")
            end
            local oldNC
            oldNC = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if method == "FireServer" or method == "InvokeServer" then
                    if (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
                        local args = {...}
                        local argStr = tostring(args[1] or "")
                        -- Buscar eventos relacionados con pets/swap/equip
                        local lower = self.Name:lower()..argStr:lower()
                        if lower:find("pet") or lower:find("equip") or lower:find("swap") or
                           lower:find("collect") or lower:find("bag") or lower:find("deploy") then
                            lastSwapRemote = self
                            lastSwapArgs = args
                            Log("🎒 SWAP REMOTE CAPTURADO: "..self.Name.."("..argStr..")", Color3.fromRGB(255,200,0))
                        end
                    end
                end
                return oldNC(self, ...)
            end))
        end)
        if ok then
            Log("✅ Hook instalado — Ahora cambia un pet manualmente desde el menú", Color3.fromRGB(0,255,0))
            Log("(Equipa/desequipa un pet desde tu inventario para capturar el remote)", Color3.fromRGB(200,200,200))
        else
            Log("❌ Hook falló: "..tostring(err), Color3.fromRGB(255,100,100))
            Log("Tu executor no soporta hookmetamethod", Color3.fromRGB(255,100,100))
        end
    end
end)

-- Loop de swap rápido (una vez capturado el remote)
task.spawn(function()
    while true do
        task.wait(2)
        if not optBActive or not lastSwapRemote then continue end
        pcall(function()
            -- Repetir el último swap capturado
            lastSwapRemote:FireServer(table.unpack(lastSwapArgs))
            Log("🔁 Swap disparado → "..lastSwapRemote.Name, Color3.fromRGB(255,200,100))
        end)
    end
end)

-- ==============================================================================
-- AUTO-FARM BÁSICO
-- ==============================================================================
local farmActive = false
btnFarm.MouseButton1Click:Connect(function()
    farmActive = not farmActive
    btnFarm.BackgroundColor3 = farmActive and Color3.fromRGB(0,100,50) or Color3.fromRGB(40,40,55)
    btnFarm.Text = farmActive and "⚔️ FARMING ACTIVO" or "⚔️ AUTO-FARM básico (Click + Auto-E)"
end)

task.spawn(function()
    while true do
        task.wait(2.5)
        if not farmActive or not LP.Character or not LP.Character.PrimaryPart then continue end
        pcall(function()
            local best, bestDist = nil, 80
            local cm = Workspace:FindFirstChild("ClientMonsters")
            if cm then
                for _, mob in pairs(cm:GetChildren()) do
                    local cd = mob:FindFirstChildWhichIsA("ClickDetector", true)
                    if cd and mob.PrimaryPart then
                        local d = (mob.PrimaryPart.Position - LP.Character.PrimaryPart.Position).Magnitude
                        if d < bestDist then bestDist = d; best = cd end
                    end
                end
            end
            if best then fireclickdetector(best) end
        end)
    end
end)

task.spawn(function()
    pcall(function()
        for _, desc in pairs(ReplicatedStorage:GetDescendants()) do
            if desc:IsA("RemoteEvent") then
                desc.OnClientEvent:Connect(function(...)
                    if farmActive and tostring(({...})[1] or "") == "PushRewardEvent" then
                        task.delay(0.25, function()
                            pcall(function()
                                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                task.wait(0.1)
                                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            end)
                        end)
                    end
                end)
            end
        end
    end)
end)

Log("=== V11 PET ROTATION CARGADO ===", Color3.fromRGB(0,255,0))
Log("PASO 1: Pulsa 🔍 ESCANEAR para encontrar tus pets activos", Color3.fromRGB(255,220,100))
Log("PASO 2A: Pulsa 🔄 OPCIÓN A para rotar entre pets activos", Color3.fromRGB(100,200,255))
Log("PASO 2B: Pulsa 🎒 OPCIÓN B + cambia un pet manualmente", Color3.fromRGB(255,200,100))
Log("  → Cuando captures el remote, el swap se repite automático", Color3.fromRGB(200,200,200))
