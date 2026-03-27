-- ==============================================================================
-- 💀 ROBLOX EXPERT: V33 THE AUTO-TRIGGER FIX (REPARACIÓN DE INTERFAZ Y CLICK)
-- Reparación de la V32. El Botón 3. VirtualUser Inyectado y TopBar restaurada.
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
-- 🔬 BUSCADOR E INYECTOR DE GATILLO VIRTUAL (FIX PARA ESPADAS CLIENTCAST)
-- ==============================================================================
local function GetViableTarget()
    local myChar = LocalPlayer.Character
    local closestTarget = nil
    local closestDist = math.huge
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Model") and obj ~= myChar and not Players:GetPlayerFromCharacter(obj) then
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
    -- Este método ignora 'Tool:Activate()' y emula un Tapping Físico 
    -- en la pantalla del Android/PC para despertar al UserInputService de tu espada.
    pcall(function()
        VirtualUser:Button1Down(Vector2.new(0,0))
        task.wait(0.02)
        VirtualUser:Button1Up(Vector2.new(0,0))
    end)
    pcall(function()
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.02)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end)
    -- Además nos aseguramos de que el HitboxClassRemote intente forzarse por las dudas
    pcall(function() ReplicatedStorage.HitboxClassRemote:FireServer("Hit") end)
end

-- ==============================================================================
-- 🚀 ATAQUE 1: HIT & RUN (MICRO-TELEPORTACIÓN RÁPIDA)
-- ==============================================================================
local function RunAttack1()
    FullReport = "========================================================\n"
    FullReport = FullReport .. "⚔️ V33. ATAQUE 1: HIT & RUN (SEGURO AUTO-CLICK) ⚔️\n"
    FullReport = FullReport .. "========================================================\n\n"
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then AddLog("❌ ERROR: No tienes personaje o RootPart.", 0); return end
    
    local target = GetViableTarget()
    if not target then AddLog("❌ ERROR: Literalmente no existen Modelos con Humanoides vivos.", 0); return end
    
    local PosOriginal = hrp.Position
    local StartHealth = target:FindFirstChildOfClass("Humanoid").Health
    
    AddLog("[+] TARGET OBTENIDO: '" .. target.Name .. "' (Vida: " .. tostring(math.floor(StartHealth)) .. ").", 0)
    AddLog("[🚀] MÉTODO HIT & RUN: Teletransporte -> Virtual Click Sincronizado -> Regreso CFrame.", 0)
    
    pcall(function()
        local targetHRP = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
        if not targetHRP then return end
        
        for i=1, 4 do
            char:PivotTo(targetHRP.CFrame * CFrame.new(0, 0, 3))
            task.wait(0.05) -- Pausa microscópica para que cargue la HitRays del ClientCast
            ForzarClickVirtual()
            task.wait(0.15)
            char:PivotTo(CFrame.new(PosOriginal))
            task.wait(0.5) 
        end
    end)
    
    task.wait(1.5)
    local EndHealth = target:FindFirstChildOfClass("Humanoid").Health
    
    AddLog("\n[🔍 DIAGNÓSTICO DEL ATAQUE 1]", 0)
    if EndHealth < StartHealth then AddLog("├─ [🚨 FACTIBLE (VULNERABLE)]: Afectaste su HP (-" .. tostring(math.floor(StartHealth - EndHealth)) .. ").", 1)
    else AddLog("├─ [🛡️ BLOQUEADO (SEGURO)]: El NPC sigue integro.", 1) end
end

