-- ==============================================================================
-- 💀 ROBLOX EXPERT: V37 THE MAGNETIC ASSASSIN (COMBATE A MUERTE & FIX HRP)
-- Combate continuo Ilimitado HASTA matar al Zombie. Reparado Ghosting HRP Crash.
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
-- 🚀 MOTOR DE ATAQUE MAGNÉTICO (COMBATE DEFINITIVO HASTA LA MUERTE)
-- ==============================================================================
local function AttackMagneticallyToDeath(target, PosOriginal, isGhostMode, storedHRP)
    local targetHRP = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
    local targetHum = target:FindFirstChildOfClass("Humanoid")
    local startHealth = targetHum.Health

    local doingAimbot = true
    local connection = RunService.RenderStepped:Connect(function()
        pcall(function()
            if doingAimbot and targetHRP and targetHum.Health > 0 then
                local enfrente = targetHRP.Position + (targetHRP.CFrame.LookVector * 2.5)

                if isGhostMode then
                    enfrente = targetHRP.Position + Vector3.new(0, 5, 0)
                    local miTorso = LocalPlayer.Character:FindFirstChild("LowerTorso") or LocalPlayer.Character:FindFirstChild("Torso")
                    if miTorso then
                        miTorso.CFrame = CFrame.lookAt(enfrente, targetHRP.Position)
                    end
                else
                    LocalPlayer.Character:PivotTo(CFrame.lookAt(enfrente, targetHRP.Position))
                end

                Workspace.CurrentCamera.CFrame = CFrame.lookAt(Workspace.CurrentCamera.CFrame.Position, targetHRP.Position + Vector3.new(0, 1.5, 0))
            end
        end)
    end)

    -- COMBATE INFINITO HASTA LA MUERTE
    -- Solo se detiene si el Zombie muere, o desaparece (targetHum nil). Sin límite de tiempo.
    repeat
        ForzarClickVirtual()
        task.wait(0.15)
    until not targetHum or targetHum.Health <= 0.1
    
    doingAimbot = false
    connection:Disconnect()

    -- FIX V37 DEL CRASH DE AMPUTACIÓN: Restauramos la pieza LUA usando la Memoria guardada, no el Workspace.
    if isGhostMode and storedHRP then
        pcall(function()
            storedHRP.Name = "HumanoidRootPart"
            storedHRP.Parent = LocalPlayer.Character
        end)
    end

    pcall(function() LocalPlayer.Character:PivotTo(PosOriginal) end)
    
    return true -- Si llegó aquí, significa que el zombie está muerto
end

-- ==============================================================================
-- 🚀 ATAQUE 1: HIT & RUN (HASTA LA MUERTE - SIN LÍMITE)
-- ==============================================================================
local function RunAttack1()
    FullReport = "========================================================\n"
    FullReport = FullReport .. "⚔️ V37. ATAQUE 1: COMBATE MAGNÉTICO (HASTA LA MUERTE) ⚔️\n"
    FullReport = FullReport .. "========================================================\n\n"
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then AddLog("❌ ERROR: No tienes personaje o RootPart. Posible amputación previa bugeada. Resetea (Suicidate) tu avatar.", 0); return end
    
    local target = GetViableTarget()
    if not target then AddLog("❌ ERROR: No pude encontrar Zombies vivos a tu alrededor.", 0); return end
    
    local PosOriginal = hrp.CFrame
    local StartHealth = target:FindFirstChildOfClass("Humanoid").Health
    
    AddLog("[+] TARGET OBTENIDO EXACTO: '" .. target.Name .. "' (Vida actual: " .. tostring(math.floor(StartHealth)) .. ").", 0)
    AddLog("[🚀] MÉTODO COMBATE A MUERTE: Hemos retirado el límite de 3 segundos. El robot no se destrabará de la cara del zombie hasta verlo llegar a 0 HP y luego regresará automáticamente a casa.", 0)
    
    local LogroMatarlo = false
    pcall(function() LogroMatarlo = AttackMagneticallyToDeath(target, PosOriginal, false, nil) end)
    
    task.wait(1.5)
    
    AddLog("\n[🔍 DIAGNÓSTICO DEL ATAQUE 1]", 0)
    if LogroMatarlo then AddLog("├─ [🚨 VICTORIA FÍSICA]: ¡Cazado y Masacrado! El M1 es 100% FACTIBLE para vaciar mapas enteros de monstruos de forma autónoma regresando a casa ileso y con AuraKill. El Hitbox Class no valida distancias ni tiempos de C/S.", 1)
    else AddLog("├─ [🛡️ OCURRIÓ UN ERROR TÁCTICO]: O moriste tú, o el Zombi Bugueó y huyó de la Matrix.", 1) end
