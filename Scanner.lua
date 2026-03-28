-- ==============================================================================
-- 🔬 ESCÁNER PROFUNDO DE MEMORIA DEL INVENTARIO
-- ==============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- GUI NÚCLEO
-- ==========================================
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "InvScannerUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "InvScannerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 500, 0, 450)
Panel.Position = UDim2.new(0, 50, 0.5, -225)
Panel.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(200, 100, 50)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(80, 40, 20)
Title.Text = " 🔬 ESCÁNER DE MEMORIA DE INVENTARIO"
Title.TextColor3 = Color3.fromRGB(255, 220, 200)
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

-- ==========================================
-- BOTONES DE ACCIÓN
-- ==========================================
local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0.5, -2, 0, 40)
CopyBtn.Position = UDim2.new(0, 5, 1, -45)
CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
CopyBtn.Text = "📋 COPIAR LOG"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.Code
CopyBtn.TextSize = 12
CopyBtn.Parent = Panel
CopyBtn.MouseButton1Click:Connect(function() pcall(function() setclipboard(table.concat(LogHistory, "\n")) end) end)

local ScanBtn = Instance.new("TextButton")
ScanBtn.Size = UDim2.new(0.5, -7, 0, 40)
ScanBtn.Position = UDim2.new(0.5, 2, 1, -45)
ScanBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
ScanBtn.Text = "🔍 ESCANEAR MEMORIA"
ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanBtn.Font = Enum.Font.Code
ScanBtn.TextSize = 12
ScanBtn.Parent = Panel

-- ==========================================
-- MOTOR DE ESCANEO PROFUNDO
-- ==========================================
ScanBtn.MouseButton1Click:Connect(function()
    Log("══════════════════════════════════", Color3.fromRGB(150,150,150))
    Log("🔍 INICIANDO RASTREO DE INVENTARIO PROFUNDO...", Color3.fromRGB(0, 255, 255))
    
    task.spawn(function()
        -- 1. Buscar en Variables del Jugador (Directorios Ocultos)
        Log("📂 Escaneando LocalPlayer (Buscando variables de límite o datos)...", Color3.fromRGB(255, 200, 0))
        local carpetasClave = {"Data", "Inventory", "Stats", "Profile", "Leaderstats"}
        for _, child in pairs(LocalPlayer:GetChildren()) do
            for _, kw in ipairs(carpetasClave) do
                if string.find(string.lower(child.Name), string.lower(kw)) then
                    Log("   ✅ Carpeta Sospechosa: " .. child:GetFullName(), Color3.fromRGB(150, 255, 150))
                    for _, sub in pairs(child:GetChildren()) do
                        if sub:IsA("ValueBase") then
                            Log("      -> " .. sub.Name .. " = " .. tostring(sub.Value), Color3.fromRGB(200, 200, 200))
                        end
                    end
                end
            end
        end
        
        task.wait(0.2)
        -- 2. Buscar valores numéricos exactos del límite en el juego (144)
        Log("🔢 Buscando el valor 144 a través del Cliente...", Color3.fromRGB(255, 200, 0))
        local cont144 = 0
        local function Scan144(parent)
            for _, obj in pairs(parent:GetDescendants()) do
                if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                    if tonumber(obj.Value) == 144 then
                        Log("   🎯 LIMITE ENCONTRADO EN: " .. obj:GetFullName(), Color3.fromRGB(0, 255, 0))
                        cont144 = cont144 + 1
                    end
                end
            end
        end
        pcall(function() Scan144(LocalPlayer) end)
        pcall(function() Scan144(ReplicatedStorage) end)
        if cont144 == 0 then Log("   ❌ No se encontró el número 144 incrustado en valores sueltos.", Color3.fromRGB(255, 100, 100)) end
        
        task.wait(0.2)
        -- 3. Explorar los Controllers de Knit (Módulos de ReplicatedStorage)
        Log("🧰 Inspeccionando Knit Controllers de Interfaz...", Color3.fromRGB(255, 200, 0))
        local pathsKNIT = {
            ReplicatedStorage:FindFirstChild("Controllers") and ReplicatedStorage.Controllers:FindFirstChild("UIController"),
            ReplicatedStorage:FindFirstChild("Controllers")
        }
        
        for _, path in ipairs(pathsKNIT) do
            if path then
                for _, modu in pairs(path:GetDescendants()) do
                    if modu:IsA("ModuleScript") and (string.find(string.lower(modu.Name), "inventory") or string.find(string.lower(modu.Name), "data")) then
                        Log("   🧠 Módulo Relevante Detectado: " .. modu:GetFullName(), Color3.fromRGB(150, 255, 255))
                        -- Intentaremos sacar funciones o variables de este módulo
                        local success, res = pcall(function() return require(modu) end)
                        if success and type(res) == "table" then
                            for k, v in pairs(res) do
                                Log("      | Función/Dato: " .. tostring(k) .. " (" .. type(v) .. ")", Color3.fromRGB(200, 200, 200))
                            end
                        else
                            Log("      | (Módulo protegido o no retorna tabla simple)", Color3.fromRGB(100, 100, 100))
                        end
                    end
                end
            end
        end
        
        task.wait(0.2)
        -- 4. Buscar Atributos del Jugador
        Log("🏷️ Escaneando Atributos del Jugador...", Color3.fromRGB(255, 200, 0))
        local attrs = LocalPlayer:GetAttributes()
        local attrCount = 0
        for k, v in pairs(attrs) do
            Log("   [Attr] " .. tostring(k) .. " = " .. tostring(v), Color3.fromRGB(200, 200, 200))
            attrCount = attrCount + 1
        end
        if attrCount == 0 then Log("   Ningún atributo relevante en el LocalPlayer.", Color3.fromRGB(150, 150, 150)) end
        
        Log("🏁 ESCANEO COMPLETADO. Copia el log.", Color3.fromRGB(0, 255, 0))
        Log("══════════════════════════════════", Color3.fromRGB(150,150,150))
    end)
end)

Log("🕵️ Presiona el botón verde para cazar la base de datos de tu inventario.")
