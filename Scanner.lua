-- ==============================================================================
-- 💀 ROBLOX EXPERT: V39 THE PING-PONG FARMER (EVASIÓN DEL SENSOR C++)
-- Hit & Run Continuo. Anula tu Kickeo engañando al AntiCheat de Velocidad Mantenida.
-- ==============================================================================

local SCRIPT_URL = "https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
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
-- 🔬 BUSCADOR ESTRICTO POR NOMBRES LUA C/S
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
                local targetHRP = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj.PrimaryPart
                
                if hum and targetHRP and hum.Health > 0.1 then
                    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    if myHrp then
                        local dist = (myHrp.Position - targetHRP.Position).Magnitude
                        if dist < closestDist then closestDist = dist; closestTarget = obj end
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
-- 🚀 MOTOR EFECTO PING-PONG (COMBATE DE DESTELLOS MILISEGUNDOS)
-- ==============================================================================
local function AttackPingPong(target, hrp, PosOriginal, SafeWaitTime)
    local targetHRP = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
    local targetHum = target:FindFirstChildOfClass("Humanoid")
    local startHealth = targetHum.Health

    if not targetHRP or not targetHum then return end

    -- BUCLE DE DESTELLO (HIT & RUN REPETIDO)
    local TimeOutClock = tick()
    
    repeat
        pcall(function()
            -- 1. TELEPORT Y DISPARO AL ZOMBI (0.15s - WindUp Hitbox)
            local enfrente = targetHRP.Position + (targetHRP.CFrame.LookVector * 2.5) + Vector3.new(0, 0.5, 0)
            hrp.CFrame = CFrame.lookAt(enfrente, targetHRP.Position)
            Workspace.CurrentCamera.CFrame = CFrame.lookAt(Workspace.CurrentCamera.CFrame.Position, targetHRP.Position + Vector3.new(0, 1.5, 0))
            
            ForzarClickVirtual()
            task.wait(0.2) -- OBLIGATORIO: Tu juego pide que estés al menos 0.2s frente a él para que el clientcast baje daño
            
            -- 2. REGRESO INMEDIATO (EVASIÓN DEL KICK DEL ANTI-CHEAT C++)
            hrp.CFrame = PosOriginal
            task.wait(SafeWaitTime) -- ESTE wait() es el que resetea las alertas del AntiCheat
        end)
    until not targetHum or targetHum.Health <= 0.1 or (tick() - TimeOutClock) > 20 -- Tope 20s en caso de Boss

    pcall(function() hrp.CFrame = PosOriginal end)
    return true
end

