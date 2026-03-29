-- ==============================================================================
-- 🗺️ PANEL DE MISIONES AUTO-QUEST V1.0
-- ==============================================================================
-- Panel que muestra misiones disponibles y permite aceptarlas automáticamente.
-- Usa: ForceDialogue → RunCommand(Yes) → RunCommand(Give Quest)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- OBTENER REMOTES
-- ==========================================
local KnitServices = ReplicatedStorage
    and ReplicatedStorage:FindFirstChild("Shared")
    and ReplicatedStorage.Shared:FindFirstChild("Packages")
    and ReplicatedStorage.Shared.Packages:FindFirstChild("Knit")
    and ReplicatedStorage.Shared.Packages.Knit:FindFirstChild("Services")

local ForceDialogue, RunCommand, ClientTrackQuest, DialogueRemote

if KnitServices then
    local proxSvc = KnitServices:FindFirstChild("ProximityService")
    if proxSvc and proxSvc:FindFirstChild("RF") then
        ForceDialogue = proxSvc.RF:FindFirstChild("ForceDialogue")
    end
    local dialogSvc = KnitServices:FindFirstChild("DialogueService")
    if dialogSvc and dialogSvc:FindFirstChild("RF") then
        RunCommand = dialogSvc.RF:FindFirstChild("RunCommand")
    end
    local questSvc = KnitServices:FindFirstChild("QuestService")
    if questSvc and questSvc:FindFirstChild("RF") then
        ClientTrackQuest = questSvc.RF:FindFirstChild("ClientTrackQuest")
    end
end

DialogueRemote = ReplicatedStorage:FindFirstChild("DialogueEvents")
    and ReplicatedStorage.DialogueEvents:FindFirstChild("DialogueRemote")

-- ==========================================
-- BASE DE DATOS DE MISIONES
-- ==========================================
local MISIONES = {
    {
        id = "Mining",
        nombre = "⛏️ Extracción de Minerales",
        npc = "Farmer",
        tipo = "RECOLECTAR",
        descripcion = "Recolectar ores para el minero.",
        ruta = "Dialogues.Mining.MiningMain",
        nodoAceptar = "Yes",
        nodoQuest = "Give Quest",
    },
    {
        id = "Daily1",
        nombre = "📅 Misión Diaria (100 Ores)",
        npc = "Daily NPC",
        tipo = "RECOLECTAR",
        descripcion = "Recolectar 100 ores de cualquier tipo.",
        ruta = "Dialogues.Daily1.Daily1Main",
        nodoAceptar = "Lets Start",
        nodoQuest = "Give Quest",
    },
    {
        id = "Weekly1",
        nombre = "📆 Misión Semanal (500 Ores)",
        npc = "Weekly NPC",
        tipo = "RECOLECTAR",
        descripcion = "Recolectar 500 ores de cualquier tipo.",
        ruta = "Dialogues.Weekly1.Weekly1Main",
        nodoAceptar = "Lets Start",
        nodoQuest = "Give Quest",
    },
    {
        id = "Zombie",
        nombre = "🧟 Cacería de Zombies",
        npc = "Zombie Quest NPC",
        tipo = "COMBATE",
        descripcion = "Eliminar zombies en las cuevas.",
        ruta = "Dialogues.Zombie.ZombieMain",
        nodoAceptar = "Yes",
        nodoQuest = "Give Quest",
    },
    {
        id = "SenseiMoro2",
        nombre = "📜 Sensei Moro 2",
        npc = "Sensei Moro 2",
        tipo = "HISTORIA",
        descripcion = "Misión del Sensei: minar y explorar.",
        ruta = "Dialogues.SenseiMoro2.SenseiMoroIsland2",
        nodoAceptar = "Lets Start",
        nodoQuest = "Give Quest",
    },
    {
        id = "GoblinKing",
        nombre = "👑 Rey Goblin",
        npc = "Goblin King",
        tipo = "HISTORIA",
        descripcion = "Cadena de misiones del Rey Goblin.",
        ruta = "Dialogues.GoblinKing.GoblinKingDialogue",
        nodoAceptar = "Lets Start",
        nodoQuest = "Give Quest",
    },
    {
        id = "Tomo",
        nombre = "🐱 Tomo (TomoCat)",
        npc = "Tomo",
        tipo = "HISTORIA",
        descripcion = "Misiones del gato Tomo.",
        ruta = "Dialogues.Tomo.TomoDialogue",
        nodoAceptar = "Yes",
        nodoQuest = "Give Quest",
    },
    {
        id = "Bard",
        nombre = "🎵 El Bardo",
        npc = "Bard",
        tipo = "HISTORIA",
        descripcion = "Misiones del Bardo.",
        ruta = "Dialogues.Bard.BardDialogue",
        nodoAceptar = "Yes",
        nodoQuest = "Give Quest",
    },
    {
        id = "MaskedStranger",
        nombre = "🎭 Extraño Enmascarado",
        npc = "Masked Stranger",
        tipo = "COMBATE",
        descripcion = "50 Skeleton Rogues + 30 Axe Skeletons + 15 Deathaxe + 5 Bombers.",
        ruta = "Dialogues.MaskedStranger.MaskedStrangerDialogue",
        nodoAceptar = "Response", -- "I'll do it."
        nodoQuest = "Command",
    },
}

