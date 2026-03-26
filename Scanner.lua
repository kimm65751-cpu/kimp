-- ==============================================================================
-- 🛡️ ANALIZADOR FORENSE ULTIMATE V4 (BULLETPROOF)
-- Construido con la logica anti-crasheo y validaciones estrictas
-- ==============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- 🧩 1. CORE LOGGER
local Analyzer = { Logs = {} }

function Analyzer:Clear()
    self.Logs = {}
    if self.UI_LogBox then
        self.UI_LogBox.Text = ""
    end
end

function Analyzer:Log(txt)
    print("[FORENSE V4] " .. txt)
    table.insert(self.Logs, txt)
    if self.UI_LogBox then
        self.UI_LogBox.Text = self.UI_LogBox.Text .. "\n" .. txt
    end
end

-- 🌐 2. ANALISIS DE RED 
local Network = {}
function Network:Analyze()
    Analyzer:Log("\n[📡] ANALIZANDO TOPOLOGÍA DE RED Y CONEXIONES...")
    local remotes = {}
    local suspicious = {"damage", "hit", "attack", "money", "reward", "exp", "drop", "kill", "die", "spawn", "weapon", "combat", "stat"}
    
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local nL = string.lower(v.Name)
            for _, word in ipairs(suspicious) do
                if string.find(nL, word) then
                    table.insert(remotes, v)
                    break
                end
            end
        end
    end
    
    Analyzer:Log(" -> Remotes Críticos Detectados: " .. #remotes)
    for _, r in ipairs(remotes) do
        local info = "   [" .. r.ClassName .. "] " .. r:GetFullName()
        
        -- Validacion estricta para getconnections
        if r:IsA("RemoteEvent") and type(getconnections) == "function" then
            local success, conns = pcall(function() return getconnections(r.OnClientEvent) end)
            if success and conns then
                info = info .. " | Conexiones S->C: " .. #conns
            end
        end
        Analyzer:Log(info)
    end
end

-- 🛡️ 3. ANTI-CHEATS LOCALES
local Security = {}
function Security:Analyze()
    Analyzer:Log("\n[🛡️] ESCANEANDO SEGURIDAD (ANTI-CHEAT LOCAL)...")
    local anticheats = 0
    local acNames = {"ac", "anti", "cheat", "exploit", "admindetect", "speed", "fly"}
    
    for _, v in pairs(LocalPlayer:GetDescendants()) do
        if v:IsA("LocalScript") then
            local nL = string.lower(v.Name)
            for _, word in ipairs(acNames) do
                if string.find(nL, word) then
                    Analyzer:Log(" ⚠️ AntiCheat/Monitor Local: " .. v:GetFullName())
                    anticheats = anticheats + 1
                    break
                end
            end
        end
    end
    if anticheats == 0 then Analyzer:Log(" -> No se encontraron Anti-Cheats locales evidentes.") end
end

-- 🗡️ 4. ANALISIS PROFUNDO DE ARMAS Y HERRAMIENTAS
local WeaponAnalyzer = {}
function WeaponAnalyzer:Analyze()
    Analyzer:Log("\n[🗡️] DISECCIONANDO TUS ARMAS Y MULTIPLICADORES...")
    local tools = {}
    
    if LocalPlayer:FindFirstChild("Backpack") then
        for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do if t:IsA("Tool") then table.insert(tools, t) end end
    end
    
    local myChar = LocalPlayer.Character
    if myChar then
        for _, t in pairs(myChar:GetChildren()) do if t:IsA("Tool") then table.insert(tools, t) end end
    end
    
    if #tools == 0 then
        Analyzer:Log(" ❌ No tienes armas equipadas o en la mochila.")
        return
    end
    
    for _, tool in ipairs(tools) do
        Analyzer:Log("\n -> [ARMA]: " .. tool.Name)
        
        -- Revisar Atributos
        local attrs = tool:GetAttributes()
        local attrStr = ""
        for k, v in pairs(attrs) do attrStr = attrStr .. k .. "=" .. tostring(v) .. " " end
        if attrStr ~= "" then
            Analyzer:Log("  ⚠️ Atributos Base: " .. attrStr)
        else
            Analyzer:Log("  - Cero atributos nativos expuestos.")
        end
        
        -- Revisar Values Internos o MODULOS de Configuración
        local foundVals = false
        for _, v in pairs(tool:GetDescendants()) do
            if v:IsA("NumberValue") or v:IsA("IntValue") then
                Analyzer:Log("  ⚙️ Config Value: " .. v.Name .. " = " .. tostring(v.Value))
                foundVals = true
            elseif v:IsA("ModuleScript") then
                local n = string.lower(v.Name)
                if string.find(n, "config") or string.find(n, "setting") or string.find(n, "stat") then
                    Analyzer:Log("  💀 MODULO DE VARIABLES ENCONTRADO: " .. v:GetFullName())
                    Analyzer:Log("  🔥 EXPLOIT: Usa `require(arma."..v.Name..").Damage = 99999`.")
                end
            end
        end
        if not foundVals then Analyzer:Log("  - El arma es solo un modelo. Todo el calculo esta en el Server.") end
    end
end

-- 🧟 5. ANALISIS ESTRUCTURAL DE ZOMBIS
local ZombieAnalyzer = {}
function ZombieAnalyzer:Analyze()
    Analyzer:Log("\n[🧟] ANALIZANDO ESTRUCTURA DE ZOMBIS...")
    local mobs = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) and obj:FindFirstChild("Humanoid") then
            if not mobs[obj.Name] and obj.Humanoid.Health > 0 then mobs[obj.Name] = obj end
        end
    end
    
    local keys = {}
    for k in pairs(mobs) do table.insert(keys, k) end
    if #keys == 0 then
        Analyzer:Log(" ❌ No se encontraron zombis vivos.")
        return
    end
    
    for _, name in pairs(keys) do
        local mob = mobs[name]
        Analyzer:Log("\n  > ZOMBI: " .. name)
        
        local scripts = 0
        for _, s in pairs(mob:GetDescendants()) do
            if s:IsA("Script") or s:IsA("LocalScript") then scripts = scripts + 1 end
        end
        Analyzer:Log("    - Inteligencia: " .. scripts .. " scripts internos.")
        
        local root = mob:FindFirstChild("HumanoidRootPart")
        if root then
            local okAnchor = pcall(function() root.Anchored = true; root.Anchored = false end)
            Analyzer:Log("    - Mutabilidad Física: " .. (okAnchor and "Sin error al anclar" or "Protegido por server"))
            Analyzer:Log("    💡 AVISO: `pcall` no detecta si el server revierte el anclaje físico, solo si da error de permisos. Pruebalo en combate.")
        end
        
        local attrs = mob:GetAttributes()
        local attrStr = ""
        for k, v in pairs(attrs) do attrStr = attrStr .. k .. "=" .. tostring(v) .. "  " end
        if attrStr ~= "" then
            Analyzer:Log("    ⚠️ Atributos de IA: " .. attrStr)
        end
    end
