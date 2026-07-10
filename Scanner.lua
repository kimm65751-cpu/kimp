-- Evomon QA Scanner - Con DEEP SCAN de NPCs, Botones, Remotes y ProximityPrompts
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local fileName = "EvomonQA_LiveReport.txt"

-- Detectar qué método de escritura funciona
local writeMethod = nil
local function tryInit()
    -- Método 1: writefile estándar
    if writefile then
        local ok = pcall(writefile, fileName, "=== EVOMON QA REPORT - INICIADO ===\n")
        if ok then writeMethod = "writefile" return end
    end
    -- Método 2: io.open estándar de Lua
    local f = io.open(fileName, "w")
    if f then f:write("=== EVOMON QA REPORT - INICIADO ===\n") f:close() writeMethod = "io" return end
    -- Método 3: ruta absoluta Android sdcard
    if writefile then
        local p = "/sdcard/" .. fileName
        local ok = pcall(writefile, p, "=== EVOMON QA REPORT - INICIADO ===\n")
        if ok then fileName = p writeMethod = "writefile_abs" return end
    end
end
tryInit()

local function writeLog(level, msg)
    local timeStr = os.date("%H:%M:%S")
    local fullMsg = string.format("[%s] [%s] %s", timeStr, level, msg)
    print("[EvomonQA] " .. fullMsg)
    if writeMethod == "writefile" then
        if appendfile then
            pcall(function() appendfile(fileName, fullMsg .. "\n") end)
        elseif writefile and isfile then
            pcall(function()
                local cur = isfile(fileName) and readfile(fileName) or ""
                writefile(fileName, cur .. fullMsg .. "\n")
            end)
        end
    elseif writeMethod == "io" or writeMethod == "writefile_abs" then
        pcall(function()
            local f = io.open(fileName, "a")
            if f then f:write(fullMsg .. "\n") f:close() end
        end)
    else
        -- Sin método disponible, solo print
    end
end

-- GUI
local SG = Instance.new("ScreenGui")
SG.Name = "EvomonQAGui"
SG.ResetOnSpawn = false
if pcall(function() SG.Parent = CoreGui end) then else SG.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 300)
MainFrame.Position = UDim2.new(1, -470, 1, -320)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = SG
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = " Evomon QA Scanner"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local BtnContainer = Instance.new("Frame")
BtnContainer.Size = UDim2.new(0, 120, 1, -50)
BtnContainer.Position = UDim2.new(0, 10, 0, 40)
BtnContainer.BackgroundTransparency = 1
BtnContainer.Parent = MainFrame
Instance.new("UIListLayout", BtnContainer).Padding = UDim.new(0, 6)

