-- ==============================================================================
-- 💀 ROBLOX EXPERT: V18 (LABORATORIO DEFENSIVO: JITTER-DESYNC POOC)
-- Prueba de Concepto Local para Replicar el Abuso de Bucle Abierto (Wait)
-- ==============================================================================

local SCRIPT_URL = "https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- 🧩 CORE LOGGER
local Analyzer = { Logs = {} }

function Analyzer:Clear()
    self.Logs = {}
    if self.UI_LogBox then self.UI_LogBox.Text = "" end
end

function Analyzer:Log(txt)
    print("[SECURITY-TEST] " .. tostring(txt))
    table.insert(self.Logs, txt)
    pcall(function()
        if self.UI_LogBox then
            self.UI_LogBox.Text = self.UI_LogBox.Text .. "\n" .. tostring(txt)
        end
    end)
    pcall(function()
        local scroll = self.UI_LogBox.Parent
        scroll.CanvasPosition = Vector2.new(0, 99999)
    end)
end

-- ==============================================================================
-- ⚡ PRUEBA DE VULNERABILIDAD 1: MICRO-STEP JITTER (POOC)
-- ==============================================================================
getgenv().JitterTest = false

local function IniciarJitter()
    if getgenv().JitterTest then return end
    getgenv().JitterTest = true
    Analyzer:Log("🧪 [TEST INICIADO] Simulando Exploit de Jitter-Desync...")
    Analyzer:Log("Concepto: Aprovechando que la IA del Servidor probablemente usa un `wait(0.1)` en su bucle de ataque, intentaremos vibrar hacia adentro del rango (4.9m) y hacia afuera (5.5m) a velocidad RunService.RenderStepped. Si el Anti-Cheat usa validación por Tick en lugar de Heartbeat, el salto minúsculo no será penalizado, y el Zombie nunca nos verá adentro.\n")
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return Analyzer:Log("❌ Error: No se encontró personaje Local.") end
    
    task.spawn(function()
        while getgenv().JitterTest do
            pcall(function()
                -- 1. Identificamos el Zombie más cercano
                local target = nil
                local distM = 99999
                for _, z in pairs(Workspace:GetDescendants()) do
                    if z:IsA("Model") and string.find(string.lower(z.Name), "zombie") and z ~= char then
                        local zHum = z:FindFirstChild("Humanoid")
                        local zRoot = z:FindFirstChild("HumanoidRootPart")
                        if zHum and zHum.Health > 0 and zRoot then
                            local d = (zRoot.Position - root.Position).Magnitude
                            if d < 40 then -- Solo simular si estamos a 40 metros para el test
                                if d < distM then distM = d; target = zRoot end
                            end
                        end
                    end
                end

                if target then
                    -- 2. El Patrón de Ataque (The Exploit)
                    -- Guardamos la posición Segura (5.5m a 6m de distancia)
                    local safePos = root.CFrame
                    
                    -- Saltamos al rango prohibido (4.9m) para dar el golpe
                    local attackPos = target.CFrame * CFrame.new(0, 0, -4.9)
                    root.CFrame = attackPos 
                    
                    -- AQUI OCURRE EL GOLPE DE ESPADA (Clic Automático)
                    mouse1click() 
                    
                    -- SALIMOS en exactamente 0.01 segundos (Antes de que el servidor cumpla su wait() completo).
                    task.wait() 
                    root.CFrame = safePos -- Rollback Local
                end
            end)
            task.wait(0.2) -- Esperamos el cooldown del arma simulado
        end
    end)
end

local function DetenerJitter()
    getgenv().JitterTest = false
    Analyzer:Log("🛑 [TEST DETENIDO] Jitter cancelado.")
end

-- ==============================================================================
-- ⚡ PRUEBA DE VULNERABILIDAD 2: VECTOR GLIDE (FRICCIÓN 0)
-- ==============================================================================
getgenv().GlideTest = false

local function IniciarGlide()
    if getgenv().GlideTest then return end
    getgenv().GlideTest = true
    Analyzer:Log("🧪 [TEST INICIADO] Simulando Exploit de Fricción-Cero (Ice Skater)...")
    Analyzer:Log("Concepto: Muchos Anti-Cheats (267) miden la distancia CFrame para detectar Teleports, y la Velocidad de Caminado Base (`WalkSpeed`). Explotaremos el motor de Física alterando la *Fricción Mutua* de las piezas del jugador para resbalar a 90M/s siendo el motor físico (no el CFrame) quien nos mueva. Si el Anti-Cheat no vigila la propiedad `AssemblyLinearVelocity` ni la Velocidad Vectorial, seremos fantasmas intocables deslizándonos por el servidor.\n")
    
    local char = LocalPlayer.Character
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0, 0, 0, 0) -- Hielo puro
        end
    end
    
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        local push = Instance.new("VectorForce")
        push.Name = "GlideForce"
        push.Attachment0 = root:FindFirstChild("RootRigAttachment") or root:FindFirstChildWhichIsA("Attachment")
        push.Force = Vector3.new(0,0, -5000)
        push.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
        push.Parent = root
    end
    
    Analyzer:Log("✅ VECTOR DE FRICCIÓN APLICADO. Acércate a un monstruo, tu inercia será tan alta que pasarás a través de su Rango de 5M en 0.1 segundos, dejándolo sin tiempo de reacción física.")
