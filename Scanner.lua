-- ==============================================================================
-- 💀 ROBLOX EXPERT: DEEP RECON EXCAVATOR V16 (ANÁLISIS DE DATOS)
-- Lee la genética, atributos, estados ocultos y dependencias de ataque Server.
-- ==============================================================================

local SCRIPT_URL = "https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- 🧩 CORE LOGGER
local Analyzer = { Logs = {} }

function Analyzer:Clear()
    self.Logs = {}
    if self.UI_LogBox then self.UI_LogBox.Text = "" end
end

function Analyzer:Log(txt)
    print("[CRACKER-RECON] " .. tostring(txt))
    table.insert(self.Logs, txt)
    pcall(function()
        if self.UI_LogBox then
            self.UI_LogBox.Text = self.UI_LogBox.Text .. "\n" .. tostring(txt)
        end
    end)
    pcall(function()
        local scroll = self.UI_LogBox.Parent
        scroll.CanvasPosition = Vector2.new(0, 99999)
    end)
end

-- ==============================================================================
-- 🔬 ESCÁNER PROFUNDO DE VECTORES
-- ==============================================================================
local function FormatValue(v)
    if typeof(v) == "Instance" then return v:GetFullName()
    elseif typeof(v) == "Vector3" then return "V3("..math.floor(v.X)..","..math.floor(v.Y)..","..math.floor(v.Z)..")"
    elseif typeof(v) == "CFrame" then return "CF[...]"
    else return tostring(v) end
end

local function ScanEntity(entity, title)
    Analyzer:Clear()
    Analyzer:Log("🔬 RADIOGRAFÍA DE DATOS A: " .. title .. " (" .. entity.Name .. ")")
    Analyzer:Log("--------------------------------------------------")
    
    local foundData = 0

    -- 1. Atributos Ocultos (Roblox 2026+)
    local attrs = entity:GetAttributes()
    local hasAttr = false
    for k, v in pairs(attrs) do
        if not hasAttr then Analyzer:Log("\n[💎 ATRIBUTOS NATIVOS]:") hasAttr = true end
        Analyzer:Log(" - " .. k .. " = " .. FormatValue(v))
        foundData = foundData + 1
    end
    
    if entity:FindFirstChild("Humanoid") then
        local humAttrs = entity.Humanoid:GetAttributes()
        for k, v in pairs(humAttrs) do
            if not hasAttr then Analyzer:Log("\n[💎 ATRIBUTOS HUMANOID]:") hasAttr = true end
            Analyzer:Log(" - " .. k .. " = " .. FormatValue(v))
            foundData = foundData + 1
        end
    end

    -- 2. Variables Clásicas (Values) y Scripts Relevantes
    Analyzer:Log("\n[📂 VALORES, SCRIPTS Y SENSORES]:")
    for _, obj in pairs(entity:GetDescendants()) do
        if obj:IsA("ValueBase") then
            Analyzer:Log(" 📌 " .. obj.ClassName .. ": " .. obj.Name .. " -> [" .. FormatValue(obj.Value) .. "]")
            foundData = foundData + 1
        elseif obj:IsA("TouchTransmitter") then
            Analyzer:Log(" 🖐️ TouchSensor detectado en: " .. obj.Parent.Name .. " (Esto significa que su ataque te toca físicamente, no es Raycast).")
            foundData = foundData + 1
        elseif obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
            Analyzer:Log(" 🔗 Vínculo Server: " .. obj.Name)
            foundData = foundData + 1
        elseif obj:IsA("StringValue") and string.find(string.lower(obj.Name), "target") then
            Analyzer:Log(" 🎯 TARGET SYSTEM ENCONTRADO: " .. obj.Name .. " -> " .. FormatValue(obj.Value))
            foundData = foundData + 1
        elseif obj:IsA("ObjectValue") and obj.Name == "creator" then
            Analyzer:Log(" 🗡️ SYSTEM KILL-TAG: 'creator' -> Registra quién le pegó último.")
        end
    end
    
    -- 3. Estado del Humanoid
    local hum = entity:FindFirstChild("Humanoid")
    if hum then
        Analyzer:Log("\n[🩸 STATUS DEL HUMANOID]:")
        Analyzer:Log(" - MaxHealth: " .. tostring(hum.MaxHealth))
        Analyzer:Log(" - WalkSpeed: " .. tostring(hum.WalkSpeed))
        local state = hum:GetState()
        Analyzer:Log(" - Estado Actual: " .. tostring(state))
    end
    
    Analyzer:Log("--------------------------------------------------")
    if foundData == 0 then
        Analyzer:Log("💀 ADVERTENCIA: Esta entidad está 100% blindada. No usa tags ni atributos. Su código es Código Servidor Puro con Raycast matemático.")
    else
        Analyzer:Log("✅ Análisis completado. Busca fallas en estas variables (Tags de 'Stun', 'Hit', 'Target', 'Cooldown').")
    end
end

