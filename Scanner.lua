-- ==============================================================================
-- ⚔️ FORGE AUTOPLAYER v1.0 — JUEGA LOS 3 MINIJUEGOS PERFECTO
-- ==============================================================================
-- ZERO hooks. Detecta UI por .Visible y simula inputs humanos.
-- Basado en telemetría real del X-RAY v5.0
-- MELT:   Spam click en Heater.Top (TextButton)
-- POUR:   mouse1press/release adaptativo persiguiendo Area.Position.Y
-- HAMMER: Click en círculos cuando Circle.Size ≈ 1.1 (zona Perfect)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============ CONFIG ============
local MELT_CLICK_INTERVAL = 0.08    -- Segundos entre clicks del Heater
local POUR_THRESHOLD = 0.06         -- Margen para decidir press/release
local HAMMER_PERFECT_ZONE = 1.12    -- Click cuando Circle.Size <= este valor
local HAMMER_MIN_SIZE = 0.85        -- No clickear si ya pasó de este punto

-- ============ COMPACT UI ============
local CoreGui = game:GetService("CoreGui")
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or PlayerGui
for _, v in pairs(parentUI:GetChildren()) do if v.Name == "AutoForgeUI" then v:Destroy() end end

local SG = Instance.new("ScreenGui")
SG.Name = "AutoForgeUI"
SG.ResetOnSpawn = false
SG.DisplayOrder = 1000
SG.Parent = parentUI

local StatusBar = Instance.new("TextLabel")
StatusBar.Size = UDim2.new(0, 300, 0, 28)
StatusBar.Position = UDim2.new(0.5, -150, 0, 4)
StatusBar.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
StatusBar.BorderColor3 = Color3.fromRGB(50, 200, 100)
StatusBar.BorderSizePixel = 2
StatusBar.Text = " ⚔️ FORGE AUTO v1.0 | Esperando..."
StatusBar.TextColor3 = Color3.fromRGB(150, 255, 150)
StatusBar.TextSize = 12
StatusBar.Font = Enum.Font.Code
StatusBar.TextXAlignment = Enum.TextXAlignment.Left
StatusBar.Parent = SG

local function SetStatus(text, color)
    StatusBar.Text = " ⚔️ " .. text
    StatusBar.TextColor3 = color or Color3.fromRGB(150, 255, 150)
end

-- ============ INPUT SIMULATION ============
local function ClickButton(button)
    if not button or not button.Parent then return end
    -- Method 1: fireclick
    local ok1 = pcall(function() fireclick(button) end)
    if ok1 then return end
    -- Method 2: firesignal
    local ok2 = pcall(function()
        if button:IsA("TextButton") or button:IsA("ImageButton") then
            firesignal(button.MouseButton1Click)
        end
    end)
    if ok2 then return end
    -- Method 3: VirtualInputManager click at button center
    pcall(function()
        local pos = button.AbsolutePosition
        local sz = button.AbsoluteSize
        local cx, cy = pos.X + sz.X/2, pos.Y + sz.Y/2
        VIM:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
        task.wait()
        VIM:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
    end)
end

local mouseDown = false
local function PressMouseAt(x, y)
    if mouseDown then return end
    mouseDown = true
    local ok = pcall(function()
        mousemoveabs(x, y)
        mouse1press()
    end)
    if not ok then
        pcall(function()
            VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
        end)
    end
end

