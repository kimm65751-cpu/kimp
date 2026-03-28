-- ==============================================================================
-- 💎 AUTO-VENDEDOR PRO V3.0 (BYPASS DE ESTADO & FORENSE)
-- ==============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- BUSCADOR DE REMOTOS AVANZADO
-- ==========================================
local RF_RunCommand = nil
local RE_DialogueEvent = nil
local RF_ForceDialogue = nil
local RF_Dialogue = nil
local SeyNPC = nil

for _, obj in pairs(Workspace:GetDescendants()) do
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
-- DICCIONARIO
-- ==========================================
local MINERALES = {
    {es="Cuarzo", en="Quartz", color=Color3.fromRGB(200, 200, 200)},
    {es="Excremento", en="Excrement", color=Color3.fromRGB(150, 100, 80)},
    {es="Cobalto", en="Cobalt", color=Color3.fromRGB(150, 150, 255)},
    {es="Esmeralda", en="Emerald", color=Color3.fromRGB(50, 255, 100)},
    {es="Zafiro", en="Sapphire", color=Color3.fromRGB(100, 150, 255)},
    {es="Diamante", en="Diamond", color=Color3.fromRGB(150, 200, 255)},
    {es="Mina ocular", en="Eye Mine", color=Color3.fromRGB(255, 150, 50)},
    {es="Fichillium", en="Fichillium", color=Color3.fromRGB(255, 255, 100)},
    {es="Ametista", en="Amethyst", color=Color3.fromRGB(200, 100, 255)},
    {es="Esencia pequeña", en="Small Essence", color=Color3.fromRGB(220, 220, 220)},
}

-- ==========================================
-- GUI CON CONSOLA FORENSE
-- ==========================================
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "AutoVendorProUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoVendorProUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 480, 0, 550)
Panel.Position = UDim2.new(0, 50, 0.5, -275)
Panel.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(100, 150, 255)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(20, 40, 80)
Title.Text = " 💎 VENDE MINERALES REMOTO (V3.0 - LOGS)eeeee"
Title.TextColor3 = Color3.fromRGB(200, 220, 255)
Title.TextSize = 13
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Panel

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.Code
CloseBtn.Parent = Panel
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Consola de Logs (NUEVO)
local TermHeader = Instance.new("Frame")
TermHeader.Size = UDim2.new(1, -10, 0, 20)
TermHeader.Position = UDim2.new(0, 5, 0, 40)
TermHeader.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TermHeader.Parent = Panel

local ClearLogBtn = Instance.new("TextButton")
ClearLogBtn.Size = UDim2.new(0, 60, 1, 0)
ClearLogBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ClearLogBtn.Text = "🗑️ LIMP"
ClearLogBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearLogBtn.Font = Enum.Font.Code
ClearLogBtn.TextSize = 10
ClearLogBtn.Parent = TermHeader

local CopyLogBtn = Instance.new("TextButton")
CopyLogBtn.Size = UDim2.new(0, 80, 1, 0)
CopyLogBtn.Position = UDim2.new(0, 65, 0, 0)
CopyLogBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
CopyLogBtn.Text = "📋 COPIAR"
CopyLogBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyLogBtn.Font = Enum.Font.Code
CopyLogBtn.TextSize = 10
CopyLogBtn.Parent = TermHeader

local TermScroll = Instance.new("ScrollingFrame")
TermScroll.Size = UDim2.new(1, -10, 0, 100)
TermScroll.Position = UDim2.new(0, 5, 0, 60)
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

ClearLogBtn.MouseButton1Click:Connect(function()
    for _, v in ipairs(TermScroll:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
    LogHistory = {}
end)

CopyLogBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard(table.concat(LogHistory, "\n")) end)
    CopyLogBtn.Text = "✅ COPIADO"
    task.delay(1.5, function() CopyLogBtn.Text = "📋 COPIAR" end)
end)

-- Estado de los Remotos
Log((RF_RunCommand and "✅ RunCommand " or "❌ RunCommand ") .. 
    (RE_DialogueEvent and "✅ DialogueEvent " or "❌ DialogueEvent ") .. 
    (SeyNPC and "✅ NPC_Sey " or "❌ NPC_Sey"))

-- Lista SCROLL de Items
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -225)
Scroll.Position = UDim2.new(0, 5, 0, 165)
Scroll.BackgroundColor3 = Color3.fromRGB(10, 15, 20)
Scroll.ScrollBarThickness = 6
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Panel
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 3)

local TablaDeCantidades = {} 