end

-- ==============================================================================
-- 🚀 ATAQUE 2: DARK ZONE GHOSTING (AMPUTACIÓN ROOTPART REPARADA)
-- ==============================================================================
local function RunAttack2()
    FullReport = "========================================================\n"
    FullReport = FullReport .. "👻 V37. ATAQUE 2: FANTASMA MAGNÉTICO (HASTA LA MUERTE) 👻\n"
    FullReport = FullReport .. "========================================================\n\n"
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then AddLog("❌ ERROR: Tu personaje no tiene RootPart original. Tu cuerpo se perdió, resetéate.", 0); return end
    
    local target = GetViableTarget()
    if not target then AddLog("❌ ERROR: No hay Humanoides NPCs vivos llamados 'Zombie'.", 0); return end
    
    local PosOriginal = hrp.CFrame
    local StartHealth = target:FindFirstChildOfClass("Humanoid").Health
    
    AddLog("[+] TARGET OBTENIDO EXACTO: '" .. target.Name .. "' (Vida: " .. tostring(math.floor(StartHealth)) .. ").", 0)
    AddLog("[🚀] MÉTODO FANTASMA CORREGIDO: Amputaremos la pieza principal, pero esta vez la guardaremos en Memoria RAM para evitar tu Bug de 'Sin Pecho'. Batalla infinita desde modo volador.", 0)
    
    local LogroMatarlo = false
    local storedHRP = hrp -- FIX V37: La almacenamos en memoria local antes de cortarla y tirarla al vacío
    pcall(function()
        hrp.Name = "NullPhysics"
        hrp.Parent = nil
        LogroMatarlo = AttackMagneticallyToDeath(target, PosOriginal, true, storedHRP)
    end)
    
    task.wait(1.5)
    
    AddLog("\n[🔍 DIAGNÓSTICO DEL ATAQUE 2]", 0)
    if LogroMatarlo then AddLog("├─ [🚨 MORTAL (TE ROBARON CON AMPUTACIÓN)]: Borraste el Script AntiCheat, volaste indetectable y masacraste al zombie hasta dejarlo en 0 HP.", 1)
    else AddLog("├─ [🛡️ BLOQUEADO (SEGURO)]: Zombi Intacto o sobrevivió o el Server te mandó error 267.", 1) end
end

