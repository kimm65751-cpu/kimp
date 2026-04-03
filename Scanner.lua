-- ==============================================================================
-- 🧠 OMNI-SCANNER PRO V2.0 - REVERSE ENGINEERING & ARCHITECTURE MAPPER
-- Diseñado para Ingeniería Inversa Local (Localhost MMORPG/RPG)
-- Mapea rutas, extrae configuraciones (Armas, Mobs, Ciudades), e intenta descompilar.
-- ==============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer

-- ==============================================================================
-- Utilidades Base (Archivos y Log)
-- ==============================================================================
local function getNextFileName(base)
    local i = 1
    while true do
        local name = base .. "_" .. i .. ".txt"
        local exists = false
        pcall(function() exists = isfile(name) end)
        if not exists then return name end
        i = i + 1
    end
end

local logs = {}
local function log(text, indent)
    local prefix = string.rep("  ", indent or 0)
    table.insert(logs, prefix .. text)
end

local function export(baseName)
    local fn = getNextFileName(baseName)
    pcall(function() writefile(fn, table.concat(logs, "\n")) end)
    logs = {}
    return fn
end

-- ==============================================================================
-- GUI
-- ==============================================================================
local TargetGui = pcall(function() return CoreGui.Name end) and CoreGui or LP:WaitForChild("PlayerGui")
for _, v in pairs(TargetGui:GetChildren()) do if v.Name == "OmniScannerPro" then pcall(function() v:Destroy() end) end end

local SG = Instance.new("ScreenGui")
SG.Name = "OmniScannerPro"
SG.ResetOnSpawn = false
SG.Parent = TargetGui

local MF = Instance.new("Frame", SG)
MF.Size = UDim2.new(0, 500, 0, 480)
MF.Position = UDim2.new(0.35, 0, 0.15, 0)
MF.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MF.BorderSizePixel = 2
MF.BorderColor3 = Color3.fromRGB(255, 100, 50)
MF.Active = true
MF.Draggable = true

local Title = Instance.new("TextLabel", MF)
Title.Size = UDim2.new(1, 0, 0, 26)
Title.BackgroundColor3 = Color3.fromRGB(50, 10, 10)
Title.Text = " 🧠 OMNI-SCANNER PRO (MAPA MENTAL Y CÓDIGO)"
Title.TextColor3 = Color3.fromRGB(255, 150, 100)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left

local LogFrame = Instance.new("ScrollingFrame", MF)
LogFrame.Size = UDim2.new(1, -10, 0, 260)
LogFrame.Position = UDim2.new(0, 5, 0, 30)
LogFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LogFrame.ScrollBarThickness = 4
LogFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", LogFrame).SortOrder = Enum.SortOrder.LayoutOrder

local lc = 0
local function guiLog(t, c)
    lc = lc + 1
    local m = Instance.new("TextLabel", LogFrame)
    m.Size = UDim2.new(1, 0, 0, 14)
    m.BackgroundTransparency = 1
    m.Text = "["..os.date("%X").."] "..t
    m.TextXAlignment = Enum.TextXAlignment.Left
    m.TextColor3 = c or Color3.fromRGB(200, 200, 200)
    m.Font = Enum.Font.Code
    m.TextSize = 11
    m.TextWrapped = true
    m.AutomaticSize = Enum.AutomaticSize.Y
    m.LayoutOrder = lc
    LogFrame.CanvasPosition = Vector2.new(0, 99999)
end

local function MkBtn(txt, py)
    local b = Instance.new("TextButton", MF)
    b.Size = UDim2.new(0.92, 0, 0, 30)
    b.Position = UDim2.new(0.04, 0, 0, py)
    b.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 11
    b.Text = txt
    return b
end

local btnConfigs = MkBtn("📦 1. EXTRAER CONFIGURACIONES (Armas, Mobs, Datos)", 300)
local btnMindMap = MkBtn("🕸️ 2. MAPA MENTAL Y DEPENDENCIAS (Quién usa a quién)", 340)
local btnDecomp  = MkBtn("⚙️ 3. EXTRAER/DESCOMPILAR CÓDIGO DE JUEGO", 380)

-- ==============================================================================
-- MOTOR DE EXTRACCIÓN PROFUNDA (DUMPING)
-- ==============================================================================
local function DeepDumpTable(tbl, name, maxDepth, currentDepth, visited)
    currentDepth = currentDepth or 0
    visited = visited or {}
    
    if currentDepth > maxDepth then return end
    if type(tbl) ~= "table" then return end
    if visited[tbl] then return end
    visited[tbl] = true

    for k, v in pairs(tbl) do
        local keyType = type(k)
        local valType = type(v)
        local displayKey = tostring(k)
        
        if valType == "table" then
            log("[" .. displayKey .. "] (Table) {", currentDepth)
            DeepDumpTable(v, displayKey, maxDepth, currentDepth + 1, visited)
            log("}", currentDepth)
        elseif valType == "string" then
            log("[" .. displayKey .. "] = '" .. v .. "'", currentDepth)
        elseif valType == "number" or valType == "boolean" then
            log("[" .. displayKey .. "] = " .. tostring(v), currentDepth)
        elseif valType == "function" then
            log("[" .. displayKey .. "] = function()", currentDepth)
        else
            log("[" .. displayKey .. "] = " .. valType, currentDepth)
        end
    end
