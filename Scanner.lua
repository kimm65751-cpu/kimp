-- EVOMON SCANNER - Usa appendfile (igual que el script original que SÍ funcionó)
local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LP      = Players.LocalPlayer

local FILE = "EvomonQA_ScanData.txt"

-- Igual que el script original que generó EvomonQA_LiveReport.txt
local function wLine(s)
    print("[SCAN] " .. s)
    if appendfile then
        pcall(function() appendfile(FILE, s .. "\n") end)
    elseif writefile and isfile then
        pcall(function()
            local cur = isfile(FILE) and readfile(FILE) or ""
            writefile(FILE, cur .. s .. "\n")
        end)
    end
end

-- Reiniciar archivo
if writefile then
    pcall(function() writefile(FILE, "=== EVOMON SCAN " .. os.date("%H:%M:%S") .. " ===\n") end)
end

-- GUI minima solo para el boton
pcall(function()
    local old = CoreGui:FindFirstChild("EvoScan")
    if old then old:Destroy() end
end)

local SG = Instance.new("ScreenGui")
SG.Name = "EvoScan"
SG.ResetOnSpawn = false
pcall(function() SG.Parent = CoreGui end)
if not SG.Parent or SG.Parent ~= CoreGui then
    pcall(function() SG.Parent = LP:WaitForChild("PlayerGui",5) end)
end

local F = Instance.new("Frame")
F.Size = UDim2.new(0,280,0,90)
F.Position = UDim2.new(0.5,-140,0,10)
F.BackgroundColor3 = Color3.fromRGB(15,15,20)
F.BorderSizePixel = 0
F.Parent = SG
Instance.new("UICorner",F).CornerRadius = UDim.new(0,8)

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1,0,0,30)
Status.BackgroundTransparency = 1
Status.Text = "EVOMON SCANNER - listo"
Status.TextColor3 = Color3.fromRGB(100,220,255)
Status.Font = Enum.Font.GothamBold
Status.TextSize = 12
Status.Parent = F

local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(1,-16,0,34)
Btn.Position = UDim2.new(0,8,0,34)
Btn.BackgroundColor3 = Color3.fromRGB(41,128,185)
Btn.Text = ">>> ESCANEAR Y GUARDAR .TXT <<<"
Btn.TextColor3 = Color3.fromRGB(255,255,255)
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 12
Btn.BorderSizePixel = 0
Btn.Parent = F
Instance.new("UICorner",Btn).CornerRadius = UDim.new(0,6)

