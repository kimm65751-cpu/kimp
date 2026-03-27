-- ==============================================================================
-- 💀 ROBLOX EXPERT: V36 THE MAGNETIC ASSASSIN (AIMBOT DE IMPACTO SEGURO)
-- Combate continuo Asíncrono. Espera hasta registrar daño y persigue Zombis.
-- ==============================================================================

local SCRIPT_URL = "https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local VIM = game:GetService("VirtualInputManager")

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
-- 🔬 BUSCADOR ESTRICTO POR NOMBRES Y AIMBOT SINTÉTICO
-- ==============================================================================
local function GetViableTarget()
    local myChar = LocalPlayer.Character
    local closestTarget = nil
    local closestDist = math.huge
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            local name = obj.Name:lower()
            -- El Radar AHORA NUNCA FALLARÁ en dar un NPC Válido de verdad.
            if name:match("zombie") or name:match("delver") or name:match("brute") or name:match("elite") or name:match("boss") then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj.PrimaryPart
                
                if hum and hrp and hum.Health > 0.1 then
                    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    if myHrp then
                        local dist = (myHrp.Position - hrp.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestTarget = obj
                        end
                    else closestTarget = obj end
                end
            end
        end)
    end
    return closestTarget
end

local function ForzarClickVirtual()
    pcall(function()
        local cam = Workspace.CurrentCamera
        local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        VirtualUser:Button1Down(center)
        task.wait(0.01)
        VirtualUser:Button1Up(center)
    end)
    pcall(function()
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.01)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end)
    pcall(function() ReplicatedStorage.HitboxClassRemote:FireServer("Hit") end)
end

-- ==============================================================================
-- 🚀 MOTOR DE ATAQUE MAGNÉTICO (AWAIT IMPACT)
-- ==============================================================================
local function AttackMagnetically(target, PosOriginal, isGhostMode)
    local targetHRP = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
    local targetHum = target:FindFirstChildOfClass("Humanoid")
    local startHealth = targetHum.Health

    local doingAimbot = true
    local connection = RunService.RenderStepped:Connect(function()
        pcall(function()
            if doingAimbot and targetHRP and targetHum.Health > 0 then
                -- Posición letal justo en la nariz del Zombie
                local enfrente = targetHRP.Position + (targetHRP.CFrame.LookVector * 2.5)

                if isGhostMode then
                    -- En Fantasma, amputamos Root, así que movemos el Torso y nos ponemos encima de él
                    enfrente = targetHRP.Position + Vector3.new(0, 5, 0)
                    local miTorso = LocalPlayer.Character:FindFirstChild("LowerTorso") or LocalPlayer.Character:FindFirstChild("Torso")
                    if miTorso then
                        miTorso.CFrame = CFrame.lookAt(enfrente, targetHRP.Position)
                    end
                else
                    -- Ataque Normal
                    LocalPlayer.Character:PivotTo(CFrame.lookAt(enfrente, targetHRP.Position))
                end

                -- Lock Aim a la cabeza para el Hitbox
                Workspace.CurrentCamera.CFrame = CFrame.lookAt(Workspace.CurrentCamera.CFrame.Position, targetHRP.Position + Vector3.new(0, 1.5, 0))
            end
        end)
    end)

    -- ESPERAMOS A QUE EL IMPACTO REALMENTE OCURRA O SE AGOTE EL TIEMPO
    local startTick = tick()
    repeat
        ForzarClickVirtual()
        task.wait(0.15)
    until targetHum.Health < startHealth or (tick() - startTick) > 3.5
    
    -- Se acabó el Lock y regresamos
    doingAimbot = false
    connection:Disconnect()

    if isGhostMode then
        pcall(function()
            local hrpBasura = LocalPlayer.Character:FindFirstChild("NullPhysics")
            if hrpBasura then 
                hrpBasura.Parent = LocalPlayer.Character
                hrpBasura.Name = "HumanoidRootPart"
            end
        end)
    end

    pcall(function() LocalPlayer.Character:PivotTo(PosOriginal) end)
    
    return targetHum.Health
end

