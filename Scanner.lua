local success_load, err_load = pcall(function()
-- ==============================================================================
-- 🧠 OMNI-SCANNER PRO V2.1 - FALLAS ATENUADAS (ANTI-CRASH) Y PORTAPAPELES
-- ==============================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

-- ==============================================================================
-- Utilidades Base
-- ==============================================================================
local function getNextFileName(base)
    local i = 1
    while true do
        local name = base .. "_" .. i .. ".txt"
        local exists = false
        pcall(function() exists = isfile and isfile(name) end)
        if not exists then return name end
        i = i + 1
    end
end

local logs = {}
local function log(text, indent)
    local prefix = string.rep("  ", indent or 0)
    table.insert(logs, prefix .. text)
end

-- Exportador con fallbacks (Clipboard si writefile falla)
local function export(baseName)
    local fn = getNextFileName(baseName)
    local content = table.concat(logs, "\n")
    
    local fileSaved = false
    pcall(function()
        if writefile then
            writefile(fn, content)
            fileSaved = true
        end
    end)
    
    -- Si no pudo crear archivo, al menos lo pega en el portapapeles
    if not fileSaved then
        pcall(function()
            if setclipboard then
                setclipboard(content)
            end
        end)
    end
    
    logs = {}
    return fn, fileSaved
end

-- ==============================================================================
-- GUI Ultra Segura (Mismo sistema que V9.4)
-- ==============================================================================
local TargetGui = LP:WaitForChild("PlayerGui", 5)

for _, v in pairs(TargetGui:GetChildren()) do 
    if v.Name == "OmniScannerPro" then pcall(function() v:Destroy() end) end 
end

local SG = Instance.new("ScreenGui")
SG.Name = "OmniScannerPro"
SG.ResetOnSpawn = false
SG.Parent = TargetGui

local MF = Instance.new("Frame", SG)
MF.Size = UDim2.new(0, 500, 0, 480)
MF.Position = UDim2.new(0.35, 0, 0.15, 0)
MF.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MF.BorderSizePixel = 2
MF.BorderColor3 = Color3.fromRGB(0, 255, 120)
MF.Active = true
MF.Draggable = true

local Title = Instance.new("TextLabel", MF)
Title.Size = UDim2.new(1, 0, 0, 26)
Title.BackgroundColor3 = Color3.fromRGB(10, 50, 30)
Title.Text = " 🧠 OMNI-SCANNER PRO V2.1 (ANTI-CRASH)"
Title.TextColor3 = Color3.fromRGB(150, 255, 200)
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
    pcall(function()
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
    end)
end

local function MkBtn(txt, py)
    local b = Instance.new("TextButton", MF)
    b.Size = UDim2.new(0.92, 0, 0, 30)
    b.Position = UDim2.new(0.04, 0, 0, py)
    b.BackgroundColor3 = Color3.fromRGB(35, 45, 40)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 11
    b.Text = txt
    return b
end

local btnConfigs = MkBtn("📦 1. EXTRAER CONFIGURACIONES (Armas, Mobs, Islas...)", 300)
local btnMindMap = MkBtn("🕸️ 2. MAPA MENTAL JERÁRQUICO (Rutas de Conexión)", 340)
local btnDecomp  = MkBtn("⚙️ 3. MAPEAR FUNCIONES INTERNAS DEL JUEGO", 380)

-- ==============================================================================
-- MOTOR DE EXTRACCIÓN PROFUNDA ENCAPSULADO
-- ==============================================================================
local function DeepDumpTable(tbl, name, maxDepth, currentDepth, visited)
    currentDepth = currentDepth or 0
    visited = visited or {}
    
    if currentDepth > maxDepth then return end
    if type(tbl) ~= "table" then return end
    if visited[tbl] then return end
    visited[tbl] = true

    for k, v in pairs(tbl) do
        local displayKey = tostring(k)
        local valType = type(v)
        
        if valType == "table" then
            log("[" .. displayKey .. "] (Table) {", currentDepth)
            pcall(function() DeepDumpTable(v, displayKey, maxDepth, currentDepth + 1, visited) end)
            log("}", currentDepth)
        elseif valType == "string" then
            log("[" .. displayKey .. "] = '" .. v .. "'", currentDepth)
        elseif valType == "number" or valType == "boolean" then
            log("[" .. displayKey .. "] = " .. tostring(v), currentDepth)
        else
            log("[" .. displayKey .. "] = " .. valType, currentDepth)
        end
    end
end

-- ==============================================================================
-- ACCIONES (Con control de agotamiento de script "Anti-Lag")
-- ==============================================================================
btnConfigs.MouseButton1Click:Connect(function()
    guiLog("Iniciando Extractor de Módulos... Esto tardará unos segundos.", Color3.fromRGB(0, 255, 255))
    
    task.spawn(function()
        local ok_scan, err_scan = pcall(function()
            log("--- REPORTE DE CONFIGURACIONES (RPG) ---")
            local modulesFound, dataFound = 0, 0
            local rpgKeys = {
                "mob", "boss", "weapon", "config", "data", "pet", "quest", "level", "npc", "city", 
                "map", "skill", "item", "gem", "race", "setting", "stat", "event", "island", "isla", 
                "fly", "vuelo", "speed", "jump", "salto", "reroll", "roll", "gacha", "fragment", 
                "shard", "money", "coin", "sword", "accessory", "melee", "key", "llave", "seal", 
                "drop", "moon slayer", "moon", "slayer", "power"
            }

            for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                if obj:IsA("ModuleScript") then
                    modulesFound = modulesFound + 1
                    local isImportant = false
                    local lName = obj.Name:lower()
                    
                    for _, k in ipairs(rpgKeys) do
                        if lName:find(k) then isImportant = true; break end
                    end
                    
                    if isImportant then
                        local ok_req, result = pcall(function() return require(obj) end)
                        if ok_req and type(result) == "table" then
                            log("\n[📌] DATOS EN MÓDULO PÚBLICO: " .. obj:GetFullName())
                            DeepDumpTable(result, obj.Name, 3) 
                            dataFound = dataFound + 1
                        end
                    end
                    if modulesFound % 25 == 0 then task.wait(0.05) end -- ANTICRASH VITAl
                end
            end
            
            -- Física local también
            log("\n--- LÍMITES FÍSICOS ---")
            if LP.Character and LP.Character:FindFirstChild("Humanoid") then
                local hum = LP.Character.Humanoid
                log("WalkSpeed: " .. tostring(hum.WalkSpeed))
                log("JumpPower: " .. tostring(hum.JumpPower))
            else
                log("Avatar no encontrado al momento del escaneo.")
            end

            local fn, saved = export("OmniConfigData")
            
            if saved then
                guiLog("✅ Datos extraídos! Creado archivo: " .. fn, Color3.fromRGB(0, 255, 0))
            else
                guiLog("⚠️ Escaneo ok, pero NO SE PUDO CREAR EL .TXT. Se copió todo a tu portapapeles (CONTROL+V)", Color3.fromRGB(255, 200, 0))
            end
        end)
        
        if not ok_scan then
            guiLog("❌ Error durante el escaneo: " .. tostring(err_scan), Color3.fromRGB(255, 0, 0))
        end
    end)
end)

btnMindMap.MouseButton1Click:Connect(function()
    guiLog("Mapeando el universo del juego... (Evitando crash)", Color3.fromRGB(200, 100, 255))
    task.spawn(function()
        local function mapHierarchy(parent, depth)
            if depth > 4 then return end
            local count = 0
            for _, v in pairs(parent:GetChildren()) do
                if v:IsA("Folder") or v:IsA("ModuleScript") or v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                    log((v:IsA("Folder") and "📂" or (v:IsA("ModuleScript") and "⚙️" or "📡")) .. " " .. v.Name, depth)
                    pcall(function() mapHierarchy(v, depth + 1) end)
                    
                    count = count + 1
                    if count % 20 == 0 then task.wait(0.01) end
                end
            end
        end

        local ok_map, err_map = pcall(function()
            log("--- ENDPOINTS DISPONIBLES ---")
            for _, rem in pairs(ReplicatedStorage:GetDescendants()) do
                if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                    log("📡 " .. rem:GetFullName())
                    if rem.Parent and rem.Parent:IsA("ModuleScript") then
                        log("  ╰─🔗 Modulo Vinculado: " .. rem.Parent.Name)
                    end
                end
            end

            log("\n--- ÁRBOL DE COMPONENTES ---")
            mapHierarchy(ReplicatedStorage, 0)
            
            local fn, saved = export("OmniMindMap")
            if saved then
                guiLog("✅ Mapa mental absoluto creado: " .. fn, Color3.fromRGB(0, 255, 0))
            else
                guiLog("⚠️ Guardado en Portapapeles. 'writefile' no habilitado.", Color3.fromRGB(255, 200, 0))
            end
        end)

        if not ok_map then
            guiLog("❌ Error en Mapa Mental: " .. tostring(err_map), Color3.fromRGB(255, 0, 0))
        end
    end)
end)

btnDecomp.MouseButton1Click:Connect(function()
    guiLog("Analizando código fuente disponible...", Color3.fromRGB(255, 100, 100))
    task.spawn(function()
        local ok_dc, err_dc = pcall(function()
            local analyzedCount = 0
            for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                if obj:IsA("ModuleScript") or obj:IsA("LocalScript") then
                    log("\n[+] SCRIPT/MÓDULO: " .. obj:GetFullName())
                    
                    -- Intento estricto de descompilacion si está permitida
                    local sourceObtained = false
                    if type(decompile) == "function" then
                        local ok_d, src = pcall(function() return decompile(obj) end)
                        if ok_d and type(src) == "string" and #src > 10 then
                            log("<< INICIO CÓDIGO >>")
                            log(src)
                            log("<< FIN CÓDIGO >>")
                            sourceObtained = true
                        end
                    end
                    
                    if not sourceObtained then
                        local ok_req, res = pcall(function() return require(obj) end)
                        if ok_req and type(res) == "table" then
                            for k, func in pairs(res) do
                                if type(func) == "function" then
                                    log("  ╰─ Función localizada: " .. tostring(k))
                                end
                            end
                        else
                            log("  ╰─ Código protegido (Sin acceso).")
                        end
                    end
                    
                    analyzedCount = analyzedCount + 1
                    if analyzedCount % 10 == 0 then task.wait(0.05) end
                end
            end
            
            local fn, saved = export("OmniDecompiledCode")
            if saved then
                guiLog("✅ Rutinas del juego volcadas a: " .. fn, Color3.fromRGB(0, 255, 0))
            else
                guiLog("⚠️ Archivo no creado, pero se COPIÓ TODO al portapapeles.", Color3.fromRGB(255, 200, 0))
            end
        end)
        if not ok_dc then
            guiLog("❌ Error en Extractor de Código: " .. tostring(err_dc), Color3.fromRGB(255, 0, 0))
        end
    end)
end)

guiLog("🧠 V2.1 Cargado — Todo encapsulado con Anti-Crash.", Color3.fromRGB(0, 255, 0))
guiLog("OJO: Si 'writefile' no existe, usará tu portapapeles.", Color3.fromRGB(200, 200, 0))

end) -- FIN PCALL MAESTRO
if not success_load then
    local sg = Instance.new("ScreenGui")
    sg.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local tl = Instance.new("TextLabel", sg)
    tl.Size = UDim2.new(1,0,1,0)
    tl.BackgroundColor3 = Color3.new(0.5, 0, 0)
    tl.TextColor3 = Color3.new(1,1,1)
    tl.Font = Enum.Font.Code
    tl.TextScaled = true
    tl.Text = "ERROR CRÍTICO AL CARGAR OMNISCANNER:\n" .. tostring(err_load)
end
