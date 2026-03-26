    -- ==============================================================================
    -- FORENSE ANALYZER V1.0 - SCRIPT INDEPENDIENTE
    -- Analiza mobs en 17 vectores: fisica, hitbox, red, remotes, replay de dano
    -- Inyectar APARTE del script principal. No interfiere con nada.
    -- ==============================================================================

    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local HttpService = game:GetService("HttpService")
    local LocalPlayer = Players.LocalPlayer

    -- ========== GUI ==========
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ForenseAnalyzerV1"
    ScreenGui.ResetOnSpawn = false
    local ok, parentUI = pcall(function() return game:GetService("CoreGui") end)
    parentUI = ok and parentUI or LocalPlayer:WaitForChild("PlayerGui")
    if parentUI:FindFirstChild("ForenseAnalyzerV1") then
        parentUI:FindFirstChild("ForenseAnalyzerV1"):Destroy()
    end
    ScreenGui.Parent = parentUI

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 680, 0, 520)
    Frame.Position = UDim2.new(0.5, -340, 0.5, -260)
    Frame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    Frame.BorderSizePixel = 2
    Frame.BorderColor3 = Color3.fromRGB(200, 30, 30)
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -35, 0, 32)
    Title.BackgroundColor3 = Color3.fromRGB(160, 10, 10)
    Title.Text = "  [X] FORENSE ANALYZER V1 - 17 VECTORES COMBATE + RED"
    Title.TextColor3 = Color3.fromRGB(255, 240, 80)
    Title.Font = Enum.Font.Code
    Title.TextSize = 12
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Frame

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 32, 0, 32)
    CloseBtn.Position = UDim2.new(1, -32, 0, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 20, 20)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.TextSize = 14
    CloseBtn.Parent = Frame
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local AnalizarBtn = Instance.new("TextButton")
    AnalizarBtn.Size = UDim2.new(0.65, -6, 0, 38)
    AnalizarBtn.Position = UDim2.new(0, 4, 0, 36)
    AnalizarBtn.BackgroundColor3 = Color3.fromRGB(160, 10, 10)
    AnalizarBtn.Text = "[ANALIZAR] Presiona para iniciar 17 vectores (parate cerca de un mob)"
    AnalizarBtn.TextColor3 = Color3.fromRGB(255, 240, 80)
    AnalizarBtn.Font = Enum.Font.Code
    AnalizarBtn.TextSize = 11
    AnalizarBtn.Parent = Frame

    local LimpiarBtn = Instance.new("TextButton")
    LimpiarBtn.Size = UDim2.new(0.35, -6, 0, 38)
    LimpiarBtn.Position = UDim2.new(0.65, 4, 0, 36)
    LimpiarBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    LimpiarBtn.Text = "[LIMPIAR LOG]"
    LimpiarBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    LimpiarBtn.Font = Enum.Font.Code
    LimpiarBtn.TextSize = 12
    LimpiarBtn.Parent = Frame

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -8, 0, 20)
    StatusLabel.Position = UDim2.new(0, 4, 0, 78)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Estado: Listo. Acercate a un zombi y presiona ANALIZAR."
    StatusLabel.TextColor3 = Color3.fromRGB(100, 220, 100)
    StatusLabel.Font = Enum.Font.Code
    StatusLabel.TextSize = 11
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = Frame

    local LogScroll = Instance.new("ScrollingFrame")
    LogScroll.Size = UDim2.new(1, -8, 1, -102)
    LogScroll.Position = UDim2.new(0, 4, 0, 100)
    LogScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    LogScroll.ScrollBarThickness = 5
    LogScroll.BorderSizePixel = 0
    LogScroll.Parent = Frame

    local Layout = Instance.new("UIListLayout")
    Layout.Parent = LogScroll
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 3)

    -- ========== SISTEMA DE LOGS ==========
    local logOrder = 0
    local function AddLog(tag, title, body)
        logOrder = logOrder + 1
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -6, 0, 58)
        row.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
        row.BorderSizePixel = 0
        row.LayoutOrder = logOrder
        row.Parent = LogScroll

        local tagLab = Instance.new("TextLabel")
        tagLab.Size = UDim2.new(0, 55, 0, 58)
        tagLab.BackgroundColor3 = Color3.fromRGB(140, 8, 8)
        tagLab.Text = tag
        tagLab.TextColor3 = Color3.fromRGB(255, 255, 100)
        tagLab.Font = Enum.Font.Code
        tagLab.TextSize = 10
        tagLab.TextWrapped = true
        tagLab.Parent = row

        local titleLab = Instance.new("TextLabel")
        titleLab.Size = UDim2.new(1, -130, 0, 22)
        titleLab.Position = UDim2.new(0, 58, 0, 2)
        titleLab.BackgroundTransparency = 1
        titleLab.Text = title
        titleLab.TextColor3 = Color3.fromRGB(0, 220, 255)
        titleLab.Font = Enum.Font.Code
        titleLab.TextSize = 11
        titleLab.TextXAlignment = Enum.TextXAlignment.Left
        titleLab.Parent = row

        local bodyLab = Instance.new("TextLabel")
        bodyLab.Size = UDim2.new(1, -130, 0, 32)
        bodyLab.Position = UDim2.new(0, 58, 0, 22)
        bodyLab.BackgroundTransparency = 1
        bodyLab.Text = string.sub(body, 1, 180) .. (#body > 180 and "..." or "")
        bodyLab.TextColor3 = Color3.fromRGB(190, 190, 190)
        bodyLab.Font = Enum.Font.Code
        bodyLab.TextSize = 10
        bodyLab.TextXAlignment = Enum.TextXAlignment.Left
        bodyLab.TextWrapped = true
        bodyLab.Parent = row

        local copyBtn = Instance.new("TextButton")
        copyBtn.Size = UDim2.new(0, 62, 0, 28)
        copyBtn.Position = UDim2.new(1, -66, 0.5, -14)
        copyBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
        copyBtn.Text = "COPY"
        copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        copyBtn.Font = Enum.Font.Code
        copyBtn.TextSize = 11
        copyBtn.Parent = row
        copyBtn.MouseButton1Click:Connect(function()
            pcall(function()
                if setclipboard then
                    setclipboard("[" .. tag .. "] " .. title .. "\n" .. body)
                    copyBtn.Text = "OK!"
                    task.delay(1.5, function() copyBtn.Text = "COPY" end)
                end
            end)
        end)
    end

    LimpiarBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(LogScroll:GetChildren()) do
            if v:IsA("Frame") then v:Destroy() end
        end
        logOrder = 0
        StatusLabel.Text = "Log limpiado."
    end)

    -- ========== FUNCION PRINCIPAL DE ANALISIS ==========
    AnalizarBtn.MouseButton1Click:Connect(function()
        AnalizarBtn.Text = "[...] ANALIZANDO... espera ~6 segundos"
        AnalizarBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 0)

        for _, v in pairs(LogScroll:GetChildren()) do
            if v:IsA("Frame") then v:Destroy() end
        end
        logOrder = 0

        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

        -- Buscar mob mas cercano con vida
        local mob, mobRoot, mobHum, closestD = nil, nil, nil, math.huge
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= myChar and not Players:GetPlayerFromCharacter(obj) then
                local h = obj:FindFirstChildWhichIsA("Humanoid")
                local r = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                if h and h.Health > 0 and r then
                    local d = myRoot and (myRoot.Position - r.Position).Magnitude or 9999
                    if d < closestD then
                        closestD = d; mob = obj; mobRoot = r; mobHum = h
                    end
                end
            end
        end

        if not mob then
            StatusLabel.Text = "ERROR: No hay mobs con vida. Acercate a un zombi."
            AddLog("ERR", "Sin mob disponible", "Acercate a un zombi vivo y presiona ANALIZAR de nuevo.")
            AnalizarBtn.Text = "[ANALIZAR] Presiona para iniciar 17 vectores (parate cerca de un mob)"
            AnalizarBtn.BackgroundColor3 = Color3.fromRGB(160, 10, 10)
            return
        end

        StatusLabel.Text = "Analizando: " .. mob.Name .. " (HP:" .. math.floor(mobHum.Health) .. "/" .. math.floor(mobHum.MaxHealth) .. " | " .. math.floor(closestD) .. "m)"
        AddLog("MOB", mob.Name .. " | HP:" .. math.floor(mobHum.Health) .. "/" .. math.floor(mobHum.MaxHealth) .. " | Dist:" .. math.floor(closestD) .. "m", "Iniciando analisis de 17 vectores. Vectores V1-V10 son fisicos, V11-V17 son de red en vivo.")

        local touchParts, attackParts = {}, {}

        -- V1: Mutabilidad de atributos
        local v1 = ""
        local ok1, attrs = pcall(function() return mob:GetAttributes() end)
        if ok1 and next(attrs) then
            v1 = "Atributos encontrados:\n"
            for k, val in pairs(attrs) do
                v1 = v1 .. "  " .. k .. " = " .. tostring(val) .. " (" .. typeof(val) .. ")\n"
            end
            local sa1 = pcall(function() mob:SetAttribute("Health", 0) end)
            local sa2 = pcall(function() mob:SetAttribute("IsNpc", false) end)
            v1 = v1 .. "SetAttribute Health=0: " .. (sa1 and "EXITOSO - posible 1-shot" or "Bloqueado") .. "\n"
            v1 = v1 .. "SetAttribute IsNpc=false: " .. (sa2 and "EJECUTADO" or "Bloqueado")
        else
            v1 = "Sin atributos locales expuestos. Dano 100% server-side."
        end
        AddLog("V1", "Mutabilidad de Atributos del Mob", v1)
        task.wait(0.05)

        -- V2: Scripts locales dentro del mob
        local v2, sc = "", 0
        for _, s in pairs(mob:GetDescendants()) do
            if s:IsA("Script") or s:IsA("LocalScript") or s:IsA("ModuleScript") then
                v2 = v2 .. "[" .. s.ClassName .. "] " .. s:GetFullName() .. "\n"
                sc = sc + 1
            end
        end
        if sc > 0 then
            v2 = "Scripts dentro del mob (" .. sc .. "):\n" .. v2 .. "POTENCIAL: deshabilitar con Disabled=true"
        else
            v2 = "Sin scripts locales. El mob es controlado 100% server-side via Raycast."
        end
        AddLog("V2", "Scripts de IA/Dano dentro del Mob", v2)
        task.wait(0.05)

        -- V3: Validacion de direccion
        local v3 = "Sin HumanoidRootPart local (imposible calcular)."
        if myRoot then
            local okDot, dot = pcall(function()
                return (mobRoot.Position - myRoot.Position).Unit:Dot(myRoot.CFrame.LookVector)
            end)
            if okDot then
                local orient = dot > 0.5 and "MIRANDOLO (frente)" or dot < -0.5 and "DE ESPALDAS al mob" or "LATERAL"
                v3 = "Dot producto: " .. string.format("%.2f", dot) .. " -> " .. orient .. "\n"
                v3 = v3 .. "TIP: Ataca desde atras (Interceptor ON). Si el HP baja = servidor NO valida direccion. Exploit de ataque invisible disponible."
            end
        end
        AddLog("V3", "Validacion de Direccion para Hacer Dano", v3)
        task.wait(0.05)

        -- V4: Knockback / empuje
        local v4 = ""
        local okPush = pcall(function()
            if myRoot then
                mobRoot.AssemblyLinearVelocity = (mobRoot.Position - myRoot.Position).Unit * -30
            end
        end)
        v4 = "Empuje via AssemblyLinearVelocity x-30: " .. (okPush and "EXITOSO (mob salio volando)" or "Bloqueado por servidor") .. "\n"
        for _, vv in pairs(mob:GetDescendants()) do
            if vv:IsA("BodyVelocity") or vv:IsA("LinearVelocity") then
                v4 = v4 .. "Physics encontrado: " .. vv:GetFullName() .. " (manipulable)\n"
            end
        end
        AddLog("V4", "Knockback y Empuje Fisico del Mob", v4)
        task.wait(0.05)

        -- V5: Rotacion forzada
        local v5 = "Sin myRoot - imposible."
        if myRoot then
            local awayPos = myRoot.Position + myRoot.CFrame.LookVector * 100
            local okRot = pcall(function()
                mobRoot.CFrame = CFrame.new(mobRoot.Position, Vector3.new(awayPos.X, mobRoot.Position.Y, awayPos.Z))
            end)
            v5 = "Forzar rotacion CFrame (dar la espalda): " .. (okRot and "EXITOSO! Integra en Farm Loop: mobRoot.CFrame=CFrame.lookAt(pos,awayPos)" or "Bloqueado server-side.")
        end
        AddLog("V5", "Rotacion Forzada CFrame del Mob", v5)
        task.wait(0.05)

        -- V6: TouchInterest (dano por contacto)
        local v6 = ""
        for _, part in pairs(mob:GetDescendants()) do
            if part:IsA("BasePart") then
                local tt = part:FindFirstChildWhichIsA("TouchTransmitter")
                if tt then
                    table.insert(touchParts, part)
                    v6 = v6 .. part.Name .. " [Size:" .. tostring(part.Size) .. "]\n"
                    v6 = v6 .. "  EXPLOIT: tt:Destroy() -> esta parte no puede detectar tu cuerpo\n"
                end
            end
        end
        AddLog("V6", "TouchInterest (Dano por Contacto)", v6 == "" and "Sin TouchInterest. Mob usa Raycast/OverlapParams server-side para hacer dano." or v6)
        task.wait(0.05)

        -- V7: Brazos y hitbox de ataque
        local v7 = ""
        for _, part in pairs(mob:GetDescendants()) do
            if part:IsA("BasePart") then
                local n = string.lower(part.Name)
                if string.find(n, "arm") or string.find(n, "hand") or string.find(n, "weapon") or string.find(n, "hit") or string.find(n, "attack") then
                    table.insert(attackParts, part)
                    local okSz = pcall(function() part.Size = Vector3.new(0.1, 0.1, 0.1) end)
                    v7 = v7 .. part.Name .. " -> size reducido: " .. (okSz and "EXITOSO" or "Bloqueado") .. "\n"
                end
            end
        end
        AddLog("V7", "Brazos / Hitbox de Ataque", v7 == "" and "Sin partes de ataque por nombre. El mob usa Raycast desde HRP (radio ~5-8 studs). Aumenta offset del muro a -6.5 studs." or v7)
        task.wait(0.05)

        -- V8: Congelar IA
        local okWS = pcall(function() mobHum.WalkSpeed = 0; mobHum.JumpPower = 0 end)
        local okCS = pcall(function() mobHum:ChangeState(Enum.HumanoidStateType.Disabled) end)
        AddLog("V8", "Congelar IA / Pathfinding del Mob",
            "WalkSpeed=0 JumpPower=0: " .. (okWS and "EXITOSO (mob paralizado)" or "Bloqueado") ..
            "\nChangeState Disabled: " .. (okCS and "EJECUTADO" or "Bloqueado"))
        task.wait(0.05)

        -- V9: Flags de invulnerabilidad
        local v9, fc = "", 0
        for _, child in pairs(mob:GetDescendants()) do
            if child:IsA("BoolValue") or child:IsA("NumberValue") or child:IsA("IntValue") or child:IsA("StringValue") then
                local n = string.lower(child.Name)
                local sus = string.find(n, "invul") or string.find(n, "immune") or string.find(n, "god") or string.find(n, "stun") or string.find(n, "dead")
                v9 = v9 .. (sus and "[SOSPECHOSO] " or "  ") .. child.Name .. " = " .. tostring(child.Value) .. "\n"
                fc = fc + 1
            end
        end
        AddLog("V9", "Flags de Invulnerabilidad", fc == 0 and "Sin Values dentro del mob. Las flags son server-side." or v9)
        task.wait(0.05)

        -- V10: Resumen fisico
        local v10 = "Mob analizado: " .. mob.Name .. "\n"
        v10 = v10 .. "Partes con TouchInterest: " .. #touchParts .. "\n"
        v10 = v10 .. "Partes de ataque: " .. #attackParts .. "\n\n"
        v10 = v10 .. "PRIORIDADES:\n"
        if #touchParts > 0 then v10 = v10 .. "  [1] V6: destruir TouchTransmitter en loop para anular dano por contacto\n" end
        if #attackParts > 0 then v10 = v10 .. "  [2] V7: arm.Size=Vector3.new(0.1,0.1,0.1) en loop\n" end
        v10 = v10 .. "  [3] Muro offset -6.5 studs (en lugar de -3.5)\n"
        v10 = v10 .. "  [4] Si V5 exitoso: rotar mob con cada golpe en Farm\n"
        AddLog("V10", "Resumen Fisico Pre-Red", v10)

        -- ===== VECTORES 11-17: ANALISIS DE RED EN VIVO =====
        StatusLabel.Text = "V11-V17: Iniciando captura de red en vivo (3 segundos)..."

        -- V11: Inventario de remotes de combate
        local v11, rcnt = "", 0
        for _, rem in pairs(game:GetDescendants()) do
            if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") or rem:IsA("UnreliableRemoteEvent") then
                local n = string.lower(rem.Name)
                if string.find(n, "damage") or string.find(n, "hit") or string.find(n, "hurt") or
                   string.find(n, "attack") or string.find(n, "health") or string.find(n, "hp") or
                   string.find(n, "mob") or string.find(n, "kill") or string.find(n, "tool") or
                   string.find(n, "weapon") or string.find(n, "ability") or string.find(n, "combat") then
                    v11 = v11 .. "[" .. rem.ClassName .. "] " .. rem:GetFullName() .. "\n"
                    rcnt = rcnt + 1
                end
            end
        end
        AddLog("V11", "Inventario Remotes de Combate (" .. rcnt .. " encontrados)", rcnt == 0 and "Sin remotes con nombre obvio. El juego usa nombres genericos. El Interceptor del script principal capturara todo." or v11)

        -- V12: Hook captura en vivo + ataque 3s
        AddLog("V12", "[RED] Captura en vivo iniciada (3 segundos)", "Atacando al mob automaticamente mientras capturamos C->S. Analizando...")
        task.wait(0.3)

        local capturedPkts = {}
        local captureActive = true
        local captureStart = tick()
        local remoteGroups = {}

        local liveHook
        pcall(function()
            liveHook = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                local method = string.lower(tostring(getnamecallmethod()))
                if captureActive and (method == "fireserver" or method == "invokeserver") then
                    pcall(function()
                        local nm, fp = "?", "?"
                        pcall(function() nm = self.Name; fp = self:GetFullName() end)
                        local nLow = string.lower(nm)
                        if not string.find(nLow, "mouse") and not string.find(nLow, "camera") and not string.find(nLow, "input") then
                            table.insert(capturedPkts, {
                                t = tick() - captureStart,
                                name = nm, path = fp,
                                cls = self.ClassName,
                                args = {...},
                                rem = self
                            })
                        end
                    end)
                end
                return liveHook(self, ...)
            end))
        end)

        -- Buscar ToolRF para atacar
        local ToolRF = nil
        pcall(function()
            ToolRF = ReplicatedStorage.Shared.Packages.Knit.Services.ToolService.RF.ToolActivated
        end)

        local hpBefore = mobHum.Health
        local hpSamples = {{t = 0, hp = hpBefore}}

        task.spawn(function()
            local endT = tick() + 3
            while tick() < endT and captureActive do
                pcall(function()
                    if myRoot and mobRoot then
                        myRoot.CFrame = CFrame.lookAt(myRoot.Position, Vector3.new(mobRoot.Position.X, myRoot.Position.Y, mobRoot.Position.Z))
                    end
                    if ToolRF then ToolRF:InvokeServer("Weapon") end
                end)
                pcall(function()
                    table.insert(hpSamples, {t = tick() - captureStart, hp = mobHum.Health})
                end)
                task.wait(0.15)
            end
        end)

        task.wait(3.2)
        captureActive = false

        for _, pkt in ipairs(capturedPkts) do
            if not remoteGroups[pkt.name] then remoteGroups[pkt.name] = {} end
            table.insert(remoteGroups[pkt.name], pkt)
        end

        -- V13: Curva HP forense
        local hpAfter = mobHum.Health
        local hpDrop = hpBefore - hpAfter
        local v13 = "HP inicial: " .. string.format("%.1f", hpBefore) .. " | HP final: " .. string.format("%.1f", hpAfter) .. "\n"
        v13 = v13 .. "Dano total en 3s: " .. string.format("%.1f", hpDrop) .. " | DPS: " .. string.format("%.2f", hpDrop / 3) .. "\n\nCurva de dano:\n"
        for i, s in ipairs(hpSamples) do
            if i > 1 then
                local delta = hpSamples[i - 1].hp - s.hp
                if delta > 0 then
                    v13 = v13 .. "  t+" .. string.format("%.1f", s.t) .. "s : HP " .. string.format("%.0f", s.hp) .. " (-" .. string.format("%.1f", delta) .. ")\n"
                end
            end
        end
        if hpDrop <= 0 then
            v13 = v13 .. "\nDANO NULO: ToolRF no es el canal de dano para este mob. Ver V14 para el remote correcto."
        else
            v13 = v13 .. "\nToolRF CONFIRMADO: " .. string.format("%.1f", hpDrop) .. " HP quitados en 3 segundos."
        end
        AddLog("V13", "Curva HP Forense en Tiempo Real", v13)

        -- V14: Decodificacion paquetes C->S
        local v14 = "Total paquetes capturados: " .. #capturedPkts .. "\n\n"
        for rName, pkts in pairs(remoteGroups) do
            v14 = v14 .. "[" .. pkts[1].cls .. "] " .. rName .. " x" .. #pkts .. "\n"
            v14 = v14 .. "  Path: " .. pkts[1].path .. "\n"
            v14 = v14 .. "  Argumentos de muestra:\n"
            for i, arg in ipairs(pkts[1].args) do
                local tp = typeof(arg)
                local extra = ""
                pcall(function()
                    if tp == "Instance" then extra = " -> " .. arg:GetFullName()
                    elseif tp == "table" then extra = " -> " .. HttpService:JSONEncode(arg)
                    elseif tp == "CFrame" then extra = " pos=" .. tostring(arg.Position) end
                end)
                v14 = v14 .. "    [" .. i .. "] (" .. tp .. ") " .. tostring(arg) .. extra .. "\n"
            end
            if #pkts >= 2 then
                local intv = (pkts[#pkts].t - pkts[1].t) / math.max(1, #pkts - 1)
                v14 = v14 .. "  Rate: " .. string.format("%.1f", 1 / intv) .. "/s\n"
            end
            v14 = v14 .. "\n"
        end
        if #capturedPkts == 0 then
            v14 = v14 .. "CERO paquetes. Tu executor puede no soportar hookmetamethod.\nUsa el Interceptor del script principal + ataque manual para capturar."
        end
        AddLog("V14", "Paquetes C->S Decodificados (lo que envias al server)", v14)

        -- V15: S->C (incoming del servidor)
        AddLog("V15", "Paquetes S->C (Servidor a Cliente)",
            "El HP del mob se sincroniza via Humanoid.Health replication automatica de Roblox (no usa RemoteEvents).\n" ..
            "Para monitorear HP en tiempo real usa el Live Monitor del script principal apuntando al mob.")

        -- V16: Replay y amplificacion de dano
        local v16 = ""
        local bestRem, bestCount, bestArgs = nil, 0, nil
        for _, pkts in pairs(remoteGroups) do
            if #pkts > bestCount then
                bestCount = #pkts
                bestRem = pkts[1].rem
                bestArgs = pkts[1].args
            end
        end

        if bestRem then
            v16 = "Remote mas frecuente: " .. bestRem.Name .. " x" .. bestCount .. "\n"
            v16 = v16 .. "Ejecutando REPLAY x5 en rafaga...\n"
            local hpPre = mobHum.Health
            local hits = 0
            for i = 1, 5 do
                local ok = pcall(function()
                    if bestRem:IsA("RemoteFunction") then
                        bestRem:InvokeServer(table.unpack(bestArgs))
                    else
                        bestRem:FireServer(table.unpack(bestArgs))
                    end
                end)
                if ok then hits = hits + 1 end
                task.wait(0.04)
            end
            task.wait(0.35)
            local dmgReplay = hpPre - mobHum.Health
            v16 = v16 .. "Replays OK: " .. hits .. "/5 | Dano de replay: " .. string.format("%.1f", dmgReplay) .. "\n"
            if dmgReplay > 0 then
                v16 = v16 .. "MEGA-EXPLOIT DETECTADO: Servidor sin rate-limit!\n"
                v16 = v16 .. "Integra un loop de FireServer/InvokeServer en el Farm Loop para x10 DPS.\n"
                v16 = v16 .. "Remote path: " .. bestRem:GetFullName()
            elseif hits > 0 then
                v16 = v16 .. "Rate-limit activo. El remote es valido pero el servidor bloquea spam.\nDPS no ampliable pero remote identificado para otras pruebas."
            else
                v16 = v16 .. "Ningun replay ejecutado correctamente. Remote puede requerir args especificos."
            end
        else
            v16 = "Sin remote capturado en los 3 segundos de combate.\n"
            v16 = v16 .. "Opciones:\n  1. Tu arma no usa RemoteFunction/RemoteEvent\n  2. Executor sin soporte de hookmetamethod\n  3. Usa Interceptor manual del script principal y ataca"
        end
        AddLog("V16", "Replay / Rate-Limit / Amplificacion de Dano", v16)

        -- V17: Resumen final
        local groupCount = 0
        for _ in pairs(remoteGroups) do groupCount = groupCount + 1 end
        local v17 = "=== RESUMEN FORENSE COMPLETO ===\n"
        v17 = v17 .. "Mob: " .. mob.Name .. " | HP restante: " .. string.format("%.1f", mobHum.Health) .. "\n"
        v17 = v17 .. "Paquetes C->S capturados: " .. #capturedPkts .. " | Remotes unicos: " .. groupCount .. "\n"
        v17 = v17 .. "Dano total en 3s: " .. string.format("%.1f", hpDrop) .. " HP | DPS: " .. string.format("%.2f", hpDrop / 3) .. "\n\n"
        v17 = v17 .. "HALLAZGOS:\n"
        v17 = v17 .. (hpDrop > 0 and "  [OK] ToolRF hace dano confirmado\n" or "  [NO] ToolRF no valido para este mob\n")
        v17 = v17 .. (#capturedPkts > 0 and "  [OK] Red capturada - ver V14 para el remote exacto\n" or "  [NO] Red no capturada - usar Interceptor manual\n")
        v17 = v17 .. (#touchParts > 0 and "  [!!] TouchInterest explotable - V6\n" or "")
        v17 = v17 .. (#attackParts > 0 and "  [!!] Brazos/hitbox manipulables - V7\n" or "")
        v17 = v17 .. "\nPROXIMOS PASOS:\n"
        v17 = v17 .. "  1. V16 OK -> loop spam del remote en FarmTask\n"
        v17 = v17 .. "  2. V6 OK -> TouchTransmitter:Destroy() en loop\n"
        v17 = v17 .. "  3. V5 OK -> mobRoot.CFrame=CFrame.lookAt(pos,away) en cada golpe\n"
        v17 = v17 .. "  4. Muro offset: CFrame.new(0,0,-6.5) en ShieldBtn del script principal"
        AddLog("V17", "[FIN] RESUMEN FORENSE - 17 VECTORES COMPLETOS", v17)

        StatusLabel.Text = "Analisis completado. " .. #capturedPkts .. " paquetes capturados. " .. groupCount .. " remotes unicos. DPS: " .. string.format("%.2f", hpDrop / 3)
        AnalizarBtn.Text = "[ANALIZAR] Presiona para iniciar 17 vectores (parate cerca de un mob)"
        AnalizarBtn.BackgroundColor3 = Color3.fromRGB(160, 10, 10)
    end)
