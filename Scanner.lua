-- ==============================================================================
-- 🔬 FORGE X-RAY v5.0 — MONITOR PRECISO DE LOS 4 MINIJUEGOS
-- ==============================================================================
-- ❌ CERO hooks. CERO modificaciones. Juega 100% normal.
-- ✅ Monitorea Forge.MeltMinigame / PourMinigame / HammerMinigame por Visible
-- ✅ DescendantAdded para capturar círculos dinámicos (Juego 4 = Hammer circles)
-- ✅ Captura Water como animación, no juego
-- ✅ Logs a info5.txt automático
-- ==============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============ ARCHIVO ============
local FILE_PATH = "info5.txt"
local fileBuffer = {}
local fileBlockCount = 0

local function FlushToFile()
    if #fileBuffer == 0 then return end
    fileBlockCount = fileBlockCount + 1
    local content = table.concat(fileBuffer, "\n")
    pcall(function()
        if fileBlockCount == 1 then
            writefile(FILE_PATH, "=== FORGE X-RAY v5.0 === " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n\n" .. content .. "\n")
        else
            appendfile(FILE_PATH, "\n" .. content .. "\n")
        end
    end)
    fileBuffer = {}
end

local function LogToFile(text)
    table.insert(fileBuffer, text)
    if #fileBuffer >= 20 then FlushToFile() end
end

-- ============ UI PANEL ============
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or PlayerGui
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "XRayUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XRayUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = parentUI

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 560, 0, 400)
Panel.Position = UDim2.new(1, -580, 0.5, -200)
Panel.BackgroundColor3 = Color3.fromRGB(8, 4, 12)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(80, 180, 255)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 26)
Title.BackgroundColor3 = Color3.fromRGB(10, 40, 70)
Title.Text = " 🔬 X-RAY v5.0 | Melt·Pour·Hammer·Circles"
Title.TextColor3 = Color3.fromRGB(130, 210, 255)
Title.TextSize = 11
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Panel

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 26)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.Font = Enum.Font.Code
CloseBtn.TextSize = 14
CloseBtn.Parent = Panel
CloseBtn.MouseButton1Click:Connect(function() FlushToFile(); ScreenGui:Destroy() end)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -8, 0, 18)
StatusLabel.Position = UDim2.new(0, 4, 0, 28)
StatusLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
StatusLabel.Text = " Esperando forja..."
StatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
StatusLabel.TextSize = 10
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = Panel

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -8, 1, -80)
LogScroll.Position = UDim2.new(0, 4, 0, 50)
LogScroll.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogScroll.ScrollBarThickness = 5
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.Parent = Panel
Instance.new("UIListLayout", LogScroll).Padding = UDim.new(0, 1)

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(1, -8, 0, 24)
CopyBtn.Position = UDim2.new(0, 4, 1, -28)
CopyBtn.BackgroundColor3 = Color3.fromRGB(25, 70, 140)
CopyBtn.Text = "📋 COPIAR LOG"
CopyBtn.TextColor3 = Color3.fromRGB(255,255,255)
CopyBtn.Font = Enum.Font.Code
CopyBtn.TextSize = 11
CopyBtn.Parent = Panel

local MasterLog = {}
local logCount = 0

local function AddLog(tag, msg, clr)
    logCount = logCount + 1
    if logCount > 5000 then return end
    local full = "[" .. os.date("%H:%M:%S") .. "] [" .. tag .. "] " .. msg
    table.insert(MasterLog, full)
    LogToFile(full)
    task.defer(function()
        pcall(function()
            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1, -4, 0, 0)
            txt.BackgroundTransparency = 1
            txt.Text = full
            txt.TextColor3 = clr or Color3.fromRGB(190,190,190)
            txt.Font = Enum.Font.Code
            txt.TextSize = 9
            txt.TextXAlignment = Enum.TextXAlignment.Left
            txt.TextWrapped = true
            txt.Parent = LogScroll
            local ts = game:GetService("TextService")
            local s = ts:GetTextSize(txt.Text, txt.TextSize, txt.Font, Vector2.new(LogScroll.AbsoluteSize.X - 12, math.huge))
            txt.Size = UDim2.new(1, -4, 0, s.Y + 2)
            LogScroll.CanvasPosition = Vector2.new(0, 999999)
        end)
    end)
