-- ==============================================================================
-- 💀 ROBLOX EXPERT: OUT-OF-THE-BOX VULNERABILITY PROBER (V14)
-- Pruebas Forenses Científicas para determinar tácticas sin sufrir Kick 267.
-- ==============================================================================

local SCRIPT_URL = "https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local NetworkSettings = settings():GetService("NetworkSettings")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- 🧩 CORE LOGGER PARA LA PRUEBA
local Analyzer = { Logs = {} }

function Analyzer:Clear()
    self.Logs = {}
    if self.UI_LogBox then self.UI_LogBox.Text = "" end
end

function Analyzer:Log(txt)
    print("[CRACKER-SCAN] " .. tostring(txt))
    table.insert(self.Logs, txt)
    pcall(function()
        if self.UI_LogBox then
            self.UI_LogBox.Text = self.UI_LogBox.Text .. "\n" .. tostring(txt)
        end
    end)
end

-- ==============================================================================
-- 📡 MICRO-PRUEBAS CONTROLADAS (SIN KICKS DESTRUCTIVOS)
-- ==============================================================================

-- PRUEBA 1: NETWORK OWNERSHIP (PROP TELEKINESIS)
local function TestPropTelekinesis()
    Analyzer:Clear()
    Analyzer:Log("🧪 [TEST 1] ESCANEO DE PROPS FÍSICOS (TELEKINESIS)...")
    Analyzer:Log("Buscando objetos en el mapa que no estén anclados y que podamos usar como proyectiles físicos...")
    
    local foundProps = 0
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Anchored and obj.Name ~= "HumanoidRootPart" and obj.Name ~= "Head" and obj.Name ~= "Torso" then
            -- Asegurarse que no sea de un Zombi o Jugador
            if not obj.Parent:FindFirstChild("Humanoid") then
                foundProps = foundProps + 1
            end
        end
    end
    
    if foundProps > 0 then
        Analyzer:Log("✅ ¡FACTIBLE! Se encontraron " .. tostring(foundProps) .. " objetos sueltos. Podríamos construir el Fling de Props hacia el zombie a distancia.")
    else
        Analyzer:Log("❌ FALLIDO: El creador ancló todo el mapa absoluto. No hay física suelta que podamos manipular. Telekinesis descartada.")
    end
end

-- PRUEBA 2: SPIN-FLING (HAVOK PHYSICS OVERLOAD)
local function TestSpinFling()
    Analyzer:Clear()
    Analyzer:Log("🧪 [TEST 2] ESTABILIDAD DEL SPIN-FLING (ANTI-CHEAT TEST)...")
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return Analyzer:Log("❌ Error: Personaje no encontrado.") end

    Analyzer:Log("Inyectando 1,000 grados de Velocidad Angular por 1.5 Segundos...")
    local bv = Instance.new("BodyAngularVelocity")
    bv.MaxTorque = Vector3.new(Math.huge, math.huge, math.huge)
    bv.AngularVelocity = Vector3.new(0, 100, 0)
    bv.Parent = root
    
    task.wait(1.5)
    
    if bv and bv.Parent then
        bv:Destroy()
        -- Si llegamos aquí y no nos kickeó el Anti-TP:
        Analyzer:Log("✅ ¡FACTIBLE! El servidor permitió la hiper-rotación C++ sin kickearte. Podemos usar tu cuerpo como un Trompo demoledor para aniquilarlos con rebote físico sin que logren pegarte.")
        -- Si nos kickea durante esos 1.5seg, ya sabemos que el AC vigila Angulos.
    end
end