Btn.MouseButton1Click:Connect(function()
    Btn.Text = "Escaneando..."
    Btn.BackgroundColor3 = Color3.fromRGB(80,80,80)
    Status.Text = "Escribiendo: " .. FILE

    -- Reset archivo
    pcall(function()
        if writefile then writefile(FILE, "=== EVOMON SCAN " .. os.date("%H:%M:%S") .. " ===\n") end
    end)

    task.spawn(function()
        local ok, err = pcall(function()

        -- =====================================================
        -- 1. JUGADORES (para filtrar)
        -- =====================================================
        wLine("")
        wLine("[1] JUGADORES ACTIVOS (filtrar de NPCs)")
        local playerNames = {}
        pcall(function()
            for _,p in ipairs(Players:GetPlayers()) do
                playerNames[p.Name] = true
                wLine("PLAYER|" .. p.Name)
            end
        end)

        -- =====================================================
        -- 2. NPCs EN WORKSPACE
        -- =====================================================
        wLine("")
        wLine("[2] NPCs EN WORKSPACE (Model+Humanoid+HRP, no-jugadores)")
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
                        wLine("NPC|" .. obj.Name .. "|dist=" .. dist .. "|" .. obj:GetFullName())
                        -- ProximityPrompts dentro
                        pcall(function()
                            for _,pp in ipairs(obj:GetDescendants()) do
                                if pp:IsA("ProximityPrompt") then
                                    wLine("  PP|"..pp.ActionText.."|"..pp:GetFullName())
                                end
                            end
                        end)
                        npcCount += 1
                    end
                end
            end
        end)
        wLine("TOTAL_NPCS=" .. npcCount)
        task.wait(0.05)

        -- =====================================================
        -- 3. BOTONES EN PLAYERGUI
        -- =====================================================
        wLine("")
        wLine("[3] BOTONES EN PLAYERGUI")
        pcall(function()
            local pg = LP:FindFirstChildOfClass("PlayerGui")
            if pg then
                for _,obj in ipairs(pg:GetDescendants()) do
                    if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                        local vis = obj.Visible and "VIS" or "HID"
                        local txt = ""
                        pcall(function() if obj:IsA("TextButton") then txt = obj.Text end end)
                        wLine("BTN|"..vis.."|"..obj.Name.."|"..txt.."|"..obj:GetFullName())
                    end
                end
            else
                wLine("ERROR: PlayerGui no encontrado")
            end
        end)
        task.wait(0.05)

        -- =====================================================
        -- 4. REMOTEEVENTS EN RS
        -- =====================================================
        wLine("")
        wLine("[4] REMOTEEVENTS EN REPLICATEDSTORAGE")
        pcall(function()
            local kw = {"battle","catch","escape","flee","pity","summon","monster",
                        "capture","operate","enter","settle","result","wild","npc"}
            for _,obj in ipairs(RS:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local low = string.lower(obj.Name)
                    for _,k in ipairs(kw) do
                        if string.find(low,k) then
                            wLine("REMOTE|"..obj.ClassName.."|"..obj.Name.."|"..obj:GetFullName())
                            break
                        end
                    end
                end
            end
        end)
        task.wait(0.05)

        -- =====================================================
        -- 5. PROXIMITYPROMPTS GLOBALES
        -- =====================================================
        wLine("")
        wLine("[5] PROXIMITYPROMPTS GLOBALES")
        pcall(function()
            for _,obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    wLine("PP|"..obj.ActionText.."|en="..tostring(obj.Enabled).."|"..obj:GetFullName())
                end
            end
        end)
        task.wait(0.05)

        -- =====================================================
        -- 6. VALORES DEL JUGADOR
        -- =====================================================
        wLine("")
        wLine("[6] VALORES DEL JUGADOR (leaderstats, etc)")
        pcall(function()
            local function scanF(folder, prefix)
                for _,v in ipairs(folder:GetChildren()) do
                    if v:IsA("ValueBase") then
                        wLine("VAL|"..prefix..v.Name.."="..tostring(v.Value))
                    elseif v:IsA("Folder") or v:IsA("Configuration") then
                        scanF(v, prefix..v.Name.."/")
                    end
                end
            end
            scanF(LP,"LP/")
        end)
        task.wait(0.05)

        -- =====================================================
        -- 7. TEXTLABELS CON PITY/SHINY/ESCAPE
        -- =====================================================
        wLine("")
        wLine("[7] TEXTLABELS CON PITY/SHINY/CATCH/ESCAPE")
        pcall(function()
            local pg = LP:FindFirstChildOfClass("PlayerGui")
            if pg then
                for _,obj in ipairs(pg:GetDescendants()) do
                    if (obj:IsA("TextLabel") or obj:IsA("TextBox")) and obj.Text~="" then
                        local t = string.lower(obj.Text)
                        if string.find(t,"pity") or string.find(t,"shiny")
                        or string.find(t,"prismatic") or string.find(t,"catch")
                        or string.find(t,"escape") or string.find(t,"ball")
                        or string.find(t,"flee") or string.find(t,"rate") then
                            wLine("LBL|"..obj.Name.."|"..obj.Text.."|"..obj:GetFullName())
                        end
                    end
                end
            end
        end)
        task.wait(0.05)

        -- =====================================================
        -- 8. RS ESTRUCTURA COMPLETA
        -- =====================================================
        wLine("")
        wLine("[8] REPLICATEDSTORAGE ESTRUCTURA")
        pcall(function()
            for _,c in ipairs(RS:GetChildren()) do
                wLine("RS|"..c.Name.."|"..c.ClassName)
                for _,s in ipairs(c:GetChildren()) do
                    wLine("  RS|"..c.Name.."|"..s.Name.."|"..s.ClassName)
                end
            end
        end)
        task.wait(0.05)

        -- =====================================================
        -- 9. RUNTIMECACHE MODELOS
        -- =====================================================
        wLine("")
        wLine("[9] RUNTIMECACHE MODELOS")
        pcall(function()
            local rc = workspace:FindFirstChild("RuntimeCache")
            if rc then
                local srv = rc:FindFirstChild("RuntimeCacheServer")
                if srv then
                    local cc = srv:FindFirstChild("CreatureModelCache")
                    if cc then
                        local seen = {}
                        for _,folder in ipairs(cc:GetChildren()) do
                            for _,mdl in ipairs(folder:GetChildren()) do
                                if mdl:IsA("Model") and not seen[mdl.Name] then
                                    seen[mdl.Name] = true
                                    local h1 = mdl:FindFirstChild("HumanoidRootPart")~=nil
                                    local h2 = mdl:FindFirstChildOfClass("Humanoid")~=nil
                                    wLine("CACHE|"..mdl.Name.."|HRP="..tostring(h1).."|Hum="..tostring(h2))
                                end
                            end
                        end
                    else
                        wLine("CreatureModelCache NO encontrado")
                    end
                end
            else
                wLine("RuntimeCache NO encontrado en workspace")
            end
        end)

        wLine("")
        wLine("=== FIN DEL SCAN ===")

        end) -- fin pcall

        if ok then
            Btn.Text = "LISTO - archivo: " .. FILE
            Btn.BackgroundColor3 = Color3.fromRGB(39,174,96)
            Status.Text = "Guardado en " .. FILE
        else
            Btn.Text = "ERROR: " .. tostring(err)
            Btn.BackgroundColor3 = Color3.fromRGB(192,57,43)
            Status.Text = "Revisa consola del executor"
            print("[SCAN ERROR] " .. tostring(err))
        end
    end)
end)
