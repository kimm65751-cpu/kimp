-- ==============================================================================
-- 💀 ROBLOX EXPERT: V32 TARGET-LOCK BYPASS (EL OMNI-BUSCADOR UNIVERSAL)
-- Arreglo crítico de Búsqueda Anatómica para Bypass Físico de Zona Oscura.
-- ==============================================================================

local SCRIPT_URL = "https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local FullReport = ""
local Pages = {}
local CurrentPage = 1
local CHARS_PER_PAGE = 7000

local function AddLog(text, indentLevel)
    local prefix = string.rep("  ", indentLevel or 0)
    FullReport = FullReport .. prefix .. text .. "\n"
end

private_G = {}

-- ==============================================================================
-- 🔬 EL BUSCADOR ANATÓMICO (SIN ASUMIR NOMBRES)
-- ==============================================================================
local function GetViableTarget()
    local myChar = LocalPlayer.Character
    local closestTarget = nil
    local closestDist = math.huge
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            -- Solo requerimos que sea un Modelo con un Humanoid válido y no ser nosotros
            if obj:IsA("Model") and obj ~= myChar and not Players:GetPlayerFromCharacter(obj) then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj.PrimaryPart
                
                if hum and hrp and hum.Health > 0.1 then
                    -- Es un NPC, Monstruo o Bandido válido. Calcular el más cercano a ti para pegarle.
                    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    if myHrp then
                        local dist = (myHrp.Position - hrp.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestTarget = obj
                        end
                    else
                        -- Si estamos usando el ataque 2 y no tenemos HRP, solo agarramos al primero vivo
                        closestTarget = obj
                    end
                end
            end
        end)
    end
    return closestTarget
end

-- Mecanismo robusto para usar armas
local function FireWeapon()
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
        if bp then
            tool = bp:FindFirstChildOfClass("Tool")
            if tool then
                tool.Parent = LocalPlayer.Character
                task.wait(0.25)
            end
        end
    end
    if tool then pcall(function() tool:Activate() end) end
    return tool
end

-- ==============================================================================
-- 🚀 ATAQUE 1: HIT & RUN (MICRO-TELEPORTACIÓN RÁPIDA)
-- ==============================================================================
local function RunAttack1()
    FullReport = "========================================================\n"
    FullReport = FullReport .. "⚔️ V32. ATAQUE 1: HIT & RUN (CFRAME PURO RAPIDO) ⚔️\n"
    FullReport = FullReport .. "========================================================\n\n"
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then AddLog("❌ ERROR: No tienes personaje o RootPart.", 0); return end
    
    local target = GetViableTarget()
    if not target then AddLog("❌ ERROR ABSOLUTO: Literalmente no existen Modelos con Humanoides vivos en el mapa Workspace. ¿El juego genera monstruos locales?", 0); return end
    
    local PosOriginal = hrp.Position
    local StartHealth = target:FindFirstChildOfClass("Humanoid").Health
    
    AddLog("[+] TARGET OBTENIDO: '" .. target.Name .. "' (Vida actual: " .. tostring(math.floor(StartHealth)) .. ").", 0)
    AddLog("[🚀] MÉTODO HIT & RUN: Teletransporte -> Pegar -> Regresar (En 0.15s para saltar Tick de Anti-Cheat).", 0)
    
    local HuboFallo = false
    pcall(function()
        local targetHRP = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
        if not targetHRP then HuboFallo = true; return end
        
        for i=1, 4 do
            -- 1. Saltar a la cabeza del enemigo
            char:PivotTo(targetHRP.CFrame * CFrame.new(0, 0, 2))
            -- 2. Disparar el Arma de ClientCast inmediatamente
            FireWeapon()
            task.wait(0.15)
            -- 3. Regresar volando
            char:PivotTo(CFrame.new(PosOriginal))
            task.wait(0.5) 
        end
    end)
    
    if HuboFallo then AddLog("❌ ERROR: El monstruo no tiene partes físicas a las cuales teletransportarse.", 0); return end
    
    task.wait(1.5)
    local EndHealth = target:FindFirstChildOfClass("Humanoid").Health
    
    AddLog("\n[🔍 DIAGNÓSTICO DEL ATAQUE 1]", 0)
    if EndHealth < StartHealth then
        AddLog("├─ [🚨 FACTIBLE (TE ROBAN ASÍ)]: Lograste golpear al NPC ('"..target.Name.."') y quitarle " .. tostring(math.floor(StartHealth - EndHealth)) .. " HP regresando a base ileso.", 1)
        AddLog("├─ Por qué falla el Anti-Cheat: Mide tu posición cada 1 o 2 segundos. Viajar rápido C/S (Hit & Run de 0.15s) no deja rastro temporal para hacer Trigger a la sanción.", 1)
        AddLog("└─ SOLUCIÓN C++: Poner chequeos estáticos de Magnitud pura al recibir el daño de combate.", 1)
    else
        AddLog("├─ [🛡️ BLOQUEADO (SEGURO)]: El NPC ('"..target.Name.."') sigue con " .. tostring(math.floor(EndHealth)) .. " HP. El arma no se activó a tiempo o el Servidor hizo un 'Rollback' al daño.", 1)
        AddLog("└─ CONCLUSIÓN: Si este falló, significa que tu código base es demasiado rápido o requiere estar cerca para infligir daño.", 1)
    end
