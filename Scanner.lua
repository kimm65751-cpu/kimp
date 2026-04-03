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
MF.Size = UDim2.new(0, 300, 0, 285)
MF.Position = UDim2.new(0.05, 0, 0.4, 0)
MF.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MF.BorderSizePixel = 2
MF.BorderColor3 = Color3.fromRGB(255, 0, 100)
MF.Active = true
MF.Draggable = true

local Title = Instance.new("TextLabel", MF)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(50, 10, 20)
Title.Text = " ⚔️ AURA-FARM (HOVER MODE)"
Title.TextColor3 = Color3.fromRGB(255, 150, 150)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

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
BtnCodes.BackgroundColor3 = Color3.fromRGB(80, 60, 20)
BtnCodes.TextColor3 = Color3.new(1,1,1)
BtnCodes.Font = Enum.Font.GothamBold
BtnCodes.TextSize = 12
BtnCodes.Text = "💎 INTENTAR RECLAMAR (A CIEGAS)"

local BtnScanCodes = Instance.new("TextButton", MF)
BtnScanCodes.Size = UDim2.new(0.9, 0, 0, 35)
BtnScanCodes.Position = UDim2.new(0.05, 0, 0, 200)
BtnScanCodes.BackgroundColor3 = Color3.fromRGB(20, 60, 90)
BtnScanCodes.TextColor3 = Color3.new(1,1,1)
BtnScanCodes.Font = Enum.Font.GothamBold
BtnScanCodes.TextSize = 12
BtnScanCodes.Text = "🔍 ESCANEAR SISTEMA DE CÓDIGOS"

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
            -- Solo enfocarse en mobs vivos
            if mob.Humanoid.Health > 0 then
                local dist = (hrp.Position - mob.HumanoidRootPart.Position).Magnitude
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
    end
end)

-- Motor de ataque y persecución
task.spawn(function()
    while task.wait() do
        if AutoFarm then
            local char = LP.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                -- Check si el jugador murió para reiniciar
                if char.Humanoid.Health <= 0 then
                    StatusLabel.Text = "Status: Reviviendo..."
                    task.wait(2)
                    continue
                end

                -- Equipar espada/arma si la tenemos
                local tool = char:FindFirstChildOfClass("Tool")
                if not tool then
                    tool = LP.Backpack:FindFirstChildOfClass("Tool")
                    if tool then char.Humanoid:EquipTool(tool) end
                end

                local mob = GetNearestMob()
                if mob then
                    StatusLabel.Text = "Cazando: " .. mob.Name
                    local hrp = char.HumanoidRootPart
                    local mobHrp = mob:WaitForChild("HumanoidRootPart", 1)

                    if mobHrp then
                        -- ==========================================
                        -- REPOSICIONAMIENTO PERFECTO (HOVER, DETRÁS, ABAJO)
                        
                        -- Evitar cálculo de LookAt que colapsaba la cámara
                        if FarmMode == "Arriba" then
                            -- Se ubica arriba y copia la rotación Y del mob para estar derecho
                            hrp.CFrame = mobHrp.CFrame * CFrame.new(0, OfsY, 0)
                        elseif FarmMode == "Detras" then
                            hrp.CFrame = mobHrp.CFrame * CFrame.new(0, 0, OfsZ)
                        elseif FarmMode == "Abajo" then
                            hrp.CFrame = mobHrp.CFrame * CFrame.new(0, OfsY, 0)
                        end
                        
                        -- ==========================================
                        -- CAMARA CINEMATOGRÁFICA (Espectador de Mob)
                        -- Esto evita que el suelo o noclip ponga tu cámara en primera persona o negra
                        pcall(function()
                            local cam = Workspace.CurrentCamera
                            if cam and cam.CameraSubject ~= mob:FindFirstChild("Humanoid") then
                                cam.CameraSubject = mob:FindFirstChild("Humanoid") or mobHrp
                            end
                        end)
                        -- ==========================================
                        -- AURA KILL (Ataca instantáneamente enviando el Remoto de Hitt)
                        pcall(function()
                            -- Según el escaneo, no pide argumentos, pero asume que tienes el arma equipada.
                            CombatRemote:FireServer()
                            
                            -- Algunos juegos animan la espada, disparamos click también para que el server lo procese
                            if tool then tool:Activate() end
                        end)
                    end
                else
                    StatusLabel.Text = "Buscando Mobs vivos..."
                end
            else
                StatusLabel.Text = "Esperando al Personaje..."
            end
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
        
        -- Si inicias o revives, asegura que no te caigas reseteando cosas raras
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:FindFirstChildOfClass("BodyVelocity") then
            hrp:FindFirstChildOfClass("BodyVelocity"):Destroy()
        end
    else
        BtnToggle.Text = "► INICIAR AUTO-FARM"
        BtnToggle.BackgroundColor3 = Color3.fromRGB(100, 20, 30)
        StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        StatusLabel.Text = "Status: INACTIVO"
        
        -- Restaurar cámara cuando apagas
        pcall(function()
            if LP.Character and LP.Character:FindFirstChild("Humanoid") then
                Workspace.CurrentCamera.CameraSubject = LP.Character.Humanoid
            end
        end)
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
        OfsY = -8 -- 8 studs bajo tierra
        OfsZ = 0
        BtnHeight.Text = "Posición Segura: 🕳️ SUBTERRÁNEO"
    else
        FarmMode = "Arriba"
        OfsY = 10 -- 10 studs sobre su cabeza
        OfsZ = 0
        BtnHeight.Text = "Posición Segura: ☁️ ARRIBA"
    end
end)

