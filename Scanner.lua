-- ==============================================================================
-- 🔬 FORGE MINIGAME X-RAY v3.0 — SIN __NAMECALL, CERO INTERFERENCIA
-- ==============================================================================
-- ✅ NO USA hookmetamethod(__namecall) — No bloquea NPCs ni interacción.
-- ✅ USA hookfunction() en funciones ESPECÍFICAS del ForgeController.
-- ✅ USA getconnections() para ver oyentes de los remotes de forja.
-- ✅ USA decompile() en los LocalScripts de cada minijuego.
-- ✅ USA getgc() para buscar tablas/funciones internas de la forja.
-- ✅ Tú juegas normal, este script SOLO observa y anota.
-- ==============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ============ SISTEMA DE ARCHIVO ============
local FILE_PATH = "info5.txt"
local fileBuffer = {}
local fileBlockCount = 0

local function FlushToFile()
    if #fileBuffer == 0 then return end
    fileBlockCount = fileBlockCount + 1
    local content = table.concat(fileBuffer, "\n")
    pcall(function()
        if fileBlockCount == 1 then
            writefile(FILE_PATH, "=== FORGE X-RAY v3.0 === " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n\n" .. content .. "\n")
        else
            appendfile(FILE_PATH, "\n" .. content .. "\n")
        end
    end)
    fileBuffer = {}
end

local function LogToFile(text)
    table.insert(fileBuffer, text)
    if #fileBuffer >= 30 then FlushToFile() end
end

-- ============ UI DEL PANEL ============
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "XRayUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XRayUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 620, 0, 440)
Panel.Position = UDim2.new(1, -640, 0.5, -220)
Panel.BackgroundColor3 = Color3.fromRGB(10, 5, 15)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(255, 100, 50)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 28)
Title.BackgroundColor3 = Color3.fromRGB(80, 30, 10)
Title.Text = " 🔬 X-RAY v3.0 — CERO INTERFERENCIA, JUEGA NORMAL"
Title.TextColor3 = Color3.fromRGB(255, 200, 100)
Title.TextSize = 12
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Panel

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 28)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.Code
CloseBtn.TextSize = 14
CloseBtn.Parent = Panel
CloseBtn.MouseButton1Click:Connect(function() FlushToFile(); ScreenGui:Destroy() end)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -8, 0, 20)
StatusLabel.Position = UDim2.new(0, 4, 0, 30)
StatusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
StatusLabel.Text = " Estado: Esperando forja... (Interacción NO bloqueada)"
StatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = Panel

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -8, 1, -90)
LogScroll.Position = UDim2.new(0, 4, 0, 55)
LogScroll.BackgroundColor3 = Color3.fromRGB(5, 8, 5)
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogScroll.ScrollBarThickness = 6
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.Parent = Panel
Instance.new("UIListLayout", LogScroll).Padding = UDim.new(0, 1)

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(1, -8, 0, 28)
CopyBtn.Position = UDim2.new(0, 4, 1, -32)
CopyBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 150)
CopyBtn.Text = "📋 COPIAR LOG COMPLETO"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.Code
CopyBtn.TextSize = 12
CopyBtn.Parent = Panel

local MasterLog = {}
local logCount = 0

local function AddLog(tag, msg, clr)
    logCount = logCount + 1
    if logCount > 2000 then return end -- Protección anti-lag
    local ts = os.date("%H:%M:%S")
    local full = "[" .. ts .. "] [" .. tag .. "] " .. msg
    table.insert(MasterLog, full)
    LogToFile(full)
    task.defer(function()
        pcall(function()
            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1, -4, 0, 0)
            txt.BackgroundTransparency = 1
            txt.Text = full
            txt.TextColor3 = clr or Color3.fromRGB(200, 200, 200)
            txt.Font = Enum.Font.Code
            txt.TextSize = 10
            txt.TextXAlignment = Enum.TextXAlignment.Left
            txt.TextWrapped = true
            txt.Parent = LogScroll
            local s = game:GetService("TextService"):GetTextSize(txt.Text, txt.TextSize, txt.Font, Vector2.new(LogScroll.AbsoluteSize.X - 15, math.huge))
            txt.Size = UDim2.new(1, -4, 0, s.Y + 3)
            LogScroll.CanvasPosition = Vector2.new(0, 999999)
        end)
    end)
