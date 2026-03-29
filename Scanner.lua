-- ==============================================================================
-- 🔬 DIAGNÓSTICO PROFUNDO DE QUEST V1.0
-- ==============================================================================
-- Escucha PASIVAMENTE todos los remotes ANTES de llamarlos.
-- Captura TODA respuesta del servidor para ver qué pasa realmente.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- GUI SIMPLE
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "DiagQuestUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DiagQuestUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 420)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 50, 255)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -150, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 10, 30)
Title.Text = " 🔬 DIAGNÓSTICO QUEST - OBSERVADOR"
Title.TextColor3 = Color3.fromRGB(255, 50, 255)
Title.TextSize = 13
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0, 80, 0, 30)
SaveBtn.Position = UDim2.new(1, -150, 0, 0)
SaveBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
SaveBtn.Text = "💾 GUARDAR"
SaveBtn.TextColor3 = Color3.new(1,1,1)
SaveBtn.Font = Enum.Font.Code
SaveBtn.TextSize = 10
SaveBtn.Parent = MainFrame

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -65, 0, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(180, 150, 0)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.Font = Enum.Font.Code
MinBtn.TextSize = 16
MinBtn.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -33, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.Code
CloseBtn.TextSize = 16
CloseBtn.Parent = MainFrame

local OutputScroll = Instance.new("ScrollingFrame")
OutputScroll.Size = UDim2.new(1, -10, 1, -70)
OutputScroll.Position = UDim2.new(0, 5, 0, 65)
OutputScroll.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
OutputScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
OutputScroll.ScrollBarThickness = 6
OutputScroll.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = OutputScroll
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 1)

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    OutputScroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 15)
end)

local isMin = false
MinBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    MainFrame.Size = isMin and UDim2.new(0, 550, 0, 30) or UDim2.new(0, 550, 0, 420)
    OutputScroll.Visible = not isMin
end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local FullLog = "=== DIAGNÓSTICO PROFUNDO DE QUEST ===\n\n"
local sc = 0

SaveBtn.MouseButton1Click:Connect(function()
    writefile("diag_quest.txt", FullLog)
    SaveBtn.Text = "✅"
    task.delay(1.5, function() SaveBtn.Text = "💾 GUARDAR" end)
end)

local function L(text, color)
    FullLog = FullLog .. text .. "\n"
    sc = sc + 1
    if sc >= 8 then
        pcall(function() writefile("diag_quest.txt", FullLog) end)
        sc = 0
    end
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, -10, 0, 18)
    msg.BackgroundTransparency = 1
    msg.Text = text
    msg.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    msg.TextSize = 10
    msg.Font = Enum.Font.Code
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.TextWrapped = true
    msg.Parent = OutputScroll
    msg.Size = UDim2.new(1, -10, 0, msg.TextBounds.Y + 4)
    OutputScroll.CanvasPosition = Vector2.new(0, 99999)
end

local function Dump(v)
    if typeof(v) == "Instance" then return "[Inst] " .. v:GetFullName() end
    if type(v) == "table" then
        local ok, r = pcall(function() return HttpService:JSONEncode(v) end)
        if ok then return r end
        local s = "{"
        for k, val in pairs(v) do s = s .. tostring(k) .. "=" .. tostring(val) .. ", " end
        return s .. "}"
    end
    if v == nil then return "NIL" end
    return "(" .. typeof(v) .. ") " .. tostring(v)
end

-- ==========================================
-- OBTENER REMOTES
-- ==========================================
local Knit = ReplicatedStorage:FindFirstChild("Shared")
    and ReplicatedStorage.Shared:FindFirstChild("Packages")
    and ReplicatedStorage.Shared.Packages:FindFirstChild("Knit")
    and ReplicatedStorage.Shared.Packages.Knit:FindFirstChild("Services")

local ForceDialogue = Knit and Knit:FindFirstChild("ProximityService") and Knit.ProximityService:FindFirstChild("RF") and Knit.ProximityService.RF:FindFirstChild("ForceDialogue")
local ProxDialogue = Knit and Knit:FindFirstChild("ProximityService") and Knit.ProximityService:FindFirstChild("RF") and Knit.ProximityService.RF:FindFirstChild("Dialogue")
local RunCommand = Knit and Knit:FindFirstChild("DialogueService") and Knit.DialogueService:FindFirstChild("RF") and Knit.DialogueService.RF:FindFirstChild("RunCommand")
local DialogueEvent = Knit and Knit:FindFirstChild("DialogueService") and Knit.DialogueService:FindFirstChild("RE") and Knit.DialogueService.RE:FindFirstChild("DialogueEvent")
local TrackQuest = Knit and Knit:FindFirstChild("QuestService") and Knit.QuestService:FindFirstChild("RF") and Knit.QuestService.RF:FindFirstChild("ClientTrackQuest")
local ProgressQuest = Knit and Knit:FindFirstChild("QuestService") and Knit.QuestService:FindFirstChild("RF") and Knit.QuestService.RF:FindFirstChild("ProgressUIQuest")
local DialogueRemote = ReplicatedStorage:FindFirstChild("DialogueEvents") and ReplicatedStorage.DialogueEvents:FindFirstChild("DialogueRemote")
local DialogueBindable = ReplicatedStorage:FindFirstChild("DialogueEvents") and ReplicatedStorage.DialogueEvents:FindFirstChild("DialogueBindable")

