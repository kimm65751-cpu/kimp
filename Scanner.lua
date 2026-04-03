
 
-- ==============================================================================
-- 🔬 DIAGNÓSTICO TOTAL V1.0 — DETECTOR DE FALLOS EN GUI Y LUA
-- Ejecuta ANTES que cualquier otro script para saber exactamente:
-- ✅ Qué APIs funcionan en tu ejecutor/entorno
-- ❌ Dónde se corta tu código y por qué
-- 📊 Versión del servidor, seguridad, plugins, scripts
-- ==============================================================================

-- ╔══════════════════════════════════════════════════════╗
-- ║  FASE 0: MOTOR DE LOGGING SEGURO (NO USA GUI AÚN)  ║
-- ╚══════════════════════════════════════════════════════╝

local DiagLog = {}    -- Tabla de resultados: {emoji, categoria, mensaje, detalle}
local ErrorCount = 0
local WarnCount = 0
local PassCount = 0

local function LogPass(cat, msg, detail)
    PassCount = PassCount + 1
    table.insert(DiagLog, {"PASS", cat, msg, detail or ""})
end

local function LogFail(cat, msg, detail)
    ErrorCount = ErrorCount + 1
    table.insert(DiagLog, {"FAIL", cat, msg, detail or ""})
end

local function LogWarn(cat, msg, detail)
    WarnCount = WarnCount + 1
    table.insert(DiagLog, {"WARN", cat, msg, detail or ""})
end

local function LogInfo(cat, msg, detail)
    table.insert(DiagLog, {"INFO", cat, msg, detail or ""})
end

local function LogSection(title)
    table.insert(DiagLog, {"HEAD", "---", title, ""})
end

-- Función segura para ejecutar una prueba
local function Test(category, description, testFn)
    local ok, result = pcall(testFn)
    if ok then
        if result == false then
            LogFail(category, description, "Retornó false")
        elseif type(result) == "string" and string.sub(result, 1, 5) == "WARN:" then
            LogWarn(category, description, string.sub(result, 6))
        else
            LogPass(category, description, tostring(result or "OK"))
        end
    else
        LogFail(category, description, tostring(result))
    end
end

-- ╔══════════════════════════════════════════════════════╗
-- ║  FASE 1: ANÁLISIS DEL ENTORNO DE EJECUCIÓN          ║
-- ╚══════════════════════════════════════════════════════╝

LogSection("FASE 1: ENTORNO DE EJECUCION Y VERSIÓN")

-- 1.1 Versión de Lua / Luau
Test("ENTORNO", "Version de Lua/Luau", function()
    local v = _VERSION or "Desconocida"
    return v
end)

-- 1.2 Identidad del ejecutor
Test("ENTORNO", "Identlevel (getidentity/getthreadidentity)", function()
    local id = nil
    if getidentity then id = getidentity()
    elseif getthreadidentity then id = getthreadidentity()
    elseif getthreadcontext then id = getthreadcontext()
    end
    if id then return "Identity Level: " .. tostring(id) end
    return "WARN: No se encontro getidentity/getthreadidentity/getthreadcontext"
end)

-- 1.3 Nombre del ejecutor
Test("ENTORNO", "Nombre del Ejecutor (identifyexecutor)", function()
    if identifyexecutor then
        local name, ver = identifyexecutor()
        return tostring(name) .. " " .. tostring(ver or "")
    elseif getexecutorname then
        return tostring(getexecutorname())
    end
    return "WARN: No se detecta nombre de ejecutor (puede ser Roblox Studio)"
end)

-- 1.4 Plataforma
Test("ENTORNO", "Deteccion de Plataforma", function()
    local UserInputService = game:GetService("UserInputService")
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local isPC = UserInputService.KeyboardEnabled
    local isConsole = UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled
    if isMobile then return "MOBILE (Android/iOS) - Touch"
    elseif isPC then return "PC/DESKTOP - Teclado+Raton"
    elseif isConsole then return "CONSOLA - Gamepad"
    else return "Desconocido" end
end)

-- ╔══════════════════════════════════════════════════════╗
-- ║  FASE 2: SERVICIOS DE ROBLOX (¿Cuáles cargan?)     ║
-- ╚══════════════════════════════════════════════════════╝

LogSection("FASE 2: ACCESO A SERVICIOS CLAVE")

local ServiciosRequeridos = {
    "Players", "Workspace", "ReplicatedStorage", "ReplicatedFirst",
    "StarterGui", "StarterPack", "StarterPlayer",
    "Lighting", "SoundService", "RunService",
    "UserInputService", "TweenService", "HttpService",
    "MarketplaceService", "Chat", "Teams",
    "ServerStorage", "ServerScriptService",
    "CoreGui", "VirtualUser", "ScriptContext",
    "NetworkClient", "ContentProvider"
}

local ServiciosOK = {}
for _, sName in ipairs(ServiciosRequeridos) do
    Test("SERVICIOS", "game:GetService('" .. sName .. "')", function()
        local svc = game:GetService(sName)
        ServiciosOK[sName] = svc
        return svc.ClassName .. " (accesible)"
    end)
end

-- ╔══════════════════════════════════════════════════════╗
-- ║  FASE 3: PLAYER Y PERSONAJE                         ║
-- ╚══════════════════════════════════════════════════════╝

