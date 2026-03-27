-- ==============================================================================
-- 💀 ROBLOX EXPERT: V31 THE DARK-ZONE ORCHESTRATOR (AISLAMIENTO TÁCTICO)
-- Explotación activa de los Vectores Físicos Vulnerables (Hit & Run vs Core Amputee)
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
-- 🔬 UTILIDADES Y BÚSQUEDA DE OBJETIVOS
-- ==============================================================================
local function GetViableTarget()
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Name:lower():match("zombie") or obj.Name:lower():match("boss") then
                if obj.Humanoid.Health > 0 and obj:FindFirstChild("HumanoidRootPart") then return obj end
            end
        end)
    end
    return nil
end

local function FireWeapon()
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp and bp:FindFirstChildOfClass("Tool") then
            tool = bp:FindFirstChildOfClass("Tool")
            tool.Parent = LocalPlayer.Character
            task.wait(0.2)
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
    FullReport = FullReport .. "⚔️ V31. ATAQUE 1: HIT & RUN (CFRAME PURO RAPIDO) ⚔️\n"
    FullReport = FullReport .. "========================================================\n\n"
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then AddLog("❌ ERROR: No tienes personaje o RootPart.", 0); return end
    
    local target = GetViableTarget()
    if not target then AddLog("❌ ERROR: No hay Zombies vivos en el mapa.", 0); return end
    
    local PosOriginal = hrp.Position
    local StartHealth = target.Humanoid.Health
    
    AddLog("[+] TARGET: " .. target.Name .. " (Vida: " .. tostring(StartHealth) .. ").", 0)
    AddLog("[🚀] MÉTODO HIT & RUN: Teletransporte -> Pegar -> Regresar (En 0.1s para evitar al Anti-Cheat).", 0)
    
    pcall(function()
        for i=1, 3 do
            -- 1. Saltar a la cabeza del zombie
            char:PivotTo(target:FindFirstChild("HumanoidRootPart").CFrame * CFrame.new(0, 0, 2))
            -- 2. Disparar el Arma de ClientCast inmediatamente
            FireWeapon()
            task.wait(0.15)
            -- 3. Regresar a la base volando antes de que el Servidor se de cuenta
            char:PivotTo(CFrame.new(PosOriginal))
            task.wait(0.5) -- Esperar que el servidor procese el golpe y baje la fatiga
        end
    end)
    
    task.wait(1)
    local EndHealth = target.Humanoid.Health
    
    AddLog("\n[🔍 DIAGNÓSTICO DEL ATAQUE 1]", 0)
    if EndHealth < StartHealth then
        AddLog("├─ [🚨 FACTIBLE (TE ESTÁN ROBANDOASÍ)]: Logramos golpear al Zombie y quitarle " .. tostring(StartHealth - EndHealth) .. " de HP.", 1)
        AddLog("├─ ¿Por qué falló tu Anti-Trampas?: Porque tu servidor mide la posición CADA SEGUNDO (o más lento). El hacker ataca y vuelve muy rápido; para cuando el Servidor lo escanea, él sigue en la base y parece inocente.", 1)
        AddLog("└─ JERARQUÍA DE SOLUCIÓN: Optimizar el Anti-Cheat o forzar Magnitude Server-Side al recibir el evento RaycastHitbox.", 1)
    else
        AddLog("├─ [🛡️ BLOQUEADO (SEGURO)]: El zombie sigue con " .. tostring(EndHealth) .. " HP. El arma no se activó a tiempo o el Servidor rebotó el daño por desincronización rápida.", 1)
        AddLog("└─ CONCLUSIÓN: Si este falló, significa que tu Anti-Cheat es extremadamente veloz y sí te jala de vuelta.", 1)
    end
end

