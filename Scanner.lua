-- ==============================================================================
-- 🔬 FORGE ANALYZER PURO - OBSERVADOR TOTAL V1.0
-- ==============================================================================
-- NO INTERFIERE. NO BLOQUEA. NO MODIFICA. Solo OBSERVA y GRABA.
-- Ejecuta esto PRIMERO, luego ve a la forja y haz una espada NORMAL.
-- Todo queda grabado en forge_observador.txt

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- GUI
-- ==========================================
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "ForgeObsUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ForgeObsUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 350)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 15)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 150, 0)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -110, 0, 28)
Title.BackgroundColor3 = Color3.fromRGB(40, 20, 0)
Title.Text = " 🔬 FORGE OBSERVADOR PURO (0% interferencia)"
Title.TextColor3 = Color3.fromRGB(255, 150, 0)
Title.TextSize = 11
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0, 70, 0, 28)
SaveBtn.Position = UDim2.new(1, -110, 0, 0)
SaveBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
SaveBtn.Text = "💾"
SaveBtn.TextColor3 = Color3.new(1,1,1)
SaveBtn.Font = Enum.Font.Code
SaveBtn.TextSize = 16
SaveBtn.Parent = MainFrame

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -38, 0, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(180, 150, 0)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.Font = Enum.Font.Code
MinBtn.TextSize = 16
MinBtn.Parent = MainFrame

local OutputScroll = Instance.new("ScrollingFrame")
OutputScroll.Size = UDim2.new(1, -8, 1, -34)
OutputScroll.Position = UDim2.new(0, 4, 0, 30)
OutputScroll.BackgroundColor3 = Color3.fromRGB(3, 3, 6)
OutputScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
OutputScroll.ScrollBarThickness = 5
OutputScroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Parent = OutputScroll
UIList.Padding = UDim.new(0, 1)
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    OutputScroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 10)
end)

local isMin = false
MinBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    MainFrame.Size = isMin and UDim2.new(0, 480, 0, 28) or UDim2.new(0, 480, 0, 350)
    OutputScroll.Visible = not isMin
end)

local FullLog = "=== FORGE OBSERVADOR PURO ===\nInicio: " .. os.date() .. "\n\n"
local sc = 0
local startTime = tick()

SaveBtn.MouseButton1Click:Connect(function()
    writefile("forge_observador.txt", FullLog)
    SaveBtn.Text = "✅"
    task.delay(1, function() SaveBtn.Text = "💾" end)
end)

local function L(text, color)
    local timestamp = string.format("%.2f", tick() - startTime)
    local line = "[" .. timestamp .. "s] " .. text
    FullLog = FullLog .. line .. "\n"
    sc = sc + 1
    if sc >= 5 then
        pcall(function() writefile("forge_observador.txt", FullLog) end)
        sc = 0
    end
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, -6, 0, 16)
    msg.BackgroundTransparency = 1
    msg.Text = line
    msg.TextColor3 = color or Color3.fromRGB(180, 180, 180)
    msg.TextSize = 9
    msg.Font = Enum.Font.Code
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.TextWrapped = true
    msg.Parent = OutputScroll
    msg.Size = UDim2.new(1, -6, 0, msg.TextBounds.Y + 3)
    OutputScroll.CanvasPosition = Vector2.new(0, 99999)
end

local HttpService = game:GetService("HttpService")
local function Dump(v)
    if typeof(v) == "Instance" then return "[Inst:" .. v.ClassName .. "] " .. v:GetFullName() end
    if v == nil then return "nil" end
    if type(v) == "table" then
        local ok, r = pcall(function() return HttpService:JSONEncode(v) end)
        if ok then return r end
        local s = "{"
        local c = 0
        for k, val in pairs(v) do
            c = c + 1
            if c > 15 then s = s .. "...(+" .. (c) .. ")"; break end
            s = s .. tostring(k) .. "=" .. tostring(val) .. ", "
        end
        return s .. "}"
    end
    return "(" .. typeof(v) .. ")" .. tostring(v)
end

-- ==========================================
-- 1. HOOK NAMECALL — SOLO OBSERVAR, NO TOCAR
-- ==========================================
L("═══ INSTALANDO OBSERVADORES ═══", Color3.fromRGB(255, 150, 0))

