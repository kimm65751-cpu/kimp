-- ==============================================================================
-- 🕵️ FORGE FORENSIC OMNI-LOGGER V6.0 (RAW DATA EXTRACTOR)
-- Captura jerárquica de Clicks, Red, Textos GUI, Módulos y Paquetes de Servidor.
-- ==============================================================================

local SCRIPT_VERSION = "V6.0 - FORENSIC OMNI-LOGGER"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "ForgeAnalyzerUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ForgeAnalyzerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 600, 0, 450)
Panel.Position = UDim2.new(1, -620, 0.5, -225)
Panel.BackgroundColor3 = Color3.fromRGB(15, 10, 15)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(0, 255, 150)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(10, 50, 40)
Title.Text = " 🕵️ FORGE V6.0 (FORENSIC OMNI-LOGGER)"
Title.TextColor3 = Color3.fromRGB(100, 255, 200)
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

local RecordBtn = Instance.new("TextButton")
RecordBtn.Size = UDim2.new(1, -8, 0, 35)
RecordBtn.Position = UDim2.new(0, 4, 0, 35)
RecordBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
RecordBtn.Text = "🔴 GRABANDO TODO AL .TXT (JUEGA NORMAL)"
RecordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RecordBtn.Font = Enum.Font.Code
RecordBtn.TextSize = 14
RecordBtn.Parent = Panel

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -8, 1, -115)
LogScroll.Position = UDim2.new(0, 4, 0, 75)
LogScroll.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
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
ClearBtn.Text = "🗑️ LIMPIAR PANTALLA"
ClearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearBtn.Font = Enum.Font.Code
ClearBtn.Parent = ControlsFrame

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0.5, -2, 1, 0)
CopyBtn.Position = UDim2.new(0.5, 2, 0, 0)
CopyBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 150)
CopyBtn.Text = "📋 COPIAR AL PORTAPAPELES"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.Code
CopyBtn.Parent = ControlsFrame

-- ==========================================
-- SISTEMA DE LOGS Y MEMÓRIA A ARCHIVO
-- ==========================================
local MasterLogList = {}

local function SaveLogToFile(message)
    task.spawn(function()
        pcall(function()
            local filename = "ForgeForensicLog_V6.txt"
            if appendfile then
                appendfile(filename, message .. "\n")
            elseif readfile and writefile then
                local current = ""
                pcall(function() current = readfile(filename) end)
                writefile(filename, current .. message .. "\n")
            elseif writefile then
                writefile(filename, message .. "\n")
            end
        end)
    end)
end

local function AddLog(logType, message, color)
    local ms = tostring(math.floor((os.clock() % 1) * 1000))
    if #ms == 1 then ms = "00"..ms elseif #ms == 2 then ms = "0"..ms end
    local fullString = "[" .. os.date("%H:%M:%S") .. "." .. ms .. "] [" .. logType .. "] " .. message
    
    SaveLogToFile(fullString)
    table.insert(MasterLogList, fullString)
    
    if #MasterLogList > 1000 then table.remove(MasterLogList, 1) end
    
    task.defer(function()
        pcall(function()
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
            
            local ts = game:GetService("TextService"):GetTextSize(txt.Text, txt.TextSize, txt.Font, Vector2.new(LogScroll.AbsoluteSize.X - 15, math.huge))
            txt.Size = UDim2.new(1, -4, 0, ts.Y + 4)
            LogScroll.CanvasPosition = Vector2.new(0, 999999)
        end)
    end)
end

ClearBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(LogScroll:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
    MasterLogList = {}
end)

CopyBtn.MouseButton1Click:Connect(function()
    local result = "=== REPORTE FORENSE PROFUNDO (V6.0) ===\n\n"
    for i, _ in ipairs(MasterLogList) do result = result .. MasterLogList[i] .. "\n" end
    if setclipboard then setclipboard(result); CopyBtn.Text = "✅ ¡COPIADO!" else CopyBtn.Text = "❌ ERROR" end
    task.delay(2, function() CopyBtn.Text = "📋 COPIAR AL PORTAPAPELES" end)
end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local DumpTableDeep
DumpTableDeep = function(tbl, depth)
    depth = depth or 0
    if type(tbl) ~= "table" then return tostring(tbl) end
    if depth > 5 then return "{MAX_DEPTH}" end
    local str = "{"
    for k, v in pairs(tbl) do
        local vt = typeof(v)
        if vt == "table" then str = str .. "["..tostring(k).."]=" .. DumpTableDeep(v, depth + 1) .. ", "
        else str = str .. "["..tostring(k).."]=" .. tostring(v) .. ", " end
    end
    return str .. "}"
end

-- ==========================================
-- 1. RASTREO FÍSICO DE CLICKS
-- ==========================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        AddLog("MOUSE_CLICK", string.format("X:%d, Y:%d | SobreUI: %s", input.Position.X, input.Position.Y, tostring(gameProcessed)), Color3.fromRGB(150,150,150))
    end
end)

