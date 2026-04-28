--[[
╔══════════════════════════════════════════════════════════════╗
║  BLOXBURG JOB SCANNER v1.0 — Pasivo, No Intrusivo          ║
║  Toggle GUI: Tecla K | Minimizar con botón                  ║
║  Guarda todo en: BloxburgJobScan.txt                        ║
╚══════════════════════════════════════════════════════════════╝
]]

-- ═══ SERVICIOS ═══
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local SG = Instance.new("ScreenGui", game:GetService("CoreGui"))
SG.Name = "JobScanner"
SG.ResetOnSpawn = false

-- ═══ ESTADO ═══
local scanning = false
local guiVisible = true
local guiLogLines = {} -- Solo para GUI (últimas 60)
local logCount = 0
local totalEvents = 0
local connPool = {}
local lastPos = nil
local lastTool = ""
local scanStart = 0
local FILE = "BloxburgJobScan_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"

-- ═══ FILTRO DE RUIDO ═══
local lastScheduleLog = 0
local SCHEDULE_INTERVAL = 10 -- Solo loguear schedule cada 10 seg
local lastPosLog = 0
local POS_INTERVAL = 3 -- Solo loguear posición cada 3 seg
local lastPosValue = ""

local function IsNoise(cat, msg)
    if cat == "S→C" or cat == "S→C_NEW" then
        -- 1. activeScheduleLesson spam (1 cada 30s)
        if msg:find("activeScheduleLesson") then
            local now = tick()
            if now - lastScheduleLog < 30 then return true end
            lastScheduleLog = now
            return false
        end
        -- 2. Vehicle Springs/Speed telemetry
        if msg:find("Springs=") or msg:find("SpeedDelta=") then return true end
        -- 3. Wall/Plot construction de otros
        if msg:find("WallLength=") and msg:find("WallCFrame=") then return true end
        -- 4. Empty object streaming
        if msg:find("| {O={}, } |") or msg:match("| {O={[^}]*Spruce Tree") then return true end
        -- 5. Sound events de otros
        if msg:find("Sound=GroundSound") or msg:find("Sound=DriveSound") or msg:find("Sound=JumpSound") then return true end
        -- 6. Walls vacías
        if msg:find("| {Walls={}, } |") then return true end
        -- 7. Empty payload puro (solo si no tiene nada útil)
        if msg:match("| {} |$") then return false end -- Mantener: pueden ser confirmaciones de trabajo
    end
    return false
end

-- ═══ SERIALIZACIÓN RECURSIVA ═══
local function Ser(obj, d)
    d = d or 0
    if d > 4 then return "{...}" end
    if type(obj) == "table" then
        local s = "{"
        local c = 0
        for k, v in pairs(obj) do
            c = c + 1
            if c > 20 then s = s .. "..+" .. (c) .. "more, "; break end
            s = s .. tostring(k) .. "=" .. Ser(v, d+1) .. ", "
        end
        return s .. "}"
    elseif typeof(obj) == "Vector3" then
        return "V3(" .. math.floor(obj.X) .. "," .. math.floor(obj.Y) .. "," .. math.floor(obj.Z) .. ")"
    elseif typeof(obj) == "CFrame" then
        local p = obj.Position
        return "CF(" .. math.floor(p.X) .. "," .. math.floor(p.Y) .. "," .. math.floor(p.Z) .. ")"
    elseif typeof(obj) == "Instance" then
        return "Inst[" .. obj.ClassName .. "]:" .. obj:GetFullName()
    elseif typeof(obj) == "EnumItem" then
        return tostring(obj)
    end
    return tostring(obj)
end

-- ═══ LOG Y GUARDADO (SIN LÍMITE) ═══
local writeBuffer = ""
local bufferCount = 0

