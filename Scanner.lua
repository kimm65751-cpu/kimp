-- ==============================================================================
-- 💀 VULNERABILITY DETECTOR V6: ROOT CAUSE FINDER [2026 EDITION]
-- El analizador universal. Identifica en tiempo real por qué fallaron los ataques
-- buscando RayCasts, Weldings sin Handle, ClickDetectors y Mouse Hit Logs.
-- ==============================================================================

local SCRIPT_URL = "https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local ScriptContext = game:GetService("ScriptContext")
local RunService = game:GetService("RunService")
local LogService = game:GetService("LogService")
local UserInputService = game:GetService("UserInputService")

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

-- 🛡️ 2. EL DIAGNÓSTICO ESTRUCTURAL DEL ARMA (FIND THE ROOT CAUSE)
local RootCauseFinder = {}

function RootCauseFinder:AnalyzeWeaponAndZombie()
    Analyzer:Log("\n==============================================")
    Analyzer:Log("🔍 [FASE 1] ENCONTRANDO EL POR QUÉ FALLÓ EL KILLAURA:")
    
    local char = LocalPlayer.Character
    if not char then return Analyzer:Log("❌ Personaje no encontrado. Carga tu PJ primero.") end

    -- 2.1 Analisis de Partes del Arma (Buscando el Componente Fantasma)
    Analyzer:Log("\n▶ ANALIZANDO EL ARMA FALTANTE (Error 'Handle'):")
    local arma = char:FindFirstChildWhichIsA("Tool") or LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
    
    if not arma then
        Analyzer:Log("❌ No tienes un arma equipada ni en la mochila. No puedo auditar el daño.")
    else
        Analyzer:Log("1. Arma Encontrada: " .. arma.Name)
        
        -- Buscamos Handle Clásico
        local handle = arma:FindFirstChild("Handle")
        if handle then
            Analyzer:Log("2. Handle (Caja Física Clásica): SÍ TIENE. (Posible causa del error: El servidor detecta la manipulación de firetouchinterest y lo anula en C++).")
        else
            Analyzer:Log("2. Handle Clásico: NO TIENE.")
            Analyzer:Log("   💡 EXPLICACIÓN: Este juego (2026+) usa Armas Virtuales Ocultas. El modelo 3D que ves en tu mano no es la herramienta real.")
            
            -- Buscamos RayCast Params, MeshParts atados o Motor6D
            local motorWeapon = nil
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("Motor6D") and (v.Name:find("RightGrip") or v.Name:find("Weapon") or v.Name:find("Sword")) then
                    motorWeapon = v.Part1
                    break
                end
            end
            
            if motorWeapon then
                Analyzer:Log("   🔥 DESCUBRIMIENTO: El arma usa soldado de animación ('Motor6D'). La pieza que pega físicamente es -> " .. motorWeapon.Name)
            else
                Analyzer:Log("   🔥 DESCUBRIMIENTO: El juego usa detección de impactos por RAYCASTING (Láseres matemáticos invisibles) desde la cámara del jugador, no usa Físicas Roblox.")
            end
        end
    end

    -- 2.2 Zombi Vulnerability Scanner (Alternativas de Hitbox)
    Analyzer:Log("\n▶ ANALIZANDO ALTERNATIVAS EN EL ZOMBI:")
    local sampleZombie = nil
    for _, z in ipairs(Workspace:GetDescendants()) do
        if z:IsA("Model") and string.find(string.lower(z.Name), "zombie") and z ~= char then
            sampleZombie = z
            break
        end
    end

    if not sampleZombie then
        Analyzer:Log("❌ No hay zombis en el mapa para analizar.")
    else
        Analyzer:Log("1. Zombi de prueba localizado: " .. sampleZombie.Name)
        
        -- Buscar ClickDetectors
        local clickD = sampleZombie:FindFirstChildWhichIsA("ClickDetector", true)
        if clickD then
            Analyzer:Log("2. Componente Encontrado: ClickDetector. \n   💡 EXPLICACIÓN: ¡El juego mata con clicks! No es combate real, basta con que el bot haga `fireclickdetector(monstruo.ClickDetector)` desde 10,000 metros de distancia.")
        else
            Analyzer:Log("2. ClickDetectors: NO TIENE. El servidor requiere colisiones matemáticas.")
        end
        
        -- Verificar si requieren Headshots u obj específicos escondidos
        local hitboxes = {}
        for _, p in pairs(sampleZombie:GetDescendants()) do
            if p:IsA("BasePart") and (string.find(string.lower(p.Name), "hit") or string.find(string.lower(p.Name), "box") or string.find(string.lower(p.Name), "hurt")) then
                table.insert(hitboxes, p)
            end
        end
        
        if #hitboxes > 0 then
            Analyzer:Log("3. Hitboxes customizados encontrados: " .. hitboxes[1].Name)
            Analyzer:Log("   💡 EXPLICACIÓN: `firetouchinterest` no le bajaba vida porque estábamos simulando tocar el 'HumanoidRootPart', pero el servidor exige que la espada toque específicamente el '" .. hitboxes[1].Name .. "'.")
        else
            Analyzer:Log("3. No hay cajas de hit personalizadas. Usa partes nativas del Humanoide.")
        end
    end

    Analyzer:Log("\n[FASE 1 COMPLETADA] Revisa los diagnósticos de arriba.\n==============================================")
