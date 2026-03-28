-- ==============================================================================
-- 💎 AUTO-VENDEDOR PRO V5.0 (SECUENCIA EXACTA VERIFICADA POR FORENSE)
-- ==============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- ESCUDO ANTI-CONGELAMIENTO (PARÁLISIS INVISIBLE)
-- ==========================================
if not getgenv().InmunidadV8Activa then
    getgenv().InmunidadV8Activa = true
    local OriginalNewIndex
    OriginalNewIndex = hookmetamethod(game, "__newindex", function(t, k, v)
        if not checkcaller() then
            if t:IsA("BasePart") and t.Name == "HumanoidRootPart" and k == "Anchored" and v == true then return end
            if t:IsA("Humanoid") and (k == "WalkSpeed" and v < 16) then return end
        end
        return OriginalNewIndex(t, k, v)
    end)
end

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
    {es="Excremento",       en="Excrement",       color=Color3.fromRGB(150, 100, 80),   auto=true},
    {es="Cartonita",        en="Cartonite",       color=Color3.fromRGB(200, 200, 200),  auto=true},
    {es="Boneita",          en="Boneite",         color=Color3.fromRGB(200, 200, 200),  auto=true},
    {es="Aite",             en="Aite",            color=Color3.fromRGB(200, 200, 200),  auto=true},
    {es="Cuarzo",           en="Quartz",          color=Color3.fromRGB(200, 200, 200),  auto=true},
    {es="Cuprita",          en="Cuprite",         color=Color3.fromRGB(200, 200, 200),  auto=false},
    {es="Cobalto",          en="Cobalt",          color=Color3.fromRGB(150, 150, 255),  auto=false},
    {es="Topaz",            en="Topaz",           color=Color3.fromRGB(100, 255, 100),  auto=false},
    {es="Bananita",         en="Bananite",        color=Color3.fromRGB(255, 255, 50),   auto=false},
    {es="Esmeralda",        en="Emerald",         color=Color3.fromRGB(50, 255, 100),   auto=false},
    {es="Zafiro",           en="Sapphire",        color=Color3.fromRGB(100, 150, 255),  auto=false},
    {es="Lapis Lazuli",     en="Lapis Lazuli",    color=Color3.fromRGB(50, 100, 255),   auto=false},
    {es="Titánio",          en="Titanium",        color=Color3.fromRGB(180, 200, 255),  auto=false},
    {es="Diamante",         en="Diamond",         color=Color3.fromRGB(150, 200, 255),  auto=false},
    {es="Mina ocular",      en="Eye Mine",        color=Color3.fromRGB(255, 150, 50),   auto=false},
    {es="Fichillium",       en="Fichillium",      color=Color3.fromRGB(255, 255, 100),  auto=false},
    {es="Ametista",         en="Amethyst",        color=Color3.fromRGB(200, 100, 255),  auto=false},
    {es="Esencia pequeña",  en="Tiny Essence",    color=Color3.fromRGB(220, 220, 220),  auto=true},
    {es="Esencia mediana",  en="Medium Essence",  color=Color3.fromRGB(150, 255, 150),  auto=false},
    {es="Esencia grande",   en="Large Essence",   color=Color3.fromRGB(100, 200, 255),  auto=false},
    {es="Esencia superior", en="Superior Essence", color=Color3.fromRGB(255, 150, 255), auto=false},
    {es="Chispa de fuego",  en="Fire Spark",      color=Color3.fromRGB(255, 100, 50),   auto=false},
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

local UIS = game:GetService("UserInputService")
local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 480, 0, 400)
Panel.Position = UDim2.new(0, 50, 0.5, -200)
Panel.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(100, 150, 255)
Panel.Active = true
Panel.Parent = ScreenGui

local dragging, dragInput, dragStart, startPos
Panel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Panel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
Panel.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 40, 80)
Title.Text = " 💎 AUTO-VENDEDOR REMOTO V511.0"
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

local function Log(texto, color)
    print("[AutoVendedorPRO] " .. string.gsub(texto, "❌", "ERROR:"))
end

-- Estado
Log((RF_RunCommand and "✅ RunCommand " or "❌ RunCommand ") .. 
    (RF_Dialogue and "✅ Dialogue " or "❌ Dialogue ") .. 
    (RF_ForceDialogue and "✅ ForceDialogue " or "❌ ForceDialogue ") ..
    (RE_DialogueEvent and "✅ DialogueEvent " or "❌ DialogueEvent ") ..
    (SeyNPC and "✅ NPC" or "❌ NPC"))

-- ==========================================
-- UTILIDADES DE INVENTARIO
-- ==========================================
local InvController = nil
pcall(function() InvController = require(ReplicatedStorage.Controllers.UIController.Inventory) end)

