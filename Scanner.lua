-- ==============================================================================
-- 💰 VENTA FORENSIC ANALYZER V1.0
-- Analizador de Inventario, NPCs y Remotos de Venta
-- ==============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- GUI
-- ==========================================
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "VentaAnalyzerUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VentaAnalyzerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 550, 0, 500)
Panel.Position = UDim2.new(0, 20, 0.5, -250)
Panel.BackgroundColor3 = Color3.fromRGB(15, 20, 10)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(50, 255, 100)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 80, 20)
Title.Text = " 💰 VENTA ANALYZER V1.0"
Title.TextColor3 = Color3.fromRGB(200, 255, 200)
Title.TextSize = 13
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Panel

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.Code
CloseBtn.TextSize = 16
CloseBtn.Parent = Panel
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- BOTONES
local BtnInv = Instance.new("TextButton")
BtnInv.Size = UDim2.new(0.33, -4, 0, 40)
BtnInv.Position = UDim2.new(0, 4, 0, 35)
BtnInv.BackgroundColor3 = Color3.fromRGB(80, 50, 150)
BtnInv.Text = "🎒 ESCANEAR\nINVENTARIO"
BtnInv.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnInv.Font = Enum.Font.Code
BtnInv.TextSize = 11
BtnInv.Parent = Panel

local BtnNPC = Instance.new("TextButton")
BtnNPC.Size = UDim2.new(0.33, -4, 0, 40)
BtnNPC.Position = UDim2.new(0.33, 2, 0, 35)
BtnNPC.BackgroundColor3 = Color3.fromRGB(150, 80, 20)
BtnNPC.Text = "🕵️ BUSCAR\nNPC SEY"
BtnNPC.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnNPC.Font = Enum.Font.Code
BtnNPC.TextSize = 11
BtnNPC.Parent = Panel

local BtnHook = Instance.new("TextButton")
BtnHook.Size = UDim2.new(0.34, -4, 0, 40)
BtnHook.Position = UDim2.new(0.66, 2, 0, 35)
BtnHook.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
BtnHook.Text = "📡 INTERCEPTOR\nDE VENTAS"
BtnHook.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnHook.Font = Enum.Font.Code
BtnHook.TextSize = 11
BtnHook.Parent = Panel

-- LOG
local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -8, 1, -120)
LogScroll.Position = UDim2.new(0, 4, 0, 80)
LogScroll.BackgroundColor3 = Color3.fromRGB(5, 10, 5)
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogScroll.ScrollBarThickness = 6
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.Parent = Panel
Instance.new("UIListLayout", LogScroll).Padding = UDim.new(0, 2)

-- Controles inferiores
local ControlsFrame = Instance.new("Frame")
ControlsFrame.Size = UDim2.new(1, -8, 0, 30)
ControlsFrame.Position = UDim2.new(0, 4, 1, -34)
ControlsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 15)
ControlsFrame.Parent = Panel

local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0.33, -2, 1, 0)
ClearBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ClearBtn.Text = "🗑️ LIMPIAR"
ClearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearBtn.Font = Enum.Font.Code
ClearBtn.TextSize = 11
ClearBtn.Parent = ControlsFrame

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0.33, -2, 1, 0)
CopyBtn.Position = UDim2.new(0.33, 2, 0, 0)
CopyBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 150)
CopyBtn.Text = "📋 COPIAR"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.Code
CopyBtn.TextSize = 11
CopyBtn.Parent = ControlsFrame

local SaveTxtBtn = Instance.new("TextButton")
SaveTxtBtn.Size = UDim2.new(0.34, -2, 1, 0)
SaveTxtBtn.Position = UDim2.new(0.66, 2, 0, 0)
SaveTxtBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
SaveTxtBtn.Text = "💾 GUARDAR .TXT"
SaveTxtBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveTxtBtn.Font = Enum.Font.Code
SaveTxtBtn.TextSize = 11
SaveTxtBtn.Parent = ControlsFrame

