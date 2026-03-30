-- ==============================================================================
-- ⛏️ MINING DEEP ANALYZER v1.0 — ANÁLISIS FORENSE DE MINERÍA
-- ==============================================================================
-- Análisis pasivo y completo de:
-- 1. Todas las minas del juego (nombre, vida, daño requerido)
-- 2. Tráfico Cliente↔Servidor (RemoteEvents/RemoteFunctions)
-- 3. Decompilación de scripts de minería
-- 4. Inspección de memoria (getgc) para variables internas
-- 5. Conexiones activas (getconnections)
-- 6. Timing entre golpes (cooldown detection)
-- 7. Auto-guardado en .txt
-- ==============================================================================

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CG = game:GetService("CoreGui")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

-- ============ ESTADO ============
local isMonitoring = false
local LOG = {}
local hookConnections = {}
local hitTimestamps = {}
local mineDataCache = {}
local remoteTraffic = {}
local MAX_LOG = 5000
local AUTO_SAVE_PATH = "MiningAnalysis_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"

-- ============ UI ============
local parentUI = pcall(function() return CG.Name end) and CG or PG
for _, v in pairs(parentUI:GetChildren()) do if v.Name == "MiningAnalyzerUI" then v:Destroy() end end

local SG = Instance.new("ScreenGui")
SG.Name = "MiningAnalyzerUI"; SG.ResetOnSpawn = false
SG.DisplayOrder = 1001; SG.Parent = parentUI

-- Panel Principal
local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 620, 0, 500)
Panel.Position = UDim2.new(1, -640, 0.5, -250)
Panel.BackgroundColor3 = Color3.fromRGB(12, 8, 18)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(80, 200, 255)
Panel.Active = true; Panel.Draggable = true
Panel.Parent = SG

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -35, 0, 28)
Title.BackgroundColor3 = Color3.fromRGB(10, 40, 80)
Title.Text = " ⛏️ MINING DEEP ANALYZER v1.0"
Title.TextColor3 = Color3.fromRGB(100, 220, 255)
Title.TextSize = 13; Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Panel

-- Botón cerrar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 28)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.Code; CloseBtn.TextSize = 14
CloseBtn.Parent = Panel

-- Barra de botones
local BtnBar = Instance.new("Frame")
BtnBar.Size = UDim2.new(1, -8, 0, 32)
BtnBar.Position = UDim2.new(0, 4, 0, 32)
BtnBar.BackgroundColor3 = Color3.fromRGB(18, 14, 25)
BtnBar.Parent = Panel

local function MakeBtn(name, text, color, pos)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = UDim2.new(0, 95, 0, 26)
    b.Position = UDim2.new(0, pos, 0, 3)
    b.BackgroundColor3 = color
    b.Text = text; b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.Code; b.TextSize = 10
    b.Parent = BtnBar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    return b
end

local ScanBtn = MakeBtn("Scan", "🔍 ESCANEAR", Color3.fromRGB(30, 100, 180), 4)
local MonitorBtn = MakeBtn("Monitor", "📡 MONITOR", Color3.fromRGB(30, 130, 50), 104)
local DecompBtn = MakeBtn("Decomp", "📜 DECOMPILE", Color3.fromRGB(130, 80, 30), 204)
local MemBtn = MakeBtn("Memory", "🧠 MEMORIA", Color3.fromRGB(100, 30, 130), 304)
local CopyBtn = MakeBtn("Copy", "📋 COPIAR", Color3.fromRGB(50, 50, 120), 404)
local SaveBtn = MakeBtn("Save", "💾 GUARDAR", Color3.fromRGB(120, 50, 50), 504)

-- Log area
local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -8, 1, -72)
LogScroll.Position = UDim2.new(0, 4, 0, 68)
LogScroll.BackgroundColor3 = Color3.fromRGB(8, 6, 12)
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogScroll.ScrollBarThickness = 6
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.Parent = Panel
Instance.new("UIListLayout", LogScroll).Padding = UDim.new(0, 1)

-- ============ AUTO-SAVE ============
local saveCounter = 0
local function AutoSave()
    pcall(function()
        writefile(AUTO_SAVE_PATH, table.concat(LOG, "\n"))
    end)
