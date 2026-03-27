-- ==============================================================================
-- 🔨 FORGE OMNI-ANALYZER V1.1 (MODO DIOS - SIN FILTROS)
-- Diseñado para captar el 100% de la actividad de red en la forja.
-- ==============================================================================

local SCRIPT_VERSION = "V1.1 - MODO DIOS"

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
Panel.BorderColor3 = Color3.fromRGB(255, 50, 50) -- Rojo vivo para V1.1
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
Title.Text = " 📡 FORGE ANALYZER V1.1 (MODO DIOS)"
Title.TextColor3 = Color3.fromRGB(255, 200, 200)
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

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -8, 1, -80)
LogScroll.Position = UDim2.new(0, 4, 0, 35)
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
local MasterLogList = {}

local function AddUILog(message, color)
    local timestamp = os.date("%H:%M:%S")
    local fullString = "[" .. timestamp .. "] " .. message
    
    table.insert(MasterLogList, fullString)
    
    -- Protección contra saturación de UI (Dejamos los últimos 300)
    if #MasterLogList > 300 then
        table.remove(MasterLogList, 1)
        local first = LogScroll:FindFirstChildWhichIsA("TextLabel")
        if first then first:Destroy() end
    end
    
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
    
    -- Ajustar la altura dependiendo del texto
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
    local result = "=== REPORTE TOTAL SIN FILTROS (V1.1) ===\n\n"
    for i, _ in ipairs(MasterLogList) do
        result = result .. MasterLogList[i] .. "\n"
    end
    
    if setclipboard then
        setclipboard(result)
        CopyBtn.Text = "✅ ¡COPIADO!"
    else
        CopyBtn.Text = "❌ ERROR: No soportado"
    end
    task.delay(2, function() CopyBtn.Text = "📋 COPIAR AL PORTAPAPELES" end)
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ==========================================
-- EL HOOK BESTIAL SIN FILTROS (MODO DIOS)
-- ==========================================
-- Palabras a bloquear para no saturar con el movimiento/mouse inútil del jugador
local BlacklistWords = {
    "move", "mouse", "camera", "ping", "update", "render", "step", "chat", 
    "character", "root", "position", "look"
}

local OriginalNamecall
OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- Si es el Executor, ignóralo. Solo atrapamos los RemoteFunctions o RemoteEvents
    if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
        local fullName = self:GetFullName()
        local nameLower = string.lower(fullName)
        
        -- Filtramos la basura constante
        local skip = false
        for _, word in pairs(BlacklistWords) do
            if string.find(nameLower, word) then
                skip = true
                break
            end
        end
        
        if not skip then
            -- Mapear variables a texto puro
            local argDump = ""
            for i, v in ipairs(args) do
                local vType = typeof(v)
                if vType == "table" then
                    argDump = argDump .. "Arg["..i.."]=TABLE{ "
                    for k2, v2 in pairs(v) do
                        argDump = argDump .. "["..tostring(k2).."]="..tostring(v2)..", "
                    end
                    argDump = argDump .. "} "
                else
                    argDump = argDump .. "Arg["..i.."]="..tostring(v).." ("..vType.."), "
                end
            end
            if argDump == "" then argDump = "<Sin Argumentos>" end
            
            -- Imprimir en el Log UI
            AddUILog(string.upper(method) .. " -> " .. fullName .. "\n   " .. argDump, Color3.fromRGB(200, 200, 255))
        end
    end
    
    return OriginalNamecall(self, ...)
end)

AddUILog("📡 V1.1 (MODO DIOS) INICIADO.", Color3.fromRGB(150, 255, 150))
AddUILog("► Ve al forjador, crea el arma completa, dale al botón COPIAR LOGS (abajo en azul).", Color3.fromRGB(200, 255, 200))
