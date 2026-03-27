-- ==============================================================================
-- 💀 ROBLOX EXPERT: V19 DEV STRESS-TOOL (PRUEBA DE ESTADO Y SATURACIÓN)
-- Simuladores de penetración de caja blanca de alto rendimiento sin acelerador.
-- ==============================================================================

local SCRIPT_URL = "https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local Analyzer = { Logs = {} }

function Analyzer:Clear()
    self.Logs = {}
    if self.UI_LogBox then self.UI_LogBox.Text = "" end
end

function Analyzer:Log(txt)
    print("[DEV-AUDIT] " .. tostring(txt))
    table.insert(self.Logs, txt)
    pcall(function() if self.UI_LogBox then self.UI_LogBox.Text = self.UI_LogBox.Text .. "\n" .. tostring(txt) end end)
    pcall(function() self.UI_LogBox.Parent.CanvasPosition = Vector2.new(0, 99999) end)
end

-- ==============================================================================
-- ⚡ TEST 1: MICRO-STEP JITTER ULTRA RÁPIDO (SATURACIÓN FRAME-PER-FRAME)
-- ==============================================================================
getgenv().JitterTest = false

local function IniciarJitter()
    if getgenv().JitterTest then return end
    getgenv().JitterTest = true
    Analyzer:Log("🧪 [V19-TEST 1] Corriendo Jitter-Desync al Máximo Rendimiento...")
    Analyzer:Log("He quitado todos los limitadores 'wait()'. Ahora el script vibra calculadamente 60 VECES POR SEGUNDO haciendo el Micro-Teleport y el Clic simultáneo (Auto-Clicker Overdrive LUA). Si tu servidor procesa estos 60 paquetes y te Kickea a ti, tu Anti-Cheat está perfecto midiendo saturación de 'Tool.Activated' y sumatorias de mini-saltos CFrame en un Tick.")
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return Analyzer:Log("❌ Error: No se encontró personaje.") end
    
    task.spawn(function()
        while getgenv().JitterTest do
            pcall(function()
                local target = nil
                local distM = 99999
                for _, z in pairs(Workspace:GetDescendants()) do
                    if z:IsA("Model") and string.find(string.lower(z.Name), "zombie") and z ~= char then
                        local zHum = z:FindFirstChild("Humanoid")
                        local zRoot = z:FindFirstChild("HumanoidRootPart")
                        if zHum and zHum.Health > 0 and zRoot then
                            local d = (zRoot.Position - root.Position).Magnitude
                            if d < 100 then
                                if d < distM then distM = d; target = zRoot end
                            end
                        end
                    end
                end

                if target then
                    local safePos = target.CFrame * CFrame.new(0, 0, -6) -- Frontera
                    local attackPos = target.CFrame * CFrame.new(0, 0, -4.9) -- Peligro (Adentro del Zombi)
                    
                    root.CFrame = safePos -- Asegura estar afuera primero
                    
                    -- Micro-Dodge Frame (Entra, actívate y sal)
                    root.CFrame = attackPos 
                    
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                    
                    root.CFrame = safePos 
                end
            end)
            RunService.RenderStepped:Wait() -- Ultra-velocidad LUA sin pausas pesadas
        end
    end)
end

local function DetenerJitter() getgenv().JitterTest = false Analyzer:Log("🛑 Jitter Cero-Delay detenido.") end

-- ==============================================================================
-- ⚡ TEST 2: LINEAR GLIDE FLIGHT (DESLIZAMIENTO SIN ARRASTRAR)
-- ==============================================================================
getgenv().GlideTest = false

local function IniciarGlide()
    if getgenv().GlideTest then return end
    getgenv().GlideTest = true
    Analyzer:Log("🧪 [V19-TEST 2] Glide Físico usando LinearVelocity (Alineado)...")
    Analyzer:Log("Corregí el 'arrastre en el piso' fijando un Vector Paralelo Absoluto usando 'LinearVelocity' y anulando tu peso C++. Ahora tu personaje ignorará el WalkSpeed (que suele medirse en LUA) y se moverá a 60 Studs/s usando pura aceleración del motor físico directo hacia donde miras. Si esto NO te dispara el Error 267, tu servidor y los zombis son vulnerables al Patinador Hit-and-Run.")

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return Analyzer:Log("❌ Error de Personaje.") end
    
    local att = Instance.new("Attachment", root)
    att.Name = "GlideAtt"
    
    local lv = Instance.new("LinearVelocity")
    lv.Name = "IceScaterVelocity"
    lv.Attachment0 = att
    lv.MaxForce = math.huge
    lv.VectorVelocity = root.CFrame.LookVector * 60
    lv.RelativeTo = Enum.ActuatorRelativeTo.World
    lv.Parent = root
    
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then v.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0, 0, 0, 0) end
    end
    
    task.spawn(function()
        while getgenv().GlideTest do
            pcall(function()
                 lv.VectorVelocity = (root.CFrame.LookVector * 60) + Vector3.new(0, 0.1, 0) -- Updateo para evitar hundirse
            end)
            RunService.Heartbeat:Wait()
        end
    end)
end

local function DetenerGlide()
    getgenv().GlideTest = false
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            if root:FindFirstChild("LinearVelocity") then root:FindFirstChild("LinearVelocity"):Destroy() end
            if root:FindFirstChild("GlideAtt") then root:FindFirstChild("GlideAtt"):Destroy() end
            local glide = root:FindFirstChild("IceScaterVelocity")
            if glide then glide:Destroy() end
        end
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CustomPhysicalProperties = nil end
        end
    end
    Analyzer:Log("🛑 Glide Motor Físico desactivado.")
end

