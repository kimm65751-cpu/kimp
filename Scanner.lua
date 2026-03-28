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
-- ESCANER DE ERRORES SILENCIOSOS (ScriptContext)
-- ==========================================
game:GetService("ScriptContext").Error:Connect(function(message, trace, script)
    -- Solo logeamos errores relacionados al jugador o inventario
    if string.find(string.lower(trace), "playergui") or string.find(string.lower(trace), "replicatedstorage") then
        Log(" ", Color3.fromRGB(0,0,0))
        Log("☠️ ¡CRASH INTERNO DEL JUEGO DETECTADO!", Color3.fromRGB(255, 0, 0))
        Log("📝 Error: " .. tostring(message), Color3.fromRGB(255, 100, 100))
        Log("📜 Script Culpable: " .. (script and script:GetFullName() or "Desconocido"), Color3.fromRGB(255, 150, 150))
        Log("🔍 Traceback:", Color3.fromRGB(200, 50, 50))
        for line in string.gmatch(trace, "[^\r\n]+") do
            Log("  -> " .. line, Color3.fromRGB(200, 150, 150))
        end
        Log("--------------------------------------------------", Color3.fromRGB(100, 100, 100))
    end
end)

-- ==========================================
-- ESCANER DE CHIVATOS DE DEVELOPERS (LogService)
-- ==========================================
game:GetService("LogService").MessageOut:Connect(function(message, messageType)
    local lowMsg = string.lower(message)
    if string.find(lowMsg, "error") or string.find(lowMsg, "fail") or string.find(lowMsg, "invalid") or string.find(lowMsg, "basket") or string.find(lowMsg, "sell") then
        if messageType == Enum.MessageType.MessageWarning or messageType == Enum.MessageType.MessageError or messageType == Enum.MessageType.MessageOutput then
            Log("📢 LOG DESARROLLADOR: " .. message, Color3.fromRGB(255, 100, 200))
        end
    end
end)

-- ==========================================
-- ESCANEO DE MÓDULOS DE UI RECIÉN CREADOS (MERCHANT)
-- Y RAYOS X AL NPC SEY
-- ==========================================
Log("🔍 [FASE 1] ESCANEANDO CEREBRO DE INTERFAZ & NPC...", Color3.fromRGB(255, 200, 0))

local merchantUI = LocalPlayer.PlayerGui:FindFirstChild("MerchantShop")
if merchantUI then
    Log("✅ UI MerchantShop detectada. Archivos claves encontrados:", Color3.fromRGB(0, 255, 100))
    for _, obj in pairs(merchantUI:GetDescendants()) do
        if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            Log("   -> " .. obj:GetFullName(), Color3.fromRGB(150, 200, 255))
        end
    end
else
    Log("⚠️ No se encontró la UI MerchantShop (quizás se carga cuando le hablas).", Color3.fromRGB(255, 255, 0))
end

Log("\n🔍 BUSCANDO A SEY EN WORKSPACE PARA RAYOS X...", Color3.fromRGB(255, 200, 0))
local seyTotal = 0
for _, obj in pairs(game.Workspace:GetDescendants()) do
    if obj:IsA("Model") and string.find(string.lower(obj.Name), "cey") then
        seyTotal = seyTotal + 1
        Log("👤 NPC Encontrado: " .. obj:GetFullName(), Color3.fromRGB(0, 255, 255))
        
        -- Escanear los scripts físicos en su cuerpo
        for _, child in pairs(obj:GetDescendants()) do
            if child:IsA("ProximityPrompt") then
                Log("   💬 Usa ProximityPrompt: " .. child.ObjectText, Color3.fromRGB(100, 255, 100))
            elseif child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then
                Log("   📜 Script atado a él: " .. child:GetFullName(), Color3.fromRGB(200, 150, 255))
            elseif child:IsA("ObjectValue") or child:IsA("StringValue") then
                Log("   🔑 Variable secreta: " .. child.Name .. " = " .. tostring(child.Value), Color3.fromRGB(255, 150, 150))
            end
        end
        
        local attrs = obj:GetAttributes()
        for k, v in pairs(attrs) do
            Log("   ⚙️ Atributo: " .. k .. " = " .. tostring(v), Color3.fromRGB(255, 255, 0))
        end
    end
