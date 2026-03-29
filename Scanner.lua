-- ==============================================================================
-- 🔬 FORGE MINIGAME X-RAY v4.0 — FANTASMA TOTAL, CERO HOOKS
-- ==============================================================================
-- ❌ NO USA hookmetamethod   (bloqueaba NPCs)
-- ❌ NO USA hookfunction     (bloqueaba la forja)
-- ❌ NO MODIFICA NADA EN EL JUEGO
-- ✅ SOLO Lee, Observa, Escucha señales nativas, Pollea estados.
-- ✅ decompile() solo en los LocalScripts que ENCUENTRE dentro de minijuegos
-- ✅ getgc() para leer memoria sin modificarla
-- ✅ GetPropertyChangedSignal (nativo, no invasivo)
-- ✅ ChildAdded/Removed (nativo, no invasivo)
-- ==============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ============ ARCHIVO ============
local FILE_PATH = "info5.txt"
local fileBuffer = {}
local fileBlockCount = 0

local function FlushToFile()
    if #fileBuffer == 0 then return end
    fileBlockCount = fileBlockCount + 1
    local content = table.concat(fileBuffer, "\n")
    pcall(function()
        if fileBlockCount == 1 then
            writefile(FILE_PATH, "=== FORGE X-RAY v4.0 (FANTASMA) === " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n\n" .. content .. "\n")
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

-- ============ UI ============
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
Panel.BorderColor3 = Color3.fromRGB(100, 200, 255)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 28)
Title.BackgroundColor3 = Color3.fromRGB(10, 50, 80)
Title.Text = " 👻 X-RAY v4.0 FANTASMA — NO TOCA NADA"
Title.TextColor3 = Color3.fromRGB(150, 220, 255)
Title.TextSize = 12
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Panel

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 28)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.Font = Enum.Font.Code
CloseBtn.TextSize = 14
CloseBtn.Parent = Panel
CloseBtn.MouseButton1Click:Connect(function() FlushToFile(); ScreenGui:Destroy() end)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -8, 0, 20)
StatusLabel.Position = UDim2.new(0, 4, 0, 30)
StatusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
StatusLabel.Text = " 👻 Fantasma activo. Juega normal."
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
CopyBtn.Text = "📋 COPIAR TODO"
CopyBtn.TextColor3 = Color3.fromRGB(255,255,255)
CopyBtn.Font = Enum.Font.Code
CopyBtn.TextSize = 12
CopyBtn.Parent = Panel

local MasterLog = {}
local logCount = 0

local function AddLog(tag, msg, clr)
    logCount = logCount + 1
    if logCount > 3000 then return end
    local full = "[" .. os.date("%H:%M:%S") .. "] [" .. tag .. "] " .. msg
    table.insert(MasterLog, full)
    LogToFile(full)
    task.defer(function()
        pcall(function()
            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1, -4, 0, 0)
            txt.BackgroundTransparency = 1
            txt.Text = full
            txt.TextColor3 = clr or Color3.fromRGB(200,200,200)
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
    if setclipboard then setclipboard(table.concat(MasterLog, "\n")); CopyBtn.Text = "✅ COPIADO (" .. #MasterLog .. ")" end
    task.delay(2, function() CopyBtn.Text = "📋 COPIAR TODO" end)
end)

-- ============ UTILIDADES ============
local function DumpVal(v, d)
    d = d or 0; if d > 3 then return "{...}" end
    if type(v) == "table" then
        local p = {}; for k, val in pairs(v) do table.insert(p, tostring(k) .. "=" .. DumpVal(val, d+1)) end
        return "{" .. table.concat(p, ", ") .. "}"
    end
    return tostring(v)
end
local function DColor(c) return string.format("RGB(%d,%d,%d)", math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255)) end
local function DUDim(u) return string.format("S(%.3f,%.3f)O(%d,%d)", u.X.Scale, u.Y.Scale, u.X.Offset, u.Y.Offset) end
local function DAbs(o)
    local p, s = "?", "?"
    pcall(function() p = string.format("Abs(%d,%d)", math.floor(o.AbsolutePosition.X), math.floor(o.AbsolutePosition.Y)) end)
    pcall(function() s = string.format("Sz(%d,%d)", math.floor(o.AbsoluteSize.X), math.floor(o.AbsoluteSize.Y)) end)
    return p .. " " .. s
end

