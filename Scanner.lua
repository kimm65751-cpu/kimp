-- ==============================================================================
-- 🕵️ EXTRACTOR DE NOMBRES REALES Y RAREZA (EL DESCIFRADOR)
-- ==============================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "DictScannerUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DictScannerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 500, 0, 480)
Panel.Position = UDim2.new(0, 50, 0.5, -240)
Panel.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(255, 100, 100)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
Title.Text = " 🕵️ EXTRACTOR DE NOMBRES REALES"
Title.TextColor3 = Color3.fromRGB(255, 200, 200)
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

local TermScroll = Instance.new("ScrollingFrame")
TermScroll.Size = UDim2.new(1, -10, 1, -85)
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

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(1, -10, 0, 40)
CopyBtn.Position = UDim2.new(0, 5, 1, -45)
CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
CopyBtn.Text = "📋 COPIAR NOMBRES ENCONTRADOS"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.Code
CopyBtn.TextSize = 12
CopyBtn.Parent = Panel
CopyBtn.MouseButton1Click:Connect(function() pcall(function() setclipboard(table.concat(LogHistory, "\n")) end) end)

Log("==========================================", Color3.fromRGB(150, 150, 150))
Log("🎯 MÉTODO DIRECTO ACTIVADO", Color3.fromRGB(255, 255, 0))
Log("Instrucción: Ve al NPC del juego y Vende MANUALMENTE (1 cantidad de cada ítem) que no te funcione.", Color3.fromRGB(200, 255, 200))
Log("El script capturará en este instante CÓMO SE LLAMAN INTERNAMENTE. ¡Mira abajo los resultados!", Color3.fromRGB(200, 255, 200))
Log("==========================================", Color3.fromRGB(150, 150, 150))

-- ==========================================
-- EL HOOK INTERCEPTOR
-- ==========================================
local ncall
ncall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and method == "InvokeServer" and self.Name == "RunCommand" then
        if args[1] == "SellConfirm" and type(args[2]) == "table" and type(args[2].Basket) == "table" then
            task.spawn(function()
                Log("------------------------------------------")
                Log("👀 SE HA DETECTADO UNA VENTA DESDE TU INTERFAZ ORIGINAL:", Color3.fromRGB(0, 255, 255))
                for nombreInterno, cantidad in pairs(args[2].Basket) do
                    Log("➡ Nombre Real del Servidor: '" .. tostring(nombreInterno) .. "'", Color3.fromRGB(255, 100, 255))
                    Log("➡ Cantidad Enviada: " .. tostring(cantidad), Color3.fromRGB(200, 200, 200))
                end
            end)
        end
    end
    
    return ncall(self, ...)
end)

-- ==========================================
-- ESCÁNER DE BASES DE DATOS (MÓDULOS DE ITEMS)
-- ==========================================
task.spawn(function()
    Log("🔍 Escaneando módulos de ítems por si la base de datos es pública...", Color3.fromRGB(200, 200, 50))
    local ModulosSospechosos = {"Items", "ItemDrop", "ItemDatabase", "ItemsData", "Info"}
    local encontrados = 0
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("ModuleScript") then
            for _, kw in pairs(ModulosSospechosos) do
                if string.find(string.lower(obj.Name), string.lower(kw)) then
                    local ok, data = pcall(function() return require(obj) end)
                    if ok and type(data) == "table" then
                        Log("📂 Posible base de datos de Ítems encontrada: " .. obj.Name, Color3.fromRGB(100, 255, 100))
                        encontrados = encontrados + 1
                    end
                end
            end
        end
    end
    if encontrados == 0 then
        Log("⚠️ La base de datos es secreta, usa la técnica de ir a vender 1 al NPC tal como te pedí arriba.", Color3.fromRGB(255, 255, 0))
    end
end)