local OriginalNamecall
OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- Solo observar, NUNCA bloquear
    if not checkcaller() and (method == "InvokeServer" or method == "FireServer") then
        task.spawn(function()
            pcall(function()
                local name = self.Name
                local fullName = self:GetFullName()
                local nameLower = string.lower(fullName)
                
                -- Filtrar spam
                local spam = {"move", "mouse", "camera", "ping", "render", "step", "chat", "position", "look", "heartbeat"}
                for _, w in pairs(spam) do if string.find(nameLower, w) then return end end
                
                -- Log detallado para forge
                local isForge = string.find(nameLower, "forge") or string.find(nameLower, "changesequence") or string.find(nameLower, "sequence")
                
                if isForge then
                    L("🔥 CLIENTE→SERVER [" .. method .. "] " .. name, Color3.fromRGB(255, 100, 50))
                    L("   Ruta: " .. fullName, Color3.fromRGB(200, 120, 50))
                    for i, v in ipairs(args) do
                        L("   arg[" .. i .. "] = " .. Dump(v), Color3.fromRGB(255, 200, 100))
                    end
                else
                    -- Log genérico para otros remotes
                    local argStr = ""
                    for i, v in ipairs(args) do argStr = argStr .. "[" .. i .. "]=" .. tostring(v) .. " " end
                    if argStr ~= "" then
                        L("📤 " .. method .. " " .. name .. " >> " .. argStr, Color3.fromRGB(100, 100, 100))
                    end
                end
            end)
        end)
    end
    
    -- IMPORTANTE: Capturar el RETURN del server para forge
    if not checkcaller() and method == "InvokeServer" then
        local fullName = self:GetFullName()
        if string.find(string.lower(fullName), "changesequence") or string.find(string.lower(fullName), "forge") then
            local results = {OriginalNamecall(self, ...)}
            task.spawn(function()
                pcall(function()
                    L("🔵 SERVER RETORNÓ para " .. self.Name .. ":", Color3.fromRGB(50, 150, 255))
                    for i, v in ipairs(results) do
                        L("   ret[" .. i .. "] = " .. Dump(v), Color3.fromRGB(100, 200, 255))
                    end
                    -- Extraer tiempos si es tabla
                    if type(results[1]) == "table" then
                        local function findKeys(t, prefix, depth)
                            if depth > 4 then return end
                            for k, v in pairs(t) do
                                local key = prefix .. tostring(k)
                                if type(v) == "table" then
                                    findKeys(v, key .. ".", (depth or 0) + 1)
                                else
                                    L("      " .. key .. " = " .. tostring(v), Color3.fromRGB(150, 220, 255))
                                end
                            end
                        end
                        findKeys(results[1], "", 0)
                    end
                end)
            end)
            return unpack(results)
        end
    end
    
    return OriginalNamecall(self, ...)
end)
L("  ✅ Hook __namecall (solo observar)", Color3.fromRGB(100, 255, 100))

-- ==========================================
-- 2. ESCUCHAR REMOTES DEL SERVER
-- ==========================================
for _, v in pairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA("RemoteEvent") then
        local nameLower = string.lower(v.Name .. v:GetFullName())
        if string.find(nameLower, "forge") or string.find(nameLower, "sequence") or string.find(nameLower, "minigame") then
            v.OnClientEvent:Connect(function(...)
                local args = {...}
                L("📡 SERVER→CLIENTE [" .. v.Name .. "]", Color3.fromRGB(0, 255, 100))
                L("   Ruta: " .. v:GetFullName(), Color3.fromRGB(100, 200, 100))
                for i, val in ipairs(args) do
                    L("   arg[" .. i .. "] = " .. Dump(val), Color3.fromRGB(150, 255, 150))
                end
            end)
            L("  ✅ Escuchando: " .. v.Name, Color3.fromRGB(100, 255, 100))
        end
    end
end