end

CopyBtn.MouseButton1Click:Connect(function()
    FlushToFile()
    if setclipboard then setclipboard(table.concat(MasterLog, "\n")); CopyBtn.Text = "✅ " .. #MasterLog .. " líneas" end
    task.delay(2, function() pcall(function() CopyBtn.Text = "📋 COPIAR LOG" end) end)
end)

-- ============ UTILIDADES ============
local function FP(v) return string.format("%.3f", v) end
local function DPos(o)
    local ok, p = pcall(function() return o.Position end)
    if ok then return "P(S" .. FP(p.X.Scale) .. "," .. FP(p.Y.Scale) .. " O" .. p.X.Offset .. "," .. p.Y.Offset .. ")" end
    return "P(?)"
end
local function DSz(o)
    local ok, s = pcall(function() return o.Size end)
    if ok then return "Sz(S" .. FP(s.X.Scale) .. "," .. FP(s.Y.Scale) .. " O" .. s.X.Offset .. "," .. s.Y.Offset .. ")" end
    return "Sz(?)"
end
local function DAbs(o)
    local ap, as = "?", "?"
    pcall(function() ap = math.floor(o.AbsolutePosition.X) .. "," .. math.floor(o.AbsolutePosition.Y) end)
    pcall(function() as = math.floor(o.AbsoluteSize.X) .. "x" .. math.floor(o.AbsoluteSize.Y) end)
    return "Abs(" .. ap .. ") " .. as
end

-- ============ FORGE GUI ============
local ForgeGui = nil
local MeltMG, PourMG, HammerMG = nil, nil, nil
local activeGame = ""
local trackedElements = {}

-- Esperar al Forge GUI
local function FindForge()
    ForgeGui = PlayerGui:FindFirstChild("Forge")
    if ForgeGui then
        MeltMG = ForgeGui:FindFirstChild("MeltMinigame")
        PourMG = ForgeGui:FindFirstChild("PourMinigame")
        HammerMG = ForgeGui:FindFirstChild("HammerMinigame")
        AddLog("INIT", "✅ Forge GUI encontrado. Melt=" .. tostring(MeltMG ~= nil) .. " Pour=" .. tostring(PourMG ~= nil) .. " Hammer=" .. tostring(HammerMG ~= nil), Color3.fromRGB(0, 255, 0))
        return true
    end
    return false
end

if not FindForge() then
    PlayerGui.ChildAdded:Connect(function(child)
        if child.Name == "Forge" then
            task.wait(0.5)
            FindForge()
        end
    end)
    AddLog("INIT", "⏳ Esperando Forge GUI...", Color3.fromRGB(255, 200, 50))
end

