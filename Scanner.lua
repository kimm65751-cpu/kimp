-- ==============================================================================
-- 💎 AUTO-VENDEDOR PRO V9.0 (MODO DIOS Y AUTO-LIMPIEZA ÓPTICA)
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
-- DICCIONARIO SEGURO (SOLO RANGOS BAJOS / INTERMEDIOS)
-- ==========================================
local MINERALES_SEGUROS = {
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
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(100, 150, 255)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 40, 80)
Title.Text = " 💎 MÁQUINA DE LIMPIEZA INVENTARIO V9.0"
Title.TextColor3 = Color3.fromRGB(200, 220, 255)
Title.TextSize = 13
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Panel

local CapacidadInfo = Instance.new("TextLabel")
CapacidadInfo.Size = UDim2.new(0, 150, 0, 30)
CapacidadInfo.Position = UDim2.new(1, -200, 0, 0)
CapacidadInfo.BackgroundTransparency = 1
CapacidadInfo.Text = "Cargando Espacio..."
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
CloseBtn.Font = Enum.Font.Code
CloseBtn.Parent = Panel
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- CONSOLA DE LOGS
local TermScroll = Instance.new("ScrollingFrame")
TermScroll.Size = UDim2.new(1, -10, 0, 140)
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
    msg.TextSize = 10
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
LogControls.Position = UDim2.new(0, 5, 0, 178)
LogControls.BackgroundTransparency = 1
LogControls.Parent = Panel

local ClearLogBtn = Instance.new("TextButton")
ClearLogBtn.Size = UDim2.new(1, 0, 1, 0)
ClearLogBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ClearLogBtn.Text = "🗑️ LIMPIAR LOG"
ClearLogBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearLogBtn.Font = Enum.Font.Code
ClearLogBtn.TextSize = 10
ClearLogBtn.Parent = LogControls
ClearLogBtn.MouseButton1Click:Connect(function()
    for _, v in ipairs(TermScroll:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
    LogHistory = {}
end)

-- ==========================================
-- EL ESCUDO DE PARÁLISIS (V8 INTACTO)
-- ==========================================
if not getgenv().InmunidadV9Activa then
    getgenv().InmunidadV9Activa = true
    local OriginalNewIndex
    OriginalNewIndex = hookmetamethod(game, "__newindex", function(t, k, v)
        if not checkcaller() then
            if t:IsA("BasePart") and t.Name == "HumanoidRootPart" and k == "Anchored" and v == true then return end
            if t:IsA("Camera") and k == "CameraType" and v ~= Enum.CameraType.Custom then return end
            if t:IsA("Humanoid") and (k == "WalkSpeed" and v < 16) then return end
        end
        return OriginalNewIndex(t, k, v)
    end)
    Log("🛡️ ESCUDO METAMÉTODO ACTIVO. Inmune a parálisis.", Color3.fromRGB(0, 255, 255))
end

-- ==========================================
-- MOTOR BASE DE VENTA NINJA (NÚCLEO V8.1)
-- ==========================================
local function EjecutarVentaNinja(miBasket)
    if not SeyNPC or not RF_ForceDialogue or not RF_RunCommand or not RE_DialogueEvent then
        Log("❌ Error Faltan remotos o SeyNPC.", Color3.fromRGB(255,0,0)) return
    end
    
    task.spawn(function()
        Log("══════════════════════════════════", Color3.fromRGB(150,150,150))
        Log("🚀 EJECUTANDO EXTRACCIÓN NINJA...", Color3.fromRGB(0, 255, 255))
        
        local basketStr = "{"
        for k, v in pairs(miBasket) do basketStr = basketStr .. k .. "=" .. v .. ", " end
        basketStr = basketStr .. "}"
        Log("📦 Despachando: " .. basketStr, Color3.fromRGB(200, 200, 200))
        
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local oldCFrame = root and root.CFrame
        
        pcall(function() RF_ForceDialogue:InvokeServer(SeyNPC, "SellConfirmMisc") end)
        task.wait(0.2)
        pcall(function() RE_DialogueEvent:FireServer("Opened") end)
        
        local ok2, resp = pcall(function() return RF_RunCommand:InvokeServer("SellConfirm", {Basket = miBasket}) end)
        if ok2 then Log("💰 ¡DINERO COBRADO!", Color3.fromRGB(0, 255, 0)) end
        
        if root and oldCFrame then root.CFrame = oldCFrame end -- Teleport Bypass
        
        task.wait(0.5)
        
        -- Cierre Táctico
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
-- ESCÁNER ÓPTICO DE INVENTARIO
-- ==========================================
local function EscanearCantidad(nombreES)
    local mayorCant = 0
    pcall(function()
        for _, obj in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if (obj:IsA("TextLabel") and obj.Visible and string.lower(obj.Text) == string.lower(nombreES)) then
                -- Escanea alrededor del nombre buscando el "x15"
                local framePadre = obj.Parent
                if framePadre then
                    for _, child in pairs(framePadre:GetDescendants()) do
                        if child:IsA("TextLabel") then
                            local mtch = string.match(child.Text, "[xX](%d+)")
                            if mtch then
                                local num = tonumber(mtch)
                                if num > mayorCant then mayorCant = num end
                            else
                                local n2 = tonumber(child.Text)
                                if n2 and n2 > mayorCant and n2 < 99999 then mayorCant = n2 end
                            end
                        end
                    end
                end
            end
        end
    end)
    return mayorCant
end

local InvController = nil
pcall(function()
    InvController = require(ReplicatedStorage.Controllers.UIController.Inventory)
end)

local function ObtenerCapacidad()
    -- 1. Intento por Memoria Profunda (Knit Controller)
    if InvController then
        local okC, cur = pcall(function()
            if type(InvController.CalculateTotal) == "function" then
                return InvController:CalculateTotal()
            end
        end)
        local okM, maxm = pcall(function()
            if type(InvController.GetBagCapacity) == "function" then
                return InvController:GetBagCapacity()
            end
        end)
        
        if okC and okM and type(cur) == "number" and type(maxm) == "number" then
            return cur, maxm
        end
    end
    
    -- 2. Fallback: Escáner Óptico de Interfaz
    local c, m = nil, nil
    pcall(function()
        for _, obj in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Visible then
                if string.find(string.lower(obj.Text), "capacidad") then
                    local x, y = string.match(obj.Text, "(%d+)/(%d+)")
                    if x and y then c, m = tonumber(x), tonumber(y) break end
                end
            end
        end
    end)
    return c, m
end

-- ==========================================
-- GENERACIÓN DE INTERFAZ FILTRADA
-- ==========================================
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -260)
Scroll.Position = UDim2.new(0, 5, 0, 203)
Scroll.BackgroundColor3 = Color3.fromRGB(10, 15, 20)
Scroll.ScrollBarThickness = 6
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Panel
Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 3)