-- ==========================================
-- 2. RASTREO JERÁRQUICO DE GUI (TEXTOS Y FRAMES)
-- ==========================================
local TrackedGUIs = {}
local function TrackGUI(inst)
    if not inst:IsA("GuiObject") then return end
    if TrackedGUIs[inst] then return end
    TrackedGUIs[inst] = true
    
    -- Detectar etiquetas de "Perfect", "Bad", "Good"
    if inst:IsA("TextLabel") or inst:IsA("TextButton") then
        inst:GetPropertyChangedSignal("Text"):Connect(function()
            if inst.Text ~= "" and inst.Text ~= " " then
                AddLog("GUI_TEXT_CHANGE", string.format("[%s] -> '%s'", inst.Name, inst.Text), Color3.fromRGB(0, 255, 255))
            end
        end)
    end
    
    -- Avisar si es una UI propia de Forja / Minijuego
    if string.find(string.lower(inst.Name), "forge") or string.find(string.lower(inst.Name), "minigame") or string.find(string.lower(inst.Name), "circle") then
        AddLog("GUI_SPAWNED", string.format("Apareció: %s (%s)", inst.Name, inst.ClassName), Color3.fromRGB(200, 100, 255))
    end
end
LocalPlayer.PlayerGui.DescendantAdded:Connect(TrackGUI)
for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do TrackGUI(v) end

-- ==========================================
-- 3. RASTREO PURAMENTE FORENSE DE RED (SIN BLOQUEOS)
-- ==========================================
local OriginalNamecall
OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and (method == "InvokeServer" or method == "FireServer") then
        local fullName = self.GetFullName(self)
        local nameLower = string.lower(fullName)
        
        task.spawn(function()
            pcall(function()
                -- Ignorar basura irrelevante para no saturar
                local Blacklist = {"mouse", "character", "ping", "move", "step", "chat", "render", "camera"}
                local skip = false
                for _, w in pairs(Blacklist) do if string.find(nameLower, w) then skip = true break end end
                
                if not skip then
                    local argStr = DumpTableDeep(args)
                    -- Resaltar ChangeSequence y Forge
                    local col = Color3.fromRGB(200,200,200)
                    if string.find(nameLower, "changesequence") then col = Color3.fromRGB(255,0,0) end
                    AddLog("NET_OUT:"..method, self.Name .. " => " .. argStr, col)
                end
            end)
        end)
    end
    
    return OriginalNamecall(self, ...)
end)

-- ==========================================
-- 4. RASTREO DEL SERVIDOR INCOMING (OnClientEvent)
-- ==========================================
task.spawn(function()
    for _, event in pairs(ReplicatedStorage:GetDescendants()) do
        if event:IsA("RemoteEvent") then
            -- Solo nos interesan eventos reales del juego
            if string.find(string.lower(event:GetFullName()), "knit") or string.find(string.lower(event.Name), "forge") then
                event.OnClientEvent:Connect(function(...)
                    local args = {...}
                    local argStr = DumpTableDeep(args)
                    AddLog("SERVER_INCOMING", event.Name .. " => " .. argStr, Color3.fromRGB(0, 255, 0))
                end)
            end
        end
    end
end)

-- ==========================================
-- 5. RASTREO DE NUEVOS SCRIPTS
-- ==========================================
LocalPlayer.PlayerScripts.ChildAdded:Connect(function(child)
    if child:IsA("LocalScript") or child:IsA("ModuleScript") then
        AddLog("NEW_SCRIPT", "Se añadió Script al jugador: " .. child.Name, Color3.fromRGB(255,255,0))
    end
end)

AddLog("SISTEMA", "V6.0 FORENSE INICIADA. AHORA SOMOS SOLO UN FANTASMA OBSERVADOR.", Color3.fromRGB(150, 255, 150))
AddLog("SISTEMA", "Ve, Juega normalmente (lo mejor que puedas) y captura cada interacción secreta.", Color3.fromRGB(255, 255, 150))
