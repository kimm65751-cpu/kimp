-- ==============================================================================
-- 🗡️ FORGE OMNI-ANALYZER V1.3 (SISTEMA JERÁRQUICO Y AUTO-BYPASS EXPERIMENTAL)
-- ==============================================================================

local SCRIPT_VERSION = "V1.3 - JERARQUÍA Y BYPASS"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- ELIMINAR GUI ANTERIOR
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
Panel.Size = UDim2.new(0, 520, 0, 400)
Panel.Position = UDim2.new(1, -540, 0.5, -200)
Panel.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(200, 50, 255) -- Morado V1.3
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(80, 20, 100)
Title.Text = " 📡 FORGE ANALYZER V1.3 (DEEP SCAN & BYPASS)"
Title.TextColor3 = Color3.fromRGB(255, 200, 255)
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

-- PANEL DE BOTONES SUPERIORES (BYPASS)
local BypassFrame = Instance.new("Frame")
BypassFrame.Size = UDim2.new(1, -8, 0, 45)
BypassFrame.Position = UDim2.new(0, 4, 0, 35)
BypassFrame.BackgroundColor3 = Color3.fromRGB(20, 30, 20)
BypassFrame.Parent = Panel
Instance.new("UICorner", BypassFrame).CornerRadius = UDim.new(0, 4)

local BypassBtn = Instance.new("TextButton")
BypassBtn.Size = UDim2.new(0.5, -6, 1, -8)
BypassBtn.Position = UDim2.new(0, 4, 0, 4)
BypassBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
BypassBtn.Text = "🚀 EJECUTAR 'FAST-FORGE' BYPASS"
BypassBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BypassBtn.Font = Enum.Font.Code
BypassBtn.TextSize = 12
BypassBtn.Parent = BypassFrame

local PerfectBtn = Instance.new("TextButton")
PerfectBtn.Size = UDim2.new(0.5, -6, 1, -8)
PerfectBtn.Position = UDim2.new(0.5, 2, 0, 4)
PerfectBtn.BackgroundColor3 = Color3.fromRGB(180, 100, 0)
PerfectBtn.Text = "⏱️ EJECUTAR 'PERFECT TIMING' BYPASS"
PerfectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PerfectBtn.Font = Enum.Font.Code
PerfectBtn.TextSize = 11
PerfectBtn.Parent = BypassFrame

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -8, 1, -125)
LogScroll.Position = UDim2.new(0, 4, 0, 85)
LogScroll.BackgroundColor3 = Color3.fromRGB(10, 15, 10)
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogScroll.ScrollBarThickness = 6
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.Parent = Panel
local ListLayout = Instance.new("UIListLayout", LogScroll)
ListLayout.Padding = UDim.new(0, 2)

local ControlsFrame = Instance.new("Frame")
ControlsFrame.Size = UDim2.new(1, -8, 0, 35)
ControlsFrame.Position = UDim2.new(0, 4, 1, -38)
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
-- SISTEMA DE LOGS Y MEMORIA (JERARQUÍA COMPLETA)
-- ==========================================
local MasterLogList = {}
local LastOresDetected = {} -- Ores cacheados al enviar "Melt" nativo

local function AddUILog(logType, message, color)
    local timestamp = os.date("%H:%M:%S")
    local fullString = "[" .. timestamp .. "] [" .. logType .. "] " .. message
    
    table.insert(MasterLogList, fullString)
    if #MasterLogList > 400 then
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
    
    local textSize = game:GetService("TextService"):GetTextSize(txt.Text, txt.TextSize, txt.Font, Vector2.new(LogScroll.AbsoluteSize.X - 15, math.huge))
    txt.Size = UDim2.new(1, -4, 0, textSize.Y + 4)
    LogScroll.CanvasPosition = Vector2.new(0, 999999)
end

