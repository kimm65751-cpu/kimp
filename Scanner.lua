-- ==============================================================================
-- 🛡️ REVERSE ENG: MASTER INJECTOR V5.0
-- Inyección de fuerza bruta dirigida al Servidor de Compras de Tycoon y Red.
-- ==============================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

pcall(function()
    for _, obj in pairs(CoreGui:GetChildren()) do
        if obj.Name:match("Injector") or obj.Name:match("Analyzer") or obj.Name:match("Trace") or obj.Name:match("Defender") then 
            obj:Destroy() 
        end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MasterInjectorV5"
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 280)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(200, 0, 255)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(200, 100, 255)
Title.Text = "🛡️ V5.0 MASTER BYPASS (FUERZA BRUTA DE RED)"
Title.Font = Enum.Font.Code
Title.TextSize = 15
Title.Parent = MainFrame

local LogHolder = Instance.new("ScrollingFrame")
LogHolder.Size = UDim2.new(0.9, 0, 0, 180)
LogHolder.Position = UDim2.new(0.05, 0, 0, 40)
LogHolder.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
LogHolder.BorderSizePixel = 1
LogHolder.BorderColor3 = Color3.fromRGB(200, 0, 255)
LogHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
LogHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogHolder.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout", LogHolder)

local logCount = 0
local function AddLog(msg, color)
    logCount = logCount + 1
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    lbl.Text = " " .. msg
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 12
    lbl.LayoutOrder = logCount
    lbl.Parent = LogHolder
    LogHolder.CanvasPosition = Vector2.new(0, 99999)
end

local BtnInject = Instance.new("TextButton")
BtnInject.Size = UDim2.new(0.9, 0, 0, 35)
BtnInject.Position = UDim2.new(0.05, 0, 0, 230)
BtnInject.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
BtnInject.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnInject.Text = "🚀 FORZAR BLOQUEO / SALTO AL SERVIDOR"
BtnInject.Font = Enum.Font.Code
BtnInject.TextSize = 14
BtnInject.Parent = MainFrame

AddLog("✅ Archivos base analizados. Ya descubrimos por qué pasa esto.", Color3.fromRGB(100, 255, 100))

BtnInject.MouseButton1Click:Connect(function()
    AddLog("\n🚀 CORTOCIRCUITANDO CÓDIGO LOCAL, COMUNICANDO AL SERVER...", Color3.fromRGB(255, 50, 50))
    
    local TargetButton = nil
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "Main" and obj.Parent and obj.Parent.Name == "PlotBlock" then
            TargetButton = obj
            break
        end
    end
    
    local netFolder = ReplicatedStorage:FindFirstChild("Packages")
    if not netFolder then
        AddLog("❌ No se encontró la base de red Packages.Net", Color3.fromRGB(255, 50, 50))
        return
    end

    local Remotes = {}
    for _, desc in pairs(netFolder:GetDescendants()) do
        if desc:IsA("RemoteEvent") then
            table.insert(Remotes, desc)
        end
    end

    AddLog("🔄 Inyectando payloads en PlotService, ShopService y Ocultos...", Color3.fromRGB(200, 150, 255))
    
    local shots = 0
    for _, remote in pairs(Remotes) do
        local name = remote.Name
        -- Candidatos más probables del reporte de scanner
        if name:match("Plot") or name:match("Purchase") or name == "ToggleFriends" or name == "Place" or name == "Open" or name:match("Set") then
            pcall(function()
                -- Enviar sin argumentos (Activadores vacios)
                remote:FireServer()
                -- Argumento String (Si es una base de compra)
                remote:FireServer("PlotBlock")
                -- Argumento Objeto (Si el servidor espera el botón)
                if TargetButton then
                    remote:FireServer(TargetButton)
                    remote:FireServer(TargetButton.Parent)
                end
                -- Argumento Lógico
                remote:FireServer(true)
                remote:FireServer("Lock")
                
                shots = shots + 1
            end)
        end
    end
    
    AddLog("✅ " .. shots .. " Puertos RemoteEvent ejecutados con éxito.", Color3.fromRGB(100, 255, 100))
    AddLog("💡 Revisa las paredes/barreras. Si siguen abiertas, el servidor bloquea la red estrictamente por dinero/stats.", Color3.fromRGB(255, 200, 100))
end)
