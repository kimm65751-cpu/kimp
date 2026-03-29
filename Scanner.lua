-- ==============================================================================
-- 🗺️ EXPLORADOR DE ÁRBOLES DE DIÁLOGO V1.1 (SEGURO)
-- ==============================================================================
-- Lee la estructura de ReplicatedStorage.Dialogues SIN require() peligrosos.
-- Solo lee la jerarquía de instancias y sus propiedades visibles.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- GUI
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
Title.Text = " 🗺️ EXPLORADOR DIÁLOGOS V1.4"
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
local linesSinceLastSave = 0

CopyBtn.MouseButton1Click:Connect(function()
    writefile("datos.txt", FullLogText)
    if setclipboard then setclipboard(FullLogText) end
    CopyBtn.Text = "¡GUARDADO!"
    task.delay(2, function() CopyBtn.Text = "💾 GUARDAR" end)
end)

local function LogGUI(text, color)
    FullLogText = FullLogText .. text .. "\n"
    linesSinceLastSave = linesSinceLastSave + 1
    -- Auto-guardar cada 20 líneas para no perder datos si crashea
    if linesSinceLastSave >= 20 then
        pcall(function() writefile("datos.txt", FullLogText) end)
        linesSinceLastSave = 0
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

-- ==========================================
-- FASE 1: LEER ESTRUCTURA DE Dialogues (SIN require)
-- ==========================================
LogGUI("============================================================", Color3.fromRGB(100, 200, 255))
LogGUI("  🔍 EXPLORANDO ReplicatedStorage.Dialogues", Color3.fromRGB(100, 200, 255))
LogGUI("============================================================\n", Color3.fromRGB(100, 200, 255))

local DialoguesFolder = ReplicatedStorage:FindFirstChild("Dialogues")
if not DialoguesFolder then
    LogGUI("❌ ERROR: No se encontró ReplicatedStorage.Dialogues", Color3.fromRGB(255, 50, 50))
    return
end

-- Función segura para leer propiedades
local function LeerPropiedad(inst, prop)
    local ok, val = pcall(function() return inst[prop] end)
    if ok then return val end
    return nil
end

-- Explorar jerarquía de instancias (máx 5 niveles, con pausa cada NPC)
local function ExplorarInstancia(inst, indent, depth)
    if depth > 5 then return end
    
    for _, child in pairs(inst:GetChildren()) do
        local clase = child.ClassName
        local extra = ""
        
        -- Leer propiedades según el tipo
        if child:IsA("StringValue") then
            extra = " = \"" .. tostring(child.Value) .. "\""
        elseif child:IsA("IntValue") or child:IsA("NumberValue") then
            extra = " = " .. tostring(child.Value)
        elseif child:IsA("BoolValue") then
            extra = " = " .. tostring(child.Value)
        elseif child:IsA("ObjectValue") then
            local val = LeerPropiedad(child, "Value")
            extra = " -> " .. (val and val:GetFullName() or "nil")
        end
        
        -- Color según tipo
        local color = Color3.fromRGB(180, 180, 180)
        if child:IsA("ModuleScript") then
            color = Color3.fromRGB(255, 200, 50)
            extra = extra .. " [⚡MODULE - " .. #child:GetChildren() .. " hijos]"
        elseif child:IsA("Folder") or child:IsA("Configuration") then
            color = Color3.fromRGB(100, 200, 255)
            extra = extra .. " [📂 " .. #child:GetChildren() .. " hijos]"
        end
        
        LogGUI(indent .. "[" .. clase .. "] " .. child.Name .. extra, color)
        
        -- Recursión solo en no-ModuleScripts (require crashea)
        if not child:IsA("ModuleScript") then
            ExplorarInstancia(child, indent .. "   ", depth + 1)
        else
            -- Para ModuleScripts, solo listar sus hijos (que son sub-diálogos)
            for _, sub in pairs(child:GetChildren()) do
                local subExtra = ""
                if sub:IsA("StringValue") then
                    subExtra = " = \"" .. tostring(sub.Value) .. "\""
                elseif sub:IsA("ModuleScript") then
                    subExtra = " [⚡MODULE - " .. #sub:GetChildren() .. " hijos]"
                elseif sub:IsA("Folder") then
                    subExtra = " [📂 " .. #sub:GetChildren() .. " hijos]"
                end
                LogGUI(indent .. "   [" .. sub.ClassName .. "] " .. sub.Name .. subExtra, Color3.fromRGB(200, 200, 150))
                
                -- Un nivel más para sub-sub
                for _, subsub in pairs(sub:GetChildren()) do
                    local ss = ""
                    if subsub:IsA("StringValue") then
                        ss = " = \"" .. tostring(subsub.Value) .. "\""
                    elseif subsub:IsA("IntValue") or subsub:IsA("NumberValue") then
                        ss = " = " .. tostring(subsub.Value)
                    elseif subsub:IsA("BoolValue") then
                        ss = " = " .. tostring(subsub.Value)
                    elseif subsub:IsA("ModuleScript") then
                        ss = " [⚡MODULE]"
                    elseif subsub:IsA("Folder") then
                        ss = " [📂 " .. #subsub:GetChildren() .. " hijos]"
                    end
                    LogGUI(indent .. "      [" .. subsub.ClassName .. "] " .. subsub.Name .. ss, Color3.fromRGB(170, 170, 140))
                end
            end
        end
    end