local function DumpTableDeep(tbl, depth)
    depth = depth or 0
    if depth > 5 then return "{...}" end -- Límite de seguridad
    local str = "{"
    local count = 0
    for k, v in pairs(tbl) do
        count = count + 1
        local vt = typeof(v)
        if vt == "table" then
            str = str .. "["..tostring(k).."]=" .. DumpTableDeep(v, depth + 1) .. ", "
        else
            str = str .. "["..tostring(k).."]=" .. tostring(v) .. " ("..vt.."), "
        end
    end
    if count == 0 then return "{}" end
    return str .. "}"
end

-- ==========================================
-- EL HOOK BESTIAL V1.3 (FULL DEEP SCAN)
-- ==========================================
local BlacklistWords = {"move", "mouse", "camera", "ping", "update", "render", "step", "chat", "character", "root", "position", "look"}

local OriginalNamecall
OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
        task.spawn(function()
            pcall(function()
                local fullName = self.GetFullName(self)
                local nameLower = string.lower(fullName)
                local skip = false
                for _, word in pairs(BlacklistWords) do
                    if string.find(nameLower, word) then skip = true; break end
                end
                
                if not skip then
                    local argDump = ""
                    for i, v in ipairs(args) do
                        local vType = typeof(v)
                        if vType == "table" then
                            local success, res = pcall(function() return DumpTableDeep(v) end)
                            argDump = argDump .. "Arg["..i.."]=" .. (success and res or "ERROR_TABLE") .. " "
                        else
                            pcall(function() argDump = argDump .. "Arg["..i.."]="..tostring(v).." ("..vType..") " end)
                        end
                    end
                    if argDump == "" then argDump = "<Sin Argumentos>" end
                    
                    AddUILog("NET:"..string.upper(method), fullName .. "\n   >> " .. argDump, Color3.fromRGB(200, 200, 255))
                    
                    -- CACHEAR LOS ORES PARA EL BYPASS!
                    if string.find(nameLower, "changesequence") and typeof(args[1]) == "string" and args[1] == "Melt" then
                        if typeof(args[2]) == "table" and args[2].Ores then
                            LastOresDetected = args[2].Ores
                            AddUILog("MEMORIA", "¡Se atraparon y guardaron los ORES seleccionados en memoria! ("..tostring(args[2].Ores)..")", Color3.fromRGB(255, 255, 100))
                        end
                    end
                end
            end)
        end)
    end
    return OriginalNamecall(self, ...)
end)

-- ==========================================
-- BYPASS LOGIC (BOTONES EXPERIMENTALES)
-- ==========================================
local function GetForgeRemotes()
    local RS = game:GetService("ReplicatedStorage")
    local knit = RS:FindFirstChild("Shared") and RS.Shared:FindFirstChild("Packages") and RS.Shared.Packages:FindFirstChild("Knit")
    if knit then
        local forgeService = knit.Services:FindFirstChild("ForgeService")
        if forgeService and forgeService:FindFirstChild("RF") then
            return forgeService.RF:FindFirstChild("ChangeSequence"), forgeService.RF:FindFirstChild("StartForge")
        end
    end
    return nil, nil
end

BypassBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        AddUILog("TEST_1", "Iniciando Test FAST-FORGE...", Color3.fromRGB(200, 255, 50))
        local ChangeSequence, StartForge = GetForgeRemotes()
        
        if not ChangeSequence then
            AddUILog("ERROR", "No se encontró ForgeService.RF.ChangeSequence. El script no puede continuar.", Color3.fromRGB(255, 50, 50))
            return
        end
        
        if next(LastOresDetected) == nil then
            AddUILog("ADVERTENCIA", "No has metido ores a la olla recientemente o no los guardamos. Da click a 'GO' normal una vez para que atrape qué metales pusiste y luego cancela la forja.", Color3.fromRGB(255, 100, 50))
            return
        end

        pcall(function()
            AddUILog("TEST_1", "Enviando Solicitud Melt [FastForge = true]...", Color3.fromRGB(150, 255, 255))
            local meltArgs = {
                FastForge = true,
                ItemType = "Weapon",
                Ores = LastOresDetected
            }
            local success, res = pcall(function() return ChangeSequence:InvokeServer("Melt", meltArgs) end)
            if success then
                AddUILog("SERVER_REPLY", "Melt Reply: " .. tostring(res), Color3.fromRGB(100, 255, 100))
                -- Finalizar inmediatamente
                ChangeSequence:InvokeServer("Showcase", {})
                AddUILog("TEST_1", "¡Secuencia Showcase enviada! Revisa si te dio el arma.", Color3.fromRGB(50, 255, 100))
            else
                AddUILog("ERROR", "El servidor rompió la conexión (¿Patcheado?): " .. tostring(res), Color3.fromRGB(255, 50, 50))
            end
        end)
    end)