-- ============ [1] LEER SINGLETON SIN MODIFICARLO ============
local FC = nil
local lastForgeActive = nil
local lastPhaseReported = ""

pcall(function()
    local Knit = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"))
    FC = Knit.GetController("ForgeController")
    if FC then
        AddLog("INIT", "✅ ForgeController leído (SIN modificar). ForgeActive=" .. tostring(FC.ForgeActive), Color3.fromRGB(0,255,0))
    end
end)

-- ============ [2] LISTAR REMOTES DE FORJA (SIN HOOKEAR) ============
pcall(function()
    local controllers = ReplicatedStorage:FindFirstChild("Controllers")
    if controllers then
        local fcFolder = controllers:FindFirstChild("ForgeController")
        if fcFolder then
            AddLog("REMOTES", "📂 " .. fcFolder:GetFullName(), Color3.fromRGB(255, 150, 50))
            for _, child in pairs(fcFolder:GetDescendants()) do
                if child:IsA("RemoteFunction") or child:IsA("RemoteEvent") or child:IsA("BindableEvent") then
                    AddLog("REMOTES", "  └ " .. child.ClassName .. ": " .. child:GetFullName(), Color3.fromRGB(200, 200, 100))
                end
            end
        end
    end
    -- Knit Services
    local knitSvc = ReplicatedStorage:FindFirstChild("Knit")
    if knitSvc then
        local svcs = knitSvc:FindFirstChild("Services")
        if svcs then
            for _, svc in pairs(svcs:GetChildren()) do
                if string.find(string.lower(svc.Name), "forge") then
                    AddLog("REMOTES", "📡 Servicio: " .. svc.Name, Color3.fromRGB(255, 200, 50))
                    for _, rf in pairs(svc:GetDescendants()) do
                        if rf:IsA("RemoteFunction") or rf:IsA("RemoteEvent") then
                            AddLog("REMOTES", "  └ " .. rf.ClassName .. ": " .. rf.Name .. " → " .. rf:GetFullName(), Color3.fromRGB(200, 200, 100))
                        end
                    end
                end
            end
        end
    end
end)
FlushToFile()

-- ============ [3] POLLING PASIVO DEL FORGECONTROLLER ============
-- Lee el estado cada frame SIN modificar nada.
local frameSkip = 0

RunService.Heartbeat:Connect(function()
    if not ScreenGui.Parent then return end
    frameSkip = frameSkip + 1
    if frameSkip % 10 ~= 0 then return end -- Solo cada 10 frames (~6 veces/seg)
    
    if FC then
        -- Detectar cambio de ForgeActive
        local fa = nil
        pcall(function() fa = FC.ForgeActive end)
        if fa ~= nil and fa ~= lastForgeActive then
            lastForgeActive = fa
            if fa then
                AddLog("STATE", "🔥 ForgeActive = TRUE → FORJA ACTIVA", Color3.fromRGB(255, 50, 50))
                StatusLabel.Text = " 🔥 FORJA ACTIVA"
                StatusLabel.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
            else
                AddLog("STATE", "✅ ForgeActive = FALSE → LIBRE", Color3.fromRGB(0, 255, 0))
                StatusLabel.Text = " ✅ LIBRE (ForgeActive=false)"
                StatusLabel.BackgroundColor3 = Color3.fromRGB(20, 80, 20)
                FlushToFile()
            end
        end
        
        -- Leer cualquier propiedad pública que cambie
        pcall(function()
            if FC.replica and type(FC.replica) == "table" then
                for k, v in pairs(FC.replica) do
                    local key = tostring(k)
                    local val = tostring(v)
                    if #val < 100 then
                        -- Solo loguear si hay un cambio (lo chequeamos con un cache)
                        -- Para no spamear, solo al inicio
                    end
                end
            end
        end)
    end
end)

-- ============ [4] SNAPSHOT COMPLETO DE UI + DECOMPILE ============
local scanDone = {}
local trackedEls = {}

