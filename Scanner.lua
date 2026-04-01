-- ==============================================================================
-- 🕯️ DEMONOLOGY V4.0: SPEEDRUN & EVIDENCE ESP
-- Ojo de Dios, Localizador de Hueso/Malditos, y Analizador Físico de Entorno
-- ==============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer

-- ============================================================
-- INTERCEPTOR SILENCIOSO (Escucha el Diario del Jugador)
-- Mapeo de indice de objetivo a nombre de evidencia
-- Basdado en el orden exacto del diario visto en el juego
-- ============================================================
local EVI_MAP_IDX = {
    [1] = "Nivel EMF 5",
    [2] = "Huellas Dactilares",
    [3] = "Caja de Espíritus",
    [4] = "Orbe Fantasma",
    [5] = "Temperaturas Heladas",
    [6] = "Escritura de fantasmas",
    [7] = "Proyector láser",
    [8] = "Marchitar"
}

-- Tabla con evidencias; se llena aquí SIN necesitar GUI lista
local EvidenciasEncontradas = {}
local function RegistrarEvidencia(nombre)
    if nombre and not EvidenciasEncontradas[nombre] then
        EvidenciasEncontradas[nombre] = true
        -- ActualizarPizarraResolucion se llama después de que la GUI esté lista
        pcall(ActualizarPizarraResolucion)
    end
end

-- Hook silencioso de FireServer pre-GUI
if hookmetamethod then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            local n = string.lower(tostring(self.Name))
            local args = {...}
            
            -- OMNI-SPY: Atrapar y mostrar TODOS LOS PAQUETES DE RED (ignorando ruido)
            if not string.find(n, "move") and not string.find(n, "mouse") and not string.find(n, "sound") and not string.find(n, "cam") and not string.find(n, "step") then
                pcall(function()
                    local msg = ""
                    for i, a in pairs(args) do
                        if typeof(a) == "Instance" then msg = msg .. "[Inst: " .. a.Name .. "] "
                        else msg = msg .. "[" .. type(a) .. ": " .. tostring(a) .. "] " end
                    end
                    -- No repetir spam de chat
                    if not string.find(n, "chat") then
                        AddLog("🕵️ [C->S] " .. self.Name .. " -> " .. msg, Color3.fromRGB(150, 100, 255))
                    end
                end)
            end
            
            -- Detectar SelectEvidence / MarkEvidence del diario
            if string.find(n, "evidence") or string.find(n, "select") or string.find(n, "journal") or string.find(n, "mark") then
                pcall(function()
                    for _, a in pairs(args) do
                        local s = string.lower(tostring(a))
                        if string.find(s, "emf") then RegistrarEvidencia("Nivel EMF 5")
                        elseif string.find(s, "orb") then RegistrarEvidencia("Orbe Fantasma")
                        elseif string.find(s, "spirit") or string.find(s, "box") then RegistrarEvidencia("Caja de Espíritus")
                        elseif string.find(s, "writ") then RegistrarEvidencia("Escritura de fantasmas")
                        elseif string.find(s, "freez") or string.find(s, "cold") then RegistrarEvidencia("Temperaturas Heladas")
                        elseif string.find(s, "print") or string.find(s, "hand") then RegistrarEvidencia("Huellas Dactilares")
                        elseif string.find(s, "laser") or string.find(s, "lidar") then RegistrarEvidencia("Proyector láser")
                        elseif string.find(s, "wither") then RegistrarEvidencia("Marchitar")
                        end
                    end
                end)
            end
        elseif method == "InvokeServer" then
            local n = string.lower(tostring(self.Name))
            if string.find(n, "ghost") or string.find(n, "select") then
                -- Capturar la respuesta del server en remotefunction
                local ok, resultado = pcall(oldNamecall, self, ...)
                if ok and resultado then
                    pcall(function()
                        local s = string.lower(tostring(resultado))
                        AddLog("🏆 GetSelectedGhost RESPONDIO: " .. tostring(resultado), Color3.fromRGB(255, 215, 0))
                    end)
                    return resultado
                end
            end
        end
        return oldNamecall(self, ...)
    end)
end

-- ==================== GUI MASTER (SPEEDRUN THEME) ====================
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LP:WaitForChild("PlayerGui")
for _, v in pairs(parentUI:GetChildren()) do if v.Name == "DemonologySpeedrunPro" then v:Destroy() end end

local SG = Instance.new("ScreenGui")
SG.Name = "DemonologySpeedrunPro"
SG.ResetOnSpawn = false
SG.Parent = parentUI

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 500, 0, 400)
Panel.Position = UDim2.new(0.5, -250, 0.5, -200)
Panel.BackgroundColor3 = Color3.fromRGB(15, 18, 15)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(20, 180, 20)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = SG

-- Título y Efectos
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(5, 40, 5)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Panel

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = " ⏱️ DEMONOLOGY V4.0 | MODO SPEEDRUN & ESP "
Title.TextColor3 = Color3.fromRGB(100, 255, 100)
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

-- Zona de Botones (Izquierda)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 180, 1, -30)
Sidebar.Position = UDim2.new(0, 0, 0, 30)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 25, 20)
Sidebar.BorderSizePixel = 1
Sidebar.BorderColor3 = Color3.fromRGB(20, 100, 20)
Sidebar.Parent = Panel

local minimizado = false
MinBtn.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    if minimizado then
        Panel.Size = UDim2.new(0, 500, 0, 30)
        Sidebar.Visible = false
    else
        Panel.Size = UDim2.new(0, 500, 0, 400)
        Sidebar.Visible = true
    end
end)

local function CreateUIBtn(yPos, text, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 40)
    b.Position = UDim2.new(0, 5, 0, yPos)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.fromRGB(230, 230, 230)
    b.Font = Enum.Font.Code
    b.TextSize = 12
    b.Parent = Sidebar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    return b
end

local BtnESP       = CreateUIBtn(10,  "👁️ ESP FANTASMA", Color3.fromRGB(60, 10, 20))
local BtnItems     = CreateUIBtn(60,  "💎 ESP HUESO Y MALDITOS", Color3.fromRGB(60, 40, 10))
local BtnEvidence  = CreateUIBtn(110, "📖 SCAN DE EVIDENCIAS", Color3.fromRGB(10, 40, 60))
local BtnPing      = CreateUIBtn(160, "📡 PING GHOST & AUTO-LAB", Color3.fromRGB(150, 40, 0))
local BtnDump      = CreateUIBtn(210, "🕵️ HACKEAR MÓDULOS DE ITEMS", Color3.fromRGB(80, 0, 150))