end)

PerfectBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        AddUILog("TEST_2", "Iniciando Test TIMING PERFECTO Matemático...", Color3.fromRGB(255, 150, 50))
        local ChangeSequence = GetForgeRemotes()
        if not ChangeSequence then return end
        
        if next(LastOresDetected) == nil then
            AddUILog("ADVERTENCIA", "Faltan los ORES. Haz una forja manual primero para robar los datos de tus metales.", Color3.fromRGB(255, 100, 50))
            return
        end

        pcall(function()
            -- Enviamos la falsa secuencia con tiempos irreales por detrás de cámaras
            AddUILog("TEST_2", "Paso 1: Melt asíncrono...", Color3.fromRGB(200, 200, 200))
            local t0 = os.clock()
            ChangeSequence:InvokeServer("Melt", {FastForge = false, ItemType = "Weapon", Ores = LastOresDetected})
            
            task.wait(1)
            AddUILog("TEST_2", "Paso 2: Pour (Falso Tiempo 5s)...", Color3.fromRGB(200, 200, 200))
            ChangeSequence:InvokeServer("Pour", {ClientTime = t0 + 5.0}) -- Engañando reloj
            
            task.wait(1)
            AddUILog("TEST_2", "Paso 3: Hammer (Falso Tiempo +12.5s)...", Color3.fromRGB(200, 200, 200))
            ChangeSequence:InvokeServer("Hammer", {ClientTime = t0 + 17.5})
            
            task.wait(1)
            AddUILog("TEST_2", "Paso 4: Water (Falso Tiempo +6s)...", Color3.fromRGB(200, 200, 200))
            ChangeSequence:InvokeServer("Water", {ClientTime = t0 + 23.5})
            
            task.wait(1)
            AddUILog("TEST_2", "Paso 5: Showcase...", Color3.fromRGB(200, 200, 200))
            ChangeSequence:InvokeServer("Showcase", {})
            
            AddUILog("TEST_2", "Secuencia enviada usando Time-Spoof. ¿Qué recibiste?", Color3.fromRGB(150, 255, 100))
        end)
    end)
end)

-- ==========================================
ClearBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(LogScroll:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
    MasterLogList = {}
end)

CopyBtn.MouseButton1Click:Connect(function()
    local result = "=== REPORTE TOTAL SIN FILTROS (V1.3) ===\n\n"
    for i, _ in ipairs(MasterLogList) do result = result .. MasterLogList[i] .. "\n" end
    if setclipboard then setclipboard(result); CopyBtn.Text = "✅ ¡COPIADO!" else CopyBtn.Text = "❌ ERROR" end
    task.delay(2, function() CopyBtn.Text = "📋 COPIAR AL PORTAPAPELES" end)
end)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

AddUILog("SISTEMA", "📡 V1.3 INICIADA: Escaneo jerárquico profundo de tablas activo y Botones de Bypass listos.", Color3.fromRGB(150, 255, 150))
AddUILog("INSTRUCCIÓN", "1. Acércate, mete los metales en la Olla y dale al botón VERDE GO del juego normal.\n2. Inmediatamente el log dirá '¡Se atraparon y guardaron los ORES!'.\n3. Salte del minijuego (cancélalo o ciérralo) y presiona los botones de Bypass de mi ventana para probar saltárnoslo del todo.", Color3.fromRGB(255, 200, 100))
