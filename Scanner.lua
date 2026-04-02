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
    [1] = "Nivel EMF 5",           -- EMFLevel5 = 1
    [2] = "Caja de Espíritus",     -- SpiritBox = 2
    [3] = "Escritura de fantasmas",-- GhostWriting = 3
    [4] = "Temperaturas Heladas",  -- FreezingTemperatures = 4
    [5] = "Orbe Fantasma",         -- GhostOrb = 5
    [6] = "Huellas Dactilares",    -- Handprints = 6
    [7] = "Proyector láser",       -- LaserProjector = 7
    [8] = "Marchitar"              -- Wither = 8
}

-- Tabla con evidencias; se llena aquí SIN necesitar GUI lista
local EvidenciasEncontradas = {}
local MapEvs = {
    ["Nivel EMF 5"] = "EMFLevel5",
    ["Caja de Espíritus"] = "SpiritBox",
    ["Escritura de fantasmas"] = "GhostWriting",
    ["Temperaturas Heladas"] = "FreezingTemperatures",
    ["Orbe Fantasma"] = "GhostOrb",
    ["Huellas Dactilares"] = "Handprints",
    ["Proyector láser"] = "LaserProjector",
    ["Marchitar"] = "Wither"
}

local function RegistrarEvidencia(nombre)
    if nombre and not EvidenciasEncontradas[nombre] then
        EvidenciasEncontradas[nombre] = true
        
        -- AUTO-MARCADO EN TIEMPO REAL
        pcall(function()
            local rsEvents = game:GetService("ReplicatedStorage"):FindFirstChild("Events")
            if rsEvents and rsEvents:FindFirstChild("EvidenceMarkedInJournal") then
                local evCodename = MapEvs[nombre]
                if evCodename then
                    rsEvents.EvidenceMarkedInJournal:FireServer(evCodename)
                end
            end
        end)
        
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
        end
        if method == "InvokeServer" then
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
Title.Text = " ⏱️ a "
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

-- (EvidenciasEncontradas ya declarada en línea 30, NO redeclarar aquí)

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

local _G_EvidenciasYaMarcadasEnDiario = _G._EvidenciasYaMarcadasEnDiario or {}
_G._EvidenciasYaMarcadasEnDiario = _G_EvidenciasYaMarcadasEnDiario

