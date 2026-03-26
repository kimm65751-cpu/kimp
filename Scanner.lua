-- FORENSE ANALYZER V2 - Script Independiente
-- Inyecta aparte del script principal. No lo modifica.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- GUI principal
local sg = Instance.new("ScreenGui")
sg.Name = "ForenseV2"
sg.ResetOnSpawn = false
local okCg = pcall(function() sg.Parent = game:GetService("CoreGui") end)
if not okCg then sg.Parent = LocalPlayer:WaitForChild("PlayerGui", 10) end

if sg.Parent then
    local old = sg.Parent:FindFirstChild("ForenseV2")
    if old and old ~= sg then old:Destroy() end
end

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 700, 0, 510)
Main.Position = UDim2.new(0.5, -350, 0.5, -255)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(200, 30, 30)
Main.Active = true
Main.Draggable = true
Main.Parent = sg

local Bar = Instance.new("TextLabel")
Bar.Size = UDim2.new(1, -32, 0, 30)
Bar.BackgroundColor3 = Color3.fromRGB(160, 10, 10)
Bar.Text = "  FORENSE ANALYZER V2 - 17 VECTORES (FISICOS + RED EN VIVO)"
Bar.TextColor3 = Color3.fromRGB(255, 240, 80)
Bar.Font = Enum.Font.Code
Bar.TextSize = 12
Bar.TextXAlignment = Enum.TextXAlignment.Left
Bar.Parent = Main

local XBtn = Instance.new("TextButton")
XBtn.Size = UDim2.new(0, 32, 0, 30)
XBtn.Position = UDim2.new(1, -32, 0, 0)
XBtn.BackgroundColor3 = Color3.fromRGB(200, 20, 20)
XBtn.Text = "X"
XBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
XBtn.Font = Enum.Font.Code
XBtn.TextSize = 14
XBtn.Parent = Main
XBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

local RunBtn = Instance.new("TextButton")
RunBtn.Size = UDim2.new(0.62, -4, 0, 36)
RunBtn.Position = UDim2.new(0, 4, 0, 34)
RunBtn.BackgroundColor3 = Color3.fromRGB(150, 8, 8)
RunBtn.Text = "[ANALIZAR] Parate cerca de un mob y presiona aqui"
RunBtn.TextColor3 = Color3.fromRGB(255, 240, 80)
RunBtn.Font = Enum.Font.Code
RunBtn.TextSize = 11
RunBtn.Parent = Main

local ClrBtn = Instance.new("TextButton")
ClrBtn.Size = UDim2.new(0.38, -4, 0, 36)
ClrBtn.Position = UDim2.new(0.62, 2, 0, 34)
ClrBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ClrBtn.Text = "[LIMPIAR LOG]"
ClrBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
ClrBtn.Font = Enum.Font.Code
ClrBtn.TextSize = 12
ClrBtn.Parent = Main

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -8, 0, 18)
Status.Position = UDim2.new(0, 4, 0, 74)
Status.BackgroundTransparency = 1
Status.Text = "Listo. Acercate a un zombi y presiona ANALIZAR."
Status.TextColor3 = Color3.fromRGB(80, 220, 80)
Status.Font = Enum.Font.Code
Status.TextSize = 11
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -8, 1, -96)
Scroll.Position = UDim2.new(0, 4, 0, 94)
Scroll.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.ScrollBarThickness = 5
Scroll.BorderSizePixel = 0
Scroll.Parent = Main

local ULL = Instance.new("UIListLayout")
ULL.Parent = Scroll
ULL.SortOrder = Enum.SortOrder.LayoutOrder
ULL.Padding = UDim.new(0, 2)

