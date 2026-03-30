-- ==============================================================================
-- ⛏️ MINING BYPASS TESTER v1.4 — RE-ANALIZADO DEL .LUA Y .TXT ORIGINAL
-- ==============================================================================
-- Basado 100% en MiningAnalyzer.lua (ScanMines + keywords) + tu log .txt
-- Filtra flatrock (terreno falso), prioriza minas reales con Health/HP/Atributos

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

local LOG = {}
local mineList = {}
local isNoclipping = false
local noclipConn = nil
local AUTO_SAVE_PATH = "MiningBypass_v1.4_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"

-- UI
local SG = Instance.new("ScreenGui")
SG.Name = "MiningBypass_v1_4"
SG.ResetOnSpawn = false
SG.DisplayOrder = 9999
SG.Parent = game:GetService("CoreGui") or LP:WaitForChild("PlayerGui")

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 820, 0, 680)
Panel.Position = UDim2.new(0.5, -410, 0.5, -340)
Panel.BackgroundColor3 = Color3.fromRGB(8, 6, 12)
Panel.BorderColor3 = Color3.fromRGB(0, 180, 255)
Panel.Active = false
Panel.Draggable = true
Panel.Parent = SG

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -55, 0, 42)
Title.BackgroundColor3 = Color3.fromRGB(0, 70, 140)
Title.Text = "⛏️ MINING BYPASS v1.4 — RE-ANALIZADO DEL .TXT"
Title.TextColor3 = Color3.fromRGB(180, 255, 255)
Title.TextSize = 15
Title.Font = Enum.Font.Code
Title.Parent = Panel

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 55, 0, 42)
CloseBtn.Position = UDim2.new(1, -55, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.TextSize = 20
CloseBtn.Font = Enum.Font.Code
CloseBtn.Parent = Panel

-- Botones
local function MakeBtn(text, color, xPos)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 148, 0, 38)
    b.Position = UDim2.new(0, xPos, 0, 50)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.Code
    b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    b.Parent = Panel
    return b
end

local ScanBtn   = MakeBtn("🔍 ESCANEAR MINAS", Color3.fromRGB(30,100,200), 10)
local ListBtn   = MakeBtn("📋 MOSTRAR LISTA", Color3.fromRGB(30,160,80), 168)
local GoBtn     = MakeBtn("🚀 IR A MÁS CERCANA", Color3.fromRGB(200,120,0), 326)
local BypassBtn = MakeBtn("❌ QUITAR LÍMITE", Color3.fromRGB(180,30,30), 484)
local NoclipBtn = MakeBtn("👻 NOCLIP", Color3.fromRGB(100,30,180), 642)

-- Selección manual
local SelectLabel = Instance.new("TextLabel")
SelectLabel.Size = UDim2.new(0, 190, 0, 28)
SelectLabel.Position = UDim2.new(0, 10, 0, 98)
SelectLabel.BackgroundTransparency = 1
SelectLabel.Text = "Ir a mina número →"
SelectLabel.TextColor3 = Color3.fromRGB(180,255,255)
SelectLabel.TextSize = 13
SelectLabel.Font = Enum.Font.Code
SelectLabel.Parent = Panel

local SelectBox = Instance.new("TextBox")
SelectBox.Size = UDim2.new(0, 70, 0, 28)
SelectBox.Position = UDim2.new(0, 210, 0, 98)
SelectBox.BackgroundColor3 = Color3.fromRGB(25,25,25)
SelectBox.Text = "1"
SelectBox.TextColor3 = Color3.new(1,1,1)
SelectBox.Font = Enum.Font.Code
SelectBox.TextSize = 15
SelectBox.Parent = Panel

local GoSelectBtn = Instance.new("TextButton")
GoSelectBtn.Size = UDim2.new(0, 110, 0, 28)
GoSelectBtn.Position = UDim2.new(0, 290, 0, 98)
GoSelectBtn.BackgroundColor3 = Color3.fromRGB(0,160,80)
GoSelectBtn.Text = "IR A ESTA MINA"
GoSelectBtn.TextColor3 = Color3.new(1,1,1)
GoSelectBtn.Font = Enum.Font.Code
GoSelectBtn.Parent = Panel

-- Log
local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -20, 1, -170)
LogScroll.Position = UDim2.new(0, 10, 0, 135)
LogScroll.BackgroundColor3 = Color3.fromRGB(0,0,0)
LogScroll.ScrollBarThickness = 8
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogScroll.Parent = Panel
Instance.new("UIListLayout", LogScroll).Padding = UDim.new(0,2)

local function AddLog(tag, msg, color)
    local str = string.format("[%s] [%s] %s", os.date("%H:%M:%S"), tag, msg)
    table.insert(LOG, str)
    task.defer(function()
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Text = str
        lbl.TextColor3 = color or Color3.fromRGB(220,220,220)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextWrapped = true
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 11
        lbl.Size = UDim2.new(1,-20,0,0)
        lbl.Parent = LogScroll
        local ts = game:GetService("TextService"):GetTextSize(lbl.Text,11,lbl.Font,Vector2.new(LogScroll.AbsoluteSize.X-40,9999))
        lbl.Size = UDim2.new(1,-20,0,ts.Y+8)
        LogScroll.CanvasPosition = Vector2.new(0,999999)
    end)
end

