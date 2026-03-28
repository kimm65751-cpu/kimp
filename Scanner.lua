-- ==============================================================================
-- 💎 AUTO-VENDEDOR PRO V5.0 (SECUENCIA EXACTA VERIFICADA POR FORENSE)
-- ==============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- BUSCADOR DE REMOTOS
-- ==========================================
local RF_RunCommand, RF_ForceDialogue, RF_Dialogue = nil, nil, nil
local RE_DialogueEvent = nil
local SeyNPC = nil

for _, obj in pairs(game.Workspace:GetDescendants()) do
    if obj:IsA("Model") and string.find(string.lower(obj.Name), "cey") then
        SeyNPC = obj
        break
    end
end

for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteFunction") then
        if obj.Name == "RunCommand" then RF_RunCommand = obj end
        if obj.Name == "ForceDialogue" then RF_ForceDialogue = obj end
        if obj.Name == "Dialogue" then RF_Dialogue = obj end
    elseif obj:IsA("RemoteEvent") then
        if obj.Name == "DialogueEvent" then RE_DialogueEvent = obj end
    end
end

-- ==========================================
-- DICCIONARIO DE MINERALES (SOLO BASURA, CERO ARMAS)
-- ==========================================
local MINERALES = {
    {es="Excremento",       en="Excrement",       color=Color3.fromRGB(150, 100, 80)},
    {es="Cartonita",        en="Cartonite",        color=Color3.fromRGB(200, 200, 200)},
    {es="Boneita",          en="Boneita",          color=Color3.fromRGB(200, 200, 200)},
    {es="Aite",             en="Aite",             color=Color3.fromRGB(200, 200, 200)},
    {es="Cuarzo",           en="Quartz",           color=Color3.fromRGB(200, 200, 200)},
    {es="Cuprita",          en="Cuprite",          color=Color3.fromRGB(200, 200, 200)},
    {es="Cobalto",          en="Cobalt",           color=Color3.fromRGB(150, 150, 255)},
    {es="Topaz",            en="Topaz",            color=Color3.fromRGB(100, 255, 100)},
    {es="Bananita",         en="Bananite",         color=Color3.fromRGB(255, 255, 50)},
    {es="Esmeralda",        en="Emerald",          color=Color3.fromRGB(50, 255, 100)},
    {es="Zafiro",           en="Sapphire",         color=Color3.fromRGB(100, 150, 255)},
    {es="Lapis Lazuli",     en="Lapis Lazuli",     color=Color3.fromRGB(50, 100, 255)},
    {es="Titánio",          en="Titanium",         color=Color3.fromRGB(180, 200, 255)},
    {es="Diamante",         en="Diamond",          color=Color3.fromRGB(150, 200, 255)},
    {es="Mina ocular",      en="Eye Mine",         color=Color3.fromRGB(255, 150, 50)},
    {es="Fichillium",       en="Fichillium",       color=Color3.fromRGB(255, 255, 100)},
    {es="Ametista",         en="Amethyst",         color=Color3.fromRGB(200, 100, 255)},
    {es="Esencia pequeña",  en="Small Essence",    color=Color3.fromRGB(220, 220, 220)},
    {es="Esencia mediana",  en="Medium Essence",   color=Color3.fromRGB(150, 255, 150)},
    {es="Esencia grande",   en="Large Essence",    color=Color3.fromRGB(100, 200, 255)},
    {es="Esencia superior", en="Superior Essence",  color=Color3.fromRGB(255, 150, 255)},
    {es="Chispa de fuego",  en="Fire Spark",       color=Color3.fromRGB(255, 100, 50)},
}