-- ==========================================
-- SISTEMA DE LOGS Y DUMP
-- ==========================================
local MasterLogList = {}
local LOG_FILENAME = "VentaLog.txt"

local function SmartDump(val, depth)
    depth = depth or 0
    if depth > 5 then return "{...}" end
    local t = typeof(val)
    if t == "Instance" then
        return "<Inst:" .. val:GetFullName() .. ">"
    elseif t == "table" then
        local parts = {}
        for k, v in pairs(val) do
            table.insert(parts, "[" .. tostring(k) .. "]=" .. SmartDump(v, depth + 1))
        end
        return "{\n" .. string.rep("  ", depth+1) .. table.concat(parts, ",\n" .. string.rep("  ", depth+1)) .. "\n" .. string.rep("  ", depth) .. "}"
    elseif t == "string" then return '"' .. tostring(val) .. '"'
    else return tostring(val) end
end

local function AddLog(logType, message, color)
    local fullString = "[" .. os.date("%H:%M:%S") .. "] [" .. logType .. "] " .. message
    table.insert(MasterLogList, fullString)
    pcall(function()
        local ok, ex = pcall(readfile, LOG_FILENAME)
        writefile(LOG_FILENAME, (ok and type(ex)=="string" and ex or "") .. fullString .. "\n")
    end)
    task.defer(function()
        pcall(function()
            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1, -4, 0, 0)
            txt.BackgroundTransparency = 1
            txt.Text = fullString
            txt.TextColor3 = color or Color3.fromRGB(200, 200, 200)
            txt.Font = Enum.Font.Code
            txt.TextSize = 10
            txt.TextXAlignment = Enum.TextXAlignment.Left
            txt.TextWrapped = true
            txt.Parent = LogScroll
            local tsz = game:GetService("TextService"):GetTextSize(txt.Text, txt.TextSize, txt.Font, Vector2.new(LogScroll.AbsoluteSize.X-15, math.huge))
            txt.Size = UDim2.new(1, -4, 0, tsz.Y + 4)
            LogScroll.CanvasPosition = Vector2.new(0, 999999)
        end)
    end)
end

ClearBtn.MouseButton1Click:Connect(function() LogScroll:ClearAllChildren(); Instance.new("UIListLayout", LogScroll).Padding = UDim.new(0, 2); MasterLogList = {} end)
CopyBtn.MouseButton1Click:Connect(function() pcall(function() setclipboard(table.concat(MasterLogList, "\n")); CopyBtn.Text = "✅" end) task.delay(2, function() CopyBtn.Text = "📋 COPIAR" end) end)
SaveTxtBtn.MouseButton1Click:Connect(function() pcall(function() writefile(LOG_FILENAME, "=== LOG VENTA ===\n" .. table.concat(MasterLogList, "\n")); SaveTxtBtn.Text = "✅" end) task.delay(3, function() SaveTxtBtn.Text = "💾 GUARDAR .TXT" end) end)

-- ==========================================
-- 1. ESCANEAR INVENTARIO
-- ==========================================
BtnInv.MouseButton1Click:Connect(function()
    AddLog("INV", "══════════════════════════════════", Color3.fromRGB(150, 100, 255))
    AddLog("INV", "🔍 BUSCANDO ITEMS COMUNES Y POCO COMUNES...", Color3.fromRGB(200, 150, 255))
    
    -- El inventario suele guardarse localmente en la GUI o en una carpeta de Player
    -- Metodo pasivo: Buscamos en la PlayerGui
    pcall(function()
        local invFound = false
        for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if gui:IsA("TextLabel") and (string.find(string.lower(gui.Text), "com") or string.find(string.lower(gui.Text), "uncommon")) then
                AddLog("INV_GUI", "Item encontrado en UI: " .. gui:GetFullName() .. " -> " .. gui.Text, Color3.fromRGB(0, 255, 100))
                -- Intentar imprimir el padre para ver más atributos
                AddLog("INV_GUI", "Padre Dump: " .. SmartDump(gui.Parent:GetAttributes()), Color3.fromRGB(150, 255, 150))
                invFound = true
            end
        end
        if not invFound then
            AddLog("INV", "No se encontró texto común en la UI visible.", Color3.fromRGB(255, 100, 100))
        end
    end)
    
    -- Método 2: Atributos del jugador/personaje
    pcall(function()
        local attrs = LocalPlayer:GetAttributes()
        for k, v in pairs(attrs) do
            if string.find(string.lower(k), "inv") or string.find(string.lower(k), "item") then
                AddLog("INV_ATTR", "Atributo en Player: " .. k .. " = " .. tostring(v), Color3.fromRGB(0, 200, 255))
            end
        end
    end)
    AddLog("INV", "💡 Si no hay datos útiles aquí, la info del inventario está oculta en una tabla de módulo. El Interceptor de Ventas nos dará la clave.", Color3.fromRGB(255, 255, 100))
end)