end

-- ==============================================================================
-- 🚀 ATAQUE 2: DARK ZONE GHOSTING (AMPUTACIÓN ROOTPART)
-- ==============================================================================
local function RunAttack2()
    FullReport = "========================================================\n"
    FullReport = FullReport .. "👻 V32. ATAQUE 2: DARK ZONE GHOSTING (AMPUTACIÓN HRP) 👻\n"
    FullReport = FullReport .. "========================================================\n\n"
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then AddLog("❌ ERROR: Tu personaje no tiene RootPart original.", 0); return end
    
    local target = GetViableTarget()
    if not target then AddLog("❌ ERROR: No hay Humanoides NPCs vivos en el mapa.", 0); return end
    
    local PosOriginal = hrp.Position
    local StartHealth = target:FindFirstChildOfClass("Humanoid").Health
    local SafeZone = PosOriginal + Vector3.new(0, 1500, 0)
    
    AddLog("[+] TARGET OBTENIDO: '" .. target.Name .. "' (Vida: " .. tostring(math.floor(StartHealth)) .. ").", 0)
    AddLog("[🚀] MÉTODO GHOST: Viajamos a Zona Oscura (+1500 Y) -> Borramos RootPart Local (Crashear Anti-Cheat) -> Bajamos oscilando a pegarle al NPC -> Volvemos.", 0)
    
    pcall(function()
        -- 1. Destruimos el HRP Local para cegar/crashear el Anticheat en Servidor
        hrp.Name = "NullPhysics"
        hrp.Parent = nil
        local torso = char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso")
        if not torso then return end
        
        -- 2. Nos vamos al cielo
        torso.CFrame = CFrame.new(SafeZone)
        task.wait(0.5)
        
        local targetHRP = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
        if not targetHRP then return end

        for i=1, 4 do
            torso.CFrame = targetHRP.CFrame * CFrame.new(0, 5, 0)
            FireWeapon()
            task.wait(0.3)
            torso.CFrame = CFrame.new(SafeZone)
            task.wait(0.5)
        end
        
        -- Restaurar física
        pcall(function() hrp.Parent = char; hrp.Name = "HumanoidRootPart" end)
        pcall(function() char:PivotTo(CFrame.new(PosOriginal)) end)
    end)
    
    task.wait(1.5)
    local EndHealth = target:FindFirstChildOfClass("Humanoid").Health
    
    AddLog("\n[🔍 DIAGNÓSTICO DEL ATAQUE 2]", 0)
    if EndHealth < StartHealth then
        AddLog("├─ [🚨 MORTAL (TE ROBAN ASÍ)]: Le quitaste " .. tostring(math.floor(StartHealth - EndHealth)) .. " HP desde el cielo siendo un personaje amputado.", 1)
        AddLog("├─ PENSAMIENTO HACKER: La falta del HumanoidRootPart ha dejado inoperativo al Script vigilante en tu servidor. Tu motor requiere parches Try/Catch urgentes.", 1)
        AddLog("└─ SOLUCIÓN C++: 'if Jugador.Character y no Jugador.Character:FindFirstChild(\"HumanoidRootPart\") entonces Kick' cada 2 segundos.", 1)
    else
        AddLog("├─ [🛡️ BLOQUEADO (SEGURO)]: NPC Intacto (" .. tostring(math.floor(EndHealth)) .. " HP). El servidor bloquea daño si tu personaje perdió partes base.", 1)
        AddLog("└─ CONCLUSIÓN: Estás blindado contra NullReference Exceptions físicas.", 1)
    end