end

-- ⚔️ 6. COMBATE, DAÑO Y RECOMPENSAS
local Combat = {}
function Combat:AnalyzeMob(durationTime)
    Analyzer:Log("\n[⚔️] AISLANDO MOB MAS CERCANO PARA ANALISIS DE DAÑO...")
    
    local myChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChild("Humanoid")
    
    local mob, mRoot, mHum, mDist = nil, nil, nil, math.huge
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) then
            local h = obj:FindFirstChildOfClass("Humanoid")
            local r = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
            if h and h.Health > 0 and r then
                local d = myRoot and (myRoot.Position - r.Position).Magnitude or 9999
                if d < mDist then mDist=d; mob=obj; mRoot=r; mHum=h end
            end
        end
    end
    
    if not mob then
        Analyzer:Log(" ❌ ERROR: ACERCATE A UN ZOMBI PARA ANALIZARLO.")
        return
    end
    
    Analyzer:Log(" -> OBJETIVO FIJADO: " .. mob.Name .. " | Distancia: " .. string.format("%.1f", mDist) .. "m")
    Analyzer:Log("\n[⏱️] MONITOREO DE " .. durationTime .. " SEGS (¡ATACALO / DEJA QUE TE PEGUE!)")
    
    local InitialMyHp = myHum and myHum.Health or 0
    local InitialMobHp = mHum.Health
    
    local InitialMoney = 0
    local mainStat = nil
    local statFolder = LocalPlayer:FindFirstChild("leaderstats")
    
    -- Validacion segura del leaderstats
    if statFolder then
        local stats = statFolder:GetChildren()
        if #stats > 0 then
            mainStat = stats[1]
            if mainStat:IsA("ValueBase") then InitialMoney = tonumber(mainStat.Value) or 0 end
        end
    end
    
    local HitCountReceived = 0
    local HitConnection
    if myHum then
        HitConnection = myHum.HealthChanged:Connect(function(newHp)
            if newHp < InitialMyHp then HitCountReceived = HitCountReceived + 1 end
        end)
    end
    
    for i = 1, durationTime * 10 do
        if mHum.Health <= 0 then break end
        task.wait(0.1)
    end
    
    if HitConnection then HitConnection:Disconnect() end
    
    local FinalMyHp = myHum and myHum.Health or 0
    local FinalMobHp = mHum.Health
    local FinalMoney = mainStat and tonumber(mainStat.Value) or 0
    
    local myDamageTaken = InitialMyHp - FinalMyHp
    local mobDamageTaken = InitialMobHp - FinalMobHp
    local reward = FinalMoney - InitialMoney

    Analyzer:Log("\n[📊] METRICAS FINALES DE COMBATE:")
    
    Analyzer:Log(" 🗡️ DAÑO QUE LE HICISTE: " .. string.format("%.1f", mobDamageTaken))
    if mobDamageTaken > 0 then
        Analyzer:Log("   -> DPS TUYO: " .. string.format("%.1f", mobDamageTaken / durationTime))
    end
    
    Analyzer:Log("\n 🩸 DAÑO QUE RECIBISTE: " .. string.format("%.1f", myDamageTaken))
    if myDamageTaken > 0 then
        local damagePerHit = HitCountReceived > 0 and (myDamageTaken / HitCountReceived) or myDamageTaken
        Analyzer:Log("   -> GOLPES RECIBIDOS: " .. HitCountReceived)
        Analyzer:Log("   -> DAÑO PROMEDIO POR GOLPE: " .. string.format("%.1f", damagePerHit))
    end
    
    if InitialMobHp > 0 and FinalMobHp <= 0 then
        Analyzer:Log("\n ☠️ MOB DESTRUIDO!")
        if reward > 0 then
            Analyzer:Log("   -> 💰 RECOMPENSA OBTENIDA: +" .. reward .. " " .. (mainStat and mainStat.Name or "monedas"))
        else
            Analyzer:Log("   -> ❓ No hubo recompensa en leaderstats locales.")
        end
    end
