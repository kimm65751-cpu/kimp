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

-- Items que se venden automáticamente cuando el inventario está lleno
local AUTO_VENDER = {
    ["Small Essence"] = true,
    ["Medium Essence"] = true,
    ["Cobalt"] = true,
    ["Boneita"] = true,
    ["Titanium"] = true,
    ["Amethyst"] = true,
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
Title.Text = " 💎 AUTO-VENDEDOR REMOTO V35.5"
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
TermScroll.Size = UDim2.new(1, -10, 0, 160)
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

-- ==========================================
-- ESCUDO INMUNOLÓGICO Y RASTREADOR (__newindex)
-- ==========================================
if not getgenv().InmunidadV8Activa then
    getgenv().InmunidadV8Activa = true
    local OriginalNewIndex
    OriginalNewIndex = hookmetamethod(game, "__newindex", function(t, k, v)
        if not checkcaller() then
            -- Prevenir Anclaje Físico (Secuestro de movimiento)
            if t:IsA("BasePart") and t.Name == "HumanoidRootPart" and k == "Anchored" and v == true then
                task.spawn(function()
                    Log("🛡️ BLOQUEADO: Intento de anclaje físico evadido.", Color3.fromRGB(50, 255, 50))
                    local trace = debug.traceback()
                    for line in string.gmatch(trace, "[^\r\n]+") do
                        if string.find(line, "PlayerScripts") or string.find(line, "ReplicatedStorage") then
                            Log("   -> Culpable: " .. line, Color3.fromRGB(255, 100, 100))
                        end
                    end
                end)
                return -- ABORTAMOS EL CAMBIO
            end
            
            -- Prevenir Secuestro de Cámara
            if t:IsA("Camera") and k == "CameraType" and v ~= Enum.CameraType.Custom then
                task.spawn(function()
                    Log("🛡️ BLOQUEADO: Intento de rotar tu cámara a " .. tostring(v), Color3.fromRGB(50, 255, 50))
                    local trace = debug.traceback()
                    for line in string.gmatch(trace, "[^\r\n]+") do
                        if string.find(line, "PlayerScripts") or string.find(line, "ReplicatedStorage") then
                            Log("   -> Culpable: " .. line, Color3.fromRGB(255, 100, 100))
                        end
                    end
                end)
                return -- ABORTAMOS EL CAMBIO
            end
            
            -- Prevenir Reducción de Velocidad (Parálisis)
            if t:IsA("Humanoid") and (k == "WalkSpeed" and v < 16) then
                task.spawn(function()
                    Log("🛡️ BLOQUEADO: Intento de paralizar tu velocidad.", Color3.fromRGB(50, 255, 50))
                    local trace = debug.traceback()
                    for line in string.gmatch(trace, "[^\r\n]+") do
                        if string.find(line, "PlayerScripts") or string.find(line, "ReplicatedStorage") then
                            Log("   -> Culpable: " .. line, Color3.fromRGB(255, 100, 100))
                        end
                    end
                end)
                return -- ABORTAMOS EL CAMBIO
            end
        end
        return OriginalNewIndex(t, k, v)
    end)
    Log("🛡️ MOTOR DE INMUNIDAD Y RASTREO V8 ACTIVO.", Color3.fromRGB(0, 255, 255))
end

-- Controles de Log
local LogControls = Instance.new("Frame")
LogControls.Size = UDim2.new(1, -10, 0, 20)
LogControls.Position = UDim2.new(0, 5, 0, 198)
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
Scroll.Size = UDim2.new(1, -10, 1, -290)
Scroll.Position = UDim2.new(0, 5, 0, 223)
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
        Log("🚀 INICIANDO VENTA NINJA (SIN INTERFAZ)...", Color3.fromRGB(0, 255, 255))
        
        local basketStr = "{"
        for k, v in pairs(miBasket) do basketStr = basketStr .. k .. "=" .. v .. ", " end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local oldCFrame = root and root.CFrame
        
        -- ========== PASO 1: ENGAÑAR CON EL MENÚ MISC DIRECTAMENTE ==========
        Log("🛒 [1/3] Invocando ForceDialogue(SellConfirmMisc)", Color3.fromRGB(255, 150, 0))
        local ok1, err1 = pcall(function() RF_ForceDialogue:InvokeServer(SeyNPC, "SellConfirmMisc") end)
        if not ok1 then Log("❌ ForceDialogue Falló: " .. tostring(err1), Color3.fromRGB(255, 0, 0)) end
        
        task.wait(0.2)
        pcall(function() RE_DialogueEvent:FireServer("Opened") end)
        
        -- ========== PASO 2: VENTA PURA Y DURA ==========
        Log("💎 [2/3] Inyectando RunCommand...", Color3.fromRGB(255, 0, 255))
        local ok2, resp = pcall(function()
            return RF_RunCommand:InvokeServer("SellConfirm", paqueteFinal)
        end)
        
        if ok2 then
            Log("✅ ¡Transacción Procesada! (Revisa tu Oro)", Color3.fromRGB(0, 255, 0))
        else
            Log("❌ Error Paso 2: " .. tostring(resp), Color3.fromRGB(255, 0, 0))
        end
        
        -- Retorno de Posición Instántaneo
        if root and oldCFrame then
            root.CFrame = oldCFrame
            Log("👻 Posición restaurada al punto de origen", Color3.fromRGB(150, 255, 150))
        end
        
        task.wait(0.5) -- Damos tiempo al juego de dibujar la UI de despedida
        
        -- ========== PASO 3: LIMPIEZA SILENCIOSA Y AUTO-ADIÓS ==========
        Log("🔓 [3/3] Auto-Clickeando el botón 'Adiós'...", Color3.fromRGB(255, 150, 0))
        local adiosVisto = false
        
        pcall(function()
            for _, obj in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if obj:IsA("TextButton") and obj.Visible then
                    local t = string.lower(obj.Text)
                    if string.find(t, "adi") or string.find(t, "bye") or string.find(t, "2.") or string.find(t, "2%]") then
                        adiosVisto = true
                        Log("✅ Botón Adiós encontrado: " .. obj.Text, Color3.fromRGB(0, 255, 0))
                        pcall(function() firesignal(obj.MouseButton1Click) end)
                        pcall(function() for _, c in pairs(getconnections(obj.MouseButton1Click)) do c:Fire() end end)
                    end
                end
            end
        end)
        
        if not adiosVisto then
            Log("⚠️ Aviso: El botón 'Adiós' no se encontró o estaba oculto.", Color3.fromRGB(255, 255, 0))
        end
        
        pcall(function() RE_DialogueEvent:FireServer("Closed") end)
        
        Log("✅ ¡LISTO! Venta remota completada en Modo Dios 8.1", Color3.fromRGB(0, 255, 255))
        Log("══════════════════════════════════", Color3.fromRGB(100,100,100))
    end)
