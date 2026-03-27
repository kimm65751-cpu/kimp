-- ==============================================================================
-- 💀 ROBLOX EXPERT: V21.1 OMNI-SCANNER PRO (HOTFIX DE PORTAPAPELES)
-- Fixeado Copiado Emulador Delta|LDPlayer + Árbol Jerárquico.
-- ==============================================================================

local SCRIPT_URL = "https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local FullReport = ""

local function AddLog(text, indentLevel)
    local prefix = string.rep("  ", indentLevel or 0)
    FullReport = FullReport .. prefix .. text .. "\n"
    print("[OMNI-SCAN PRO] " .. prefix .. text)
end

-- ==============================================================================
-- ⚙️ MOTOR DEL OMNI-SCANNER PRO (JERÁRQUICO)
-- ==============================================================================
local function FormatValue(v)
    if typeof(v) == "Instance" then return v.Name
    elseif typeof(v) == "Vector3" then return "V3"
    elseif typeof(v) == "CFrame" then return "CF"
    else return tostring(v) end
end

local function GetDetails(obj, indent)
    for _, v in pairs(obj:GetChildren()) do
        pcall(function()
            if v:IsA("ValueBase") then       AddLog("📌 DATO: " .. v.Name .. " = " .. FormatValue(v.Value), indent)
            elseif v:IsA("RemoteEvent") then AddLog("🔗 EVENTO (Sin Respuesta): " .. v.Name, indent)
            elseif v:IsA("RemoteFunction") then AddLog("🔗 EVENTO (Con Respuesta): " .. v.Name, indent)
            elseif v:IsA("ProximityPrompt") or v:IsA("ClickDetector") then AddLog("🏪 INTERACCIÓN/AGARRE: '" .. tostring(v.ClassName) .. "'", indent)
            end
        end)
    end
end

local function EscaneoOmniJerarquico()
    FullReport = "========================================================\n"
    FullReport = FullReport .. "👑 REPORTE DE AUDITORÍA JERÁRQUICA V21 (ROBLOX 2026) 👑\n"
    FullReport = FullReport .. "========================================================\n\n"
    
    AddLog("INICIANDO ESCANEO FORENSE EN CASCADA (TREE DUMP)...", 0)

    -- ------------------------------------------------------------------
    -- 1. ANÁLISIS DE NETWORK / REMOTES (ESPECIALIZADO)
    -- ------------------------------------------------------------------
    AddLog("\n[📡 SECCIÓN 1: ARQUITECTURA DE RED Y EVENTOS C/S]", 0)
    local function ScanNet(parent, indent)
        for _, obj in pairs(parent:GetChildren()) do
            if obj:IsA("Folder") then
                local hasremotes = false
                for _, d in pairs(obj:GetDescendants()) do if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then hasremotes = true break end end
                if hasremotes then
                    AddLog("📁 " .. obj.Name, indent)
                    ScanNet(obj, indent + 1)
                end
            elseif obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local honeypot = (string.find(string.lower(obj.Name), "ban") or string.find(string.lower(obj.Name), "kick")) and " [🚨 TRAMPA/HONEYPOT]" or ""
                local warning = (obj.Name == "HitboxClassRemote") and " [‼️ VULNERABILIDAD RCH V4 DETECTADA]" or ""
                AddLog("🔗 " .. obj.Name .. " (" .. obj.ClassName .. ")" .. honeypot .. warning, indent)
            end
        end
    end
    ScanNet(ReplicatedStorage, 1)
    
    -- ------------------------------------------------------------------
    -- 2. ANÁLISIS DE MOBS, ZOMBIES Y ATRIBUTOS DE IA
    -- ------------------------------------------------------------------
    AddLog("\n[🧟 SECCIÓN 2: BASE DE DATOS DE ZOMBIES Y ENEMIGOS (INDIVIDUAL)]", 0)
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                if string.find(string.lower(obj.Name), "zombie") or string.find(string.lower(obj.Name), "boss") then
                    AddLog("🧬 " .. obj.Name, 1)
                    local hum = obj:FindFirstChild("Humanoid")
                    AddLog("🩸 Salud: " .. tostring(hum.MaxHealth) .. " | WalkSpeed: " .. tostring(hum.WalkSpeed), 2)
                    GetDetails(obj, 2)
                    
                    local hasTouch = false
                    for _, v in pairs(obj:GetDescendants()) do if v:IsA("TouchTransmitter") then hasTouch = true end end
                    if hasTouch then AddLog("⚔️ Usa TouchTransmitters (.Touched activo).", 2) else AddLog("⚔️ Usa Magnitude (Matemático Puro).", 2) end
                    
                    local attrs = obj:GetAttributes()
                    for k, v in pairs(attrs) do AddLog("💎 Atributo: " .. tostring(k) .. " = " .. FormatValue(v), 2) end
                end
            end
        end)
    end

    -- ------------------------------------------------------------------
    -- 3. UNIDADES FÍSICAS (PROPS, ORES, BASURA)
    -- ------------------------------------------------------------------
    AddLog("\n[🧱 SECCIÓN 3: ÁRBOL DE OBJETOS FÍSICOS SUELTOS]", 0)
    AddLog("Detallando qué objetos se pueden mover libremente, su Masa y Estados de Agarre:", 0)
    
    local PhysicsTree = {}
    local unanchoredCount = 0
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("BasePart") and not obj.Anchored and not obj.Parent:FindFirstChild("Humanoid") then
                unanchoredCount = unanchoredCount + 1
                local parentName = obj.Parent.Name
                local itemType = obj.Name .. " (" .. obj.ClassName .. ")"
                
                if not PhysicsTree[parentName] then PhysicsTree[parentName] = {} end
                if not PhysicsTree[parentName][itemType] then 
                    
                    local interactable = false
                    if obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChildOfClass("ClickDetector") then interactable = true end
                    
                    PhysicsTree[parentName][itemType] = {
                        count = 0, 
                        mass = math.floor(obj:GetMass()),
                        collision = obj.CanCollide and "Sólido" or "Fantasma",
                        status = obj.Anchored and "Estático" or "Dinámico (Movible)",
                        grabbable = interactable and "Sí (Tiene Prompt)" or "No (Físico Puro)"
                    }
                end
                PhysicsTree[parentName][itemType].count = PhysicsTree[parentName][itemType].count + 1
            end
        end)
    end
    
    for folder, items in pairs(PhysicsTree) do
        AddLog("📁 Ubicación: " .. folder, 1)
        for name, data in pairs(items) do
            AddLog("▶ Modelos: " .. tostring(data.count) .. "x " .. name, 2)
            AddLog("  ├─ Estado Físico: " .. data.status .. " | Colisión: " .. data.collision, 2)
            AddLog("  ├─ Masa Estimada: " .. tostring(data.mass) .. " uds.", 2)
            AddLog("  └─ ¿Interactuable/Sujetable?: " .. data.grabbable, 2)
        end
    end
    AddLog("\nTOTAL UNIDADES DINÁMICAS HALLADAS: " .. tostring(unanchoredCount), 1)

    -- ------------------------------------------------------------------
    -- 4. ANÁLISIS DEL PERSONAJE CLIENTE Y LÓGICA LOCAL
    -- ------------------------------------------------------------------
    AddLog("\n[👤 SECCIÓN 4: TU AVATAR E INVENTARIO]", 0)
    pcall(function()
        if LocalPlayer.Character then
            AddLog("🟢 Personaje Vivo: " .. LocalPlayer.Character.Name, 1)
            GetDetails(LocalPlayer.Character, 2)
        end
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            AddLog("🎒 Inventario Local:", 1)
            for _, tool in pairs(backpack:GetChildren()) do
                AddLog("⚔️ " .. tool.Name, 2)
                GetDetails(tool, 3)
            end
        end
    end)

    AddLog("\n========================================================", 0)
    AddLog("✅ ESCANEO JERÁRQUICO V21 COMPLETO.", 0)