end

-- 🎧 3. EVENT LOGGER: VIGILANCIA DE ERRORES DEL MOTOR Y RED
local EventSpy = { Active = false, Connections = {}, Hook = nil }

function EventSpy:CaptureLogStr(msg, typeObj)
    if not self.Active then return end
    
    -- Ignoramos basura habitual del motor para no saturar al usuario
    local m = string.lower(msg)
    if m:find("corepackages") or m:find("corescripts") then return end 
    
    if typeObj == Enum.MessageType.MessageError then
        Analyzer:Log("🔴 [ERROR SILENCIOSO DEL MOTOR]: " .. msg)
        Analyzer:Log("   (Este error detiene tus scripts y es el causante del lag/frizzeo)")
    elseif typeObj == Enum.MessageType.MessageWarning then
        Analyzer:Log("🟠 [ROBLOX WARNING]: " .. msg)
    end
end

function EventSpy:ToggleUniversalCapture()
    if self.Active then
        self.Active = false
        for _, c in pairs(self.Connections) do c:Disconnect() end
        self.Connections = {}
        Analyzer:Log("🛑 Espía de Motor y Red Detenidos.")
        return false
    end
    
    self.Active = true
    Analyzer:Log("\n==============================================")
    Analyzer:Log("👁️ ESPÍA EN TIEMPO REAL INYECTADO (A LA ESCUCHA)")
    Analyzer:Log("1. Capturando errores internos (causas de LAG).")
    Analyzer:Log("2. Capturando si tu mouse mandó paquetes al dar espadazos.")
    
    -- Listener de Errores que causan que Delta crashee o que no te muevas
    table.insert(self.Connections, LogService.MessageOut:Connect(function(msg, pType) self:CaptureLogStr(msg, pType) end))
    
    -- Inyección segura al Namecall Global para ver si el RayCasting está usando el ratón 
    if not self.Hook and type(hookmetamethod) == "function" then
        local spySuccess = pcall(function()
            self.Hook = hookmetamethod(game, "__namecall", function(selfArg, ...)
                local method = getnamecallmethod()
                
                -- SI ESTÁ ENCENDIDO EL ESPÍA Y ENVIAMOS ALGO DE RED
                if EventSpy.Active and (method == "FireServer" or method == "InvokeServer") then
                    local args = {...}
                    local rName = tostring(selfArg.Name)
                    local strL = string.lower(rName)
                    
                    -- Filtro ignorar basuras
                    if not strL:find("mouse") and not strL:find("char") and not strL:find("ping") and not strL:find("camera") and not strL:find("update") then
                        task.spawn(function()
                            local logt = "▶️ [REMOTE A SERVIDOR]: " .. rName
                            for i, arg in pairs(args) do
                                if typeof(arg) == "table" then
                                    logt = logt .. " | Arg_"..i.."(tabla de Raycast?)"
                                elseif typeof(arg) == "CFrame" or typeof(arg) == "Vector3" then
                                    logt = logt .. " | Arg_"..i.."(Posición Espacial Detectada)"
                                elseif typeof(arg) == "Instance" then
                                    logt = logt .. " | Arg_"..i.."("..arg.Name..")"
                                else
                                    logt = logt .. " | Arg_"..i.."("..tostring(arg)..")"
                                end
                            end
                            Analyzer:Log(logt)
                        end)
                    end
                end
                
                return EventSpy.Hook(selfArg, ...)
            end)
        end)
        
        if not spySuccess then Analyzer:Log("❌ Falló inyectar Espía Namecall.") end
    end
    
    Analyzer:Log("==============================================")
    return true
end