end)

Log("💎 ModV8.1: Escoge ítems, pon la cant, y clica Vender.")

-- ==============================================================================
-- 🔄 AUTO-VENTA CUANDO INVENTARIO LLENO (AGREGADO ENCIMA DEL CÓDIGO FUNCIONAL)
-- ==============================================================================

local function EjecutarAutoVenta(miBasket)
    if not RF_RunCommand or not RF_ForceDialogue or not RE_DialogueEvent or not SeyNPC then return end
    local paqueteFinal = { Basket = miBasket }
    task.spawn(function()
        Log("☢️ AUTO-VENTA ACTIVADA...", Color3.fromRGB(255, 100, 50))
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local oldCFrame = root and root.CFrame
        
        pcall(function() RF_ForceDialogue:InvokeServer(SeyNPC, "SellConfirmMisc") end)
        task.wait(0.2)
        pcall(function() RE_DialogueEvent:FireServer("Opened") end)
        
        local ok, resp = pcall(function() return RF_RunCommand:InvokeServer("SellConfirm", paqueteFinal) end)
        if ok then
            Log("✅ Auto-venta procesada.", Color3.fromRGB(0, 255, 0))
        else
            Log("❌ Auto-venta error: " .. tostring(resp), Color3.fromRGB(255, 0, 0))
        end
        
        if root and oldCFrame then root.CFrame = oldCFrame end
        task.wait(0.5)
        
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
        Log("✅ Auto-venta completada.", Color3.fromRGB(0, 255, 255))
    end)
end

local function EscanearStock()
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

local function ObtenerCapacidadInventario()
    local cur, maxm = nil, nil
    pcall(function()
        for _, obj in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Visible then
                local x, y = string.match(obj.Text, "(%d+)/(%d+)")
                if x and y then
                    local valY = tonumber(y)
                    if valY == 144 or valY > 50 then
                        cur, maxm = tonumber(x), valY
                        return
                    end
                end
            end
        end
    end)
    return cur, maxm
end

-- Bucle de monitoreo
task.spawn(function()
    while true do
        task.wait(5)
        pcall(function()
            local cur, maxm = ObtenerCapacidadInventario()
            if cur and maxm and cur >= (maxm - 5) then
                local stock = EscanearStock()
                local autoBasket = {}
                local count = 0
                for itemEN, _ in pairs(AUTO_VENDER) do
                    local cant = stock[itemEN] or 0
                    if cant > 0 then
                        autoBasket[itemEN] = cant
                        count = count + 1
                    end
                end
                if count > 0 then
                    EjecutarAutoVenta(autoBasket)
                end
            end
        end)
    end
end)
