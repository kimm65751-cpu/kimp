-- ==============================================================================
-- 🕯️ DEMONOLOGY V4.0: SPEEDRUN & EVIDENCE ESP
-- Ojo de Dios, Localizador de Hueso/Malditos, y Analizador Físico de Entorno
-- ==============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer

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
Title.Text = " ⏱️ DEMONOLOGY V6 | MODO SPEEDRUN & ESP "
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
local BtnPing      = CreateUIBtn(160, "📡 PING DE SERVIDOR (V6)", Color3.fromRGB(150, 40, 0))

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
                        -- Filtramos ruidos constantes
                        if not string.find(n, "move") and not string.find(n, "mouse") and not string.find(n, "sound") then
                            local args = {...}
                            local msg = ""
                            for _, arg in pairs(args) do msg = msg .. tostring(arg) .. " " end
                            
                            -- Resaltar evidencias interceptadas del servidor
                            if string.find(n, "spirit") or string.find(n, "chat") or string.find(n, "lidar") or string.find(n, "thermometer") or string.find(n, "emf") then
                                AddLog("🚨 RESPUESTA SERVIDOR ["..rem.Name.."]: " .. msg, Color3.fromRGB(255, 0, 0))
                            else
                                AddLog(">> [S->C] " .. rem.Name .. ": " .. string.sub(msg, 1, 50), Color3.fromRGB(50, 150, 255))
                            end
                        end
                    end
                end)
            end
        end
        
        -- Inyectando engaños a los aparatos a distancia de forma contínua y fuerza bruta
        task.spawn(function()
            while pingActivo do
                task.wait(3)
                if not pingActivo then break end
                
                local askSpirit = game.ReplicatedStorage:FindFirstChild("AskSpiritBoxFromUI", true)
                if askSpirit then
                    AddLog("[ATAQUE] Forzando Spirit Box invisiblemente...", Color3.fromRGB(255, 255, 0))
                    pcall(function() askSpirit:FireServer("Are you here?") end)
                end
                
                local askLidar = game.ReplicatedStorage:FindFirstChild("DetectedGhostWithLIDAR", true)
                if askLidar then
                    pcall(function() askLidar:FireServer() end)
                end
                
                -- PROVOCACIÓN AVANZADA (Wiki Secret Commands):
                -- Forzar escritura de fantasma, EMF y apariciones en chat.
                pcall(function()
                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Can you write in the book", "All")
                end)
                task.wait(1)
                pcall(function()
                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Give me a sign", "All")
                end)
                
                AddLog("[ATAQUE] Comandos de Provocación de chat enviados al Servidor.", Color3.fromRGB(255, 100, 0))
                
                -- Se espera 20 segundos por el cooldown oficial revelado en la wiki
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
                    
                    -- Huellas (Suelen aparecer como calcomanías/decals)
                    if obj:IsA("Decal") and (string.find(nl, "finger") or string.find(nl, "hand") or string.find(nl, "print")) and obj.Transparency < 1 then
                        evName = "Huellas Dactilares"
                        isEvi = true
                    end
                    
                    -- Temperaturas Heladas (Si hay humo de frío en tu personaje o en el mapa)
                    if obj:IsA("ParticleEmitter") and (string.find(nl, "breath") or string.find(nl, "cold") or string.find(nl, "frost")) then
                        evName = "Temperaturas Heladas"
                        isEvi = true
                    end
                    
                    -- Book Written (El libro se actualiza a escrito)
                    if (string.find(nl, "write") or string.find(nl, "written")) and string.find(nl, "book") then
                        evName = "Escritura de Fantasmas"
                        isEvi = true
                    end
                    
                    if isEvi and not EvidenciasEncontradas[evName] then
                        EvidenciasEncontradas[evName] = true
                        ApplyESPTag(obj, "🔴 " .. evName, Color3.fromRGB(255, 100, 0), true)
                        ActualizarPizarraResolucion()
                    end
                end
                task.wait(2)
            end
        end)
    else
        BtnEvidence.Text = "📖 SCAN DE EVIDENCIAS"
        BtnEvidence.BackgroundColor3 = Color3.fromRGB(10, 40, 60)
        AddLog("[STOP] Escáner Apagado.", Color3.fromRGB(150, 150, 150))
    end
end)
