-- ==============================================================================
-- 💎 AUTO-VENDEDOR PRO V9.1 (REMASTERIZADO & DEBUG DE VENTA)
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
    if obj:IsA("Model") and string.find(string.lower(obj.Name), "cey") then SeyNPC = obj break end
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
-- MINERALES 
-- ==========================================
local MINERALES = {
    {es="Excremento",       en="Excrement",       color=Color3.fromRGB(150, 100, 80)},
    {es="Cartonita",        en="Cartonite",        color=Color3.fromRGB(200, 200, 200)},
    {es="Boneita",          en="Boneita",          color=Color3.fromRGB(200, 200, 200)},
    {es="Aite",             en="Aite",             color=Color3.fromRGB(200, 200, 200)},
    {es="Cuarzo",           en="Quartz",           color=Color3.fromRGB(150, 200, 150)},
    {es="Cuprita",          en="Cuprite",          color=Color3.fromRGB(200, 100, 100)},
    {es="Cobalto",          en="Cobalt",           color=Color3.fromRGB(150, 150, 255)},
    {es="Topaz",            en="Topaz",            color=Color3.fromRGB(100, 255, 100)},
    {es="Bananita",         en="Bananite",         color=Color3.fromRGB(255, 255, 50)},
    {es="Esmeralda",        en="Emerald",          color=Color3.fromRGB(50, 255, 100)},
    {es="Zafiro",           en="Sapphire",         color=Color3.fromRGB(100, 150, 255)},
    {es="Esencia pequeña",  en="Small Essence",    color=Color3.fromRGB(220, 220, 220)},
    {es="Chispa de fuego",  en="Fire Spark",       color=Color3.fromRGB(255, 100, 50)}
}

-- ==========================================
-- GUI NÚCLEO
-- ==========================================
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "AutoVendorProUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoVendorProUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 520, 0, 580)
Panel.Position = UDim2.new(0, 50, 0.5, -290)
Panel.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 40, 80)
Title.Text = " 💎 AUTO VENDEDOR PRO V9.1 (DEBUG)"
Title.TextColor3 = Color3.fromRGB(200, 220, 255)
Title.TextSize = 13
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Panel

local CapacidadInfo = Instance.new("TextLabel")
CapacidadInfo.Size = UDim2.new(0, 150, 0, 30)
CapacidadInfo.Position = UDim2.new(1, -200, 0, 0)
CapacidadInfo.BackgroundTransparency = 1
CapacidadInfo.Text = "Espacio: ?/?"
CapacidadInfo.TextColor3 = Color3.fromRGB(255, 255, 0)
CapacidadInfo.TextSize = 12
CapacidadInfo.Font = Enum.Font.Code
CapacidadInfo.Parent = Panel

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Parent = Panel
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local TermScroll = Instance.new("ScrollingFrame")
TermScroll.Size = UDim2.new(1, -10, 0, 140)
TermScroll.Position = UDim2.new(0, 5, 0, 35)
TermScroll.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
TermScroll.ScrollBarThickness = 6
TermScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
TermScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TermScroll.Parent = Panel
Instance.new("UIListLayout", TermScroll).Padding = UDim.new(0, 2)

local function Log(texto, color)
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, -4, 0, 0)
    msg.BackgroundTransparency = 1
    msg.Text = "[" .. os.date("%H:%M:%S") .. "] " .. texto
    msg.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    msg.Font = Enum.Font.Code
    msg.TextSize = 10
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.TextWrapped = true
    msg.Parent = TermScroll
    local tsz = game:GetService("TextService"):GetTextSize(msg.Text, msg.TextSize, msg.Font, Vector2.new(TermScroll.AbsoluteSize.X-15, math.huge))
    msg.Size = UDim2.new(1, -4, 0, tsz.Y + 2)
    TermScroll.CanvasPosition = Vector2.new(0, 999999)
end

