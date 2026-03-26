-- FORENSE ANALYZER V4 - Sin ScrollingFrame (compatibilidad maxima)
local sg = Instance.new("ScreenGui")
sg.Name = "ForenseV4"
sg.ResetOnSpawn = false
local okCg = pcall(function() sg.Parent = game:GetService("CoreGui") end)
if not okCg then
    sg.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui", 5)
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local HttpService
pcall(function() HttpService = game:GetService("HttpService") end)
local ReplicatedStorage
pcall(function() ReplicatedStorage = game:GetService("ReplicatedStorage") end)

local W, H = 700, 540
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, W, 0, H)
Main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(200, 30, 30)
Main.Active = true
Main.Draggable = true
Main.ZIndex = 5
Main.Parent = sg

local function MkLbl(txt, x, y, w, h, fc, bg)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0, w, 0, h)
    l.Position = UDim2.new(0, x, 0, y)
    l.BackgroundColor3 = bg or Color3.fromRGB(0,0,0)
    l.BackgroundTransparency = bg and 0 or 1
    l.Text = txt
    l.TextColor3 = fc or Color3.fromRGB(255,255,255)
    l.Font = Enum.Font.Code
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextWrapped = true
    l.ZIndex = 6
    l.Parent = Main
    return l
end

local function MkBtn(txt, x, y, w, h, bc, fc)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, w, 0, h)
    b.Position = UDim2.new(0, x, 0, y)
    b.BackgroundColor3 = bc
    b.Text = txt
    b.TextColor3 = fc or Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.Code
    b.TextSize = 11
    b.TextWrapped = true
    b.ZIndex = 6
    b.Parent = Main
    return b
end

MkLbl("  FORENSE ANALYZER V4 - 17 VECTORES", 0, 0, W-32, 30, Color3.fromRGB(255,240,80), Color3.fromRGB(160,10,10))

local XBtn = MkBtn("X", W-32, 0, 32, 30, Color3.fromRGB(200,20,20))
XBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

local RunBtn = MkBtn("[ANALIZAR] Parate cerca de un mob y presiona aqui", 4, 34, W-8, 36, Color3.fromRGB(140,5,5), Color3.fromRGB(255,240,80))
local ClrBtn = MkBtn("[LIMPIAR]", 4, 74, 120, 26, Color3.fromRGB(40,40,40))
local StatusLbl = MkLbl("Listo.", 130, 74, W-134, 26, Color3.fromRGB(80,220,80))

local LogLbl = Instance.new("TextLabel")
LogLbl.Size = UDim2.new(0, W-8, 0, H-105)
LogLbl.Position = UDim2.new(0, 4, 0, 104)
LogLbl.BackgroundColor3 = Color3.fromRGB(14,14,20)
LogLbl.BackgroundTransparency = 0
LogLbl.Text = "Log vacio. Presiona ANALIZAR cerca de un zombi."
LogLbl.TextColor3 = Color3.fromRGB(185,185,185)
LogLbl.Font = Enum.Font.Code
LogLbl.TextSize = 11
LogLbl.TextXAlignment = Enum.TextXAlignment.Left
LogLbl.TextYAlignment = Enum.TextYAlignment.Top
LogLbl.TextWrapped = true
LogLbl.ZIndex = 6
LogLbl.Parent = Main

ClrBtn.MouseButton1Click:Connect(function()
    LogLbl.Text = "Log limpiado."
    StatusLbl.Text = "Listo."
end)

