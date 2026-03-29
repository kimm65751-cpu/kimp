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
-- MINERALES A VENDER AUTOMÁTICAMENTE
-- ==========================================
local AUTO_VENDER = {
    ["Small Essence"] = true,
    ["Medium Essence"] = true,
    ["Cobalt"] = true,
    ["Boneita"] = true,
    ["Titanium"] = true,
    ["Amethyst"] = true,
}

-- Lista completa de minerales para escanear
local MINERALES = {
    {es="Excremento",       en="Excrement"},
    {es="Cartonita",        en="Cartonite"},
    {es="Boneita",          en="Boneita"},
    {es="Aite",             en="Aite"},
    {es="Cuarzo",           en="Quartz"},
    {es="Cuprita",          en="Cuprite"},
    {es="Cobalto",          en="Cobalt"},
    {es="Topaz",            en="Topaz"},
    {es="Bananita",         en="Bananite"},
    {es="Esmeralda",        en="Emerald"},
    {es="Zafiro",           en="Sapphire"},
    {es="Lapis Lazuli",     en="Lapis Lazuli"},
    {es="Titánio",          en="Titanium"},
    {es="Diamante",         en="Diamond"},
    {es="Mina ocular",      en="Eye Mine"},
    {es="Fichillium",       en="Fichillium"},
    {es="Ametista",         en="Amethyst"},
    {es="Esencia pequeña",  en="Small Essence"},
    {es="Esencia mediana",  en="Medium Essence"},
    {es="Esencia grande",   en="Large Essence"},
    {es="Esencia superior", en="Superior Essence"},
    {es="Chispa de fuego",  en="Fire Spark"},
}

-- ==========================================
-- GUI MÍNIMA
-- ==========================================
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "AutoVendorProUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoVendorProUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 250, 0, 80)
Panel.Position = UDim2.new(0, 50, 0, 50)
Panel.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(100, 150, 255)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -30, 0, 25)
Title.BackgroundColor3 = Color3.fromRGB(20, 40, 80)
Title.Text = " 💎 AUTO-VENDEDOR V5.0"
Title.TextColor3 = Color3.fromRGB(200, 220, 255)
Title.TextSize = 12
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Panel

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.Code
CloseBtn.TextSize = 12
CloseBtn.Parent = Panel
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local AutoVenderActivo = false

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -10, 0, 40)
ToggleBtn.Position = UDim2.new(0, 5, 0, 30)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
ToggleBtn.Text = "AUTOVENDER ❌ OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.Code
ToggleBtn.TextSize = 14
ToggleBtn.Parent = Panel
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

ToggleBtn.MouseButton1Click:Connect(function()
    AutoVenderActivo = not AutoVenderActivo
    if AutoVenderActivo then
        ToggleBtn.Text = "AUTOVENDERR ✅ ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    else
        ToggleBtn.Text = "AUTOVENDER ❌ OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
    end
end)

-- Log silencioso (F9)
local function Log(texto, color)
    print("[AutoVendedor] " .. texto)
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
                    Log("🛡️ BLOQUEADO: Intento de anclaje físico evadido.")
                    local trace = debug.traceback()
                    for line in string.gmatch(trace, "[^\r\n]+") do
                        if string.find(line, "PlayerScripts") or string.find(line, "ReplicatedStorage") then
                            Log("   -> Culpable: " .. line)
                        end
                    end
                end)
                return
            end
            
            -- Prevenir Secuestro de Cámara
            if t:IsA("Camera") and k == "CameraType" and v ~= Enum.CameraType.Custom then
                task.spawn(function()
                    Log("🛡️ BLOQUEADO: Intento de rotar tu cámara a " .. tostring(v))
                    local trace = debug.traceback()
                    for line in string.gmatch(trace, "[^\r\n]+") do
                        if string.find(line, "PlayerScripts") or string.find(line, "ReplicatedStorage") then
                            Log("   -> Culpable: " .. line)
                        end
                    end
                end)
                return
            end
            
            -- Prevenir Reducción de Velocidad (Parálisis)
            if t:IsA("Humanoid") and (k == "WalkSpeed" and v < 16) then
                task.spawn(function()
                    Log("🛡️ BLOQUEADO: Intento de paralizar tu velocidad.")
                    local trace = debug.traceback()
                    for line in string.gmatch(trace, "[^\r\n]+") do
                        if string.find(line, "PlayerScripts") or string.find(line, "ReplicatedStorage") then
                            Log("   -> Culpable: " .. line)
                        end
                    end
                end)
                return
            end
        end
        return OriginalNewIndex(t, k, v)
    end)
    Log("🛡️ MOTOR DE INMUNIDAD V8 ACTIVO.")
end

-- Estado
Log((RF_RunCommand and "✅ RunCommand " or "❌ RunCommand ") .. 
    (RF_ForceDialogue and "✅ ForceDialogue " or "❌ ForceDialogue ") ..
    (RE_DialogueEvent and "✅ DialogueEvent " or "❌ DialogueEvent ") ..
    (SeyNPC and "✅ NPC" or "❌ NPC"))

-- ==========================================
-- FUNCIÓN DE VENTA (SECUENCIA EXACTA DEL FORENSE)
-- ==========================================
local function EjecutarVenta(miBasket)
    if not RF_RunCommand or not RF_ForceDialogue or not RE_DialogueEvent or not SeyNPC then return end
    
    local paqueteFinal = { Basket = miBasket }
    
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local oldCFrame = root and root.CFrame
    
    -- PASO 1
    pcall(function() RF_ForceDialogue:InvokeServer(SeyNPC, "SellConfirmMisc") end)
    task.wait(0.2)
    pcall(function() RE_DialogueEvent:FireServer("Opened") end)
    
    -- PASO 2
    local ok, resp = pcall(function() return RF_RunCommand:InvokeServer("SellConfirm", paqueteFinal) end)
    if ok then
        Log("✅ Venta procesada.")
    else
        Log("❌ Error: " .. tostring(resp))
    end
    
    if root and oldCFrame then root.CFrame = oldCFrame end
    task.wait(0.5)
    
    -- PASO 3
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
end

-- ==========================================
-- ESCANEAR STOCK DEL INVENTARIO
-- ==========================================
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

-- ==========================================
-- DETECTAR CAPACIDAD DEL INVENTARIO
-- ==========================================
local function ObtenerCapacidad()
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

-- ==========================================
-- BUCLE DE MONITOREO AUTO-VENTA
-- ==========================================
task.spawn(function()
    while true do
        task.wait(5)
        if AutoVenderActivo then
            pcall(function()
                local cur, maxm = ObtenerCapacidad()
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
                        Log("☢️ INV LLENO → Vendiendo " .. count .. " tipos de mineral...")
                        EjecutarVenta(autoBasket)
                    end
                end
            end)
        end
    end
end)

Log("💎 Auto-Vendedor listo. Activa el botón para vender automáticamente.")