-- ==========================================
-- PASO 0: ESCUCHAR TODO PASIVAMENTE
-- ==========================================
L("============================================================", Color3.fromRGB(255, 50, 255))
L("  👁️ OREJAS ABIERTAS: Escuchando TODOS los remotes", Color3.fromRGB(255, 50, 255))
L("============================================================\n", Color3.fromRGB(255, 50, 255))

local eventLog = {}

if DialogueRemote then
    DialogueRemote.OnClientEvent:Connect(function(...)
        local args = {...}
        L("📡 [DialogueRemote] SERVER ENVIÓ:", Color3.fromRGB(255, 100, 100))
        for i, v in ipairs(args) do L("   arg[" .. i .. "] = " .. Dump(v), Color3.fromRGB(255, 200, 150)) end
        table.insert(eventLog, {remote = "DialogueRemote", args = args, time = tick()})
    end)
    L("  ✅ Escuchando DialogueRemote", Color3.fromRGB(100, 255, 100))
end

if DialogueEvent then
    DialogueEvent.OnClientEvent:Connect(function(...)
        local args = {...}
        L("📡 [DialogueEvent] SERVER ENVIÓ:", Color3.fromRGB(100, 200, 255))
        for i, v in ipairs(args) do L("   arg[" .. i .. "] = " .. Dump(v), Color3.fromRGB(200, 220, 255)) end
        table.insert(eventLog, {remote = "DialogueEvent", args = args, time = tick()})
    end)
    L("  ✅ Escuchando DialogueEvent", Color3.fromRGB(100, 255, 100))
end

if DialogueBindable then
    DialogueBindable.Event:Connect(function(...)
        local args = {...}
        L("⚡ [DialogueBindable] INTERNO:", Color3.fromRGB(255, 255, 100))
        for i, v in ipairs(args) do L("   arg[" .. i .. "] = " .. Dump(v), Color3.fromRGB(255, 255, 200)) end
        table.insert(eventLog, {remote = "DialogueBindable", args = args, time = tick()})
    end)
    L("  ✅ Escuchando DialogueBindable", Color3.fromRGB(100, 255, 100))
end

-- Escuchar TODOS los RemoteEvents de Knit que tengan que ver con quest/dialogue
for _, child in pairs(ReplicatedStorage:GetDescendants()) do
    if child:IsA("RemoteEvent") and child ~= DialogueRemote and child ~= DialogueEvent then
        local n = string.lower(child.Name .. child:GetFullName())
        if string.find(n, "quest") or string.find(n, "progress") then
            child.OnClientEvent:Connect(function(...)
                local args = {...}
                L("📡 [" .. child.Name .. "] SERVER:", Color3.fromRGB(200, 150, 255))
                for i, v in ipairs(args) do L("   arg[" .. i .. "] = " .. Dump(v), Color3.fromRGB(200, 200, 255)) end
            end)
            L("  ✅ Escuchando " .. child.Name, Color3.fromRGB(100, 255, 100))
        end
    end
end

-- ==========================================
-- PASO 1: PROBAR ProgressUIQuest para obtener quests activas
-- ==========================================
L("\n============================================================", Color3.fromRGB(100, 255, 255))
L("  📋 PASO 1: Pidiendo info de quests activas", Color3.fromRGB(100, 255, 255))
L("============================================================\n", Color3.fromRGB(100, 255, 255))

