-- ==============================================================================
-- 💀 VULNERABILITY SCANNER V2 (CON KILLAURA "GHOST REAPER")
-- Modo bypass integrado basado en la auditoría del juego.
-- ==============================================================================

local SCRIPT_URL = "https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local ScriptContext = game:GetService("ScriptContext")
local RunService = game:GetService("RunService")

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

-- 🛡️ 2. HONEYPOT & ANTI-CHEAT SCANNER
local SecurityAudit = {}

function SecurityAudit:RunAudit()
    Analyzer:Log("\n==============================================")
    Analyzer:Log("💀 INICIANDO AUDITORIA DE SEGURIDAD GLOBAL (CORE ENGINE)...")
    
    local cgHooks = 0
    for _, obj in pairs(CoreGui:GetDescendants()) do
        if obj:IsA("LocalScript") and obj.Name ~= "ForenseV8UI" then cgHooks = cgHooks + 1 end
    end
    if cgHooks > 0 then Analyzer:Log("  ⚠️ PELIGRO: " .. cgHooks .. " scripts monitoreando el CoreGui.") else Analyzer:Log("  ✅ CoreGui Limpio.") end

    local scConnections = pcall(function() return #getconnections(ScriptContext.Error) end) and #getconnections(ScriptContext.Error) or 0
    if type(scConnections) == "number" and scConnections > 0 then Analyzer:Log("  ⚠️ HONEYPOT: " .. scConnections .. " listeners de Error globales detectados.") else Analyzer:Log("  ✅ Honeypots Globales de Error no evidentes.") end

    local acRemotes = {}
    local suspiciousWords = {"ban", "kick", "report", "flag", "detect", "cheat"}
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            for _, word in ipairs(suspiciousWords) do if string.find(string.lower(v.Name), word) then table.insert(acRemotes, v); break end end
        end
    end
    
    if #acRemotes > 0 then
        Analyzer:Log("  🚨 " .. #acRemotes .. " REMOTES ANTI-CHEAT ENCONTRADOS.")
    else
        Analyzer:Log("  ✅ Cero remotes dedicatorios a Banneo.")
    end

    if type(firetouchinterest) ~= "function" then Analyzer:Log("  ❌ EL EXECUTOR CARECE DE 'firetouchinterest'.") else Analyzer:Log("  ✅ 'firetouchinterest' soportado.") end
    Analyzer:Log("==============================================\n")
end

-- 🌐 3. COMBAT DISSECTOR
local CombatDissector = {}
function CombatDissector:Analyze()
    Analyzer:Log("\n[🗡️] DISECCION DE VULNERABILIDADES DEL ARMA:")
    local tools = {}
    if LocalPlayer:FindFirstChild("Backpack") then for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do if t:IsA("Tool") then table.insert(tools, t) end end end
    local myChar = LocalPlayer.Character
    if myChar then for _, t in pairs(myChar:GetChildren()) do if t:IsA("Tool") then table.insert(tools, t) end end end
    
    if #tools == 0 then return Analyzer:Log(" ❌ No tienes armas.") end
    for _, tool in ipairs(tools) do
        local scriptFounds = 0
        for _, obj in pairs(tool:GetDescendants()) do if obj:IsA("LocalScript") then scriptFounds = scriptFounds + 1 end end
        if scriptFounds == 0 then Analyzer:Log(" -> Analizando " .. tool.Name .. " | 🔒 ARMA SERVER-CONTROLLED (Cero scripts locales).") else Analyzer:Log(" -> Analizando " .. tool.Name .. " | ☢️ ARMA CONTROLADA LOCALMENTE ("..scriptFounds.." scripts).") end
    end
end

-- ⚔️ 4. MÓDULO KILLAURA GHOST REAPER
local KillAura = { Active = false, Connection = nil, Hooked = false }

function KillAura:Toggle()
    if self.Active then
        self.Active = false
        if self.Connection then self.Connection:Disconnect() end
        Analyzer:Log("🛑 Ghost Aura Apagado.")
        return false
    else
        self.Active = true
        Analyzer:Log("\n🔥 PREPARANDO REAPER AURA (TELEPORT + AUTO-ATTACK)...")
        
        -- Inyector Anti-Kick
        pcall(function()
            if type(hookmetamethod) == "function" and not self.Hooked then
                self.Hooked = true
                local oldNamecall
                oldNamecall = hookmetamethod(game, "__namecall", function(selfArg, ...)
                    local method = getnamecallmethod()
                    local methodName = tostring(method)
                    
                    if methodName == "Kick" or methodName == "kick" then return nil end
                    if selfArg:IsA("RemoteFunction") or selfArg:IsA("RemoteEvent") then
                        if tostring(selfArg.Name) == "Kick" or tostring(selfArg.Name) == "kick" then return nil end
                    end
                    
                    return oldNamecall(selfArg, ...)
                end)
                Analyzer:Log("✅ Escudo Anti-Kick (Bypass) Activado en el Motor C++.")
            end
        end)

        self.Connection = RunService.Heartbeat:Connect(function()
            if not self.Active then return end
            
            local char = LocalPlayer.Character
            if not char then return end
            
            local miRoot = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not miRoot or not hum or hum.Health <= 0 then return end
            
            -- Auto-equipamiento de arma
            local arma = char:FindFirstChildWhichIsA("Tool")
            if not arma then
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                if backpack then
                    local mejorArma = backpack:FindFirstChild("Weapon") or backpack:FindFirstChildWhichIsA("Tool")
                    if mejorArma then
                        hum:EquipTool(mejorArma)
                        arma = mejorArma
                    end
                end
            end

            -- Si tenemos arma y cuerpo, cazar al zombi
            if miRoot and arma then
                local mejorZombi = nil
                local mejorDistancia = 500 -- Radio de caza de 500 studs
                
                for _, z in pairs(Workspace:GetDescendants()) do
                    if z:IsA("Model") and not Players:GetPlayerFromCharacter(z) then
                        local zHum = z:FindFirstChildOfClass("Humanoid")
                        local zRoot = z:FindFirstChild("HumanoidRootPart")
                        -- Buscar 'zombie' en el nombre o si tiene un Animator
                        if zHum and zHum.Health > 0 and zRoot and string.find(string.lower(z.Name), "zombie") then
                            local dist = (zRoot.Position - miRoot.Position).Magnitude
                            if dist < mejorDistancia then
                                mejorDistancia = dist
                                mejorZombi = zRoot
                            end
                        end
                    end
                end
                
                if mejorZombi then
                    -- Nos posamos a 6.5 studs arriba del core del zombi
                    local offsetSeguro = Vector3.new(0, 6.5, 0)
                    -- Forzar CFrame mirando hacia abajo al zombi
                    miRoot.CFrame = CFrame.new(mejorZombi.Position + offsetSeguro, mejorZombi.Position)
                    miRoot.Velocity = Vector3.zero 
                    
                    -- Explotamos el Tool:Activate() (click virtual validado por el server)
                    arma:Activate()
                end
            end
        end)
        
        return true
    end
end

-- ==============================================================================
-- 🖥️ 5. GUI ACTUALIZADA (V8)
-- ==============================================================================
local function ConstruirUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "ForenseV8UI"
    sg.ResetOnSpawn = false
    
    local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "ForenseV8UI" then v:Destroy() end end
    sg.Parent = parentUI

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 850, 0, 600)
    MainFrame.Position = UDim2.new(0.5, -425, 0.5, -300)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.fromRGB(200, 0, 0)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local MaximizeBtn = Instance.new("TextButton")
    MaximizeBtn.Size = UDim2.new(0, 60, 0, 60)
    MaximizeBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
    MaximizeBtn.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
    MaximizeBtn.Text = "💀"
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
    TopBar.BackgroundColor3 = Color3.fromRGB(50, 5, 5)
    TopBar.Text = "  VULNERABILITY DETECTOR V2 (CON KILLAURA BYPASS)"
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

    CloseBtn.MouseButton1Click:Connect(function() pcall(function() KillAura.Active=false; if KillAura.Connection then KillAura.Connection:Disconnect() end end) sg:Destroy() end)
    MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; MaximizeBtn.Visible = true end)
    MaximizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true; MaximizeBtn.Visible = false end)
    ReloadBtn.MouseButton1Click:Connect(function()
        pcall(function()
            Analyzer:Log("🔄 Recarga rápida iniciada...")
            KillAura.Active = false
            if KillAura.Connection then KillAura.Connection:Disconnect() end
            sg:Destroy()
            if type(loadstring) == "function" then
                loadstring(game:HttpGet(SCRIPT_URL .. "?reload=" .. tostring(math.random(11111, 99999))))()
            end
        end)
    end)

    -- Botones
    local ScanBtn = Instance.new("TextButton")
    ScanBtn.Size = UDim2.new(0.5, -15, 0, 50)
    ScanBtn.Position = UDim2.new(0, 10, 0, 45)
    ScanBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    ScanBtn.Text = "1. INICIAR AUDITORÍA\n(Seguridad del Server)"
    ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScanBtn.Font = Enum.Font.Code
    ScanBtn.TextSize = 14
    ScanBtn.Parent = MainFrame

    local KillBtn = Instance.new("TextButton")
    KillBtn.Size = UDim2.new(0.5, -15, 0, 50)
    KillBtn.Position = UDim2.new(0.5, 5, 0, 45)
    KillBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
    KillBtn.Text = "2. ENCENDER KILLAURA\n(Inmortal / Ghost Reaper)"
    KillBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    KillBtn.Font = Enum.Font.Code
    KillBtn.TextSize = 14
    KillBtn.Parent = MainFrame

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
    LogText.Text = ">>> THE GHOST REAPER INYECTADO <<<\n\nVulnerabilidades explotadas en este módulo:\n1. Bloqueo de Remotes de Kickeo (Inmunidad).\n2. Teleport al Punto Ciego del zombi (+6.5 studs arriba, para que no puedan tocarte).\n3. Sistema de auto-equipamiento de tool y cliks automáticos validados por el motor del servidor (Dado que descubrimos que el arma no usa LocalScripts ni Remotes falsos).\n\n🔥 INSTRUCCIONES:\nSolo toca el Botón 2 morado de arriba. El bot te pondrá la espada en la mano mágicamente y saltará de cabeza en cabeza cazando zombis infinitamente y farmeando su oro. Si quieres que se detenga, vuelve a tocar el Botón 2."
    LogText.TextColor3 = Color3.fromRGB(255, 150, 255)
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
    CopyBtn.Text = "COPIAR LOGS (POR SI SALTA ALGUN ERROR)"
    CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyBtn.Font = Enum.Font.Code
    CopyBtn.TextSize = 14
    CopyBtn.Parent = MainFrame

    ScanBtn.MouseButton1Click:Connect(function()
        pcall(function() Analyzer:Clear(); SecurityAudit:RunAudit(); CombatDissector:Analyze() end)
    end)

    KillBtn.MouseButton1Click:Connect(function()
        pcall(function()
            local isActive = KillAura:Toggle()
            if isActive then
                KillBtn.Text = "🛑 APAGAR KILLAURA"
                KillBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            else
                KillBtn.Text = "2. ENCENDER KILLAURA\n(Inmortal / Ghost Reaper)"
                KillBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
            end
        end)
    end)
    
    CopyBtn.MouseButton1Click:Connect(function()
        pcall(function()
            if type(setclipboard) == "function" then
                setclipboard(LogText.Text)
                CopyBtn.Text = "¡COPIADO!"
                task.delay(1, function() CopyBtn.Text = "COPIAR LOGS" end)
            end
        end)
    end)
end

ConstruirUI()