LogSection("FASE 3: JUGADOR LOCAL Y PERSONAJE")

local LP = nil
Test("PLAYER", "Players.LocalPlayer existe", function()
    LP = game:GetService("Players").LocalPlayer
    if LP then return LP.Name else return false end
end)

Test("PLAYER", "LocalPlayer.Character cargado", function()
    if not LP then return false end
    local char = LP.Character
    if char then return char.Name .. " (cargado)" 
    else return "WARN: Character es nil (puede estar respawneando)" end
end)

Test("PLAYER", "HumanoidRootPart accesible", function()
    if not LP or not LP.Character then return "WARN: Sin personaje" end
    local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp then return "Posicion: " .. tostring(hrp.Position) else return false end
end)

Test("PLAYER", "PlayerGui accesible", function()
    if not LP then return false end
    local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 3)
    if pg then return "PlayerGui OK (" .. tostring(#pg:GetChildren()) .. " hijos)" else return false end
end)

Test("PLAYER", "Backpack accesible", function()
    if not LP then return false end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        local tools = bp:GetChildren()
        return #tools .. " tools en Backpack"
    end
    return "WARN: Sin Backpack visible"
end)

Test("PLAYER", "leaderstats", function()
    if not LP then return false end
    local ls = LP:FindFirstChild("leaderstats")
    if ls then
        local names = {}
        for _, v in ipairs(ls:GetChildren()) do
            table.insert(names, v.Name .. "=" .. tostring(v.Value))
        end
        return table.concat(names, ", ")
    end
    return "WARN: Sin leaderstats (puede usar Attributes o ProfileService)"
end)

-- ╔══════════════════════════════════════════════════════╗
-- ║  FASE 4: PRUEBAS DE GUI (DONDE PROBABLEMENTE FALLA)║
-- ╚══════════════════════════════════════════════════════╝

LogSection("FASE 4: PRUEBAS DE GUI PASO A PASO")

-- 4.1 CoreGui vs PlayerGui
local GUIParent = nil
Test("GUI", "Acceso a CoreGui como padre de GUI", function()
    local cg = game:GetService("CoreGui")
    -- Intentar leer .Name como prueba mínima
    local n = cg.Name
    -- Intentar crear un ScreenGui ahí
    local testSG = Instance.new("ScreenGui")
    testSG.Name = "__DiagTest_CoreGui"
    testSG.Parent = cg
    if testSG.Parent == cg then
        testSG:Destroy()
        GUIParent = cg
        return "CoreGui FUNCIONAL como padre de GUI"
    else
        testSG:Destroy()
        return false
    end
end)

if not GUIParent then
    Test("GUI", "Fallback a PlayerGui", function()
        if not LP then return false end
        local pg = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 5)
        if pg then
            local testSG = Instance.new("ScreenGui")
            testSG.Name = "__DiagTest_PlayerGui"
            testSG.Parent = pg
            if testSG.Parent == pg then
                testSG:Destroy()
                GUIParent = pg
                return "PlayerGui FUNCIONAL como padre"
            else
                testSG:Destroy()
                return false
            end
        end
        return false
    end)
end

if not GUIParent then
    LogFail("GUI", "NO HAY PADRE VALIDO PARA GUI", "Ni CoreGui ni PlayerGui aceptan hijos. La GUI nunca cargara.")
end

-- 4.2 ScreenGui básico
local TestScreenGui = nil
Test("GUI", "Crear ScreenGui basico", function()
    if not GUIParent then return false end
    TestScreenGui = Instance.new("ScreenGui")
    TestScreenGui.Name = "__Diagnostico_GUI"
    TestScreenGui.ResetOnSpawn = false
    TestScreenGui.Parent = GUIParent
    return "ScreenGui creado en " .. GUIParent.Name
end)

-- 4.3 Frame
local TestFrame = nil
Test("GUI", "Crear Frame con propiedades", function()
    if not TestScreenGui then return false end
    TestFrame = Instance.new("Frame")
    TestFrame.Size = UDim2.new(0, 300, 0, 200)
    TestFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    TestFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    TestFrame.BorderSizePixel = 2
    TestFrame.Parent = TestScreenGui
    return "Frame creado OK"
end)

-- 4.4 Frame.Draggable (DEPRECIADO)
Test("GUI", "Frame.Draggable (DEPRECIADO en Roblox moderno)", function()
    if not TestFrame then return false end
    TestFrame.Active = true
    TestFrame.Draggable = true
    return "Draggable aceptado (pero puede estar depreciado)"
end)

-- 4.5 TextLabel
Test("GUI", "Crear TextLabel", function()
    if not TestFrame then return false end
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, 0, 0, 30)
    tl.Text = "Test Label"
    tl.TextColor3 = Color3.fromRGB(255, 255, 255)
    tl.Font = Enum.Font.Code
    tl.TextSize = 14
    tl.Parent = TestFrame
    return "TextLabel OK"
end)

-- 4.6 TextButton
Test("GUI", "Crear TextButton", function()
    if not TestFrame then return false end
    local tb = Instance.new("TextButton")
    tb.Size = UDim2.new(0, 100, 0, 30)
    tb.Position = UDim2.new(0, 5, 0, 35)
    tb.Text = "Boton Test"
    tb.TextColor3 = Color3.fromRGB(255, 255, 255)
    tb.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    tb.Parent = TestFrame
    return "TextButton OK"
end)

