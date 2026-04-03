-- ==============================================================================
-- 🦖 CATCH A MONSTER: V7.0 — ENVENENADOR DE PLANTILLAS
-- Modificamos los TEMPLATES de monstruos para que todo mob NUEVO
-- nazca con 1 HP, 0 daño, y 100% probabilidad de captura.
-- ==============================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

local UI_Name = "CAM_Poisoner"
if CoreGui:FindFirstChild(UI_Name) then CoreGui[UI_Name]:Destroy() end

local SG = Instance.new("ScreenGui")
SG.Name = UI_Name
SG.ResetOnSpawn = false
SG.Parent = pcall(function() return CoreGui.Name end) and CoreGui or LP:WaitForChild("PlayerGui")

local MF = Instance.new("Frame", SG)
MF.Size = UDim2.new(0, 440, 0, 350)
MF.Position = UDim2.new(0.5, 0, 0.25, 0)
MF.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MF.BorderSizePixel = 2
MF.BorderColor3 = Color3.fromRGB(0, 255, 100)
MF.Active = true
MF.Draggable = true

local Title = Instance.new("TextLabel", MF)
Title.Size = UDim2.new(1, 0, 0, 26)
Title.BackgroundColor3 = Color3.fromRGB(0, 60, 20)
Title.Text = " ☠️ ENVENENADOR DE PLANTILLAS V7"
Title.TextColor3 = Color3.fromRGB(100, 255, 150)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left

local LogFrame = Instance.new("ScrollingFrame", MF)
LogFrame.Size = UDim2.new(1, -12, 0, 140)
LogFrame.Position = UDim2.new(0, 6, 0, 30)
LogFrame.BackgroundColor3 = Color3.fromRGB(3, 3, 3)
LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LogFrame.ScrollBarThickness = 4
LogFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", LogFrame).SortOrder = Enum.SortOrder.LayoutOrder