local capacidadLabelCache = nil
local function ObtenerCapacidad()
    local cur, maxm = nil, nil
    if InvController then pcall(function() maxm = InvController:GetBagCapacity() end) end
    if not maxm then maxm = 144 end
    if capacidadLabelCache and capacidadLabelCache.Parent then
        local x, y = string.match(capacidadLabelCache.Text, "(%d+)/(%d+)")
        if x and y then return tonumber(x), tonumber(y) end
    end
    pcall(function()
        for _, obj in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Visible then
                local x, y = string.match(obj.Text, "(%d+)/(%d+)")
                if x and y then
                    local valY = tonumber(y)
                    if valY == maxm or valY == 144 then
                        cur, maxm = tonumber(x), valY
                        capacidadLabelCache = obj
                        break
                    end
                end
            end
        end
    end)
    return cur, maxm
end

local function EscanearCantidadesGlobales()
    local dir = {}
    pcall(function()
        for _, obj in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Visible then
                local txt = string.lower(obj.Text)
                for _, item in ipairs(MINERALES) do
                    if txt == string.lower(item.es) or txt == string.lower(item.en) then
                        local padre = obj.Parent
                        if padre then
                            for _, child in pairs(padre:GetDescendants()) do
                                if child:IsA("TextLabel") then
                                    local mx = string.match(child.Text, "[xX](%d+)")
                                    if mx then
                                        local n = tonumber(mx)
                                        if n > (dir[item.en] or 0) then dir[item.en] = n end
                                    else
                                        local n2 = tonumber(child.Text)
                                        if n2 and n2 > (dir[item.en] or 0) and n2 < 99999 then dir[item.en] = n2 end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    return dir
end

-- ==========================================
-- LA FUNCIÓN MAESTRA INTOCABLE DE RED (V8)
-- ==========================================
local function EjecutarVentaNinja(miBasket)
    if not RF_RunCommand or not RF_ForceDialogue or not RE_DialogueEvent or not SeyNPC then 
        Log("❌ Faltan remotos o NPC.", Color3.fromRGB(255,0,0)) return 
    end
    
    local paqueteFinal = { Basket = miBasket }
    
    task.spawn(function()
        Log("══════════════════════════════════", Color3.fromRGB(100,100,100))
        Log("🚀 INICIANDO VENTA NINJA (SIN INTERFAZ)...", Color3.fromRGB(0, 255, 255))
        
        local basketStr = "{"
        for k, v in pairs(miBasket) do basketStr = basketStr .. k .. "=" .. v .. ", " end
        basketStr = basketStr .. "}"
        Log("📦 Despachando: " .. basketStr, Color3.fromRGB(255, 255, 0))

        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local oldCFrame = root and root.CFrame
        
        -- PASO 1 (Intacto V8)
        Log("🛒 [1/3] Invocando ForceDialogue(SellConfirmMisc)", Color3.fromRGB(255, 150, 0))
        local ok1, err1 = pcall(function() RF_ForceDialogue:InvokeServer(SeyNPC, "SellConfirmMisc") end)
        task.wait(0.2)
        pcall(function() RE_DialogueEvent:FireServer("Opened") end)
        
        -- PASO 2 (Intacto V8)
        Log("💎 [2/3] Inyectando RunCommand...", Color3.fromRGB(255, 0, 255))
        local ok2, resp = pcall(function() return RF_RunCommand:InvokeServer("SellConfirm", paqueteFinal) end)
        
        if ok2 then
            Log("✅ ¡Transacción Procesada! (Revisa tu Oro)", Color3.fromRGB(0, 255, 0))
        else
            Log("❌ Error Paso 2: " .. tostring(resp), Color3.fromRGB(255, 0, 0))
        end
        
        if root and oldCFrame then root.CFrame = oldCFrame end
        task.wait(0.5)
        
        -- PASO 3 (Intacto V8)
        Log("🔓 [3/3] Auto-Clickeando el botón 'Adiós'...", Color3.fromRGB(255, 150, 0))
        pcall(function()
            for _, obj in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if obj:IsA("TextButton") and obj.Visible then
                    local t = string.lower(obj.Text)
                    if string.find(t, "adi") or string.find(t, "bye") or string.find(t, "2.") or string.find(t, "2%]") then
                        pcall(function() firesignal(obj.MouseButton1Click) end)
                        pcall(function() for _, c in pairs(getconnections(obj.MouseButton1Click)) do c:Fire() end end)
                    end
                end
            end
        end)
        pcall(function() RE_DialogueEvent:FireServer("Closed") end)
        Log("✅ ¡LISTO! Venta remota completada en Modo Dios 8.1", Color3.fromRGB(0, 255, 255))
        Log("══════════════════════════════════", Color3.fromRGB(100,100,100))
    end)
end

-- ==========================================
-- INTERFAZ
-- ==========================================
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -95)
Scroll.Position = UDim2.new(0, 5, 0, 35)
Scroll.BackgroundColor3 = Color3.fromRGB(10, 15, 20)
Scroll.ScrollBarThickness = 6
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Panel
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 3)

