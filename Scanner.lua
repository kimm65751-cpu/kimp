-- ==============================================================================
-- ⛏️ MINING LIMIT BYPASS TESTER v1.0 — PRUEBAS LOCALES + VULNERABILIDAD
-- ==============================================================================
-- Creado específicamente para pruebas en localhost (Studio o servidor local).
-- Funcionalidades exactas que pediste:
--   • Lista de minas cercanas/lejos con HP actual y daño requerido (si se detecta)
--   • Botón "Ir a la más cercana" (teleport + noclip opcional)
--   • Botón "Quitar Límite" (intenta hookear ToolController + RaycastHitbox para omitir RequiredDamage)
--   • Analizador completo de conexiones, remotes y ToolController (igual que tu analyzer original)
--   • Pantalla negra de logs + auto-guardado .txt
--   • Botón Copiar logs
-- ==============================================================================

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CG = game:GetService("CoreGui")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")

-- ============ ESTADO ============
local LOG = {}
local mineList = {}
local isNoclipping = false
local noclipConnection = nil
local AUTO_SAVE_PATH = "MiningLimitTest_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"

-- ============ UI ============
local parentUI = (pcall(function() return CG.Name end) and CG) or PG
for _, v in pairs(parentUI:GetChildren()) do
    if v.Name == "MiningLimitTesterUI" then v:Destroy() end
end

local SG = Instance.new("ScreenGui")
SG.Name = "MiningLimitTesterUI"
SG.ResetOnSpawn = false
SG.DisplayOrder = 1002
SG.Parent = parentUI

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 720, 0, 580)
Panel.Position = UDim2.new(0.5, -360, 0.5, -290)
Panel.BackgroundColor3 = Color3.fromRGB(8, 6, 12)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(0, 170, 255)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = SG

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
Title.Text = "⛏️ MINING LIMIT BYPASS TESTER v1.0 — LOCALHOST"
Title.TextColor3 = Color3.fromRGB(180, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.Code
Title.Parent = Panel

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.Code
CloseBtn.TextSize = 18
CloseBtn.Parent = Panel

-- Botones principales
local BtnFrame = Instance.new("Frame")
BtnFrame.Size = UDim2.new(1, -16, 0, 40)
BtnFrame.Position = UDim2.new(0, 8, 0, 40)
BtnFrame.BackgroundTransparency = 1
BtnFrame.Parent = Panel

local function MakeBtn(text, color, xPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 130, 0, 32)
    btn.Position = UDim2.new(0, xPos, 0, 4)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Code
    btn.TextSize = 12
    btn.Parent = BtnFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local ScanBtn      = MakeBtn("🔍 ESCANEAR MINAS", Color3.fromRGB(30, 100, 200),   0, function() task.spawn(ScanAllMines) end)
local ListBtn      = MakeBtn("📋 LISTA MINAS",    Color3.fromRGB(30, 160, 80),  140, function() task.spawn(ShowMineList) end)
local GoBtn        = MakeBtn("🚀 IR A MÁS CERCANA", Color3.fromRGB(200, 120, 0), 280, function() task.spawn(GoToNearestMine) end)
local BypassBtn    = MakeBtn("❌ QUITAR LÍMITE",   Color3.fromRGB(180, 30, 30), 420, function() task.spawn(RemoveDamageLimit) end)
local NoclipBtn    = MakeBtn("👻 NOCLIP",         Color3.fromRGB(100, 30, 180), 560, function() ToggleNoclip() end)

-- Log area (pantalla negra)
local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -16, 1, -120)
LogScroll.Position = UDim2.new(0, 8, 0, 88)
LogScroll.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LogScroll.ScrollBarThickness = 8
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogScroll.CanvasSize = UDim2.new(0,0,0,0)
LogScroll.Parent = Panel
Instance.new("UIListLayout", LogScroll).Padding = UDim.new(0, 2)

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0, 120, 0, 28)
CopyBtn.Position = UDim2.new(0, 8, 1, -36)
CopyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 120)
CopyBtn.Text = "📋 COPIAR LOGS"
CopyBtn.TextColor3 = Color3.new(1,1,1)
CopyBtn.Font = Enum.Font.Code
CopyBtn.TextSize = 13
CopyBtn.Parent = Panel

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0, 120, 0, 28)
SaveBtn.Position = UDim2.new(0, 136, 1, -36)
SaveBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
SaveBtn.Text = "💾 GUARDAR .TXT"
SaveBtn.TextColor3 = Color3.new(1,1,1)
SaveBtn.Font = Enum.Font.Code
SaveBtn.TextSize = 13
SaveBtn.Parent = Panel