-- ==========================================
-- GUI
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "QuestPanelUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QuestPanelUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 500)
MainFrame.Position = UDim2.new(0, 10, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(80, 180, 255)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -110, 0, 32)
Title.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
Title.Text = " 🗺️ MISIONES DISPONIBLES"
Title.TextColor3 = Color3.fromRGB(80, 200, 255)
Title.TextSize = 15
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0, 70, 0, 32)
SaveBtn.Position = UDim2.new(1, -110, 0, 0)
SaveBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
SaveBtn.Text = "💾"
SaveBtn.TextColor3 = Color3.new(1,1,1)
SaveBtn.Font = Enum.Font.Code
SaveBtn.TextSize = 16
SaveBtn.Parent = MainFrame

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(1, -38, 0, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(180, 150, 0)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.Font = Enum.Font.Code
MinBtn.TextSize = 18
MinBtn.Parent = MainFrame

-- Filtros
local filterBar = Instance.new("Frame")
filterBar.Size = UDim2.new(1, -10, 0, 26)
filterBar.Position = UDim2.new(0, 5, 0, 34)
filterBar.BackgroundTransparency = 1
filterBar.Parent = MainFrame

local filtros = {"TODAS", "RECOLECTAR", "COMBATE", "HISTORIA"}
local filtroActual = "TODAS"

-- Scroll de misiones
local QuestScroll = Instance.new("ScrollingFrame")
QuestScroll.Size = UDim2.new(1, -10, 1, -100)
QuestScroll.Position = UDim2.new(0, 5, 0, 62)
QuestScroll.BackgroundColor3 = Color3.fromRGB(8, 8, 15)
QuestScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
QuestScroll.ScrollBarThickness = 5
QuestScroll.Parent = MainFrame

local QuestLayout = Instance.new("UIListLayout")
QuestLayout.Parent = QuestScroll
QuestLayout.SortOrder = Enum.SortOrder.LayoutOrder
QuestLayout.Padding = UDim.new(0, 4)

QuestLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    QuestScroll.CanvasSize = UDim2.new(0, 0, 0, QuestLayout.AbsoluteContentSize.Y + 10)
end)

-- Log en la parte inferior
local LogLabel = Instance.new("TextLabel")
LogLabel.Size = UDim2.new(1, -10, 0, 34)
LogLabel.Position = UDim2.new(0, 5, 1, -38)
LogLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
LogLabel.Text = " Listo. Selecciona una misión."
LogLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
LogLabel.TextSize = 10
LogLabel.Font = Enum.Font.Code
LogLabel.TextXAlignment = Enum.TextXAlignment.Left
LogLabel.TextWrapped = true
LogLabel.Parent = MainFrame

local FullLog = "=== PANEL DE MISIONES ===\n\n"

local function Log(text, color)
    FullLog = FullLog .. text .. "\n"
    LogLabel.Text = " " .. text
    LogLabel.TextColor3 = color or Color3.fromRGB(150, 150, 150)
end

-- Minimizar
local isMin = false
MinBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    MainFrame.Size = isMin and UDim2.new(0, 420, 0, 32) or UDim2.new(0, 420, 0, 500)
    QuestScroll.Visible = not isMin
    filterBar.Visible = not isMin
    LogLabel.Visible = not isMin
end)

SaveBtn.MouseButton1Click:Connect(function()
    writefile("quest_panel_log.txt", FullLog)
    SaveBtn.Text = "✅"
    task.delay(1.5, function() SaveBtn.Text = "💾" end)
end)

-- ==========================================
-- RESOLVER INSTANCIA DE DIÁLOGO
-- ==========================================
local function GetDialogueInst(ruta)
    local inst = ReplicatedStorage
    for _, part in pairs(string.split(ruta, ".")) do
        inst = inst and inst:FindFirstChild(part)
    end
    return inst
