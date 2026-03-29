-- ==============================================================================
-- 🗺️ EXPLORADOR DE ÁRBOLES DE DIÁLOGO V1.0
-- ==============================================================================
-- Lee TODA la estructura interna de ReplicatedStorage.Dialogues
-- Clasifica misiones por tipo: "Hablar con NPC", "Matar Mobs", "Recolectar", etc.
-- También captura qué RemoteEvents se disparan al elegir opciones de diálogo.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- GUI EN PANTALLA
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "DialogExplorerUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DialogExplorerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 15, 20)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(100, 200, 255)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -170, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
Title.Text = " 🗺️ EXPLORADOR DE DIÁLOGOS V1.0"
Title.TextColor3 = Color3.fromRGB(100, 200, 255)
Title.TextSize = 14
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0, 100, 0, 30)
CopyBtn.Position = UDim2.new(1, -170, 0, 0)
CopyBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
CopyBtn.Text = "📥 COPIAR"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.Code
CopyBtn.TextSize = 11
CopyBtn.Parent = MainFrame

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 35, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(180, 150, 0)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.Code
MinBtn.TextSize = 16
MinBtn.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.Code
CloseBtn.TextSize = 16
CloseBtn.Parent = MainFrame

local OutputScroll = Instance.new("ScrollingFrame")
OutputScroll.Size = UDim2.new(1, -10, 1, -40)
OutputScroll.Position = UDim2.new(0, 5, 0, 35)
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
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 500, 0, 30)
        OutputScroll.Visible = false
    else
        MainFrame.Size = UDim2.new(0, 500, 0, 400)
        OutputScroll.Visible = true
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local FullLogText = "=== EXPLORADOR DE ÁRBOLES DE DIÁLOGO ===\n\n"
CopyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(FullLogText)
        CopyBtn.Text = "¡COPIADO!"
        task.delay(2, function() CopyBtn.Text = "📥 COPIAR" end)
    end
end)

local function LogGUI(text, color)
    FullLogText = FullLogText .. text .. "\n"
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
    OutputScroll.CanvasPosition = Vector2.new(0, 99999)
end

-- ==========================================
-- FASE 1: EXPLORAR ReplicatedStorage.Dialogues
-- ==========================================
LogGUI("============================================================", Color3.fromRGB(100, 200, 255))
LogGUI("  🔍 EXPLORANDO ReplicatedStorage.Dialogues", Color3.fromRGB(100, 200, 255))
LogGUI("============================================================\n", Color3.fromRGB(100, 200, 255))

local DialoguesFolder = ReplicatedStorage:FindFirstChild("Dialogues")
if not DialoguesFolder then
    LogGUI("❌ ERROR: No se encontró ReplicatedStorage.Dialogues", Color3.fromRGB(255, 50, 50))
    return
end

local misionesDetectadas = {
    hablarNPC = {},
    matarMobs = {},
    recolectar = {},
    otras = {}
}

local function SafeRequire(moduleScript)
    local success, result = pcall(function()
        return require(moduleScript)
    end)
    if success then return result end
    return nil
end

local function AnalizarValor(valor, indent)
    indent = indent or ""
    if type(valor) == "table" then
        for k, v in pairs(valor) do
            if type(v) == "table" then
                LogGUI(indent .. "📂 " .. tostring(k) .. ":", Color3.fromRGB(200, 200, 150))
                AnalizarValor(v, indent .. "   ")
            else
                LogGUI(indent .. "🔑 " .. tostring(k) .. " = " .. tostring(v), Color3.fromRGB(180, 180, 180))
            end
        end
    else
        LogGUI(indent .. "📄 " .. tostring(valor), Color3.fromRGB(180, 180, 180))
    end
end

local function ClasificarMision(npcName, texto)
    local t = string.lower(tostring(texto))
    if string.find(t, "talk to") or string.find(t, "speak") or string.find(t, "habla") or string.find(t, "visit") or string.find(t, "go to") or string.find(t, "find") then
        return "hablarNPC"
    elseif string.find(t, "kill") or string.find(t, "defeat") or string.find(t, "slay") or string.find(t, "destroy") or string.find(t, "hunt") then
        return "matarMobs"
    elseif string.find(t, "collect") or string.find(t, "gather") or string.find(t, "mine") or string.find(t, "bring") then
        return "recolectar"
    end
    return "otras"