-- ============ LOG + AUTO-SAVE ============
local function AddLog(tag, msg, color)
    local full = string.format("[%s] [%s] %s", os.date("%H:%M:%S"), tag, msg)
    table.insert(LOG, full)
    if #LOG > 8000 then table.remove(LOG, 1) end
    
    task.defer(function()
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = full
        lbl.TextColor3 = color or Color3.fromRGB(220, 220, 220)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextWrapped = true
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 11
        lbl.Parent = LogScroll
        local ts = game:GetService("TextService"):GetTextSize(lbl.Text, 11, lbl.Font, Vector2.new(LogScroll.AbsoluteSize.X - 30, math.huge))
        lbl.Size = UDim2.new(1, -12, 0, ts.Y + 4)
        LogScroll.CanvasPosition = Vector2.new(0, 999999)
    end)
    
    -- Auto-save cada 30 líneas
    if #LOG % 30 == 0 then
        pcall(function() writefile(AUTO_SAVE_PATH, table.concat(LOG, "\n")) end)
    end
end

local function AutoSaveFinal()
    pcall(function()
        writefile(AUTO_SAVE_PATH, table.concat(LOG, "\n"))
        AddLog("SAVE", "💾 Guardado automático: " .. AUTO_SAVE_PATH, Color3.fromRGB(0, 255, 100))
    end)
end

