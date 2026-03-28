-- ==============================================================================
-- 🔬 SUPER FORENSE VENTAS V2.0 (BASADO EN HOOK PROBADO DEL VENTA ANALYZER)
-- ==============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "SuperForenseUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SuperForenseUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 550, 0, 500)
Panel.Position = UDim2.new(0.5, -275, 0.5, -250)
Panel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(200, 50, 100)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(80, 20, 40)
Title.Text = " 🔬 SUPER FORENSE VENTAS V2.0"
Title.TextColor3 = Color3.fromRGB(255, 200, 220)
Title.TextSize = 12
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

-- BOTONES
local BtnScan = Instance.new("TextButton")
BtnScan.Size = UDim2.new(0.5, -4, 0, 35)
BtnScan.Position = UDim2.new(0, 4, 0, 35)
BtnScan.BackgroundColor3 = Color3.fromRGB(150, 80, 20)
BtnScan.Text = "🔍 RAYOS X AL NPC"
BtnScan.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnScan.Font = Enum.Font.Code
BtnScan.TextSize = 11
BtnScan.Parent = Panel

local BtnHook = Instance.new("TextButton")
BtnHook.Size = UDim2.new(0.5, -4, 0, 35)
BtnHook.Position = UDim2.new(0.5, 2, 0, 35)
BtnHook.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
BtnHook.Text = "📡 ACTIVAR INTERCEPTOR"
BtnHook.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnHook.Font = Enum.Font.Code
BtnHook.TextSize = 11
BtnHook.Parent = Panel

-- LOG
local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -8, 1, -110)
LogScroll.Position = UDim2.new(0, 4, 0, 75)
LogScroll.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
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
-- SISTEMA DE LOGS
-- ==========================================
local MasterLogList = {}

local function AddLog(logType, message, color)
    local fullString = "[" .. os.date("%H:%M:%S") .. "] [" .. logType .. "] " .. message
    table.insert(MasterLogList, fullString)
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
SaveTxtBtn.MouseButton1Click:Connect(function() pcall(function() writefile("SuperForenseLog.txt", "=== SUPER FORENSE ===\n" .. table.concat(MasterLogList, "\n")); SaveTxtBtn.Text = "✅" end) task.delay(3, function() SaveTxtBtn.Text = "💾 GUARDAR .TXT" end) end)

-- ==========================================
-- STRICT DUMP (CON TIPOS)
-- ==========================================
local function StrictDump(val, depth)
    depth = depth or 0
    if depth > 5 then return "{...}" end
    local t = typeof(val)
    if t == "Instance" then
        return "<Inst:" .. val.ClassName .. ">" .. val:GetFullName()
    elseif t == "table" then
        local parts = {}
        for k, v in pairs(val) do
            table.insert(parts, "[" .. StrictDump(k, depth+1) .. "]=" .. StrictDump(v, depth+1))
        end
        return "{\n" .. string.rep("  ", depth+1) .. table.concat(parts, ",\n" .. string.rep("  ", depth+1)) .. "\n" .. string.rep("  ", depth) .. "}"
    elseif t == "string" then
        return '"' .. tostring(val) .. '"(str)'
    elseif t == "number" then
        return tostring(val) .. "(num)"
    elseif t == "boolean" then
        return tostring(val) .. "(bool)"
    else
        return tostring(val) .. "(" .. t .. ")"
    end
end

-- ==========================================
-- ESCANER DE ERRORES SILENCIOSOS
-- ==========================================
game:GetService("ScriptContext").Error:Connect(function(message, trace, script)
    if string.find(string.lower(trace), "playergui") or string.find(string.lower(trace), "replicatedstorage") then
        AddLog("💀CRASH", message, Color3.fromRGB(255, 0, 0))
        AddLog("💀CRASH", "Script: " .. (script and script:GetFullName() or "?"), Color3.fromRGB(255, 100, 100))
    end
end)

game:GetService("LogService").MessageOut:Connect(function(message, messageType)
    local lowMsg = string.lower(message)
    if string.find(lowMsg, "sell") or string.find(lowMsg, "basket") or string.find(lowMsg, "invalid") or string.find(lowMsg, "merchant") then
        AddLog("📢DEV", message, Color3.fromRGB(255, 100, 200))
    end
end)

