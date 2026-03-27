-- ==============================================================================
-- 🔨 FORGE OMNI-ANALYZER V1.0 - (Forgotten Kingdom Island 2)
-- Analizador Forense de Red, Logs y Eventos del NPC de Forja.
-- ==============================================================================

local SCRIPT_VERSION = "V1.0 - ANALIZADOR DE FORJA"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- ELIMINAR GUI ANTERIOR (Si existe)
-- ==========================================
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do
    if v.Name == "ForgeAnalyzerUI" then v:Destroy() end
end

-- ==========================================
-- CREACIÓN DE GUI (MONITOR LOGS)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ForgeAnalyzerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 480, 0, 360)
Panel.Position = UDim2.new(1, -500, 0.5, -180) -- Lado derecho de la pantalla
Panel.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(255, 150, 0) -- Naranja de forja
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(100, 50, 0)
Title.Text = " 🔨 FORGE OMNI-ANALYZER V1.0"
Title.TextColor3 = Color3.fromRGB(255, 200, 50)
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

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, 0, 0, 20)
SubTitle.Position = UDim2.new(0, 0, 0, 30)
SubTitle.BackgroundColor3 = Color3.fromRGB(40, 20, 10)
SubTitle.Text = "  Interceptando tráfico de red hacia el servidor..."
SubTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
SubTitle.TextSize = 11
SubTitle.Font = Enum.Font.Code
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = Panel

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -8, 1, -100)
LogScroll.Position = UDim2.new(0, 4, 0, 55)
LogScroll.BackgroundColor3 = Color3.fromRGB(10, 15, 10)
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogScroll.ScrollBarThickness = 6
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.Parent = Panel
local ListLayout = Instance.new("UIListLayout", LogScroll)
ListLayout.Padding = UDim.new(0, 2)

local ControlsFrame = Instance.new("Frame")
ControlsFrame.Size = UDim2.new(1, -8, 0, 40)
ControlsFrame.Position = UDim2.new(0, 4, 1, -42)
ControlsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ControlsFrame.Parent = Panel

local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0.5, -2, 1, 0)
ClearBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ClearBtn.Text = "🗑️ LIMPIAR LOGS"
ClearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearBtn.Font = Enum.Font.Code
ClearBtn.TextSize = 12
ClearBtn.Parent = ControlsFrame

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0.5, -2, 1, 0)
CopyBtn.Position = UDim2.new(0.5, 2, 0, 0)
CopyBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 150)
CopyBtn.Text = "📋 COPIAR AL PORTAPAPELES"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.Code
CopyBtn.TextSize = 12
CopyBtn.Parent = ControlsFrame

-- ==========================================
-- SISTEMA DE LOGS INTERNO (Almacenamiento y UI)
-- ==========================================
local MasterLogList = {} -- Para poder copiar todo el texto fácilmente

local function AddUILog(logType, message, color)
    local timestamp = os.date("%H:%M:%S")
    local fullString = "[" .. timestamp .. "] [" .. logType .. "] " .. message
    
    table.insert(MasterLogList, fullString)
    
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, -4, 0, 0)
    txt.BackgroundTransparency = 1
    txt.Text = fullString
    txt.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    txt.Font = Enum.Font.Code
    txt.TextSize = 11
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.TextWrapped = true
    txt.Parent = LogScroll
    
    -- Ajustar la altura dependiendo del texto (Simple fix)
    local textSize = game:GetService("TextService"):GetTextSize(txt.Text, txt.TextSize, txt.Font, Vector2.new(LogScroll.AbsoluteSize.X - 15, math.huge))
    txt.Size = UDim2.new(1, -4, 0, textSize.Y + 4)
    
    -- Auto-scroll al fondo
    LogScroll.CanvasPosition = Vector2.new(0, 999999)
end

-- ==========================================
-- EVENTOS BOTONES INFERIORES
-- ==========================================
ClearBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(LogScroll:GetChildren()) do
        if v:IsA("TextLabel") then v:Destroy() end
    end
    MasterLogList = {}
end)

