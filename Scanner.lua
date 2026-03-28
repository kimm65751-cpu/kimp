-- ==============================================================================
-- 📡 TACTICAL NETWORK SNIFFER V1.0 (ANÁLISIS PROFUNDO DE VENTAS)
-- Detecta y vuelca todos los datos, argumentos y módulos que se comunican
-- entre el Cliente y el Servidor durante el proceso exacto de VENTA.
-- ==============================================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local LogHistory = {}
local TermScroll -- Declaramos aquí para usarla en Log

local function Log(msg)
    local fullMsg = "["..os.date("%H:%M:%S").."] " .. msg
    table.insert(LogHistory, fullMsg)
    print(fullMsg)
    
    if TermScroll then
        pcall(function()
            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1, -4, 0, 0)
            txt.BackgroundTransparency = 1
            txt.Text = fullMsg
            txt.TextColor3 = Color3.fromRGB(200, 255, 200)
            txt.Font = Enum.Font.Code
            txt.TextSize = 10
            txt.TextXAlignment = Enum.TextXAlignment.Left
            txt.TextWrapped = true
            txt.Parent = TermScroll
            
            local tsz = game:GetService("TextService"):GetTextSize(txt.Text, txt.TextSize, txt.Font, Vector2.new(TermScroll.AbsoluteSize.X-15, math.huge))
            txt.Size = UDim2.new(1, -4, 0, tsz.Y + 2)
            TermScroll.CanvasPosition = Vector2.new(0, 999999)
        end)
    end
end

Log("=============================================")
Log("📡 INICIANDO INTERCEPTOR DE TRÁFICO...")
Log("=============================================")
Log("Script activo. Ve y VENDE ALGO AL NPC MANUALMENTE AHORA MISMO.")
Log("Registrando todas las peticiones InvokeServer y FireServer...")

-- Función recursiva profunda para aplanar tablas (las ventas mandan diccionarios complejos)
local function DeepDump(t, depth)
    local maxDepth = 5
    depth = depth or 0
    
    if type(t) == "string" then return '"'..t..'"' end
    if type(t) == "number" or type(t) == "boolean" then return tostring(t) end
    if type(t) == "userdata" then return "<UserData:" .. tostring(t) .. ">" end
    if type(t) == "function" then return "<Function>" end
    if type(t) ~= "table" then return "<" .. type(t) .. ">" end
    
    if depth > maxDepth then return "{...}" end
    
    local res = "{"
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
        local keyStr = (type(k) == "string") and k or "["..tostring(k).."]"
        
        local valStr = ""
        local ok, err = pcall(function()
            if type(v) == "table" then
                valStr = DeepDump(v, depth + 1)
            elseif type(v) == "string" then
                valStr = '"'..v..'"'
            elseif type(v) == "userdata" then
                valStr = "<UserData:" .. tostring(v) .. ">"
            else
                valStr = tostring(v)
            end
        end)
        if not ok then valStr = "<ErrorLeyendoValor>" end
        
        res = res .. keyStr .. " = " .. valStr .. ", "
    end
    
    if count == 0 then return "{}" end
    return string.sub(res, 1, -3) .. "}"
end