end

CopyBtn.MouseButton1Click:Connect(function()
    FlushToFile()
    if setclipboard then setclipboard(table.concat(MasterLog, "\n")); CopyBtn.Text = "✅ COPIADO (" .. #MasterLog .. " líneas)" end
    task.delay(2, function() CopyBtn.Text = "📋 COPIAR LOG COMPLETO" end)
end)

-- ============ UTILIDADES ============
local function DumpValue(v, depth)
    depth = depth or 0
    if depth > 3 then return "{...}" end
    if type(v) == "table" then
        local p = {}
        for k, val in pairs(v) do table.insert(p, tostring(k) .. "=" .. DumpValue(val, depth+1)) end
        return "{" .. table.concat(p, ", ") .. "}"
    end
    return tostring(v)
end

local function DescribeColor(c3)
    return string.format("RGB(%d,%d,%d)", math.floor(c3.R*255), math.floor(c3.G*255), math.floor(c3.B*255))
end

local function DescribeUDim2(ud)
    return string.format("S(%.3f,%.3f)O(%d,%d)", ud.X.Scale, ud.Y.Scale, ud.X.Offset, ud.Y.Offset)
end

local function DescribeAbsolute(obj)
    local p, s = "?", "?"
    pcall(function() p = string.format("Abs(%d,%d)", math.floor(obj.AbsolutePosition.X), math.floor(obj.AbsolutePosition.Y)) end)
    pcall(function() s = string.format("Sz(%d,%d)", math.floor(obj.AbsoluteSize.X), math.floor(obj.AbsoluteSize.Y)) end)
    return p .. " " .. s
end

-- ============ [1] HOOKFUNCTION EN FORGECONTROLLER (SIN TOCAR __NAMECALL) ============
AddLog("INIT", "Instalando hooks QUIRÚRGICOS (sin __namecall)...", Color3.fromRGB(255, 200, 0))

pcall(function()
    local Knit = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"))
    local FC = Knit.GetController("ForgeController")
    
    if FC then
        AddLog("INIT", "✅ ForgeController singleton obtenido.", Color3.fromRGB(0, 255, 0))
        
        -- hookfunction en cada método del ForgeController
        local origStartForge = FC.StartForge
        FC.StartForge = function(self2, ...)
            AddLog("FORGE", "🔥 StartForge(" .. DumpValue({...}) .. ")", Color3.fromRGB(255, 50, 50))
            StatusLabel.Text = " 🔥 FORJA INICIADA"; StatusLabel.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
            return origStartForge(self2, ...)
        end
        
        local origCS = FC.ChangeSequence
        FC.ChangeSequence = function(self2, ...)
            local a = {...}
            local phase = tostring(a[1] or "?")
            local data = DumpValue(a[2] or {})
            AddLog("SEQ", "⚡ ChangeSequence(\"" .. phase .. "\", " .. data .. ")", Color3.fromRGB(255, 200, 0))
            StatusLabel.Text = " ⚡ FASE: " .. phase
            return origCS(self2, ...)
        end
        
        local origCC = FC.ChangeCamera
        FC.ChangeCamera = function(self2, ...)
            local a = {...}
            AddLog("CAM", "📹 ChangeCamera(\"" .. tostring(a[1] or "?") .. "\", \"" .. tostring(a[2] or "?") .. "\")", Color3.fromRGB(200, 150, 255))
            return origCC(self2, ...)
        end
        
        local origEF = FC.EndForge
        FC.EndForge = function(self2, ...)
            AddLog("FORGE", "✅ EndForge() — FORJA TERMINADA. ForgeActive → false", Color3.fromRGB(0, 255, 0))
            StatusLabel.Text = " ✅ TERMINADA"; StatusLabel.BackgroundColor3 = Color3.fromRGB(20, 80, 20)
            FlushToFile()
            return origEF(self2, ...)
        end
        
        local origFade = FC.Fade
        FC.Fade = function(self2, ...)
            local a = {...}
            AddLog("FADE", "🌑 Fade(" .. tostring(a[1] or "?") .. ")", Color3.fromRGB(150, 150, 150))
            return origFade(self2, ...)
        end
        
        AddLog("INIT", "✅ 5 hooks instalados en ForgeController (StartForge, ChangeSequence, ChangeCamera, EndForge, Fade)", Color3.fromRGB(100, 255, 100))
    end
end)

