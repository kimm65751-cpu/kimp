-- =====================================================================
-- 👁️ DEMONOLOGY: FORENSIC NETWORK & INSTANCE ANALYZER (ZERO-DAY) 👁️
-- =====================================================================
-- Creado para: Análisis profundo de Mátrix y Mecánicas de Inyección
-- Descripción: Este script desmitifica cómo el servidor genera las 
-- pistas escondidas, espía los eventos de red de tu cliente e intenta
-- hackear el rango de efectividad de cualquier módulo en memoria.
-- =====================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- ==========================================
-- 🗄️ 0. SISTEMA AUTO-INCREMENTAL DE LOGS TXT
-- ==========================================
local fileIndex = 1
if isfile then
    while isfile("anty_" .. fileIndex .. ".txt") do
        fileIndex = fileIndex + 1
    end
end
local LogFileName = "anty_" .. fileIndex .. ".txt"

if writefile then
    pcall(function() writefile(LogFileName, "=== INICIO DE FORENSE DEMONOLOGY (" .. os.date("%x %X") .. ") ===\n") end)
end

-- ==========================================
-- 🖥️ 1. INTERFAZ GRÁFICA (CONSOLA EN VIVO)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ForenseScannerUI"
ScreenGui.ResetOnSpawn = false
-- Proteger la GUI de reportes del juego si es posible
if gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 450)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 100)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(0, 50, 20)
Title.TextColor3 = Color3.fromRGB(0, 255, 100)
Title.TextSize = 16
Title.Font = Enum.Font.Code
Title.Text = " 👁️ ESCÁNER FORENSE CIBERNÉTICO ("..LogFileName..")"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -10, 1, -40)
LogScroll.Position = UDim2.new(0, 5, 0, 35)
LogScroll.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
LogScroll.ScrollBarThickness = 6
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 2)
UIListLayout.Parent = LogScroll

local LogEntries = 0
local MaxLogs = 1000

local function AddLog(texto, color)
    local timestamp = os.date("%X")
    LogEntries = LogEntries + 1
    
    local entry = Instance.new("TextLabel")
    entry.Size = UDim2.new(1, 0, 0, 18)
    entry.BackgroundTransparency = 1
    entry.Text = "[" .. timestamp .. "] " .. texto
    entry.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    entry.TextSize = 13
    entry.Font = Enum.Font.Code
    entry.TextXAlignment = Enum.TextXAlignment.Left
    entry.TextWrapped = true
    entry.LayoutOrder = LogEntries
    entry.Parent = LogScroll
    
    LogScroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    LogScroll.CanvasPosition = Vector2.new(0, LogScroll.CanvasSize.Y.Offset)
    
    -- Escribir al archivo incremental
    if appendfile then
        pcall(function() appendfile(LogFileName, "[" .. timestamp .. "] " .. texto .. "\n") end)
    end
    
    -- Mecanismo para no quemar la RAM del executor
    if LogEntries > MaxLogs then
        local oldest = nil
        for _, child in pairs(LogScroll:GetChildren()) do
            if child:IsA("TextLabel") then
                if not oldest or child.LayoutOrder < oldest.LayoutOrder then
                    oldest = child
                end
            end
        end
        if oldest then oldest:Destroy() end
    end
end

AddLog("Iniciando Módulos de Interceptación Profunda...", Color3.fromRGB(0, 255, 255))

-- ==========================================
-- 📡 2. INTERCEPTOR DE RED (__namecall HOOK)
-- ==========================================
-- Nos chivará todo lo que tu cuenta le solicite al Servidor (FireServer/InvokeServer)
-- Esto descubre exploits de "DropItem", "UseTool", etc.

pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Ignoramos las llamadas nativas del Executor (checkcaller), solo queremos las que envía el juego
        if not checkcaller() then
            if method == "FireServer" or method == "InvokeServer" then
                local objName = tostring(self.Name)
                
                -- Filtrar ruido de red normal (Sistemas de movimiento o mouse aburridos)
                if not string.find(string.lower(objName), "move") and not string.find(string.lower(objName), "mouse") and not string.find(objName, "Update") then
                    local argStr = ""
                    for i, v in ipairs(args) do
                        argStr = argStr .. tostring(v) .. " | "
                    end
                    if argStr == "" then argStr = "[Ningún Flag]" end
                    AddLog("📡 [TÓXICO] Mando evento al Servidor: [" .. objName .. "] Datos: " .. argStr, Color3.fromRGB(255, 150, 0))
                end
            end
        end
        return oldNamecall(self, ...)
    end)
    AddLog("Capa de Espionaje de Red (Namecall): ACTIVA e indetectable.", Color3.fromRGB(0, 255, 100))
end)

-- ==========================================
-- 🔬 3. MONITOR DE INYECCIÓN DE OBJETOS (ESTOCÁSTICO)
-- ==========================================
-- Esto te avisará al instante de que "algo" nació en el mapa por parte del Servidor.