-- Pizarra de Evidencias (Derecha)
local BoardBG = Instance.new("Frame")
BoardBG.Size = UDim2.new(1, -190, 1, -40)
BoardBG.Position = UDim2.new(0, 185, 0, 35)
BoardBG.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
BoardBG.BorderColor3 = Color3.fromRGB(100, 255, 100)
BoardBG.BorderSizePixel = 1
BoardBG.Parent = Panel
Instance.new("UICorner", BoardBG).CornerRadius = UDim.new(0, 4)

local BoardTitle = Instance.new("TextLabel")
BoardTitle.Size = UDim2.new(1, -70, 0, 25)
BoardTitle.Position = UDim2.new(0, 0, 0, 0)
BoardTitle.BackgroundTransparency = 1
BoardTitle.Text = " 📜 EVIDENCIAS / LOGS "
BoardTitle.TextColor3 = Color3.fromRGB(100, 255, 100)
BoardTitle.Font = Enum.Font.Code; BoardTitle.TextSize = 13
BoardTitle.TextXAlignment = Enum.TextXAlignment.Center
BoardTitle.Parent = BoardBG

local BtnCopy = Instance.new("TextButton")
BtnCopy.Size = UDim2.new(0, 70, 0, 20)
BtnCopy.Position = UDim2.new(1, -75, 0, 2)
BtnCopy.BackgroundColor3 = Color3.fromRGB(30, 80, 150)
BtnCopy.Text = "📋 Copiar"
BtnCopy.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnCopy.Font = Enum.Font.Code; BtnCopy.TextSize = 12
BtnCopy.Parent = BoardBG
Instance.new("UICorner", BtnCopy).CornerRadius = UDim.new(0, 4)

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -10, 1, -30)
LogScroll.Position = UDim2.new(0, 5, 0, 25)
LogScroll.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LogScroll.BorderSizePixel = 0
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogScroll.ScrollBarThickness = 5
LogScroll.Parent = BoardBG
Instance.new("UIListLayout", LogScroll).Padding = UDim.new(0, 4)

-- Base de Datos Oficial (Wiki de Demonology 2026)
local GHOST_DB = {
    ["Aswang"] = {"Marchitar", "Nivel EMF 5", "Escritura de fantasmas"},
    ["Banshee"] = {"Orbe Fantasma", "Huellas Dactilares", "Temperaturas Heladas"},
    ["Demon"] = {"Nivel EMF 5", "Huellas Dactilares", "Temperaturas Heladas"},
    ["Dullahan"] = {"Marchitar", "Proyector láser", "Temperaturas Heladas"},
    ["Dybbuk"] = {"Marchitar", "Huellas Dactilares", "Temperaturas Heladas"},
    ["Entity"] = {"Caja de Espíritus", "Huellas Dactilares", "Proyector láser"},
    ["Ghoul"] = {"Caja de Espíritus", "Temperaturas Heladas", "Orbe Fantasma"},
    ["Keres"] = {"Marchitar", "Huellas Dactilares", "Caja de Espíritus"},
    ["Leviathan"] = {"Orbe Fantasma", "Huellas Dactilares", "Escritura de fantasmas"},
    ["Nightmare"] = {"Nivel EMF 5", "Caja de Espíritus", "Orbe Fantasma"},
    ["Oni"] = {"Proyector láser", "Caja de Espíritus", "Temperaturas Heladas"},
    ["Phantom"] = {"Nivel EMF 5", "Huellas Dactilares", "Orbe Fantasma"},
    ["Revenant"] = {"Escritura de fantasmas", "Nivel EMF 5", "Temperaturas Heladas"},
    ["Siren"] = {"Marchitar", "Caja de Espíritus", "Nivel EMF 5"},
    ["Shadow"] = {"Nivel EMF 5", "Escritura de fantasmas", "Proyector láser"},
    ["Skinwalker"] = {"Temperaturas Heladas", "Escritura de fantasmas", "Caja de Espíritus"},
    ["Specter"] = {"Nivel EMF 5", "Temperaturas Heladas", "Proyector láser"},
    ["Spirit"] = {"Huellas Dactilares", "Escritura de fantasmas", "Caja de Espíritus"},
    ["The Wisp"] = {"Marchitar", "Proyector láser", "Orbe Fantasma"},
    ["Umbra"] = {"Orbe Fantasma", "Proyector láser", "Huellas Dactilares"},
    ["Vex"] = {"Marchitar", "Orbe Fantasma", "Temperaturas Heladas"},
    ["Wendigo"] = {"Orbe Fantasma", "Escritura de fantasmas", "Proyector láser"},
    ["Wraith"] = {"Nivel EMF 5", "Caja de Espíritus", "Proyector láser"}
}

local EvidenciasEncontradas = {}

local function AddLog(msg, color)
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, -4, 0, 0)
    txt.BackgroundTransparency = 1
    txt.Text = ">> " .. msg
    txt.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    txt.Font = Enum.Font.Code; txt.TextSize = 12
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.TextWrapped = true
    txt.Parent = LogScroll
    
    local ts = game:GetService("TextService"):GetTextSize(txt.Text, txt.TextSize, txt.Font, Vector2.new(LogScroll.AbsoluteSize.X - 15, 9999))
    txt.Size = UDim2.new(1, -4, 0, ts.Y + 4)
    LogScroll.CanvasPosition = Vector2.new(0, 999999)
end

BtnCopy.MouseButton1Click:Connect(function()
    local fullText = ""
    for _, v in ipairs(LogScroll:GetChildren()) do
        if v:IsA("TextLabel") then
            fullText = fullText .. v.Text .. "\n"
        end
    end
    if setclipboard then
        pcall(function() setclipboard(fullText) end)
        BtnCopy.Text = "¡Copiado!"
    else
        BtnCopy.Text = "Sin setclip"
    end
    task.delay(2, function() BtnCopy.Text = "📋 Copiar" end)
end)