local function Log(cat, msg)
    -- Filtrar ruido
    if IsNoise(cat, msg) then
        totalEvents = totalEvents + 1
        return
    end
    
    logCount = logCount + 1
    totalEvents = totalEvents + 1
    local ts = os.date("%H:%M:%S")
    local elapsed = scanning and string.format("%.1f", tick() - scanStart) or "0"
    local line = "[" .. ts .. " +" .. elapsed .. "s] [" .. cat .. "] " .. msg
    
    -- Acumular en buffer de escritura
    writeBuffer = writeBuffer .. line .. "\n"
    bufferCount = bufferCount + 1
    
    -- Escribir al archivo cada 10 líneas (append real)
    if bufferCount >= 10 and appendfile then
        pcall(function()
            appendfile(FILE, writeBuffer)
        end)
        writeBuffer = ""
        bufferCount = 0
    elseif bufferCount >= 10 and writefile then
        -- Fallback: si no hay appendfile, usar writefile con acumulación
        pcall(function()
            local existing = ""
            if isfile and isfile(FILE) then
                existing = readfile(FILE)
            end
            writefile(FILE, existing .. writeBuffer)
        end)
        writeBuffer = ""
        bufferCount = 0
    end
    
    print(line)
end

local function SaveNow()
    if writeBuffer ~= "" then
        if appendfile then
            pcall(function() appendfile(FILE, writeBuffer) end)
        elseif writefile then
            pcall(function()
                local existing = ""
                if isfile and isfile(FILE) then
                    existing = readfile(FILE)
                end
                writefile(FILE, existing .. writeBuffer)
            end)
        end
        writeBuffer = ""
        bufferCount = 0
    end
end

-- ═══ FUNCIONES DE ANÁLISIS ═══
local function GetPlayerPos()
    local ch = LP.Character
    if ch and ch:FindFirstChild("HumanoidRootPart") then
        local p = ch.HumanoidRootPart.Position
        return math.floor(p.X) .. "," .. math.floor(p.Y) .. "," .. math.floor(p.Z)
    end
    return "?"
end

local function GetEquippedTool()
    local ch = LP.Character
    if ch then
        for _, c in ipairs(ch:GetChildren()) do
            if c:IsA("Tool") then return c.Name end
        end
    end
    return "none"
end

local function ScanModuleData(mod, path, depth)
    if depth > 2 then return end
    pcall(function()
        local data = require(mod)
        if type(data) == "table" then
            for k, v in pairs(data) do
                local t = type(v)
                if t == "function" then
                    Log("MODULE", path .. "." .. tostring(k) .. " = [function]")
                elseif t == "table" then
                    local count = 0
                    for _ in pairs(v) do count = count + 1 end
                    Log("MODULE", path .. "." .. tostring(k) .. " = [table:" .. count .. " keys]")
                else
                    Log("MODULE", path .. "." .. tostring(k) .. " = " .. Ser(v))
                end
            end
        end
    end)
end