local function ScanTargetZombie()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return Analyzer:Log("Error: No tienes personaje.") end
    
    local target = nil
    local distM = 99999
    for _, z in pairs(Workspace:GetDescendants()) do
        if z:IsA("Model") and string.find(string.lower(z.Name), "zombie") and z ~= char then
            local zRoot = z:FindFirstChild("HumanoidRootPart")
            if zRoot then
                local d = (zRoot.Position - root.Position).Magnitude
                if d < distM then distM = d; target = z end
            end
        end
    end
    
    if target then
        ScanEntity(target, "ZOMBIE CERCANO")
    else
        Analyzer:Log("❌ No se detectan zombies vivos cerca para escanear.")
    end
end

local function ScanMe()
    local char = LocalPlayer.Character
    if char then
        ScanEntity(char, "TU PERSONAJE CLON C++")
    else
        Analyzer:Log("❌ Error: No tienes personaje.")
    end
end

-- ==============================================================================
-- 🖥️ GUI V2026: DEEP RECON EXCAVATOR COMPACTO
-- ==============================================================================
local function ConstruirUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "MasterBypass2026UI"
    sg.ResetOnSpawn = false
    
    local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "MasterBypass2026UI" then v:Destroy() end end
    sg.Parent = parentUI

    -- 📐 REDUCIDO DRÁSTICAMENTE (LDPlayer Formato)
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 560, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -280, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
    MainFrame.BorderSizePixel = 3
    MainFrame.BorderColor3 = Color3.fromRGB(150, 50, 200)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -90, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(40, 20, 60)
    TopBar.Text = "  [V16: DEEP RECON EXCAVATOR - EXTRACCIÓN DE DATOS]"
    TopBar.TextColor3 = Color3.fromRGB(200, 150, 255)
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
    InfoScroll.Size = UDim2.new(1, -16, 0.5, 0)
    InfoScroll.Position = UDim2.new(0, 8, 0, 35)
    InfoScroll.BackgroundColor3 = Color3.fromRGB(20, 15, 25)
    InfoScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    InfoScroll.ScrollBarThickness = 6
    InfoScroll.Parent = MainFrame

    local LogText = Instance.new("TextLabel")
    LogText.Size = UDim2.new(1, -10, 1, 0)
    LogText.Position = UDim2.new(0, 5, 0, 5)
    LogText.BackgroundTransparency = 1
    LogText.Text = "TIENES TODA LA RAZÓN. Te explico qué acaba de pasar con la 'Cadena' loca:\n\nTu PC (El Cliente) la agarró mediante físicas y la estrelló a millón contra el zombie. Tu PC calculó que el zombi explotó, dándole un 'Fling Falso' (Por eso desaparecieron de tu pantalla). Pero el juego tiene al Zombi bloqueado en Propiedad de Red... ¡El Servidor denegó esa explosión! Así que un Fantasma Zombi Invisible e invencible bajó a tu cueva y te partió a golpes sin que tú lo vieras porque tu PC pensaba que estaba muerto.\n\nPor culpa de ese blindaje físico, la única y absoluta forma de atacarlos es descubriendo QUÉ TIPO DE DATOS TIENEN OCULTOS para atacarte. Acabo de forjar un Escáner de Rayos X (Radiografía Forense).\n\nPárate al lado de un zombi o cueva y pégale una RADIOGRAFÍA. Me dirá si el zombi usa un StringValue llamado 'Target' a tu nombre, si tiene un TouchSensor en sus manos, o si usa 'Attributes' ocultos que yo pueda apagar (Invulnerabilidad por desvinculación)."
    LogText.TextColor3 = Color3.fromRGB(220, 180, 255)
    LogText.Font = Enum.Font.Code
    LogText.TextSize = 12
    LogText.TextXAlignment = Enum.TextXAlignment.Left
    LogText.TextYAlignment = Enum.TextYAlignment.Top
    LogText.TextWrapped = true
    LogText.Parent = InfoScroll

    -- Botones de Radiografía
    local btnZombie = Instance.new("TextButton")
    btnZombie.Size = UDim2.new(0.48, 0, 0, 50)
    btnZombie.Position = UDim2.new(0, 8, 0.62, 0)
    btnZombie.BackgroundColor3 = Color3.fromRGB(150, 0, 50)
    btnZombie.Text = "🧟 RADIOGRAFÍA AL ZOMBIE 🧟"
    btnZombie.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnZombie.Font = Enum.Font.Code
    btnZombie.TextSize = 13
    btnZombie.Parent = MainFrame

    local btnPlayer = Instance.new("TextButton")
    btnPlayer.Size = UDim2.new(0.48, 0, 0, 50)
    btnPlayer.Position = UDim2.new(0.5, 4, 0.62, 0)
    btnPlayer.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
    btnPlayer.Text = "👤 RADIOGRAFÍA A TU PERSONAJE 👤"
    btnPlayer.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnPlayer.Font = Enum.Font.Code
    btnPlayer.TextSize = 13
    btnPlayer.Parent = MainFrame

    btnZombie.MouseButton1Click:Connect(function() pcall(ScanTargetZombie) end)
    btnPlayer.MouseButton1Click:Connect(function() pcall(ScanMe) end)
end

ConstruirUI()