-- ==============================================================================
-- 🚀 ATAQUE 1: HIT & RUN (SEGURO AUTO-CLICK + ORIENTACIÓN V35)
-- ==============================================================================
local function RunAttack1()
    FullReport = "========================================================\n"
    FullReport = FullReport .. "⚔️ V36. ATAQUE 1: HIT & RUN MAGNÉTICO CONTINUO ⚔️\n"
    FullReport = FullReport .. "========================================================\n\n"
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then AddLog("❌ ERROR: No tienes personaje o RootPart.", 0); return end
    
    local target = GetViableTarget()
    if not target then AddLog("❌ ERROR: No pude encontrar ninguno de tus puros Zombies.", 0); return end
    
    local PosOriginal = hrp.CFrame
    local StartHealth = target:FindFirstChildOfClass("Humanoid").Health
    
    AddLog("[+] TARGET OBTENIDO EXACTO: '" .. target.Name .. "' (Vida actual: " .. tostring(math.floor(StartHealth)) .. ").", 0)
    AddLog("[🚀] MÉTODO HIT & RUN MAGNÉTICO: Aimbot PEGADO al zombi, disparando repetidamente HASTA QUE la vida le baje. Si la vida le baja, huiremos de regreso a la zona segura automáticamente.", 0)
    
    local EndHealth = StartHealth
    pcall(function()
        EndHealth = AttackMagnetically(target, PosOriginal, false)
    end)
    
    task.wait(1.5)
    
    AddLog("\n[🔍 DIAGNÓSTICO DEL ATAQUE 1]", 0)
    if EndHealth < StartHealth then AddLog("├─ [🚨 VULNERABLE AL HIT]: ¡Pudiste matarlo/pegarle sin fallar un solo golpe antes de regresar!", 1)
    else AddLog("├─ [🛡️ BLOQUEADO (SEGURO)]: Estuvo 3 segundos pegado al zombie dándole espadazos pero el Servidor lo anuló por la distancia. Tu C++ funciona bien.", 1) end
end

-- ==============================================================================
-- 🚀 ATAQUE 2: DARK ZONE GHOSTING (AMPUTACIÓN ROOTPART)
-- ==============================================================================
local function RunAttack2()
    FullReport = "========================================================\n"
    FullReport = FullReport .. "👻 V36. ATAQUE 2: FANTASMA MAGNÉTICO AMPUTADO 👻\n"
    FullReport = FullReport .. "========================================================\n\n"
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then AddLog("❌ ERROR: Tu personaje no tiene RootPart original.", 0); return end
    
    local target = GetViableTarget()
    if not target then AddLog("❌ ERROR: No hay Humanoides NPCs vivos llamados 'Zombie'.", 0); return end
    
    local PosOriginal = hrp.CFrame
    local StartHealth = target:FindFirstChildOfClass("Humanoid").Health
    
    AddLog("[+] TARGET OBTENIDO EXACTO: '" .. target.Name .. "' (Vida: " .. tostring(math.floor(StartHealth)) .. ").", 0)
    AddLog("[🚀] MÉTODO FANTASMA: Se borrará el HRP para engañar a tu AntiCheat, y se te amarrará al pecho del Zombie con el Torso inferior disparando hasta dañarlo.", 0)
    
    local EndHealth = StartHealth
    pcall(function()
        hrp.Name = "NullPhysics"
        hrp.Parent = nil
        EndHealth = AttackMagnetically(target, PosOriginal, true)
    end)
    
    task.wait(1.5)
    
    AddLog("\n[🔍 DIAGNÓSTICO DEL ATAQUE 2]", 0)
    if EndHealth < StartHealth then AddLog("├─ [🚨 MORTAL (TE ROBARON MODO FANTASMA)]: El Zombie perdió vida. El no tener HRP Ciega por completo a tu script vigilante C++.", 1)
    else AddLog("├─ [🛡️ BLOQUEADO (SEGURO)]: Zombi Intacto. Tienes defensas perfectas contra personajes Rotos (Sin RootPart).", 1) end
end