-- ==========================================
-- GUI
-- ==========================================
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "AutoVendorProUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoVendorProUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 480, 0, 580)
Panel.Position = UDim2.new(0, 50, 0.5, -290)
Panel.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(100, 150, 255)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 40, 80)
Title.Text = " 💎 AUTO-VENDEDOR REMOTO V5.0"
Title.TextColor3 = Color3.fromRGB(200, 220, 255)
Title.TextSize = 13
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Panel

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.Code
CloseBtn.Parent = Panel
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- CONSOLA DE LOGS
local TermScroll = Instance.new("ScrollingFrame")
TermScroll.Size = UDim2.new(1, -10, 0, 100)
TermScroll.Position = UDim2.new(0, 5, 0, 35)
TermScroll.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
TermScroll.ScrollBarThickness = 6
TermScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
TermScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TermScroll.Parent = Panel
Instance.new("UIListLayout", TermScroll).Padding = UDim.new(0, 2)

local LogHistory = {}
local function Log(texto, color)
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, -4, 0, 0)
    msg.BackgroundTransparency = 1
    msg.Text = "[" .. os.date("%H:%M:%S") .. "] " .. texto
    msg.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    msg.Font = Enum.Font.Code
    msg.TextSize = 11
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.TextWrapped = true
    msg.Parent = TermScroll
    local tsz = game:GetService("TextService"):GetTextSize(msg.Text, msg.TextSize, msg.Font, Vector2.new(TermScroll.AbsoluteSize.X-15, math.huge))
    msg.Size = UDim2.new(1, -4, 0, tsz.Y + 2)
    TermScroll.CanvasPosition = Vector2.new(0, 999999)
    table.insert(LogHistory, msg.Text)
end

-- Controles de Log
local LogControls = Instance.new("Frame")
LogControls.Size = UDim2.new(1, -10, 0, 20)
LogControls.Position = UDim2.new(0, 5, 0, 138)
LogControls.BackgroundTransparency = 1
LogControls.Parent = Panel

local CopyLogBtn = Instance.new("TextButton")
CopyLogBtn.Size = UDim2.new(0.5, -2, 1, 0)
CopyLogBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
CopyLogBtn.Text = "📋 COPIAR LOG"
CopyLogBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyLogBtn.Font = Enum.Font.Code
CopyLogBtn.TextSize = 10
CopyLogBtn.Parent = LogControls
CopyLogBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard(table.concat(LogHistory, "\n")) end)
    CopyLogBtn.Text = "✅ COPIADO"
    task.delay(1.5, function() CopyLogBtn.Text = "📋 COPIAR LOG" end)
end)

local ClearLogBtn = Instance.new("TextButton")
ClearLogBtn.Size = UDim2.new(0.5, -2, 1, 0)
ClearLogBtn.Position = UDim2.new(0.5, 2, 0, 0)
ClearLogBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ClearLogBtn.Text = "🗑️ LIMPIAR"
ClearLogBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearLogBtn.Font = Enum.Font.Code
ClearLogBtn.TextSize = 10
ClearLogBtn.Parent = LogControls
ClearLogBtn.MouseButton1Click:Connect(function()
    for _, v in ipairs(TermScroll:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
    LogHistory = {}
end)

-- Estado
Log((RF_RunCommand and "✅ RunCommand " or "❌ RunCommand ") .. 
    (RF_Dialogue and "✅ Dialogue " or "❌ Dialogue ") .. 
    (RF_ForceDialogue and "✅ ForceDialogue " or "❌ ForceDialogue ") ..
    (RE_DialogueEvent and "✅ DialogueEvent " or "❌ DialogueEvent ") ..
    (SeyNPC and "✅ NPC" or "❌ NPC"))

-- ==========================================
-- LISTA DE ITEMS SCROLL
-- ==========================================
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -230)
Scroll.Position = UDim2.new(0, 5, 0, 163)
Scroll.BackgroundColor3 = Color3.fromRGB(10, 15, 20)
Scroll.ScrollBarThickness = 6
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Panel
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 3)

local TablaDeCantidades = {}

