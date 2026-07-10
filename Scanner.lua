-- EVOMON SCANNER - Salida por Clipboard + GUI TextBox
local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LP      = Players.LocalPlayer

pcall(function()
    local old = CoreGui:FindFirstChild("EvoScanner")
    if old then old:Destroy() end
end)

-- =====================================================
-- GUI
-- =====================================================
local SG = Instance.new("ScreenGui")
SG.Name = "EvoScanner"
SG.ResetOnSpawn = false
pcall(function() SG.Parent = CoreGui end)
if not SG.Parent or SG.Parent ~= CoreGui then
    pcall(function() SG.Parent = LP:WaitForChild("PlayerGui",5) end)
end

local Frame = Instance.new("Frame")
Frame.Size     = UDim2.new(0, 520, 0, 460)
Frame.Position = UDim2.new(0.5,-260,0.5,-230)
Frame.BackgroundColor3 = Color3.fromRGB(15,15,20)
Frame.BorderSizePixel = 0
Frame.Parent = SG
Instance.new("UICorner",Frame).CornerRadius = UDim.new(0,8)

local TBar = Instance.new("Frame")
TBar.Size = UDim2.new(1,0,0,32)
TBar.BackgroundColor3 = Color3.fromRGB(25,25,40)
TBar.BorderSizePixel = 0
TBar.Parent = Frame
Instance.new("UICorner",TBar).CornerRadius = UDim.new(0,8)

local TLbl = Instance.new("TextLabel")
TLbl.Size = UDim2.new(1,-10,1,0)
TLbl.Position = UDim2.new(0,10,0,0)
TLbl.BackgroundTransparency = 1
TLbl.Text = "EVOMON SCANNER - Salida: Clipboard + Console"
TLbl.TextColor3 = Color3.fromRGB(100,220,255)
TLbl.Font = Enum.Font.GothamBold
TLbl.TextSize = 13
TLbl.TextXAlignment = Enum.TextXAlignment.Left
TLbl.Parent = TBar

-- Botones
local function mkBtn(txt, x, w2, r,g,b)
    local b = Instance.new("TextButton")
    b.Position = UDim2.new(0,x,0,35)
    b.Size     = UDim2.new(0,w2,0,26)
    b.BackgroundColor3 = Color3.fromRGB(r,g,b)
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.BorderSizePixel = 0
    b.Parent = Frame
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,5)
    return b
end

local BtnScan    = mkBtn("ESCANEAR", 8, 150, 41,128,185)
local BtnCopy    = mkBtn("COPIAR AL CLIPBOARD", 165, 180, 39,174,96)
local BtnClear   = mkBtn("LIMPIAR", 352, 80, 80,80,80)
local BtnClose   = mkBtn("X", 438, 74, 192,57,43)

-- Area de texto (muestra todo el resultado)
local TBox = Instance.new("TextBox")
TBox.Size = UDim2.new(1,-10,1,-70)
TBox.Position = UDim2.new(0,5,0,65)
TBox.BackgroundColor3 = Color3.fromRGB(10,10,13)
TBox.TextColor3 = Color3.fromRGB(200,255,200)
TBox.Font = Enum.Font.Code
TBox.TextSize = 10
TBox.TextXAlignment = Enum.TextXAlignment.Left
TBox.TextYAlignment = Enum.TextYAlignment.Top
TBox.MultiLine = true
TBox.ClearTextOnFocus = false
TBox.Text = "Presiona ESCANEAR para comenzar.\nLos resultados apareceran aqui.\nTambien se intentara copiar al clipboard."
TBox.BorderSizePixel = 0
TBox.Parent = Frame
Instance.new("UICorner",TBox).CornerRadius = UDim.new(0,5)

-- =====================================================
-- ESCANEO
-- =====================================================
local scanData = {}

local function rec(s)
    table.insert(scanData, s)
    print("[SCAN] " .. s)
end