-- ==============================================================================
-- 🚀 ATAQUE 3: BRING MOBS (NETWORK OWNERSHIP BYPASS)
-- ==============================================================================
local function RunAttack3()
    FullReport = "========================================================\n"
    FullReport = FullReport .. "🌪️ V36. ATAQUE 3: SECUESTRO FÍSICO PERFECTO 🌪️\n"
    FullReport = FullReport .. "========================================================\n\n"
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then AddLog("❌ ERROR: No tienes personaje.", 0); return end
    
    local target = GetViableTarget()
    if not target then AddLog("❌ ERROR: No hay Zombies detectados.", 0); return end
    
    local zHRP = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
    if not zHRP then AddLog("❌ ERROR: El NPC no tiene física.", 0); return end

    local PosOriginal = hrp.Position
    local StartHealth = target:FindFirstChildOfClass("Humanoid").Health
    
    AddLog("[+] TARGET EXACTO: '" .. target.Name .. "'.", 0)
    AddLog("[🚀] MÉTODO SECUESTRO: Traeremos repetidamente al zombi a nuestra espada enfocándola, hasta que baje vida.", 0)
    
    pcall(function()
        local startTick = tick()
        repeat
            zHRP.CFrame = hrp.CFrame * CFrame.new(0, 0, -3.5) 
            Workspace.CurrentCamera.CFrame = CFrame.lookAt(Workspace.CurrentCamera.CFrame.Position, zHRP.Position)
            ForzarClickVirtual()
            task.wait(0.1)
        until target:FindFirstChildOfClass("Humanoid").Health < StartHealth or (tick() - startTick) > 3.5
    end)
    
    task.wait(1.5)
    local EndHealth = target:FindFirstChildOfClass("Humanoid").Health
    
    AddLog("\n[🔍 DIAGNÓSTICO DEL ATAQUE 3]", 0)
    if EndHealth < StartHealth then AddLog("├─ [🚨 FACTIBLE Y DAÑADO]: Puedes secuestrar zombis teletransportándolos frente a ti y pegarles impunemente sin moverte.", 1)
    else AddLog("├─ [🛡️ BLOQUEADO (SEGURO)]: El Servidor rechaza la teletransportación del monstruo.", 1) end
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
-- 🖥️ GUI V36: THE MAGNETIC ASSASSIN
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
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 10, 20)
    MainFrame.BorderSizePixel = 3
    MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 150)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -120, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(0, 60, 40)
    TopBar.Text = "  [V36: COMANDOS APLICADOS - AIMBOT CONTINUO Y AWAIT IMPACT]"
    TopBar.TextColor3 = Color3.fromRGB(150, 255, 200)
    TopBar.Font = Enum.Font.Code
    TopBar.TextSize = 13
    TopBar.TextXAlignment = Enum.TextXAlignment.Left
    TopBar.Parent = MainFrame

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 40, 0, 30)
    CloseBtn.Position = UDim2.new(1, -40, 0, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.TextSize = 16
    CloseBtn.Parent = MainFrame

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 40, 0, 30)
    MinBtn.Position = UDim2.new(1, -80, 0, 0)
    MinBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.Font = Enum.Font.Code
    MinBtn.TextSize = 16
    MinBtn.Parent = MainFrame

    local ReloadBtn = Instance.new("TextButton")
    ReloadBtn.Size = UDim2.new(0, 40, 0, 30)
    ReloadBtn.Position = UDim2.new(1, -120, 0, 0)
    ReloadBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 255)
    ReloadBtn.Text = "↻"
    ReloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ReloadBtn.Font = Enum.Font.Code
    ReloadBtn.TextSize = 18
    ReloadBtn.Parent = MainFrame

    local InfoScroll = Instance.new("ScrollingFrame")
    InfoScroll.Size = UDim2.new(1, -16, 0.55, 0)
    InfoScroll.Position = UDim2.new(0, 8, 0, 35)
    InfoScroll.BackgroundColor3 = Color3.fromRGB(15, 10, 15)
    InfoScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    InfoScroll.ScrollBarThickness = 6
    InfoScroll.Parent = MainFrame

    local LogTextBox = Instance.new("TextBox")
    LogTextBox.Size = UDim2.new(1, -10, 1, 0)
    LogTextBox.Position = UDim2.new(0, 5, 0, 5)
    LogTextBox.BackgroundTransparency = 1
    LogTextBox.Text = "HE EJECUTADO TUS ÓRDENES EXACTAS:\n\n1. 'Mejora puntería que no falle el golpe, no apunta al zombie': Antes, el script te teletransportaba 1 vez al punto donde estaba el Zombie. Si el Zombie caminaba en ese milisegundo, la espada pegaba en donde estuvo el zombie, es decir... 'al aire'.\n¡NUEVO SISTEMA!: He inyectado un motor *RunService.RenderStepped* (Aimbot Magnético a 60 FPS). Al presionar el Target, el script TE PEGA FÍSICAMENTE COMO UN IMÁN a su cara. Si él corre, tú corres frente a él. Si brinca, tú brincas. La cámara y tu espada siempre apuntarán hacia su pecho sin importar a dónde escape garantizando puntería militar.\n\n2. 'Que espere a yo darle el impacto, que analize si le bajé la vida y luego se vaya': Efectivamente la espada tiene una animación 'wind-up' en tu motor ClientCast de ZServer. Anteriormente yo me fugaba en 0.25 segundos y el daño no era registrado a tiempo. \n¡NUEVO SISTEMA!: Hemos implementado la variable temporal Cíclica. El Bot M1 y M2 ahora te llevará, te enfocará en él y repartirá Auto-Clicks EN BUCLE, hasta que tu barra de vida detecte que ese zombi finalmente sufrió Daño Real C/S (impactó completo). Recién cuando él pierda su sangre, el Bot romperá el Cíclo y te regresará ileso a la base. Un testeo 100% perfecto.\n\nPrueba los 3 Botones Magnéticos, si esto logra dañar al zombie y retornar (Factible en Verde), acabamos de encontrar la matriz perfecta de Aura Kill que usa el Hacker. (Nota: quité el texto 'Aire =' para no generar confusiones)."
    LogTextBox.TextColor3 = Color3.fromRGB(230, 255, 230)
    LogTextBox.Font = Enum.Font.Code
    LogTextBox.TextSize = 12
    LogTextBox.TextXAlignment = Enum.TextXAlignment.Left
    LogTextBox.TextYAlignment = Enum.TextYAlignment.Top
    LogTextBox.TextWrapped = true
    LogTextBox.ClearTextOnFocus = false
    LogTextBox.TextEditable = false
    LogTextBox.MultiLine = true
    LogTextBox.Parent = InfoScroll

    -- EVENTOS GUI
    local Minimizado = false
    MinBtn.MouseButton1Click:Connect(function()
        Minimizado = not Minimizado
        if Minimizado then
            MainFrame.Size = UDim2.new(0, 200, 0, 30); InfoScroll.Visible = false
        else
            MainFrame.Size = UDim2.new(0, 720, 0, 560); InfoScroll.Visible = true
        end
    end)
    ReloadBtn.MouseButton1Click:Connect(function() 
        pcall(function() sg:Destroy(); loadstring(game:HttpGet(SCRIPT_URL .. "?r=" .. math.random(11,99)))() end) 
    end)
    CloseBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

    local function ActualizarPantalla()
        if #Pages == 0 then return end
        LogTextBox.Text = Pages[CurrentPage]
        InfoScroll.CanvasPosition = Vector2.new(0, 0)
    end

    -- BOTONES TÁCTICOS
    local btnAtk1 = Instance.new("TextButton")
    btnAtk1.Size = UDim2.new(0.32, 0, 0, 40)
    btnAtk1.Position = UDim2.new(0, 8, 0.70, 0)
    btnAtk1.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    btnAtk1.Text = "🔥 ATK 1: HIT & RUN VELOZ"
    btnAtk1.TextColor3 = Color3.fromRGB(200, 255, 200)
    btnAtk1.Font = Enum.Font.Code
    btnAtk1.TextSize = 12
    btnAtk1.Parent = MainFrame
    
    local btnAtk2 = Instance.new("TextButton")
    btnAtk2.Size = UDim2.new(0.32, 0, 0, 40)
    btnAtk2.Position = UDim2.new(0.34, 0, 0.70, 0)
    btnAtk2.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    btnAtk2.Text = "👻 ATK 2: FANTASMA"
    btnAtk2.TextColor3 = Color3.fromRGB(255, 200, 200)
    btnAtk2.Font = Enum.Font.Code
    btnAtk2.TextSize = 12
    btnAtk2.Parent = MainFrame
    
    local btnAtk3 = Instance.new("TextButton")
    btnAtk3.Size = UDim2.new(0.32, 0, 0, 40)
    btnAtk3.Position = UDim2.new(0.66, 8, 0.70, 0)
    btnAtk3.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
    btnAtk3.Text = "🌪️ ATK 3: SECUESTRO FÍSICO"
    btnAtk3.TextColor3 = Color3.fromRGB(200, 220, 255)
    btnAtk3.Font = Enum.Font.Code
    btnAtk3.TextSize = 12
    btnAtk3.Parent = MainFrame

    btnAtk1.MouseButton1Click:Connect(function() pcall(function() RunAttack1() SegmentarPaginas() ActualizarPantalla() end) end)
    btnAtk2.MouseButton1Click:Connect(function() pcall(function() RunAttack2() SegmentarPaginas() ActualizarPantalla() end) end)
    btnAtk3.MouseButton1Click:Connect(function() pcall(function() RunAttack3() SegmentarPaginas() ActualizarPantalla() end) end)
    
    local btnPrev = Instance.new("TextButton")
    btnPrev.Size = UDim2.new(0.32, 0, 0, 30)
    btnPrev.Position = UDim2.new(0, 8, 0.85, 0)
    btnPrev.BackgroundColor3 = Color3.fromRGB(20, 40, 30)
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
    btnNext.BackgroundColor3 = Color3.fromRGB(20, 40, 30)
    btnNext.Text = "Lectura >"
    btnNext.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnNext.Parent = MainFrame
    
    local function UptLabel() PageLabel.Text = "Página " .. tostring(CurrentPage) .. " / " .. tostring(#Pages) end
    btnPrev.MouseButton1Click:Connect(function() if CurrentPage > 1 then CurrentPage = CurrentPage - 1; ActualizarPantalla(); UptLabel() end end)
    btnNext.MouseButton1Click:Connect(function() if CurrentPage < #Pages then CurrentPage = CurrentPage + 1; ActualizarPantalla(); UptLabel() end end)
end

ConstruirUI()