end

if seyTotal == 0 then Log("❌ SEY no visto en la zona actual o el mundo usa ChunkLoading.", Color3.fromRGB(255, 0, 0)) end
Log("--------------------------------------------------\n", Color3.fromRGB(100, 100, 100))

-- ==========================================
-- HOOK ULTRA AGRESIVO
-- ==========================================
Log("🔴 HOOK ACTIVADO. VE Y VENDE MANUALMENTE 1 ITEM A SEY...", Color3.fromRGB(255, 100, 100))

local OriginalNamecall
OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = tostring(getnamecallmethod())
    local args = {...}
    
    if method == "InvokeServer" or method == "FireServer" or method == "invokeServer" or method == "fireServer" then
        -- Protección a prueba de balas para no causar crashes
        local nameStr = "UnknownRemote"
        pcall(function() nameStr = tostring(self.Name) end)
        
        -- SOLO CAZAR LOS 4 REMOTOS QUE NECESITAMOS, SIN FILTROS DE SPAM QUE CAUSEN FALSOS POSITIVOS
        if nameStr == "RunCommand" or nameStr == "ForceDialogue" or nameStr == "DialogueEvent" or nameStr == "Dialogue" then
            task.spawn(function()
                Log(" ", Color3.fromRGB(0,0,0))
                Log("🚨 INTERCEPTADO: " .. method .. " -> '" .. nameStr .. "'", Color3.fromRGB(255, 0, 255))
                
                -- Dumpear Argumentos con TIPOS ESTRICTOS Y VALORES REALES
                local dumpText = ""
                for i, v in ipairs(args) do
                    dumpText = dumpText .. "[Arg " .. i .. "]: " .. StrictDump(v) .. "\n"
                end
                if dumpText ~= "" then Log("📦 ARGUMENTOS CRUDOS:\n" .. dumpText, Color3.fromRGB(200, 200, 255)) end
                
                -- Dumpear Traceback (¿Quién y qué módulo mandó la señal exactamente?)
                local trace = debug.traceback()
                Log("🕵️ MÓDULO ORIGEN (Traceback):", Color3.fromRGB(255, 200, 50))
                
                local foundTrace = false
                for line in string.gmatch(trace, "[^\r\n]+") do
                    if string.find(line, "PlayerScripts") or string.find(line, "PlayerGui") or string.find(line, "ReplicatedStorage") or string.find(line, "Packages") then
                        Log("  -> " .. line, Color3.fromRGB(255, 255, 150))
                        foundTrace = true
                    end
                end
                
                if not foundTrace then 
                    Log("  -> Invocación directa del Motor Roblox (Core/C++).", Color3.fromRGB(150, 150, 150)) 
                end
                
                Log("--------------------------------------------------", Color3.fromRGB(100, 100, 100))
            end)
            
            -- Si es un Invoke, capturar obligatoriamente qué nos dijo el servidor
            if method == "InvokeServer" or method == "invokeServer" then
                local ret = {OriginalNamecall(self, ...)}
                task.spawn(function()
                    local retDump = ""
                    for i, v in ipairs(ret) do
                        retDump = retDump .. "[Ret " .. i .. "]: " .. StrictDump(v) .. "\n"
                    end
                    if retDump ~= "" then
                        Log("📥 RESPUESTA DEL SERVER ('" .. nameStr .. "'):\n" .. retDump, Color3.fromRGB(0, 255, 0))
                    else
                        Log("📥 EL SERVER NO DEVOLVIÓ NADA ('" .. nameStr .. "') -> nil", Color3.fromRGB(150, 255, 150))
                    end
                end)
                return unpack(ret)
            end
        end
    end
    
    return OriginalNamecall(self, ...)
end)