local lc = 0
local logBuffer = {}
local function Log(t, c)
    lc = lc + 1
    table.insert(logBuffer, "["..os.date("%X").."] "..t)
    local m = Instance.new("TextLabel", LogFrame)
    m.Size = UDim2.new(1, 0, 0, 15)
    m.BackgroundTransparency = 1
    m.Text = logBuffer[#logBuffer]
    m.TextXAlignment = Enum.TextXAlignment.Left
    m.TextColor3 = c or Color3.fromRGB(170, 170, 170)
    m.Font = Enum.Font.Code; m.TextSize = 10
    m.TextWrapped = true; m.AutomaticSize = Enum.AutomaticSize.Y
    m.LayoutOrder = lc
    LogFrame.CanvasPosition = Vector2.new(0, 99999)
end

local function MkBtn(txt, py)
    local b = Instance.new("TextButton", MF)
    b.Size = UDim2.new(0.92, 0, 0, 30)
    b.Position = UDim2.new(0.04, 0, 0, py)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamSemibold; b.TextSize = 12
    b.Text = txt
    return b
end

local btnPoison  = MkBtn("☠️ ENVENENAR PLANTILLAS (Mobs = 1HP/0DMG)", 176)
local btnFarm    = MkBtn("⚔️ AUTO-FARM (Click + Auto-Catch)", 210)
local btnCatch   = MkBtn("🎯 CAPTURA 100% (CatchProbability = 1)", 244)
local btnExport  = MkBtn("💾 EXPORTAR LOG", 278)
local btnPetBuff = MkBtn("💪 BUFF MASCOTAS (Damage x50)", 312)

-- ==========================================================
-- 1. ENVENENADOR DE PLANTILLAS DE MONSTRUOS
-- ==========================================================
-- Identificamos las plantillas de mobs por tener AMBOS:
-- "TmplId" (número) + "MonsterLogic" (tabla) + "Health" (número)
-- Esto excluye las plantillas de mascotas (que tienen "Source"="Evolution")

btnPoison.MouseButton1Click:Connect(function()
    Log("☠️ Buscando plantillas de monstruos en getgc()...", Color3.fromRGB(255, 200, 0))
    local poisoned = 0
    
    pcall(function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" then
                local tmpl = rawget(v, "TmplId")
                local monLogic = rawget(v, "MonsterLogic")
                local hp = rawget(v, "Health")
                
                -- Es una plantilla de MONSTRUO si tiene TmplId + MonsterLogic
                if tmpl and monLogic and hp then
                    local oldHp = hp
                    local oldDmg = rawget(v, "Damage") or 0
                    local name = rawget(v, "Name") or rawget(v, "Model") or "?"
                    
                    -- ENVENENAR: HP mínimo, Daño cero, Crecimiento cero
                    rawset(v, "Health", 0.1)
                    rawset(v, "HealthGrow", 0)
                    rawset(v, "Damage", 0)
                    rawset(v, "DamageGrow", 0)
                    
                    -- Captura garantizada
                    if rawget(v, "CatchProbability") then
                        rawset(v, "CatchProbability", 1)
                    end
                    
                    poisoned = poisoned + 1
                    Log("  ☠️ TmplId="..tostring(tmpl).." ("..tostring(name)..") HP:"..tostring(oldHp).."→0.1 DMG:"..tostring(oldDmg).."→0", Color3.fromRGB(255, 100, 100))
                end
            end
        end
    end)
    
    Log("✅ " .. poisoned .. " plantillas de monstruos envenenadas", Color3.fromRGB(0, 255, 0))
    Log("⚠️ Los mobs ACTUALES no cambian. Aléjate y vuelve para que spawnen NUEVOS mobs.", Color3.fromRGB(255, 255, 0))
    btnPoison.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
    btnPoison.Text = "☠️ ENVENENADO (" .. poisoned .. " templates)"
end)

-- ==========================================================
-- 2. BUFF DE MASCOTAS
-- ==========================================================
-- Las plantillas de mascotas tienen "Source" = "Evolution"
btnPetBuff.MouseButton1Click:Connect(function()
    Log("💪 Buscando plantillas de mascotas...", Color3.fromRGB(100, 200, 255))
    local buffed = 0
    
    pcall(function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" then
                local src = rawget(v, "Source")
                local dmg = rawget(v, "Damage")
                local hp = rawget(v, "Health")
                
                -- Es MASCOTA si tiene Source="Evolution" + Damage + Health
                if src == "Evolution" and type(dmg) == "number" and type(hp) == "number" then
                    local name = rawget(v, "Name") or "?"
                    
                    -- Solo buffear si no fue ya buffeado (evitar x50 doble)
                    if dmg < 999999999999 then
                        rawset(v, "Damage", dmg * 50)
                        rawset(v, "DamageGrow", (rawget(v, "DamageGrow") or 0) * 50)
                        rawset(v, "Health", hp * 50)
                        rawset(v, "HealthGrow", (rawget(v, "HealthGrow") or 0) * 50)
                        
                        -- Boost crit
                        if rawget(v, "CriticalProb") then
                            rawset(v, "CriticalProb", 1) -- 100% crit
                        end
                        if rawget(v, "CriticalDamageRatio") then
                            rawset(v, "CriticalDamageRatio", 10) -- 10x crit damage
                        end
                        
                        buffed = buffed + 1
                        Log("  💪 "..name.." DMG:"..tostring(dmg).."→"..tostring(dmg*50), Color3.fromRGB(100, 200, 255))
                    end
                end
            end
        end
    end)
    
    Log("✅ " .. buffed .. " mascotas buffeadas x50", Color3.fromRGB(0, 255, 0))
    btnPetBuff.BackgroundColor3 = Color3.fromRGB(0, 80, 180)
    btnPetBuff.Text = "💪 BUFFED (" .. buffed .. " pets)"
end)

-- ==========================================================
-- 3. CAPTURA 100%
-- ==========================================================
btnCatch.MouseButton1Click:Connect(function()
    Log("🎯 Forzando CatchProbability = 1 en todo...", Color3.fromRGB(255, 255, 0))
    local fixed = 0
    pcall(function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" then
                local cp = rawget(v, "CatchProbability")
                if type(cp) == "number" and cp < 1 then
                    rawset(v, "CatchProbability", 1)
                    fixed = fixed + 1
                end
            end
        end
    end)
    Log("✅ " .. fixed .. " tablas con CatchProbability = 1.0", Color3.fromRGB(0, 255, 0))
    btnCatch.BackgroundColor3 = Color3.fromRGB(180, 150, 0)
end)

-- ==========================================================
-- 4. AUTO-FARM (ClickDetector + Auto-Catch con E)
-- ==========================================================
local farmActive = false

btnFarm.MouseButton1Click:Connect(function()
    farmActive = not farmActive
    btnFarm.BackgroundColor3 = farmActive and Color3.fromRGB(40, 130, 40) or Color3.fromRGB(35, 35, 40)
    btnFarm.Text = farmActive and "⚔️ FARMING..." or "⚔️ AUTO-FARM (Click + Auto-Catch)"
    Log(farmActive and "Auto-Farm ON" or "Auto-Farm OFF", Color3.fromRGB(100, 255, 100))
end)

task.spawn(function()
    while true do
        if farmActive then
            pcall(function()
                if not LP.Character or not LP.Character.PrimaryPart then return end
                local myPos = LP.Character.PrimaryPart.Position
                local best, bestDist = nil, 80
                
                local cm = Workspace:FindFirstChild("ClientMonsters")
                if cm then
                    for _, mob in pairs(cm:GetChildren()) do
                        if mob:IsA("Model") then
                            local cd = mob:FindFirstChildWhichIsA("ClickDetector", true)
                            if cd then
                                local p = mob.PrimaryPart or mob:FindFirstChildWhichIsA("BasePart")
                                if p then
                                    local d = (p.Position - myPos).Magnitude
                                    if d < bestDist then bestDist = d; best = cd end
                                end
                            end
                        end
                    end
                end
                
                if best then
                    fireclickdetector(best)
                    Log("🖱️ Click mob ["..math.floor(bestDist).."m]", Color3.fromRGB(100, 200, 255))
                end
            end)
        end
        task.wait(2.5)
    end
end)

-- Auto-catch con E después de PushRewardEvent
task.spawn(function()
    pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        for _, desc in pairs(rs:GetDescendants()) do
            if desc:IsA("RemoteEvent") then
                desc.OnClientEvent:Connect(function(...)
                    local args = {...}
                    local name = tostring(args[1] or "")
                    if farmActive and name == "PushRewardEvent" then
                        Log("💀 MOB MUERTO → Auto-E", Color3.fromRGB(255, 255, 0))
                        task.delay(0.3, function()
                            pcall(function()
                                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                task.wait(0.15)
                                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            end)
                        end)
                    end
                end)
            end
        end
    end)
end)