local n = 0
local function Log(tag, title, body)
    n = n + 1
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 58)
    row.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    row.BorderSizePixel = 0
    row.LayoutOrder = n
    row.Parent = Scroll

    local tg = Instance.new("TextLabel")
    tg.Size = UDim2.new(0, 48, 1, 0)
    tg.BackgroundColor3 = Color3.fromRGB(120, 6, 6)
    tg.Text = tag
    tg.TextColor3 = Color3.fromRGB(255, 255, 80)
    tg.Font = Enum.Font.Code
    tg.TextSize = 10
    tg.TextWrapped = true
    tg.Parent = row

    local ti = Instance.new("TextLabel")
    ti.Size = UDim2.new(1, -118, 0, 20)
    ti.Position = UDim2.new(0, 52, 0, 2)
    ti.BackgroundTransparency = 1
    ti.Text = title
    ti.TextColor3 = Color3.fromRGB(0, 210, 255)
    ti.Font = Enum.Font.Code
    ti.TextSize = 11
    ti.TextXAlignment = Enum.TextXAlignment.Left
    ti.Parent = row

    local bd = Instance.new("TextLabel")
    bd.Size = UDim2.new(1, -118, 0, 32)
    bd.Position = UDim2.new(0, 52, 0, 22)
    bd.BackgroundTransparency = 1
    bd.Text = string.sub(body, 1, 200) .. (#body > 200 and "..." or "")
    bd.TextColor3 = Color3.fromRGB(185, 185, 185)
    bd.Font = Enum.Font.Code
    bd.TextSize = 10
    bd.TextXAlignment = Enum.TextXAlignment.Left
    bd.TextWrapped = true
    bd.Parent = row

    local cp = Instance.new("TextButton")
    cp.Size = UDim2.new(0, 56, 0, 26)
    cp.Position = UDim2.new(1, -60, 0.5, -13)
    cp.BackgroundColor3 = Color3.fromRGB(20, 100, 20)
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
                task.delay(1.5, function() pcall(function() cp.Text = "COPY" end) end)
            end
        end)
    end)
end

ClrBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(Scroll:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    n = 0
    Status.Text = "Log limpiado."
end)

