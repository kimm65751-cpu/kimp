-- =====================================================
-- EVOMON QA v3 - Basado en EvomonQA_LiveReport.txt
-- Monstruos reales: CreatureModelCache/Npc[N]
-- Batalla: BattleCatchOption1-4, BattleCatchConfirm
-- Pity:    ClientSummonMonsterPityHasChanged
-- =====================================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui    = game:GetService("CoreGui")
local RS         = game:GetService("ReplicatedStorage")

local LP = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- =====================================================
-- LOG EN VIVO -> EvomonQA_LiveReport.txt
-- =====================================================
local LOG_FILE = "EvomonQA_LiveReport.txt"
pcall(function()
    if writefile then
        writefile(LOG_FILE, "=== EVOMON QA v3 INICIADO: " .. os.date("%H:%M:%S") .. " ===\n")
    end
end)

local function log(tag, msg)
    local line = string.format("[%s][%s] %s", os.date("%H:%M:%S"), tag, msg)
    print(line)
    pcall(function()
        if appendfile then appendfile(LOG_FILE, line .. "\n")
        elseif writefile and isfile then
            writefile(LOG_FILE, (isfile(LOG_FILE) and readfile(LOG_FILE) or "") .. line .. "\n")
        end
    end)
    return line
end

-- =====================================================
-- GUI
-- =====================================================
do
    local old = CoreGui:FindFirstChild("EvoQAv3")
    if old then old:Destroy() end
end

local SG = Instance.new("ScreenGui")
SG.Name = "EvoQAv3"
SG.ResetOnSpawn = false
pcall(function() SG.Parent = CoreGui end)
if not SG.Parent or SG.Parent ~= CoreGui then
    SG.Parent = LP:WaitForChild("PlayerGui")
end

-- Panel principal
local Panel = Instance.new("Frame")
Panel.Size        = UDim2.new(0, 420, 0, 420)
Panel.Position    = UDim2.new(1, -430, 1, -440)
Panel.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Panel.BorderSizePixel  = 0
Panel.Parent = SG
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 10)

-- Barra de título
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,36)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Panel
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(1,-10,1,0)
TitleLbl.Position = UDim2.new(0,10,0,0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "⚔ EVOMON QA v3"
TitleLbl.TextColor3 = Color3.fromRGB(255,255,255)
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextSize = 14
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.Parent = TitleBar

-- Columna izquierda: botones
local BtnCol = Instance.new("Frame")
BtnCol.Size = UDim2.new(0,130,1,-44)
BtnCol.Position = UDim2.new(0,8,0,40)
BtnCol.BackgroundTransparency = 1
BtnCol.Parent = Panel
local BtnLayout = Instance.new("UIListLayout", BtnCol)
BtnLayout.Padding = UDim.new(0,6)

local function makeBtn(txt, r,g,b)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,34)
    b.BackgroundColor3 = Color3.fromRGB(r,g,b)
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 10
    b.TextWrapped = true
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)
    b.Parent = BtnCol
    return b
end

local BtnScan    = makeBtn("🔍 BUSCAR\nEVOMONS", 41,128,185)
local BtnWalk    = makeBtn("🚶 CAMINAR\nAL MARCADO", 39,174,96)
local BtnCapture = makeBtn("🎯 CAPTURAR\n(al final batalla)", 142,68,173)
local BtnFlee    = makeBtn("🏃 HUIR\n(sin capturar)", 243,156,18)
local BtnPity    = makeBtn("⭐ PITY\nPRISMATIC/SHINY", 52,73,94)
local BtnClear   = makeBtn("🗑 LIMPIAR\nLOG", 80,80,80)

-- Consola derecha
local Console = Instance.new("ScrollingFrame")
Console.Size = UDim2.new(1,-146,1,-44)
Console.Position = UDim2.new(0,140,0,40)
Console.BackgroundColor3 = Color3.fromRGB(12,12,15)
Console.BorderSizePixel = 0
Console.ScrollBarThickness = 3
Console.Parent = Panel
Instance.new("UICorner", Console).CornerRadius = UDim.new(0,6)
local ConLayout = Instance.new("UIListLayout", Console)
ConLayout.SortOrder = Enum.SortOrder.LayoutOrder

