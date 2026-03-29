-- ==============================================================================
-- 🎯 SNIFFER DE OPCIONES DE DIÁLOGO V1.0
-- ==============================================================================
-- Objetivo: Descubrir qué Remote usa el CLIENTE para enviar la opción elegida
-- al SERVIDOR cuando seleccionas "Lets Start", "Yes", etc. en un diálogo.
-- 100% PASIVO. CERO hooks. NO rompe interacciones.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- GUI
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "DialogSnifferUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DialogSnifferUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 100, 100)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -110, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 15, 15)
Title.Text = " 🎯 SNIFFER OPCIONES DIÁLOGO"
Title.TextColor3 = Color3.fromRGB(255, 100, 100)
Title.TextSize = 14
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

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
    MainFrame.Size = isMinimized and UDim2.new(0, 500, 0, 30) or UDim2.new(0, 500, 0, 350)
    OutputScroll.Visible = not isMinimized
end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local FullLog = "=== SNIFFER DE OPCIONES DE DIÁLOGO ===\n\n"
local HttpService = game:GetService("HttpService")
local saveCount = 0

local function LogGUI(text, color)
    FullLog = FullLog .. text .. "\n"
    saveCount = saveCount + 1
    if saveCount >= 10 then
        pcall(function() writefile("sniffer_dialogos.txt", FullLog) end)
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

local function SafeJSON(v)
    if type(v) == "table" then
        local ok, res = pcall(function() return HttpService:JSONEncode(v) end)
        if ok then return res end
        local s = "{"
        for k, val in pairs(v) do s = s .. tostring(k) .. "=" .. tostring(val) .. ", " end
        return s .. "}"
    elseif typeof(v) == "Instance" then
        return "[Instance] " .. v:GetFullName()
    else
        return "(" .. typeof(v) .. ") " .. tostring(v)
    end
end

-- ==========================================
-- SISTEMA NOCLIP + VUELO
-- ==========================================
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local isFlyingTo = false
local noclipConn = nil

local function BuscarNPC(nombre)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and string.lower(obj.Name) == string.lower(nombre) then
            local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChildWhichIsA("BasePart")
            if root then return root.Position end
        end
    end
    -- Buscar por ProximityPrompt con ObjectText
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj:FindFirstAncestorWhichIsA("Model")
            if parent and string.find(string.lower(parent.Name), string.lower(nombre)) then
                local root = parent:FindFirstChild("HumanoidRootPart") or parent:FindFirstChild("Torso") or parent:FindFirstChildWhichIsA("BasePart")
                if root then return root.Position end
            end
        end
    end
    return nil
end

local function IrHaciaNPC(targetPos, npcName)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then LogGUI("❌ Sin personaje", Color3.fromRGB(255, 50, 50)); return end
    if root:FindFirstChild("_NoclipSniffer") then root._NoclipSniffer:Destroy() end

    local bv = Instance.new("BodyVelocity")
    bv.Name = "_NoclipSniffer"
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Parent = root
    isFlyingTo = true

    if noclipConn then noclipConn:Disconnect() end
    noclipConn = RunService.Stepped:Connect(function()
        if not isFlyingTo then
            if noclipConn then noclipConn:Disconnect() end
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
            end
            return
        end
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end)

    LogGUI("✈️ Volando NOCLIP hacia " .. npcName .. "...", Color3.fromRGB(100, 255, 255))

    task.spawn(function()
        while isFlyingTo and bv.Parent and root.Parent do
            local dist = (root.Position - targetPos).Magnitude
            if dist < 5 then
                bv:Destroy()
                isFlyingTo = false
                LogGUI("✅ Llegaste a " .. npcName .. ". Presiona E.", Color3.fromRGB(100, 255, 100))
                break
            end
            local dir = (targetPos - root.Position).Unit
            bv.Velocity = dir * 65
            task.wait(0.05)
        end
    end)
end

-- ==========================================
-- BOTONES DE NPCs DE QUEST
-- ==========================================
local NPCsQuest = {
    {name = "Farmer",         pos = Vector3.new(-119.1, 21.4, -35.2),  tag = "⛏️ Mining"},
    {name = "Barakkulf",      pos = Vector3.new(26.0, 23.4, -37.9),    tag = "⚔️ Barakkulf"},
    {name = "Sensei Moro 2",  pos = Vector3.new(10.2, 23.8, -55.0),    tag = "📜 Moro2"},
    {name = "Goblin King",    pos = Vector3.new(79.1, 20.3, -335.7),   tag = "👑 GoblinK"},
    {name = "Masked Stranger",pos = Vector3.new(91.8, 74.9, -23.0),    tag = "🎭 Masked"},
    {name = "Captain Rowan",  pos = Vector3.new(14.9, 75.1, -70.3),    tag = "⚓ Rowan"},
}

