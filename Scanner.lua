-- ==============================================================================
-- 🛡️ ANALIZADOR FORENSE ULTIMATE V6 (CON MÓDULO ESPÍA DE KILLAURA)
-- Construido con la logica anti-crasheo, tracking pasivo inteligente, 
-- UI fluida con minimizacion, hot reload, y un Robador de Paquetes Visual integrado.
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
    print("[FORENSE V6] " .. tostring(txt))
    table.insert(self.Logs, txt)
    if self.UI_LogBox then
        self.UI_LogBox.Text = self.UI_LogBox.Text .. "\n" .. tostring(txt)
    end
end

-- 🌐 2. ANALIZADOR ESTRUCTURAL
local StructuralAnalyzer = {}
function StructuralAnalyzer:AnalyzeAll()
    Analyzer:Log("\n==============================================")
    Analyzer:Log("🔍 INICIANDO ESCANEO ESTRUCTURAL PROFUNDO...")

    local remotes = {}
    local suspicious = {"damage", "hit", "attack", "money", "reward", "exp", "drop", "kill", "die", "spawn", "weapon", "combat", "stat", "hitbox"}
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local nL = string.lower(v.Name)
            for _, word in ipairs(suspicious) do
                if string.find(nL, word) then table.insert(remotes, v); break end
            end
        end
    end
    Analyzer:Log("\n[📡] TOPOLOGIA DE RED:")
    Analyzer:Log(" -> Remotes Sospechosos: " .. #remotes)
    for _, r in ipairs(remotes) do
        local info = "   [" .. r.ClassName .. "] " .. r.Name
        if r:IsA("RemoteEvent") and type(getconnections) == "function" then
            local success, conns = pcall(function() return getconnections(r.OnClientEvent) end)
            if success and conns then info = info .. " | Conexiones S->C: " .. #conns end
        end
        Analyzer:Log(info)
    end

    Analyzer:Log("\n[🗡️] DISECCION DE ARMAS:")
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
        end
    end

    Analyzer:Log("\n[🧟] DISECCION DE ZOMBIS:")
    local mobs = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) and obj:FindFirstChild("Humanoid") then
            if not mobs[obj.Name] and obj.Humanoid.Health > 0 then mobs[obj.Name] = obj end
        end
    end
    for name, mob in pairs(mobs) do
        Analyzer:Log("\n  > ZOMBI CLASE: " .. name)
        local root = mob:FindFirstChild("HumanoidRootPart")
        if root then
            local okAnchor = pcall(function() root.Anchored = true; root.Anchored = false end)
            Analyzer:Log("    - Mutabilidad Fisica: " .. (okAnchor and "PERMITIDA" or "BLOQUEADA POR SERVER"))
        end
    end
    Analyzer:Log("==============================================\n")
end

-- ⚔️ 3. AUTO-TRACKER PASIVO
local AutoTracker = { Active = false, Connections = {}, TrackedZombies = {} }

function AutoTracker:Toggle()
    if self.Active then
        for _, conn in ipairs(self.Connections) do pcall(function() conn:Disconnect() end) end
        self.Connections = {}
        self.TrackedZombies = {}
        self.Active = false
        Analyzer:Log("\n[⛔] MONITOR PASIVO DETENIDO.")
        return false
    else
        self.Active = true
        Analyzer:Log("\n==============================================")
        Analyzer:Log("[✅] ESCUCHA PASIVA DE COMBATE ENCENDIDA")
        Analyzer:Log("==============================================\n")

        local function MonitorPlayer(char)
            local hum = char:WaitForChild("Humanoid", 3)
            if hum then
                local lastHp = hum.Health
                table.insert(self.Connections, hum.HealthChanged:Connect(function(newHp)
                    if newHp < lastHp then
                        Analyzer:Log(" 🩸 [DAÑO RECIBIDO] 🩸 El server registra que perdiste " .. string.format("%.1f", lastHp - newHp) .. " de HP.")
                    end
                    lastHp = newHp
                end))
            end
        end

        local myChar = LocalPlayer.Character
        if myChar then MonitorPlayer(myChar) end
        table.insert(self.Connections, LocalPlayer.CharacterAdded:Connect(MonitorPlayer))

        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if leaderstats then
            for _, stat in pairs(leaderstats:GetChildren()) do
                if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                    local lastValue = stat.Value
                    table.insert(self.Connections, stat:GetPropertyChangedSignal("Value"):Connect(function()
                        if tonumber(stat.Value) and tonumber(lastValue) then
                            local diff = tonumber(stat.Value) - tonumber(lastValue)
                            if diff > 0 then Analyzer:Log(" 💰 [RECOMPENSA] Ganaste: +" .. diff .. " " .. stat.Name) end
                        end
                        lastValue = stat.Value
                    end))
                end
            end
        end
        return true
    end