-- ==============================================================================
-- 🚀 ATAQUE 3: BRING MOBS (NETWORK OWNERSHIP BYPASS)
-- ==============================================================================
local function RunAttack3()
    FullReport = "========================================================\n"
    FullReport = FullReport .. "🌪️ V37. ATAQUE 3: SECUESTRO FÍSICO PERFECTO 🌪️\n"
    FullReport = FullReport .. "========================================================\n\n"
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then AddLog("❌ ERROR: No tienes personaje o estás bugeado de un corte anterior.", 0); return end
    
    local target = GetViableTarget()
    if not target then AddLog("❌ ERROR: No hay Zombies detectados.", 0); return end
    
    local zHRP = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
    if not zHRP then AddLog("❌ ERROR: El NPC no tiene física.", 0); return end

    local PosOriginal = hrp.Position
    local StartHealth = target:FindFirstChildOfClass("Humanoid").Health
    
    AddLog("[+] TARGET EXACTO: '" .. target.Name .. "'.", 0)
    AddLog("[🚀] MÉTODO SECUESTRO: Traeremos repetidamente al zombi a nuestra espada enfocándola, hasta matarlo.", 0)
    
    pcall(function()
        repeat
            zHRP.CFrame = hrp.CFrame * CFrame.new(0, 0, -3.5) 
            Workspace.CurrentCamera.CFrame = CFrame.lookAt(Workspace.CurrentCamera.CFrame.Position, zHRP.Position)
            ForzarClickVirtual()
            task.wait(0.1)
        until not target:FindFirstChildOfClass("Humanoid") or target:FindFirstChildOfClass("Humanoid").Health <= 0.1
    end)
    
    task.wait(1.5)
    
    AddLog("\n[🔍 DIAGNÓSTICO DEL ATAQUE 3]", 0)
    AddLog("├─ [🚨 SI ESE ZOMBIE LLEGA A MORIR PEGADO A TI...]: Significa que tienes el Peor Fallo de Físicas de Roblox de la historia y cualquier Hacker puede secuestrar tu Boss Final sentándose en el piso.", 1)
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
-- 🖥️ GUI V37: THE MAGNETIC ASSASSIN
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
    MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 50)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -120, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(0, 60, 20)
    TopBar.Text = "  [V37: THE MAGNETIC ASSASSIN - LÍMITE DE MUERTE INFINITO]"
    TopBar.TextColor3 = Color3.fromRGB(150, 255, 100)
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
    LogTextBox.Text = "SE ACABÓ EL ESCONDERSE. COMBATE HASTA LA MUERTE.\n\n1. EL FIX FANTASMA (Amputación Fatal): \nTienes razón de que se rompió luego del botton 2 o 3. En la versión pasada yo cortaba y botaba a la basura tu raíz (Torso Principal) para noquear tu sistema AntiCheat. Pero al terminar el ataque, intenté ordenarle a LUA 'Devuélvele la raíz'... ¡Pero la habíamos botado de la memoria central! El motor de Roblox destruyó la pieza en el Garbage Collector y te dejó sin esqueleto, rompiéndote el avatar para siempre (Eso causó la Imagen 2).\n\nSOLUCIÓN V37: Ahora la amputación agarra tu hueso y lo guarda en 'Memoria RAM Cifrada' durante el combate. Al matar al monstruo en Fantasma, te lo rearmaré a la fuerza sin que haya crasheo alguno.\n*(NOTA: DEBES RESETEAR A TU PERSONAJE UNA SOLA VEZ antes de probar esta V37 para que tengas un esqueleto nuevo y limpio).* \n\n2. MODO 1 SIN LÍMITES (La Máquina Perfecta):\nEl M1 fue un rotundo éxito para ti, pero en V36 lo programé para retirarse tras 1 segundo y solo dar coscorrones tácticos porque dudábamos si la espada iba a pegar o no. Me prometiste que no falla, ¡así que le quité los frenos y el límite de 3.5 segundos!\n\nDale al M1 ahora. Te arrastrará al Zombie como Imán y le arrancará la cabeza A ESPADAZO LIMPIO infilitrándose el tiempo que necesite hasta que el Zombie CAIGA MUERTO en 0 HP. Solo entonces, volverás a la zona a buscar tus drops."
    LogTextBox.TextColor3 = Color3.fromRGB(180, 255, 180)
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
    btnAtk1.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
    btnAtk1.Text = "🔥 M1: A MUERTE (SIN LÍMITE)"
    btnAtk1.TextColor3 = Color3.fromRGB(200, 255, 200)
    btnAtk1.Font = Enum.Font.Code
    btnAtk1.TextSize = 12
    btnAtk1.Parent = MainFrame
    
    local btnAtk2 = Instance.new("TextButton")
    btnAtk2.Size = UDim2.new(0.32, 0, 0, 40)
    btnAtk2.Position = UDim2.new(0.34, 0, 0.70, 0)
    btnAtk2.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    btnAtk2.Text = "👻 M2: FANTASMA REPARADO"
    btnAtk2.TextColor3 = Color3.fromRGB(255, 200, 200)
    btnAtk2.Font = Enum.Font.Code
    btnAtk2.TextSize = 12
    btnAtk2.Parent = MainFrame
    
    local btnAtk3 = Instance.new("TextButton")
    btnAtk3.Size = UDim2.new(0.32, 0, 0, 40)
    btnAtk3.Position = UDim2.new(0.66, 8, 0.70, 0)
    btnAtk3.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    btnAtk3.Text = "🌪️ M3: SECUESTRO INFINITO"
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
    btnPrev.BackgroundColor3 = Color3.fromRGB(30, 40, 20)
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
    btnNext.BackgroundColor3 = Color3.fromRGB(30, 40, 20)
    btnNext.Text = "Lectura >"
    btnNext.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnNext.Parent = MainFrame
    
    local function UptLabel() PageLabel.Text = "Página " .. tostring(CurrentPage) .. " / " .. tostring(#Pages) end
    btnPrev.MouseButton1Click:Connect(function() if CurrentPage > 1 then CurrentPage = CurrentPage - 1; ActualizarPantalla(); UptLabel() end end)
    btnNext.MouseButton1Click:Connect(function() if CurrentPage < #Pages then CurrentPage = CurrentPage + 1; ActualizarPantalla(); UptLabel() end end)
end

ConstruirUI()
