local success, errorMessage = pcall(function()
    -- ==============================================================================
    -- 🦖 CATCH A MONSTER: V9.4 — SAFE LOADER + ERROR CATCHER
    -- ==============================================================================

    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LP = Players.LocalPlayer

    -- Evitamos fallos si VirtualInputManager está bloqueado por tu executor
    local VirtualInputManager = nil
    pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)

    -- Decidir la carpeta correcta para la GUI (PlayerGui siempre es seguro)
    local TargetGui = LP:WaitForChild("PlayerGui")

    -- Limpieza segura
    for _, v in pairs(TargetGui:GetChildren()) do
        if v.Name == "CAM_Injector" or v.Name == "CAM_ErrorGui" then
            pcall(function() v:Destroy() end)
        end
    end

    local SG = Instance.new("ScreenGui")
    SG.Name = "CAM_Injector"
    SG.ResetOnSpawn = false
    SG.Parent = TargetGui

    local MF = Instance.new("Frame", SG)
    MF.Size = UDim2.new(0, 480, 0, 415)
    MF.Position = UDim2.new(0.45, 0, 0.2, 0)
    MF.BackgroundColor3 = Color3.fromRGB(20, 15, 20)
    MF.BorderSizePixel = 2
    MF.BorderColor3 = Color3.fromRGB(0, 255, 150)
    MF.Active = true
    MF.Draggable = true

    local Title = Instance.new("TextLabel", MF)
    Title.Size = UDim2.new(1, 0, 0, 26)
    Title.BackgroundColor3 = Color3.fromRGB(10, 60, 40)
    Title.Text = " 💉 INYECTOR GATLING V9.4 (SAFE MODE)"
    Title.TextColor3 = Color3.fromRGB(150, 255, 200)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 12
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local LogFrame = Instance.new("ScrollingFrame", MF)
    LogFrame.Size = UDim2.new(1, -12, 0, 180)
    LogFrame.Position = UDim2.new(0, 6, 0, 30)
    LogFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    LogFrame.ScrollBarThickness = 4
    LogFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local listLayout = Instance.new("UIListLayout", LogFrame)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local lc = 0
    local logBuffer = {}

    local function Log(t, c)
        lc = lc + 1
        local timeStr = "["..os.date("%X").."] "
        table.insert(logBuffer, timeStr..t)
        
        local m = Instance.new("TextLabel", LogFrame)
        m.Size = UDim2.new(1, 0, 0, 15)
        m.BackgroundTransparency = 1
        m.Text = timeStr..t
        m.TextXAlignment = Enum.TextXAlignment.Left
        m.TextColor3 = c or Color3.fromRGB(170, 170, 170)
        m.Font = Enum.Font.Code
        m.TextSize = 11
        m.TextWrapped = true
        m.AutomaticSize = Enum.AutomaticSize.Y
        m.LayoutOrder = lc
        LogFrame.CanvasPosition = Vector2.new(0, 99999)
    end

    local function MkBtn(txt, py)
        local b = Instance.new("TextButton", MF)
        b.Size = UDim2.new(0.92, 0, 0, 30)
        b.Position = UDim2.new(0.04, 0, 0, py)
        b.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        b.TextColor3 = Color3.new(1,1,1)
        b.Font = Enum.Font.GothamSemibold
        b.TextSize = 11
        b.Text = txt
        return b
    end

    local btnHook    = MkBtn("⚙️ SECUESTRAR MÓDULO (MgrFightClient)", 220)
    local btnGatling = MkBtn("💥 ACTIVAR: GATLING DE ATAQUES", 255)
    local btnAFK     = MkBtn("⚔️ AUTO-FARM BÁSICO (Click + AutoCatch)", 290)
    local btnCatch   = MkBtn("🎯 FORZAR CAPTURA 100% (Templates)", 325)
    local btnCopy    = MkBtn("📋 COPIAR LOG (SetClipboard)", 360)

    btnCopy.MouseButton1Click:Connect(function()
        pcall(function()
            if setclipboard then
                setclipboard(table.concat(logBuffer, "\n"))
                Log("📋 Log copiado!", Color3.fromRGB(0, 255, 0))
            else
                Log("❌ setclipboard no soportado por tu executor", Color3.fromRGB(255, 100, 100))
            end
        end)
    end)

    -- ==========================================================
    -- LOGICA DE COMBATE
    -- ==========================================================
    local MgrFightClient = nil

    btnHook.MouseButton1Click:Connect(function()
        Log("Buscando MgrFightClient...", Color3.fromRGB(200, 200, 50))
        pcall(function()
            local modPath = ReplicatedStorage:FindFirstChild("ClientLogic")
            if modPath then modPath = modPath:FindFirstChild("Fight") end
            if modPath then modPath = modPath:FindFirstChild("MgrFightClient") end
            
            if modPath and modPath:IsA("ModuleScript") then
                MgrFightClient = require(modPath)
                if type(MgrFightClient) == "table" and MgrFightClient.TryUseSkill then
                    Log("✅ Módulo SECUESTRADO exitosamente", Color3.fromRGB(0, 255, 0))
                else
                    Log("⚠️ Encontrado pero sin TryUseSkill", Color3.fromRGB(255, 100, 100))
                end
            else
                Log("❌ No se encontró MgrFightClient", Color3.fromRGB(255, 0, 0))
            end
        end)
    end)

    local gatlingActive = false
    btnGatling.MouseButton1Click:Connect(function()
        if not MgrFightClient then
            Log("❌ Primero debes secuestrar el módulo.", Color3.fromRGB(255, 100, 100))
            return
        end
        gatlingActive = not gatlingActive
        btnGatling.BackgroundColor3 = gatlingActive and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(35, 35, 40)
        Log(gatlingActive and "💥 Gatling ON" or "🛑 Gatling OFF", Color3.fromRGB(255, 150, 255))
    end)

    task.spawn(function()
        while true do
            if gatlingActive and MgrFightClient and LP.Character and LP.Character.PrimaryPart then
                pcall(function()
                    local myPos = LP.Character.PrimaryPart.Position
                    local targetMob = nil
                    local targetDist = 60
                    
                    local cm = Workspace:FindFirstChild("ClientMonsters")
                    if cm then
                        for _, mob in pairs(cm:GetChildren()) do
                            if mob:IsA("Model") and mob.PrimaryPart then
                                local d = (mob.PrimaryPart.Position - myPos).Magnitude
                                if d < targetDist then
                                    targetDist = d
                                    targetMob = mob
                                end
                            end
                        end
                    end
                    
                    if targetMob then
                        local oks, errs = 0, nil
                        for i = 1, 5 do
                            local s, e = pcall(function() MgrFightClient.TryUseSkill(MgrFightClient, targetMob) end)
                            if s then oks = oks + 1 else errs = e end
                            
                            local s2, e2 = pcall(function() MgrFightClient.TryUseSkill(targetMob) end)
                            if s2 then oks = oks + 1 else errs = errs or e2 end
                        end
                        if oks > 0 then Log("💥 TryUseSkill "..oks.."x -> "..tostring(targetMob.Name), Color3.fromRGB(100, 255, 100)) end
                        if errs then Log("❌ TryUseSkill Err: "..tostring(errs), Color3.fromRGB(255, 100, 100)) end
                    end
                end)
            end
            task.wait(1) 
        end
    end)

    local farmActive = false
    btnAFK.MouseButton1Click:Connect(function()
        farmActive = not farmActive
        btnAFK.BackgroundColor3 = farmActive and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(35, 35, 40)
    end)

    task.spawn(function()
        while true do
            if farmActive and LP.Character and LP.Character.PrimaryPart then
                pcall(function()
                    local best, bestDist = nil, 60
                    local cm = Workspace:FindFirstChild("ClientMonsters")
                    if cm then
                        for _, mob in pairs(cm:GetChildren()) do
                            local cd = mob:FindFirstChildWhichIsA("ClickDetector", true)
                            if cd and mob.PrimaryPart then
                                local d = (mob.PrimaryPart.Position - LP.Character.PrimaryPart.Position).Magnitude
                                if d < bestDist then bestDist = d; best = cd end
                            end
                        end
                    end
                    if best then fireclickdetector(best) end
                end)
            end
            task.wait(2.5)
        end
    end)

    task.spawn(function()
        pcall(function()
            for _, desc in pairs(ReplicatedStorage:GetDescendants()) do
                if desc:IsA("RemoteEvent") then
                    desc.OnClientEvent:Connect(function(...)
                        if farmActive and tostring({...}[1] or "") == "PushRewardEvent" then
                            task.delay(0.2, function()
                                pcall(function()
                                    if VirtualInputManager then
                                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                        task.wait(0.1)
                                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                    else
                                        Log("⚠️ No se pudo Auto-Catch (InputManager bloqueado)", Color3.fromRGB(255, 100, 100))
                                    end
                                end)
                            end)
                        end
                    end)
                end
            end
        end)
    end)

    btnCatch.MouseButton1Click:Connect(function()
        pcall(function()
            for _, v in pairs(getgc(true)) do
                if type(v) == "table" and type(rawget(v, "CatchProbability")) == "number" then
                    rawset(v, "CatchProbability", 1)
                end
            end
        end)
        Log("✅ Forzada captura", Color3.fromRGB(0, 255, 0))
    end)

end) -- Fin de la protección (pcall)

-- SI ALGO FALLA EN EL CODIGO DE ARRIBA, CREAMOS UNA PANTALLA GIGANTE ROJA DE ERROR
if not success then
    pcall(function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "CAM_ErrorGui"
        sg.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        
        local bg = Instance.new("Frame", sg)
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.new(0.5, 0, 0) -- Rojo oscuro
        
        local msg = Instance.new("TextLabel", bg)
        msg.Size = UDim2.new(0.8, 0, 0.8, 0)
        msg.Position = UDim2.new(0.1, 0, 0.1, 0)
        msg.BackgroundTransparency = 1
        msg.TextColor3 = Color3.new(1, 1, 1)
        msg.TextScaled = true
        msg.Font = Enum.Font.Code
        msg.Text = "¡ERROR CRÍTICO AL CARGAR SCRIPT!\n\nPor favor, envíame una foto o copia este texto:\n\n" .. tostring(errorMessage)
    end)
end