end

-- ============ LOG FUNCTIONS ============
local function AddLog(tag, msg, color)
    local fullStr = string.format("[%s] [%s] %s", os.date("%H:%M:%S"), tag, msg)
    table.insert(LOG, fullStr)
    if #LOG > MAX_LOG then table.remove(LOG, 1) end
    
    -- Auto-save cada 50 líneas
    saveCounter = saveCounter + 1
    if saveCounter >= 50 then
        saveCounter = 0
        task.defer(AutoSave)
    end
    
    task.defer(function()
        pcall(function()
            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1, -4, 0, 0)
            txt.BackgroundTransparency = 1
            txt.Text = fullStr
            txt.TextColor3 = color or Color3.fromRGB(200, 200, 200)
            txt.Font = Enum.Font.Code; txt.TextSize = 10
            txt.TextXAlignment = Enum.TextXAlignment.Left
            txt.TextWrapped = true
            txt.Parent = LogScroll
            local ts = game:GetService("TextService"):GetTextSize(
                txt.Text, txt.TextSize, txt.Font,
                Vector2.new(LogScroll.AbsoluteSize.X - 15, math.huge)
            )
            txt.Size = UDim2.new(1, -4, 0, ts.Y + 3)
            LogScroll.CanvasPosition = Vector2.new(0, 999999)
        end)
    end)
end

local function ClearLog()
    for _, v in pairs(LogScroll:GetChildren()) do
        if v:IsA("TextLabel") then v:Destroy() end
    end
end

local function Sep(title)
    AddLog("═══", string.rep("═", 50), Color3.fromRGB(80,200,255))
    AddLog("SEC", "▶ " .. title, Color3.fromRGB(80,200,255))
    AddLog("═══", string.rep("═", 50), Color3.fromRGB(80,200,255))
end