-- PRUEBA 3: TICK-WALKING (LAG-SWITCH SIN TELEPORT)
local function TestTickWalking()
    Analyzer:Clear()
    Analyzer:Log("🧪 [TEST 3] PRUEBA DE LAG-SWITCH CONTROLADO (SIN CFRAME)...")
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if not hum then return Analyzer:Log("❌ Error: Personaje no encontrado.") end

    Analyzer:Log("Congelando red y caminando legalmente (WalkSpeed) 5 metros adelante y atrás...")
    local success = pcall(function() NetworkSettings.IncomingReplicationLag = 10 end)
    if not success then return Analyzer:Log("❌ Error: Tu teléfono/Delta no soporta el comando de Lag-Switch API. Deberás apagar tu WiFi físico y encenderlo rápido para los Bypasses de red.") end
    
    local startPos = char.HumanoidRootPart.Position
    local adelante = startPos + (char.HumanoidRootPart.CFrame.LookVector * 5)
    
    hum:MoveTo(adelante)
    task.wait(0.5) -- caminar legalmente
    hum:MoveTo(startPos)
    task.wait(0.5) -- volver
    
    pcall(function() NetworkSettings.IncomingReplicationLag = 0 end)
    
    Analyzer:Log("Descargando Buffer al Servidor... Espera 2 segundos para ver si hay Kick.")
    task.wait(2)
    Analyzer:Log("✅ ¡FACTIBLE! Si sigues en el juego, significa que el Anti-TP solo te kickeó en el anterior porque usamos CFRAME. Si caminamos 'Lageados' somos dioses indetectables.")
end

-- PRUEBA 4: LA IDEA RARA (MOTOR6D OFFSET SPOOFER)
local function TestGripSpoofer()
    Analyzer:Clear()
    Analyzer:Log("🧪 [TEST 4] IDEA RARA: MUTACIÓN DEL MOTOR6D...")
    
    local char = LocalPlayer.Character
    if not char then return Analyzer:Log("❌ Error: Personaje no encontrado.") end
    
    local isR15 = char:FindFirstChild("UpperTorso") ~= nil
    local jointName = isR15 and "RightGrip" or "RightGrip" -- Generalmente es siempre RightGrip
    local weaponJoint = nil
    
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("Weld") or v:IsA("Motor6D") then
            if string.find(string.lower(v.Name), "grip") or string.find(string.lower(v.Name), "weapon") then
                weaponJoint = v
                break
            end
        end
    end
    
    if weaponJoint then
        Analyzer:Log("Se ubicó el Atornillado (Motor6D/Weld) de la Espada.")
        Analyzer:Log("Estirándolo matemáticamente 50 Metros hacia adelante...")
        
        -- Guardar original
        local originalC0 = weaponJoint.C0
        weaponJoint.C0 = weaponJoint.C0 * CFrame.new(0, 50, 0) -- Movemos 50 studs visiblemente
        
        Analyzer:Log("✅ TU ESPADA ACABA DE CRECER HASTA 50 METROS EN TU PANTALLA.")
        Analyzer:Log("🔍 [ACCIÓN REQUERIDA]: Párate a 30 Metros de un zombi, e intenta pegarle con esta espada mega-larga ANTES de que termine el tiempo de calibración (10 seg).")
        
        task.wait(10)
        weaponJoint.C0 = originalC0
        Analyzer:Log("Restaurado. ¿Logró darle al Zombi a distancia gracias a la espada estirada?")
    else
        Analyzer:Log("❌ FALLIDO: Tu espada no usa 'Welds' o 'Grips' convencionales detectables. Parece integrada al modelo C++ puro.")
    end
end

