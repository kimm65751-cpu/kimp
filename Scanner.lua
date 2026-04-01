-- ==============================================================================
-- 🕯️ DEMONOLOGY V2.0: OJO DE DIOS & NETWORK ANALYZER
-- Interfaz de Alto Nivel, Monitor de Red Ligero, Gestión de Archivos .txt
-- ==============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer

-- ==================== GUI MASTER (BLACK THEME) ====================
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LP:WaitForChild("PlayerGui")
for _, v in pairs(parentUI:GetChildren()) do if v.Name == "DemonologyHubPro" then v:Destroy() end end

local SG = Instance.new("ScreenGui")
SG.Name = "DemonologyHubPro"
SG.ResetOnSpawn = false
SG.Parent = parentUI

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 500, 0, 450)
Panel.Position = UDim2.new(0.5, -250, 0.5, -225)
Panel.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(180, 20, 20)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = SG

-- Título y Efectos
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 5, 5)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Panel

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = " 🕯️ DEMONOLOGY V21 | EXPERTO EN REDES "
Title.TextColor3 = Color3.fromRGB(255, 100, 100)
Title.Font = Enum.Font.Code
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 35, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(180, 150, 0)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.Code
MinBtn.TextSize = 14
MinBtn.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 20, 20)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.Code
CloseBtn.TextSize = 14
CloseBtn.Parent = TitleBar
CloseBtn.MouseButton1Click:Connect(function() SG:Destroy() end)

local minimizado = false
MinBtn.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    if minimizado then
        Panel.Size = UDim2.new(0, 500, 0, 30)
        Sidebar.Visible = false
        ConsoleBG.Visible = false
    else
        Panel.Size = UDim2.new(0, 500, 0, 450)
        Sidebar.Visible = true
        ConsoleBG.Visible = true
    end
end)

-- Zona de Botones (Izquierda)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 160, 1, -30)
Sidebar.Position = UDim2.new(0, 0, 0, 30)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Sidebar.BorderSizePixel = 1
Sidebar.BorderColor3 = Color3.fromRGB(100, 20, 20)
Sidebar.Parent = Panel

local function CreateUIBtn(yPos, text, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 35)
    b.Position = UDim2.new(0, 5, 0, yPos)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.fromRGB(230, 230, 230)
    b.Font = Enum.Font.Code
    b.TextSize = 11
    b.Parent = Sidebar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    return b
end

local BtnESP     = CreateUIBtn(10, "👁️ OJO DE DIOS (ESP)", Color3.fromRGB(50, 10, 40))
local BtnScan    = CreateUIBtn(50, "🔎 ESCANEAR FANTASMA", Color3.fromRGB(10, 40, 20))
local BtnMonitor = CreateUIBtn(90, "📡 ANALIZAR RED", Color3.fromRGB(10, 40, 60))

local Linea = Instance.new("Frame")
Linea.Size = UDim2.new(1, -10, 0, 1)
Linea.Position = UDim2.new(0, 5, 0, 140)
Linea.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
Linea.Parent = Sidebar

local BtnCopy    = CreateUIBtn(150, "📋 COPIAR LOGS", Color3.fromRGB(60, 60, 20))
local BtnSave    = CreateUIBtn(190, "💾 GUARDAR EN .TXT", Color3.fromRGB(20, 60, 20))
local BtnClear   = CreateUIBtn(230, "🗑️ LIMPIAR CONSOLA", Color3.fromRGB(60, 20, 20))

-- Zona "Pantalla Negra" de Consola (Derecha)
local ConsoleBG = Instance.new("Frame")
ConsoleBG.Size = UDim2.new(1, -170, 1, -40)
ConsoleBG.Position = UDim2.new(0, 165, 0, 35)
ConsoleBG.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ConsoleBG.BorderColor3 = Color3.fromRGB(0, 255, 100)
ConsoleBG.BorderSizePixel = 1
ConsoleBG.Parent = Panel
Instance.new("UICorner", ConsoleBG).CornerRadius = UDim.new(0, 4)

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -10, 1, -10)
LogScroll.Position = UDim2.new(0, 5, 0, 5)
LogScroll.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LogScroll.BorderSizePixel = 0
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogScroll.ScrollBarThickness = 5
LogScroll.Parent = ConsoleBG
Instance.new("UIListLayout", LogScroll).Padding = UDim.new(0, 2)

