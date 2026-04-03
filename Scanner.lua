-- ==============================================================================
-- 🦖 CATCH A MONSTER: AUTO-FARM V1.0 (PANEL MULTI-HACKS DE DEFENSA)
-- Creado para: Pruebas Aisladas de Evasión de Daño y Curación Portátil
-- ==============================================================================

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer

-- Variables de Estado (Toggles)
local Toggles = {
    Aereo = false,
    Subterraneo = false,
    SinDueno = false,
    Ghosting = false,
    Fountain = false,
    ESP = true
}

-- ==========================================================
-- 1. CREACIÓN DE LA INTERFAZ GRÁFICA (GUI & LOGS)
-- ==========================================================
local UI_Name = "CAM_AnalyzerBot"
if CoreGui:FindFirstChild(UI_Name) then CoreGui[UI_Name]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = UI_Name
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = pcall(function() return CoreGui.Name end) and CoreGui or LP:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 480, 0, 380)
MainFrame.Position = UDim2.new(0.6, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 40, 50)
Title.Text = " 🦖aR: PANEL DE EVASIÓN"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Contenedor de Botones (Opciones Exclusivas)
local BtnFrame = Instance.new("Frame", MainFrame)
BtnFrame.Size = UDim2.new(1, 0, 0, 100)
BtnFrame.Position = UDim2.new(0, 0, 0, 35)
BtnFrame.BackgroundTransparency = 1

local UIGridLayout = Instance.new("UIGridLayout", BtnFrame)
UIGridLayout.CellSize = UDim2.new(0.3, -5, 0, 25)
UIGridLayout.CellPadding = UDim2.new(0, 5, 0, 5)

