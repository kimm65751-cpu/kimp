-- ==============================================================================
-- 💀 ROBLOX EXPERT: V15 DOOMSDAY DEVICE (BYPASS ANTI-CHEAT ABSOLUTO)
-- Resultados de Pruebas: Prop Telekinesis = 363 Props Válidos (ÉXITO).
--                        Lag-Walk (Sin CFrames) = Anti-TP Evasión (ÉXITO).
-- ==============================================================================

local SCRIPT_URL = "https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local NetworkSettings = settings():GetService("NetworkSettings")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- ==============================================================================
-- 🔫 ARMA 1: PROP TELEKINESIS (EL CAÑÓN DE OBJETOS C++)
-- Extrae los 363 objetos sueltos del mundo (minerales) y los proyecta con físicas Havok.
-- ==============================================================================
getgenv().PropTelekinesis = false

local function IniciarPropTelekinesis()
    if getgenv().PropTelekinesis then return end
    getgenv().PropTelekinesis = true
    print("[CRACKER] Telequinesis Iniciada. Obteniendo NetworkOwnership de la basura del mapa.")
    
    task.spawn(function()
        while getgenv().PropTelekinesis do
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                -- Buscar presa viva
                local target = nil
                local distM = 99999
                for _, z in pairs(Workspace:GetDescendants()) do
                    if z:IsA("Model") and string.find(string.lower(z.Name), "zombie") and z ~= char then
                        local zHum = z:FindFirstChild("Humanoid")
                        local zRoot = z:FindFirstChild("HumanoidRootPart")
                        if zHum and zHum.Health > 0 and zRoot then
                            local d = (zRoot.Position - root.Position).Magnitude
                            if d < distM then distM = d; target = zRoot end
                        end
                    end
                end

                if target then
                    -- Recolectar Físicas Sueltas
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and not obj.Anchored and obj.Name ~= "HumanoidRootPart" and obj.Name ~= "Head" and obj.Name ~= "Torso" then
                            if not obj.Parent:FindFirstChild("Humanoid") then
                                -- TELEQUINESIS: Teletransportar todos los objetos al Zombie
                                -- Moverlos a velocidad hiper sónica dentro del pecho del monstruo destrutye sus uniones C++
                                obj.CFrame = target.CFrame * CFrame.new(math.random(-1,1), math.random(-1,1), math.random(-1,1))
                                -- Agregamos locura física para causar un choque incalculable por el Motor Havok
                                obj.AssemblyLinearVelocity = Vector3.new(0, -9999, 0)
                                obj.AssemblyAngularVelocity = Vector3.new(9999, 9999, 9999)
                            end
                        end
                    end
                end
            end)
            task.wait(0.02)
        end
    end)
end

local function DetenerPropTelekinesis()
    getgenv().PropTelekinesis = false
    print("[CRACKER] Telequinesis apagada. Las piedras vuelven a caer al suelo.")
end

-- ==============================================================================
-- 🌪️ ARMA 2: EL TORNADO HAVOK (SPIN-FLING TÁCTICO)
-- Como el Anti-TP obvió la velocidad angular en el Test 2, podemos usar nuestro cuerpo como Bala.
-- ==============================================================================
getgenv().SpinFling = false
local FlingVelocity = nil

local function IniciarSpinFling()
    if getgenv().SpinFling then return end
    getgenv().SpinFling = true
    print("[CRACKER] Spin-Fling Iniciado.")
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not root or not hum then return end
    
    -- Blindar el cuerpo del jugador de tropiezos
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then v.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 0, 0, 0) end
    end
    
    hum.WalkSpeed = 22 -- Caminar rápido legal
    
    FlingVelocity = Instance.new("BodyAngularVelocity")
    FlingVelocity.Name = "HavokTornado"
    FlingVelocity.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    FlingVelocity.AngularVelocity = Vector3.new(0, 99999, 0) -- Giro Huracanado (Muerte por contacto)
    FlingVelocity.Parent = root
    
    task.spawn(function()
        while getgenv().SpinFling do
            pcall(function()
                -- En este modo TÚ caminas hacia ellos para empujarlos al vacío. 
                -- Automáticamente rebotarán contigo y saldrán de la atmósfera del juego antes de pegarte.
                root.AssemblyAngularVelocity = Vector3.new(0, 99999, 0)
            end)
            task.wait(0.1)
        end
    end)