local function ActualizarPizarraResolucion()
    -- 📝 V8.82: AUTO-MARCADO DEL DIARIO EN TIEMPO REAL (UI + SERVER)
    pcall(function()
        local LP = game:GetService("Players").LocalPlayer
        local rsEvents = game:GetService("ReplicatedStorage"):FindFirstChild("Events")
        
        for ev, _ in pairs(EvidenciasEncontradas) do
            if not _G_EvidenciasYaMarcadasEnDiario[ev] then
                local evCodename = MapEvs[ev]
                if evCodename then
                    -- 0. Anti-RaceCondition MÁXIMO (60fps)
                    _G_EvidenciasYaMarcadasEnDiario[ev] = true
                    
                    -- 1. Forzar UI Local (Visuales y lógica del cliente)
                    pcall(function()
                        local evTypes = LP.PlayerGui:FindFirstChild("EvidenceTypes", true)
                        if evTypes and evTypes:FindFirstChild(evCodename) then
                            local btn = evTypes[evCodename]:FindFirstChild("Detection", true)
                            local container = btn and btn.Parent
                            if container and getconnections then
                                local highlight = container:FindFirstChild("Highlight")
                                local crossOut = container:FindFirstChild("CrossOut")
                                local conns = getconnections(btn.MouseButton1Click)
                                if conns and conns[1] then
                                    -- V8.96: Usar los elementos REALES del juego (Highlight/CrossOut)
                                    -- Ciclo de estados del juego: nil→true(Highlight)→false(CrossOut)→0(nada)→true...
                                    if highlight and highlight.Visible then
                                        -- Ya marcado correctamente, no tocar
                                    elseif crossOut and crossOut.Visible then
                                        -- Estado X (false) → 2 clics: false→0→true
                                        conns[1]:Fire()
                                        task.wait(0.15)
                                        conns[1]:Fire()
                                        task.wait(0.15)
                                    else
                                        -- Estado neutro (nil/0) → 1 clic: nil→true
                                        conns[1]:Fire()
                                        task.wait(0.15)
                                    end
                                    -- Verificación final
                                    task.wait(0.1)
                                    if highlight and not highlight.Visible then
                                        AddLog("⚠️ [DIARIO] Evidencia '" .. ev .. "' NO se verificó en UI. Reintentando próximo ciclo.", Color3.fromRGB(255, 100, 0))
                                        _G_EvidenciasYaMarcadasEnDiario[ev] = nil -- Permitir reintento
                                    end
                                end
                            end
                        end
                    end)
                    
                    -- 2. Asegurar Servidor (Por si la UI falla)
                    if rsEvents and rsEvents:FindFirstChild("EvidenceMarkedInJournal") then
                        rsEvents.EvidenceMarkedInJournal:FireServer(evCodename)
                    end
                    
                    AddLog("📓 [DIARIO] Evidencia marcada y UI actualizada: " .. ev, Color3.fromRGB(255, 215, 0))
                    task.wait(0.15)
                end
            end
        end
    end)
    
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
    
    local finalGhostName = ""
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
            finalGhostName = gName
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
    
    if posibles == 1 and not _G.MatchCompletado then
        _G.MatchCompletado = true
        BoardTitle.Text = " 🏆 ¡FANTASMA DESCUBIERTO! "
        BoardTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
        
        -- Ejecución del Final del Juego
        coroutine.wrap(function()
            AddLog("--------------------------------", Color3.fromRGB(100, 100, 100))
            AddLog("💡 [SPEEDRUN] ¡EVIDENCIA COMPLETA! Rellenando el Diario y seleccionando " .. finalGhostName .. "...", Color3.fromRGB(0, 255, 150))
            
            local rsEvents = game:GetService("ReplicatedStorage"):FindFirstChild("Events")
            if rsEvents and rsEvents:FindFirstChild("EvidenceMarkedInJournal") then
                local networkName = finalGhostName == "The Wisp" and "Wisp" or finalGhostName
                
                -- ═══ PASO 1: HOOK DE RED (GARANTÍA ABSOLUTA) ═══
                -- Interceptar GetSelectedGhost ANTES de todo. Si el servidor pregunta qué
                -- fantasma elegimos, SIEMPRE devolverá nuestro cálculo perfecto.
                local hookActivo = false
                local hookFn = function()
                    return networkName
                end
                if rsEvents:FindFirstChild("GetSelectedGhost") then
                    rsEvents.GetSelectedGhost.OnClientInvoke = hookFn
                    hookActivo = true
                    AddLog("       🎯 Hook GetSelectedGhost activo: Servidor recibirá [" .. networkName .. "]", Color3.fromRGB(0, 255, 150))
                end
                
                -- ═══ PASO 2: DISPARO AL SERVIDOR (NOTIFICACIÓN DIRECTA) ═══
                rsEvents.EvidenceMarkedInJournal:FireServer(networkName)
                AddLog("       📡 Servidor notificado: EvidenceMarkedInJournal(" .. networkName .. ")", Color3.fromRGB(0, 200, 255))
                task.wait(0.3)
                
                -- ═══ PASO 3: CLIC UI DEL FANTASMA (VISUAL LOCAL) ═══
                -- Intentar clickear el botón del fantasma en el diario para consistencia visual.
                -- El ghost type usa estado: nil→true(seleccionado)→false→nil→true...
                -- Un solo clic desde nil pone true. SOLO disparamos conns[1] para evitar doble-clic.
                pcall(function()
                    local LP = game:GetService("Players").LocalPlayer
                    local gTypes = LP.PlayerGui:FindFirstChild("GhostTypes", true)
                    if gTypes and gTypes:FindFirstChild(networkName) then
                        local btn = gTypes[networkName]:FindFirstChild("Detection", true)
                        if btn and getconnections then
                            local conns = getconnections(btn.MouseButton1Click)
                            if conns and conns[1] then
                                conns[1]:Fire() -- UN solo clic: nil→true
                                AddLog("       🖱️ Clic UI enviado a GhostTypes[" .. networkName .. "]", Color3.fromRGB(200, 200, 100))
                            end
                        end
                    end
                end)
                task.wait(0.5)
                
                -- ═══ PASO 4: VERIFICACIÓN DE EVIDENCIAS EN DIARIO ═══
                -- Comprobar que las 3 evidencias están marcadas (Highlight visible)
                local evidenciasFaltantes = {}
                pcall(function()
                    local LP = game:GetService("Players").LocalPlayer
                    local evTypes = LP.PlayerGui:FindFirstChild("EvidenceTypes", true)
                    if evTypes then
                        for ev, _ in pairs(EvidenciasEncontradas) do
                            local codename = MapEvs[ev]
                            if codename and evTypes:FindFirstChild(codename) then
                                local container = evTypes[codename]:FindFirstChild("Container", true) or evTypes[codename]
                                local highlight = container:FindFirstChild("Highlight")
                                if not highlight or not highlight.Visible then
                                    table.insert(evidenciasFaltantes, ev)
                                end
                            end
                        end
                    end
                end)
                
                -- Si hay evidencias sin marcar en UI, reintentar
                if #evidenciasFaltantes > 0 then
                    AddLog("⚠️ [VERIFICACIÓN] " .. #evidenciasFaltantes .. " evidencias sin marcar en UI. Reintentando...", Color3.fromRGB(255, 150, 0))
                    for _, evFaltante in ipairs(evidenciasFaltantes) do
                        _G_EvidenciasYaMarcadasEnDiario[evFaltante] = nil
                    end
                    pcall(ActualizarPizarraResolucion)
                    task.wait(0.5)
                end
                
                -- ═══ PASO 5: VERIFICACIÓN FINAL ANTES DE ESCAPAR ═══
                -- Verificamos que el hook devuelve el nombre correcto.
                local verificacionOK = false
                if hookActivo then
                    local ok, result = pcall(hookFn)
                    if ok and result == networkName then
                        verificacionOK = true
                    end
                end
                
                if not verificacionOK then
                    AddLog("⚠️ FATAL: Hook de GetSelectedGhost NO devolvió [" .. networkName .. "]. ¡ABORTO DE ESCAPE!", Color3.fromRGB(255, 50, 50))
                    AddLog("⚠️ El Bot se detendrá. Marca el fantasma manualmente y sal al camión.", Color3.fromRGB(255, 50, 50))
                    return
                end
                
                AddLog("       ✅ VERIFICACIÓN COMPLETA: Hook confirmado → [" .. networkName .. "]", Color3.fromRGB(0, 255, 100))
                task.wait(0.5)
                if rsEvents:FindFirstChild("ToggleJournal") then rsEvents.ToggleJournal:FireServer() end
            end
            
            AddLog("🚚 [ESCAPE MÁXIMO] ¡Trabajo hecho! Teletransportando al camión...", Color3.fromRGB(0, 255, 255))
            -- Teletransportar al camión/base para escapar
            pcall(function()
                local LP = game:GetService("Players").LocalPlayer
                local cb = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Rooms") and workspace.Map.Rooms:FindFirstChild("Base Camp")
                if cb and cb:FindFirstChild("Truck") and cb.Truck.PrimaryPart then
                    LP.Character.HumanoidRootPart.CFrame = cb.Truck.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
                elseif workspace:FindFirstChild("Items") and workspace.Items.PrimaryPart then
                    LP.Character.HumanoidRootPart.CFrame = workspace.Items.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
                end
            end)
            
            task.wait(2)
            -- Cobrar el premio y salir! (Finish Job event)
            if rsEvents and rsEvents:FindFirstChild("RequestReturnToLobby") then
                AddLog("💰 ¡MARCANDO FINISH JOB! Ganando dinero y regresando al lobby...", Color3.fromRGB(255, 215, 0))
                rsEvents.RequestReturnToLobby:FireServer()
            end
        end)()
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
                        
                        -- 🔥 V8.47: Se eliminó el mapeo roto de ObjectiveCompleted que causaba falsos positivos de 'Orbe Fantasma'.
                        -- Los objetivos NO SON equivalentes a los IDs de evidencias.
                        if string.find(n, "objective") then
                            AddLog("🎯 Notificación de Objetivo: " .. msg, Color3.fromRGB(200, 200, 200))
                        
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
                
                -- === AUTO-LABORATORIO V8.41: Gestión Real de Inventario ===
                local remEquip  = game.ReplicatedStorage:FindFirstChild("RequestItemEquip", true)
                local remToggle = game.ReplicatedStorage:FindFirstChild("ToggleItemState", true)
                local remDrop   = game.ReplicatedStorage:FindFirstChild("RequestItemDrop", true)
                local remPickup = game.ReplicatedStorage:FindFirstChild("RequestItemPickup", true)
                
                -- === 🛡️ AUTO-LABORATORIO V8.54: LOCKDOWN DE CACERÍA ===
                if _G.IsHunting == true then
                    -- Nos congelamos en el subciclo para no morir teletransportandonos enfrente del Fantasma Cazando
                    task.wait(2)
                    continue
                end
                
                -- 🚪 V8.80: AUTO-APERTURA DE TODAS LAS PUERTAS AL INICIO DEL CICLO
                if not _G.DoorsOpened then
                    pcall(function()
                        local CS2 = game:GetService("CollectionService")
                        local rsEv = game:GetService("ReplicatedStorage"):FindFirstChild("Events")
                        if rsEv and rsEv:FindFirstChild("ClientChangeDoorState") then
                            local allDoors = CS2:GetTagged("Door")
                            local puertasAbiertas = 0
                            for _, door in ipairs(allDoors) do
                                pcall(function()
                                    local parentModel = door.Parent
                                    if parentModel and parentModel:GetAttribute("DoorClosed") == true then
                                        rsEv.ClientChangeDoorState:FireServer(door)
                                        puertasAbiertas = puertasAbiertas + 1
                                    end
                                end)
                            end
                            if puertasAbiertas > 0 then
                                AddLog("🔓 " .. puertasAbiertas .. " puertas hackeadas y abiertas (I.A. Despierta)", Color3.fromRGB(150, 255, 150))
                                _G.DoorsOpened = true
                            end
                        end
                    end)
                end
                
                -- === AUTO-LABORATORIO V8.25: DRONE-TRACKING (Mover si el fantasma huye) ===
                local CS = game:GetService("CollectionService")
                
                -- 🚀 V8.50: FILTRO ESTRICTO DE ORIGEN BIOLÓGICO PARA LA ZONA SEGURA (isPlanted)
                local ghostPos = nil
                local currentGhostInstance = nil
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj ~= LP.Character then
                        local n = string.lower(obj.Name)
                        if n == "ghost" or n == "entity" or n == "demon" or obj:GetAttribute("IsGhost") == true then
                            if not string.find(n, "orb") and not string.find(n, "book") then
                                local part = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("ZoneCheckPart") or obj.PrimaryPart
                                if part then 
                                    ghostPos = part.Position
                                    currentGhostInstance = obj
                                    break 
                                end
                            end
                        end
                    end
                end
                
                -- === 🧼 AUTO-LABORATORIO V8.74: ANTI-STALE EVIDENCE WIPE ===
                if currentGhostInstance then
                    local currentGhostDebugId = currentGhostInstance:GetDebugId()
                    if _G.CurrentMatchGhostID ~= currentGhostDebugId then
                        AddLog("🔄 [NUEVA PARTIDA DETECTADA] Limpiando memoria caché de partida anterior...", Color3.fromRGB(0, 255, 255))
                        _G.CurrentMatchGhostID = currentGhostDebugId
                        _G.MatchCompletado = false
                        _G.DoorsOpened = false
                        _G.BookSpyData = {}
                        for k in pairs(_G_EvidenciasYaMarcadasEnDiario) do _G_EvidenciasYaMarcadasEnDiario[k] = nil end
                        for k in pairs(EvidenciasEncontradas) do EvidenciasEncontradas[k] = nil end
                        pcall(ActualizarPizarraResolucion)
                    end
                end

                local todasHerramientas = CS:GetTagged("Item")
                
                -- === 🚀 V8.65: POLLEO Y SPY DE ESTADO DEL LIBRO (REESCRITO) ===
                if not _G.BookSpyData then _G.BookSpyData = {} end
                for _, obj in ipairs(todasHerramientas) do
                    if obj:GetAttribute("ItemName") == "Spirit Book" then
                        local currentY = obj.PrimaryPart and obj.PrimaryPart.Position.Y or 0
                        local objId = tostring(obj:GetDebugId())
                        
                        -- Buscar la textura actual de la página del libro (SurfaceGui > ImageLabel)
                        local currentTexture = ""
                        pcall(function()
                            for _, part in ipairs(obj:GetDescendants()) do
                                if part:IsA("SurfaceGui") then
                                    local img = part:FindFirstChildOfClass("ImageLabel")
                                    if img and img.Image and img.Image ~= "" then
                                        currentTexture = img.Image
                                    end
                                end
                            end
                        end)
                        
                        -- SPY: Comparar con estado memorizado
                        if _G.BookSpyData[objId] then
                            -- Detectar Levitación
                            local oldY = _G.BookSpyData[objId].Y
                            if math.abs(currentY - oldY) > 1 then
                                AddLog("🔍 [SPY-BOOK] ¡LEVITACIÓN! Altura cambió " .. string.format("%.1f", currentY - oldY) .. " studs.", Color3.fromRGB(200, 150, 255))
                                _G.BookSpyData[objId].Y = currentY
                            end
                            
                            -- Detectar Escritura por ATRIBUTOS REALES del servidor (V8.67)
                            -- El servidor pone PhotoRewardType = "GhostWriting" y Disabled = true cuando el fantasma escribe
                            local photoRewardType = obj:GetAttribute("PhotoRewardType")
                            local isDisabled = obj:GetAttribute("Disabled")
                            
                            if (photoRewardType == "GhostWriting" or isDisabled == true) and not EvidenciasEncontradas["Escritura de fantasmas"] then
                                EvidenciasEncontradas["Escritura de fantasmas"] = true
                                AddLog("⭐ EVIDENCIA OBTENIDA AUTOMÁTICAMENTE: Escritura de Fantasmas (El servidor confirmó: PhotoRewardType=" .. tostring(photoRewardType) .. ", Disabled=" .. tostring(isDisabled) .. ")", Color3.fromRGB(255, 255, 0))
                                pcall(ActualizarPizarraResolucion)
                            end
                            
                            -- Monitorear TODOS los atributos para debugging
                            for attrName, attrVal in pairs(obj:GetAttributes()) do
                                local oldAttrs = _G.BookSpyData[objId].Attrs or {}
                                if oldAttrs[attrName] ~= attrVal then
                                    AddLog("🔍 [SPY-BOOK] Atributo '" .. attrName .. "' cambió: " .. tostring(oldAttrs[attrName]) .. " → " .. tostring(attrVal), Color3.fromRGB(200, 150, 255))
                                    if not _G.BookSpyData[objId].Attrs then _G.BookSpyData[objId].Attrs = {} end
                                    _G.BookSpyData[objId].Attrs[attrName] = attrVal
                                end
                            end
                        else
                            _G.BookSpyData[objId] = { Y = currentY, Texture = currentTexture, Attrs = obj:GetAttributes() }
                        end
                    end
                end
                
                -- === 🚀 V8.69: DETECCIÓN INSTANTÁNEA DE ORBES FANTASMAS ===
                -- El juego carga físicamente un modelo llamado "GhostOrb" en el workspace si la evidencia existe.
                -- V8.78: Muchos mapas cargan un Orbe oculto debajo del mapa. Debemos verificar si orbita al fantasma.
                local orb = workspace:FindFirstChild("GhostOrb")
                if orb and not EvidenciasEncontradas["Orbe Fantasma"] then
                    local orbPos = orb:IsA("Model") and (orb.PrimaryPart and orb.PrimaryPart.Position or orb:GetBoundingBox().Position) or orb.Position
                    if ghostPos and (orbPos - ghostPos).Magnitude <= 35 then
                        -- V8.90 - PARCHE DE PROFUNDIDAD (Falso Positivo)
                        -- Los desarrolladores ocultan el Orb debajo del mapa (Y = -10 o inferior) en partidas 
                        -- donde no es evidencia válida (Ej: Dullahan). Si está enterrado, ignorarlo por completo.
                        if orbPos.Y < -5 then 
                            isRealOrb = false 
                        else
                            -- V8.84: Muchos orbes existen físicamente pero apagados si no es la evidencia.
                            for _, particle in pairs(orb:GetDescendants()) do
                                if particle:IsA("ParticleEmitter") and particle.Enabled and particle.Rate > 0 then
                                    isRealOrb = true
                                    break
                                end
                            end
                            
                            -- En caso de que el juego use un Trail u otro método en lugar de ParticleEmitter:
                            if not isRealOrb and orb:IsA("BasePart") and orb.Transparency < 1 then
                                isRealOrb = true
                            end
                        end
                        
                        if isRealOrb then
                            EvidenciasEncontradas["Orbe Fantasma"] = true
                            AddLog("⭐ EVIDENCIA OBTENIDA: Orbe Fantasma (Orbitando Entidad activamente)", Color3.fromRGB(0, 255, 255))
                            pcall(ActualizarPizarraResolucion)
                        end
                    end
                end
                
                local tomables = {}
                for _, obj in ipairs(todasHerramientas) do
                    -- Ignorar monedas, tickets de lotería o herramientas humanas ocupadas
                    if not obj:IsDescendantOf(game.Players) and (not obj.Parent or not obj.Parent:FindFirstChild("Humanoid")) then
                        local n = string.lower(obj:GetAttribute("ItemName") or obj:GetAttribute("DisplayName") or obj.Name)
                        if n ~= "100" and not string.find(n, "coin") and not string.find(n, "ticket") and not string.find(n, "tarot") and not string.find(n, "ouija") and not string.find(n, "umbra") and not string.find(n, "bone") and not string.find(n, "music box") and not string.find(n, "haunted mirror") and not string.find(n, "plushie") and not string.find(n, "fortune") and not string.find(n, "defibrillator") and not string.find(n, "holy oil") and not string.find(n, "shotgun") and not string.find(n, "lighter") and not string.find(n, "salt") then
                            -- Confirmar si la trampa ya está bien plantada cerca del monstruo
                            local isPlanted = false
                            if ghostPos then
                                local p = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                                if not p then
                                    for _, ch in pairs(obj:GetDescendants()) do
                                        if ch:IsA("BasePart") then p = ch; break end
                                    end
                                end
                                
                                -- V8.70: Reducido de 35 a 18 studs para que no se solape con el camión si el fantasma está cerca de la puerta (Ej. Garage)
                                if p and (p.Position - ghostPos).Magnitude <= 18 then
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
                                -- V8.45: Resolver el NOMBRE REAL de la herramienta (el slot guarda IDs numéricos)
                                local realItemName = itemFalso:GetAttribute("ItemName") or itemFalso:GetAttribute("DisplayName") or itemFalso.Name or capturedItemName
                                AddLog("   └─> ¡MATERIALIZADO!: " .. tostring(realItemName) .. " (slot=" .. capturedItemName .. ")", Color3.fromRGB(150, 255, 150))
                                task.wait(0.5)
                                
                                -- ==========================================================
                                -- 🚀 V8.48: TELETRANSPORTE CARA A CARA Y SIN FALSOS POSITIVOS
                                -- ==========================================================
                                local ghostPart = nil
                                for _, g_obj in pairs(workspace:GetDescendants()) do
                                    if g_obj:IsA("Model") and g_obj ~= LP.Character then
                                        local n = string.lower(g_obj.Name)
                                        if n == "ghost" or n == "entity" or n == "demon" or g_obj:GetAttribute("IsGhost") == true then
                                            -- Ignorar explícitamente cosas que no son la entidad
                                            if not string.find(n, "orb") and not string.find(n, "book") then
                                                ghostPart = g_obj:FindFirstChild("HumanoidRootPart") or g_obj:FindFirstChild("ZoneCheckPart") or g_obj.PrimaryPart
                                                if ghostPart then break end
                                            end
                                        end
                                    end
                                end
                                
                                local posOriginal = LP.Character and LP.Character.PrimaryPart and LP.Character.PrimaryPart.CFrame or nil
                                
                                if ghostPart and LP.Character and LP.Character.PrimaryPart then
                                    local hrp = LP.Character.PrimaryPart
                                    pcall(function() hrp.Velocity = Vector3.new(0,0,0) end)
                                    pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0,0,0) end)
                                    
                                    -- V8.80: Nos ponemos al LADO del fantasma (offset lateral) para no atravesar paredes
                                    local ghostPos = ghostPart.Position
                                    -- Buscar dirección lateral (perpendicular a donde mira el fantasma)
                                    local rightVector = ghostPart.CFrame.RightVector
                                    local standPos = ghostPos + (rightVector * 4)
                                    standPos = Vector3.new(standPos.X, ghostPos.Y, standPos.Z)
                                    
                                    hrp.CFrame = CFrame.lookAt(standPos, ghostPos)
                                    AddLog("       🎯 Auto-Aim: Lateral (" .. string.format("%.1f", (hrp.Position - ghostPos).Magnitude) .. " studs)", Color3.fromRGB(200, 200, 255))
                                    
                                    -- 🚪 V8.75: AUTO-APERTURA DE TODAS LAS PUERTAS
                                    -- Así encendemos la IA del Fantasma y no necesitamos buscar las llaves ni la puerta principal.
                                    pcall(function()
                                        local CS = game:GetService("CollectionService")
                                        local rsEv = game:GetService("ReplicatedStorage"):FindFirstChild("Events")
                                        if rsEv and rsEv:FindFirstChild("ClientChangeDoorState") then
                                            local allDoors = CS:GetTagged("Door")
                                            local puertasAbiertas = 0
                                            for _, door in ipairs(allDoors) do
                                                if door:GetAttribute("DoorClosed") == true then
                                                    rsEv.ClientChangeDoorState:FireServer(door)
                                                    puertasAbiertas = puertasAbiertas + 1
                                                end
                                            end
                                            if puertasAbiertas > 0 then
                                                AddLog("       🔓 " .. puertasAbiertas .. " puertas hackeadas y abiertas (I.A. Despierta)", Color3.fromRGB(150, 255, 150))
                                            end
                                        end
                                    end)
                                    
                                    -- 🚀 V8.53: FORZA A LA CÁMARA (Ojos del jugador) A MIRAR AL FANTASMA
                                    -- Ya que los trípodes toman la rotación de CurrentCamera al hacer clic derecho
                                    pcall(function() workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, ghostPos) end)
                                    task.wait(1.5)
                                    hrp.CFrame = CFrame.lookAt(standPos, ghostPos) -- Re-confirmar rotación
                                    pcall(function() workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, ghostPos) end)
                                    task.wait(0.3)
                                else
                                    AddLog("       ⚠️ ghostPos NO encontrado, soltando aquí.", Color3.fromRGB(255, 100, 100))
                                end
                                
                                -- ==========================================================
                                -- ⚡ V8.47: ENCENDIDO Y USO AUTÓNOMO CON AUTO-AIM (MOUSE2)
                                -- ==========================================================
                                local itemNameLower = string.lower(tostring(realItemName))
                                -- === 🚀 V8.63: SISTEMA UNIFICADO DE PLANTADO ===
                                local skipDrop = false -- Flag para trípodes que se plantan con clic
                                
                                pcall(function()
                                    if string.find(itemNameLower, "video camera") or string.find(itemNameLower, "laser") then
                                        pcall(function()
                                            if itemFalso:GetAttribute("Enabled") == true or itemFalso:GetAttribute("Power") == true then return end
                                            
                                            local psEvents = LP:FindFirstChild("PlayerScripts") and LP.PlayerScripts:FindFirstChild("Events")
                                            if psEvents and psEvents:FindFirstChild("UseItem") then
                                                psEvents.UseItem:Fire()
                                                AddLog("       🔌 Overlay local encendido (UseItem)", Color3.fromRGB(0, 255, 200))
                                            end
                                            -- 🚀 V8.88: Separación de Lógica (Laser vs Cámara)
                                            -- El juego sí notifica al host cuando encendemos el Laser con UseItem, así que no necesitamos forzarlo.
                                            -- PERO la cámara no, así que el forzado extra SOLO debe ir a la cámara de video.
                                            if string.find(itemNameLower, "video camera") then
                                                if typeof(remToggle) == "Instance" then 
                                                    remToggle:FireServer(itemFalso) 
                                                    AddLog("       🔌 Lente activado en Host (ToggleItemState Especial)", Color3.fromRGB(200, 200, 100))
                                                end
                                            end
                                        end)
                                        task.wait(0.8)
                                        
                                        -- 2. Soltar al piso con el nombre del Slot correcto (InvSlot1-InvSlot4)
                                        pcall(function()
                                            local equippedObj = LP:GetAttribute("EquippedObject")
                                            if equippedObj then
                                                local slotName = nil
                                                for _, sn in ipairs({"InvSlot1","InvSlot2","InvSlot3","InvSlot4"}) do
                                                    if LP:GetAttribute(sn) == equippedObj then
                                                        slotName = sn
                                                        break
                                                    end
                                                end
                                                if slotName and remDrop then
                                                    remDrop:FireServer(slotName)
                                                    AddLog("       📍 Soltado al piso usando slot: " .. slotName, Color3.fromRGB(150, 200, 255))
                                                end
                                            end
                                        end)
                                        skipDrop = true -- Ya lo soltamos aquí arriba
                                        
                                        AddLog("       ✅ " .. realItemName .. " ENCENDIDO y plantado en el cuarto", Color3.fromRGB(0, 255, 150))
                                        
                                    elseif string.find(itemNameLower, "thermometer") then
                                        pcall(function()
                                            if itemFalso:GetAttribute("Enabled") == true or itemFalso:GetAttribute("Power") == true then return end
                                            
                                            local psEvents = LP:FindFirstChild("PlayerScripts") and LP.PlayerScripts:FindFirstChild("Events")
                                            if psEvents and psEvents:FindFirstChild("UseItem") then
                                                psEvents.UseItem:Fire()
                                                AddLog("       🌡️ Termómetro ENCENDIDO por UseItem", Color3.fromRGB(200, 200, 100))
                                            else
                                                if typeof(remToggle) == "Instance" then remToggle:FireServer(itemFalso) end
                                                AddLog("       🌡️ Termómetro ENCENDIDO por ToggleItemState (Fallback)", Color3.fromRGB(200, 200, 100))
                                            end
                                        end)
                                        -- Esperar 10s para que el servidor procese varias lecturas de temperatura
                                        AddLog("       🌡️ Esperando lectura de temperatura (10s)...", Color3.fromRGB(200, 200, 100))
                                        task.wait(10)
                                        AddLog("       🌡️ Termómetro escaneado completamente", Color3.fromRGB(0, 255, 150))
                                        
                                    elseif string.find(itemNameLower, "salt") then
                                        local saltEvent = game.ReplicatedStorage.Events:FindFirstChild("LaySaltPile")
                                        if saltEvent then saltEvent:FireServer() end
                                        AddLog("       🧂 Sal derramada (LaySaltPile)", Color3.fromRGB(200, 200, 200))
                                    
                                    elseif string.find(itemNameLower, "photo") then
                                        local photoSpoof = game.ReplicatedStorage.Events:FindFirstChild("TakePhotoWithCamera")
                                        if photoSpoof then
                                            AddLog("       📸 Generando 5 Fotos 3-Estrellas...", Color3.fromRGB(200, 255, 100))
                                            for fotoIdx = 1, 5 do
                                                photoSpoof:FireServer(workspace.CurrentCamera.CFrame, {
                                                    ["Object"] = workspace:FindFirstChild("Ghost") or LP.Character,
                                                    ["Type"] = "Ghost", ["Reward"] = 24,
                                                    ["Stars"] = 3, ["Percentage"] = 100
                                                })
                                                task.wait(0.3)
                                            end
                                        end
                                        
                                    elseif string.find(itemNameLower, "lidar") then
                                        if remToggle then remToggle:FireServer(itemFalso) end
                                        task.wait(0.3)
                                        local lidarSpoof = game.ReplicatedStorage.Events:FindFirstChild("DetectedGhostWithLIDAR")
                                        if lidarSpoof then
                                            lidarSpoof:FireServer()
                                            AddLog("       ⭐ LIDAR Spoofeado (Marchitar)", Color3.fromRGB(0, 255, 255))
                                            EvidenciasEncontradas["Marchitar"] = true
                                            pcall(ActualizarPizarraResolucion)
                                        end
                                        
                                    elseif string.find(itemNameLower, "blacklight") or string.find(itemNameLower, "uv light") then
                                        if remToggle then remToggle:FireServer(itemFalso) end
                                        task.wait(0.3)
                                        pcall(function()
                                            local handprints = workspace:FindFirstChild("Handprints")
                                            if handprints then
                                                for _, hp in pairs(handprints:GetChildren()) do
                                                    pcall(function()
                                                        local sg = hp:FindFirstChildOfClass("SurfaceGui")
                                                        if sg then
                                                            local img = sg:FindFirstChildOfClass("ImageLabel")
                                                            if img and img.ImageTransparency < 1 then
                                                                local blHover = game.ReplicatedStorage.Events:FindFirstChild("BlacklightHoveredPrint")
                                                                if blHover then blHover:FireServer(hp) end
                                                                EvidenciasEncontradas["Huellas Dactilares"] = true
                                                                pcall(ActualizarPizarraResolucion)
                                                            end
                                                        end
                                                    end)
                                                end
                                            end
                                        end)
                                    
                                    elseif string.find(itemNameLower, "lantern") then
                                        local lanternEvent = game.ReplicatedStorage.Events:FindFirstChild("ToggleLantern")
                                        if lanternEvent then lanternEvent:FireServer() end
                                        AddLog("       🏮 Lantern encendida", Color3.fromRGB(255, 200, 50))
                                    
                                    elseif string.find(itemNameLower, "lighter") then
                                        local lighterEvent = game.ReplicatedStorage.Events:FindFirstChild("UseLighter")
                                        if lighterEvent then lighterEvent:FireServer() end
                                        AddLog("       🔥 Lighter activado", Color3.fromRGB(255, 150, 0))
                                    
                                    elseif string.find(itemNameLower, "music box") then
                                        local musicEvent = game.ReplicatedStorage.Events:FindFirstChild("PlayMusicBox")
                                        if musicEvent then musicEvent:FireServer() end
                                        AddLog("       🎵 Music Box activada", Color3.fromRGB(200, 100, 255))
                                    
                                    else
                                        -- V8.80: Toggle INTELIGENTE - Solo prender si está apagado
                                        local yaEncendido = itemFalso:GetAttribute("Enabled") == true
                                        if not yaEncendido and remToggle then 
                                            remToggle:FireServer(itemFalso)
                                            AddLog("       🔋 " .. tostring(realItemName) .. " encendida (ToggleItemState)", Color3.fromRGB(100, 255, 100))
                                        elseif yaEncendido then
                                            AddLog("       ✅ " .. tostring(realItemName) .. " ya estaba encendida. No se tocó.", Color3.fromRGB(150, 255, 150))
                                        end
                                    end
                                    
                                    if appendfile then 
                                        appendfile("OjoDeDios_DeepLog.txt", "["..os.date("%X").."] TOOL_ACTIVATED: " .. tostring(realItemName) .. "\n") 
                                    end
                                end)
                                task.wait(0.5)
                                
                                -- 3. Soltar (SOLO si no fue plantado con sistema de trípode nativo)
                                if not skipDrop then
                                    if remDrop then pcall(function() remDrop:FireServer(filledSlot) end) end
                                    task.wait(0.5)
                                end
                                
                                AddLog("       📍 " .. tostring(realItemName) .. " plantada EN el cuarto.", Color3.fromRGB(200, 200, 255))
                                
                                -- 📡 V8.81: AUDITORÍA DE ESTADO DE RED PARA EL USUARIO
                                pcall(function()
                                    if itemFalso then
                                        local isEnabled = itemFalso:GetAttribute("Enabled") == true or itemFalso:GetAttribute("Power") == true
                                        local isElectronic = string.find(itemNameLower, "emf") or string.find(itemNameLower, "thermo") or string.find(itemNameLower, "laser") or string.find(itemNameLower, "camera") or string.find(itemNameLower, "box") or string.find(itemNameLower, "lidar") or string.find(itemNameLower, "blacklight")
                                        if isElectronic then
                                            if isEnabled then
                                                AddLog("       📡 Teleremotría: [EN LÍNEA] Transmitiendo datos correctamente.", Color3.fromRGB(0, 255, 100))
                                            else
                                                AddLog("       ⚠️ ERROR DE HOST: La herramienta reporta estar [APAGADA]. El servidor la rechazó o tiene delay.", Color3.fromRGB(255, 100, 100))
                                            end
                                        else
                                            AddLog("       🔘 Estado Analógico: Lista para interacción física.", Color3.fromRGB(200, 200, 200))
                                        end
                                    end
                                end)
                                
                                -- 4. Regresar
                                if posOriginal and LP.Character and LP.Character.PrimaryPart then
                                    LP.Character.PrimaryPart.CFrame = posOriginal
                                end
                                
                                AddLog("⏳ Pausando por seguridad anti-spam de red...", Color3.fromRGB(100, 100, 100))
                                task.wait(1.5)
                                
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
                
                -- ========================================================
                -- 📖 V8.45: MONITOR DE LIBRO (Spirit Book)
                -- El ItemName real es "Spirit Book" (confirmado en código fuente)
                -- La escritura se manifiesta como Decals en el modelo del libro
                -- ========================================================
                if not _G.LibroMonitoreado then
                    _G.LibroMonitoreado = true
                    pcall(function()
                        local function MonitorearLibro(item)
                            local itemName = tostring(item:GetAttribute("ItemName") or "")
                            if itemName ~= "Spirit Book" then return end
                            
                            AddLog("📖 Spirit Book detectado — vigilando escritura...", Color3.fromRGB(255, 200, 100))
                            
                            -- Método 1: Vigilar CUALQUIER Decal/Texture nueva, pero filtrando las texturas base
                            item.DescendantAdded:Connect(function(desc)
                                if not EvidenciasEncontradas["Escritura de fantasmas"] then
                                    if desc:IsA("Decal") or desc:IsA("Texture") or desc:IsA("SurfaceGui") then
                                        local dn = string.lower(desc.Name)
                                        if string.find(dn, "writ") or string.find(dn, "ink") or string.find(dn, "scrib") or string.find(dn, "draw") then
                                            EvidenciasEncontradas["Escritura de fantasmas"] = true
                                            AddLog("⭐ EVIDENCIA: Escritura de fantasmas (Tinta Activa en Book!)", Color3.fromRGB(255, 255, 0))
                                            pcall(ActualizarPizarraResolucion)
                                        end
                                    end
                                end
                            end)
                            
                            -- Método 2: Vigilar CUALQUIER cambio de atributo del libro
                            item.AttributeChanged:Connect(function(attrName)
                                if not EvidenciasEncontradas["Escritura de fantasmas"] then
                                    local an = string.lower(attrName)
                                    if string.find(an, "writ") or string.find(an, "drawn") or string.find(an, "used") or string.find(an, "active") then
                                        EvidenciasEncontradas["Escritura de fantasmas"] = true
                                        AddLog("⭐ EVIDENCIA: Escritura de fantasmas (Atributo Spirit Book!)", Color3.fromRGB(255, 255, 0))
                                        pcall(ActualizarPizarraResolucion)
                                    end
                                end
                            end)
                            
                            -- Método 3: Si el libro YA tiene Decals cuando llegamos (escritura pasada)
                            for _, desc in pairs(item:GetDescendants()) do
                                if (desc:IsA("Decal") or desc:IsA("Texture")) and not EvidenciasEncontradas["Escritura de fantasmas"] then
                                    local dn = string.lower(desc.Name)
                                    if string.find(dn, "writ") or string.find(dn, "ink") or string.find(dn, "scrib") or string.find(dn, "draw") then
                                        EvidenciasEncontradas["Escritura de fantasmas"] = true
                                        AddLog("⭐ EVIDENCIA: Escritura de fantasmas (Libro YA tenía marcas!)", Color3.fromRGB(255, 255, 0))
                                        pcall(ActualizarPizarraResolucion)
                                    end
                                end
                            end
                        end
                        
                        -- Buscar en Items del workspace
                        local items = workspace:FindFirstChild("Items")
                        if items then
                            for _, item in pairs(items:GetChildren()) do
                                MonitorearLibro(item)
                            end
                            items.ChildAdded:Connect(function(newItem)
                                task.wait(0.5)
                                MonitorearLibro(newItem)
                            end)
                        end
                        
                        -- También buscar por CollectionService
                        local CS = game:GetService("CollectionService")
                        for _, item in ipairs(CS:GetTagged("Item")) do
                            MonitorearLibro(item)
                        end
                    end)
                end
                
                -- ========================================================
                -- 🌸 MONITOR DE FLORES: Detectar Marchitar (Wither)
                -- ========================================================
                if not _G.FloresMonitoreadas then
                    _G.FloresMonitoreadas = true
                    pcall(function()
                        -- Buscar flores, plantas y objetos que marchitan en el mapa
                        for _, obj in pairs(workspace:GetDescendants()) do
                            local nl = string.lower(obj.Name)
                            if (string.find(nl, "flower") or string.find(nl, "plant") or string.find(nl, "vase") or string.find(nl, "wilt") or string.find(nl, "wither")) then
                                if obj:IsA("Model") or obj:IsA("BasePart") then
                                    -- Vigilar cambio de color/transparencia (marchitarse = cambio visual)
                                    if obj:IsA("BasePart") then
                                        obj:GetPropertyChangedSignal("Color"):Connect(function()
                                            if not EvidenciasEncontradas["Marchitar"] then
                                                EvidenciasEncontradas["Marchitar"] = true
                                                AddLog("⭐ EVIDENCIA OBTENIDA: Marchitar (Flor cambió de color!)", Color3.fromRGB(0, 255, 255))
                                                pcall(ActualizarPizarraResolucion)
                                            end
                                        end)
                                    end
                                    -- Vigilar atributo "Withered" o "Dead"
                                    pcall(function()
                                        obj:GetAttributeChangedSignal("Withered"):Connect(function()
                                            if obj:GetAttribute("Withered") == true and not EvidenciasEncontradas["Marchitar"] then
                                                EvidenciasEncontradas["Marchitar"] = true
                                                AddLog("⭐ EVIDENCIA OBTENIDA: Marchitar (Atributo 'Withered' Activado!)", Color3.fromRGB(0, 255, 255))
                                                pcall(ActualizarPizarraResolucion)
                                            end
                                        end)
                                    end)
                                end
                            end
                        end
                    end)
                end
                
                -- Spirit Box por chat (Preguntas del Código Fuente)
                AddLog("[CHAT] Interrogatorio al Spirit Box...", Color3.fromRGB(255, 150, 0))
                pcall(function()
                    local askSpirit = game.ReplicatedStorage.Events:FindFirstChild("AskSpiritBoxFromUI")
                    if askSpirit then 
                        askSpirit:FireServer("Where are you?")
                        task.wait(1.5)
                        askSpirit:FireServer("What do you want?")
                        task.wait(1.5)
                        askSpirit:FireServer("How long ago did you die?")
                    end
                end)
                pcall(function()
                    local tcs = game:GetService("TextChatService")
                    if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
                        tcs.TextChannels.RBXGeneral:SendAsync("Where are you?")
                    else
                        local req = game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest
                        req:FireServer("Where are you?", "All")
                    end
                end)
                
                -- ========================================================
                -- 🎯 V8.44: LECTOR DE OBJETIVOS + AUTO-COMPLETADOR
                -- ========================================================
                if not _G.ObjetivosHookeados then
                    _G.ObjetivosHookeados = true
                    -- Hook para saber cuándo se completa un objetivo
                    pcall(function()
                        local objCompleted = game.ReplicatedStorage.Events:FindFirstChild("ObjectiveCompleted")
                        if objCompleted then
                            objCompleted.OnClientEvent:Connect(function(idx)
                                AddLog("🎯 ¡OBJETIVO #" .. tostring(idx) .. " COMPLETADO! (+25$)", Color3.fromRGB(0, 255, 0))
                            end)
                        end
                    end)
                end
                
                -- Leer objetivos desde la GUI del teléfono
                pcall(function()
                    local phoneScreen = LP:WaitForChild("PlayerGui"):FindFirstChild("PhoneScreen")
                    if phoneScreen then
                        local container = phoneScreen:FindFirstChild("Container")
                        if container then
                            local screen = container:FindFirstChild("Screen")
                            if screen then
                                -- Buscar TextLabels que contengan descripciones de objetivos
                                for _, desc in pairs(screen:GetDescendants()) do
                                    if desc:IsA("TextLabel") and desc.Text and #desc.Text > 20 then
                                        local t = string.lower(desc.Text)
                                        -- Auto-completar lo que podemos
                                        if string.find(t, "photo") and string.find(t, "ghost") then
                                            AddLog("🎯 Objetivo detectado: FOTO DEL FANTASMA → Fraude fotográfico activo", Color3.fromRGB(255, 200, 0))
                                        elseif string.find(t, "emf") then
                                            AddLog("🎯 Objetivo detectado: EMF READER → Herramienta plantada", Color3.fromRGB(255, 200, 0))
                                        elseif string.find(t, "lidar") then
                                            AddLog("🎯 Objetivo detectado: LIDAR SCANNER → Spoof activo", Color3.fromRGB(255, 200, 0))
                                        elseif string.find(t, "energy") and string.find(t, "25") then
                                            AddLog("🎯 Objetivo detectado: ENERGÍA <25% → Se cumple solo con el tiempo", Color3.fromRGB(255, 200, 0))
                                        elseif string.find(t, "ghost event") or string.find(t, "experience") then
                                            AddLog("🎯 Objetivo detectado: EVENTO FANTASMA → Quédate en su cuarto", Color3.fromRGB(255, 200, 0))
                                        elseif string.find(t, "escape") and string.find(t, "hunt") then
                                            AddLog("🎯 Objetivo detectado: SOBREVIVIR CACERÍA → Escóndete cuando cace", Color3.fromRGB(255, 200, 0))
                                        elseif string.find(t, "cross") then
                                            AddLog("🎯 Objetivo detectado: QUEMAR CRUCIFIJO → Deja un Cross en el cuarto", Color3.fromRGB(255, 200, 0))
                                        elseif string.find(t, "cursed") then
                                            AddLog("🎯 Objetivo detectado: PROVOCAR CACERÍA MALDITA → Usa Music Box/Ouija", Color3.fromRGB(255, 200, 0))
                                        elseif string.find(t, "candle") then
                                            AddLog("🎯 Objetivo detectado: VELA APAGADA → Deja un Lighter+Vela en el cuarto", Color3.fromRGB(255, 200, 0))
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
                
                AddLog("━━━ CICLO COMPLETO - Esperando 15s ━━━", Color3.fromRGB(100, 100, 100))
                for waitIdx = 1, 15 do
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
                                    AddLog("❌ El creador ocultó los atributos en el modelo.", Color3.fromRGB(255, 50, 50))
                                else
                                    AddLog("✅ MIRA SI HAY UNA EVIDENCIA ESCONDIDA ARRIBA.", Color3.fromRGB(100, 255, 100))
                                end
                                
                                -- =======================================================
                                -- 🧠 V8.51: PERFILADO BIOLÓGICO Y ANATÓMICO ABSOLUTO
                                -- =======================================================
                                local esDullahan = false
                                
                                -- 1. Dar prioridad Suprema al Atributo del Motor si existe (Es la verdad absoluta)
                                local atrHeadless = obj:GetAttribute("Headless")
                                if atrHeadless ~= nil then
                                    esDullahan = atrHeadless
                                else
                                    -- Si el atributo fue borrado, usar respaldo analizando la física 3D
                                    local tieneCabeza = false
                                    for _, c in pairs(obj:GetDescendants()) do
                                        if c:IsA("BasePart") or c:IsA("MeshPart") then
                                            local n = string.lower(c.Name)
                                            if string.find(n, "head") and c.Transparency < 1 then
                                                tieneCabeza = true
                                                break
                                            end
                                        end
                                    end
                                    esDullahan = not tieneCabeza
                                end
                                
                                if esDullahan then
                                    AddLog("⚠️ ALERTA ANATÓMICA: ¡Atrofia biológica detectada (Sin Cabeza)!", Color3.fromRGB(255, 0, 0))
                                    AddLog("   └─> CULPABLE CASI SEGURO: DULLAHAN", Color3.fromRGB(255, 50, 50))
                                end
                                
                                -- Texturas/Caras Vistas
                                local face = obj:FindFirstChild("Head") and obj.Head:FindFirstChildOfClass("Decal")
                                if face and face.Texture ~= "" then
                                    AddLog("🎭 TEXTURA ASIGNADA: " .. tostring(face.Texture), Color3.fromRGB(0, 255, 255))
                                end
                                
                                -- =======================================================
                                -- 🚨 SISTEMA DE ALERTA TEMPRANA CONTRA ATAQUES
                                -- =======================================================
                                if not _G.HuntMonitorActivo then
                                    _G.HuntMonitorActivo = true
                                    obj.AttributeChanged:Connect(function(attr)
                                        local an = string.lower(attr)
                                        if string.find(an, "hunt") then
                                            _G.IsHunting = obj:GetAttribute(attr)
                                            if _G.IsHunting == true then
                                                AddLog("💀 ¡¡ALERTA MÁXIMA!! ¡EL FANTASMA ENTRÓ EN MODO CACERÍA!", Color3.fromRGB(255, 0, 0))
                                                
                                                -- 🚀 AUTO-EVASIÓN INMEDIATA 🚀
                                                pcall(function()
                                                    local hrp = LP.Character and LP.Character.PrimaryPart
                                                    if hrp then
                                                        local safeSpot = nil
                                                        for _, v in pairs(workspace:GetDescendants()) do
                                                            if v:IsA("SpawnLocation") then safeSpot = v.Position; break end
                                                        end
                                                        if not safeSpot then safeSpot = Vector3.new(0, 500, 0) end
                                                        hrp.CFrame = CFrame.new(safeSpot + Vector3.new(0, 3, 0))
                                                        AddLog("   └─> ¡AUTO-EVASIÓN ACTIVADA! Huyendo al Camión.", Color3.fromRGB(0, 255, 0))
                                                    end
                                                end)
                                            else
                                                AddLog("✅ CACERÍA FINALIZADA. Puedes salir del Camión.", Color3.fromRGB(150, 255, 150))
                                            end
                                        elseif string.find(an, "visible") or string.find(an, "reveal") then
                                            AddLog("👁️ EL FANTASMA ES VISIBLE AHORA MISMO: " .. tostring(obj:GetAttribute(attr)), Color3.fromRGB(255, 150, 0))
                                            
                                        -- 🚀 V8.60: SENSOR DE LÁSER INYECTADO AL ATRIBUTO BIOLÓGICO DEL ENTE
                                        elseif string.find(an, "laservisible") or string.find(an, "inlaser") then
                                            if obj:GetAttribute(attr) == true and not EvidenciasEncontradas["Proyector láser"] then
                                                EvidenciasEncontradas["Proyector láser"] = true
                                                AddLog("⭐ EVIDENCIA OBTENIDA AUTOMÁTICAMENTE: Proyector Láser (El Motor del Servidor confesó la interacción láser!)", Color3.fromRGB(255, 255, 0))
                                                pcall(ActualizarPizarraResolucion)
                                            end
                                        end
                                    end)
                                    
                                    -- Chequear si la partida entera (workspace) entra en hunt
                                    workspace.AttributeChanged:Connect(function(attr)
                                        local an = string.lower(attr)
                                        if string.find(an, "hunt") then
                                            _G.IsHunting = workspace:GetAttribute(attr)
                                            if _G.IsHunting == true then
                                                AddLog("💀 ¡¡ALERTA GLOBAL!! ¡INICIO DE CACERÍA (Workspace)!", Color3.fromRGB(255, 0, 0))
                                                pcall(function()
                                                    local hrp = LP.Character and LP.Character.PrimaryPart
                                                    if hrp then
                                                        local safeSpot = nil
                                                        for _, v in pairs(workspace:GetDescendants()) do
                                                            if v:IsA("SpawnLocation") then safeSpot = v.Position; break end
                                                        end
                                                        if not safeSpot then safeSpot = Vector3.new(0, 500, 0) end
                                                        hrp.CFrame = CFrame.new(safeSpot + Vector3.new(0, 3, 0))
                                                        AddLog("   └─> ¡AUTO-EVASIÓN GLOBAL ACTIVADA!", Color3.fromRGB(0, 255, 0))
                                                    end
                                                end)
                                            end
                                        end
                                    end)
                                end
                                
                                -- Hook Conductual de Sonido y Físicas (Solo se inyecta una vez)
                                if not _G.ConductaHookeada then
                                    _G.ConductaHookeada = true
                                    workspace.DescendantAdded:Connect(function(desc)
                                        pcall(function()
                                            -- Detectar Lamentos Personalizados (Skinwalker / Banshee)
                                            if desc:IsA("Sound") and desc.Name == "Hunt" then
                                                if desc.PlaybackSpeed > 1 then
                                                    AddLog("⚠️ ALERTA ACÚSTICA: 'Ghost Wail' (Grito Especial) Detectado!", Color3.fromRGB(255, 0, 0))
                                                    AddLog("   └─> CULPABLE POSIBLE: BANSHEE o SKINWALKER", Color3.fromRGB(255, 50, 50))
                                                end
                                            end
                                            
                                            -- Detectar Cristales/Espejos Rotos (Banshee) - Evitar pasos y huesos
                                            if desc:IsA("Sound") then
                                                local sn = string.lower(desc.Name)
                                                if not string.find(sn, "footstep") and not string.find(sn, "step") and not string.find(sn, "bone") then
                                                    if string.find(sn, "glass") or string.find(sn, "shatter") or string.find(sn, "break") then
                                                        AddLog("⚠️ ALERTA FÍSICA: ¡Cristal o Espejo Roto! (" .. desc.Name .. ")", Color3.fromRGB(255, 0, 0))
                                                        AddLog("   └─> CULPABLE CASI SEGURO: BANSHEE", Color3.fromRGB(255, 50, 50))
                                                    end
                                                end
                                            end
                                            
                                            -- 🚀 V8.50: AUTO-DETECTAR EVIDENCIAS FÍSICAS EXTREMAS
                                            local dn = string.lower(desc.Name)
                                            -- 1. Orbe Fantasma (Usualmente partículas o partes spawnadas en el cuarto)
                                            if string.find(dn, "ghostorb") or string.find(dn, "orbparticle") or dn == "orb" then
                                                if not EvidenciasEncontradas["Orbe Fantasma"] then
                                                    EvidenciasEncontradas["Orbe Fantasma"] = true
                                                    AddLog("⭐ EVIDENCIA OBTENIDA AUTOMÁTICAMENTE: Orbe Fantasma (Detectado en 3D)", Color3.fromRGB(255, 255, 0))
                                                    pcall(ActualizarPizarraResolucion)
                                                end
                                            end
                                            
                                            -- 2. Huellas Dactilares (Decals o Partes en puertas/ventanas)
                                            if string.find(dn, "handprint") or string.find(dn, "fingerprint") or string.find(dn, "footprint") then
                                                if not EvidenciasEncontradas["Huellas Dactilares"] then
                                                    EvidenciasEncontradas["Huellas Dactilares"] = true
                                                    AddLog("⭐ EVIDENCIA OBTENIDA AUTOMÁTICAMENTE: Huellas Dactilares (Decal detectado)", Color3.fromRGB(255, 255, 0))
                                                    pcall(ActualizarPizarraResolucion)
                                                end
                                            end
                                            
                                            -- 3. Proyector Láser (El fantasma crea un clon silueta interactuando con el DOTS)
                                            if desc:IsA("Model") and (string.find(dn, "silhouette") or string.find(dn, "laserghost") or string.find(dn, "dots")) then
                                                if not EvidenciasEncontradas["Proyector láser"] then
                                                    EvidenciasEncontradas["Proyector láser"] = true
                                                    AddLog("⭐ EVIDENCIA OBTENIDA AUTOMÁTICAMENTE: Proyector Láser (Silueta interceptada)", Color3.fromRGB(255, 255, 0))
                                                    pcall(ActualizarPizarraResolucion)
                                                end
                                            end
                                            
                                            -- Eliminado el monitoreo ciego de Decals del Libro para evitar Falsos Positivos cuando se suelta al piso con texturas de portada.
                                        end)
                                    end)
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
                            if item:GetAttribute("ReadingLevel") or item:GetAttribute("EMFLevel") then
                                local lvl = tonumber(item:GetAttribute("ReadingLevel") or item:GetAttribute("EMFLevel"))
                                if lvl and lvl >= 5 and not EvidenciasEncontradas["Nivel EMF 5"] then
                                    EvidenciasEncontradas["Nivel EMF 5"] = true
                                    ActualizarPizarraResolucion()
                                    AddLog("⭐ EVIDENCIA OBTENIDA: Nivel EMF 5 (Atributo 'ReadingLevel' en Placa Base)", Color3.fromRGB(255, 0, 0))
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
                                        if string.find(dName, "writ") or string.find(dName, "text") or string.find(dName, "mess") or string.find(dName, "scrib") or string.find(dName, "ink") or string.find(dName, "draw") then
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
                
                -- V8.26b: Interceptor Radiactivo del Spirit Box Total (ShowSubtitle Event local y de red)
                pcall(function()
                    local RS = game:GetService("ReplicatedStorage")
                    if RS:FindFirstChild("Events") and RS.Events:FindFirstChild("ShowSubtitle") and not _G.SpiritBoxInterceptado then
                        _G.SpiritBoxInterceptado = true
                        local function OnSubtitle(msg)
                            if msg then
                                local t = string.lower(tostring(msg))
                                -- El Spirit Box responde con palabras específicas. 
                                -- Respuestas conocidas: "here", "leave", "kill", "die", "elder", "child", "teen", "adult", "far", "behind"
                                -- Ignoramos acciones (que llevan "> <" como "> Glass Breaking <")
                                if string.find(t, "<") and string.find(t, ">") then return end
                                
                                if string.find(t, "where") or string.find(t, "near") or string.find(t, "here") or string.find(t, "old") or string.find(t, "die") or string.find(t, "alive") or string.find(t, "behind") or string.find(t, "kill") or string.find(t, "leave") or string.find(t, "hate") or string.find(t, "elder") or string.find(t, "child") or string.find(t, "teen") or string.find(t, "adult") or string.find(t, "far") or string.find(t, "close") then
                                    AddLog("🎤 [ESPÍRITU RESPONDIÓ (SUBTÍTULO)]: " .. tostring(msg), Color3.fromRGB(200, 150, 255))
                                    if not EvidenciasEncontradas["Caja de Espíritus"] then
                                        EvidenciasEncontradas["Caja de Espíritus"] = true
                                        pcall(ActualizarPizarraResolucion)
                                        AddLog("⭐ EVIDENCIA OBTENIDA: Caja de Espíritus (Respuesta)", Color3.fromRGB(0, 255, 0))
                                    end
                                end
                            end
                        end
                        -- Atacar ambos (RemoteEvent y BindableEvent) porque no sabemos dónde lo envían exactamente.
                        if RS.Events.ShowSubtitle:IsA("RemoteEvent") then
                            RS.Events.ShowSubtitle.OnClientEvent:Connect(OnSubtitle)
                        elseif RS.Events.ShowSubtitle:IsA("BindableEvent") then
                            RS.Events.ShowSubtitle.Event:Connect(OnSubtitle)
                        end
                    end
                end)
                
                -- V8.98: Hook de Fuerza Bruta sobre el AUDIO del Spirit Box (Ventana de Detección en Tone).
                pcall(function()
                    if not _G.SpiritBoxAudioInterceptado then
                        _G.SpiritBoxAudioInterceptado = true
                        
                        local function InyectarBox(box)
                            pcall(function()
                                local t = box:WaitForChild("Handle", 2):WaitForChild("Tone", 2)
                                if t then
                                    -- Detectar cambio de Audio
                                    t:GetPropertyChangedSignal("SoundId"):Connect(function()
                                        if string.len(t.SoundId) > 5 then
                                            AddLog("🎤 [AUDIO DETECTADO]: Cambio de Frecuencia -> " .. tostring(t.SoundId), Color3.fromRGB(200, 150, 255))
                                            if not EvidenciasEncontradas["Caja de Espíritus"] then
                                                EvidenciasEncontradas["Caja de Espíritus"] = true
                                                pcall(ActualizarPizarraResolucion)
                                            end
                                        end
                                    end)
                                    -- Detectar cuando el servidor presiona "Play()" en la herramienta
                                    t:GetPropertyChangedSignal("Playing"):Connect(function()
                                        if t.Playing == true then
                                            AddLog("🎤 [TONE ACTIVO]: Emisión de voz fantasma física detectada.", Color3.fromRGB(200, 150, 255))
                                            if not EvidenciasEncontradas["Caja de Espíritus"] then
                                                EvidenciasEncontradas["Caja de Espíritus"] = true
                                                pcall(ActualizarPizarraResolucion)
                                            end
                                        end
                                    end)
                                end
                            end)
                        end
                        
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj:IsA("Model") and obj:GetAttribute("ItemName") == "Spirit Box" then InyectarBox(obj) end
                        end
                        workspace.DescendantAdded:Connect(function(obj)
                            if obj:IsA("Model") and obj:GetAttribute("ItemName") == "Spirit Box" then InyectarBox(obj) end
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

BtnDump.Text = "🧠 DEEP SCAN (DESCOMPILAR)"
BtnDump.BackgroundColor3 = Color3.fromRGB(60, 20, 100)
BtnDump.MouseButton1Click:Connect(function()
    AddLog("━━━ DEEP SCAN V8.28 (DESCOMPILADOR) ━━━", Color3.fromRGB(200, 100, 255))
    AddLog("🔎 Extrayendo Código Fuente y Jerarquía de Módulos...", Color3.fromRGB(200, 200, 0))
    
    task.spawn(function()
        if writefile or appendfile then
            local t = "\n============================================================\n"
            t = t .. "🧠 DEMONOLOGY EXPORTACIÓN JERÁRQUICA: MÓDULOS DE JUEGO Y ARMAS\n"
            t = t .. "FECHA: " .. os.date("%c") .. "\n"
            t = t .. "============================================================\n\n"
            
            pcall(function() if appendfile then appendfile("OjoDeDios_DeepLog.txt", t) end end)
            
            local scriptsCount = 0
            for _, obj in pairs(game:GetDescendants()) do
                if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                    -- Filtrar el propio roblox core
                    if not string.find(obj:GetFullName(), "CoreGui") and not string.find(obj:GetFullName(), "CorePackages") then
                        scriptsCount = scriptsCount + 1
                        local treeData = "\n[+] " .. obj.ClassName .. " | Ubicación Jerárquica: " .. obj:GetFullName() .. "\n"
                        
                        -- Intentar ingeniería inversa al texto crudo si el Executor tiene permisos Nivel 7
                        pcall(function()
                            if decompile then
                                local source = decompile(obj)
                                if source and source ~= "" then
                                    treeData = treeData .. "--- CÓDIGO FUENTE ("..obj.Name..") ---\n"
                                    treeData = treeData .. source .. "\n"
                                    treeData = treeData .. "--- FIN DE " .. obj.Name .. " ---\n"
                                else
                                    treeData = treeData .. "   └─> [Bloqueado por Obfuscación o Vacio]\n"
                                end
                            else
                                treeData = treeData .. "   └─> [Tu executor actual no soporta descompilación (decompile() no encontrado)]\n"
                            end
                        end)
                        
                        -- Guardar en disco progresivamente para evitar colapso de RAM
                        pcall(function() if appendfile then appendfile("OjoDeDios_DeepLog.txt", treeData) end end)
                    end
                end
            end
            AddLog("✅ ¡Exportación Completada! ("..scriptsCount.." Módulos rastreados). Revisa el .txt.", Color3.fromRGB(100, 255, 100))
            AddLog("   └─> Cierra el juego si sientes lag. Todo está seguro en tu disco.", Color3.fromRGB(150, 255, 150))
        else
            AddLog("❌ ERROR: Tu executor no tiene permisos de lectura/escritura (writefile).", Color3.fromRGB(255, 50, 50))
        end
    end)
end)