local function runScan()
    scanData = {}
    TBox.Text = "Escaneando..."
    BtnScan.Text = "Escaneando..."
    BtnScan.BackgroundColor3 = Color3.fromRGB(80,80,80)

    task.wait(0.1)

    rec("=== EVOMON DEEP SCAN === " .. os.date("%H:%M:%S"))
    rec("")

    -- 1. NPCs en workspace
    rec("[1] NPCs EN WORKSPACE (sin jugadores)")
    local playerNames = {}
    pcall(function()
        for _,p in ipairs(Players:GetPlayers()) do playerNames[p.Name]=true end
    end)
    local npcCount = 0
    pcall(function()
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and not playerNames[obj.Name] then
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                local hum = obj:FindFirstChildOfClass("Humanoid")
                if hrp and hum then
                    local dist = -1
                    pcall(function()
                        local c = LP.Character
                        if c and c:FindFirstChild("HumanoidRootPart") then
                            dist = math.floor((hrp.Position - c.HumanoidRootPart.Position).Magnitude)
                        end
                    end)
                    rec("NPC|" .. obj.Name .. "|dist=" .. dist .. "|" .. obj:GetFullName())
                    pcall(function()
                        for _,pp in ipairs(obj:GetDescendants()) do
                            if pp:IsA("ProximityPrompt") then
                                rec("  PP|"..pp.ActionText.."|"..pp:GetFullName())
                            end
                        end
                    end)
                    npcCount += 1
                end
            end
        end
    end)
    rec("TOTAL_NPCS=" .. npcCount)
    rec("")
    task.wait(0.05)

    -- 2. Botones en PlayerGui
    rec("[2] BOTONES EN PLAYERGUI")
    pcall(function()
        local pg = LP:FindFirstChildOfClass("PlayerGui")
        if pg then
            for _,obj in ipairs(pg:GetDescendants()) do
                if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                    local vis = obj.Visible and "VIS" or "HID"
                    local txt = ""
                    pcall(function() if obj:IsA("TextButton") then txt=obj.Text end end)
                    rec("BTN|"..vis.."|"..obj.Name.."|"..txt.."|"..obj:GetFullName())
                end
            end
        end
    end)
    rec("")
    task.wait(0.05)

    -- 3. RemoteEvents
    rec("[3] REMOTEEVENTS RS")
    pcall(function()
        local kw={"battle","catch","escape","flee","pity","summon","monster","capture","operate","enter","settle","result","wild"}
        for _,obj in ipairs(RS:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local low = string.lower(obj.Name)
                for _,k in ipairs(kw) do
                    if string.find(low,k) then
                        rec("REMOTE|"..obj.ClassName.."|"..obj.Name.."|"..obj:GetFullName())
                        break
                    end
                end
            end
        end
    end)
    rec("")
    task.wait(0.05)

    -- 4. ProximityPrompts globales
    rec("[4] PROXIMITYPROMPTS GLOBALES")
    pcall(function()
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                rec("PP|"..obj.ActionText.."|en="..tostring(obj.Enabled).."|"..obj:GetFullName())
            end
        end
    end)
    rec("")
    task.wait(0.05)

    -- 5. Valores del jugador
    rec("[5] PLAYER VALUES")
    pcall(function()
        local function scanF(folder, prefix)
            for _,v in ipairs(folder:GetChildren()) do
                if v:IsA("ValueBase") then
                    rec("VAL|"..prefix..v.Name.."="..tostring(v.Value))
                elseif v:IsA("Folder") or v:IsA("Configuration") then
                    scanF(v, prefix..v.Name.."/")
                end
            end
        end
        scanF(LP,"")
    end)
    rec("")
    task.wait(0.05)

    -- 6. TextLabels con pity/shiny/catch
    rec("[6] TEXTLABELS ACTIVOS")
    pcall(function()
        local pg = LP:FindFirstChildOfClass("PlayerGui")
        if pg then
            for _,obj in ipairs(pg:GetDescendants()) do
                if (obj:IsA("TextLabel") or obj:IsA("TextBox")) and obj.Text~="" then
                    local t = string.lower(obj.Text)
                    if string.find(t,"pity") or string.find(t,"shiny") or string.find(t,"prismatic")
                    or string.find(t,"catch") or string.find(t,"escape") or string.find(t,"ball")
                    or string.find(t,"rate") or string.find(t,"flee") then
                        rec("LBL|"..obj.Name.."|"..obj.Text.."|"..obj:GetFullName())
                    end
                end
            end
        end
    end)
    rec("")
    task.wait(0.05)

    -- 7. RS estructura
    rec("[7] RS ESTRUCTURA")
    pcall(function()
        for _,c in ipairs(RS:GetChildren()) do
            rec("RS/"..c.Name.."("..c.ClassName..")")
        end
    end)
    rec("")
    task.wait(0.05)

    -- 8. RuntimeCache
    rec("[8] RUNTIMECACHE MODELOS")
    pcall(function()
        local rc = workspace:FindFirstChild("RuntimeCache")
        if rc then
            local srv = rc:FindFirstChild("RuntimeCacheServer")
            if srv then
                local cc = srv:FindFirstChild("CreatureModelCache")
                if cc then
                    local seen={}
                    for _,folder in ipairs(cc:GetChildren()) do
                        for _,mdl in ipairs(folder:GetChildren()) do
                            if mdl:IsA("Model") and not seen[mdl.Name] then
                                seen[mdl.Name]=true
                                local h1=mdl:FindFirstChild("HumanoidRootPart")~=nil
                                local h2=mdl:FindFirstChildOfClass("Humanoid")~=nil
                                rec("CACHE|"..mdl.Name.."|HRP="..tostring(h1).."|Hum="..tostring(h2).."|"..folder.Name)
                            end
                        end
                    end
                end
            end
        else
            rec("RuntimeCache NO encontrado")
        end
    end)
    rec("")

    rec("=== FIN SCAN ===")

    -- Mostrar en TextBox
    local full = table.concat(scanData, "\n")
    TBox.Text = full

    -- Intentar guardar archivo
    local saved = false
    pcall(function()
        if writefile then writefile("EvomonQA_ScanData.txt", full) saved=true end
    end)
    pcall(function()
        if not saved and WriteFile then WriteFile("EvomonQA_ScanData.txt", full) saved=true end
    end)

    -- Intentar clipboard
    local clipped = false
    pcall(function()
        if setclipboard then setclipboard(full) clipped=true end
    end)
    pcall(function()
        if not clipped and copyToClipboard then copyToClipboard(full) clipped=true end
    end)

    local status = ""
    if saved then status = status .. " | ARCHIVO CREADO" end
    if clipped then status = status .. " | COPIADO AL CLIPBOARD" end
    if status == "" then status = " | LEE EL OUTPUT DE CONSOLA" end

    BtnScan.Text = "LISTO" .. status
    BtnScan.BackgroundColor3 = Color3.fromRGB(39,174,96)

    -- Todo impreso en consola igual
    print("====== EVOMON SCAN COMPLETO ======")
    print(full)
    print("==================================")
end

BtnScan.MouseButton1Click:Connect(function() task.spawn(runScan) end)

BtnCopy.MouseButton1Click:Connect(function()
    local full = table.concat(scanData,"\n")
    if full == "" then TBox.Text = "Primero presiona ESCANEAR" return end
    local ok = false
    pcall(function() if setclipboard then setclipboard(full) ok=true end end)
    if ok then
        BtnCopy.Text = "COPIADO!"
        task.delay(2, function() BtnCopy.Text = "COPIAR AL CLIPBOARD" end)
    else
        TBox.Text = "setclipboard no disponible.\nCopia el texto del area de abajo manualmente.\n\n" .. full
    end
end)

BtnClear.MouseButton1Click:Connect(function()
    scanData = {}
    TBox.Text = ""
end)

BtnClose.MouseButton1Click:Connect(function()
    SG:Destroy()
end)