-- ==============================================================================
-- 🖥️ GUI V2026: PANEL DE PRUEBAS DEL CREADOR (Local-Host)
-- ==============================================================================
local function ConstruirUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "MasterBypass2026UI"
    sg.ResetOnSpawn = false
    
    local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "MasterBypass2026UI" then v:Destroy() end end
    sg.Parent = parentUI

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 560, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -280, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
    MainFrame.BorderSizePixel = 3
    MainFrame.BorderColor3 = Color3.fromRGB(255, 100, 150)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -90, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
    TopBar.Text = "  [V19: STRESS-TEST LOCAL DE DESARROLLADOR]"
    TopBar.TextColor3 = Color3.fromRGB(255, 150, 150)
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

    CloseBtn.MouseButton1Click:Connect(function() pcall(function() DetenerJitter() DetenerGlide() end) sg:Destroy() end)
    MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)
    ReloadBtn.MouseButton1Click:Connect(function()
        pcall(function() sg:Destroy(); loadstring(game:HttpGet(SCRIPT_URL .. "?r=" .. math.random(111,999)))() end)
    end)

    local InfoScroll = Instance.new("ScrollingFrame")
    InfoScroll.Size = UDim2.new(1, -16, 0.45, 0)
    InfoScroll.Position = UDim2.new(0, 8, 0, 35)
    InfoScroll.BackgroundColor3 = Color3.fromRGB(25, 20, 25)
    InfoScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    InfoScroll.ScrollBarThickness = 6
    InfoScroll.Parent = MainFrame

    local LogText = Instance.new("TextLabel")
    LogText.Size = UDim2.new(1, -10, 1, 0)
    LogText.Position = UDim2.new(0, 5, 0, 5)
    LogText.BackgroundTransparency = 1
    LogText.Text = "Corregí la Fricción del Patinador y le quité los frenos al Ticker para que actúen como verdaderos 'Exploits de Overdrive' puros contra ti.\n\nESTAS SON OTRAS 3 IDEAS RARAS COMO DEV:\n\n💡 1. TWEEN C-FRAME (EL SALTO LINEAR): Si tu Anti-Cheat 267 solo calcula 'Saltos en 0 milisegundos', el Hacker usa 'TweenService' en Local para volar Lenta pero matemáticamente linealmente, burlando el límite sin dar el salto de Coordenada.\n💡 2. Y-AXIS BLINDSPOT (CONSTRUIR ESCALERAS): A veces tu (RootPart - Zombie.RootPart.Position).Magnitude es ciego en altura si no haces un cilindro. Si el Hacker clona una tabla invisible al cielo en C++ y camina arriba a 4.9 Studs exactamente sobre la cabeza del Zombier... ¿Tu zombie mirará hacia arriba para atacarlo o el Pathfinding se atorará con las montañas?\n💡 3. STATE SPOOFING (BORRAR EL HUMANOID): Algunos scripts de Servidor explotan si no detectan el estado Local del Personaje. Si un Hacker localmente envía el estado 'Humanoid:ChangeState(Enum.HumanoidStateType.Dead)', pero sigue vivo por salud real, algunos Raycasts de AI Servidor descartan el 'Objeto' como Target por ser Cadáver, volviéndolo Intocable a Daño LUA de NPC."
    LogText.TextColor3 = Color3.fromRGB(255, 200, 200)
    LogText.Font = Enum.Font.Code
    LogText.TextSize = 12
    LogText.TextXAlignment = Enum.TextXAlignment.Left
    LogText.TextYAlignment = Enum.TextYAlignment.Top
    LogText.TextWrapped = true
    LogText.Parent = InfoScroll

    Analyzer.UI_LogBox = LogText

    local btnJitter = Instance.new("TextButton")
    btnJitter.Size = UDim2.new(0.48, 0, 0, 50)
    btnJitter.Position = UDim2.new(0, 8, 0.62, 0)
    btnJitter.BackgroundColor3 = Color3.fromRGB(150, 0, 50)
    btnJitter.Text = "⚡ 1. TEST JITTER CERO LIMITES (60X FRAME)"
    btnJitter.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnJitter.Font = Enum.Font.Code
    btnJitter.TextSize = 13
    btnJitter.Parent = MainFrame

    local btnGlide = Instance.new("TextButton")
    btnGlide.Size = UDim2.new(0.48, 0, 0, 50)
    btnGlide.Position = UDim2.new(0.5, 4, 0.62, 0)
    btnGlide.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
    btnGlide.Text = "⚡ 2. TEST GLIDE (LinearVelocity Perfecto)"
    btnGlide.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnGlide.Font = Enum.Font.Code
    btnGlide.TextSize = 13
    btnGlide.Parent = MainFrame

    btnJitter.MouseButton1Click:Connect(function()
        pcall(function()
            if getgenv().JitterTest then DetenerJitter() btnJitter.Text = "⚡ 1. TEST JITTER (CERO LIMITES)" btnJitter.BackgroundColor3 = Color3.fromRGB(150, 0, 50)
            else IniciarJitter() btnJitter.Text = "🛑 DETENER SATURACIÓN" btnJitter.BackgroundColor3 = Color3.fromRGB(50, 0, 0) end
        end)
    end)
    
    btnGlide.MouseButton1Click:Connect(function()
        pcall(function()
            if getgenv().GlideTest then DetenerGlide() btnGlide.Text = "⚡ 2. TEST GLIDE (LinearVelocity Perfecto)" btnGlide.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
            else IniciarGlide() btnGlide.Text = "🛑 DETENER PATINADOR" btnGlide.BackgroundColor3 = Color3.fromRGB(50, 0, 0) end
        end)
    end)
end

ConstruirUI()
