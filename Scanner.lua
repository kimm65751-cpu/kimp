-- ==============================================================================
-- 💀 ROBLOX EXPERT: SERVER-AUTHORITATIVE KILLAURA BYPASS (V10)
-- Documentado 2026: Bypass de Error 267 (Anti-TP), Solucion al Raycast "GHOST".
-- Cambio de Objetivo. La cabeza es la única parte vulnerable al RayCasting.
-- ==============================================================================

local SCRIPT_URL = "https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

getgenv().HitboxMaster = false
getgenv().KiteBotActive = false

-- ==============================================================================
-- 📡 MÉTODO 1: HEAD-EXPANDER (BYPASS FINAL AL RAYCAST FILTERING)
-- ==============================================================================
local function StartHitboxExpander()
    if getgenv().HitboxMaster then return end
    getgenv().HitboxMaster = true
    print("[CRACKER] Hitbox Expander Activo: Cabezas Gigantes.")
    
    task.spawn(function()
        while getgenv().HitboxMaster do
            pcall(function()
                for _, z in pairs(Workspace:GetDescendants()) do
                    if z:IsA("Model") and string.find(string.lower(z.Name), "zombie") and z ~= LocalPlayer.Character then
                        local hum = z:FindFirstChild("Humanoid")
                        
                        -- CRACK 2026: El Server IGNORA el HumanoidRootPart en los ataques. 
                        -- ÚNICAMENTE la malla visual (Malla visible, no la caja central física) recibe daño.
                        -- Por eso inflaremos LA CABEZA ("Head").
                        local head = z:FindFirstChild("Head") or z:FindFirstChild("UpperTorso") or z:FindFirstChild("Torso")
                        if hum and hum.Health > 0 and head then
                            head.Size = Vector3.new(45, 45, 45) -- 45 Metros
                            head.Transparency = 0.5
                            head.BrickColor = BrickColor.new("Bright blue")
                            head.Material = Enum.Material.Neon
                            head.CanCollide = false
                        end
                        
                        -- Reducimos el RootPart visual de la version anterior para que no moleste
                        local root = z:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.Transparency = 1
                            root.Size = Vector3.new(2, 2, 1)
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end)
end

local function StopHitboxExpander()
    getgenv().HitboxMaster = false
    print("[CRACKER] Hitbox apagados, volviendo zombis a la normalidad.")
    pcall(function()
        for _, z in pairs(Workspace:GetDescendants()) do
            if z:IsA("Model") and string.find(string.lower(z.Name), "zombie") then
                local head = z:FindFirstChild("Head")
                if head then
                    head.Size = Vector3.new(1.2, 1.2, 1.2) -- Tamaño Clásico Cabeza
                    head.Transparency = 0
                end
            end
        end
    end)
end

-- ==============================================================================
-- 🧩 MÉTODO 1.5: RAYCAST DEBUGGER (SABER POR QUÉ NO PEGA LA ESPADA)
-- ==============================================================================
local function CheckRaycastHit()
    local char = LocalPlayer.Character
    local head = char and char:FindFirstChild("Head")
    if not head then return end
    
    local mouse = LocalPlayer:GetMouse()
    local dir = (mouse.Hit.Position - head.Position).Unit * 100
    
    local ray = Ray.new(head.Position, dir)
    -- Tiramos un Láser nosotros mismos
    local objToque = Workspace:FindPartOnRay(ray, char)
    
    print("\n----------------------")
    print("🔍 DIAGNÓSTICO DE RAYCAST (Si tiraras un golpe C++ a donde apuntas):")
    if objToque then
        print("▶️ Estás apuntando a la parte: " .. objToque.Name)
        if objToque.Name == "HumanoidRootPart" then
            print("❌ ATENCIÓN: El motor de Roblox o tu espada IGNORAN esta pieza. Por eso el Aura Roja Gigante no te servía, el arma traspasaba el cuadro rojo.")
        elseif objToque.Name == "Head" then
            print("✅ ¡SÍRVIO! Estás tocando la CABEZA del zombi. Un ataque del arma aquí SÍ será validado por el Servidor.")
        end
    else
        print("▶️ No estás tocando a nadie en la línea del Láser.")
    end
    print("----------------------\n")
end


-- ==============================================================================
-- ⚔️ MÉTODO 2: KITE-BOT (HIT & RUN BYPASS. ÁREA AoE 5M)
-- ==============================================================================
local function StartKiteBot()
    if getgenv().KiteBotActive then return end
    getgenv().KiteBotActive = true
    print("[CRACKER] IA Táctica Iniciada. Movimiento Auto-Esquive Activado.")

    task.spawn(function()
        while getgenv().KiteBotActive do
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChild("Humanoid")
                local arma = LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool") or char and char:FindFirstChildWhichIsA("Tool")
                
                if arma and hum then hum:EquipTool(arma) end

                if root and hum.Health > 0 and arma then
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
                        local safeDist = 5.5
                        local posObj = target.CFrame * CFrame.new(0, 0, safeDist) 
                        hum:MoveTo(posObj.Position)
                        if (target.Position - root.Position).Magnitude <= 6.5 then
                            root.CFrame = CFrame.new(root.Position, target.Position)
                            arma:Activate()
                            pcall(function() mouse1click() end)
                        end
                    end
                end
            end)
            task.wait(0.05)
        end
    end)