end

-- 🔪 4. MÓDULO ESPÍA DE PAQUETES (BUSCADOR DE KILLAURA)
local SpyModule = { Active = false, Hook = nil }

local function MostrarSpyPopup(mensaje, colorFondo)
    local sg = Instance.new("ScreenGui")
    sg.Name = "SpoofedPopupUI"
    local cgOk = pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not cgOk then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    
    for _, v in pairs(sg.Parent:GetChildren()) do
        if v.Name == "SpoofedPopupUI" and v ~= sg then v:Destroy() end
    end
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -225)
    MainFrame.BackgroundColor3 = colorFondo or Color3.fromRGB(0, 40, 100)
    MainFrame.BorderSizePixel = 3
    MainFrame.BorderColor3 = Color3.new(1,1,1)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg
    
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -20, 1, -80)
    Scroll.Position = UDim2.new(0, 10, 0, 10)
    Scroll.BackgroundTransparency = 1
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Scroll.ScrollBarThickness = 6
    Scroll.Parent = MainFrame
    
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, -10, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.fromRGB(230, 230, 230)
    txt.TextSize = 13
    txt.Font = Enum.Font.Code
    txt.TextWrapped = true
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.TextYAlignment = Enum.TextYAlignment.Top
    txt.Text = " 🛑 ALERTA DEL ESPÍA:\n\n" .. tostring(mensaje)
    txt.Parent = Scroll
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 45)
    btn.Position = UDim2.new(0, 10, 1, -55)
    btn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    btn.Text = "CERRAR ESTE POPUP"
    btn.Font = Enum.Font.ArialBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = MainFrame
    btn.MouseButton1Click:Connect(function() sg:Destroy() end)
    
    local btnCopy = Instance.new("TextButton")
    btnCopy.Size = UDim2.new(1, -20, 0, 20)
    btnCopy.Position = UDim2.new(0, 10, 1, -80)
    btnCopy.BackgroundColor3 = Color3.fromRGB(30, 150, 50)
    btnCopy.Text = "COPIAR ESTOS DATOS"
    btnCopy.Font = Enum.Font.Code
    btnCopy.TextSize = 12
    btnCopy.TextColor3 = Color3.new(1,1,1)
    btnCopy.Parent = MainFrame
    btnCopy.MouseButton1Click:Connect(function() 
        pcall(function() 
            if type(setclipboard) == "function" then 
                setclipboard(txt.Text) 
                btnCopy.Text = "COPIADO!" 
                task.delay(1, function() btnCopy.Text = "COPIAR" end)
            end
        end) 
    end)
end

