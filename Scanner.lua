-- ==============================================================================
-- 🔬 FORGE MINIGAME X-RAY v2.0 — CAPTURA TOTAL EN TIEMPO REAL
-- ==============================================================================
-- TÚ JUEGAS. ESTE SCRIPT OBSERVA TODO.
-- Captura: UI completa (nombres, clases, posiciones, tamaños, colores, textos),
-- datos de red (qué envía cliente→servidor, qué responde servidor→cliente),
-- cambios de propiedad en los elementos UI en tiempo real,
-- y lo guarda TODO en info5.txt automáticamente por bloques.
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
local totalLinesWritten = 0

local function FlushToFile()
    if #fileBuffer == 0 then return end
    fileBlockCount = fileBlockCount + 1
    local content = table.concat(fileBuffer, "\n")
    pcall(function()
        if fileBlockCount == 1 then
            writefile(FILE_PATH, "=== FORGE MINIGAME X-RAY v2.0 === " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n\n" .. content .. "\n")
        else
            appendfile(FILE_PATH, "\n" .. content .. "\n")
        end
    end)
    totalLinesWritten = totalLinesWritten + #fileBuffer
    fileBuffer = {}
end

local function LogToFile(text)
    table.insert(fileBuffer, text)
    if #fileBuffer >= 40 then FlushToFile() end
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
Title.Text = " 🔬 X-RAY v2.0 — JUEGA NORMAL, CAPTURO TODO"
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
StatusLabel.Text = " Estado: Esperando forja..."
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
CopyBtn.Text = "📋 COPIAR LOG COMPLETO AL PORTAPAPELES"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.Code
CopyBtn.TextSize = 12
CopyBtn.Parent = Panel

local MasterLog = {}

local function AddLog(tag, msg, clr)
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
    if setclipboard then
        setclipboard(table.concat(MasterLog, "\n"))
        CopyBtn.Text = "✅ COPIADO (" .. #MasterLog .. " líneas)"
    end
    task.delay(2, function() CopyBtn.Text = "📋 COPIAR LOG COMPLETO AL PORTAPAPELES" end)
end)

-- ============ FUNCIONES DE ANÁLISIS ============

local function DescribeColor(c3)
    return string.format("RGB(%d,%d,%d)", math.floor(c3.R*255), math.floor(c3.G*255), math.floor(c3.B*255))
end

local function DescribeUDim2(ud)
    return string.format("Scale(%.3f,%.3f) Offset(%d,%d)", ud.X.Scale, ud.Y.Scale, ud.X.Offset, ud.Y.Offset)
end

local function DescribeAbsolute(obj)
    local pos = "?"
    local size = "?"
    pcall(function() pos = string.format("AbsPos(%d,%d)", math.floor(obj.AbsolutePosition.X), math.floor(obj.AbsolutePosition.Y)) end)
    pcall(function() size = string.format("AbsSize(%d,%d)", math.floor(obj.AbsoluteSize.X), math.floor(obj.AbsoluteSize.Y)) end)
    return pos .. " " .. size
end

