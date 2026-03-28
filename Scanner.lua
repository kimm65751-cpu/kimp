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
    print(texto) -- También lo lanza a la consola F9 por seguridad
end

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(1, -10, 0, 40)
CopyBtn.Position = UDim2.new(0, 5, 1, -45)
CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
CopyBtn.Text = "📋 GUARDAR/COPIAR RESULTADOS"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.Code
CopyBtn.TextSize = 12
CopyBtn.Parent = Panel
CopyBtn.MouseButton1Click:Connect(function() pcall(function() setclipboard(table.concat(LogHistory, "\n")); CopyBtn.Text = "✅" end) task.delay(2, function() CopyBtn.Text = "📋 COPIAR" end) end)

Log("==========================================", Color3.fromRGB(150, 150, 150))
Log("🎯 ANALIZADOR ESTRUCTURAL DE INVENTARIO", Color3.fromRGB(255, 255, 0))
Log("Presiona el Botón de abajo para Escanear estáticamente toda tu mochila y cazar su ID interior.", Color3.fromRGB(200, 255, 200))
Log("==========================================", Color3.fromRGB(150, 150, 150))

local function AnalizarTodoElInventario()
    Log("🔍 Escaneando todas tus casillas de Inventario...", Color3.fromRGB(200, 200, 50))
    local encontrados = {}
    local totalItems = 0
    
    pcall(function()
        for _, obj in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Visible then
                local txt = obj.Text
                -- Ignorar textos demasiado cortos, números puros, o signos
                if string.len(txt) > 2 and not tonumber(txt) and not string.match(txt, "^[xX]%d+") and not string.find(string.lower(txt), "capacidad") then
                    local padre = obj.Parent
                    if padre and (padre:IsA("Frame") or padre:IsA("ImageLabel")) then
                        if not encontrados[txt] then
                            encontrados[txt] = true
                            totalItems = totalItems + 1
                            
                            Log("------------------------------------", Color3.fromRGB(100, 100, 100))
                            Log("📦 ÍTEM (Español UI): " .. txt, Color3.fromRGB(0, 255, 255))
                            Log("   ➡ ID EN MEMORIA DEL CUADRO: " .. padre.Name, Color3.fromRGB(255, 150, 100))
                            
                            -- Escáner de Atributos del Cuadro
                            local attrs = padre:GetAttributes()
                            local numAttrs = 0
                            for k, v in pairs(attrs) do
                                Log("   🏷️ Atributo: [" .. k .. "] = " .. tostring(v), Color3.fromRGB(200, 255, 100))
                                numAttrs = numAttrs + 1
                            end
                            
                            -- Escáner de StringValues y variables dentro del slot
                            for _, child in pairs(padre:GetChildren()) do
                                if child:IsA("StringValue") then
                                    Log("   🪧 ScriptVariable: [" .. child.Name .. "] = " .. child.Value, Color3.fromRGB(200, 150, 255))
                                end
                                if child:IsA("TextLabel") and string.match(child.Text, "[xX](%d+)") then
                                    Log("   📊 Cantidad Vistazo: " .. child.Text, Color3.fromRGB(150, 150, 150))
                                end
                            end
                            
                            if numAttrs == 0 and string.find(string.lower(padre.Name), "frame") then
                                local abuelo = padre.Parent
                                if abuelo then
                                    Log("   (Buscando en contenedor Abuelo: " .. abuelo.Name .. ")", Color3.fromRGB(100, 100, 100))
                                    local gAttrs = abuelo:GetAttributes()
                                    for gk, gv in pairs(gAttrs) do
                                        Log("      🏷️ Attr Abuelo: [" .. gk .. "] = " .. tostring(gv), Color3.fromRGB(200, 255, 100))
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    
    Log("------------------------------------", Color3.fromRGB(100, 100, 100))
    Log("✅ CONCLUIDO. Se encontraron " .. totalItems .. " posibles ítems.", Color3.fromRGB(0, 255, 0))
    Log(">> Revisa el 'ID EN MEMORIA DEL CUADRO' o los Atributos para ver el nombre oficial.", Color3.fromRGB(200, 200, 200))
end

local ScanBtn = Instance.new("TextButton")
ScanBtn.Size = UDim2.new(1, -10, 0, 40)
ScanBtn.Position = UDim2.new(0, 5, 1, -90)
ScanBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
ScanBtn.Text = "🔎 INICIAR ANÁLISIS DEL INVENTARIO"
ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanBtn.Font = Enum.Font.Code
ScanBtn.TextSize = 12
ScanBtn.Parent = Panel
ScanBtn.MouseButton1Click:Connect(function()
    AnalizarTodoElInventario()
end)
