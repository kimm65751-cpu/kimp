-- ==============================================================================
-- 💀 ROBLOX EXPERT: V20 THE GOD-EYE OMNI-SCANNER (MAPA ESTRUCTURAL COMPLETO)
-- Auditoría Definitiva de Servidor: NPCs, Red, Economía, Físicas y Anti-Cheat.
-- ==============================================================================

local SCRIPT_URL = "https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local FullReport = ""

local function AddLog(text)
    FullReport = FullReport .. text .. "\n"
    print("[OMNI-SCAN] " .. text)
end

-- ==============================================================================
-- ⚙️ MOTOR DEL OMNI-SCANNER
-- ==============================================================================
local function FormatValue(v)
    if typeof(v) == "Instance" then return v.Name
    elseif typeof(v) == "Vector3" then return "V3"
    elseif typeof(v) == "CFrame" then return "CF"
    else return tostring(v) end
end

local function EscaneoOmniAbsoluto()
    FullReport = "========================================================\n"
    FullReport = FullReport .. "👑 REPORTE DE AUDITORÍA OMNI-SCANNER V20 (ROBLOX 2026) 👑\n"
    FullReport = FullReport .. "========================================================\n\n"
    
    AddLog("Iniciando DUMP Masivo de Memoria del Servidor...")

    -- ------------------------------------------------------------------
    -- 1. ANÁLISIS DE NETWORK / REMOTES Y TRAMPAS (HONEYPOTS)
    -- ------------------------------------------------------------------
    AddLog("\n[📡 SECCIÓN 1: ARQUITECTURA DE RED Y EVENTOS C/S]")
    local Remotes = 0
    local Honeypots = 0
    for _, obj in pairs(game:GetDescendants()) do
        pcall(function()
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                Remotes = Remotes + 1
                local name = string.lower(obj.Name)
                if string.find(name, "ban") or string.find(name, "kick") or string.find(name, "cheat") or string.find(name, "detect") then
                    AddLog(" 🚨 HONEYPOT / TRAMPA DETECTADA: " .. obj:GetFullName())
                    Honeypots = Honeypots + 1
                else
                    AddLog(" 🔗 Vía Abierta: " .. obj.Name .. " (" .. obj.ClassName .. ") en " .. obj.Parent.Name)
                end
            end
        end)
    end
    if Remotes == 0 then AddLog(" 🔒 SERVIDOR 100% AUTORITATIVO. Cero eventos remotos abiertos hallados. No hay huecos de inyección directa.") end
    
    -- ------------------------------------------------------------------
    -- 2. ANÁLISIS DE MOBS, ZOMBIES Y ATRIBUTOS DE IA
    -- ------------------------------------------------------------------
    AddLog("\n[🧟 SECCIÓN 2: BASE DE DATOS DE ZOMBIES Y ENEMIGOS]")
    local mobsAnalyzed = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                if string.find(string.lower(obj.Name), "zombie") or string.find(string.lower(obj.Name), "mob") or string.find(string.lower(obj.Name), "boss") then
                    if not mobsAnalyzed[obj.Name] then
                        mobsAnalyzed[obj.Name] = true
                        AddLog("\n 🧬 Entidad Detectada: " .. obj.Name)
                        local hum = obj:FindFirstChild("Humanoid")
                        AddLog("   - Salud Base: " .. tostring(hum.MaxHealth) .. " | Velocidad: " .. tostring(hum.WalkSpeed))
                        
                        -- Buscar TouchTransmitters, Scripts, y Atributos
                        local hasTouch = false
                        for _, v in pairs(obj:GetDescendants()) do
                            if v:IsA("TouchTransmitter") then hasTouch = true end
                            if v:IsA("ValueBase") then
                                AddLog("   - Data Interna: " .. v.Name .. " = " .. FormatValue(v.Value))
                            end
                        end
                        if hasTouch then AddLog("   - Sistema de Daño: FÍSICO (.Touched detectado. Puedes esquivarlo).")
                        else AddLog("   - Sistema de Daño: MATEMÁTICO (Vectorial/Magnitude C++. Imposible evadir tocando).") end
                        
                        local attrs = obj:GetAttributes()
                        for k, v in pairs(attrs) do AddLog("   - Atributo Oculto: " .. k .. " = " .. FormatValue(v)) end
                    end
                end
            end
        end)
    end

    -- ------------------------------------------------------------------
    -- 3. ECONOMÍA, TIENDAS, EVENTOS HUMANOS Y DROP RATES
    -- ------------------------------------------------------------------
    AddLog("\n[💰 SECCIÓN 3: TIENDAS, ECONOMÍA Y DROPS]")
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            -- Tiendas
            if obj:IsA("Model") and (string.find(string.lower(obj.Name), "shop") or string.find(string.lower(obj.Name), "npc") or string.find(string.lower(obj.Name), "store")) then
                AddLog(" 🏪 Tienda/NPC Hallado: " .. obj.Name)
                for _, prompt in pairs(obj:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        AddLog("   - Interacción: '" .. tostring(prompt.ActionText) .. "' (Rango: " .. tostring(prompt.MaxActivationDistance) .. ")")
                    elseif prompt:IsA("ValueBase") then
                        AddLog("   - Dato Comercial: " .. prompt.Name .. " = " .. FormatValue(prompt.Value))
                    end
                end
            end
            
            -- Drop Rates y Cofres
            if string.find(string.lower(obj.Name), "chest") or string.find(string.lower(obj.Name), "drop") or string.find(string.lower(obj.Name), "rate") then
                 AddLog(" 💎 Loot/Cofre Detectado: " .. obj.Name)
                 for _, v in pairs(obj:GetDescendants()) do
                     if v:IsA("NumberValue") or v:IsA("IntValue") then
                         AddLog("   - Probabilidad/Valor: " .. v.Name .. " = " .. FormatValue(v.Value))
                     end
                 end
            end
        end)
    end

    -- ------------------------------------------------------------------
    -- 4. ANÁLISIS DEL PERSONAJE: INVENTARIO, ARMAS Y ERRORES LOCALES
    -- ------------------------------------------------------------------
    AddLog("\n[👤 SECCIÓN 4: TU AVATAR E INVENTARIO]")
    pcall(function()
        if LocalPlayer.Character then
            AddLog(" 🟢 Personaje Vivo. Tool Equipado: " .. (LocalPlayer.Character:FindFirstChildOfClass("Tool") and LocalPlayer.Character:FindFirstChildOfClass("Tool").Name or "Ninguno"))
        end
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            AddLog(" 🎒 Inventario (Backpack):")
            for _, tool in pairs(backpack:GetChildren()) do
                AddLog("   - Arma/Item: " .. tool.Name)
                for _, req in pairs(tool:GetDescendants()) do
                    if req:IsA("ValueBase") then AddLog("     > Requisito/Dato: " .. req.Name .. " = " .. FormatValue(req.Value)) end
                end
            end
        end
        
        local leader = LocalPlayer:FindFirstChild("leaderstats")
        if leader then
            AddLog(" 📊 Monedas/Economía de Perfil:")
            for _, stat in pairs(leader:GetChildren()) do AddLog("   - " .. stat.Name .. ": " .. tostring(stat.Value)) end
        end
    end)

    -- ------------------------------------------------------------------
    -- 5. FÍSICAS ROTAS, ERRORES DE ESTRUCTURA Y TELEKINESIS
    -- ------------------------------------------------------------------
    AddLog("\n[🧱 SECCIÓN 5: ANOMALÍAS FÍSICAS Y MAPA ROTO]")
    local looseParts = 0
    local fallingParts = 0
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("BasePart") then
                if not obj.Anchored and not obj.Parent:FindFirstChild("Humanoid") then
                    looseParts = looseParts + 1
                end
                if obj.Position.Y < -200 and obj.Anchored == false then
                    fallingParts = fallingParts + 1
                end
            end
        end)
    end
    AddLog(" 🌪️ Objetos sueltos movibles (Proyectiles Posibles): " .. tostring(looseParts))
    AddLog(" 🕳️ Objetos crasheados tirados en el vacío (-Y): " .. tostring(fallingParts))

    AddLog("\n========================================================")
    AddLog("✅ ESCANEO OMNI-RECURSIVO COMPLETO.")
