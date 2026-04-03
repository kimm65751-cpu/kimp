-- ==============================================================================
-- 🦖 CATCH A MONSTER: VECTOR-C V5.0 (SILENCIADOR DE MONSTRUOS)
-- El cliente calcula TODO el combate (IsServerLogic=false).
-- Si bloqueamos los FightSkillStart de mobs, NUNCA atacan.
-- ==============================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VIM = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer

-- ==========================================================
-- 1. GUI MINIMALISTA
-- ==========================================================
local UI_Name = "CAM_VectorC"
if CoreGui:FindFirstChild(UI_Name) then CoreGui[UI_Name]:Destroy() end

local SG = Instance.new("ScreenGui")
SG.Name = UI_Name
SG.ResetOnSpawn = false
SG.Parent = pcall(function() return CoreGui.Name end) and CoreGui or LP:WaitForChild("PlayerGui")

local MF = Instance.new("Frame", SG)
MF.Size = UDim2.new(0, 420, 0, 260)
MF.Position = UDim2.new(0.55, 0, 0.35, 0)
MF.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MF.BorderSizePixel = 2
MF.BorderColor3 = Color3.fromRGB(255, 80, 80)
MF.Active = true
MF.Draggable = true

local Title = Instance.new("TextLabel", MF)
Title.Size = UDim2.new(1, 0, 0, 28)
Title.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
Title.Text = " 🔇 VECTOR C: SILENCIADOR DE ATAQUES MOB"
Title.TextColor3 = Color3.fromRGB(255, 200, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Log panel
local LogFrame = Instance.new("ScrollingFrame", MF)
LogFrame.Size = UDim2.new(1, -16, 0, 120)
LogFrame.Position = UDim2.new(0, 8, 0, 32)
LogFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LogFrame.ScrollBarThickness = 4
LogFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", LogFrame).SortOrder = Enum.SortOrder.LayoutOrder

local logCount = 0
local function Log(txt, col)
    logCount = logCount + 1
    local m = Instance.new("TextLabel", LogFrame)
    m.Size = UDim2.new(1, 0, 0, 16)
    m.BackgroundTransparency = 1
    m.Text = "["..os.date("%X").."] "..txt
    m.TextXAlignment = Enum.TextXAlignment.Left
    m.TextColor3 = col or Color3.fromRGB(180, 180, 180)
    m.Font = Enum.Font.Code
    m.TextSize = 11
    m.TextWrapped = true
    m.AutomaticSize = Enum.AutomaticSize.Y
    m.LayoutOrder = logCount
    LogFrame.CanvasPosition = Vector2.new(0, 99999)
end

-- Botones
local function MakeBtn(text, posY)
    local b = Instance.new("TextButton", MF)
    b.Size = UDim2.new(0.92, 0, 0, 32)
    b.Position = UDim2.new(0.04, 0, 0, posY)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 13
    b.Text = text
    return b
end

local btnSilence = MakeBtn("🔇 ACTIVAR: Silenciar Ataques Mob", 158)
local btnAutoFarm = MakeBtn("⚔️ ACTIVAR: Auto-Farm (Click+Catch)", 196)

local Toggles = {Silence = false, AutoFarm = false}
local silencedCount = 0

btnSilence.MouseButton1Click:Connect(function()
    Toggles.Silence = not Toggles.Silence
    btnSilence.BackgroundColor3 = Toggles.Silence and Color3.fromRGB(180, 40, 40) or Color3.fromRGB(40, 40, 45)
    btnSilence.Text = Toggles.Silence and "🔇 ACTIVO: Mobs Silenciados" or "🔇 ACTIVAR: Silenciar Ataques Mob"
    Log(Toggles.Silence and "Silenciador ACTIVADO" or "Silenciador DESACTIVADO", Color3.fromRGB(255, 100, 100))
end)

btnAutoFarm.MouseButton1Click:Connect(function()
    Toggles.AutoFarm = not Toggles.AutoFarm
    btnAutoFarm.BackgroundColor3 = Toggles.AutoFarm and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(40, 40, 45)
    btnAutoFarm.Text = Toggles.AutoFarm and "⚔️ ACTIVO: Auto-Farm Encadenado" or "⚔️ ACTIVAR: Auto-Farm (Click+Catch)"
    Log(Toggles.AutoFarm and "Auto-Farm ACTIVADO" or "Auto-Farm DESACTIVADO", Color3.fromRGB(100, 255, 100))
end)

-- ==========================================================
-- 2. VECTOR C: INTERCEPTOR DE COMBATE
-- ==========================================================
-- El juego usa un sistema de mensajes centralizado via RemoteEvent.
-- Todos los eventos de combate pasan por ahí con arg1 = nombre del evento.
-- Los ataques de mobs tienen UnitKey que empieza con "M".

Log("Buscando RemoteEvents de combate...", Color3.fromRGB(0, 200, 255))

task.spawn(function()
    -- Buscar TODOS los RemoteEvents en CommonLibrary
    local commonLib = ReplicatedStorage:FindFirstChild("CommonLibrary")
    if not commonLib then
        Log("ERROR: CommonLibrary no encontrada", Color3.fromRGB(255, 0, 0))
        return
    end

    -- Buscar el evento principal de mensajes
    local targetEvent = nil
    
    -- Método 1: Buscar en Tool/RemoteManager/Events
    pcall(function()
        local tool = commonLib:FindFirstChild("Tool")
        if tool then
            local rm = tool:FindFirstChild("RemoteManager")
            if rm then
                local evts = rm:FindFirstChild("Events")
                if evts then
                    for _, child in pairs(evts:GetChildren()) do
                        if child:IsA("RemoteEvent") then
                            Log("Encontrado RE: " .. child.Name, Color3.fromRGB(150, 150, 150))
                            -- El evento principal suele llamarse "Message" o similar
                            if child.Name == "Message" or child.Name == "Msg" or child.Name == "Event" then
                                targetEvent = child
                            end
                        end
                    end
                end
            end
        end
    end)

    -- Método 2: Si no encontramos por nombre, buscamos todos los RE que tengan conexiones de combate
    if not targetEvent then
        Log("Buscando RE por conexiones activas...", Color3.fromRGB(200, 200, 0))
        pcall(function()
            if type(getconnections) ~= "function" then
                Log("ERROR: getconnections() no disponible en tu executor", Color3.fromRGB(255, 0, 0))
                return
            end
            
            -- Escanear TODOS los RemoteEvents del juego
            for _, desc in pairs(ReplicatedStorage:GetDescendants()) do
                if desc:IsA("RemoteEvent") then
                    local conns = getconnections(desc.OnClientEvent)
                    if #conns > 0 then
                        Log("RE con conexiones: " .. desc:GetFullName() .. " (" .. #conns .. " conns)", Color3.fromRGB(200, 200, 100))
                        -- Si tiene muchas conexiones, probablemente es el principal
                        if #conns >= 1 and not targetEvent then
                            targetEvent = desc
                        end
                    end
                end
            end
        end)
    end

    if not targetEvent then
        Log("No se encontró RemoteEvent principal. Intentando hookmetamethod...", Color3.fromRGB(255, 150, 0))
        
        -- Método 3: hookmetamethod - intercepta TODAS las llamadas de red
        if type(hookmetamethod) == "function" then
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                
                if method == "FireServer" or method == "InvokeServer" then
                    -- No tocamos lo que el cliente envía al servidor
                elseif method == "Connect" or method == "connect" then
                    -- No interferimos con conexiones
                end
                
                return oldNamecall(self, ...)
            end)
            Log("hookmetamethod instalado (pasivo)", Color3.fromRGB(150, 255, 150))
        end
        
        -- Método 4: Hook directo al OnClientEvent de TODOS los RE
        pcall(function()
            if type(getconnections) ~= "function" then return end
            
            for _, desc in pairs(ReplicatedStorage:GetDescendants()) do
                if desc:IsA("RemoteEvent") then
                    local conns = getconnections(desc.OnClientEvent)
                    for _, conn in pairs(conns) do
                        local origFn = conn.Function
                        if origFn then
                            conn:Disable()
                            
                            desc.OnClientEvent:Connect(function(...)
                                local args = {...}
                                local firstName = tostring(args[1] or "")
                                
                                -- VECTOR C: Silenciar ataques de monstruos
                                if Toggles.Silence then
                                    -- Bloquear FightSkillStart de mobs (UnitKey empieza con M)
                                    if firstName == "FightSkillStart" then
                                        local unitKey = tostring(args[4] or "")
                                        if unitKey:sub(1, 1) == "M" then
                                            silencedCount = silencedCount + 1
                                            if silencedCount % 5 == 1 then
                                                Log("🔇 Ataque de " .. unitKey .. " BLOQUEADO (total: " .. silencedCount .. ")", Color3.fromRGB(255, 80, 80))
                                            end
                                            return -- DROPPING: el mob no ataca
                                        end
                                    end
                                    
                                    -- Bloquear PetHurtInfo (daño recibido por mascotas)
                                    if firstName == "PetHurtInfo" then
                                        silencedCount = silencedCount + 1
                                        return -- DROPPING: tus mascotas no reciben daño
                                    end
                                    
                                    -- Bloquear ObjectPointSync de mobs (proyectiles enemigos)
                                    if firstName == "ObjectPointSyncAdd" then
                                        local data = args[3]
                                        if type(data) == "table" then
                                            local caster = tostring(data.CasterUnitKey or "")
                                            if caster:sub(1, 1) == "M" then
                                                return -- DROPPING: proyectil del mob no se renderiza
                                            end
                                        end
                                    end
                                    
                                    -- Bloquear FightLogicPlayerCreate de mobs
                                    if firstName == "FightLogicPlayerCreate" then
                                        local data = args[3]
                                        if type(data) == "table" then
                                            local src = tostring(data.SourceUnitKey or "")
                                            if src:sub(1, 1) == "M" then
                                                return -- DROPPING: lógica de ataque mob no se crea
                                            end
                                        end
                                    end
                                end
                                
                                -- AUTO-CATCH: Cuando llega PushRewardEvent, presionar E automáticamente
                                if Toggles.AutoFarm and firstName == "PushRewardEvent" then
                                    Log("💀 Mob muerto! Auto-capturando...", Color3.fromRGB(255, 255, 0))
                                    task.delay(0.3, function()
                                        pcall(function()
                                            -- Simular presionar E
                                            local vim = game:GetService("VirtualInputManager")
                                            vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                            task.wait(0.1)
                                            vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                        end)
                                    end)
                                end
                                
                                -- Todo lo demás pasa normal
                                origFn(...)
                            end)
                        end
                    end
                end
            end
            Log("✅ Hooks instalados en TODOS los RemoteEvents", Color3.fromRGB(0, 255, 0))
        end)
        
        return
    end

    -- Si encontramos el targetEvent directamente
    if targetEvent and type(getconnections) == "function" then
        local conns = getconnections(targetEvent.OnClientEvent)
        Log("Hookeando " .. targetEvent.Name .. " con " .. #conns .. " conexiones...", Color3.fromRGB(0, 255, 200))
        
        for _, conn in pairs(conns) do
            local origFn = conn.Function
            if origFn then
                conn:Disable()
                
                targetEvent.OnClientEvent:Connect(function(...)
                    local args = {...}
                    local firstName = tostring(args[1] or "")
                    
                    if Toggles.Silence then
                        if firstName == "FightSkillStart" then
                            local unitKey = tostring(args[4] or "")
                            if unitKey:sub(1, 1) == "M" then
                                silencedCount = silencedCount + 1
                                if silencedCount % 5 == 1 then
                                    Log("🔇 Bloqueado ataque " .. unitKey .. " (#" .. silencedCount .. ")", Color3.fromRGB(255, 80, 80))
                                end
                                return
                            end
                        end
                        if firstName == "PetHurtInfo" then
                            silencedCount = silencedCount + 1
                            return
                        end
                        if firstName == "ObjectPointSyncAdd" then
                            local d = args[3]
                            if type(d) == "table" and tostring(d.CasterUnitKey or ""):sub(1,1) == "M" then
                                return
                            end
                        end
                        if firstName == "FightLogicPlayerCreate" then
                            local d = args[3]
                            if type(d) == "table" and tostring(d.SourceUnitKey or ""):sub(1,1) == "M" then
                                return
                            end
                        end
                    end
                    
                    if Toggles.AutoFarm and firstName == "PushRewardEvent" then
                        Log("💀 Mob muerto! Auto-catch...", Color3.fromRGB(255, 255, 0))
                        task.delay(0.3, function()
                            pcall(function()
                                local vim = game:GetService("VirtualInputManager")
                                vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                task.wait(0.1)
                                vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            end)
                        end)
                    end
                    
                    origFn(...)
                end)
            end
        end
        Log("✅ Vector C instalado en: " .. targetEvent:GetFullName(), Color3.fromRGB(0, 255, 0))
    end
end)

-- ==========================================================
-- 3. AUTO-FARM: ClickDetector del mob más cercano
-- ==========================================================
task.spawn(function()
    while true do
        if Toggles.AutoFarm then
            pcall(function()
                if not LP.Character or not LP.Character.PrimaryPart then return end
                local myPos = LP.Character.PrimaryPart.Position
                local closest = nil
                local closestDist = 80 -- rango máximo de búsqueda
                
                -- Buscar en ClientMonsters (los que tienen ClickDetector)
                local cm = Workspace:FindFirstChild("ClientMonsters")
                if cm then
                    for _, mob in pairs(cm:GetChildren()) do
                        if mob:IsA("Model") then
                            local cd = mob:FindFirstChildWhichIsA("ClickDetector", true)
                            if cd then
                                local part = mob.PrimaryPart or mob:FindFirstChildWhichIsA("BasePart")
                                if part then
                                    local dist = (part.Position - myPos).Magnitude
                                    if dist < closestDist then
                                        closestDist = dist
                                        closest = cd
                                    end
                                end
                            end
                        end
                    end
                end
                
                if closest then
                    -- Disparar el click para iniciar combate
                    fireclickdetector(closest)
                    Log("🖱️ Click en mob a " .. math.floor(closestDist) .. "m", Color3.fromRGB(100, 200, 255))
                end
            end)
        end
        task.wait(3) -- cada 3 segundos buscar nuevo mob
    end
end)

Log("Script listo. Activa los botones para empezar.", Color3.fromRGB(255, 255, 255))