-- Escaneo profundo de todos los descendientes de una GUI
local function FullScanGUI(guiRoot, phaseName)
    local header = "═══════ SNAPSHOT DE UI: " .. phaseName .. " [" .. guiRoot.Name .. "] ═══════"
    AddLog("SCAN", header, Color3.fromRGB(255, 200, 50))
    LogToFile("\n" .. header)
    
    local descendants = guiRoot:GetDescendants()
    AddLog("SCAN", "Total descendientes: " .. #descendants, Color3.fromRGB(200, 200, 100))
    
    for _, obj in pairs(descendants) do
        local info = ""
        local className = obj.ClassName
        local objName = obj.Name
        local path = obj:GetFullName()
        
        -- Info base
        info = "[" .. className .. "] " .. objName
        
        -- Propiedades según tipo
        if obj:IsA("GuiObject") then
            local vis = "?"
            pcall(function() vis = tostring(obj.Visible) end)
            local bg = "?"
            pcall(function() bg = DescribeColor(obj.BackgroundColor3) end)
            local bgT = "?"
            pcall(function() bgT = string.format("%.2f", obj.BackgroundTransparency) end)
            local pos = DescribeUDim2(obj.Position)
            local sz = DescribeUDim2(obj.Size)
            local absInfo = DescribeAbsolute(obj)
            
            info = info .. " | Vis=" .. vis .. " BgColor=" .. bg .. " BgTrans=" .. bgT
            info = info .. " | Pos=" .. pos .. " Size=" .. sz
            info = info .. " | " .. absInfo
        end
        
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            local txt = "?"
            pcall(function() txt = string.sub(obj.Text, 1, 60) end)
            local tc = "?"
            pcall(function() tc = DescribeColor(obj.TextColor3) end)
            local ts = "?"
            pcall(function() ts = tostring(obj.TextSize) end)
            info = info .. " | Text=\"" .. txt .. "\" TextColor=" .. tc .. " TextSize=" .. ts
        end
        
        if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            local img = "?"
            pcall(function() img = obj.Image end)
            local imgT = "?"
            pcall(function() imgT = string.format("%.2f", obj.ImageTransparency) end)
            info = info .. " | Image=" .. string.sub(tostring(img), 1, 50) .. " ImgTrans=" .. imgT
        end
        
        if obj:IsA("Frame") then
            local clipD = "?"
            pcall(function() clipD = tostring(obj.ClipsDescendants) end)
            info = info .. " | ClipsDesc=" .. clipD
        end
        
        if obj:IsA("UIScale") then
            pcall(function() info = info .. " | UIScale=" .. string.format("%.3f", obj.Scale) end)
        end
        
        if obj:IsA("UIStroke") then
            pcall(function() info = info .. " | StrokeColor=" .. DescribeColor(obj.Color) .. " Thick=" .. obj.Thickness end)
        end
        
        if obj:IsA("LocalScript") then
            local disabled = "?"
            pcall(function() disabled = tostring(obj.Disabled) end)
            info = info .. " | Disabled=" .. disabled
            -- Intentar leer constantes del script
            pcall(function()
                local fn = getscriptclosure(obj)
                if fn then
                    local constants = getconstants(fn)
                    if constants and #constants > 0 then
                        local constStr = ""
                        for _, c in ipairs(constants) do
                            if type(c) == "string" and #c > 0 and #c < 40 then
                                constStr = constStr .. c .. ", "
                            end
                        end
                        if #constStr > 0 then
                            info = info .. " | Constants=[" .. string.sub(constStr, 1, 200) .. "]"
                        end
                    end
                end
            end)
        end
        
        -- Path corto
        local shortPath = string.gsub(path, "Players%." .. LocalPlayer.Name .. "%.PlayerGui%.", "")
        
        AddLog("UI", shortPath .. " → " .. info, Color3.fromRGB(180, 180, 220))
    end
    
    AddLog("SCAN", "═══════ FIN SNAPSHOT " .. phaseName .. " ═══════", Color3.fromRGB(255, 200, 50))
    FlushToFile()
end

-- ============ MONITOREO DE CAMBIOS EN TIEMPO REAL ============
local trackedProps = {}
local currentPhase = "Idle"

local function TrackPropertyChanges(guiRoot, phaseName)
    -- Buscar los elementos que cambian (barras, indicadores, etc.)
    for _, obj in pairs(guiRoot:GetDescendants()) do
        if obj:IsA("GuiObject") and obj.Visible then
            local key = obj:GetFullName()
            if not trackedProps[key] then
                trackedProps[key] = {
                    lastPos = nil,
                    lastSize = nil,
                    lastText = nil,
                    lastVis = nil,
                    lastBgColor = nil,
                    lastRot = nil,
                }
                
                -- Conectar changed para barras en movimiento
                pcall(function()
                    obj:GetPropertyChangedSignal("Position"):Connect(function()
                        if currentPhase ~= phaseName then return end
                        local newPos = DescribeUDim2(obj.Position)
                        local abs = DescribeAbsolute(obj)
                        if trackedProps[key].lastPos ~= newPos then
                            trackedProps[key].lastPos = newPos
                            AddLog("MOVE_" .. phaseName, obj.Name .. " → Pos=" .. newPos .. " " .. abs, Color3.fromRGB(0, 255, 200))
                        end
                    end)
                end)
                
                pcall(function()
                    obj:GetPropertyChangedSignal("Size"):Connect(function()
                        if currentPhase ~= phaseName then return end
                        local newSz = DescribeUDim2(obj.Size)
                        local abs = DescribeAbsolute(obj)
                        if trackedProps[key].lastSize ~= newSz then
                            trackedProps[key].lastSize = newSz
                            AddLog("RESIZE_" .. phaseName, obj.Name .. " → Size=" .. newSz .. " " .. abs, Color3.fromRGB(255, 255, 0))
                        end
                    end)
                end)
                
                pcall(function()
                    obj:GetPropertyChangedSignal("Visible"):Connect(function()
                        AddLog("VIS_" .. phaseName, obj.Name .. " → Visible=" .. tostring(obj.Visible), Color3.fromRGB(255, 150, 0))
                    end)
                end)
                
                pcall(function()
                    obj:GetPropertyChangedSignal("Rotation"):Connect(function()
                        if currentPhase ~= phaseName then return end
                        AddLog("ROT_" .. phaseName, obj.Name .. " → Rotation=" .. string.format("%.1f", obj.Rotation), Color3.fromRGB(200, 100, 255))
                    end)
                end)
                
                pcall(function()
                    obj:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
                        if currentPhase ~= phaseName then return end
                        AddLog("COLOR_" .. phaseName, obj.Name .. " → BgColor=" .. DescribeColor(obj.BackgroundColor3), Color3.fromRGB(100, 200, 255))
                    end)
                end)
            end
        end
        
        -- Textos que cambian (contadores, scores)
        if (obj:IsA("TextLabel") or obj:IsA("TextButton")) then
            local key = obj:GetFullName() .. "_text"
            if not trackedProps[key] then
                trackedProps[key] = {lastText = ""}
                pcall(function()
                    obj:GetPropertyChangedSignal("Text"):Connect(function()
                        local newT = obj.Text
                        if trackedProps[key].lastText ~= newT and #newT < 100 then
                            trackedProps[key].lastText = newT
                            AddLog("TEXT_" .. currentPhase, obj.Name .. " → \"" .. newT .. "\"", Color3.fromRGB(255, 255, 150))
                        end
                    end)
                end)
            end
        end
        
        -- ImageTransparency para efectos de fade
        if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            local key = obj:GetFullName() .. "_img"
            if not trackedProps[key] then
                trackedProps[key] = {lastTrans = -1}
                pcall(function()
                    obj:GetPropertyChangedSignal("ImageTransparency"):Connect(function()
                        local t = obj.ImageTransparency
                        if math.abs(t - trackedProps[key].lastTrans) > 0.05 then
                            trackedProps[key].lastTrans = t
                            AddLog("FADE_" .. currentPhase, obj.Name .. " → ImgTrans=" .. string.format("%.2f", t), Color3.fromRGB(150, 150, 255))
                        end
                    end)
                end)
            end
        end
    end
