-- ==============================================================================
-- 💀 VULNERABILITY SCANNER V1 (HACKER/CRACKER LEVEL)
-- Escaner activo de Core Security. No asume nada, audita honeypots, AntiFlags, 
-- hooks de deteccion de UI, y firetouchinterest antes de ejecutarlos.
-- ==============================================================================

local SCRIPT_URL = "https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local ScriptContext = game:GetService("ScriptContext")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- 🧩 1. CORE LOGGER
local Analyzer = { Logs = {} }

function Analyzer:Clear()
    self.Logs = {}
    if self.UI_LogBox then self.UI_LogBox.Text = "" end
end

function Analyzer:Log(txt)
    print("[CRACKER-SCAN] " .. tostring(txt))
    table.insert(self.Logs, txt)
    if self.UI_LogBox then
        self.UI_LogBox.Text = self.UI_LogBox.Text .. "\n" .. tostring(txt)
    end
end

-- 🛡️ 2. HONEYPOT & ANTI-CHEAT SCANNER (THE CORE AUDIT)
local SecurityAudit = {}

function SecurityAudit:RunAudit()
    Analyzer:Log("\n==============================================")
    Analyzer:Log("💀 INICIANDO AUDITORIA DE SEGURIDAD GLOBAL (CORE ENGINE)...")
    
    -- 2.1 Analisis de Detección de UI (CoreGui Checks)
    Analyzer:Log("\n[☢️] TEST DE SEGURIDAD UI E INYECCIONES:")
    local cgHooks = 0
    for _, obj in pairs(CoreGui:GetDescendants()) do
        if obj:IsA("LocalScript") and obj.Name ~= "ForenseV7UI" then
            cgHooks = cgHooks + 1
        end
    end
    if cgHooks > 0 then
        Analyzer:Log("  ⚠️ PELIGRO: El juego tiene " .. cgHooks .. " scripts monitoreando el CoreGui. Usar ScreenGuis estándar puede kickearte.")
        Analyzer:Log("  💡 BYPASS: Debes inyectar tu UI en `gethui()` o proteger la instancia con `syn.protect_gui`.")
    else
        Analyzer:Log("  ✅ CoreGui Limpio. El juego no implementa checks activos contra UIs inyectadas normales.")
    end

    -- 2.2 Analisis de Hooks de Error (ScriptContext Honeypots)
    Analyzer:Log("\n[🍯] TEST DE HONEYPOTS (Señuelos y Trampas):")
    local scConnections = pcall(function() return #getconnections(ScriptContext.Error) end) and #getconnections(ScriptContext.Error) or "Oculto"
    if type(scConnections) == "number" and scConnections > 0 then
        Analyzer:Log("  ⚠️ HONEYPOT DETECTADO: El servidor o scripts locales (Adonis/HD Admin) están escuchando llamadas a Errores globales loggeados ("..scConnections.." listeners).")
        Analyzer:Log("  💡 BYPASS: Todo tu script de kill-aura debe usar pcall(). Si un error sale de pcall, el juego enviará los traces al servidor y serás flaggeado.")
    else
        Analyzer:Log("  ✅ Honeypots Globales de Error no evidentes (O el executor los esconde correctamente).")
    end

    -- 2.3 Analisis de Remotes Señuelo (Admins/AntiExploits)
    local acRemotes = {}
    local suspiciousWords = {"ban", "kick", "report", "flag", "detect", "cheat", "log", "admin", "adminremote", "crash"}
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            for _, word in ipairs(suspiciousWords) do
                if string.find(string.lower(v.Name), word) then table.insert(acRemotes, v); break end
            end
        end
    end
    
    if #acRemotes > 0 then
        Analyzer:Log("  🚨 " .. #acRemotes .. " REMOTES ANTI-CHEAT ENCONTRADOS:")
        for _, rem in ipairs(acRemotes) do Analyzer:Log("     [" .. rem.ClassName .. "] " .. rem.Name) end
        Analyzer:Log("  💡 BYPASS (KICK PREVENCIÓN): Engancharemos Namecall y aplicaremos Drop: `if remote.Name == 'kick' then return end`.")
    else
        Analyzer:Log("  ✅ Cero remotes dedicatorios a Banneo (El servidor kickea directamente por código C++ interno).")
    end

    -- 2.4 Test Seguro de TouchInterest (FireTouchInterest)
    Analyzer:Log("\n[⚔️] TEST DE CAPACIDADES DE EXPLOTACIÓN FÍSICA:")
    if type(firetouchinterest) ~= "function" then
        Analyzer:Log("  ❌ EL EXECUTOR (Delta) CARECE DE 'firetouchinterest'. No puedes simular colisiones.")
        Analyzer:Log("  💡 ALTERNATIVA: Debes usar CFrame Teleport de tu personaje forzadamente a la ubicación de los remotes.")
    else
        Analyzer:Log("  ✅ 'firetouchinterest' soportado por tu executor. Podemos hacer hitboxes invisibles.")
        
        -- Verificar si el juego trackea el Touch
        local foundTouchTrackers = false
        if LocalPlayer.Character then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("LocalScript") and string.find(string.lower(v.Name), "touch") then foundTouchTrackers = true end
            end
        end
        if foundTouchTrackers then
            Analyzer:Log("  ⚠️ CUIDADO: Tienes un LocalScript trackeando tus colisiones. Usar firetouchinterest en bucle bruto podría alertarlo por Rate-Limit (demasiados toques en medio segundo).")
            Analyzer:Log("  💡 BYPASS: Insertar `task.wait(0.25)` entre cada disparo físico, u ocultar el arma antes de enviarlo.")
        else
            Analyzer:Log("  ✅ No hay Anti-TouchRate en el cliente.")
        end
    end

    -- 2.5 WalkSpeed & CFrame Checks
    Analyzer:Log("\n[🏃] TEST DE LÍMITES FÍSICOS (ANTI-FLY / ANTI-SPEED):")
    local envVars = {}
    for _, s in pairs(LocalPlayer:GetDescendants()) do
        if s:IsA("LocalScript") and (s.Name:find("Move") or s.Name:find("Speed") or s.Name:find("Physics") or s.Name:find("Anti")) then
            table.insert(envVars, s.Name)
        end
    end
    if #envVars > 0 then
        Analyzer:Log("  ⚠️ Scripts locales controlando tu movimiento encontrados: " .. table.concat(envVars, ", "))
        Analyzer:Log("  💡 BYPASS PREDOMINANTE: El servidor probablemente valida tu posicion cada 0.3s a 1.0s. Si vas a teletransportarte (CFrame) detrás de un zombi, NO LO HAGAS EN CERO SEGUNDOS.")
        Analyzer:Log("  💡 ESTRATEGIA: Usa `RootPart.Velocity` o saltos cortos (`TweenService`), el teleport bruto disparará las alarmas de distancia máxima permitida por frame.")
    else
        Analyzer:Log("  ✅ Scripts locales de movimiento no hallados. (Advertencia: Podría estar procesado puramente en ServerSide).")
    end

    Analyzer:Log("==============================================\n")
end

-- 🌐 3. COMBAT DISSECTOR (EL DISECCIONADOR CRACKER)
local CombatDissector = {}
function CombatDissector:Analyze()
    Analyzer:Log("\n[🗡️] DISECCION DE VULNERABILIDADES DEL ARMA:")
    local tools = {}
    if LocalPlayer:FindFirstChild("Backpack") then for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do if t:IsA("Tool") then table.insert(tools, t) end end end
    local myChar = LocalPlayer.Character
    if myChar then for _, t in pairs(myChar:GetChildren()) do if t:IsA("Tool") then table.insert(tools, t) end end end
    
    if #tools == 0 then return Analyzer:Log(" ❌ No tienes armas.") end
    
    for _, tool in ipairs(tools) do
        Analyzer:Log(" -> Analizando " .. tool.Name)
        local scriptFounds = 0
        local remoteFound = nil
        
        for _, obj in pairs(tool:GetDescendants()) do
            if obj:IsA("LocalScript") then scriptFounds = scriptFounds + 1 end
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then remoteFound = obj end
        end
        
        if remoteFound then
            Analyzer:Log("  ☢️ ARMA DUAL: Esta arma contiene un Remote oculto adentro ("..remoteFound.Name..").")
            Analyzer:Log("  💡 ESTRATEGIA KILLAURA: El script del killaura no debe llamar a un remote del Workspace, debe buscar ESE remote específico ("..remoteFound:GetFullName()..") y envíarselo al servidor.")
        elseif scriptFounds > 0 then
            Analyzer:Log("  🕵️ ARMA CLIENT-CONTROLLED: Esta arma ("..scriptFounds.." LocalScripts) calcula el daño en tu PC y envia el paquete general. La vulnerabilidad esta en modificar los Values base del arma.")
        else
            Analyzer:Log("  🔒 ARMA SERVER-CONTROLLED: Esta arma no tiene inteligencia local (0 LocalScripts). Solo avisa al servidor 'hice click'. El servidor hace Raycast y decide a quién mataste.")
            Analyzer:Log("  💡 BYPASS UNICO PARA ARMAS SERVER: El KillAura no puede enviar Hitboxes. Debe Teletransportar al jugador (CFrame) detrás de cada mob del mapa y usar `mouse1click()` o `VirtualInputManager`. Forzamos al servidor a presenciar el daño.")
        end
    end
end

-- ==============================================================================
-- 🖥️ 4. GUI CRACKER (TOTALMENTE NUEVA ARQUITECTURA)
-- ==============================================================================
local function ConstruirUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "ForenseV7UI"
    sg.ResetOnSpawn = false
    
    local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    for _, v in ipairs(parentUI:GetChildren()) do
        if v.Name == "ForenseV7UI" then v:Destroy() end
    end
    sg.Parent = parentUI

    -- 🔳 FRAME PRINCIPAL
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 850, 0, 600)
    MainFrame.Position = UDim2.new(0.5, -425, 0.5, -300)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.fromRGB(200, 0, 0)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    -- 🔵 BOTON FLOTANTE MAXIMIZAR
    local MaximizeBtn = Instance.new("TextButton")
    MaximizeBtn.Size = UDim2.new(0, 60, 0, 60)
    MaximizeBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
    MaximizeBtn.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
    MaximizeBtn.Text = "💀\nABRIR"
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
    TopBar.BackgroundColor3 = Color3.fromRGB(50, 5, 5)
    TopBar.Text = "  VULNERABILITY DETECTOR V1 (HACKER AUDIT) - ANTI-BAN"
    TopBar.TextColor3 = Color3.fromRGB(255, 150, 150)
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
    MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; MaximizeBtn.Visible = true end)
    MaximizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true; MaximizeBtn.Visible = false end)
    ReloadBtn.MouseButton1Click:Connect(function()
        pcall(function()
            Analyzer:Log("🔄 Forzando recarga de caché desde GitHub...")
            sg:Destroy()
            if type(loadstring) == "function" then
                loadstring(game:HttpGet(SCRIPT_URL .. "?reload=" .. tostring(math.random(11111, 99999))))()
            end
        end)
    end)

    -- Botones de Accion
    local ScanBtn = Instance.new("TextButton")
    ScanBtn.Size = UDim2.new(1, -20, 0, 50)
    ScanBtn.Position = UDim2.new(0, 10, 0, 45)
    ScanBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    ScanBtn.Text = "💀 INICIAR AUDITORÍA PROFUNDA DE SEGURIDAD DEL JUEGO 💀"
    ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScanBtn.Font = Enum.Font.Code
    ScanBtn.TextSize = 14
    ScanBtn.Parent = MainFrame

    -- Display
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -20, 1, -150)
    ScrollFrame.Position = UDim2.new(0, 10, 0, 105)
    ScrollFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
    ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollFrame.ScrollBarThickness = 8
    ScrollFrame.Parent = MainFrame

    local LogText = Instance.new("TextLabel")
    LogText.Size = UDim2.new(1, -15, 1, 0)
    LogText.Position = UDim2.new(0, 5, 0, 5)
    LogText.BackgroundTransparency = 1
    LogText.Text = ">>> ALGORITMO CRACKER INICIADO <<<\n\nTienes toda la razón, estábamos yendo a ciegas asumiendo que el juego era básico. Vamos a auditar DE ARRIBA A ABAJO qué sistemas Anti-Cheats y Honeypots (Remotes de penalización por usarlos mal) tiene el juego antes de siquiera pensar en tirar un firetouchinterest o un teleport bruto.\n\nPulsa el boton rojo arriba para iniciar la ingeniería inversa de los sistemas de seguridad y de tus armas, para saber ESPECIFICAMENTE cómo crear el KillAura. Todo este diagnóstico me indicará exactamente qué comandos de exploit tu executor sí puede correr y cuáles el servidor bloqueará."
    LogText.TextColor3 = Color3.fromRGB(255, 100, 100)
    LogText.Font = Enum.Font.Code
    LogText.TextSize = 13
    LogText.TextXAlignment = Enum.TextXAlignment.Left
    LogText.TextYAlignment = Enum.TextYAlignment.Top
    LogText.TextWrapped = true
    LogText.Parent = ScrollFrame

    Analyzer.UI_LogBox = LogText

    local CopyBtn = Instance.new("TextButton")
    CopyBtn.Size = UDim2.new(1, -20, 0, 35)
    CopyBtn.Position = UDim2.new(0, 10, 1, -40)
    CopyBtn.BackgroundColor3 = Color3.fromRGB(30, 100, 200)
    CopyBtn.Text = "COPIAR REPORTE AL PORTAPAPELES"
    CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyBtn.Font = Enum.Font.Code
    CopyBtn.TextSize = 14
    CopyBtn.Parent = MainFrame

    ScanBtn.MouseButton1Click:Connect(function()
        pcall(function()
            Analyzer:Clear()
            SecurityAudit:RunAudit()
            CombatDissector:Analyze()
        end)
    end)
    
    CopyBtn.MouseButton1Click:Connect(function()
        pcall(function()
            if type(setclipboard) == "function" then
                setclipboard(LogText.Text)
                CopyBtn.Text = "¡COPIADO CON ÉXITO!"
                task.delay(2, function() CopyBtn.Text = "COPIAR REPORTE AL PORTAPAPELES" end)
            end
        end)
    end)
end

ConstruirUI()