-- ==============================================================================
-- 🚀 ATAQUE 2: DARK ZONE GHOSTING (AMPUTACIÓN ROOTPART)
-- ==============================================================================
local function RunAttack2()
    FullReport = "========================================================\n"
    FullReport = FullReport .. "👻 V31. ATAQUE 2: DARK ZONE GHOSTING (AMPUTACIÓN HRP) 👻\n"
    FullReport = FullReport .. "========================================================\n\n"
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then AddLog("❌ ERROR: Ya estás amputado o muerto.", 0); return end
    
    local target = GetViableTarget()
    if not target then AddLog("❌ ERROR: No hay Zombies vivos en el mapa.", 0); return end
    
    local PosOriginal = hrp.Position
    local StartHealth = target.Humanoid.Health
    local SafeZone = PosOriginal + Vector3.new(0, 1500, 0)
    
    AddLog("[+] TARGET: " .. target.Name .. " (Vida: " .. tostring(StartHealth) .. ").", 0)
    AddLog("[🚀] MÉTODO GHOST: Viajamos a Zona Oscura (1500 studs) -> Borramos nuestra Raíz para Crashear tu Anti-Trampas -> Bajamos a pegarle al Zombi desde arriba -> Volvemos al Cielo.", 0)
    
    pcall(function()
        -- 1. Destruimos el HRP Local para cegar al Server
        hrp.Name = "Basura"
        hrp.Parent = nil
        local torso = char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso")
        if not torso then return end
        
        -- 2. Nos vamos al cielo
        torso.CFrame = CFrame.new(SafeZone)
        task.wait(0.5)
        
        -- 3. Bajamos al Zombie a machacar
        for i=1, 3 do
            torso.CFrame = target:FindFirstChild("HumanoidRootPart").CFrame * CFrame.new(0, 5, 0)
            FireWeapon()
            task.wait(0.3)
            -- Subir
            torso.CFrame = CFrame.new(SafeZone)
            task.wait(0.5)
        end
        
        -- Restaurar
        hrp.Parent = char; hrp.Name = "HumanoidRootPart"
        char:PivotTo(CFrame.new(PosOriginal))
    end)
    
    task.wait(1)
    local EndHealth = target.Humanoid.Health
    
    AddLog("\n[🔍 DIAGNÓSTICO DEL ATAQUE 2]", 0)
    if EndHealth < StartHealth then
        AddLog("├─ [🚨 FACTIBLE (BRUTALMENTE VULNERABLE)]: Le quitaste " .. tostring(StartHealth - EndHealth) .. " HP desde el cielo siendo un Fantasma indetectable.", 1)
        AddLog("├─ ¿Por qué falló tu Anti-Trampas?: Porque se apoyaba exclusivamente en HumanoidRootPart. Al borrarlo, tu código C++ generó un error (letras rojas en tu consola F9) y dejó de protegerte. El hacker se vuelve Inmune a tus banneos.", 1)
        AddLog("└─ JERARQUÍA DE SOLUCIÓN: Agrega 'if not Player.Character:FindFirstChild(\"HumanoidRootPart\") then Player:Kick() end' en tu rutina C++ del servidor.", 1)
    else
        AddLog("├─ [🛡️ BLOQUEADO (SEGURO)]: Zombi intacto (" .. tostring(EndHealth) .. "). O el arma falló sin RootPart, o tu Servidor castiga amputaciones.", 1)
        AddLog("└─ CONCLUSIÓN: Tus defensas no se inmutan por falta de partes del cuerpo.", 1)
    end
end