-- ==================== SISTEMA DE LOGS INTERNOS ====================
local InternalLogs = {} -- Para guardar en el .txt o portapapeles
local MaxLines = 150 -- Limitar visual para evitar lag
local LogCount = 0

local function LimpiarColor(texto)
    return tostring(texto)
end

local function RegistrarLog(fuente, mensaje, color)
    local msgCompleto = "[" .. string.upper(fuente) .. "] " .. tostring(mensaje)
    table.insert(InternalLogs, msgCompleto)
    
    LogCount = LogCount + 1
    
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, -4, 0, 0)
    txt.BackgroundTransparency = 1
    txt.Text = msgCompleto
    txt.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    txt.Font = Enum.Font.Code; txt.TextSize = 11
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.TextWrapped = true
    txt.Parent = LogScroll
    
    local ts = game:GetService("TextService"):GetTextSize(
        txt.Text, txt.TextSize, txt.Font, Vector2.new(LogScroll.AbsoluteSize.X - 15, 9999)
    )
    txt.Size = UDim2.new(1, -4, 0, ts.Y + 2)
    LogScroll.CanvasPosition = Vector2.new(0, 999999)
    
    -- Borrar logs antiguos si hay demasiados (Previene lag visual)
    if LogCount > MaxLines then
        local first = LogScroll:FindFirstChildWhichIsA("TextLabel")
        if first then first:Destroy() end
        LogCount = LogCount - 1
    end
end

RegistrarLog("SYS", "Consola Segura Iniciada. Prevención de Congelamientos: ON", Color3.fromRGB(0, 255, 100))

BtnClear.MouseButton1Click:Connect(function()
    InternalLogs = {}
    for _, v in pairs(LogScroll:GetChildren()) do
        if v:IsA("TextLabel") then v:Destroy() end
    end
    LogCount = 0
    RegistrarLog("SYS", "Consola Limpiada.", Color3.fromRGB(0, 255, 100))
end)

BtnCopy.MouseButton1Click:Connect(function()
    if setclipboard then
        local texto = table.concat(InternalLogs, "\n")
        setclipboard(texto)
        RegistrarLog("AVISO", "Logs copiados al Portapapeles exitosamente.", Color3.fromRGB(255, 255, 0))
    else
        RegistrarLog("ERROR", "Tu Ejecutor (Delta) falló al usar 'setclipboard'. Usa Guardar .TXT.", Color3.fromRGB(255, 50, 50))
    end
end)

BtnSave.MouseButton1Click:Connect(function()
    if writefile then
        local texto = table.concat(InternalLogs, "\n")
        local nombreArchivo = "Demonology_Analisis_" .. os.date("%H%M%S") .. ".txt"
        pcall(function()
            writefile(nombreArchivo, texto)
        end)
        RegistrarLog("AVISO", "Guardado físico como: " .. nombreArchivo .. " (Revisa carpeta 'workspace' de Delta)", Color3.fromRGB(0, 255, 255))
    else
        RegistrarLog("ERROR", "Tu Ejecutor no soporta 'writefile'.", Color3.fromRGB(255, 50, 50))
    end
end)