-- ═══ ESCANEO DE ESTRUCTURA INICIAL ═══
local function ScanStructure()
    Log("SCAN", "══ INICIO: Estructura de ReplicatedStorage ══")
    Log("SCAN", "Posición inicial: " .. GetPlayerPos())

    -- DataService endpoints
    local ds = RS:FindFirstChild("Modules") and RS.Modules:FindFirstChild("DataService")
    if ds then
        Log("STRUCT", "DataService encontrado: " .. ds:GetFullName())
        local remotes = {}
        for _, child in ipairs(ds:GetDescendants()) do
            if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") or child:IsA("BindableEvent") then
                table.insert(remotes, {name=child.Name, class=child.ClassName, path=child:GetFullName()})
            end
        end
        Log("STRUCT", "DataService tiene " .. #remotes .. " endpoints de red")
        for i, r in ipairs(remotes) do
            if i <= 30 then
                Log("ENDPOINT", r.class .. " → " .. r.path)
            end
        end
        if #remotes > 30 then
            Log("ENDPOINT", "... y " .. (#remotes - 30) .. " más")
        end
    end

    -- Buscar RemoteEvents sueltos
    Log("STRUCT", "══ RemoteEvents en raíz de RS ══")
    for _, child in ipairs(RS:GetChildren()) do
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            Log("REMOTE", child.ClassName .. ": " .. child.Name)
        end
    end

    -- Escanear módulos clave
    local targets = {"JobData", "ObjectivesShared", "EventService", "InteractionData",
                     "ItemService", "StaminaService", "SkillData", "QuestService"}
    local mods = RS:FindFirstChild("Modules")
    if mods then
        for _, tName in ipairs(targets) do
            local m = mods:FindFirstChild(tName, true)
            if m and m:IsA("ModuleScript") then
                Log("SCAN", "── Escaneando módulo: " .. tName .. " ──")
                ScanModuleData(m, tName, 0)
            end
        end
    end

    -- _Data subfolder
    local dataFolder = mods and mods:FindFirstChild("_Data")
    if dataFolder then
        for _, tName in ipairs({"JobData", "SkillData"}) do
            local m = dataFolder:FindFirstChild(tName)
            if m and m:IsA("ModuleScript") then
                Log("SCAN", "── Escaneando _Data." .. tName .. " ──")
                ScanModuleData(m, "_Data." .. tName, 0)
            end
        end
    end

    SaveNow()
    Log("SCAN", "══ FIN estructura inicial ══")
end

-- ═══ CONECTAR LISTENERS PASIVOS ═══
local function StartListening()
    -- Limpiar conexiones previas
    for _, c in ipairs(connPool) do pcall(function() c:Disconnect() end) end
    connPool = {}

    -- 1) Escuchar TODOS los RemoteEvents en ReplicatedStorage
    for _, obj in ipairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local rName = obj.Name
            local conn = obj.OnClientEvent:Connect(function(...)
                if not scanning then return end
                local args = {...}
                local argStr = ""
                for i, a in ipairs(args) do
                    argStr = argStr .. Ser(a) .. " | "
                end
                local pos = GetPlayerPos()
                local tool = GetEquippedTool()
                Log("S→C", rName .. " @ pos=" .. pos .. " tool=" .. tool .. " | " .. argStr)
            end)
            table.insert(connPool, conn)
        end
    end
    Log("NET", "Conectado a " .. #connPool .. " RemoteEvents pasivos")

    -- 2) HOOK __namecall para interceptar FireServer/InvokeServer (C→S)
    local oldNamecall = nil
    pcall(function()
        local mt = getrawmetatable(game)
        if mt then
            local oldNC = mt.__namecall
            oldNamecall = oldNC
            if setreadonly then setreadonly(mt, false) end
            mt.__namecall = newcclosure(function(self, ...)
                if scanning then
                    local method = getnamecallmethod()
                    if method == "FireServer" or method == "InvokeServer" then
                        local args = {...}
                        task.spawn(function()
                            pcall(function()
                                local argStr = ""
                                for i, a in ipairs(args) do
                                    argStr = argStr .. Ser(a) .. " | "
                                end
                                local pos = GetPlayerPos()
                                local rName = "?"
                                pcall(function() rName = self.Name or self:GetFullName() end)
                                Log("C→S", method .. " " .. rName .. " @ pos=" .. pos .. " | " .. argStr)
                            end)
                        end)
                    end
                end
                return oldNC(self, ...)
            end)
            if setreadonly then setreadonly(mt, true) end
            Log("HOOK", "__namecall hook activo — capturando FireServer/InvokeServer")
        else
            Log("HOOK", "⚠ No se pudo hookear __namecall (sin getrawmetatable)")
        end
    end)
    if not oldNamecall then
        Log("HOOK", "⚠ Intentando hookear con hookmetamethod...")
        pcall(function()
            if hookmetamethod then
                oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                    if scanning then
                        local method = getnamecallmethod()
                        if method == "FireServer" or method == "InvokeServer" then
                            local args = {...}
                            task.spawn(function()
                                pcall(function()
                                    local argStr = ""
                                    for i, a in ipairs(args) do
                                        argStr = argStr .. Ser(a) .. " | "
                                    end
                                    local pos = GetPlayerPos()
                                    local rName = "?"
                                    pcall(function() rName = self.Name or self:GetFullName() end)
                                    Log("C→S", method .. " " .. rName .. " @ pos=" .. pos .. " | " .. argStr)
                                end)
                            end)
                        end
                    end
                    return oldNamecall(self, ...)
                end)
                Log("HOOK", "hookmetamethod activo — capturando FireServer/InvokeServer")
            end
        end)
    end

    -- 3) Monitorear posición SOLO cada 3 segundos (anti-spam)
    local posTimer = 0
    local posConn = RunService.Heartbeat:Connect(function(dt)
        if not scanning then return end
        posTimer = posTimer + dt
        if posTimer >= POS_INTERVAL then
            posTimer = 0
            local pos = GetPlayerPos()
            local tool = GetEquippedTool()
            if pos ~= lastPosValue then
                Log("POS", "Posición → " .. pos .. " tool=" .. tool)
                lastPosValue = pos
            end
            if tool ~= lastTool then
                Log("TOOL", "Herramienta: " .. lastTool .. " → " .. tool .. " @ " .. pos)
                lastTool = tool
            end
        end
    end)
    table.insert(connPool, posConn)

    -- 4) Monitorear cambios en el personaje (tools, backpack)
    local function watchChar(char)
        if not char then return end
        local addConn = char.ChildAdded:Connect(function(child)
            if not scanning then return end
            if child:IsA("Tool") then
                Log("EQUIP", "Tool equipada: " .. child.Name .. " @ " .. GetPlayerPos())
            end
        end)
        local remConn = char.ChildRemoved:Connect(function(child)
            if not scanning then return end
            if child:IsA("Tool") then
                Log("UNEQUIP", "Tool desequipada: " .. child.Name .. " @ " .. GetPlayerPos())
            end
        end)
        table.insert(connPool, addConn)
        table.insert(connPool, remConn)
    end
    if LP.Character then watchChar(LP.Character) end
    local charConn = LP.CharacterAdded:Connect(function(c)
        task.wait(0.5)
        watchChar(c)
        Log("CHAR", "Personaje respawneado @ " .. GetPlayerPos())
    end)
    table.insert(connPool, charConn)

    -- 5) Monitorear Backpack
    local bpConn = LP.Backpack.ChildAdded:Connect(function(child)
        if not scanning then return end
        if child:IsA("Tool") then
            Log("BACKPACK", "Nueva tool en mochila: " .. child.Name)
        end
    end)
    table.insert(connPool, bpConn)

    -- 6) Monitorear PlayerGui para cambios de UI de trabajo
    pcall(function()
        local pg = LP:WaitForChild("PlayerGui", 2)
        if pg then
            local guiConn = pg.DescendantAdded:Connect(function(desc)
                if not scanning then return end
                pcall(function()
                    local name = desc.Name:lower()
                    -- Detectar UI de trabajo
                    if name:find("job") or name:find("work") or name:find("task")
                       or name:find("objective") or name:find("skill")
                       or name:find("promote") or name:find("level")
                       or name:find("pay") or name:find("salary") then
                        Log("GUI_JOB", "UI apareció: " .. desc:GetFullName() .. " [" .. desc.ClassName .. "]")
                        if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                            Log("GUI_JOB", "  Text=" .. tostring(desc.Text))
                        end
                    end
                end)
            end)
            table.insert(connPool, guiConn)
            Log("GUI", "Monitoreando PlayerGui para UI de trabajo")
        end
    end)

    -- 7) Monitorear valores (IntValue, NumberValue, StringValue) bajo el jugador
    pcall(function()
        local function watchValue(val)
            if val:IsA("ValueBase") then
                local vConn = val.Changed:Connect(function(newVal)
                    if not scanning then return end
                    Log("VALUE", val:GetFullName() .. " = " .. tostring(newVal) .. " @ " .. GetPlayerPos())
                end)
                table.insert(connPool, vConn)
            end
        end
        -- Buscar valores existentes bajo el jugador
        for _, desc in ipairs(LP:GetDescendants()) do
            pcall(function() watchValue(desc) end)
        end
        -- Detectar nuevos valores
        local valConn = LP.DescendantAdded:Connect(function(desc)
            if not scanning then return end
            pcall(function()
                if desc:IsA("ValueBase") then
                    Log("NEW_VAL", "Nuevo valor: " .. desc:GetFullName() .. " = " .. tostring(desc.Value))
                    watchValue(desc)
                end
            end)
        end)
        table.insert(connPool, valConn)
        Log("VAL", "Monitoreando valores (IntValue/etc) bajo Player")
    end)

    -- 8) Monitorear atributos del jugador y personaje
    pcall(function()
        local attrConn = LP.AttributeChanged:Connect(function(attr)
            if not scanning then return end
            Log("ATTR", "Player." .. attr .. " = " .. tostring(LP:GetAttribute(attr)) .. " @ " .. GetPlayerPos())
        end)
        table.insert(connPool, attrConn)
        if LP.Character then
            local charAttr = LP.Character.AttributeChanged:Connect(function(attr)
                if not scanning then return end
                Log("ATTR", "Char." .. attr .. " = " .. tostring(LP.Character:GetAttribute(attr)) .. " @ " .. GetPlayerPos())
            end)
            table.insert(connPool, charAttr)
        end
        Log("ATTR", "Monitoreando atributos de Player y Character")
    end)

    -- 9) Monitorear nuevos RemoteEvents creados dinámicamente
    local newRemConn = RS.DescendantAdded:Connect(function(desc)
        if not scanning then return end
        if desc:IsA("RemoteEvent") then
            Log("NEW_RE", "Nuevo RemoteEvent creado: " .. desc:GetFullName())
            local c = desc.OnClientEvent:Connect(function(...)
                if not scanning then return end
                local args = {...}
                local argStr = ""
                for i, a in ipairs(args) do argStr = argStr .. Ser(a) .. " | " end
                Log("S→C_NEW", desc.Name .. " | " .. argStr)
            end)
            table.insert(connPool, c)
        end
    end)
    table.insert(connPool, newRemConn)