end

-- ==========================================
-- VERIFICAR DISPONIBILIDAD
-- ==========================================
local function CheckDisponible(mision)
    local dialogueInst = GetDialogueInst(mision.ruta)
    if not dialogueInst then return "NO_EXISTE", "Diálogo no encontrado" end

    -- Verificar que existen los nodos necesarios
    local nodoAceptar = dialogueInst:FindFirstChild(mision.nodoAceptar)
    local nodoQuest = dialogueInst:FindFirstChild(mision.nodoQuest)

    if not nodoAceptar then return "FALTA_NODO", "Nodo '" .. mision.nodoAceptar .. "' no existe" end
    if not nodoQuest then return "FALTA_NODO", "Nodo '" .. mision.nodoQuest .. "' no existe" end

    -- Si tiene nodo "All Are Completed", podría estar completada
    -- Si tiene "Condition", depende del server
    return "DISPONIBLE", "Diálogo y nodos encontrados"
end

-- ==========================================
-- ACEPTAR MISIÓN
-- ==========================================
local function AceptarMision(mision, statusLabel)
    local dialogueInst = GetDialogueInst(mision.ruta)
    if not dialogueInst then
        Log("❌ Diálogo no encontrado: " .. mision.ruta, Color3.fromRGB(255, 50, 50))
        return false
    end

    statusLabel.Text = "⏳ Iniciando..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    Log("🔄 Aceptando: " .. mision.nombre, Color3.fromRGB(255, 200, 50))

    -- Paso 1: ForceDialogue
    if ForceDialogue then
        local ok, res = pcall(function()
            return ForceDialogue:InvokeServer(dialogueInst)
        end)
        Log("  [1] ForceDialogue: " .. (ok and "✅" or "❌ " .. tostring(res)), ok and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 50, 50))
        if not ok then
            statusLabel.Text = "❌ Error"
            statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            return false
        end
        task.wait(0.5)
    end

    -- Paso 2: RunCommand con nodo de aceptar (Yes/Lets Start)
    if RunCommand then
        local nodoAceptar = dialogueInst:FindFirstChild(mision.nodoAceptar)
        if nodoAceptar then
            statusLabel.Text = "⏳ Aceptando..."
            local ok, res = pcall(function()
                return RunCommand:InvokeServer(nodoAceptar)
            end)
            Log("  [2] RunCommand(" .. mision.nodoAceptar .. "): " .. (ok and "✅" or "❌ " .. tostring(res)), ok and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 50, 50))
            task.wait(0.5)
        end
    end

    -- Paso 3: RunCommand con Give Quest
    if RunCommand then
        local nodoQuest = dialogueInst:FindFirstChild(mision.nodoQuest)
        if nodoQuest then
            statusLabel.Text = "⏳ Activando Quest..."
            local ok, res = pcall(function()
                return RunCommand:InvokeServer(nodoQuest)
            end)
            Log("  [3] RunCommand(" .. mision.nodoQuest .. "): " .. (ok and "✅" or "❌ " .. tostring(res)), ok and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 50, 50))
            task.wait(0.3)
        end
    end

    -- Paso 4: Track Quest
    if ClientTrackQuest then
        pcall(function()
            ClientTrackQuest:InvokeServer(mision.id)
        end)
    end

    statusLabel.Text = "✅ Enviado"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    Log("✅ Secuencia completa para: " .. mision.nombre, Color3.fromRGB(100, 255, 100))
    
    -- Auto-guardar
    pcall(function() writefile("quest_panel_log.txt", FullLog) end)
    return true
end