-- Escuchar TODOS los Knit services relevantes
for _, v in pairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA("RemoteEvent") then
        local nameLower = string.lower(v:GetFullName())
        if string.find(nameLower, "knit") and not string.find(nameLower, "forge") then
            local n = string.lower(v.Name)
            if string.find(n, "progress") or string.find(n, "equip") or string.find(n, "inventory") or string.find(n, "reward") or string.find(n, "craft") or string.find(n, "item") then
                v.OnClientEvent:Connect(function(...)
                    local args = {...}
                    L("📡 [KNIT] " .. v.Name .. " (" .. #args .. " args)", Color3.fromRGB(200, 200, 100))
                    for i, val in ipairs(args) do
                        L("   arg[" .. i .. "] = " .. Dump(val), Color3.fromRGB(220, 220, 150))
                    end
                end)
            end
        end
    end
end

-- ==========================================
-- 3. MONITOR DE PlayerGui (detectar UIs de forja)
-- ==========================================
L("  ✅ Monitor de PlayerGui activo", Color3.fromRGB(100, 255, 100))

local trackedGUIs = {}
task.spawn(function()
    while ScreenGui.Parent do
        pcall(function()
            for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Name ~= "ForgeObsUI" then
                    local nl = string.lower(gui.Name)
                    if string.find(nl, "forge") or string.find(nl, "minigame") or string.find(nl, "craft") then
                        if not trackedGUIs[gui.Name] then
                            trackedGUIs[gui.Name] = true
                            L("🖥️ UI APARECIÓ: " .. gui.Name .. " (Enabled=" .. tostring(gui.Enabled) .. ")", Color3.fromRGB(255, 255, 0))
                            
                            -- Listar TODOS los hijos
                            for _, child in pairs(gui:GetDescendants()) do
                                if child:IsA("TextLabel") then
                                    L("   📝 Label: \"" .. child.Text .. "\" [" .. child.Name .. "]", Color3.fromRGB(255, 255, 150))
                                elseif child:IsA("TextButton") then
                                    L("   🔘 Button: \"" .. child.Text .. "\" [" .. child.Name .. "]", Color3.fromRGB(255, 200, 100))
                                elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
                                    L("   🖼️ Image: " .. child.Name, Color3.fromRGB(200, 200, 150))
                                elseif child:IsA("Frame") then
                                    -- solo frames importantes
                                end
                            end
                            
                            -- Observar cambios en la UI
                            gui.DescendantAdded:Connect(function(desc)
                                task.spawn(function()
                                    pcall(function()
                                        if desc:IsA("TextLabel") and desc.Text ~= "" then
                                            L("🖥️+ NUEVO en " .. gui.Name .. ": \"" .. desc.Text .. "\" [" .. desc.Name .. "]", Color3.fromRGB(255, 255, 50))
                                        elseif desc:IsA("TextButton") then
                                            L("🖥️+ BOTÓN en " .. gui.Name .. ": \"" .. desc.Text .. "\" [" .. desc.Name .. "]", Color3.fromRGB(255, 200, 50))
                                        end
                                    end)
                                end)
                            end)
                            
                            gui.DescendantRemoving:Connect(function(desc)
                                task.spawn(function()
                                    pcall(function()
                                        if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                                            L("🖥️- REMOVIDO de " .. gui.Name .. ": [" .. desc.Name .. "]", Color3.fromRGB(255, 150, 50))
                                        end
                                    end)
                                end)
                            end)
                        end
                    end
                end
            end
        end)
        task.wait(0.5)
    end
end)

-- ==========================================
-- 4. MONITOR DEL PERSONAJE (detectar congelamiento)
-- ==========================================
task.spawn(function()
    local lastPos = nil
    local stuckCount = 0
    while ScreenGui.Parent do
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChild("Humanoid")
                if root and hum then
                    local pos = root.Position
                    local anchored = root.Anchored
                    local walkSpeed = hum.WalkSpeed
                    local state = hum:GetState().Name
                    
                    -- Detectar si está pegado
                    if lastPos and (pos - lastPos).Magnitude < 0.01 and walkSpeed == 0 then
                        stuckCount = stuckCount + 1
                        if stuckCount == 3 then -- 3 checks = 3 segundos pegado
                            L("⚠️ PERSONAJE PEGADO! Anchored=" .. tostring(anchored) .. " WalkSpeed=" .. walkSpeed .. " State=" .. state, Color3.fromRGB(255, 50, 50))
                            -- Listar BodyMovers
                            for _, child in pairs(root:GetChildren()) do
                                if child:IsA("BodyMover") or child:IsA("Constraint") then
                                    L("   🔗 " .. child.ClassName .. ": " .. child.Name, Color3.fromRGB(255, 100, 100))
                                end
                            end
                        end
                    else
                        if stuckCount >= 3 then
                            L("✅ Personaje se LIBERÓ", Color3.fromRGB(100, 255, 100))
                        end
                        stuckCount = 0
                    end
                    lastPos = pos
                end
            end
        end)
        task.wait(1)
    end
end)

-- ==========================================
-- LISTO
-- ==========================================
L("\n═══════════════════════════════════════════", Color3.fromRGB(255, 150, 0))
L("  🔬 OBSERVADOR LISTO. Ve a la forja y haz un arma.", Color3.fromRGB(255, 150, 0))
L("  NO interfiero en NADA. Solo grabo todo.", Color3.fromRGB(255, 200, 100))
L("  Se guarda automático en forge_observador.txt", Color3.fromRGB(200, 200, 200))
L("═══════════════════════════════════════════\n", Color3.fromRGB(255, 150, 0))

pcall(function() writefile("forge_observador.txt", FullLog) end)