-- ============ TRACK PROPERTY CHANGES ============
local function TrackElement(obj, gameName)
    local key = tostring(obj) .. obj:GetFullName()
    if trackedElements[key] then return end
    trackedElements[key] = true
    
    local shortName = obj.Name
    
    -- Position
    pcall(function()
        obj:GetPropertyChangedSignal("Position"):Connect(function()
            AddLog("MOVE", "🔸 [" .. gameName .. "] " .. shortName .. " " .. DPos(obj) .. " " .. DAbs(obj), Color3.fromRGB(0, 220, 200))
        end)
    end)
    
    -- Size
    pcall(function()
        obj:GetPropertyChangedSignal("Size"):Connect(function()
            AddLog("SIZE", "📐 [" .. gameName .. "] " .. shortName .. " " .. DSz(obj) .. " " .. DAbs(obj), Color3.fromRGB(255, 255, 0))
        end)
    end)
    
    -- Visible
    pcall(function()
        obj:GetPropertyChangedSignal("Visible"):Connect(function()
            AddLog("VIS", "👁️ [" .. gameName .. "] " .. shortName .. " V=" .. tostring(obj.Visible), Color3.fromRGB(255, 150, 0))
        end)
    end)
    
    -- Rotation (para los círculos que aparecen)
    pcall(function()
        obj:GetPropertyChangedSignal("Rotation"):Connect(function()
            AddLog("ROT", "🔄 [" .. gameName .. "] " .. shortName .. " R=" .. FP(obj.Rotation), Color3.fromRGB(200, 100, 255))
        end)
    end)
    
    -- Text
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        pcall(function()
            local lastT = obj.Text
            obj:GetPropertyChangedSignal("Text"):Connect(function()
                if obj.Text ~= lastT then
                    lastT = obj.Text
                    AddLog("TEXT", "💬 [" .. gameName .. "] " .. shortName .. " → \"" .. string.sub(obj.Text, 1, 60) .. "\"", Color3.fromRGB(255, 255, 150))
                end
            end)
        end)
    end
    
    -- BackgroundColor3
    pcall(function()
        obj:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
            local c = obj.BackgroundColor3
            AddLog("CLR", "🎨 [" .. gameName .. "] " .. shortName .. " RGB(" .. math.floor(c.R*255) .. "," .. math.floor(c.G*255) .. "," .. math.floor(c.B*255) .. ")", Color3.fromRGB(100, 200, 255))
        end)
    end)
    
    -- BackgroundTransparency
    pcall(function()
        local lastBT = obj.BackgroundTransparency
        obj:GetPropertyChangedSignal("BackgroundTransparency"):Connect(function()
            if math.abs(obj.BackgroundTransparency - lastBT) > 0.05 then
                lastBT = obj.BackgroundTransparency
                AddLog("FADE", "🌫️ [" .. gameName .. "] " .. shortName .. " BgT=" .. FP(obj.BackgroundTransparency), Color3.fromRGB(150, 150, 255))
            end
        end)
    end)
    
    -- ImageTransparency
    if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
        pcall(function()
            local lastIT = obj.ImageTransparency
            obj:GetPropertyChangedSignal("ImageTransparency"):Connect(function()
                if math.abs(obj.ImageTransparency - lastIT) > 0.05 then
                    lastIT = obj.ImageTransparency
                    AddLog("IFADE", "🖼️ [" .. gameName .. "] " .. shortName .. " IT=" .. FP(obj.ImageTransparency), Color3.fromRGB(120, 120, 255))
                end
            end)
        end)
    end
end

-- ============ SNAPSHOT DE UN MINIJUEGO ============
local snapshotDone = {}