-- ==========================================
-- CREAR TARJETAS DE MISIÓN
-- ==========================================
local function CrearTarjetas(filtro)
    -- Limpiar
    for _, child in pairs(QuestScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local colores = {
        RECOLECTAR = Color3.fromRGB(50, 130, 50),
        COMBATE = Color3.fromRGB(180, 50, 50),
        HISTORIA = Color3.fromRGB(50, 80, 180),
    }

    local iconos = {
        RECOLECTAR = "⛏️",
        COMBATE = "⚔️",
        HISTORIA = "📜",
    }

    for i, mision in ipairs(MISIONES) do
        if filtro == "TODAS" or mision.tipo == filtro then
            local estado, detalle = CheckDisponible(mision)

            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, -8, 0, 70)
            card.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
            card.BorderSizePixel = 1
            card.BorderColor3 = colores[mision.tipo] or Color3.fromRGB(80, 80, 80)
            card.LayoutOrder = i
            card.Parent = QuestScroll

            -- Tipo badge
            local badge = Instance.new("TextLabel")
            badge.Size = UDim2.new(0, 80, 0, 16)
            badge.Position = UDim2.new(0, 4, 0, 2)
            badge.BackgroundColor3 = colores[mision.tipo] or Color3.fromRGB(60, 60, 60)
            badge.Text = (iconos[mision.tipo] or "") .. " " .. mision.tipo
            badge.TextColor3 = Color3.new(1,1,1)
            badge.TextSize = 9
            badge.Font = Enum.Font.Code
            badge.Parent = card

            -- Nombre
            local nombre = Instance.new("TextLabel")
            nombre.Size = UDim2.new(1, -100, 0, 18)
            nombre.Position = UDim2.new(0, 88, 0, 1)
            nombre.BackgroundTransparency = 1
            nombre.Text = mision.nombre
            nombre.TextColor3 = Color3.fromRGB(240, 240, 240)
            nombre.TextSize = 12
            nombre.Font = Enum.Font.Code
            nombre.TextXAlignment = Enum.TextXAlignment.Left
            nombre.Parent = card

            -- Descripcion
            local desc = Instance.new("TextLabel")
            desc.Size = UDim2.new(1, -90, 0, 14)
            desc.Position = UDim2.new(0, 4, 0, 20)
            desc.BackgroundTransparency = 1
            desc.Text = "NPC: " .. mision.npc .. " | " .. mision.descripcion
            desc.TextColor3 = Color3.fromRGB(150, 150, 170)
            desc.TextSize = 9
            desc.Font = Enum.Font.Code
            desc.TextXAlignment = Enum.TextXAlignment.Left
            desc.TextWrapped = true
            desc.Parent = card

            -- Estado
            local statusLabel = Instance.new("TextLabel")
            statusLabel.Size = UDim2.new(0, 100, 0, 16)
            statusLabel.Position = UDim2.new(1, -106, 0, 50)
            statusLabel.BackgroundTransparency = 1
            statusLabel.Text = estado == "DISPONIBLE" and "🟢 Disponible" or "🔴 " .. detalle
            statusLabel.TextColor3 = estado == "DISPONIBLE" and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
            statusLabel.TextSize = 9
            statusLabel.Font = Enum.Font.Code
            statusLabel.TextXAlignment = Enum.TextXAlignment.Right
            statusLabel.Parent = card

            -- Botón Aceptar
            if estado == "DISPONIBLE" then
                local acceptBtn = Instance.new("TextButton")
                acceptBtn.Size = UDim2.new(0, 90, 0, 24)
                acceptBtn.Position = UDim2.new(0, 4, 0, 42)
                acceptBtn.BackgroundColor3 = colores[mision.tipo] or Color3.fromRGB(50, 100, 50)
                acceptBtn.Text = "▶ ACEPTAR"
                acceptBtn.TextColor3 = Color3.new(1,1,1)
                acceptBtn.TextSize = 11
                acceptBtn.Font = Enum.Font.Code
                acceptBtn.Parent = card

                acceptBtn.MouseButton1Click:Connect(function()
                    acceptBtn.Text = "..."
                    task.spawn(function()
                        local ok = AceptarMision(mision, statusLabel)
                        acceptBtn.Text = ok and "✅ HECHO" or "❌ ERROR"
                        task.wait(3)
                        acceptBtn.Text = "▶ ACEPTAR"
                    end)
                end)
            end
        end
    end
end

-- Crear filtros
for i, f in ipairs(filtros) do
    local fbtn = Instance.new("TextButton")
    fbtn.Size = UDim2.new(0, 95, 0, 22)
    fbtn.Position = UDim2.new(0, (i-1) * 98, 0, 2)
    fbtn.BackgroundColor3 = f == "TODAS" and Color3.fromRGB(80, 80, 120) or Color3.fromRGB(30, 30, 50)
    fbtn.Text = f
    fbtn.TextColor3 = Color3.new(1,1,1)
    fbtn.TextSize = 10
    fbtn.Font = Enum.Font.Code
    fbtn.Parent = filterBar

    fbtn.MouseButton1Click:Connect(function()
        filtroActual = f
        for _, ch in pairs(filterBar:GetChildren()) do
            if ch:IsA("TextButton") then
                ch.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
            end
        end
        fbtn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
        CrearTarjetas(f)
    end)
end

-- Iniciar
CrearTarjetas("TODAS")
Log("🗺️ Panel cargado. " .. #MISIONES .. " misiones en la base de datos.", Color3.fromRGB(100, 200, 255))