end

-- Explorar cada NPC
local npcCount = 0
for _, npcFolder in pairs(DialoguesFolder:GetChildren()) do
    npcCount = npcCount + 1
    LogGUI("╔══════════════════════════════════════════╗", Color3.fromRGB(100, 255, 100))
    LogGUI("║ 🤖 NPC: " .. npcFolder.Name, Color3.fromRGB(100, 255, 100))
    LogGUI("║ 📂 Ruta: " .. npcFolder:GetFullName(), Color3.fromRGB(150, 150, 150))
    LogGUI("║ 📊 Hijos directos: " .. #npcFolder:GetChildren(), Color3.fromRGB(150, 150, 150))
    LogGUI("╚══════════════════════════════════════════╝", Color3.fromRGB(100, 255, 100))
    
    ExplorarInstancia(npcFolder, "   ", 0)
    LogGUI("", Color3.fromRGB(50, 50, 50))
    
    -- Pausa para no congelar el juego
    task.wait(0.1)
end

-- ==========================================
-- FASE 2: LISTAR TODOS LOS REMOTES EN DialogueEvents
-- ==========================================
LogGUI("\n============================================================", Color3.fromRGB(255, 200, 100))
LogGUI("  📡 REMOTES EN DialogueEvents", Color3.fromRGB(255, 200, 100))
LogGUI("============================================================\n", Color3.fromRGB(255, 200, 100))

local DialogueEvents = ReplicatedStorage:FindFirstChild("DialogueEvents")
if DialogueEvents then
    for _, remote in pairs(DialogueEvents:GetChildren()) do
        LogGUI("📡 [" .. remote.ClassName .. "] " .. remote.Name, Color3.fromRGB(200, 200, 200))
    end
else
    LogGUI("❌ No se encontró DialogueEvents", Color3.fromRGB(255, 50, 50))
end

-- ==========================================
-- FASE 3: BUSCAR RemoteEvents/Functions CON NOMBRE DE QUEST
-- ==========================================
LogGUI("\n============================================================", Color3.fromRGB(255, 150, 50))
LogGUI("  🔧 REMOTES DE QUEST/MISSION EN ReplicatedStorage", Color3.fromRGB(255, 150, 50))
LogGUI("============================================================\n", Color3.fromRGB(255, 150, 50))

local questKeywords = {"quest", "mission", "dialogue", "npc", "accept", "complete", "claim", "progress"}

for _, child in pairs(ReplicatedStorage:GetDescendants()) do
    if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") or child:IsA("BindableEvent") then
        local nameLower = string.lower(child.Name)
        for _, kw in pairs(questKeywords) do
            if string.find(nameLower, kw) then
                local icon = child:IsA("RemoteEvent") and "📡" or child:IsA("RemoteFunction") and "🔗" or "⚡"
                LogGUI(icon .. " [" .. child.ClassName .. "] " .. child:GetFullName(), Color3.fromRGB(255, 200, 100))
                break
            end
        end
    end
end

-- ==========================================
-- RESUMEN
-- ==========================================
LogGUI("\n============================================================", Color3.fromRGB(100, 255, 100))
LogGUI("  📊 RESUMEN", Color3.fromRGB(100, 255, 100))
LogGUI("============================================================", Color3.fromRGB(100, 255, 100))
LogGUI("🤖 NPCs con Diálogos encontrados: " .. npcCount, Color3.fromRGB(200, 200, 200))

-- GUARDAR FINAL
writefile("datos.txt", FullLogText)
LogGUI("\n[✔] datos.txt GUARDADO. Total: " .. #FullLogText .. " caracteres.", Color3.fromRGB(100, 255, 100))

LogGUI("[✔] Exploración completada.", Color3.fromRGB(100, 255, 100))