end

-- ==============================================================================
-- 🖥️ 7. INTERFAZ GRÁFICA V4 (CON MANEJO SEGURO DE PROPIEDADES)
-- ==============================================================================
local function ConstruirUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "ForenseV4UI"
    sg.ResetOnSpawn = false
    
    local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    for _, v in ipairs(parentUI:GetChildren()) do
        if v.Name == "ForenseV4UI" then v:Destroy() end
    end
    sg.Parent = parentUI

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 800, 0, 580)
    MainFrame.Position = UDim2.new(0.5, -400, 0.5, -290)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 100)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -40, 0, 35)
    TopBar.BackgroundColor3 = Color3.fromRGB(0, 70, 40)
    TopBar.Text = "  ANALISIS FORENSE V4 (BULLETPROOF)"
    TopBar.TextColor3 = Color3.fromRGB(200, 255, 200)
    TopBar.Font = Enum.Font.Code
    TopBar.TextSize = 14
    TopBar.TextXAlignment = Enum.TextXAlignment.Left
    TopBar.Parent = MainFrame

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

    local ScanBtn = Instance.new("TextButton")
    ScanBtn.Size = UDim2.new(0.5, -10, 0, 45)
    ScanBtn.Position = UDim2.new(0, 10, 0, 45)
    ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
    ScanBtn.Text = "1. FORENSE ESTRUCTURAL (RED, ARMAS Y ZOMBIES)"
    ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScanBtn.Font = Enum.Font.Code
    ScanBtn.TextSize = 12
    ScanBtn.Parent = MainFrame
    
    local CombatBtn = Instance.new("TextButton")
    CombatBtn.Size = UDim2.new(0.5, -15, 0, 45)
    CombatBtn.Position = UDim2.new(0.5, 5, 0, 45)
    CombatBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    CombatBtn.Text = "2. ANALIZAR DAÑOS Y RECOMPENSAS (5s DE PELEA)"
    CombatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CombatBtn.Font = Enum.Font.Code
    CombatBtn.TextSize = 12
    CombatBtn.Parent = MainFrame

    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -20, 1, -145)
    ScrollFrame.Position = UDim2.new(0, 10, 0, 95)
    ScrollFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
    
    -- Fix para ScrollingFrame basado en tu sugerencia (borramos CanvasSize UDim de 0,0,0,0 que confunde al motor)
    ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollFrame.ScrollBarThickness = 8
    ScrollFrame.Parent = MainFrame

    local LogText = Instance.new("TextLabel")
    LogText.Size = UDim2.new(1, -15, 1, 0)
    LogText.Position = UDim2.new(0, 5, 0, 5)
    LogText.BackgroundTransparency = 1
    LogText.Text = ">>> FORENSE V4 <<<\n\n[Boton 1] Analizara tu arma buscando ModuleScripts vulnerables, remotes criticos y zombis.\n\n[Boton 2] Medira matematicamente tu combate (Dano recibido por golpe y oro obtenido al morir el mob).\n\n"
    LogText.TextColor3 = Color3.fromRGB(150, 255, 255)
    LogText.Font = Enum.Font.Code
    LogText.TextSize = 13
    LogText.TextXAlignment = Enum.TextXAlignment.Left
    LogText.TextYAlignment = Enum.TextYAlignment.Top
    LogText.TextWrapped = true
    LogText.Parent = ScrollFrame

    Analyzer.UI_LogBox = LogText

    local CopyBtn = Instance.new("TextButton")
    CopyBtn.Size = UDim2.new(1, -20, 0, 35)
    CopyBtn.Position = UDim2.new(0, 10, 1, -45)
    CopyBtn.BackgroundColor3 = Color3.fromRGB(30, 200, 50)
    CopyBtn.Text = " GUARDAR REPORTE"
    CopyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    CopyBtn.Font = Enum.Font.Code
    CopyBtn.TextSize = 14
    CopyBtn.Parent = MainFrame

    ScanBtn.MouseButton1Click:Connect(function()
        pcall(function()
            Analyzer:Clear()
            Analyzer:Log("\n==============================================")
            Network:Analyze()
            Security:Analyze()
            WeaponAnalyzer:Analyze()
            ZombieAnalyzer:Analyze()
            Analyzer:Log("\n==============================================\n")
        end)
    end)
    
    CombatBtn.MouseButton1Click:Connect(function()
        pcall(function()
            Analyzer:Clear()
            Analyzer:Log("==============================================")
            CombatBtn.Text = "MIDIENDO... !ATACA!"
            CombatBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
            
            Combat:AnalyzeMob(5)
            
            CombatBtn.Text = "2. ANALIZAR DAÑOS Y RECOMPENSAS (5s DE PELEA)"
            CombatBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
            Analyzer:Log("==============================================\n")
        end)
    end)
    
    CopyBtn.MouseButton1Click:Connect(function()
        pcall(function()
            if type(setclipboard) == "function" then
                setclipboard(LogText.Text)
                CopyBtn.Text = "¡REPORTE COPIADO! PEGATELO EN UN BLOC DE NOTAS."
                task.delay(3, function() CopyBtn.Text = " GUARDAR REPORTE " end)
            else
                CopyBtn.Text = "SE REQUIERE UN EXECUTOR CON SETCLIPBOARD PARA ESTO"
                task.delay(3, function() CopyBtn.Text = " GUARDAR REPORTE " end)
            end
        end)
    end)
end

ConstruirUI()