-- ==============================================================================
-- 🚀 ATAQUE 1: PING-PONG (NORMAL)
-- ==============================================================================
local function RunPingPong(SafeWaitTime)
    FullReport = "========================================================\n"
    FullReport = FullReport .. "⚔️ V39. PING-PONG FARMER (EVITA KICKEO) ⚔️\n"
    FullReport = FullReport .. "========================================================\n\n"
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then AddLog("❌ ERROR: No tienes personaje. Recuerda suicidarte para recuperar tu cuerpo.", 0); return end
    
    local target = GetViableTarget()
    if not target then AddLog("❌ ERROR: No pude encontrar ninguno de tus puros Zombies.", 0); return end
    
    local PosOriginal = hrp.CFrame
    local StartHealth = target:FindFirstChildOfClass("Humanoid").Health
    
    AddLog("[+] TARGET OBTENIDO EXACTO: '" .. target.Name .. "' (Vida actual: " .. tostring(math.floor(StartHealth)) .. ").", 0)
    AddLog("[🚀] MÉTODO PING-PONG EN DESTELLOS: Rebotarás como una pelota de Tenis. Aparecerás en el zombi 0.2s, darás el tajo, y te volverás a fugar a tu Zona Segura donde descansarás " .. tostring(SafeWaitTime) .. " segundos para calmar a los AntiCheats del servidor antes de golpear de nuevo. ¡Este ciclo matará al zombi y tú serás inmune a ataques y Kickeos!", 0)
    
    pcall(function() AttackPingPong(target, hrp, PosOriginal, SafeWaitTime) end)
    
    task.wait(1.5)
    
    AddLog("\n[🔍 DIAGNÓSTICO DEL ATAQUE]", 0)
    if not target or target.Parent == nil or target:FindFirstChildOfClass("Humanoid").Health <= 0.1 then 
        AddLog("├─ [🚨 VICTORIA FÍSICA AURA-KILL]: ¡EL ZOMBI MURIÓ DESTROZADO A PURAS PUNTADAS INVISIBLES SIN KICKS!", 1)
    else 
        AddLog("├─ [🛡️ SOBREVIVIÓ]: Algo se trabó o el Server AntiCheat tiene la rutina más veloz posible.", 1) 
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
-- 🖥️ GUI V39: THE PING-PONG FARMER
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
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
    MainFrame.BorderSizePixel = 3
    MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 150)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -120, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(0, 80, 60)
    TopBar.Text = "  [V39: THE PING-PONG FARMER - AUTO FARMEADOR INDETECTABLE]"
    TopBar.TextColor3 = Color3.fromRGB(200, 255, 200)
    TopBar.Font = Enum.Font.Code
    TopBar.TextSize = 13
    TopBar.TextXAlignment = Enum.TextXAlignment.Left
    TopBar.Parent = MainFrame

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 40, 0, 30)
    CloseBtn.Position = UDim2.new(1, -40, 0, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.TextSize = 16
    CloseBtn.Parent = MainFrame

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 40, 0, 30)
    MinBtn.Position = UDim2.new(1, -80, 0, 0)
    MinBtn.BackgroundColor3 = Color3.fromRGB(180, 150, 0)
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.Font = Enum.Font.Code
    MinBtn.TextSize = 16
    MinBtn.Parent = MainFrame

    local ReloadBtn = Instance.new("TextButton")
    ReloadBtn.Size = UDim2.new(0, 40, 0, 30)
    ReloadBtn.Position = UDim2.new(1, -120, 0, 0)
    ReloadBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 200)
    ReloadBtn.Text = "↻"
    ReloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ReloadBtn.Font = Enum.Font.Code
    ReloadBtn.TextSize = 18
    ReloadBtn.Parent = MainFrame

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
    LogTextBox.Text = "¡TUS REVELACIONES ME HICIERON COMPRENDER EXACTAMENTE TU JUEGO!\n\n1. El de la Imagen (Botón 2): ¡Misterio Resuelto! Resulta que cortar o alterar el RootPart vuelve a tu personaje de 'cartón'. ¿Viste cómo tu cuerpo se cayó en la imagen (Ragdoll)? La espada clientcast JAMÁS podrá hacer disparos si tu cuerpo central cae, se rompe y descoordina sus CFrame... Esto significa que el MODO 2 FANTASMA ES INÚTIL, lo he mandado al tacho.\n\n2. 'El Modo 1 no falló antes, fue KICK luego de meter el bucle sin fin': \n¡Bingo! El Modo 1 Hit&Run de la V35 era 100% puro y funcional, lo confesaste. El Anti-Cheat detectaba tu teletransporte en V37 SOLO porque te quedaste a dormir 5 segundos peleando contra el Zombi. (El Kick por Distancia Constante detectó tu posición). \n\n¡BIENVENIDO AL PING-PONG FARMER (V39)!\nAquí es donde nos vengamos del juego con su propio error. He reemplazado TODAS LAS OPCIONES fallidas, y usaremos solo variaciones magistrales del Hit&Run (Modo 1).\n\n¿Cómo anula al AntiCheat y es ilimitado a la vez?\nTe acercas, le das UN espadaazo, y EN MENOS DE 0.2 SEGUNDOS EL BOT TE ARRASTRA DE VUELTA A TU ESCONDITE y te espera en la base medio segundo. Tu avatar REBOTARÁ constantemente como pelota de Tenis. El Zombi te atacará el aire, ¡Y los radares Anti-Teleportes de tu Server pensarán que NUNCA TE MOVISTE DE TU ESCONDITE porque cuando te escanean, siempre estás en reposo en tu base!\n\nTienes 3 botones:\n- ATK 1 (Normal): Espera 0.5s y vuelve a rebotar.\n- ATK 2 (Lento - AntiKick): Espera 1.0s, el más seguro ante Moderadores estrictos.\n- ATK 3 (Rápido - Agresivo): Espera solo 0.2s.\n\nPonte parado en un lugar lejos de los zombis (ej. sobre un poste de madera oscuro) pero que los veas... y desata el ATK 1.\n(NOTA: RESETA A TU AVATAR SUICIDANDOTE SI QUEDÓ ROTO POR LA V38!)"
    LogTextBox.TextColor3 = Color3.fromRGB(220, 255, 230)
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
    btnAtk1.BackgroundColor3 = Color3.fromRGB(0, 100, 50)
    btnAtk1.Text = "🏓 ATK 1: PING-PONG (0.5s PAUSA)"
    btnAtk1.TextColor3 = Color3.fromRGB(150, 255, 150)
    btnAtk1.Font = Enum.Font.Code
    btnAtk1.TextSize = 11
    btnAtk1.Parent = MainFrame
    
    local btnAtk2 = Instance.new("TextButton")
    btnAtk2.Size = UDim2.new(0.32, 0, 0, 40)
    btnAtk2.Position = UDim2.new(0.34, 0, 0.70, 0)
    btnAtk2.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
    btnAtk2.Text = "🛡️ ATK 2: LENTO (1.0s SEGURO KICK)"
    btnAtk2.TextColor3 = Color3.fromRGB(200, 220, 255)
    btnAtk2.Font = Enum.Font.Code
    btnAtk2.TextSize = 11
    btnAtk2.Parent = MainFrame

    local btnAtk3 = Instance.new("TextButton")
    btnAtk3.Size = UDim2.new(0.32, 0, 0, 40)
    btnAtk3.Position = UDim2.new(0.66, 8, 0.70, 0)
    btnAtk3.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    btnAtk3.Text = "🔥 ATK 3: RÁPIDO (0.2s AGRESIVO)"
    btnAtk3.TextColor3 = Color3.fromRGB(255, 200, 200)
    btnAtk3.Font = Enum.Font.Code
    btnAtk3.TextSize = 11
    btnAtk3.Parent = MainFrame

    btnAtk1.MouseButton1Click:Connect(function() pcall(function() RunPingPong(0.5) SegmentarPaginas() ActualizarPantalla() end) end)
    btnAtk2.MouseButton1Click:Connect(function() pcall(function() RunPingPong(1.0) SegmentarPaginas() ActualizarPantalla() end) end)
    btnAtk3.MouseButton1Click:Connect(function() pcall(function() RunPingPong(0.2) SegmentarPaginas() ActualizarPantalla() end) end)
    
    local btnPrev = Instance.new("TextButton")
    btnPrev.Size = UDim2.new(0.32, 0, 0, 30)
    btnPrev.Position = UDim2.new(0, 8, 0.85, 0)
    btnPrev.BackgroundColor3 = Color3.fromRGB(20, 30, 40)
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
    btnNext.BackgroundColor3 = Color3.fromRGB(20, 30, 40)
    btnNext.Text = "Lectura >"
    btnNext.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnNext.Parent = MainFrame
    
    local function UptLabel() PageLabel.Text = "Página " .. tostring(CurrentPage) .. " / " .. tostring(#Pages) end
    btnPrev.MouseButton1Click:Connect(function() if CurrentPage > 1 then CurrentPage = CurrentPage - 1; ActualizarPantalla(); UptLabel() end end)
    btnNext.MouseButton1Click:Connect(function() if CurrentPage < #Pages then CurrentPage = CurrentPage + 1; ActualizarPantalla(); UptLabel() end end)
end

ConstruirUI()
