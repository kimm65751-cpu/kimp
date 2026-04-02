-- =====================================================================
-- 👁️ DEMONOLOGY: FORENSIC NETWORK & INSTANCE ANALYZER (V2 ULTIMATE) 👁️
-- =====================================================================
-- Creado para: Extracción Brutal de Datos, sin filtros conservadores.
-- Este script ahora roba y piratea TODO el tráfico ENTRANTE del servidor
-- =====================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- ==========================================
-- 🗄️ 0. SISTEMA AUTO-INCREMENTAL DE LOGS TXT
-- ==========================================
local fileIndex = 1
if isfile then
    while isfile("anty_" .. fileIndex .. ".txt") do
        fileIndex = fileIndex + 1
    end
end
local LogFileName = "anty_" .. fileIndex .. ".txt"

if writefile then
    pcall(function() writefile(LogFileName, "=== INICIO DE FORENSE V2 (" .. os.date("%x %X") .. ") ===\n") end)
end

-- ==========================================
-- 🖥️ 1. INTERFAZ GRÁFICA OMNICIENTE
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ForenseScannerUI"
ScreenGui.ResetOnSpawn = false
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = CoreGui end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 700, 0, 500)
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
Title.TextColor3 = Color3.fromRGB(255, 100, 100)
Title.TextSize = 16
Title.Font = Enum.Font.Code
Title.Text = " 👁️ ESCÁNER FORENSE DE EXTRACCIÓN MASIVA ("..LogFileName..")"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -10, 1, -40)
LogScroll.Position = UDim2.new(0, 5, 0, 35)
LogScroll.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
LogScroll.ScrollBarThickness = 6
LogScroll.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 2)
UIListLayout.Parent = LogScroll

local LogEntries = 0
local MaxLogs = 2000

local function AddLog(texto, color)
    local timestamp = os.date("%X")
    LogEntries = LogEntries + 1
    
    local entry = Instance.new("TextLabel")
    entry.Size = UDim2.new(1, 0, 0, 16)
    entry.BackgroundTransparency = 1
    entry.Text = "[" .. timestamp .. "] " .. texto
    entry.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    entry.TextSize = 13
    entry.Font = Enum.Font.Code
    entry.TextXAlignment = Enum.TextXAlignment.Left
    entry.TextWrapped = true
    entry.LayoutOrder = LogEntries
    entry.Parent = LogScroll
    
    LogScroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    LogScroll.CanvasPosition = Vector2.new(0, LogScroll.CanvasSize.Y.Offset)
    
    if appendfile then
        pcall(function() appendfile(LogFileName, "[" .. timestamp .. "] " .. texto .. "\n") end)
    end
    
    if LogEntries > MaxLogs then
        local oldest = nil
        for _, child in pairs(LogScroll:GetChildren()) do
            if child:IsA("TextLabel") and (not oldest or child.LayoutOrder < oldest.LayoutOrder) then
                oldest = child
            end
        end
        if oldest then oldest:Destroy() end
    end
end

AddLog("Arrancando Ojo de Dios Forense - Extracción Masiva", Color3.fromRGB(0, 255, 255))

-- ==========================================
-- 📡 2. INTERCEPTOR ABSOLUTO DE RED (OUTGOING)
-- ==========================================
pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
            local objName = tostring(self.Name)
            if not string.find(string.lower(objName), "move") then
                task.spawn(function()
                    local argStr = ""
                    for _, v in ipairs(args) do argStr = argStr .. tostring(v) .. " | " end
                    pcall(function() AddLog("📤 [OUT] " .. objName .. " -> " .. argStr, Color3.fromRGB(255, 150, 0)) end)
                end)
            end
        end
        return oldNamecall(self, ...)
    end)
end)

-- ==========================================
-- 📥 3. ESPÍA CLÁSICO DE ENTRADAS (INCOMING) - LA CLAVE
-- ==========================================
-- Nos atamos como sanguijuelas a TODOS los RemoteEvents del juego.
-- Si el servidor te envía una pista fantasma silenciosa, gritará aquí.
task.spawn(function()
    local enganches = 0
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            pcall(function()
                obj.OnClientEvent:Connect(function(...)
                    local argStr = ""
                    local args = {...}
                    for _, v in pairs(args) do argStr = argStr .. tostring(v) .. " | " end
                    if argStr == "" then argStr = "Ping/Act" end
                    AddLog("📥 [RED ENTRANTE] Servidor usó: " .. obj.Name .. " Datos: " .. argStr, Color3.fromRGB(0, 200, 255))
                end)
                enganches = enganches + 1
            end)
        end
    end
    AddLog("Sanguijuelas inyectadas a " .. enganches .. " eventos de entrada.", Color3.fromRGB(0, 255, 0))
    
    -- Atrapar eventos que se creen en el futuro
    game.DescendantAdded:Connect(function(obj)
        if obj:IsA("RemoteEvent") then
            pcall(function()
                obj.OnClientEvent:Connect(function(...)
                    local argStr = ""
                    local args = {...}
                    for _, v in pairs(args) do argStr = argStr .. tostring(v) .. " | " end
                    AddLog("📥 [NUEVO EVENTO IN] " .. obj.Name .. " -> " .. argStr, Color3.fromRGB(0, 200, 255))
                end)
            end)
        end
    end)
end)

