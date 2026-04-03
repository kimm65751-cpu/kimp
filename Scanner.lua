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
MF.Size = UDim2.new(0, 300, 0, 405)
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

local BtnSpy = Instance.new("TextButton", MF)
BtnSpy.Size = UDim2.new(0.9, 0, 0, 30)
BtnSpy.Position = UDim2.new(0.05, 0, 0, 280)
BtnSpy.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
BtnSpy.TextColor3 = Color3.new(1,1,1)
BtnSpy.Font = Enum.Font.GothamBold
BtnSpy.TextSize = 11
BtnSpy.Text = "📡 INICIAR ESPÍA Y LOG A TXT"

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
-- [NUEVO] INTERCEPTOR GLOBAL DE RED (SPY LOG)
-- ==============================================================================
pcall(function()
    local mt = getrawmetatable(game)
    if mt and mt.__namecall then
        setreadonly(mt, false)
        local oldNamecall = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if SpyEnabled and (method == "FireServer" or method == "InvokeServer") then
                -- Filtramos el Remoto de combate propio para no llenar el TXT (spam)
                if self ~= CombatRemote and self.Name ~= "RequestHit" then
                    local args = {...}
                    local strArgs = ""
                    for _, v in ipairs(args) do
                        strArgs = strArgs .. tostring(v) .. " [" .. typeof(v) .. "], "
                    end
                    
                    local logLine = "\n[SPY] " .. self.Name .. ":" .. method .. "() | Args: " .. strArgs
                    -- Imprime en consola (F9)
                    print(logLine)
                    
                    -- Guarda automáticamente en el Workspace del Ejecutor
                    task.spawn(function()
                        if appendfile then
                            pcall(function() appendfile(SpyFileName, logLine) end)
                        elseif writefile then
                            local old = ""
                            pcall(function() old = readfile(SpyFileName) end)
                            pcall(function() writefile(SpyFileName, old .. logLine) end)
                        end
                    end)
                end
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end
end)
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
                    
                    StatusLabel.Text = "Cazando: " .. mob.Name
                    local hrp = char.HumanoidRootPart
                    local mobHrp = mob:WaitForChild("HumanoidRootPart", 1)

                    if mobHrp then
                        GlobalMagnetTarget = mobHrp.Position
                        
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

BtnSpy.MouseButton1Click:Connect(function()
    SpyEnabled = not SpyEnabled
    if SpyEnabled then
        BtnSpy.BackgroundColor3 = Color3.fromRGB(10, 100, 200)
        BtnSpy.Text = "📡 ESPÍA ACTIVO: GUARDANDO EN TXT..."
        SpyFileName = "OmniSpy_Dumps_" .. tostring(math.floor(os.clock())) .. ".txt"
        print("Iniciando Log a archivo en la carpeta 'workspace' del ejecutor: " .. SpyFileName)
        if writefile then
            pcall(function() writefile(SpyFileName, "=== OMNI-SPY INICIADO ===\nVe y pisa la Zona Segura para capturar el remoto...\n") end)
        end
    else
        BtnSpy.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        BtnSpy.Text = "📡 INICIAR ESPÍA Y LOG A TXT"
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
