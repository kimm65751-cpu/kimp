-- ==============================================================================
-- 🛡️ ANALIZADOR FORENSE ULTIMATE V3 (PROFUNDO, SEGURO, SIN HOOKS)
-- Incorpora analisis intenso de armas, mutacion de zombis y autoridades de red.
-- ==============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- 🧩 1. CORE LOGGER
local Analyzer = { Logs = {} }

function Analyzer:Log(txt)
    print("[FORENSE V3] " .. txt)
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
        if r:IsA("RemoteEvent") and getconnections then
            local success, conns = pcall(function() return getconnections(r.OnClientEvent) end)
            if success and conns then
                info = info .. " | Conexiones Servidor->Cliente: " .. #conns
            end
        end
        Analyzer:Log(info)
    end
    
    Analyzer:Log("\n 💡 CÓMO INTERPRETAR LOS DATOS DE RED:")
    Analyzer:Log("  - Si el juego tiene pocos Remotes (ej. 1 solo llamado 'Combat'), todo se valida en el server.")
    Analyzer:Log("  - Si hay un Event llamado 'DamageMob', tu cliente es quien avisa cuánto daño hace. ¡Vulnerabilidad de Spoofing altísima!")
end

-- 🛡️ 3. ANTI-CHEATS LOCALES
local Security = {}
function Security:Analyze()
    Analyzer:Log("\n[🛡️] ESCANEANDO SEGURIDAD (ANTI-CHEAT LOCAL)...")
    local anticheats = 0
    local acNames = {"ac", "anti", "cheat", "exploit", "admindetect", "speed", "fly"}
    
    for _, v in pairs(Players.LocalPlayer:GetDescendants()) do
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
    if anticheats == 0 then Analyzer:Log(" -> No se encontraron Anti-Cheats locales. Todo se procesa server-side.") end
end

-- 🗡️ 4. ANALISIS PROFUNDO DE ARMAS Y HERRAMIENTAS
local WeaponAnalyzer = {}
function WeaponAnalyzer:Analyze()
    Analyzer:Log("\n[🗡️] DISECCIONANDO TUS ARMAS Y MULTIPLICADORES DE DAÑO...")
    local player = Players.LocalPlayer
    local tools = {}
    
    if player:FindFirstChild("Backpack") then
        for _, t in pairs(player.Backpack:GetChildren()) do if t:IsA("Tool") then table.insert(tools, t) end end
    end
    if player.Character then
        for _, t in pairs(player.Character:GetChildren()) do if t:IsA("Tool") then table.insert(tools, t) end end
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
            Analyzer:Log("  💡 EXPLOIT DETECTADO: El servidor o cliente lee este Atributo para atacar.")
            Analyzer:Log("  🔥 ACCION RECOMENDADA: Usa `arma:SetAttribute('Damage', 99999)` y ve a pegar. Si lo matas de un golpe, el juego confía ciegamente en el cliente.")
        else
            Analyzer:Log("  - Cero atributos nativos expuestos.")
        end
        
        -- Revisar Values Internos o MODULOS de Configuración
        local foundVals = false
        for _, v in pairs(tool:GetDescendants()) do
            if v:IsA("NumberValue") or v:IsA("IntValue") then
                Analyzer:Log("  ⚙️ Config Value: " .. v.Name .. " = " .. tostring(v.Value))
                Analyzer:Log("  🔥 ACCION RECOMENDADA: Cambia este Value (`v.Value = 9999`) y golpea. Puede saltarse el limite de daño.")
                foundVals = true
            elseif v:IsA("ModuleScript") then
                local n = string.lower(v.Name)
                if string.find(n, "config") or string.find(n, "setting") or string.find(n, "stat") then
                    Analyzer:Log("  💀 MODULO CRITICO ENCONTRADO: " .. v:GetFullName())
                    Analyzer:Log("  🔥 MEGASPLOIT: Muchos juegos RPG guardan el daño en un ModuleScript local. Puedes editarlo usando:")
                    Analyzer:Log("      `local cfg = require(arma.Config); cfg.Damage = 99999`")
                end
            end
        end
        if not foundVals then Analyzer:Log("  - El arma es solo un modelo. Todo el calculo de cuanto bajas esta guardado de manera remota en el Server.") end
    end
end