end

local function StopListening()
    for _, c in ipairs(connPool) do pcall(function() c:Disconnect() end) end
    connPool = {}
    SaveNow()
    Log("NET", "Todas las conexiones desconectadas. Archivo guardado.")
end

-- ═══ GUI MINIMALISTA ═══
local C = {bg = Color3.fromRGB(10,10,15), card = Color3.fromRGB(20,22,30),
           accent = Color3.fromRGB(60,130,255), green = Color3.fromRGB(40,200,100),
           red = Color3.fromRGB(220,60,60), text = Color3.fromRGB(220,225,240),
           muted = Color3.fromRGB(100,110,130)}

-- Mini botón flotante (siempre visible)
local MiniBtn = Instance.new("TextButton", SG)
MiniBtn.Size = UDim2.new(0,36,0,36)
MiniBtn.Position = UDim2.new(0,8,0.5,-18)
MiniBtn.BackgroundColor3 = C.accent
MiniBtn.Text = "🔍"
MiniBtn.TextSize = 18
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextColor3 = C.text
MiniBtn.BorderSizePixel = 0
MiniBtn.ZIndex = 10
local miniCorner = Instance.new("UICorner", MiniBtn)
miniCorner.CornerRadius = UDim.new(0,18)

-- Panel principal
local Panel = Instance.new("Frame", SG)
Panel.Size = UDim2.new(0,320,0,360)
Panel.Position = UDim2.new(0,50,0.5,-180)
Panel.BackgroundColor3 = C.bg
Panel.BorderSizePixel = 0
Panel.Visible = true
local panelCorner = Instance.new("UICorner", Panel)
panelCorner.CornerRadius = UDim.new(0,10)
local panelStroke = Instance.new("UIStroke", Panel)
panelStroke.Color = C.accent
panelStroke.Thickness = 1.5

