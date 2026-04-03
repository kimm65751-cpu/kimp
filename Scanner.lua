-- ==============================================================================
-- 🦖 CAM V9.5 — MgrFightClient GATLING (10x/seg) + LOGS + COPY
-- PlayerGui confirmado funcional
-- ==============================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-- Limpieza
for _, v in pairs(PlayerGui:GetChildren()) do
    if v.Name:find("CAM_") then pcall(function() v:Destroy() end) end
end

local SG = Instance.new("ScreenGui")
SG.Name = "CAM_V95"
SG.ResetOnSpawn = false
SG.Parent = PlayerGui

local MF = Instance.new("Frame", SG)
MF.Size = UDim2.new(0, 490, 0, 420)
MF.Position = UDim2.new(0.4, 0, 0.15, 0)
MF.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MF.BorderSizePixel = 2
MF.BorderColor3 = Color3.fromRGB(180, 0, 255)
MF.Active = true
MF.Draggable = true

local Title = Instance.new("TextLabel", MF)
Title.Size = UDim2.new(1, 0, 0, 26)
Title.BackgroundColor3 = Color3.fromRGB(50, 0, 70)
Title.Text = "  💉 GATLING V9.5 — MgrFightClient (10x/seg)"
Title.TextColor3 = Color3.fromRGB(220, 150, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left

-- LOG SCROLLFRAME
local LogFrame = Instance.new("ScrollingFrame", MF)
LogFrame.Size = UDim2.new(1, -10, 0, 200)
LogFrame.Position = UDim2.new(0, 5, 0, 28)
LogFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LogFrame.ScrollBarThickness = 4
LogFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", LogFrame).SortOrder = Enum.SortOrder.LayoutOrder

local lc = 0
local logBuffer = {}

local function Log(t, c)
    lc = lc + 1
    local line = "["..os.date("%X").."] "..t
    table.insert(logBuffer, line)
    local m = Instance.new("TextLabel", LogFrame)
    m.Size = UDim2.new(1, 0, 0, 14)
    m.BackgroundTransparency = 1
    m.Text = line
    m.TextXAlignment = Enum.TextXAlignment.Left
    m.TextColor3 = c or Color3.fromRGB(200, 200, 200)
    m.Font = Enum.Font.Code
    m.TextSize = 11
    m.TextWrapped = true
    m.AutomaticSize = Enum.AutomaticSize.Y
    m.LayoutOrder = lc
    LogFrame.CanvasPosition = Vector2.new(0, 99999)
end

local function MkBtn(txt, py, col)
    local b = Instance.new("TextButton", MF)
    b.Size = UDim2.new(0.92, 0, 0, 28)
    b.Position = UDim2.new(0.04, 0, 0, py)
    b.BackgroundColor3 = col or Color3.fromRGB(40, 40, 50)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 11
    b.Text = txt
    return b
end

local btnHook    = MkBtn("⚙️  PASO 1: Cargar MgrFightClient (TryUseSkill)", 235)
local btnGatling = MkBtn("💥  PASO 2: ACTIVAR GATLING (10x/seg)", 268)
local btnFarm    = MkBtn("⚔️  AUTO-FARM (Click + Auto-Catch)",  301)
local btnCatch   = MkBtn("🎯  CAPTURA 100% (CatchProbability=1)", 334)
local btnCopy    = MkBtn("📋  COPIAR LOG AL PORTAPAPELES",        367, Color3.fromRGB(0, 60, 30))

-- COPIAR LOG
btnCopy.MouseButton1Click:Connect(function()
    pcall(function()
        if setclipboard then
            setclipboard(table.concat(logBuffer, "\n"))
            Log("📋 Log copiado al portapapeles!", Color3.fromRGB(0, 255, 0))
        else
            Log("❌ setclipboard no disponible en tu executor", Color3.fromRGB(255, 100, 100))
        end
    end)
end)

-- ==============================================================================
-- 1. CARGAR MÓDULO
-- ==============================================================================
local MFC = nil  -- MgrFightClient

btnHook.MouseButton1Click:Connect(function()
    Log("Buscando ClientLogic.Fight.MgrFightClient...", Color3.fromRGB(255, 220, 80))

    local ok, err = pcall(function()
        local cl = ReplicatedStorage:FindFirstChild("ClientLogic")
        if not cl then error("No existe ClientLogic en ReplicatedStorage") end

        local fight = cl:FindFirstChild("Fight")
        if not fight then error("No existe Fight dentro de ClientLogic") end

        local mod = fight:FindFirstChild("MgrFightClient")
        if not mod then error("No existe MgrFightClient dentro de Fight") end

        if not mod:IsA("ModuleScript") then error("MgrFightClient no es un ModuleScript") end

        MFC = require(mod)
        btnHook.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
        btnHook.Text = "⚙️  MÓDULO CARGADO ✅"

        if type(MFC) ~= "table" then error("require() devolvió: "..type(MFC)) end

        -- Listar funciones disponibles
        local funcs = {}
        for k, v in pairs(MFC) do
            if type(v) == "function" then table.insert(funcs, k) end
        end
        Log("✅ MÓDULO CARGADO. Funciones: "..table.concat(funcs, ", "), Color3.fromRGB(0, 255, 0))

        if MFC.TryUseSkill then
            Log("  → TryUseSkill ✅", Color3.fromRGB(100, 255, 100))
        end
        if MFC._doUseSkillWaitAck then
            Log("  → _doUseSkillWaitAck ✅ (bypass cooldown)", Color3.fromRGB(100, 255, 200))
        end
        if MFC._pushUnitUsingSkill then
            Log("  → _pushUnitUsingSkill ✅", Color3.fromRGB(100, 255, 200))
        end
    end)

    if not ok then
        Log("❌ ERROR al cargar módulo: "..tostring(err), Color3.fromRGB(255, 0, 0))
    end
end)

-- ==============================================================================
-- 2. GATLING — 10 llamadas por segundo a TryUseSkill
-- ==============================================================================
local gatlingActive = false

btnGatling.MouseButton1Click:Connect(function()
    if not MFC then
        Log("❌ Primero carga el módulo (Paso 1)", Color3.fromRGB(255, 100, 100))
        return
    end
    gatlingActive = not gatlingActive
    btnGatling.BackgroundColor3 = gatlingActive and Color3.fromRGB(160, 0, 0) or Color3.fromRGB(40, 40, 50)
    btnGatling.Text = gatlingActive and "💥  GATLING ACTIVO — (Pulsa para PARAR)" or "💥  PASO 2: ACTIVAR GATLING (10x/seg)"
    Log(gatlingActive and "✅ Gatling ON (10x/seg)" or "🛑 Gatling OFF", Color3.fromRGB(220, 150, 255))
end)

task.spawn(function()
    while true do
        task.wait(1) -- Ciclo cada 1 segundo

        if not (gatlingActive and MFC and LP.Character and LP.Character.PrimaryPart) then
            continue
        end

        -- Buscar mob más cercano
        local myPos = LP.Character.PrimaryPart.Position
        local targetMob, targetCd, targetDist = nil, nil, 80

        pcall(function()
            local cm = Workspace:FindFirstChild("ClientMonsters")
            if not cm then return end
            for _, mob in pairs(cm:GetChildren()) do
                if mob:IsA("Model") and mob.PrimaryPart then
                    local d = (mob.PrimaryPart.Position - myPos).Magnitude
                    if d < targetDist then
                        targetDist = d
                        targetMob = mob
                        targetCd = mob:FindFirstChildWhichIsA("ClickDetector", true)
                    end
                end
            end
        end)

        if not targetMob then
            Log("⚠️ Sin mobs cerca (<80 studs)", Color3.fromRGB(255, 180, 0))
            continue
        end

        -- PASO 1: Click para iniciar combate
        if targetCd then
            pcall(function() fireclickdetector(targetCd) end)
        end

        -- PASO 2: Bypasear cooldown con _doUseSkillWaitAck
        -- TryUseSkill tiene cooldown interno. _doUseSkillWaitAck es la capa
        -- inferior que envía el ataque directo al servidor sin verificar cooldown.
        local oks, lastErr = 0, nil
        local method_used = "?"

        -- Intento A: _doUseSkillWaitAck directo (sin cooldown)
        if MFC._doUseSkillWaitAck then
            for i = 1, 10 do
                local s, e = pcall(function()
                    MFC:_doUseSkillWaitAck(targetMob)
                end)
                if s then oks = oks + 1; method_used = "_doUseSkillWaitAck"
                else lastErr = tostring(e) end
            end
        end

        -- Intento B: _pushUnitUsingSkill para resetear estado + TryUseSkill
        if oks == 0 and MFC._pushUnitUsingSkill then
            for i = 1, 10 do
                local s, e = pcall(function()
                    MFC:_pushUnitUsingSkill(targetMob)
                    MFC:TryUseSkill(targetMob)
                end)
                if s then oks = oks + 1; method_used = "push+TryUseSkill"
                else lastErr = tostring(e) end
            end
        end

        -- Intento C: TryUseRush (ataque rápido alternativo)
        if oks == 0 and MFC.TryUseRush then
            for i = 1, 10 do
                local s, e = pcall(function()
                    MFC:TryUseRush(targetMob)
                end)
                if s then oks = oks + 1; method_used = "TryUseRush"
                else lastErr = tostring(e) end
            end
        end

        -- Fallback D: TryUseSkill normal
        if oks == 0 then
            for i = 1, 10 do
                local s, e = pcall(function() MFC:TryUseSkill(targetMob) end)
                if s then oks = oks + 1; method_used = "TryUseSkill"
                else lastErr = tostring(e) end
            end
        end

        -- Reporte
        if oks > 0 then
            Log("💥 "..method_used.." "..oks.."/10 → "..targetMob.Name.." ["..math.floor(targetDist).."m]", Color3.fromRGB(100, 255, 100))
        else
            Log("❌ TODAS fallaron. Err: "..tostring(lastErr), Color3.fromRGB(255, 80, 80))
        end
    end
end)

-- ==============================================================================
-- 3. AUTO-FARM (Click + Auto-Catch)
-- ==============================================================================
local farmActive = false
btnFarm.MouseButton1Click:Connect(function()
    farmActive = not farmActive
    btnFarm.BackgroundColor3 = farmActive and Color3.fromRGB(0, 100, 160) or Color3.fromRGB(40, 40, 50)
    btnFarm.Text = farmActive and "⚔️  FARMING ACTIVO" or "⚔️  AUTO-FARM (Click + Auto-Catch)"
    Log(farmActive and "⚔️ Auto-Farm ON" or "🛑 Auto-Farm OFF", Color3.fromRGB(100, 200, 255))
end)

task.spawn(function()
    while true do
        task.wait(2.5)
        if not (farmActive and LP.Character and LP.Character.PrimaryPart) then continue end
        pcall(function()
            local best, bestDist = nil, 80
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
end)

-- Auto-Catch con E
task.spawn(function()
    pcall(function()
        for _, desc in pairs(ReplicatedStorage:GetDescendants()) do
            if desc:IsA("RemoteEvent") then
                desc.OnClientEvent:Connect(function(...)
                    if farmActive and tostring(({...})[1] or "") == "PushRewardEvent" then
                        task.delay(0.25, function()
                            pcall(function()
                                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                task.wait(0.1)
                                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            end)
                        end)
                    end
                end)
            end
        end
    end)
end)

-- ==============================================================================
-- 4. CAPTURA 100%
-- ==============================================================================
btnCatch.MouseButton1Click:Connect(function()
    local fixed = 0
    pcall(function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and type(rawget(v, "CatchProbability")) == "number" then
                rawset(v, "CatchProbability", 1)
                fixed = fixed + 1
            end
        end
    end)
    Log("🎯 CatchProbability=1 en "..fixed.." tablas", Color3.fromRGB(255, 220, 0))
    btnCatch.BackgroundColor3 = Color3.fromRGB(100, 70, 0)
end)

-- ==============================================================================
Log("✅ V9.5 cargada con PlayerGui", Color3.fromRGB(0, 255, 0))
Log("PASO 1 → Cargar módulo | PASO 2 → Gatling", Color3.fromRGB(255, 220, 100))
Log("El log mostrará OK o el ERROR exacto de cada llamada", Color3.fromRGB(200, 200, 200))
