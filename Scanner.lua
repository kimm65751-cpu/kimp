-- ==============================================================================
-- 🛡️ REVERSE ENG: CODE TRACER V4.0 (EL ORIGEN VIRTUAL)
-- Implanta ganchos de red directamente sobre la parte física para extraer
-- que script exacto y línea de código controlan este botón.
-- ==============================================================================
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Limpieza
pcall(function()
    for _, obj in pairs(CoreGui:GetChildren()) do
        if obj.Name:match("Analyzer") or obj.Name:match("AutoDefender") or obj.Name:match("Trace") then 
            obj:Destroy() 
        end
    end
end)

-- UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TraceAnalyzerV4"
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 320)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(200, 150, 0)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(200, 150, 0)
Title.Text = "🛡️ V4.0 CODE TRACER (AUTOPSIA DE SERVIDOR)"
Title.Font = Enum.Font.Code
Title.TextSize = 16
Title.Parent = MainFrame

local BtnTrace = Instance.new("TextButton")
BtnTrace.Size = UDim2.new(0.9, 0, 0, 35)
BtnTrace.Position = UDim2.new(0.05, 0, 0, 40)
BtnTrace.BackgroundColor3 = Color3.fromRGB(150, 80, 0)
BtnTrace.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnTrace.Text = "🕵️‍♂️ EXTRAER LÍNEA DE CÓDIGO (ROOT CAUSE)"
BtnTrace.Font = Enum.Font.Code
BtnTrace.TextSize = 14
BtnTrace.Parent = MainFrame

local LogHolder = Instance.new("ScrollingFrame")
LogHolder.Size = UDim2.new(0.9, 0, 0, 220)
LogHolder.Position = UDim2.new(0.05, 0, 0, 85)
LogHolder.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
LogHolder.BorderSizePixel = 1
LogHolder.BorderColor3 = Color3.fromRGB(200, 150, 0)
LogHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
LogHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogHolder.Parent = MainFrame

local layout = Instance.new("UIListLayout", LogHolder)

local logCount = 0
local function AddLog(msg, color)
    logCount = logCount + 1
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    lbl.Text = " " .. msg
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 13
    lbl.LayoutOrder = logCount
    lbl.Parent = LogHolder
    LogHolder.CanvasPosition = Vector2.new(0, 99999)
end

AddLog("🔌 Rastreador de Memoria Listo.", Color3.fromRGB(100, 255, 100))

BtnTrace.MouseButton1Click:Connect(function()
    -- Validamos si el ejectuor permite debugear conexiones en Ram
    if not getconnections then
        AddLog("❌ Error: Tu Delta no soporta la función 'getconnections()'.", Color3.fromRGB(255, 50, 50))
        AddLog("No podremos rastrear la línea de código exacta desde aquí.", Color3.fromRGB(200, 200, 200))
        return
    end
    
    AddLog("\n🔍 Buscando la dirección en RAM del botón...", Color3.fromRGB(200, 200, 255))
    
    local TargetButton = nil
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("TextLabel") and (obj.Text:match("%d+s") or obj.Text:match("Lock")) then
            local p = obj:FindFirstAncestorWhichIsA("BillboardGui") or obj:FindFirstAncestorWhichIsA("SurfaceGui")
            if p and p.Adornee then TargetButton = p.Adornee end
            if not TargetButton and p and p.Parent and p.Parent:IsA("BasePart") then TargetButton = p.Parent end
        end
    end
    
    if not TargetButton then
        AddLog("❌ Círculo no encontrado en el mapa local.", Color3.fromRGB(255, 50, 50))
        return
    end
    
    AddLog("🎯 Puntero enlazado a: " .. TargetButton.Name, Color3.fromRGB(0, 255, 150))
    AddLog("Extrayendo conexiones físicas (.Touched) asociadas...", Color3.fromRGB(255, 150, 0))
    
    -- Ataque maestro: Leer qué código escucha este botón
    pcall(function()
        local conns = getconnections(TargetButton.Touched)
        
        if #conns == 0 then
            AddLog("\n⚠️ DIAGNÓSTICO FINAL: ERROR DEL DESARROLLADOR", Color3.fromRGB(255, 50, 50))
            AddLog("--------------------------------------------------", Color3.fromRGB(255, 50, 50))
            AddLog("El botón está 'HUECO'. No hay NINGÚN Script atrapando la parte de la colisión.", Color3.fromRGB(200, 200, 200))
            AddLog("Si el timer retrocede de 56 a 0, y tú ves 'LOCKED':", Color3.fromRGB(255, 255, 100))
            AddLog("Significa que programaste una ilusión. Tu código central está en un LocalScript que solo cambia las propiedades del BillboardGui.", Color3.fromRGB(255, 255, 100))
            AddLog("Para que la base SE BLOQUEE DE VERDAD: Tienes que ir a tu archivo ServerScriptService, interceptar el botón, y asignar `PuertaSecreta.CanCollide = true` y `Transparency = 0`.", Color3.fromRGB(150, 255, 255))
            
        else
            AddLog("✅ RESULTADO: Se encontraron " .. #conns .. " scripts vinculados a este botón.", Color3.fromRGB(100, 255, 100))
            for i, conn in ipairs(conns) do
                local func = conn.Function
                if func then
                    local info = debug.getinfo(func)
                    local scriptName = info.source or "Codigo_Cifrado"
                    local line = info.currentline or 0
                    local sType = info.what or "?"
                    
                    AddLog("📜 Conexión " .. i .. ": ", Color3.fromRGB(255, 200, 100))
                    AddLog("   - Archivo Fuente: " .. tostring(scriptName), Color3.fromRGB(255, 200, 100))
                    AddLog("   - Línea Exacta: " .. tostring(line), Color3.fromRGB(255, 200, 100))
                    AddLog("   - Estructura: " .. tostring(sType), Color3.fromRGB(255, 200, 100))
                else
                    AddLog("📜 Conexión " .. i .. ": Función C++ Oculta.", Color3.fromRGB(200, 100, 100))
                end
            end
            AddLog("\n👉 SOLUCIÓN: Abre Roblox Studio, ve al Archivo Fuente y la Línea Exacta que te marqué arriba.\nDentro de esa función verás que olvidaste programar las físicas de la puerta (CanCollide = true).", Color3.fromRGB(0, 255, 255))
        end
    end)
end)