-- ==============================================================================
-- 🚀 ATAQUE 2: DARK ZONE GHOSTING (AMPUTACIÓN ROOTPART)
-- ==============================================================================
local function RunAttack2()
    FullReport = "========================================================\n"
    FullReport = FullReport .. "👻 V33. ATAQUE 2: ZONA OSCURA GHOSTING (SEGURO AUTO-CLICK) 👻\n"
    FullReport = FullReport .. "========================================================\n\n"
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then AddLog("❌ ERROR: Tu personaje no tiene RootPart original.", 0); return end
    
    local target = GetViableTarget()
    if not target then AddLog("❌ ERROR: No hay Humanoides NPCs vivos.", 0); return end
    
    local PosOriginal = hrp.Position
    local StartHealth = target:FindFirstChildOfClass("Humanoid").Health
    local SafeZone = PosOriginal + Vector3.new(0, 1500, 0)
    
    AddLog("[+] TARGET OBTENIDO: '" .. target.Name .. "' (Vida: " .. tostring(math.floor(StartHealth)) .. ").", 0)
    AddLog("[🚀] MÉTODO GHOST: Subimos 1500 Studs -> Amputamos HRP para Anular 267 -> Bajamos a Pegar con Virtual Click.", 0)
    
    pcall(function()
        hrp.Name = "NullPhysics"
        hrp.Parent = nil
        local torso = char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso")
        if not torso then return end
        
        torso.CFrame = CFrame.new(SafeZone)
        task.wait(0.5)
        
        local targetHRP = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
        if not targetHRP then return end

        for i=1, 4 do
            torso.CFrame = targetHRP.CFrame * CFrame.new(0, 4, 0)
            task.wait(0.1)
            ForzarClickVirtual()
            task.wait(0.2)
            torso.CFrame = CFrame.new(SafeZone)
            task.wait(0.5)
        end
        
        pcall(function() hrp.Parent = char; hrp.Name = "HumanoidRootPart" end)
        pcall(function() char:PivotTo(CFrame.new(PosOriginal)) end)
    end)
    
    task.wait(1.5)
    local EndHealth = target:FindFirstChildOfClass("Humanoid").Health
    
    AddLog("\n[🔍 DIAGNÓSTICO DEL ATAQUE 2]", 0)
    if EndHealth < StartHealth then AddLog("├─ [🚨 FACTIBLE MORTAL]: HP del NPC dañado desde el Modo Fantasma silencioso sin HRP.", 1)
    else AddLog("├─ [🛡️ BLOQUEADO (SEGURO)]: NPC Intacto. El Servidor anula o no escucha clicks de cuerpos Rotos.", 1) end
end