end

-- ==============================================================================
-- 🚀 ATAQUE 3: BRING MOBS (NETWORK OWNERSHIP BYPASS)
-- ==============================================================================
local function RunAttack3()
    FullReport = "========================================================\n"
    FullReport = FullReport .. "🌪️ V32. ATAQUE 3: SECUESTRO FÍSICO (BRING MOBS) 🌪️\n"
    FullReport = FullReport .. "========================================================\n\n"
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then AddLog("❌ ERROR: No tienes personaje.", 0); return end
    
    local target = GetViableTarget()
    if not target then AddLog("❌ ERROR: No hay NPCs vivos en el mapa.", 0); return end
    
    local zHRP = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
    if not zHRP then AddLog("❌ ERROR: El NPC no tiene física.", 0); return end

    local PosOriginal = hrp.Position
    local ZombOriginal = zHRP.Position
    local StartHealth = target:FindFirstChildOfClass("Humanoid").Health
    
    AddLog("[+] TARGET OBTENIDO: '" .. target.Name .. "' (A " .. tostring(math.floor((PosOriginal - ZombOriginal).Magnitude)) .. " Studs).", 0)
    AddLog("[🚀] MÉTODO SECUESTRO: Falsificar la autoría de Red. Teletransportamos al NPC hacia nosotros abusando de una mala asignación Client-Owner.", 0)
    
    pcall(function()
        task.spawn(function()
            for i=1, 30 do
                if not target or not zHRP or not hrp then break end
                -- Traemos violentamente al Boss o Zombie hacia el Avatar
                zHRP.CFrame = hrp.CFrame * CFrame.new(0, 0, -4) 
                task.wait(0.05)
            end
        end)
        
        task.wait(0.3)
        for i=1, 4 do FireWeapon(); task.wait(0.3) end
    end)
    
    task.wait(1.5)
    local EndHealth = target:FindFirstChildOfClass("Humanoid").Health
    local ZombFinal = zHRP.Position
    
    AddLog("\n[🔍 DIAGNÓSTICO DEL ATAQUE 3]", 0)
    local HuboMovimientoMaligno = (ZombFinal - PosOriginal).Magnitude < 15 and (ZombOriginal - PosOriginal).Magnitude > 25

    if HuboMovimientoMaligno then
        AddLog("├─ [🚨 FACTIBLE (ROBO DE RED)]: El '"..target.Name.."' fue forzado a volar hacia tu cara y el Servidor LO PERMITIÓ.", 1)
        if EndHealth < StartHealth then AddLog("├─ CONSECUENCIA DIRECTA: Le quitaste " .. tostring(math.floor(StartHealth - EndHealth)) .. " HP sin siquiera moverte.", 1) end
        AddLog("└─ SOLUCIÓN C++: Falto ejecutar 'ZombiRootPart:SetNetworkOwner(nil)'. Hazlo siempre en el momento que Spawneas un nuevo monstruo.", 1)
    else
        AddLog("├─ [🛡️ BLOQUEADO (SEGURO)]: El '"..target.Name.."' se rehusó a obedecer las matemáticas LUA del Cliente. La física no se alteró en Red.", 1)
        AddLog("└─ CONCLUSIÓN: El C++ gestiona los dueños de físicas espléndidamente. Nadie mueve a tus monstruos.", 1)
    end
end

-- ==============================================================================
-- ⚙️ MOTOR DEL OMNI-SCANNER Y CHUNKER
-- ==============================================================================
local function SegmentarPaginas()
    Pages = {}
    local startIdx = 1
    while startIdx <= #FullReport do
        local endIdx = startIdx + CHARS_PER_PAGE - 1
        table.insert(Pages, string.sub(FullReport, startIdx, endIdx))
        startIdx = endIdx + 1
    end
    CurrentPage = 1
    if #Pages == 0 then table.insert(Pages, "No hay datos generados que mostrar.") end