local btnBar = Instance.new("Frame")
btnBar.Size = UDim2.new(1, -10, 0, 28)
btnBar.BackgroundTransparency = 1
btnBar.Parent = OutputScroll

local btnCount = 0
for _, npc in ipairs(NPCsQuest) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 75, 0, 24)
    btn.Position = UDim2.new(0, btnCount * 78, 0, 2)
    btn.BackgroundColor3 = Color3.fromRGB(40, 80, 160)
    btn.Text = npc.tag
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 9
    btn.Font = Enum.Font.Code
    btn.Parent = btnBar
    btnCount = btnCount + 1

    btn.MouseButton1Click:Connect(function()
        if isFlyingTo then
            isFlyingTo = false
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root and root:FindFirstChild("_NoclipSniffer") then root._NoclipSniffer:Destroy() end
            btn.BackgroundColor3 = Color3.fromRGB(40, 80, 160)
            return
        end
        -- Buscar posición actualizada del NPC en el mundo
        local pos = BuscarNPC(npc.name) or npc.pos
        btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        IrHaciaNPC(pos, npc.name)
        task.spawn(function()
            repeat task.wait(0.5) until not isFlyingTo
            if btn.Parent then btn.BackgroundColor3 = Color3.fromRGB(40, 80, 160) end
        end)
    end)
end

LogGUI("⬆️ Toca un botón para VOLAR con NOCLIP al NPC de quest.", Color3.fromRGB(100, 255, 255))

-- ==========================================
-- FASE 1: LISTAR TODOS LOS REMOTES EN DialogueEvents
-- ==========================================
LogGUI("============================================================", Color3.fromRGB(255, 100, 100))
LogGUI("  🔍 FASE 1: Mapeando DialogueEvents", Color3.fromRGB(255, 100, 100))
LogGUI("============================================================\n", Color3.fromRGB(255, 100, 100))

local DialogueEvents = ReplicatedStorage:FindFirstChild("DialogueEvents")
local totalRemotes = 0

if DialogueEvents then
    for _, child in pairs(DialogueEvents:GetDescendants()) do
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") or child:IsA("BindableEvent") or child:IsA("BindableFunction") then
            totalRemotes = totalRemotes + 1
            local icon = child:IsA("RemoteEvent") and "📡" or child:IsA("RemoteFunction") and "🔗" or "⚡"
            LogGUI(icon .. " [" .. child.ClassName .. "] " .. child:GetFullName(), Color3.fromRGB(255, 200, 100))
        end
    end
    LogGUI("\n[✔] Total Remotes en DialogueEvents: " .. totalRemotes, Color3.fromRGB(100, 255, 100))
else
    LogGUI("❌ DialogueEvents no encontrado!", Color3.fromRGB(255, 50, 50))
end

-- ==========================================
-- FASE 2: BUSCAR TODOS LOS REMOTES DE DIÁLOGO EN TODO EL JUEGO
-- ==========================================
LogGUI("\n============================================================", Color3.fromRGB(255, 200, 50))
LogGUI("  🔍 FASE 2: Buscando remotes de diálogo en TODO ReplicatedStorage", Color3.fromRGB(255, 200, 50))
LogGUI("============================================================\n", Color3.fromRGB(255, 200, 50))

local keywords = {"dialogue", "dialog", "quest", "npc", "conversation", "choice", "option", "respond", "answer", "select"}
local remotesEncontrados = {}

for _, child in pairs(ReplicatedStorage:GetDescendants()) do
    if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
        local nameLower = string.lower(child.Name)
        local pathLower = string.lower(child:GetFullName())
        for _, kw in pairs(keywords) do
            if string.find(nameLower, kw) or string.find(pathLower, kw) then
                local icon = child:IsA("RemoteEvent") and "📡" or "🔗"
                LogGUI(icon .. " " .. child:GetFullName(), Color3.fromRGB(200, 200, 200))
                table.insert(remotesEncontrados, child)
                break
            end
        end
    end
