-- ==============================================================================
-- 🧪 TESTER DE AUTO-QUEST V1.0
-- ==============================================================================
-- Prueba invocar los RemoteFunctions de diálogo para aceptar misiones
-- sin necesidad de presionar E ni elegir opciones manualmente.
-- Guarda TODOS los resultados en autoquest_test.txt

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- GUI
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "AutoQuestTestUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoQuestTestUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 400)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 20, 10)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(100, 255, 100)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -180, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(15, 30, 15)
Title.Text = " 🧪 AUTO-QUEST TESTER V1.0"
Title.TextColor3 = Color3.fromRGB(100, 255, 100)
Title.TextSize = 14
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0, 100, 0, 30)
SaveBtn.Position = UDim2.new(1, -180, 0, 0)
SaveBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
SaveBtn.Text = "💾 GUARDAR"
SaveBtn.TextColor3 = Color3.new(1,1,1)
SaveBtn.Font = Enum.Font.Code
SaveBtn.TextSize = 11
SaveBtn.Parent = MainFrame

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 35, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(180, 150, 0)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.Font = Enum.Font.Code
MinBtn.TextSize = 16
MinBtn.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.Code
CloseBtn.TextSize = 16
CloseBtn.Parent = MainFrame

local OutputScroll = Instance.new("ScrollingFrame")
OutputScroll.Size = UDim2.new(1, -10, 1, -65)
OutputScroll.Position = UDim2.new(0, 5, 0, 60)
OutputScroll.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
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

local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    MainFrame.Size = isMinimized and UDim2.new(0, 520, 0, 30) or UDim2.new(0, 520, 0, 400)
    OutputScroll.Visible = not isMinimized
end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local FullLog = "=== AUTO-QUEST TESTER ===\n\n"
local saveCount = 0

SaveBtn.MouseButton1Click:Connect(function()
    writefile("autoquest_test.txt", FullLog)
    if setclipboard then setclipboard(FullLog) end
    SaveBtn.Text = "¡GUARDADO!"
    task.delay(2, function() SaveBtn.Text = "💾 GUARDAR" end)
end)

local function LogGUI(text, color)
    FullLog = FullLog .. text .. "\n"
    saveCount = saveCount + 1
    if saveCount >= 15 then
        pcall(function() writefile("autoquest_test.txt", FullLog) end)
        saveCount = 0
    end
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, -10, 0, 18)
    msg.BackgroundTransparency = 1
    msg.Text = text
    msg.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    msg.TextSize = 11
    msg.Font = Enum.Font.Code
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.TextWrapped = true
    msg.Parent = OutputScroll
    msg.Size = UDim2.new(1, -10, 0, msg.TextBounds.Y + 4)
end

local function SafeStr(v)
    if typeof(v) == "Instance" then return "[Instance] " .. v:GetFullName() end
    if type(v) == "table" then
        local ok, r = pcall(function() return HttpService:JSONEncode(v) end)
        if ok then return r end
        local s = "{"
        for k, val in pairs(v) do s = s .. tostring(k) .. "=" .. tostring(val) .. ", " end
        return s .. "}"
    end
    return "(" .. typeof(v) .. ") " .. tostring(v)
end

-- ==========================================
-- OBTENER REFERENCIAS A LOS REMOTES
-- ==========================================
LogGUI("============================================================", Color3.fromRGB(100, 255, 100))
LogGUI("  🔧 Obteniendo referencias a RemoteFunctions", Color3.fromRGB(100, 255, 100))
LogGUI("============================================================\n", Color3.fromRGB(100, 255, 100))

local KnitServices = ReplicatedStorage:FindFirstChild("Shared")
    and ReplicatedStorage.Shared:FindFirstChild("Packages")
    and ReplicatedStorage.Shared.Packages:FindFirstChild("Knit")
    and ReplicatedStorage.Shared.Packages.Knit:FindFirstChild("Services")

local ProximityDialogue, ForceDialogue, DialogueEvent, RunCommand, ClientTrackQuest, ProgressUIQuest