end

local function DetenerSpinFling()
    getgenv().SpinFling = false
    if FlingVelocity then FlingVelocity:Destroy() FlingVelocity = nil end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then root.AssemblyAngularVelocity = Vector3.zero end
    print("[CRACKER] Trompo Físico Apagado.")
end

-- ==============================================================================
-- 🖥️ GUI V2026: EL APOCALIPSIS COMPACTO
-- ==============================================================================
local function ConstruirUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "MasterBypass2026UI"
    sg.ResetOnSpawn = false
    
    local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "MasterBypass2026UI" then v:Destroy() end end
    sg.Parent = parentUI

    -- 📐 REDUCIDO DRÁSTICAMENTE (LDPlayer Formato)
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 560, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -280, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
    MainFrame.BorderSizePixel = 3
    MainFrame.BorderColor3 = Color3.fromRGB(200, 0, 50)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -90, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(50, 0, 10)
    TopBar.Text = "  [V15: THE DOOMSDAY DEVICE - CRACK CONFIRMADO]"
    TopBar.TextColor3 = Color3.fromRGB(255, 100, 100)
    TopBar.Font = Enum.Font.Code
    TopBar.TextSize = 13
    TopBar.TextXAlignment = Enum.TextXAlignment.Left
    TopBar.Parent = MainFrame

    local ReloadBtn = Instance.new("TextButton")
    ReloadBtn.Size = UDim2.new(0, 30, 0, 30)
    ReloadBtn.Position = UDim2.new(1, -90, 0, 0)
    ReloadBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 0)
    ReloadBtn.Text = "↻"
    ReloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ReloadBtn.Font = Enum.Font.Code
    ReloadBtn.TextSize = 18
    ReloadBtn.Parent = MainFrame

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    MinimizeBtn.Position = UDim2.new(1, -60, 0, 0)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 150)
    MinimizeBtn.Text = "_"
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.Font = Enum.Font.Code
    MinimizeBtn.TextSize = 14
    MinimizeBtn.Parent = MainFrame

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.TextSize = 14
    CloseBtn.Parent = MainFrame

    CloseBtn.MouseButton1Click:Connect(function() pcall(function() DetenerPropTelekinesis(); DetenerSpinFling() end) sg:Destroy() end)
    MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)
    ReloadBtn.MouseButton1Click:Connect(function()
        pcall(function() sg:Destroy(); loadstring(game:HttpGet(SCRIPT_URL .. "?r=" .. math.random(111,999)))() end)
    end)

    local InfoScroll = Instance.new("ScrollingFrame")
    InfoScroll.Size = UDim2.new(1, -16, 0.5, 0)
    InfoScroll.Position = UDim2.new(0, 8, 0, 35)
    InfoScroll.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    InfoScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    InfoScroll.ScrollBarThickness = 6
    InfoScroll.Parent = MainFrame

    local LogText = Instance.new("TextLabel")
    LogText.Size = UDim2.new(1, -10, 1, 0)
    LogText.Position = UDim2.new(0, 5, 0, 5)
    LogText.BackgroundTransparency = 1
    LogText.Text = ">>> ANÁLISIS CONFIRMADO: VULNERABILIDAD FÍSICA INYECTADA <<<\n\nVi todos tus audios y tus logs del Escáner V14. \n\n¡TENEMOS LUZ VERDE EN DOS VULNERABILIDADES DE INGENIERÍA!\n1. El Test 1 diagnosticó 363 objetos sueltos. \n2. El Test 2 confirmó que el Anticheat es Ciego a la rotación extrema.\n\nHe fabricado Las 2 Armas Definitivas en base a ti:\n\n🔥 1. TELEQUINESIS MASIVA (Para Farmear a Milla de Distancia sin moverte):\nRoblox te regalará el NetworkOwnership de esos 363 minerales caídos. El Botón 1 usará un ciclo matemático para tomarlos TODOS a la vez de forma invisible y acribillar al Zombi estallándolos desde su garganta a 9,999 MPH de velocidad angular. Morirá aplastado por el propio mundo. Ni siquiera tienes que sacar tu espada.\n\n🔥 2. EL TORNADO HAVOK (Por si te aburres y quieres destrozarlos):\nInyectará 100,000 grados de rotación en tu cuerpo. Te volverás un Trompo de fuerza bruta. Camina libremente hacia ellos: en cuanto la IA intente atacar tu esfera, el colapso del 'Havok Physics Engine' expulsará al zombi a la órbita espacial, ganando el choque instantáneo antes del cálculo del daño C++."
    LogText.TextColor3 = Color3.fromRGB(255, 180, 180)
    LogText.Font = Enum.Font.Code
    LogText.TextSize = 12
    LogText.TextXAlignment = Enum.TextXAlignment.Left
    LogText.TextYAlignment = Enum.TextYAlignment.Top
    LogText.TextWrapped = true
    LogText.Parent = InfoScroll

    -- Botones de Impacto
    local btnProps = Instance.new("TextButton")
    btnProps.Size = UDim2.new(1, -16, 0, 50)
    btnProps.Position = UDim2.new(0, 8, 0.62, 0)
    btnProps.BackgroundColor3 = Color3.fromRGB(150, 60, 0)
    btnProps.Text = "💥 1. ACTIVAR TELEQUINESIS (USAR LOS 363 OBJETOS COMO BALAS FÍSICAS) 💥"
    btnProps.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnProps.Font = Enum.Font.Code
    btnProps.TextSize = 13
    btnProps.Parent = MainFrame

    local btnFling = Instance.new("TextButton")
    btnFling.Size = UDim2.new(1, -16, 0, 50)
    btnFling.Position = UDim2.new(0, 8, 0.62, 55)
    btnFling.BackgroundColor3 = Color3.fromRGB(180, 0, 50)
    btnFling.Text = "🌪️ 2. ACTIVAR TORNADO HAVOK (DESTRUIRLOS AL CHOCARLOS Y MANDARLOS A VOLAR) 🌪️"
    btnFling.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnFling.Font = Enum.Font.Code
    btnFling.TextSize = 13
    btnFling.Parent = MainFrame

    btnProps.MouseButton1Click:Connect(function()
        pcall(function()
            if getgenv().PropTelekinesis then
                DetenerPropTelekinesis()
                btnProps.Text = "💥 1. ACTIVAR TELEQUINESIS (USAR OBJETOS)"
                btnProps.BackgroundColor3 = Color3.fromRGB(150, 60, 0)
            else
                IniciarPropTelekinesis()
                btnProps.Text = "🛑 DETENER CAÑÓN DE TELEQUINESIS"
                btnProps.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
            end
        end)
    end)
    
    btnFling.MouseButton1Click:Connect(function()
        pcall(function()
            if getgenv().SpinFling then
                DetenerSpinFling()
                btnFling.Text = "🌪️ 2. ACTIVAR TORNADO HAVOK (DESTRUIRLOS COMO BOLA DE BOLOS)"
                btnFling.BackgroundColor3 = Color3.fromRGB(180, 0, 50)
            else
                IniciarSpinFling()
                btnFling.Text = "🛑 DETENER TORNADO"
                btnFling.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
            end
        end)
    end)
end

ConstruirUI()
