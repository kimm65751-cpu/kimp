-- ==============================================================================
-- 🦖 CATCH A MONSTER: V9.0 — INYECCIÓN DE MÓDULOS DE COMBATE
-- Secuestramos la lógica oficial del juego (MgrFightClient) 
-- y disparamos sus propias funciones a la velocidad de la luz (x50/segundo).
-- ==============================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer

local UI_Name = "CAM_Injector"
if CoreGui:FindFirstChild(UI_Name) then CoreGui[UI_Name]:Destroy() end

local SG = Instance.new("ScreenGui")
SG.Name = UI_Name
SG.ResetOnSpawn = false
SG.Parent = pcall(function() return CoreGui.Name end) and CoreGui or LP:WaitForChild("PlayerGui")

local MF = Instance.new("Frame", SG)
MF.Size = UDim2.new(0, 480, 0, 415)
MF.Position = UDim2.new(0.45, 0, 0.2, 0)
MF.BackgroundColor3 = Color3.fromRGB(15, 10, 15)
MF.BorderSizePixel = 2
MF.BorderColor3 = Color3.fromRGB(200, 0, 255)
MF.Active = true
MF.Draggable = true

local Title = Instance.new("TextLabel", MF)
Title.Size = UDim2.new(1, 0, 0, 26)
Title.BackgroundColor3 = Color3.fromRGB(60, 0, 80)
Title.Text = " 💉 INYECTOR DE MÓDULOS (GATLING) V9.1"
Title.TextColor3 = Color3.fromRGB(240, 150, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left

local LogFrame = Instance.new("ScrollingFrame", MF)
LogFrame.Size = UDim2.new(1, -12, 0, 180)
LogFrame.Position = UDim2.new(0, 6, 0, 30)
LogFrame.BackgroundColor3 = Color3.fromRGB(3, 3, 3)
LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LogFrame.ScrollBarThickness = 4
LogFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", LogFrame).SortOrder = Enum.SortOrder.LayoutOrder

local lc = 0
local logBuffer = {}

local function Log(t, c)
    lc = lc + 1
    local timeStr = "["..os.date("%X").."] "
    table.insert(logBuffer, timeStr..t)
    
    local m = Instance.new("TextLabel", LogFrame)
    m.Size = UDim2.new(1, 0, 0, 15)
    m.BackgroundTransparency = 1
    m.Text = timeStr..t
    m.TextXAlignment = Enum.TextXAlignment.Left
    m.TextColor3 = c or Color3.fromRGB(170, 170, 170)
    m.Font = Enum.Font.Code; m.TextSize = 11
    m.TextWrapped = true; m.AutomaticSize = Enum.AutomaticSize.Y
    m.LayoutOrder = lc
    LogFrame.CanvasPosition = Vector2.new(0, 99999)
end

local function MkBtn(txt, py)
    local b = Instance.new("TextButton", MF)
    b.Size = UDim2.new(0.92, 0, 0, 30)
    b.Position = UDim2.new(0.04, 0, 0, py)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamSemibold; b.TextSize = 11
    b.Text = txt
    return b
end

local btnHook    = MkBtn("⚙️ SECUESTRAR MÓDULO (MgrFightClient)", 220)
local btnGatling = MkBtn("💥 ACTIVAR: GATLING DE ATAQUES (Aura Mode)", 255)
local btnAFK     = MkBtn("⚔️ AUTO-FARM BÁSICO (Click + AutoCatch)", 290)
local btnCatch   = MkBtn("🎯 FORZAR CAPTURA 100% (Templates)", 325)
local btnCopy    = MkBtn("📋 COPIAR LOG AL PORTAPAPELES", 360)

btnCopy.MouseButton1Click:Connect(function()
    pcall(function()
        if setclipboard then
            setclipboard(table.concat(logBuffer, "\n"))
            Log("📋 ¡Log copiado al portapapeles!", Color3.fromRGB(0, 255, 0))
        else
            Log("❌ Tu executor no soporta setclipboard", Color3.fromRGB(255, 0, 0))
        end
    end)
end)

-- ==========================================================
-- 1. SECUESTRO DE MÓDULO
-- ==========================================================
local MgrFightClient = nil

btnHook.MouseButton1Click:Connect(function()
    Log("Buscando ReplicatedStorage.ClientLogic.Fight.MgrFightClient...", Color3.fromRGB(200, 200, 50))
    pcall(function()
        local modPath = ReplicatedStorage:FindFirstChild("ClientLogic")
        if modPath then modPath = modPath:FindFirstChild("Fight") end
        if modPath then modPath = modPath:FindFirstChild("MgrFightClient") end
        
        if modPath and modPath:IsA("ModuleScript") then
            MgrFightClient = require(modPath)
            if type(MgrFightClient) == "table" and MgrFightClient.TryUseSkill then
                Log("✅ ¡Módulo SECUESTRADO exitosamente!", Color3.fromRGB(0, 255, 0))
                Log("  → Funciones disponibles: TryUseSkill, _doUseSkillWaitAck...", Color3.fromRGB(150, 255, 150))
                btnHook.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
                btnHook.Text = "⚙️ MÓDULO SECUESTRADO"
            else
                Log("⚠️ Módulo encontrado pero no tiene TryUseSkill", Color3.fromRGB(255, 100, 100))
            end
        else
            Log("❌ No se encontró MgrFightClient", Color3.fromRGB(255, 0, 0))
        end
    end)
end)

-- ==========================================================
-- 2. GATLING (AURA) DE ATAQUES REPETIDOS
-- ==========================================================
local gatlingActive = false

btnGatling.MouseButton1Click:Connect(function()
    if not MgrFightClient then
        Log("❌ Debes secuestrar el módulo primero.", Color3.fromRGB(255, 0, 0))
        return
    end
    gatlingActive = not gatlingActive
    btnGatling.BackgroundColor3 = gatlingActive and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(35, 35, 40)
    btnGatling.Text = gatlingActive and "💥 GATLING ACTIVADO (Spamming TryUseSkill)" or "💥 ACTIVAR: GATLING DE ATAQUES"
    Log(gatlingActive and "✅ Gatling de ataques activado!" or "🛑 Gatling desactivado.", Color3.fromRGB(200, 100, 255))
end)

task.spawn(function()
    while true do
        if gatlingActive and MgrFightClient and LP.Character and LP.Character.PrimaryPart then
            pcall(function()
                local myPos = LP.Character.PrimaryPart.Position
                local targetMob = nil
                local targetDist = 60
                
                -- Buscar mob más cercano
                local cm = Workspace:FindFirstChild("ClientMonsters")
                if cm then
                    for _, mob in pairs(cm:GetChildren()) do
                        if mob:IsA("Model") and mob.PrimaryPart then
                            local cd = mob:FindFirstChildWhichIsA("ClickDetector", true)
                            if cd then
                                local d = (mob.PrimaryPart.Position - myPos).Magnitude
                                if d < targetDist then
                                    targetDist = d
                                    targetMob = mob
                                end
                            end
                        end
                    end
                end
                
                -- Extraer nuestro Pet (si "ArriettyShushu_Pet_1" etc)
                -- Esto asume que TryUseSkill requiere el mob y quizas el owner o el pet
                -- Haremos fuzzing mandándolo directamente con nuestro Character y el mob
                if targetMob then
                    local successCount = 0
                    local failMsg = nil
                    
                    -- Disparar 10 veces usando combinaciones de TryUseSkill
                    for i = 1, 5 do
                        local s1, e1 = pcall(function()
                            MgrFightClient.TryUseSkill(MgrFightClient, targetMob) 
                        end)
                        if s1 then successCount = successCount + 1 else failMsg = e1 end
                        
                        local s2, e2 = pcall(function()
                            MgrFightClient:TryUseSkill(targetMob)
                        end)
                        if s2 then successCount = successCount + 1 else failMsg = failMsg or e2 end
                    end
                    
                    if successCount > 0 then
                        Log("💥 TryUseSkill enviado "..successCount.."x a "..tostring(targetMob.Name), Color3.fromRGB(150, 255, 100))
                    end
                    if failMsg then
                        Log("❌ Error: "..tostring(failMsg), Color3.fromRGB(255, 100, 100))
                    end
                end
            end)
        end
        task.wait(1) -- 1 vez por segundo, 10 ataques por ciclo = 10 por segundo (reducido para no crashear)
    end
end)

-- ==========================================================
-- 3. AUTO-FARM (Click + AutoCatch)
-- ==========================================================
local farmActive = false
btnAFK.MouseButton1Click:Connect(function()
    farmActive = not farmActive
    btnAFK.BackgroundColor3 = farmActive and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(35, 35, 40)
    btnAFK.Text = farmActive and "⚔️ FARMING ACTIVO" or "⚔️ AUTO-FARM BÁSICO"
end)

task.spawn(function()
    while true do
        if farmActive and LP.Character and LP.Character.PrimaryPart then
            pcall(function()
                local best, bestDist = nil, 60
                local cm = Workspace:FindFirstChild("ClientMonsters")
                if cm then
                    for _, mob in pairs(cm:GetChildren()) do
                        local cd = mob:FindFirstChildWhichIsA("ClickDetector", true)
                        if cd and mob.PrimaryPart then
                            local d = (mob.PrimaryPart.Position - LP.Character.PrimaryPart.Position).Magnitude
                            if d < bestDist then bestDist = d; best = cd end
                        end
                    end
                end
                if best then fireclickdetector(best) end
            end)
        end
        task.wait(2.5)
    end
end)

-- Auto E en PushRewardEvent
task.spawn(function()
    pcall(function()
        for _, desc in pairs(ReplicatedStorage:GetDescendants()) do
            if desc:IsA("RemoteEvent") then
                desc.OnClientEvent:Connect(function(...)
                    if farmActive and tostring({...}[1] or "") == "PushRewardEvent" then
                        task.delay(0.2, function()
                            pcall(function()
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                task.wait(0.1)
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            end)
                        end)
                    end
                end)
            end
        end
    end)
end)

-- ==========================================================
-- 4. CAPTURA 100% TEMPLATES (En caso de que lo necesites)
-- ==========================================================
btnCatch.MouseButton1Click:Connect(function()
    Log("Forzando CatchProbability = 1 en todo gc...", Color3.fromRGB(200, 200, 100))
    local fixed = 0
    pcall(function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" then
                if type(rawget(v, "CatchProbability")) == "number" then
                    rawset(v, "CatchProbability", 1)
                    fixed = fixed + 1
                end
            end
        end
    end)
    Log("✅ " .. fixed .. " tablas con CatchProbability = 1", Color3.fromRGB(0, 255, 0))
    btnCatch.BackgroundColor3 = Color3.fromRGB(150, 100, 0)
end)

Log("=== INSTRUCCIONES ===", Color3.fromRGB(255, 255, 255))
Log("1) Pulsa 'SECUESTRAR MÓDULO'. Debería decir EXITO.", Color3.fromRGB(200, 200, 200))
Log("2) Pulsa 'ACTIVAR GATLING'.", Color3.fromRGB(200, 200, 200))
Log("3) Acércate a un mob. El script bombardeará al juego con llamadas a TryUseSkill.", Color3.fromRGB(255, 200, 100))
Log("Si funciona, el mob se derretirá instantáneamente.", Color3.fromRGB(100, 255, 100))
