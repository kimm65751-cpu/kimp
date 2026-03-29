-- ==============================================================================
-- 🔬 FORGE OBSERVADOR V1.2 — SIN HOOK (no rompe NPC)
-- ==============================================================================
-- CERO hookmetamethod. Solo escucha RemoteEvents + monitorea UI.
-- NO interfiere con NADA del juego.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

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
Title.Size = UDim2.new(1, -75, 0, 28)
Title.BackgroundColor3 = Color3.fromRGB(40, 20, 0)
Title.Text = " 🔬 FORGE OBSERVADOR V1.2 (SIN HOOK)"
Title.TextColor3 = Color3.fromRGB(255, 150, 0)
Title.TextSize = 11
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0, 40, 0, 28)
SaveBtn.Position = UDim2.new(1, -75, 0, 0)
SaveBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
SaveBtn.Text = "💾"
SaveBtn.TextColor3 = Color3.new(1,1,1)
SaveBtn.Font = Enum.Font.Code
SaveBtn.TextSize = 16
SaveBtn.Parent = MainFrame

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -33, 0, 0)
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

local FullLog = "=== FORGE OBSERVADOR V1.2 (SIN HOOK) ===\n\n"
local sc = 0
local startTime = tick()
local msgCount = 0

SaveBtn.MouseButton1Click:Connect(function()
    writefile("forge_observador.txt", FullLog)
    SaveBtn.Text = "✅"
    task.delay(1, function() SaveBtn.Text = "💾" end)
end)

local function L(text, color)
    local t = string.format("%.2f", tick() - startTime)
    local line = "[" .. t .. "s] " .. text
    FullLog = FullLog .. line .. "\n"
    sc = sc + 1
    if sc >= 8 then
        pcall(function() writefile("forge_observador.txt", FullLog) end)
        sc = 0
    end
    msgCount = msgCount + 1
    if msgCount > 500 then return end
    task.defer(function()
        pcall(function()
            local msg = Instance.new("TextLabel")
            msg.Size = UDim2.new(1, -6, 0, 14)
            msg.BackgroundTransparency = 1
            msg.Text = line
            msg.TextColor3 = color or Color3.fromRGB(180, 180, 180)
            msg.TextSize = 9
            msg.Font = Enum.Font.Code
            msg.TextXAlignment = Enum.TextXAlignment.Left
            msg.TextWrapped = true
            msg.Parent = OutputScroll
            msg.Size = UDim2.new(1, -6, 0, msg.TextBounds.Y + 2)
            OutputScroll.CanvasPosition = Vector2.new(0, 99999)
        end)
    end)
end

local function Dump(v)
    if typeof(v) == "Instance" then return "[" .. v.ClassName .. "] " .. v.Name end
    if v == nil then return "nil" end
    if type(v) == "table" then
        local s = "{"
        local c = 0
        for k, val in pairs(v) do
            c = c + 1
            if c > 12 then s = s .. "..."; break end
            if type(val) == "table" then
                local inner = "{"
                local ic = 0
                for ik, iv in pairs(val) do
                    ic = ic + 1
                    if ic > 5 then inner = inner .. "..."; break end
                    inner = inner .. tostring(ik) .. "=" .. tostring(iv) .. ", "
                end
                s = s .. tostring(k) .. "=" .. inner .. "}, "
            else
                s = s .. tostring(k) .. "=" .. tostring(val) .. ", "
            end
        end
        return s .. "}"
    end
    return tostring(v)
end

-- ==========================================
-- 1. ESCUCHAR TODOS LOS REMOTES RELEVANTES
-- ==========================================
L("═══ CONECTANDO ESCUCHAS PASIVAS ═══", Color3.fromRGB(255, 150, 0))

local remotesConectados = 0
for _, v in pairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA("RemoteEvent") then
        local nl = string.lower(v.Name .. v:GetFullName())
        -- Escuchar TODOS los que sean forge, craft, progress, equip, sequence, knit services
        if string.find(nl, "forge") or string.find(nl, "sequence") or string.find(nl, "progress")
            or string.find(nl, "equip") or string.find(nl, "craft") or string.find(nl, "reward")
            or string.find(nl, "inventory") or string.find(nl, "item") or string.find(nl, "weapon") then
            v.OnClientEvent:Connect(function(...)
                local args = {...}
                task.defer(function()
                    L("📡 SERVER→CLIENTE: " .. v.Name, Color3.fromRGB(0, 255, 100))
                    for i, val in ipairs(args) do
                        L("   [" .. i .. "] " .. Dump(val), Color3.fromRGB(150, 255, 150))
                    end
                end)
            end)
            remotesConectados = remotesConectados + 1
        end
    end
end
L("  ✅ " .. remotesConectados .. " RemoteEvents escuchados", Color3.fromRGB(100, 255, 100))

-- ==========================================
-- 2. MONITOR DE UI DE FORJA
-- ==========================================
local trackedGUIs = {}
local trackedElements = {}