-- ==========================================
-- ESCUDO INTACTO DE V8
-- ==========================================
if not getgenv().InmunidadV9Activa then
    getgenv().InmunidadV9Activa = true
    local OriginalNewIndex
    OriginalNewIndex = hookmetamethod(game, "__newindex", function(t, k, v)
        if not checkcaller() then
            if t:IsA("BasePart") and t.Name == "HumanoidRootPart" and k == "Anchored" and v == true then return end
            if t:IsA("Camera") and k == "CameraType" and v ~= Enum.CameraType.Custom then return end
        end
        return OriginalNewIndex(t, k, v)
    end)
    Log("🛡️ ESCUDO METAMÉTODO ACTIVO. Inmune a parálisis de Dialogo.", Color3.fromRGB(0, 255, 255))
end

-- ==========================================
-- EJECUCIÓN DE VENTA
-- ==========================================
local function EjecutarVentaNinja(miBasket)
    if not SeyNPC then Log("❌ NPC no encontrado.", Color3.fromRGB(255,0,0)) return end
    
    task.spawn(function()
        Log("══════════════════════════════════", Color3.fromRGB(150,150,150))
        local basketStr = "{"
        for k, v in pairs(miBasket) do basketStr = basketStr .. k .. "=" .. v .. ", " end
        basketStr = basketStr .. "}"
        Log("📦 Despachando: " .. basketStr, Color3.fromRGB(255, 255, 0))
        
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local oldCFrame = root and root.CFrame
        
        -- Igual que en V8: invocamos la interfaz falsa de confirmación del NPC
        local ok1, e1 = pcall(function() RF_ForceDialogue:InvokeServer(SeyNPC, "SellConfirmMisc") end)
        task.wait(0.2)
        pcall(function() RE_DialogueEvent:FireServer("Opened") end)
        
        -- Ejecución idéntica a V8 pura
        local paqueteFinal = { Basket = miBasket }
        Log("💎 Inyectando Venta al Servidor...", Color3.fromRGB(255, 0, 255))
        
        local ok2, resp = pcall(function() 
            return RF_RunCommand:InvokeServer("SellConfirm", paqueteFinal) 
        end)
        
        if ok2 then 
            if resp == nil then
                Log("✅ ¡Transacción Procesada (El Servidor la Aceptó)!", Color3.fromRGB(0, 255, 0)) 
            else
                Log("⚠️ Servidor Respondió: " .. tostring(resp), Color3.fromRGB(255, 100, 100))
            end
        else
            Log("❌ Error Remoto Crítico: " .. tostring(resp), Color3.fromRGB(255, 0, 0))
        end
        
        if root and oldCFrame then root.CFrame = oldCFrame end
        
        task.wait(0.5)
        
        -- Cierre de Interfaces V8
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
        Log("══════════════════════════════════", Color3.fromRGB(150,150,150))
    end)
end

-- ==========================================
-- BUSCADORES COMPATIBLES
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
                        cur = tonumber(x)
                        maxm = valY
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
                                        if n > (dir[item.es] or 0) then dir[item.es] = n end
                                    else
                                        local n2 = tonumber(child.Text)
                                        if n2 and n2 > (dir[item.es] or 0) and n2 < 99999 then dir[item.es] = n2 end
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
-- INTERFAZ GRÁFICA
-- ==========================================
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -230)
Scroll.Position = UDim2.new(0, 5, 0, 178)
Scroll.BackgroundColor3 = Color3.fromRGB(10, 15, 20)
Scroll.Parent = Panel
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 3)