if KnitServices then
    local proxSvc = KnitServices:FindFirstChild("ProximityService")
    if proxSvc and proxSvc:FindFirstChild("RF") then
        ProximityDialogue = proxSvc.RF:FindFirstChild("Dialogue")
        ForceDialogue = proxSvc.RF:FindFirstChild("ForceDialogue")
    end

    local dialogSvc = KnitServices:FindFirstChild("DialogueService")
    if dialogSvc then
        if dialogSvc:FindFirstChild("RE") then
            DialogueEvent = dialogSvc.RE:FindFirstChild("DialogueEvent")
        end
        if dialogSvc:FindFirstChild("RF") then
            RunCommand = dialogSvc.RF:FindFirstChild("RunCommand")
        end
    end

    local questSvc = KnitServices:FindFirstChild("QuestService")
    if questSvc and questSvc:FindFirstChild("RF") then
        ClientTrackQuest = questSvc.RF:FindFirstChild("ClientTrackQuest")
        ProgressUIQuest = questSvc.RF:FindFirstChild("ProgressUIQuest")
    end
end

LogGUI("ProximityService.Dialogue: " .. (ProximityDialogue and "✅" or "❌"), ProximityDialogue and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 50, 50))
LogGUI("ProximityService.ForceDialogue: " .. (ForceDialogue and "✅" or "❌"), ForceDialogue and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 50, 50))
LogGUI("DialogueService.DialogueEvent: " .. (DialogueEvent and "✅" or "❌"), DialogueEvent and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 50, 50))
LogGUI("DialogueService.RunCommand: " .. (RunCommand and "✅" or "❌"), RunCommand and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 50, 50))
LogGUI("QuestService.ClientTrackQuest: " .. (ClientTrackQuest and "✅" or "❌"), ClientTrackQuest and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 50, 50))
LogGUI("QuestService.ProgressUIQuest: " .. (ProgressUIQuest and "✅" or "❌"), ProgressUIQuest and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 50, 50))

-- Escuchar DialogueEvent (server -> client)
if DialogueEvent then
    DialogueEvent.OnClientEvent:Connect(function(...)
        local args = {...}
        LogGUI("\n🔵 [DialogueService.DialogueEvent] SERVER → CLIENTE", Color3.fromRGB(100, 200, 255))
        for i, v in ipairs(args) do
            LogGUI("   [" .. i .. "] " .. SafeStr(v), Color3.fromRGB(200, 200, 200))
        end
    end)
end

-- Escuchar DialogueRemote
local DialogueRemote = ReplicatedStorage:FindFirstChild("DialogueEvents") and ReplicatedStorage.DialogueEvents:FindFirstChild("DialogueRemote")
if DialogueRemote then
    DialogueRemote.OnClientEvent:Connect(function(...)
        local args = {...}
        LogGUI("\n🔴 [DialogueRemote] SERVER → CLIENTE", Color3.fromRGB(255, 100, 100))
        for i, v in ipairs(args) do
            LogGUI("   [" .. i .. "] " .. SafeStr(v), Color3.fromRGB(200, 200, 200))
        end
    end)
end

-- ==========================================
-- BOTONES DE TEST POR NPC
-- ==========================================
LogGUI("\n============================================================", Color3.fromRGB(255, 255, 100))
LogGUI("  🧪 BOTONES DE PRUEBA - Toca uno para testear", Color3.fromRGB(255, 255, 100))
LogGUI("============================================================\n", Color3.fromRGB(255, 255, 100))

local testNPCs = {
    {name = "Mining",   dialogue = "Dialogues.Mining.MiningMain",             npcWorld = "Farmer",        tag = "⛏️MINING"},
    {name = "Zombie",   dialogue = "Dialogues.Zombie.ZombieMain",             npcWorld = "Zombie Quest",  tag = "🧟ZOMBIE"},
    {name = "Daily1",   dialogue = "Dialogues.Daily1.Daily1Main",             npcWorld = "Daily1",        tag = "📅DAILY"},
    {name = "SenseiM2", dialogue = "Dialogues.SenseiMoro2.SenseiMoroIsland2", npcWorld = "Sensei Moro 2", tag = "📜SENSEI"},
}

local btnBar = Instance.new("Frame")
btnBar.Size = UDim2.new(1, -10, 0, 30)
btnBar.Position = UDim2.new(0, 5, 0, 32)
btnBar.BackgroundTransparency = 1
btnBar.Parent = MainFrame