for _, item in ipairs(MINERALES) do
    local fila = Instance.new("Frame")
    fila.Size = UDim2.new(1, -10, 0, 28)
    fila.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
    fila.Parent = Scroll
    
    local NameL = Instance.new("TextLabel")
    NameL.Size = UDim2.new(0.6, 0, 1, 0)
    NameL.Position = UDim2.new(0, 10, 0, 0)
    NameL.BackgroundTransparency = 1
    NameL.Text = item.es
    NameL.TextColor3 = item.color
    NameL.Font = Enum.Font.Code
    NameL.TextSize = 13
    NameL.TextXAlignment = Enum.TextXAlignment.Left
    NameL.Parent = fila
    
    local BoxCont = Instance.new("Frame")
    BoxCont.Size = UDim2.new(0.35, 0, 0, 20)
    BoxCont.Position = UDim2.new(0.65, -5, 0.5, -10)
    BoxCont.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    BoxCont.BorderSizePixel = 1
    BoxCont.BorderColor3 = item.color
    BoxCont.Parent = fila
    
    local TB = Instance.new("TextBox")
    TB.Size = UDim2.new(1, 0, 1, 0)
    TB.BackgroundTransparency = 1
    TB.Text = ""
    TB.PlaceholderText = "Cant."
    TB.TextColor3 = Color3.fromRGB(255, 255, 255)
    TB.Font = Enum.Font.Code
    TB.TextSize = 12
    TB.Parent = BoxCont
    
    TablaDeCantidades[item.en] = TB
end

-- ==========================================
-- BOTON VENDER (SECUENCIA EXACTA DEL FORENSE)
-- ==========================================
local SellBtn = Instance.new("TextButton")
SellBtn.Size = UDim2.new(1, -10, 0, 50)
SellBtn.Position = UDim2.new(0, 5, 1, -55)
SellBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 50)
SellBtn.Text = "💸 VENDER ITEMS SELECCIONADOS"
SellBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SellBtn.Font = Enum.Font.Code
SellBtn.TextSize = 13
SellBtn.Parent = Panel
Instance.new("UICorner", SellBtn).CornerRadius = UDim.new(0, 6)

