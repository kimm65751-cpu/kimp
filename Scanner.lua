-- ==============================================================================
-- 💀 VULNERABILITY DETECTOR V8: WEAPON FORGE & GOD-MODE TESTER
-- Identificada un IA de Zombi Esférico (Rango Mutuo). Soluciones
-- aplicables: Modificación de Reach (Attribute), CFrame Fast-Dash o GodMode
-- ==============================================================================

local SCRIPT_URL = "https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
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
    pcall(function()
        if self.UI_LogBox then
            self.UI_LogBox.Text = self.UI_LogBox.Text .. "\n" .. tostring(txt)
        end
    end)
end

-- 🛡️ 2. REACH SPOOFER (Weapon Forge)
local WeaponForge = {}

function WeaponForge:ForgeWeaponRange()
    Analyzer:Log("\n==============================================")
    Analyzer:Log("🔨 [FASE 1] ALTERANDO RANGOS DEL ARMA (REACH SPOOF)...")
    
    local char = LocalPlayer.Character
    if not char then return Analyzer:Log("❌ Personaje no encontrado. Carga tu PJ primero.") end

    local arma = char:FindFirstChildWhichIsA("Tool") or LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
    
    if not arma then
        Analyzer:Log("❌ No tienes un arma para forjar su rango.")
    else
        Analyzer:Log("1. Arma Forjable Encontrada: " .. arma.Name)
        
        -- Trucos comunes de forjado de armas en Roblox 2026
        local mods = 0
        
        -- Táctica A: Modificar Valores Numéricos internos del Tool
        for _, v in pairs(arma:GetDescendants()) do
            if v:IsA("NumberValue") or v:IsA("IntValue") then
                local lname = string.lower(v.Name)
                if lname:find("range") or lname:find("reach") or lname:find("dist") or lname:find("rad") or lname:find("size") then
                    local ov = v.Value
                    v.Value = 100 -- 100 studs de distancia
                    Analyzer:Log("   🔥 Modificado Valor Interno: " .. v.Name .. " (" .. tostring(ov) .. " -> 100)")
                    mods = mods + 1
                end
            end
        end
        
        -- Táctica B: Modificar Atributos C++ del Tool
        local attrs = arma:GetAttributes()
        for k, v in pairs(attrs) do
            local lname = string.lower(k)
            if typeof(v) == "number" and (lname:find("range") or lname:find("reach") or lname:find("dist") or lname:find("rad") or lname:find("size")) then
                arma:SetAttribute(k, 100)
                Analyzer:Log("   🎯 Modificado Atributo C++: " .. k .. " (" .. tostring(v) .. " -> 100)")
                mods = mods + 1
            end
        end
        
        if mods == 0 then
            Analyzer:Log("   ⚠️ No se encontraron variables de rango locales en el arma. El rango podría estar fuertemente hardcodeado en el servidor o derivar del tamaño de la MeshPart.")
        else
            Analyzer:Log("✅ ¡Se inyectó un Mega-Rango de 100 Metros a tu espada! Si golpeas al aire lejos del zombi, el servidor podría validar las muertes gracias a esta alteración matemática.")
        end
    end

    Analyzer:Log("==============================================")
end

-- 🎧 3. EVENT LOGGER: VIGILANCIA DE DAÑO A MI PERSONAJE (GODMODE FINDER)
local EventSpy = { Active = false, Hook = nil }

function EventSpy:ToggleUniversalCapture()
    if self.Active then
        self.Active = false
        Analyzer:Log("🛑 Log de Inmortalidad Detenido.")
        return false
    end
    
    self.Active = true
    Analyzer:Log("\n==============================================")
    Analyzer:Log("👁️ BUSCADOR DE INMORTALIDAD (GODMODE) ACTIVO")
    Analyzer:Log("1. Como el zombie te pega si o si, vamos a ver si es posible hacernos intocables.")
    Analyzer:Log("2. ACÉRCATE a un Zombi y DEJA que te pegue 1 vez.")
    
    if not self.Hook and type(hookmetamethod) == "function" then
        local spySuccess = pcall(function()
            self.Hook = hookmetamethod(game, "__namecall", function(selfArg, ...)
                local method = getnamecallmethod()
                
                if EventSpy.Active and (method == "FireServer" or method == "InvokeServer") then
                    local args = {...}
                    local rName = tostring(selfArg.Name)
                    local strL = string.lower(rName)
                    
                    -- Si el Zombi pega e invoca un paquete nuestro que podemos anular para ser inmortales
                    if strL:find("damage") or strL:find("hit") or strL:find("hurt") or strL:find("take") then
                        task.spawn(function()
                            Analyzer:Log("🛡️ ¡PAQUETE DE DAÑO RECIBIDO INTERCEPTADO! (Posible GodMode Local): " .. rName)
                        end)
                        -- Si esto bloquea el daño, somos inmortales
                        return nil 
                    end
                end
                
                return EventSpy.Hook(selfArg, ...)
            end)
        end)
        
        if not spySuccess then Analyzer:Log("❌ Falló inyectar el módulo interceptor.") end
    end
    
    Analyzer:Log("==============================================")
    return true