-- ==================== 1. OJO DE DIOS (ESP) ====================
local EspActivo = false
BtnESP.MouseButton1Click:Connect(function()
    EspActivo = not EspActivo
    if EspActivo then
        BtnESP.Text = "👁️ ESP: ON"
        BtnESP.BackgroundColor3 = Color3.fromRGB(120, 20, 40)
        RegistrarLog("ESP", "Buscando demonios en las paredes...", Color3.fromRGB(255, 150, 150))
        
        task.spawn(function()
            while EspActivo do
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj ~= LP.Character then
                        local isGhost = false
                        local nl = string.lower(obj.Name)
                        if nl == "ghost" or nl == "monster" or nl == "entity" or nl == "demon" then isGhost = true end
                        
                        local hum = obj:FindFirstChildWhichIsA("Humanoid")
                        if hum and not Players:GetPlayerFromCharacter(obj) then isGhost = true end
                        
                        if isGhost and not obj:FindFirstChild("_DemonESP") then
                            local hl = Instance.new("Highlight")
                            hl.Name = "_DemonESP"
                            hl.FillColor = Color3.fromRGB(255, 0, 0)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.3
                            hl.Parent = obj
                            RegistrarLog("ESP", "Capturado: " .. obj.Name .. " a " .. tostring(math.floor((obj:GetPivot().Position - LP.Character:GetPivot().Position).Magnitude)) .. "m", Color3.fromRGB(255, 50, 50))
                        end
                    end
                end
                task.wait(3)
            end
        end)
    else
        BtnESP.Text = "👁️ OJO DE DIOS (ESP)"
        BtnESP.BackgroundColor3 = Color3.fromRGB(50, 10, 40)
        RegistrarLog("ESP", "Desactivado y limpiando mapa.", Color3.fromRGB(150, 150, 150))
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name == "_DemonESP" then obj:Destroy() end
        end
    end
end)

-- ==================== 2. AUTO-SCANNER MEMORIA (MEMORY SCAN) ====================
BtnScan.MouseButton1Click:Connect(function()
    RegistrarLog("SCAN", "Escaneando Memoria RAM profunda (getgc)...", Color3.fromRGB(150, 255, 150))
    local hallado = false
    
    -- 1. Scan básico de atributos primero (para saber la habitación)
    for _, obj in pairs(Workspace:GetDescendants()) do
        local nl = string.lower(obj.Name)
        if nl == "ghost" or nl == "entity" then
            local favRoom = obj:GetAttribute("FavoriteRoom")
            if favRoom then
                RegistrarLog("SCAN", "📍 El fantasma habita en: " .. tostring(favRoom), Color3.fromRGB(0, 255, 255))
            end
        end
    end
    
    -- 2. Scan de Memoria vía Delta (Busca tablas creadas por los LocalScripts)
    if getgc then
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" then
                -- Buscar si la tabla guarda la identidad del fantasma o sus evidencias
                local fType = rawget(v, "GhostType") or rawget(v, "Type") or rawget(v, "Ghost")
                local hasEvi = rawget(v, "Evidence1") or rawget(v, "Evidence") or rawget(v, "Evidences")
                
                if fType and type(fType) == "string" and string.len(fType) > 2 then
                    -- Filtrar cosas que no sean fantasmas
                    if string.match(fType, "^%a+$") then
                        RegistrarLog("SCAN", "🔥 IDENTIDAD OCULTA ENCONTRADA: " .. tostring(fType), Color3.fromRGB(255, 0, 0))
                        hallado = true
                    end
                end
                
                if hasEvi and type(hasEvi) == "table" then
                    local eviStr = ""
                    for _, ev in pairs(hasEvi) do eviStr = eviStr .. tostring(ev) .. ", " end
                    if eviStr ~= "" then
                        RegistrarLog("SCAN", "📖 EVIDENCIAS EN MEMORIA: " .. eviStr, Color3.fromRGB(255, 255, 0))
                        hallado = true
                    end
                end
            end
        end
    else
        RegistrarLog("ERROR", "Tu ejecutor no soporta getgc() para leer la memoria profunda.", Color3.fromRGB(255, 50, 50))
    end
    
    if not hallado then
        RegistrarLog("SCAN", "El fantasma está completamente cifrado por el servidor y no envía su nombre hasta el final.", Color3.fromRGB(255, 150, 100))
        RegistrarLog("SCAN", "Usa la Habitación Favorita e intenta adivinarlo enviando un remoto con F9.", Color3.fromRGB(200, 200, 200))
    end
end)

-- ==================== 3. NETWORK SPY (ANTI-LAG) ====================
local MonitorActivo = false
local ConnectionCache = {}
local OriginalNamecall = nil

-- Filtro inteligente para NO congelar el PC.
-- Solo dejamos pasar palabras clave de economía, misiones y fantasmas.
local PALABRAS_CLAVE = {"Data", "Challenge", "Ghost", "Result", "Earn", "Money", "Exp", "Difficulty", "Save", "Fetch"}

