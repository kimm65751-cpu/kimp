-- FORENSE ANALYZER V1 - Script Independiente
-- Inyecta aparte del script principal. No lo afecta.
-- Analiza mobs cercanos en 17 vectores: fisica + red en vivo.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

if parentUI:FindFirstChild("ForenseV1") then
    parentUI:FindFirstChild("ForenseV1"):Destroy()
end

local SGui = Instance.new("ScreenGui")
SGui.Name = "ForenseV1"
SGui.ResetOnSpawn = false
SGui.Parent = parentUI

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 680, 0, 500)
Main.Position = UDim2.new(0.5, -340, 0.5, -250)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(200, 30, 30)
Main.Active = true
Main.Draggable = true
Main.Parent = SGui

local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, -32, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(160, 10, 10)
TitleBar.Text = "  FORENSE ANALYZER V1 - 17 VECTORES (FISICOS + RED)"
TitleBar.TextColor3 = Color3.fromRGB(255, 240, 80)
TitleBar.Font = Enum.Font.Code
TitleBar.TextSize = 12
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.Parent = Main

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 30)
CloseBtn.Position = UDim2.new(1, -32, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 20, 20)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.Code
CloseBtn.TextSize = 14
CloseBtn.Parent = Main
CloseBtn.MouseButton1Click:Connect(function()
    SGui:Destroy()
end)

local RunBtn = Instance.new("TextButton")
RunBtn.Size = UDim2.new(0.6, -4, 0, 36)
RunBtn.Position = UDim2.new(0, 4, 0, 34)
RunBtn.BackgroundColor3 = Color3.fromRGB(160, 10, 10)
RunBtn.Text = "[ANALIZAR] Parate cerca de un mob y presiona aqui"
RunBtn.TextColor3 = Color3.fromRGB(255, 240, 80)
RunBtn.Font = Enum.Font.Code
RunBtn.TextSize = 11
RunBtn.Parent = Main

local ClrBtn = Instance.new("TextButton")
ClrBtn.Size = UDim2.new(0.4, -4, 0, 36)
ClrBtn.Position = UDim2.new(0.6, 2, 0, 34)
ClrBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ClrBtn.Text = "[LIMPIAR]"
ClrBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
ClrBtn.Font = Enum.Font.Code
ClrBtn.TextSize = 12
ClrBtn.Parent = Main

local StatusLbl = Instance.new("TextLabel")
StatusLbl.Size = UDim2.new(1, -8, 0, 18)
StatusLbl.Position = UDim2.new(0, 4, 0, 74)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text = "Listo. Acercate a un zombi y presiona ANALIZAR."
StatusLbl.TextColor3 = Color3.fromRGB(80, 220, 80)
StatusLbl.Font = Enum.Font.Code
StatusLbl.TextSize = 11
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
StatusLbl.Parent = Main

local ScrollF = Instance.new("ScrollingFrame")
ScrollF.Size = UDim2.new(1, -8, 1, -96)
ScrollF.Position = UDim2.new(0, 4, 0, 94)
ScrollF.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
ScrollF.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollF.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollF.ScrollBarThickness = 5
ScrollF.BorderSizePixel = 0
ScrollF.Parent = Main

local ListLayout = Instance.new("UIListLayout")
ListLayout.Parent = ScrollF
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 2)

