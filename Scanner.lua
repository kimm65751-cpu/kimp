-- EVOMON DEEP SCANNER - Con GUI y anti-crash total
local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LP      = Players.LocalPlayer

-- =====================================================
-- GUI BASICA (siempre visible)
-- =====================================================
pcall(function()
    local old = CoreGui:FindFirstChild("EvoScanner")
    if old then old:Destroy() end
end)

local SG = Instance.new("ScreenGui")
SG.Name = "EvoScanner"
SG.ResetOnSpawn = false
pcall(function() SG.Parent = CoreGui end)
if not SG.Parent or SG.Parent ~= CoreGui then
    pcall(function() SG.Parent = LP:WaitForChild("PlayerGui", 5) end)
end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 500, 0, 400)
Frame.Position = UDim2.new(0.5, -250, 0.5, -200)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Frame.BorderSizePixel = 0
Frame.Parent = SG
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.Text = "EVOMON SCANNER"
Title.TextColor3 = Color3.fromRGB(100, 220, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BorderSizePixel = 0
Title.Parent = Frame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

local BtnScan = Instance.new("TextButton")
BtnScan.Size = UDim2.new(1, -20, 0, 32)
BtnScan.Position = UDim2.new(0, 10, 0, 38)
BtnScan.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
BtnScan.Text = ">>> INICIAR ESCANEO <<<"
BtnScan.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnScan.Font = Enum.Font.GothamBold
BtnScan.TextSize = 13
BtnScan.BorderSizePixel = 0
BtnScan.Parent = Frame
Instance.new("UICorner", BtnScan).CornerRadius = UDim.new(0, 6)

local Log = Instance.new("ScrollingFrame")
Log.Size = UDim2.new(1, -10, 1, -80)
Log.Position = UDim2.new(0, 5, 0, 75)
Log.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
Log.BorderSizePixel = 0
Log.ScrollBarThickness = 3
Log.Parent = Frame
Instance.new("UIListLayout", Log).SortOrder = Enum.SortOrder.LayoutOrder

local lineCount = 0
local function addLine(txt, r, g, b)
    lineCount += 1
    local lbl = Instance.new("TextLabel")
    lbl.LayoutOrder = lineCount
    lbl.Size = UDim2.new(1, -4, 0, 14)
    lbl.BackgroundTransparency = 1
    lbl.Text = txt
    lbl.TextSize = 10
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = Color3.fromRGB(r or 200, g or 200, b or 200)
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.Parent = Log
    Log.CanvasSize = UDim2.new(0, 0, 0, lineCount * 14 + 4)
    Log.CanvasPosition = Vector2.new(0, lineCount * 14)
    print("[SCAN] " .. txt)
end

-- =====================================================
-- ESCRITURA DE ARCHIVO (con fallback a solo print)
-- =====================================================
local fileLines = {}
local function rec(s)
    table.insert(fileLines, s)
end
local function saveFile()
    local content = table.concat(fileLines, "\n")
    local saved = false
    pcall(function()
        if writefile then
            writefile("EvomonQA_ScanData.txt", content)
            saved = true
        end
    end)
    if saved then
        addLine("ARCHIVO GUARDADO: EvomonQA_ScanData.txt", 100, 255, 100)
    else
        addLine("writefile NO disponible - lee el output del executor", 255, 200, 80)
        -- Imprimir todo en consola igual
        print("======= SCAN DATA =======")
        print(content)
        print("=========================")
    end
end

-- =====================================================
-- ESCANEO PRINCIPAL
-- =====================================================
BtnScan.MouseButton1Click:Connect(function()
    BtnScan.Text = "Escaneando..."
    BtnScan.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    fileLines = {}
    lineCount = 0
    for _, c in ipairs(Log:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end

    task.wait(0.1)
    rec("=== EVOMON DEEP SCAN === " .. os.date("%H:%M:%S"))
    rec("")

    -- =====================================================
    -- SECCION 1: NPCs en workspace (sin jugadores)
    -- =====================================================
    addLine("=== [1] BUSCANDO NPCS EN WORKSPACE ===", 100, 220, 255)
    rec("[1] NPCs EN WORKSPACE CON HUMANOID")
    
    local playerNames = {}
    pcall(function()
        for _, p in ipairs(Players:GetPlayers()) do
            playerNames[p.Name] = true
        end
    end)

    local npcCount = 0
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and not playerNames[obj.Name] then
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                local hum = obj:FindFirstChildOfClass("Humanoid")
                if hrp and hum then
                    local char = LP.Character
                    local dist = -1
                    pcall(function()
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            dist = math.floor((hrp.Position - char.HumanoidRootPart.Position).Magnitude)
                        end
                    end)
                    local line = "NPC|" .. obj.Name .. "|dist=" .. dist .. "|" .. obj:GetFullName()
                    rec(line)
                    addLine(line, 150, 255, 150)
                    npcCount += 1

                    -- ProximityPrompts
                    pcall(function()
                        for _, pp in ipairs(obj:GetDescendants()) do
                            if pp:IsA("ProximityPrompt") then
                                local pl = "  PP|" .. pp.ActionText .. "|" .. pp:GetFullName()
                                rec(pl)
                                addLine(pl, 255, 200, 100)
                            end
                        end
                    end)
                end
            end
        end
    end)
    rec("TOTAL_NPCS=" .. npcCount)
    addLine("Total NPCs: " .. npcCount, 100, 255, 100)
    rec("")
    task.wait(0.05)

    -- =====================================================
    -- SECCION 2: BOTONES EN PLAYERGUI
    -- =====================================================
    addLine("=== [2] BOTONES EN PLAYERGUI ===", 100, 220, 255)
    rec("[2] BOTONES PLAYERGUI")
    pcall(function()
        local pg = LP:FindFirstChildOfClass("PlayerGui")
        if pg then
            for _, obj in ipairs(pg:GetDescendants()) do
                if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                    local vis = obj.Visible and "VISIBLE" or "hidden"
                    local txt = ""
                    pcall(function()
                        if obj:IsA("TextButton") then txt = obj.Text end
                    end)
                    local line = "BTN|" .. vis .. "|" .. obj.Name .. "|\"" .. txt .. "\"|" .. obj:GetFullName()
                    rec(line)
                    if obj.Visible then
                        addLine(line, 200, 200, 255)
                    end
                end
            end
        else
            rec("ERROR: Sin PlayerGui")
            addLine("ERROR: Sin PlayerGui", 255, 80, 80)
        end
    end)
    rec("")
    task.wait(0.05)

    -- =====================================================
    -- SECCION 3: REMOTEEVENTS EN RS
    -- =====================================================
    addLine("=== [3] REMOTEEVENTS RELEVANTES ===", 100, 220, 255)
    rec("[3] REMOTEEVENTS EN RS")
    pcall(function()
        local kw = {"battle","catch","escape","flee","pity","summon","monster","capture","operate","enter","settle","result","wild"}
        for _, obj in ipairs(RS:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local low = string.lower(obj.Name)
                for _, k in ipairs(kw) do
                    if string.find(low, k) then
                        local line = "REMOTE|" .. obj.ClassName .. "|" .. obj.Name .. "|" .. obj:GetFullName()
                        rec(line)
                        addLine(line, 255, 180, 100)
                        break
                    end
                end
            end
        end
    end)
    rec("")
    task.wait(0.05)

    -- =====================================================
    -- SECCION 4: PROXIMITYPROMPTS EN WORKSPACE
    -- =====================================================
    addLine("=== [4] PROXIMITYPROMPTS GLOBALES ===", 100, 220, 255)
    rec("[4] PROXIMITYPROMPTS")
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local line = "PP|" .. obj.ActionText .. "|enabled=" .. tostring(obj.Enabled) .. "|" .. obj:GetFullName()
                rec(line)
                addLine(line, 255, 220, 100)
            end
        end
    end)
    rec("")
    task.wait(0.05)

    -- =====================================================
    -- SECCION 5: VALORES DEL JUGADOR (pity, shiny, stats)
    -- =====================================================
    addLine("=== [5] DATOS DEL JUGADOR ===", 100, 220, 255)
    rec("[5] PLAYER VALUES")
    pcall(function()
        local function scanFolder(folder, prefix)
            for _, v in ipairs(folder:GetChildren()) do
                if v:IsA("ValueBase") then
                    local line = "VAL|" .. prefix .. v.Name .. "=" .. tostring(v.Value)
                    rec(line)
                    addLine(line, 200, 255, 200)
                elseif v:IsA("Folder") or v:IsA("Model") then
                    scanFolder(v, prefix .. v.Name .. "/")
                end
            end
        end
        scanFolder(LP, "")
    end)
    rec("")
    task.wait(0.05)

    -- =====================================================
    -- SECCION 6: TEXTLABELS ACTIVOS CON DATOS DE INTERES
    -- =====================================================
    addLine("=== [6] TEXTLABELS ACTIVOS (pity/shiny/catch) ===", 100, 220, 255)
    rec("[6] TEXTLABELS ACTIVOS")
    pcall(function()
        local pg = LP:FindFirstChildOfClass("PlayerGui")
        if pg then
            for _, obj in ipairs(pg:GetDescendants()) do
                if (obj:IsA("TextLabel") or obj:IsA("TextBox")) and obj.Text ~= "" and obj.Text ~= " " then
                    local t = string.lower(obj.Text)
                    if string.find(t,"pity") or string.find(t,"shiny") or string.find(t,"prismatic")
                    or string.find(t,"catch") or string.find(t,"captur") or string.find(t,"rate")
                    or string.find(t,"escape") or string.find(t,"flee") or string.find(t,"ball") then
                        local line = "LBL|" .. obj.Name .. "|\"" .. obj.Text .. "\"|" .. obj:GetFullName()
                        rec(line)
                        addLine(line, 255, 255, 150)
                    end
                end
            end
        end
    end)
    rec("")
    task.wait(0.05)

    -- =====================================================
    -- SECCION 7: ESTRUCTURA RS (carpetas)
    -- =====================================================
    addLine("=== [7] RS ESTRUCTURA ===", 100, 220, 255)
    rec("[7] REPLICATEDSTORAGE ESTRUCTURA")
    pcall(function()
        for _, child in ipairs(RS:GetChildren()) do
            rec("RS/" .. child.Name .. " (" .. child.ClassName .. ")")
            for _, sub in ipairs(child:GetChildren()) do
                rec("  RS/" .. child.Name .. "/" .. sub.Name .. " (" .. sub.ClassName .. ")")
            end
        end
    end)
    rec("")
    task.wait(0.05)

    -- =====================================================
    -- SECCION 8: RUNTIMECACHE
    -- =====================================================
    addLine("=== [8] RUNTIMECACHE ===", 100, 220, 255)
    rec("[8] RUNTIMECACHE")
    pcall(function()
        local rc = workspace:FindFirstChild("RuntimeCache")
        if rc then
            for _, child in ipairs(rc:GetChildren()) do
                rec("RC/" .. child.Name)
                for _, sub in ipairs(child:GetChildren()) do
                    rec("  RC/" .. child.Name .. "/" .. sub.Name .. " (" .. sub.ClassName .. ")")
                    if sub.Name == "CreatureModelCache" then
                        local seen = {}
                        for _, folder in ipairs(sub:GetChildren()) do
                            for _, mdl in ipairs(folder:GetChildren()) do
                                if mdl:IsA("Model") and not seen[mdl.Name] then
                                    seen[mdl.Name] = true
                                    local hasHRP = mdl:FindFirstChild("HumanoidRootPart") ~= nil
                                    local hasHum = mdl:FindFirstChildOfClass("Humanoid") ~= nil
                                    rec("    MODEL|" .. mdl.Name .. "|HRP=" .. tostring(hasHRP) .. "|Hum=" .. tostring(hasHum))
                                    addLine("CACHE: " .. mdl.Name .. " HRP=" .. tostring(hasHRP), 180, 180, 255)
                                end
                            end
                        end
                    end
                end
            end
        else
            rec("RuntimeCache NO existe")
            addLine("RuntimeCache NO existe en workspace", 255, 80, 80)
        end
    end)
    rec("")

    rec("=== FIN DEL SCAN ===")
    addLine("=== FIN DEL SCAN ===", 100, 255, 100)

    saveFile()

    BtnScan.Text = "SCAN COMPLETO - corre de nuevo en batalla"
    BtnScan.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
end)

addLine("Script listo. Presiona el boton azul para escanear.", 100, 200, 255)
addLine("Corre DENTRO de Roblox con tu executor.", 255, 200, 80)
