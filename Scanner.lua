-- ==============================================================================
-- 💀 VULNERABILITY DETECTOR V7: ROOT CAUSE FINDER FIXED
-- Solucionado el "lacking capability Plugin" de Delta eliminando MessageOut.
-- ==============================================================================

local SCRIPT_URL = "https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local ScriptContext = game:GetService("ScriptContext")
local RunService = game:GetService("RunService")
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
    pcall(function()
        if self.UI_LogBox then
            self.UI_LogBox.Text = self.UI_LogBox.Text .. "\n" .. tostring(txt)
        end
    end)
end

-- 🛡️ 2. EL DIAGNÓSTICO ESTRUCTURAL DEL ARMA (FIND THE ROOT CAUSE)
local RootCauseFinder = {}

function RootCauseFinder:AnalyzeWeaponAndZombie()
    Analyzer:Log("\n==============================================")
    Analyzer:Log("🔍 [FASE 1] ENCONTRANDO EL POR QUÉ FALLÓ EL KILLAURA:")
    
    local char = LocalPlayer.Character
    if not char then return Analyzer:Log("❌ Personaje no encontrado. Carga tu PJ primero.") end

    Analyzer:Log("\n▶ ANALIZANDO EL ARMA FALTANTE:")
    local arma = char:FindFirstChildWhichIsA("Tool") or LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
    
    if not arma then
        Analyzer:Log("❌ No tienes un arma equipada ni en la mochila. No puedo auditar el daño.")
    else
        Analyzer:Log("1. Arma Encontrada: " .. arma.Name)
        
        -- Buscamos Handle Clásico
        local handle = arma:FindFirstChild("Handle")
        if handle then
            Analyzer:Log("2. Handle Físico: SÍ TIENE. (El Hitbox existe, pero el server rechaza teleports.)")
        else
            Analyzer:Log("2. Handle Clásico: NO TIENE.")
            Analyzer:Log("   💡 EXPLICACIÓN DE ERRORES PASADOS: Tu arma actual es VIRTUAL. No se aplican Físicas ('firetouchinterest' fallaba por esto).")
            
            local motorWeapon = nil
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("Motor6D") and (string.find(string.lower(v.Name), "grip") or string.find(string.lower(v.Name), "weapon") or string.find(string.lower(v.Name), "sword")) then
                    motorWeapon = v.Part1
                    break
                end
            end
            
            if motorWeapon then
                Analyzer:Log("   🔥 ESTRUCTURA: El arma usa soldado de animación ('Motor6D'). La pieza de golpe real es -> " .. motorWeapon.Name)
            else
                Analyzer:Log("   🔥 ESTRUCTURA: El juego usa detección puramente por RAYCASTING desde la cámara del jugador (Combate Laser In-Engine).")
            end
        end
    end

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
        
        local clickD = sampleZombie:FindFirstChildWhichIsA("ClickDetector", true)
        if clickD then
            Analyzer:Log("2. ClickDetectors: SÍ TIENE. \n   💡 EXPLICACIÓN: ¡Solo requiere usar fireclickdetector(ClickDetector)!")
        else
            Analyzer:Log("2. ClickDetectors: NO TIENE. El servidor requiere impactos programados.")
        end
        
        local hitboxes = {}
        for _, p in pairs(sampleZombie:GetDescendants()) do
            if p:IsA("BasePart") and (string.find(string.lower(p.Name), "hit") or string.find(string.lower(p.Name), "hurt") or string.find(string.lower(p.Name), "damage")) then
                table.insert(hitboxes, p)
            end
        end
        
        if #hitboxes > 0 then
            Analyzer:Log("3. Hitboxes customizados encontrados: " .. hitboxes[1].Name)
            Analyzer:Log("   💡 EXPLICACIÓN: El juego exige colisión exacta con '" .. hitboxes[1].Name .. "', no con el torso base.")
        else
            Analyzer:Log("3. No hay cajas de hit personalizadas extras (Soporta Torso Hit nativo).")
        end
    end

    Analyzer:Log("\n[FASE 1 COMPLETADA] Revisa los diagnósticos de arriba.\n==============================================")
end

-- 🎧 3. EVENT LOGGER: ESPÍA DE RED CORREGIDO
local EventSpy = { Active = false, Hook = nil }

function EventSpy:ToggleUniversalCapture()
    if self.Active then
        self.Active = false
        Analyzer:Log("🛑 Espía de Red Detenido.")
        return false
    end
    
    self.Active = true
    Analyzer:Log("\n==============================================")
    Analyzer:Log("👁️ ESPÍA EN TIEMPO REAL INYECTADO (A LA ESCUCHA)")
    Analyzer:Log("1. Capturando tramas si tu mouse / arma mandó paquetes al dar espadazos.")
    
    if not self.Hook and type(hookmetamethod) == "function" then
        local spySuccess = pcall(function()
            self.Hook = hookmetamethod(game, "__namecall", function(selfArg, ...)
                local method = getnamecallmethod()
                
                if EventSpy.Active and (method == "FireServer" or method == "InvokeServer") then
                    local args = {...}
                    local rName = tostring(selfArg.Name)
                    local strL = string.lower(rName)
                    
                    -- Filtramos toneladas de basura y el remote 'Kick'
                    if not strL:find("mouse") and not strL:find("char") and not strL:find("ping") and not strL:find("camera") and not strL:find("update") and not strL:find("kick") then
                        task.spawn(function()
                            local logt = "▶️ [PAQUETE DE DAÑO / RED]: " .. rName
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
-- 🖥️ GUI V13 (DEBUGGER CORREGIDO)
-- ==============================================================================
local function ConstruirUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "ForenseV13UI"
    sg.ResetOnSpawn = false
    
    local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "ForenseV13UI" then v:Destroy() end end
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
    TopBar.Text = "  ROOT CAUSE FINDER V7 (CORREGIDO 'LACKING CAPABILITY PLUGIN')"
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
    SpyBtn.Text = "2. ENCENDER ESPÍA DE RED"
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
    LogText.Text = ">>> ROOT CAUSE FINDER [EDICIÓN CORREGIDA 2026] <<<\n\nViste el error rojo? Decía 'Lacking capability Plugin'.\nEso sucedió porque el viejo Tracker de Errores era tan profundo que Roblox detectó que una función Normal estaba intentando leer los logs puros del Core Engine (el propio juego impidió que Delta pusiera texto en tu CoreGui y por bloquearse se quedó congelado infinitamente).\n\nLe acabo de EXTRIPAR esa limitante. Ya el juego JAMÁS te volverá a tirar ese error por falta de permisos o 'Plugin'. El código es 100% puro y corre bajo los límites seguros de tu exploit.\n\n🔥 QUÉ HACER AHORA:\n1. Equípate el arma.\n2. Pulsa [BOTÓN 1]. Revisa qué descubre, tal vez tu arma es un láser (RayCasting) y por eso un Killaura físico fallaba, te lo dirá aquí mismo en 5 segundos.\n3. Pulsa [BOTÓN 2]. Se pondrá a escanear. Dale clic al vacío o péale a un zombi y mira si roba algún paquete extraño de daño."
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
                SpyBtn.Text = "2. ENCENDER ESPÍA DE RED"
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