-- ==========================================
-- 2. ESCANEAR NPC SEY (BÚSQUEDA PROFUNDA)
-- ==========================================
BtnNPC.MouseButton1Click:Connect(function()
    AddLog("NPC", "══════════════════════════════════", Color3.fromRGB(255, 150, 50))
    AddLog("NPC", "🕵️ INICIANDO ESCANEO FORENSE DE SEY...", Color3.fromRGB(255, 200, 100))
    
    local posiblesNPCs = {}
    
    -- Escaneo 1: Buscar por Textos sobre la cabeza (BillboardGui)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            local textLower = string.lower(obj.Text)
            if string.find(textLower, "sey") or string.find(textLower, "codic") or string.find(textLower, "greedy") then
                -- Si encontramos el texto, buscamos el Modelo padre
                local parent = obj
                while parent and not parent:IsA("Model") do
                    parent = parent.Parent
                end
                if parent then
                    posiblesNPCs[parent] = "Texto GUI: " .. obj.Text
                end
            end
        end
        -- Escaneo 2: Buscar por nombre del modelo
        if obj:IsA("Model") then
            local nameLower = string.lower(obj.Name)
            if string.find(nameLower, "sey") or string.find(nameLower, "merchant") or string.find(nameLower, "sell") then
                posiblesNPCs[obj] = "Nombre Modelo: " .. obj.Name
            end
        end
    end
    
    -- Analizar resultados
    local count = 0
    for npcModel, motivo in pairs(posiblesNPCs) do
        count = count + 1
        AddLog("NPC", "✅ ¡Posible Sey Encontrado! (" .. count .. ")", Color3.fromRGB(0, 255, 0))
        AddLog("NPC", "   Nombre REAL del Objeto: " .. npcModel.Name, Color3.fromRGB(0, 255, 255))
        AddLog("NPC", "   Motivo: " .. motivo, Color3.fromRGB(200, 200, 200))
        
        -- Coordenadas
        local hrp = npcModel:FindFirstChild("HumanoidRootPart") or npcModel:FindFirstChildWhichIsA("BasePart")
        if hrp then
            local pos = hrp.Position
            AddLog("NPC", "   📍 Coordenadas: " .. string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z), Color3.fromRGB(255, 255, 0))
        end
        
        -- Buscar Prompts y Scripts
        local prompt = npcModel:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then
            AddLog("NPC", "   💬 Prompt: [" .. prompt.ActionText .. "] -> Padre: " .. prompt.Parent.Name, Color3.fromRGB(0, 255, 100))
        else
            AddLog("NPC", "   ⚠️ No usa ProximityPrompt. Es un NPC clickeable o usa Raycast.", Color3.fromRGB(255, 150, 150))
        end
        
        -- Atributos Ocultos
        local attrs = npcModel:GetAttributes()
        for k, v in pairs(attrs) do
            AddLog("NPC", "   ⚙️ Atributo interno: " .. k .. " = " .. tostring(v), Color3.fromRGB(150, 150, 255))
        end
        AddLog("NPC", "   ------------------------", Color3.fromRGB(50, 50, 50))
    end
    
    if count == 0 then
        AddLog("NPC", "❌ No se encontró ningún NPC físico con 'Sey'. Puede que esté oculto en una zona lejana o cargue dinámicamente.", Color3.fromRGB(255, 100, 100))
    end
    AddLog("NPC", "🎯 Siguiente paso: Háblale y vende algo con el Interceptor Activado.", Color3.fromRGB(255, 255, 0))