end

local function BuscarTextosMision(tbl, npcName, depth)
    depth = depth or 0
    if depth > 10 then return end
    
    if type(tbl) ~= "table" then return end
    
    for k, v in pairs(tbl) do
        local key = string.lower(tostring(k))
        
        -- Buscar campos que parezcan texto de misión
        if type(v) == "string" then
            local vLower = string.lower(v)
            if string.find(vLower, "kill") or string.find(vLower, "defeat") or string.find(vLower, "talk to") 
                or string.find(vLower, "speak") or string.find(vLower, "collect") or string.find(vLower, "gather")
                or string.find(vLower, "mine") or string.find(vLower, "find") or string.find(vLower, "bring")
                or string.find(vLower, "slay") or string.find(vLower, "hunt") or string.find(vLower, "go to")
                or string.find(vLower, "visit") or string.find(vLower, "quest") or string.find(vLower, "mission")
                or string.find(vLower, "accept") or string.find(vLower, "reward") then
                
                local tipo = ClasificarMision(npcName, v)
                LogGUI("   🎯 [" .. string.upper(tipo) .. "] " .. tostring(k) .. ": " .. v, Color3.fromRGB(255, 255, 100))
                
                table.insert(misionesDetectadas[tipo], {
                    npc = npcName,
                    campo = tostring(k),
                    texto = v
                })
            end
        elseif type(v) == "table" then
            BuscarTextosMision(v, npcName, depth + 1)
        end
    end
end

