-- ==============================================================================
-- 🕵️ OMNI-FORENSICS V5.0 "TITAN" (BYPASS CACHE & AGGRESSIVE SCAN)
-- Optimizado para Delta Exploit | Framework: Knit / Comm
-- ==============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- --- CONFIGURACIÓN DE ACTUALIZACIÓN ---
local SCRIPT_URL = "https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"
local InterceptorActivo = false
local ReportHistory = {}

-- ==========================================
-- 1. INTERFAZ GRÁFICA (UI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OmniForensics_Titan"
ScreenGui.ResetOnSpawn = false
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Parent = parentUI

-- Icono Flotante (Minimizado)
local FloatingIcon = Instance.new("ImageButton")
FloatingIcon.Size = UDim2.new(0, 50, 0, 50)
FloatingIcon.Position = UDim2.new(0.02, 0, 0.4, 0)
FloatingIcon.BackgroundColor3 = Color3.fromRGB(0, 255, 128)
FloatingIcon.Image = "rbxassetid://10886105073"
FloatingIcon.Visible = false
FloatingIcon.Draggable = true
FloatingIcon.Parent = ScreenGui
Instance.new("UICorner", FloatingIcon).CornerRadius = UDim.new(1, 0)

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 680, 0, 520)
MainFrame.Position = UDim2.new(0.5, -340, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(0, 255, 128)
Stroke.Thickness = 1.5

-- Monitor En Vivo (Monitor que mostraste en la imagen)
local LivePanel = Instance.new("Frame")
LivePanel.Size = UDim2.new(0, 260, 0, 400)
LivePanel.Position = UDim2.new(1, 10, 0, 0)
LivePanel.BackgroundColor3 = Color3.fromRGB(5, 10, 5)
LivePanel.Parent = MainFrame
Instance.new("UIStroke", LivePanel).Color = Color3.fromRGB(0, 200, 100)

local LiveTitle = Instance.new("TextLabel")
LiveTitle.Size = UDim2.new(1, 0, 0, 25)
LiveTitle.BackgroundColor3 = Color3.fromRGB(0, 60, 30)
LiveTitle.Text = " 🟢 LIVE MONITOR (TITAN)"
LiveTitle.TextColor3 = Color3.fromRGB(0, 255, 128)
LiveTitle.Font = Enum.Font.Code
LiveTitle.Parent = LivePanel

local LiveText = Instance.new("TextLabel")
LiveText.Size = UDim2.new(1, -10, 1, -30)
LiveText.Position = UDim2.new(0, 5, 0, 30)
LiveText.BackgroundTransparency = 1
LiveText.Text = "Apunta a un objetivo..."
LiveText.TextColor3 = Color3.fromRGB(200, 255, 200)
LiveText.TextSize = 11
LiveText.Font = Enum.Font.Code
LiveText.TextXAlignment = Enum.TextXAlignment.Left
LiveText.TextYAlignment = Enum.TextYAlignment.Top
LiveText.TextWrapped = true
LiveText.Parent = LivePanel

-- ==========================================
-- 2. BOTONES DE CONTROL
-- ==========================================
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
Title.Text = "  🕵️ OMNI-FORENSICS V5.0 | ENGINE TITAN"
Title.TextColor3 = Color3.fromRGB(0, 255, 128)
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -60, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "_"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Parent = MainFrame

local UpdateBtn = Instance.new("TextButton")
UpdateBtn.Size = UDim2.new(0.48, 0, 0, 35)
UpdateBtn.Position = UDim2.new(0.01, 0, 0, 40)
UpdateBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
UpdateBtn.Text = "🔄 ACTUALIZAR (FORCE NO-CACHE)"
UpdateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UpdateBtn.Font = Enum.Font.Code
UpdateBtn.Parent = MainFrame

local CopyAllBtn = Instance.new("TextButton")
CopyAllBtn.Size = UDim2.new(0.48, 0, 0, 35)
CopyAllBtn.Position = UDim2.new(0.51, 0, 0, 40)
CopyAllBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 80)
CopyAllBtn.Text = "📋 COPIAR REPORTE ORDENADO"
CopyAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyAllBtn.Font = Enum.Font.Code
CopyAllBtn.Parent = MainFrame