for _, item in ipairs(MINERALES) do
    item.AutoCheck = false
    local fila = Instance.new("Frame", Scroll)
    fila.Size = UDim2.new(1, -10, 0, 30)
    fila.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
    
    local NameL = Instance.new("TextLabel", fila)
    NameL.Size = UDim2.new(0.35, 0, 1, 0)
    NameL.BackgroundTransparency = 1
    NameL.Text = " " .. item.es
    NameL.TextColor3 = item.color
    NameL.Font = Enum.Font.Code
    NameL.TextSize = 12
    NameL.TextXAlignment = Enum.TextXAlignment.Left
    
    local TBDir = Instance.new("TextBox", fila)
    TBDir.Size = UDim2.new(0.18, 0, 0.8, 0)
    TBDir.Position = UDim2.new(0.36, 0, 0.1, 0)
    TBDir.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    TBDir.Text = ""
    TBDir.PlaceholderText = "Cant."
    TBDir.TextColor3 = Color3.fromRGB(255,255,255)
    item.TB = TBDir
    
    local VenderTodoBtn = Instance.new("TextButton", fila)
    VenderTodoBtn.Size = UDim2.new(0.22, 0, 0.8, 0)
    VenderTodoBtn.Position = UDim2.new(0.56, 0, 0.1, 0)
    VenderTodoBtn.BackgroundColor3 = Color3.fromRGB(50, 80, 150)
    VenderTodoBtn.Text = "Vender Todo"
    VenderTodoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    VenderTodoBtn.MouseButton1Click:Connect(function()
        local miStockCache = EscanearCantidadesGlobales()
        local miCant = miStockCache[item.es] or 0
        if miCant > 0 then
            EjecutarVentaNinja({[item.en] = miCant})
        else
            Log("❌ Error: Tienes 0 " .. item.es .. " o no leo el Inventario.", Color3.fromRGB(255, 100, 100))
        end
    end)
    
    local AutoBtn = Instance.new("TextButton", fila)
    AutoBtn.Size = UDim2.new(0.18, 0, 0.8, 0)
    AutoBtn.Position = UDim2.new(0.80, 0, 0.1, 0)
    AutoBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
    AutoBtn.Text = "AUTO ❌"
    AutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    AutoBtn.MouseButton1Click:Connect(function()
        item.AutoCheck = not item.AutoCheck
        AutoBtn.BackgroundColor3 = item.AutoCheck and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(100, 50, 50)
        AutoBtn.Text = item.AutoCheck and "AUTO ✅" or "AUTO ❌"
    end)
end

local SellGlobalBtn = Instance.new("TextButton", Panel)
SellGlobalBtn.Size = UDim2.new(1, -10, 0, 45)
SellGlobalBtn.Position = UDim2.new(0, 5, 1, -50)
SellGlobalBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 50)
SellGlobalBtn.Text = "🛠️ VENDER TODOS LOS CAMPOS MANUALES"
SellGlobalBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SellGlobalBtn.Font = Enum.Font.Code
SellGlobalBtn.TextSize = 13

SellGlobalBtn.MouseButton1Click:Connect(function()
    local miBasket = {}
    local c = 0
    for _, item in ipairs(MINERALES) do
        if item.TB.Text ~= "" then
            local cant = tonumber(item.TB.Text)
            if cant and cant > 0 then
                miBasket[item.en] = cant
                c = c + 1
                item.TB.Text = ""
            end
        end
    end
    if c > 0 then EjecutarVentaNinja(miBasket) else Log("⚠️ Escribe cantidades manuales antes.", Color3.fromRGB(255,255,0)) end
end)

task.spawn(function()
    while true do
        task.wait(4)
        local current, maxm = ObtenerCapacidad()
        if current and maxm then
            CapacidadInfo.Text = "Espacio: " .. current .. "/" .. maxm
            if current >= (maxm - 5) then
                local autoBasket = {}
                local count = 0
                local stockGlobal = EscanearCantidadesGlobales()
                for _, item in ipairs(MINERALES) do
                    if item.AutoCheck then
                        local stock = stockGlobal[item.es] or 0
                        if stock > 0 then
                            autoBasket[item.en] = stock
                            count = count + 1
                        end
                    end
                end
                if count > 0 then
                    Log("☢️ ¡ALERTA! Auto-Limpiando Inventario...", Color3.fromRGB(255, 100, 50))
                    EjecutarVentaNinja(autoBasket)
                end
            end
        else
            CapacidadInfo.Text = "Abre Inventario (Detectar)"
        end
    end
end)
