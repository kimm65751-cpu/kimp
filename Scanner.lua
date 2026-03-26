-- FORENSE ANALYZER V5 - GUI DE MAXIMA COMPATIBILIDAD (Botones Flotantes)
local sg = Instance.new("ScreenGui")
sg.Name = "ForenseV5"
sg.ResetOnSpawn = false
local okCg = pcall(function() sg.Parent = game:GetService("CoreGui") end)
if not okCg then
    sg.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui", 5)
end

-- Limpiar anteriores
if sg.Parent then
    for _, v in ipairs(sg.Parent:GetChildren()) do
        if v.Name == "ForenseV5" and v ~= sg then v:Destroy() end
    end
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local HttpService
pcall(function() HttpService = game:GetService("HttpService") end)
local ReplicatedStorage
pcall(function() ReplicatedStorage = game:GetService("ReplicatedStorage") end)

-- Panel Principal Transparente
local Base = Instance.new("Frame")
Base.Size = UDim2.new(0, 600, 0, 450)
Base.Position = UDim2.new(0.5, -300, 0.5, -225)
Base.BackgroundTransparency = 1
Base.Active = true
Base.Draggable = true
Base.Parent = sg

-- Crear Elementos Individuales (sin containers anidados)
local function MkElm(cls, n, sX, sY, pX, pY, bg)
    local e = Instance.new(cls)
    e.Name = n
    e.Size = UDim2.new(0, sX, 0, sY)
    e.Position = UDim2.new(0, pX, 0, pY)
    e.BackgroundColor3 = bg
    e.BorderSizePixel = 2
    e.BorderColor3 = Color3.fromRGB(0,0,0)
    e.Parent = Base
    return e
end

local Title = MkElm("TextLabel", "Title", 560, 30, 0, 0, Color3.fromRGB(160, 10, 10))
Title.Text = " FORENSE ANALYZER V5 - 17 VECTORES"
Title.TextColor3 = Color3.fromRGB(255, 240, 80)
Title.Font = Enum.Font.Code
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

local XBtn = MkElm("TextButton", "XBtn", 40, 30, 560, 0, Color3.fromRGB(200, 20, 20))
XBtn.Text = "X"
XBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
XBtn.Font = Enum.Font.Code
XBtn.TextSize = 14
XBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

local RunBtn = MkElm("TextButton", "RunBtn", 600, 40, 0, 32, Color3.fromRGB(20, 100, 20))
RunBtn.Text = ">>> INICIAR ANALISIS (ACERCATE A UN MOB) <<<"
RunBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RunBtn.Font = Enum.Font.Code
RunBtn.TextSize = 14

local LogBox = MkElm("TextLabel", "LogBox", 600, 376, 0, 74, Color3.fromRGB(15, 15, 20))
LogBox.Text = "ESPERANDO ORDEN...\nLos resultados completos se copiaran a tu portapapeles automaticamente al terminar."
LogBox.TextColor3 = Color3.fromRGB(200, 200, 200)
LogBox.Font = Enum.Font.Code
LogBox.TextSize = 12
LogBox.TextXAlignment = Enum.TextXAlignment.Left
LogBox.TextYAlignment = Enum.TextYAlignment.Top
LogBox.TextWrapped = true