end

-- ============ DETECTOR DE MINIJUEGOS (POLLING) ============
local lastDetectedGame = ""
local scanDone = {}

RunService.Heartbeat:Connect(function()
    if not ScreenGui.Parent then return end
    
    local foundGame = nil
    local foundName = ""
    
    for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
        local nm = string.lower(v.Name)
        if v:IsA("ScreenGui") and v.Enabled then
            if string.find(nm, "minigame") or string.find(nm, "melt") or string.find(nm, "pour") or string.find(nm, "hammer") or string.find(nm, "water") then
                foundGame = v
                foundName = v.Name
                break
            end
        end
    end
    
    if foundGame and foundName ~= lastDetectedGame then
        lastDetectedGame = foundName
        currentPhase = foundName
        
        StatusLabel.Text = " 🎮 JUEGO DETECTADO: " .. foundName .. " — Escaneando..."
        StatusLabel.BackgroundColor3 = Color3.fromRGB(50, 80, 20)
        
        AddLog("DETECT", "🎮 ¡MINIJUEGO DETECTADO! → " .. foundName, Color3.fromRGB(0, 255, 0))
        
        -- Snapshot completo de la UI
        if not scanDone[foundName] then
            scanDone[foundName] = true
            task.spawn(function()
                task.wait(0.3) -- Esperar a que se renderice
                FullScanGUI(foundGame, foundName)
                TrackPropertyChanges(foundGame, foundName)
                AddLog("TRACK", "Monitoreo de cambios ACTIVADO para " .. foundName, Color3.fromRGB(100, 255, 100))
            end)
        end
    end
    
    if not foundGame and lastDetectedGame ~= "" then
        AddLog("DETECT", "❌ Minijuego [" .. lastDetectedGame .. "] CERRADO/TERMINÓ", Color3.fromRGB(255, 100, 50))
        FlushToFile()
        lastDetectedGame = ""
        StatusLabel.Text = " Estado: Esperando siguiente juego..."
        StatusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    end
end)