local function FullScanGUI(guiRoot, phaseName)
    AddLog("SCAN", "═══════ SNAPSHOT: " .. phaseName .. " [" .. guiRoot.Name .. "] ═══════", Color3.fromRGB(255, 200, 50))
    
    local desc = guiRoot:GetDescendants()
    AddLog("SCAN", "Descendientes: " .. #desc, Color3.fromRGB(200, 200, 100))
    
    for _, obj in pairs(desc) do
        local info = "[" .. obj.ClassName .. "] " .. obj.Name
        
        if obj:IsA("GuiObject") then
            pcall(function()
                local vis = tostring(obj.Visible)
                info = info .. " V=" .. vis .. " Bg=" .. DColor(obj.BackgroundColor3) .. " BgT=" .. string.format("%.2f", obj.BackgroundTransparency)
                info = info .. " P=" .. DUDim(obj.Position) .. " Sz=" .. DUDim(obj.Size) .. " " .. DAbs(obj)
            end)
        end
        
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            pcall(function() info = info .. " Text=\"" .. string.sub(obj.Text, 1, 50) .. "\" TC=" .. DColor(obj.TextColor3) end)
        end
        
        if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            pcall(function() info = info .. " Img=" .. string.sub(tostring(obj.Image), 1, 40) .. " IT=" .. string.format("%.2f", obj.ImageTransparency) end)
        end
        
        -- DECOMPILE scripts dentro del minijuego
        if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            pcall(function() info = info .. " Disabled=" .. tostring(obj.Disabled or false) end)
            pcall(function()
                local src = decompile(obj)
                if src and #src > 10 then
                    LogToFile("\n===== DECOMPILE: " .. obj:GetFullName() .. " =====")
                    local lc = 0
                    for line in string.gmatch(src, "[^\n]+") do
                        lc = lc + 1
                        LogToFile("  " .. line)
                        if lc > 400 then LogToFile("  ... TRUNCADO"); break end
                    end
                    LogToFile("===== FIN =====\n")
                    FlushToFile()
                    AddLog("DECOMPILE", "📜 " .. obj.Name .. " → " .. lc .. " líneas guardadas en info5.txt", Color3.fromRGB(255, 100, 255))
                end
            end)
        end
        
        AddLog("UI", string.gsub(obj:GetFullName(), "Players%." .. LocalPlayer.Name .. "%.PlayerGui%.", "") .. " → " .. info, Color3.fromRGB(180, 180, 220))
    end
    
    AddLog("SCAN", "═══════ FIN " .. phaseName .. " ═══════", Color3.fromRGB(255, 200, 50))
    FlushToFile()
end

-- ============ [5] MONITOREO DE CAMBIOS EN VIVO (SIGNALS) ============
local function TrackChanges(guiRoot, phaseName)
    for _, obj in pairs(guiRoot:GetDescendants()) do
        local key = tostring(obj)
        if trackedEls[key] then continue end
        trackedEls[key] = true
        
        if obj:IsA("GuiObject") then
            pcall(function() obj:GetPropertyChangedSignal("Position"):Connect(function()
                AddLog("MOVE", obj.Name .. " P=" .. DUDim(obj.Position) .. " " .. DAbs(obj), Color3.fromRGB(0, 255, 200))
            end) end)
            pcall(function() obj:GetPropertyChangedSignal("Size"):Connect(function()
                AddLog("SIZE", obj.Name .. " Sz=" .. DUDim(obj.Size) .. " " .. DAbs(obj), Color3.fromRGB(255, 255, 0))
            end) end)
            pcall(function() obj:GetPropertyChangedSignal("Visible"):Connect(function()
                AddLog("VIS", obj.Name .. " Vis=" .. tostring(obj.Visible), Color3.fromRGB(255, 150, 0))
            end) end)
            pcall(function() obj:GetPropertyChangedSignal("Rotation"):Connect(function()
                AddLog("ROT", obj.Name .. " Rot=" .. string.format("%.1f", obj.Rotation), Color3.fromRGB(200, 100, 255))
            end) end)
            pcall(function() obj:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
                AddLog("COLOR", obj.Name .. " " .. DColor(obj.BackgroundColor3), Color3.fromRGB(100, 200, 255))
            end) end)
        end
        
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            pcall(function()
                local last = obj.Text
                obj:GetPropertyChangedSignal("Text"):Connect(function()
                    if obj.Text ~= last and #obj.Text < 80 then
                        last = obj.Text
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
                        AddLog("FADE", obj.Name .. " IT=" .. string.format("%.2f", obj.ImageTransparency), Color3.fromRGB(150, 150, 255))
                    end
                end)
            end)
        end
    end
end

-- ============ [6] DETECTOR DE MINIJUEGOS ============
local lastDetected = ""

