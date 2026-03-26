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
MainFrame.Size = UDim2.new(0, 700, 0, 500)
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 128)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Title.Text = " 🕵️ OMNI-FORENSICS V2.0 : HITBOX & DELTA EXPLOIT ENGINE"
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

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -20, 1, -125)
LogScroll.Position = UDim2.new(0, 10, 0, 115)
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

-- Hook para outgoing (Tu PC -> Servidor)
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local methodStr = string.lower(tostring(method))
    
    if InterceptorActivo and (methodStr == "fireserver" or methodStr == "invokeserver") then
        local args = {...}
        local selfName = "UnknownRemote"
        pcall(function() selfName = self.Name end)
        local nLow = string.lower(selfName)
        
        -- Ignoramos basura de movimiento o cámara
        if not string.find(nLow, "mouse") and not string.find(nLow, "camera") and not string.find(nLow, "move") then
            -- MODO EDICIÓN EN TIEMPO REAL:
            -- Si detectamos que nos quitan vida, mandamos "0"
            if string.find(nLow, "takedamage") then
                args[1] = 0 -- Bajar nuestro daño a 0
            end
            
            -- Hacemos el volcado de texto asíncrono y protegido para NUNCA romper tu ataque en el juego
            task.spawn(function()
                pcall(function()
                    local fullPath = "Unknown"
                    pcall(function() fullPath = self:GetFullName() end)
                    
                    local argDump = "--- PAQUETE SALIENTE --- \nDestino: " .. fullPath .. "\nMétodo: " .. methodStr .. "\nArgumentos:\n"
                    for i, v in ipairs(args) do
                        local extraInfo = ""
                        if typeof(v) == "Instance" then
                            local vP, vIsPart, vName = "nil", false, "unknown"
                            pcall(function() vP = tostring(v.Parent); vIsPart = v:IsA("BasePart"); vName = v.Name end)
                            extraInfo = " | Padre: " .. vP .. " | Es BasePart: " .. tostring(vIsPart)
                            
                            if vIsPart and string.find(string.lower(vName), "hitbox") then
                                extraInfo = extraInfo .. " 🎯 ¡ALERTA HITBOX! Usa este argument en FireServer."
                            end
                        elseif typeof(v) == "Vector3" then
                            extraInfo = " | Posición Mundo (Raycast / HitPos)"
                        elseif typeof(v) == "CFrame" then
                            extraInfo = " | Coordenadas/Rotación Orientada"
                        end

                        argDump = argDump .. "["..i.."] ("..typeof(v)..") = " .. tostring(v) .. extraInfo .. "\n"
                        
                        if typeof(v) == "table" then
                            pcall(function() argDump = argDump .. "   Tabla: " .. HttpService:JSONEncode(v) .. "\n" end)
                        end
                    end
                    AddLog("C->S", selfName, argDump)
                end)
            end)
            
            if string.find(nLow, "takedamage") then
                return oldNamecall(self, unpack(args)) -- Enviamos args hackeados solo en daño propio
            end
        end
    end
    return oldNamecall(self, ...)
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