CopyBtn.MouseButton1Click:Connect(function()
    local result = "=== REPORTE DE FORJA FORGOTTEN KINGDOM ===\n\n"
    for i, _ in ipairs(MasterLogList) do
        result = result .. MasterLogList[i] .. "\n"
    end
    
    if setclipboard then
        setclipboard(result)
        CopyBtn.Text = "✅ ¡COPIADO!"
        task.delay(2, function() CopyBtn.Text = "📋 COPIAR AL PORTAPAPELES" end)
    else
        CopyBtn.Text = "❌ ERROR: No soportado"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ==========================================
-- NÚCLEO SNIFFER: INTERCEPCIÓN DE RED (HOOK)
-- ==========================================
local OriginalNamecall
OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() then return OriginalNamecall(self, ...) end
    
    -- Interceptar llamadas cliente-servidor
    if method == "FireServer" or method == "InvokeServer" then
        local remoteName = self.Name
        local remoteNameLower = string.lower(remoteName)
        local parentName = self.Parent and string.lower(self.Parent.Name) or "nil"
        local grandParentName = self.Parent and self.Parent.Parent and string.lower(self.Parent.Parent.Name) or "nil"
        
        -- Filtro: Solo buscamos eventos de Forge, Minigame, Hammer o Knit Core.
        if string.find(remoteNameLower, "forge") or string.find(parentName, "forge") or string.find(grandParentName, "forge")
           or string.find(remoteNameLower, "minigame") or string.find(parentName, "minigame")
           or string.find(remoteNameLower, "hammer") or string.find(parentName, "hammer")
           or string.find(parentName, "knit") then
           
            -- Analizar tabla de argumentos a un texto plano:
            local argDump = ""
            for i, v in ipairs(args) do
                local vType = typeof(v)
                if vType == "table" then
                    argDump = argDump .. "Arg["..i.."]="..vType.." {\n"
                    for k2, v2 in pairs(v) do
                        argDump = argDump .. "  ["..tostring(k2).."] = " .. tostring(v2) .. " (" .. typeof(v2) .. ")\n"
                    end
                    argDump = argDump .. "}, "
                else
                    argDump = argDump .. "Arg["..i.."]=" .. tostring(v) .. " (" .. vType .. "), "
                end
            end
            
            -- Mandar al Log
            AddUILog("NETWORK", string.upper(method) .. " -> " .. self:GetFullName() .. "\n" .. argDump, Color3.fromRGB(255, 200, 50))
            print("[FORGE ANALYZER] -> " .. self:GetFullName() .. " | " .. argDump)
        end
    end
    
    return OriginalNamecall(self, ...)
end)

-- ==========================================
-- NÚCLEO BÚSQUEDA DE NPCs Y ESTRUCTURAS DE FORJA
-- ==========================================
-- Buscar de forma pasiva cosas rotuladas como "Forge" en workspace para sacar coordenadas
task.spawn(function()
    AddUILog("INFO", "Escaneando Workspace en busca de NPCs/Objetos de Forja...", Color3.fromRGB(150, 150, 255))
    local foundSomething = false
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if typeof(obj.Name) == "string" and string.find(string.lower(obj.Name), "forge") then
            -- Verificamos si es un NPC o un Modelo con Position
            if obj:IsA("Model") then
                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                if root then
                    AddUILog("SCAN", "Hallado: [" .. obj.Name .. "] en " .. tostring(root.Position), Color3.fromRGB(150, 255, 150))
                    foundSomething = true
                end
            end
        end
    end
    
    if not foundSomething then
        AddUILog("SCAN", "No se encontraron Modelos nombrados 'Forge' a simple vista. (El NPC puede tener un nombre genérico).", Color3.fromRGB(255, 100, 100))
    end
end)

AddUILog("SISTEMA", "Forge Omni-Analyzer Inyectado Exitosamente. Cierra esta ventana con la 'X'.\nVe a crear un arma de forma normal. Toda la comunicación de los círculos, el martillo y la olla quedará grabada aquí.", Color3.fromRGB(100, 255, 100))