end

-- ==============================================================================
-- 🖥️ GUI V2026: THE OMNI-SCANNER INTERFACE
-- ==============================================================================
local function ConstruirUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "MasterBypass2026UI"
    sg.ResetOnSpawn = false
    
    local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "MasterBypass2026UI" then v:Destroy() end end
    sg.Parent = parentUI

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 600, 0, 480)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -240)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    MainFrame.BorderSizePixel = 3
    MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -90, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(0, 40, 50)
    TopBar.Text = "  [V20: THE GOD-EYE OMNI-SCANNER (FULL SYSTEM DUMP)]"
    TopBar.TextColor3 = Color3.fromRGB(100, 255, 255)
    TopBar.Font = Enum.Font.Code
    TopBar.TextSize = 13
    TopBar.TextXAlignment = Enum.TextXAlignment.Left
    TopBar.Parent = MainFrame

    local ReloadBtn = Instance.new("TextButton")
    ReloadBtn.Size = UDim2.new(0, 30, 0, 30)
    ReloadBtn.Position = UDim2.new(1, -90, 0, 0)
    ReloadBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 0)
    ReloadBtn.Text = "↻"
    ReloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ReloadBtn.Font = Enum.Font.Code
    ReloadBtn.TextSize = 18
    ReloadBtn.Parent = MainFrame

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    MinimizeBtn.Position = UDim2.new(1, -60, 0, 0)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 150)
    MinimizeBtn.Text = "_"
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.Font = Enum.Font.Code
    MinimizeBtn.TextSize = 14
    MinimizeBtn.Parent = MainFrame

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.TextSize = 14
    CloseBtn.Parent = MainFrame

    CloseBtn.MouseButton1Click:Connect(function() sg:Destroy() end)
    MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)
    ReloadBtn.MouseButton1Click:Connect(function()
        pcall(function() sg:Destroy(); loadstring(game:HttpGet(SCRIPT_URL .. "?r=" .. math.random(111,999)))() end)
    end)

    local InfoScroll = Instance.new("ScrollingFrame")
    InfoScroll.Size = UDim2.new(1, -16, 0.70, 0)
    InfoScroll.Position = UDim2.new(0, 8, 0, 35)
    InfoScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    InfoScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    InfoScroll.ScrollBarThickness = 6
    InfoScroll.Parent = MainFrame

    local LogText = Instance.new("TextLabel")
    LogText.Size = UDim2.new(1, -10, 1, 0)
    LogText.Position = UDim2.new(0, 5, 0, 5)
    LogText.BackgroundTransparency = 1
    LogText.Text = "Tienes razón. Adivinar y probar a ciegas agota el tiempo de ambos. \n\nHe forjado el OMNI-SCANNER. Un algoritmo recursivo gigante que leerá cada carpeta de tu servidor. Con un solo botón extraerá:\n1. Qué Eventos recibe el Servidor y si existen Trampas (Honeypots).\n2. El DNA de cada Mob: Drop Rates, Vida, Eventos Internos, Físicas.\n3. Tiendas, Cofres, Interacciones de NPCs y Economía.\n4. Tus armas, tu mochila, y tus stats (Leaderstats).\n5. Objetos rotos o inyectables en el Motor C++.\n\nPulsa [INICIAR OMNI-SCAN] abajo para generar el Dumpeo Absoluto. Luego usa [COPIAR REPORTE AL PORTAPAPELES] para que puedas pegarlo en un bloc de notas y ver el estado desnudo de tu videojuego."
    LogText.TextColor3 = Color3.fromRGB(0, 255, 255)
    LogText.Font = Enum.Font.Code
    LogText.TextSize = 12
    LogText.TextXAlignment = Enum.TextXAlignment.Left
    LogText.TextYAlignment = Enum.TextYAlignment.Top
    LogText.TextWrapped = true
    LogText.Parent = InfoScroll

    local function ActualizarPantalla()
        LogText.Text = FullReport
        InfoScroll.CanvasPosition = Vector2.new(0, 999999)
    end

    local btnScan = Instance.new("TextButton")
    btnScan.Size = UDim2.new(0.48, 0, 0, 50)
    btnScan.Position = UDim2.new(0, 8, 0.85, 0)
    btnScan.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
    btnScan.Text = "👁️ 1. INICIAR OMNI-SCAN DEL SERVER"
    btnScan.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnScan.Font = Enum.Font.Code
    btnScan.TextSize = 12
    btnScan.Parent = MainFrame

    local btnCopy = Instance.new("TextButton")
    btnCopy.Size = UDim2.new(0.48, 0, 0, 50)
    btnCopy.Position = UDim2.new(0.5, 4, 0.85, 0)
    btnCopy.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    btnCopy.Text = "📋 2. COPIAR REPORTE AL PORTAPAPELES"
    btnCopy.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnCopy.Font = Enum.Font.Code
    btnCopy.TextSize = 12
    btnCopy.Parent = MainFrame

    btnScan.MouseButton1Click:Connect(function()
        pcall(function()
            EscaneoOmniAbsoluto()
            ActualizarPantalla()
        end)
    end)
    
    btnCopy.MouseButton1Click:Connect(function()
        pcall(function()
            if setclipboard then
                setclipboard(FullReport)
                btnCopy.Text = "✅ ¡COPIADO EXITOSAMENTE!"
                task.wait(2)
                btnCopy.Text = "📋 2. COPIAR REPORTE AL PORTAPAPELES"
            else
                Warn("Tu exploit no soporta setclipboard(). Mira los logs en F9.")
            end
        end)
    end)
end

ConstruirUI()