for _, item in ipairs(MINERALES_SEGUROS) do
    item.AutoCheck = false -- Estado del auto-farm
    
    local fila = Instance.new("Frame")
    fila.Size = UDim2.new(1, -10, 0, 30)
    fila.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
    fila.Parent = Scroll
    
    -- NOMBRE
    local NameL = Instance.new("TextLabel")
    NameL.Size = UDim2.new(0.35, 0, 1, 0)
    NameL.Position = UDim2.new(0, 5, 0, 0)
    NameL.BackgroundTransparency = 1
    NameL.Text = item.es
    NameL.TextColor3 = item.color
    NameL.Font = Enum.Font.Code
    NameL.TextSize = 12
    NameL.TextXAlignment = Enum.TextXAlignment.Left
    NameL.Parent = fila
    
    -- CAJA CANTIDAD
    local TBDir = Instance.new("TextBox")
    TBDir.Size = UDim2.new(0.18, 0, 0.8, 0)
    TBDir.Position = UDim2.new(0.36, 0, 0.1, 0)
    TBDir.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    TBDir.BorderColor3 = item.color
    TBDir.Text = ""
    TBDir.PlaceholderText = "Cant."
    TBDir.TextColor3 = Color3.fromRGB(255,255,255)
    TBDir.Font = Enum.Font.Code
    TBDir.TextSize = 11
    TBDir.Parent = fila
    item.TB = TBDir
    
    -- BOTÓN VENDER TODO
    local VenderTodoBtn = Instance.new("TextButton")
    VenderTodoBtn.Size = UDim2.new(0.22, 0, 0.8, 0)
    VenderTodoBtn.Position = UDim2.new(0.56, 0, 0.1, 0)
    VenderTodoBtn.BackgroundColor3 = Color3.fromRGB(50, 80, 150)
    VenderTodoBtn.Text = "TODO 💸"
    VenderTodoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    VenderTodoBtn.Font = Enum.Font.Code
    VenderTodoBtn.TextSize = 11
    VenderTodoBtn.Parent = fila
    
    VenderTodoBtn.MouseButton1Click:Connect(function()
        local miCant = EscanearCantidad(item.es)
        if miCant > 0 then
            Log("🔍 Óptico detectó " .. miCant .. "x " .. item.es, Color3.fromRGB(0, 255, 0))
            EjecutarVentaNinja({[item.en] = miCant})
        else
            Log("❌ Error: Tienes 0 " .. item.es .. " o no tienes el inventario abierto para leer.", Color3.fromRGB(255, 100, 100))
        end
    end)
    
    -- CHECKBOX AUTO-LIMPIEZA
    local AutoBtn = Instance.new("TextButton")
    AutoBtn.Size = UDim2.new(0.18, 0, 0.8, 0)
    AutoBtn.Position = UDim2.new(0.80, 0, 0.1, 0)
    AutoBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
    AutoBtn.Text = "AUTO ❌"
    AutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoBtn.Font = Enum.Font.Code
    AutoBtn.TextSize = 10
    AutoBtn.Parent = fila
    
    AutoBtn.MouseButton1Click:Connect(function()
        item.AutoCheck = not item.AutoCheck
        if item.AutoCheck then
            AutoBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
            AutoBtn.Text = "AUTO ✅"
        else
            AutoBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
            AutoBtn.Text = "AUTO ❌"
        end
    end)
