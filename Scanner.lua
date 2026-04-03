-- ==============================================================================
-- 🦖 CATCH A MONSTER: AUTO-FARM V1.0 (GUI + HUEVOS + FLOTADOR DE MASCOTAS)
-- Creado para: Pruebas de filtrado Server-Side y Ataques Aéreos
-- ==============================================================================

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer

-- ==========================================================
-- 1. CREACIÓN DE LA INTERFAZ GRÁFICA (GUI & LOGS)
-- ==========================================================
local UI_Name = "CAM_AnalyzerBot"
if CoreGui:FindFirstChild(UI_Name) then
    CoreGui[UI_Name]:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = UI_Name
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local getGuiParent = function()
    local ok = pcall(function() return CoreGui.Name end)
    if ok then return CoreGui end
    return LP:WaitForChild("PlayerGui")
end
ScreenGui.Parent = getGuiParent()

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 450, 0, 320)
MainFrame.Position = UDim2.new(0.6, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- (Simple drag nativo)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 40, 50)
Title.Text = " 🦖 CATCH A MONSTER V1 - TEST VECTOR"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local LogFrame = Instance.new("ScrollingFrame", MainFrame)
LogFrame.Size = UDim2.new(1, -20, 1, -50)
LogFrame.Position = UDim2.new(0, 10, 0, 40)
LogFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LogFrame.ScrollBarThickness = 6
LogFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local UIListLayout = Instance.new("UIListLayout", LogFrame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 2)

local ToggleESPBtn = Instance.new("TextButton", Title)
ToggleESPBtn.Size = UDim2.new(0, 80, 0, 20)
ToggleESPBtn.Position = UDim2.new(1, -90, 0, 5)
ToggleESPBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
ToggleESPBtn.Text = "ESP: ON"
ToggleESPBtn.Font = Enum.Font.GothamBold
ToggleESPBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
local ESPEnabled = true

-- Función para inyectar logs visuales
local function AddLog(texto, color)
    color = color or Color3.fromRGB(200, 200, 200)
    local msg = Instance.new("TextLabel", LogFrame)
    msg.Size = UDim2.new(1, 0, 0, 16)
    msg.BackgroundTransparency = 1
    msg.Text = "["..os.date("%X").."] " .. texto
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.TextColor3 = color
    msg.Font = Enum.Font.Code
    msg.TextSize = 12
    msg.TextWrapped = true
    msg.AutomaticSize = Enum.AutomaticSize.Y
    
    LogFrame.CanvasPosition = Vector2.new(0, 99999)
end

AddLog("Iniciando Módulos de Penetración...", Color3.fromRGB(0, 255, 255))

-- ==========================================================
-- 2. SISTEMA ESP GLOBAL (HUEVOS Y PICKUPS)
-- ==========================================================
local ESP_Folder = Instance.new("Folder", ScreenGui)
ESP_Folder.Name = "ESP_World"

local function CrearESP(objeto, color, texto_base)
    if not objeto or not objeto.Parent then return end
    if ESP_Folder:FindFirstChild(objeto.Name .. "_" .. tostring(objeto:GetDebugId(10))) then return end
    
    local gui = Instance.new("BillboardGui")
    gui.Name = objeto.Name .. "_" .. tostring(objeto:GetDebugId(10))
    gui.Adornee = objeto:IsA("Model") and (objeto.PrimaryPart or objeto:FindFirstChildWhichIsA("BasePart")) or objeto
    gui.Size = UDim2.new(0, 150, 0, 50)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
    gui.Parent = ESP_Folder
    gui.Enabled = ESPEnabled
    
    local txt = Instance.new("TextLabel", gui)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = color
    txt.TextStrokeTransparency = 0
    txt.TextScaled = true
    txt.Font = Enum.Font.GothamBold
    
    task.spawn(function()
        while gui.Parent and objeto and objeto.Parent do
            gui.Enabled = ESPEnabled
            if ESPEnabled and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                local ad = gui.Adornee
                if ad then
                    local dist = math.floor((ad.Position - LP.Character.HumanoidRootPart.Position).Magnitude)
                    txt.Text = texto_base .. "\n[" .. dist .. "m]"
                end
            end
            task.wait(0.5)
        end
        if gui then gui:Destroy() end
    end)
end

local function BuscarPickups()
    local areaPickUp = Workspace:FindFirstChild("AreaPickUp")
    if areaPickUp then
        for _, obj in pairs(areaPickUp:GetChildren()) do
            local nl = string.lower(obj.Name)
            if string.find(nl, "egg") or (obj:GetAttribute("RewardRes") == "Egg") then
                CrearESP(obj, Color3.fromRGB(255, 255, 0), "🥚 HUEVO")
            else
                CrearESP(obj, Color3.fromRGB(100, 255, 100), "💎 LOOT: " .. obj.Name)
            end
        end
        
        areaPickUp.ChildAdded:Connect(function(obj)
            task.wait(0.2)
            local nl = string.lower(obj.Name)
            if string.find(nl, "egg") or (obj:GetAttribute("RewardRes") == "Egg") then
                CrearESP(obj, Color3.fromRGB(255, 255, 0), "🥚 HUEVO DROPEADO")
            else
                CrearESP(obj, Color3.fromRGB(100, 255, 100), "💎 LOOT")
            end
        end)
    end
end
BuscarPickups()

ToggleESPBtn.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    ToggleESPBtn.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"
    ToggleESPBtn.BackgroundColor3 = ESPEnabled and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(200, 100, 100)
end)

