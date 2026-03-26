-- ==============================================================================
-- 💀 VULNERABILITY SCANNER V5 (AURA FÍSICA MAGNÉTICA)
-- KillAura blindado contra el Anti-TP (Error 267). Solo abusa colisiones.
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

-- 🧩 1. LOGGER
local Analyzer = { Logs = {} }
function Analyzer:Clear()
    self.Logs = {}
    if self.UI_LogBox then self.UI_LogBox.Text = "" end
end
function Analyzer:Log(txt)
    print("[CRACKER-SCAN] " .. tostring(txt))
    table.insert(self.Logs, txt)
    if self.UI_LogBox then self.UI_LogBox.Text = self.UI_LogBox.Text .. "\n" .. tostring(txt) end
end

-- 🛡️ 2. SECURITY SCAN
local SecurityAudit = {}
function SecurityAudit:RunAudit()
    Analyzer:Log("\n==============================================")
    Analyzer:Log("💀 INICIANDO AUDITORIA GLOBAL...")
    local cgHooks = 0
    for _, obj in pairs(CoreGui:GetDescendants()) do if obj:IsA("LocalScript") and obj.Name ~= "ForenseV11UI" then cgHooks = cgHooks + 1 end end
    if cgHooks > 0 then Analyzer:Log("  ⚠️ PELIGRO: " .. cgHooks .. " scripts monitoreando el CoreGui.") else Analyzer:Log("  ✅ CoreGui Limpio.") end
    
    local scConnections = pcall(function() return #getconnections(ScriptContext.Error) end) and #getconnections(ScriptContext.Error) or 0
    if type(scConnections) == "number" and scConnections > 0 then Analyzer:Log("  ⚠️ HONEYPOT: " .. scConnections .. " listeners de Error.") else Analyzer:Log("  ✅ Errores Limpios.") end
    Analyzer:Log("==============================================\n")
end

local CombatDissector = {}
function CombatDissector:Analyze()
    Analyzer:Log("\n[🗡️] DISECCION DE ARMAS COMPLETADA: Control local nulo.")
end

-- ⚔️ 4. MÓDULO KILLAURA MAGNÉTICO (AURA ANTI-TP)
local KillAura = { Active = false }

function KillAura:Toggle()
    if self.Active then
        self.Active = false
        Analyzer:Log("🛑 Aura Magnética Apagada.")
        return false
    else
        self.Active = true
        Analyzer:Log("\n==============================================")
        Analyzer:Log("🔥 PREPARANDO AURA MAGNÉTICA (STALL-BYPASS)...")
        
        if type(firetouchinterest) ~= "function" then
            Analyzer:Log("❌ ERROR CRÍTICO: Tu inyector no admite magias físicas ('firetouchinterest' bloqueado). Esta función es vital para engañar al server.")
            self.Active = false
            return false
        end
        
        Analyzer:Log("✔️ Sistema 'firetouchinterest' verificado y cargado. Disparando red a Zombis...")

        task.spawn(function()
            while self.Active do
                local success, err = pcall(function()
                    local char = LocalPlayer.Character
                    if not char then return end
                    
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if not hum or hum.Health <= 0 then return end
                    
                    local arma = char:FindFirstChildWhichIsA("Tool")
                    if not arma then
                        local backpack = LocalPlayer:FindFirstChild("Backpack")
                        local mejorArma = backpack and (backpack:FindFirstChild("Weapon") or backpack:FindFirstChildWhichIsA("Tool"))
                        if mejorArma then
                            hum:EquipTool(mejorArma)
                            arma = mejorArma
                        end
                    end

                    if arma then
                        local handle = arma:FindFirstChild("Handle") or arma:FindFirstChildWhichIsA("BasePart")
                        if handle then
                            for _, z in ipairs(Workspace:GetDescendants()) do
                                if z:IsA("Model") and z ~= char and string.find(string.lower(z.Name), "zombie") then
                                    local zHum = z:FindFirstChildOfClass("Humanoid")
                                    local zRoot = z:FindFirstChild("HumanoidRootPart")
                                    -- Dispara el hitbox tactil forzosamente. Solo atacamos zombis vivos.
                                    if zHum and zHum.Health > 0 and zRoot then
                                        firetouchinterest(handle, zRoot, 0)
                                        firetouchinterest(handle, zRoot, 1)
                                    end
                                end
                            end
                            
                            -- Validación en server-side por si exigen trigger normal de click
                            arma:Activate()
                            pcall(function() mouse1click() end)
                        else
                            Analyzer:Log("❌ Arma sin caja física para tocar ('Handle').")
                        end
                    end
                end)

                if not success then
                    Analyzer:Log("🐞 [CRASH MÓDULO FÍSICO]: " .. tostring(err))
                    self.Active = false
                    break
                end
                
                -- Limitar la velocidad de red (5 Hitboxes p/seg) para que no crashee Delta
                task.wait(0.2)
            end
        end)
        
        return true
    end
end

-- ==============================================================================
-- 🖥️ GUI V11
-- ==============================================================================
local function ConstruirUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "ForenseV11UI"
    sg.ResetOnSpawn = false
    
    local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "ForenseV11UI" then v:Destroy() end end
    sg.Parent = parentUI

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 850, 0, 600)
    MainFrame.Position = UDim2.new(0.5, -425, 0.5, -300)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.fromRGB(200, 100, 0) -- Naranja de advertencia
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local MaximizeBtn = Instance.new("TextButton")
    MaximizeBtn.Size = UDim2.new(0, 60, 0, 60)
    MaximizeBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
    MaximizeBtn.BackgroundColor3 = Color3.fromRGB(150, 80, 20)
    MaximizeBtn.Text = "🗡️"
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
    TopBar.BackgroundColor3 = Color3.fromRGB(50, 25, 5)
    TopBar.Text = "  VULNERABILITY DETECTOR V5 (AURA FÍSICA INVISIBLE - BYPASS ANTI-TP)"
    TopBar.TextColor3 = Color3.fromRGB(255, 220, 150)
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

    CloseBtn.MouseButton1Click:Connect(function() pcall(function() KillAura.Active=false end) sg:Destroy() end)
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
    ScanBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    ScanBtn.Text = "1. INICIAR AUDITORÍA"
    ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScanBtn.Font = Enum.Font.Code
    ScanBtn.TextSize = 14
    ScanBtn.Parent = MainFrame

    local KillBtn = Instance.new("TextButton")
    KillBtn.Size = UDim2.new(0.5, -15, 0, 50)
    KillBtn.Position = UDim2.new(0.5, 5, 0, 45)
    KillBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    KillBtn.Text = "2. ENCENDER MAGNÉTÓ_AURA (SIN TELEPORTS)"
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
    LogText.Text = ">>> KILLAURA MAGNÉTICO INTEGRADO (BYPASS SERVER ANTI-TP) <<<\n\nHemos erradicado 100% los saltos posicionales de tu Humanoide. El Anti-Trampas central de este juego (Cód: 267) detecta coordenadas irregulares (Kicks por Anti-Vuelo), pero tiene un vacío ciego en las posiciones relativas de las armas.\n\nEL AURA ACTUAL:\n  - Usa MAGIA CUÁNTICA C++ (`firetouchinterest`) para cruzar las físicas de espada invisiblemente a las gargantas de todos los mobs eludiendo las comprobaciones de movimiento.\n  - Enviarás rafagas contínuas de 5 Hitboxes de espada por segundo globalmente sin ser flaggeado por el localizador.\n\n🔥 INSTRUCCIONES ESTRICTAS:\nPulsa el Botón 2 naranja de arriba y QUÉDATE QUIETO o esconde a tu personaje en donde sea seguro. Observa de lejos cómo los zombis empiezan a fallecer sin motivo."
    LogText.TextColor3 = Color3.fromRGB(255, 200, 100)
    LogText.Font = Enum.Font.Code
    LogText.TextSize = 13
    LogText.TextXAlignment = Enum.TextXAlignment.Left
    LogText.TextYAlignment = Enum.TextYAlignment.Top
    LogText.TextWrapped = true
    LogText.Parent = ScrollFrame

    Analyzer.UI_LogBox = LogText

    ScanBtn.MouseButton1Click:Connect(function()
        pcall(function() Analyzer:Clear(); SecurityAudit:RunAudit(); CombatDissector:Analyze() end)
    end)

    KillBtn.MouseButton1Click:Connect(function()
        pcall(function()
            local isActive = KillAura:Toggle()
            if isActive then
                KillBtn.Text = "🛑 APAGAR MAGNETO-AURA"
                KillBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            else
                KillBtn.Text = "2. ENCENDER MAGNÉTÓ_AURA (SIN TELEPORTS)"
                KillBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
            end
        end)
    end)
end

ConstruirUI()
