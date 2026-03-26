-- =====================================================================
-- DELTA OMNI-TRACKER v3.8 (GUI FORENSE EN VIVO)
-- Registra Coordenadas, Economía, Herramientas, Toques, Combate y Red.
-- Con Escáner Óptico de Interfaz (ScreenGui Reader) para Juegos RPG.
-- =====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local TrackerRunning = true

-- =====================================================================
-- 1. CREACIÓN DE LA INTERFAZ GRÁFICA (GUI FANTASMA)
-- =====================================================================
if CoreGui:FindFirstChild("OmniTrackerGUI") then
    CoreGui.OmniTrackerGUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OmniTrackerGUI"
ScreenGui.Parent = CoreGui 

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -25)
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenBtn.BorderSizePixel = 2
OpenBtn.BorderColor3 = Color3.fromRGB(0, 120, 200)
OpenBtn.Text = "👁️"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.TextSize = 25
OpenBtn.Visible = false 
OpenBtn.Draggable = true
OpenBtn.Active = true
OpenBtn.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = " 🕵️ OMNI-TRACKER V3.8 (RCTRL para ocultar)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.Code
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -145, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 50)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.Code
MinimizeBtn.TextSize = 20
MinimizeBtn.Parent = MainFrame

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0, 105, 0, 30)
RefreshBtn.Position = UDim2.new(1, -110, 0, 5)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
RefreshBtn.Text = "Refrescar (.lua)"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Font = Enum.Font.Code
RefreshBtn.TextSize = 12
RefreshBtn.Parent = MainFrame

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -20, 1, -60)
LogScroll.Position = UDim2.new(0, 10, 0, 50)
LogScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
LogScroll.ScrollBarThickness = 6
LogScroll.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = LogScroll
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function ToggleMenu()
    if MainFrame.Visible then
        MainFrame.Visible = false
        OpenBtn.Visible = true
    else
        MainFrame.Visible = true
        OpenBtn.Visible = false
    end
end

MinimizeBtn.MouseButton1Click:Connect(ToggleMenu)
OpenBtn.MouseButton1Click:Connect(ToggleMenu)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.RightControl then
            ToggleMenu()
        end
    end
end)

-- =====================================================================
-- 2. MOTOR DE REGISTRO (LOGGING ENGINE)
-- =====================================================================
local LogIndex = 0

local function AddLog(category, message, copiableData)
    LogIndex = LogIndex + 1
    
    local LogEntry = Instance.new("Frame")
    LogEntry.Size = UDim2.new(1, -10, 0, 40)
    LogEntry.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    LogEntry.Parent = LogScroll
    
    local TextPrefix = Instance.new("TextLabel")
    TextPrefix.Size = UDim2.new(0, 80, 1, 0)
    TextPrefix.BackgroundTransparency = 1
    TextPrefix.Text = "["..category.."]"
    if category == "RED" then TextPrefix.TextColor3 = Color3.fromRGB(200, 100, 100)
    elseif category == "COMBATE" then TextPrefix.TextColor3 = Color3.fromRGB(255, 80, 80)
    elseif category == "FISICA" then TextPrefix.TextColor3 = Color3.fromRGB(100, 200, 100)
    elseif category == "TOOL" then TextPrefix.TextColor3 = Color3.fromRGB(200, 200, 100)
    elseif category == "STAT" then TextPrefix.TextColor3 = Color3.fromRGB(255, 215, 0)
    else TextPrefix.TextColor3 = Color3.fromRGB(200, 200, 200) end
    TextPrefix.Font = Enum.Font.Code
    TextPrefix.TextSize = 14
    TextPrefix.Parent = LogEntry
    
    local LogMessage = Instance.new("TextLabel")
    LogMessage.Size = UDim2.new(1, -150, 1, 0)
    LogMessage.Position = UDim2.new(0, 85, 0, 0)
    LogMessage.BackgroundTransparency = 1
    LogMessage.Text = message
    LogMessage.TextColor3 = Color3.fromRGB(220, 220, 220)
    LogMessage.TextXAlignment = Enum.TextXAlignment.Left
    LogMessage.TextWrapped = true
    LogMessage.Font = Enum.Font.Code
    LogMessage.TextSize = 12
    LogMessage.Parent = LogEntry
    
    if copiableData then
        local CopyBtn = Instance.new("TextButton")
        CopyBtn.Size = UDim2.new(0, 45, 0, 25)
        CopyBtn.Position = UDim2.new(1, -50, 0, 7)
        CopyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        CopyBtn.Text = "Copy"
        CopyBtn.TextColor3 = Color3.fromRGB(255,255,255)
        CopyBtn.Font = Enum.Font.Code
        CopyBtn.TextSize = 12
        CopyBtn.Parent = LogEntry
        
        CopyBtn.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(copiableData)
                CopyBtn.Text = "OK"
                task.wait(1)
                CopyBtn.Text = "Copy"
            end
        end)
    end
    
    LogScroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
    LogScroll.CanvasPosition = Vector2.new(0, LogScroll.CanvasSize.Y.Offset)