-- 🧟 5. ANALISIS ESTRUCTURAL DE ZOMBIS (MUTACIONES Y CONTROL)
local ZombieAnalyzer = {}
function ZombieAnalyzer:Analyze()
    Analyzer:Log("\n[🧟] ANALIZANDO ADN Y COMPORTAMIENTO LOCAL DE LOS ZOMBIS...")
    local mobs = {}
    
    -- Agrupar un solo especimen de cada zombie para no sobrecargar el log
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) and obj:FindFirstChild("Humanoid") then
            if not mobs[obj.Name] and obj.Humanoid.Health > 0 then mobs[obj.Name] = obj end
        end
    end
    
    local keys = {}
    for k in pairs(mobs) do table.insert(keys, k) end
    if #keys == 0 then
        Analyzer:Log(" ❌ No se encontraron zombis vivos en el mapa cercano.")
        return
    end
    
    Analyzer:Log(" -> Se analizará la vulnerabilidad de " .. #keys .. " especies distintas:")
    for _, name in pairs(keys) do
        local mob = mobs[name]
        Analyzer:Log("\n  > ZOMBI: " .. name)
        
        -- 1. Evaluando IA y Scripts
        local scripts = 0
        for _, s in pairs(mob:GetDescendants()) do
            if s:IsA("Script") or s:IsA("LocalScript") then scripts = scripts + 1 end
        end
        Analyzer:Log("    - Inteligencia: " .. scripts .. " scripts internos (Si son LocalScripts, puedes desactivarlos con .Disabled = true).")
        
        -- 2. Evaluando Network Ownership y Mutación (Piedra)
        local root = mob:FindFirstChild("HumanoidRootPart")
        if root then
            local okAnchor = pcall(function() root.Anchored = true; root.Anchored = false end)
            if okAnchor then
                Analyzer:Log("    - Mutabilidad Física: PERMITIDA. Las partes no están bloqueadas por el servidor.")
                Analyzer:Log("    💡 COMO VOLVERLO PIEDRA: `RootPart.Anchored = true`. Si al hacerlo el zombi deja de perseguirte para ti, significa que la física del zombi la calcula tu PC (Client Network Ownership). Eres intocable.")
            else
                Analyzer:Log("    - Mutabilidad Física: BLOQUEADA (Strict Server-Side).")
            end
        end
        
        -- 3. Atributos de Control y Manipulación de stats
        local attrs = mob:GetAttributes()
        local attrStr = ""
        for k, v in pairs(attrs) do attrStr = attrStr .. k .. "=" .. tostring(v) .. "  " end
        if attrStr ~= "" then
            Analyzer:Log("    ⚠️ Atributos de Status EXPUESTOS: " .. attrStr)
            Analyzer:Log("    💡 Puedes volverlo piedra logica: `mob:SetAttribute('Stunned', true)` o cambiar su `Damage` a 0 si existe el atributo. ¡Fuerzalo aunque no lo use, a veces el motor lo lee!")
        else
            Analyzer:Log("    - Sin Atributos de Status. Para evitar el daño toca interceptar Hitboxes (TouchTransmitters) o atacar teletransportándote por sus espaldas a 5 studs siempre (Farm).")
        end
    end
end

-- ⚔️ 6. COMBATE, DAÑO Y RECOMPENSAS
local Combat = {}
function Combat:AnalyzeMob(durationTime)
    Analyzer:Log("\n[⚔️] AISLANDO MOB MAS CERCANO PARA ANALISIS DE DAÑO EXACTO...")
    
    local p = Players.LocalPlayer
    local myChar = p.Character
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
        Analyzer:Log(" ❌ ERROR: ACERCATE A UN ZOMBI PARA ANALIZARLO. No puedo calcular DPS fantasmas.")
        return
    end
    
    Analyzer:Log(" -> OBJETIVO FIJADO: " .. mob.Name .. " | Distancia: " .. string.format("%.1f", mDist) .. "m")

    Analyzer:Log("\n[⏱️] MONITOREO DE " .. durationTime .. " SEGS (¡GOLPÉALO Y DEJA QUE TE GOLPEE!)")
    
    local InitialMyHp = myHum and myHum.Health or 0
    local InitialMobHp = mHum.Health
    
    local statFolder = p:FindFirstChild("leaderstats")
    local InitialMoney = 0
    local mainStat = nil
    if statFolder then
        mainStat = statFolder:GetChildren()[1]
        if mainStat then InitialMoney = mainStat.Value end
    end
    
    local HitCountReceived = 0
    local HitConnection
    if myHum then
        HitConnection = myHum.HealthChanged:Connect(function(newHp)
            if newHp < InitialMyHp then HitCountReceived = HitCountReceived + 1 end
        end)
    end
    
    -- Monitorear
    for i = 1, durationTime * 10 do
        if mHum.Health <= 0 then break end
        task.wait(0.1)
    end
    
    if HitConnection then HitConnection:Disconnect() end
    
    local FinalMyHp = myHum and myHum.Health or 0
    local FinalMobHp = mHum.Health
    local FinalMoney = mainStat and mainStat.Value or 0
    
    local myDamageTaken = InitialMyHp - FinalMyHp
    local mobDamageTaken = InitialMobHp - FinalMobHp
    local reward = FinalMoney - InitialMoney

    Analyzer:Log("\n[📊] METRICAS FINALES DE COMBATE:")
    
    -- Analisis del daño que nosotros hacemos (Bajar vida al Mob)
    Analyzer:Log(" 🗡️ DAÑO INFLIGIDO (Lo que tú le bajaste al Mob): " .. string.format("%.1f", mobDamageTaken))
    if mobDamageTaken > 0 then
        local dmgPerSec = mobDamageTaken / durationTime
        Analyzer:Log("   -> DPS TUYO: " .. string.format("%.1f", dmgPerSec))
        Analyzer:Log("   -> EL SERVIDOR CONFIRMÓ TUS GOLPES. Intenta testear ahora con los Attributes cambiados como te dije arriba a ver si tu DPS de 1 se vuelve de 9999.")
    else
        Analyzer:Log("   -> 0 Daño validado. O estás fallando, o requieres enviar un Remote especifico que no estás activando.")
    end
    
    -- Analisis del daño que el Mob nos hace (Estrategias de Inmunidad)
    Analyzer:Log("\n 🩸 DAÑO RECIBIDO (Lo que el Mob te logró pegar): " .. string.format("%.1f", myDamageTaken))
    if myDamageTaken > 0 then
        local damagePerHit = HitCountReceived > 0 and (myDamageTaken / HitCountReceived) or myDamageTaken
        Analyzer:Log("   -> IMPACTOS CONTADOS: " .. HitCountReceived)
        Analyzer:Log("   -> EL ZOMBI BAJA APROX: " .. string.format("%.1f", damagePerHit) .. " DE VIDA POR CADA GOLPE.")
        Analyzer:Log("   💡 COMO HACER PARA QUE NO TE PEGUE:")
        Analyzer:Log("      1. FÍSICO (Touch): Borra sus hitboxes `TouchTransmitter`.")
        Analyzer:Log("      2. POSICIÓN (Safe-Spot): El Bot de farmeo debe ubicarse a `CFrame.new(0,0, -7)` studs a la espalda del zombi todo el tiempo. Como los mobs usan raycast frontal, ignorarán si estás atorado en su mochila.")
        Analyzer:Log("      3. ESTADO (Piedra): Destruye todo LocalScript dentro del zombi y ánclalo o aplícale un Atributo `Stunned = true`.")
    else
        Analyzer:Log("   -> Inmune. No sufriste daños esta ronda.")
    end
    
    -- Analisis de recompensas (Economía Server vs Client)
    if InitialMobHp > 0 and FinalMobHp <= 0 then
        Analyzer:Log("\n ☠️ MOB DESTRUIDO!")
        if reward > 0 then
            Analyzer:Log("   -> 💰 RECOMPENSA VALIDADA: +" .. reward .. " " .. (mainStat and mainStat.Name or "oro"))
            Analyzer:Log("   -> FLUJO ECONOMICO: El servidor vinculó el asesinato contifo. Existe altísima chance de poder spoofear (engańar) al sistema de recompensa mandando el Remote que da 'Kill' sin haberle pegado.")
        else
            Analyzer:Log("   -> ❓ No se detectaron recompensas agregadas en sus 'leaderstats'. El Loot puede ser físico (monedas en el suelo).")
        end
    end
end

-- ==============================================================================
-- 🖥️ 7. INTERFAZ GRÁFICA V3 (PANEL PRINCIPAL DE ESTUDIO)
-- ==============================================================================
local function ConstruirUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "ForenseV3UI"
    sg.ResetOnSpawn = false
    
    local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or Players.LocalPlayer:WaitForChild("PlayerGui")
    for _, v in ipairs(parentUI:GetChildren()) do
        if v.Name == "ForenseV3UI" then v:Destroy() end
    end
    sg.Parent = parentUI

    -- Fondo General
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 800, 0, 580)
    MainFrame.Position = UDim2.new(0.5, -400, 0.5, -290)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.fromRGB(200, 150, 0)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    -- Barra Superior
    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -40, 0, 35)
    TopBar.BackgroundColor3 = Color3.fromRGB(180, 100, 0)
    TopBar.Text = "  ANALISIS PROFUNDO V3 (RED, ARMAS, MUTACIONES Y DAÑO)"
    TopBar.TextColor3 = Color3.fromRGB(255, 255, 255)
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

    -- Boton 1: Scanner Global
    local ScanBtn = Instance.new("TextButton")
    ScanBtn.Size = UDim2.new(0.5, -10, 0, 45)
    ScanBtn.Position = UDim2.new(0, 10, 0, 45)
    ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
    ScanBtn.Text = "1. FORENSE ESTRUCTURAL (RED, ARMAS Y ZOMBIES)"
    ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScanBtn.Font = Enum.Font.Code
    ScanBtn.TextSize = 12
    ScanBtn.Parent = MainFrame
    
    -- Boton 2: Combat Scanner
    local CombatBtn = Instance.new("TextButton")
    CombatBtn.Size = UDim2.new(0.5, -15, 0, 45)
    CombatBtn.Position = UDim2.new(0.5, 5, 0, 45)
    CombatBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    CombatBtn.Text = "2. ANALIZAR DAÑOS Y RECOMPENSAS (5s DE PELEA)"
    CombatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CombatBtn.Font = Enum.Font.Code
    CombatBtn.TextSize = 12
    CombatBtn.Parent = MainFrame

    -- Are de Logs Auto-Scrolling
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -20, 1, -145)
    ScrollFrame.Position = UDim2.new(0, 10, 0, 95)
    ScrollFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollFrame.ScrollBarThickness = 8
    ScrollFrame.Parent = MainFrame

    local LogText = Instance.new("TextLabel")
    LogText.Size = UDim2.new(1, -15, 1, 0)
    LogText.Position = UDim2.new(0, 5, 0, 5)
    LogText.BackgroundTransparency = 1
    LogText.Text = ">>> FORENSE ULTIMATE V3 <<<\n\n[Boton 1] Analizará todos los zombis buscando vulnerabilidades (cómo volverlos de piedra), analizará todas las armas buscando formas de pasarnos del límite de daño, y verá la seguridad de red del juego.\n\n[Boton 2] Medirá matemáticamente cuánto daño te hace el zombi por golpe, calculando la manera óptima de volverse inmortal al farmearlo, y checando de dónde viene la economía.\n\n"
    LogText.TextColor3 = Color3.fromRGB(150, 255, 255)
    LogText.Font = Enum.Font.Code
    LogText.TextSize = 13
    LogText.TextXAlignment = Enum.TextXAlignment.Left
    LogText.TextYAlignment = Enum.TextYAlignment.Top
    LogText.TextWrapped = true
    LogText.Parent = ScrollFrame

    Analyzer.UI_LogBox = LogText

    -- Boton Copiar
    local CopyBtn = Instance.new("TextButton")
    CopyBtn.Size = UDim2.new(1, -20, 0, 35)
    CopyBtn.Position = UDim2.new(0, 10, 1, -45)
    CopyBtn.BackgroundColor3 = Color3.fromRGB(30, 200, 50)
    CopyBtn.Text = "GUARDAR Y COPIAR REPORTE AL PORTAPAPELES"
    CopyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    CopyBtn.Font = Enum.Font.Code
    CopyBtn.TextSize = 14
    CopyBtn.Parent = MainFrame

    -- Lógica Botones
    ScanBtn.MouseButton1Click:Connect(function()
        Analyzer:Clear()
        Analyzer:Log("\n==============================================")
        Network:Analyze()
        Security:Analyze()
        WeaponAnalyzer:Analyze()
        ZombieAnalyzer:Analyze()
        Analyzer:Log("\n==============================================\n")
    end)
    
    CombatBtn.MouseButton1Click:Connect(function()
        Analyzer:Clear()
        Analyzer:Log("==============================================")
        CombatBtn.Text = "¡ESTAS EN COMBATE! ATACALO AHORA (5 SEGUNDOS)"
        CombatBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        Combat:AnalyzeMob(5) -- 5 segundos de monitoreo de impactos activos
        
        CombatBtn.Text = "2. ANALIZAR DAÑOS Y RECOMPENSAS (5s DE PELEA)"
        CombatBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        Analyzer:Log("==============================================\n")
    end)
    
    CopyBtn.MouseButton1Click:Connect(function()
        pcall(function()
            if setclipboard then
                setclipboard(LogText.Text)
                CopyBtn.Text = "¡REPORTE COPIADO! PEGATELO EN UN BLOC DE NOTAS."
                task.delay(3, function() CopyBtn.Text = "GUARDAR Y COPIAR REPORTE AL PORTAPAPELES" end)
            end
        end)
    end)
end

ConstruirUI()