local function SnapshotGame(root, gameName)
    if snapshotDone[gameName] then return end
    snapshotDone[gameName] = true
    
    AddLog("SNAP", "══════ SNAPSHOT: " .. gameName .. " ══════", Color3.fromRGB(255, 200, 50))
    
    local desc = root:GetDescendants()
    AddLog("SNAP", "Total descendientes: " .. #desc, Color3.fromRGB(200, 200, 100))
    
    for _, obj in pairs(desc) do
        if obj:IsA("GuiObject") then
            local info = obj.Name .. " [" .. obj.ClassName .. "] V=" .. tostring(obj.Visible)
            pcall(function() info = info .. " " .. DPos(obj) .. " " .. DSz(obj) .. " " .. DAbs(obj) end)
            pcall(function()
                if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                    info = info .. " T=\"" .. string.sub(obj.Text, 1, 30) .. "\""
                end
            end)
            pcall(function()
                local c = obj.BackgroundColor3
                info = info .. " Bg=(" .. math.floor(c.R*255) .. "," .. math.floor(c.G*255) .. "," .. math.floor(c.B*255) .. ")"
            end)
            AddLog("EL", "  " .. info, Color3.fromRGB(170, 170, 200))
            
            -- Track cambios en este elemento
            TrackElement(obj, gameName)
        end
        
        -- Decompilar scripts encontrados
        if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            pcall(function()
                local src = decompile(obj)
                if src and #src > 10 then
                    LogToFile("\n===== DECOMPILE [" .. gameName .. "]: " .. obj:GetFullName() .. " =====")
                    local lc = 0
                    for line in string.gmatch(src, "[^\n]+") do
                        lc = lc + 1
                        LogToFile("  " .. line)
                        if lc > 500 then LogToFile("  ... TRUNCADO"); break end
                    end
                    LogToFile("===== FIN =====\n")
                    FlushToFile()
                    AddLog("DECOMPILE", "📜 " .. obj.Name .. " → " .. lc .. " líneas en info5.txt", Color3.fromRGB(255, 100, 255))
                end
            end)
        end
    end
    
    AddLog("SNAP", "══════ FIN " .. gameName .. " ══════", Color3.fromRGB(255, 200, 50))
    FlushToFile()
end

-- ============ MONITOREAR HIJOS DINÁMICOS (CÍRCULOS) ============
local function WatchForDynamicChildren(root, gameName)
    root.DescendantAdded:Connect(function(obj)
        local info = "➕ " .. obj.Name .. " [" .. obj.ClassName .. "]"
        pcall(function()
            if obj:IsA("GuiObject") then
                info = info .. " V=" .. tostring(obj.Visible) .. " " .. DPos(obj) .. " " .. DSz(obj) .. " " .. DAbs(obj)
                pcall(function()
                    local c = obj.BackgroundColor3
                    info = info .. " Bg=(" .. math.floor(c.R*255) .. "," .. math.floor(c.G*255) .. "," .. math.floor(c.B*255) .. ")"
                end)
                -- Track este nuevo elemento
                TrackElement(obj, gameName)
            end
        end)
        AddLog("NEW", info, Color3.fromRGB(0, 255, 100))
    end)
    
    root.DescendantRemoving:Connect(function(obj)
        if obj:IsA("GuiObject") then
            local info = "➖ " .. obj.Name .. " [" .. obj.ClassName .. "]"
            pcall(function() info = info .. " " .. DAbs(obj) end)
            AddLog("DEL", info, Color3.fromRGB(255, 80, 80))
        end
    end)
end

-- ============ DETECTAR CUANDO SE ACTIVA CADA JUEGO ============
local function SetupGameDetector(miniGameFrame, gameName)
    if not miniGameFrame then return end
    
    -- Cuando el frame se hace visible = juego empezó
    miniGameFrame:GetPropertyChangedSignal("Visible"):Connect(function()
        if miniGameFrame.Visible then
            activeGame = gameName
            StatusLabel.Text = " 🎮 JUGANDO: " .. gameName
            StatusLabel.BackgroundColor3 = Color3.fromRGB(50, 80, 20)
            AddLog("JUEGO", "🎮🎮🎮 " .. gameName .. " ACTIVADO 🎮🎮🎮", Color3.fromRGB(0, 255, 0))
            
            -- Tomar snapshot la primera vez
            task.spawn(function()
                task.wait(0.3) -- dar tiempo a que carguen hijos dinámicos
                SnapshotGame(miniGameFrame, gameName)
            end)
        else
            if activeGame == gameName then
                AddLog("JUEGO", "❌ " .. gameName .. " TERMINÓ", Color3.fromRGB(255, 100, 50))
                FlushToFile()
                activeGame = ""
                StatusLabel.Text = " ⏳ Esperando siguiente..."
                StatusLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
            end
        end
    end)
    
    -- Monitorear TODOS los hijos dinámicos (círculos del juego Hammer, etc.)
    WatchForDynamicChildren(miniGameFrame, gameName)
    
    -- PRE-track de elementos clave que ya existen
    for _, obj in pairs(miniGameFrame:GetDescendants()) do
        if obj:IsA("GuiObject") then
            TrackElement(obj, gameName)
        end
    end
    
    AddLog("SETUP", "✅ " .. gameName .. " monitoreado (" .. #miniGameFrame:GetDescendants() .. " desc)", Color3.fromRGB(100, 200, 100))
end

-- ============ SETUP DE TODO EL FORGE ============
local function SetupForgeMonitoring()
    if not ForgeGui then return end
    
    -- Monitorear los 3 minijuegos estáticos
    SetupGameDetector(MeltMG, "MELT")
    SetupGameDetector(PourMG, "POUR")
    SetupGameDetector(HammerMG, "HAMMER")
    
    -- Monitorear CUALQUIER hijo nuevo que aparezca en Forge (para Water u otros)
    ForgeGui.ChildAdded:Connect(function(child)
        AddLog("FORGE+", "📦 Nuevo hijo en Forge: " .. child.Name .. " [" .. child.ClassName .. "]", Color3.fromRGB(255, 200, 50))
        
        if child:IsA("Frame") or child:IsA("ScreenGui") then
            task.wait(0.5)
            -- Si es algo nuevo (no MeltMinigame/PourMinigame/HammerMinigame/EndScreen/OreSelect)
            local known = {MeltMinigame=1, PourMinigame=1, HammerMinigame=1, EndScreen=1, OreSelect=1}
            if not known[child.Name] then
                AddLog("FORGE+", "🆕 ELEMENTO DINÁMICO DETECTADO: " .. child.Name, Color3.fromRGB(255, 50, 255))
                SnapshotGame(child, "DYNAMIC_" .. child.Name)
                WatchForDynamicChildren(child, "DYNAMIC_" .. child.Name)
                
                if child:IsA("GuiObject") then
                    child:GetPropertyChangedSignal("Visible"):Connect(function()
                        AddLog("DYNVIS", "👁️ " .. child.Name .. " V=" .. tostring(child.Visible), Color3.fromRGB(255, 200, 100))
                    end)
                end
            end
        end
    end)
    
    ForgeGui.ChildRemoved:Connect(function(child)
        AddLog("FORGE-", "🗑️ Removido de Forge: " .. child.Name, Color3.fromRGB(255, 80, 80))
        FlushToFile()
    end)
    
    -- También monitorear descendientes NUEVOS de Forge completo
    ForgeGui.DescendantAdded:Connect(function(obj)
        -- Solo loguear cosas interesantes (ignorar UIStroke, UIGradient, etc.)
        if obj:IsA("Frame") or obj:IsA("ImageLabel") or obj:IsA("ImageButton") or obj:IsA("TextLabel") or obj:IsA("TextButton") then
            -- Solo si está DENTRO de un juego activo
            local parentName = ""
            pcall(function()
                local p = obj.Parent
                while p and p ~= ForgeGui do
                    if p.Name == "MeltMinigame" or p.Name == "PourMinigame" or p.Name == "HammerMinigame" then
                        parentName = p.Name
                        break
                    end
                    p = p.Parent
                end
            end)
            
            if parentName ~= "" then
                local info = "➕ " .. obj.Name .. " [" .. obj.ClassName .. "]"
                pcall(function()
                    info = info .. " " .. DPos(obj) .. " " .. DSz(obj) .. " " .. DAbs(obj)
                end)
                pcall(function()
                    if obj:IsA("Frame") then
                        local c = obj.BackgroundColor3
                        info = info .. " Bg=(" .. math.floor(c.R*255) .. "," .. math.floor(c.G*255) .. "," .. math.floor(c.B*255) .. ")"
                        info = info .. " BgT=" .. FP(obj.BackgroundTransparency)
                    end
                end)
                AddLog("CHILD+", "[" .. parentName .. "] " .. info, Color3.fromRGB(50, 255, 150))
                
                -- IMPORTANTE: Track changes en este nuevo hijo
                if obj:IsA("GuiObject") then
                    TrackElement(obj, parentName)
                end
            end
        end
    end)
end

-- ============ POLLING ForgeActive (LECTURA PASIVA) ============
local FC = nil
local lastForgeActive = nil

pcall(function()
    local Knit = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"))
    FC = Knit.GetController("ForgeController")
    if FC then
        AddLog("FC", "✅ ForgeController.ForgeActive = " .. tostring(FC.ForgeActive), Color3.fromRGB(0, 255, 0))
    end
end)

RunService.Heartbeat:Connect(function()
    if not ScreenGui.Parent then return end
    if not FC then return end
    
    local fa = nil
    pcall(function() fa = FC.ForgeActive end)
    if fa ~= nil and fa ~= lastForgeActive then
        lastForgeActive = fa
        if fa then
            AddLog("FC", "🔥 ForgeActive = TRUE", Color3.fromRGB(255, 50, 50))
        else
            AddLog("FC", "✅ ForgeActive = FALSE", Color3.fromRGB(0, 255, 0))
            FlushToFile()
        end
    end
end)

-- ============ LISTAR REMOTES ============
pcall(function()
    local fcFolder = ReplicatedStorage:FindFirstChild("Controllers")
    if fcFolder then
        fcFolder = fcFolder:FindFirstChild("ForgeController")
        if fcFolder then
            for _, d in pairs(fcFolder:GetDescendants()) do
                if d:IsA("RemoteFunction") or d:IsA("RemoteEvent") then
                    AddLog("REMOTE", "📡 " .. d.ClassName .. ": " .. d:GetFullName(), Color3.fromRGB(200, 200, 100))
                end
            end
        end
    end
    local knitSvc = ReplicatedStorage:FindFirstChild("Knit")
    if knitSvc then
        local svcs = knitSvc:FindFirstChild("Services")
        if svcs then
            for _, svc in pairs(svcs:GetChildren()) do
                if string.find(string.lower(svc.Name), "forge") then
                    for _, rf in pairs(svc:GetDescendants()) do
                        if rf:IsA("RemoteFunction") or rf:IsA("RemoteEvent") then
                            AddLog("REMOTE", "📡 " .. rf.ClassName .. ": " .. rf:GetFullName(), Color3.fromRGB(200, 200, 100))
                        end
                    end
                end
            end
        end
    end
end)

-- ============ GC SCAN ============
pcall(function()
    local found = 0
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" then
            for k, val in pairs(v) do
                local ks = tostring(k):lower()
                if ks == "forgeactive" or ks == "currentsequence" or ks == "meltbar" or ks == "pourbar" or ks == "hammerresult" or ks == "perfect" or ks == "score" then
                    found = found + 1
                    AddLog("GC", "🧠 " .. tostring(k) .. " = " .. tostring(val), Color3.fromRGB(200, 150, 255))
                    if found > 30 then break end
                end
            end
        end
        if found > 30 then break end
    end
    AddLog("GC", "Búsqueda GC: " .. found .. " hits", Color3.fromRGB(150, 150, 200))
end)

-- ============ INICIAR ============
task.spawn(function()
    -- Si Forge no existía al inicio, esperar
    if not ForgeGui then
        local tries = 0
        while not ForgeGui and tries < 60 do
            task.wait(1)
            FindForge()
            tries = tries + 1
        end
    end
    
    if ForgeGui then
        SetupForgeMonitoring()
    else
        AddLog("ERROR", "❌ Forge GUI no encontrado después de 60s", Color3.fromRGB(255, 0, 0))
    end
end)

-- Auto-flush
task.spawn(function()
    while ScreenGui.Parent do FlushToFile(); task.wait(3) end
end)

-- Monitorear PlayerGui
PlayerGui.ChildAdded:Connect(function(child)
    AddLog("GUI+", "📦 " .. child.Name .. " [" .. child.ClassName .. "]", Color3.fromRGB(255, 200, 100))
    if child.Name == "Forge" and not ForgeGui then
        task.wait(0.5)
        if FindForge() then SetupForgeMonitoring() end
    end
end)
PlayerGui.ChildRemoved:Connect(function(child)
    AddLog("GUI-", "🗑️ " .. child.Name, Color3.fromRGB(255, 80, 80))
    FlushToFile()
end)

AddLog("SYS", "🔬 X-RAY v5.0 LISTO. CERO hooks. Juega normal.", Color3.fromRGB(100, 255, 100))
AddLog("SYS", "Monitoreando: Forge.MeltMinigame / PourMinigame / HammerMinigame", Color3.fromRGB(100, 255, 100))
AddLog("SYS", "Círculos dinámicos se capturan via DescendantAdded", Color3.fromRGB(100, 255, 100))
AddLog("SYS", "info5.txt se guarda cada 3 seg. 📋 Botón para copiar.", Color3.fromRGB(100, 255, 100))
FlushToFile()