for i, item in ipairs(MINERALES) do
    local fila = Instance.new("Frame")
    fila.Size = UDim2.new(1, -10, 0, 30)
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
    BoxCont.Size = UDim2.new(0.35, 0, 0, 22)
    BoxCont.Position = UDim2.new(0.65, -5, 0.5, -11)
    BoxCont.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    BoxCont.BorderSizePixel = 1
    BoxCont.BorderColor3 = item.color
    BoxCont.Parent = fila
    
    local TB = Instance.new("TextBox")
    TB.Size = UDim2.new(1, 0, 1, 0)
    TB.BackgroundTransparency = 1
    TB.Text = ""
    TB.PlaceholderText = "Cant. a vender"
    TB.TextColor3 = Color3.fromRGB(255, 255, 255)
    TB.Font = Enum.Font.Code
    TB.TextSize = 12
    TB.Parent = BoxCont
    
    TablaDeCantidades[item.en] = TB
end

local function SmartDump(val)
    if type(val) == "table" then
        local s = "{"
        for k,v in pairs(val) do s = s .. tostring(k) .. "=" .. tostring(v) .. ", " end
        return s .. "}"
    end
    return tostring(val)
end

-- Boton VENDER
local SellBtn = Instance.new("TextButton")
SellBtn.Size = UDim2.new(1, -10, 0, 50)
SellBtn.Position = UDim2.new(0, 5, 1, -55)
SellBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 50)
SellBtn.Text = "💸 EJECUTAR VENTA Y VER LOGS"
SellBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SellBtn.Font = Enum.Font.Code
SellBtn.TextSize = 12
SellBtn.Parent = Panel
Instance.new("UICorner", SellBtn).CornerRadius = UDim.new(0, 6)

SellBtn.MouseButton1Click:Connect(function()
    if not RF_RunCommand then Log("❌ NO EXISTE RunCommand.", Color3.fromRGB(255,0,0)) return end
    
    local miBasket = {}
    local cuenta = 0
    for nombreEN, textBox in pairs(TablaDeCantidades) do
        if textBox.Text ~= "" then
            local cant = tonumber(textBox.Text)
            if cant and cant > 0 then
                miBasket[nombreEN] = cant
                cuenta = cuenta + 1
            end
        end
    end
    
    if cuenta == 0 then Log("⚠️ Escribe cuantas esencias/minerales quieres bajar.", Color3.fromRGB(255,255,0)) return end
    
    local paqueteFinal = { Basket = miBasket }
    
    task.spawn(function()
        Log("==============================", Color3.fromRGB(100,100,100))
        Log("🚀 INICIANDO HANDSHAKE DE VENTA...", Color3.fromRGB(0, 255, 255))
        Log("📦 Basket: " .. SmartDump(miBasket), Color3.fromRGB(200, 200, 200))
        
        -- PASO 1: Iniciar charla con Sey para registrar la sesión en el servidor
        if RF_Dialogue and SeyNPC then
            Log("🗣️ 1. Invocando Dialogue con SeyNPC", Color3.fromRGB(255, 150, 0))
            pcall(function() RF_Dialogue:InvokeServer(SeyNPC) end)
        else
            Log("⚠️ RF_Dialogue no encontrado, podría fallar...", Color3.fromRGB(255, 0, 0))
        end
        
        -- PASO 2: Abrir canal de texto
        if RE_DialogueEvent then
            Log("🔓 2. DialogueEvent -> 'Opened'", Color3.fromRGB(255, 150, 0))
            pcall(function() RE_DialogueEvent:FireServer("Opened") end)
        end
        
        -- PASO 3: Transición a Modo Venta Misc
        if RF_ForceDialogue and SeyNPC then
            Log("🛒 3. ForceDialogue -> 'SellConfirmMisc'", Color3.fromRGB(255, 150, 0))
            pcall(function() RF_ForceDialogue:InvokeServer(SeyNPC, "SellConfirmMisc") end)
        end
        
        -- PASO 4: Confirmar apertura del sub-menú (lo que vimos en logs)
        if RE_DialogueEvent then
            Log("🔓 4. DialogueEvent -> 'Opened' (Sub-menú)", Color3.fromRGB(255, 150, 0))
            pcall(function() RE_DialogueEvent:FireServer("Opened") end)
        end
        
        -- PASO 5: LA ORDEN REAL DE VENTA CON NUESTRA TABLA
        Log("💰 5. RunCommand('SellConfirm', Basket)", Color3.fromRGB(255, 0, 255))
        local exito, resp1, resp2 = pcall(function()
            return RF_RunCommand:InvokeServer("SellConfirm", paqueteFinal)
        end)
        
        if exito then
            Log("📥 Respuesta de Server: " .. SmartDump(resp1) .. " | " .. SmartDump(resp2), Color3.fromRGB(0, 255, 0))
            Log("💬 MIRA EL JUEGO: Si te dice 'Te daré X oro', dale a 1.[Acuerdo.]", Color3.fromRGB(255, 255, 0))
        else
            Log("❌ Error Interno CRASH: " .. tostring(resp1), Color3.fromRGB(255, 0, 0))
        end
        
        Log("✅ Handshake enviado. Cruza los dedos.", Color3.fromRGB(0, 255, 255))
    end)
end)
