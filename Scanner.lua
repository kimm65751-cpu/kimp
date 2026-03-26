-- ==============================================================================
-- 🛡️ ANALIZADOR FORENSE ULTIMATE V5 (AUTO-TRACKING Y ANTI-CACHE)
-- Construido con la logica anti-crasheo, tracking pasivo inteligente 
-- y UI fluida con minimizacion + hot reload desde GitHub.
-- ==============================================================================

local SCRIPT_URL = "https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- 🧩 1. CORE LOGGER
local Analyzer = { Logs = {} }

function Analyzer:Clear()
    self.Logs = {}
    if self.UI_LogBox then self.UI_LogBox.Text = "" end
end

function Analyzer:Log(txt)
    print("[FORENSE V5] " .. tostring(txt))
    table.insert(self.Logs, txt)
    if self.UI_LogBox then
        self.UI_LogBox.Text = self.UI_LogBox.Text .. "\n" .. tostring(txt)
    end
end

-- 🌐 2. ANALIZADOR ESTRUCTURAL (RED, ARMAS, Y ZOMBIS)
local StructuralAnalyzer = {}
function StructuralAnalyzer:AnalyzeAll()
    Analyzer:Log("\n==============================================")
    Analyzer:Log("🔍 INICIANDO ESCANEO ESTRUCTURAL PROFUNDO...")

    -- 2.1 RECABAR REMOTES
    local remotes = {}
    local suspicious = {"damage", "hit", "attack", "money", "reward", "exp", "drop", "kill", "die", "spawn", "weapon", "combat", "stat"}
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local nL = string.lower(v.Name)
            for _, word in ipairs(suspicious) do
                if string.find(nL, word) then table.insert(remotes, v); break end
            end
        end
    end
    Analyzer:Log("\n[📡] TOPOLOGIA DE RED:")
    Analyzer:Log(" -> Remotes Sospechosos de Combate/Economía: " .. #remotes)
    for _, r in ipairs(remotes) do
        local info = "   [" .. r.ClassName .. "] " .. r.Name
        if r:IsA("RemoteEvent") and type(getconnections) == "function" then
            local success, conns = pcall(function() return getconnections(r.OnClientEvent) end)
            if success and conns then info = info .. " | Conexiones Servidor->Cliente: " .. #conns end
        end
        Analyzer:Log(info)
    end
    Analyzer:Log(" 💡 CONSEJO DE RED: Identifica aquí arriba el nombre del RemoteEvent exacto de 'Hit/Damage' que usa tu arma.")

    -- 2.2 ARMAS Y HERRAMIENTAS
    Analyzer:Log("\n[🗡️] DISECCION DE TUS ARMAS ACTUALES:")
    local tools = {}
    if LocalPlayer:FindFirstChild("Backpack") then for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do if t:IsA("Tool") then table.insert(tools, t) end end end
    local myChar = LocalPlayer.Character
    if myChar then for _, t in pairs(myChar:GetChildren()) do if t:IsA("Tool") then table.insert(tools, t) end end end
    
    if #tools == 0 then
        Analyzer:Log(" ❌ No tienes armas ni herramientas para analizar.")
    else
        for _, tool in ipairs(tools) do
            Analyzer:Log(" -> [ARMA]: " .. tool.Name)
            local attrs = tool:GetAttributes()
            local attrStr = ""
            for k, v in pairs(attrs) do attrStr = attrStr .. k .. "=" .. tostring(v) .. " " end
            if attrStr ~= "" then Analyzer:Log("  ⚠️ Atributos: " .. attrStr) end
            
            for _, v in pairs(tool:GetDescendants()) do
                if v:IsA("NumberValue") or v:IsA("IntValue") then
                    Analyzer:Log("  ⚙️ Config Value: " .. v.Name .. " = " .. tostring(v.Value))
                elseif v:IsA("ModuleScript") then
                    local n = string.lower(v.Name)
                    if string.find(n, "config") or string.find(n, "setting") or string.find(n, "stat") then
                        Analyzer:Log("  💀 MODULO ENCONTRADO: " .. v.Name .. " (Megasploit de DAÑO INFINITO: require(arma."..v.Name..").Damage = 99999)")
                    end
                end
            end
        end
    end

    -- 2.3 ESTRUCTURA DE ZOMBIS
    Analyzer:Log("\n[🧟] DISECCION CRIPTOGRÁFICA DE ZOMBIS EN EL MAPA:")
    local mobs = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) and obj:FindFirstChild("Humanoid") then
            if not mobs[obj.Name] and obj.Humanoid.Health > 0 then mobs[obj.Name] = obj end
        end
    end
    
    local c = 0
    for name, mob in pairs(mobs) do
        c = c + 1
        Analyzer:Log("\n  > ZOMBI CLASE: " .. name)
        
        local root = mob:FindFirstChild("HumanoidRootPart")
        if root then
            local okAnchor = pcall(function() root.Anchored = true; root.Anchored = false end)
            Analyzer:Log("    - Mutabilidad Fisica: " .. (okAnchor and "PERMITIDA" or "BLOQUEADA POR SERVER"))
            Analyzer:Log("    💡 PARA CONGELARLO LOGICAMENTE (Dejarlo de piedra y robar Network Ownership): `RootPart.Anchored = true`")
        end
        
        local attrs = mob:GetAttributes()
        local attrStr = ""
        for k, v in pairs(attrs) do attrStr = attrStr .. k .. "=" .. tostring(v) .. "  " end
        if attrStr ~= "" then
            Analyzer:Log("    ⚠️ Atributos de IA Nativos: " .. attrStr)
            Analyzer:Log("    💡 CAMBIAR ESTADOS: Manipula estos valores (ej: `IsFrozen` o `Stunned`) desde el cliente para dormirlo.")
        end
    end
    if c == 0 then Analyzer:Log(" ❌ No se encontraron mobs.") end

    Analyzer:Log("==============================================\n")
