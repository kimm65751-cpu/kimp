-- ==============================================================================
-- 🔬 SUPER FORENSE VENTAS V1.0 (ANÁLISIS PROFUNDO DE TIPOS Y DEPURACIÓN)
-- ==============================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "SuperForenseUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SuperForenseUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 500, 0, 400)
Panel.Position = UDim2.new(0.5, -250, 0.5, -200)
Panel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(200, 50, 100)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(80, 20, 40)
Title.Text = " 🔬 SUPER FORENSE: ANÁLISIS PROFUNDO DE VENTA"
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

local TermHeader = Instance.new("Frame")
TermHeader.Size = UDim2.new(1, 0, 0, 25)
TermHeader.Position = UDim2.new(0, 0, 0, 30)
TermHeader.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TermHeader.Parent = Panel

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0, 100, 1, 0)
CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
CopyBtn.Text = "📋 COPIAR LOG"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.Code
CopyBtn.TextSize = 11
CopyBtn.Parent = TermHeader

local TermScroll = Instance.new("ScrollingFrame")
TermScroll.Size = UDim2.new(1, -10, 1, -65)
TermScroll.Position = UDim2.new(0, 5, 0, 60)
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

CopyBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard(table.concat(LogHistory, "\n")) end)
    CopyBtn.Text = "✅ COPIADO"
    task.delay(1.5, function() CopyBtn.Text = "📋 COPIAR LOG" end)
end)

-- ==========================================
-- DUMPER TIPO ESTRICTO
-- ==========================================
local cache = {}
local function StrictDump(val, depth)
    depth = depth or 0
    if depth > 5 then return "<-LIMITE->" end
    
    local t = typeof(val)
    if t == "Instance" then
        return "<Inst:" .. val.ClassName .. '>"' .. val:GetFullName() .. '"'
    elseif t == "table" then
        if cache[val] then return "<Tabla Recursiva>" end
        cache[val] = true
        
        local s = "{\n"
        local indent = string.rep("  ", depth + 1)
        for k, v in pairs(val) do
            s = s .. indent .. "[" .. StrictDump(k, depth + 1) .. "] = " .. StrictDump(v, depth + 1) .. ",\n"
        end
        cache[val] = nil
        return s .. string.rep("  ", depth) .. "}"
    elseif t == "string" then
        return '"' .. val .. '"(string)'
    elseif t == "number" or t == "boolean" then
        return tostring(val) .. "(" .. t .. ")"
    else
        return tostring(val) .. "(" .. t .. ")"
    end
end

-- ==========================================
-- ESCANEO DE MÓDULOS DE UI (MERCHANT)
-- ==========================================
Log("🔍 ESCANEANDO SCRIPTS EN MERCHANT SHOP...", Color3.fromRGB(255, 255, 0))
local merchantUI = LocalPlayer.PlayerGui:FindFirstChild("MerchantShop")
if merchantUI then
    for _, obj in pairs(merchantUI:GetDescendants()) do
        if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            Log("📜 Encontrado Script de UI: " .. obj:GetFullName(), Color3.fromRGB(150, 200, 255))
        end
    end
else
    Log("⚠️ No se encontro PlayerGui.MerchantShop", Color3.fromRGB(255, 100, 100))
end
Log("--------------------------------------------------", Color3.fromRGB(100, 100, 100))

-- ==========================================
-- HOOK ULTRA AGRESIVO
-- ==========================================
Log("🔴 HOOK ACTIVADO. VE Y VENDE MANUALMENTE 1 ITEM A SEY...", Color3.fromRGB(255, 100, 100))

local OriginalNamecall
OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local name = tostring(self.Name)
    local args = {...}

    if method == "InvokeServer" or method == "FireServer" then
        if name == "RunCommand" or name == "ForceDialogue" or name == "DialogueEvent" or name == "Dialogue" then
            
            task.spawn(function()
                Log(" ", Color3.fromRGB(0,0,0))
                Log("🚨 INTERCEPTADO: " .. method .. " -> " .. name, Color3.fromRGB(255, 0, 255))
                
                -- Dumpear Argumentos con TIPOS ESTRICTOS
                local dumpText = ""
                for i, v in ipairs(args) do
                    dumpText = dumpText .. "[Arg " .. i .. "]: " .. StrictDump(v) .. "\n"
                end
                Log("📦 DATOS CRUDOS:\n" .. dumpText, Color3.fromRGB(200, 200, 255))
                
                -- Dumpear Traceback (¿Quién mandó la señal?)
                local trace = debug.traceback()
                Log("🕵️ ORIGEN (Traceback):", Color3.fromRGB(255, 200, 50))
                for line in string.gmatch(trace, "[^\r\n]+") do
                    if string.find(line, "LocalScript") or string.find(line, "ModuleScript") or string.find(line, "PlayerGui") or string.find(line, "Packages") then
                        Log("  -> " .. line, Color3.fromRGB(255, 255, 150))
                    end
                end
                Log("--------------------------------------------------", Color3.fromRGB(100, 100, 100))
            end)
            
            -- Si es un Invoke, capturar respuesta también de forma estricta
            if method == "InvokeServer" then
                local ret = {OriginalNamecall(self, ...)}
                task.spawn(function()
                    local retDump = ""
                    for i, v in ipairs(ret) do
                        retDump = retDump .. "[Ret " .. i .. "]: " .. StrictDump(v) .. "\n"
                    end
                    if retDump ~= "" then
                        Log("📥 RESPUESTA SERVER (" .. name .. "):\n" .. retDump, Color3.fromRGB(0, 255, 0))
                    end
                end)
                return unpack(ret)
            end
        end
    end
    
    return OriginalNamecall(self, ...)
end)