for i, npc in ipairs(testNPCs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 0, 26)
    btn.Position = UDim2.new(0, (i-1) * 124, 0, 2)
    btn.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
    btn.Text = npc.tag
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 10
    btn.Font = Enum.Font.Code
    btn.Parent = btnBar

    btn.MouseButton1Click:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(200, 200, 0)
        btn.Text = "PROBANDO..."
        
        -- Obtener la instancia del diálogo
        local dialoguePath = npc.dialogue
        local dialogueInst = ReplicatedStorage
        for _, part in pairs(string.split(dialoguePath, ".")) do
            dialogueInst = dialogueInst and dialogueInst:FindFirstChild(part)
        end
        
        LogGUI("\n🧪 ========================================", Color3.fromRGB(255, 255, 100))
        LogGUI("🧪 TESTEANDO: " .. npc.name, Color3.fromRGB(255, 255, 100))
        LogGUI("🧪 Diálogo: " .. (dialogueInst and dialogueInst:GetFullName() or "NO ENCONTRADO"), Color3.fromRGB(200, 200, 200))
        LogGUI("🧪 ========================================\n", Color3.fromRGB(255, 255, 100))

        if not dialogueInst then
            LogGUI("❌ No se encontró la instancia de diálogo", Color3.fromRGB(255, 50, 50))
            btn.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
            btn.Text = npc.tag
            return
        end

        -- ==========================================
        -- TEST 1: ForceDialogue
        -- ==========================================
        if ForceDialogue then
            LogGUI("[TEST 1] ForceDialogue(dialogueInst)", Color3.fromRGB(255, 200, 50))
            local ok, res = pcall(function()
                return ForceDialogue:InvokeServer(dialogueInst)
            end)
            LogGUI("  Resultado: " .. (ok and "✅ " .. SafeStr(res) or "❌ " .. tostring(res)), ok and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100))
            task.wait(1)
        end

        -- ==========================================
        -- TEST 2: ProximityDialogue
        -- ==========================================
        if ProximityDialogue then
            LogGUI("[TEST 2] ProximityDialogue(dialogueInst)", Color3.fromRGB(255, 200, 50))
            local ok, res = pcall(function()
                return ProximityDialogue:InvokeServer(dialogueInst)
            end)
            LogGUI("  Resultado: " .. (ok and "✅ " .. SafeStr(res) or "❌ " .. tostring(res)), ok and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100))
            task.wait(1)
        end

        -- ==========================================
        -- TEST 3: RunCommand con nodo "Yes" / "Lets Start"
        -- ==========================================
        if RunCommand then
            local testNodes = {"Yes", "Lets Start", "Let's start", "I'm in"}
            for _, nodeName in pairs(testNodes) do
                local nodo = dialogueInst:FindFirstChild(nodeName)
                if nodo then
                    LogGUI("[TEST 3] RunCommand(\"" .. nodeName .. "\"): " .. nodo:GetFullName(), Color3.fromRGB(255, 200, 50))
                    local ok, res = pcall(function()
                        return RunCommand:InvokeServer(nodo)
                    end)
                    LogGUI("  Resultado: " .. (ok and "✅ " .. SafeStr(res) or "❌ " .. tostring(res)), ok and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100))
                    task.wait(0.5)
                end
            end

            -- Test con Give Quest
            local giveQuest = dialogueInst:FindFirstChild("Give Quest")
            if giveQuest then
                LogGUI("[TEST 3b] RunCommand(Give Quest): " .. giveQuest:GetFullName(), Color3.fromRGB(255, 200, 50))
                local ok, res = pcall(function()
                    return RunCommand:InvokeServer(giveQuest)
                end)
                LogGUI("  Resultado: " .. (ok and "✅ " .. SafeStr(res) or "❌ " .. tostring(res)), ok and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100))
            end
        end

        -- ==========================================
        -- TEST 4: ClientTrackQuest
        -- ==========================================
        if ClientTrackQuest then
            LogGUI("[TEST 4] ClientTrackQuest(\"" .. npc.name .. "\")", Color3.fromRGB(255, 200, 50))
            local ok, res = pcall(function()
                return ClientTrackQuest:InvokeServer(npc.name)
            end)
            LogGUI("  Resultado: " .. (ok and "✅ " .. SafeStr(res) or "❌ " .. tostring(res)), ok and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100))
        end

        LogGUI("\n🧪 TESTS COMPLETADOS para " .. npc.name, Color3.fromRGB(100, 255, 100))
        
        -- Auto-guardar
        pcall(function() writefile("autoquest_test.txt", FullLog) end)
        
        btn.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
        btn.Text = npc.tag
    end)
end

LogGUI("⬆️ Toca un botón para probar aceptar esa misión automáticamente.", Color3.fromRGB(100, 255, 255))
LogGUI("[!] Los resultados de cada test aparecerán aquí.\n", Color3.fromRGB(255, 255, 50))

-- Auto-guardar al final
pcall(function() writefile("autoquest_test.txt", FullLog) end)
