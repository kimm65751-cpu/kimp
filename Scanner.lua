-- ==============================================================================
-- 💎 AUTO-VENDEDOR PRO V2.0 (SAFE MODE: SOLO MINERALES Y ESENCIAS)
-- Venta remota con colores de rareza y cero riesgo de vender armas.
-- Falsifica el 'Basket' y lo manda al servidor mediante 'RunCommand'.
-- ==============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Buscar Remoto de Venta
local RF_RunCommand = nil
for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteFunction") and obj.Name == "RunCommand" then
        RF_RunCommand = obj
        break
    end
end

-- ==========================================
-- DICCIONARIO DE MINERALES Y DROPS
-- (NameES = Visual, NameEN = Lo que el server lee, Rarity = Color)
-- ==========================================
local MINERALES = {
    -- COMUNES (GRIS/BLANCO)
    {es="Boneita", en="Boneita", color=Color3.fromRGB(200, 200, 200)},
    {es="Cuarzo", en="Quartz", color=Color3.fromRGB(200, 200, 200)},
    {es="Cuprita", en="Cuprite", color=Color3.fromRGB(200, 200, 200)},
    {es="Excremento", en="Excrement", color=Color3.fromRGB(150, 100, 80)},
    {es="Cartonita", en="Cartonite", color=Color3.fromRGB(200, 200, 200)},
    {es="Aite", en="Aite", color=Color3.fromRGB(200, 200, 200)},
    {es="Cobalto", en="Cobalt", color=Color3.fromRGB(150, 150, 255)},
    
    -- POCO COMUNES / RAROS (VERDE / AZUL)
    {es="Topaz", en="Topaz", color=Color3.fromRGB(100, 255, 100)},
    {es="Esmeralda", en="Emerald", color=Color3.fromRGB(50, 255, 100)},
    {es="Bananita", en="Bananite", color=Color3.fromRGB(255, 255, 50)},
    {es="Titánio", en="Titanium", color=Color3.fromRGB(180, 200, 255)},
    {es="Zafiro", en="Sapphire", color=Color3.fromRGB(100, 150, 255)},
    {es="Lapis Lazuli", en="Lapis Lazuli", color=Color3.fromRGB(50, 100, 255)},
    {es="Diamante", en="Diamond", color=Color3.fromRGB(150, 200, 255)},
    {es="Mina ocular", en="Eye Mine", color=Color3.fromRGB(255, 150, 50)},
    {es="Fichillium", en="Fichillium", color=Color3.fromRGB(255, 255, 100)},
    {es="Ametista", en="Amethyst", color=Color3.fromRGB(200, 100, 255)},
    
    -- ESENCIAS
    {es="Esencia pequeña", en="Small Essence", color=Color3.fromRGB(220, 220, 220)},
    {es="Esencia mediana", en="Medium Essence", color=Color3.fromRGB(150, 255, 150)},
    {es="Esencia grande", en="Large Essence", color=Color3.fromRGB(100, 200, 255)},
    {es="Esencia superior", en="Superior Essence", color=Color3.fromRGB(255, 150, 255)},
    {es="Chispa de fuego", en="Fire Spark", color=Color3.fromRGB(255, 100, 50)},
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
Panel.Size = UDim2.new(0, 420, 0, 500)
Panel.Position = UDim2.new(0, 50, 0.5, -250)
Panel.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(100, 150, 255)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(20, 40, 80)
Title.Text = " 💎 VENDE MINERALES REMOTO (SEGURO)"
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

-- Lista SCROLL de Items
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -100)
Scroll.Position = UDim2.new(0, 5, 0, 40)
Scroll.BackgroundColor3 = Color3.fromRGB(10, 15, 20)
Scroll.ScrollBarThickness = 6
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Panel
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 3)

local TablaDeCantidades = {} -- Referencias a los TextBox

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
    
    TablaDeCantidades[item.en] = TB -- Guardamos referencia usando nombre en INGLÉS
end

-- Boton VENDER
local SellBtn = Instance.new("TextButton")
SellBtn.Size = UDim2.new(1, -10, 0, 50)
SellBtn.Position = UDim2.new(0, 5, 1, -55)
SellBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 50)
SellBtn.Text = "💸 VENDER ITEMS SELECCIONADOS AL SERVIDOR"
SellBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SellBtn.Font = Enum.Font.Code
SellBtn.TextSize = 12
SellBtn.Parent = Panel
Instance.new("UICorner", SellBtn).CornerRadius = UDim.new(0, 6)

SellBtn.MouseButton1Click:Connect(function()
    if not RF_RunCommand then
        SellBtn.Text = "❌ Remoto de venta NO encontrado"
        SellBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        return
    end
    
    -- Construimos la tabla secreta "Basket"
    local miBasket = {}
    local hayAlgoQueVender = false
    
    for nombreEN, textBox in pairs(TablaDeCantidades) do
        local txt = textBox.Text
        if txt and txt ~= "" then
            local cantidad = tonumber(txt)
            if cantidad and cantidad > 0 then
                miBasket[nombreEN] = cantidad
                hayAlgoQueVender = true
                -- Limpiar caja después de vender
                textBox.Text = "" 
            end
        end
    end
    
    if not hayAlgoQueVender then
        SellBtn.Text = "⚠️ No pusiste cantidades en ningún mineral!"
        task.delay(2, function() SellBtn.Text = "💸 VENDER ITEMS SELECCIONADOS AL SERVIDORR" end)
        return
    end
    
    -- Empaqueta y manda al servidor!
    local paqueteFinal = {
        Basket = miBasket
    }
    
    task.spawn(function()
        SellBtn.Text = "⏳ ENVIANDO AL SERVIDOR..."
        SellBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 0)
        
        local exito, resp = pcall(function()
            return RF_RunCommand:InvokeServer("SellConfirm", paqueteFinal)
        end)
        
        if exito then
            SellBtn.Text = "✅ ¡VENTA COMPLETADA CON ÉXITO!"
            SellBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        else
            SellBtn.Text = "❌ ERROR: " .. tostring(resp)
            SellBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        end
        
        task.delay(3, function() 
            SellBtn.Text = "💸 VENDER ITEMS SELECCIONADOS AL SERVIDOR" 
            SellBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 50)
        end)
    end)
end)

print("💎 AutoVendedor PRO V2.0 Cargado!")