SellBtn.MouseButton1Click:Connect(function()
    -- Validar dependencias
    if not RF_RunCommand then Log("❌ RunCommand no encontrado.", Color3.fromRGB(255,0,0)) return end
    if not RF_Dialogue then Log("❌ Dialogue no encontrado.", Color3.fromRGB(255,0,0)) return end
    if not RF_ForceDialogue then Log("❌ ForceDialogue no encontrado.", Color3.fromRGB(255,0,0)) return end
    if not RE_DialogueEvent then Log("❌ DialogueEvent no encontrado.", Color3.fromRGB(255,0,0)) return end
    if not SeyNPC then Log("❌ NPC Sey no encontrado.", Color3.fromRGB(255,0,0)) return end
    
    -- Construir tabla Basket
    local miBasket = {}
    local cuenta = 0
    for nombreEN, textBox in pairs(TablaDeCantidades) do
        if textBox.Text ~= "" then
            local cant = tonumber(textBox.Text)
            if cant and cant > 0 then
                miBasket[nombreEN] = cant
                cuenta = cuenta + 1
                textBox.Text = ""
            end
        end
    end
    
    if cuenta == 0 then Log("⚠️ Escribe cantidades primero.", Color3.fromRGB(255,255,0)) return end
    
    local paqueteFinal = { Basket = miBasket }
    
    task.spawn(function()
        Log("══════════════════════════════════", Color3.fromRGB(100,100,100))
        Log("🚀 INICIANDO VENTA FANTASMA...", Color3.fromRGB(0, 255, 255))
        
        local basketStr = "{"
        for k, v in pairs(miBasket) do basketStr = basketStr .. k .. "=" .. v .. ", " end
        basketStr = basketStr .. "}"
        Log("📦 Basket: " .. basketStr, Color3.fromRGB(200, 200, 200))
        
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local oldCFrame = root and root.CFrame
        
        -- ========== PASO 1: ABRIR SESIÓN Y BYPASS DE DISTANCIA ==========
        Log("🗣️ [1/4] Abriendo sesión a la fuerza", Color3.fromRGB(255, 150, 0))
        local ok1, err1 = pcall(function() RF_Dialogue:InvokeServer(SeyNPC) end)
        
        -- El servidor nos teletransportó. Nos devolvemos a la mina AL INSTANTE.
        if root and oldCFrame then
            task.wait(0.1)
            root.CFrame = oldCFrame
            Log("👻 Posición restaurada (Bypass de Teleport)", Color3.fromRGB(150, 255, 150))
        end
        
        task.wait(0.2)
        pcall(function() RE_DialogueEvent:FireServer("Opened") end)
        
        -- ========== PASO 2: ACTIVAR MENÚ DE VENTA ==========
        Log("🛒 [2/4] ForceDialogue a Sey", Color3.fromRGB(255, 150, 0))
        pcall(function() RF_ForceDialogue:InvokeServer(SeyNPC, "SellConfirmMisc") end)
        task.wait(0.2)
        pcall(function() RE_DialogueEvent:FireServer("Opened") end)
        
        -- ========== PASO 3: ROBO... DIGO, VENTA DIRECTA ==========
        Log("💎 [3/4] Inyectando RunCommand...", Color3.fromRGB(255, 0, 255))
        local ok6, resp = pcall(function()
            return RF_RunCommand:InvokeServer("SellConfirm", paqueteFinal)
        end)
        
        if ok6 then
            Log("✅ ¡Transacción procesada! Revisa el oro.", Color3.fromRGB(0, 255, 0))
        else
            Log("❌ Error Paso 3: " .. tostring(resp), Color3.fromRGB(255, 0, 0))
        end
        
        -- ========== PASO 4: DESBLOQUEO TÁCTICO DEL JUGADOR ==========
        Log("🔓 [4/4] Limpiando UI y liberando personaje...", Color3.fromRGB(255, 150, 0))
        
        -- 1. Cerrar a nivel Servidor
        pcall(function() RE_DialogueEvent:FireServer("Closed") end)
        
        -- 2. Matar el diálogo en pantalla forzando clics en "Adiós" u ocultándolo
        local adiosEncontrado = false
        pcall(function()
            for _, obj in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if obj:IsA("TextButton") and obj.Visible then
                    local txt = string.lower(obj.Text)
                    if string.find(txt, "adi") or string.find(txt, "bye") or string.find(txt, "close") or string.find(txt, "2.") or string.find(txt, "2]") then
                        for _, conn in pairs(getconnections(obj.MouseButton1Click)) do conn:Fire() end
                        adiosEncontrado = true
                    end
                end
                
                -- Ocultar el UI a la bruta por si acaso
                if obj.Name == "Dialogue" or obj.Name == "MerchantShop" then
                    if obj:IsA("GuiObject") then obj.Visible = false end
                end
            end
        end)
        
        -- 3. Restaurar velocidad de movimiento y salto (anti-pegado)
        pcall(function()
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    hum.WalkSpeed = 16
                    hum.JumpPower = 50
                    -- Si usan Atributos locales para bloquear
                    hum:SetAttribute("DialogueOpen", false)
                    hum:SetAttribute("Stunned", false)
                end
                -- Restaurar controles de PlayerModule si Knit los apagó
                local PlayerModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))
                local controls = PlayerModule:GetControls()
                if controls then controls:Enable() end
            end
        end)
        
        Log("✅ ¡LISTO! Limpio y sin pisar la tienda.", Color3.fromRGB(0, 255, 255))
        Log("══════════════════════════════════", Color3.fromRGB(100,100,100))
    end)
end)

Log("💎 ModGhost 6.0: Escoge ítems, pon la cant, y clica Vender.")
