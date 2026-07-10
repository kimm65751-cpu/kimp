local Players = game:GetService("Players")
local CoreGui  = game:GetService("CoreGui")
local LP = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ScanV5"
gui.ResetOnSpawn = false
local ok = pcall(function() gui.Parent = CoreGui end)
if not ok then gui.Parent = LP:WaitForChild("PlayerGui") end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,300,0,110)
frame.Position = UDim2.new(0.5,-150,0,5)
frame.BackgroundColor3 = Color3.fromRGB(10,10,15)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner",frame).CornerRadius = UDim.new(0,8)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,0,0,28)
status.BackgroundTransparency = 1
status.Text = "SCAN V5 - presiona el boton"
status.TextColor3 = Color3.fromRGB(180,220,255)
status.Font = Enum.Font.GothamBold
status.TextSize = 11
status.Parent = frame

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1,-10,0,34)
btn.Position = UDim2.new(0,5,0,30)
btn.BackgroundColor3 = Color3.fromRGB(41,128,185)
btn.Text = "ESCANEAR TODO Y GUARDAR .TXT"
btn.TextColor3 = Color3.fromRGB(255,255,255)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 12
btn.BorderSizePixel = 0
btn.Parent = frame
Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)

local res = Instance.new("TextLabel")
res.Size = UDim2.new(1,-10,0,36)
res.Position = UDim2.new(0,5,0,68)
res.BackgroundTransparency = 1
res.Text = "Esperando..."
res.TextColor3 = Color3.fromRGB(200,200,200)
res.Font = Enum.Font.Code
res.TextSize = 9
res.TextWrapped = true
res.TextXAlignment = Enum.TextXAlignment.Left
res.Parent = frame

btn.MouseButton1Click:Connect(function()
    btn.Text = "Escaneando..."
    btn.BackgroundColor3 = Color3.fromRGB(100,100,100)

    task.spawn(function()
        local lines = {}
        local function add(s) table.insert(lines, tostring(s)) print(tostring(s)) end

        add("=== SCAN " .. os.date("%H:%M:%S") .. " ===")

        local pnames = {}
        add("[JUGADORES]")
        for _, p in ipairs(Players:GetPlayers()) do
            pnames[p.Name] = true
            add("P|" .. p.Name)
        end

        add("[NPCS]")
        local nc = 0
        for _, o in ipairs(workspace:GetDescendants()) do
            if o:IsA("Model") and not pnames[o.Name] then
                local hrp = o:FindFirstChild("HumanoidRootPart")
                local hum = o:FindFirstChildOfClass("Humanoid")
                if hrp and hum then
                    local d = -1
                    local c = LP.Character
                    if c and c:FindFirstChild("HumanoidRootPart") then
                        d = math.floor((hrp.Position - c.HumanoidRootPart.Position).Magnitude)
                    end
                    add("NPC|" .. o.Name .. "|" .. d .. "st|" .. o:GetFullName())
                    nc = nc + 1
                end
            end
        end
        add("NPC_TOTAL=" .. nc)

        add("[BOTONES]")
        local pg = LP:FindFirstChildOfClass("PlayerGui")
        if pg then
            for _, o in ipairs(pg:GetDescendants()) do
                if o:IsA("TextButton") or o:IsA("ImageButton") then
                    local t = o:IsA("TextButton") and o.Text or ""
                    add("BTN|" .. (o.Visible and"V"or"H") .. "|" .. o.Name .. "|" .. t)
                end
            end
        end

        add("[REMOTES]")
        local kw = {"battle","catch","escape","flee","pity","summon","monster","capture","operate","enter","settle","wild"}
        for _, o in ipairs(game:GetDescendants()) do
            if o:IsA("RemoteEvent") or o:IsA("RemoteFunction") then
                local n = string.lower(o.Name)
                for _, k in ipairs(kw) do
                    if string.find(n,k) then
                        add("REM|" .. o.Name .. "|" .. o:GetFullName())
                        break
                    end
                end
            end
        end

        add("[PROXIMITYPROMPTS]")
        for _, o in ipairs(workspace:GetDescendants()) do
            if o:IsA("ProximityPrompt") then
                add("PP|" .. o.ActionText .. "|" .. o:GetFullName())
            end
        end

        add("[PLAYERVALS]")
        local function sv(f, pre)
            for _, v in ipairs(f:GetChildren()) do
                if v:IsA("ValueBase") then add("VAL|"..pre..v.Name.."="..tostring(v.Value))
                elseif v:IsA("Folder") then sv(v, pre..v.Name.."/") end
            end
        end
        sv(LP, "")

        add("=== FIN ===")

        local content = table.concat(lines, "\n")
        local saved = false

        if writefile then
            local s = pcall(writefile, "EvomonQA_ScanData.txt", content)
            if s then saved = true res.Text = "OK: EvomonQA_ScanData.txt" end
        end
        if not saved and appendfile then
            local s = pcall(appendfile, "EvomonQA_LiveReport.txt", "\n\n"..content)
            if s then saved = true res.Text = "OK: appendado en LiveReport.txt" end
        end
        if not saved then
            res.Text = "No se pudo guardar.\n" .. nc .. " NPCs en consola (print)"
            res.TextColor3 = Color3.fromRGB(255,100,100)
        end

        btn.Text = saved and "LISTO" or "SIN ACCESO A ARCHIVOS"
        btn.BackgroundColor3 = saved and Color3.fromRGB(39,174,96) or Color3.fromRGB(192,57,43)
        status.Text = nc .. " NPCs | " .. #lines .. " lineas"
    end)
end)