if ProgressQuest then
    L("[*] Llamando ProgressUIQuest:InvokeServer()...", Color3.fromRGB(255, 200, 50))
    local ok, res = pcall(function() return ProgressQuest:InvokeServer() end)
    L("  Return: " .. (ok and "✅ " .. Dump(res) or "❌ " .. tostring(res)), ok and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 50, 50))

    L("\n[*] Llamando ProgressUIQuest:InvokeServer(true)...", Color3.fromRGB(255, 200, 50))
    local ok2, res2 = pcall(function() return ProgressQuest:InvokeServer(true) end)
    L("  Return: " .. (ok2 and "✅ " .. Dump(res2) or "❌ " .. tostring(res2)), ok2 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 50, 50))

    L("\n[*] Llamando ProgressUIQuest:InvokeServer(\"all\")...", Color3.fromRGB(255, 200, 50))
    local ok3, res3 = pcall(function() return ProgressQuest:InvokeServer("all") end)
    L("  Return: " .. (ok3 and "✅ " .. Dump(res3) or "❌ " .. tostring(res3)), ok3 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 50, 50))
end

if TrackQuest then
    L("\n[*] Llamando ClientTrackQuest:InvokeServer()...", Color3.fromRGB(255, 200, 50))
    local ok, res = pcall(function() return TrackQuest:InvokeServer() end)
    L("  Return: " .. (ok and "✅ " .. Dump(res) or "❌ " .. tostring(res)), ok and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 50, 50))
end

-- ==========================================
-- PASO 2: BUSCAR REPLICA DATA (quest state)
-- ==========================================
L("\n============================================================", Color3.fromRGB(255, 200, 100))
L("  🔑 PASO 2: Buscando datos de Quest en Player/ReplicaData", Color3.fromRGB(255, 200, 100))
L("============================================================\n", Color3.fromRGB(255, 200, 100))

-- Buscar en leaderstats
local ls = LocalPlayer:FindFirstChild("leaderstats")
if ls then
    L("[leaderstats encontrado]", Color3.fromRGB(100, 255, 100))
    for _, child in pairs(ls:GetChildren()) do
        L("  " .. child.Name .. " = " .. tostring(child.Value), Color3.fromRGB(200, 200, 200))
    end
end

-- Buscar cualquier carpeta que tenga "quest" o "data"
for _, child in pairs(LocalPlayer:GetChildren()) do
    local nl = string.lower(child.Name)
    if string.find(nl, "quest") or string.find(nl, "data") or string.find(nl, "save") or string.find(nl, "stat") or string.find(nl, "progress") then
        L("[" .. child.ClassName .. "] " .. child.Name, Color3.fromRGB(255, 200, 100))
        if child:IsA("ValueBase") then
            L("  Value = " .. tostring(child.Value), Color3.fromRGB(200, 200, 200))
        end
        for _, sub in pairs(child:GetChildren()) do
            if sub:IsA("ValueBase") then
                L("  " .. sub.Name .. " = " .. tostring(sub.Value), Color3.fromRGB(200, 200, 200))
            else
                L("  [" .. sub.ClassName .. "] " .. sub.Name, Color3.fromRGB(180, 180, 180))
            end
        end
    end
end

-- ==========================================
-- PASO 3: BOTONES DE TEST CON OBSERVACIÓN COMPLETA
-- ==========================================
L("\n============================================================", Color3.fromRGB(100, 255, 100))
L("  🧪 PASO 3: Toca un botón para test REAL con observación", Color3.fromRGB(100, 255, 100))
L("============================================================\n", Color3.fromRGB(100, 255, 100))

local tests = {
    {tag = "⛏️MINING", ruta = "Dialogues.Mining.MiningMain", aceptar = "Yes", quest = "Give Quest"},
    {tag = "🧟ZOMBIE", ruta = "Dialogues.Zombie.ZombieMain", aceptar = "Yes", quest = "Give Quest"},
    {tag = "📅DAILY",  ruta = "Dialogues.Daily1.Daily1Main", aceptar = "Lets Start", quest = "Give Quest"},
}

local btnBar = Instance.new("Frame")
btnBar.Size = UDim2.new(1, -10, 0, 28)
btnBar.Position = UDim2.new(0, 5, 0, 34)
btnBar.BackgroundTransparency = 1
btnBar.Parent = MainFrame