local function ActualizarPizarraResolucion()
    for _, v in pairs(LogScroll:GetChildren()) do
        if v:IsA("TextLabel") then v:Destroy() end
    end
    
    local foundList = {}
    for ev, _ in pairs(EvidenciasEncontradas) do table.insert(foundList, ev) end
    
    AddLog("🔍 EVIDENCIAS DETECTADAS ("..#foundList.."/3)", Color3.fromRGB(255, 255, 0))
    for _, ev in ipairs(foundList) do AddLog("- " .. ev, Color3.fromRGB(255, 150, 0)) end
    
    AddLog("--------------------------------", Color3.fromRGB(100, 100, 100))
    AddLog("👻 FANTASMAS POSIBLES:", Color3.fromRGB(255, 0, 0))
    
    local posibles = 0
    local faltantes = {}
    
    for gName, gEvs in pairs(GHOST_DB) do
        local coincide = true
        for _, miEv in ipairs(foundList) do
            local tieneEsta = false
            for _, suEv in ipairs(gEvs) do
                if miEv == suEv then tieneEsta = true; break end
            end
            if not tieneEsta then coincide = false; break end
        end
        if coincide then
            posibles = posibles + 1
            AddLog(">> " .. gName, Color3.fromRGB(100, 255, 100))
            
            -- Recopilar evidencias que nos faltan buscar
            for _, suEv in ipairs(gEvs) do
                local yaLaTengo = false
                for _, miEv in ipairs(foundList) do
                    if miEv == suEv then yaLaTengo = true; break end
                end
                if not yaLaTengo then faltantes[suEv] = true end
            end
        end
    end
    
    if posibles == 1 then
        BoardTitle.Text = " 🏆 ¡FANTASMA DESCUBIERTO! "
        BoardTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
    else
        BoardTitle.Text = " 📜 RESOLVIENDO CASO... "
        BoardTitle.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        -- Sugerir herramientas
        AddLog("--------------------------------", Color3.fromRGB(100, 100, 100))
        AddLog("🛠️ VE AL CAMIÓN Y TRAE ESTO A: " .. (Workspace:FindFirstChild("Ghost") and Workspace.Ghost:GetAttribute("FavoriteRoom") or "Su Cuarto"), Color3.fromRGB(0, 255, 255))
        
        local tools = {
            ["Nivel EMF 5"] = "Lector EMF",
            ["Caja de Espíritus"] = "Spirit Box (Apaga la luz)",
            ["Escritura de fantasmas"] = "Libro (Déjalo en el piso)",
            ["Huellas Dactilares"] = "Linterna UV (Luz negra en puertas)",
            ["Temperaturas Heladas"] = "Termómetro",
            ["Proyector láser"] = "Proyector Láser D.O.T.S",
            ["Orbe Fantasma"] = "Cámara de Video (Modo Nocturno)",
            ["Marchitar"] = "Escáner LIDAR / Observar entorno"
        }
        
        for evFaltante, _ in pairs(faltantes) do
            local herramienta = tools[evFaltante] or evFaltante
            AddLog("☐ " .. herramienta, Color3.fromRGB(200, 200, 255))
        end
    end
end

-- Función AddLog fue movida hacia arriba para prevenir el error de 'nil call'

AddLog("Sistema Speedrun Activo.", Color3.fromRGB(0, 255, 100))
AddLog("Busca las evidencias en el mapa...", Color3.fromRGB(200, 200, 200))

-- ==================== FUNCIONES ESP CORE ====================
local function ApplyESPTag(obj, text, color, isEvidence)
    if not obj:FindFirstChild("_SR_Tag") then
        if not isEvidence then
            local hl = Instance.new("Highlight")
            hl.Name = "_SR_Tag"
            hl.FillColor = color
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.5
            hl.Parent = obj
        end
        
        local bgui = Instance.new("BillboardGui")
        bgui.Name = "_SR_Text"
        bgui.Size = UDim2.new(0, 150, 0, 40)
        bgui.AlwaysOnTop = true
        bgui.Parent = obj:FindFirstChildWhichIsA("BasePart") or obj
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = color
        lbl.TextStrokeTransparency = 0
        lbl.TextStrokeColor3 = Color3.new(0,0,0)
        lbl.TextScaled = true
        lbl.Font = Enum.Font.Bangers
        lbl.Parent = bgui
    end
end

local pingActivo = false
BtnPing.MouseButton1Click:Connect(function()
    pingActivo = not pingActivo
    if pingActivo then
        BtnPing.Text = "📡 PING: ON (DETECTANDO)"
        BtnPing.BackgroundColor3 = Color3.fromRGB(200, 50, 0)
        AddLog("[V6] INICIANDO INTERROGATORIO AL SERVIDOR...", Color3.fromRGB(255, 100, 0))
        
        -- Hook de respuestas del Servidor al Cliente (S -> C)
        for _, rem in pairs(game.ReplicatedStorage:GetDescendants()) do
            if rem:IsA("RemoteEvent") then
                rem.OnClientEvent:Connect(function(...)
                    if pingActivo then
                        local n = string.lower(rem.Name)
                        -- Ignorar SOLO ruido puro de movimiento y sonido
                        if not string.find(n, "playsound") and not string.find(n, "stopsound") and not string.find(n, "mousemove") then
                            local args = {...}
                            local msg = ""
                            for _, arg in pairs(args) do msg = msg .. tostring(arg) .. " " end
                            
                        -- -------------------------------------------------------------
                        -- 🔴 DEEP SPY (Analizador Integral de Logs)
                        -- -------------------------------------------------------------
                        -- Guardar automáticamente todo en un txt a nivel de exploit si writefile está habilitado.
                        pcall(function()
                            if writefile or appendfile then
                                local dumpText = "["..os.date("%X").."] " .. (rem and rem.Name or "UNKNOWN") .. " : " .. (msg or "N/A") .. "\n"
                                if appendfile then appendfile("OjoDeDios_DeepLog.txt", dumpText) 
                                elseif writefile and readfile then writefile("OjoDeDios_DeepLog.txt", readfile("OjoDeDios_DeepLog.txt") .. dumpText) end
                            end
                        end)
                        -- -------------------------------------------------------------
                        
                        -- ORO PURO: ObjectiveCompleted con numero -> mapear a evidencia
                        if string.find(n, "objective") then
                            AddLog("🏆 JACKPOT ["..rem.Name.."]: " .. msg, Color3.fromRGB(255, 215, 0))
                            local idx = tonumber(string.match(msg, "%d+"))
                            if idx and EvidenciasEncontradas then
                                local eviNombre = EVI_MAP_IDX[idx]
                                if eviNombre then
                                    AddLog("⭐ OBJETIVO "..idx.." = ".. eviNombre, Color3.fromRGB(255, 255, 0))
                                    EvidenciasEncontradas[eviNombre] = true
                                    pcall(ActualizarPizarraResolucion)
                                end
                            end
                        -- 🔥 TERMÓMETRO REMOTO: El servidor envía temperatura aunque no lo tengas
                        elseif string.find(n, "thermometerdisplay") then
                            local temp = tonumber(args[2]) or 99
                            if temp < 0 then
                                if not EvidenciasEncontradas["Temperaturas Heladas"] then
                                    AddLog("❄️ TEMPERATURA DETECTADA: " .. string.format("%.1f", temp) .. "°C", Color3.fromRGB(100, 200, 255))
                                    EvidenciasEncontradas["Temperaturas Heladas"] = true
                                    pcall(ActualizarPizarraResolucion)
                                end
                            end
                        -- 🔥 SPIRIT BOX: Los '####' en PostChatMessage = fantasma hablo por radio
                        elseif string.find(n, "chatmessage") or string.find(n, "chatbubble") then
                            if string.find(msg, "###") then
                                AddLog("🚨 SPIRIT BOX CONFIRMADA: El fantasma habló por Radio! [##]", Color3.fromRGB(255, 0, 200))
                                EvidenciasEncontradas["Caja de Espíritus"] = true
                                pcall(ActualizarPizarraResolucion)
                            end
                        -- EVIDENCIA directa por nombre
                        elseif string.find(n, "evidence") or string.find(n, "complete") or string.find(n, "reward") or string.find(n, "result") then
                            AddLog("🏆 JACKPOT ["..rem.Name.."]: " .. msg, Color3.fromRGB(255, 215, 0))
                        -- Aparatos de evidencia respondiendo
                        elseif string.find(n, "spirit") or string.find(n, "lidar") or string.find(n, "thermometer") or string.find(n, "emf") then
                            AddLog("🚨 RESPUESTA SERVIDOR ["..rem.Name.."]: " .. msg, Color3.fromRGB(255, 0, 0))
                        -- Cualquier otro evento (captura todo en azul)
                        else
                            AddLog(">> [S->C] " .. rem.Name .. ": " .. string.sub(msg, 1, 60), Color3.fromRGB(50, 150, 255))
                        end
                    end
                    end
                end)
            end
        end
        
        -- Inyectando engaños a los aparatos a distancia de forma contínua y fuerza bruta
        task.spawn(function()
            while pingActivo do
                task.wait(2)
                if not pingActivo then break end
                
                -- === AUTO-LABORATORIO: Equipa y activa cada herramienta ===
                local remEquip  = game.ReplicatedStorage:FindFirstChild("RequestItemEquip", true)
                local remToggle = game.ReplicatedStorage:FindFirstChild("ToggleItemState", true)
                local remDrop   = game.ReplicatedStorage:FindFirstChild("RequestItemDrop", true)
                local remPickup = game.ReplicatedStorage:FindFirstChild("RequestItemPickup", true)
                
                -- === AUTO-LABORATORIO V8.2: Gestión Real de Inventario ===
                local remEquip  = game.ReplicatedStorage:FindFirstChild("RequestItemEquip", true)
                local remToggle = game.ReplicatedStorage:FindFirstChild("ToggleItemState", true)
                local remDrop   = game.ReplicatedStorage:FindFirstChild("RequestItemDrop", true)
                local remPickup = game.ReplicatedStorage:FindFirstChild("RequestItemPickup", true)
                
                -- === AUTO-LABORATORIO V8.25: DRONE-TRACKING (Mover si el fantasma huye) ===
                local CS = game:GetService("CollectionService")
                
                -- Buscar origen biológico (Fantasma) primero
                local ghostPos = nil
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and (obj:GetAttribute("IsGhost") == true or string.find(string.lower(obj.Name), "ghost")) then
                        local part = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("ZoneCheckPart") or obj.PrimaryPart
                        if part then ghostPos = part.Position; break end
                    end
                end

                local todasHerramientas = CS:GetTagged("Item")
                local tomables = {}
                for _, obj in ipairs(todasHerramientas) do
                    -- Ignorar monedas, tickets de lotería o herramientas humanas ocupadas
                    if not obj:IsDescendantOf(game.Players) and (not obj.Parent or not obj.Parent:FindFirstChild("Humanoid")) then
                        local n = string.lower(obj.Name)
                        if n ~= "100" and not string.find(n, "coin") and not string.find(n, "ticket") and not string.find(n, "tarot") and not string.find(n, "ouija") then
                            -- Confirmar si la trampa ya está bien plantada cerca del monstruo
                            local isPlanted = false
                            if ghostPos then
                                local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                                if not p then
                                    for _, ch in pairs(obj:GetDescendants()) do
                                        if ch:IsA("BasePart") then p = ch; break end
                                    end
                                end
                                
                                if p and (p.Position - ghostPos).Magnitude <= 35 then
                                    isPlanted = true
                                end
                            end
                            
                            -- Si el arma está lejos, o el fantasma cambió de cuarto (roaming), la recogemos
                            if not isPlanted then
                                table.insert(tomables, obj)
                            end
                        end
                    end
                end
                
                if #tomables == 0 then
                    AddLog("━━━ ZONA TÁCTICA ASEGURADA. Bot durmiendo... ━━━", Color3.fromRGB(150, 255, 150))
                    task.wait(3)
                    -- No forzar fallback de inyección
                else
                    AddLog("━━━ DEMONOLOGY ZERO-DAY V8.25: " .. #tomables .. " OBJETIVOS ━━━", Color3.fromRGB(230, 255, 0))
                end
                
                for i, target in ipairs(tomables) do
                    if not pingActivo then break end
                    local n = type(target) == "string" and target or target.Name
                    AddLog("💀 ["..i.."] Secuestrando: " .. n, Color3.fromRGB(200, 100, 0))
                    
                    local remDrop = game.ReplicatedStorage.Events:FindFirstChild("RequestItemDrop")
                    local remChange = game.ReplicatedStorage.Events:FindFirstChild("ChangeSelectedItem")
                    local remEquipRemote = game.ReplicatedStorage.Events:FindFirstChild("RequestItemEquip")
                    local remToggle = game.ReplicatedStorage.Events:FindFirstChild("ToggleItemState")
                    
                    -- ==========================================
                    -- 0. VACIADOR BLINDADO (El servidor exige equipar antes de tirar)
                    -- ==========================================
                    local function GetFreeSlot()
                        for _i=1, 3 do
                            if not LP:GetAttribute("InvSlot" .. _i) or LP:GetAttribute("InvSlot" .. _i) == "" then return "InvSlot".._i end
                        end
                        return nil
                    end
                    
                    if not GetFreeSlot() then
                        for _i=1, 3 do
                            local slotName = "InvSlot" .. _i
                            local val = LP:GetAttribute(slotName)
                            if val and val ~= "" and not string.find(string.lower(val), "journal") then
                                pcall(function()
                                    if remChange then remChange:FireServer(slotName) end
                                    task.wait(0.2)
                                    if remDrop then remDrop:FireServer(slotName) end
                                end)
                                task.wait(0.2)
                            end
                        end
                    end

                    -- Capturar memoria de inventario ANTES de recoger
                    local memAntes = {}
                    for _i=1, 3 do memAntes["InvSlot".._i] = LP:GetAttribute("InvSlot".._i) end

                    -- 1. Intentar recoger objetivo real
                    if remPickup then 
                        pcall(function() remPickup:FireServer(target) end)
                    end
                    
                    -- Esperar a que un Slot CAMBIE (diferente a memAntes)
                    local filledSlot = nil
                    local capturedItemName = nil
                    for timer = 1, 15 do
                        for _i=1, 3 do
                            local val = LP:GetAttribute("InvSlot".._i)
                            if val and val ~= "" and val ~= memAntes["InvSlot".._i] and not string.find(string.lower(val), "journal") then
                                filledSlot = "InvSlot".._i
                                capturedItemName = val
                                break
                            end
                        end
                        if filledSlot then break end
                        task.wait(0.1)
                    end
                    
                    if filledSlot and capturedItemName then
                        -- 2. Equipar
                        pcall(function()
                            if remChange then remChange:FireServer(filledSlot) end
                            if remEquipRemote then remEquipRemote:FireServer(filledSlot) end
                        end)
                        
                        -- Esperar a que el servidor confirme que lo tenemos en mano
                        local materializado = false
                        for timer = 1, 15 do
                            if LP:GetAttribute("EquippedObject") == capturedItemName then
                                materializado = true
                                break
                            end
                            task.wait(0.1)
                        end
                        
                        if materializado then
                            -- 3. Buscar la réplica física local
                            local itemFalso = nil
                            if LP.Character then
                                for _, v in pairs(LP.Character:GetChildren()) do
                                    if pcall(function() return v:HasTag("Item") end) and v:HasTag("Item") then
                                        itemFalso = v
                                        break
                                    end
                                    if v:IsA("Model") and not v:FindFirstChild("Humanoid") and not string.find(string.lower(v.Name), "journal") then
                                        itemFalso = v
                                    end
                                end
                            end
                            
                            if itemFalso then
                                AddLog("   └─> ¡MATERIALIZADO Y ACTIVO!: " .. capturedItemName, Color3.fromRGB(150, 255, 150))
                                task.wait(0.5) -- Esperar a que el motor local amarre la heramienta a la mano
                                
                                -- Forzar Encendido (Hardware Level) - Doble pulso para asegurar
                                pcall(function()
                                    if remToggle then remToggle:FireServer() end
                                    local vim = game:GetService("VirtualInputManager")
                                    vim:SendMouseButtonEvent(0, 0, 1, true, game, 1)
                                    task.wait(0.1)
                                    vim:SendMouseButtonEvent(0, 0, 1, false, game, 1)
                                    task.wait(0.2)
                                    vim:SendMouseButtonEvent(0, 0, 1, true, game, 1)
                                    task.wait(0.1)
                                    vim:SendMouseButtonEvent(0, 0, 1, false, game, 1)
                                    -- Auto-guardado en log para el Deep Spy de uso de herramientas
                                    if appendfile then appendfile("OjoDeDios_DeepLog.txt", "["..os.date("%X").."] TOOL_USED (Virtual D-Click): " .. capturedItemName .. "\n") end
                                end)
                                task.wait(1.5)
                                
                                -- Buscar centro de masa del fantasma
                                local ghostPos = nil
                                for _, g_obj in pairs(workspace:GetDescendants()) do
                                    if g_obj:IsA("Model") and (g_obj:GetAttribute("IsGhost") == true or string.find(string.lower(g_obj.Name), "ghost")) then
                                        local part = g_obj:FindFirstChild("HumanoidRootPart") or g_obj:FindFirstChild("ZoneCheckPart") or g_obj.PrimaryPart
                                        if part then ghostPos = part.Position; break end
                                    end
                                end
                                
                                -- Desechar Oficial
                                if remDrop then pcall(function() remDrop:FireServer(filledSlot) end) end
                                task.wait(1)
                                
                                -- Rehubicación Táctica de Nueva Instancia (Volumétrica)
                                if ghostPos and LP.Character and LP.Character.PrimaryPart then
                                    pcall(function()
                                        local miPos = LP.Character.PrimaryPart.Position
                                        -- El servidor destruye el obj y spawnea uno nuevo en tus pies al droppear. El ping no es instantáneo.
                                        task.wait(2) -- Retardo incrementado para asegurar que la réplica de red reviva en nuestra cara
                                        for _, v in pairs(game:GetService("CollectionService"):GetTagged("Item")) do
                                            local pt = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart", true)
                                            if not pt then
                                                for _, ch in pairs(v:GetDescendants()) do if ch:IsA("BasePart") then pt = ch; break end end
                                            end
                                            -- Si está aplastado a nuestros pies (recién soltado en el camión), lo pateamos al cuarto
                                            if pt and (pt.Position - miPos).Magnitude < 15 then
                                                v:PivotTo(CFrame.new(ghostPos + Vector3.new(math.random(-2,2), 1, math.random(-2,2))))
                                            end
                                        end
                                    end)
                                    AddLog("       📍 Objeto plantado (Drone Tracking activado).", Color3.fromRGB(200, 200, 255))
                                end
                                
                                -- NO destruir localmente para no desvincular el ID
                            else
                                AddLog("   └─> Confirmado en DB, pero sin modelo 3D.", Color3.fromRGB(150, 150, 150))
                                if remDrop then pcall(function() remDrop:FireServer(filledSlot) end) end
                            end
                        else
                            AddLog("   └─> Bloqueo en protocolo de Equipar ("..capturedItemName..").", Color3.fromRGB(255, 100, 100))
                            if remDrop then pcall(function() remDrop:FireServer(filledSlot) end) end
                        end
                    else
                        AddLog("   └─> Denegado por servidor. No se registró en tu Attribute.", Color3.fromRGB(150, 150, 150))
                    end
                    
                    -- Pausa anticheat
                    if i % 3 == 0 then 
                        AddLog("⏳ Pausando por seguridad anti-spam...", Color3.fromRGB(150, 150, 150))
                        task.wait(2) 
                    end
                end
                
                -- Spirit Box por chat + comandos secretos Wiki
                AddLog("[CHAT] Enviando comandos secretos al fantasma...", Color3.fromRGB(255, 150, 0))
                local askSpirit = game.ReplicatedStorage:FindFirstChild("AskSpiritBoxFromUI", true)
                if askSpirit then pcall(function() askSpirit:FireServer("Are you here?") end) end
                
                pcall(function()
                    local tcs = game:GetService("TextChatService")
                    if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
                        tcs.TextChannels.RBXGeneral:SendAsync("Can you write in the book")
                        task.wait(1)
                        tcs.TextChannels.RBXGeneral:SendAsync("Give me a sign")
                        task.wait(1)
                        tcs.TextChannels.RBXGeneral:SendAsync("Show yourself")
                    else
                        local req = game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest
                        req:FireServer("Can you write in the book", "All")
                        task.wait(1)
                        req:FireServer("Give me a sign", "All")
                    end
                end)
                
                AddLog("━━━ CICLO COMPLETO - Esperando 20s ━━━", Color3.fromRGB(100, 100, 100))
                for i = 1, 20 do
                    if not pingActivo then break end
                    task.wait(1)
                end
            end
        end)
        
    else
        BtnPing.Text = "📡 PING DE SERVIDOR (V6)"
        BtnPing.BackgroundColor3 = Color3.fromRGB(150, 40, 0)
        AddLog("[STOP] Interrogatorio Cancelado.", Color3.fromRGB(150, 150, 150))
    end
end)

-- 1. OJO DE DIOS (FANTASMA Y SU HABITACIÓN)
local EspFantasma = false
local AdnDescifrado = false

BtnESP.MouseButton1Click:Connect(function()
    EspFantasma = not EspFantasma
    if EspFantasma then
        BtnESP.Text = "👁️ ESP FANTASMA: ON"
        BtnESP.BackgroundColor3 = Color3.fromRGB(120, 20, 40)
        AdnDescifrado = false
        task.spawn(function()
            while EspFantasma do
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj ~= LP.Character then
                        local nl = string.lower(obj.Name)
                        if nl == "ghost" or nl == "entity" or nl == "demon" or nl == "monster" then
                            local favRoom = obj:GetAttribute("FavoriteRoom") or "Desconocida"
                            ApplyESPTag(obj, "👻 FANTASMA ("..favRoom..")", Color3.fromRGB(255, 0, 0), false)
                            
                            -- Escáner de ADN (Extraer Variables Ocultas)
                            if not AdnDescifrado then
                                AdnDescifrado = true
                                AddLog("--------------------------------", Color3.fromRGB(100, 100, 100))
                                AddLog("🧬 EXTRACCIÓN DE ADN ("..obj.Name..")", Color3.fromRGB(255, 100, 255))
                                local attrs = obj:GetAttributes()
                                local count = 0
                                for k, v in pairs(attrs) do
                                    count = count + 1
                                    AddLog(">> [ATRIBUTO] " .. tostring(k) .. " = " .. tostring(v), Color3.fromRGB(200, 150, 255))
                                end
                                for _, ch in pairs(obj:GetChildren()) do
                                    if ch:IsA("StringValue") or ch:IsA("IntValue") or ch:IsA("BoolValue") or ch:IsA("NumberValue") then
                                        count = count + 1
                                        AddLog(">> [VAR] " .. ch.Name .. " = " .. tostring(ch.Value), Color3.fromRGB(150, 200, 255))
                                    end
                                end
                                
                                AddLog("🦴 [ESQUELETO 3D DEL FANTASMA]:", Color3.fromRGB(200, 100, 255))
                                for _, desc in pairs(obj:GetDescendants()) do
                                    -- Filtrar partes del cuerpo básico (Head, Torso, etc.)
                                    local dn = desc.Name
                                    if not string.find(dn, "Arm") and not string.find(dn, "Leg") and not string.find(dn, "Torso") and dn ~= "Humanoid" and dn ~= "HumanoidRootPart" and dn ~= "Head" then
                                        count = count + 1
                                        AddLog(">> [PIEZA] " .. desc.ClassName .. " | " .. dn, Color3.fromRGB(150, 150, 200))
                                        
                                        -- Auto-Detectar indicios basados en el esqueleto
                                        if string.find(string.lower(dn), "emf") then
                                            AddLog("⭐ EVIDENCIA LEAKEADA: NIVEL EMF 5", Color3.fromRGB(255, 255, 0))
                                        elseif string.find(string.lower(dn), "spirit") or string.find(string.lower(dn), "box") then
                                            AddLog("⭐ EVIDENCIA LEAKEADA: CAJA DE ESPÍRITUS", Color3.fromRGB(255, 255, 0))
                                        elseif string.find(string.lower(dn), "wither") or string.find(string.lower(dn), "lidar") then
                                            AddLog("⭐ EVIDENCIA LEAKEADA: MARCHITAR", Color3.fromRGB(255, 255, 0))
                                        end
                                    end
                                end
                                
                                if count == 0 then
                                    AddLog("❌ El creador no filtró evidencias en el modelo.", Color3.fromRGB(255, 50, 50))
                                else
                                    AddLog("✅ MIRA SI HAY UNA EVIDENCIA ESCONDIDA ARRIBA.", Color3.fromRGB(100, 255, 100))
                                end
                            end
                        end
                    end
                end
                task.wait(2)
            end
        end)
    else
        BtnESP.Text = "👁️ ESP FANTASMA"
        BtnESP.BackgroundColor3 = Color3.fromRGB(60, 10, 20)
    end
end)

-- 2. ESP HUESOS Y OBJETOS MALDITOS (DINERO/EXP)
local EspItems = false
BtnItems.MouseButton1Click:Connect(function()
    EspItems = not EspItems
    if EspItems then
        BtnItems.Text = "💎 ESP OBJETOS: ON"
        BtnItems.BackgroundColor3 = Color3.fromRGB(120, 80, 20)
        task.spawn(function()
            while EspItems do
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") or obj:IsA("BasePart") then
                        local nl = string.lower(obj.Name)
                        -- Huesos (Exactos)
                        if nl == "bone" or nl == "hueso" or string.find(nl, "spine") or string.find(nl, "ribcage") then
                            ApplyESPTag(obj, "🦴 HUESO", Color3.fromRGB(255, 255, 0), false)
                        end
                        -- Objetos Malditos (Nombres exactos o con ProximityPrompt interactivo)
                        if nl == "tarotcards" or nl == "tarot cards" or nl == "ouija board" or nl == "ouijaboard" or nl == "haunted mirror" or nl == "hauntedmirror" or nl == "voodoo doll" or nl == "voodoodoll" or nl == "music box" or nl == "musicbox" or nl == "summoning circle" then
                            ApplyESPTag(obj, "🔮 MALDITO: " .. obj.Name, Color3.fromRGB(150, 0, 255), false)
                        end
                        -- Caja de Braker (Electricidad)
                        if string.find(nl, "breaker") or string.find(nl, "fuse") then
                            ApplyESPTag(obj, "⚡ LUCES", Color3.fromRGB(0, 150, 255), false)
                        end
                    end
                end
                task.wait(3)
            end
        end)
    else
        BtnItems.Text = "💎 ESP HUESO Y MALDITOS"
        BtnItems.BackgroundColor3 = Color3.fromRGB(60, 40, 10)
    end
end)

-- 3. SCANNER DE EVIDENCIA EN TIEMPO REAL
local ScanEvi = false
BtnEvidence.MouseButton1Click:Connect(function()
    ScanEvi = not ScanEvi
    if ScanEvi then
        BtnEvidence.Text = "📖 SCAN DE EVIDENCIA: ON"
        BtnEvidence.BackgroundColor3 = Color3.fromRGB(20, 100, 180)
        AddLog("[START] Escáner de Ambiente Activo...", Color3.fromRGB(100, 200, 255))
        
        task.spawn(function()
            while ScanEvi do
                for _, obj in pairs(Workspace:GetDescendants()) do
                    local isEvi = false
                    local evName = ""
                    local nl = string.lower(obj.Name)
                    
                    -- Orbes
                    if obj:IsA("ParticleEmitter") and string.find(nl, "orb") then
                        evName = "Orbe Fantasma"
                        isEvi = true
                    elseif obj:IsA("BasePart") and string.find(nl, "orb") and not string.find(nl, "board") then
                        evName = "Orbe Fantasma"
                        isEvi = true
                    end
                    
                    -- Huellas (Calcomanías, Decals invisibles o visibles)
                    if obj:IsA("Decal") and (string.find(nl, "finger") or string.find(nl, "hand") or string.find(nl, "print")) then
                        evName = "Huellas Dactilares"
                        isEvi = true
                    end
                    
                    -- Temperaturas Heladas (Si hay humo de frío en tu personaje o en el mapa)
                    if obj:IsA("ParticleEmitter") and (string.find(nl, "breath") or string.find(nl, "cold") or string.find(nl, "frost")) then
                        evName = "Temperaturas Heladas"
                        isEvi = true
                    end
                    
                    -- Book Written (Decal o Modelo de Libro Escrito)
                    if (string.find(nl, "write") or string.find(nl, "written")) and (obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Model")) then
                        evName = "Escritura de fantasmas"
                        isEvi = true
                    end
                    
                    -- Proyector D.O.T.S (Cuando el fantasma colisiona, su fantasma verde D.O.T.S aparece)
                    if string.find(nl, "dot") and string.find(nl, "ghost") then
                        evName = "Proyector láser"
                        isEvi = true
                    end
                    
                    if isEvi and not EvidenciasEncontradas[evName] then
                        EvidenciasEncontradas[evName] = true
                        ApplyESPTag(obj, "🔴 " .. evName, Color3.fromRGB(255, 100, 0), true)
                        ActualizarPizarraResolucion()
                    end
                end
                
                -- V8.29: HACKEO DE HERRAMIENTAS ELECTRÓNICAS ABANDONADAS (EMF y TERMÓMETRO)
                pcall(function()
                    local CS = game:GetService("CollectionService")
                    for _, item in ipairs(CS:GetTagged("Item")) do
                        local n = string.lower(item.Name)
                        local attr = string.lower(tostring(item:GetAttribute("ItemName") or ""))
                        
                        -- Hackear sensores del termómetro
                        if string.find(n, "thermo") or string.find(attr, "thermo") then
                            for _, desc in pairs(item:GetDescendants()) do
                                if desc:IsA("TextLabel") and desc.Text then
                                    local tempStr = tostring(desc.Text)
                                    -- Si la pantalla marca un signo negativo (ej: -2.4, -0.1) o 0
                                    if string.find(tempStr, "%-") then
                                        if not EvidenciasEncontradas["Temperaturas Heladas"] then
                                            EvidenciasEncontradas["Temperaturas Heladas"] = true
                                            ActualizarPizarraResolucion()
                                            AddLog("⭐ EVIDENCIA OBTENIDA: Temperaturas Heladas (Sensor Hackeado)", Color3.fromRGB(0, 255, 255))
                                        end
                                    end
                                end
                                -- Las temperaturas negativas también cambian Atributos
                                if desc:GetAttribute("Temperature") then
                                    local tz = tonumber(desc:GetAttribute("Temperature"))
                                    if tz and tz <= 0 and not EvidenciasEncontradas["Temperaturas Heladas"] then
                                        EvidenciasEncontradas["Temperaturas Heladas"] = true
                                        ActualizarPizarraResolucion()
                                    end
                                end
                            end
                        end
                        
                        -- Hackear frecuencias del Lector EMF
                        if string.find(n, "emf") or string.find(attr, "emf") then
                            if item:GetAttribute("EMFLevel") then
                                local lvl = tonumber(item:GetAttribute("EMFLevel"))
                                if lvl and lvl >= 5 and not EvidenciasEncontradas["Nivel EMF 5"] then
                                    EvidenciasEncontradas["Nivel EMF 5"] = true
                                    ActualizarPizarraResolucion()
                                    AddLog("⭐ EVIDENCIA OBTENIDA: Nivel EMF 5 (Datos de Placa Base Leídos)", Color3.fromRGB(255, 0, 0))
                                end
                            end
                            for _, desc in pairs(item:GetDescendants()) do
                                if desc:IsA("BasePart") and desc.Material == Enum.Material.Neon then
                                    if string.find(string.lower(desc.Name), "5") or string.find(string.lower(desc.Name), "red") then
                                        if not EvidenciasEncontradas["Nivel EMF 5"] then
                                            EvidenciasEncontradas["Nivel EMF 5"] = true
                                            ActualizarPizarraResolucion()
                                            AddLog("⭐ EVIDENCIA OBTENIDA: Nivel EMF 5 (LED 5 Interceptado)", Color3.fromRGB(255, 0, 0))
                                        end
                                    end
                                end
                            end
                        end
                        
                        -- Análisis de Tinta Forense (Libros Abandonados)
                        if string.find(n, "book") or string.find(attr, "book") or string.find(n, "libro") or string.find(attr, "libro") then
                            local hasInk = false
                            if item:GetAttribute("Written") == true or item:GetAttribute("IsWritten") == true then hasInk = true end
                            for _, desc in pairs(item:GetDescendants()) do
                                if desc:IsA("Decal") or desc:IsA("Texture") or desc:IsA("ImageLabel") or desc:IsA("SurfaceGui") then
                                    local dName = string.lower(desc.Name)
                                    local alpha = desc:IsA("ImageLabel") and desc.ImageTransparency or desc:IsA("SurfaceGui") and 1 or desc.Transparency
                                    if alpha <= 0.5 then
                                        if dName == "roblox" or dName == "decal" or dName == "image" or string.find(dName, "writ") or string.find(dName, "text") or string.find(dName, "draw") then
                                            hasInk = true
                                        end
                                    end
                                end
                            end
                            if hasInk and not EvidenciasEncontradas["Escritura de fantasmas"] then
                                EvidenciasEncontradas["Escritura de fantasmas"] = true
                                ActualizarPizarraResolucion()
                                AddLog("⭐ EVIDENCIA OBTENIDA: Escritura de fantasmas (Tinta Analizada)", Color3.fromRGB(255, 255, 255))
                            end
                        end
                    end
                end)
                
                -- V8.26: Interceptor Radiactivo del Spirit Box (ShowSubtitle Event)
                pcall(function()
                    local RS = game:GetService("ReplicatedStorage")
                    if RS:FindFirstChild("Events") and RS.Events:FindFirstChild("ShowSubtitle") and not _G.SpiritBoxInterceptado then
                        _G.SpiritBoxInterceptado = true
                        RS.Events.ShowSubtitle.OnClientEvent:Connect(function(msg)
                            if msg then
                                local t = string.lower(tostring(msg))
                                AddLog("🎤 [ESPÍRITU RESPONDIÓ]: " .. tostring(msg), Color3.fromRGB(200, 150, 255))
                                if string.find(t, "behind") or string.find(t, "away") or string.find(t, "close") or string.find(t, "here") or string.find(t, "old") then
                                    if not EvidenciasEncontradas["Caja de Espíritus"] then
                                        EvidenciasEncontradas["Caja de Espíritus"] = true
                                        ActualizarPizarraResolucion()
                                        AddLog("⭐ EVIDENCIA OBTENIDA: Caja de Espíritus", Color3.fromRGB(0, 255, 0))
                                    end
                                end
                            end
                        end)
                    end
                end)
                task.wait(2)
            end
        end)
    else
        BtnEvidence.Text = "📖 SCAN DE EVIDENCIAS"
        BtnEvidence.BackgroundColor3 = Color3.fromRGB(10, 40, 60)
        AddLog("[STOP] Escáner Apagado.", Color3.fromRGB(150, 150, 150))
    end
end)

BtnDump.Text = "🧠 DEEP SCAN (FUGAS)"
BtnDump.BackgroundColor3 = Color3.fromRGB(60, 20, 100)
BtnDump.MouseButton1Click:Connect(function()
    AddLog("━━━ DEEP SCAN V8.27 (CAZA DE MEMORIA) ━━━", Color3.fromRGB(200, 100, 255))
    AddLog("🔎 Escaneando millones de variables en RAM...", Color3.fromRGB(200, 200, 0))
    
    local found = false
    local leakLocs = {}
    
    local ghostsToHunt = {}
    for ghostName, _ in pairs(GHOST_DB) do
        table.insert(ghostsToHunt, ghostName)
    end
    
    local function CheckFuga(valor, ubicacion)
        if type(valor) == "string" and valor ~= "" then
            local strL = string.lower(valor)
            for _, ghost in ipairs(ghostsToHunt) do
                if strL == string.lower(ghost) then
                    local locL = string.lower(ubicacion)
                    -- Filtrar nuestros propios scripts y GUI del juego que solo sean diccionarios
                    if not string.find(locL, "demonologyspeedrunpro") and not string.find(locL, "journal") and not string.find(locL, "dictionary") and not string.find(locL, "playergui") then
                        if not leakLocs[ubicacion] then
                            leakLocs[ubicacion] = true
                            AddLog("🚨 ¡FUGA DE MEMORIA!: Fantasma real es -> " .. ghost, Color3.fromRGB(255, 50, 50))
                            AddLog("   └─> CÓDIGO FUENTE: " .. ubicacion, Color3.fromRGB(255, 100, 100))
                            found = true
                        end
                    end
                end
            end
        end
    end
    
    task.spawn(function()
        for _, obj in pairs(game:GetDescendants()) do
            pcall(function()
                if obj:IsA("StringValue") then
                    CheckFuga(obj.Value, obj:GetFullName() .. " (StringValue)")
                end
                if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                    CheckFuga(obj.Text, obj:GetFullName() .. " (Texto UI)")
                end
                local objAttrs = obj:GetAttributes()
                for k, v in pairs(objAttrs) do
                    CheckFuga(tostring(v), obj:GetFullName() .. " [Attribute: " .. tostring(k) .. "]")
                end
            end)
        end
        if not found then
            AddLog("✅ RESULTADO ANÁLISIS FORENSE:", Color3.fromRGB(100, 255, 100))
            AddLog("   └─> El Servidor NO FILTRA el nombre a los jugadores. Código protegido.", Color3.fromRGB(150, 255, 150))
            AddLog("   └─> CONCLUSIÓN: Es matemáticamente obligatorio usar herramientas.", Color3.fromRGB(150, 255, 150))
        end
    end)
end)
