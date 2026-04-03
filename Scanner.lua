-- ==============================================================================
-- 🦖 CAM V10 — REPLAY ATTACK + SPY (USA PlayerGui, GUI CONFIRMADA OK)
-- ==============================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-- Limpieza
for _, v in pairs(PlayerGui:GetChildren()) do
    if v.Name == "CAM_Test" or v.Name == "CAM_V10" then
        pcall(function() v:Destroy() end)
    end
end

local SG = Instance.new("ScreenGui")
SG.Name = "CAM_V10"
SG.ResetOnSpawn = false
SG.Parent = PlayerGui

local MF = Instance.new("Frame", SG)
MF.Size = UDim2.new(0, 500, 0, 430)
MF.Position = UDim2.new(0.4, 0, 0.15, 0)
MF.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MF.BorderSizePixel = 2
MF.BorderColor3 = Color3.fromRGB(255, 180, 0)
MF.Active = true
MF.Draggable = true

local Title = Instance.new("TextLabel", MF)
Title.Size = UDim2.new(1, 0, 0, 26)
Title.BackgroundColor3 = Color3.fromRGB(60, 50, 0)
Title.Text = "  🕵️ REPLAY ATTACK V10  (SPY + GATLING)"
Title.TextColor3 = Color3.fromRGB(255, 220, 100)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left

-- ScrollLog
local LogFrame = Instance.new("ScrollingFrame", MF)
LogFrame.Size = UDim2.new(1, -10, 0, 190)
LogFrame.Position = UDim2.new(0, 5, 0, 28)
LogFrame.BackgroundColor3 = Color3.fromRGB(3, 3, 3)
LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LogFrame.ScrollBarThickness = 4
LogFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", LogFrame).SortOrder = Enum.SortOrder.LayoutOrder

local lc = 0
local logBuffer = {}

local function Log(t, c)
    lc = lc + 1
    local line = "["..os.date("%X").."] "..t
    table.insert(logBuffer, line)
    local m = Instance.new("TextLabel", LogFrame)
    m.Size = UDim2.new(1, 0, 0, 14)
    m.BackgroundTransparency = 1
    m.Text = line
    m.TextXAlignment = Enum.TextXAlignment.Left
    m.TextColor3 = c or Color3.fromRGB(200, 200, 200)
    m.Font = Enum.Font.Code
    m.TextSize = 11
    m.TextWrapped = true
    m.AutomaticSize = Enum.AutomaticSize.Y
    m.LayoutOrder = lc
    LogFrame.CanvasPosition = Vector2.new(0, 99999)
end

local function MkBtn(txt, py, w)
    local b = Instance.new("TextButton", MF)
    b.Size = UDim2.new(w or 0.92, 0, 0, 28)
    b.Position = UDim2.new(0.04, 0, 0, py)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 11
    b.Text = txt
    return b
end

local btnSpy     = MkBtn("🕵️ ESPÍA ON/OFF (Captura FireServer/InvokeServer)", 225)
local btnReplay  = MkBtn("🔁 REPLAY ATTACK ON/OFF (x10 el último ataque)", 258)
local btnFarm    = MkBtn("⚔️ AUTO-FARM (Click + Auto-E)", 291)
local btnCopy    = MkBtn("📋 COPIAR LOG", 324, 0.44)
local btnExport  = MkBtn("💾 EXPORTAR .txt", 324, 0.44)
btnExport.Position = UDim2.new(0.52, 0, 0, 324)

-- Exportar
btnExport.MouseButton1Click:Connect(function()
    local fn = "CAM_Spy_"..os.date("%Y%m%d_%H%M%S")..".txt"
    pcall(function() writefile(fn, table.concat(logBuffer, "\n")) end)
    Log("💾 Exportado: "..fn, Color3.fromRGB(0, 255, 200))
end)

-- Copiar
btnCopy.MouseButton1Click:Connect(function()
    pcall(function()
        if setclipboard then
            setclipboard(table.concat(logBuffer, "\n"))
            Log("📋 Log copiado!", Color3.fromRGB(0, 255, 0))
        else
            Log("❌ setclipboard no soportado", Color3.fromRGB(255, 100, 100))
        end
    end)
end)

-- ==============================================================================
-- ESTADO GLOBAL
-- ==============================================================================
local spyActive     = false
local replayActive  = false
local farmActive    = false

-- Guardamos el ÚLTIMO FireServer capturado en combate
local lastCombatRemote = nil
local lastCombatArgs   = nil
local capturedCount    = 0

-- ==============================================================================
-- 1. ESPÍA: hookmetamethod __namecall
-- ==============================================================================
local hookInstalled = false

