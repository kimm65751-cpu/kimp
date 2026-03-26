-- ==============================================================================
-- 🕵️ OMNI-FORENSICS ULTIMATE V2.0 (DEEP-SCAN & INTERCEPTOR)
-- Motor de ingeniería inversa para análisis de Remotos y Atributos.
-- ==============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. CREACIÓN DE LA INTERFAZ (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OmniForensicsV2"
ScreenGui.ResetOnSpawn = false
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Parent = parentUI

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 650, 0, 450)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Bordes neón
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 255, 150)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Title.Text = " 🕵️ OMNI-FORENSICS V2.0 | RECONOCIMIENTO PROFUNDO"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.TextSize = 14
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.TextSize = 20
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local DumpBtn = Instance.new("TextButton")
DumpBtn.Size = UDim2.new(0.48, 0, 0, 40)
DumpBtn.Position = UDim2.new(0.01, 0, 0, 45)
DumpBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 60)
DumpBtn.Text = "🔍 ESCÁNER FORENSE TOTAL"
DumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DumpBtn.Font = Enum.Font.Code
DumpBtn.Parent = MainFrame

local InterceptBtn = Instance.new("TextButton")
InterceptBtn.Size = UDim2.new(0.48, 0, 0, 40)
InterceptBtn.Position = UDim2.new(0.51, 0, 0, 45)
InterceptBtn.BackgroundColor3 = Color3.fromRGB(20, 40, 60)
InterceptBtn.Text = "📡 INTERCEPTOR: OFF"
InterceptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
InterceptBtn.Font = Enum.Font.Code
InterceptBtn.Parent = MainFrame

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -20, 1, -100)
LogScroll.Position = UDim2.new(0, 10, 0, 95)
LogScroll.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogScroll.ScrollBarThickness = 4
LogScroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Parent = LogScroll
UIList.Padding = UDim.new(0, 5)

-- ==========================================
-- 2. SISTEMA DE REGISTRO (LOGS)
-- ==========================================
local function AddLog(Prefix, TitleText, Details)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -5, 0, 60)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.Parent = LogScroll
    
    local titleLab = Instance.new("TextLabel")
    titleLab.Size = UDim2.new(1, -70, 0.4, 0)
    titleLab.Position = UDim2.new(0, 10, 0.1, 0)
    titleLab.BackgroundTransparency = 1
    titleLab.Text = "[" .. Prefix .. "] " .. TitleText
    titleLab.TextColor3 = (Prefix == "CRÍTICO" or Prefix == "RED") and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(0, 255, 255)
    titleLab.TextXAlignment = Enum.TextXAlignment.Left
    titleLab.Font = Enum.Font.Code
    titleLab.TextSize = 12
    titleLab.Parent = frame
    
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 60, 0, 25)
    copyBtn.Position = UDim2.new(1, -65, 0.5, -12)
    copyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    copyBtn.Text = "COPY"
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.Font = Enum.Font.Code
    copyBtn.Parent = frame
    
    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(Details)
            copyBtn.Text = "OK!"
            task.wait(1)
            copyBtn.Text = "COPY"
        end
    end)
end

-- ==========================================
-- 3. MOTOR DE ANÁLISIS PROFUNDO
-- ==========================================
local function DeepScanObject(obj)
    local data = "--- REPORTE DE OBJETO ---\n"
    data = data .. "Full Name: " .. obj:GetFullName() .. "\n"
    data = data .. "Class: " .. obj.ClassName .. "\n"
    
    -- Escaneo de Atributos (Donde se esconden llaves de seguridad)
    data = data .. "Atributos:\n"
    for k, v in pairs(obj:GetAttributes()) do
        data = data .. "  > " .. k .. " : " .. tostring(v) .. " (" .. typeof(v) .. ")\n"
    end
    
    -- Escaneo de Sibling Configs (Archivos de configuración hermanos)
    if obj.Parent then
        data = data .. "Hermanos Críticos:\n"
        for _, sibling in pairs(obj.Parent:GetChildren()) do
            if sibling:IsA("ModuleScript") or sibling:IsA("Configuration") then
                data = data .. "  ! Posible Config: " .. sibling.Name .. "\n"
            end
        end
    end
    return data
end

-- ==========================================
-- 4. INTERCEPTOR DE RED (METAMETHOD HOOK)
-- ==========================================
local InterceptorActivo = false
local oldNamecall

InterceptBtn.MouseButton1Click:Connect(function()
    InterceptorActivo = not InterceptorActivo
    if InterceptorActivo then
        InterceptBtn.Text = "📡 INTERCEPTOR: ON"
        InterceptBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
        AddLog("SISTEMA", "Red Activada", "Interceptando tráfico de salida...")
    else
        InterceptBtn.Text = "📡 INTERCEPTOR: OFF"
        InterceptBtn.BackgroundColor3 = Color3.fromRGB(20, 40, 60)
    end
end)

oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local methodStr = string.lower(tostring(method))
    
    if InterceptorActivo and (methodStr == "fireserver" or methodStr == "invokeserver") then
        local args = {...}
        local selfName = tostring(self.Name)
        local nLow = string.lower(selfName)
        
        -- FILTRO DE PUNTOS CRÍTICOS (Hitbox, Damage, Mine, Combat)
        if string.find(nLow, "hit") or string.find(nLow, "dmg") or string.find(nLow, "mine") or string.find(nLow, "attack") then
            
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            local metaData = DeepScanObject(self)
            
            local argDump = "\n--- ARGUMENTOS DETECTADOS ---\n"
            for i, v in ipairs(args) do
                local vType = typeof(v)
                local vVal = tostring(v)
                if vType == "Instance" then vVal = v:GetFullName() end
                if vType == "table" then pcall(function() vVal = HttpService:JSONEncode(v) end) end
                argDump = argDump .. "[" .. i .. "] (" .. vType .. "): " .. vVal .. "\n"
            end
            
            local fullReport = metaData .. "\nTool en Mano: " .. (tool and tool.Name or "None") .. "\n" .. argDump
            task.spawn(function() AddLog("CRÍTICO", selfName, fullReport) end)
        end
    end
    return oldNamecall(self, ...)
end))

-- ==========================================
-- 5. BOTÓN DE ESCANEO GENERAL (DUMP)
-- ==========================================
DumpBtn.MouseButton1Click:Connect(function()
    AddLog("SISTEMA", "Iniciando Escrutinio...", "Escaneando Workspace y ReplicatedStorage en busca de vulnerabilidades.")
    
    -- Buscar Remotos con nombres sospechosos
    for _, rem in pairs(game:GetDescendants()) do
        if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
            local n = string.lower(rem.Name)
            if string.find(n, "hitbox") or string.find(n, "damage") or string.find(n, "remote") then
                local report = DeepScanObject(rem)
                AddLog("HALLAZGO", rem.Name, report)
            end
        end
    end
end)

AddLog("SISTEMA", "V2.0 Ready", "Consola forense cargada con éxito en Delta.")
