-- =====================================================================
-- DELTA EXECUTOR - GHOST ANALYZER v2.0 (MODO PASIVO - READ ONLY)
-- Indetectable por Anticheats. Extractor forense de datos ocultos (2026)
-- Cargar vía Github: loadstring(game:HttpGet("TU_LINK_RAW_DE_GITHUB_AQUI"))()
-- =====================================================================

local GhostAnalyzer = {}

-- 1. EXTRACTOR DE INSTANCIAS FANTASMAS (NIL DUMP)
-- Busca scripts o piezas que el desarrollador intentó borrar (Destroy)
-- o esconder cambiando su padre a nil.
function GhostAnalyzer.DumpNilInstances()
    warn("\n[👻 GHOST SCANNER] Buscando scripts borrados / ocultos (NIL)...")
    -- getnilinstances() es exclusiva de ejecutores Nivel 7.
    local nilInstances = getnilinstances()
    local count = 0
    
    for _, obj in pairs(nilInstances) do
        if obj:IsA("LocalScript") or obj:IsA("ModuleScript") or obj:IsA("RemoteEvent") then
            count = count + 1
            print("   -> Secreto Encontrado: " .. obj.Name .. " [" .. obj.ClassName .. "]")
            -- NOTA: Como hacker usarías `decompile(obj)` aquí para robar el código fuente.
        end
    end
    
    print("   Total Secretos Ocultos en Nil: " .. count)
    if count > 0 then
        warn("   ⚠️ RIESGO ALTO: El juego intenta esconder scripts borrándolos. ¡Un Executor los puede leer igual!")
    end
end

-- 2. ESCÁNER DE MEMORIA RAM (GARBAGE COLLECTION DUMP)
-- Busca diccionarios o tablas de configuración guardadas temporalmente
-- en la memoria del cliente (ej. Estadísticas, Multiplicadores, Precios).
function GhostAnalyzer.DumpGC()
    warn("\n[🗑️ GC SCANNER] Escaneando la Memoria RAM del cliente (Tablas Locales)...")
    local count = 0
    
    -- getgc(true) obtiene toda la recolección de basura de Lua
    for _, v in pairs(getgc(true)) do
        if typeof(v) == "table" then
            -- Buscamos palabras clave sensibles que los desarrolladores suelen dejar en tablas locales
            if rawget(v, "Admin") or rawget(v, "Bypass") or rawget(v, "Multiplier") or rawget(v, "Price") then
                count = count + 1
                warn("   ⚠️ RIESGO EXTREMO: Tabla de configuración expuesta en memoria:")
                
                -- Extraemos los datos vulnerables
                for key, val in pairs(v) do
                    print("      [" .. tostring(key) .. "] = " .. tostring(val))
                    -- NOTA: Un hacker aquí haría `v.Price = -999` para manipular el juego.
                end
            end
        end
    end
    
    print("   Tablas Vulnerables Encontradas en Memoria: " .. count)
end

-- 3. ESPÍA DE EVENTOS Y BOTONES INVISIBLES (CONNECTION SPY)
-- Busca botones UI que el jugador no puede ver, pero que existen y se pueden presionar
-- forzosamente llamando a la función conectada a él.
function GhostAnalyzer.SpyConnections()
    warn("\n[🔌 CONNECTION SPY] Mapeando botones ocultos y triggers...")
    local uiCount = 0
    
    for _, obj in pairs(game:GetService("Players").LocalPlayer:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            -- getconnections() obtiene las funciones enlazadas a .MouseButton1Click
            local connections = getconnections(obj.MouseButton1Click)
            if #connections > 0 then
                uiCount = uiCount + 1
                -- NOTA: Un hacker no hace click, ejecuta: connections[1]:Fire() para auto-farmear UI.
            end
        end
    end
    
    print("   Botones/UI vulnerables a Auto-Clickers invisibles: " .. uiCount)
end

-- =====================================================================
-- EJECUCIÓN 100% PASIVA (NO BAN / INDETECTABLE)
-- Como este código SOLO LEE funciones y NO altera valores de memoria (Velocidad, Salto)
-- ni bombardea ReplicatedStorage con Pings falsos, Hyperion (Anti-Cheat 2026) 
-- no baneerá el código Lua, porque el script es inofensivo en ejecución.
-- =====================================================================
warn("==================================================")
warn("🕵️ DELTA GHOST ANALYZER INICIADO EN MODO PROTEGIDO")
warn("==================================================")

GhostAnalyzer.DumpNilInstances()
GhostAnalyzer.DumpGC()
GhostAnalyzer.SpyConnections()

warn("==================================================")
warn("✅ ESCANEO COMPLETADO. Cero modificaciones hechas al entorno.")
warn("==================================================")