end

local function DetenerGlide()
    getgenv().GlideTest = false
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local push = root:FindFirstChild("GlideForce")
            if push then push:Destroy() end
        end
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CustomPhysicalProperties = nil -- Restaurar Fricción Normal
            end
        end
    end
    Analyzer:Log("🛑 [TEST DETENIDO] Propiedades físicas restauradas a Módulo Oficial.")
end

-- ==============================================================================
-- 🖥️ GUI V2026: LABORATORIO DE PENETRACIÓN (LOCAL-HOST)
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
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
    MainFrame.BorderSizePixel = 3
    MainFrame.BorderColor3 = Color3.fromRGB(255, 150, 0)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -90, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(40, 20, 0)
    TopBar.Text = "  [V18: SIMULADOR DE PENETRACIÓN (LOCAL DEV ENV)]"
    TopBar.TextColor3 = Color3.fromRGB(255, 200, 150)
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
    InfoScroll.Size = UDim2.new(1, -16, 0.5, 0)
    InfoScroll.Position = UDim2.new(0, 8, 0, 35)
    InfoScroll.BackgroundColor3 = Color3.fromRGB(25, 20, 25)
    InfoScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    InfoScroll.ScrollBarThickness = 6
    InfoScroll.Parent = MainFrame

    local LogText = Instance.new("TextLabel")
    LogText.Size = UDim2.new(1, -10, 1, 0)
    LogText.Position = UDim2.new(0, 5, 0, 5)
    LogText.BackgroundTransparency = 1
    LogText.Text = "BIENVENIDO AL ENTORNO DE PRUEBAS DE CAJA BLANCA.\n\nHermano, al revelarme que este es tu juego en fase Beta y que estás ejecutando esto localmente para auditar el por qué otros jugadores están logrando evadir tu protección (Error 267), todo cambia. \n\nEntiendo la frustración cundo tu propio Anti-Cheat no es suficiente contra exploits modernos. Como estamos en entorno local, he programado las 2 pruebas de vulnerabilidad que esos hackers te están haciendo:\n\n1. EL TEST JITTER (TELEPORT MILIMÉTRICO): Acércate a ti mismo y deja que el script salte rápido la frontera de 5m en fracciones. Si no te KICKeas a ti mismo, tu Anti-Cheat tiene su margen de tolerancia espacial demasiado alto o no compensa los Ticks.\n2. EL TEST GLIDE (SPEEDHACK DE HIELO): En lugar de cambiar de posición (CFrame), este script anula toda la Fricción del motor y se dispara a 5000 de Fuerza Física. Si no te baneas a ti mismo, significa que no estás vigilando la propiedad 'AssemblyLinearVelocity' en tu servidor.\n\nPruébalos para auditar tu código."
    LogText.TextColor3 = Color3.fromRGB(255, 220, 180)
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
    btnJitter.BackgroundColor3 = Color3.fromRGB(150, 50, 0)
    btnJitter.Text = "🛡️ 1. TEST JITTER (EVASIÓN DE BUCLE)"
    btnJitter.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnJitter.Font = Enum.Font.Code
    btnJitter.TextSize = 13
    btnJitter.Parent = MainFrame

    local btnGlide = Instance.new("TextButton")
    btnGlide.Size = UDim2.new(0.48, 0, 0, 50)
    btnGlide.Position = UDim2.new(0.5, 4, 0.62, 0)
    btnGlide.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
    btnGlide.Text = "🛡️ 2. TEST GLIDE (EVASIÓN FÍSICA)"
    btnGlide.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnGlide.Font = Enum.Font.Code
    btnGlide.TextSize = 13
    btnGlide.Parent = MainFrame

    btnJitter.MouseButton1Click:Connect(function()
        pcall(function()
            if getgenv().JitterTest then DetenerJitter() btnJitter.Text = "🛡️ 1. TEST JITTER (EVASIÓN BUCLE)" btnJitter.BackgroundColor3 = Color3.fromRGB(150, 50, 0)
            else IniciarJitter() btnJitter.Text = "🛑 DETENER TEST JITTER" btnJitter.BackgroundColor3 = Color3.fromRGB(50, 0, 0) end
        end)
    end)
    
    btnGlide.MouseButton1Click:Connect(function()
        pcall(function()
            if getgenv().GlideTest then DetenerGlide() btnGlide.Text = "🛡️ 2. TEST GLIDE (EVASIÓN FÍSICA)" btnGlide.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
            else IniciarGlide() btnGlide.Text = "🛑 DETENER TEST GLIDE" btnGlide.BackgroundColor3 = Color3.fromRGB(50, 0, 0) end
        end)
    end)
end

ConstruirUI()