RunBtn.MouseButton1Click:Connect(function()
    RunBtn.Text = "[...] Analizando... (~6s)"
    RunBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 0)
    for _, v in pairs(Scroll:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    n = 0

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
        Status.Text = "Sin mob encontrado. Acercate mas."
        Log("ERR", "Sin mob vivo en rango", "Acercate a un zombi vivo y presiona ANALIZAR de nuevo.")
        RunBtn.Text = "[ANALIZAR] Parate cerca de un mob y presiona aqui"
        RunBtn.BackgroundColor3 = Color3.fromRGB(150, 8, 8)
        return
    end

    Status.Text = mob.Name .. " HP:" .. math.floor(mHum.Health) .. " Dist:" .. math.floor(mDist) .. "m"
    Log("MOB", mob.Name .. " HP:" .. math.floor(mHum.Health) .. "/" .. math.floor(mHum.MaxHealth) .. " Dist:" .. math.floor(mDist) .. "m", "17 vectores. V1-V10 fisicos. V11-V17 red en vivo (3s de combate).")

    local tParts, aParts = {}, {}

    -- V1: Atributos
    local v1 = ""
    local attrs = mob:GetAttributes()
    if next(attrs) then
        v1 = "Atributos locales del mob:\n"
        for k, v in pairs(attrs) do v1 = v1 .. "  " .. k .. " = " .. tostring(v) .. " (" .. typeof(v) .. ")\n" end
        local a1 = pcall(function() mob:SetAttribute("Health", 0) end)
        local a2 = pcall(function() mob:SetAttribute("IsNpc", false) end)
        v1 = v1 .. "SetAttribute Health=0: " .. (a1 and "EXITOSO (posible 1-shot)" or "Bloqueado")
        v1 = v1 .. "\nSetAttribute IsNpc=false: " .. (a2 and "EJECUTADO" or "Bloqueado")
    else
        v1 = "Sin atributos locales. Dano es 100% server-side."
    end
    Log("V1", "Mutabilidad de Atributos", v1)
    task.wait(0.05)

    -- V2: Scripts
    local v2, sc = "", 0
    for _, s in pairs(mob:GetDescendants()) do
        if s:IsA("Script") or s:IsA("LocalScript") or s:IsA("ModuleScript") then
            v2 = v2 .. "[" .. s.ClassName .. "] " .. s:GetFullName() .. "\n"
            sc = sc + 1
        end
    end
    Log("V2", "Scripts IA/Dano dentro del Mob (" .. sc .. ")", sc > 0 and v2 .. "POTENCIAL: s.Disabled=true" or "Sin scripts locales. Mob controlado server-side (Raycast).")
    task.wait(0.05)

    -- V3: Direccion
    local v3 = "Sin myRoot."
    if myRoot then
        local ok3, dot = pcall(function()
            return (mRoot.Position - myRoot.Position).Unit:Dot(myRoot.CFrame.LookVector)
        end)
        if ok3 then
            v3 = "Dot: " .. string.format("%.2f", dot) .. " | " .. (dot > 0.5 and "MIRANDOLO" or dot < -0.5 and "DE ESPALDAS" or "LATERAL")
            v3 = v3 .. "\nTIP: Si HP baja atacando de espaldas -> servidor NO valida direccion = exploit ataque invisible."
        end
    end
    Log("V3", "Validacion de Direccion para Dano", v3)
    task.wait(0.05)

    -- V4: Knockback
    local okPush = pcall(function()
        if myRoot then mRoot.AssemblyLinearVelocity = (mRoot.Position - myRoot.Position).Unit * -30 end
    end)
    local v4 = "Empuje AssemblyLinearVelocity x-30: " .. (okPush and "EXITOSO (mob salio volando)" or "Bloqueado")
    for _, vv in pairs(mob:GetDescendants()) do
        if vv:IsA("BodyVelocity") or vv:IsA("LinearVelocity") then
            v4 = v4 .. "\nPhysics encontrado: " .. vv:GetFullName()
        end
    end
    Log("V4", "Knockback / Empuje Fisico", v4)
    task.wait(0.05)

    -- V5: Rotacion
    local v5 = "Sin myRoot."
    if myRoot then
        local away = myRoot.Position + myRoot.CFrame.LookVector * 100
        local okR = pcall(function()
            mRoot.CFrame = CFrame.new(mRoot.Position, Vector3.new(away.X, mRoot.Position.Y, away.Z))
        end)
        v5 = "Forzar rotacion (dar espalda): " .. (okR and "EXITOSO - integra: mRoot.CFrame=CFrame.lookAt(pos,away)" or "Bloqueado server-side.")
    end
    Log("V5", "Rotacion Forzada CFrame del Mob", v5)
    task.wait(0.05)

    -- V6: TouchInterest
    local v6 = ""
    for _, part in pairs(mob:GetDescendants()) do
        if part:IsA("BasePart") and part:FindFirstChildWhichIsA("TouchTransmitter") then
            table.insert(tParts, part)
            v6 = v6 .. part.Name .. " [" .. tostring(part.Size) .. "] EXPLOIT: tt:Destroy()\n"
        end
    end
    Log("V6", "TouchInterest / Dano por Contacto (" .. #tParts .. ")", v6 == "" and "Sin TouchInterest. Mob usa Raycast/OverlapParams server-side." or v6)
    task.wait(0.05)

    -- V7: Brazos
    local v7 = ""
    for _, part in pairs(mob:GetDescendants()) do
        if part:IsA("BasePart") then
            local nm = string.lower(part.Name)
            if string.find(nm,"arm") or string.find(nm,"hand") or string.find(nm,"weapon") or string.find(nm,"hit") or string.find(nm,"attack") then
                table.insert(aParts, part)
                local ok7 = pcall(function() part.Size = Vector3.new(0.1, 0.1, 0.1) end)
                v7 = v7 .. part.Name .. " -> " .. (ok7 and "REDUCIDO OK" or "Bloqueado") .. "\n"
            end
        end
    end
    Log("V7", "Brazos / Hitbox de Ataque (" .. #aParts .. ")", v7 == "" and "Sin partes por nombre. Raycast ~5-8 studs desde HRP. Fix: offset muro -6.5 studs." or v7)
    task.wait(0.05)

    -- V8: Congelar IA
    local okW = pcall(function() mHum.WalkSpeed = 0; mHum.JumpPower = 0 end)
    local okS = pcall(function() mHum:ChangeState(Enum.HumanoidStateType.Disabled) end)
    Log("V8", "Congelar IA del Mob", "WalkSpeed=0: " .. (okW and "EXITOSO" or "Bloqueado") .. "\nChangeState Disabled: " .. (okS and "EJECUTADO" or "Bloqueado"))
    task.wait(0.05)

    -- V9: Flags
    local v9, fc = "", 0
    for _, c in pairs(mob:GetDescendants()) do
        if c:IsA("BoolValue") or c:IsA("NumberValue") or c:IsA("IntValue") or c:IsA("StringValue") then
            local nm = string.lower(c.Name)
            local sus = string.find(nm,"invul") or string.find(nm,"immune") or string.find(nm,"god") or string.find(nm,"stun") or string.find(nm,"dead")
            v9 = v9 .. (sus and "[SOSPECHOSO] " or "  ") .. c.Name .. " = " .. tostring(c.Value) .. "\n"
            fc = fc + 1
        end
    end
    Log("V9", "Flags de Invulnerabilidad (" .. fc .. " Values)", fc == 0 and "Sin Values expuestos. Flags son server-side." or v9)
    task.wait(0.05)

    -- V10: Resumen fisico
    local v10 = "Mob: " .. mob.Name .. " | TouchParts: " .. #tParts .. " | AttackParts: " .. #aParts .. "\n\nPRIORIDADES:\n"
    if #tParts > 0 then v10 = v10 .. "[1] V6 OK: TouchTransmitter:Destroy() en loop\n" end
    if #aParts > 0 then v10 = v10 .. "[2] V7 OK: arm.Size=Vector3.new(0.1,0.1,0.1) en loop\n" end
    v10 = v10 .. "[3] Muro offset: CFrame.new(0,0,-6.5) en ShieldBtn del script principal\n"
    v10 = v10 .. "[4] Si V5 OK: mRoot.CFrame=CFrame.lookAt con cada golpe en Farm\n"
    Log("V10", "Resumen Fisico + Recomendaciones Prioritarias", v10)

    -- RED EN VIVO
    Status.Text = "Red en vivo: capturando 3 segundos de combate..."

    -- V11: Catalogo remotes
    local v11, rcnt = "", 0
    for _, rem in pairs(game:GetDescendants()) do
        if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") or rem:IsA("UnreliableRemoteEvent") then
            local nm = string.lower(rem.Name)
            if string.find(nm,"damage") or string.find(nm,"hit") or string.find(nm,"hurt") or string.find(nm,"attack") or
               string.find(nm,"health") or string.find(nm,"hp") or string.find(nm,"mob") or string.find(nm,"kill") or
               string.find(nm,"tool") or string.find(nm,"weapon") or string.find(nm,"ability") then
                v11 = v11 .. "[" .. rem.ClassName .. "] " .. rem:GetFullName() .. "\n"
                rcnt = rcnt + 1
            end
        end
    end
    Log("V11", "Remotes de Combate por Nombre (" .. rcnt .. ")", rcnt == 0 and "Sin nombres obvios. Ver V14 para captura en vivo." or v11)

    -- V12: Captura
    Log("V12", "Captura en Vivo - 3 segundos", "Iniciada. Atacando al mob y registrando paquetes C->S...")
    task.wait(0.2)

    local pkts, captOn, t0, grps = {}, true, tick(), {}
    local cHk
    pcall(function()
        cHk = hookmetamethod(game, "__namecall", newcclosure(function(s2, ...)
            local m = string.lower(tostring(getnamecallmethod()))
            if captOn and (m == "fireserver" or m == "invokeserver") then
                pcall(function()
                    local nm, fp = "?", "?"
                    pcall(function() nm = s2.Name; fp = s2:GetFullName() end)
                    local nL = string.lower(nm)
                    if not string.find(nL,"mouse") and not string.find(nL,"camera") and not string.find(nL,"input") then
                        table.insert(pkts, {t=tick()-t0, name=nm, path=fp, cls=s2.ClassName, args={...}, rem=s2})
                    end
                end)
            end
            return cHk(s2, ...)
        end))
    end)

    local ToolRF = nil
    pcall(function()
        ToolRF = ReplicatedStorage.Shared.Packages.Knit.Services.ToolService.RF.ToolActivated
    end)

    local hpB = mHum.Health
    local hpLog = {{t=0, hp=hpB}}

    task.spawn(function()
        local endT = tick() + 3
        while tick() < endT and captOn do
            pcall(function()
                if myRoot and mRoot then
                    myRoot.CFrame = CFrame.lookAt(myRoot.Position, Vector3.new(mRoot.Position.X, myRoot.Position.Y, mRoot.Position.Z))
                end
                if ToolRF then ToolRF:InvokeServer("Weapon") end
            end)
            pcall(function() table.insert(hpLog, {t=tick()-t0, hp=mHum.Health}) end)
            task.wait(0.15)
        end
    end)

    task.wait(3.2)
    captOn = false

    for _, p in ipairs(pkts) do
        if not grps[p.name] then grps[p.name] = {} end
        table.insert(grps[p.name], p)
    end

    -- V13: Curva HP
    local hpA = mHum.Health
    local hpDrop = hpB - hpA
    local v13 = "HP: " .. string.format("%.1f",hpB) .. " -> " .. string.format("%.1f",hpA)
    v13 = v13 .. "\nDano 3s: " .. string.format("%.1f",hpDrop) .. " | DPS: " .. string.format("%.2f",hpDrop/3) .. "\nCurva:\n"
    for i, s in ipairs(hpLog) do
        if i > 1 then
            local d = hpLog[i-1].hp - s.hp
            if d > 0 then
                v13 = v13 .. "  t+" .. string.format("%.1f",s.t) .. "s HP:" .. string.format("%.0f",s.hp) .. " (-" .. string.format("%.1f",d) .. ")\n"
            end
        end
    end
    v13 = v13 .. (hpDrop <= 0 and "DANO NULO - ToolRF no valido. Ver V14." or "ToolRF CONFIRMADO - " .. string.format("%.1f",hpDrop) .. " HP en 3s.")
    Log("V13", "Curva HP Forense en Tiempo Real", v13)

    -- V14: Paquetes
    local v14 = "Total paquetes C->S: " .. #pkts .. "\n\n"
    for rName, rp in pairs(grps) do
        v14 = v14 .. "[" .. rp[1].cls .. "] " .. rName .. " x" .. #rp .. "\n"
        v14 = v14 .. "  Path: " .. rp[1].path .. "\n  Args:\n"
        for i, arg in ipairs(rp[1].args) do
            local tp = typeof(arg)
            local ex = ""
            pcall(function()
                if tp == "Instance" then ex = " -> " .. arg:GetFullName()
                elseif tp == "table" then ex = " -> " .. HttpService:JSONEncode(arg)
                elseif tp == "CFrame" then ex = " pos=" .. tostring(arg.Position) end
            end)
            v14 = v14 .. "    [" .. i .. "] (" .. tp .. ") " .. tostring(arg) .. ex .. "\n"
        end
        if #rp >= 2 then
            local intv = (rp[#rp].t - rp[1].t) / math.max(1, #rp - 1)
            v14 = v14 .. "  Rate: " .. string.format("%.1f", 1/intv) .. "/s\n"
        end
        v14 = v14 .. "\n"
    end
    if #pkts == 0 then
        v14 = v14 .. "CERO paquetes capturados.\nUsa Interceptor del script principal ON + ataca manualmente."
    end
    Log("V14", "Paquetes C->S Decodificados (" .. #pkts .. " capturas)", v14)

    -- V15
    Log("V15", "Paquetes S->C (Servidor->Ti)", "HP sincronizado via Humanoid.Health replication de Roblox (sin RemoteEvents).\nUsa el Live Monitor del script principal apuntando al mob para ver HP en tiempo real.")

    -- V16: Replay
    local bestR, bestC, bestA = nil, 0, nil
    for _, rp in pairs(grps) do
        if #rp > bestC then bestC = #rp; bestR = rp[1].rem; bestA = rp[1].args end
    end
    local v16 = ""
    if bestR then
        v16 = "Remote: " .. bestR.Name .. " x" .. bestC .. "\nREPLAY x5...\n"
        local hpPre = mHum.Health
        local hits = 0
        for i = 1, 5 do
            local ok = pcall(function()
                if bestR:IsA("RemoteFunction") then bestR:InvokeServer(table.unpack(bestA))
                else bestR:FireServer(table.unpack(bestA)) end
            end)
            if ok then hits = hits + 1 end
            task.wait(0.04)
        end
        task.wait(0.35)
        local dmgR = hpPre - mHum.Health
        v16 = v16 .. "Replays: " .. hits .. "/5 | Dano replay: " .. string.format("%.1f", dmgR) .. "\n"
        if dmgR > 0 then
            v16 = v16 .. "MEGA-EXPLOIT: Sin rate-limit! Loop spam -> x10 DPS.\nPath: " .. bestR:GetFullName()
        elseif hits > 0 then
            v16 = v16 .. "Rate-limit activo. Remote valido pero spam bloqueado."
        end
    else
        v16 = "Sin remote capturado en 3s.\nUsa Interceptor del script principal + ataque manual para identificarlo."
    end
    Log("V16", "Replay / Rate-Limit / Amplificacion de Dano", v16)

    -- V17: Resumen
    local gc = 0
    for _ in pairs(grps) do gc = gc + 1 end
    local v17 = "=== RESUMEN FINAL ===\n"
    v17 = v17 .. "Mob: " .. mob.Name .. "\n"
    v17 = v17 .. "Paquetes: " .. #pkts .. " | Remotes unicos: " .. gc .. "\n"
    v17 = v17 .. "Dano 3s: " .. string.format("%.1f",hpDrop) .. " | DPS: " .. string.format("%.2f",hpDrop/3) .. "\n\n"
    v17 = v17 .. "HALLAZGOS:\n"
    v17 = v17 .. (hpDrop > 0 and "  [OK] ToolRF hace dano\n" or "  [NO] ToolRF no valido -> Ver V14\n")
    v17 = v17 .. (#pkts > 0 and "  [OK] Red capturada -> Ver V14\n" or "  [NO] Red no capturada -> Usar Interceptor\n")
    v17 = v17 .. (#tParts > 0 and "  [!!] TouchInterest explotable -> V6\n" or "")
    v17 = v17 .. (#aParts > 0 and "  [!!] Brazos manipulables -> V7\n" or "")
    v17 = v17 .. "\nPROXIMOS PASOS:\n"
    v17 = v17 .. "  1. V16 OK -> loop spam remote en FarmTask del script principal\n"
    v17 = v17 .. "  2. V6 OK -> TouchTransmitter:Destroy() en loop\n"
    v17 = v17 .. "  3. V5 OK -> mRoot.CFrame=CFrame.lookAt en Farm con cada golpe\n"
    v17 = v17 .. "  4. Offset muro: CFrame.new(0,0,-6.5) en ShieldBtn"
    Log("V17", "[FIN] RESUMEN FORENSE 17 VECTORES", v17)

    Status.Text = "Listo. Pkts:" .. #pkts .. " | Remotes:" .. gc .. " | DPS:" .. string.format("%.2f",hpDrop/3)
    RunBtn.Text = "[ANALIZAR] Parate cerca de un mob y presiona aqui"
    RunBtn.BackgroundColor3 = Color3.fromRGB(150, 8, 8)
end)
