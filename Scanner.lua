local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- GUI - EXACTA COPIA DEL V2 QUE FUNCIONA
local SG = Instance.new("ScreenGui")
SG.Name = "EvoScanV5"
SG.ResetOnSpawn = false
if pcall(function() SG.Parent = CoreGui end) then else SG.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local F = Instance.new("Frame")
F.Size = UDim2.new(0, 300, 0, 100)
F.Position = UDim2.new(0.5, -150, 0, 5)
F.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
F.BorderSizePixel = 0
F.Parent = SG
Instance.new("UICorner", F).CornerRadius = UDim.new(0, 8)

local T = Instance.new("TextLabel")
T.Size = UDim2.new(1, 0, 0, 25)
T.BackgroundTransparency = 1
T.Text = "EVOMON SCANNER V5"
T.TextColor3 = Color3.fromRGB(100, 200, 255)
T.Font = Enum.Font.GothamBold
T.TextSize = 12
T.Parent = F

local B = Instance.new("TextButton")
B.Size = UDim2.new(1, -10, 0, 34)
B.Position = UDim2.new(0, 5, 0, 27)
B.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
B.Text = "ESCANEAR TODO"
B.TextColor3 = Color3.fromRGB(255, 255, 255)
B.Font = Enum.Font.GothamBold
B.TextSize = 12
B.BorderSizePixel = 0
B.Parent = F
Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)

local R = Instance.new("TextLabel")
R.Size = UDim2.new(1, -8, 0, 28)
R.Position = UDim2.new(0, 4, 0, 65)
R.BackgroundTransparency = 1
R.Text = "Presiona el boton..."
R.TextColor3 = Color3.fromRGB(200, 200, 200)
R.Font = Enum.Font.Code
R.TextSize = 9
R.TextWrapped = true
R.TextXAlignment = Enum.TextXAlignment.Left
R.Parent = F

-- FILE WRITE - igual al v2
local FILE = "EvomonQA_LiveReport.txt"
local function wLog(msg)
    local line = "[SCAN][" .. os.date("%H:%M:%S") .. "] " .. msg
    print(line)
    if appendfile then
        pcall(function() appendfile(FILE, line .. "\n") end)
    elseif writefile and isfile then
        pcall(function()
            local cur = isfile(FILE) and readfile(FILE) or ""
            writefile(FILE, cur .. line .. "\n")
        end)
    end
end

B.MouseButton1Click:Connect(function()
    B.Text = "Escaneando..."
    B.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    task.spawn(function()
        wLog("=== INICIO SCAN ===")

        local pn = {}
        for _, p in ipairs(Players:GetPlayers()) do
            pn[p.Name] = true
            wLog("PLAYER|" .. p.Name)
        end

        local nc = 0
        for _, o in ipairs(workspace:GetDescendants()) do
            if o:IsA("Model") and not pn[o.Name] then
                local h = o:FindFirstChild("HumanoidRootPart")
                local m = o:FindFirstChildOfClass("Humanoid")
                if h and m then
                    local d = -1
                    local c = LocalPlayer.Character
                    if c and c:FindFirstChild("HumanoidRootPart") then
                        d = math.floor((h.Position - c.HumanoidRootPart.Position).Magnitude)
                    end
                    wLog("NPC|" .. o.Name .. "|" .. d .. "st|" .. o:GetFullName())
                    nc = nc + 1
                end
            end
        end
        wLog("NPC_TOTAL=" .. nc)

        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if pg then
            for _, o in ipairs(pg:GetDescendants()) do
                if o:IsA("TextButton") or o:IsA("ImageButton") then
                    local t = o:IsA("TextButton") and o.Text or ""
                    wLog("BTN|" .. (o.Visible and "V" or "H") .. "|" .. o.Name .. "|" .. t .. "|" .. o:GetFullName())
                end
            end
        end

        local kw = {"battle","catch","escape","flee","pity","summon","monster","capture","enter","settle","wild"}
        for _, o in ipairs(game:GetDescendants()) do
            if o:IsA("RemoteEvent") or o:IsA("RemoteFunction") then
                local n = string.lower(o.Name)
                for _, k in ipairs(kw) do
                    if string.find(n, k) then
                        wLog("REM|" .. o.Name .. "|" .. o:GetFullName())
                        break
                    end
                end
            end
        end

        for _, o in ipairs(workspace:GetDescendants()) do
            if o:IsA("ProximityPrompt") then
                wLog("PP|" .. o.ActionText .. "|" .. o:GetFullName())
            end
        end

        wLog("=== FIN SCAN ===")
        B.Text = "LISTO -> " .. FILE
        B.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
        R.Text = "Scan completo: " .. nc .. " NPCs\nBusca en: " .. FILE
        R.TextColor3 = Color3.fromRGB(100, 255, 100)
    end)
end)