-- ==============================================================================
-- 🚀 ATAQUE 3: BRING MOBS (NETWORK OWNERSHIP BYPASS)
-- ==============================================================================
local function RunAttack3()
    FullReport = "========================================================\n"
    FullReport = FullReport .. "🌪️ V33. ATAQUE 3: SECUESTRO FÍSICO (SEGURO AUTO-CLICK) 🌪️\n"
    FullReport = FullReport .. "========================================================\n\n"
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then AddLog("❌ ERROR: No tienes personaje.", 0); return end
    
    local target = GetViableTarget()
    if not target then AddLog("❌ ERROR: No hay NPCs vivos.", 0); return end
    
    local zHRP = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
    if not zHRP then AddLog("❌ ERROR: El NPC no tiene física.", 0); return end

    local PosOriginal = hrp.Position
    local StartHealth = target:FindFirstChildOfClass("Humanoid").Health
    
    AddLog("[+] TARGET: '" .. target.Name .. "'.", 0)
    AddLog("[🚀] MÉTODO SECUESTRO: Teletransportamos al Zombi hacia nuestra Espada y le damos Clicks Virtuales.", 0)
    
    pcall(function()
        task.spawn(function()
            for i=1, 40 do
                if not target or not zHRP or not hrp then break end
                zHRP.CFrame = hrp.CFrame * CFrame.new(0, 0, -3.5) 
                task.wait(0.05)
            end
        end)
        
        task.wait(0.3)
        for i=1, 5 do ForzarClickVirtual(); task.wait(0.3) end
    end)
    
    task.wait(1.5)
    local EndHealth = target:FindFirstChildOfClass("Humanoid").Health
    
    AddLog("\n[🔍 DIAGNÓSTICO DEL ATAQUE 3]", 0)
    if EndHealth < StartHealth then AddLog("├─ [🚨 FACTIBLE Y DAÑADO]: Le quitaste " .. tostring(math.floor(StartHealth - EndHealth)) .. " HP trayéndolo mágicamente hacia ti.", 1)
    else AddLog("├─ [🛡️ BLOQUEADO (SEGURO)]: El Target esquivó el robo Network o el Servidor anuló los disparos.", 1) end
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
-- 🖥️ GUI V33: THE ANTI-CHEAT BREAKER UI FIX
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
    MainFrame.BorderColor3 = Color3.fromRGB(20, 200, 100)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -120, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(0, 80, 50)
    TopBar.Text = "  [V33: REPARACIÓN GUI & AUTO-CLICK VIRTUAL]"
    TopBar.TextColor3 = Color3.fromRGB(150, 255, 200)
    TopBar.Font = Enum.Font.Code
    TopBar.TextSize = 13
    TopBar.TextXAlignment = Enum.TextXAlignment.Left
    TopBar.Parent = MainFrame

    -- FIX GUI CONTROLS
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
    MinBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.Font = Enum.Font.Code
    MinBtn.TextSize = 16
    MinBtn.Parent = MainFrame

    local ReloadBtn = Instance.new("TextButton")
    ReloadBtn.Size = UDim2.new(0, 40, 0, 30)
    ReloadBtn.Position = UDim2.new(1, -120, 0, 0)
    ReloadBtn.BackgroundColor3 = Color3.fromRGB(20, 100, 200)
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
    LogTextBox.Text = "¡REPARACIÓN TÁCTICA V33 EJECUTADA!\n\nRegaño Aceptado: Los botones de Minimizar, Cerrar y Refrescar de la barra superior han sido completamente reestablecidos bajo la estructura OmniTracker Original.\n\nEL VERDADERO PROBLEMA IDENTIFICADO:\nTienes toda la razón en tu observación visual: 'El script va al zombie pero la espada no se está moviendo'.\nEn la V32, utilicé `Tool:Activate()`. Muchos Combates ClientCast (y el tuyo) IGNORAN ese comando porque programaste UserInputService para que la espada solo haga swing cuando dejas apretada la pantalla / mouse físico real. Si la espada no baila, el Hitbox nunca envía el daño al servidor e imposibilita la prueba engañándonos con [Seguro].\n\nNUEVO MOTOR DE ATAQUE:\nHe inyectado la Api de `VirtualUser` y `VirtualInputManager`. El Bot 3.0 ahora forzará un TAP VIRTUAL en el centro de tu pantalla milisegundos después del salto cuántico. Tu espada bailará (O se enviará un 'Hit' silencioso a la central).\n\nCon la tuerca del gatillo apretada, aprieta los 3 asaltos de nuevo. Esta es la vencida."
    LogTextBox.TextColor3 = Color3.fromRGB(200, 255, 180)
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
    btnAtk1.BackgroundColor3 = Color3.fromRGB(120, 40, 0)
    btnAtk1.Text = "🔥 ATK 1: HIT & RUN VIRTUAL"
    btnAtk1.TextColor3 = Color3.fromRGB(255, 230, 200)
    btnAtk1.Font = Enum.Font.Code
    btnAtk1.TextSize = 12
    btnAtk1.Parent = MainFrame
    
    local btnAtk2 = Instance.new("TextButton")
    btnAtk2.Size = UDim2.new(0.32, 0, 0, 40)
    btnAtk2.Position = UDim2.new(0.34, 0, 0.70, 0)
    btnAtk2.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
    btnAtk2.Text = "👻 ATK 2: FANTASMA"
    btnAtk2.TextColor3 = Color3.fromRGB(255, 220, 255)
    btnAtk2.Font = Enum.Font.Code
    btnAtk2.TextSize = 12
    btnAtk2.Parent = MainFrame
    
    local btnAtk3 = Instance.new("TextButton")
    btnAtk3.Size = UDim2.new(0.32, 0, 0, 40)
    btnAtk3.Position = UDim2.new(0.66, 8, 0.70, 0)
    btnAtk3.BackgroundColor3 = Color3.fromRGB(0, 100, 160)
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