end
LogGUI("[✔] Total relevantes: " .. #remotesEncontrados, Color3.fromRGB(100, 255, 100))

-- ==========================================
-- FASE 3: CONECTAR ESCUCHA PASIVA A TODOS
-- ==========================================
LogGUI("\n============================================================", Color3.fromRGB(100, 200, 255))
LogGUI("  🎧 FASE 3: Escuchando TODOS los remotes de diálogo", Color3.fromRGB(100, 200, 255))
LogGUI("============================================================", Color3.fromRGB(100, 200, 255))
LogGUI("[!] AHORA ve al NPC, presiona E, y ELIGE UNA OPCIÓN.", Color3.fromRGB(255, 255, 50))
LogGUI("[!] Cada dato que el servidor mande aparecerá aquí.\n", Color3.fromRGB(255, 255, 50))

local conexiones = {}

-- Escuchar TODOS los RemoteEvents que encontramos
for _, remote in pairs(remotesEncontrados) do
    if remote:IsA("RemoteEvent") then
        local c = remote.OnClientEvent:Connect(function(...)
            local args = {...}
            task.spawn(function()
                LogGUI("\n🔴 ========== SERVER → CLIENTE ==========", Color3.fromRGB(255, 100, 100))
                LogGUI("📡 Remote: " .. remote.Name, Color3.fromRGB(255, 200, 100))
                LogGUI("📂 Ruta:   " .. remote:GetFullName(), Color3.fromRGB(200, 200, 200))
                LogGUI("📦 Args (" .. #args .. "):", Color3.fromRGB(255, 255, 150))
                for i, v in ipairs(args) do
                    LogGUI("   [" .. i .. "] " .. SafeJSON(v), Color3.fromRGB(220, 220, 220))
                end
                LogGUI("🔴 =========================================\n", Color3.fromRGB(255, 100, 100))
            end)
        end)
        table.insert(conexiones, c)
    end
end

-- También escuchar DialogueEvents directamente si tiene hijos adicionales
if DialogueEvents then
    for _, child in pairs(DialogueEvents:GetDescendants()) do
        if child:IsA("RemoteEvent") then
            local yaConectado = false
            for _, r in pairs(remotesEncontrados) do
                if r == child then yaConectado = true; break end
            end
            if not yaConectado then
                local c = child.OnClientEvent:Connect(function(...)
                    local args = {...}
                    task.spawn(function()
                        LogGUI("\n🟡 ========== SERVER → CLIENTE (EXTRA) ==========", Color3.fromRGB(255, 200, 50))
                        LogGUI("📡 Remote: " .. child.Name, Color3.fromRGB(255, 200, 100))
                        LogGUI("📂 Ruta:   " .. child:GetFullName(), Color3.fromRGB(200, 200, 200))
                        LogGUI("📦 Args (" .. #args .. "):", Color3.fromRGB(255, 255, 150))
                        for i, v in ipairs(args) do
                            LogGUI("   [" .. i .. "] " .. SafeJSON(v), Color3.fromRGB(220, 220, 220))
                        end
                        LogGUI("🟡 ================================================\n", Color3.fromRGB(255, 200, 50))
                    end)
                end)
                table.insert(conexiones, c)
            end
        end
    end
end

-- ==========================================
-- FASE 4: MONITOREAR PlayerGui PARA DETECTAR UI DE DIÁLOGO
-- ==========================================
LogGUI("\n[*] Monitoreando PlayerGui para detectar UI de diálogo...", Color3.fromRGB(255, 200, 50))

-- Buscar el DialogueUI y sus botones
task.spawn(function()
    while ScreenGui.Parent do
        local dialogueUI = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("DialogueUI")
        if dialogueUI then
            LogGUI("\n✅ [DETECTADO] DialogueUI está ABIERTO en pantalla!", Color3.fromRGB(100, 255, 100))
            
            -- Explorar su contenido
            for _, child in pairs(dialogueUI:GetDescendants()) do
                if child:IsA("TextButton") and child.Visible then
                    LogGUI("   🔘 Botón visible: \"" .. child.Text .. "\" [" .. child:GetFullName() .. "]", Color3.fromRGB(255, 255, 100))
                end
            end
            
            -- Esperar a que se cierre para no spamear
            repeat task.wait(0.5) until not dialogueUI.Parent or not ScreenGui.Parent
            if ScreenGui.Parent then
                LogGUI("❌ [CERRADO] DialogueUI se cerró.", Color3.fromRGB(255, 150, 150))
            end
        end
        task.wait(1)
    end
end)

-- Guardar al final
pcall(function() writefile("sniffer_dialogos.txt", FullLog) end)
LogGUI("\n[✔] Sniffer activo. Escuchando " .. #conexiones .. " remotes.", Color3.fromRGB(100, 255, 100))
LogGUI("[!] Ve al NPC → Presiona E → Elige opciones → Todo se grabará aquí.", Color3.fromRGB(255, 255, 50))