-- ============ OBSERVADOR DE RED (NAMECALL) ============
local function DumpValue(v, depth)
    depth = depth or 0
    if depth > 4 then return "{...}" end
    if type(v) == "table" then
        local parts = {}
        for k, val in pairs(v) do
            table.insert(parts, tostring(k) .. "=" .. DumpValue(val, depth+1))
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    end
    return tostring(v)
end

local OriginalNamecall
OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and (method == "InvokeServer" or method == "FireServer") then
        local fullName = ""
        pcall(function() fullName = self:GetFullName() end)
        local nameLower = string.lower(fullName)
        
        -- Filtrar basura (mouse, camera, etc)
        local skip = false
        local blacklist = {"mouse", "camera", "ping", "update", "render", "step", "chat", "position", "look", "move"}
        for _, w in pairs(blacklist) do if string.find(nameLower, w) then skip = true break end end
        
        if not skip then
            -- Capturar los argumentos enviados
            local argDump = ""
            for i, v in ipairs(args) do
                argDump = argDump .. "Arg" .. i .. "=" .. DumpValue(v) .. " "
            end
            
            -- LOG del envío
            AddLog("NET_OUT", method .. " → " .. self.Name .. " | " .. argDump, Color3.fromRGB(255, 100, 100))
            
            -- Si es InvokeServer, capturar la RESPUESTA del servidor
            if method == "InvokeServer" then
                local retTuple = {OriginalNamecall(self, ...)}
                
                local retDump = ""
                for i, v in ipairs(retTuple) do
                    retDump = retDump .. "Ret" .. i .. "=" .. DumpValue(v) .. " "
                end
                
                if #retDump > 0 then
                    AddLog("NET_IN", "SERVIDOR RESPONDE → " .. self.Name .. " | " .. retDump, Color3.fromRGB(100, 255, 100))
                end
                
                return unpack(retTuple)
            end
        end
    end
    
    return OriginalNamecall(self, ...)
end)