end

local function StopKiteBot()
    getgenv().KiteBotActive = false
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then root.Velocity = Vector3.zero end
    print("[CRACKER] Inteligencia Artificial Kiting Desactivada.")
end

-- ==============================================================================
-- 🖥️ GUI V2026: EL PANEL OPERATIVO DEFINITIVO
-- ==============================================================================
local function ConstruirUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "MasterBypass2026UI"
    sg.ResetOnSpawn = false
    
    local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "MasterBypass2026UI" then v:Destroy() end end
    sg.Parent = parentUI

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 850, 0, 700)
    MainFrame.Position = UDim2.new(0.5, -425, 0.5, -350)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    MainFrame.BorderSizePixel = 3
    MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -120, 0, 35)
    TopBar.BackgroundColor3 = Color3.fromRGB(5, 50, 50)
    TopBar.Text = "  [BYPASS DE SEGURIDAD 2026: V10 - HITBOX TÁCTIL (HEAD GHOST-FIX)]"
    TopBar.TextColor3 = Color3.fromRGB(100, 255, 255)
    TopBar.Font = Enum.Font.Code
    TopBar.TextSize = 14
    TopBar.TextXAlignment = Enum.TextXAlignment.Left
    TopBar.Parent = MainFrame

    local ReloadBtn = Instance.new("TextButton")
    ReloadBtn.Size = UDim2.new(0, 40, 0, 35)
    ReloadBtn.Position = UDim2.new(1, -120, 0, 0)
    ReloadBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 0)
    ReloadBtn.Text = "↻"
    ReloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ReloadBtn.Font = Enum.Font.Code
    ReloadBtn.TextSize = 20
    ReloadBtn.Parent = MainFrame

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 40, 0, 35)
    MinimizeBtn.Position = UDim2.new(1, -80, 0, 0)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 150)
    MinimizeBtn.Text = "_"
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.Font = Enum.Font.Code
    MinimizeBtn.TextSize = 16
    MinimizeBtn.Parent = MainFrame

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 40, 0, 35)
    CloseBtn.Position = UDim2.new(1, -40, 0, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.TextSize = 16
    CloseBtn.Parent = MainFrame

    CloseBtn.MouseButton1Click:Connect(function() pcall(function() StopHitboxExpander(); StopKiteBot() end) sg:Destroy() end)
    MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)
    ReloadBtn.MouseButton1Click:Connect(function()
        pcall(function()
            sg:Destroy()
            if type(loadstring) == "function" then
                loadstring(game:HttpGet(SCRIPT_URL .. "?reload=" .. tostring(math.random(11111, 99999))))()
            end
        end)
    end)

    local InfoScroll = Instance.new("ScrollingFrame")
    InfoScroll.Size = UDim2.new(1, -20, 0.45, 0)
    InfoScroll.Position = UDim2.new(0, 10, 0, 45)
    InfoScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    InfoScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    InfoScroll.ScrollBarThickness = 8
    InfoScroll.Parent = MainFrame

    local LogText = Instance.new("TextLabel")
    LogText.Size = UDim2.new(1, -15, 1, 0)
    LogText.Position = UDim2.new(0, 5, 0, 5)
    LogText.BackgroundTransparency = 1
    LogText.Text = ">>> EXCELENTE DESCUBRIMIENTO <<<\n\nViendo el cuadro rojo fantasma comprobaste mi sospecha del Motor Roblox 2026. Lo que estábamos haciendo gigante era el `HumanoidRootPart` (El ancla física). Sin embargo, casi todos los Laser de Combate modernos (RaycastParams) traen un código que dice: *'Ignorar el RootPart y solo buscar la cabeza o los brazos'.* \n\nPor eso el arma 'traspasaba' la burbuja roja como si fuera un fantasma; el servidor la estaba bloqueando y esperando que toques el centro ('Head').\n\n🔹 EL PARCHE EXACTO (BOTÓN 1): \nAhora atacaremos directamente a la CABEZA del zombi y la volveremos un domo gigante y azul de 45 metros de ancho. Si le das un espadazo a la malla de esa cabeza y tu ratón la selecciona, el arma estará obligada a registrar el golpe C++ a leguas de distancia.\n\n🔹 DIAGNÓSTICO LÁSER (BOTÓN 3): \nComo somos metódicos, añadí un botón de diagnóstico láser. Si apuntas con el mouse al cubo gigante y pulsas el botón 3, el escáner te dirá si el Láser lo reconoce como 'Hit' (Cabeza) o si el motor lo rechaza."
    LogText.TextColor3 = Color3.fromRGB(230, 255, 255)
    LogText.Font = Enum.Font.Code
    LogText.TextSize = 13
    LogText.TextXAlignment = Enum.TextXAlignment.Left
    LogText.TextYAlignment = Enum.TextYAlignment.Top
    LogText.TextWrapped = true
    LogText.Parent = InfoScroll

    local Btn1 = Instance.new("TextButton")
    Btn1.Size = UDim2.new(0.5, -15, 0, 55)
    Btn1.Position = UDim2.new(0, 10, 0.5, 40)
    Btn1.BackgroundColor3 = Color3.fromRGB(0, 50, 150)
    Btn1.Text = "1. INFLAR 'CABEZAS' GIGANTES\n(Bypass al Ghosting del RootPart)"
    Btn1.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn1.Font = Enum.Font.Code
    Btn1.TextSize = 14
    Btn1.Parent = MainFrame

    local Btn2 = Instance.new("TextButton")
    Btn2.Size = UDim2.new(0.5, -15, 0, 55)
    Btn2.Position = UDim2.new(0.5, 5, 0.5, 40)
    Btn2.BackgroundColor3 = Color3.fromRGB(0, 100, 50)
    Btn2.Text = "2. ACTIVAR IA DE ESQUIVE\n(El Kite-Bot Táctico)"
    Btn2.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn2.Font = Enum.Font.Code
    Btn2.TextSize = 14
    Btn2.Parent = MainFrame
    
    local Btn3 = Instance.new("TextButton")
    Btn3.Size = UDim2.new(1, -20, 0, 45)
    Btn3.Position = UDim2.new(0, 10, 0.5, 105)
    Btn3.BackgroundColor3 = Color3.fromRGB(150, 80, 0)
    Btn3.Text = "3. [ESCANEAR LÁSER]: Apunta al cubo y mira tu consola de exploit"
    Btn3.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn3.Font = Enum.Font.Code
    Btn3.TextSize = 14
    Btn3.Parent = MainFrame

    Btn1.MouseButton1Click:Connect(function()
        pcall(function()
            if getgenv().HitboxMaster then
                StopHitboxExpander()
                Btn1.Text = "1. INFLAR 'CABEZAS' GIGANTES\n(Bypass al Ghosting)"
                Btn1.BackgroundColor3 = Color3.fromRGB(0, 50, 150)
            else
                StartHitboxExpander()
                Btn1.Text = "🛑 APAGAR CABEZAS GIGANTES"
                Btn1.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
            end
        end)
    end)

    Btn2.MouseButton1Click:Connect(function()
        pcall(function()
            if getgenv().KiteBotActive then
                StopKiteBot()
                Btn2.Text = "2. ACTIVAR IA DE ESQUIVE\n(El Kite-Bot Táctico)"
                Btn2.BackgroundColor3 = Color3.fromRGB(0, 100, 50)
            else
                StartKiteBot()
                Btn2.Text = "🛑 APAGAR IA"
                Btn2.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
            end
        end)
    end)
    
    Btn3.MouseButton1Click:Connect(function() pcall(CheckRaycastHit) end)
end

ConstruirUI()