for i, t in ipairs(tests) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 170, 0, 24)
    btn.Position = UDim2.new(0, (i-1) * 174, 0, 2)
    btn.BackgroundColor3 = Color3.fromRGB(60, 30, 80)
    btn.Text = t.tag
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 10
    btn.Font = Enum.Font.Code
    btn.Parent = btnBar

    btn.MouseButton1Click:Connect(function()
        btn.Text = "PROBANDO..."
        btn.BackgroundColor3 = Color3.fromRGB(200, 200, 0)

        local inst = ReplicatedStorage
        for _, part in pairs(string.split(t.ruta, ".")) do
            inst = inst and inst:FindFirstChild(part)
        end
        if not inst then
            L("❌ No encontré: " .. t.ruta, Color3.fromRGB(255, 50, 50))
            btn.Text = t.tag; btn.BackgroundColor3 = Color3.fromRGB(60, 30, 80)
            return
        end

        -- Limpiar log de eventos
        eventLog = {}

        L("\n🔬 ═══════════════════════════════════", Color3.fromRGB(255, 50, 255))
        L("🔬 TEST: " .. t.tag, Color3.fromRGB(255, 50, 255))
        L("🔬 Diálogo: " .. inst:GetFullName(), Color3.fromRGB(200, 200, 200))
        L("🔬 ═══════════════════════════════════\n", Color3.fromRGB(255, 50, 255))

        -- LLAMAR ForceDialogue y ESPERAR respuesta
        L("[1] ForceDialogue:InvokeServer(inst)...", Color3.fromRGB(255, 200, 50))
        local t1 = tick()
        local ok1, ret1 = pcall(function() return ForceDialogue:InvokeServer(inst) end)
        local dur1 = tick() - t1
        L("  ⏱️ Tardó: " .. string.format("%.3f", dur1) .. "s", Color3.fromRGB(180, 180, 180))
        L("  Return: " .. Dump(ret1), ok1 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 50, 50))
        L("  Eventos del servidor recibidos: " .. #eventLog, Color3.fromRGB(255, 255, 100))
        task.wait(1)
        L("  Eventos después de 1s: " .. #eventLog, Color3.fromRGB(255, 255, 100))

        -- LLAMAR RunCommand(Yes) y ESPERAR
        local nodoA = inst:FindFirstChild(t.aceptar)
        if nodoA then
            L("\n[2] RunCommand:InvokeServer(\"" .. t.aceptar .. "\")...", Color3.fromRGB(255, 200, 50))
            local prevEvents = #eventLog
            local t2 = tick()
            local ok2, ret2 = pcall(function() return RunCommand:InvokeServer(nodoA) end)
            local dur2 = tick() - t2
            L("  ⏱️ Tardó: " .. string.format("%.3f", dur2) .. "s", Color3.fromRGB(180, 180, 180))
            L("  Return: " .. Dump(ret2), ok2 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 50, 50))
            task.wait(1)
            L("  Eventos nuevos: " .. (#eventLog - prevEvents), Color3.fromRGB(255, 255, 100))
        else
            L("❌ Nodo '" .. t.aceptar .. "' no existe", Color3.fromRGB(255, 50, 50))
        end

        -- LLAMAR RunCommand(Give Quest) y ESPERAR
        local nodoQ = inst:FindFirstChild(t.quest)
        if nodoQ then
            L("\n[3] RunCommand:InvokeServer(\"" .. t.quest .. "\")...", Color3.fromRGB(255, 200, 50))
            local prevEvents = #eventLog
            local t3 = tick()
            local ok3, ret3 = pcall(function() return RunCommand:InvokeServer(nodoQ) end)
            local dur3 = tick() - t3
            L("  ⏱️ Tardó: " .. string.format("%.3f", dur3) .. "s", Color3.fromRGB(180, 180, 180))
            L("  Return: " .. Dump(ret3), ok3 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 50, 50))
            task.wait(1)
            L("  Eventos nuevos: " .. (#eventLog - prevEvents), Color3.fromRGB(255, 255, 100))
        else
            L("❌ Nodo '" .. t.quest .. "' no existe", Color3.fromRGB(255, 50, 50))
        end

        -- RESUMEN DE EVENTOS
        L("\n📊 RESUMEN: Total eventos del servidor = " .. #eventLog, Color3.fromRGB(255, 150, 50))
        if #eventLog == 0 then
            L("⚠️ EL SERVIDOR NO RESPONDIÓ NADA. Posibles causas:", Color3.fromRGB(255, 50, 50))
            L("   1. No estás cerca del NPC", Color3.fromRGB(255, 150, 150))
            L("   2. Necesitas ProximityPrompt real (presionar E)", Color3.fromRGB(255, 150, 150))
            L("   3. Quest bloqueada por nivel/prerrequisito", Color3.fromRGB(255, 150, 150))
        end

        -- AUTO-GUARDAR
        pcall(function() writefile("diag_quest.txt", FullLog) end)
        btn.Text = t.tag
        btn.BackgroundColor3 = Color3.fromRGB(60, 30, 80)
    end)
end

L("⬆️ Toca un botón. Cada evento del servidor se capturará.", Color3.fromRGB(100, 255, 255))
L("[*] También escucho eventos mientras hablas manualmente (E).\n", Color3.fromRGB(255, 255, 50))

-- Auto-guardar
pcall(function() writefile("diag_quest.txt", FullLog) end)
