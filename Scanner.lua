-- ==============================================================================
-- 📡 TACTICAL NETWORK SNIFFER V3.0 (ULTRA SEGURO - ANTI CRASH)
-- Basado en diseño estable. No bloquea el hilo principal del juego.
-- ==============================================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local LogHistory = {}
local TermScroll = nil 

local function Log(msg)
    local fullMsg = "["..os.date("%H:%M:%S").."] " .. msg
    table.insert(LogHistory, fullMsg)
    
    if TermScroll then
        task.spawn(function()
            pcall(function()
                local txt = Instance.new("TextLabel")
                txt.Size = UDim2.new(1, -4, 0, 0)
                txt.BackgroundTransparency = 1
                txt.Text = fullMsg
                txt.TextColor3 = Color3.fromRGB(150, 255, 150)
                txt.Font = Enum.Font.Code
                txt.TextSize = 11
                txt.TextXAlignment = Enum.TextXAlignment.Left
                txt.TextWrapped = true
                txt.Parent = TermScroll
                
                local tsz = game:GetService("TextService"):GetTextSize(txt.Text, txt.TextSize, txt.Font, Vector2.new(TermScroll.AbsoluteSize.X-15, 9999))
                txt.Size = UDim2.new(1, -4, 0, tsz.Y + 4)
                TermScroll.CanvasPosition = Vector2.new(0, 999999)
            end)
        end)
    else
        print(fullMsg)
    end
end

-- ==========================================
-- DUMPER SEGURO: Previene Cuelgues por Recursividad
-- ==========================================
local function DeepDump(t, depth, visited)
    depth = depth or 0
    visited = visited or {}
    local maxDepth = 4
    
    if type(t) == "string" then return '"'..t..'"' end
    if type(t) == "number" or type(t) == "boolean" then return tostring(t) end
    if type(t) == "userdata" then return "<UserData:" .. tostring(t) .. ">" end
    if type(t) == "function" then return "<Function>" end
    if type(t) ~= "table" then return "<" .. type(t) .. ">" end
    
    if depth > maxDepth then return "{... MAX DEPTH}" end
    if visited[t] then return "{... CIRCULAR REF}" end
    visited[t] = true
    
    local res = "{"
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
        local keyStr = (type(k) == "string") and k or "["..tostring(k).."]"
        local valStr = ""
        pcall(function() valStr = DeepDump(v, depth + 1, visited) end)
        res = res .. keyStr .. " = " .. valStr .. ", "
    end
    
    if count == 0 then return "{}" end
    return string.sub(res, 1, -3) .. "}"
end

-- ==========================================
-- HOOK ULTRA-LIGERO (Previene el cuelgue del motor)
-- ==========================================
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    
    if method == "InvokeServer" or method == "FireServer" then
        local remoteName = self.Name
        
        -- SOLO procesaremos si el Remote tiene nombres específicos de venta
        if remoteName == "RunCommand" or remoteName == "ForceDialogue" or string.find(string.lower(remoteName), "sell") then
            local args = {...}
            
            -- Tarea Asíncrona para Log de Envío (NO cuelga el juego)
            task.spawn(function()
                Log("\n⚠️ [INTERCEPCIÓN " .. method .. "] " .. remoteName)
                local payloadDump = DeepDump(args)
                Log("-> [CLIENTE ENVÍA]: " .. payloadDump)
            end)
            
            -- Si es InvokeServer, capturamos asíncronamente qué responde el servidor
            if method == "InvokeServer" then
                local res = {oldNamecall(self, ...)}
                task.spawn(function()
                    Log("<- [SERVIDOR RESPONDE]: " .. DeepDump(res))
                    Log(string.rep("-", 40))
                end)
                return unpack(res)
            end
        end
    end
    
    -- Devolvemos inmediatamente la función original, el juego nunca se frena
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

Log("✅ Hook insertado exitosamente. Cero Lag Garantizado.")

-- ==========================================
-- GUI ULTRA-SEGURA (Evitando Draggable Depreciado)
-- ==========================================
local guiParent = nil
pcall(function() guiParent = CoreGui end)
if not guiParent then guiParent = LocalPlayer:WaitForChild("PlayerGui") end

