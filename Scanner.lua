local Players=game:GetService("Players")
local CoreGui=game:GetService("CoreGui")
local LP=Players.LocalPlayer or Players.PlayerAdded:Wait()
local FILE="EvomonQA_LiveReport.txt"

if writefile then pcall(function()writefile(FILE,"=== SCAN "..os.date("%H:%M:%S").." ===\n")end)end

local function w(m)
    local l="["..os.date("%H:%M:%S").."] "..m
    print(l)
    if appendfile then pcall(function()appendfile(FILE,l.."\n")end)
    elseif writefile and isfile then pcall(function()
        writefile(FILE,(isfile(FILE)and readfile(FILE)or "")..l.."\n")
    end)end
end

-- GUI
local SG=Instance.new("ScreenGui")SG.Name="EScan"SG.ResetOnSpawn=false
if pcall(function()SG.Parent=CoreGui end)then else SG.Parent=LP:WaitForChild("PlayerGui")end
local F=Instance.new("Frame")F.Size=UDim2.new(0,240,0,50)F.Position=UDim2.new(0,10,0,10)
F.BackgroundColor3=Color3.fromRGB(20,20,28)F.BorderSizePixel=0 F.Parent=SG
Instance.new("UICorner",F).CornerRadius=UDim.new(0,6)
local B=Instance.new("TextButton")B.Size=UDim2.new(1,-10,0,34)B.Position=UDim2.new(0,5,0,8)
B.BackgroundColor3=Color3.fromRGB(41,128,185)B.Text="ESCANEAR TODO -> "..FILE
B.TextColor3=Color3.fromRGB(255,255,255)B.Font=Enum.Font.GothamBold B.TextSize=11
B.BorderSizePixel=0 B.Parent=F Instance.new("UICorner",B).CornerRadius=UDim.new(0,5)

w("Script cargado OK")

B.MouseButton1Click:Connect(function()
    B.Text="Escaneando..."
    B.BackgroundColor3=Color3.fromRGB(80,80,80)

    -- JUGADORES
    local pn={}
    w("==[JUGADORES]==")
    pcall(function()for _,p in ipairs(Players:GetPlayers())do pn[p.Name]=true w("PLAYER|"..p.Name)end end)

    -- NPCs
    w("==[NPCs]==")
    local nc=0
    pcall(function()
        for _,o in ipairs(workspace:GetDescendants())do
            if o:IsA("Model")and not pn[o.Name]then
                local h=o:FindFirstChild("HumanoidRootPart")
                local hu=o:FindFirstChildOfClass("Humanoid")
                if h and hu then
                    local d=-1
                    pcall(function()local c=LP.Character
                        if c and c:FindFirstChild("HumanoidRootPart")then
                            d=math.floor((h.Position-c.HumanoidRootPart.Position).Magnitude)end end)
                    w("NPC|"..o.Name.."|dist="..d.."|"..o:GetFullName())
                    nc+=1
                end
            end
        end
    end)
    w("TOTAL_NPC="..nc)

    -- BOTONES GUI
    w("==[BOTONES GUI]==")
    pcall(function()
        local pg=LP:FindFirstChildOfClass("PlayerGui")
        if pg then local c=0
            for _,o in ipairs(pg:GetDescendants())do
                if o:IsA("TextButton")or o:IsA("ImageButton")then
                    local v=o.Visible and"VIS"or"HID"
                    local t=""pcall(function()if o:IsA("TextButton")then t=o.Text end end)
                    w("BTN|"..v.."|"..o.Name.."|"..t.."|"..o:GetFullName())c+=1
                end
            end
            w("TOTAL_BTN="..c)
        end
    end)

    -- REMOTES
    w("==[REMOTEEVENTS]==")
    pcall(function()
        local kw={"battle","catch","escape","flee","pity","summon","monster","capture","operate","enter","settle","result","wild","npc"}
        local c=0
        for _,o in ipairs(game:GetDescendants())do
            if o:IsA("RemoteEvent")or o:IsA("RemoteFunction")then
                local low=string.lower(o.Name)
                for _,k in ipairs(kw)do
                    if string.find(low,k)then
                        w("REMOTE|"..o.ClassName.."|"..o.Name.."|"..o:GetFullName())c+=1 break
                    end
                end
            end
        end
        w("TOTAL_REMOTE="..c)
    end)

    -- PROXIMITYPROMPTS
    w("==[PROXIMITYPROMPTS]==")
    pcall(function()local c=0
        for _,o in ipairs(workspace:GetDescendants())do
            if o:IsA("ProximityPrompt")then
                w("PP|"..o.ActionText.."|en="..tostring(o.Enabled).."|"..o:GetFullName())c+=1
            end
        end
        w("TOTAL_PP="..c)
    end)

    -- VALORES JUGADOR
    w("==[VALORES JUGADOR]==")
    pcall(function()
        local function sv(f,p)for _,v in ipairs(f:GetChildren())do
            if v:IsA("ValueBase")then w("VAL|"..p..v.Name.."="..tostring(v.Value))
            elseif v:IsA("Folder")then sv(v,p..v.Name.."/")end
        end end
        sv(LP,"")
    end)

    w("==FIN SCAN==")
    B.Text="LISTO -> "..FILE
    B.BackgroundColor3=Color3.fromRGB(39,174,96)
end)