RunBtn.MouseButton1Click:Connect(function()
    RunBtn.Text = "[...] Buscando mob y analizando..."
    StatusLbl.Text = "Buscando mob..."

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local mob, mRoot, mHum, mDist = nil, nil, nil, math.huge

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= myChar and not Players:GetPlayerFromCharacter(obj) then
            local h = obj:FindFirstChildWhichIsA("Humanoid")
            local r = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
            if h and h.Health > 0 and r then
                local d = myRoot and (myRoot.Position - r.Position).Magnitude or 9999
                if d < mDist then mDist=d; mob=obj; mRoot=r; mHum=h end
            end
        end
    end

    if not mob then
        StatusLbl.Text = "Sin mob vivo cerca."
        LogLbl.Text = "No se encontro mob.\nAcercate a un zombi vivo y vuelve a presionar."
        RunBtn.Text = "[ANALIZAR] Parate cerca de un mob y presiona aqui"
        return
    end

    StatusLbl.Text = mob.Name .. " HP:" .. math.floor(mHum.Health) .. " Dist:" .. math.floor(mDist) .. "m"
    local log = "=== MOB: " .. mob.Name .. " HP:" .. math.floor(mHum.Health) .. "/" .. math.floor(mHum.MaxHealth) .. " Dist:" .. math.floor(mDist) .. "m ===\n\n"

    -- V1 Atributos
    local attrs = mob:GetAttributes()
    if next(attrs) then
        log = log .. "V1 ATRIBUTOS:\n"
        for k, v in pairs(attrs) do log = log .. "  " .. k .. "=" .. tostring(v) .. "\n" end
        local a1 = pcall(function() mob:SetAttribute("Health",0) end)
        log = log .. "SetAttr Health=0: " .. (a1 and "EXITOSO (posible 1-shot!)" or "Bloqueado") .. "\n\n"
    else
        log = log .. "V1: Sin atributos locales. Dano server-side.\n\n"
    end

    -- V2 Scripts
    local sc = 0
    for _, s in pairs(mob:GetDescendants()) do
        if s:IsA("Script") or s:IsA("LocalScript") then sc=sc+1 end
    end
    log = log .. "V2 SCRIPTS en mob: " .. sc .. (sc>0 and " → POTENCIAL: s.Disabled=true" or " → Server-side") .. "\n\n"

    -- V3 Direccion
    if myRoot then
        local ok3, dot = pcall(function() return (mRoot.Position-myRoot.Position).Unit:Dot(myRoot.CFrame.LookVector) end)
        if ok3 then log = log .. "V3 DIRECCION Dot:" .. string.format("%.2f",dot) .. " | " .. (dot>0.5 and "MIRANDOLO" or dot<-0.5 and "DE ESPALDAS" or "LATERAL") .. "\n\n" end
    end

    -- V4 Knockback
    local okP = pcall(function() if myRoot then mRoot.AssemblyLinearVelocity=(mRoot.Position-myRoot.Position).Unit*-30 end end)
    log = log .. "V4 KNOCKBACK: " .. (okP and "EXITOSO (salio volando)" or "Bloqueado") .. "\n\n"

    -- V5 Rotacion
    if myRoot then
        local away = myRoot.Position + myRoot.CFrame.LookVector*100
        local okR = pcall(function() mRoot.CFrame=CFrame.new(mRoot.Position,Vector3.new(away.X,mRoot.Position.Y,away.Z)) end)
        log = log .. "V5 ROTACION CFrame: " .. (okR and "EXITOSO → integra en Farm: lookAt" or "Bloqueado") .. "\n\n"
    end

    -- V6 TouchInterest
    local tt = 0
    for _, p in pairs(mob:GetDescendants()) do
        if p:IsA("BasePart") and p:FindFirstChildWhichIsA("TouchTransmitter") then tt=tt+1 end
    end
    log = log .. "V6 TOUCHINTEREST: " .. tt .. " partes" .. (tt>0 and " → EXPLOIT: tt:Destroy() en loop" or " → Raycast server-side") .. "\n\n"

    -- V7 Brazos
    local arms = 0
    for _, p in pairs(mob:GetDescendants()) do
        if p:IsA("BasePart") then
            local n = string.lower(p.Name)
            if string.find(n,"arm") or string.find(n,"hand") or string.find(n,"hit") then
                arms=arms+1
                pcall(function() p.Size=Vector3.new(0.1,0.1,0.1) end)
            end
        end
    end
    log = log .. "V7 BRAZOS/HITBOX: " .. arms .. " partes encontradas\n\n"

    -- V8 Congelar
    local okW = pcall(function() mHum.WalkSpeed=0; mHum.JumpPower=0 end)
    log = log .. "V8 CONGELAR IA: " .. (okW and "EXITOSO" or "Bloqueado") .. "\n\n"

    -- V9 Flags
    local fc = 0
    for _, c in pairs(mob:GetDescendants()) do
        if c:IsA("BoolValue") or c:IsA("NumberValue") or c:IsA("IntValue") then
            fc=fc+1
        end
    end
    log = log .. "V9 FLAGS: " .. fc .. " Values locales en el mob\n\n"

    -- V11 Remotes
    local rcnt = 0
    local rl = ""
    for _, rem in pairs(game:GetDescendants()) do
        if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
            local n = string.lower(rem.Name)
            if string.find(n,"damage") or string.find(n,"hit") or string.find(n,"attack") or string.find(n,"tool") or string.find(n,"weapon") then
                rcnt=rcnt+1; rl=rl.."  ["..rem.ClassName.."] "..rem:GetFullName().."\n"
            end
        end
    end
    log = log .. "V11 REMOTES COMBATE: " .. rcnt .. "\n" .. (rcnt>0 and rl or "  Sin nombres obvios. Usa Interceptor.\n") .. "\n"

    -- V12-V17 Red en vivo
    log = log .. "V12 CAPTURA RED (3s)...\n"
    LogLbl.Text = log
    StatusLbl.Text = "Capturando red 3s..."
    task.wait(0.2)

    local pkts, captOn, t0, grps = {}, true, tick(), {}
    local cHk
    pcall(function()
        cHk = hookmetamethod(game, "__namecall", newcclosure(function(s2, ...)
            local m = string.lower(tostring(getnamecallmethod()))
            if captOn and (m=="fireserver" or m=="invokeserver") then
                pcall(function()
                    local nm,fp="?","?"
                    pcall(function() nm=s2.Name; fp=s2:GetFullName() end)
                    local nL=string.lower(nm)
                    if not string.find(nL,"mouse") and not string.find(nL,"camera") and not string.find(nL,"input") then
                        table.insert(pkts,{t=tick()-t0,name=nm,path=fp,cls=s2.ClassName,args={...},rem=s2})
                    end
                end)
            end
            return cHk(s2,...)
        end))
    end)

    local ToolRF = nil
    pcall(function() ToolRF = ReplicatedStorage.Shared.Packages.Knit.Services.ToolService.RF.ToolActivated end)

    local hpB = mHum.Health
    task.spawn(function()
        local endT = tick()+3
        while tick()<endT and captOn do
            pcall(function()
                if myRoot and mRoot then myRoot.CFrame=CFrame.lookAt(myRoot.Position,Vector3.new(mRoot.Position.X,myRoot.Position.Y,mRoot.Position.Z)) end
                if ToolRF then ToolRF:InvokeServer("Weapon") end
            end)
            task.wait(0.15)
        end
    end)
    task.wait(3.2)
    captOn=false

    local hpA=mHum.Health; local hpDrop=hpB-hpA
    for _,p in ipairs(pkts) do
        if not grps[p.name] then grps[p.name]={} end
        table.insert(grps[p.name],p)
    end
    local gc=0; for _ in pairs(grps) do gc=gc+1 end

    log = log .. "V13 HP: "..string.format("%.1f",hpB).." → "..string.format("%.1f",hpA).." | Dano:"..string.format("%.1f",hpDrop).." DPS:"..string.format("%.2f",hpDrop/3).."\n"
    log = log .. (hpDrop>0 and "  ToolRF CONFIRMADO\n\n" or "  ToolRF no valido → busca remote en V14\n\n")
    log = log .. "V14 PAQUETES C->S: " .. #pkts .. " | Remotes unicos: " .. gc .. "\n"
    for rName,rp in pairs(grps) do
        log = log .. "  ["..rp[1].cls.."] "..rName.." x"..#rp.." | Path: "..rp[1].path.."\n"
        if #rp>=2 then
            log = log .. "  Rate: "..string.format("%.1f",1/((rp[#rp].t-rp[1].t)/math.max(1,#rp-1))).." /s\n"
        end
    end
    if #pkts==0 then log=log.."  CERO paquetes. Usa Interceptor+manual.\n" end
    log = log .. "\n"

    local bestR,bestC,bestA=nil,0,nil
    for _,rp in pairs(grps) do if #rp>bestC then bestC=#rp; bestR=rp[1].rem; bestA=rp[1].args end end
    if bestR then
        log = log .. "V16 REPLAY x5...\n"
        local hpPre=mHum.Health; local hits=0
        for i=1,5 do
            local ok=pcall(function() if bestR:IsA("RemoteFunction") then bestR:InvokeServer(table.unpack(bestA)) else bestR:FireServer(table.unpack(bestA)) end end)
            if ok then hits=hits+1 end; task.wait(0.04)
        end
        task.wait(0.35)
        local dmgR=hpPre-mHum.Health
        log = log .. "  Replays:"..hits.."/5 Dano:"..string.format("%.1f",dmgR).."\n"
        log = log .. (dmgR>0 and "  MEGA-EXPLOIT: sin rate-limit!\n  Path: "..bestR:GetFullName().."\n" or "  Rate-limit activo.\n")
    else
        log = log .. "V16: Sin remote capturado.\n"
    end

    log = log .. "\n=== FIN ANALISIS ===\n"
    log = log .. "DPS: "..string.format("%.2f",hpDrop/3).." | Touch:"..tt.." | Arms:"..arms.." | Pkts:"..#pkts

    LogLbl.Text = log
    StatusLbl.Text = "LISTO. DPS:" .. string.format("%.2f",hpDrop/3) .. " Pkts:" .. #pkts
    RunBtn.Text = "[ANALIZAR] Parate cerca de un mob y presiona aqui"
    RunBtn.BackgroundColor3 = Color3.fromRGB(140,5,5)
end)