for _, v in pairs(guiParent:GetChildren()) do 
    if v.Name == "_SnifferSeguroUI" then v:Destroy() end 
end

local SG = Instance.new("ScreenGui")
SG.Name = "_SnifferSeguroUI"
SG.ResetOnSpawn = false
SG.Parent = guiParent

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 500, 0, 360)
main.Position = UDim2.new(0.5, -250, 0.5, -180)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
main.BorderSizePixel = 2
main.BorderColor3 = Color3.fromRGB(240, 100, 100)
main.Active = true
main.Parent = SG

-- Sistema de Dragging Moderno y Seguro
local dragging, dragStart, startPos = false, nil, nil
main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
main.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local topbar = Instance.new("Frame")
topbar.Size = UDim2.new(1, 0, 0, 32)
topbar.BackgroundColor3 = Color3.fromRGB(140, 30, 30)
topbar.BorderSizePixel = 0
topbar.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "📡 MODO SNIFFER ACTIVO - HAZ UNA VENTA"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.Code
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topbar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -32, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.Code
closeBtn.TextSize = 14
closeBtn.BorderSizePixel = 0
closeBtn.Parent = topbar
closeBtn.MouseButton1Click:Connect(function()
    pcall(function()
        setreadonly(mt, false)
        mt.__namecall = oldNamecall
        setreadonly(mt, true)
    end)
    SG:Destroy()
end)

TermScroll = Instance.new("ScrollingFrame")
TermScroll.Size = UDim2.new(1, -16, 1, -84)
TermScroll.Position = UDim2.new(0, 8, 0, 40)
TermScroll.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
TermScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
TermScroll.ScrollBarThickness = 6
TermScroll.BorderSizePixel = 1
TermScroll.BorderColor3 = Color3.fromRGB(50, 50, 60)
TermScroll.Parent = main

local Layout = Instance.new("UIListLayout", TermScroll)
Layout.Padding = UDim.new(0, 3)

local bottomFrame = Instance.new("Frame")
bottomFrame.Size = UDim2.new(1, 0, 0, 36)
bottomFrame.Position = UDim2.new(0, 0, 1, -40)
bottomFrame.BackgroundTransparency = 1
bottomFrame.Parent = main

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0.48, 0, 1, 0)
CopyBtn.Position = UDim2.new(0, 5, 0, 0)
CopyBtn.BackgroundColor3 = Color3.fromRGB(70, 40, 140)
CopyBtn.Text = "COPIAR AL PORTAPAPELES"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.Code
CopyBtn.TextSize = 11
CopyBtn.BorderSizePixel = 0
CopyBtn.Parent = bottomFrame

CopyBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local txt = table.concat(LogHistory, "\n")
        if setclipboard then setclipboard(txt) elseif toclipboard then toclipboard(txt) end
        CopyBtn.Text = "¡COPIADO!"
        CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        task.delay(2, function()
            CopyBtn.Text = "COPIAR AL PORTAPAPELES"
            CopyBtn.BackgroundColor3 = Color3.fromRGB(70, 40, 140)
        end)
    end)
end)

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0.48, 0, 1, 0)
SaveBtn.Position = UDim2.new(0.5, 2, 0, 0)
SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
SaveBtn.Text = "GUARDAR (.TXT)"
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBtn.Font = Enum.Font.Code
SaveBtn.TextSize = 11
SaveBtn.BorderSizePixel = 0
SaveBtn.Parent = bottomFrame

SaveBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if writefile then
            writefile("SnifferDeVentas_Log.txt", table.concat(LogHistory, "\n"))
            SaveBtn.Text = "¡GUARDADO! (WORKSPACE)"
            SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        else
            SaveBtn.Text = "ERROR: SIN ACCESO WRITE"
            SaveBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
        task.delay(2, function()
            SaveBtn.Text = "GUARDAR (.TXT)"
            SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
        end)
    end)
end)

for _, m in ipairs(LogHistory) do
    Log(m)
end