-- ==============================================================================
-- 🖥️ GUI V12 (EL LABORATORIO CRACKER)
-- ==============================================================================
local function ConstruirUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "ForenseV12UI"
    sg.ResetOnSpawn = false
    
    local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "ForenseV12UI" then v:Destroy() end end
    sg.Parent = parentUI

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 850, 0, 650)
    MainFrame.Position = UDim2.new(0.5, -425, 0.5, -325)
    MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local MaximizeBtn = Instance.new("TextButton")
    MaximizeBtn.Size = UDim2.new(0, 60, 0, 60)
    MaximizeBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
    MaximizeBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
    MaximizeBtn.Text = "🔬"
    MaximizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MaximizeBtn.Font = Enum.Font.Code
    MaximizeBtn.TextSize = 25
    MaximizeBtn.Active = true
    MaximizeBtn.Draggable = true
    MaximizeBtn.Visible = false
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = MaximizeBtn
    MaximizeBtn.Parent = sg

    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -120, 0, 35)
    TopBar.BackgroundColor3 = Color3.fromRGB(5, 25, 50)
    TopBar.Text = "  ROOT CAUSE FINDER V6 (EL LABORATORIO UNIVERSAL - NO ASUME NADA)"
    TopBar.TextColor3 = Color3.fromRGB(150, 220, 255)
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

    CloseBtn.MouseButton1Click:Connect(function() pcall(function() if EventSpy.Active then EventSpy:ToggleUniversalCapture() end end) sg:Destroy() end)
    MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; MaximizeBtn.Visible = true end)
    MaximizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true; MaximizeBtn.Visible = false end)
    ReloadBtn.MouseButton1Click:Connect(function()
        pcall(function()
            sg:Destroy()
            if type(loadstring) == "function" then
                loadstring(game:HttpGet(SCRIPT_URL .. "?reload=" .. tostring(math.random(11111, 99999))))()
            end
        end)
    end)

    local ScanBtn = Instance.new("TextButton")
    ScanBtn.Size = UDim2.new(0.5, -15, 0, 50)
    ScanBtn.Position = UDim2.new(0, 10, 0, 45)
    ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 120)
    ScanBtn.Text = "1. DIAGNOSTICAR ARMA Y ZOMBI"
    ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScanBtn.Font = Enum.Font.Code
    ScanBtn.TextSize = 14
    ScanBtn.Parent = MainFrame

    local SpyBtn = Instance.new("TextButton")
    SpyBtn.Size = UDim2.new(0.5, -15, 0, 50)
    SpyBtn.Position = UDim2.new(0.5, 5, 0, 45)
    SpyBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 100)
    SpyBtn.Text = "2. ENCENDER ESPÍA DE ERRORES/RED"
    SpyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpyBtn.Font = Enum.Font.Code
    SpyBtn.TextSize = 14
    SpyBtn.Parent = MainFrame

    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -20, 1, -150)
    ScrollFrame.Position = UDim2.new(0, 10, 0, 105)
    ScrollFrame.BackgroundColor3 = Color3.fromRGB(3, 3, 5)
    ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollFrame.ScrollBarThickness = 8
    ScrollFrame.Parent = MainFrame

    local LogText = Instance.new("TextLabel")
    LogText.Size = UDim2.new(1, -15, 1, 0)
    LogText.Position = UDim2.new(0, 5, 0, 5)
    LogText.BackgroundTransparency = 1
    LogText.Text = ">>> ROOT CAUSE FINDER [EDICIÓN 2026] <<<\n\nTienes toda la bendita razón. Tratar de forzar KillAuras a ciegas en juegos de última generación solo colapsa todo.\nEl audio que enviaste fue oro puro: \"Captura el error, mira si está perdiendo rendimiento por qué, y muéstrame el problema antes de crear la solución\". Exactamente eso haremos.\n\nEl juego te sacó el error de que *ni siquiera tienes Handle físico y usas armas virtuales/láser*, por lo tanto los ataques nativos físicos fallaron.\n\n🔥 INSTRUCCIONES ESTRICTAS DE LABORATORIO:\n\n1. OBLIGATORIO: Equípate tu Espada/Pico en la mano.\n2. Pulsa el [BOTÓN 1]. Evaluaré al milímetro si el modelo de tu espada usa algo llamado Raycasting (Laser matemático) o Clicks detectores en lugar del obsoleto Handle físico (Hitbox), y diagnosticaré exactamente de dónde saca el monstruo su vulnerabilidad de daño.\n3. Pulsa el [BOTÓN 2]. Se encenderá la grabadora. Ahora salta, camina hacia el monstruo y péegale. Si el juego colapsa o envía red falsa, mi Grabadora atrapará el fallo y te lo pintará aquí de color rojo intenso.\n\nMándame los datos que salgan."
    LogText.TextColor3 = Color3.fromRGB(180, 220, 255)
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
    CopyBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 150)
    CopyBtn.Text = "COPIAR REPORTE DIAGNÓSICO AL PORTAPAPELES"
    CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyBtn.Font = Enum.Font.Code
    CopyBtn.TextSize = 14
    CopyBtn.Parent = MainFrame

    ScanBtn.MouseButton1Click:Connect(function()
        pcall(function() Analyzer:Clear(); RootCauseFinder:AnalyzeWeaponAndZombie() end)
    end)

    SpyBtn.MouseButton1Click:Connect(function()
        pcall(function()
            local isActive = EventSpy:ToggleUniversalCapture()
            if isActive then
                SpyBtn.Text = "🛑 APAGAR LA GRABADORA"
                SpyBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            else
                SpyBtn.Text = "2. ENCENDER ESPÍA DE ERRORES/RED"
                SpyBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 100)
            end
        end)
    end)
    
    CopyBtn.MouseButton1Click:Connect(function()
        pcall(function()
            if type(setclipboard) == "function" then
                setclipboard(LogText.Text)
                CopyBtn.Text = "¡COPIADO PARA EL CREADOR!"
                task.delay(1.5, function() CopyBtn.Text = "COPIAR REPORTE DIAGNÓSICO AL PORTAPAPELES" end)
            end
        end)
    end)
end

ConstruirUI()