end

-- ==========================================
-- BOTÓN VENDER MANUAL DE CAJITAS
-- ==========================================
local SellGlobalBtn = Instance.new("TextButton")
SellGlobalBtn.Size = UDim2.new(1, -10, 0, 45)
SellGlobalBtn.Position = UDim2.new(0, 5, 1, -50)
SellGlobalBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 50)
SellGlobalBtn.Text = "🛠️ VENDER TEXTOS MANUALES"
SellGlobalBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SellGlobalBtn.Font = Enum.Font.Code
SellGlobalBtn.TextSize = 13
SellGlobalBtn.Parent = Panel
Instance.new("UICorner", SellGlobalBtn).CornerRadius = UDim.new(0, 6)

SellGlobalBtn.MouseButton1Click:Connect(function()
    local miBasket = {}
    local c = 0
    for _, item in ipairs(MINERALES_SEGUROS) do
        if item.TB.Text ~= "" then
            local cant = tonumber(item.TB.Text)
            if cant and cant > 0 then
                miBasket[item.en] = cant
                c = c + 1
                item.TB.Text = ""
            end
        end
    end
    if c > 0 then EjecutarVentaNinja(miBasket) else Log("⚠️ Escribe cantidades.", Color3.fromRGB(255,255,0)) end
end)

-- ==========================================
-- RUTINA DE AUTO-LIMPIEZA DE FARMEO (BACKGROUND WORKER)
-- ==========================================
task.spawn(function()
    while true do
        task.wait(4) -- Revisor de Latido de Inventario
        
        local current, maxm = ObtenerCapacidad()
        if current and maxm then
            CapacidadInfo.Text = "Espacio: " .. current .. "/" .. maxm
            
            -- Si estamos a 5 slots de llenarnos (o llenos), purgamos!
            if current >= (maxm - 5) then
                local autoBasket = {}
                local count = 0
                
                for _, item in ipairs(MINERALES_SEGUROS) do
                    if item.AutoCheck then
                        local stock = EscanearCantidad(item.es)
                        if stock > 0 then
                            autoBasket[item.en] = stock
                            count = count + 1
                        end
                    end
                end
                
                if count > 0 then
                    Log("☢️ ¡ALERTA DE ESPACIO! Auto-Vaciando Múltiples Minerales...", Color3.fromRGB(255, 100, 50))
                    EjecutarVentaNinja(autoBasket)
                    task.wait(10) -- Cooldown amplio después de la purga masiva para no saturar
                end
            end
        else
            CapacidadInfo.Text = "Abre Inventario (Detectar)"
        end
    end
end)

Log("💎 V9 Cosechadora Cargada: Mantén el inventario abierto en pantalla para auto-leer capacidad.")
