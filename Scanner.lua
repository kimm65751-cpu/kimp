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
-- 4. CONTROLADOR FÍSICO Y ANTI-GRAVEDAD (Vuelo Limpio)
-- ==========================================================
local altura_flotacion = 15

task.spawn(function()
    while true do
        pcall(function()
            local miPersonaje = LP.Character
            if not miPersonaje or not miPersonaje.PrimaryPart then return end
            
            local myId = tostring(LP.UserId)
            local clientPets = Workspace:FindFirstChild("ClientPets")
            if not clientPets then return end
            
            for _, pet in pairs(clientPets:GetChildren()) do
                if pet:IsA("Model") then
                    local owner = tostring(pet:GetAttribute("OwnerUserId") or "")
                    
                    -- Si es nuestra mascota o está muy cerca
                    if owner == myId or (pet.PrimaryPart and (pet.PrimaryPart.Position - miPersonaje.PrimaryPart.Position).Magnitude < 40) then
                        
                        local humanoid = pet:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            -- TRUCO MAGISTRAL: No forzamos `.Position`, le decimos al motor 
                            -- que las piernas del pet miden 15 metros. El pet caminará naturalmente por el aire.
                            if humanoid.HipHeight < altura_flotacion then
                                humanoid.HipHeight = altura_flotacion
                                
                                -- Ajustar variables de salto o escalada por si acaso
                                humanoid.UseJumpPower = true
                                humanoid.JumpPower = 0
                            end
                        end
                        
                        -- En caso de que usen algo distinto al Humanoid (como Animators/BodyVelocity)
                        if pet.PrimaryPart then
                            local ap = pet.PrimaryPart:FindFirstChildWhichIsA("AlignPosition")
                            if ap and ap.Attachment1 and ap.Attachment1.Parent then
                                -- Corregimos la atracción visual también
                                local pX, pY, pZ = ap.Attachment1.Position.X, ap.Attachment1.Position.Y, ap.Attachment1.Position.Z
                                if pY < altura_flotacion then
                                    ap.Attachment1.Position = Vector3.new(pX, pY + altura_flotacion, pZ)
                                end
                            end
                        end
                        
                    end
                end
            end
        end)
        task.wait(0.5) -- Revisar medio segundo, HipHeight es persistente
    end
end)


-- ==========================================================
-- 5. ATAQUE SPAMMER: SATURACIÓN DE SERVIDOR (Click Aura)
-- ==========================================================
-- Como descubrimos que el servidor rige el ritmo (AttackSpeed ignorado local),
-- vamos a bombardear el ClickDetector (MouseClick) del monstruo lejano.
-- Esto forzará al servidor a crear "FightLogicPlayerCreate" de forma superpuesta si no tiene rate-limit.
local TargetAura = true
local Rango_Aura = 200

task.spawn(function()
    while true do
        if TargetAura then
            pcall(function()
                local miPersonaje = LP.Character
                if not miPersonaje or not miPersonaje.PrimaryPart then return end
                local myPos = miPersonaje.PrimaryPart.Position
                
                -- Buscar todos los ClickDetectors de monstros activos
                local function BuscarEn(carpeta)
                    if not carpeta then return end
                    for _, obj in pairs(carpeta:GetChildren()) do
                        local cd = obj:FindFirstChildWhichIsA("ClickDetector", true)
                        if cd then
                            local part = cd.Parent
                            if part and part:IsA("BasePart") then
                                local dist = (part.Position - myPos).Magnitude
                                if dist <= Rango_Aura then
                                    -- ¡Fuego! (Disparar el click remote)
                                    -- Algunos ClickDetectors en local firing requieren usar fireclickdetector si usas exploit, 
                                    -- pero fireclickdetector(cd) depende del inyector. Usaremos un fallback nativo si no hay fireclick.
                                    if type(fireclickdetector) == "function" then
                                        fireclickdetector(cd, 0)
                                    end
                                end
                            end
                        end
                    end
                end
                
                -- Las clásicas carpetas donde podrían estar los Mobs 
                BuscarEn(Workspace:FindFirstChild("Monsters"))
                BuscarEn(Workspace:FindFirstChild("ClientMonsters"))
                BuscarEn(Workspace:FindFirstChild("Bosses"))
            end)
        end
        -- Disparar cada 0.1s (10 Clicks por segundo por Monstruo en el Radar)
        task.wait(0.1)
    end
end)

-- ==========================================================
-- 6. AUDITORÍA DE RED (ESPIA DEL SERVIDOR LOG)
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

AddLog("Configuración Física inicializada: Mascotas elevarán su vuelo a " .. altura_flotacion .. "m con HipHeight.", Color3.fromRGB(255, 150, 255))
AddLog("Aura de Ataque (ClickDetector) Activada: Saturando Servidor...", Color3.fromRGB(255, 0, 0))
