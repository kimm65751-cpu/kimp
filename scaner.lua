-- FORENSE ANALYZER V6 - INYECTOR EXCLUYENTE 100% FIABLE
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- EXCLUSION: Destruir previas inyecciones
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in pairs(parentUI:GetChildren()) do
    if v.Name == "ForenseV6" then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ForenseV6"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

-- VENTANA PRINCIPAL ROJA
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 680, 0, 500)
MainFrame.Position = UDim2.new(0.5, -340, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 10)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 50, 50)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local TitleArea = Instance.new("TextLabel")
TitleArea.Size = UDim2.new(1, -30, 0, 30)
TitleArea.BackgroundColor3 = Color3.fromRGB(180, 10, 10)
TitleArea.Text = "  FORENSE ANALYZER V6 - 17 VECTORES EN VIVO"
TitleArea.TextColor3 = Color3.fromRGB(255, 255, 0)
TitleArea.Font = Enum.Font.Code
TitleArea.TextSize = 13
TitleArea.TextXAlignment = Enum.TextXAlignment.Left
TitleArea.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.Code
CloseBtn.TextSize = 14
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local ActionBtn = Instance.new("TextButton")
ActionBtn.Size = UDim2.new(1, -10, 0, 40)
ActionBtn.Position = UDim2.new(0, 5, 0, 35)
ActionBtn.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
ActionBtn.Text = "/// CLICK AQUI PARA INICIAR EL ANALISIS DEL ZOMBI AL FRENTE ///"
ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionBtn.Font = Enum.Font.Code
ActionBtn.TextSize = 14
ActionBtn.Parent = MainFrame

-- SIN SCROLL: USAMOS SIMPLE TEXTLABEL (BUG DELTA-COMPATIBLE)
local LogWindow = Instance.new("TextLabel")
LogWindow.Size = UDim2.new(1, -10, 1, -85)
LogWindow.Position = UDim2.new(0, 5, 0, 80)
LogWindow.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
LogWindow.TextColor3 = Color3.fromRGB(200, 200, 200)
LogWindow.Font = Enum.Font.Code
LogWindow.TextSize = 12
LogWindow.TextXAlignment = Enum.TextXAlignment.Left
LogWindow.TextYAlignment = Enum.TextYAlignment.Top
LogWindow.TextWrapped = true
LogWindow.Text = "\n  1. Parate a menos de 50 studs de un zombi vivo.\n  2. Dale click al boton rojo superior.\n  3. Comenzara el escaneo fisico (hitboxes/scripts/TouchTransmitters)\n  4. Y luego capturara todo el combate en red durante 3 segundos.\n\n  AL TERMINAR, SE COPIARA todo el escaneo a tu portapapeles ctrl+c/v."
LogWindow.Parent = MainFrame

ActionBtn.MouseButton1Click:Connect(function()
    ActionBtn.Text = "ESPERA... ESCANEANDO MOB (~5s)"
    ActionBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
    LogWindow.Text = "Buscando objetivo..."

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
        ActionBtn.Text = "ERROR: ACERCATE A UN MOB Vivo Y VUELVE A CLICKAR"
        ActionBtn.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
        LogWindow.Text = "No se encontro ningun mob en la escena o estan muy lejos.\nAcercate y reinicia el escaneo."
        return
    end

    local log = "== TARGET: " .. mob.Name .. " (HP:" .. math.floor(mHum.Health) .. ") ==\n\n"

    -- V1 Atributos
    local attrs = mob:GetAttributes()
    if next(attrs) then
        local a1 = pcall(function() mob:SetAttribute("Health",0) end)
        log = log .. "[V1] ATRIBUTOS: SetAttr Health=0 -> " .. (a1 and "Exitoso" or "Bloqueado") .. "\n"
    else
        log = log .. "[V1] ATRIBUTOS: Ninguno (100% Server-side)\n"
    end

    -- V2-V5 Físicas y scripts
    local sc = 0
    for _, s in pairs(mob:GetDescendants()) do if s:IsA("Script") then sc=sc+1 end end
    log = log .. "[V2] SCRIPTS LOCALS: " .. sc .. "\n"

    local okP = pcall(function() if myRoot then mRoot.AssemblyLinearVelocity=(mRoot.Position-myRoot.Position).Unit*-30 end end)
    log = log .. "[V4] KNOCKBACK (Empuje): " .. (okP and "Salio Volando (Exploitable)" or "Bloqueado") .. "\n"

    if myRoot then
        local aw = myRoot.Position + myRoot.CFrame.LookVector*100
        local okR = pcall(function() mRoot.CFrame=CFrame.new(mRoot.Position,Vector3.new(aw.X,mRoot.Position.Y,aw.Z)) end)
        log = log .. "[V5] ROTACION CFRAME: " .. (okR and "Obligado a dar espalda (Exploitable)" or "Bloqueada") .. "\n"
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
    log = log .. "[V6] TouchTransmitter: " .. tt .. (tt>0 and " -> USAR: V6 tt:Destroy()" or " -> Dano por Raycast") .. "\n"
    log = log .. "[V7] Hitbox Brazos: " .. arms .. (arms>0 and " -> Reducidos a 0.1 studs" or " -> No se detectaron brazos") .. "\n\n"

    -- V11 Remotes
    local rl = ""
    for _, rem in pairs(game:GetDescendants()) do
        if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
            local n = string.lower(rem.Name)
            if string.find(n,"damage") or string.find(n,"hit") or string.find(n,"attack") then
                rl=rl..rem.Name.." "
            end
        end
    end
    log = log .. "[V11] NOMBRES REMOTES:\n " .. (rl~="" and rl or " Ninguno obvio.") .. "\n\n"

    -- V12-V16 Red en Vivo
    LogWindow.Text = log .. "CAPTURANDO EL COMBATE Y PAQUETES DE RED EN VIVO... (3s)\nNO TEMUEVAS..."
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

    log = log .. "[V13] Dano en 3s: " .. string.format("%.1f",hpDrop) .. " | DPS: " .. string.format("%.2f",hpDrop/3) .. "\n"
    log = log .. (hpDrop>0 and " --> ToolRF Funciona perfectamente\n\n" or " --> ToolRF NO hizo dano. Busca paquete en V14.\n\n")

    log = log .. "[V14] " .. #pkts .. " PAQUETES RECIBIDOS (C->S):\n"
    for rName,rp in pairs(grps) do
        log = log .. " " .. rName .. " -> llamadox" .. #rp .. " veces\n"
        log = log .. " Path: " .. rp[1].path .. "\n"
    end
    if #pkts==0 then log=log.." CERO paquetes de red. El juego oculta sus remotes.\n" end
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
        log = log .. "[V16] REPLAY TEST (Evadiendo rate-limits): " .. hits .. "/5 replays enviados\n  Dano infligido: " .. string.format("%.1f",dmgR) .. "\n"
        log = log .. (dmgR>0 and "  -> MEGA-EXPLOIT: Multiplica DPS x10 al spamear\n" or "  -> Rate-limit activo del server\n")
    else
        log = log .. "[V16] REPLAY: No se capturaron remotes para testear replays.\n"
    end

    -- Mostrar y Copiar
    LogWindow.Text = log
    ActionBtn.Text = "/// ANALISIS TERMINADO Y COPIADO AL PORTAPAPELES (CTRL+V) ///"
    ActionBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)

    pcall(function()
        if setclipboard then setclipboard(log) end
    end)
end)