local function ReleaseMouse()
    if not mouseDown then return end
    mouseDown = false
    local ok = pcall(function() mouse1release() end)
    if not ok then
        pcall(function()
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
    end
end

-- ============ FIND FORGE GUI ============
local ForgeGui = nil
local MeltMG, PourMG, HammerMG = nil, nil, nil

local function FindForge()
    ForgeGui = PlayerGui:FindFirstChild("Forge")
    if ForgeGui then
        MeltMG = ForgeGui:FindFirstChild("MeltMinigame")
        PourMG = ForgeGui:FindFirstChild("PourMinigame")
        HammerMG = ForgeGui:FindFirstChild("HammerMinigame")
        return true
    end
    return false
end

FindForge()
if not ForgeGui then
    PlayerGui.ChildAdded:Connect(function(c)
        if c.Name == "Forge" then task.wait(0.5); FindForge() end
    end)
end

-- ============ GAME 1: MELT ============
local meltActive = false
local meltThread = nil

local function PlayMelt()
    if meltActive then return end
    meltActive = true
    SetStatus("MELT — Bombeando...", Color3.fromRGB(255, 100, 50))
    
    local heaterTop = nil
    pcall(function()
        heaterTop = MeltMG.Heater.Top
    end)
    
    if not heaterTop then
        SetStatus("MELT — ERROR: Heater.Top no encontrado", Color3.fromRGB(255, 0, 0))
        meltActive = false
        return
    end
    
    meltThread = task.spawn(function()
        while meltActive and MeltMG and MeltMG.Visible do
            -- Click the pump
            ClickButton(heaterTop)
            
            -- Check bar level
            local areaSize = 0
            pcall(function()
                areaSize = MeltMG.Bar.Area.Size.Y.Scale
            end)
            
            SetStatus(string.format("MELT — Barra: %.0f%%", areaSize * 100), Color3.fromRGB(255, math.floor(200 * areaSize), 50))
            
            -- Check if Finish button is clickable (visible on screen)
            pcall(function()
                local finish = MeltMG.Finish
                if finish and finish.Position.Y.Scale < 1.0 then
                    task.wait(0.1)
                    ClickButton(finish)
                end
            end)
            
            task.wait(MELT_CLICK_INTERVAL)
        end
        meltActive = false
    end)
end

local function StopMelt()
    meltActive = false
    if meltThread then
        pcall(function() task.cancel(meltThread) end)
        meltThread = nil
    end
end

-- ============ GAME 2: POUR ============
local pourActive = false
local pourThread = nil

local function PlayPour()
    if pourActive then return end
    pourActive = true
    SetStatus("POUR — Siguiendo zona...", Color3.fromRGB(100, 200, 255))
    
    local frame, area, line
    pcall(function()
        frame = PourMG.Frame
        area = frame.Area
        line = frame.Line
    end)
    
    if not area or not line then
        SetStatus("POUR — ERROR: Area/Line no encontrado", Color3.fromRGB(255, 0, 0))
        pourActive = false
        return
    end
    
    -- Position mouse over the game area
    local screenCenter = Vector2.new(500, 300)
    pcall(function()
        local fp = frame.AbsolutePosition
        local fs = frame.AbsoluteSize
        screenCenter = Vector2.new(fp.X + fs.X / 2, fp.Y + fs.Y / 2)
    end)
    
    pourThread = task.spawn(function()
        while pourActive and PourMG and PourMG.Visible do
            local areaY, lineY = 0.5, 0.5
            pcall(function() areaY = area.Position.Y.Scale end)
            pcall(function() lineY = line.Position.Y.Scale end)
            
            -- Area center = areaY + (areaHeight/2)
            -- We want Line to be at the CENTER of the Area
            local areaHeight = 0.200 -- Area is ~20% of bar height
            pcall(function() areaHeight = area.Size.Y.Scale end)
            local areaCenter = areaY + areaHeight / 2
            
            local diff = lineY - areaCenter
            
            if diff > POUR_THRESHOLD then
                -- Line is BELOW area center → need to go UP → PRESS
                PressMouseAt(screenCenter.X, screenCenter.Y)
            elseif diff < -POUR_THRESHOLD then
                -- Line is ABOVE area center → need to go DOWN → RELEASE
                ReleaseMouse()
            end
            -- If within threshold → hold current state (keeps steady)
            
            SetStatus(string.format("POUR — Line:%.2f Area:%.2f Diff:%.3f %s", 
                lineY, areaCenter, diff, mouseDown and "▲HOLD" or "▼FREE"), 
                Color3.fromRGB(100, 200, 255))
            
            task.wait() -- Every frame
        end
        ReleaseMouse()
        pourActive = false
    end)
end

local function StopPour()
    pourActive = false
    ReleaseMouse()
    if pourThread then
        pcall(function() task.cancel(pourThread) end)
        pourThread = nil
    end
end

-- ============ GAME 3: HAMMER (Circles) ============
local hammerActive = false
local hammerConn = nil
local circlesHandled = 0

local function HandleCircle(textButton)
    -- Each circle structure:
    -- Frame [TextButton] ← click this
    --   ├── Frame [ImageLabel] (center dot)
    --   ├── Border [ImageLabel] (Size 1.1)
    --   └── Circle [ImageLabel] (Size starts at 2.5, shrinks to 0)
    
    task.spawn(function()
        -- Wait for Circle child to appear
        local circle = nil
        local tries = 0
        while tries < 30 and not circle do
            for _, child in pairs(textButton:GetChildren()) do
                if child.Name == "Circle" and child:IsA("ImageLabel") then
                    circle = child
                    break
                end
            end
            if not circle then
                task.wait(0.05)
                tries = tries + 1
            end
        end
        
        if not circle then return end
        
        -- Monitor Circle.Size.X.Scale and click at the perfect moment
        local clicked = false
        while not clicked and circle.Parent and textButton.Parent and hammerActive do
            local sz = 2.5
            pcall(function() sz = circle.Size.X.Scale end)
            
            if sz <= HAMMER_PERFECT_ZONE and sz >= HAMMER_MIN_SIZE then
                -- PERFECT ZONE! Click NOW!
                task.wait(0.01) -- Tiny delay for human-like timing
                ClickButton(textButton)
                clicked = true
                circlesHandled = circlesHandled + 1
                SetStatus(string.format("HAMMER — ✨ CLICK! #%d (Size=%.2f)", circlesHandled, sz), Color3.fromRGB(255, 255, 0))
            elseif sz < HAMMER_MIN_SIZE then
                -- Missed the zone, click anyway to not miss entirely
                ClickButton(textButton)
                clicked = true
                circlesHandled = circlesHandled + 1
                SetStatus(string.format("HAMMER — ⚡ Late click #%d (Size=%.2f)", circlesHandled, sz), Color3.fromRGB(255, 150, 0))
            end
            
            if not clicked then
                task.wait() -- Check every frame
            end
        end
    end)
end

local function PlayHammer()
    if hammerActive then return end
    hammerActive = true
    circlesHandled = 0
    SetStatus("HAMMER — Esperando círculos...", Color3.fromRGB(255, 200, 50))
    
    -- Listen for new TextButtons (circles) appearing
    hammerConn = HammerMG.DescendantAdded:Connect(function(obj)
        if not hammerActive then return end
        -- Each circle appears as a TextButton named "Frame"
        if obj:IsA("TextButton") and obj.Name == "Frame" then
            task.wait(0.05) -- Let the circle children spawn
            HandleCircle(obj)
        end
    end)
    
    -- Also check for any TextButtons that already exist (in case some spawned before connection)
    for _, child in pairs(HammerMG:GetChildren()) do
        if child:IsA("TextButton") and child.Name == "Frame" then
            HandleCircle(child)
        end
    end
end

local function StopHammer()
    hammerActive = false
    if hammerConn then
        hammerConn:Disconnect()
        hammerConn = nil
    end
end

-- ============ GAME DETECTION & MAIN LOOP ============
local function SetupGameDetection()
    if not ForgeGui then return end
    
    -- MELT
    if MeltMG then
        MeltMG:GetPropertyChangedSignal("Visible"):Connect(function()
            if MeltMG.Visible then
                task.wait(1.5) -- Wait for entrance animation + countdown
                PlayMelt()
            else
                StopMelt()
                SetStatus("MELT completado ✅", Color3.fromRGB(0, 255, 100))
            end
        end)
    end
    
    -- POUR
    if PourMG then
        PourMG:GetPropertyChangedSignal("Visible"):Connect(function()
            if PourMG.Visible then
                task.wait(1.5) -- Wait for entrance + countdown
                PlayPour()
            else
                StopPour()
                SetStatus("POUR completado ✅", Color3.fromRGB(0, 255, 100))
            end
        end)
    end
    
    -- HAMMER
    if HammerMG then
        HammerMG:GetPropertyChangedSignal("Visible"):Connect(function()
            if HammerMG.Visible then
                task.wait(1.5) -- Wait for entrance + countdown
                PlayHammer()
            else
                StopHammer()
                SetStatus(string.format("HAMMER completado ✅ (%d círculos)", circlesHandled), Color3.fromRGB(0, 255, 100))
            end
        end)
    end
    
    SetStatus("LISTO — Inicia la forja ⚒️", Color3.fromRGB(150, 255, 150))
end

-- ============ INIT ============
task.spawn(function()
    if not ForgeGui then
        SetStatus("Esperando Forge GUI...", Color3.fromRGB(255, 200, 50))
        local tries = 0
        while not ForgeGui and tries < 120 do
            task.wait(0.5)
            FindForge()
            tries = tries + 1
        end
    end
    
    if ForgeGui then
        SetupGameDetection()
        
        -- If any game is already visible (hot reload)
        if MeltMG and MeltMG.Visible then PlayMelt() end
        if PourMG and PourMG.Visible then PlayPour() end
        if HammerMG and HammerMG.Visible then PlayHammer() end
    else
        SetStatus("ERROR: Forge GUI no encontrado", Color3.fromRGB(255, 0, 0))
    end
end)

-- Cleanup on script removal
SG.Destroying:Connect(function()
    StopMelt()
    StopPour()
    StopHammer()
end)