local CapacidadInfo = Instance.new("TextLabel")
CapacidadInfo.Size = UDim2.new(0, 150, 0, 30)
CapacidadInfo.Position = UDim2.new(1, -200, 0, 0)
CapacidadInfo.BackgroundTransparency = 1
CapacidadInfo.Text = "Espacio: ?/?"
CapacidadInfo.TextColor3 = Color3.fromRGB(255, 255, 0)
CapacidadInfo.TextSize = 12
CapacidadInfo.Font = Enum.Font.Code
CapacidadInfo.Parent = Panel

local TablaDeCantidades = {}

for _, item in ipairs(MINERALES) do
    local fila = Instance.new("Frame")
    fila.Size = UDim2.new(1, -10, 0, 30)
    fila.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
    fila.Parent = Scroll
    
    local NameL = Instance.new("TextLabel")
    NameL.Size = UDim2.new(0.35, 0, 1, 0)
    NameL.BackgroundTransparency = 1
    NameL.Text = " " .. item.es
    NameL.TextColor3 = item.color
    NameL.Font = Enum.Font.Code
    NameL.TextSize = 12
    NameL.TextXAlignment = Enum.TextXAlignment.Left
    NameL.Parent = fila
    
    local TBDir = Instance.new("TextBox")
    TBDir.Size = UDim2.new(0.18, 0, 0.8, 0)
    TBDir.Position = UDim2.new(0.36, 0, 0.1, 0)
    TBDir.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    TBDir.Text = ""
    TBDir.PlaceholderText = "Cant."
    TBDir.TextColor3 = Color3.fromRGB(255,255,255)
    TBDir.Parent = fila
    TablaDeCantidades[item.en] = TBDir
    
    local VenderTodoBtn = Instance.new("TextButton", fila)
    VenderTodoBtn.Size = UDim2.new(0.22, 0, 0.8, 0)
    VenderTodoBtn.Position = UDim2.new(0.56, 0, 0.1, 0)
    VenderTodoBtn.BackgroundColor3 = Color3.fromRGB(50, 80, 150)
    VenderTodoBtn.Text = "Vender Todo"
    VenderTodoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    VenderTodoBtn.MouseButton1Click:Connect(function()
        local miStockCache = EscanearCantidadesGlobales()
        local miCant = miStockCache[item.en] or 0
        if miCant > 0 then
            Log("🔍 Detectado " .. miCant .. "x " .. item.es, Color3.fromRGB(0, 255, 0))
            EjecutarVentaNinja({[item.en] = miCant})
        else
            Log("❌ Error: Tienes 0 " .. item.es .. " o no leo el Inventario.", Color3.fromRGB(255, 100, 100))
        end
    end)
    
    local AutoBtn = Instance.new("TextButton", fila)
    AutoBtn.Size = UDim2.new(0.18, 0, 0.8, 0)
    AutoBtn.Position = UDim2.new(0.80, 0, 0.1, 0)
    AutoBtn.BackgroundColor3 = item.auto and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
    AutoBtn.Text = item.auto and "AUTO ✅" or "AUTO ❌"
    AutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoBtn.MouseButton1Click:Connect(function()
        item.auto = not item.auto
        AutoBtn.BackgroundColor3 = item.auto and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
        AutoBtn.Text = item.auto and "AUTO ✅" or "AUTO ❌"
    end)
end

local SellBtn = Instance.new("TextButton")
SellBtn.Size = UDim2.new(1, -10, 0, 50)
SellBtn.Position = UDim2.new(0, 5, 1, -55)
SellBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 50)
SellBtn.Text = "🛠️ VENDER CAMPOS MANUALES"
SellBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SellBtn.Font = Enum.Font.Code
SellBtn.TextSize = 13
SellBtn.Parent = Panel
Instance.new("UICorner", SellBtn).CornerRadius = UDim.new(0, 6)

SellBtn.MouseButton1Click:Connect(function()
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
    if cuenta > 0 then EjecutarVentaNinja(miBasket) else Log("⚠️ Escribe cantidades manuales antes.", Color3.fromRGB(255,255,0)) end
end)

-- BUCLE AUTOMÁTICO DE ESCANEO DE INVENTARIO
task.spawn(function()
    while true do
        task.wait(4)
        local cur, maxm = ObtenerCapacidad()
        if cur and maxm then
            CapacidadInfo.Text = "Espacio: " .. cur .. "/" .. maxm
            if cur >= (maxm - 5) then
                local autoBasket = {}
                local count = 0
                local stockGlobal = EscanearCantidadesGlobales()
                for _, item in ipairs(MINERALES) do
                    if item.auto then
                        local stock = stockGlobal[item.en] or 0
                        if stock > 0 then
                            autoBasket[item.en] = stock
                            count = count + 1
                        end
                    end
                end
                if count > 0 then
                    Log("☢️ INVENTARIO LLENO. Auto-Limpiando...", Color3.fromRGB(255, 100, 50))
                    EjecutarVentaNinja(autoBasket)
                end
            end
        else
            CapacidadInfo.Text = "Abre Inventario (Detectar)"
        end
    end
end)

Log("💎 Integración de Escáner y Venta Segura Completa.")
