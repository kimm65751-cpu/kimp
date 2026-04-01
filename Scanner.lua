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
local BtnClearTags = CreateUIBtn(160, "🧹 LIMPIAR ESP", Color3.fromRGB(30, 30, 30))

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
BoardTitle.Size = UDim2.new(1, 0, 0, 25)
BoardTitle.BackgroundTransparency = 1
BoardTitle.Text = " 📜 EVIDENCIAS CONFIRMADAS "
BoardTitle.TextColor3 = Color3.fromRGB(100, 255, 100)
BoardTitle.Font = Enum.Font.Code; BoardTitle.TextSize = 13
BoardTitle.TextXAlignment = Enum.TextXAlignment.Center
BoardTitle.Parent = BoardBG

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
        end
    end
    if posibles == 1 then
        BoardTitle.Text = " 🏆 ¡FANTASMA DESCUBIERTO! "
        BoardTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
    else
        BoardTitle.Text = " 📜 RESOLVIENDO CASO... "
        BoardTitle.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
end

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

BtnClearTags.MouseButton1Click:Connect(function()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "_SR_Tag" or v.Name == "_SR_Text" then v:Destroy() end
    end
end)

-- 1. OJO DE DIOS (FANTASMA Y SU HABITACIÓN)
local EspFantasma = false
BtnESP.MouseButton1Click:Connect(function()
    EspFantasma = not EspFantasma
    if EspFantasma then
        BtnESP.Text = "👁️ ESP FANTASMA: ON"
        BtnESP.BackgroundColor3 = Color3.fromRGB(120, 20, 40)
        task.spawn(function()
            while EspFantasma do
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj ~= LP.Character then
                        local nl = string.lower(obj.Name)
                        if nl == "ghost" or nl == "entity" or nl == "demon" or nl == "monster" then
                            local favRoom = obj:GetAttribute("FavoriteRoom") or "Desconocida"
                            ApplyESPTag(obj, "👻 FANTASMA ("..favRoom..")", Color3.fromRGB(255, 0, 0), false)
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
                        -- Huesos
                        if string.find(nl, "bone") or string.find(nl, "hueso") then
                            ApplyESPTag(obj, "🦴 HUESO", Color3.fromRGB(255, 255, 0), false)
                        end
                        -- Objetos Malditos (Tarot, Ouija, Espejo, Voodoo, Musica)
                        if string.find(nl, "tarot") or string.find(nl, "board") or string.find(nl, "ouija") or string.find(nl, "voodoo") or string.find(nl, "mirror") or string.find(nl, "music") then
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
