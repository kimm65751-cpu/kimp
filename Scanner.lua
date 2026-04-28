-- ==========================================
-- 🚀 Bloxburg Multi-Job AutoFarm + Elf Radar
-- ==========================================
-- Creado en base a intercepciones pasivas C->S
-- Trabajos: Panadero, Pescador, Peluquero, Repartidor
-- ==========================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local DataService = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("DataService")

-- El RemoteEvent multiplexado (ID 876751419)
local MainEvent = DataService:FindFirstChild("876751419") or ReplicatedStorage:FindFirstChild("876751419", true)

local getEvent = function()
    return MainEvent
end

-- Variables de Estado
local _G = _G or {}
_G.AutoFarmRunning = false
_G.CurrentJob = nil

local function StartJob(jobName)
    local remote = getEvent()
    if remote then
        -- Enviar código para "Empezar Turno"
        remote:InvokeServer({Job = jobName})
        print("[AutoFarm] Empezando trabajo: " .. jobName)
        task.wait(1.5)
    end
end

-- ==========================================
-- MÓDULOS DE TRABAJO
-- ==========================================

local Jobs = {
    -- 🍕 1. PANADERO (Baker)
    PizzaPlanetBaker = function()
        -- Teleport a la estación que atrapamos en el scan: pos=-31, 4, -56
        local targetCFrame = CFrame.new(-31, 4, -56)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = targetCFrame
        end
        
        StartJob("PizzaPlanetBaker")
        
        -- Loop de trabajo
        while _G.AutoFarmRunning and _G.CurrentJob == "PizzaPlanetBaker" do
            -- Según nuestro scan, manda {Order={...}, Workstation=...}
            -- Para un AutoFarm seguro, interceptaremos el evento del servidor para auto-completar el pedido en tiempo real,
            -- o simplemente re-enviamos el payload de la masa.
            local remote = getEvent()
            if remote then
                -- SIMULACIÓN DE PAYLOAD DE PANADERO (Ejemplo genérico, se ajustará con el pedido)
                -- remote:FireServer({Workstation=..., Order={1=true, 2=true}})
                print("[AutoFarm] Preparando Pizza...")
            end
            task.wait(2)
        end
    end,

    -- 🎣 2. PESCADOR (Fisherman)
    HutFisherman = function()
        -- Teleport a la zona de pesca detectada: pos=-353, -11, -106
        local targetCFrame = CFrame.new(-353, -11, -106)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = targetCFrame
        end
        
        StartJob("HutFisherman")
        
        while _G.AutoFarmRunning and _G.CurrentJob == "HutFisherman" do
            local remote = getEvent()
            if remote then
                print("[AutoFarm] Lanzando caña...")
                remote:FireServer({State=true, Pos=Vector3.new(-353, -11, -106)})
                task.wait(3.5) -- Esperar a que pique
                print("[AutoFarm] Pescando...")
                remote:InvokeServer({}) -- Minijuego / Acción
                task.wait(1)
                remote:FireServer({State=false})
            end
            task.wait(1)
        end
    end,

    -- 💇‍♀️ 3. PELUQUERO (Hairdresser)
    StylezHairdresser = function()
        local targetCFrame = CFrame.new(-67, 4, -324)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = targetCFrame
        end
        
        StartJob("StylezHairdresser")
        
        -- Estación detectada
        local workstation = workspace.Environment.Locations.City.StylezHairStudio.Interior.HairdresserWorkstations:FindFirstChild("Workstation")
        
        while _G.AutoFarmRunning and _G.CurrentJob == "StylezHairdresser" do
            local remote = getEvent()
            if remote and workstation then
                print("[AutoFarm] Cortando cabello...")
                remote:FireServer({Workstation = workstation})
            end
            task.wait(3)
        end
    end,
}

-- ==========================================
-- RADAR DE DUENDES (ELF ESP)
-- ==========================================
local function ScanForElves()
    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:find("Elf") or obj.Name:find("Duende")) then
            count = count + 1
            print("[RADAR] 🌟 DUENDE ENCONTRADO EN: ", tostring(obj:GetPivot().Position))
            
            -- Crear ESP
            if not obj:FindFirstChild("ElfESP") then
                local bg = Instance.new("BillboardGui")
                bg.Name = "ElfESP"
                bg.AlwaysOnTop = true
                bg.Size = UDim2.new(0, 200, 0, 50)
                bg.ExtentsOffset = Vector3.new(0, 3, 0)
                
                local txt = Instance.new("TextLabel")
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.BackgroundTransparency = 1
                txt.Text = "🚨 DUENDE AQUI 🚨"
                txt.TextColor3 = Color3.new(1, 0, 0)
                txt.TextStrokeTransparency = 0
                txt.TextScaled = true
                txt.Parent = bg
                bg.Parent = obj
            end
        end
    end
    print("[RADAR] Búsqueda completada. Duendes encontrados: " .. count)
    return count
end

-- ==========================================
-- INTERFAZ DE USUARIO SIMPLE (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BloxburgHacks"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
Title.Text = " Bloxburg AutoFarm + Elf"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

-- Funciones UI
local function createButton(yPos, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.Parent = MainFrame
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Botones
createButton(50, "🎣 Iniciar Pescador", function()
    if _G.AutoFarmRunning then _G.AutoFarmRunning = false task.wait(0.5) end
    _G.AutoFarmRunning = true
    _G.CurrentJob = "HutFisherman"
    task.spawn(Jobs.HutFisherman)
end)

createButton(95, "💇‍♀️ Iniciar Peluquero", function()
    if _G.AutoFarmRunning then _G.AutoFarmRunning = false task.wait(0.5) end
    _G.AutoFarmRunning = true
    _G.CurrentJob = "StylezHairdresser"
    task.spawn(Jobs.StylezHairdresser)
end)

createButton(140, "🍕 Iniciar Panadero (WIP)", function()
    if _G.AutoFarmRunning then _G.AutoFarmRunning = false task.wait(0.5) end
    _G.AutoFarmRunning = true
    _G.CurrentJob = "PizzaPlanetBaker"
    task.spawn(Jobs.PizzaPlanetBaker)
end)

createButton(185, "🛑 DETENER TODO", function()
    _G.AutoFarmRunning = false
    _G.CurrentJob = nil
    print("[AutoFarm] Detenido.")
end)

createButton(230, "🧝‍♂️ ESCANEAR DUENDES", function()
    local c = ScanForElves()
    if c == 0 then
        -- Si no encuentra duendes con nombres obvios, escanea Interactables
        for _, obj in ipairs(workspace.Environment:GetDescendants()) do
            if obj:IsA("StringValue") and obj.Name == "InteractionTag" and obj.Value == "ValidElfAction" then
                print("[RADAR] 🌟 DUENDE INTERACTUABLE EN: ", tostring(obj.Parent:GetPivot().Position))
            end
        end
    end
end)

-- Sistema Anti-AFK (Previene desconexiones de 20 minutos)
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

print("✅ Bloxburg AutoFarm UI Cargada.")
