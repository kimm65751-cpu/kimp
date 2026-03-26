    -- ==============================================================================
    -- 🕵️ OMNI-FORENSICS ULTIMATE V1.0 (GOD-MODE SCANNER & INTERCEPTOR)
    -- Creado para ingeniería inversa masiva, intercepción de red y clonación de datos.
    -- ==============================================================================

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")
    local CoreGui = game:GetService("CoreGui")
    local HttpService = game:GetService("HttpService")
    local LocalPlayer = Players.LocalPlayer

    -- ==========================================
    -- 1. CREACIÓN DE LA INTERFAZ FORENSE (GUI)
    -- ==========================================
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "OmniForensicsUltimate"
    ScreenGui.ResetOnSpawn = false
    local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.Parent = parentUI

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 700, 0, 530)
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -265)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 128)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    -- Panel lateral: Monitor En Vivo (siempre activo)
    local LivePanel = Instance.new("Frame")
    LivePanel.Size = UDim2.new(0, 280, 0, 430)
    LivePanel.Position = UDim2.new(0, 710, 0.5, -215)
    LivePanel.BackgroundColor3 = Color3.fromRGB(10, 15, 10)
    LivePanel.BorderSizePixel = 2
    LivePanel.BorderColor3 = Color3.fromRGB(0, 200, 100)
    LivePanel.Active = true
    LivePanel.Draggable = true
    LivePanel.Parent = ScreenGui

    local LiveTitle = Instance.new("TextLabel")
    LiveTitle.Size = UDim2.new(1, 0, 0, 25)
    LiveTitle.BackgroundColor3 = Color3.fromRGB(0, 80, 40)
    LiveTitle.Text = " 🟢 LIVE MONITOR (AUTO)"
    LiveTitle.TextColor3 = Color3.fromRGB(0, 255, 100)
    LiveTitle.TextSize = 12
    LiveTitle.Font = Enum.Font.Code
    LiveTitle.TextXAlignment = Enum.TextXAlignment.Left
    LiveTitle.Parent = LivePanel

    local LiveLabel = Instance.new("TextLabel")
    LiveLabel.Size = UDim2.new(1, -4, 1, -30)
    LiveLabel.Position = UDim2.new(0, 2, 0, 27)
    LiveLabel.BackgroundTransparency = 1
    LiveLabel.Text = "(Apunta tu mouse\na algo en el juego)"
    LiveLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    LiveLabel.TextSize = 11
    LiveLabel.Font = Enum.Font.Code
    LiveLabel.TextXAlignment = Enum.TextXAlignment.Left
    LiveLabel.TextYAlignment = Enum.TextYAlignment.Top
    LiveLabel.TextWrapped = true
    LiveLabel.Parent = LivePanel

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    Title.Text = " 🕵️ OMNI-HACKS V3.5 : SKY BOMBER ENGINE 🚀"
    Title.TextColor3 = Color3.fromRGB(0, 255, 128)
    Title.TextSize = 13
    Title.Font = Enum.Font.Code
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = MainFrame

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.Parent = MainFrame
    -- Limpiar la ventana anterior si ya existe para evitar duplicados
    if parentUI:FindFirstChild("OmniForensicsUltimate") and parentUI:FindFirstChild("OmniForensicsUltimate") ~= ScreenGui then
        parentUI:FindFirstChild("OmniForensicsUltimate"):Destroy()
    end

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    MinimizeBtn.Position = UDim2.new(1, -60, 0, 0)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.Font = Enum.Font.Code
    MinimizeBtn.Parent = MainFrame

    local OpenIcon = Instance.new("ImageButton")
    OpenIcon.Size = UDim2.new(0, 50, 0, 50)
    OpenIcon.Position = UDim2.new(0.5, -25, 0, 20)
    OpenIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    OpenIcon.Image = "rbxassetid://10886105073" -- Icono hacker generico en roblox
    OpenIcon.Visible = false
    OpenIcon.Active = true
    OpenIcon.Draggable = true
    OpenIcon.Parent = ScreenGui

    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(1, 0)
    IconCorner.Parent = OpenIcon

    MinimizeBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        OpenIcon.Visible = true
    end)

    OpenIcon.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        OpenIcon.Visible = false
    end)

    local DumpBtn = Instance.new("TextButton")
    DumpBtn.Size = UDim2.new(0.48, 0, 0, 35)
    DumpBtn.Position = UDim2.new(0.01, 0, 0, 35)
    DumpBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 100)
    DumpBtn.Text = "🔍 1. ESCÁNER FORENSE TOTAL"
    DumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DumpBtn.Font = Enum.Font.Code
    DumpBtn.TextSize = 13
    DumpBtn.Parent = MainFrame

    local InterceptBtn = Instance.new("TextButton")
    InterceptBtn.Size = UDim2.new(0.48, 0, 0, 35)
    InterceptBtn.Position = UDim2.new(0.51, 0, 0, 35)
    InterceptBtn.BackgroundColor3 = Color3.fromRGB(20, 80, 100)
    InterceptBtn.Text = "📡 2. INTERCEPTOR RED: OFF"
    InterceptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    InterceptBtn.Font = Enum.Font.Code
    InterceptBtn.TextSize = 13
    InterceptBtn.Parent = MainFrame

    local DeepExamineBtn = Instance.new("TextButton")
    DeepExamineBtn.Size = UDim2.new(0.48, 0, 0, 35)
    DeepExamineBtn.Position = UDim2.new(0.01, 0, 0, 75)
    DeepExamineBtn.BackgroundColor3 = Color3.fromRGB(100, 60, 20)
    DeepExamineBtn.Text = "🔬 3. EXAMINACIÓN PROFUNDA CRÍTICA"
    DeepExamineBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DeepExamineBtn.Font = Enum.Font.Code
    DeepExamineBtn.TextSize = 13
    DeepExamineBtn.Parent = MainFrame

    local UpdateBtn = Instance.new("TextButton")
    UpdateBtn.Size = UDim2.new(0.48, 0, 0, 35)
    UpdateBtn.Position = UDim2.new(0.51, 0, 0, 75)
    UpdateBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    UpdateBtn.Text = "🔄 4. ACTUALIZAR SCRIPT (NO CACHE)"
    UpdateBtn.TextColor3 = Color3.fromRGB(255, 150, 150)
    UpdateBtn.Font = Enum.Font.Code
    UpdateBtn.TextSize = 13
    UpdateBtn.Parent = MainFrame

    local LabBtn = Instance.new("TextButton")
    LabBtn.Size = UDim2.new(0.48, 0, 0, 35)
    LabBtn.Position = UDim2.new(0.01, 0, 0, 115)
    LabBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
    LabBtn.Text = "🧪 5. LAB: CLIC-DIAGNÓSTICO"
    LabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    LabBtn.Font = Enum.Font.Code
    LabBtn.TextSize = 13
    LabBtn.Parent = MainFrame

    local ClearBtn = Instance.new("TextButton")
    ClearBtn.Size = UDim2.new(0.48, 0, 0, 35)
    ClearBtn.Position = UDim2.new(0.51, 0, 0, 115)
    ClearBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ClearBtn.Text = "🗑️ 6. LIMPIAR LOG"
    ClearBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    ClearBtn.Font = Enum.Font.Code
    ClearBtn.TextSize = 13
    ClearBtn.Parent = MainFrame

    ClearBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(LogScroll:GetChildren()) do
            if v:IsA("Frame") then v:Destroy() end
        end
    end)

    local ExploitBtn = Instance.new("TextButton")
    ExploitBtn.Size = UDim2.new(1, -10, 0, 35)
    ExploitBtn.Position = UDim2.new(0.01, 0, 0, 155)
    ExploitBtn.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
    ExploitBtn.Text = "☠️ 7. ANALISIS EXPLOIT AVANZADO (BUGS DE COMBATE NPC)"
    ExploitBtn.TextColor3 = Color3.fromRGB(255, 255, 100)
    ExploitBtn.Font = Enum.Font.Code
    ExploitBtn.TextSize = 13
    ExploitBtn.Parent = MainFrame

    local LogScroll = Instance.new("ScrollingFrame")
    LogScroll.Size = UDim2.new(1, -20, 1, -205)
    LogScroll.Position = UDim2.new(0, 10, 0, 200)
    LogScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    LogScroll.ScrollBarThickness = 6
    LogScroll.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = LogScroll
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)

    -- ==========================================
    -- 2. SISTEMA DE LOGS CONTEXTUALES
    -- ==========================================
    local function AddLog(Prefix, Text, Details)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 50)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        frame.Parent = LogScroll
        
        local titleLab = Instance.new("TextLabel")
        titleLab.Size = UDim2.new(1, -80, 0.4, 0)
        titleLab.Position = UDim2.new(0, 5, 0, 2)
        titleLab.BackgroundTransparency = 1
        titleLab.Text = "["..Prefix.."] " .. Text
        titleLab.TextColor3 = Color3.fromRGB(0, 255, 255)
        titleLab.TextXAlignment = Enum.TextXAlignment.Left
        titleLab.Font = Enum.Font.Code
        titleLab.TextSize = 12
        titleLab.Parent = frame
        
        local descLab = Instance.new("TextLabel")
        descLab.Size = UDim2.new(1, -80, 0.5, 0)
        descLab.Position = UDim2.new(0, 5, 0.4, 0)
        descLab.BackgroundTransparency = 1
        descLab.Text = string.sub(Details, 1, 150) .. (#Details > 150 and "..." or "")
        descLab.TextColor3 = Color3.fromRGB(200, 200, 200)
        descLab.TextXAlignment = Enum.TextXAlignment.Left
        descLab.Font = Enum.Font.Code
        descLab.TextSize = 11
        descLab.TextWrapped = true
        descLab.Parent = frame
        
        local copyBtn = Instance.new("TextButton")
        copyBtn.Size = UDim2.new(0, 60, 0, 30)
        copyBtn.Position = UDim2.new(1, -70, 0.5, -15)
        copyBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        copyBtn.Text = "Copy"
        copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        copyBtn.Font = Enum.Font.Code
        copyBtn.Parent = frame
        copyBtn.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(Details)
                copyBtn.Text = "Copied!"
                task.delay(1, function() copyBtn.Text = "Copy" end)
            end
        end)
    end

    local function SerializeInstance(obj)
        local str = "[\n"
        pcall(function()
            for k,v in pairs(obj:GetAttributes()) do str = str .. "  " .. k .. " = " .. typeof(v) .. ":" .. tostring(v) .. ",\n" end
            if obj:IsA("ValueBase") then str = str .. "  Value = " .. tostring(obj.Value) .. "\n" end
        end)
        return str .. "]"
    end

    -- ==========================================
    -- 3. INTERCEPTOR Y MANIPULADOR DE RED (LA MAGIA)
    -- ==========================================
    local InterceptorActivo = false
    local oldNamecall
    local originalFireClient

    CloseBtn.MouseButton1Click:Connect(function()
        InterceptorActivo = false
        ScreenGui:Destroy()
    end)

    UpdateBtn.MouseButton1Click:Connect(function()
        -- Cerrar todo lo local limpiamente
        InterceptorActivo = false
        ScreenGui:Destroy()
        
        -- Inyección directa al repo especificado (sin cache)
        local ScriptURL = "https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"
        local bypassUrl = ScriptURL .. "?v=" .. tostring(os.time()) .. tostring(math.random(1000, 9999))
        
        pcall(function()
            loadstring(game:HttpGet(bypassUrl, true))()
        end)
    end)

    InterceptBtn.MouseButton1Click:Connect(function()
        InterceptorActivo = not InterceptorActivo
        if InterceptorActivo then
            InterceptBtn.Text = "📡 2. INTERCEPTOR DE RED: ON"
            InterceptBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
            AddLog("RED", "Iniciando captura de paquetes...", "Con el Interceptor encendido, cualquier click a tiendas, minería o combates será analizado y mostrado aquí antes de ir al servidor.")
        else
            InterceptBtn.Text = "📡 2. INTERCEPTOR DE RED: OFF"
            InterceptBtn.BackgroundColor3 = Color3.fromRGB(20, 80, 100)
        end
    end)

    local NetworkQueue = {}
    local LabClickActivo = false

    local function LogPacketToQueue(methodAlias, obj, args)
        if #NetworkQueue > 100 then table.remove(NetworkQueue, 1) end
        table.insert(NetworkQueue, {
            Time = tick(),
            Method = methodAlias,
            Obj = obj,
            Args = args
        })

        if InterceptorActivo then
            local selfName = "UnknownRemote"
            pcall(function() selfName = obj.Name end)
            local nLow = string.lower(selfName)

            -- Filtramos solo ruido puro de mouse/camara
            if not string.find(nLow, "camera") and not string.find(nLow, "mousemove") then
                task.spawn(function()
                    pcall(function()
                        local fullPath = "Unknown"
                        pcall(function() fullPath = obj:GetFullName() end)
                        local argDump = "--- MODO "..methodAlias.." ---\nDestino: " .. fullPath .. "\nArgs:\n"
                        for i, v in pairs(args) do
                            local typeV = typeof(v)
                            local extraInfo = ""
                            if typeV == "Instance" then pcall(function() extraInfo = " | Padre: "..tostring(v.Parent) end) end
                            if typeV == "table" then pcall(function() extraInfo = " | JSON: "..HttpService:JSONEncode(v) end) end
                            argDump = argDump .. "["..tostring(i).."] ("..typeV..") = " .. tostring(v) .. extraInfo .. "\n"
                        end
                        AddLog("C->S", selfName, argDump)
                    end)
                end)
            end
        end
    end

    -- Hook de Red: Namecall Clásico
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local methodStr = string.lower(tostring(method))
        if methodStr == "fireserver" or methodStr == "invokeserver" then
            LogPacketToQueue("Namecall("..methodStr..")", self, {...})
        end
        return oldNamecall(self, ...)
    end))

    -- Hook de Red: FireServer Directo
    local originalFireServer
    originalFireServer = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(self, ...)
        LogPacketToQueue("FireServer", self, {...})
        return originalFireServer(self, ...)
    end))

    -- Hook de Red: UnreliableRemoteEvent (Si el juego es nuevo/lag compensado)
    local originalUnreliable
    pcall(function()
        originalUnreliable = hookfunction(Instance.new("UnreliableRemoteEvent").FireServer, newcclosure(function(self, ...)
            LogPacketToQueue("UnreliableFireServer", self, {...})
            return originalUnreliable(self, ...)
        end))
    end)

    -- Hook de Red: InvokeServer Directo
    local originalInvokeServer
    originalInvokeServer = hookfunction(Instance.new("RemoteFunction").InvokeServer, newcclosure(function(self, ...)
        LogPacketToQueue("InvokeServer", self, {...})
        return originalInvokeServer(self, ...)
    end))

    -- Hook para incoming (Servidor -> Tu PC)
    -- Interceptar eventos OnClientEvent para ver cómo nos mandan recompensas, stats o daños
    if not originalFireClient then
        originalFireClient = hookfunction(Instance.new("RemoteEvent").FireClient, newcclosure(function(self, player, ...)
            if InterceptorActivo and player == LocalPlayer then
                local args = {...}
                local argDump = "--- PAQUETE ENTRANTE ---\nOrigen: " .. self:GetFullName() .. "\nArgumentos:\n"
                for i, v in ipairs(args) do
                    local extraInfo = ""
                    if typeof(v) == "table" then
                        pcall(function() extraInfo = " | JSON: " .. HttpService:JSONEncode(v) end)
                    elseif typeof(v) == "Instance" then
                        pcall(function() extraInfo = " | Nombre/Path: " .. v:GetFullName() end)
                    end
                    argDump = argDump .. "["..i.."] ("..typeof(v)..") = " .. tostring(v) .. extraInfo .. "\n"
                end
                task.spawn(function() AddLog("S->C", self.Name, argDump) end)
            end
            return originalFireClient(self, player, ...)
        end))
    end

    -- ==========================================
    -- 4. ESCÁNER FORENSE ABSOLUTO (DUMP TOTAL)
    -- ==========================================
    DumpBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(LogScroll:GetChildren()) do
            if v:IsA("Frame") then v:Destroy() end
        end
        AddLog("SISTEMA", "Iniciando Escrutinio Profundo...", "Leyendo arquitectura completa del juego...")
        task.wait(0.1)
        
        local MegaDump = "=========== 🕵️ REPORTE FORENSE UNIVERSAL ROBLOX V1.0 ===========\nGenerado: " .. tostring(os.date()) .. "\n\n"

        -- 1. IDENTIFICACIÓN DEL JUEGO Y SEGURIDAD
        MegaDump = MegaDump .. "==================== [1] ARQUITECTURA Y ANTI-CHEAT ====================\n"
        local acFound = ""
        for _, script in pairs(LocalPlayer:GetDescendants()) do
            if script:IsA("LocalScript") then
                local n = string.lower(script.Name)
                if string.find(n, "anti") or string.find(n, "ban") or string.find(n, "admin") or string.find(n, "exploit") or string.find(n, "kick") then
                    acFound = acFound .. " - " .. script:GetFullName() .. "\n"
                end
            end
        end
        MegaDump = MegaDump .. "🛡️ Scripts de Seguridad Client-Sided:\n" .. (acFound ~= "" and acFound or " Ninguno aparente en el jugador.\n")
        
        local pkgs = ReplicatedStorage:FindFirstChild("Packages")
        MegaDump = MegaDump .. "⚙️ Framework Principal: " .. (pkgs and "Knit/Aero Detectado (Carpetas de Node Packages presentes)\n" or "Scripting Raw / Propio\n")

        -- 2. ECONOMÍA, DATA Y RECOMPENSAS
        MegaDump = MegaDump .. "\n==================== [2] ECONOMÍA Y STATS ====================\n"
        for _, folderName in pairs({"leaderstats", "Data", "Profile", "Stats"}) do
            local f = LocalPlayer:FindFirstChild(folderName)
            if f then
                MegaDump = MegaDump .. "📂 " .. folderName .. " Encontrado:\n"
                for _, val in pairs(f:GetDescendants()) do
                    if val:IsA("ValueBase") then
                        MegaDump = MegaDump .. "  💰 " .. val.Name .. " = " .. tostring(val.Value) .. "\n"
                    end
                end
            end
        end
        MegaDump = MegaDump .. "🏷️ Atributos Base del Jugador:\n"
        for k, v in pairs(LocalPlayer:GetAttributes()) do MegaDump = MegaDump .. "  " .. k .. " = " .. tostring(v) .. "\n" end

        -- 3. SISTEMA DE ARMAS / COMBATE
        MegaDump = MegaDump .. "\n==================== [3] ARSENAL E INVENTARIO ====================\n"
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Tool") or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
        if tool then
            MegaDump = MegaDump .. "🗡️ Arma de Muestra: " .. tool.Name .. "\n"
            MegaDump = MegaDump .. "  Tipo de Almacenamiento: " .. (tool:GetAttribute("ItemJSON") and "Usa ItemJSON (¡Hackeable por Strings!)" or "Usa Partes/Values nativos") .. "\n"
            MegaDump = MegaDump .. "  Atributos Extra:\n"
            for k, v in pairs(tool:GetAttributes()) do MegaDump = MegaDump .. "    -" .. k .. " = " .. tostring(v) .. "\n" end
            local rEq = tool:FindFirstChildWhichIsA("RemoteEvent", true) or tool:FindFirstChildWhichIsA("RemoteFunction", true)
            MegaDump = MegaDump .. "  Remote Inyectado en Arma: " .. (rEq and rEq:GetFullName() or "Ninguno local") .. "\n"
        else
            MegaDump = MegaDump .. "⚠️ Sin equipo para analizar.\n"
        end

        -- 4. INGENIERÍA INVERSA DE NPC / TIENDAS
        MegaDump = MegaDump .. "\n==================== [4] INTERACCIONES Y TIENDAS ====================\n"
        local npcs = {}
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                -- ¿Como se vende algo?
                table.insert(npcs, "  🛒 ProximityPrompt: [" .. obj.ActionText .. "] en " .. obj.Parent.Name .. " | Destino: " .. obj:GetFullName())
            end
        end
        for i=1, math.min(10, #npcs) do MegaDump = MegaDump .. npcs[i] .. "\n" end
        MegaDump = MegaDump .. ( #npcs == 0 and "  No usa ProximityPrompts para tiendas, probablemente usa GUI OnClick + Raycast.\n" or "")

        -- 5. LEYES DE MINERÍA / FÍSICAS RESTRINGIDAS
        MegaDump = MegaDump .. "\n==================== [5] BLOQUEOS DE MINERÍA ====================\n"
        local rocksFound = false
        for _, obj in pairs(Workspace:GetDescendants()) do
            local n = string.lower(obj.Name)
            if (string.find(n, "rock") or string.find(n, "pebble") or string.find(n, "ore")) and obj:IsA("Model") then
                rocksFound = true
                MegaDump = MegaDump .. "⛏️ Ejemplo de Roca: " .. obj:GetFullName() .. "\n"
                MegaDump = MegaDump .. "  ¿Por qué no la pico?\n"
                MegaDump = MegaDump .. "  Atributos: " .. SerializeInstance(obj) .. "\n"
                
                local reqs = ""
                for _, v in pairs(obj:GetChildren()) do
                    if string.find(string.lower(v.Name), "req") or string.find(string.lower(v.Name), "tier") or v:IsA("ValueBase") then
                        reqs = reqs .. v.Name .. " ("..v.ClassName..") = " .. tostring(pcall(function() return v.Value end) and v.Value or "nil") .. " | "
                    end
                end
                MegaDump = MegaDump .. "  Dependencias Ocultas: " .. (reqs ~= "" and reqs or "No usa Values, exige comprobación de String de herramienta en Servidor.") .. "\n"
                break
            end
        end
        if not rocksFound then MegaDump = MegaDump .. "Ningún Ore encontrado en Workspace.\n" end

        -- 6. ANÁLISIS DE ENEMIGOS (MOBS)
        MegaDump = MegaDump .. "\n==================== [6] ESTRUCTURA DE MOBS ====================\n"
        local hRoot
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= LocalPlayer.Character and not Players:GetPlayerFromCharacter(obj) then
                hRoot = obj
                break
            end
        end
        
        if hRoot then
            MegaDump = MegaDump .. "🧟 Zombie de muestra: " .. hRoot.Name .. "\n"
            MegaDump = MegaDump .. "  Atributos: " .. SerializeInstance(hRoot) .. "\n"
            local dmgScipt = hRoot:FindFirstChild("Damage") or hRoot:FindFirstChild("Combat")
            MegaDump = MegaDump .. "  ¿Cómo nos pega?: " .. (dmgScipt and "Usa Script Local en su cuerpo." or "El servidor calcula el raycast desde su HumanoidRootPart hacia ti.") .. "\n"
            MegaDump = MegaDump .. "  Humanoid Hipotético (HP): " .. tostring(hRoot.Humanoid.Health) .. "/" .. tostring(hRoot.Humanoid.MaxHealth) .. "\n"
        else
            MegaDump = MegaDump .. "Sin mobs en el mapa de prueba.\n"
        end

        -- 7. CATÁLOGO DE ATAQUES AL SERVIDOR
        MegaDump = MegaDump .. "\n==================== [7] REMOTES DE IMPACTO ====================\n"
        local critFound = 0
        for _, rem in pairs(game:GetDescendants()) do
            if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                local n = string.lower(rem.Name)
                if string.find(n, "damage") or string.find(n, "hurt") or string.find(n, "hit") or string.find(n, "attack") or string.find(n, "combat") then
                    critFound = critFound + 1
                    if critFound <= 20 then
                        MegaDump = MegaDump .. "  ⚔️ COMBAT REMOTE: " .. rem:GetFullName() .. " ["..rem.ClassName.."]\n"
                        MegaDump = MegaDump .. "    --> Tips: Intercepta para ver los args. Probable uso: FireServer(Mob.Hitbox, WeaponID)\n"
                    end
                end
            end
        end

        -- 8. INGENIERÍA DE HITBOXES Y PUNTOS CRÍTICOS (NUEVO)
        MegaDump = MegaDump .. "\n==================== [8] HITBOXES Y PUNTOS CRÍTICOS ====================\n"
        local hitboxesFound = 0
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = string.lower(obj.Name)
                if string.find(n, "hitbox") or string.find(n, "weak") or string.find(n, "crit") or string.find(n, "head") then
                    hitboxesFound = hitboxesFound + 1
                    if hitboxesFound <= 15 then -- Limitamos a 15 para no saturar
                        MegaDump = MegaDump .. "🎯 " .. obj.Name .. " encontrado en: " .. obj:GetFullName() .. "\n"
                        MegaDump = MegaDump .. "  - Tamaño y Transparencia: " .. tostring(obj.Size) .. " | Transparencia: " .. tostring(obj.Transparency) .. "\n"
                        
                        local touch = obj:FindFirstChildWhichIsA("TouchTransmitter")
                        if touch then
                            MegaDump = MegaDump .. "  - 💥 ¡Usa 'TouchInterest'! Métodos de explotación en Delta:\n"
                            MegaDump = MegaDump .. "      Opción A: Ejecutar firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 0) y luego (..., 1).\n"
                            MegaDump = MegaDump .. "      Opción B: Teletransportar localmente la Hitbox hacia la parte de tu arma constantemente en RunService.\n"
                        else
                            MegaDump = MegaDump .. "  - 📡 No usa TouchInterest directo. El daño se debe manejar vía Region3, OverlapParams, Raycast o RemoteEvent pasando la Hitbox al impactarla en el cliente.\n"
                        end

                        local weldedTo = obj:FindFirstChildWhichIsA("Weld") or obj:FindFirstChildWhichIsA("WeldConstraint") or obj:FindFirstChildWhichIsA("Motor6D")
                        if weldedTo then
                            MegaDump = MegaDump .. "  - 🔗 Soldado a: " .. tostring(weldedTo.Part0) .. " / " .. tostring(weldedTo.Part1) .. "\n"
                        end
                    end
                end
            end
        end
        if hitboxesFound == 0 then
            MegaDump = MegaDump .. "No se encontraron partes explícitas con el nombre 'Hitbox' o 'Critbox'. El juego podría calcular el daño dinámicamente o por Raycast desde el rootpart.\n"
        elseif hitboxesFound > 15 then
            MegaDump = MegaDump .. "... y " .. tostring(hitboxesFound - 15) .. " Hitboxes más omitidas para resumir.\n"
        end

        MegaDump = MegaDump .. "\n========================================================================\n"
        MegaDump = MegaDump .. "                [ FIN DEL REPORTE - COPIA LA DATA COMPLETA ]\n"
        MegaDump = MegaDump .. "========================================================================"

        AddLog("REPORTE", "¡DUMP EXITOSO! Toda la arquitectura ha sido vaciada.", MegaDump)
    end)

    -- ==========================================
    -- 5. EXAMINACIÓN PROFUNDA (DEEP EXAMINE)
    -- ==========================================
    DeepExamineBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(LogScroll:GetChildren()) do
            if v:IsA("Frame") then v:Destroy() end
        end
        AddLog("ANALISIS", "Iniciando Examinación Profunda de Funciones y Entorno...", "Buscando Metatables, Entornos Ocultos y Conexiones Fantasma.")
        task.wait(0.2)

        -- 1. Buscar módulos ocultos o requeridos que administren el anticheat o daño
        local modulesDump = "==================== [A] MÓDULOS SOSPECHOSOS Y FUNCIONES ====================\n"
        local foundModules = 0
        for _, v in pairs(getloadedmodules and getloadedmodules() or {}) do
            local n = string.lower(v.Name)
            if string.find(n, "damage") or string.find(n, "combat") or string.find(n, "security") or string.find(n, "network") or string.find(n, "client") then
                foundModules = foundModules + 1
                if foundModules <= 15 then
                    modulesDump = modulesDump .. "📦 Módulo Encontrado: " .. v:GetFullName() .. "\n"
                    local success, env = pcall(require, v)
                    if success and type(env) == "table" then
                        modulesDump = modulesDump .. "  --> Funciones Exportadas: \n"
                        for key, val in pairs(env) do
                            if type(val) == "function" then
                                modulesDump = modulesDump .. "       - " .. tostring(key) .. "() (Llamable)\n"
                            end
                        end
                    else
                        modulesDump = modulesDump .. "  --> Módulo protegido o no es una tabla accesible.\n"
                    end
                end
            end
        end
        if foundModules == 0 then modulesDump = modulesDump .. "No se encontraron módulos de combate expuestos localmente.\n" end
        AddLog("MÓDULOS", "Estructura interna de scripts interceptada.", modulesDump)

        -- 2. Análisis Crítico de Propiedades Físicas Escondidas en el Personaje
        local propertiesDump = "==================== [B] PROPIEDADES CRÍTICAS FÍSICAS (JUGADOR) ====================\n"
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if root and hum then
            propertiesDump = propertiesDump .. "🏃 Velocidades y Estados:\n"
            propertiesDump = propertiesDump .. "   WalkSpeed Base: " .. tostring(hum.WalkSpeed) .. "\n"
            propertiesDump = propertiesDump .. "   CollisionGroupId (Root): " .. tostring(root.CollisionGroupId) .. "\n"
            propertiesDump = propertiesDump .. "   Masa del Root: " .. tostring(root:GetMass()) .. " (Podría usarse para detectar Anti-Fly/Float)\n"
            
            local hiddenValues = ""
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("NumberValue") or v:IsA("StringValue") or v:IsA("BoolValue") then
                    hiddenValues = hiddenValues .. "   - " .. v.Name .. " ("..v.ClassName..") = " .. tostring(v.Value) .. "\n"
                end
            end
            propertiesDump = propertiesDump .. "💰 Values Ocultos In-Character:\n" .. (hiddenValues ~= "" and hiddenValues or "   Ninguno.\n")
        end
        AddLog("FÍSICAS", "Verificación de Flags Anticheat en Jugador.", propertiesDump)

        -- 3. Reconocimiento de Remotes Señuelo (Honeypots)
        local honeypotDump = "==================== [C] DETECCIÓN DE TRAMPAS (HONEYPOTS) ====================\n"
        local trapCount = 0
        for _, rem in pairs(game:GetDescendants()) do
            if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                local n = string.lower(rem.Name)
                -- Remotos trampa comunes
                if string.find(n, "ban") or string.find(n, "kick") or string.find(n, "crash") or string.find(n, "error") or string.find(n, "detect") or string.find(n, "flag") then
                    trapCount = trapCount + 1
                    honeypotDump = honeypotDump .. "🚫 HONEYPOT (¡NO LO TOQUES!): " .. rem:GetFullName() .. "\n"
                    honeypotDump = honeypotDump .. "   Razón: Remoto que claramente levanta un ban directo en el servidor al activarse (Admin/Anticheat Trap).\n"
                end
            end
        end
        if trapCount == 0 then honeypotDump = honeypotDump .. "Tu juego parece seguro a simple vista, no hay remotes trampa evidentes.\n" end
        AddLog("ANTITRAMPAS", "Búsqueda de sistemas de baneo integrados.", honeypotDump)
        
    end)

    -- ==========================================
    -- 6. MÓDULO LABORATORIO DE INTERCEPCIÓN (DIAGNÓSTICO DE CLICS)
    -- ==========================================
    local UIS = game:GetService("UserInputService")
    local mouse = LocalPlayer:GetMouse()

    LabBtn.MouseButton1Click:Connect(function()
        LabClickActivo = not LabClickActivo
        if LabClickActivo then
            LabBtn.Text = "🧪 5. DIAGNÓSTICO EN CURSO (¡PEGA/PICA ALGO CLICKEANDO!)"
            LabBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            AddLog("LAB", "Laboratorio Activado", "Acércate a una roca/zombie y haz clic. Atraparemos qué evento usa el juego exactamente y veremos por qué está fallando.")
        else
            LabBtn.Text = "🧪 5. LABORATORIO: EXAMINAR ATAQUE/CLIC (DIAGNÓSTICO)"
            LabBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
        end
    end)

    UIS.InputBegan:Connect(function(input, gp)
        if LabClickActivo and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local target = mouse.Target
            local tName = target and target:GetFullName() or "Ninguno"
            
            AddLog("LAB", "Click registrado", "Capturando TODOS los remotos de los próximos 2 segundos (swing + hitbox + combo)...")
            LabClickActivo = false
            LabBtn.Text = "🧪 5. LABORATORIO: EXAMINAR ATAQUE/CLIC (DIAGNÓSTICO)"
            LabBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
            
            task.delay(2.0, function()
                local curTime = tick()
                local report = "🎯 Blanco: " .. tName .. "\n\n"
                
                local foundRemotes = 0
                for _, data in ipairs(NetworkQueue) do
                    -- Capturar TODO lo ocurrido en los 3 segundos anteriores al reporte
                    if curTime - data.Time <= 3 then
                        foundRemotes = foundRemotes + 1
                        report = report .. "✅ VÍA DETECTADA: [" .. data.Method .. "]\n"
                        pcall(function() report = report .. "   - Hacia: " .. data.Obj:GetFullName() .. " ("..data.Obj.ClassName..")\n" end)
                        
                        report = report .. "   - Parámetros Enviados:\n"
                        for i, arg in pairs(data.Args) do
                            local t = typeof(arg)
                            local ex = ""
                            pcall(function() if t=="table" then ex = " | "..HttpService:JSONEncode(arg) end end)
                            pcall(function() if t=="Instance" then ex = " | "..arg:GetFullName() end end)
                            report = report .. "      ["..i.."] = ("..t..") : " .. tostring(arg) .. ex .. "\n"
                        end
                        report = report .. "\n"
                    end
                end
                
                if foundRemotes == 0 then
                    report = report .. "⚠️ NEGATIVO: No se atrapó NINGÚN envío de red en tu clic.\n"
                    report = report .. "🔍 ¿Por qué sucede esto?\n"
                    report = report .. "  -> 1. El daño se envía desde un Script puramente Local (No Remote).\n"
                    report = report .. "  -> 2. Tu herramienta dispara remotos Bindeables antes, la lógica es server-sided con Region3.\n"
                    report = report .. "  -> 3. Estás lejos y el cliente filtra el clic antes de enviarlo por la red.\n"
                    report = report .. "  -> 4. Fallo de Executor: Tu inyector no soporta hookfunction o hooks de UnreliableRemoteEvents.\n"
                else
                    report = report .. "🔥 ÉXITO ABSOLUTO: " .. foundRemotes .. " eventos capturados que puedes usar de forma directa para el hack."
                end
                
                AddLog("LAB-RESULTADO", "Diagnóstico del Ataque Finalizado", report)
            end)
        end
    end)

    -- ==========================================
    -- 7. LIVE MONITOR EN VIVO (RunService Heartbeat)
    -- ==========================================
    local RunService = game:GetService("RunService")
    local mouse = LocalPlayer:GetMouse()
    local liveTimer = 0
    local LiveScanActivo = false
    local NoclipActivo = false

    -- ==========================================
    -- NOCLIP ENGINE (Stepped = ANTES del physics engine, nunca se atora)
    -- ==========================================
    RunService.Stepped:Connect(function()
        if not NoclipActivo then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end)

    RunService.Heartbeat:Connect(function(dt)
        if not LiveScanActivo then 
            LiveLabel.Text = "(Scanner Pausado - Presiona 📡 SCAN para analizar FPS/Objetos)"
            return 
        end
        
        liveTimer = liveTimer + dt
        if liveTimer < 0.2 then return end
        liveTimer = 0

        pcall(function()
            local target = mouse.Target
            if not target or not target.Parent then
                LiveLabel.Text = "(Apunta el mouse\na roca o enemigo)"
                return
            end

            local txt = ""
            local partName = target.Name
            local partPath = ""
            pcall(function() partPath = target:GetFullName() end)
            txt = txt .. "🎯 PARTE: " .. partName .. "\n"
            txt = txt .. "📂 " .. partPath .. "\n"

            -- Atributos directos de la parte
            for k, v in pairs(target:GetAttributes()) do
                txt = txt .. "  🔵 " .. k .. " = " .. tostring(v) .. "\n"
            end

            -- Modelo padre (mobs o rocas)
            local model = target:FindFirstAncestorWhichIsA("Model")
            if model then
                txt = txt .. "\n👾 MODELO: " .. model.Name .. "\n"

                -- HP humanoid (zombies, NPCs)
                local hum = model:FindFirstChildWhichIsA("Humanoid")
                if hum then
                    local pct = math.floor((hum.Health / math.max(hum.MaxHealth, 1)) * 100)
                    txt = txt .. "❤️ HP: " .. string.format("%.0f", hum.Health) .. "/" .. string.format("%.0f", hum.MaxHealth) .. " (" .. pct .. "%)\n"
                    txt = txt .. "🏃 Speed: " .. tostring(hum.WalkSpeed) .. "\n"
                end

                -- Atributos del modelo (rocas: Health, RequiredDamage, etc.)
                for k, v in pairs(model:GetAttributes()) do
                    txt = txt .. "  🟡 " .. k .. " = " .. tostring(v) .. "\n"
                end

                -- Values hijos del modelo
                for _, v in pairs(model:GetChildren()) do
                    if v:IsA("NumberValue") or v:IsA("StringValue") or v:IsA("BoolValue") or v:IsA("IntValue") then
                        txt = txt .. "  💰 " .. v.Name .. " = " .. tostring(v.Value) .. "\n"
                    end
                end
            end

            LiveLabel.Text = txt == "" and "(Sin datos en " .. partName .. ")" or txt
        end)
    end)

    -- ==========================================
    -- 8. AUTOFARM PANEL (dentro del LivePanel)
    -- ==========================================
    local ToolRF = game:GetService("ReplicatedStorage").Shared.Packages.Knit.Services.ToolService.RF.ToolActivated

    local AutoMineActivo = false
    local AutoKillActivo = false
    
    local LiveScanBtn = Instance.new("TextButton")
    LiveScanBtn.Size = UDim2.new(0.5, -6, 0, 30)
    LiveScanBtn.Position = UDim2.new(0, 4, 1, -175)
    LiveScanBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    LiveScanBtn.Text = "📡 LIVE SCAN: OFF"
    LiveScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    LiveScanBtn.Font = Enum.Font.Code
    LiveScanBtn.TextSize = 10
    LiveScanBtn.Parent = LivePanel

    local NoclipBtn = Instance.new("TextButton")
    NoclipBtn.Size = UDim2.new(0.5, -6, 0, 30)
    NoclipBtn.Position = UDim2.new(0.5, 2, 1, -175)
    NoclipBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    NoclipBtn.Text = "👻 NOCLIP: OFF"
    NoclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    NoclipBtn.Font = Enum.Font.Code
    NoclipBtn.TextSize = 11
    NoclipBtn.Parent = LivePanel
    
    LiveScanBtn.MouseButton1Click:Connect(function()
        LiveScanActivo = not LiveScanActivo
        if LiveScanActivo then
            LiveScanBtn.Text = "📡 LIVE SCAN: ON"
            LiveScanBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 80)
        else
            LiveScanBtn.Text = "📡 LIVE SCAN: OFF"
            LiveScanBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end
    end)
    
    NoclipBtn.MouseButton1Click:Connect(function()
        NoclipActivo = not NoclipActivo
        if NoclipActivo then
            NoclipBtn.Text = "👻 NOCLIP: ON"
            NoclipBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 180)
        else
            NoclipBtn.Text = "👻 NOCLIP: OFF"
            NoclipBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            pcall(function() 
                local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if r then r.Anchored = false end 
            end)
        end
    end)

    local ShieldBtn = Instance.new("TextButton")
    ShieldBtn.Size = UDim2.new(1, -8, 0, 30)
    ShieldBtn.Position = UDim2.new(0, 4, 1, -140)
    ShieldBtn.BackgroundColor3 = Color3.fromRGB(20, 100, 160)
    ShieldBtn.Text = "🛡️ MURO TRAMPA (GLITCH ZOMBI)"
    ShieldBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ShieldBtn.Font = Enum.Font.Code
    ShieldBtn.TextSize = 12
    ShieldBtn.Parent = LivePanel

    local HeadshotBtn = Instance.new("TextButton")
    HeadshotBtn.Size = UDim2.new(1, -8, 0, 30)
    HeadshotBtn.Position = UDim2.new(0, 4, 1, -105)
    HeadshotBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    HeadshotBtn.Text = "🎯 AIMBOT CABEZA: OFF"
    HeadshotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    HeadshotBtn.Font = Enum.Font.Code
    HeadshotBtn.TextSize = 11
    HeadshotBtn.Parent = LivePanel

    local KiteBtn = Instance.new("TextButton")
    KiteBtn.Size = UDim2.new(0.5, -6, 0, 30)
    KiteBtn.Position = UDim2.new(0, 4, 1, -70)
    KiteBtn.BackgroundColor3 = Color3.fromRGB(180, 80, 40)
    KiteBtn.Text = "🗡️ FARM MOBS"
    KiteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    KiteBtn.Font = Enum.Font.Code
    KiteBtn.TextSize = 11
    KiteBtn.Parent = LivePanel

    local MineBtn = Instance.new("TextButton")
    MineBtn.Size = UDim2.new(0.5, -6, 0, 30)
    MineBtn.Position = UDim2.new(0.5, 2, 1, -70)
    MineBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 40)
    MineBtn.Text = "⛏️ FARM MINAS"
    MineBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MineBtn.Font = Enum.Font.Code
    MineBtn.TextSize = 11
    MineBtn.Parent = LivePanel

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -8, 0, 28)
    StatusLabel.Position = UDim2.new(0, 4, 1, -34)
    StatusLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    StatusLabel.Text = "Estado: Inactivo..."
    StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    StatusLabel.Font = Enum.Font.Code
    StatusLabel.TextSize = 11
    StatusLabel.TextWrapped = true
    StatusLabel.Parent = LivePanel

    -- Función: encontrar la parte más cercana al jugador que cumpla condición
    local function findNearest(condFn)
        local char = LocalPlayer.Character
        if not char then return nil end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return nil end
        local closest, closestDist = nil, math.huge
        for _, obj in pairs(Workspace:GetDescendants()) do
            if condFn(obj) then
                local p = nil
                pcall(function()
                    local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChildWhichIsA("BasePart")
                    if hrp then
                        p = hrp.Position
                    end
                end)
                if p then
                    local d = (root.Position - p).Magnitude
                    if d < closestDist then
                        closestDist = d
                        closest = obj
                    end
                end
            end
        end
        return closest, closestDist
    end

    -- Función: hacer que el personaje mire hacia una posición
    local function faceTarget(targetPos)
        pcall(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local origin = root.Position
                local lookDir = (Vector3.new(targetPos.X, origin.Y, targetPos.Z) - origin)
                if lookDir.Magnitude > 0.1 then
                    root.CFrame = CFrame.lookAt(origin, origin + lookDir)
                end
            end
        end)
    end

    local ShieldActivo = false
    local MyShield = nil

    ShieldBtn.MouseButton1Click:Connect(function()
        ShieldActivo = not ShieldActivo
        if ShieldActivo then
            ShieldBtn.Text = "🛡️ MURO TRAMPA: ON ✅"
            ShieldBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 180)
            
            MyShield = Instance.new("Part")
            MyShield.Name = "MuroDefensivo"
            -- Restaurado a la medida exacta que genera el Glitch Físico del Agujero en la IA del Zombi
            MyShield.Size = Vector3.new(12, 12, 2) 
            MyShield.Transparency = 0.5
            MyShield.Material = Enum.Material.ForceField
            MyShield.BrickColor = BrickColor.new("Cyan")
            MyShield.Anchored = true
            MyShield.CanCollide = true
            MyShield.Parent = Workspace
            
            task.spawn(function()
                while ShieldActivo and MyShield do
                    pcall(function()
                        local char = LocalPlayer.Character
                        local myRoot = char and char:FindFirstChild("HumanoidRootPart")
                        if myRoot then
                            -- Fasear al jugador para CERO Kicks por TP
                            for _, v in pairs(char:GetDescendants()) do
                                if v:IsA("BasePart") then
                                    local cName = "NCC_" .. v.Name
                                    if not MyShield:FindFirstChild(cName) then
                                        local nc = Instance.new("NoCollisionConstraint")
                                        nc.Name = cName
                                        nc.Part0 = v
                                        nc.Part1 = MyShield
                                        nc.Parent = MyShield
                                    end
                                end
                            end
                            
                            -- Restaurado a como te gustaba: Esto causa que el muro "abrace" el pathing frontal 
                            -- y tuerza al Muro del Zombi forzándolo a dar la espalda eternamente por clip en su hitbox.
                            MyShield.CFrame = myRoot.CFrame * CFrame.new(0, 0, -3.5)
                        end
                    end)
                    task.wait()
                end
            end)
            StatusLabel.Text = "🛡️ Muro original atado a tu pecho. Los Zombis se quedarán atorados de espaldas ("Agujero" Glitch)."
        else
            ShieldBtn.Text = "🛡️ MURO TRAMPA (GLITCH ZOMBI)"
            ShieldBtn.BackgroundColor3 = Color3.fromRGB(20, 100, 160)
            if MyShield then MyShield:Destroy() MyShield = nil end
        end
    end)

    local HeadshotActivo = false
    
    HeadshotBtn.MouseButton1Click:Connect(function()
        HeadshotActivo = not HeadshotActivo
        if HeadshotActivo then
            HeadshotBtn.Text = "🎯 AIMBOT CABEZA: ON ✅"
            HeadshotBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
            StatusLabel.Text = "🎯 Headshot Aimbot configurado. Los ataques automáticos buscarán la cabeza."
        else
            HeadshotBtn.Text = "🎯 AIMBOT CABEZA: OFF"
            HeadshotBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        end
    end)

    local KiteActivo = false
    local MineActivo = false
    local FarmTask = nil

    local function DetenerFarm()
        if not KiteActivo and not MineActivo then
            if FarmTask then task.cancel(FarmTask) FarmTask = nil end
            pcall(function()
                local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if r then r.Anchored = false end
            end)
            StatusLabel.Text = "Estado: Inactivo"
        end
    end

    local function IniciarFarm()
        if FarmTask then return end
        LiveScanActivo = false
        LiveScanBtn.Text = "📡 LIVE SCAN: OFF"
        LiveScanBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        
        FarmTask = task.spawn(function()
            local loopTick = 0
            local zTarget, oreTarget = nil, nil
            local zDist, oDist = math.huge, math.huge

            while KiteActivo or MineActivo do
                pcall(function()
                    local char = LocalPlayer.Character
                    if not char then return end
                    local currentHum = char:FindFirstChild("Humanoid")
                    local myRoot = char:FindFirstChild("HumanoidRootPart")
                    if not myRoot or not currentHum then return end

                    loopTick = loopTick + 1
                    
                    -- ESCANEO OPTIMIZADO (Anti-Lag Extremo 0 FPS Drop):
                    if loopTick % 10 == 0 or not zTarget or (zTarget and not zTarget:FindFirstChildWhichIsA("Humanoid")) or (MineActivo and not oreTarget) then
                        if KiteActivo or MineActivo then
                            zTarget, zDist = findNearest(function(o)
                                if o:IsA("Model") and o ~= char then
                                    local h = o:FindFirstChildWhichIsA("Humanoid")
                                    return h and h.Health > 0 and o:GetAttribute("IsNpc") == true
                                end
                                return false
                            end)
                        end

                        if MineActivo then
                            oreTarget, oDist = findNearest(function(o)
                                if o:IsA("Model") and o ~= char then
                                    local n = string.lower(o.Name)
                                    local h = o:GetAttribute("Health")
                                    if h and h > 0 and (string.find(n, "pebb") or string.find(n, "rock") or string.find(n, "ore")) then
                                        return true
                                    end
                                end
                                return false
                            end)
                        end
                    else
                        -- Solo actualiza las distancias de los que ya encontró (Ahorra un 10,000% de CPU)
                        if zTarget and zTarget.Parent then
                            local zPart = zTarget:FindFirstChild("HumanoidRootPart") or zTarget:FindFirstChild("Torso")
                            if zPart then zDist = (myRoot.Position - zPart.Position).Magnitude else zTarget = nil end
                        else zTarget = nil end

                        if oreTarget and oreTarget.Parent then
                            local oPart = oreTarget:FindFirstChild("HumanoidRootPart") or oreTarget:FindFirstChild("Torso") or oreTarget:FindFirstChildWhichIsA("BasePart")
                            if oPart then oDist = (myRoot.Position - oPart.Position).Magnitude else oreTarget = nil end
                        else oreTarget = nil end
                    end

                    local targetObj = nil
                    local dist = 0
                    local targetDist = 7
                    local mode = "None"
                    local toolId = "weapon"

                    -- PRIORIDAD 1: CAZA PURA (Todo el mapa) O SUPERVIVENCIA
                    if zTarget and (KiteActivo or (MineActivo and zDist < 40)) then
                        targetObj = zTarget
                        dist = zDist
                        targetDist = ShieldActivo and 4 or 7
                        mode = "Combat"
                        toolId = "weapon"
                    -- PRIORIDAD 2: MINADO RUTINARIO
                    elseif oreTarget and MineActivo then
                        targetObj = oreTarget
                        dist = oDist
                        targetDist = 4
                        mode = "Mining"
                        toolId = "pickaxe"
                    end

                    if targetObj then
                        local targetPart = targetObj:FindFirstChild("HumanoidRootPart") or targetObj:FindFirstChild("Torso") or targetObj:FindFirstChildWhichIsA("BasePart")
                        if not targetPart then return end

                        -- == 1. CEREBRO DE HERRAMIENTAS ==
                        local isEquipped = false
                        for _, t in pairs(char:GetChildren()) do
                            if t:IsA("Tool") and string.find(string.lower(t.Name), toolId) then
                                isEquipped = true; break
                            end
                        end

                        if not isEquipped then
                            local bpTools = LocalPlayer.Backpack:GetChildren()
                            local equippedCorrectly = false
                            for _, t in pairs(bpTools) do
                                if string.find(string.lower(t.Name), toolId) then
                                    currentHum:EquipTool(t)
                                    equippedCorrectly = true; break
                                end
                            end
                            if not equippedCorrectly and #bpTools > 0 then
                                if toolId == "pickaxe" then
                                    currentHum:EquipTool(bpTools[1])
                                elseif #bpTools >= 2 then
                                    currentHum:EquipTool(bpTools[2])
                                else
                                    currentHum:EquipTool(bpTools[1])
                                end
                            end
                        end

                        -- == 2. NOCLIP Y PATHING V2 ==
                        if dist > targetDist then
                            if NoclipActivo then
                                -- Modo Fantasma: BodyVelocity directo, sin Anchored, nunca se atora
                                myRoot.Anchored = false
                                local bv = myRoot:FindFirstChild("_NoclipBV")
                                if not bv then
                                    bv = Instance.new("BodyVelocity")
                                    bv.Name = "_NoclipBV"
                                    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                                    bv.Parent = myRoot
                                end
                                local speed = currentHum.WalkSpeed or 16
                                local dir = (targetPart.Position - myRoot.Position).Unit
                                bv.Velocity = dir * speed * 2.5
                                -- Rotar el personaje hacia el objetivo
                                myRoot.CFrame = CFrame.new(myRoot.Position, myRoot.Position + Vector3.new(dir.X, 0, dir.Z))
                            else
                                -- Limpiar BodyVelocity si Noclip se apagó
                                local bv = myRoot:FindFirstChild("_NoclipBV")
                                if bv then bv:Destroy() end
                                myRoot.Anchored = false
                                currentHum:MoveTo(targetPart.Position)
                            end
                        else
                            -- En rango: parar BodyVelocity, desanclar para golpear
                            local bv = myRoot:FindFirstChild("_NoclipBV")
                            if bv then bv.Velocity = Vector3.zero end
                            myRoot.Anchored = false
                            currentHum:MoveTo(myRoot.Position)
                        end

                        -- == 3. GOLPE SENSORIAL ==
                        local lookTarget = Vector3.new(targetPart.Position.X, myRoot.Position.Y, targetPart.Position.Z)
                        myRoot.CFrame = CFrame.lookAt(myRoot.Position, lookTarget)
                        local serverArg = mode == "Mining" and "Pickaxe" or "Weapon"

                        -- ROOT DESANCLADO: Ataque totalmente válido para el servidor
                        if dist <= targetDist + 1.5 then
                            if mode == "Combat" and HeadshotActivo then
                                local head = targetObj:FindFirstChild("Head") or targetPart
                                local snapOrigin = myRoot.CFrame
                                myRoot.CFrame = CFrame.lookAt(myRoot.Position, head.Position)
                                ToolRF:InvokeServer(serverArg)
                                myRoot.CFrame = snapOrigin
                            else
                                ToolRF:InvokeServer(serverArg)
                            end
                            StatusLabel.Text = (mode == "Mining" and "⛏️ Picando: " or "🗡️ Atacando: ") .. targetObj.Name .. " (" .. tostring(math.floor(dist)) .. "m)"
                        else
                            StatusLabel.Text = (mode == "Mining" and "🏃 Acercándose a Mina: " or "🏃 Cazando a: ") .. targetObj.Name .. " (" .. tostring(math.floor(dist)) .. "m)"
                        end
                    else
                        StatusLabel.Text = "🗡️/⛏️ Buscando objetivo por el mapa..."
                    end
                end)
                task.wait()
            end
            DetenerFarm()
        end)
    end

    KiteBtn.MouseButton1Click:Connect(function()
        KiteActivo = not KiteActivo
        if KiteActivo then
            KiteBtn.Text = "🗡️ FARM MOBS: ON"
            KiteBtn.BackgroundColor3 = Color3.fromRGB(220, 130, 40)
            IniciarFarm()
        else
            KiteBtn.Text = "🗡️ FARM MOBS"
            KiteBtn.BackgroundColor3 = Color3.fromRGB(180, 80, 40)
            DetenerFarm()
        end
    end)

    MineBtn.MouseButton1Click:Connect(function()
        MineActivo = not MineActivo
        if MineActivo then
            MineBtn.Text = "⛏️ FARM MINAS: ON"
            MineBtn.BackgroundColor3 = Color3.fromRGB(120, 220, 40)
            IniciarFarm()
        else
            MineBtn.Text = "⛏️ FARM MINAS"
            MineBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 40)
            DetenerFarm()
        end
    end)

    -- ==========================================
    -- 9. ANALIZADOR DE EXPLOITS AVANZADO (BUGS DE COMBATE NPC)
    -- ==========================================
    ExploitBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(LogScroll:GetChildren()) do
            if v:IsA("Frame") then v:Destroy() end
        end
        AddLog("☠️ EXPLOIT", "Iniciando análisis de vulnerabilidades de combate NPC...", "Buscando 10+ vectores de ataque. Asegúrate de estar cerca de un zombi.")
        task.wait(0.3)

        -- Buscar un mob de muestra
        local mob = nil
        local mobRoot = nil
        local mobHum = nil
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= LocalPlayer.Character and not Players:GetPlayerFromCharacter(obj) then
                local h = obj:FindFirstChildWhichIsA("Humanoid")
                local r = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                if h and h.Health > 0 and r then
                    mob = obj
                    mobRoot = r
                    mobHum = h
                    break
                end
            end
        end

        if not mob then
            AddLog("⚠️ ERROR", "No se encontró ningún mob vivo en el mapa.", "Acércate a un zombi y vuelve a escanear.")
            return
        end

        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local distToMob = myRoot and (myRoot.Position - mobRoot.Position).Magnitude or 9999

        AddLog("🧟 MOB OBJETIVO", mob.Name .. " | HP: " .. tostring(math.floor(mobHum.Health)) .. "/" .. tostring(math.floor(mobHum.MaxHealth)) .. " | Distancia: " .. tostring(math.floor(distToMob)) .. "m", "Comenzando análisis en este objetivo...")

        -- ============================================================
        -- VECTOR 1: MUTABILIDAD DE ATRIBUTOS (El Bug Más Grande Posible)
        -- ============================================================
        local v1 = "====== [V1] MUTABILIDAD DE ATRIBUTOS ======\n"
        local attrs = mob:GetAttributes()
        if next(attrs) ~= nil then
            v1 = v1 .. "✅ El mob TIENE atributos acccesibles:\n"
            for k, val in pairs(attrs) do
                v1 = v1 .. "   🔵 " .. k .. " = (" .. typeof(val) .. ") " .. tostring(val) .. "\n"
            end
            -- Intentar mutar Health directamente
            local ok, err = pcall(function() mob:SetAttribute("Health", 0) end)
            v1 = v1 .. "\n🔥 INTENTO de mob:SetAttribute('Health', 0): " .. (ok and "✅ EXITOSO (el servidor puede no validar esto)" or "❌ BLOQUEADO: " .. tostring(err)) .. "\n"
            -- Intentar convertir en piedra
            local okClass, errC = pcall(function() mob:SetAttribute("IsNpc", false) mob:SetAttribute("IsMob", false) end)
            v1 = v1 .. "🧱 INTENTO de cambiar IsNpc/IsMob a false (Camuflaje como piedra): " .. (okClass and "✅ EJECUTADO (testea si el zombi deja de atacarte)" or "❌ Bloqueado") .. "\n"
        else
            v1 = v1 .. "❌ El mob no tiene atributos accesibles localmente. Daño manejado por el servidor puro.\n"
        end
        AddLog("V1", "Mutabilidad de Atributos", v1)

        -- ============================================================
        -- VECTOR 2: DETECCIÓN DE SCRIPT DE DAÑO EXPUESTO
        -- ============================================================
        task.wait(0.1)
        local v2 = "====== [V2] SCRIPT DE DAÑO LOCAL ======\n"
        local damageScripts = {}
        for _, s in pairs(mob:GetDescendants()) do
            if s:IsA("Script") or s:IsA("LocalScript") or s:IsA("ModuleScript") then
                table.insert(damageScripts, s:GetFullName() .. " [" .. s.ClassName .. "]")
            end
        end
        if #damageScripts > 0 then
            v2 = v2 .. "🔥 Scripts DENTRO del mob (potencialmente explotables):\n"
            for _, s in pairs(damageScripts) do v2 = v2 .. "   - " .. s .. "\n" end
            v2 = v2 .. "\n💡 OPORTUNIDAD: Si hay un LocalScript con 'Damage' o 'Attack', puede ser deshabilitado con script:Disable().\n"
        else
            v2 = v2 .. "✅ Sin scripts locales expuestos. El daño viene del servidor con Raycast/Region3.\n"
        end
        AddLog("V2", "Scripts de daño dentro del mob", v2)

        -- ============================================================  
        -- VECTOR 3: ANÁLISIS DE VALIDACIÓN DE DIRECCIÓN (¿Necesitas estar enfrente?)
        -- ============================================================
        task.wait(0.1)
        local v3 = "====== [V3] VALIDACIÓN DE DIRECCIÓN ======\n"
        v3 = v3 .. "📐 Tu posición relativa al mob:\n"
        if myRoot then
            local toMob = (mobRoot.Position - myRoot.Position).Unit
            local myLook = myRoot.CFrame.LookVector
            local dot = toMob:Dot(myLook)
            v3 = v3 .. "   Dot Product (1=frente, -1=espalda): " .. string.format("%.2f", dot) .. "\n"
            v3 = v3 .. "   Tu orientación respecto al mob: " .. (dot > 0.5 and "MIRÁNDOLO" or dot < -0.5 and "DANDOLE LA ESPALDA" or "LATERAL") .. "\n\n"
            v3 = v3 .. "🔍 PREGUNTA CLAVE: ¿El servidor valida que mires al mob para que el daño cuente?\n"
            v3 = v3 .. "💡 MÉTODO DE TEST: Usa el Interceptor de Red y ataca desde atrás del mob. Si el remote se envía y el mob baja HP, NO valida dirección.\n"
            v3 = v3 .. "💡 Si NO baja HP atacando de espaldas al mob, el servidor usa CFrame.LookVector delta < 90° como requisito.\n"
        end
        AddLog("V3", "Validación de dirección para hacer daño", v3)

        -- ============================================================
        -- VECTOR 4: SISTEMA DE KNOCKBACK (¿El empuje es explotable?)
        -- ============================================================
        task.wait(0.1)
        local v4 = "====== [V4] KNOCKBACK Y EMPUJE ======\n"
        -- Buscar BodyVelocity / BodyForce en el mob
        local hasPhysicsObjects = false
        for _, v in pairs(mob:GetDescendants()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyForce") or v:IsA("LinearVelocity") then
                hasPhysicsObjects = true
                v4 = v4 .. "🔥 PHYSICS OBJECT ENCONTRADO: " .. v:GetFullName() .. " [" .. v.ClassName .. "]\n"
                if v:IsA("BodyVelocity") then
                    v4 = v4 .. "   Velocidad actual: " .. tostring(v.Velocity) .. "\n"
                    v4 = v4 .. "   MaxForce: " .. tostring(v.MaxForce) .. "\n"
                    v4 = v4 .. "   💡 EXPLOIT: Si puedes acceder a este objeto, puedes empujarlo con: v.Velocity = Vector3.new(0,0,100)\n"
                end
            end
        end
        if not hasPhysicsObjects then
            v4 = v4 .. "❌ Sin BodyVelocity expuesto. El knockback se maneja por el servidor al aplicar impulso con AssemblyLinearVelocity.\n"
        end
        -- Intentar empujar el mob directamente
        local okPush, errPush = pcall(function()
            if mobRoot then
                mobRoot.AssemblyLinearVelocity = (mobRoot.Position - myRoot.Position).Unit * (-20)
            end
        end)
        v4 = v4 .. "\n🔥 INTENTO de empujar mob con AssemblyLinearVelocity: " .. (okPush and "✅ EJECUTADO (si el mob se movió, es explotable)" or "❌ Bloqueado: " .. tostring(errPush)) .. "\n"
        AddLog("V4", "Knockback y empuje forzado del mob", v4)

        -- ============================================================
        -- VECTOR 5: ROTACIÓN FORZADA (Hacerlo dar la espalda)
        -- ============================================================
        task.wait(0.1)
        local v5 = "====== [V5] ROTACIÓN FORZADA DEL MOB ======\n"
        if myRoot then
            local behindPos = myRoot.Position + myRoot.CFrame.LookVector * 5
            local okRotate, errR = pcall(function()
                -- Intentar rotar el mob para que mire HACIA ATRÁS de ti
                mobRoot.CFrame = CFrame.new(mobRoot.Position, Vector3.new(myRoot.Position.X, mobRoot.Position.Y, myRoot.Position.Z) + myRoot.CFrame.LookVector * 100)
            end)
            v5 = v5 .. "🔄 INTENTO de rotar mob para que dé la espalda: " .. (okRotate and "✅ EXITOSO (si se giró, el servidor no protege el CFrame del mob)" or "❌ Bloqueado: " .. tostring(errR)) .. "\n"
            if okRotate then
                v5 = v5 .. "💡 VENTAJA MASIVA: Puedes mantener al mob mirando en dirección opuesta con un loop en el Farm.\n"
                v5 = v5 .. "   Código a integrar: mobRoot.CFrame = CFrame.lookAt(mobRoot.Position, awayPos)\n"
            else
                v5 = v5 .. "💡 El servidor protege el CFrame del mob. Usa el Muro Trampa como alternativa física.\n"
            end
        end
        AddLog("V5", "Rotación forzada (CFrame hijack del mob)", v5)

        -- ============================================================
        -- VECTOR 6: DETECCIÓN DE TOUCHINTEREST (Explosión de contacto)
        -- ============================================================
        task.wait(0.1)
        local v6 = "====== [V6] TOUCHINTEREST Y DAÑO POR CONTACTO ======\n"
        local touchParts = {}
        for _, part in pairs(mob:GetDescendants()) do
            if part:IsA("BasePart") then
                local tt = part:FindFirstChildWhichIsA("TouchTransmitter")
                if tt then
                    table.insert(touchParts, part)
                    v6 = v6 .. "🔥 PARTE CON TOUCH: " .. part:GetFullName() .. " | Size: " .. tostring(part.Size) .. "\n"
                    -- Este es el vector de ataque: si el mob usa Touch para detectar impactos
                    v6 = v6 .. "   💡 EXPLOIT A: firetouchinterest(LocalPlayer.Character.HumanoidRootPart, part, 0)\n"
                    v6 = v6 .. "   💡 EXPLOIT B: Desactiva el TouchTransmitter: tt:Destroy() -> El mob deja de detectar tu toque y no te hace daño\n"
                end
            end
        end
        if #touchParts == 0 then
            v6 = v6 .. "❌ Sin TouchInterest expuesto. El mob usa Raycast o OverlapParams server-side para detectar colisiones.\n"
            v6 = v6 .. "💡 Opción: Si el mob usa un HitboxPart (zona de daño), podemos sacarlo del workspace localmente.\n"
        end
        AddLog("V6", "TouchInterest - Daño por contacto y desactivación", v6)

        -- ============================================================
        -- VECTOR 7: ANÁLISIS DE BRAZOS Y HITBOX DE ATAQUE
        -- ============================================================
        task.wait(0.1)
        local v7 = "====== [V7] BRAZOS, RANGO Y HITBOX DE ATAQUE ======\n"
        local attackParts = {}
        for _, part in pairs(mob:GetDescendants()) do
            if part:IsA("BasePart") then
                local n = string.lower(part.Name)
                if string.find(n, "arm") or string.find(n, "hand") or string.find(n, "weapon") or string.find(n, "attack") or string.find(n, "hit") then
                    table.insert(attackParts, part)
                    v7 = v7 .. "⚔️ PARTE DE ATAQUE: " .. part.Name .. " | Size: " .. tostring(part.Size) .. " | CanCollide: " .. tostring(part.CanCollide) .. "\n"
                    
                    -- INTENTO 1: Destruir localmente el brazo atacante
                    local okDestroy = pcall(function() part.CanCollide = false part.Size = Vector3.new(0.1, 0.1, 0.1) end)
                    v7 = v7 .. "   📐 Intento de reducir brazo a 0.1x: " .. (okDestroy and "✅ EXITOSO (el hitbox del brazo se redujo localmente)" or "❌ Bloqueado") .. "\n"
                end
            end
        end
        if #attackParts == 0 then
            v7 = v7 .. "❌ No se encontraron partes de ataque nombradas explícitamente.\n"
            v7 = v7 .. "💡 El juego usa Raycast desde el HumanoidRootPart del mob con un radio fijo (probablemente 5-8 studs).\n"
            v7 = v7 .. "💡 Si el Muro (12x12x2) te mantiene a 3.5 studs del mob, aún entras dentro de su radio de 5-8 studs.\n"
            v7 = v7 .. "💡 SOLUCIÓN: Aumenta el offset del muro de 3.5 a 5.5-6.0 studs para quedar fuera del radio de golpe.\n"
        else
            v7 = v7 .. "📊 Total partes de ataque encontradas: " .. #attackParts .. "\n"
        end
        AddLog("V7", "Hitbox de brazos y rango de ataque del mob", v7)

        -- ============================================================
        -- VECTOR 8: DESACTIVAR AI/PATHFINDING
        -- ============================================================
        task.wait(0.1)
        local v8 = "====== [V8] CONTROL DE IA / PATHFINDING ======\n"
        -- Buscar PathfindingService connections
        local aiScripts = {}
        for _, s in pairs(mob:GetDescendants()) do
            if s:IsA("Script") and (string.find(string.lower(s.Name), "ai") or string.find(string.lower(s.Name), "path") or string.find(string.lower(s.Name), "move") or string.find(string.lower(s.Name), "chase")) then
                table.insert(aiScripts, s:GetFullName())
            end
        end
        v8 = v8 .. "Scripts de AI encontrados: " .. (#aiScripts > 0 and table.concat(aiScripts, "\n  ") or "Ninguno visible del lado cliente") .. "\n\n"
        
        -- Intentar pausar el humanoid (trick clásico)
        local okFreeze, errF = pcall(function()
            mobHum.WalkSpeed = 0
            mobHum.JumpPower = 0
        end)
        v8 = v8 .. "❄️ INTENTO de congelar mob (WalkSpeed=0): " .. (okFreeze and "✅ EXITOSO (si el mob se paró, el servidor no valida WalkSpeed)" or "❌ Bloqueado: " .. tostring(errF)) .. "\n"
        
        local okDisable, errD = pcall(function()
            mobHum:ChangeState(Enum.HumanoidStateType.Disabled)
        end)
        v8 = v8 .. "🔒 INTENTO de ChangeState(Disabled): " .. (okDisable and "✅ EJECUTADO" or "❌ Bloqueado: " .. tostring(errD)) .. "\n"
        AddLog("V8", "Control de IA y pathfinding del mob", v8)

        -- ============================================================
        -- VECTOR 9: ANÁLISIS DE VALORES OCULTOS (Health Values, Invulnerability Flags)
        -- ============================================================
        task.wait(0.1)
        local v9 = "====== [V9] FLAGS DE INVULNERABILIDAD ======\n"
        for _, child in pairs(mob:GetDescendants()) do
            if child:IsA("BoolValue") or child:IsA("NumberValue") or child:IsA("IntValue") or child:IsA("StringValue") then
                local n = string.lower(child.Name)
                local suspicious = string.find(n, "invul") or string.find(n, "immune") or string.find(n, "god") or string.find(n, "protect") or string.find(n, "dead") or string.find(n, "alive") or string.find(n, "stun")
                local prefix = suspicious and "🚨 [SOSPECHOSO]" or "   "
                v9 = v9 .. prefix .. " " .. child.Name .. " = " .. tostring(child.Value) .. " (" .. child.ClassName .. ")\n"
            end
        end
        if v9 == "====== [V9] FLAGS DE INVULNERABILIDAD ======\n" then
            v9 = v9 .. "No se encontraron Values simples dentro del mob. Los flags de invulnerabilidad son server-side puros.\n"
        end
        AddLog("V9", "Flags de Invulnerabilidad e Inmunidad", v9)

        -- ============================================================
        -- VECTOR 10: RECOMENDACIONES FINALES AUTOMÁTICAS
        -- ============================================================
        task.wait(0.1)
        local v10 = "====== [V10] RECOMENDACIONES RÁPIDAS ======\n\n"
        v10 = v10 .. "Basado en el análisis de " .. mob.Name .. ":\n\n"
        if #touchParts > 0 then
            v10 = v10 .. "🥇 TouchInterest encontrado: destruye el TouchTransmitter del mob para anular su daño.\n"
        end
        v10 = v10 .. "🥇 Muro offset sugerido: CFrame.new(0,0,-6.5) en lugar de -3.5 para melee largo.\n"
        v10 = v10 .. "🥈 Si V5 EXITOSO: rotar mob con cada golpe en Farm Loop.\n"
        v10 = v10 .. "🥉 Si V7 EXITOSO: arm.Size = Vector3.new(0.1,0.1,0.1) en loop.\n"
        AddLog("V10", "Recomendaciones Rápidas Pre-Red", v10)

        -- ============================================================
        -- VECTOR 11: INVENTARIO DE REMOTES DE COMBATE
        -- ============================================================
        task.wait(0.1)
        local v11 = "====== [V11] REMOTES DE COMBATE ENCONTRADOS ======\n"
        local combatRemotes = {}
        for _, rem in pairs(game:GetDescendants()) do
            if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") or rem:IsA("UnreliableRemoteEvent") then
                local n = string.lower(rem.Name)
                if string.find(n,"damage") or string.find(n,"hit") or string.find(n,"hurt") or
                   string.find(n,"attack") or string.find(n,"combat") or string.find(n,"health") or
                   string.find(n,"hp") or string.find(n,"mob") or string.find(n,"enemy") or
                   string.find(n,"kill") or string.find(n,"death") or string.find(n,"tool") or
                   string.find(n,"weapon") or string.find(n,"swing") or string.find(n,"ability") then
                    table.insert(combatRemotes, rem)
                    v11 = v11 .. "🎯 [" .. rem.ClassName .. "] " .. rem:GetFullName() .. "\n"
                end
            end
        end
        v11 = v11 .. "\nTotal: " .. #combatRemotes .. (
            #combatRemotes == 0 and "\n⚠️ Sin remotes con nombre obvio. El juego usa nombres genéricos. Usa Interceptor." or ""
        )
        AddLog("V11", "Catálogo de Remotes de Combate", v11)

        -- ============================================================
        -- VECTOR 12: CAPTURA FORENSE EN VIVO (3s de combate real)
        -- ============================================================
        task.wait(0.1)
        AddLog("V12", "🔴 CAPTURA EN VIVO ACTIVA (3 segundos)", "Atacando al mob automáticamente. Capturando TODOS los paquetes C→S y S→C. Espera...")
        task.wait(0.4)

        local capturedPackets = {}
        local capturedIncoming = {}
        local captureActive = true
        local captureStart = tick()
        local remoteGroups = {}

        -- Hook C→S
        local captureHook
        pcall(function()
            captureHook = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                local method = string.lower(tostring(getnamecallmethod()))
                if captureActive and (method == "fireserver" or method == "invokeserver") then
                    pcall(function()
                        local args = {...}
                        local name, fullPath = "?", "?"
                        pcall(function() name = self.Name fullPath = self:GetFullName() end)
                        local nLow = string.lower(name)
                        if not string.find(nLow,"mouse") and not string.find(nLow,"camera") then
                            table.insert(capturedPackets, {
                                t = tick() - captureStart, name = name,
                                path = fullPath, class = self.ClassName,
                                args = args, remote = self
                            })
                        end
                    end)
                end
                return captureHook(self, ...)
            end))
        end)

        -- Muestreo HP durante ataque
        local hpBefore = mobHum.Health
        local hpSamples = {{t=0, hp=hpBefore}}

        task.spawn(function()
            local endT = tick() + 3
            while tick() < endT and captureActive do
                pcall(function()
                    local myR = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if myR and mobRoot then
                        local lk = Vector3.new(mobRoot.Position.X, myR.Position.Y, mobRoot.Position.Z)
                        myR.CFrame = CFrame.lookAt(myR.Position, lk)
                    end
                    ToolRF:InvokeServer("Weapon")
                end)
                pcall(function() table.insert(hpSamples, {t=tick()-captureStart, hp=mobHum.Health}) end)
                task.wait(0.15)
            end
        end)

        task.wait(3.2)
        captureActive = false

        -- Agrupar remotes
        for _, pkt in ipairs(capturedPackets) do
            if not remoteGroups[pkt.name] then remoteGroups[pkt.name] = {} end
            table.insert(remoteGroups[pkt.name], pkt)
        end

        -- ============================================================
        -- VECTOR 13: ANÁLISIS HP FORENSE
        -- ============================================================
        local hpAfter = mobHum.Health
        local hpDropped = hpBefore - hpAfter
        local v13 = "====== [V13] ANÁLISIS HP DURANTE COMBATE ======\n"
        v13 = v13 .. "HP antes: " .. string.format("%.1f", hpBefore) .. " | HP después: " .. string.format("%.1f", hpAfter) .. "\n"
        v13 = v13 .. "Daño total (3s): " .. string.format("%.1f", hpDropped) .. " | DPS: " .. string.format("%.2f", hpDropped/3) .. "\n\n"
        v13 = v13 .. "📈 Curva de daño:\n"
        for i, s in ipairs(hpSamples) do
            if i > 1 then
                local delta = hpSamples[i-1].hp - s.hp
                if delta > 0 then
                    v13 = v13 .. "   t+" .. string.format("%.1f", s.t) .. "s → HP " .. string.format("%.0f", s.hp) .. " (-" .. string.format("%.1f", delta) .. ")\n"
                end
            end
        end
        if hpDropped <= 0 then
            v13 = v13 .. "\n⚠️ DAÑO NULO: ToolRF no conecta con este mob. Busca el remote correcto en V14.\n"
        else
            v13 = v13 .. "\n✅ ToolRF es el canal válido. " .. string.format("%.1f", hpDropped) .. " HP quitados.\n"
        end
        AddLog("V13", "Curva HP forense en tiempo real", v13)

        -- ============================================================
        -- VECTOR 14: DECODIFICACIÓN DE PAQUETES C→S
        -- ============================================================
        task.wait(0.1)
        local v14 = "====== [V14] PAQUETES C→S DURANTE COMBATE ======\n"
        v14 = v14 .. "Total capturados: " .. #capturedPackets .. "\n\n"

        for remoteName, pkts in pairs(remoteGroups) do
            v14 = v14 .. "📡 [" .. pkts[1].class .. "] " .. remoteName .. " × " .. #pkts .. "\n"
            v14 = v14 .. "   Path: " .. pkts[1].path .. "\n"
            v14 = v14 .. "   📦 Args de muestra:\n"
            for i, arg in ipairs(pkts[1].args) do
                local t = typeof(arg)
                local extra = ""
                pcall(function()
                    if t=="Instance" then extra=" → "..arg:GetFullName()
                    elseif t=="table" then extra=" → "..HttpService:JSONEncode(arg)
                    elseif t=="CFrame" then extra=" pos="..tostring(arg.Position) end
                end)
                v14 = v14 .. "      ["..i.."] ("..t..") "..tostring(arg)..extra.."\n"
            end
            if #pkts >= 2 then
                local intv = (pkts[#pkts].t - pkts[1].t) / math.max(1, #pkts-1)
                v14 = v14 .. "   ⏱️ Rate: "..string.format("%.1f", 1/intv).."/s\n"
            end
            v14 = v14 .. "\n"
        end

        if #capturedPackets == 0 then
            v14 = v14 .. "⚠️ CERO paquetes. Posibles causas:\n"
            v14 = v14 .. "  → Executor sin hookmetamethod\n  → Usa botón 2 INTERCEPTOR + ataca manualmente\n"
        end
        AddLog("V14", "Decodificación C→S (Cliente al Servidor)", v14)

        -- ============================================================
        -- VECTOR 15: PAQUETES S→C (Servidor al Cliente)
        -- ============================================================
        task.wait(0.1)
        local v15 = "====== [V15] PAQUETES S→C (SERVIDOR → CLIENTE) ======\n"
        v15 = v15 .. "Capturados: " .. #capturedIncoming .. "\n\n"
        if #capturedIncoming == 0 then
            v15 = v15 .. "ℹ️ Sin paquetes S→C. El juego sincroniza HP via Humanoid.Health replication automática de Roblox.\n"
            v15 = v15 .. "💡 Usa Live Scan apuntando al mob para ver HP en tiempo real sin eventos.\n"
        else
            for _, pkt in ipairs(capturedIncoming) do
                v15 = v15 .. "📥 [+"..string.format("%.2f", pkt.t).."s] "..pkt.name.." → "..pkt.path.."\n"
                for i, arg in ipairs(pkt.args) do
                    local t = typeof(arg)
                    local extra = ""
                    pcall(function()
                        if t=="number" and arg>0 and arg<10000 then extra=" ← ¿HP/Daño?" end
                        if t=="Instance" then extra=" → "..arg:GetFullName() end
                    end)
                    v15 = v15 .. "   ["..i.."] ("..t..") "..tostring(arg)..extra.."\n"
                end
            end
        end
        AddLog("V15", "Decodificación S→C (Servidor al Cliente)", v15)

        -- ============================================================
        -- VECTOR 16: REPLAY Y AMPLIFICACIÓN DE DAÑO
        -- ============================================================
        task.wait(0.1)
        local v16 = "====== [V16] REPLAY Y AMPLIFICACIÓN DE DAÑO ======\n"
        local bestRemote, bestCount, bestArgs = nil, 0, nil
        for _, pkts in pairs(remoteGroups) do
            if #pkts > bestCount then
                bestCount = #pkts
                bestRemote = pkts[1].remote
                bestArgs = pkts[1].args
            end
        end

        if bestRemote then
            v16 = v16 .. "🎯 Remote más frecuente: " .. bestRemote.Name .. " ×" .. bestCount .. "\n"
            v16 = v16 .. "💥 Ejecutando REPLAY ×5 en ráfaga...\n\n"
            local hpPre = mobHum.Health
            local ok5 = 0
            for i = 1, 5 do
                local ok = pcall(function()
                    if bestRemote:IsA("RemoteFunction") then bestRemote:InvokeServer(table.unpack(bestArgs))
                    else bestRemote:FireServer(table.unpack(bestArgs)) end
                end)
                if ok then ok5 = ok5 + 1 end
                task.wait(0.04)
            end
            task.wait(0.3)
            local hpPost = mobHum.Health
            local dmgReplay = hpPre - hpPost
            v16 = v16 .. "Replays: "..ok5.."/5 | Daño replay: "..string.format("%.1f", dmgReplay).."\n"
            if dmgReplay > 0 then
                v16 = v16 .. "\n🔥🔥 MEGA-EXPLOIT: Servidor sin rate-limit! Puedes spamear el remote.\n"
                v16 = v16 .. "   Remote: " .. bestRemote:GetFullName() .. "\n"
                v16 = v16 .. "   → Integra loop de replay en Farm para ×10 DPS.\n"
            elseif ok5 > 0 then
                v16 = v16 .. "\n🔒 Rate-limit activo. Spam bloqueado pero remote es válido.\n"
            end
        else
            v16 = v16 .. "❌ No se capturó ningún remote para replay.\n"
            v16 = v16 .. "💡 Usa el Interceptor (botón 2) manualmente y ataca para identificar el remote.\n"
        end
        AddLog("V16", "Replay / Rate-Limit Test", v16)

        -- ============================================================
        -- VECTOR 17: RESUMEN FORENSE TOTAL
        -- ============================================================
        task.wait(0.1)
        local v17 = "====== [V17] RESUMEN FORENSE COMPLETO ======\n\n"
        v17 = v17 .. "🎮 Mob: " .. mob.Name .. "\n"
        v17 = v17 .. "📦 Paquetes C→S: " .. #capturedPackets .. "\n"
        v17 = v17 .. "📥 Paquetes S→C: " .. #capturedIncoming .. "\n"
        v17 = v17 .. "💥 Daño real en 3s: " .. string.format("%.1f", hpDropped) .. " HP\n"
        local rCount = 0 for _ in pairs(remoteGroups) do rCount=rCount+1 end
        v17 = v17 .. "🎯 Remotes únicos C→S: " .. rCount .. "\n\n"
        v17 = v17 .. "HALLAZGOS:\n"
        v17 = v17 .. (hpDropped>0 and "   ✅ ToolRF hace daño confirmado\n" or "   ❌ ToolRF no válido - buscar remote alternativo\n")
        v17 = v17 .. (#capturedPackets>0 and "   ✅ Red capturada - ver V14\n" or "   ⚠️ Red no capturada - usar INTERCEPTOR manual\n")
        v17 = v17 .. (#touchParts>0 and "   🔥 TouchInterest explotable (V6)\n" or "")
        v17 = v17 .. (#attackParts>0 and "   🔥 Brazos manipulables (V7)\n" or "")
        v17 = v17 .. "\nPRÓXIMOS PASOS:\n"
        v17 = v17 .. "   1. V16 EXITOSO → loop spam del remote en Farm\n"
        v17 = v17 .. "   2. V6 EXITOSO → destruir TouchTransmitter en loop\n"
        v17 = v17 .. "   3. V5 EXITOSO → rotar mob con cada golpe\n"
        v17 = v17 .. "   4. Interceptor + Lab juntos para captura manual completa\n"
        AddLog("V17", "🏁 RESUMEN FORENSE (17 Vectores)", v17)
        AddLog("✅ FIN", "Análisis Completo - " .. mob.Name, "17 vectores + red forense analizados. Presiona COPY en cada sección para exportar al clipboard.")
    end)