end

-- ⚔️ 3. COMBATE PASIVO E INTELIGENTE (AUTO-TRACKING)
local AutoTracker = { Active = false, Connections = {}, TrackedZombies = {} }

function AutoTracker:Toggle()
    if self.Active then
        self:Stop()
        return false
    else
        self:Start()
        return true
    end
end

function AutoTracker:Stop()
    for _, conn in ipairs(self.Connections) do pcall(function() conn:Disconnect() end) end
    self.Connections = {}
    self.TrackedZombies = {}
    self.Active = false
    Analyzer:Log("\n[⛔] MONITOR PASIVO DETENIDO. Ya no estamos escuchando el combate.")
end

function AutoTracker:Start()
    self.Active = true
    Analyzer:Log("\n==============================================")
    Analyzer:Log("[✅] ESCUCHA ACTIVA DE COMBATE ENCENDIDA EN SEGUNDO PLANO")
    Analyzer:Log(" -> Pégale al zombi, o deja que te pegue.")
    Analyzer:Log(" -> El sistema interceptará matemáticamente todo el daño, armas y economía de forma automática.")
    Analyzer:Log("==============================================\n")

    -- 3.1 Escuchar mi propia vida (Daño Recibido)
    local function MonitorPlayer(char)
        local hum = char:WaitForChild("Humanoid", 3)
        if hum then
            local lastHp = hum.Health
            table.insert(self.Connections, hum.HealthChanged:Connect(function(newHp)
                if newHp < lastHp then
                    local damage = lastHp - newHp
                    -- Buscar zombi mas cercano para culparlo
                    local mobName = "Zombi Desconocido"
                    local closestD = 999
                    if char.PrimaryPart then
                        for _, z in pairs(Workspace:GetDescendants()) do
                            if z:IsA("Model") and not Players:GetPlayerFromCharacter(z) and z:FindFirstChild("Humanoid") then
                                local r = z:FindFirstChild("HumanoidRootPart")
                                if r then
                                    local dist = (r.Position - char.PrimaryPart.Position).Magnitude
                                    if dist < 20 and dist < closestD then
                                        closestD = dist
                                        mobName = z.Name
                                    end
                                end
                            end
                        end
                    end
                    Analyzer:Log(" 🩸 [DAÑO RECIBIDO] 🩸 El mob [" .. mobName .. "] te hizo " .. string.format("%.1f", damage) .. " de daño de golpe.")
                end
                lastHp = newHp
            end))
        end
    end

    local myChar = LocalPlayer.Character
    if myChar then MonitorPlayer(myChar) end
    table.insert(self.Connections, LocalPlayer.CharacterAdded:Connect(MonitorPlayer))

    -- 3.2 Escuchar los Mobs (Daño Efectuado)
    local function MonitorZombie(mob)
        if self.TrackedZombies[mob] then return end
        local hum = mob:FindFirstChildOfClass("Humanoid")
        if hum then
            self.TrackedZombies[mob] = true
            local lastHp = hum.Health
            table.insert(self.Connections, hum.HealthChanged:Connect(function(newHp)
                if newHp < lastHp then
                    local damage = lastHp - newHp
                    
                    -- Interceptar si tenemos una tool activada justo ahora
                    local myTools = LocalPlayer.Character and LocalPlayer.Character:GetChildren() or {}
                    local activeTool = "Desconocida/Remote"
                    for _, t in pairs(myTools) do if t:IsA("Tool") then activeTool = t.Name end end

                    Analyzer:Log(" 🗡️ [DAÑO INFLIGIDO] 🗡️ Le hiciste " .. string.format("%.1f", damage) .. " a [" .. mob.Name .. "]  -> (Arma asociada: " .. activeTool .. ")")
                end
                lastHp = newHp
                
                if newHp <= 0 then
                    Analyzer:Log(" ☠️ [ELIMINADO] [" .. mob.Name .. "] murió. Monitoreando si el server nos envía drops a las bolsas...")
                end
            end))
        end
    end

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) then MonitorZombie(obj) end
    end
    table.insert(self.Connections, Workspace.DescendantAdded:Connect(function(desc)
        task.wait(1) -- dar tiempo a que cargue su cuerpo
        if desc:IsA("Model") and not Players:GetPlayerFromCharacter(desc) and desc:FindFirstChildOfClass("Humanoid") then
            MonitorZombie(desc)
        end
    end))

    -- 3.3 Escuchar la Economía (Stats y Oro)
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        for _, stat in pairs(leaderstats:GetChildren()) do
            if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                local lastValue = stat.Value
                table.insert(self.Connections, stat:GetPropertyChangedSignal("Value"):Connect(function()
                    local current = stat.Value
                    if tonumber(current) and tonumber(lastValue) then
                        local diff = tonumber(current) - tonumber(lastValue)
                        if diff > 0 then
                            Analyzer:Log(" 💰 [RECOMPENSA ACUMULADA] 💰 El server verificó una kill o minado! Ganaste: +" .. diff .. " " .. stat.Name)
                        end
                    end
                    lastValue = stat.Value
                end))
            end
        end
    end