function SpyModule:ToggleHookMetamethod()
    if self.Active then
        Analyzer:Log("❌ Desactivando Espia de Paquetes. (Nota: Hookmetamethod sigue inyectado de forma pasiva por arquitectura de executors, recarga el script para eliminarlo 100%).")
        self.Active = false
        return false
    end

    local HitboxClassRemote = nil
    for _, v in pairs(game:GetDescendants()) do
        if v.Name == "HitboxClassRemote" then
            HitboxClassRemote = v
            break
        end
    end

    if not HitboxClassRemote then 
        MostrarSpyPopup("❌ FATAL: No se encontró HitboxClassRemote en el mapa. Asegurate de que tu arma este equipada.", Color3.fromRGB(150, 50, 0))
        return false
    end

    if type(hookmetamethod) ~= "function" then
        MostrarSpyPopup("❌ FATAL: Tu executor tiene la función 'hookmetamethod' deshabilitada.", Color3.fromRGB(150, 0, 0))
        return false
    end
    
    self.Active = true
    Analyzer:Log("\n🛡️ [ESPÍA C++] INYECTADO CORRECTAMENTE.\n-> Ataca ahora a un zombi con tu espada. Si el HitboxClassRemote se dispara cruzando la barrera del motor, secuestraremos la tabla de empaquetado y saltará un POPUP en tu pantalla.\n")
    
    -- Inyectamos Hook 
    if not self.Hook then
        local spySuccess, spyError = pcall(function()
            self.Hook = hookmetamethod(game, "__namecall", function(selfArg, ...)
                local method = getnamecallmethod()
                
                if SpyModule.Active and selfArg == HitboxClassRemote and (method == "FireServer" or method == "InvokeServer") then
                    local args = {...}
                    task.spawn(function()
                        local logStr = "====== 🎯 SE HA EJECUTADO UN ATAQUE ======\n"
                        logStr = logStr .. "El Remoto 'HitboxClassRemote' acaba de enviar esta estructura para validación de KillAura:\n\n"
                        for i, p in pairs(args) do
                            logStr = logStr .. "▶ ARGUMENTO " .. i .. " [Tipo: " .. type(p) .. "]\n"
                            if type(p) == "table" then
                                for k, v in pairs(p) do 
                                    local valStr = tostring(v)
                                    if typeof(v) == "Instance" then valStr = "<Objeto: " .. v.Name .. ">" end
                                    logStr = logStr .. "   ["..tostring(k).."] = ".. valStr .."\n" 
                                end
                            elseif typeof(p) == "Instance" then
                                logStr = logStr .. "   (INSTANCIA): " .. p.Name .. "\n"
                            else
                                logStr = logStr .. "   " .. tostring(p) .. "\n"
                            end
                        end
                        logStr = logStr .. "\n\nCopia esta información. Con esta tabla de argumentos enviaremos bucles infinitos por segundo."
                        MostrarSpyPopup(logStr, Color3.fromRGB(0, 50, 150))
                    end)
                end
                
                return SpyModule.Hook(selfArg, ...)
            end)
        end)
        
        if not spySuccess then
            self.Active = false
            MostrarSpyPopup("❌ CRASH INTERNO: " .. tostring(spyError), Color3.fromRGB(150, 0, 0))
            return false
        end
    end
    
    return true
end

