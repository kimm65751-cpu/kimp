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
    ExploitBtn.BackgroundColor3 = Color3.fromRGB(160, 10, 10)
    ExploitBtn.Text = "☠️ 7. EXPLOIT FORENSE TOTAL (MOBS + RED)"
    ExploitBtn.TextColor3 = Color3.fromRGB(255, 240, 80)
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

    -- =====================================================
    -- ANALIZADOR FORENSE TOTAL - 17 VECTORES
    -- =====================================================
    ExploitBtn.MouseButton1Click:Connect(function()
        ExploitBtn.Text = "☠️ ANALIZANDO... (~5s)"
        ExploitBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 0)
        task.wait(0.1)
        for _, v in pairs(LogScroll:GetChildren()) do
            if v:IsA("Frame") then v:Destroy() end
        end

        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local mob, mobRoot, mobHum, closestD = nil, nil, nil, math.huge
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= myChar and not Players:GetPlayerFromCharacter(obj) then
                local h = obj:FindFirstChildWhichIsA("Humanoid")
                local r = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                if h and h.Health > 0 and r then
                    local d = myRoot and (myRoot.Position - r.Position).Magnitude or 9999
                    if d < closestD then closestD = d; mob = obj; mobRoot = r; mobHum = h end
                end
            end
        end

        if not mob then
            AddLog("⚠️", "Sin mob vivo cerca", "Acercate a un zombi y reintenta.")
            ExploitBtn.Text = "☠️ 7. EXPLOIT FORENSE TOTAL (MOBS + RED)"
            ExploitBtn.BackgroundColor3 = Color3.fromRGB(160, 10, 10)
            return
        end

        AddLog("🧟 MOB", mob.Name.." | HP:"..math.floor(mobHum.Health).."/"..math.floor(mobHum.MaxHealth).." | Dist:"..math.floor(closestD).."m", "Iniciando 17 vectores...")

        local touchParts, attackParts = {}, {}

        -- V1: Mutabilidad Atributos
        local v1, attrs = "", mob:GetAttributes()
        if next(attrs) then
            v1 = "Atributos accesibles:\n"
            for k,val in pairs(attrs) do v1=v1.."  "..k.." = "..tostring(val).." ("..typeof(val)..")\n" end
            local ok1 = pcall(function() mob:SetAttribute("Health",0) end)
            local ok2 = pcall(function() mob:SetAttribute("IsNpc",false) end)
            v1=v1.."\nSetAttribute Health=0: "..(ok1 and "EXITOSO (posible 1-shot)" or "Bloqueado")
            v1=v1.."\nSetAttribute IsNpc=false: "..(ok2 and "EJECUTADO" or "Bloqueado")
        else v1 = "Sin atributos locales. Dano server-side puro." end
        AddLog("V1", "Mutabilidad de Atributos", v1); task.wait(0.05)

        -- V2: Scripts dentro del mob
        local v2, dsc = "", 0
        for _,s in pairs(mob:GetDescendants()) do
            if s:IsA("Script") or s:IsA("LocalScript") or s:IsA("ModuleScript") then
                v2=v2.."["..s.ClassName.."] "..s:GetFullName().."\n"; dsc=dsc+1
            end
        end
        v2 = dsc>0 and "Scripts dentro del mob ("..dsc.."):\n"..v2.."\nOportunidad: script:Disable()" or "Sin scripts locales. Dano via Raycast server-side."
        AddLog("V2", "Scripts de dano del mob", v2); task.wait(0.05)

        -- V3: Validacion de direccion
        local v3 = ""
        if myRoot then
            local dot = (mobRoot.Position-myRoot.Position).Unit:Dot(myRoot.CFrame.LookVector)
            v3 = "Dot (frente=1 espalda=-1): "..string.format("%.2f",dot).."\n"
            v3 = v3..(dot>0.5 and "Orientacion: MIRANDOLO" or dot<-0.5 and "Orientacion: DE ESPALDAS" or "Orientacion: LATERAL")
            v3 = v3.."\n\nSi el mob baja HP atacando desde atras = NO valida direccion (exploit de ataque invisible)."
        else v3 = "Sin HRP local para calcular angulo." end
        AddLog("V3", "Validacion de direccion para dano", v3); task.wait(0.05)

        -- V4: Knockback
        local v4 = ""
        local okPush = pcall(function() if myRoot then mobRoot.AssemblyLinearVelocity=(mobRoot.Position-myRoot.Position).Unit*-25 end end)
        v4 = "Empujar con AssemblyLinearVelocity: "..(okPush and "EXITOSO (mob volio)" or "Bloqueado")
        for _,v in pairs(mob:GetDescendants()) do
            if v:IsA("BodyVelocity") or v:IsA("LinearVelocity") then v4=v4.."\nPhysics encontrado: "..v:GetFullName() end
        end
        AddLog("V4", "Knockback y Empuje", v4); task.wait(0.05)

        -- V5: Rotacion forzada
        local v5 = ""
        if myRoot then
            local away = myRoot.Position + myRoot.CFrame.LookVector*100
            local okR = pcall(function() mobRoot.CFrame = CFrame.new(mobRoot.Position, Vector3.new(away.X, mobRoot.Position.Y, away.Z)) end)
            v5 = "Rotar mob de espaldas: "..(okR and "EXITOSO - integra en Farm Loop con: mobRoot.CFrame = CFrame.lookAt(pos, awayPos)" or "Bloqueado por servidor.")
        end
        AddLog("V5", "Rotacion Forzada CFrame del Mob", v5); task.wait(0.05)

        -- V6: TouchInterest
        local v6 = ""
        for _,part in pairs(mob:GetDescendants()) do
            if part:IsA("BasePart") and part:FindFirstChildWhichIsA("TouchTransmitter") then
                table.insert(touchParts, part)
                v6=v6..part.Name.." | Size:"..tostring(part.Size).."\n  EXPLOIT: TouchTransmitter:Destroy() -> mob no detecta tu cuerpo\n"
            end
        end
        v6 = v6=="" and "Sin TouchInterest. Mob usa Raycast/OverlapParams server-side." or v6
        AddLog("V6", "TouchInterest y Dano por Contacto", v6); task.wait(0.05)

        -- V7: Brazos y Hitbox
        local v7 = ""
        for _,part in pairs(mob:GetDescendants()) do
            if part:IsA("BasePart") then
                local n = string.lower(part.Name)
                if string.find(n,"arm") or string.find(n,"hand") or string.find(n,"weapon") or string.find(n,"hit") or string.find(n,"attack") then
                    table.insert(attackParts, part)
                    local okSz = pcall(function() part.Size=Vector3.new(0.1,0.1,0.1) end)
                    v7=v7..part.Name.." | Reducir size: "..(okSz and "EXITOSO" or "Bloqueado").."\n"
                end
            end
        end
        v7 = v7=="" and "Sin partes de ataque nombradas. Raycast radio fijo ~5-8 studs.\nSolucion: aumenta offset muro a -6.5 studs." or v7
        AddLog("V7", "Brazos / Hitbox de Ataque", v7); task.wait(0.05)

        -- V8: Congelar IA
        local okW = pcall(function() mobHum.WalkSpeed=0; mobHum.JumpPower=0 end)
        local okS = pcall(function() mobHum:ChangeState(Enum.HumanoidStateType.Disabled) end)
        AddLog("V8", "Congelar IA del Mob",
            "WalkSpeed=0: "..(okW and "EXITOSO (mob congelado)" or "Bloqueado").."\nChangeState Disabled: "..(okS and "EJECUTADO" or "Bloqueado"))
        task.wait(0.05)

        -- V9: Flags de invulnerabilidad
        local v9, fc = "", 0
        for _,child in pairs(mob:GetDescendants()) do
            if child:IsA("BoolValue") or child:IsA("NumberValue") or child:IsA("IntValue") or child:IsA("StringValue") then
                local n = string.lower(child.Name)
                local sus = string.find(n,"invul") or string.find(n,"immune") or string.find(n,"god") or string.find(n,"stun") or string.find(n,"dead")
                v9=v9..(sus and "[SOSPECHOSO] " or "  ")..child.Name.." = "..tostring(child.Value).."\n"
                fc=fc+1
            end
        end
        AddLog("V9", "Flags de Invulnerabilidad", fc==0 and "Sin Values en el mob. Flags son server-side." or v9); task.wait(0.05)

        -- V10: Recomendaciones rapidas
        local v10 = "Mob: "..mob.Name.."\n"
        v10=v10..(#touchParts>0 and "PRIORIDAD 1: TouchInterest detectado - destruir tt en loop\n" or "")
        v10=v10..(#attackParts>0 and "PRIORIDAD 2: Brazos reducibles a 0.1x (V7 exitoso)\n" or "")
        v10=v10.."Muro: incrementar offset a -6.5 studs\n"
        v10=v10.."Si V5 exitoso: rotar mob con cada golpe en Farm\n"
        AddLog("V10", "Recomendaciones de Combate", v10)

        -- V11: Catalogo remotes de combate
        local v11, rcnt = "", 0
        for _,rem in pairs(game:GetDescendants()) do
            if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") or rem:IsA("UnreliableRemoteEvent") then
                local n = string.lower(rem.Name)
                if string.find(n,"damage") or string.find(n,"hit") or string.find(n,"hurt") or string.find(n,"attack") or
                   string.find(n,"health") or string.find(n,"hp") or string.find(n,"mob") or string.find(n,"kill") or
                   string.find(n,"tool") or string.find(n,"weapon") or string.find(n,"ability") then
                    v11=v11.."["..rem.ClassName.."] "..rem:GetFullName().."\n"; rcnt=rcnt+1
                end
            end
        end
        AddLog("V11", "Catalogo Remotes de Combate", "Total: "..rcnt.."\n"..(rcnt==0 and "Sin nombres obvios. Usa Interceptor." or v11))

        -- V12: Captura en vivo 3s
        AddLog("V12", "CAPTURA EN VIVO (3s)", "Atacando al mob y capturando paquetes C->S. Espera...")
        task.wait(0.3)

        local pkts, captureOn, t0, grps = {}, true, tick(), {}
        local cHook
        pcall(function()
            cHook = hookmetamethod(game, "__namecall", newcclosure(function(s2, ...)
                local m = string.lower(tostring(getnamecallmethod()))
                if captureOn and (m=="fireserver" or m=="invokeserver") then
                    pcall(function()
                        local nm, fp = "?", "?"
                        pcall(function() nm=s2.Name; fp=s2:GetFullName() end)
                        local nL = string.lower(nm)
                        if not string.find(nL,"mouse") and not string.find(nL,"camera") and not string.find(nL,"input") then
                            table.insert(pkts, {t=tick()-t0, name=nm, path=fp, cls=s2.ClassName, args={...}, rem=s2})
                        end
                    end)
                end
                return cHook(s2, ...)
            end))
        end)

        local hpB = mobHum.Health
        local hpLog = {{t=0, hp=hpB}}
        task.spawn(function()
            local endT = tick()+3
            while tick()<endT and captureOn do
                pcall(function()
                    if myRoot and mobRoot then
                        myRoot.CFrame = CFrame.lookAt(myRoot.Position, Vector3.new(mobRoot.Position.X,myRoot.Position.Y,mobRoot.Position.Z))
                    end
                    ToolRF:InvokeServer("Weapon")
                end)
                pcall(function() table.insert(hpLog,{t=tick()-t0, hp=mobHum.Health}) end)
                task.wait(0.15)
            end
        end)
        task.wait(3.2)
        captureOn = false

        for _,p in ipairs(pkts) do
            if not grps[p.name] then grps[p.name]={} end
            table.insert(grps[p.name], p)
        end

        -- V13: Curva HP
        local hpA = mobHum.Health
        local hpDrop = hpB - hpA
        local v13 = "HP: "..string.format("%.1f",hpB).." -> "..string.format("%.1f",hpA).."\n"
        v13=v13.."Dano 3s: "..string.format("%.1f",hpDrop).." | DPS: "..string.format("%.2f",hpDrop/3).."\n\nCurva:\n"
        for i,s in ipairs(hpLog) do
            if i>1 then local d=hpLog[i-1].hp-s.hp; if d>0 then v13=v13.."  t+"..string.format("%.1f",s.t).."s HP:"..string.format("%.0f",s.hp).." (-"..string.format("%.1f",d)..")\n" end end
        end
        v13=v13..(hpDrop<=0 and "\nDANO NULO. ToolRF no valido para este mob." or "\nToolRF confirmado. "..string.format("%.1f",hpDrop).." HP quitados.")
        AddLog("V13", "Curva HP forense (3s)", v13)

        -- V14: Paquetes C->S
        local v14 = "Total paquetes: "..#pkts.."\n\n"
        for rName,rPkts in pairs(grps) do
            v14=v14.."["..rPkts[1].cls.."] "..rName.." x"..#rPkts.."\n  Path: "..rPkts[1].path.."\n  Args muestra:\n"
            for i,arg in ipairs(rPkts[1].args) do
                local tp=typeof(arg); local ex=""
                pcall(function()
                    if tp=="Instance" then ex=" -> "..arg:GetFullName()
                    elseif tp=="table" then ex=" -> "..HttpService:JSONEncode(arg)
                    elseif tp=="CFrame" then ex=" pos="..tostring(arg.Position) end
                end)
                v14=v14.."    ["..i.."] ("..tp..") "..tostring(arg)..ex.."\n"
            end
            if #rPkts>=2 then
                local intv=(rPkts[#rPkts].t-rPkts[1].t)/math.max(1,#rPkts-1)
                v14=v14.."  Rate: "..string.format("%.1f",1/intv).."/s\n"
            end
            v14=v14.."\n"
        end
        if #pkts==0 then v14=v14.."CERO paquetes. Executor sin hookmetamethod.\nUsa Interceptor (boton 2) + ataque manual." end
        AddLog("V14", "Paquetes C->S", v14)

        -- V15: S->C
        AddLog("V15", "Paquetes S->C",
            "HP sincronizado via Humanoid.Health replication de Roblox (sin RemoteEvents).\nUsa Live Scan apuntando al mob para monitorear HP en tiempo real.")

        -- V16: Replay
        local v16, bestR, bestC, bestA = "", nil, 0, nil
        for _,rp in pairs(grps) do
            if #rp>bestC then bestC=#rp; bestR=rp[1].rem; bestA=rp[1].args end
        end
        if bestR then
            v16="Remote: "..bestR.Name.." x"..bestC.."\nREPLAY x5...\n"
            local hpPre=mobHum.Health; local hits=0
            for i=1,5 do
                local ok=pcall(function()
                    if bestR:IsA("RemoteFunction") then bestR:InvokeServer(table.unpack(bestA))
                    else bestR:FireServer(table.unpack(bestA)) end
                end)
                if ok then hits=hits+1 end; task.wait(0.04)
            end
            task.wait(0.3)
            local dmgR=hpPre-mobHum.Health
            v16=v16.."Replays: "..hits.."/5 | Dano replay: "..string.format("%.1f",dmgR).."\n"
            if dmgR>0 then
                v16=v16.."MEGA-EXPLOIT: Sin rate-limit!\nIntegra loop de replay en Farm -> x10 DPS.\nPath: "..bestR:GetFullName()
            elseif hits>0 then v16=v16.."Rate-limit detectado. Remote valido pero spam bloqueado."
            end
        else v16="Sin remote identificado.\nUsa Interceptor + ataque manual." end
        AddLog("V16", "Replay / Rate-Limit Test", v16)

        -- V17: Resumen
        local gc=0; for _ in pairs(grps) do gc=gc+1 end
        local v17="Mob: "..mob.Name.."\nPaquetes C->S: "..#pkts.." | Remotes unicos: "..gc.."\nDano 3s: "..string.format("%.1f",hpDrop).." HP\n\nHallazgos:\n"
        v17=v17..(hpDrop>0 and "  ToolRF valido\n" or "  ToolRF NO valido - busca remote correcto en V14\n")
        v17=v17..(#pkts>0 and "  Red capturada - ver V14\n" or "  Red NO capturada - usar Interceptor\n")
        v17=v17..(#touchParts>0 and "  TouchInterest explotable (V6)\n" or "")
        v17=v17..(#attackParts>0 and "  Brazos reducibles (V7)\n" or "")
        v17=v17.."\nProximos pasos:\n  1. V16 OK -> spam remote en Farm\n  2. V6 OK -> destruir TouchTransmitter\n  3. V5 OK -> forzar rotacion mob\n  4. Interceptor + Lab para captura manual"
        AddLog("V17", "RESUMEN FORENSE (17 Vectores)", v17)

        ExploitBtn.Text = "☠️ 7. EXPLOIT FORENSE TOTAL (MOBS + RED)"
        ExploitBtn.BackgroundColor3 = Color3.fromRGB(160, 10, 10)
    end)