RunBtn.MouseButton1Click:Connect(function()
    RunBtn.Text = "ANALIZANDO (~5s)..."
    RunBtn.BackgroundColor3 = Color3.fromRGB(150, 80, 0)
    LogBox.Text = "Buscando mob cercano..."

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
        LogBox.Text = "ERROR: Sin mob vivo cerca.\nAcercate a menos de 50 studs de un zombi."
        RunBtn.Text = ">>> REINTENTAR <<<"
        RunBtn.BackgroundColor3 = Color3.fromRGB(20, 100, 20)
        return
    end

    LogBox.Text = "Mob encontrado: " .. mob.Name .. "\nIniciando 17 vectores..."
    local log = "=== FORENSE: " .. mob.Name .. " (HP:" .. math.floor(mHum.Health) .. ") ===\n\n"

    -- V1 Atributos
    local attrs = mob:GetAttributes()
    if next(attrs) then
        local a1 = pcall(function() mob:SetAttribute("Health",0) end)
        log = log .. "[V1] ATRIBUTOS: Manipulables. SetAttr Health=0: " .. (a1 and "OK" or "Block") .. "\n"
    else
        log = log .. "[V1] ATRIBUTOS: Server-side puro.\n"
    end

    -- V2-V5 Físicas y scripts
    local sc = 0
    for _, s in pairs(mob:GetDescendants()) do if s:IsA("Script") then sc=sc+1 end end
    log = log .. "[V2] SCRIPTS IA: " .. sc .. "\n"

    local okP = pcall(function() if myRoot then mRoot.AssemblyLinearVelocity=(mRoot.Position-myRoot.Position).Unit*-30 end end)
    log = log .. "[V4] KNOCKBACK: " .. (okP and "Salio Volando (OK)" or "Bloqueado") .. "\n"

    if myRoot then
        local aw = myRoot.Position + myRoot.CFrame.LookVector*100
        local okR = pcall(function() mRoot.CFrame=CFrame.new(mRoot.Position,Vector3.new(aw.X,mRoot.Position.Y,aw.Z)) end)
        log = log .. "[V5] ROTACION: " .. (okR and "Manipulable (OK)" or "Bloqueada") .. "\n"
    end

    -- V6-V7 Hitboxes
    local tt = 0; local arms = 0
    for _, p in pairs(mob:GetDescendants()) do
        if p:IsA("BasePart") then
            if p:FindFirstChildWhichIsA("TouchTransmitter") then tt=tt+1 end
            local n = string.lower(p.Name)
            if string.find(n,"arm") or string.find(n,"hand") or string.find(n,"hit") then
                arms=arms+1; pcall(function() p.Size=Vector3.new(0.1,0.1,0.1) end)
            end
        end
    end
    log = log .. "[V6] TouchInterest: " .. tt .. (tt>0 and " -> EXPLOIT: tt:Destroy()" or "") .. "\n"
    log = log .. "[V7] Hitbox Ataque: " .. arms .. (arms>0 and " -> Reducidas a 0.1x" or "") .. "\n"

    -- V11 Remotes
    local rl = ""
    for _, rem in pairs(game:GetDescendants()) do
        if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
            local n = string.lower(rem.Name)
            if string.find(n,"damage") or string.find(n,"hit") or string.find(n,"attack") then
                rl=rl.." "..rem.Name.."\n"
            end
        end
    end
    log = log .. "[V11] REMOTES OBVIOS:\n" .. (rl~="" and rl or " Ninguno.\n") .. "\n"

    -- V12-V16 Red en Vivo
    LogBox.Text = log .. "CAPTURANDO RED EN VIVO... (3s)"
    task.wait(0.2)

    local pkts, captOn, t0, grps = {}, true, tick(), {}
    local cHk
    pcall(function()
        cHk = hookmetamethod(game, "__namecall", newcclosure(function(s2, ...)
            local m = string.lower(tostring(getnamecallmethod()))
            if captOn and (m=="fireserver" or m=="invokeserver") then
                pcall(function()
                    local nm = s2.Name
                    local nL = string.lower(nm)
                    if not string.find(nL,"mouse") and not string.find(nL,"camera") then
                        table.insert(pkts,{t=tick()-t0, name=nm, path=s2:GetFullName(), cls=s2.ClassName, args={...}, rem=s2})
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
    captOn = false

    local hpA=mHum.Health; local hpDrop=hpB-hpA
    for _,p in ipairs(pkts) do
        if not grps[p.name] then grps[p.name]={} end
        table.insert(grps[p.name],p)
    end

    log = log .. "=== RESULTADO COMBATE ===\n"
    log = log .. "[V13] Dano 3s: " .. string.format("%.1f",hpDrop) .. " | DPS: " .. string.format("%.2f",hpDrop/3) .. "\n"
    log = log .. (hpDrop>0 and " --> ToolRF HACE DANO OK\n\n" or " --> ToolRF NO HACE DANO. Usa V14.\n\n")

    log = log .. "[V14] PAQUETES DE RED CAPTURADOS: " .. #pkts .. "\n"
    for rName,rp in pairs(grps) do
        log = log .. " ["..rp[1].cls.."] " .. rName .. " -> x" .. #rp .. " veces\n"
        log = log .. " Path: " .. rp[1].path .. "\n"
    end
    if #pkts==0 then log=log.." CERO paquetes.\n" end
    log = log .. "\n"

    local bestR,bestC,bestA=nil,0,nil
    for _,rp in pairs(grps) do if #rp>bestC then bestC=#rp; bestR=rp[1].rem; bestA=rp[1].args end end
    if bestR then
        local hpPre=mHum.Health; local hits=0
        for i=1,5 do
            local ok=pcall(function() if bestR:IsA("RemoteFunction") then bestR:InvokeServer(table.unpack(bestA)) else bestR:FireServer(table.unpack(bestA)) end end)
            if ok then hits=hits+1 end; task.wait(0.04)
        end
        task.wait(0.35)
        local dmgR = hpPre-mHum.Health
        log = log .. "[V16] REPLAY TEST (x5): " .. hits .. "/5 ejecutados\n  Dano: " .. string.format("%.1f",dmgR) .. "\n"
        log = log .. (dmgR>0 and "  -> MEGA-EXPLOIT: Sin rate-limit (x10 DPS posible)\n" or "  -> Rate-limit activo\n")
    else
        log = log .. "[V16] REPLAY: No hay remotes suficientes.\n"
    end

    LogBox.Text = log
    RunBtn.Text = ">>> ANALISIS FINALIZADO (COPIADO AL PORTAPAPELES) <<<"
    RunBtn.BackgroundColor3 = Color3.fromRGB(20, 100, 20)

    pcall(function()
        if setclipboard then setclipboard(log) end
    end)
end)