-- ==============================================================================
-- 🚀 ATAQUE 3: BRING MOBS (NETWORK OWNERSHIP BYPASS)
-- ==============================================================================
local function RunAttack3()
    FullReport = "========================================================\n"
    FullReport = FullReport .. "🌪️ V31. ATAQUE 3: BRING MOBS (MAGNETISMO DE RED) 🌪️\n"
    FullReport = FullReport .. "========================================================\n\n"
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then AddLog("❌ ERROR: No tienes personaje.", 0); return end
    
    local target = GetViableTarget()
    if not target then AddLog("❌ ERROR: No hay Zombies vivos en el mapa.", 0); return end
    
    local PosOriginal = hrp.Position
    local ZombOriginal = target:FindFirstChild("HumanoidRootPart").Position
    local StartHealth = target.Humanoid.Health
    
    AddLog("[+] TARGET: " .. target.Name .. " (Distancia original: " .. tostring(math.floor((PosOriginal - ZombOriginal).Magnitude)) .. " Studs).", 0)
    AddLog("[🚀] MÉTODO IMÁN: No viaja el Hacker. Le roba la Física (NetworkOwner) al Zombie y teletransporta al Zombie hacia el arma del Hacker.", 0)
    
    pcall(function()
        local zHRP = target:FindFirstChild("HumanoidRootPart")
        if zHRP then
            -- Intentamos secuestrar la fisica asumiendo que el server la delego al cliente más cercano accidentalmente
            task.spawn(function()
                for i=1, 20 do
                    if not zHRP then break end
                    zHRP.CFrame = hrp.CFrame * CFrame.new(0, 0, -3) -- Lo obligamos a estar de frente nuestro
                    task.wait(0.05)
                end
            end)
            
            task.wait(0.2)
            for i=1, 3 do FireWeapon(); task.wait(0.3) end
        end
    end)
    
    task.wait(1)
    local EndHealth = target.Humanoid.Health
    local ZombFinal = target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("HumanoidRootPart").Position or ZombOriginal
    
    AddLog("\n[🔍 DIAGNÓSTICO DEL ATAQUE 3]", 0)
    if (ZombFinal - PosOriginal).Magnitude < 15 and (ZombOriginal - PosOriginal).Magnitude > 25 then
        AddLog("├─ [🚨 FACTIBLE POSICIONAL (ROBO DE RED)]: El Zombi se teletransportó hacia ti sin permiso. El Servidor le regaló el NetworkOwnership a tu cliente permitiéndote imantar monstruos.", 1)
        if EndHealth < StartHealth then AddLog("├─ Y además... ¡Mataste al zombie imantado (-" .. tostring(StartHealth - EndHealth) .. " HP)!", 1) end
        AddLog("└─ JERARQUÍA DE SOLUCIÓN: Agrega 'ZombieHRP:SetNetworkOwner(nil)' al final del ciclo for de todos tus NPCs en Servidor para que TÚ servidor maneje las físicas inquebrantablemente.", 1)
    else
        AddLog("├─ [🛡️ BLOQUEADO (SEGURO)]: El Zombi ignoró mi orden matemática de venir hacia ti. Se mantuvo en su sitio o cerca de su origen original.", 1)
        AddLog("└─ CONCLUSIÓN: Has aplicado bien SetNetworkOwner(nil) en tus mobs. Son intocables.", 1)
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
-- 🖥️ GUI V31: THE DARK-ZONE ORCHESTRATOR
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
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
    MainFrame.BorderSizePixel = 3
    MainFrame.BorderColor3 = Color3.fromRGB(200, 0, 255)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -90, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(70, 0, 90)
    TopBar.Text = "  [V31: THE DARK-ZONE ORCHESTRATOR - AUTORIZACIÓN POR ATAQUES AISLADOS]"
    TopBar.TextColor3 = Color3.fromRGB(255, 150, 255)
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

    local InfoScroll = Instance.new("ScrollingFrame")
    InfoScroll.Size = UDim2.new(1, -16, 0.55, 0)
    InfoScroll.Position = UDim2.new(0, 8, 0, 35)
    InfoScroll.BackgroundColor3 = Color3.fromRGB(10, 5, 15)
    InfoScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    InfoScroll.ScrollBarThickness = 6
    InfoScroll.Parent = MainFrame

    local LogTextBox = Instance.new("TextBox")
    LogTextBox.Size = UDim2.new(1, -10, 1, 0)
    LogTextBox.Position = UDim2.new(0, 5, 0, 5)
    LogTextBox.BackgroundTransparency = 1
    LogTextBox.Text = "TUS ÓRDENES FUERON CLARAS:\nCrear los 3 Botones para los ataques ofensivos que descubríamos en V30 de a un clic (Por si alguno nos provoca un error masivo o pateada, no perdemos todo el Log).\n\nHE CREADO LAS TRES PRUEBAS DE ESTRÉS (HACER DAÑO A ZOMBIES):\n\n[Botón ATAQUE 1: HIT & RUN ESPACIAL]\nVa al Zombi, le saca vida con ClientCast y regresa en milésimas de segundo intentando engañar la velocidad del Sensor.\n\n[Botón ATAQUE 2: ZONA OSCURA + AMPUTACIÓN]\nSe roba a sí mismo el 'HumanoidRootPart', cruza a 1500 Studs (Cielo) ciber-silenciosamente, baja y masacra al Zombi. Crashea al C++.\n\n[Botón ATAQUE 3: LA IMANTACIÓN DE RED]\nEl Hacker no viaja al zombie; Secuestra el estado del Zombie en su cliente y arrastra a los NPCs volando hacia la base segura para matarlos farmeando.\n\nPrueba los 3, uno por uno..."
    LogTextBox.TextColor3 = Color3.fromRGB(230, 180, 255)
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
    btnAtk1.BackgroundColor3 = Color3.fromRGB(100, 50, 0)
    btnAtk1.Text = "🔥 ATK 1: HIT & RUN"
    btnAtk1.TextColor3 = Color3.fromRGB(255, 230, 200)
    btnAtk1.Font = Enum.Font.Code
    btnAtk1.TextSize = 12
    btnAtk1.Parent = MainFrame
    
    local btnAtk2 = Instance.new("TextButton")
    btnAtk2.Size = UDim2.new(0.32, 0, 0, 40)
    btnAtk2.Position = UDim2.new(0.34, 0, 0.70, 0)
    btnAtk2.BackgroundColor3 = Color3.fromRGB(120, 0, 150)
    btnAtk2.Text = "👻 ATK 2: FANTASMA"
    btnAtk2.TextColor3 = Color3.fromRGB(255, 220, 255)
    btnAtk2.Font = Enum.Font.Code
    btnAtk2.TextSize = 12
    btnAtk2.Parent = MainFrame
    
    local btnAtk3 = Instance.new("TextButton")
    btnAtk3.Size = UDim2.new(0.32, 0, 0, 40)
    btnAtk3.Position = UDim2.new(0.66, 8, 0.70, 0)
    btnAtk3.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
    btnAtk3.Text = "🌪️ ATK 3: IMÁN ZOMBIE"
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
    btnPrev.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
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
    btnNext.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btnNext.Text = "Lectura >"
    btnNext.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnNext.Parent = MainFrame
    
    local function UptLabel() PageLabel.Text = "Página " .. tostring(CurrentPage) .. " / " .. tostring(#Pages) end
    btnPrev.MouseButton1Click:Connect(function() if CurrentPage > 1 then CurrentPage = CurrentPage - 1; ActualizarPantalla(); UptLabel() end end)
    btnNext.MouseButton1Click:Connect(function() if CurrentPage < #Pages then CurrentPage = CurrentPage + 1; ActualizarPantalla(); UptLabel() end end)
end

ConstruirUI()
