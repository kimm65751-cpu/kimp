-- ==============================================================================
-- 🛡️ ANALIZADOR SEGURO Y MODULAR (SIN HOOKS INESTABLES)
-- Estructura modular consolidada en un solo archivo para subir a GitHub
-- ==============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

-- 🧩 1. CORE LOGGER (BASE)
local Analyzer = { Logs = {} }

function Analyzer:Log(txt)
    print("[ANALYZER] " .. txt)
    table.insert(self.Logs, txt)
    -- Si hay GUI conectada, actualizarla y hacer autoscroll hacia abajo
    if self.UI_LogBox then
        self.UI_LogBox.Text = self.UI_LogBox.Text .. "\n" .. txt
    end
end

-- 🌐 2. NETWORK ANALYZER (Escaneo estático seguro)
local Network = {}
function Network:ScanRemotes()
    local remotes = {}
    Analyzer:Log("===== ESCANEANDO REMOTES =====")
    
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            -- Solo guardamos los que parecen interesantes para no spamear
            local n = string.lower(v.Name)
            if string.find(n, "damage") or string.find(n, "hit") or string.find(n, "attack") or string.find(n, "reward") or string.find(n, "gold") or string.find(n, "give") then
                table.insert(remotes, v)
            end
        end
    end
    
    Analyzer:Log("Remotes criticos encontrados: " .. #remotes)
    for _, r in ipairs(remotes) do
        Analyzer:Log(" -> [" .. r.ClassName .. "] " .. r:GetFullName())
    end
end

-- 🧠 3. DETECTOR DE ACCIONES (ATAQUE, MINAR, COMPRAR)
local Behavior = {}
function Behavior:TrackTool()
    local player = Players.LocalPlayer
    Analyzer:Log("===== TRACKING DE ARMAS ACTIVO =====")
    
    local function ConectarPersonaje(char)
        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                Analyzer:Log("🔧 Tool equipada: " .. child.Name)
                
                child.Activated:Connect(function()
                    Analyzer:Log("⚔️ ACCION DETECTADA: Disparo/Golpe con " .. child.Name)
                end)
            end
        end)
    end
    
    if player.Character then
        ConectarPersonaje(player.Character)
    end
    player.CharacterAdded:Connect(ConectarPersonaje)
end