-- ==========================================================
-- 5. EXPORTAR
-- ==========================================================
btnExport.MouseButton1Click:Connect(function()
    local fn = "CAM_Poison_"..os.date("%Y%m%d_%H%M%S")..".txt"
    pcall(function()
        writefile(fn, table.concat(logBuffer, "\n"))
    end)
    Log("💾 Exportado: "..fn, Color3.fromRGB(0, 255, 200))
end)

-- ==========================================================
-- 6. LOOP: Envenenamiento continuo (cada 30s re-aplica)
-- ==========================================================
task.spawn(function()
    while true do
        task.wait(30)
        pcall(function()
            for _, v in pairs(getgc(true)) do
                if type(v) == "table" then
                    -- Re-envenenar mobs continuamente
                    if rawget(v, "TmplId") and rawget(v, "MonsterLogic") and rawget(v, "Health") then
                        if v.Health > 1 then
                            v.Health = 0.1
                            v.HealthGrow = 0
                            v.Damage = 0
                            v.DamageGrow = 0
                            if rawget(v, "CatchProbability") then v.CatchProbability = 1 end
                        end
                    end
                    -- Mantener rangos
                    if rawget(v, "AttackRange") and v.AttackRange < 150 then v.AttackRange = 300 end
                    if rawget(v, "CatchRange") and v.CatchRange < 150 then v.CatchRange = 300 end
                end
            end
        end)
    end
end)

Log("=== INSTRUCCIONES ===", Color3.fromRGB(255, 255, 255))
Log("1) Pulsa ☠️ ENVENENAR primero", Color3.fromRGB(200, 200, 200))
Log("2) Pulsa 💪 BUFF MASCOTAS", Color3.fromRGB(200, 200, 200))
Log("3) Pulsa 🎯 CAPTURA 100%", Color3.fromRGB(200, 200, 200))
Log("4) ALÉJATE de los mobs actuales (para que despawneen)", Color3.fromRGB(255, 200, 100))
Log("5) VUELVE — los nuevos mobs tendrán 0.1 HP", Color3.fromRGB(255, 200, 100))
Log("6) Activa ⚔️ AUTO-FARM y disfruta", Color3.fromRGB(200, 200, 200))