-- Buscador Dinámico y Reclamador de Codigos
BtnCodes.MouseButton1Click:Connect(function()
    BtnCodes.Text = "⏳ Buscando remotas..."
    task.spawn(function()
        local codeRemote = nil
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local lName = obj.Name:lower()
                if lName:find("code") or lName:find("redeem") then
                    codeRemote = obj
                    break
                end
            end
        end
        
        if not codeRemote then
            BtnCodes.Text = "❌ No se encontró el evento de Códigos"
            task.wait(2)
            BtnCodes.Text = "💎 RECLAMAR TODOS LOS CÓDIGOS"
            return
        end
        
        BtnCodes.Text = "⏳ Robando datos de CodesConfig..."
        local ok, conf = pcall(function() return require(ReplicatedStorage:WaitForChild("CodesConfig", 2)) end)
        
        if ok and conf and conf.Codes then
            local count = 0
            for codeName, _ in pairs(conf.Codes) do
                pcall(function()
                    if codeRemote:IsA("RemoteEvent") then
                        codeRemote:FireServer(codeName)
                    else
                        codeRemote:InvokeServer(codeName)
                    end
                end)
                count = count + 1
                BtnCodes.Text = "💎 Reclamando: " .. count .. " / " .. tostring(BtnCodes.Text:match("/ (%d+)") or "?")
                task.wait(0.2)
            end
            BtnCodes.Text = "✅ " .. count .. " CÓDIGOS RECLAMADOS"
        else
            BtnCodes.Text = "❌ Módulo CodesConfig no accesible"
        end
        
        task.wait(3)
        BtnCodes.Text = "💎 INTENTAR RECLAMAR (A CIEGAS)"
    end)
end)

-- Escáner Forense para Sistema de Códigos
BtnScanCodes.MouseButton1Click:Connect(function()
    BtnScanCodes.Text = "⏳ Escaneando..."
    task.spawn(function()
        local logDump = "=== REPORTE DE AUDITORÍA: SISTEMA DE CÓDIGOS ===\n"
        logDump = logDump .. "Fecha: " .. os.date() .. "\n\n"
        
        logDump = logDump .. "[1] BUSCANDO REMOTAS (RemoteEvents / RemoteFunctions)\n"
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local name = obj.Name:lower()
                -- Filtro: Cualquier cosa que suene a canjear códigos, recompensas o menús
                if name:find("code") or name:find("redeem") or name:find("claim") or name:find("reward") or name:find("promo") then
                    logDump = logDump .. "[EXACT MATCH] " .. obj.ClassName .. ": " .. obj:GetFullName() .. "\n"
                end
            end
        end
        
        logDump = logDump .. "\n[2] BUSCANDO MÓDULOS DE CONFIGURACIÓN (.lua)\n"
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("ModuleScript") then
                local name = obj.Name:lower()
                if name:find("code") or name:find("redeem") or name:find("reward") or name:find("gift") then
                    logDump = logDump .. "[MODULO ENCONTRADO] " .. obj:GetFullName() .. "\n"
                    
                    -- Intentar extraer algo de info si es posible
                    pcall(function()
                        local req = require(obj)
                        if type(req) == "table" then
                            logDump = logDump .. "   > (Requiere Exitoso) Claves internas: "
                            for k, _ in pairs(req) do
                                logDump = logDump .. tostring(k) .. ", "
                            end
                            logDump = logDump .. "\n"
                        end
                    end)
                end
            end
        end
        
        logDump = logDump .. "\n[3] BUSCANDO BOTONES EN UI DEL CLIENTE LOCAL\n"
        if LP:FindFirstChild("PlayerGui") then
            for _, obj in pairs(LP.PlayerGui:GetDescendants()) do
                if obj:IsA("TextButton") or obj:IsA("ImageButton") or obj:IsA("TextBox") then
                    local name = obj.Name:lower()
                    if name:find("code") or name:find("redeem") or name:find("enter") then
                        logDump = logDump .. "[UI ELEMENT] " .. obj.ClassName .. " en " .. obj:GetFullName() .. "\n"
                    end
                end
            end
        end

        logDump = logDump .. "\n=== FIN DEL ESCANEO ===\n"
        
        -- Guardar el Archivo
        local fileName = "CODE_ANALYZER_REPORT_" .. tostring(os.time()) .. ".txt"
        if writefile then
            pcall(function() writefile(fileName, logDump) end)
            BtnScanCodes.Text = "✅ GUARDADO: " .. fileName
        elseif setclipboard then
            setclipboard(logDump)
            BtnScanCodes.Text = "✅ COPIADO AL PORTAPAPELES"
        else
            BtnScanCodes.Text = "❌ ERROR: EJECUTOR NO SOPORTA ESCRITURA"
        end
        
        task.wait(4)
        BtnScanCodes.Text = "🔍 ESCANEAR SISTEMA DE CÓDIGOS"
    end)
end)