end

-- ==============================================================================
-- [1] EXTRACCIÓN DE DATOS Y CONFIGURACIONES (REQUIRE DUMP)
-- ==============================================================================
btnConfigs.MouseButton1Click:Connect(function()
    guiLog("Comenzando extracción global de configuraciones...", Color3.fromRGB(0, 255, 255))
    task.spawn(function()
        log("====================================================================")
        log("📦 REPORTE DE CONFIGURACIONES INTERNAS Y DATOS (RPG/MMO BASE)")
        log("====================================================================")
        
        local modulesFound = 0
        local dataFound = 0

        -- Base de datos experta: Busca palabras clave en los módulos para priorizarlos
        local rpgKeys = {
            "mob", "boss", "weapon", "config", "data", "pet", "quest", "level", "npc", "city", 
            "map", "skill", "item", "gem", "race", "setting", "stat", "event", "island", "isla", 
            "fly", "vuelo", "speed", "jump", "salto", "reroll", "roll", "gacha", "fragment", 
            "shard", "money", "coin", "sword", "accessory", "melee", "key", "llave", "seal", 
            "drop", "moon slayer", "moon", "slayer", "power"
        }

        local function analyzeModule(mod)
            local lowerName = mod.Name:lower()
            local isImportant = false
            for _, k in ipairs(rpgKeys) do
                if lowerName:find(k) then isImportant = true; break end
            end
            
            if isImportant then
                local success, result = pcall(function() return require(mod) end)
                if success and type(result) == "table" then
                    log("\n[+] MODULO IMPORTANTE DE DATOS: " .. mod:GetFullName())
                    DeepDumpTable(result, mod.Name, 3, 1) -- Hasta profundidad 3 para no explotar memoria
                    dataFound = dataFound + 1
                end
            end
            modulesFound = modulesFound + 1
            if modulesFound % 30 == 0 then task.wait(0.1) end
        end

        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("ModuleScript") then analyzeModule(obj) end
        end

        log("\nTOTAL MODULOS ANALIZADOS: " .. modulesFound)
        log("TOTAL CONFIGURACIONES DE DATOS EXTRAIDAS: " .. dataFound)
        
        -- ANÁLISIS DE FÍSICAS LOCALES (Volar, Velocidad, Doble Salto)
        log("\n====================================================================")
        log("🏃‍♂️ LÍMITES FÍSICOS Y ESTADO ACTUAL DEL JUGADOR")
        log("====================================================================")
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            local hum = LP.Character.Humanoid
            log("Velocidad Base (WalkSpeed): " .. tostring(hum.WalkSpeed))
            log("Fuerza de Salto (JumpPower): " .. tostring(hum.JumpPower))
            log("Altura de Salto (JumpHeight): " .. tostring(hum.JumpHeight))
            log("Salto Activado (UseJumpPower): " .. tostring(hum.UseJumpPower))
        else
            log("Personaje no encontrado aún. No pudimos leer WalkSpeed.")
        end
        
        local fn = export("OmniConfigData")
        guiLog("✅ Datos extraídos (Misiones, Armas, Ciudades).", Color3.fromRGB(0, 255, 0))
        guiLog("💾 Guardado en: " .. fn, Color3.fromRGB(0, 255, 0))
    end)
end)