-- Header
local Header = Instance.new("Frame", Panel)
Header.Size = UDim2.new(1,0,0,40)
Header.BackgroundColor3 = C.card
Header.BorderSizePixel = 0
local hCorner = Instance.new("UICorner", Header)
hCorner.CornerRadius = UDim.new(0,10)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1,-80,1,0)
Title.Position = UDim2.new(0,12,0,0)
Title.BackgroundTransparency = 1
Title.Text = "🔬 Job Scanner v1.2"
Title.TextColor3 = C.text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Botón minimizar
local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0,30,0,30)
MinBtn.Position = UDim2.new(1,-70,0,5)
MinBtn.BackgroundColor3 = Color3.fromRGB(50,50,60)
MinBtn.Text = "—"
MinBtn.TextColor3 = C.muted
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.BorderSizePixel = 0
local minC = Instance.new("UICorner", MinBtn)
minC.CornerRadius = UDim.new(0,6)

-- Botón cerrar
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0,30,0,30)
CloseBtn.Position = UDim2.new(1,-36,0,5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60,30,30)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = C.red
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
local clC = Instance.new("UICorner", CloseBtn)
clC.CornerRadius = UDim.new(0,6)

-- Status
local StatusLbl = Instance.new("TextLabel", Panel)
StatusLbl.Size = UDim2.new(0.92,0,0,20)
StatusLbl.Position = UDim2.new(0.04,0,0,46)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text = "⏹ Detenido"
StatusLbl.TextColor3 = C.muted
StatusLbl.Font = Enum.Font.GothamBold
StatusLbl.TextSize = 12
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left