-- ==============================================================================
-- 🖥️ 5. INTERFAZ GRÁFICA GIGANTE (V6)
-- ==============================================================================
local function ConstruirUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "ForenseV6UI"
    sg.ResetOnSpawn = false
    
    local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    for _, v in ipairs(parentUI:GetChildren()) do
        if v.Name == "ForenseV6UI" then v:Destroy() end
    end
    sg.Parent = parentUI

    -- 🔳 FRAME PRINCIPAL
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 800, 0, 600)
    MainFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
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
    MaximizeBtn.Visible = false
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = MaximizeBtn
    MaximizeBtn.Parent = sg

    -- Barra Superior
    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -120, 0, 35)
    TopBar.BackgroundColor3 = Color3.fromRGB(0, 60, 100)
    TopBar.Text = "  ANALISIS FORENSE V6 - + ESPIA DE KILLAURA INCLUIDO"
    TopBar.TextColor3 = Color3.fromRGB(200, 255, 200)
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
    CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.TextSize = 16
    CloseBtn.Parent = MainFrame

    CloseBtn.MouseButton1Click:Connect(function() AutoTracker:Stop(); SpyModule.Active = false; sg:Destroy() end)
    MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; MaximizeBtn.Visible = true end)
    MaximizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true; MaximizeBtn.Visible = false end)
    ReloadBtn.MouseButton1Click:Connect(function()
        pcall(function()
            Analyzer:Log("🔄 Recargando bypass de caché...")
            AutoTracker:Stop()
            SpyModule.Active = false
            sg:Destroy()
            if type(loadstring) == "function" then
                loadstring(game:HttpGet(SCRIPT_URL .. "?reload=" .. tostring(math.random(11111, 99999))))()
            end
        end)
    end)

    -- Botones de Accion (Acomodados en fila de 3 para la V6)
    local ScanBtn = Instance.new("TextButton")
    ScanBtn.Size = UDim2.new(0.33, -10, 0, 45)
    ScanBtn.Position = UDim2.new(0, 10, 0, 45)
    ScanBtn.BackgroundColor3 = Color3.fromRGB(150, 80, 0)
    ScanBtn.Text = "1. ESCÁNEO DE\nESTRUCTURA MUNDIAL"
    ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScanBtn.Font = Enum.Font.Code
    ScanBtn.TextSize = 11
    ScanBtn.Parent = MainFrame
    
    local AutoBtn = Instance.new("TextButton")
    AutoBtn.Size = UDim2.new(0.33, -10, 0, 45)
    AutoBtn.Position = UDim2.new(0.33, 5, 0, 45)
    AutoBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 50)
    AutoBtn.Text = "2. AUTO-TRACKER\nCOMBATE PASIVO"
    AutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoBtn.Font = Enum.Font.Code
    AutoBtn.TextSize = 11
    AutoBtn.Parent = MainFrame

    local SpyBtn = Instance.new("TextButton")
    SpyBtn.Size = UDim2.new(0.33, -10, 0, 45)
    SpyBtn.Position = UDim2.new(0.66, 0, 0, 45)
    SpyBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
    SpyBtn.Text = "3. INYECTAR ESPÍA \nPARA KILLAURA (C++)"
    SpyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpyBtn.Font = Enum.Font.Code
    SpyBtn.TextSize = 11
    SpyBtn.Parent = MainFrame

    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -20, 1, -145)
    ScrollFrame.Position = UDim2.new(0, 10, 0, 100)
    ScrollFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
    ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollFrame.ScrollBarThickness = 8
    ScrollFrame.Parent = MainFrame

    local LogText = Instance.new("TextLabel")
    LogText.Size = UDim2.new(1, -15, 1, 0)
    LogText.Position = UDim2.new(0, 5, 0, 5)
    LogText.BackgroundTransparency = 1
    LogText.Text = ">>> FORENSE V6 <<<\n\n[BOTON 3 AÑADIDO]: El inyector de hookmetamethod ya fue incorporado como un bloque protegido (Spy Module).\nSi tocas el Botón 3, el executor esperará a que des un espadazo real al aire o al zombi. En cuanto HitboxClassRemote mande los datos C++ envueltos, saltará una GUI roja emergente (Popup) robandose absolutamente todos esos datos al instante para poder crear un KillAura infinito basándonos en ellos.\n\n"
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

    ScanBtn.MouseButton1Click:Connect(function()
        pcall(function() Analyzer:Clear(); StructuralAnalyzer:AnalyzeAll() end)
    end)
    
    AutoBtn.MouseButton1Click:Connect(function()
        pcall(function()
            local isTracking = AutoTracker:Toggle()
            if isTracking then
                AutoBtn.Text = "🛑 DETENER\nAUTO-TRACKER"
                AutoBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
            else
                AutoBtn.Text = "2. AUTO-TRACKER\nCOMBATE PASIVO"
                AutoBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 50)
            end
        end)
    end)

    SpyBtn.MouseButton1Click:Connect(function()
        pcall(function()
            local spyEncedido = SpyModule:ToggleHookMetamethod()
            if spyEncedido then
                SpyBtn.Text = "🛑 APAGAR\nESPÍA C++"
                SpyBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 80)
            else
                SpyBtn.Text = "3. INYECTAR ESPÍA \nPARA KILLAURA (C++)"
                SpyBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
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