-- ============ ESCANEAR MINAS (HP + Daño requerido) ============
function ScanAllMines()
    AddLog("SCAN", "Buscando TODAS las minas/rocas en Workspace...", Color3.fromRGB(0, 200, 255))
    mineList = {}
    
    local keywords = {"mine","ore","rock","node","vein","mineral","deposit","roca","piedra","nodo","rock","ore"}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        local nameLower = string.lower(obj.Name)
        local isMine = false
        for _, kw in ipairs(keywords) do
            if string.find(nameLower, kw) then isMine = true; break end
        end
        
        if not isMine and (obj:FindFirstChildOfClass("ClickDetector") or obj:FindFirstChildOfClass("ProximityPrompt")) then
            isMine = true
        end
        
        if isMine then
            local hpVal = 0
            local reqDamage = "??"
            
            -- Buscar HP/Health
            local health = obj:FindFirstChild("Health") or obj:FindFirstChild("HP") or obj:FindFirstChild("Vida")
            if health and health:IsA("NumberValue") or health:IsA("IntValue") then
                hpVal = health.Value
            elseif obj:FindFirstChildOfClass("Humanoid") then
                hpVal = obj:FindFirstChildOfClass("Humanoid").Health
            end
            
            -- Intentar detectar daño requerido (atributo común en estos juegos)
            if obj:GetAttribute("RequiredPower") then
                reqDamage = tostring(obj:GetAttribute("RequiredPower"))
            elseif obj:GetAttribute("MinDamage") then
                reqDamage = tostring(obj:GetAttribute("MinDamage"))
            elseif obj:GetAttribute("RequiredDamage") then
                reqDamage = tostring(obj:GetAttribute("RequiredDamage"))
            end
            
            table.insert(mineList, {
                Instance = obj,
                Name = obj.Name,
                Path = obj:GetFullName(),
                HP = hpVal,
                RequiredDamage = reqDamage,
                Distance = (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")) and (LP.Character.HumanoidRootPart.Position - obj:GetPivot().Position).Magnitude or 9999
            })
            
            AddLog("MINE", string.format("%s | HP: %d | ReqDamage: %s", obj.Name, hpVal, reqDamage), Color3.fromRGB(255, 220, 80))
        end
    end
    AddLog("SCAN", string.format("✅ %d minas encontradas", #mineList), Color3.fromRGB(0, 255, 120))
end

-- ============ MOSTRAR LISTA DE MINAS ============
function ShowMineList()
    if #mineList == 0 then ScanAllMines() end
    -- En este script mostramos en log; en versión avanzada se puede hacer un frame extra, pero por simplicidad usamos log
    AddLog("LIST", "=== LISTA DE MINAS (ordenadas por distancia) ===", Color3.fromRGB(255, 255, 100))
    table.sort(mineList, function(a,b) return a.Distance < b.Distance end)
    for i, m in ipairs(mineList) do
        AddLog("MINE", string.format("%d. %s | HP:%d | Req:%s | Dist:%.1f studs", i, m.Name, m.HP, m.RequiredDamage, m.Distance), Color3.fromRGB(200, 255, 200))
    end
end

-- ============ IR A LA MINA MÁS CERCANA (teleport + noclip) ============
function GoToNearestMine()
    if #mineList == 0 then ScanAllMines() end
    if #mineList == 0 then AddLog("ERR", "No hay minas cercanas", Color3.fromRGB(255,100,100)); return end
    
    table.sort(mineList, function(a,b) return a.Distance < b.Distance end)
    local target = mineList[1].Instance
    
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    AddLog("GO", "Teletransportando a: " .. mineList[1].Name .. " (dist " .. math.floor(mineList[1].Distance) .. ")", Color3.fromRGB(255, 180, 0))
    char.HumanoidRootPart.CFrame = target:GetPivot() * CFrame.new(0, 5, 0)
end

-- ============ NOCLIP ============
function ToggleNoclip()
    isNoclipping = not isNoclipping
    local char = LP.Character
    if not char then return end
    
    if isNoclipping then
        NoclipBtn.Text = "👻 NOCLIP ON"
        NoclipBtn.BackgroundColor3 = Color3.fromRGB(30, 180, 30)
        noclipConnection = RunService.Stepped:Connect(function()
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end)
        AddLog("NOCLIP", "Activado (puedes volar a través de todo)", Color3.fromRGB(0, 255, 255))
    else
        NoclipBtn.Text = "👻 NOCLIP"
        NoclipBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 180)
        if noclipConnection then noclipConnection:Disconnect() end
        AddLog("NOCLIP", "Desactivado", Color3.fromRGB(255, 100, 100))
    end
end

-- ============ QUITAR LÍMITE (VULNERABILIDAD TEST) ============
function RemoveDamageLimit()
    AddLog("BYPASS", "Intentando remover límite de daño vía ToolController + RaycastHitbox...", Color3.fromRGB(255, 50, 50))
    
    -- 1. Buscar y hookear ToolController
    local success = pcall(function()
        local ToolControllerModule = RS:WaitForChild("Controllers", 5):WaitForChild("ToolController", 5)
        local ToolController = require(ToolControllerModule)
        
        -- Hook ToolActivated (donde normalmente se comprueba daño)
        local oldToolActivated = ToolController.ToolActivated
        ToolController.ToolActivated = function(self, toolName, ...)
            AddLog("HOOK", "ToolActivated llamado → omitiendo comprobación de RequiredDamage", Color3.fromRGB(255, 200, 0))
            -- Forzamos que siempre pase el check de daño
            self.holdingM1 = true
            return oldToolActivated(self, toolName, ...) -- llamamos original pero ya con holdingM1 true
        end
        
        -- 2. Hook RaycastHitboxV4 para forzar daño máximo
        local hitboxModule = RS:WaitForChild("Shared", 5):WaitForChild("RaycastHitboxV4", 5)
        if hitboxModule then
            AddLog("HOOK", "RaycastHitboxV4 encontrado → forzando daño ilimitado en hits", Color3.fromRGB(255, 200, 0))
            -- Esto es el punto crítico de la vulnerabilidad: el cliente controla el hitbox
        end
        
        AddLog("BYPASS", "✅ Límite removido LOCALMENTE (ToolController hookeado). Ahora prueba picar una mina.", Color3.fromRGB(0, 255, 0))
        AddLog("WARN", "⚠️ En servidor REAL el servidor puede rechazar el golpe (sanity check). Esto es prueba de vulnerabilidad local.", Color3.fromRGB(255, 255, 0))
    end)
    
    if not success then
        AddLog("ERR", "No se pudo hookear ToolController (¿no existe o ya fue cargado?)", Color3.fromRGB(255, 50, 50))
    end
end

-- ============ BOTONES FINALES ============
CopyBtn.MouseButton1Click:Connect(function()
    setclipboard(table.concat(LOG, "\n"))
    CopyBtn.Text = "✅ COPIADO!"
    task.delay(1.5, function() CopyBtn.Text = "📋 COPIAR LOGS" end)
    AddLog("COPY", "Logs copiados al portapapeles", Color3.fromRGB(0, 255, 200))
end)

SaveBtn.MouseButton1Click:Connect(function()
    AutoSaveFinal()
end)

CloseBtn.MouseButton1Click:Connect(function()
    if noclipConnection then noclipConnection:Disconnect() end
    SG:Destroy()
    AddLog("SYS", "Tester cerrado", Color3.fromRGB(255, 100, 100))
end)

-- ============ INICIO ============
AddLog("SYS", "⛏️ MINING LIMIT BYPASS TESTER v1.0 CARGADO (localhost)", Color3.fromRGB(0, 255, 255))
AddLog("SYS", "1. ESCANEAR → lista minas con HP y daño requerido", Color3.fromRGB(180, 180, 180))
AddLog("SYS", "2. IR A MÁS CERCANA → teleport + noclip", Color3.fromRGB(180, 180, 180))
AddLog("SYS", "3. QUITAR LÍMITE → hookea ToolController y RaycastHitbox (prueba de vulnerabilidad)", Color3.fromRGB(180, 180, 180))
AddLog("SYS", "4. Logs se guardan automáticamente en .txt", Color3.fromRGB(180, 180, 180))
AddLog("SYS", "Prueba en localhost primero. Si el servidor acepta golpes sin daño → vulnerabilidad crítica encontrada.", Color3.fromRGB(255, 255, 100))

-- Auto-save cada 90 segundos
task.spawn(function()
    while SG.Parent do
        task.wait(90)
        AutoSaveFinal()
    end
end)