end

-- ==============================================================================
-- 🖥️ GUI V32: THE DARK-ZONE ORCHESTRATOR (O-SCANNER)
-- ==============================================================================
local function ConstruirUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "MasterBypass2026UI"
    sg.ResetOnSpawn = false
    
    local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "MasterBypass2026UI" then v:Destroy() end end
    sg.Parent = parentUI

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 720, 0, 560)
    MainFrame.Position = UDim2.new(0.5, -360, 0.5, -280)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 30)
    MainFrame.BorderSizePixel = 3
    MainFrame.BorderColor3 = Color3.fromRGB(0, 200, 255)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -90, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
    TopBar.Text = "  [V32: TARGET-LOCK BYPASS - CAZADOR DE ANATOMÍA PURA]"
    TopBar.TextColor3 = Color3.fromRGB(150, 255, 255)
    TopBar.Font = Enum.Font.Code
    TopBar.TextSize = 13
    TopBar.TextXAlignment = Enum.TextXAlignment.Left
    TopBar.Parent = MainFrame

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.TextSize = 14
    CloseBtn.Parent = MainFrame

    local ReloadBtn = Instance.new("TextButton")
    ReloadBtn.Size = UDim2.new(0, 30, 0, 30)
    ReloadBtn.Position = UDim2.new(1, -60, 0, 0)
    ReloadBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 0)
    ReloadBtn.Text = "↻"
    ReloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ReloadBtn.Font = Enum.Font.Code
    ReloadBtn.TextSize = 18
    ReloadBtn.Parent = MainFrame

    CloseBtn.MouseButton1Click:Connect(function() sg:Destroy() end)
    ReloadBtn.MouseButton1Click:Connect(function() pcall(function() sg:Destroy(); loadstring(game:HttpGet(SCRIPT_URL .. "?r=" .. math.random(111,999)))() end) end)

    local InfoScroll = Instance.new("ScrollingFrame")
    InfoScroll.Size = UDim2.new(1, -16, 0.55, 0)
    InfoScroll.Position = UDim2.new(0, 8, 0, 35)
    InfoScroll.BackgroundColor3 = Color3.fromRGB(10, 15, 20)
    InfoScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    InfoScroll.ScrollBarThickness = 6
    InfoScroll.Parent = MainFrame

    local LogTextBox = Instance.new("TextBox")
    LogTextBox.Size = UDim2.new(1, -10, 1, 0)
    LogTextBox.Position = UDim2.new(0, 5, 0, 5)
    LogTextBox.BackgroundTransparency = 1
    LogTextBox.Text = "ERROR CORREGIDO. EL BUSCADOR AHORA ES CIEGO A LOS NOMBRES.\n\nEn la prueba anterior te salió 'No hay zombies' a pesar de que tenías a los NPCs enfrente.\nEl problema es que yo asumía que los programabas con nombres de texto que incluían la palabra 'Zombie' o 'Boss'. Algunos Devs prefieren llamarlos 'Enemy', 'Mummy', 'Slime', etc.\n\nACTUALIZACIONES DE LA V32:\n- Reescritura del algoritmo de Cazador LUA: Tu herramienta ya NO MIRA EL NOMBRE. Escudriñará el mapa entero hasta hallar cualquier modelo biomecánico con la clase 'Humanoid' que tenga Vida > 0.1 y que no seas tú o tus amigos.\n- Asegurará el Target más cercano automáticamente.\n- Conectar el Arma es OBLIGATORIO (Pon tu escudo y espada en tu mano antes de presionar cualquiera de los 3 asaltos).\n\nAhora tienes luz verde total frente a tus NPCs anónimos. ¡Elige un ataque!"
    LogTextBox.TextColor3 = Color3.fromRGB(180, 240, 255)
    LogTextBox.Font = Enum.Font.Code
    LogTextBox.TextSize = 12
    LogTextBox.TextXAlignment = Enum.TextXAlignment.Left
    LogTextBox.TextYAlignment = Enum.TextYAlignment.Top
    LogTextBox.TextWrapped = true
    LogTextBox.ClearTextOnFocus = false
    LogTextBox.TextEditable = false
    LogTextBox.MultiLine = true
    LogTextBox.Parent = InfoScroll

    local function ActualizarPantalla()
        if #Pages == 0 then return end
        LogTextBox.Text = Pages[CurrentPage]
        InfoScroll.CanvasPosition = Vector2.new(0, 0)
    end

    -- BOTONES TÁCTICOS (LOS 3 PEDIDOS)
    local btnAtk1 = Instance.new("TextButton")
    btnAtk1.Size = UDim2.new(0.32, 0, 0, 40)
    btnAtk1.Position = UDim2.new(0, 8, 0.70, 0)
    btnAtk1.BackgroundColor3 = Color3.fromRGB(120, 60, 0)
    btnAtk1.Text = "🔥 ATK 1: HIT & RUN VELOZ"
    btnAtk1.TextColor3 = Color3.fromRGB(255, 230, 200)
    btnAtk1.Font = Enum.Font.Code
    btnAtk1.TextSize = 12
    btnAtk1.Parent = MainFrame
    
    local btnAtk2 = Instance.new("TextButton")
    btnAtk2.Size = UDim2.new(0.32, 0, 0, 40)
    btnAtk2.Position = UDim2.new(0.34, 0, 0.70, 0)
    btnAtk2.BackgroundColor3 = Color3.fromRGB(140, 0, 180)
    btnAtk2.Text = "👻 ATK 2: FANTASMA"
    btnAtk2.TextColor3 = Color3.fromRGB(255, 220, 255)
    btnAtk2.Font = Enum.Font.Code
    btnAtk2.TextSize = 12
    btnAtk2.Parent = MainFrame
    
    local btnAtk3 = Instance.new("TextButton")
    btnAtk3.Size = UDim2.new(0.32, 0, 0, 40)
    btnAtk3.Position = UDim2.new(0.66, 8, 0.70, 0)
    btnAtk3.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    btnAtk3.Text = "🌪️ ATK 3: SECUESTRO FÍSICO"
    btnAtk3.TextColor3 = Color3.fromRGB(200, 240, 255)
    btnAtk3.Font = Enum.Font.Code
    btnAtk3.TextSize = 12
    btnAtk3.Parent = MainFrame

    btnAtk1.MouseButton1Click:Connect(function() pcall(function() RunAttack1() SegmentarPaginas() ActualizarPantalla() end) end)
    btnAtk2.MouseButton1Click:Connect(function() pcall(function() RunAttack2() SegmentarPaginas() ActualizarPantalla() end) end)
    btnAtk3.MouseButton1Click:Connect(function() pcall(function() RunAttack3() SegmentarPaginas() ActualizarPantalla() end) end)
    
    local btnPrev = Instance.new("TextButton")
    btnPrev.Size = UDim2.new(0.32, 0, 0, 30)
    btnPrev.Position = UDim2.new(0, 8, 0.85, 0)
    btnPrev.BackgroundColor3 = Color3.fromRGB(30, 60, 80)
    btnPrev.Text = "< Pielgues"
    btnPrev.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnPrev.Parent = MainFrame

    local PageLabel = Instance.new("TextLabel")
    PageLabel.Size = UDim2.new(0.32, 0, 0, 30)
    PageLabel.Position = UDim2.new(0.34, 0, 0.85, 0)
    PageLabel.BackgroundTransparency = 1
    PageLabel.Text = "Página.. "
    PageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    PageLabel.Parent = MainFrame

    local btnNext = Instance.new("TextButton")
    btnNext.Size = UDim2.new(0.32, 0, 0, 30)
    btnNext.Position = UDim2.new(0.66, 8, 0.85, 0)
    btnNext.BackgroundColor3 = Color3.fromRGB(30, 60, 80)
    btnNext.Text = "Lectura >"
    btnNext.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnNext.Parent = MainFrame
    
    local function UptLabel() PageLabel.Text = "Página " .. tostring(CurrentPage) .. " / " .. tostring(#Pages) end
    btnPrev.MouseButton1Click:Connect(function() if CurrentPage > 1 then CurrentPage = CurrentPage - 1; ActualizarPantalla(); UptLabel() end end)
    btnNext.MouseButton1Click:Connect(function() if CurrentPage < #Pages then CurrentPage = CurrentPage + 1; ActualizarPantalla(); UptLabel() end end)
end

ConstruirUI()