local InterBtn = Instance.new("TextButton")
InterBtn.Size = UDim2.new(1, -20, 0, 35)
InterBtn.Position = UDim2.new(0, 10, 0, 80)
InterBtn.BackgroundColor3 = Color3.fromRGB(20, 40, 80)
InterBtn.Text = "📡 INTERCEPTOR RED: OFF"
InterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
InterBtn.Font = Enum.Font.Code
InterBtn.Parent = MainFrame

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -20, 1, -130)
LogScroll.Position = UDim2.new(0, 10, 0, 125)
LogScroll.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogScroll.ScrollBarThickness = 2
LogScroll.Parent = MainFrame
Instance.new("UIListLayout", LogScroll).Padding = UDim.new(0, 2)

-- ==========================================
-- 3. LÓGICA DE ACTUALIZACIÓN Y MINIMIZADO
-- ==========================================
MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FloatingIcon.Visible = true
end)

FloatingIcon.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    FloatingIcon.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

UpdateBtn.MouseButton1Click:Connect(function()
    UpdateBtn.Text = "BYPASSING CACHE..."
    local finalUrl = SCRIPT_URL .. "?nocache=" .. tostring(tick()) .. tostring(math.random(1, 999))
    ScreenGui:Destroy()
    loadstring(game:HttpGet(finalUrl))()
end)

-- ==========================================
-- 4. INTERCEPTOR AGRESIVO
-- ==========================================
local function AddLog(prefix, name, details)
    local entry = string.format("[%s] [%s] %s\n%s\n", os.date("%X"), prefix, name, details)
    table.insert(ReportHistory, entry)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -5, 0, 25)
    label.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    label.Text = " [" .. prefix .. "] " .. name
    label.TextColor3 = prefix == "NET" and Color3.fromRGB(0, 255, 128) or Color3.fromRGB(0, 200, 255)
    label.Font = Enum.Font.Code
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = LogScroll
end

InterBtn.MouseButton1Click:Connect(function()
    InterceptorActivo = not InterceptorActivo
    InterBtn.Text = InterceptorActivo and "📡 INTERCEPTOR: ON (ESCUCHANDO)" or "📡 INTERCEPTOR: OFF"
    InterBtn.BackgroundColor3 = InterceptorActivo and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(20, 40, 80)
end)

CopyAllBtn.MouseButton1Click:Connect(function()
    local finalReport = table.concat(ReportHistory, "\n")
    if setclipboard then
        setclipboard(finalReport)
        CopyAllBtn.Text = "✅ ¡COPIADO!"
        task.wait(1)
        CopyAllBtn.Text = "📋 COPIAR REPORTE ORDENADO"
    end
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if InterceptorActivo and (method == "FireServer" or method == "InvokeServer") then
        local name = self.Name
        local args = {...}
        
        -- Ignorar ping y movimiento
        if name ~= "Ping" and not string.find(string.lower(name), "move") then
            local argStr = "Path: " .. self:GetFullName() .. "\nArgs: " .. HttpService:JSONEncode(args)
            task.spawn(function() AddLog("NET", name, argStr) end)
        end
    end
    return oldNamecall(self, ...)
end))

-- ==========================================
-- 5. LIVE MONITOR (MEJORADO PARA NPCS)
-- ==========================================
RunService.Heartbeat:Connect(function()
    local target = Mouse.Target
    if not target then 
        LiveText.Text = "Apunta a un objetivo..."
        return 
    end

    local txt = "🎯 PARTE: " .. target.Name .. "\n"
    txt = txt .. "📂 RUTA: " .. target:GetFullName() .. "\n\n"

    local model = target:FindFirstAncestorWhichIsA("Model")
    if model then
        txt = txt .. "👾 MODELO: " .. model.Name .. "\n"
        local hum = model:FindFirstChildWhichIsA("Humanoid")
        if hum then
            local pct = math.floor((hum.Health / math.max(hum.MaxHealth, 1)) * 100)
            txt = txt .. "❤️ HP: " .. string.format("%.0f/%.0f", hum.Health, hum.MaxHealth) .. " (" .. pct .. "%)\n"
            txt = txt .. "🏃 SPEED: " .. tostring(hum.WalkSpeed) .. "\n"
        end
        
        -- Escaneo de Atributos Críticos
        txt = txt .. "\n💎 ATRIBUTOS:\n"
        for k, v in pairs(model:GetAttributes()) do
            txt = txt .. " > " .. k .. " = " .. tostring(v) .. "\n"
        end
    end
    
    LiveText.Text = txt
end)

AddLog("SISTEMA", "V5.0 Titan Cargada", "Listo para ingeniería inversa.")