local logCount = 0
local function Log(tag, title, body)
    logCount = logCount + 1
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 56)
    row.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    row.BorderSizePixel = 0
    row.LayoutOrder = logCount
    row.Parent = ScrollF

    local tg = Instance.new("TextLabel")
    tg.Size = UDim2.new(0, 50, 1, 0)
    tg.BackgroundColor3 = Color3.fromRGB(130, 8, 8)
    tg.Text = tag
    tg.TextColor3 = Color3.fromRGB(255, 255, 80)
    tg.Font = Enum.Font.Code
    tg.TextSize = 10
    tg.TextWrapped = true
    tg.Parent = row

    local ti = Instance.new("TextLabel")
    ti.Size = UDim2.new(1, -120, 0, 20)
    ti.Position = UDim2.new(0, 54, 0, 2)
    ti.BackgroundTransparency = 1
    ti.Text = title
    ti.TextColor3 = Color3.fromRGB(0, 210, 255)
    ti.Font = Enum.Font.Code
    ti.TextSize = 11
    ti.TextXAlignment = Enum.TextXAlignment.Left
    ti.Parent = row

    local bd = Instance.new("TextLabel")
    bd.Size = UDim2.new(1, -120, 0, 30)
    bd.Position = UDim2.new(0, 54, 0, 22)
    bd.BackgroundTransparency = 1
    bd.Text = string.sub(body, 1, 200) .. (#body > 200 and "..." or "")
    bd.TextColor3 = Color3.fromRGB(185, 185, 185)
    bd.Font = Enum.Font.Code
    bd.TextSize = 10
    bd.TextXAlignment = Enum.TextXAlignment.Left
    bd.TextWrapped = true
    bd.Parent = row

    local cp = Instance.new("TextButton")
    cp.Size = UDim2.new(0, 58, 0, 25)
    cp.Position = UDim2.new(1, -62, 0.5, -12)
    cp.BackgroundColor3 = Color3.fromRGB(25, 110, 25)
    cp.Text = "COPY"
    cp.TextColor3 = Color3.fromRGB(255, 255, 255)
    cp.Font = Enum.Font.Code
    cp.TextSize = 11
    cp.Parent = row
    cp.MouseButton1Click:Connect(function()
        pcall(function()
            if setclipboard then
                setclipboard("[" .. tag .. "] " .. title .. "\n\n" .. body)
                cp.Text = "OK!"
                task.delay(1.5, function() cp.Text = "COPY" end)
            end
        end)
    end)
end

ClrBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(ScrollF:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    logCount = 0
    StatusLbl.Text = "Log limpiado."
end)

RunBtn.MouseButton1Click:Connect(function()
    RunBtn.Text = "[...] Analizando... (~6s)"
    RunBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 0)
    for _, v in pairs(ScrollF:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    logCount = 0

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local mob, mobRoot, mobHum, bestDist = nil, nil, nil, math.huge

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= myChar and not Players:GetPlayerFromCharacter(obj) then
            local h = obj:FindFirstChildWhichIsA("Humanoid")
            local r = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
            if h and h.Health > 0 and r then
                local d = myRoot and (myRoot.Position - r.Position).Magnitude or 9999
                if d < bestDist then bestDist=d; mob=obj; mobRoot=r; mobHum=h end
            end
        end
    end

    if not mob then
        StatusLbl.Text = "Sin mob encontrado. Acercate mas a un zombi."
        Log("ERR", "Sin mob con vida cerca", "Acercate a un zombi vivo (menos de 100 studs) y vuelve a presionar ANALIZAR.")
        RunBtn.Text = "[ANALIZAR] Parate cerca de un mob y presiona aqui"
        RunBtn.BackgroundColor3 = Color3.fromRGB(160, 10, 10)
        return
    end

    StatusLbl.Text = "Mob: " .. mob.Name .. " HP:" .. math.floor(mobHum.Health) .. " Dist:" .. math.floor(bestDist) .. "m"
    Log("MOB", mob.Name .. " | HP:" .. math.floor(mobHum.Health) .. "/" .. math.floor(mobHum.MaxHealth) .. " | Dist:" .. math.floor(bestDist) .. "m", "Iniciando analisis de 17 vectores. V1-V10 son fisicos locales. V12-V17 analizan la red en vivo durante 3s de combate.")

    local touchParts, attackParts = {}, {}

    -- V1
    local v1 = ""
    local attrs = mob:GetAttributes()
    if next(attrs) then
        v1 = "Atributos locales:\n"
        for k, val in pairs(attrs) do v1 = v1.."  "..k.." = "..tostring(val).." ("..typeof(val)..")\n" end
        local ok1 = pcall(function() mob:SetAttribute("Health", 0) end)
        local ok2 = pcall(function() mob:SetAttribute("IsNpc", false) end)
        v1 = v1.."SetAttribute Health=0: "..(ok1 and "EXITOSO - posible 1-shot" or "Bloqueado")
        v1 = v1.."\nSetAttribute IsNpc=false: "..(ok2 and "EJECUTADO" or "Bloqueado")
    else
        v1 = "Sin atributos locales. Dano 100% server-side."
    end
    Log("V1", "Mutabilidad de Atributos", v1); task.wait(0.05)

    -- V2
    local v2, sc = "", 0
    for _, s in pairs(mob:GetDescendants()) do
        if s:IsA("Script") or s:IsA("LocalScript") or s:IsA("ModuleScript") then
            v2 = v2.."["..s.ClassName.."] "..s:GetFullName().."\n"; sc=sc+1
        end
    end
    Log("V2", "Scripts dentro del Mob ("..sc..")", sc>0 and "Scripts encontrados:\n"..v2.."Potencial: Disabled=true para desactivarlos" or "Sin scripts locales. Mob controlado server-side via Raycast."); task.wait(0.05)

    -- V3
    local v3 = "Sin HumanoidRootPart propio."
    if myRoot then
        local ok3, dot = pcall(function() return (mobRoot.Position-myRoot.Position).Unit:Dot(myRoot.CFrame.LookVector) end)
        if ok3 then
            v3 = "Dot: "..string.format("%.2f",dot).." | "..(dot>0.5 and "Mirandolo de frente" or dot<-0.5 and "De espaldas al mob" or "Lateral")
            v3 = v3.."\nTIP: Si HP baja atacando de espaldas = servidor NO valida direccion. Exploit: ataque invisible."
        end
    end
    Log("V3", "Validacion de Direccion para Dano", v3); task.wait(0.05)

    -- V4
    local okPush = pcall(function() if myRoot then mobRoot.AssemblyLinearVelocity=(mobRoot.Position-myRoot.Position).Unit*-30 end end)
    local v4 = "Empuje AssemblyLinearVelocity x-30: "..(okPush and "EXITOSO" or "Bloqueado")
    for _, vv in pairs(mob:GetDescendants()) do
        if vv:IsA("BodyVelocity") or vv:IsA("LinearVelocity") then v4=v4.."\nPhysics: "..vv:GetFullName() end
    end
    Log("V4", "Knockback / Empuje Fisico", v4); task.wait(0.05)

    -- V5
    local v5 = "Sin myRoot."
    if myRoot then
        local away = myRoot.Position + myRoot.CFrame.LookVector*100
        local okR = pcall(function() mobRoot.CFrame=CFrame.new(mobRoot.Position,Vector3.new(away.X,mobRoot.Position.Y,away.Z)) end)
        v5 = "Forzar rotacion CFrame: "..(okR and "EXITOSO - integra en Farm: mobRoot.CFrame=CFrame.lookAt(pos,away)" or "Bloqueado server-side.")
    end
    Log("V5", "Rotacion Forzada CFrame del Mob", v5); task.wait(0.05)

    -- V6
    local v6 = ""
    for _, part in pairs(mob:GetDescendants()) do
        if part:IsA("BasePart") and part:FindFirstChildWhichIsA("TouchTransmitter") then
            table.insert(touchParts, part)
            v6 = v6..part.Name.." [Size:"..tostring(part.Size).."] EXPLOIT: tt:Destroy()\n"
        end
    end
    Log("V6", "TouchInterest (Dano por Contacto Fisico)", v6=="" and "Sin TouchInterest. Mob usa Raycast/OverlapParams server-side." or v6); task.wait(0.05)

    -- V7
    local v7 = ""
    for _, part in pairs(mob:GetDescendants()) do
        if part:IsA("BasePart") then
            local n = string.lower(part.Name)
            if string.find(n,"arm") or string.find(n,"hand") or string.find(n,"weapon") or string.find(n,"hit") or string.find(n,"attack") then
                table.insert(attackParts, part)
                local ok7 = pcall(function() part.Size=Vector3.new(0.1,0.1,0.1) end)
                v7 = v7..part.Name.." size reducido: "..(ok7 and "OK" or "Bloqueado").."\n"
            end
        end
    end
    Log("V7", "Brazos / Hitbox de Ataque ("..#attackParts.." partes)", v7=="" and "Sin partes nombradas. Raycast radio ~5-8 studs desde HRP. Solucion: offset muro -6.5 studs." or v7); task.wait(0.05)

    -- V8
    local okW = pcall(function() mobHum.WalkSpeed=0; mobHum.JumpPower=0 end)
    local okS = pcall(function() mobHum:ChangeState(Enum.HumanoidStateType.Disabled) end)
    Log("V8", "Congelar IA del Mob", "WalkSpeed=0: "..(okW and "EXITOSO (mob paralizado)" or "Bloqueado").."\nChangeState Disabled: "..(okS and "EJECUTADO" or "Bloqueado")); task.wait(0.05)

    -- V9
    local v9, fc = "", 0
    for _, c in pairs(mob:GetDescendants()) do
        if c:IsA("BoolValue") or c:IsA("NumberValue") or c:IsA("IntValue") or c:IsA("StringValue") then
            local n = string.lower(c.Name)
            local sus = string.find(n,"invul") or string.find(n,"immune") or string.find(n,"god") or string.find(n,"stun") or string.find(n,"dead")
            v9 = v9..(sus and "[SOSPECHOSO] " or "  ")..c.Name.." = "..tostring(c.Value).."\n"; fc=fc+1
        end
    end
    Log("V9", "Flags de Invulnerabilidad ("..fc.." Values)", fc==0 and "Sin Values expuestos. Flags son server-side." or v9); task.wait(0.05)

    -- V10
    local v10 = "Mob: "..mob.Name.."\nTouchParts: "..#touchParts.." | AttackParts: "..#attackParts.."\n\nPRIORIDADES:\n"
    if #touchParts>0 then v10=v10.."[1] V6: TouchTransmitter:Destroy() en loop - anula dano por contacto\n" end
    if #attackParts>0 then v10=v10.."[2] V7: arm.Size=Vector3.new(0.1,0.1,0.1) en loop\n" end
    v10 = v10.."[3] Offset muro: CFrame.new(0,0,-6.5) en ShieldBtn del script principal\n"
    v10 = v10..(okW and "[4] WalkSpeed bloqueado: mob ya esta paralizado en este momento\n" or "[4] Si V5 OK: mobRoot.CFrame=CFrame.lookAt con cada golpe en Farm\n")
    Log("V10", "Resumen Fisico + Recomendaciones", v10)

    -- ===== RED EN VIVO =====
    StatusLbl.Text = "V11-V17: Capturando red en vivo 3 segundos..."

    -- V11
    local v11, rcnt = "", 0
    for _, rem in pairs(game:GetDescendants()) do
        if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") or rem:IsA("UnreliableRemoteEvent") then
            local n = string.lower(rem.Name)
            if string.find(n,"damage") or string.find(n,"hit") or string.find(n,"hurt") or string.find(n,"attack") or
               string.find(n,"health") or string.find(n,"hp") or string.find(n,"mob") or string.find(n,"kill") or
               string.find(n,"tool") or string.find(n,"weapon") or string.find(n,"ability") then
                v11 = v11.."["..rem.ClassName.."] "..rem:GetFullName().."\n"; rcnt=rcnt+1
            end
        end
    end
    Log("V11", "Inventario Remotes de Combate ("..rcnt..")", rcnt==0 and "Sin nombres obvios. El juego usa nombres genericos. Ver V14 para captura en vivo." or v11)

    -- V12: captura
    Log("V12", "Captura en vivo - 3 segundos", "Iniciada. Atacando al mob y registrando todos los paquetes C->S...")
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
                    local nL = string.lower(nm)
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

    local hpB = mobHum.Health
    local hpLog = {{t=0,hp=hpB}}

    task.spawn(function()
        local endT = tick()+3
        while tick()<endT and captOn do
            pcall(function()
                if myRoot and mobRoot then
                    myRoot.CFrame = CFrame.lookAt(myRoot.Position, Vector3.new(mobRoot.Position.X,myRoot.Position.Y,mobRoot.Position.Z))
                end
                if ToolRF then ToolRF:InvokeServer("Weapon") end
            end)
            pcall(function() table.insert(hpLog,{t=tick()-t0,hp=mobHum.Health}) end)
            task.wait(0.15)
        end
    end)

    task.wait(3.2)
    captOn = false
    for _, p in ipairs(pkts) do
        if not grps[p.name] then grps[p.name]={} end
        table.insert(grps[p.name],p)
    end

    -- V13
    local hpA = mobHum.Health
    local hpDrop = hpB - hpA
    local v13 = "HP: "..string.format("%.1f",hpB).." -> "..string.format("%.1f",hpA).."\nDano 3s: "..string.format("%.1f",hpDrop).." | DPS: "..string.format("%.2f",hpDrop/3).."\nCurva:\n"
    for i, s in ipairs(hpLog) do
        if i>1 then
            local d = hpLog[i-1].hp-s.hp
            if d>0 then v13=v13.."  t+"..string.format("%.1f",s.t).."s HP:"..string.format("%.0f",s.hp).." (-"..string.format("%.1f",d)..")\n" end
        end
    end
    v13 = v13..(hpDrop<=0 and "DANO NULO - ToolRF no valido para este mob." or "ToolRF CONFIRMADO - "..string.format("%.1f",hpDrop).." HP quitados.")
    Log("V13", "Curva HP Forense en Tiempo Real", v13)

    -- V14
    local v14 = "Total paquetes: "..#pkts.."\n\n"
    for rName, rp in pairs(grps) do
        v14 = v14.."["..rp[1].cls.."] "..rName.." x"..#rp.."\n  Path: "..rp[1].path.."\n  Args:\n"
        for i, arg in ipairs(rp[1].args) do
            local tp = typeof(arg); local ex=""
            pcall(function()
                if tp=="Instance" then ex=" -> "..arg:GetFullName()
                elseif tp=="table" then ex=" -> "..HttpService:JSONEncode(arg)
                elseif tp=="CFrame" then ex=" pos="..tostring(arg.Position) end
            end)
            v14 = v14.."    ["..i.."] ("..tp..") "..tostring(arg)..ex.."\n"
        end
        if #rp>=2 then
            v14 = v14.."  Rate: "..string.format("%.1f",1/((rp[#rp].t-rp[1].t)/math.max(1,#rp-1))).." /s\n"
        end
        v14 = v14.."\n"
    end
    if #pkts==0 then v14=v14.."CERO paquetes. Usa Interceptor del script principal + ataque manual." end
    Log("V14", "Paquetes C->S Decodificados", v14)

    -- V15
    Log("V15", "Paquetes S->C (Servidor a Ti)", "HP sincronizado via Humanoid.Health replication de Roblox (sin RemoteEvents).\nUsa Live Monitor del script principal apuntando al mob para ver HP en tiempo real.")

    -- V16
    local bestR, bestC, bestA = nil, 0, nil
    for _, rp in pairs(grps) do
        if #rp>bestC then bestC=#rp; bestR=rp[1].rem; bestA=rp[1].args end
    end
    local v16 = ""
    if bestR then
        v16 = "Remote: "..bestR.Name.." x"..bestC.."\nEjecutando REPLAY x5...\n"
        local hpPre = mobHum.Health; local hits=0
        for i=1,5 do
            local ok = pcall(function()
                if bestR:IsA("RemoteFunction") then bestR:InvokeServer(table.unpack(bestA))
                else bestR:FireServer(table.unpack(bestA)) end
            end)
            if ok then hits=hits+1 end
            task.wait(0.04)
        end
        task.wait(0.35)
        local dmgR = hpPre - mobHum.Health
        v16 = v16.."Replays: "..hits.."/5 | Dano replay: "..string.format("%.1f",dmgR).."\n"
        if dmgR>0 then
            v16 = v16.."MEGA-EXPLOIT: Sin rate-limit. Loop spam -> x10 DPS.\nPath: "..bestR:GetFullName()
        elseif hits>0 then
            v16 = v16.."Rate-limit activo. Remote valido pero spam bloqueado."
        end
    else
        v16 = "Sin remote capturado.\nAtaca manualmente con Interceptor del script principal ON."
    end
    Log("V16", "Replay / Rate-Limit / Amplificacion", v16)

    -- V17
    local gc=0; for _ in pairs(grps) do gc=gc+1 end
    local v17 = "Mob: "..mob.Name.."\nPaquetes C->S: "..#pkts.." | Remotes unicos: "..gc.."\nDano 3s: "..string.format("%.1f",hpDrop).." | DPS: "..string.format("%.2f",hpDrop/3).."\n\nHALLAZGOS:\n"
    v17 = v17..(hpDrop>0 and "  [OK] ToolRF valido\n" or "  [NO] ToolRF no valido -> busca remote en V14\n")
    v17 = v17..(#pkts>0 and "  [OK] Red capturada - ver V14\n" or "  [NO] Red no capturada - usa Interceptor\n")
    v17 = v17..(#touchParts>0 and "  [!!] TouchInterest explotable - V6\n" or "")
    v17 = v17..(#attackParts>0 and "  [!!] Brazos reducibles - V7\n" or "")
    v17 = v17.."\nPROXIMOS PASOS:\n  1. V16 OK -> spam remote en FarmTask del script principal\n  2. V6 OK -> TouchTransmitter:Destroy() en loop\n  3. V5 OK -> mobRoot.CFrame=CFrame.lookAt en Farm con cada golpe\n  4. Muro: CFrame.new(0,0,-6.5) en ShieldBtn"
    Log("V17", "[FIN] RESUMEN FORENSE 17 VECTORES", v17)

    StatusLbl.Text = "Completado. Paquetes: "..#pkts.." | Remotes: "..gc.." | DPS: "..string.format("%.2f",hpDrop/3)
    RunBtn.Text = "[ANALIZAR] Parate cerca de un mob y presiona aqui"
    RunBtn.BackgroundColor3 = Color3.fromRGB(160, 10, 10)
end)