-- ====================== ESCÁNER (RE-ANALIZADO DEL .LUA ORIGINAL) ======================
local function ScanAllMines()
    AddLog("SCAN", "Escaneando con la misma lógica del MiningAnalyzer.lua original...", Color3.fromRGB(255,200,0))
    mineList = {}

    local keywords = {"mine","ore","rock","node","vein","mineral","deposit","mina","piedra","roca","nodo","coal","iron","gold","diamond","crystal","gem","stone","copper","silver","cobalt"}

    for _, obj in ipairs(Workspace:GetDescendants()) do
        local nameLower = string.lower(obj.Name)

        -- FILTRO ESTRICTO: eliminar flatrock (terreno falso que aparece en tu log)
        if string.find(nameLower, "flatrock") then continue end

        local isMine = false

        -- Misma lógica del .lua original
        for _, kw in ipairs(keywords) do
            if string.find(nameLower, kw) then isMine = true; break end
        end

        -- También cualquier objeto con ClickDetector o ProximityPrompt (como en el .lua original)
        if not isMine and (obj:FindFirstChildOfClass("ClickDetector") or obj:FindFirstChildOfClass("ProximityPrompt")) then
            isMine = true
        end

        -- También objetos con atributos numéricos (Health, RequiredPower, etc.)
        if not isMine then
            pcall(function()
                for k, v in pairs(obj:GetAttributes()) do
                    if typeof(v) == "number" and v > 0 then isMine = true; break end
                end
            end)
        end

        if isMine then
            local hp = 0
            local req = "??"

            local health = obj:FindFirstChild("Health") or obj:FindFirstChild("HP") or obj:FindFirstChild("Vida")
            if health then hp = health.Value or 0 end
            if obj:FindFirstChildOfClass("Humanoid") then hp = obj:FindFirstChildOfClass("Humanoid").Health end

            for _, key in ipairs({"RequiredPower","MinDamage","RequiredDamage","PowerNeeded"}) do
                if obj:GetAttribute(key) then req = tostring(obj:GetAttribute(key)) break end
            end

            local dist = 9999
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then dist = (hrp.Position - obj:GetPivot().Position).Magnitude end

            table.insert(mineList, {
                Obj = obj,
                Name = obj.Name .. " [" .. obj.ClassName .. "]",
                HP = math.floor(hp),
                Required = req,
                Distance = dist,
                Path = obj:GetFullName()
            })
        end
    end

    table.sort(mineList, function(a,b) return a.Distance < b.Distance end)
    AddLog("SCAN", "✅ " .. #mineList .. " MINAS REALES encontradas (flatrock eliminado)", Color3.fromRGB(0,255,120))
end

-- Funciones restantes (IR, NOCLIP, BYPASS, CERRAR)
local function GoToMine(index)
    if #mineList == 0 then AddLog("ERR","Primero ESCANEAR MINAS", Color3.fromRGB(255,80,80)) return end
    local m = mineList[index]
    if not m then return end
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = m.Obj:GetPivot() * CFrame.new(0,6,0)
        AddLog("GO", "Tele a #"..index.." → "..m.Name, Color3.fromRGB(255,180,0))
    end
end

local function GoToNearest() if #mineList == 0 then ScanAllMines() end GoToMine(1) end

local function ToggleNoclip()
    isNoclipping = not isNoclipping
    local char = LP.Character
    if isNoclipping then
        NoclipBtn.Text = "👻 NOCLIP ON"
        noclipConn = RunService.Stepped:Connect(function()
            for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
        end)
    else
        NoclipBtn.Text = "👻 NOCLIP"
        if noclipConn then noclipConn:Disconnect() end
    end
end

local function RemoveDamageLimit()
    AddLog("BYPASS", "Hookeando ToolController (como en tu log original)", Color3.fromRGB(255,50,50))
    pcall(function()
        local ToolController = require(RS:WaitForChild("Controllers"):WaitForChild("ToolController"))
        local old = ToolController.ToolActivated
        ToolController.ToolActivated = function(self, ...) self.holdingM1 = true return old(self, ...) end
        AddLog("BYPASS", "✅ Límite removido localmente", Color3.fromRGB(0,255,0))
    end)
end

-- Conexiones
ScanBtn.MouseButton1Click:Connect(function() task.spawn(ScanAllMines) end)
ListBtn.MouseButton1Click:Connect(function()
    if #mineList == 0 then ScanAllMines() end
    AddLog("LIST", "=== MINAS REALES (elige número) ===", Color3.fromRGB(255,255,100))
    for i, m in ipairs(mineList) do
        AddLog("MINE", string.format("%d → %s | HP:%d | Req:%s | Dist:%.0f", i, m.Name, m.HP, m.Required, m.Distance), Color3.fromRGB(200,255,180))
    end
end)
GoBtn.MouseButton1Click:Connect(GoToNearest)
GoSelectBtn.MouseButton1Click:Connect(function() local n = tonumber(SelectBox.Text) if n then GoToMine(n) end end)
BypassBtn.MouseButton1Click:Connect(RemoveDamageLimit)
NoclipBtn.MouseButton1Click:Connect(ToggleNoclip)
CloseBtn.MouseButton1Click:Connect(function() if noclipConn then noclipConn:Disconnect() end SG:Destroy() end)

AddLog("SYS", "v1.4 CARGADO — Re-analizado del .lua y .txt original", Color3.fromRGB(0,255,255))
AddLog("SYS", "Pulsa ESCANEAR MINAS cerca de las rocas reales", Color3.fromRGB(255,200,80))