-- ============ [2] GETCONNECTIONS — VER OYENTES DE LOS REMOTES DE FORJA ============
AddLog("INIT", "Escaneando conexiones de remotes de forja...", Color3.fromRGB(255, 200, 0))

pcall(function()
    local knitServices = ReplicatedStorage:FindFirstChild("Knit")
    if knitServices then
        local services = knitServices:FindFirstChild("Services")
        if services then
            for _, svc in pairs(services:GetChildren()) do
                if string.find(string.lower(svc.Name), "forge") then
                    AddLog("CONN", "📡 Servicio encontrado: " .. svc:GetFullName(), Color3.fromRGB(255, 150, 50))
                    for _, rf in pairs(svc:GetDescendants()) do
                        if rf:IsA("RemoteFunction") or rf:IsA("RemoteEvent") then
                            AddLog("CONN", "  └ Remote: " .. rf.Name .. " [" .. rf.ClassName .. "] en " .. rf:GetFullName(), Color3.fromRGB(200, 200, 100))
                            pcall(function()
                                local conns = getconnections(rf.OnClientInvoke or rf.OnClientEvent)
                                if conns then
                                    for ci, conn in ipairs(conns) do
                                        local fnInfo = ""
                                        pcall(function() fnInfo = " Script=" .. tostring(getinfo(conn.Function).source) end)
                                        AddLog("CONN", "    └ Oyente #" .. ci .. fnInfo, Color3.fromRGB(150, 200, 150))
                                    end
                                end
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- Buscar también en Controllers
pcall(function()
    local controllers = ReplicatedStorage:FindFirstChild("Controllers")
    if controllers then
        local fcFolder = controllers:FindFirstChild("ForgeController")
        if fcFolder then
            AddLog("CONN", "📂 Carpeta ForgeController encontrada: " .. fcFolder:GetFullName(), Color3.fromRGB(255, 150, 50))
            for _, child in pairs(fcFolder:GetDescendants()) do
                if child:IsA("RemoteFunction") or child:IsA("RemoteEvent") or child:IsA("BindableEvent") or child:IsA("BindableFunction") then
                    AddLog("CONN", "  └ " .. child.ClassName .. ": " .. child.Name .. " en " .. child:GetFullName(), Color3.fromRGB(200, 200, 100))
                    pcall(function()
                        local conns = getconnections(child.OnClientInvoke or child.OnClientEvent or child.Event)
                        if conns then
                            for ci, conn in ipairs(conns) do
                                AddLog("CONN", "    └ Oyente #" .. ci, Color3.fromRGB(150, 200, 150))
                            end
                        end
                    end)
                end
            end
        end
    end
end)

FlushToFile()

-- ============ [3] GETGC — BUSCAR TABLAS/FUNCIONES INTERNAS DE LOS MINIJUEGOS ============
AddLog("INIT", "Buscando en memoria (getgc) tablas relacionadas con minijuegos...", Color3.fromRGB(255, 200, 0))

pcall(function()
    local gc = getgc(true)
    local found = 0
    local keywords = {"melt", "pour", "hammer", "water", "minigame", "forge", "perfect", "score", "target", "zone", "bar", "pointer", "bellows", "sequence"}
    
    for _, obj in ipairs(gc) do
        if type(obj) == "table" and found < 30 then
            for k, v in pairs(obj) do
                local kStr = string.lower(tostring(k))
                for _, kw in ipairs(keywords) do
                    if string.find(kStr, kw) then
                        found = found + 1
                        local vStr = DumpValue(v)
                        if #vStr > 150 then vStr = string.sub(vStr, 1, 150) .. "..." end
                        AddLog("GC", "🧠 [" .. type(v) .. "] " .. tostring(k) .. " = " .. vStr, Color3.fromRGB(200, 100, 255))
                        break
                    end
                end
            end
        end
    end
    AddLog("GC", "🧠 Búsqueda GC terminada. " .. found .. " coincidencias encontradas.", Color3.fromRGB(200, 100, 255))
end)

FlushToFile()

-- ============ [4] ESCANEO COMPLETO DE UI DE MINIJUEGO ============
local scanDone = {}
local trackedElements = {}
local currentPhase = "Idle"

local function FullScanGUI(guiRoot, phaseName)
    local header = "═══════ SNAPSHOT UI: " .. phaseName .. " [" .. guiRoot.Name .. "] ═══════"
    AddLog("SCAN", header, Color3.fromRGB(255, 200, 50))
    
    local descendants = guiRoot:GetDescendants()
    AddLog("SCAN", "Total descendientes: " .. #descendants, Color3.fromRGB(200, 200, 100))
    
    for _, obj in pairs(descendants) do
        local info = "[" .. obj.ClassName .. "] " .. obj.Name
        
        if obj:IsA("GuiObject") then
            local vis, bg, bgT = "?", "?", "?"
            pcall(function() vis = tostring(obj.Visible) end)
            pcall(function() bg = DescribeColor(obj.BackgroundColor3) end)
            pcall(function() bgT = string.format("%.2f", obj.BackgroundTransparency) end)
            local pos = DescribeUDim2(obj.Position)
            local sz = DescribeUDim2(obj.Size)
            local absI = DescribeAbsolute(obj)
            info = info .. " V=" .. vis .. " Bg=" .. bg .. " BgT=" .. bgT .. " P=" .. pos .. " Sz=" .. sz .. " " .. absI
        end
        
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            pcall(function() info = info .. " Text=\"" .. string.sub(obj.Text, 1, 50) .. "\" TC=" .. DescribeColor(obj.TextColor3) end)
        end
        
        if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            pcall(function() info = info .. " Img=" .. string.sub(tostring(obj.Image), 1, 45) .. " IT=" .. string.format("%.2f", obj.ImageTransparency) end)
        end
        
        -- DECOMPILE de LocalScripts dentro del minijuego
        if obj:IsA("LocalScript") then
            pcall(function() info = info .. " Disabled=" .. tostring(obj.Disabled) end)
            pcall(function()
                local src = decompile(obj)
                if src and #src > 0 then
                    -- Guardar el código fuente completo en el archivo
                    local srcHeader = "\n===== DECOMPILE: " .. obj:GetFullName() .. " ====="
                    LogToFile(srcHeader)
                    -- Dividir en líneas y guardar
                    local lineCount = 0
                    for line in string.gmatch(src, "[^\n]+") do
                        lineCount = lineCount + 1
                        LogToFile("  " .. line)
                        if lineCount > 300 then LogToFile("  ... (TRUNCADO a 300 líneas)"); break end
                    end
                    LogToFile("===== FIN DECOMPILE =====\n")
                    FlushToFile()
                    AddLog("DECOMPILE", "📜 " .. obj.Name .. " decompilado (" .. lineCount .. " líneas) → guardado en info5.txt", Color3.fromRGB(255, 100, 255))
                end
            end)
        end
        
        -- ModuleScript dentro del minijuego
        if obj:IsA("ModuleScript") then
            pcall(function()
                local src = decompile(obj)
                if src and #src > 0 then
                    local srcHeader = "\n===== DECOMPILE MODULE: " .. obj:GetFullName() .. " ====="
                    LogToFile(srcHeader)
                    local lineCount = 0
                    for line in string.gmatch(src, "[^\n]+") do
                        lineCount = lineCount + 1
                        LogToFile("  " .. line)
                        if lineCount > 300 then LogToFile("  ... (TRUNCADO a 300 líneas)"); break end
                    end
                    LogToFile("===== FIN DECOMPILE MODULE =====\n")
                    FlushToFile()
                    AddLog("DECOMPILE", "📦 Módulo " .. obj.Name .. " decompilado (" .. lineCount .. " líneas) → info5.txt", Color3.fromRGB(200, 100, 255))
                end
            end)
        end
        
        local shortPath = string.gsub(obj:GetFullName(), "Players%." .. LocalPlayer.Name .. "%.PlayerGui%.", "")
        AddLog("UI", shortPath .. " → " .. info, Color3.fromRGB(180, 180, 220))
    end
    
    AddLog("SCAN", "═══════ FIN SNAPSHOT " .. phaseName .. " ═══════", Color3.fromRGB(255, 200, 50))
    FlushToFile()
end

-- ============ [5] MONITOREO DE CAMBIOS EN TIEMPO REAL ============
local function TrackChanges(guiRoot, phaseName)
    for _, obj in pairs(guiRoot:GetDescendants()) do
        local key = tostring(obj) .. obj.Name
        if trackedElements[key] then continue end
        trackedElements[key] = true
        
        if obj:IsA("GuiObject") then
            pcall(function()
                obj:GetPropertyChangedSignal("Position"):Connect(function()
                    if currentPhase ~= phaseName then return end
                    AddLog("MOVE", obj.Name .. " → P=" .. DescribeUDim2(obj.Position) .. " " .. DescribeAbsolute(obj), Color3.fromRGB(0, 255, 200))
                end)
            end)
            pcall(function()
                obj:GetPropertyChangedSignal("Size"):Connect(function()
                    if currentPhase ~= phaseName then return end
                    AddLog("SIZE", obj.Name .. " → Sz=" .. DescribeUDim2(obj.Size) .. " " .. DescribeAbsolute(obj), Color3.fromRGB(255, 255, 0))
                end)
            end)
            pcall(function()
                obj:GetPropertyChangedSignal("Visible"):Connect(function()
                    AddLog("VIS", obj.Name .. " → Visible=" .. tostring(obj.Visible), Color3.fromRGB(255, 150, 0))
                end)
            end)
            pcall(function()
                obj:GetPropertyChangedSignal("Rotation"):Connect(function()
                    if currentPhase ~= phaseName then return end
                    AddLog("ROT", obj.Name .. " → Rot=" .. string.format("%.1f", obj.Rotation), Color3.fromRGB(200, 100, 255))
                end)
            end)
            pcall(function()
                obj:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
                    if currentPhase ~= phaseName then return end
                    AddLog("COLOR", obj.Name .. " → " .. DescribeColor(obj.BackgroundColor3), Color3.fromRGB(100, 200, 255))
                end)
            end)
        end
        
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            pcall(function()
                local lastT = obj.Text
                obj:GetPropertyChangedSignal("Text"):Connect(function()
                    if obj.Text ~= lastT and #obj.Text < 80 then
                        lastT = obj.Text
                        AddLog("TEXT", obj.Name .. " → \"" .. obj.Text .. "\"", Color3.fromRGB(255, 255, 150))
                    end
                end)
            end)
        end
        
        if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            pcall(function()
                local lastIT = obj.ImageTransparency
                obj:GetPropertyChangedSignal("ImageTransparency"):Connect(function()
                    if math.abs(obj.ImageTransparency - lastIT) > 0.08 then
                        lastIT = obj.ImageTransparency
                        AddLog("IMGFADE", obj.Name .. " → IT=" .. string.format("%.2f", obj.ImageTransparency), Color3.fromRGB(150, 150, 255))
                    end
                end)
            end)
        end
    end
end

-- ============ [6] DETECTOR DE MINIJUEGOS (POLLING SIN HOOK) ============
local lastDetectedGame = ""

RunService.Heartbeat:Connect(function()
    if not ScreenGui.Parent then return end
    
    local foundGame, foundName = nil, ""
    for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
        if v:IsA("ScreenGui") and v.Enabled then
            local nm = string.lower(v.Name)
            if string.find(nm, "minigame") or (string.find(nm, "forge") and nm ~= "forge") then
                foundGame = v
                foundName = v.Name
                break
            end
        end
    end
    
    if foundGame and foundName ~= lastDetectedGame then
        lastDetectedGame = foundName
        currentPhase = foundName
        StatusLabel.Text = " 🎮 ACTIVO: " .. foundName
        StatusLabel.BackgroundColor3 = Color3.fromRGB(50, 80, 20)
        AddLog("DETECT", "🎮 ¡MINIJUEGO! → " .. foundName, Color3.fromRGB(0, 255, 0))
        
        if not scanDone[foundName] then
            scanDone[foundName] = true
            task.spawn(function()
                task.wait(0.4)
                FullScanGUI(foundGame, foundName)
                TrackChanges(foundGame, foundName)
                AddLog("TRACK", "Monitoreo de cambios ACTIVADO para " .. foundName, Color3.fromRGB(100, 255, 100))
            end)
        end
    end
    
    if not foundGame and lastDetectedGame ~= "" then
        AddLog("DETECT", "❌ [" .. lastDetectedGame .. "] CERRADO", Color3.fromRGB(255, 100, 50))
        FlushToFile()
        lastDetectedGame = ""
        currentPhase = "Idle"
        StatusLabel.Text = " Esperando siguiente juego..."
        StatusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    end
end)

-- ============ [7] OBSERVADOR DE PLAYERGUI ============
LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
    AddLog("GUI+", "📦 Nueva GUI: " .. child.Name .. " [" .. child.ClassName .. "]", Color3.fromRGB(255, 200, 100))
    if string.find(string.lower(child.Name), "minigame") or string.find(string.lower(child.Name), "forge") then
        child.DescendantAdded:Connect(function(desc)
            local i = desc.Name .. " [" .. desc.ClassName .. "]"
            pcall(function() if desc:IsA("GuiObject") then i = i .. " P=" .. DescribeUDim2(desc.Position) end end)
            pcall(function() if desc:IsA("TextLabel") then i = i .. " T=\"" .. desc.Text .. "\"" end end)
            AddLog("GUI+", "  └ Hijo nuevo: " .. i, Color3.fromRGB(200, 180, 100))
        end)
        child.DescendantRemoving:Connect(function(desc)
            AddLog("GUI-", "  └ Hijo removido: " .. desc.Name .. " [" .. desc.ClassName .. "]", Color3.fromRGB(255, 100, 100))
        end)
    end
end)

LocalPlayer.PlayerGui.ChildRemoved:Connect(function(child)
    AddLog("GUI-", "🗑️ GUI eliminada: " .. child.Name, Color3.fromRGB(255, 80, 80))
    FlushToFile()
end)

-- ============ AUTO-FLUSH ============
task.spawn(function()
    while ScreenGui.Parent do FlushToFile(); task.wait(5) end
end)

AddLog("SISTEMA", "🔬 X-RAY v3.0 LISTO. NPC y clicks funcionan normal.", Color3.fromRGB(100, 255, 100))
AddLog("SISTEMA", "Ve a la forja, interactúa, juega los 4 juegos.", Color3.fromRGB(100, 255, 100))
AddLog("SISTEMA", "Todo se guarda en info5.txt automáticamente.", Color3.fromRGB(100, 255, 100))