-- ==========================================================
-- 3. INTERSECCIÓN DE MEMORIA LUA (GETGC) PARA ATAQUE/RANGO
-- ==========================================================
task.spawn(function()
    local countExitos = 0
    while true do
        pcall(function()
            for _, v in pairs(getgc(true)) do
                if type(v) == "table" then
                    local altered = false
                    
                    -- Hacking Rangos
                    if rawget(v, "AttackRange") and type(v.AttackRange) == "number" and v.AttackRange < 150 then
                        v.AttackRange = 300; altered = true
                    end
                    if rawget(v, "CatchRange") and type(v.CatchRange) == "number" and v.CatchRange < 150 then
                        v.CatchRange = 300; altered = true
                    end
                    if rawget(v, "MaxCatchDistance") and type(v.MaxCatchDistance) == "number" and v.MaxCatchDistance < 150 then
                        v.MaxCatchDistance = 300; altered = true
                    end
                    
                    -- Hacking Velocidad (Cooldown Limit Bypass)
                    if rawget(v, "AttackSpeed") and type(v.AttackSpeed) == "number" and v.AttackSpeed > 0.1 then
                        v.AttackSpeed = 0.05; altered = true
                    end
                    if rawget(v, "AttackCooldown") and type(v.AttackCooldown) == "number" and v.AttackCooldown > 0.1 then
                        v.AttackCooldown = 0.05; altered = true
                    end
                    
                    if altered then countExitos = countExitos + 1 end
                end
            end
        end)
        
        if countExitos > 0 then
            AddLog("✔️ MemoryScan exitoso: " .. countExitos .. " tablas inyectadas con Rango: 300, Cooldown: 0.05", Color3.fromRGB(100, 255, 100))
            countExitos = 0
        end
        task.wait(10)
    end
end)

-- ==========================================================
-- 4. CONTROLADOR FÍSICO: MASCOTAS FLOTANTES (Anti-Grounding)
-- ==========================================================
-- Identificaremos tus mascotas en Workspace.ClientPets y haremos que ataquen desde el aire (15 studs arriba)
local altura_flotacion = 15

task.spawn(function()
    RunService.Stepped:Connect(function()
        pcall(function()
            local miPersonaje = LP.Character
            if not miPersonaje or not miPersonaje.PrimaryPart then return end
            
            local myId = tostring(LP.UserId)
            local clientPets = Workspace:FindFirstChild("ClientPets")
            if not clientPets then return end

            local misMascotasValidadas = 0
            
            for _, pet in pairs(clientPets:GetChildren()) do
                if pet:IsA("Model") and pet.PrimaryPart then
                    -- Filtrar solo TUS mascotas. 
                    -- Usualmente el juego guarda un Attribute de 'OwnerUserId'
                    local owner = tostring(pet:GetAttribute("OwnerUserId") or "")
                    
                    if owner == myId or (pet.PrimaryPart.Position - miPersonaje.PrimaryPart.Position).Magnitude < 40 then
                        misMascotasValidadas = misMascotasValidadas + 1
                        
                        -- Intentar anular gravedad o empuje si el servidor usa AlignPosition
                        local bodyVelocity = pet.PrimaryPart:FindFirstChildWhichIsA("BodyVelocity")
                        local bp = pet.PrimaryPart:FindFirstChildWhichIsA("AlignPosition")
                        
                        if bp then
                            -- Si el juego las mueve moviendo el AlignPosition a un target (monstruo),
                            -- simplemente hackeamos el Y offset de su target:
                            if bp.Attachment1 and bp.Attachment1.Parent then
                                -- Mover la marca (Attachment) objetivo 15 studs hacia arriba
                                local currentV = bp.Attachment1.Position
                                bp.Attachment1.Position = Vector3.new(currentV.X, altura_flotacion, currentV.Z)
                            else
                                -- Modificar directamente CFrame si no obedecen
                                pet.PrimaryPart.CFrame = pet.PrimaryPart.CFrame + Vector3.new(0, 0.5, 0)
                            end
                        else
                            -- Mascota normal movida por CFrame, solo elevarla.
                            pet.PrimaryPart.CFrame = CFrame.new(pet.PrimaryPart.Position.X, miPersonaje.PrimaryPart.Position.Y + altura_flotacion, pet.PrimaryPart.Position.Z)
                        end
                    end
                end
            end
        end)
    end)
end)

-- ==========================================================
-- 5. AUDITORÍA DE RED (ESPIA DEL SERVIDOR LOG)
-- ==========================================================
task.spawn(function()
    local commonLib = ReplicatedStorage:FindFirstChild("CommonLibrary")
    if commonLib then
        local remoteManager = commonLib:FindFirstChild("Tool") and commonLib.Tool:FindFirstChild("RemoteManager")
        if remoteManager and remoteManager:FindFirstChild("Events") then
            local petHurt = remoteManager.Events:FindFirstChild("PetHurtInfo")
            local monsterHurt = remoteManager.Events:FindFirstChild("FightPlayerDie") or remoteManager.Events:FindFirstChild("SkillKillEffectEvent")
            
            if petHurt then
                petHurt.OnClientEvent:Connect(function()
                    AddLog("⚠️ Tu mascota recibió daño del monstruo (PetHurtInfo).", Color3.fromRGB(255, 100, 100))
                end)
            end
            if monsterHurt then
                monsterHurt.OnClientEvent:Connect(function()
                    AddLog("💀 Monstruo Murió (Kill Effect Validado).", Color3.fromRGB(255, 200, 0))
                end)
            end
        end
    end
end)

AddLog("Configuración Física inicializada: Mascotas elevarán su vuelo a " .. altura_flotacion .. "m en combate.", Color3.fromRGB(255, 150, 255))