-- Botón ANALIZAR
local function MakeBtn(parent, txt, yOff, col)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.92,0,0,34)
    b.Position = UDim2.new(0.04,0,0,yOff)
    b.BackgroundColor3 = col
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.BorderSizePixel = 0
    local bc = Instance.new("UICorner", b)
    bc.CornerRadius = UDim.new(0,8)
    return b
end

local BtnScan = MakeBtn(Panel, "📡 Escanear Estructura", 72, C.accent)
local BtnLive = MakeBtn(Panel, "▶ Iniciar Captura en Vivo", 112, C.green)
local BtnSave = MakeBtn(Panel, "💾 Guardar Ahora", 152, Color3.fromRGB(80,80,100))

-- Log display
local LogFrame = Instance.new("ScrollingFrame", Panel)
LogFrame.Size = UDim2.new(0.92,0,0,155)
LogFrame.Position = UDim2.new(0.04,0,0,194)
LogFrame.BackgroundColor3 = Color3.fromRGB(8,8,12)
LogFrame.BorderSizePixel = 0
LogFrame.ScrollBarThickness = 4
LogFrame.ScrollBarImageColor3 = C.accent
LogFrame.CanvasSize = UDim2.new(0,0,0,0)
LogFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
local lfC = Instance.new("UICorner", LogFrame)
lfC.CornerRadius = UDim.new(0,6)

local LogLayout = Instance.new("UIListLayout", LogFrame)
LogLayout.SortOrder = Enum.SortOrder.LayoutOrder
LogLayout.Padding = UDim.new(0,1)

local logOrder = 0
local function AddLogLine(text)
    logOrder = logOrder + 1
    local lbl = Instance.new("TextLabel", LogFrame)
    lbl.Size = UDim2.new(1,-8,0,14)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = C.muted
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.LayoutOrder = logOrder
    -- Limitar a 60 líneas visibles
    local kids = LogFrame:GetChildren()
    local labels = {}
    for _, k in ipairs(kids) do if k:IsA("TextLabel") then table.insert(labels, k) end end
    if #labels > 60 then labels[1]:Destroy() end
    LogFrame.CanvasPosition = Vector2.new(0, 99999)
