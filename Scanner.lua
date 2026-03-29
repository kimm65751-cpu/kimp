-- ==============================================================================
-- 🔬 FORGE EXECUTION TRACER (THE OMNI-MAPPER V1.0)
-- ==============================================================================
-- Este escáner inyecta "micrófonos" ocultos en CADA UNA de las funciones de todos 
-- los sistemas de la Forja y Personaje. Mapea la ejecución en tiempo real.
-- Cuando juegues la forja nativamente, imprimirá EXACTAMENTE la ruta de módulos
-- y los datos que envía cada uno de ellos.
-- ==============================================================================

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local DumpFile = "ForgeCompleteTracer.txt"
pcall(function() if writefile then writefile(DumpFile, "=== 🔬 FORGE OMNI-MAPPER ===\n\n") end end)

local function AppendLog(str)
    task.spawn(function()
        pcall(function()
            if appendfile then appendfile(DumpFile, str .. "\n")
            elseif writefile then writefile(DumpFile, readfile(DumpFile) .. str .. "\n") end
        end)
    end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TracerUI"
ScreenGui.Parent = pcall(function() return game:GetService("CoreGui").Name end) and game:GetService("CoreGui") or LP:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 480, 0, 350)
Frame.Position = UDim2.new(1, -500, 0.5, -175)
Frame.BackgroundColor3 = Color3.fromRGB(10, 15, 20)
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(0, 255, 100)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 80, 40)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = " 🔬 FORGE OMNI-MAPPER (TRACER ACTIVO)"
Title.Font = Enum.Font.Code

local LogScroll = Instance.new("ScrollingFrame", Frame)
LogScroll.Size = UDim2.new(1, -10, 1, -80)
LogScroll.Position = UDim2.new(0, 5, 0, 35)
LogScroll.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogScroll.ScrollBarThickness = 6
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local ListLayout = Instance.new("UIListLayout", LogScroll)
ListLayout.Padding = UDim.new(0, 2)

local function AddUILog(message)
    local fullString = "[" .. os.date("%H:%M:%S") .. "] " .. message
    AppendLog(fullString)
    task.defer(function()
        pcall(function()
            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1, -4, 0, 0)
            txt.BackgroundTransparency = 1
            txt.Text = fullString
            txt.TextColor3 = Color3.fromRGB(150, 255, 150)
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

local CopyBtn = Instance.new("TextButton", Frame)
CopyBtn.Size = UDim2.new(1, -10, 0, 35)
CopyBtn.Position = UDim2.new(0, 5, 1, -40)
CopyBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 150)
CopyBtn.Text = "📋 COPIAR MAPA DE EJECUCIÓN"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.Code
CopyBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard(readfile(DumpFile)) end)
    CopyBtn.Text = "✅ ¡COPIADO!"
    task.wait(2)
    CopyBtn.Text = "📋 COPIAR MAPA DE EJECUCIÓN"
end)

local DumpTable
DumpTable = function(tbl, depth)
    depth = depth or 0
    if depth > 2 then return "{...}" end
    if type(tbl) ~= "table" then return tostring(tbl) end
    local str = "{"
    for k, v in pairs(tbl) do
        str = str .. tostring(k) .. "=" .. (type(v) == "table" and DumpTable(v, depth+1) or tostring(v)) .. ", "
    end
    return str .. "}"
end

-- ==================== INYECTAR RASTREADORES EN KNIT ====================
task.spawn(function()
    AddUILog("Iniciando inyección de micrófonos en Controladores Knit...")
    pcall(function()
        local Knit = require(RS:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"))
        
        -- Encontrar todos los controladores cargados en la memoria activa (Singleton)
        local loadedModules = getloadedmodules()
        for _, mod in ipairs(loadedModules) do
            local name = mod.Name
            if string.find(name, "Controller") or string.find(name, "Forge") or string.find(name, "Minigame") then
                pcall(function()
                    local singleton = Knit.GetController(name)
                    if singleton and type(singleton) == "table" then
                        AddUILog("✅ Controlador envuelto: " .. name)
                        for funcName, funcVal in pairs(singleton) do
                            if type(funcVal) == "function" and funcName ~= "Update" and funcName ~= "Render" then
                                local original = funcVal
                                singleton[funcName] = function(self, ...)
                                    local args = {...}
                                    local argStr = DumpTable(args)
                                    AddUILog("🔥 [KNIT] " .. name .. ":" .. funcName .. "(" .. argStr .. ")")
                                    return original(self, ...)
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)
    
    AddUILog("✅ Sistema de mapeo activo. Por favor, FORJA UN ARMA MANUALMENTE AHORA.")
    AddUILog("Todo el proceso y sub-módulos se rastrearán automáticamente.")
end)

-- ==================== RASTREAR CONEXIONES A REMOTES DE FORGE ====================
task.spawn(function()
    for _, obj in ipairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            if string.find(string.lower(obj:GetFullName()), "forge") then
                local ev = obj:IsA("RemoteEvent") and obj.OnClientEvent or obj.OnClientInvoke
                if ev then
                    local cons = getconnections(ev)
                    for _, con in ipairs(cons) do
                        local originalCon = con.Function
                        pcall(function()
                            hookfunction(originalCon, function(...)
                                local args = {...}
                                AddUILog("📡 [RED RECIBE] " .. obj.Name .. " -> Args: " .. DumpTable(args))
                                return originalCon(...)
                            end)
                        end)
                    end
                end
            end
        end
    end
end)