-- ============ SERIALIZER ============
local function Serialize(v, depth)
    depth = depth or 0
    if depth > 4 then return "..." end
    local t = typeof(v)
    if t == "string" then return '"'..v..'"'
    elseif t == "number" then return tostring(v)
    elseif t == "boolean" then return tostring(v)
    elseif t == "nil" then return "nil"
    elseif t == "Vector3" then return string.format("V3(%.1f,%.1f,%.1f)", v.X, v.Y, v.Z)
    elseif t == "CFrame" then return string.format("CF(%.1f,%.1f,%.1f)", v.Position.X, v.Position.Y, v.Position.Z)
    elseif t == "Instance" then return v:GetFullName()
    elseif t == "EnumItem" then return tostring(v)
    elseif t == "table" then
        local parts = {}
        local count = 0
        for k, val in pairs(v) do
            count = count + 1
            if count > 20 then table.insert(parts, "...+" .. (#{next(v,k)} > 0 and "more" or "0")); break end
            table.insert(parts, tostring(k) .. "=" .. Serialize(val, depth+1))
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    else
        return t .. ":" .. tostring(v)
    end
end

-- ==============================================================
-- 🔍 SCAN: Buscar TODAS las minas y objetos minables
-- ==============================================================
local function ScanMines()
    Sep("ESCANEO DE MINAS Y OBJETOS MINABLES")
    AddLog("SCAN", "Buscando minas en Workspace...", Color3.fromRGB(100,200,255))
    
    local mineCount = 0
    local keywords = {"mine", "ore", "rock", "node", "vein", "mineral", "deposit",
                       "mina", "piedra", "roca", "nodo", "coal", "iron", "gold",
                       "diamond", "crystal", "gem", "stone", "copper", "silver",
                       "mythril", "adamant", "emerald", "ruby", "sapphire"}
    
    -- Buscar en Workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        local nameLower = string.lower(obj.Name)
        local isMine = false
        
        for _, kw in pairs(keywords) do
            if string.find(nameLower, kw) then isMine = true; break end
        end
        
        -- También buscar por ClickDetector o ProximityPrompt
        if not isMine and (obj:FindFirstChildOfClass("ClickDetector") or 
                           obj:FindFirstChildOfClass("ProximityPrompt")) then
            -- Verificar si tiene atributos de vida/health
            local hasHP = false
            pcall(function()
                for _, attr in pairs(obj:GetAttributes()) do
                    if typeof(attr) == "number" then hasHP = true end
                end
            end)
            if hasHP then isMine = true end
        end
        
        if isMine then
            mineCount = mineCount + 1
            local info = {Name = obj.Name, Class = obj.ClassName, Path = obj:GetFullName()}
            
            -- Atributos
            pcall(function()
                local attrs = obj:GetAttributes()
                if next(attrs) then
                    info.Attributes = attrs
                    AddLog("MINE", string.format("📦 %s [%s]", obj.Name, obj.ClassName), Color3.fromRGB(255,200,50))
                    AddLog("ATTR", "  Ruta: " .. obj:GetFullName(), Color3.fromRGB(180,180,180))
                    for k, v in pairs(attrs) do
                        AddLog("ATTR", string.format("  → %s = %s (%s)", k, tostring(v), typeof(v)), Color3.fromRGB(200,255,100))
                    end
                end
            end)
            
            -- Propiedades de vida
            local hp = nil
            pcall(function() hp = obj:FindFirstChild("Health") or obj:FindFirstChild("HP") or obj:FindFirstChild("Vida") end)
            if hp then
                AddLog("HP", string.format("  ❤️ Health Object: %s = %s", hp.Name, tostring(hp.Value)), Color3.fromRGB(255,100,100))
            end
            
            -- Humanoid con vida
            local hum = obj:FindFirstChildOfClass("Humanoid")
            if hum then
                AddLog("HP", string.format("  ❤️ Humanoid: HP=%.0f/%.0f", hum.Health, hum.MaxHealth), Color3.fromRGB(255,100,100))
            end
            
            -- ClickDetector
            local cd = obj:FindFirstChildOfClass("ClickDetector")
            if cd then
                AddLog("CLICK", string.format("  🖱️ ClickDetector: MaxDist=%.0f", cd.MaxActivationDistance), Color3.fromRGB(150,255,150))
                -- Conexiones del ClickDetector
                pcall(function()
                    local conns = getconnections(cd.MouseClick)
                    AddLog("CONN", string.format("  🔗 MouseClick: %d conexiones", #conns), Color3.fromRGB(200,150,255))
                end)
            end
            
            -- ProximityPrompt
            local pp = obj:FindFirstChildOfClass("ProximityPrompt")
            if pp then
                AddLog("PROX", string.format("  📍 ProximityPrompt: '%s' Hold=%.1fs Dist=%.0f", 
                    pp.ActionText, pp.HoldDuration, pp.MaxActivationDistance), Color3.fromRGB(150,255,150))
            end
            
            -- Scripts dentro
            pcall(function()
                for _, s in pairs(obj:GetDescendants()) do
                    if s:IsA("LocalScript") or s:IsA("ModuleScript") then
                        AddLog("SCRIPT", string.format("  📜 %s [%s]", s.Name, s.ClassName), Color3.fromRGB(255,200,100))
                    end
                end
            end)
            
            mineDataCache[obj:GetFullName()] = info
        end
    end
    
    -- Buscar en ReplicatedStorage por módulos de minería
    Sep("MÓDULOS DE MINERÍA EN REPLICATED STORAGE")
    local moduleCount = 0
    for _, obj in pairs(RS:GetDescendants()) do
        local nameLower = string.lower(obj.Name)
        for _, kw in pairs(keywords) do
            if string.find(nameLower, kw) and (obj:IsA("ModuleScript") or obj:IsA("Folder")) then
                moduleCount = moduleCount + 1
                AddLog("MODULE", string.format("📂 %s [%s] → %s", obj.Name, obj.ClassName, obj:GetFullName()), 
                    Color3.fromRGB(200,150,255))
                
                -- Si es ModuleScript, intentar require
                if obj:IsA("ModuleScript") then
                    pcall(function()
                        local data = require(obj)
                        if typeof(data) == "table" then
                            local count = 0
                            for k, v in pairs(data) do
                                count = count + 1
                                if count <= 30 then
                                    AddLog("DATA", string.format("  → %s = %s", tostring(k), Serialize(v)), 
                                        Color3.fromRGB(180,220,255))
                                end
                            end
                            if count > 30 then
                                AddLog("DATA", string.format("  ... +%d más", count-30), Color3.fromRGB(150,150,150))
                            end
                        end
                    end)
                end
                break
            end
        end
    end
    
    -- Buscar REMOTES relacionados con minería
    Sep("REMOTES DE MINERÍA")
    local mineKeywords = {"mine", "ore", "rock", "pick", "hit", "damage", "swing",
                           "dig", "harvest", "break", "smash", "strike", "attack",
                           "tool", "drill", "gather", "resource", "node", "collect"}
    
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local nameLower = string.lower(obj.Name)
            local relevant = false
            for _, kw in pairs(mineKeywords) do
                if string.find(nameLower, kw) then relevant = true; break end
            end
            
            -- También incluir Knit remotes
            local fullName = obj:GetFullName()
            if string.find(string.lower(fullName), "mine") or
               string.find(string.lower(fullName), "pick") or
               string.find(string.lower(fullName), "tool") or
               string.find(string.lower(fullName), "resource") then
                relevant = true
            end
            
            if relevant then
                AddLog("REMOTE", string.format("📡 %s [%s] → %s", obj.Name, obj.ClassName, fullName),
                    Color3.fromRGB(255,150,100))
                
                -- Connections
                pcall(function()
                    if obj:IsA("RemoteEvent") then
                        local conns = getconnections(obj.OnClientEvent)
                        AddLog("CONN", string.format("  🔗 OnClientEvent: %d conexiones", #conns), Color3.fromRGB(200,150,255))
                        for _, conn in pairs(conns) do
                            pcall(function()
                                AddLog("CONN", "    → Function: " .. tostring(conn.Function), Color3.fromRGB(150,200,255))
                            end)
                        end
                    end
                end)
            end
        end
    end
    
    -- LISTAR TODOS los remotes (para referencia)
    Sep("TODOS LOS REMOTES (para referencia)")
    local allRemotes = 0
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            allRemotes = allRemotes + 1
            AddLog("ALL_R", string.format("  %s [%s] → %s", obj.Name, obj.ClassName, obj:GetFullName()),
                Color3.fromRGB(120,120,150))
        end
    end
    
    Sep("RESUMEN DE ESCANEO")
    AddLog("TOTAL", string.format("Minas encontradas: %d", mineCount), Color3.fromRGB(0,255,100))
    AddLog("TOTAL", string.format("Módulos de minería: %d", moduleCount), Color3.fromRGB(0,255,100))
    AddLog("TOTAL", string.format("Total remotes en juego: %d", allRemotes), Color3.fromRGB(0,255,100))
end

-- ==============================================================
-- 📡 MONITOR: Escuchar tráfico S→C de forma PASIVA
-- SIN hookmetamethod (no cuelga el juego)
-- Solo conecta OnClientEvent a los remotes
-- ==============================================================
local function StartMonitor()
    if isMonitoring then
        isMonitoring = false
        MonitorBtn.Text = "📡 MONITOR"
        MonitorBtn.BackgroundColor3 = Color3.fromRGB(30, 130, 50)
        AddLog("MON", "⏹️ Monitor DETENIDO", Color3.fromRGB(255,200,100))
        for _, conn in pairs(hookConnections) do
            pcall(function() conn:Disconnect() end)
        end
        hookConnections = {}
        AutoSave()
        return
    end
    
    isMonitoring = true
    MonitorBtn.Text = "⏹️ PARAR"
    MonitorBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 30)
    
    Sep("MONITOR PASIVO (S→C) — Sin hooks")
    AddLog("MON", "📡 Conectando a RemoteEvents (solo Server→Client)...", Color3.fromRGB(0,255,100))
    AddLog("MON", "💡 Empieza a minar! Verás lo que el servidor envía.", Color3.fromRGB(255,255,100))
    AddLog("MON", "💾 Auto-guarda en: " .. AUTO_SAVE_PATH, Color3.fromRGB(200,200,100))
    
    -- Conectar OnClientEvent a CADA RemoteEvent
    local connCount = 0
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local conn = obj.OnClientEvent:Connect(function(...)
                if not isMonitoring then return end
                local args = {...}
                local remoteName = obj.Name
                
                -- ⚡ FILTRO ANTI-SPAM: ignorar ReplicaSet con Stamina/Playtime
                if remoteName == "ReplicaSet" then
                    for _, arg in ipairs(args) do
                        if typeof(arg) == "table" then
                            for _, v in pairs(arg) do
                                local vs = tostring(v):lower()
                                if vs == "stamina" or vs == "playtime" or vs == "position" 
                                   or vs == "hunger" or vs == "thirst" then
                                    return -- SKIP spam
                                end
                            end
                        end
                    end
                end
                
                local now = tick()
                local lastHit = hitTimestamps[remoteName]
                local cooldown = lastHit and string.format("%.3fs", now - lastHit) or "FIRST"
                hitTimestamps[remoteName] = now
                
                table.insert(remoteTraffic, {
                    Time = os.date("%H:%M:%S"),
                    Tick = now,
                    Dir = "S→C",
                    Type = "Event",
                    Name = remoteName,
                    Path = obj:GetFullName(),
                    Args = args,
                    Cooldown = cooldown
                })
                
                AddLog("S→C", string.format("🔻 %s (cd:%s)", remoteName, cooldown), Color3.fromRGB(100,200,255))
                for i, arg in ipairs(args) do
                    if i <= 8 then
                        AddLog("ARG", string.format("  [%d] %s = %s", i, typeof(arg), Serialize(arg):sub(1,200)),
                            Color3.fromRGB(150,200,255))
                    end
                end
            end)
            table.insert(hookConnections, conn)
            connCount = connCount + 1
        end
    end
    
    AddLog("MON", string.format("✅ Conectado a %d RemoteEvents", connCount), Color3.fromRGB(0,255,100))
end

-- ==============================================================
-- 📜 DECOMPILE: Decompilar scripts de minería
-- ==============================================================
local function DecompileScripts()
    Sep("DECOMPILACIÓN DE SCRIPTS")
    
    local hasDecompile = pcall(function() return decompile end)
    if not hasDecompile then
        AddLog("ERR", "❌ decompile() no disponible en este executor", Color3.fromRGB(255,100,100))
        AddLog("TIP", "Ejecutores como Synapse/Script-Ware soportan decompile()", Color3.fromRGB(255,200,100))
        return
    end
    
    -- Buscar scripts de minería en PlayerGui
    AddLog("DEC", "Buscando scripts activos en PlayerGui...", Color3.fromRGB(255,200,100))
    for _, obj in pairs(PG:GetDescendants()) do
        if obj:IsA("LocalScript") then
            local nameLower = string.lower(obj.Name)
            AddLog("LSCRIPT", string.format("📜 %s → %s", obj.Name, obj:GetFullName()), Color3.fromRGB(200,200,100))
            
            pcall(function()
                local src = decompile(obj)
                if src and #src > 0 then
                    -- Buscar keywords de minería en el código
                    local mineKW = {"mine", "ore", "pick", "damage", "health", "hit",
                                    "swing", "tool", "cooldown", "delay", "dig", "resource",
                                    "node", "break", "durability", "power", "strength"}
                    local found = {}
                    for _, kw in pairs(mineKW) do
                        if string.find(string.lower(src), kw) then
                            table.insert(found, kw)
                        end
                    end
                    
                    if #found > 0 then
                        AddLog("MATCH", string.format("  ⚡ Keywords: %s", table.concat(found, ", ")), 
                            Color3.fromRGB(255,150,0))
                        -- Mostrar extracto relevante
                        local lines = string.split(src, "\n")
                        for i, line in ipairs(lines) do
                            for _, kw in pairs(mineKW) do
                                if string.find(string.lower(line), kw) then
                                    AddLog("CODE", string.format("  L%d: %s", i, line:sub(1,120)),
                                        Color3.fromRGB(180,255,180))
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
    
    -- Decompilar ModuleScripts de minería en RS
    AddLog("DEC", "Decompilando módulos de ReplicatedStorage...", Color3.fromRGB(255,200,100))
    local mineKW2 = {"mine", "ore", "pick", "tool", "resource", "node", "gather", "drill"}
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("ModuleScript") then
            local nameLower = string.lower(obj.Name)
            local relevant = false
            for _, kw in pairs(mineKW2) do
                if string.find(nameLower, kw) then relevant = true; break end
            end
            
            if relevant then
                AddLog("MODULE", string.format("📜 Decompilando: %s", obj:GetFullName()), Color3.fromRGB(200,150,255))
                pcall(function()
                    local src = decompile(obj)
                    if src then
                        local lines = string.split(src, "\n")
                        AddLog("CODE", string.format("  %d líneas de código", #lines), Color3.fromRGB(150,200,150))
                        -- Mostrar primeras 40 líneas
                        for i = 1, math.min(40, #lines) do
                            AddLog("CODE", string.format("  %d| %s", i, lines[i]:sub(1,100)), 
                                Color3.fromRGB(180,200,180))
                        end
                        if #lines > 40 then
                            AddLog("CODE", string.format("  ... +%d líneas más", #lines-40), Color3.fromRGB(150,150,150))
                        end
                    end
                end)
            end
        end
    end
    
    -- Decompilar scripts del Character (tool scripts)
    pcall(function()
        local char = LP.Character
        if char then
            Sep("SCRIPTS EN HERRAMIENTAS DEL PERSONAJE")
            for _, tool in pairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    AddLog("TOOL", string.format("🔨 Tool: %s", tool.Name), Color3.fromRGB(255,200,100))
                    for _, s in pairs(tool:GetDescendants()) do
                        if s:IsA("LocalScript") or s:IsA("ModuleScript") then
                            AddLog("TOOL", string.format("  📜 %s [%s]", s.Name, s.ClassName), Color3.fromRGB(200,200,100))
                            pcall(function()
                                local src = decompile(s)
                                if src then
                                    local lines = string.split(src, "\n")
                                    for i = 1, math.min(50, #lines) do
                                        AddLog("CODE", string.format("  %d| %s", i, lines[i]:sub(1,100)),
                                            Color3.fromRGB(180,200,180))
                                    end
                                end
                            end)
                        end
                    end
                end
            end
        end
    end)
    
    -- Backpack tools
    pcall(function()
        Sep("SCRIPTS EN BACKPACK (TOOLS)")
        for _, tool in pairs(LP.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                AddLog("TOOL", string.format("🎒 %s", tool.Name), Color3.fromRGB(255,200,100))
                -- Atributos del tool
                pcall(function()
                    local attrs = tool:GetAttributes()
                    for k, v in pairs(attrs) do
                        AddLog("ATTR", string.format("  → %s = %s (%s)", k, tostring(v), typeof(v)),
                            Color3.fromRGB(200,255,100))
                    end
                end)
                -- Decompile scripts
                for _, s in pairs(tool:GetDescendants()) do
                    if s:IsA("LocalScript") or s:IsA("ModuleScript") then
                        pcall(function()
                            local src = decompile(s)
                            if src then
                                local lines = string.split(src, "\n")
                                AddLog("CODE", string.format("  📜 %s (%d líneas)", s.Name, #lines), Color3.fromRGB(200,200,100))
                                for i = 1, math.min(50, #lines) do
                                    AddLog("CODE", string.format("  %d| %s", i, lines[i]:sub(1,100)),
                                        Color3.fromRGB(180,200,180))
                                end
                            end
                        end)
                    end
                end
            end
        end
    end)
end

-- ==============================================================
-- 🧠 MEMORY: getgc + inspección de memoria
-- ==============================================================
local function ScanMemory()
    Sep("INSPECCIÓN DE MEMORIA (getgc)")
    
    local hasGetGC = pcall(function() return getgc end)
    if not hasGetGC then
        AddLog("ERR", "❌ getgc() no disponible", Color3.fromRGB(255,100,100))
        return
    end
    
    AddLog("MEM", "Escaneando tablas y funciones en memoria...", Color3.fromRGB(200,150,255))
    
    local mineKW = {"mine", "ore", "pick", "damage", "health", "hit", "swing",
                     "tool", "cooldown", "node", "resource", "power", "durability",
                     "gather", "drill", "dig", "harvest", "strength", "attack"}
    
    local gcObjects = getgc(true)
    local foundTables = 0
    local foundFunctions = 0
    
    for _, obj in pairs(gcObjects) do
        -- Tablas con claves de minería
        if typeof(obj) == "table" then
            local hasKey = false
            local matchedKeys = {}
            
            pcall(function()
                for k, v in pairs(obj) do
                    local kStr = string.lower(tostring(k))
                    for _, kw in pairs(mineKW) do
                        if string.find(kStr, kw) then
                            hasKey = true
                            table.insert(matchedKeys, tostring(k) .. "=" .. Serialize(v))
                            break
                        end
                    end
                    if #matchedKeys >= 15 then break end
                end
            end)
            
            if hasKey and #matchedKeys > 0 then
                foundTables = foundTables + 1
                AddLog("TABLE", string.format("📊 Tabla #%d con %d keys de minería:", foundTables, #matchedKeys),
                    Color3.fromRGB(255,200,100))
                for _, entry in ipairs(matchedKeys) do
                    AddLog("KEY", "  → " .. entry:sub(1, 150), Color3.fromRGB(200,255,150))
                end
            end
        end
        
        -- Funciones — buscar en upvalues
        if typeof(obj) == "function" then
            pcall(function()
                local info = getinfo(obj)
                if info and info.source then
                    local srcLower = string.lower(info.source or "")
                    for _, kw in pairs(mineKW) do
                        if string.find(srcLower, kw) then
                            foundFunctions = foundFunctions + 1
                            AddLog("FUNC", string.format("⚙️ Función de minería: %s (line %s)", 
                                info.source:sub(1,80), tostring(info.currentline or "?")),
                                Color3.fromRGB(200,150,255))
                            
                            -- Upvalues
                            pcall(function()
                                local ups = getupvalues(obj)
                                if ups then
                                    for i, uv in pairs(ups) do
                                        AddLog("UPVAL", string.format("    ↑[%d] %s = %s", i, typeof(uv), Serialize(uv)),
                                            Color3.fromRGB(180,200,255))
                                    end
                                end
                            end)
                            
                            -- Constants
                            pcall(function()
                                local consts = getconstants(obj)
                                if consts then
                                    local strConsts = {}
                                    for _, c in pairs(consts) do
                                        if typeof(c) == "string" and #c > 2 then
                                            table.insert(strConsts, c)
                                        end
                                    end
                                    if #strConsts > 0 then
                                        AddLog("CONST", "    📝 Constants: " .. table.concat(strConsts, ", "):sub(1,150),
                                            Color3.fromRGB(180,220,255))
                                    end
                                end
                            end)
                            break
                        end
                    end
                end
            end)
        end
    end
    
    -- Knit controllers
    Sep("KNIT CONTROLLERS")
    pcall(function()
        local Knit = require(RS:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"))
        
        -- Listar todos los controllers
        pcall(function()
            local controllers = Knit.Controllers or {}
            for name, ctrl in pairs(controllers) do
                local nameLower = string.lower(name)
                local relevant = false
                for _, kw in pairs(mineKW) do
                    if string.find(nameLower, kw) then relevant = true; break end
                end
                
                if relevant then
                    AddLog("KNIT", string.format("🎮 Controller: %s", name), Color3.fromRGB(255,200,50))
                    for k, v in pairs(ctrl) do
                        AddLog("KNIT", string.format("  → %s = %s (%s)", tostring(k), Serialize(v):sub(1,100), typeof(v)),
                            Color3.fromRGB(200,230,255))
                    end
                else
                    AddLog("KNIT", string.format("  📋 %s (no minería)", name), Color3.fromRGB(120,120,150))
                end
            end
        end)
    end)
    
    AddLog("TOTAL", string.format("Tablas de minería: %d | Funciones: %d", foundTables, foundFunctions),
        Color3.fromRGB(0,255,100))
end

-- ==============================================================
-- ANÁLISIS DE COOLDOWN
-- ==============================================================
local function AnalyzeCooldowns()
    if #remoteTraffic < 2 then
        AddLog("CD", "Necesitas más datos de tráfico. Mina un rato primero.", Color3.fromRGB(255,200,100))
        return
    end
    
    Sep("ANÁLISIS DE COOLDOWNS")
    
    -- Agrupar por remote
    local groups = {}
    for _, entry in ipairs(remoteTraffic) do
        if not groups[entry.Name] then groups[entry.Name] = {} end
        table.insert(groups[entry.Name], entry.Tick)
    end
    
    for name, ticks in pairs(groups) do
        if #ticks >= 2 then
            local diffs = {}
            for i = 2, #ticks do
                table.insert(diffs, ticks[i] - ticks[i-1])
            end
            
            -- Stats
            local minCD = math.huge
            local maxCD = 0
            local sum = 0
            for _, d in ipairs(diffs) do
                minCD = math.min(minCD, d)
                maxCD = math.max(maxCD, d)
                sum = sum + d
            end
            local avgCD = sum / #diffs
            
            AddLog("CD", string.format("📊 %s (%d calls)", name, #ticks), Color3.fromRGB(255,200,100))
            AddLog("CD", string.format("  Min: %.3fs | Avg: %.3fs | Max: %.3fs", minCD, avgCD, maxCD),
                Color3.fromRGB(200,255,150))
            
            -- Detectar si es spam-able
            if minCD < 0.05 then
                AddLog("CD", "  ⚡ SPAMMEABLE: No hay cooldown server-side!", Color3.fromRGB(0,255,0))
            elseif minCD < 0.2 then
                AddLog("CD", "  🔶 Cooldown bajo, posible spam limitado", Color3.fromRGB(255,200,0))
            else
                AddLog("CD", string.format("  🔒 Cooldown fijo: ~%.2fs", avgCD), Color3.fromRGB(255,100,100))
            end
        end
    end
end

-- ============ BUTTON EVENTS ============
ScanBtn.MouseButton1Click:Connect(function() task.spawn(function() ScanMines(); AutoSave() end) end)
MonitorBtn.MouseButton1Click:Connect(function() task.spawn(StartMonitor) end)
DecompBtn.MouseButton1Click:Connect(function() task.spawn(function() DecompileScripts(); AutoSave() end) end)
MemBtn.MouseButton1Click:Connect(function() 
    task.spawn(function() ScanMemory(); AnalyzeCooldowns(); AutoSave() end)
end)

CopyBtn.MouseButton1Click:Connect(function()
    pcall(function()
        setclipboard(table.concat(LOG, "\n"))
        CopyBtn.Text = "✅ COPIADO!"
        task.delay(2, function() CopyBtn.Text = "📋 COPIAR" end)
    end)
end)

SaveBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local content = table.concat(LOG, "\n")
        writefile(AUTO_SAVE_PATH, content)
        SaveBtn.Text = "✅ GUARDADO!"
        AddLog("SAVE", "💾 Guardado en: " .. AUTO_SAVE_PATH, Color3.fromRGB(0,255,100))
        task.delay(2, function() SaveBtn.Text = "💾 GUARDAR" end)
    end)
end)

CloseBtn.MouseButton1Click:Connect(function()
    isMonitoring = false
    for _, conn in pairs(hookConnections) do pcall(function() conn:Disconnect() end) end
    SG:Destroy()
end)

-- Auto-save cada 2 minutos
task.spawn(function()
    while SG and SG.Parent do
        task.wait(120)
        if #LOG > 100 then
            pcall(function()
                writefile(AUTO_SAVE_PATH, table.concat(LOG, "\n"))
                AddLog("AUTO", "💾 Auto-guardado: " .. AUTO_SAVE_PATH, Color3.fromRGB(100,200,100))
            end)
        end
    end
end)

AddLog("SYS", "⛏️ MINING DEEP ANALYZER v1.0 CARGADO", Color3.fromRGB(100,220,255))
AddLog("SYS", "1. ESCANEAR = busca minas, módulos y remotes", Color3.fromRGB(180,180,180))
AddLog("SYS", "2. MONITOR = intercepta tráfico en vivo (mina algo!)", Color3.fromRGB(180,180,180))
AddLog("SYS", "3. DECOMPILE = lee código fuente de scripts", Color3.fromRGB(180,180,180))
AddLog("SYS", "4. MEMORIA = inspecciona getgc() y Knit controllers", Color3.fromRGB(180,180,180))
AddLog("SYS", "5. COPIAR/GUARDAR para no perder datos", Color3.fromRGB(180,180,180))