-- 4.7 TextBox
Test("GUI", "Crear TextBox (para Reporte)", function()
    if not TestFrame then return false end
    local txb = Instance.new("TextBox")
    txb.Size = UDim2.new(1, 0, 0, 50)
    txb.Position = UDim2.new(0, 0, 0, 70)
    txb.Text = "Test TextBox"
    txb.ClearTextOnFocus = false
    txb.TextEditable = false
    txb.MultiLine = true
    txb.Parent = TestFrame
    return "TextBox OK"
end)

-- 4.8 ScrollingFrame
Test("GUI", "Crear ScrollingFrame", function()
    if not TestFrame then return false end
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, 0, 0, 50)
    sf.Position = UDim2.new(0, 0, 0, 125)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.ScrollBarThickness = 6
    sf.Parent = TestFrame
    return "ScrollingFrame OK"
end)

-- 4.9 ImageButton
Test("GUI", "Crear ImageButton", function()
    if not TestFrame then return false end
    local ib = Instance.new("ImageButton")
    ib.Size = UDim2.new(0, 40, 0, 40)
    ib.Image = "rbxassetid://10886105073"
    ib.Parent = TestFrame
    return "ImageButton OK"
end)

-- 4.10 UICorner
Test("GUI", "UICorner (esquinas redondeadas)", function()
    if not TestFrame then return false end
    local uc = Instance.new("UICorner")
    uc.CornerRadius = UDim.new(0, 8)
    uc.Parent = TestFrame
    return "UICorner OK"
end)

-- 4.11 Emojis en texto
Test("GUI", "Soporte de Emojis en TextLabel", function()
    if not TestFrame then return false end
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, 0, 0, 20)
    tl.Text = "🗡️ ⛏️ 🛡️ 👻 💎 🧟 📡 🔗"
    tl.TextColor3 = Color3.fromRGB(255, 255, 255)
    tl.Font = Enum.Font.Code
    tl.TextSize = 12
    tl.Parent = TestFrame
    -- No hay forma de detectar si renderiza bien, pero si no crasheó es buena señal
    return "No crasheo al insertar emojis"
end)

-- Limpiar GUI de prueba
pcall(function()
    if TestScreenGui then TestScreenGui:Destroy() end
end)

-- ╔══════════════════════════════════════════════════════╗
-- ║  FASE 5: APIs DE EXPLOIT / FUNCIONALIDAD AVANZADA   ║
-- ╚══════════════════════════════════════════════════════╝

LogSection("FASE 5: APIs AVANZADAS (EXPLOIT/EXECUTOR)")

Test("EXPLOIT", "setclipboard / toclipboard", function()
    if setclipboard then return "setclipboard existe"
    elseif toclipboard then return "toclipboard existe"
    end
    return "WARN: No hay funcion de portapapeles (no podras copiar reportes)"
end)

Test("EXPLOIT", "writefile", function()
    if writefile then return "writefile existe (puedes guardar .txt)"
    else return "WARN: writefile no disponible" end
end)

Test("EXPLOIT", "readfile", function()
    if readfile then return "readfile existe"
    else return "WARN: readfile no disponible" end
end)

Test("EXPLOIT", "loadstring permitido", function()
    local fn = loadstring("return 42")
    if fn and fn() == 42 then return "loadstring FUNCIONAL" end
    return false
end)