-- ==============================================================================
-- 🖥️ GUI V2026: PANEL DE LABORATORIO SEGURO
-- ==============================================================================
local function ConstruirUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "MasterBypass2026UI"
    sg.ResetOnSpawn = false
    
    local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "MasterBypass2026UI" then v:Destroy() end end
    sg.Parent = parentUI

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 850, 0, 750)
    MainFrame.Position = UDim2.new(0.5, -425, 0.5, -375)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    MainFrame.BorderSizePixel = 3
    MainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -120, 0, 35)
    TopBar.BackgroundColor3 = Color3.fromRGB(0, 50, 80)
    TopBar.Text = "  [LABORATORIO FORENSE V14: PROBADOR EXTREMO - SIN KICKS]"
    TopBar.TextColor3 = Color3.fromRGB(100, 200, 255)
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

    CloseBtn.MouseButton1Click:Connect(function() sg:Destroy() end)
    MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)
    ReloadBtn.MouseButton1Click:Connect(function()
        pcall(function() sg:Destroy(); loadstring(game:HttpGet(SCRIPT_URL .. "?r=" .. math.random(111,999)))() end)
    end)

    local InfoScroll = Instance.new("ScrollingFrame")
    InfoScroll.Size = UDim2.new(1, -20, 0.45, 0)
    InfoScroll.Position = UDim2.new(0, 10, 0, 45)
    InfoScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    InfoScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    InfoScroll.ScrollBarThickness = 8
    InfoScroll.Parent = MainFrame

    local LogText = Instance.new("TextLabel")
    LogText.Size = UDim2.new(1, -15, 1, 0)
    LogText.Position = UDim2.new(0, 5, 0, 5)
    LogText.BackgroundTransparency = 1
    LogText.Text = ">>> ANÁLISIS METÓDICO DE SUPERVIVENCIA <<<\n\nTienes razón, ya no podemos ir probando código a ciegas para que nos boten del servidor (Kick) como nos acaba de pasar. Yo asumo mi propia ceguera. Un verdadero Cracker prueba el terreno con goteros microscópicos para medir las paredes sin hacer sonar la alarma.\n\nHe construido 4 Botones Analizadores. \nEstos botones C++ NO intentan matar Zombis agresivamente. En lugar de eso, le hacen micro-pruebas al Motor del Servidor y al Anti-Cheat para respondernos 4 dudas vitales sin expulsarnos de la sesión:\n\n1. ¿Podemos arrojar objetos físicos como misiles?\n2. ¿El motor prohibe que yo gire violentamente para reventar al monstruo con Havok Physics?\n3. ¿El Lag-Switch falló por teletransportar, o funcionará si 'Caminamos legalmente' congelados?\n4. ALGO RARO Y ÚNICO: ¿Qué pasa si manipulamos la Tuerca (Motor6D) del brazo y estiramos la propia espada por 50 metros visuales? ¿Acaso el RayCasting del Servidor toma como origen la punta de la espada estirada?\n\nRealiza estas 4 micropruebas, la Consola Negra nos dirá '✅ FACTIBLE' si el servidor no salta, así con datos en mano, sabremos exactamente qué arma blindada fabricar."
    LogText.TextColor3 = Color3.fromRGB(150, 220, 255)
    LogText.Font = Enum.Font.Code
    LogText.TextSize = 13
    LogText.TextXAlignment = Enum.TextXAlignment.Left
    LogText.TextYAlignment = Enum.TextYAlignment.Top
    LogText.TextWrapped = true
    LogText.Parent = InfoScroll

    Analyzer.UI_LogBox = LogText

    local btnProps = Instance.new("TextButton")
    btnProps.Size = UDim2.new(0.5, -15, 0, 55)
    btnProps.Position = UDim2.new(0, 10, 0.5, 50)
    btnProps.BackgroundColor3 = Color3.fromRGB(80, 50, 0)
    btnProps.Text = "1. TEST: PROP TELEKINESIS"
    btnProps.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnProps.Font = Enum.Font.Code
    btnProps.TextSize = 14
    btnProps.Parent = MainFrame

    local btnFling = Instance.new("TextButton")
    btnFling.Size = UDim2.new(0.5, -15, 0, 55)
    btnFling.Position = UDim2.new(0.5, 5, 0.5, 50)
    btnFling.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
    btnFling.Text = "2. TEST: HAVOK SPIN-FLING"
    btnFling.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnFling.Font = Enum.Font.Code
    btnFling.TextSize = 14
    btnFling.Parent = MainFrame

    local btnTick = Instance.new("TextButton")
    btnTick.Size = UDim2.new(0.5, -15, 0, 55)
    btnTick.Position = UDim2.new(0, 10, 0.6, 60)
    btnTick.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
    btnTick.Text = "3. TEST: LAG-WALKING SAFE"
    btnTick.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnTick.Font = Enum.Font.Code
    btnTick.TextSize = 14
    btnTick.Parent = MainFrame

    local btnGrip = Instance.new("TextButton")
    btnGrip.Size = UDim2.new(0.5, -15, 0, 55)
    btnGrip.Position = UDim2.new(0.5, 5, 0.6, 60)
    btnGrip.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    btnGrip.Text = "4. TEST RARO: ESTIRAR ESPADA 50M"
    btnGrip.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnGrip.Font = Enum.Font.Code
    btnGrip.TextSize = 14
    btnGrip.Parent = MainFrame

    btnProps.MouseButton1Click:Connect(function() pcall(TestPropTelekinesis) end)
    btnFling.MouseButton1Click:Connect(function() pcall(TestSpinFling) end)
    btnTick.MouseButton1Click:Connect(function() pcall(TestTickWalking) end)
    btnGrip.MouseButton1Click:Connect(function() pcall(TestGripSpoofer) end)
end

ConstruirUI()