end

-- =====================================================================
-- 3. MÓDULOS DE RASTREO EN VIVO (LIVE SPY HOOKS)
-- =====================================================================
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    if TrackerRunning and not checkcaller() then
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            local args = {...}
            
            task.spawn(function()
                local success, selfName = pcall(function() return self.Name end)
                if not success then selfName = "Remote_Desconocido" end
                
                local argStr = ""
                for i,v in pairs(args) do
                    local strVal = typeof(v) == "Instance" and v.Name or tostring(v)
                    argStr = argStr .. "Arg" .. i .. ":" .. strVal .. " | "
                end
                
                local payload = "Remote: " .. tostring(selfName) .. "\nArgs: " .. argStr
                AddLog("RED", "Paquete enviado a: " .. tostring(selfName), payload)
            end)
        end
    end
    return oldNamecall(self, ...)
end))

local lastPos = nil
RunService.Heartbeat:Connect(function()
    if not TrackerRunning then return end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        if not lastPos or (pos - lastPos).Magnitude > 15 then
            lastPos = pos
            local coordStr = string.format("X: %.1f, Y: %.1f, Z: %.1f", pos.X, pos.Y, pos.Z)
            AddLog("FISICA", "Jugador se movió a Ruta: " .. coordStr, coordStr)
        end
    end
end)

-- Buscador de Vida (Resguardo Físico)
local function GetHealthInfo(obj)
    local target = obj
    local loopCount = 0
    while target and target ~= workspace and loopCount < 3 do
        local hum = target:FindFirstChildOfClass("Humanoid")
        if hum then return "❤️ Vida: " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth), hum, target.Name end
        for _, child in pairs(target:GetChildren()) do
            if child:IsA("NumberValue") or child:IsA("IntValue") then
                local name = string.lower(child.Name)
                if name == "health" or name == "hp" or name == "vida" then
                    return "❤️ " .. child.Name .. ": " .. math.floor(child.Value), child, target.Name
                end
            end
        end
        local attr = target:GetAttribute("HP") or target:GetAttribute("Health")
        if attr then return "❤️ Atributo Vida: " .. math.floor(attr), target, target.Name end
        
        target = target.Parent
        loopCount = loopCount + 1
    end
    return "❓ Sin vida interna/visual descubierta", nil, obj.Name
end

local touchedDebounce = {}
local function SetupTouchSpy(character)
    local root = character:WaitForChild("HumanoidRootPart", 5)
    if root then
        root.Touched:Connect(function(hit)
            if TrackerRunning and hit.Parent ~= character and not touchedDebounce[hit] then
                touchedDebounce[hit] = true
                local hpString, _, objName = GetHealthInfo(hit)
                if hit.Name == "Baseplate" or string.find(string.lower(hit.Name), "terrain") then 
                    task.delay(2, function() touchedDebounce[hit] = nil end)
                    return 
                end
                AddLog("FISICA", "Tocaste: " .. objName .. " ("..hit.Name..") | " .. hpString, hit:GetFullName())
                task.delay(10, function() touchedDebounce[hit] = nil end)
            end
        end)
    end
end

-- =====================================================================
-- 3.5 LECTOR ÓPTICO DE INTERFAZ (SCREEN GUI HEALTH SPY)
-- =====================================================================
local function FindActiveHealthBar()
    local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil, nil end
    
    -- Recorremos todos los ScreenGuis buscando la barra de vida objetivo ("Pebble 9.63 HP")
    for _, gui in pairs(playerGui:GetDescendants()) do
        if gui:IsA("TextLabel") and gui.Visible and gui.TextTransparency < 1 then
            local text = gui.Text
            if string.find(string.lower(text), "hp") and string.match(text, "[%d%.]+") then
                return gui, text
            end
        end
    end
    return nil, nil