-- También escanear la GUI principal "Forge" una sola vez
pcall(function()
    local forgeGui = LocalPlayer.PlayerGui:FindFirstChild("Forge")
    if forgeGui and not scanDone["ForgeMainUI"] then
        scanDone["ForgeMainUI"] = true
        task.spawn(function()
            FullScanGUI(forgeGui, "ForgeMainUI")
        end)
    end
end)

RunService.Heartbeat:Connect(function()
    if not ScreenGui.Parent then return end
    
    local foundGame, foundName = nil, ""
    for _, v in pairs(LocalPlayer.PlayerGui:GetChildren()) do
        if v:IsA("ScreenGui") and v.Enabled then
            local nm = string.lower(v.Name)
            if string.find(nm, "minigame") then
                foundGame = v; foundName = v.Name; break
            end
        end
    end
    
    if foundGame and foundName ~= lastDetected then
        lastDetected = foundName
        StatusLabel.Text = " 🎮 JUEGO: " .. foundName
        StatusLabel.BackgroundColor3 = Color3.fromRGB(50, 80, 20)
        AddLog("GAME", "🎮 ¡DETECTADO! → " .. foundName, Color3.fromRGB(0, 255, 0))
        
        if not scanDone[foundName] then
            scanDone[foundName] = true
            task.spawn(function()
                task.wait(0.5)
                FullScanGUI(foundGame, foundName)
                TrackChanges(foundGame, foundName)
                AddLog("TRACK", "✅ Monitoreo activado para " .. foundName, Color3.fromRGB(100, 255, 100))
                
                -- También trackear hijos nuevos que aparezcan DESPUÉS del scan
                foundGame.DescendantAdded:Connect(function(desc)
                    local i = desc.Name .. " [" .. desc.ClassName .. "]"
                    pcall(function() if desc:IsA("GuiObject") then i = i .. " P=" .. DUDim(desc.Position) .. " " .. DAbs(desc) end end)
                    pcall(function() if desc:IsA("TextLabel") then i = i .. " T=\"" .. desc.Text .. "\"" end end)
                    AddLog("NEW", "  └ " .. i, Color3.fromRGB(200, 180, 100))
                    -- Trackear cambios del nuevo elemento
                    pcall(function()
                        local key = tostring(desc)
                        if not trackedEls[key] and desc:IsA("GuiObject") then
                            trackedEls[key] = true
                            desc:GetPropertyChangedSignal("Position"):Connect(function()
                                AddLog("MOVE", desc.Name .. " P=" .. DUDim(desc.Position) .. " " .. DAbs(desc), Color3.fromRGB(0, 255, 200))
                            end)
                            desc:GetPropertyChangedSignal("Size"):Connect(function()
                                AddLog("SIZE", desc.Name .. " Sz=" .. DUDim(desc.Size) .. " " .. DAbs(desc), Color3.fromRGB(255, 255, 0))
                            end)
                        end
                    end)
                end)
                foundGame.DescendantRemoving:Connect(function(desc)
                    AddLog("DEL", "  └ Removido: " .. desc.Name .. " [" .. desc.ClassName .. "]", Color3.fromRGB(255, 100, 100))
                end)
            end)
        end
    end
    
    if not foundGame and lastDetected ~= "" then
        AddLog("GAME", "❌ [" .. lastDetected .. "] TERMINÓ", Color3.fromRGB(255, 100, 50))
        FlushToFile()
        lastDetected = ""
        StatusLabel.Text = " 👻 Esperando..."
        StatusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    end
end)

-- ============ [7] OBSERVAR PlayerGui ============
LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
    AddLog("GUI+", "📦 " .. child.Name .. " [" .. child.ClassName .. "]", Color3.fromRGB(255, 200, 100))
end)
LocalPlayer.PlayerGui.ChildRemoved:Connect(function(child)
    AddLog("GUI-", "🗑️ " .. child.Name, Color3.fromRGB(255, 80, 80))
    FlushToFile()
end)

-- ============ AUTO-FLUSH ============
task.spawn(function()
    while ScreenGui.Parent do FlushToFile(); task.wait(5) end
end)

AddLog("SISTEMA", "👻 X-RAY v4.0 FANTASMA LISTO.", Color3.fromRGB(100, 255, 100))
AddLog("SISTEMA", "CERO hooks. CERO modificaciones. Juega 100% normal.", Color3.fromRGB(100, 255, 100))
AddLog("SISTEMA", "info5.txt se guarda automáticamente.", Color3.fromRGB(100, 255, 100))