btnSpy.MouseButton1Click:Connect(function()
    spyActive = not spyActive
    btnSpy.BackgroundColor3 = spyActive and Color3.fromRGB(180, 120, 0) or Color3.fromRGB(40, 40, 50)
    btnSpy.Text = spyActive and "🕵️ ESPIANDO... (Pulsa para detener)" or "🕵️ ESPÍA ON/OFF"
    Log(spyActive and "🕵️ Espía activado — pelea un mob ahora" or "🛑 Espía detenido", Color3.fromRGB(255, 220, 100))

    -- Instalar el hook solo una vez
    if spyActive and not hookInstalled then
        hookInstalled = true
        local ok, err = pcall(function()
            if type(hookmetamethod) ~= "function" then
                error("hookmetamethod no disponible en este executor")
            end

            local oldNC
            oldNC = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                local method = getnamecallmethod()

                if (method == "FireServer" or method == "InvokeServer") and spyActive then
                    if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") then
                        local args = {...}
                        capturedCount = capturedCount + 1

                        -- Serializar args
                        local parts = {}
                        for i, a in ipairs(args) do
                            if i > 5 then break end
                            if type(a) == "table" then
                                local tp = {}
                                for k, v in pairs(a) do
                                    table.insert(tp, tostring(k).."="..tostring(v))
                                    if #tp >= 4 then break end
                                end
                                table.insert(parts, "{"..table.concat(tp, ",").."}")
                            else
                                table.insert(parts, tostring(a))
                            end
                        end

                        local preview = self.Name..":"..method.."("..table.concat(parts,", ")..")"
                        if #preview > 160 then preview = preview:sub(1,160).."..." end

                        -- Detectar si parece un evento de COMBATE
                        local lower = preview:lower()
                        local isCombat = lower:find("fight") or lower:find("skill") or
                                         lower:find("attack") or lower:find("hurt") or
                                         lower:find("damage") or lower:find("catch")

                        local col = isCombat and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(200, 200, 200)

                        -- Guardar si es combate
                        if isCombat then
                            lastCombatRemote = self
                            lastCombatArgs   = args
                            Log("⚔️ COMBATE #"..capturedCount..": "..preview, Color3.fromRGB(255, 80, 80))
                        else
                            -- Log solo eventos importantes (no spamear)
                            if capturedCount <= 30 or capturedCount % 10 == 0 then
                                Log("#"..capturedCount..": "..preview, col)
                            end
                        end
                    end
                end

                return oldNC(self, ...)
            end))
        end)

        if not ok then
            Log("❌ HOOK FALLÓ: "..tostring(err), Color3.fromRGB(255, 0, 0))
            hookInstalled = false
        else
            Log("✅ hookmetamethod instalado OK", Color3.fromRGB(0, 255, 0))
        end
    end
end)

-- ==============================================================================
-- 2. REPLAY ATTACK
-- ==============================================================================
btnReplay.MouseButton1Click:Connect(function()
    replayActive = not replayActive
    btnReplay.BackgroundColor3 = replayActive and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(40, 40, 50)
    btnReplay.Text = replayActive and "🔁 REPLAY ACTIVO (x10 por ataque)" or "🔁 REPLAY ATTACK ON/OFF"
    Log(replayActive and "🔁 Replay ON — se repetirá cada ataque x10" or "🛑 Replay OFF", Color3.fromRGB(255, 150, 150))
end)

-- Loop: cuando hay combate activo, re-disparar el último ataque capturado
task.spawn(function()
    while true do
        if replayActive and lastCombatRemote and lastCombatArgs then
            local remote = lastCombatRemote
            local args   = lastCombatArgs
            for i = 1, 10 do
                pcall(function()
                    remote:FireServer(table.unpack(args))
                end)
            end
            Log("🔁 Replay x10 → "..remote.Name, Color3.fromRGB(255, 120, 50))
            task.wait(0.5)
        else
            task.wait(0.1)
        end
    end
end)

-- ==============================================================================
-- 3. AUTO-FARM (Click + Auto-E)
-- ==============================================================================
btnFarm.MouseButton1Click:Connect(function()
    farmActive = not farmActive
    btnFarm.BackgroundColor3 = farmActive and Color3.fromRGB(0, 120, 50) or Color3.fromRGB(40, 40, 50)
    btnFarm.Text = farmActive and "⚔️ FARMING ACTIVO" or "⚔️ AUTO-FARM (Click + Auto-E)"
end)

task.spawn(function()
    while true do
        if farmActive and LP.Character and LP.Character.PrimaryPart then
            pcall(function()
                local best, bestDist = nil, 80
                local cm = Workspace:FindFirstChild("ClientMonsters")
                if cm then
                    for _, mob in pairs(cm:GetChildren()) do
                        local cd = mob:FindFirstChildWhichIsA("ClickDetector", true)
                        if cd and mob.PrimaryPart then
                            local d = (mob.PrimaryPart.Position - LP.Character.PrimaryPart.Position).Magnitude
                            if d < bestDist then bestDist = d; best = cd end
                        end
                    end
                end
                if best then fireclickdetector(best) end
            end)
        end
        task.wait(2.5)
    end
end)

-- Auto-E en muerte de mob
task.spawn(function()
    pcall(function()
        for _, desc in pairs(ReplicatedStorage:GetDescendants()) do
            if desc:IsA("RemoteEvent") then
                desc.OnClientEvent:Connect(function(...)
                    if farmActive and tostring(({...})[1] or "") == "PushRewardEvent" then
                        task.delay(0.25, function()
                            pcall(function()
                                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                task.wait(0.1)
                                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            end)
                        end)
                    end
                end)
            end
        end
    end)
end)

Log("=== V10 CARGADO — PlayerGui OK ===", Color3.fromRGB(0, 255, 0))
Log("PASO 1: Pulsa ESPÍA (si dice ERROR → tu executor no soporta hookmetamethod)", Color3.fromRGB(255, 220, 100))
Log("PASO 2: Pelea un mob MANUALMENTE", Color3.fromRGB(255, 220, 100))
Log("PASO 3: Activa REPLAY ATTACK", Color3.fromRGB(255, 220, 100))