-- 🧱 4. WORLD SCANNER (NPCs / MOBS)
local World = {}
function World:ScanNPCs()
    local mobs = {}
    Analyzer:Log("===== ESCANEO DE MUNDO (NPCs) =====")
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                table.insert(mobs, obj)
                Analyzer:Log("👾 NPC Encontrado: " .. obj.Name .. " | HP: " .. math.floor(hum.Health))
            end
        end
    end
    
    Analyzer:Log("Total de NPCs vivos: " .. #mobs)
end

-- 🎒 5. INVENTARIO Y ARMAS
local Inventory = {}
function Inventory:Scan()
    local player = Players.LocalPlayer
    Analyzer:Log("===== INVENTARIO ACTUAL =====")
    
    local mochila = player:FindFirstChild("Backpack")
    if mochila then
        for _, tool in pairs(mochila:GetChildren()) do
            Analyzer:Log("🎒 En mochila: " .. tool.Name)
        end
    end
    
    if player.Character then
        for _, tool in pairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") then
                Analyzer:Log("✋ Equipada: " .. tool.Name)
            end
        end
    end
end

-- 📡 6. DETECTAR RECOMPENSAS / CAMBIOS DE DATOS
local Data = {}
function Data:TrackStats()
    local player = Players.LocalPlayer
    Analyzer:Log("===== TRACKING DE ECONOMIA ACTIVO =====")
    
    local stats = player:FindFirstChild("leaderstats")
    if stats then
        for _, v in pairs(stats:GetChildren()) do
            v:GetPropertyChangedSignal("Value"):Connect(function()
                Analyzer:Log("💰 CAMBIO DETECTADO -> " .. v.Name .. ": " .. tostring(v.Value))
            end)
        end
    else
        Analyzer:Log("❌ No se encontro la carpeta 'leaderstats'. Buscando atributos de jugador...")
        local attrs = player:GetAttributes()
        for k, v in pairs(attrs) do
            Analyzer:Log("  Atributo: " .. k .. " = " .. tostring(v))
        end
        player.AttributeChanged:Connect(function(attr)
            Analyzer:Log("💰 ATRIBUTO CAMBIADO -> " .. attr .. ": " .. tostring(player:GetAttribute(attr)))
        end)
    end
end

-- ==============================================================================
-- 🖥️ 7. INTERFAZ GRÁFICA SEGURA Y CONSTRUCTOR
-- ==============================================================================
local function ConstruirGUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "ForenseModularUI"
    sg.ResetOnSpawn = false
    
    local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Limpiar inyeccion previa
    for _, v in ipairs(parentUI:GetChildren()) do
        if v.Name == "ForenseModularUI" then v:Destroy() end
    end
    sg.Parent = parentUI

    -- Frame Principal
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 700, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    -- Barra Titulo
    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -30, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(0, 60, 100)
    TopBar.Text = "  ANALIZADOR MODULAR V1 (100% SEGURO / SIN HOOKS)"
    TopBar.TextColor3 = Color3.fromRGB(200, 255, 255)
    TopBar.Font = Enum.Font.Code
    TopBar.TextSize = 13
    TopBar.TextXAlignment = Enum.TextXAlignment.Left
    TopBar.Parent = MainFrame

    -- Boton Cerrar
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.Parent = MainFrame
    CloseBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

    -- Boton Accion Principal
    local ScanBtn = Instance.new("TextButton")
    ScanBtn.Size = UDim2.new(0.8, -10, 0, 40)
    ScanBtn.Position = UDim2.new(0, 10, 0, 40)
    ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    ScanBtn.Text = "EJECUTAR ESCANEO GLOBAL Y ACTIVAR MONITORES"
    ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScanBtn.Font = Enum.Font.Code
    ScanBtn.TextSize = 14
    ScanBtn.Parent = MainFrame
    
    local CopyBtn = Instance.new("TextButton")
    CopyBtn.Size = UDim2.new(0.2, -10, 0, 40)
    CopyBtn.Position = UDim2.new(0.8, 0, 0, 40)
    CopyBtn.BackgroundColor3 = Color3.fromRGB(30, 150, 30)
    CopyBtn.Text = "COPIAR LOG"
    CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyBtn.Font = Enum.Font.Code
    CopyBtn.TextSize = 13
    CopyBtn.Parent = MainFrame

    -- Caja de Logs Scrolling
    local ScrollArea = Instance.new("ScrollingFrame")
    ScrollArea.Size = UDim2.new(1, -20, 1, -100)
    ScrollArea.Position = UDim2.new(0, 10, 0, 90)
    ScrollArea.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
    ScrollArea.CanvasSize = UDim2.new(0, 0, 15, 0)
    ScrollArea.ScrollBarThickness = 6
    ScrollArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollArea.Parent = MainFrame

    local LogDisplay = Instance.new("TextLabel")
    LogDisplay.Size = UDim2.new(1, -15, 1, 0)
    LogDisplay.Position = UDim2.new(0, 5, 0, 5)
    LogDisplay.BackgroundTransparency = 1
    LogDisplay.Text = "Esperando orden. Presiona el boton azul..."
    LogDisplay.TextColor3 = Color3.fromRGB(0, 255, 120)
    LogDisplay.Font = Enum.Font.Code
    LogDisplay.TextSize = 12
    LogDisplay.TextXAlignment = Enum.TextXAlignment.Left
    LogDisplay.TextYAlignment = Enum.TextYAlignment.Top
    LogDisplay.TextWrapped = true
    LogDisplay.Parent = ScrollArea

    -- Conectar Interfaz al Analizador Central
    Analyzer.UI_LogBox = LogDisplay

    -- Evento Escanear
    local escaneado = false
    ScanBtn.MouseButton1Click:Connect(function()
        if escaneado then
            LogDisplay.Text = ""
            Analyzer.Logs = {}
        end
        escaneado = true
        
        LogDisplay.Text = ""
        Analyzer:Log(">>> INICIANDO ANALISIS COMPLETO <<<")
        
        -- Ejecucion Modular
        Network:ScanRemotes()
        World:ScanNPCs()
        Inventory:Scan()
        Behavior:TrackTool()
        Data:TrackStats()
        
        Analyzer:Log(">>> ESCANEO FINALIZADO <<<")
        Analyzer:Log("Monitores de Economía y Combate en vivo están ACTIVOS de fondo.")
    end)
    
    -- Evento Copiar
    CopyBtn.MouseButton1Click:Connect(function()
        pcall(function()
            if setclipboard then
                setclipboard(LogDisplay.Text)
                CopyBtn.Text = "COPIADO!"
                task.delay(2, function() CopyBtn.Text = "COPIAR LOG" end)
            end
        end)
    end)
end

-- 🚀 INICIAR SCRIPT
ConstruirGUI()
