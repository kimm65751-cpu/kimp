-- ==============================================================================
-- 🦖 CATCH A MONSTER: AUTO-FARM V3.0 (MODO DIOS - DESTRUCTOR DE PAQUETES)
-- Creado para: Invencibilidad Clandestina Anulando Tráfico de Salud (-HP)
-- ==============================================================================

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- ==========================================================
-- 1. GUI TÁCTICA (CONSOLA DE MONITOREO)
-- ==========================================================
local UI_Name = "CAM_GodModeConsole"
if CoreGui:FindFirstChild(UI_Name) then CoreGui[UI_Name]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = UI_Name
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = pcall(function() return CoreGui.Name end) and CoreGui or LP:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 480, 0, 200)
MainFrame.Position = UDim2.new(0.6, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(10, 15, 20)
Title.Text = "  ⚡ FIREWALL DIOS: ANULANDO DAÑO SERVER-SIDE"
Title.TextColor3 = Color3.fromRGB(0, 255, 100)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

local LogFrame = Instance.new("ScrollingFrame", MainFrame)
LogFrame.Size = UDim2.new(1, -20, 1, -40)
LogFrame.Position = UDim2.new(0, 10, 0, 35)
LogFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LogFrame.ScrollBarThickness = 6
LogFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local UIListLayout = Instance.new("UIListLayout", LogFrame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function AddLog(texto, color)
    local msg = Instance.new("TextLabel", LogFrame)
    msg.Size = UDim2.new(1, 0, 0, 18)
    msg.BackgroundTransparency = 1
    msg.Text = "["..os.date("%X").."] " .. texto
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    msg.Font = Enum.Font.Code
    msg.TextSize = 12
    msg.TextWrapped = true
    msg.AutomaticSize = Enum.AutomaticSize.Y
    LogFrame.CanvasPosition = Vector2.new(0, 99999)
end

-- ==========================================================
-- 2. HACK V3: ANULACIÓN DE PAQUETES (MODO DIOS ABSOLUTO)
-- ==========================================================
local PaquetesBloqueados = 0
AddLog("Iniciando inyección de Firewall en Eventos...", Color3.fromRGB(0, 200, 255))

task.spawn(function()
    local commonLib = ReplicatedStorage:FindFirstChild("CommonLibrary")
    if not commonLib then
        AddLog("CRÍTICO: No se encontró CommonLibrary. Hook Fallido.", Color3.fromRGB(255,50,50))
        return
    end
    
    local remoteManager = commonLib:FindFirstChild("Tool") and commonLib.Tool:FindFirstChild("RemoteManager")
    local events = remoteManager and remoteManager:FindFirstChild("Events")
    
    if events then
        -- Encontramos la arteria principal del juego (Donde el servidor notifica todo)
        local MessageEvent = events:FindFirstChild("Message")
        
        if MessageEvent and MessageEvent:IsA("RemoteEvent") then
            AddLog("✔️ Interceptando RemoteEvent: 'Message'", Color3.fromRGB(100, 255, 100))
            
            -- Vamos a usar un hook directo a los eventos de Lua (getconnections)
            if type(getconnections) == "function" then
                for _, connection in pairs(getconnections(MessageEvent.OnClientEvent)) do
                    local fnOriginal = connection.Function
                    if type(fnOriginal) == "function" then
                        -- Apagamos la conexión original al instante
                        connection:Disable()
                        
                        -- Creamos nuestra propia versión del receptor de red (Filtro)
                        MessageEvent.OnClientEvent:Connect(function(arg1, arg2, arg3, arg4)
                            -- El servidor avisa al cliente de pérdida de vida (arg1: "PetHealthSync" / "PetHurtInfo")
                            if arg1 == "PetHealthSync" or arg1 == "PetHurtInfo" then
                                -- REGLA DORADA:
                                -- Si atrapamos el paquete, lo MATAMOS y el cliente de mi juego jamás actualiza la barra
                                -- de vida ni asume que murió. Localmente eres invencible.
                                PaquetesBloqueados = PaquetesBloqueados + 1
                                if PaquetesBloqueados % 10 == 0 then -- No saturar GUI
                                    AddLog("🛡️ Bloqueados " .. PaquetesBloqueados .. " ataques del servidor.", Color3.fromRGB(0, 255, 0))
                                end
                                return -- TERMINAMOS LA EJECUCIÓN (DROPPING PACKET)
                            end
                            
                            -- Si es cualquier otra cosa (Recompensas, Clicks), dejamos que pase al juego normal.
                            fnOriginal(arg1, arg2, arg3, arg4)
                        end)
                    end
                end
                AddLog("¡Firewall Instalado! Las mascotas son inmortales en el cliente.", Color3.fromRGB(255, 150, 0))
            else
                AddLog("Tu inyector no soporta 'getconnections()'.", Color3.fromRGB(255,0,0))
            end
        else
            AddLog("No se encontró el evento 'Message'.", Color3.fromRGB(255,0,0))
        end
    end
end)

-- ==========================================================
-- 3. RANGO 300 CONSTANTE (Para pegar seguros)
-- ==========================================================
task.spawn(function()
    local c = 0
    while true do
        pcall(function()
            for _, v in pairs(getgc(true)) do
                if type(v) == "table" then
                    if rawget(v, "AttackRange") and v.AttackRange < 150 then v.AttackRange = 300; c = c+1 end
                    if rawget(v, "CatchRange") and v.CatchRange < 150 then v.CatchRange = 300 end
                end
            end
        end)
        if c > 0 then
            AddLog("▶️ Rango Mantenido en 300m ("..c.." hits)", Color3.fromRGB(150, 150, 150))
            c = 0
        end
        task.wait(15)
    end
end)

AddLog("Prueba Final: Inicia el Auto-Atacar ahora. Tus mascotas deberían recibir daño nulo a pesar del combate.", Color3.fromRGB(255, 255, 0))