Test("EXPLOIT", "game:HttpGet / HttpGetAsync", function()
    local url = "https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"
    local ok, data = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and data and #data > 10 then 
        return "HttpGet OK (" .. tostring(#data) .. " chars descargados)"
    elseif ok then 
        return "WARN: HttpGet devolvió datos vacios o cortos"
    else
        return false
    end
end)

Test("EXPLOIT", "hookmetamethod / hookfunction", function()
    if hookmetamethod then return "hookmetamethod existe"
    elseif hookfunction then return "hookfunction existe"
    end
    return "WARN: Sin hooks disponibles"
end)

Test("EXPLOIT", "getgenv / getrenv", function()
    local items = {}
    if getgenv then table.insert(items, "getgenv") end
    if getrenv then table.insert(items, "getrenv") end
    if getsenv then table.insert(items, "getsenv") end
    if getfenv then table.insert(items, "getfenv") end
    if #items > 0 then return table.concat(items, ", ")
    else return "WARN: Sin funciones de entorno" end
end)

Test("EXPLOIT", "firesignal / fireproximityprompt", function()
    local items = {}
    if firesignal then table.insert(items, "firesignal") end
    if fireproximityprompt then table.insert(items, "fireproximityprompt") end
    if fireclickdetector then table.insert(items, "fireclickdetector") end
    if firetouchinterest then table.insert(items, "firetouchinterest") end
    if #items > 0 then return table.concat(items, ", ")
    else return "WARN: Sin funciones de simulacion de eventos" end
end)

-- ╔══════════════════════════════════════════════════════╗
-- ║  FASE 6: FUNCIONES LUA CRÍTICAS                     ║
-- ╚══════════════════════════════════════════════════════╝

LogSection("FASE 6: FUNCIONES LUA CRITICAS")

Test("LUA", "task.spawn", function()
    local ran = false
    task.spawn(function() ran = true end)
    task.wait(0.05)
    if ran then return "task.spawn OK" else return false end
end)

Test("LUA", "task.wait", function()
    local t1 = tick()
    task.wait(0.05)
    local elapsed = tick() - t1
    return "task.wait OK (esperó " .. string.format("%.3f", elapsed) .. "s)"
end)

Test("LUA", "task.delay", function()
    if task.delay then return "task.delay disponible" end
    return false
end)

Test("LUA", "task.cancel", function()
    if task.cancel then return "task.cancel disponible" end
    return "WARN: task.cancel no existe"
end)

Test("LUA", "pcall funcional", function()
    local ok, err = pcall(function() error("test error") end)
    if not ok and string.find(tostring(err), "test error") then
        return "pcall captura errores correctamente"
    end
    return false
end)

Test("LUA", "typeof funcional", function()
    local t = typeof(Vector3.new(0,0,0))
    if t == "Vector3" then return "typeof OK" end
    return false
end)

Test("LUA", "string.find / string.match", function()
    local r1 = string.find("hello_world", "world")
    local r2 = string.match("[Lvl. 42]", "%[Lvl%.%s*(%d+)%]")
    if r1 and r2 == "42" then return "Pattern matching OK" end
    return false
end)

Test("LUA", "Instance.new funcional", function()
    local p = Instance.new("Part")
    if p and p:IsA("Part") then
        p:Destroy()
        return "Instance.new OK"
    end
    return false
end)

Test("LUA", "tick() funcional", function()
    local t = tick()
    if t > 0 then return "tick() = " .. string.format("%.2f", t)
    else return false end
end)

Test("LUA", "os.time() funcional", function()
    local t = os.time()
    if t > 0 then return "os.time() = " .. tostring(t)
    else return false end
end)

Test("LUA", "os.clock() funcional", function()
    local t = os.clock()
    if t >= 0 then return "os.clock() = " .. string.format("%.4f", t)
    else return false end
end)

-- ╔══════════════════════════════════════════════════════╗
-- ║  FASE 7: ANÁLISIS DEL JUEGO (SERVIDOR/CONTENIDO)    ║
-- ╚══════════════════════════════════════════════════════╝

LogSection("FASE 7: ANALISIS DEL JUEGO ACTUAL")

Test("JUEGO", "Nombre del juego (PlaceId)", function()
    return "PlaceId: " .. tostring(game.PlaceId) .. " | GameId: " .. tostring(game.GameId)
end)

Test("JUEGO", "Nombre del lugar", function()
    local mps = game:GetService("MarketplaceService")
    local ok, info = pcall(function()
        return mps:GetProductInfo(game.PlaceId)
    end)
    if ok and info then
        return "'" .. tostring(info.Name) .. "' por " .. tostring(info.Creator.Name)
    end
    return "WARN: No se pudo obtener info del marketplace"
end)

Test("JUEGO", "JobId (Servidor)", function()
    return game.JobId ~= "" and ("JobId: " .. game.JobId) or "Studio/Sin servidor"
end)

Test("JUEGO", "Jugadores conectados", function()
    local players = game:GetService("Players"):GetPlayers()
    local names = {}
    for _, p in ipairs(players) do table.insert(names, p.Name) end
    return #names .. " jugadores: " .. table.concat(names, ", ")
end)

-- Contar objetos en Workspace
Test("JUEGO", "Descendientes en Workspace", function()
    local d = game:GetService("Workspace"):GetDescendants()
    return tostring(#d) .. " objetos totales en Workspace"
end)

-- Contar en ReplicatedStorage
Test("JUEGO", "Hijos en ReplicatedStorage", function()
    local rs = game:GetService("ReplicatedStorage")
    local d = rs:GetDescendants()
    return tostring(#d) .. " objetos en ReplicatedStorage"
end)

-- ╔══════════════════════════════════════════════════════╗
-- ║  FASE 8: REMOTES Y ESTRUCTURA DE RED                 ║
-- ╚══════════════════════════════════════════════════════╝

LogSection("FASE 8: REMOTES DETECTADOS (RED C/S)")

Test("RED", "RemoteEvents en ReplicatedStorage", function()
    local count = 0
    local names = {}
    for _, obj in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            count = count + 1
            if count <= 15 then table.insert(names, obj:GetFullName()) end
        end
    end
    return tostring(count) .. " RemoteEvents. Primeros: " .. table.concat(names, " | ")
end)

Test("RED", "RemoteFunctions en ReplicatedStorage", function()
    local count = 0
    local names = {}
    for _, obj in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if obj:IsA("RemoteFunction") then
            count = count + 1
            if count <= 15 then table.insert(names, obj:GetFullName()) end
        end
    end
    return tostring(count) .. " RemoteFunctions. Primeros: " .. table.concat(names, " | ")
end)

-- Detectar frameworks comunes
Test("RED", "Framework detectado (Knit/AeroGameFramework/Etc)", function()
    local frameworks = {}
    local rs = game:GetService("ReplicatedStorage")
    -- Knit
    pcall(function()
        local knit = rs:FindFirstChild("Shared")
        if knit and knit:FindFirstChild("Packages") then
            local knitPkg = knit.Packages:FindFirstChild("Knit")
            if knitPkg then table.insert(frameworks, "KNIT detectado en RS.Shared.Packages.Knit") end
        end
    end)
    -- Aero
    pcall(function()
        if rs:FindFirstChild("Aero") then table.insert(frameworks, "AeroGameFramework") end
    end)
    -- Rojo/Wally
    pcall(function()
        if rs:FindFirstChild("Packages") then table.insert(frameworks, "Wally Packages") end
    end)
    if #frameworks > 0 then return table.concat(frameworks, " | ") end
    return "WARN: No se detecto framework especifico"
end)

-- Referencia especifica del Omni-Farm V2.0 (Knit ToolService)
Test("RED", "Knit ToolService.RF.ToolActivated (ref. tu script)", function()
    local ok, rf = pcall(function()
        return game:GetService("ReplicatedStorage").Shared.Packages.Knit.Services.ToolService.RF.ToolActivated
    end)
    if ok and rf then
        return "EXISTE: " .. rf:GetFullName() .. " (" .. rf.ClassName .. ")"
    end
    return "WARN: La ruta RS.Shared.Packages.Knit.Services.ToolService.RF.ToolActivated NO EXISTE. Tu script crasheará en linea 18."
end)

-- ╔══════════════════════════════════════════════════════╗
-- ║  FASE 9: SCRIPTS Y SEGURIDAD DEL SERVIDOR            ║
-- ╚══════════════════════════════════════════════════════╝

LogSection("FASE 9: SCRIPTS Y SEGURIDAD")

Test("SEGURIDAD", "LocalScripts en PlayerScripts", function()
    if not LP then return false end
    local ps = LP:FindFirstChild("PlayerScripts")
    if ps then
        local scripts = {}
        for _, s in ipairs(ps:GetDescendants()) do
            if s:IsA("LocalScript") or s:IsA("ModuleScript") then
                table.insert(scripts, s.Name .. " (" .. s.ClassName .. ")")
            end
        end
        return #scripts .. " scripts: " .. table.concat(scripts, ", ")
    end
    return "WARN: Sin PlayerScripts visible"
end)

Test("SEGURIDAD", "Anti-Cheat posibles (busqueda heuristica)", function()
    local suspects = {}
    local searchTerms = {"anticheat", "anti_cheat", "exploit", "ban", "kick", "detect", "integrity", "security", "guard", "byfron"}
    for _, obj in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        local n = string.lower(obj.Name)
        for _, term in ipairs(searchTerms) do
            if string.find(n, term) then
                table.insert(suspects, obj.Name .. " (" .. obj.ClassName .. ") en " .. obj.Parent.Name)
                break
            end
        end
    end
    -- También buscar en Workspace
    for _, obj in ipairs(game:GetService("Workspace"):GetChildren()) do
        local n = string.lower(obj.Name)
        for _, term in ipairs(searchTerms) do
            if string.find(n, term) then
                table.insert(suspects, obj.Name .. " (" .. obj.ClassName .. ") en Workspace")
                break
            end
        end
    end
    if #suspects > 0 then
        return "DETECTADOS " .. #suspects .. ": " .. table.concat(suspects, " | ")
    end
    return "No se encontraron nombres sospechosos de Anti-Cheat"
end)

Test("SEGURIDAD", "Scripts anti-idle/AFK", function()
    local ok, vuser = pcall(function() return game:GetService("VirtualUser") end)
    if ok and vuser then return "VirtualUser accesible (anti-AFK posible)" end
    return "WARN: VirtualUser no accesible"
end)

-- ╔══════════════════════════════════════════════════════╗
-- ║  FASE 10: DIAGNÓSTICO ESPECÍFICO DEL SCANNER V23     ║
-- ╚══════════════════════════════════════════════════════╝

LogSection("FASE 10: DIAGNOSTICO DE TU SCRIPT (LINEAS PROBLEMATICAS)")

-- Simular cada paso critico del script OmniFarm V2.0 / Scanner V23

Test("TU_SCRIPT", "Linea 11: game:GetService('CoreGui')", function()
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return "CoreGui accesible" end
    return "WARN: CoreGui NO accesible — tu GUI necesita fallback a PlayerGui"
end)

Test("TU_SCRIPT", "Linea 18: ToolService.RF.ToolActivated (RUTA HARDCODED)", function()
    local ok, result = pcall(function()
        return game:GetService("ReplicatedStorage").Shared.Packages.Knit.Services.ToolService.RF.ToolActivated
    end)
    if ok and result then return "Ruta OK: " .. result:GetFullName() end
    -- Intentar encontrar paso a paso dónde se corta
    local path = {"ReplicatedStorage", "Shared", "Packages", "Knit", "Services", "ToolService", "RF", "ToolActivated"}
    local current = game:GetService("ReplicatedStorage")
    local lastGood = "ReplicatedStorage"
    for i = 2, #path do
        local next_ok, next_obj = pcall(function() return current:FindFirstChild(path[i]) end)
        if next_ok and next_obj then
            current = next_obj
            lastGood = table.concat(path, ".", 1, i)
        else
            return "FALLA EN LINEA 18: La ruta se corta en '" .. path[i] .. "'. Ultimo valido: " .. lastGood .. ". Esto CRASHEA tu script antes de crear la GUI."
        end
    end
    return "Ruta completa OK"
end)

Test("TU_SCRIPT", "Linea 96: pcall(CoreGui.Name) como test", function()
    local parentUI = pcall(function() return game:GetService("CoreGui").Name end)
    if parentUI then
        return "pcall(CoreGui.Name) = true, usará CoreGui"
    else
        return "WARN: pcall(CoreGui.Name) = false, usará PlayerGui"
    end
end)

Test("TU_SCRIPT", "Linea 107: Frame.Draggable", function()
    local f = Instance.new("Frame")
    local ok, err = pcall(function() f.Draggable = true end)
    f:Destroy()
    if ok then return "Draggable aceptado" end
    return "Draggable DEPRECIADO/ELIMINADO: " .. tostring(err) .. ". Usar UDrag o InputBegan custom."
end)

Test("TU_SCRIPT", "Linea 250: VirtualUser (Anti-AFK)", function()
    local ok, vu = pcall(function() return game:GetService("VirtualUser") end)
    if ok and vu then
        local ok2, _ = pcall(function() vu:CaptureController() end)
        if ok2 then return "VirtualUser:CaptureController() OK"
        else return "WARN: VirtualUser existe pero CaptureController fallo" end
    end
    return "WARN: VirtualUser no accesible"
end)

Test("TU_SCRIPT", "Linea 154: rbxassetid://10886105073 (ImageButton)", function()
    local ib = Instance.new("ImageButton")
    local ok, err = pcall(function()
        ib.Image = "rbxassetid://10886105073"
    end)
    ib:Destroy()
    if ok then return "Asset ID aceptado" else return "WARN: " .. tostring(err) end
end)

-- Verificar si GetDescendants funciona sin crasheo
Test("TU_SCRIPT", "GetDescendants en Workspace (scan pesado)", function()
    local t1 = tick()
    local count = 0
    local ok, err = pcall(function()
        for _, obj in ipairs(game:GetService("Workspace"):GetDescendants()) do
            count = count + 1
        end
    end)
    local elapsed = tick() - t1
    if ok then
        return count .. " objetos escaneados en " .. string.format("%.3f", elapsed) .. "s"
    end
    return "FALLA: " .. tostring(err)
end)

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  FASE 11: RESUMEN Y CREACIÓN DE LA GUI DE RESULTADOS       ║
-- ╚══════════════════════════════════════════════════════════════╝

LogSection("RESUMEN FINAL")
LogInfo("RESUMEN", "Total Tests", PassCount + ErrorCount + WarnCount .. " pruebas ejecutadas")
LogInfo("RESUMEN", "Resultados", "PASS=" .. PassCount .. " | FAIL=" .. ErrorCount .. " | WARN=" .. WarnCount)

-- Construir texto del reporte
local FullText = ""
FullText = FullText .. "============================================================\n"
FullText = FullText .. "  DIAGNOSTICO TOTAL V1.0 — REPORTE DE EJECUCION\n"
FullText = FullText .. "  Fecha: " .. tostring(os.date and os.date("%Y-%m-%d %H:%M:%S") or "N/A") .. "\n"
FullText = FullText .. "  PASS=" .. PassCount .. " | FAIL=" .. ErrorCount .. " | WARN=" .. WarnCount .. "\n"
FullText = FullText .. "============================================================\n\n"

for _, entry in ipairs(DiagLog) do
    local status = entry[1]
    local cat = entry[2]
    local msg = entry[3]
    local detail = entry[4]
    
    if status == "HEAD" then
        FullText = FullText .. "\n" .. string.rep("=", 60) .. "\n"
        FullText = FullText .. "  " .. msg .. "\n"
        FullText = FullText .. string.rep("=", 60) .. "\n"
    elseif status == "PASS" then
        FullText = FullText .. " [OK]   " .. cat .. " > " .. msg .. "\n"
        if detail ~= "" then FullText = FullText .. "         -> " .. detail .. "\n" end
    elseif status == "FAIL" then
        FullText = FullText .. " [FAIL] " .. cat .. " > " .. msg .. "\n"
        if detail ~= "" then FullText = FullText .. "         -> ERROR: " .. detail .. "\n" end
    elseif status == "WARN" then
        FullText = FullText .. " [WARN] " .. cat .. " > " .. msg .. "\n"
        if detail ~= "" then FullText = FullText .. "         -> " .. detail .. "\n" end
    elseif status == "INFO" then
        FullText = FullText .. " [INFO] " .. cat .. " > " .. msg .. "\n"
        if detail ~= "" then FullText = FullText .. "         -> " .. detail .. "\n" end
    end
end

FullText = FullText .. "\n============================================================\n"
FullText = FullText .. "  FIN DEL DIAGNOSTICO\n"
FullText = FullText .. "============================================================\n"

-- También hacer output a consola por si la GUI no carga
pcall(function()
    for _, line in ipairs(string.split(FullText, "\n")) do
        if string.find(line, "%[FAIL%]") then
            warn("[DIAG] " .. line)
        else
            print("[DIAG] " .. line)
        end
    end
end)

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  GUI ULTRA-SEGURA DE RESULTADOS (CONSTRUIDA EN MÍNIMO)     ║
-- ╚══════════════════════════════════════════════════════════════╝
-- Esta GUI se construye con el MÍNIMO de features posibles.
-- Si algo falla, usará fallbacks progresivos.

local function BuildResultGUI()
    -- Determinar padre de GUI
    local guiParent = nil
    pcall(function()
        local cg = game:GetService("CoreGui")
        local _ = cg.Name
        guiParent = cg
    end)
    if not guiParent then
        pcall(function()
            guiParent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui", 5)
        end)
    end
    
    if not guiParent then
        warn("[DIAGNOSTICO] NO SE PUEDE CREAR GUI. Lee el reporte en la consola Output (F9).")
        return
    end

    -- Limpiar GUI anterior
    pcall(function()
        for _, v in ipairs(guiParent:GetChildren()) do
            if v.Name == "_DiagnosticoResultUI" then v:Destroy() end
        end
    end)

    local sg = Instance.new("ScreenGui")
    sg.Name = "_DiagnosticoResultUI"
    sg.ResetOnSpawn = false
    sg.Parent = guiParent

    -- Frame principal - SIN Draggable por si está depreciado
    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.Size = UDim2.new(0, 620, 0, 480)
    main.Position = UDim2.new(0.5, -310, 0.5, -240)
    main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    main.BorderSizePixel = 2
    main.BorderColor3 = Color3.fromRGB(80, 200, 255)
    main.Active = true
    main.Parent = sg

    -- Drag manual (reemplaza .Draggable depreciado)
    local dragging = false
    local dragStart, startPos
    
    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    main.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Barra superior
    local topbar = Instance.new("Frame")
    topbar.Size = UDim2.new(1, 0, 0, 32)
    topbar.BackgroundColor3 = Color3.fromRGB(20, 60, 100)
    topbar.BorderSizePixel = 0
    topbar.Parent = main

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -70, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "  DIAGNOSTICO V1.0 | PASS=" .. PassCount .. " | FAIL=" .. ErrorCount .. " | WARN=" .. WarnCount
    title.TextColor3 = Color3.fromRGB(150, 240, 255)
    title.Font = Enum.Font.Code
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topbar

    -- Color de la barra según resultados
    if ErrorCount > 0 then
        topbar.BackgroundColor3 = Color3.fromRGB(140, 30, 30)
        title.TextColor3 = Color3.fromRGB(255, 200, 200)
    elseif WarnCount > 0 then
        topbar.BackgroundColor3 = Color3.fromRGB(120, 100, 20)
        title.TextColor3 = Color3.fromRGB(255, 255, 200)
    else
        topbar.BackgroundColor3 = Color3.fromRGB(20, 100, 40)
        title.TextColor3 = Color3.fromRGB(200, 255, 200)
    end

    -- Botón cerrar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -32, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.Code
    closeBtn.TextSize = 14
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = topbar
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

    -- Pestañas: Todos / Solo Errores / Solo Warnings
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(1, 0, 0, 28)
    tabFrame.Position = UDim2.new(0, 0, 0, 32)
    tabFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    tabFrame.BorderSizePixel = 0
    tabFrame.Parent = main

    local currentFilter = "ALL"

    local function MakeTab(text, filter, xPos, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 130, 0, 24)
        btn.Position = UDim2.new(0, xPos, 0, 2)
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Code
        btn.TextSize = 11
        btn.BorderSizePixel = 0
        btn.Parent = tabFrame
        return btn, filter
    end

    local tabAll, _ = MakeTab("TODOS (" .. #DiagLog .. ")", "ALL", 4, Color3.fromRGB(50, 50, 80))
    local tabFail, _ = MakeTab("ERRORES (" .. ErrorCount .. ")", "FAIL", 138, Color3.fromRGB(120, 30, 30))
    local tabWarn, _ = MakeTab("AVISOS (" .. WarnCount .. ")", "WARN", 272, Color3.fromRGB(120, 100, 20))
    local tabPass, _ = MakeTab("OK (" .. PassCount .. ")", "PASS", 406, Color3.fromRGB(20, 100, 40))

    -- Scroll con resultados
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -8, 1, -108)
    scroll.Position = UDim2.new(0, 4, 0, 62)
    scroll.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ScrollBarThickness = 8
    scroll.BorderSizePixel = 1
    scroll.BorderColor3 = Color3.fromRGB(40, 40, 60)
    scroll.Parent = main

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = scroll

    -- Función para poblar la lista
    local function PopulateList(filter)
        -- Limpiar items anteriores
        for _, c in ipairs(scroll:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end

        for i, entry in ipairs(DiagLog) do
            local status = entry[1]
            local cat = entry[2]
            local msg = entry[3]
            local detail = entry[4]

            -- Filtrar
            if filter ~= "ALL" then
                if filter == "FAIL" and status ~= "FAIL" then continue end
                if filter == "WARN" and status ~= "WARN" then continue end
                if filter == "PASS" and status ~= "PASS" then continue end
            end

            local row = Instance.new("Frame")
            row.Name = "Row_" .. tostring(i)
            row.Size = UDim2.new(1, -10, 0, 0) -- auto height
            row.AutomaticSize = Enum.AutomaticSize.Y
            row.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
            row.BorderSizePixel = 0
            row.Parent = scroll

            if status == "HEAD" then
                row.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
                local headLabel = Instance.new("TextLabel")
                headLabel.Size = UDim2.new(1, 0, 0, 28)
                headLabel.BackgroundTransparency = 1
                headLabel.Text = "  " .. msg
                headLabel.TextColor3 = Color3.fromRGB(120, 200, 255)
                headLabel.Font = Enum.Font.Code
                headLabel.TextSize = 13
                headLabel.TextXAlignment = Enum.TextXAlignment.Left
                headLabel.Parent = row
            else
                -- Indicador de color
                local indicator = Instance.new("Frame")
                indicator.Size = UDim2.new(0, 4, 1, 0)
                indicator.BorderSizePixel = 0
                indicator.Parent = row

                if status == "PASS" then indicator.BackgroundColor3 = Color3.fromRGB(40, 200, 80)
                elseif status == "FAIL" then indicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                elseif status == "WARN" then indicator.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
                else indicator.BackgroundColor3 = Color3.fromRGB(100, 150, 255) end

                local icon = status == "PASS" and "[OK]" or status == "FAIL" and "[FAIL]" or status == "WARN" and "[!]" or "[i]"
                
                local contentText = icon .. " " .. cat .. " > " .. msg
                if detail ~= "" then
                    contentText = contentText .. "\n     -> " .. detail
                end

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -8, 0, 0)
                label.AutomaticSize = Enum.AutomaticSize.Y
                label.Position = UDim2.new(0, 8, 0, 0)
                label.BackgroundTransparency = 1
                label.Text = contentText
                label.TextColor3 = status == "FAIL" and Color3.fromRGB(255, 130, 130) or
                                   status == "WARN" and Color3.fromRGB(255, 230, 130) or
                                   status == "PASS" and Color3.fromRGB(150, 255, 150) or
                                   Color3.fromRGB(200, 200, 200)
                label.Font = Enum.Font.Code
                label.TextSize = 11
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.TextYAlignment = Enum.TextYAlignment.Top
                label.TextWrapped = true
                label.Parent = row
            end
        end
    end

    tabAll.MouseButton1Click:Connect(function() PopulateList("ALL") end)
    tabFail.MouseButton1Click:Connect(function() PopulateList("FAIL") end)
    tabWarn.MouseButton1Click:Connect(function() PopulateList("WARN") end)
    tabPass.MouseButton1Click:Connect(function() PopulateList("PASS") end)

    -- Botones inferiores
    local bottomFrame = Instance.new("Frame")
    bottomFrame.Size = UDim2.new(1, 0, 0, 44)
    bottomFrame.Position = UDim2.new(0, 0, 1, -44)
    bottomFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    bottomFrame.BorderSizePixel = 0
    bottomFrame.Parent = main

    -- Botón: Guardar archivo
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.48, 0, 0, 36)
    saveBtn.Position = UDim2.new(0, 4, 0, 4)
    saveBtn.BackgroundColor3 = Color3.fromRGB(0, 90, 180)
    saveBtn.Text = "GUARDAR DIAGNOSTICO .TXT"
    saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveBtn.Font = Enum.Font.Code
    saveBtn.TextSize = 11
    saveBtn.BorderSizePixel = 0
    saveBtn.Parent = bottomFrame

    saveBtn.MouseButton1Click:Connect(function()
        pcall(function()
            if writefile then
                writefile("Diagnostico_Resultado.txt", FullText)
                saveBtn.Text = "GUARDADO EN WORKSPACE!"
                saveBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
            else
                saveBtn.Text = "writefile NO DISPONIBLE"
                saveBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
            end
            task.delay(3, function()
                pcall(function()
                    saveBtn.Text = "GUARDAR DIAGNOSTICO .TXT"
                    saveBtn.BackgroundColor3 = Color3.fromRGB(0, 90, 180)
                end)
            end)
        end)
    end)

    -- Botón: Copiar a portapapeles
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0.48, 0, 0, 36)
    copyBtn.Position = UDim2.new(0.5, 4, 0, 4)
    copyBtn.BackgroundColor3 = Color3.fromRGB(100, 60, 160)
    copyBtn.Text = "COPIAR AL PORTAPAPELES"
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.Font = Enum.Font.Code
    copyBtn.TextSize = 11
    copyBtn.BorderSizePixel = 0
    copyBtn.Parent = bottomFrame

    copyBtn.MouseButton1Click:Connect(function()
        pcall(function()
            if setclipboard then
                setclipboard(FullText)
                copyBtn.Text = "COPIADO!"
                copyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
            elseif toclipboard then
                toclipboard(FullText)
                copyBtn.Text = "COPIADO!"
                copyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
            else
                copyBtn.Text = "CLIPBOARD NO DISPONIBLE"
                copyBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
            end
            task.delay(3, function()
                pcall(function()
                    copyBtn.Text = "COPIAR AL PORTAPAPELES"
                    copyBtn.BackgroundColor3 = Color3.fromRGB(100, 60, 160)
                end)
            end)
        end)
    end)

    -- Poblar lista inicial con todos
    PopulateList("ALL")
end

-- Ejecutar la GUI de resultados
pcall(BuildResultGUI)

-- Fallback: si la GUI falla, al menos el reporte está en la consola
print("[DIAGNOSTICO] Reporte completo impreso arriba en Output (F9). Total: PASS=" .. PassCount .. " FAIL=" .. ErrorCount .. " WARN=" .. WarnCount)