end)

-- ==========================================
-- 3. INTERCEPTOR DE VENTAS (Búsqueda C/S)
-- ==========================================
local HookActivo = false
local OriginalNamecall = nil

BtnHook.MouseButton1Click:Connect(function()
    HookActivo = not HookActivo
    
    if HookActivo then
        BtnHook.Text = "🔴 INTERCEPTOR\nARMADO"
        BtnHook.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        AddLog("HOOK", "══════════════════════════════════", Color3.fromRGB(255, 50, 50))
        AddLog("HOOK", "🔴 ESCUCHANDO EL TRÁFICO AL SERVIDOR...", Color3.fromRGB(255, 100, 100))
        AddLog("HOOK", "👉 Vende 1 item común o poco común AHORA.", Color3.fromRGB(255, 255, 0))
        
        if not OriginalNamecall then
            OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                
                if not HookActivo then return OriginalNamecall(self, ...) end
                if checkcaller() then return OriginalNamecall(self, ...) end
                
                if method == "InvokeServer" or method == "FireServer" then
                    local name = tostring(self.Name)
                    local args = {...}
                    
                    -- Filtramos todo menos lo relacionado a ventas o dialogo
                    local isRelevant = string.find(string.lower(name), "sell") or 
                                     string.find(string.lower(name), "dialogue") or 
                                     string.find(string.lower(name), "purchase") or
                                     string.find(string.lower(name), "recycle") or
                                     string.find(string.lower(name), "npc")
                                     
                    if isRelevant then
                        task.spawn(function()
                            AddLog("HOOK_OUT", "📤 " .. method .. " -> " .. name, Color3.fromRGB(255, 50, 255))
                            
                            local argDump = ""
                            for i, v in ipairs(args) do
                                argDump = argDump .. "["..i.."]=" .. SmartDump(v) .. " "
                            end
                            AddLog("HOOK_ARGS", argDump, Color3.fromRGB(200, 100, 255))
                        end)
                        
                        -- Capturar respuesta si es un InvokeServer
                        if method == "InvokeServer" then
                            local ret = {OriginalNamecall(self, ...)}
                            task.spawn(function()
                                local retDump = ""
                                for i, v in ipairs(ret) do
                                    retDump = retDump .. "["..i.."]=" .. SmartDump(v) .. " "
                                end
                                AddLog("HOOK_IN", "📥 RESP DEL SERVER: " .. retDump, Color3.fromRGB(0, 255, 150))
                            end)
                            return unpack(ret)
                        end
                    end
                end
                
                return OriginalNamecall(self, ...)
            end)
        end
    else
        BtnHook.Text = "📡 INTERCEPTOR\nDE VENTAS"
        BtnHook.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        AddLog("HOOK", "⚪ Interceptor apagado.", Color3.fromRGB(150, 150, 150))
    end
end)

-- Inicialización
AddLog("SISTEMA", "💰 VENTA ANALYZER V1.0 CARGADO", Color3.fromRGB(150, 255, 150))
AddLog("SISTEMA", "Paso 1: Dale a Escanear Inventario", Color3.fromRGB(255, 255, 200))
AddLog("SISTEMA", "Paso 2: Dale a Buscar NPC Sey", Color3.fromRGB(255, 255, 200))
AddLog("SISTEMA", "Paso 3: Activa el Interceptor y Vende 1 item en el juego.", Color3.fromRGB(255, 255, 200))