end

-- ==============================================================================
-- 🖥️ 4. INTERFAZ GRÁFICA V5 (CON MINIMIZADOR, ANTI-CACHE Y ROUND BUTTON)
-- ==============================================================================
local function ConstruirUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "ForenseV5UI"
    sg.ResetOnSpawn = false
    
    local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    for _, v in ipairs(parentUI:GetChildren()) do
        if v.Name == "ForenseV5UI" then v:Destroy() end
    end
    sg.Parent = parentUI

    -- 🔳 FRAME PRINCIPAL
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 800, 0, 580)
    MainFrame.Position = UDim2.new(0.5, -400, 0.5, -290)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.fromRGB(0, 200, 150)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    -- 🔵 BOTON FLOTANTE MAXIMIZAR
    local MaximizeBtn = Instance.new("TextButton")
    MaximizeBtn.Size = UDim2.new(0, 60, 0, 60)
    MaximizeBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
    MaximizeBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    MaximizeBtn.Text = "👁️\nMAX"
    MaximizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MaximizeBtn.Font = Enum.Font.Code
    MaximizeBtn.TextSize = 14
    MaximizeBtn.Active = true
    MaximizeBtn.Draggable = true
    MaximizeBtn.Visible = false -- Oculto al inicio
    -- Hacerlo semi circular puro sin UCorner (Delta bug tolerance) asumiendo que UCorner SI sirve
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = MaximizeBtn
    MaximizeBtn.Parent = sg

    -- Barra Superior
    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -120, 0, 35)
    TopBar.BackgroundColor3 = Color3.fromRGB(0, 60, 100)
    TopBar.Text = "  ANALISIS FORENSE V5 - THE ULTIMATE OBSERVER"
    TopBar.TextColor3 = Color3.fromRGB(200, 255, 200)
    TopBar.Font = Enum.Font.Code
    TopBar.TextSize = 14
    TopBar.TextXAlignment = Enum.TextXAlignment.Left
    TopBar.Parent = MainFrame

    -- Funciones Superiores: Recargar Github, Minimizar, Cerrar
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
    CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.TextSize = 16
    CloseBtn.Parent = MainFrame

    -- Logica Ventanas
    CloseBtn.MouseButton1Click:Connect(function() AutoTracker:Stop(); sg:Destroy() end)
    
    MinimizeBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        MaximizeBtn.Visible = true
    end)
    
    MaximizeBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        MaximizeBtn.Visible = false
    end)

    ReloadBtn.MouseButton1Click:Connect(function()
        pcall(function()
            Analyzer:Log("🔄 Forzando recarga de caché desde GitHub...")
            AutoTracker:Stop()
            sg:Destroy()
            if type(loadstring) == "function" then
                -- Bypass cache brutal para executors testarudos, inyectando loadstring al final del script
                local urlBypass = SCRIPT_URL .. "?reload=" .. tostring(math.random(1000000, 9999999))
                loadstring(game:HttpGet(urlBypass))()
            end
        end)
    end)

    -- Botones Funcionales
    local ScanBtn = Instance.new("TextButton")
    ScanBtn.Size = UDim2.new(0.5, -10, 0, 45)
    ScanBtn.Position = UDim2.new(0, 10, 0, 45)
    ScanBtn.BackgroundColor3 = Color3.fromRGB(150, 80, 0)
    ScanBtn.Text = "1. VER ESTADO DEL SERVIDOR (RED / ARMAS / ZOMBIS)"
    ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScanBtn.Font = Enum.Font.Code
    ScanBtn.TextSize = 12
    ScanBtn.Parent = MainFrame
    
    local AutoBtn = Instance.new("TextButton")
    AutoBtn.Size = UDim2.new(0.5, -15, 0, 45)
    AutoBtn.Position = UDim2.new(0.5, 5, 0, 45)
    AutoBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 50)
    AutoBtn.Text = "2. ACTIVAR AUTO-TRACKER [MODO PASIVO]"
    AutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoBtn.Font = Enum.Font.Code
    AutoBtn.TextSize = 12
    AutoBtn.Parent = MainFrame

    -- Historial Log Display
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -20, 1, -145)
    ScrollFrame.Position = UDim2.new(0, 10, 0, 95)
    ScrollFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
    ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollFrame.ScrollBarThickness = 8
    ScrollFrame.Parent = MainFrame

    local LogText = Instance.new("TextLabel")
    LogText.Size = UDim2.new(1, -15, 1, 0)
    LogText.Position = UDim2.new(0, 5, 0, 5)
    LogText.BackgroundTransparency = 1
    LogText.Text = ">>> FORENSE V5 - AUTO-TRACKING <<<\n\n[Boton 1] Diseccionara tu Arma, el mapa y los Zombis buscando 'ModuleScripts' escondidos y vulnerabilidades estaticas.\n\n[Boton 2] Dejara un ESPÍA escuchando toda la partida. Ataca zombis con naturalidad y deja que te peguen. El Tracker te avisara exactamente cuanto pego, cuanto oro solto y a quien mato de forma pasiva mientras juegas.\n\n"
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
    CopyBtn.BackgroundColor3 = Color3.fromRGB(30, 100, 200)
    CopyBtn.Text = " GUARDAR REPORTE AL PORTAPAPELES "
    CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyBtn.Font = Enum.Font.Code
    CopyBtn.TextSize = 14
    CopyBtn.Parent = MainFrame

    -- Conexion de Eventos
    ScanBtn.MouseButton1Click:Connect(function()
        pcall(function()
            Analyzer:Clear()
            StructuralAnalyzer:AnalyzeAll()
        end)
    end)
    
    AutoBtn.MouseButton1Click:Connect(function()
        pcall(function()
            local isTracking = AutoTracker:Toggle()
            if isTracking then
                AutoBtn.Text = "🛑 DETENER AUTO-TRACKER"
                AutoBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
            else
                AutoBtn.Text = "2. ACTIVAR AUTO-TRACKER [MODO PASIVO]"
                AutoBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 50)
            end
        end)
    end)
    
    CopyBtn.MouseButton1Click:Connect(function()
        pcall(function()
            if type(setclipboard) == "function" then
                setclipboard(LogText.Text)
                CopyBtn.Text = "¡REPORTE COPIADO! PEGATELO EN UN BLOC DE NOTAS."
                task.delay(3, function() CopyBtn.Text = " GUARDAR REPORTE AL PORTAPAPELES " end)
            end
        end)
    end)
end

ConstruirUI()