task.spawn(function()
    while ScreenGui.Parent do
        pcall(function()
            for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Name ~= "ForgeObsUI" then
                    local nl = string.lower(gui.Name)
                    if string.find(nl, "forge") or string.find(nl, "minigame") or string.find(nl, "craft") then
                        if not trackedGUIs[gui] then
                            trackedGUIs[gui] = true
                            L("🖥️ UI APARECIÓ: [" .. gui.Name .. "]", Color3.fromRGB(255, 255, 0))
                            
                            -- Listar contenido actual
                            for _, child in pairs(gui:GetDescendants()) do
                                if child:IsA("TextLabel") and child.Text ~= "" and not trackedElements[child] then
                                    trackedElements[child] = child.Text
                                    L("   📝 \"" .. child.Text .. "\" [" .. child.Name .. "]", Color3.fromRGB(255, 255, 150))
                                elseif child:IsA("TextButton") and child.Text ~= "" and not trackedElements[child] then
                                    trackedElements[child] = child.Text
                                    L("   🔘 \"" .. child.Text .. "\" [" .. child.Name .. "]", Color3.fromRGB(255, 200, 100))
                                end
                            end
                            
                            -- Observar nuevos elementos
                            gui.DescendantAdded:Connect(function(desc)
                                task.defer(function()
                                    pcall(function()
                                        if desc:IsA("TextLabel") and desc.Text ~= "" then
                                            L("🖥️+ \"" .. desc.Text .. "\" [" .. desc.Name .. "]", Color3.fromRGB(255, 255, 50))
                                        elseif desc:IsA("TextButton") and desc.Text ~= "" then
                                            L("🔘+ BOTÓN \"" .. desc.Text .. "\" [" .. desc.Name .. "]", Color3.fromRGB(255, 200, 50))
                                        end
                                    end)
                                end)
                            end)
                            
                            gui.DescendantRemoving:Connect(function(desc)
                                task.defer(function()
                                    pcall(function()
                                        if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("Frame") then
                                            L("🖥️- QUITADO: [" .. desc.Name .. "]", Color3.fromRGB(255, 150, 50))
                                        end
                                    end)
                                end)
                            end)
                            
                            -- Detectar cuando la UI se destruye
                            gui.Destroying:Connect(function()
                                L("💀 UI DESTRUIDA: [" .. gui.Name .. "]", Color3.fromRGB(255, 50, 50))
                            end)
                        end
                    end
                end
            end
        end)
        task.wait(2)
    end
end)
L("  ✅ Monitor de PlayerGui activo", Color3.fromRGB(100, 255, 100))

-- ==========================================
-- 3. MONITOR DEL PERSONAJE + WALKSPEED
-- ==========================================
task.spawn(function()
    local lastPos = nil
    local lastWalkSpeed = nil
    local stuckCount = 0
    while ScreenGui.Parent do
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChild("Humanoid")
                if root and hum then
                    -- Detectar cambio de WalkSpeed
                    if lastWalkSpeed ~= hum.WalkSpeed then
                        L("🚶 WalkSpeed cambió: " .. tostring(lastWalkSpeed) .. " → " .. tostring(hum.WalkSpeed), Color3.fromRGB(200, 200, 255))
                        lastWalkSpeed = hum.WalkSpeed
                    end
                    
                    -- Detectar pegado
                    local pos = root.Position
                    if lastPos and (pos - lastPos).Magnitude < 0.05 and hum.WalkSpeed == 0 then
                        stuckCount = stuckCount + 1
                        if stuckCount == 2 then
                            L("⚠️ PEGADO! Anchored=" .. tostring(root.Anchored) .. " State=" .. hum:GetState().Name, Color3.fromRGB(255, 50, 50))
                            for _, c in pairs(root:GetChildren()) do
                                if c:IsA("BodyMover") or c:IsA("Constraint") or c:IsA("AlignPosition") or c:IsA("AlignOrientation") then
                                    L("   🔗 " .. c.ClassName .. ": " .. c.Name .. " (Enabled=" .. tostring(c.Enabled or "?") .. ")", Color3.fromRGB(255, 100, 100))
                                end
                            end
                        end
                    else
                        if stuckCount >= 2 then L("✅ LIBERADO! WalkSpeed=" .. hum.WalkSpeed, Color3.fromRGB(100, 255, 100)) end
                        stuckCount = 0
                    end
                    lastPos = pos
                end
            end
        end)
        task.wait(2)
    end
end)
L("  ✅ Monitor de personaje activo", Color3.fromRGB(100, 255, 100))

-- ==========================================
-- 4. MONITOREAR Workspace PARA MODELOS DE FORJA
-- ==========================================
task.spawn(function()
    task.wait(3)
    pcall(function()
        -- Buscar el modelo de la forja en workspace
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local parent = obj:FindFirstAncestorWhichIsA("Model")
                if parent and string.find(string.lower(parent.Name), "forge") then
                    L("🔨 FORJA encontrada: " .. parent:GetFullName(), Color3.fromRGB(255, 200, 100))
                    L("   ProximityPrompt: " .. obj.Name .. " ActionText=" .. tostring(obj.ActionText), Color3.fromRGB(200, 200, 150))
                end
            end
        end
    end)
end)

L("\n═══════════════════════════════════════════", Color3.fromRGB(255, 150, 0))
L("  🔬 LISTO. Ve a la forja, habla y haz un arma NORMAL.", Color3.fromRGB(255, 150, 0))
L("  SIN HOOK = no interfiere con NPCs.", Color3.fromRGB(100, 255, 100))
L("  forge_observador.txt se guarda automático.", Color3.fromRGB(200, 200, 200))
L("═══════════════════════════════════════════\n", Color3.fromRGB(255, 150, 0))
pcall(function() writefile("forge_observador.txt", FullLog) end)