-- ==============================================================================
-- [2] CONSTRUCCIÓN DE MAPA MENTAL (DEPENDENCE MAP) Y JERARQUÍA
-- ==============================================================================
btnMindMap.MouseButton1Click:Connect(function()
    guiLog("Generando mapa de arquitectura y ramas de conexión...", Color3.fromRGB(200, 100, 255))
    task.spawn(function()
        log("====================================================================")
        log("🕸️ MAPA MENTAL Y JERARQUÍA DEL JUEGO (ARCHITECTURE GRAPH)")
        log("====================================================================")

        -- Función recursiva para mapear la conexión GUI -> Sistema -> Red -> Componentes
        local function mapHierarchy(parent, depth)
            if depth > 5 then return end
            for _, v in pairs(parent:GetChildren()) do
                -- Solo mostrar carpetas, modulos y remotos para el mapa mental
                if v:IsA("Folder") or v:IsA("ModuleScript") or v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                    local sym = v:IsA("Folder") and "📂" or (v:IsA("ModuleScript") and "⚙️" or "📡")
                    log(sym .. " " .. v.Name, depth)
                    mapHierarchy(v, depth + 1)
                end
            end
            task.wait(0.01)
        end

        log("\n=== 1. JERARQUÍA DEL NÚCLEO DE RED (ReplicatedStorage) ===")
        mapHierarchy(ReplicatedStorage, 0)

        log("\n=== 2. CONTROLADORES DEL CLIENTE (PlayerScripts) ===")
        local ps = LP:WaitForChild("PlayerScripts", 2)
        if ps then mapHierarchy(ps, 0) end

        -- Análisis dinámico de conexiones (¿Quién llama a qué servidor?)
        log("\n=== 3. ANÁLISIS DE RUTAS DE RETORNO Y ENDPOINTS ===")
        for _, rem in pairs(ReplicatedStorage:GetDescendants()) do
            if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                local typePrefix = rem:IsA("RemoteEvent") and "[Unidireccional]" or "[Bidireccional]"
                log("📡 ENDPOINT: " .. typePrefix .. " " .. rem:GetFullName(), 1)
                -- Intento rudimentario de leer de qué módulo cuelga
                if rem.Parent and rem.Parent:IsA("ModuleScript") then
                    log("  ╰─🔗 Modulo Maestro Vinculado: " .. rem.Parent.Name, 1)
                end
            end
        end

        local fn = export("OmniMindMap")
        guiLog("✅ Mapa mental y arquitectura generada.", Color3.fromRGB(0, 255, 0))
        guiLog("💾 Guardado en: " .. fn, Color3.fromRGB(0, 255, 0))
    end)
end)

-- ==============================================================================
-- [3] DESCOMPILADO Y EXTRACCIÓN DE CÓDIGO
-- ==============================================================================
btnDecomp.MouseButton1Click:Connect(function()
    guiLog("Iniciando motor de descompilación de código...", Color3.fromRGB(255, 100, 100))
    task.spawn(function()
        log("====================================================================")
        log("⚙️ OMNI-SCANNER PRO - EXTRACCIÓN Y DESCOMPILACIÓN DE SCRIPTS")
        log("====================================================================")

        local hasDecompile = type(decompile) == "function"
        
        if not hasDecompile then
            guiLog("⚠️ ATENCIÓN: Tu executor NO TIENE 'decompile()'.", Color3.fromRGB(255, 100, 0))
            guiLog("⚠️ Usando métodos alternativos de volcado de strings.", Color3.fromRGB(255, 100, 0))
            log("ESTADO: Descompilador no encontrado. Mapeando constantes en memoria por proxy.\n")
        else
            log("ESTADO: Descompilador habilitado. Recuperando código fuente (ReplicatedStorage/PlayerScripts)...\n")
        end

        local decompiledCount = 0

        local function analyzeScript(scr)
            log("\n[+] SCRIPT: " .. scr:GetFullName())
            if hasDecompile then
                local ok, src = pcall(function() return decompile(scr) end)
                if ok and type(src) == "string" and #src > 0 then
                    log("--- CÓDIGO FUENTE (Descompilado) ---", 1)
                    log(src, 1)
                    log("-------------------------------------", 1)
                    decompiledCount = decompiledCount + 1
                else
                    log("❌ Fallo al descompilar: Módulo no soportado o protegido.", 1)
                end
            else
                -- Si no hay decompile, buscar dependencias require dinámicas 
                -- y volcar todas las funciones registradas mediante getgc()
                log("-> Bypass descompilador: Evaluando dependencias y Require...", 1)
                local ok, res = pcall(function() return require(scr) end)
                if ok and type(res) == "table" then
                    for k, func in pairs(res) do
                        if type(func) == "function" then
                            local info = debug.getinfo(func)
                            log("  ╰─ Función exportada detectada: [" .. tostring(k) .. "] (Líneas: " .. tostring(info.linedefined) .. "-" .. tostring(info.lastlinedefined) .. ")", 2)
                        end
                    end
                else
                    log("  ╰─ (Script Inaccesible sin descompilador de alto nivel)", 2)
                end
            end
            task.wait(0.05)
        end

        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("ModuleScript") or obj:IsA("LocalScript") then
                analyzeScript(obj)
            end
        end

        local ps = LP:WaitForChild("PlayerScripts", 2)
        if ps then
            for _, obj in pairs(ps:GetDescendants()) do
                if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                    analyzeScript(obj)
                end
            end
        end

        log("\nTOTAL SCRIPTS PROCESADOS: " .. decompiledCount)
        
        local fn = export("OmniDecompiledCode")
        guiLog("✅ Descompilación terminada.", Color3.fromRGB(0, 255, 0))
        guiLog("💾 Códigos guardados en: " .. fn, Color3.fromRGB(0, 255, 0))
    end)
end)

guiLog("🧠 CARGADO OMNI-SCANNER PRO.", Color3.fromRGB(0, 255, 0))
guiLog("→ Herramienta de Ingeniería Inversa Activa.", Color3.fromRGB(150, 150, 150))