end

-- ==============================================================================
-- 🖥️ GUI V2026: THE OMNI-SCANNER PRO (TREE VIEWER)
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
    MainFrame.BorderColor3 = Color3.fromRGB(200, 255, 0)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -90, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(60, 40, 0)
    TopBar.Text = "  [V21.1: OMNI-SCANNER CAJA BLANCA - PATCHED]"
    TopBar.TextColor3 = Color3.fromRGB(255, 255, 100)
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

    -- [V21.1 FIX: CAMBIO DE TEXTLABEL A TEXTBOX CON MODO LECTURA PARA PERMITIR SELECCIÓN Y COPIA MANUAL]
    local LogText = Instance.new("TextBox")
    LogText.Size = UDim2.new(1, -10, 1, 0)
    LogText.Position = UDim2.new(0, 5, 0, 5)
    LogText.BackgroundTransparency = 1
    LogText.Text = "Problema del Botón Copiar: Los emuladores de Android en PC (Como LDPlayer) a veces bloquean setclipboard() por temas de red.\n\nEL HOTFIX V21.1: He convertido esta pantalla negra en un Cuadro de Texto Libre (TextBox).\n\nDale al Escaneo (BOTÓN 1), espera a que se imprima toda la matriz... ¡Y ahora simplemente HAZ CLIC EN ESTE TEXTO CON EL RATÓN, presiona 'CTRL+A' (Para Seleccionar Todo) y luego 'CTRL+C' (Para Copiarlo manualmente)!\n\nLleva tu reporte al portapapeles o blocs de notas."
    LogText.TextColor3 = Color3.fromRGB(255, 255, 150)
    LogText.Font = Enum.Font.Code
    LogText.TextSize = 12
    LogText.TextXAlignment = Enum.TextXAlignment.Left
    LogText.TextYAlignment = Enum.TextYAlignment.Top
    LogText.TextWrapped = true
    LogText.ClearTextOnFocus = false
    LogText.TextEditable = false
    LogText.MultiLine = true
    LogText.Parent = InfoScroll

    local function ActualizarPantalla()
        LogText.Text = FullReport
        InfoScroll.CanvasPosition = Vector2.new(0, 999999)
    end

    local btnScan = Instance.new("TextButton")
    btnScan.Size = UDim2.new(1, -16, 0, 50)
    btnScan.Position = UDim2.new(0, 8, 0.85, 0)
    btnScan.BackgroundColor3 = Color3.fromRGB(150, 80, 0)
    btnScan.Text = "🌳 1. INICIAR OMNI-SCAN JERÁRQUICO (CASCADA)"
    btnScan.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnScan.Font = Enum.Font.Code
    btnScan.TextSize = 13
    btnScan.Parent = MainFrame

    btnScan.MouseButton1Click:Connect(function()
        pcall(function()
            EscaneoOmniJerarquico()
            ActualizarPantalla()
        end)
    end)
end

ConstruirUI()