end

-- Sobreescribir Log para también mostrar en GUI
local origLog = Log
Log = function(cat, msg)
    origLog(cat, msg)
    pcall(function()
        local short = "[" .. cat .. "] " .. msg
        if #short > 120 then short = short:sub(1,117) .. "..." end
        AddLogLine(short)
    end)
end

-- ═══ EVENTOS DE GUI ═══
MinBtn.MouseButton1Click:Connect(function()
    Panel.Visible = false
    guiVisible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    if scanning then StopListening() scanning = false end
    SG:Destroy()
end)

MiniBtn.MouseButton1Click:Connect(function()
    Panel.Visible = not Panel.Visible
    guiVisible = Panel.Visible
end)

BtnScan.MouseButton1Click:Connect(function()
    BtnScan.Text = "⏳ Escaneando..."
    BtnScan.BackgroundColor3 = C.muted
    StatusLbl.Text = "🔬 Analizando estructura..."
    StatusLbl.TextColor3 = C.accent
    task.spawn(function()
        ScanStructure()
        BtnScan.Text = "✅ Estructura Escaneada"
        BtnScan.BackgroundColor3 = Color3.fromRGB(30,100,60)
        StatusLbl.Text = "✅ Estructura lista. Inicia captura en vivo."
        StatusLbl.TextColor3 = C.green
    end)
end)

BtnLive.MouseButton1Click:Connect(function()
    scanning = not scanning
    if scanning then
        scanStart = tick()
        lastPos = GetPlayerPos()
        lastPosValue = lastPos
        lastTool = GetEquippedTool()
        logCount = 0
        totalEvents = 0
        StartListening()
        BtnLive.Text = "⏹ Detener Captura"
        BtnLive.BackgroundColor3 = C.red
        StatusLbl.Text = "🔴 CAPTURANDO — Ve a trabajar!"
        StatusLbl.TextColor3 = C.red
        Log("LIVE", "══ CAPTURA INICIADA ══ Pos:" .. lastPos .. " Tool:" .. lastTool)
        -- Contador en vivo en status
        task.spawn(function()
            while scanning do
                StatusLbl.Text = "🔴 Capturando: " .. logCount .. " guardados | " .. totalEvents .. " total (" .. (totalEvents - logCount) .. " filtrados)"
                task.wait(1)
            end
        end)
    else
        StopListening()
        BtnLive.Text = "▶ Iniciar Captura en Vivo"
        BtnLive.BackgroundColor3 = C.green
        StatusLbl.Text = "⏹ " .. logCount .. " eventos guardados. Archivo: " .. FILE
        StatusLbl.TextColor3 = C.muted
        Log("LIVE", "══ CAPTURA DETENIDA ══ Guardados: " .. logCount .. " | Total: " .. totalEvents .. " | Filtrados: " .. (totalEvents - logCount))
        SaveNow()
    end
end)

BtnSave.MouseButton1Click:Connect(function()
    SaveNow()
    BtnSave.Text = "✅ Guardado!"
    StatusLbl.Text = "💾 " .. FILE
    task.delay(2, function() BtnSave.Text = "💾 Guardar Ahora" end)
end)

-- ═══ TOGGLE CON TECLA K ═══
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.K then
        Panel.Visible = not Panel.Visible
        guiVisible = Panel.Visible
    end
end)

-- ═══ HACER GUI ARRASTRABLE ═══
local dragging, dragInput, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Panel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ═══ INICIO ═══
Log("INIT", "Job Scanner cargado. Presiona K para toggle. Archivo: " .. FILE)
Log("INIT", "1) Presiona 'Escanear Estructura' primero")
Log("INIT", "2) Luego 'Iniciar Captura en Vivo'")
Log("INIT", "3) Ve a cada trabajo y completa 1 tarea")