-- ==========================================
-- BOTON: RAYOS X AL NPC
-- ==========================================
BtnScan.MouseButton1Click:Connect(function()
    AddLog("SCAN", "══════════════════════════════════", Color3.fromRGB(255, 200, 0))
    AddLog("SCAN", "🔍 ESCANEANDO NPC, UI, y MÓDULOS...", Color3.fromRGB(255, 200, 0))
    
    -- NPC
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("Model") and string.find(string.lower(obj.Name), "cey") then
            AddLog("NPC", "👤 " .. obj:GetFullName(), Color3.fromRGB(0, 255, 255))
            for _, child in pairs(obj:GetDescendants()) do
                if child:IsA("ProximityPrompt") then
                    AddLog("NPC", "   💬 Prompt: [" .. child.ActionText .. "] dist=" .. child.MaxActivationDistance, Color3.fromRGB(100, 255, 100))
                elseif child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then
                    AddLog("NPC", "   📜 " .. child.ClassName .. ": " .. child:GetFullName(), Color3.fromRGB(200, 150, 255))
                elseif child:IsA("ObjectValue") or child:IsA("StringValue") or child:IsA("IntValue") then
                    AddLog("NPC", "   🔑 " .. child.ClassName .. " '" .. child.Name .. "' = " .. tostring(child.Value), Color3.fromRGB(255, 150, 150))
                end
            end
            for k, v in pairs(obj:GetAttributes()) do
                AddLog("NPC", "   ⚙️ " .. k .. " = " .. tostring(v), Color3.fromRGB(255, 255, 0))
            end
        end
    end
    
    -- UI MerchantShop
    local mUI = LocalPlayer.PlayerGui:FindFirstChild("MerchantShop")
    if mUI then
        AddLog("UI", "✅ MerchantShop encontrada", Color3.fromRGB(0, 255, 100))
        for _, obj in pairs(mUI:GetDescendants()) do
            if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                AddLog("UI", "   📜 " .. obj:GetFullName(), Color3.fromRGB(150, 200, 255))
            end
        end
    else
        AddLog("UI", "⚠️ MerchantShop no visible aún", Color3.fromRGB(255, 255, 0))
    end
    
    -- Knit Services
    AddLog("KNIT", "🧠 Buscando Knit/Services/Controllers...", Color3.fromRGB(200, 200, 255))
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("ModuleScript") then
            local n = string.lower(obj.Name)
            if string.find(n, "sell") or string.find(n, "merchant") or string.find(n, "inventory") or string.find(n, "dialogue") then
                AddLog("KNIT", "   📦 " .. obj:GetFullName(), Color3.fromRGB(150, 255, 200))
            end
        end
    end
    AddLog("SCAN", "══════════════════════════════════", Color3.fromRGB(255, 200, 0))
end)

-- ==========================================
-- BOTON: INTERCEPTOR (COPIADO DEL VENTA ANALYZER QUE SI FUNCIONA)
-- ==========================================
local HookActivo = false
local OriginalNamecall = nil

BtnHook.MouseButton1Click:Connect(function()
    HookActivo = not HookActivo
    
    if HookActivo then
        BtnHook.Text = "🔴 INTERCEPTOR ARMADO"
        BtnHook.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        AddLog("HOOK", "══════════════════════════════════", Color3.fromRGB(255, 50, 50))
        AddLog("HOOK", "🔴 ESCUCHANDO TODO EL TRÁFICO...", Color3.fromRGB(255, 100, 100))
        AddLog("HOOK", "👉 VE Y VENDE MANUALMENTE 1 ITEM AHORA.", Color3.fromRGB(255, 255, 0))
        
        if not OriginalNamecall then
            -- ESTE ES EL HOOK EXACTO DEL VENTA ANALYZER QUE SI FUNCIONO
            OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                
                if not HookActivo then return OriginalNamecall(self, ...) end
                if checkcaller() then return OriginalNamecall(self, ...) end
                
                if method == "InvokeServer" or method == "FireServer" then
                    local name = tostring(self.Name)
                    local args = {...}
                    
                    -- Anti-spam minimo
                    local lowName = string.lower(name)
                    local spam = string.find(lowName, "toolactivated") or 
                                 string.find(lowName, "mouse") or 
                                 string.find(lowName, "movement") or 
                                 string.find(lowName, "updateexp") or
                                 string.find(lowName, "camera")
                                 
                    if not spam then
                        task.spawn(function()
                            AddLog("📤OUT", method .. " -> " .. name, Color3.fromRGB(255, 50, 255))
                            
                            -- ARGUMENTOS CON TIPOS ESTRICTOS
                            for i, v in ipairs(args) do
                                AddLog("📦ARG", "[" .. i .. "] = " .. StrictDump(v), Color3.fromRGB(200, 100, 255))
                            end
                            
                            -- TRACEBACK (qué módulo lo mandó)
                            local trace = debug.traceback()
                            for line in string.gmatch(trace, "[^\r\n]+") do
                                if string.find(line, "PlayerScripts") or string.find(line, "PlayerGui") or string.find(line, "ReplicatedStorage") or string.find(line, "Packages") or string.find(line, "Knit") then
                                    AddLog("🧬TRACE", line, Color3.fromRGB(255, 255, 150))
                                end
                            end
                        end)
                        
                        -- Capturar respuesta si es InvokeServer
                        if method == "InvokeServer" then
                            local ret = {OriginalNamecall(self, ...)}
                            task.spawn(function()
                                for i, v in ipairs(ret) do
                                    AddLog("📥RET", "[" .. i .. "] = " .. StrictDump(v), Color3.fromRGB(0, 255, 150))
                                end
                                if #ret == 0 then
                                    AddLog("📥RET", "nil (el servidor no devolvió nada)", Color3.fromRGB(150, 255, 150))
                                end
                            end)
                            return unpack(ret)
                        end
                    end
                end
                
                return OriginalNamecall(self, ...)
            end)
        end
    else
        BtnHook.Text = "📡 ACTIVAR INTERCEPTOR"
        BtnHook.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        AddLog("HOOK", "⚪ Interceptor apagado.", Color3.fromRGB(150, 150, 150))
    end
end)

AddLog("SISTEMA", "🔬 SUPER FORENSE V2.0 CARGADO", Color3.fromRGB(150, 255, 150))
AddLog("SISTEMA", "1. Escanea NPC con el botón naranja", Color3.fromRGB(255, 255, 200))
AddLog("SISTEMA", "2. Activa Interceptor y vende 1 item manual", Color3.fromRGB(255, 255, 200))