-- ============ OBSERVADOR DE KNIT (ForgeController) ============
pcall(function()
    local Knit = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"))
    local FC = Knit.GetController("ForgeController")
    
    if FC then
        -- Hook ChangeSequence
        local origCS = FC.ChangeSequence
        FC.ChangeSequence = function(self2, ...)
            local args2 = {...}
            local phase = tostring(args2[1] or "?")
            local data = DumpValue(args2[2] or {})
            currentPhase = phase
            AddLog("KNIT_SEQ", "⚡ ChangeSequence(\"" .. phase .. "\", " .. data .. ")", Color3.fromRGB(255, 200, 0))
            StatusLabel.Text = " ⚡ FASE: " .. phase
            return origCS(self2, ...)
        end
        
        -- Hook ChangeCamera
        local origCC = FC.ChangeCamera
        FC.ChangeCamera = function(self2, ...)
            local args2 = {...}
            local cam = tostring(args2[1] or "?")
            local seq = tostring(args2[2] or "?")
            AddLog("KNIT_CAM", "📹 ChangeCamera(\"" .. cam .. "\", \"" .. seq .. "\")", Color3.fromRGB(200, 150, 255))
            return origCC(self2, ...)
        end
        
        -- Hook StartForge
        local origSF = FC.StartForge
        FC.StartForge = function(self2, ...)
            AddLog("KNIT_FORGE", "🔥 StartForge() — FORJA INICIADA", Color3.fromRGB(255, 50, 50))
            StatusLabel.Text = " 🔥 FORJA INICIADA"
            StatusLabel.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
            return origSF(self2, ...)
        end
        
        -- Hook EndForge
        local origEF = FC.EndForge
        FC.EndForge = function(self2, ...)
            AddLog("KNIT_FORGE", "✅ EndForge() — FORJA TERMINADA", Color3.fromRGB(0, 255, 0))
            StatusLabel.Text = " ✅ FORJA TERMINADA"
            StatusLabel.BackgroundColor3 = Color3.fromRGB(20, 80, 20)
            FlushToFile()
            return origEF(self2, ...)
        end
        
        -- Hook Fade
        local origFD = FC.Fade
        FC.Fade = function(self2, ...)
            local args2 = {...}
            AddLog("KNIT_FADE", "🌑 Fade(" .. tostring(args2[1] or "?") .. ")", Color3.fromRGB(150, 150, 150))
            return origFD(self2, ...)
        end
        
        AddLog("SISTEMA", "✅ Hooks de Knit ForgeController INSTALADOS", Color3.fromRGB(100, 255, 100))
    end
end)

-- ============ OBSERVADOR DE ChildAdded EN PlayerGui ============
LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
    AddLog("GUI_NEW", "📦 Nueva GUI añadida: " .. child.Name .. " [" .. child.ClassName .. "]", Color3.fromRGB(255, 200, 100))
    
    -- Si es un minijuego, también observar cuando le añaden hijos
    if string.find(string.lower(child.Name), "minigame") or string.find(string.lower(child.Name), "forge") then
        child.DescendantAdded:Connect(function(desc)
            local info = desc.Name .. " [" .. desc.ClassName .. "]"
            if desc:IsA("GuiObject") then
                pcall(function() info = info .. " Pos=" .. DescribeUDim2(desc.Position) .. " Size=" .. DescribeUDim2(desc.Size) end)
            end
            if desc:IsA("TextLabel") then
                pcall(function() info = info .. " Text=\"" .. desc.Text .. "\"" end)
            end
            AddLog("GUI_DESC", "  └ Nuevo hijo en " .. child.Name .. ": " .. info, Color3.fromRGB(200, 180, 100))
        end)
        
        child.DescendantRemoving:Connect(function(desc)
            AddLog("GUI_REM", "  └ Hijo REMOVIDO de " .. child.Name .. ": " .. desc.Name .. " [" .. desc.ClassName .. "]", Color3.fromRGB(255, 100, 100))
        end)
    end
end)

LocalPlayer.PlayerGui.ChildRemoved:Connect(function(child)
    AddLog("GUI_DEL", "🗑️ GUI eliminada: " .. child.Name, Color3.fromRGB(255, 80, 80))
    FlushToFile()
end)

-- ============ AUTO-FLUSH PERIÓDICO ============
task.spawn(function()
    while ScreenGui.Parent do
        FlushToFile()
        task.wait(5)
    end
end)

AddLog("SISTEMA", "🔬 X-RAY v2.0 LISTO. Ve a la forja y juega normal.", Color3.fromRGB(100, 255, 100))
AddLog("SISTEMA", "Todo se guarda en info5.txt automáticamente cada 5s.", Color3.fromRGB(100, 255, 100))
AddLog("SISTEMA", "Capturando: UI completa + Net + Knit + Cambios en vivo.", Color3.fromRGB(100, 255, 100))
