-- =====================================================================
-- DELTA OMNI-TRACKER v3.0 (GUI FORENSE EN VIVO)
-- Registra Coordenadas, Economía, Herramientas, Toques y Red.
-- Actualizable vía GitHub 2026. Indetectable (CoreGui).
-- =====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local TrackerRunning = true

-- =====================================================================
-- 1. CREACIÓN DE LA INTERFAZ GRÁFICA (GUI FANTASMA)
-- =====================================================================
-- Destruir GUI anterior si existe para evitar duplicados
if CoreGui:FindFirstChild("OmniTrackerGUI") then
    CoreGui.OmniTrackerGUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OmniTrackerGUI"
ScreenGui.Parent = CoreGui -- Oculto del juego

-- Marco Principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = " 🕵️ OMNI-TRACKER V3.0 (LIVE LOGS)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.Code
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Botón Refrescar (Github)
local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0, 100, 0, 30)
RefreshBtn.Position = UDim2.new(1, -105, 0, 5)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
RefreshBtn.Text = "Refrescar (.lua)"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Font = Enum.Font.Code
RefreshBtn.TextSize = 12
RefreshBtn.Parent = MainFrame

-- Contenedor de Logs (Scroll)
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

-- =====================================================================
-- 2. MOTOR DE REGISTRO (LOGGING ENGINE)
-- =====================================================================
local LogIndex = 0

-- Función para añadir entradas ordenadas al menú
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
    
    -- Botón de Copiar Portapapeles (Executor Only)
    if copiableData then
        local CopyBtn = Instance.new("TextButton")
        CopyBtn.Size = UDim2.new(0, 50, 0, 30)
        CopyBtn.Position = UDim2.new(1, -55, 0, 5)
        CopyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        CopyBtn.Text = "Copiar"
        CopyBtn.TextColor3 = Color3.fromRGB(255,255,255)
        CopyBtn.Font = Enum.Font.Code
        CopyBtn.TextSize = 12
        CopyBtn.Parent = LogEntry
        
        CopyBtn.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(copiableData)
                CopyBtn.Text = "OK!"
                task.wait(1)
                CopyBtn.Text = "Copiar"
            end
        end)
    end
    
    -- Auto-Scroll al fondo
    LogScroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
    LogScroll.CanvasPosition = Vector2.new(0, LogScroll.CanvasSize.Y.Offset)
end

-- =====================================================================
-- 3. MÓDULOS DE RASTREO EN VIVO (LIVE SPY HOOKS)
-- =====================================================================

--- A. REMOTE SPY (Todo lo que envías al servidor)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    if TrackerRunning and not checkcaller() then
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            local args = {...}
            local argStr = ""
            for i,v in pairs(args) do
                argStr = argStr .. "Arg" .. i .. ":" .. tostring(v) .. " | "
            end
            local payload = "Remote: " .. tostring(self.Name) .. "\nArgs: " .. argStr
            AddLog("RED", "Paquete enviado a: " .. tostring(self.Name), payload)
        end
    end
    return oldNamecall(self, ...)
end))

--- B. TRACKER DE FÍSICA Y COORDENADAS (Donde pisas y caminas)
local lastPos = nil
RunService.Heartbeat:Connect(function()
    if not TrackerRunning then return end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        
        -- Si me moví de manera significativa o si toco algo nuevo (Log cada 15 studs)
        if not lastPos or (pos - lastPos).Magnitude > 15 then
            lastPos = pos
            local coordStr = string.format("X: %.1f, Y: %.1f, Z: %.1f", pos.X, pos.Y, pos.Z)
            AddLog("FISICA", "Jugador se movió a Ruta: " .. coordStr, coordStr)
        end
    end
end)

--- C. TRACKER DE CONTACTO (Qué pisamos / Trampas invisibles)
local touchedDebounce = {}
local function SetupTouchSpy(character)
    local root = character:WaitForChild("HumanoidRootPart", 5)
    if root then
        root.Touched:Connect(function(hit)
            if TrackerRunning and hit.Parent ~= character and not touchedDebounce[hit] then
                touchedDebounce[hit] = true
                local pathInfo = hit:GetFullName()
                AddLog("FISICA", "Tocaste el objeto: " .. hit.Name, "Objeto tocado: " .. pathInfo)
                task.delay(5, function() touchedDebounce[hit] = nil end)
            end
        end)
    end
end

--- D. TRACKER DE HERRAMIENTAS Y BOTONES (Qué equipamos)
local function SetupToolSpy(character)
    character.ChildAdded:Connect(function(child)
        if TrackerRunning and child:IsA("Tool") then
            AddLog("TOOL", "Herramienta Equipada: " .. child.Name, child.Name)
            child.Activated:Connect(function()
                AddLog("TOOL", "Usaste la herramienta: " .. child.Name, child.Name .. " - Activada")
            end)
        end
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

--- E. TRACKER DE ECONOMÍA / STATS (Monedas, Vida, Experiencia)
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
    TrackerRunning = false -- Apaga los hooks
    ScreenGui:Destroy() -- Se autodestruye
    -- Ejecuta la versión cruda nuevamente desde la fuente 
    loadstring(game:HttpGet("https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"))()
end)

AddLog("SISTEMA", "Omni-Tracker V3 cargado con éxito. Escuchando en vivo.", "¡OmniTracker Listo!")