local LogFrame = Instance.new("ScrollingFrame", MainFrame)
LogFrame.Size = UDim2.new(1, -20, 1, -150)
LogFrame.Position = UDim2.new(0, 10, 0, 140)
LogFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LogFrame.ScrollBarThickness = 6
LogFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local UIListLayout = Instance.new("UIListLayout", LogFrame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Función para inyectar logs visuales
local function AddLog(texto, color)
    local msg = Instance.new("TextLabel", LogFrame)
    msg.Size = UDim2.new(1, 0, 0, 16)
    msg.BackgroundTransparency = 1
    msg.Text = "["..os.date("%X").."] " .. texto
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    msg.Font = Enum.Font.Code
    msg.TextSize = 11
    msg.TextWrapped = true
    msg.AutomaticSize = Enum.AutomaticSize.Y
    LogFrame.CanvasPosition = Vector2.new(0, 99999)
end

-- Generador de Botones Dinámico
local function ActivarModo(nombreActivo)
    -- Para hacerlos mutuamente exclusivos (excepto ESP y Modos que combinan)
    local excluyentes = {"Aereo", "Subterraneo", "Ghosting"}
    if table.find(excluyentes, nombreActivo) then
        for _, n in pairs(excluyentes) do
            if n ~= nombreActivo then Toggles[n] = false end
        end
    end
end

local function CrearBoton(nombre, texto)
    local btn = Instance.new("TextButton", BtnFrame)
    btn.Text = texto
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    btn.MouseButton1Click:Connect(function()
        Toggles[nombre] = not Toggles[nombre]
        ActivarModo(nombre)
        
        -- Actualizar colores de todos
        for i, v in ipairs(BtnFrame:GetChildren()) do
            if v:IsA("TextButton") then
                local toggleName = v.Name
                v.BackgroundColor3 = Toggles[toggleName] and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(50, 50, 50)
            end
        end
        AddLog("Modo [".. texto .."] cambiado a: " .. tostring(Toggles[nombre]), Color3.fromRGB(0, 255, 255))
    end)
    btn.Name = nombre
    return btn
end

CrearBoton("Aereo", "1. Flotar (Hip=25)")
CrearBoton("Subterraneo", "2. Tóxicos (Hip=-10)")
CrearBoton("SinDueno", "3. Neutralizar (Spoof)")
CrearBoton("Ghosting", "4. Ghost (Ráfaga)")
CrearBoton("Fountain", "5. Fuente Portátil")
CrearBoton("ESP", "6. ESP Huevos")

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
    gui.AlwaysOnTop = true
    gui.Parent = ESP_Folder
    
    local txt = Instance.new("TextLabel", gui)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = color
    txt.TextScaled = true
    txt.Font = Enum.Font.GothamBold
    
    task.spawn(function()
        while gui.Parent and objeto and objeto.Parent do
            gui.Enabled = Toggles.ESP
            if Toggles.ESP and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
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

-- ==========================================================
-- 3. INTERSECCIÓN DE MEMORIA LUA (GETGC) PARA RANGO
-- ==========================================================
task.spawn(function()
    while true do
        pcall(function()
            for _, v in pairs(getgc(true)) do
                if type(v) == "table" then
                    if rawget(v, "AttackRange") and type(v.AttackRange) == "number" and v.AttackRange < 150 then v.AttackRange = 300 end
                    if rawget(v, "CatchRange") and type(v.CatchRange) == "number" and v.CatchRange < 150 then v.CatchRange = 300 end
                end
            end
        end)
        task.wait(10)
    end
end)

-- ==========================================================
-- 4. CONTROLADOR FÍSICO Y EVASIÓN TÁCTICA
-- ==========================================================
local OriginalOwners = {}

task.spawn(function()
    while true do
        pcall(function()
            local miPersonaje = LP.Character
            if not miPersonaje or not miPersonaje.PrimaryPart then return end
            
            local myId = tostring(LP.UserId)
            local clientPets = Workspace:FindFirstChild("ClientPets")
            if not clientPets then return end
            
            -- Lógica para la Fuente Curativa Portátil
            if Toggles.Fountain then
                local fountainPart = nil
                -- Buscar una zona de curación en el mapa
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():match("heal") or obj.Name:lower():match("recover") or obj.Name:lower():match("fountain")) then
                        fountainPart = obj
                        break
                    end
                end
                
                if fountainPart and not fountainPart.Anchored then 
                    -- Si es un prop, teletransportarlo bajo nosotros
                    fountainPart.CFrame = miPersonaje.PrimaryPart.CFrame * CFrame.new(0, -2, 0)
                elseif fountainPart and fountainPart.Anchored then
                    -- Si es anclado, intentamos sobreescribirlo pero puede fallar
                    pcall(function() fountainPart.CFrame = miPersonaje.PrimaryPart.CFrame * CFrame.new(0, -2, 0) end)
                end
            end
            
            for _, pet in pairs(clientPets:GetChildren()) do
                if pet:IsA("Model") then
                    -- Restaurar Dueño si lo apagaron
                    if not Toggles.SinDueno and OriginalOwners[pet] then
                        pet:SetAttribute("OwnerUserId", OriginalOwners[pet])
                        OriginalOwners[pet] = nil
                    end

                    local ownerAttr = pet:GetAttribute("OwnerUserId")
                    local isMine = (tostring(ownerAttr) == myId) or (OriginalOwners[pet] == myId)
                    
                    if isMine then
                        OriginalOwners[pet] = myId
                        
                        -- Toggle 3: Spoof de Dueño (Ignorado por I.A. Enemiga)
                        if Toggles.SinDueno and pet:GetAttribute("OwnerUserId") ~= nil then
                            pet:SetAttribute("OwnerUserId", nil) 
                            pet:SetAttribute("IsPlayer", true) -- Spoof opcional
                        end
                        
                        local humanoid = pet:FindFirstChildOfClass("Humanoid")
                        local pp = pet.PrimaryPart
                        
                        if humanoid and pp then
                            -- Toggle 1 y 2: HipHeight Manipulation
                            if Toggles.Aereo then
                                humanoid.HipHeight = 25
                            elseif Toggles.Subterraneo then
                                humanoid.HipHeight = -10 -- Ir debajo de la tierra (Los proyectiles chocarán con el pasto)
                            else
                                if humanoid.HipHeight == 25 or humanoid.HipHeight == -10 then
                                    humanoid.HipHeight = 2 -- Restaurar Default aprox
                                end
                            end
                            
                            -- Toggle 4: Ghosting Strike
                            -- Dejaremos al Humanoide congelado al lado tuyo pero lanzaremos 
                            -- raycasts o lo haremos vibrar
                            if Toggles.Ghosting then
                                if not pp.Anchored then
                                    -- Lo anclamos a nuestra espalda
                                    pp.Anchored = true
                                    pp.CFrame = miPersonaje.PrimaryPart.CFrame * CFrame.new(0, 0, 5)
                                    
                                    -- De aquí, el script real "intentará" atacar, pero físicamente el pet es un holograma seguro.
                                end
                            else
                                if pp.Anchored then pp.Anchored = false end
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.2) 
    end
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
                    AddLog("⚠️ Daño detectado. (La Evasión falló en este intento)", Color3.fromRGB(255, 100, 100))
                end)
            end
            if monsterHurt then
                monsterHurt.OnClientEvent:Connect(function()
                    AddLog("💀 Monstruo Eliminado con Éxito.", Color3.fromRGB(255, 200, 0))
                end)
            end
        end
    end
end)

AddLog("Panel Multi-Vector Cargado. Elige tu arma.", Color3.fromRGB(0, 255, 0))