local function AnalyzeNewObject(obj)
    -- Evitar escanear las partes del mapa base y de tu personaje para evitar lag
    if obj:IsDescendantOf(LP.Character) then return end

    local n = string.lower(obj.Name)
    local p = obj.Parent and obj.Parent.Name or "Unknown"
    
    -- 🦇 ENTIDADES: ¿Nació un fantasma?
    if n == "ghost" or n == "entity" or n == "demon" or obj:GetAttribute("IsGhost") then
        AddLog("👻 [GENERACIÓN] Servidor inyectó Entidad: " .. obj.Name .. " dentro de [" .. p .. "]", Color3.fromRGB(255, 0, 0))
        
        -- Extraer su ADN (Atributos ocultos en tiempo real)
        obj.AttributeChanged:Connect(function(attr)
            AddLog("🧬 ["..obj.Name.."] El Servidor mutó Atributo interno: '" .. attr .. "' a -> " .. tostring(obj:GetAttribute(attr)), Color3.fromRGB(255, 100, 100))
        end)
    end
    
    -- ✨ EVIDENCIAS VFX: Orbes, Manchas, Huellas.
    if string.find(n, "orb") or string.find(n, "evidence") or string.find(n, "clue") then
        AddLog("✨ [INYECCIÓN] Apareció una Pista Dinámica: " .. obj.Name .. " en la carpeta [" .. p .. "]", Color3.fromRGB(0, 255, 255))
        
        -- MARCADOR FORENSE: Pintaremos este objeto sospechoso de MAGENTA RADIACTIVO
        if obj:IsA("BasePart") then
            obj.Color = Color3.fromRGB(255, 0, 255)
            obj.Material = Enum.Material.Neon
            obj.Size = Vector3.new(obj.Size.X, obj.Size.Y, obj.Size.Z) + Vector3.new(1,1,1)
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(0, 255, 255)
            highlight.Parent = obj
        end
    end
    
    -- 🔊 CREADOR DE VOCES INVISIBLES (Spiritbox, Lamentos cazando)
    if obj:IsA("Sound") and (string.find(n, "wail") or string.find(n, "hunt") or string.find(n, "spirit") or string.find(n, "voice")) then
        AddLog("🔊 [INYECCIÓN AUDIO] Servidor creó Archivo Sonido: " .. obj.Name .. " | ID: " .. tostring(obj.SoundId), Color3.fromRGB(200, 150, 255))
    end
    
    -- 🖐️ TEXTURAS GENERADAS (Huellas o Sangre)
    if obj:IsA("Decal") and p ~= "Unknown" then
        if string.find(n, "print") or string.find(n, "finger") or string.find(n, "hand") then
            AddLog("🖐️ [EVIDENCIA TEXTURA] El Servidor imprimió textura gráfica en: " .. p, Color3.fromRGB(255, 255, 0))
        end
    end
end

-- Lo aplicamos todo al inicio...
for _, obj in pairs(workspace:GetDescendants()) do
    AnalyzeNewObject(obj)
end

-- Y dejamos el radar escuchando el resto de la partida
workspace.DescendantAdded:Connect(AnalyzeNewObject)
ReplicatedStorage.DescendantAdded:Connect(AnalyzeNewObject)
AddLog("Capa Estocástica (Monitor de Nacimientos): ACTIVA.", Color3.fromRGB(0, 255, 100))

-- ==========================================
-- 🛠️ 4. BYPASS DE MÓDULOS DE HERRAMIENTAS (RANGO GLOBAL)
-- ==========================================
-- Escarbamos la memoria del juego buscando todos los módulos que el desarrollador intentó ocultar
AddLog("Realizando Autopsia a Memoria de Juego (Escarbando GC)...", Color3.fromRGB(150, 150, 150))

task.spawn(function()
    pcall(function()
        for i, v in pairs(getgc(true)) do
            if type(v) == "table" then
                -- 🚀 HACK DE EFECTIVIDAD Y RANGO: Módulos de Herramientas
                if rawget(v, "EffectivenessRange") then
                    local oldRange = v.EffectivenessRange
                    v.EffectivenessRange = 99999 -- Hack de Rango Masivo (Abarca todo el mapa)
                    if rawget(v, "Name") then
                        AddLog("💥 [TOOL HACK] Hardware '"..tostring(v.Name).."' Rango re-ensamblado: " .. tostring(oldRange) .. " -> 99999", Color3.fromRGB(0, 255, 0))
                    else
                        AddLog("💥 [TOOL HACK] Hardware Desconocido. Rango re-ensamblado a 99999.", Color3.fromRGB(0, 255, 0))
                    end
                end
                
                -- 🏆 LECTOR MENTAL DE SEMILLA DE PARTIDA:
                -- Buscar si hay alguna tabla con "GhostType", "SelectedGhost", o "MatchSeed"
                if rawget(v, "SelectedGhost") or rawget(v, "GhostType") then
                    AddLog("🧠 [SANTO GRIAL ENCONTRADO] ¡La Memoria del Servidor confesó!: " .. tostring(v.SelectedGhost or v.GhostType), Color3.fromRGB(255, 215, 0))
                end
                
                -- Alteración de Temperaturas Nativas
                if rawget(v, "RoomTemperature") then
                    AddLog("❄️ [TERMÓMETRO DEV] Temperatura base de mapa grabada: " .. tostring(v.RoomTemperature), Color3.fromRGB(100, 200, 255))
                end
            end
        end
        AddLog("Autopsia a Recolección de Basura (GC) Completada.", Color3.fromRGB(100, 255, 100))
    end)
end)

-- ==========================================
-- 📜 5. ATRIBUTOS GLOBALES
-- ==========================================
game.ReplicatedStorage.AttributeChanged:Connect(function(attr)
    AddLog("🌐 [HACKEO SERVIDOR] Atributo Global Mutado: " .. attr .. " -> " .. tostring(game.ReplicatedStorage:GetAttribute(attr)), Color3.fromRGB(100, 100, 255))
end)

AddLog("=====================================", Color3.fromRGB(50, 50, 50))
AddLog("🕵️ FORENSE PREPARADO. Entra al mapa para leer código duro.", Color3.fromRGB(0, 255, 0))