-- Explorar cada NPC en la carpeta Dialogues
local npcCount = 0
for _, npcFolder in pairs(DialoguesFolder:GetChildren()) do
    npcCount = npcCount + 1
    LogGUI("╔══════════════════════════════════════════╗", Color3.fromRGB(100, 255, 100))
    LogGUI("║ 🤖 NPC: " .. npcFolder.Name, Color3.fromRGB(100, 255, 100))
    LogGUI("╚══════════════════════════════════════════╝", Color3.fromRGB(100, 255, 100))
    LogGUI("📂 Ruta: " .. npcFolder:GetFullName(), Color3.fromRGB(150, 150, 150))
    LogGUI("📊 Hijos: " .. #npcFolder:GetChildren(), Color3.fromRGB(150, 150, 150))
    
    -- Listar todos los hijos con su tipo
    for _, child in pairs(npcFolder:GetChildren()) do
        local childType = child.ClassName
        LogGUI("   📄 [" .. childType .. "] " .. child.Name, Color3.fromRGB(200, 200, 200))
        
        -- Si es un ModuleScript, intentar require para leer su contenido
        if child:IsA("ModuleScript") then
            LogGUI("   ⚡ Intentando leer ModuleScript...", Color3.fromRGB(255, 200, 50))
            local data = SafeRequire(child)
            if data then
                LogGUI("   ✅ ModuleScript leído exitosamente!", Color3.fromRGB(100, 255, 100))
                AnalizarValor(data, "      ")
                BuscarTextosMision(data, npcFolder.Name)
            else
                LogGUI("   ❌ No se pudo leer el ModuleScript", Color3.fromRGB(255, 100, 100))
            end
        end
        
        -- Si es una carpeta o modelo, explorar hijos
        if child:IsA("Folder") or child:IsA("Configuration") then
            for _, subChild in pairs(child:GetChildren()) do
                LogGUI("      📄 [" .. subChild.ClassName .. "] " .. subChild.Name, Color3.fromRGB(180, 180, 180))
                
                if subChild:IsA("ModuleScript") then
                    local data = SafeRequire(subChild)
                    if data then
                        LogGUI("      ✅ SubModuleScript leído!", Color3.fromRGB(100, 255, 100))
                        AnalizarValor(data, "         ")
                        BuscarTextosMision(data, npcFolder.Name)
                    end
                end
                
                -- Leer valores simples (StringValue, IntValue, etc.)
                if subChild:IsA("ValueBase") then
                    LogGUI("      🔑 " .. subChild.Name .. " = " .. tostring(subChild.Value), Color3.fromRGB(255, 200, 100))
                end
            end
        end
        
        -- Leer valores simples directos
        if child:IsA("ValueBase") then
            LogGUI("   🔑 " .. child.Name .. " = " .. tostring(child.Value), Color3.fromRGB(255, 200, 100))
        end
    end
    LogGUI("", Color3.fromRGB(150, 150, 150))
end

-- ==========================================
-- FASE 2: EXPLORAR DialogueEvents (Remotes)
-- ==========================================
LogGUI("\n============================================================", Color3.fromRGB(255, 200, 100))
LogGUI("  📡 EXPLORANDO ReplicatedStorage.DialogueEvents", Color3.fromRGB(255, 200, 100))
LogGUI("============================================================\n", Color3.fromRGB(255, 200, 100))

local DialogueEvents = ReplicatedStorage:FindFirstChild("DialogueEvents")
if DialogueEvents then
    for _, remote in pairs(DialogueEvents:GetChildren()) do
        LogGUI("📡 [" .. remote.ClassName .. "] " .. remote.Name .. " → " .. remote:GetFullName(), Color3.fromRGB(200, 200, 200))
    end
else
    LogGUI("❌ No se encontró DialogueEvents", Color3.fromRGB(255, 50, 50))
end

-- ==========================================
-- FASE 3: EXPLORAR Knit Quest Services
-- ==========================================
LogGUI("\n============================================================", Color3.fromRGB(255, 150, 50))
LogGUI("  🔧 BUSCANDO SERVICIOS DE QUEST (Knit)", Color3.fromRGB(255, 150, 50))
LogGUI("============================================================\n", Color3.fromRGB(255, 150, 50))

local function BuscarQuests(parent, depth)
    depth = depth or 0
    if depth > 6 then return end
    for _, child in pairs(parent:GetChildren()) do
        local nameLower = string.lower(child.Name)
        if string.find(nameLower, "quest") or string.find(nameLower, "mission") or string.find(nameLower, "dialogue") then
            LogGUI(string.rep("  ", depth) .. "🔧 [" .. child.ClassName .. "] " .. child:GetFullName(), Color3.fromRGB(255, 200, 100))
            
            if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") or child:IsA("BindableEvent") then
                LogGUI(string.rep("  ", depth) .. "   ⚡ ¡REMOTE DE MISIÓN ENCONTRADO!", Color3.fromRGB(255, 100, 100))
            end
            
            if child:IsA("ModuleScript") then
                local data = SafeRequire(child)
                if data and type(data) == "table" then
                    LogGUI(string.rep("  ", depth) .. "   📦 ModuleScript con datos:", Color3.fromRGB(100, 255, 100))
                    AnalizarValor(data, string.rep("  ", depth) .. "      ")
                end
            end
        end
        BuscarQuests(child, depth + 1)
    end
end

BuscarQuests(ReplicatedStorage)

-- ==========================================
-- RESUMEN FINAL
-- ==========================================
LogGUI("\n============================================================", Color3.fromRGB(100, 255, 100))
LogGUI("  📊 RESUMEN DE MISIONES DETECTADAS", Color3.fromRGB(100, 255, 100))
LogGUI("============================================================", Color3.fromRGB(100, 255, 100))
LogGUI("🤖 NPCs con Diálogos: " .. npcCount, Color3.fromRGB(200, 200, 200))
LogGUI("🗣️ Misiones de Hablar con NPC: " .. #misionesDetectadas.hablarNPC, Color3.fromRGB(100, 200, 255))
LogGUI("⚔️ Misiones de Matar Mobs: " .. #misionesDetectadas.matarMobs, Color3.fromRGB(255, 100, 100))
LogGUI("⛏️ Misiones de Recolectar: " .. #misionesDetectadas.recolectar, Color3.fromRGB(255, 200, 50))
LogGUI("❓ Otras Misiones: " .. #misionesDetectadas.otras, Color3.fromRGB(200, 200, 200))

LogGUI("\n[✔] Exploración completada. Presiona COPIAR para enviar los datos.", Color3.fromRGB(100, 255, 100))