-- ==========================================
-- HOOK DE METATABLA (EL NÚCLEO ESPÍA)
-- ==========================================
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- Solo interceptar comunicación cliente -> servidor
    if method == "InvokeServer" or method == "FireServer" then
        local remoteName = self.Name
        
        -- Ignorar remotes de movimiento o sonido para no saturar el log de basura
        if remoteName ~= "CharacterSoundEvent" and remoteName ~= "UpdateMouse" and remoteName ~= "MoveEvent" then
            
            -- Si es uno de los remotos críticos de tienda, registrar a máxima profundidad
            if remoteName == "RunCommand" or string.find(string.lower(remoteName), "dialogue") or string.find(string.lower(remoteName), "sell") or string.find(string.lower(remoteName), "shop") or string.find(string.lower(remoteName), "inventory") then
                
                Log("\n⚠️ [INTERCEPCIÓN CRÍTICA - " .. remoteName .. "]")
                Log("-> [MÉTODO]: " .. method)
                
                -- Detectar llamador (módulo cliente) si es posible
                local caller = debug.getinfo(2, "s")
                if caller and caller.source then
                    Log("-> [MÓDULO CLIENTE QUE LO ACTIVÓ]: " .. tostring(caller.source))
                end
                
                Log("-> [CLIENTE ENVIANDO DATOS]: " .. DeepDump(args))
                
                -- Si es un InvokeServer, podemos interceptar EXACTAMENTE qué responde el servidor
                if method == "InvokeServer" then
                    local res = {oldNamecall(self, ...)}
                    Log("<- [SERVIDOR RESPONDE]: " .. DeepDump(res))
                    Log("=============================================")
                    return unpack(res)
                else
                    Log("=============================================")
                end
            else
                -- Si es otro remote desconocido, registrémoslo igual pero de forma más sutil
                Log("-> [Remote Detectado]: " .. remoteName .. " | Data: " .. DeepDump(args))
            end
        end
    end
    
    -- Dejar pasar la llamada real para que el juego no se rompa
    return oldNamecall(self, ...)
end)

setreadonly(mt, true)

-- ==========================================
-- INTERFAZ GRÁFICA PARA DETENER EL SNIFFER
-- ==========================================
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

for _, v in pairs(parentUI:GetChildren()) do if v.Name == "SnifferVentasUI" then v:Destroy() end end

local SG = Instance.new("ScreenGui")
SG.Name = "SnifferVentasUI"
SG.ResetOnSpawn = false
SG.Parent = parentUI

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 450, 0, 350)
Panel.Position = UDim2.new(0.5, -225, 0.5, -175)
Panel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(255, 50, 50)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = SG

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
Title.Text = " 🔴 RED SNIFFER - LOG EN VIVO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.Code
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Panel

TermScroll = Instance.new("ScrollingFrame")
TermScroll.Size = UDim2.new(1, -10, 1, -80)
TermScroll.Position = UDim2.new(0, 5, 0, 35)
TermScroll.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
TermScroll.ScrollBarThickness = 6
TermScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
TermScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TermScroll.Parent = Panel
local Layout = Instance.new("UIListLayout", TermScroll)
Layout.Padding = UDim.new(0, 2)

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0.5, -10, 0, 35)
CopyBtn.Position = UDim2.new(0, 5, 1, -40)
CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
CopyBtn.Text = "📋 COPIAR PORTAPAPELES"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.Code
CopyBtn.TextSize = 11
CopyBtn.Parent = Panel
CopyBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard(table.concat(LogHistory, "\n")); CopyBtn.Text = "✅ COPIADO" end)
    task.delay(2, function() CopyBtn.Text = "📋 COPIAR PORTAPAPELES" end)
end)

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0.5, -5, 0, 35)
SaveBtn.Position = UDim2.new(0.5, 0, 1, -40)
SaveBtn.BackgroundColor3 = Color3.fromRGB(150, 80, 0)
SaveBtn.Text = "💾 GUARDAR EXPORT"
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBtn.Font = Enum.Font.Code
SaveBtn.TextSize = 11
SaveBtn.Parent = Panel

SaveBtn.MouseButton1Click:Connect(function()
    local data = table.concat(LogHistory, "\n")
    pcall(function()
        if writefile then
            writefile("SnifferDeVentas_Log.txt", data)
            SaveBtn.Text = "✅ GUARDADO!"
            SaveBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
        else
            SaveBtn.Text = "❌ SIN WRITEFILE"
            SaveBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
    end)
    task.delay(3, function() SaveBtn.Text = "💾 GUARDAR EXPORT"; SaveBtn.BackgroundColor3 = Color3.fromRGB(150, 80, 0) end)
end)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 60, 0, 30)
CloseBtn.Position = UDim2.new(1, -60, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "CERRAR"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.Code
CloseBtn.Parent = Panel
CloseBtn.MouseButton1Click:Connect(function()
    pcall(function()
        setreadonly(mt, false)
        mt.__namecall = oldNamecall
        setreadonly(mt, true)
    end)
    SG:Destroy()
end)

-- Re-escribir los logs iniciales en la consola viva
for _, ms in ipairs(LogHistory) do
    Log(ms)
end