local function EsImportante(nombre)
    local nl = string.lower(nombre)
    -- IGNORAR SÓLO EVENTOS MUY RUIDOSOS
    if string.find(nl, "mouse") or string.find(nl, "move") or string.find(nl, "sound") or string.find(nl, "step") or string.find(nl, "camera") then
        return false
    end
    -- Permitir TODO lo demás para no perdernos el paquete del diario
    return true
end

local function FormatearArgumentos(...)
    local args = {...}
    local str = ""
    for i, v in ipairs(args) do
        local vt = type(v)
        if vt == "table" then
            str = str .. "{table} "
        elseif vt == "userdata" then
            str = str .. "["..typeof(v).."] "
        else
            str = str .. tostring(v) .. " "
        end
        if i > 4 then str = str .. "..."; break end -- No procesar listas infinitas para evitar lag
    end
    if str == "" then return "(vacío)" end
    return str
end

BtnMonitor.MouseButton1Click:Connect(function()
    MonitorActivo = not MonitorActivo
    if MonitorActivo then
        BtnMonitor.Text = "📡 ANALIZADOR: ON"
        BtnMonitor.BackgroundColor3 = Color3.fromRGB(20, 100, 180)
        RegistrarLog("RED", "Interceptor de Paquetes ACTIVADO.", Color3.fromRGB(0, 200, 255))
        RegistrarLog("RED", "Escuchando: Economía, Retos, Resultados de Partida.", Color3.fromRGB(0, 150, 200))

        -- 1. Capturar C -> S (Client to Server) usando hookmetamethod
        if not getgenv().DaemonNetHook then
            getgenv().OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                if MonitorActivo and not checkcaller() then
                    local method = getnamecallmethod()
                    if method == "FireServer" or method == "InvokeServer" then
                        local rName = self.Name
                        if EsImportante(rName) then
                            -- Usar task.spawn para evitar retrasar el envío real del paquete
                            local argStr = FormatearArgumentos(...)
                            task.spawn(function()
                                local logStr = "["..method.."] " .. rName .. " | Args: " .. argStr
                                RegistrarLog("C->S", logStr, Color3.fromRGB(255, 150, 0))
                                
                                -- AUTO-GUARDADO DE EMERGENCIA PARA EVITAR PERDIDA POR TELEPORT
                                pcall(function()
                                    local current = ""
                                    pcall(function() current = readfile("Demonology_AutoSave_Red.txt") end)
                                    writefile("Demonology_AutoSave_Red.txt", current .. "\n" .. logStr)
                                end)
                            end)
                        end
                    end
                end
                return getgenv().OriginalNamecall(self, ...)
            end)
            getgenv().DaemonNetHook = true
        end

        -- 2. Capturar S -> C (Server to Client) monitoreando los Remotos de RS
        for _, rem in pairs(ReplicatedStorage:GetDescendants()) do
            if rem:IsA("RemoteEvent") and EsImportante(rem.Name) then
                local conn = rem.OnClientEvent:Connect(function(...)
                    if MonitorActivo then
                        local argStr = FormatearArgumentos(...)
                        RegistrarLog("S->C", "[Event] " .. rem.Name .. " | Res: " .. argStr, Color3.fromRGB(0, 255, 150))
                    end
                end)
                table.insert(ConnectionCache, conn)
            elseif rem:IsA("RemoteFunction") and EsImportante(rem.Name) then
                -- No podemos hookear OnClientInvoke tan fácil sin romper el juego, 
                -- pero los C->S (InvokeServer) ya los registramos arriba, y la respuesta 
                -- la recibimos ahí mismo en el namecall (aunque es complejo registrar el retorno exacto sin wrapper).
                -- Nos conformamos con los C->S para RemoteFunctions por ahora.
            end
        end

    else
        BtnMonitor.Text = "📡 ANALIZAR RED"
        BtnMonitor.BackgroundColor3 = Color3.fromRGB(10, 40, 60)
        RegistrarLog("RED", "Interceptor APAGADO. Limpiando conexiones...", Color3.fromRGB(150, 150, 150))
        for _, conn in ipairs(ConnectionCache) do pcall(function() conn:Disconnect() end) end
        ConnectionCache = {}
    end
end)