local logN = 0
local function uiLog(tag, msg, r,g,b)
    logN += 1
    local lbl = Instance.new("TextLabel")
    lbl.LayoutOrder = logN
    lbl.Size = UDim2.new(1,-6,0,15)
    lbl.BackgroundTransparency = 1
    lbl.Text = "[" .. tag .. "] " .. msg
    lbl.TextSize = 10
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = Color3.fromRGB(r or 200, g or 200, b or 200)
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.Parent = Console
    Console.CanvasSize = UDim2.new(0,0,0, logN*15+4)
    Console.CanvasPosition = Vector2.new(0, logN*15)
    log(tag, msg)
end

-- =====================================================
-- ESTADO GLOBAL
-- =====================================================
local targetMonster = nil   -- modelo seleccionado
local targetName    = ""
local isWalking     = false
local pityActive    = false
local pityConns     = {}

-- =====================================================
-- 1. BUSCAR EVOMONS CERCANOS
--    Basado en log: CreatureModelCache contiene Npc[N]
--    También busca MonsterSpawn[N] directos en workspace
-- =====================================================
BtnScan.MouseButton1Click:Connect(function()
    local char = LP.Character
    if not char then uiLog("ERR","Sin personaje",255,80,80) return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then uiLog("ERR","Sin HumanoidRootPart",255,80,80) return end

    uiLog("SCAN","Buscando Evomons cercanos...", 100,200,255)
    local found = {}

    -- Busca en CreatureModelCache (donde están los Npc reales según el log)
    local cache = workspace:FindFirstChild("RuntimeCache")
    if cache then
        local srv = cache:FindFirstChild("RuntimeCacheServer")
        if srv then
            local mCache = srv:FindFirstChild("CreatureModelCache")
            if mCache then
                for _, mdl in ipairs(mCache:GetChildren()) do
                    -- Cada hijo es un Model con Npc[N] dentro
                    for _, npc in ipairs(mdl:GetChildren()) do
                        if npc:IsA("Model") then
                            local npcHRP = npc:FindFirstChild("HumanoidRootPart")
                            if npcHRP then
                                local dist = (npcHRP.Position - hrp.Position).Magnitude
                                if dist < 300 then
                                    table.insert(found, {name=npc.Name, dist=math.floor(dist), model=npc, hrp=npcHRP})
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- También busca MonsterSpawn[N] directos en Workspace (según log)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and string.find(obj.Name, "MonsterSpawn") then
            local mHRP = obj:FindFirstChild("HumanoidRootPart")
            if mHRP then
                local dist = (mHRP.Position - hrp.Position).Magnitude
                if dist < 300 then
                    table.insert(found, {name=obj.Name, dist=math.floor(dist), model=obj, hrp=mHRP})
                end
            end
        end
    end

    -- También busca LeanMonster (visto en log: LeanMonster713)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and string.find(obj.Name, "LeanMonster") then
            local mHRP = obj:FindFirstChild("HumanoidRootPart")
            if mHRP then
                local dist = (mHRP.Position - hrp.Position).Magnitude
                if dist < 300 then
                    table.insert(found, {name=obj.Name, dist=math.floor(dist), model=obj, hrp=mHRP})
                end
            end
        end
    end

    if #found == 0 then
        uiLog("SCAN","Ningún Evomon cercano (<300 studs).", 255,200,80)
        log("SCAN","Sin resultados en radio 300 studs")
        return
    end

    -- Ordenar por distancia
    table.sort(found, function(a,b) return a.dist < b.dist end)

    uiLog("SCAN", #found .. " Evomon(s) encontrado(s):", 100,255,100)
    for i, e in ipairs(found) do
        local marker = (i == 1) and " ← AUTO-MARCADO" or ""
        uiLog("NPC", e.name .. "  " .. e.dist .. "st" .. marker,
              i==1 and 150 or 180,
              i==1 and 255 or 180,
              i==1 and 150 or 180)
        log("NPC_FOUND", e.name .. " dist=" .. e.dist)
    end

    -- Auto-marcar el más cercano
    targetMonster = found[1].model
    targetName    = found[1].name
    uiLog("MARK","Marcado: " .. targetName .. " (" .. found[1].dist .. " studs)", 255,255,100)
end)

-- =====================================================
-- 2. CAMINAR AL MARCADO (seguro, con timeout 20s)
-- =====================================================
BtnWalk.MouseButton1Click:Connect(function()
    if isWalking then
        uiLog("WALK","Ya caminando, espera...", 255,200,80)
        return
    end
    if not targetMonster or not targetMonster.Parent then
        uiLog("WALK","Ningún Evomon marcado. Usa BUSCAR primero.", 255,80,80)
        return
    end

    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    local destHRP = targetMonster:FindFirstChild("HumanoidRootPart")
    if not destHRP then
        uiLog("WALK","El Evomon ya no tiene HumanoidRootPart.", 255,80,80)
        targetMonster = nil
        return
    end

    isWalking = true
    local dest = destHRP.Position
    uiLog("WALK","Caminando hacia: " .. targetName, 100,200,255)
    log("WALK_START", targetName .. " pos=" .. tostring(dest))

    hum:MoveTo(dest)

    -- Timeout 20 segundos por si se bloquea
    local arrived = false
    local conn
    conn = hum.MoveToFinished:Connect(function(reached)
        arrived = true
        conn:Disconnect()
        isWalking = false
        if reached then
            uiLog("WALK","✔ Llegamos a: " .. targetName, 100,255,100)
            log("WALK_OK", targetName)
        else
            uiLog("WALK","✘ Camino bloqueado hacia: " .. targetName, 255,200,80)
            log("WALK_BLOCKED", targetName)
        end
    end)

    task.delay(20, function()
        if not arrived then
            isWalking = false
            conn:Disconnect()
            uiLog("WALK","⏱ Timeout 20s. Cancela o intenta de nuevo.", 255,150,50)
            log("WALK_TIMEOUT", targetName)
        end
    end)
end)

-- =====================================================
-- HELPER: Presionar botón de UI del juego por nombre
-- Usa los nombres REALES del log:
--   BattleCatchOption1, BattleCatchConfirm, BattleCatchCancel
-- =====================================================
local function pressGameBtn(btnName)
    local pg = LP:FindFirstChildOfClass("PlayerGui")
    if not pg then return false end
    for _, obj in ipairs(pg:GetDescendants()) do
        if (obj:IsA("TextButton") or obj:IsA("ImageButton")) then
            if string.lower(obj.Name) == string.lower(btnName) and obj.Visible then
                -- Método 1: fire connections (si el executor lo soporta)
                pcall(function()
                    if getconnections then
                        for _, c in ipairs(getconnections(obj.MouseButton1Click)) do
                            c:Fire()
                        end
                    end
                end)
                -- Método 2: firetouchinterest / firebutton fallback
                pcall(function()
                    if firebutton then firebutton(obj, "MouseButton1Click") end
                end)
                uiLog("BTN","Presionado: " .. obj.Name, 150,255,150)
                log("BTN_PRESS", obj.Name)
                return true
            end
        end
    end
    uiLog("BTN","No encontrado en pantalla: " .. btnName, 255,180,80)
    log("BTN_MISSING", btnName)
    return false
end

-- =====================================================
-- 3. CAPTURAR (al final de la batalla)
--    Botones reales del log:
--    BattleCatchOption1 → selecciona bola 1
--    BattleCatchConfirm → confirma captura
-- =====================================================
BtnCapture.MouseButton1Click:Connect(function()
    uiLog("CAP","Iniciando secuencia de captura...", 100,255,180)
    log("CAPTURE_SEQ","inicio")

    -- Abre menú de captura
    pressGameBtn("BattleCatchContext")
    task.wait(0.6)

    -- Selecciona bola 1 (básica)
    if not pressGameBtn("BattleCatchOption1") then
        -- Intentar opción 2 si la 1 no está
        pressGameBtn("BattleCatchOption2")
    end
    task.wait(0.6)

    -- Confirmar
    pressGameBtn("BattleCatchConfirm")
    task.wait(0.3)
    uiLog("CAP","Secuencia enviada. Revisá la pantalla.", 150,255,150)
end)

-- =====================================================
-- 4. HUIR SIN CAPTURAR
--    Botón real del log: BattleCatchCancel
--    También: ReqBattleResultAction (RemoteEvent del servidor)
-- =====================================================
BtnFlee.MouseButton1Click:Connect(function()
    uiLog("FLEE","Intentando huir/cancelar batalla...", 255,200,80)
    log("FLEE_SEQ","inicio")

    -- Botón de UI cancelar captura
    pressGameBtn("BattleCatchCancel")
    task.wait(0.5)

    -- También probar vía RemoteEvent si está disponible
    pcall(function()
        local battle = RS:FindFirstChild("Battle")
        if battle then
            local req = battle:FindFirstChild("ReqBattleResultAction")
            if req and req:IsA("RemoteEvent") then
                req:FireServer({action="flee"})
                uiLog("FLEE","FireServer ReqBattleResultAction enviado.", 255,200,80)
                log("FLEE_REMOTE","ReqBattleResultAction fired")
            end
        end
    end)
end)

-- =====================================================
-- 5. PITY TRACKER - PRISMATIC / SHINY
--    Evento real del log: ClientSummonMonsterPityHasChanged
--    También escucha TextLabels con "prismatic:" o "shiny:"
-- =====================================================
BtnPity.MouseButton1Click:Connect(function()
    -- Toggle
    pityActive = not pityActive

    if not pityActive then
        for _, c in ipairs(pityConns) do
            if typeof(c) == "RBXScriptConnection" then c:Disconnect() end
        end
        pityConns = {}
        BtnPity.Text = "⭐ PITY\nPRISMATIC/SHINY"
        BtnPity.BackgroundColor3 = Color3.fromRGB(52,73,94)
        uiLog("PITY","Tracker DESACTIVADO.", 180,180,180)
        return
    end

    BtnPity.Text = "⭐ PITY ON\n(click=apagar)"
    BtnPity.BackgroundColor3 = Color3.fromRGB(46,204,113)
    uiLog("PITY","Tracker ACTIVADO. Escuchando cambios de Pity...", 255,220,50)
    log("PITY","activado")

    -- Escuchar evento real: ClientSummonMonsterPityHasChanged
    pcall(function()
        -- Busca el RemoteEvent en SummonMonster o SummonMonsterStorage
        for _, folder in ipairs(RS:GetChildren()) do
            local pityEv = folder:FindFirstChild("ClientSummonMonsterPityHasChanged")
            if pityEv and pityEv:IsA("RemoteEvent") then
                local c = pityEv.OnClientEvent:Connect(function(data)
                    local msg = "PityChange recibido"
                    if type(data) == "table" then
                        for k,v in pairs(data) do
                            msg = msg .. " | " .. tostring(k) .. "=" .. tostring(v)
                        end
                    else
                        msg = msg .. " -> " .. tostring(data)
                    end
                    uiLog("PITY", msg, 255,220,50)
                    log("PITY_EVENT", msg)
                end)
                table.insert(pityConns, c)
                uiLog("PITY","✔ Evento ClientSummonMonsterPityHasChanged conectado.", 100,255,100)
            end

            -- También ResSummonMonsterSucc para cuando captura funciona
            local succEv = folder:FindFirstChild("ClientSummonMonsterSucc")
            if succEv and succEv:IsA("RemoteEvent") then
                local c = succEv.OnClientEvent:Connect(function(data)
                    local msg = "¡CAPTURA EXITOSA!"
                    if type(data) == "table" then
                        for k,v in pairs(data) do
                            msg = msg .. " " .. tostring(k) .. "=" .. tostring(v)
                        end
                    end
                    uiLog("PITY","⭐ " .. msg, 255,255,50)
                    log("CAPTURE_SUCCESS", msg)
                end)
                table.insert(pityConns, c)
            end
        end
    end)

    -- También escucha TextLabels con "prismatic" o "shiny"
    local pg = LP:WaitForChild("PlayerGui")
    local function checkText(obj)
        if obj:IsA("TextLabel") or obj:IsA("TextBox") then
            local function onTextChange()
                local t = string.lower(obj.Text)
                if string.find(t, "prismatic") or string.find(t, "shiny") then
                    uiLog("PITY","UI: " .. obj.Text, 255,220,50)
                    log("PITY_UI", obj.Text)
                end
            end
            local c = obj:GetPropertyChangedSignal("Text"):Connect(onTextChange)
            table.insert(pityConns, c)
        end
    end
    for _, obj in ipairs(pg:GetDescendants()) do checkText(obj) end
    local c2 = pg.DescendantAdded:Connect(function(obj) checkText(obj) end)
    table.insert(pityConns, c2)
end)

-- =====================================================
-- LIMPIAR LOG UI
-- =====================================================
BtnClear.MouseButton1Click:Connect(function()
    for _, lbl in ipairs(Console:GetChildren()) do
        if lbl:IsA("TextLabel") then lbl:Destroy() end
    end
    logN = 0
    Console.CanvasSize = UDim2.new(0,0,0,0)
end)

-- =====================================================
-- INIT
-- =====================================================
uiLog("SYS","Evomon QA v3 listo.", 100,200,255)
uiLog("SYS","1) BUSCAR → detecta Evomons cercanos", 180,180,180)
uiLog("SYS","2) CAMINAR → va al que marcaste", 180,180,180)
uiLog("SYS","3) CAPTURAR o HUIR → al final de batalla", 180,180,180)
uiLog("SYS","4) PITY → rastrea prismatic/shiny en vivo", 180,180,180)
log("SYS","Script v3 iniciado OK")