local function createButton(text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.TextWrapped = true
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.Parent = BtnContainer
    return btn
end

local BtnScan    = createButton("SCAN GENERAL",   Color3.fromRGB(41, 128, 185))
local BtnDeep    = createButton("DEEP SCAN\n(NPCs/Btns/Remotes)", Color3.fromRGB(155, 89, 182))
local BtnLive    = createButton("LIVE MONITOR",   Color3.fromRGB(39, 174, 96))
local BtnStop    = createButton("STOP",           Color3.fromRGB(192, 57, 43))
local BtnHide    = createButton("MINIMIZAR",      Color3.fromRGB(100, 100, 100))

local ConsoleBox = Instance.new("ScrollingFrame")
ConsoleBox.Size = UDim2.new(1, -140, 1, -50)
ConsoleBox.Position = UDim2.new(0, 135, 0, 40)
ConsoleBox.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
ConsoleBox.BorderSizePixel = 0
ConsoleBox.ScrollBarThickness = 4
ConsoleBox.Parent = MainFrame
Instance.new("UIListLayout", ConsoleBox).SortOrder = Enum.SortOrder.LayoutOrder

local logCount = 0
local function printUI(level, msg)
    logCount += 1
    local lbl = Instance.new("TextLabel")
    lbl.LayoutOrder = logCount
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = msg
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    if level == "CRITICAL" then lbl.TextColor3 = Color3.fromRGB(255, 100, 100)
    elseif level == "WARNING" then lbl.TextColor3 = Color3.fromRGB(255, 200, 100)
    elseif level == "LIVE" then lbl.TextColor3 = Color3.fromRGB(150, 255, 150)
    else lbl.TextColor3 = Color3.fromRGB(200, 200, 200) end
    lbl.Parent = ConsoleBox
    ConsoleBox.CanvasSize = UDim2.new(0, 0, 0, logCount * 16)
    ConsoleBox.CanvasPosition = Vector2.new(0, logCount * 16)
    writeLog(level, msg)
end

-- SCAN GENERAL (igual al original)
local function AnalyzeEvomon(obj)
    local name = string.lower(obj.Name)
    if string.find(name, "capture") or string.find(name, "pokeball") then printUI("INFO", "Sistema de Captura: " .. obj.Name) end
    if string.find(name, "battle") or string.find(name, "combat") then printUI("INFO", "Sistema de Batalla: " .. obj.Name) end
    if string.find(name, "evomon") or string.find(name, "monster") then printUI("INFO", "Dato de Criatura: " .. obj.Name) end
    if string.find(name, "inventory") or string.find(name, "item") then printUI("INFO", "Sistema de Inventario: " .. obj.Name) end
end

local function AnalyzeSecurity(obj)
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        if not obj:IsDescendantOf(ReplicatedStorage) then
            printUI("WARNING", "RemoteObject fuera de RS: " .. obj:GetFullName())
        end
        local name = string.lower(obj.Name)
        if string.find(name, "admin") or string.find(name, "money") then
            printUI("CRITICAL", "Remote sensible: " .. obj:GetFullName())
        end
    end
end

local function RunScanner()
    printUI("INFO", "INICIANDO ESCANEO PROFUNDO...")
    local n = 0
    local function scan(parent)
        for _, obj in ipairs(parent:GetChildren()) do
            n += 1
            if n % 500 == 0 then task.wait() end
            if obj:IsA("Script") or obj:IsA("LocalScript") then
                if obj.Disabled then printUI("WARNING", "Script Deshabilitado: " .. obj:GetFullName()) end
            elseif obj:IsA("ObjectValue") and obj.Value == nil then
                printUI("WARNING", "Referencia Rota en: " .. obj:GetFullName())
            end
            AnalyzeEvomon(obj)
            AnalyzeSecurity(obj)
            scan(obj)
        end
    end
    for _, t in ipairs({workspace, ReplicatedStorage}) do scan(t) end
    printUI("INFO", "ESCANEO FINALIZADO. (" .. n .. " objetos)")
end

-- DEEP SCAN - Acumula en tabla, un solo writefile al final para no crashear GUI
local function RunDeepScan()
    printUI("INFO", "=== DEEP SCAN INICIADO - datos van directo al .txt ===")
    local buf = {}
    local function b(s) table.insert(buf, tostring(s)) end

    b("=== DEEP SCAN " .. os.date("%H:%M:%S") .. " ===")

    -- Jugadores
    local pn = {}
    for _, p in ipairs(Players:GetPlayers()) do
        pn[p.Name] = true
        b("PLAYER|" .. p.Name)
    end
    printUI("INFO", "[DEEP] Jugadores: " .. #Players:GetPlayers())

    -- NPCs
    b("[NPCS]")
    local nc = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and not pn[obj.Name] then
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            local hum = obj:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                local d = -1
                local c = LocalPlayer.Character
                if c and c:FindFirstChild("HumanoidRootPart") then
                    d = math.floor((hrp.Position - c.HumanoidRootPart.Position).Magnitude)
                end
                b("NPC|" .. obj.Name .. "|dist=" .. d .. "|" .. obj:GetFullName())
                for _, pp in ipairs(obj:GetDescendants()) do
                    if pp:IsA("ProximityPrompt") then
                        b("  PP|" .. pp.ActionText .. "|" .. pp:GetFullName())
                    end
                end
                nc += 1
                if nc % 20 == 0 then task.wait() end
            end
        end
    end
    b("NPC_TOTAL=" .. nc)
    printUI("INFO", "[DEEP] NPCs encontrados: " .. nc)

    -- Botones
    b("[BOTONES]")
    local bc = 0
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if pg then
        for _, obj in ipairs(pg:GetDescendants()) do
            if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                local vis = obj.Visible and "VIS" or "HID"
                local txt = obj:IsA("TextButton") and obj.Text or "(img)"
                b("BTN|" .. vis .. "|" .. obj.Name .. "|" .. txt .. "|" .. obj:GetFullName())
                bc += 1
                if bc % 50 == 0 then task.wait() end
            end
        end
    end
    b("BTN_TOTAL=" .. bc)
    printUI("INFO", "[DEEP] Botones encontrados: " .. bc)

    -- RemoteEvents
    b("[REMOTES]")
    local kw = {"battle","catch","escape","flee","pity","summon","monster","capture","operate","enter","settle","wild","npc"}
    local rc = 0
    local oc = 0
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        oc += 1
        if oc % 100 == 0 then task.wait() end
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local n = string.lower(obj.Name)
            for _, k in ipairs(kw) do
                if string.find(n, k) then
                    b("REM|" .. obj.ClassName .. "|" .. obj.Name .. "|" .. obj:GetFullName())
                    rc += 1
                    break
                end
            end
        end
    end
    b("REM_TOTAL=" .. rc)
    printUI("INFO", "[DEEP] Remotes encontrados: " .. rc)

    -- ProximityPrompts
    b("[PROXPROMPTS]")
    local pc = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            b("PP|" .. obj.ActionText .. "|en=" .. tostring(obj.Enabled) .. "|" .. obj:GetFullName())
            pc += 1
        end
    end
    b("PP_TOTAL=" .. pc)
    printUI("INFO", "[DEEP] ProximityPrompts: " .. pc)

    b("=== FIN DEEP SCAN ===")

    -- UN SOLO writefile con todo el buffer
    local content = table.concat(buf, "\n")
    local saved = false
    if writefile then
        local ok = pcall(writefile, "EvoScanDeep.txt", content)
        if ok then saved = true printUI("LIVE", "GUARDADO: EvoScanDeep.txt") end
    end
    if not saved and appendfile then
        local ok = pcall(appendfile, fileName, "\n" .. content)
        if ok then saved = true printUI("LIVE", "AGREGADO AL: " .. fileName) end
    end
    if not saved then
        printUI("WARNING", "Sin acceso a archivos. Datos en consola (print).")
        print(content)
    end

    printUI("INFO", "=== DEEP SCAN COMPLETO: " .. nc .. " NPCs, " .. bc .. " Btns, " .. rc .. " Remotes ===")
end

-- LIVE MONITOR (igual al original)
local liveConnections = {}
local isLive = false

local function StartLive()
    isLive = true
    BtnLive.Text = "LIVE: ON"
    BtnLive.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    printUI("LIVE", "--- LIVE MONITOR ACTIVADO ---")
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    table.insert(liveConnections, pg.ChildAdded:Connect(function(ui) printUI("LIVE", "[GUI] Abrió: " .. ui.Name) end))
    table.insert(liveConnections, pg.ChildRemoved:Connect(function(ui) printUI("LIVE", "[GUI] Cerró: " .. ui.Name) end))
    local bp = LocalPlayer:WaitForChild("Backpack", 5)
    if bp then
        table.insert(liveConnections, bp.ChildAdded:Connect(function(i) printUI("LIVE", "[INV] +item: " .. i.Name) end))
        table.insert(liveConnections, bp.ChildRemoved:Connect(function(i) printUI("LIVE", "[INV] -item: " .. i.Name) end))
    end
    if LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local lastPos = hrp.Position
            local t = task.spawn(function()
                while task.wait(1) do
                    if not hrp or not hrp.Parent then break end
                    local dist = (hrp.Position - lastPos).Magnitude
                    if dist > 30 then printUI("LIVE", "[MAPA] Teleport detectado (" .. math.floor(dist) .. " studs)") end
                    lastPos = hrp.Position
                end
            end)
            table.insert(liveConnections, t)
        end
    end
end

local function StopLive()
    isLive = false
    BtnLive.Text = "LIVE MONITOR"
    BtnLive.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
    printUI("INFO", "--- LIVE MONITOR DETENIDO ---")
    for _, conn in ipairs(liveConnections) do
        if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
        if type(conn) == "thread" then task.cancel(conn) end
    end
    liveConnections = {}
end

BtnScan.MouseButton1Click:Connect(function() task.spawn(RunScanner) end)
BtnDeep.MouseButton1Click:Connect(function() task.spawn(RunDeepScan) end)
BtnLive.MouseButton1Click:Connect(function() if isLive then StopLive() else StartLive() end end)
BtnStop.MouseButton1Click:Connect(function() StopLive() end)

local hidden = false
BtnHide.MouseButton1Click:Connect(function()
    hidden = not hidden
    BtnContainer.Visible = not hidden
    ConsoleBox.Visible = not hidden
    MainFrame.Size = hidden and UDim2.new(0, 120, 0, 40) or UDim2.new(0, 450, 0, 300)
    BtnHide.Text = hidden and "MAXIMIZAR" or "MINIMIZAR"
end)

printUI("INFO", "Herramienta Inyectada con exito. Listo para operar.")