end

-- ==============================================================================
-- 🖥️ GUI V14
-- ==============================================================================
local function ConstruirUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "ForenseV14UI"
    sg.ResetOnSpawn = false
    
    local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "ForenseV14UI" then v:Destroy() end end
    sg.Parent = parentUI

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 850, 0, 650)
    MainFrame.Position = UDim2.new(0.5, -425, 0.5, -325)
    MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.fromRGB(200, 150, 0)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -120, 0, 35)
    TopBar.BackgroundColor3 = Color3.fromRGB(50, 40, 5)
    TopBar.Text = "  WEAPON FORGE V8 (MANIPULADOR DE REACH Y GODMODE)"
    TopBar.TextColor3 = Color3.fromRGB(255, 200, 100)
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
    MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)
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
    ScanBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 0)
    ScanBtn.Text = "1. INYECTAR 'MEGA REACH' AL ARMA"
    ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScanBtn.Font = Enum.Font.Code
    ScanBtn.TextSize = 14
    ScanBtn.Parent = MainFrame

    local SpyBtn = Instance.new("TextButton")
    SpyBtn.Size = UDim2.new(0.5, -15, 0, 50)
    SpyBtn.Position = UDim2.new(0.5, 5, 0, 45)
    SpyBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 100)
    SpyBtn.Text = "2. PROBAR GOD-MODE (RECIBIR GOLPE)"
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
    LogText.Text = ">>> LABORATORIO: WEAPON FORGE & GODMODE <<<\n\nTienes toda la razón, entendí perfectamente tu audio. El zombi ataca en una ESFERA DE ÁREA (AoE) de rango 5. Y nuestra espada... también tiene Rango 5. Por lo tanto, cualquier intento de KillAura que te acerque, garantiza que entres a la esfera de daño del zombi y mueras. Matemática pura y dura.\n\n🔥 ¿CÓMO RESOLVEMOS EMPATES MATEMÁTICOS DE RANGO?\nTenemos 2 Opciones Diamante que funcionan en estos anti-cheats:\n\n1. EL MEGA REACH (Botón 1): Buscaremos en los archivos ocultos de tu arma si el creador dejó la variable de distancia 'Range' abierta. La modificaremos a 100. Si el Servidor es tonto, te permitirá matar a los monstruos dándole clicks al aire desde 100 metros.\n\n2. HACK DE INMORTALIDAD (GodMode) (Botón 2): Muchos juegos cometen el error de avisarle al servidor que 'recibiste daño' desde tu propia PC. Toca el botón 2, acércate a un zombi y deja que te golpee. Si mi código logra bloquear el registro del servidor, tu vida quedará estancada en el máximo (te volverás inmortal) y podrás usar cualquier AutoFarm de cercanía que te di antes y masacrarlos riéndote de sus golpes."
    LogText.TextColor3 = Color3.fromRGB(255, 200, 150)
    LogText.Font = Enum.Font.Code
    LogText.TextSize = 13
    LogText.TextXAlignment = Enum.TextXAlignment.Left
    LogText.TextYAlignment = Enum.TextYAlignment.Top
    LogText.TextWrapped = true
    LogText.Parent = ScrollFrame

    Analyzer.UI_LogBox = LogText

    ScanBtn.MouseButton1Click:Connect(function()
        pcall(function() Analyzer:Clear(); WeaponForge:ForgeWeaponRange() end)
    end)

    SpyBtn.MouseButton1Click:Connect(function()
        pcall(function()
            local isActive = EventSpy:ToggleUniversalCapture()
            if isActive then
                SpyBtn.Text = "🛑 APAGAR INMORTALIDAD"
                SpyBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            else
                SpyBtn.Text = "2. PROBAR GOD-MODE (RECIBIR GOLPE)"
                SpyBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 100)
            end
        end)
    end)
end

ConstruirUI()