-- ==========================================
-- 🔬 4. FORENSE FÍSICO Y MUTACIONES (Pistas como Marchitar / Libro)
-- ==========================================
local function AnalyzeObject(obj)
    local n = string.lower(obj.Name)
    local p = obj.Parent and obj.Parent.Name or "Map"
    
    -- Monitorear entidades
    if n == "ghost" or n == "entity" or obj:GetAttribute("IsGhost") then
        obj.AttributeChanged:Connect(function(attr)
            AddLog("🧬 Mutación de Entidad: " .. attr .. " = " .. tostring(obj:GetAttribute(attr)), Color3.fromRGB(200, 50, 50))
        end)
    end
    
    -- Si el servidor no las SPAWNEA, sino que les CAMBIA el color (Libro y Flores):
    if obj:IsA("BasePart") then
        if string.find(n, "flower") or string.find(n, "plant") or string.find(n, "vase") or string.find(n, "book") or string.find(n, "journal") or string.find(n, "door") then
            pcall(function()
                -- Si el libro cambia de calcomanía, o la flor de color/material
                obj:GetPropertyChangedSignal("Color"):Connect(function() AddLog("🎨 [ALERTA FÍSICA] " .. obj.Name .. " cambió de Color en " .. p, Color3.fromRGB(200, 200, 0)) end)
                obj:GetPropertyChangedSignal("Material"):Connect(function() AddLog("🧱 [ALERTA FÍSICA] " .. obj.Name .. " mutó su Material en " .. p, Color3.fromRGB(200, 200, 0)) end)
                obj:GetPropertyChangedSignal("Transparency"):Connect(function() AddLog("👻 [ALERTA FÍSICA] Transparencia alterada en " .. obj.Name, Color3.fromRGB(150, 150, 150)) end)
                obj.AttributeChanged:Connect(function(attr) AddLog("🏷️ Atributo local en " .. obj.Name .. " > " .. attr .. " = " .. tostring(obj:GetAttribute(attr)), Color3.fromRGB(100, 255, 100)) end)
            end)
        end
    end
end

for _, v in pairs(workspace:GetDescendants()) do AnalyzeObject(v) end
workspace.DescendantAdded:Connect(AnalyzeObject)

-- ==========================================
-- 🛠️ 5. DESNUDADOR DE MEMORIA AGRESIVO
-- ==========================================
task.spawn(function()
    AddLog("Extrayendo variables ocultas en Motor...", Color3.fromRGB(100, 100, 100))
    pcall(function()
        for i, v in pairs(getgc(true)) do
            if type(v) == "table" then
                -- Forzar expansión agresiva para ver los datos crudos
                pcall(function()
                    for key, val in pairs(v) do
                        if type(key) == "string" then
                            local kl = string.lower(key)
                            -- Buscamos cualquier cosa que delate el estado de la partida
                            if string.find(kl, "ghost") or string.find(kl, "evidence") or string.find(kl, "state") or string.find(kl, "seed") or string.find(kl, "type") then
                                if type(val) == "string" or type(val) == "number" or type(val) == "boolean" then
                                    AddLog("📂 [MEMORIA CRUDA] Tabla Módulo -> " .. tostring(key) .. " = " .. tostring(val), Color3.fromRGB(255, 100, 255))
                                end
                            end
                            if kl == "effectivenessrange" or kl == "range" or kl == "distance" then
                                local anc = v[key]
                                v[key] = 99999
                                AddLog("💥 [TOOL HACK BRUTAL] Rango '"..key.."' alterado de "..tostring(anc).." a 99999", Color3.fromRGB(0, 255, 0))
                            end
                        end
                    end
                end)
            end
        end
    end)
    AddLog("Escaneo Abusivo de Memoria Finalizado.", Color3.fromRGB(0, 255, 0))
end)

AddLog("==================================", Color3.fromRGB(50, 50, 50))
AddLog("🕵️ FORENSE V2 AL MÁXIMO. MIRA LA MAGIA.", Color3.fromRGB(0, 255, 0))