end

local Mouse = LocalPlayer:GetMouse()
local dmgDebounce = {}

local function AttachToolHooks(tool, character)
    -- Evitar duplicar radares en la misma herramienta
    if not TrackerRunning or tool:GetAttribute("Tracked") then return end
    tool:SetAttribute("Tracked", true)
    
    AddLog("TOOL", "Equipada: " .. tool.Name, tool.Name)
    
    tool.Activated:Connect(function()
        local target = Mouse.Target
        local targetName = target and target.Name or "Aire"
        
        -- Le damos al juego 0.1 segundos para que dibuje la barra de vida en tu pantalla
        task.delay(0.1, function()
            -- 1. Intentamos leer la vida ópticamente (De la esquina superior izquierda de tu pantalla)
            local hpLabel, hpText = FindActiveHealthBar()
            
            if hpLabel and not dmgDebounce[hpLabel] then
                dmgDebounce[hpLabel] = true
                
                -- Extraemos el Número y el Nombre "Pebble 9.63 HP" -> Num: 9.63 | Nom: Pebble
                local rawNumber = tonumber(string.match(hpText, "[%d%.]+")) or 0
                local cleanName = string.match(hpText, "([%a%s]+)") or targetName
                cleanName = cleanName:gsub("HP", ""):gsub("hp", ""):gsub("^%s*(.-)%s*$", "%1")
                
                AddLog("COMBATE", "Atacando a: " .. cleanName .. " | ❤️ " .. rawNumber .. " HP", "Obj: " .. cleanName)
                
                local startHp = rawNumber
                local conn
                conn = hpLabel:GetPropertyChangedSignal("Text"):Connect(function()
                    local newHp = tonumber(string.match(hpLabel.Text, "[%d%.]+")) or 0
                    if newHp > 0 and newHp < startHp then
                        local damage = startHp - newHp
                        AddLog("COMBATE", "💥 Daño Visual: " .. string.format("%.2f", damage) .. " a " .. cleanName, "Daño: " .. damage)
                    end
                    startHp = newHp
                end)
                
                task.delay(5, function() conn:Disconnect() end)
                task.delay(1, function() dmgDebounce[hpLabel] = nil end)
                
            else
                -- 2. Si no hay barra visual, usamos el método tradicional al Target Físico
                if target then
                    local hpString, healthObj, objName = GetHealthInfo(target)
                    -- Si no tiene vida, solo decimos a qué le dio clic
                    if objName == target.Name then objName = "Pieza: " .. target.Name end
                    AddLog("TOOL", "Click con " .. tool.Name .. " sobre " .. objName, target:GetFullName())
                end
            end
        end)
    end)
end

local function SetupToolSpy(character)
    -- Adjuntar a herramientas YA equipadas (Soluciona el bug de no registrar)
    for _, child in pairs(character:GetChildren()) do
        if child:IsA("Tool") then AttachToolHooks(child, character) end
    end
    -- Adjuntar a herramientas futuras
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then AttachToolHooks(child, character) end
    end)
end

if LocalPlayer.Character then
    SetupTouchSpy(LocalPlayer.Character)
    SetupToolSpy(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(function(char)
    SetupTouchSpy(char)
    SetupToolSpy(char)
end)

local function SetupStatSpy()
    local leaderstats = LocalPlayer:WaitForChild("leaderstats", 5)
    if leaderstats then
        leaderstats.DescendantChanged:Connect(function(stat)
            if TrackerRunning and (stat:IsA("IntValue") or stat:IsA("NumberValue")) then
                local statInfo = stat.Name .. " cambió a: " .. tostring(stat.Value)
                AddLog("STAT", "Economía alterada: " .. statInfo, statInfo)
            end
        end)
    end
end
task.spawn(SetupStatSpy)

-- =====================================================================
-- 4. CONECTOR GITHUB (BOTÓN DE REFRESCO)
-- =====================================================================
RefreshBtn.MouseButton1Click:Connect(function()
    AddLog("SISTEMA", "Descargando actualización desde GitHub...", "")
    TrackerRunning = false
    ScreenGui:Destroy()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"))()
end)

AddLog("SISTEMA", "Omni-Tracker V3.8 cargado con éxito. Escuchando en vivo.", "¡OmniTracker Listo!")
