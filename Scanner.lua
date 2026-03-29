-- ==============================================================================
-- ⚔️ FORGE AUTOPLAYER v3.0 — CORREGIDO POR DATOS REALES
-- ==============================================================================
-- MELT:    ¡MANTENER PRESIONADO! No soltar nunca. Hold continuo.
-- POUR:    mouse press/release adaptativo (YA FUNCIONA)
-- HAMMER:  Los círculos SON los golpes. Click en cada TextButton.
--          No hay fase "romper" separada — todo son círculos.
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============ CONFIG ============
local POUR_THRESHOLD = 0.06
local CIRCLE_PERFECT_ZONE = 1.15
local CIRCLE_MIN_SIZE = 0.60

-- ============ UI ============
local CoreGui = game:GetService("CoreGui")
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or PlayerGui
for _, v in pairs(parentUI:GetChildren()) do if v.Name == "AutoForgeUI" then v:Destroy() end end

local SG = Instance.new("ScreenGui")
SG.Name = "AutoForgeUI"
SG.ResetOnSpawn = false
SG.DisplayOrder = 1000
SG.Parent = parentUI

local StatusBar = Instance.new("TextLabel")
StatusBar.Size = UDim2.new(0, 400, 0, 28)
StatusBar.Position = UDim2.new(0.5, -200, 0, 4)
StatusBar.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
StatusBar.BorderColor3 = Color3.fromRGB(50, 200, 100)
StatusBar.BorderSizePixel = 2
StatusBar.Text = " ⚔️ FORGE AUTO v3.0"
StatusBar.TextColor3 = Color3.fromRGB(150, 255, 150)
StatusBar.TextSize = 11
StatusBar.Font = Enum.Font.Code
StatusBar.TextXAlignment = Enum.TextXAlignment.Left
StatusBar.Parent = SG

local function SetStatus(t, c)
    pcall(function() StatusBar.Text = " ⚔️ " .. t; StatusBar.TextColor3 = c or Color3.fromRGB(150,255,150) end)
end

-- ============ VIM HELPERS ============
local mouseIsDown = false
local lastMX, lastMY = 0, 0

-- GuiInset: la diferencia entre AbsolutePosition y VIM coordinates
local GuiInset = Vector2.new(0, 0)
pcall(function()
    GuiInset = game:GetService("GuiService"):GetGuiInset()
end)

local function VIMPress(x, y)
    -- Corregir por GuiInset (AbsolutePosition incluye inset, VIM puede que no)
    lastMX, lastMY = x, y
    mouseIsDown = true
    VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
end

local function VIMRelease()
    mouseIsDown = false
    VIM:SendMouseButtonEvent(lastMX, lastMY, 0, false, game, 0)
end

local function VIMClick(x, y)
    VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(0.02)
    VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

local function ElemCenter(el)
    local p = el.AbsolutePosition
    local s = el.AbsoluteSize
    return p.X + s.X/2, p.Y + s.Y/2
end

-- ============ FIND FORGE ============
local ForgeGui, MeltMG, PourMG, HammerMG

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

-- ================================================================
-- FASE 1: MELT — MANTENER PRESIONADO sobre Heater
-- La barra sube mientras mantienes presionado. Baja si sueltas.
-- Probamos: firesignal → executor mouse → VIM
-- ================================================================
local meltActive = false
local meltThread = nil

local function PlayMelt()
    if meltActive then return end
    meltActive = true
    
    meltThread = task.spawn(function()
        task.wait(0.5) -- Esperar que el Heater se posicione
        
        local heaterTop = nil
        pcall(function() heaterTop = MeltMG.Heater.Top end)
        if not heaterTop then pcall(function() heaterTop = MeltMG.Heater end) end
        if not heaterTop then
            SetStatus("MELT — ERROR: Heater nil", Color3.fromRGB(255, 0, 0))
            meltActive = false
            return
        end
        
        -- Leer posición real del Heater.Top
        local cx, cy = 0, 0
        pcall(function() cx, cy = ElemCenter(heaterTop) end)
        SetStatus(string.format("MELT — Heater en (%d,%d)", cx, cy), Color3.fromRGB(255, 200, 0))
        task.wait(0.3)
        
        -- ===== MÉTODO A: firesignal en MouseButton1Down =====
        local methodUsed = "none"
        
        -- Intentar firesignal (no requiere coordenadas correctas)
        local fireOK = pcall(function()
            firesignal(heaterTop.MouseButton1Down)
        end)
        
        if fireOK then
            -- Verificar si funcionó: esperar 0.5s y ver si la barra empezó a subir
            task.wait(0.5)
            local testSize = 0
            pcall(function() testSize = MeltMG.Bar.Area.Size.Y.Scale end)
            
            if testSize > 0.01 then
                methodUsed = "firesignal"
                SetStatus("MELT — firesignal OK ✅", Color3.fromRGB(0, 255, 100))
            else
                -- firesignal se ejecutó pero no tuvo efecto real
                -- Intentar fireUp para resetear estado
                pcall(function() firesignal(heaterTop.MouseButton1Up) end)
            end
        end
        
        -- ===== MÉTODO B: Executor mouse (mousemoveabs + mouse1press) =====
        if methodUsed == "none" then
            local execOK = pcall(function()
                mousemoveabs(cx, cy)
                mouse1press()
            end)
            
            if execOK then
                task.wait(0.5)
                local testSize = 0
                pcall(function() testSize = MeltMG.Bar.Area.Size.Y.Scale end)
                
                if testSize > 0.01 then
                    methodUsed = "execmouse"
                    SetStatus(string.format("MELT — ExecMouse OK en (%d,%d)", cx, cy), Color3.fromRGB(0, 255, 100))
                else
                    pcall(function() mouse1release() end)
                    -- Probar con GuiInset correction
                    pcall(function()
                        mousemoveabs(cx - GuiInset.X, cy - GuiInset.Y)
                        mouse1press()
                    end)
                    task.wait(0.5)
                    pcall(function() testSize = MeltMG.Bar.Area.Size.Y.Scale end)
                    if testSize > 0.01 then
                        methodUsed = "execmouse_inset"
                        cx, cy = cx - GuiInset.X, cy - GuiInset.Y
                        SetStatus(string.format("MELT — ExecMouse+Inset (%d,%d)", cx, cy), Color3.fromRGB(0, 255, 100))
                    else
                        pcall(function() mouse1release() end)
                    end
                end
            end
        end
        
        -- ===== MÉTODO C: VIM en varias posiciones =====
        if methodUsed == "none" then
            -- Probar VIM en la posición del heater
            VIMPress(cx, cy)
            task.wait(0.5)
            local testSize = 0
            pcall(function() testSize = MeltMG.Bar.Area.Size.Y.Scale end)
            
            if testSize > 0.01 then
                methodUsed = "vim_raw"
            else
                VIMRelease()
                -- Probar con corrección GuiInset
                VIMPress(cx - GuiInset.X, cy - GuiInset.Y)
                task.wait(0.5)
                pcall(function() testSize = MeltMG.Bar.Area.Size.Y.Scale end)
                if testSize > 0.01 then
                    methodUsed = "vim_inset"
                    cx, cy = cx - GuiInset.X, cy - GuiInset.Y
                else
                    VIMRelease()
                    -- Probar con GuiInset SUMADO (dirección opuesta)
                    VIMPress(cx + GuiInset.X, cy + GuiInset.Y)
                    task.wait(0.5)
                    pcall(function() testSize = MeltMG.Bar.Area.Size.Y.Scale end)
                    if testSize > 0.01 then
                        methodUsed = "vim_inset_add"
                        cx, cy = cx + GuiInset.X, cy + GuiInset.Y
                    else
                        VIMRelease()
                    end
                end
            end
        end
        
        -- ===== RESULTADO =====
        if methodUsed == "none" then
            SetStatus(string.format("MELT — NINGÚN MÉTODO FUNCIONÓ pos=(%d,%d) inset=(%d,%d)", 
                cx, cy, GuiInset.X, GuiInset.Y), Color3.fromRGB(255, 0, 0))
            meltActive = false
            return
        end
        
        -- MANTENER PRESIONADO: loop de monitoreo
        SetStatus(string.format("MELT — [%s] HOLD activo", methodUsed), Color3.fromRGB(100, 255, 100))
        
        while meltActive and MeltMG and MeltMG.Visible do
            -- Si es firesignal, re-disparar periódicamente por si se pierde
            if methodUsed == "firesignal" then
                pcall(function() firesignal(heaterTop.MouseButton1Down) end)
            end
            
            local areaSize = 0
            pcall(function() areaSize = MeltMG.Bar.Area.Size.Y.Scale end)
            SetStatus(string.format("MELT — [%s] Barra: %.0f%%", methodUsed, areaSize * 100),
                Color3.fromRGB(255, math.floor(200 * math.min(areaSize, 1)), 50))
            task.wait(0.15)
        end
        
        -- Cleanup según método
        if methodUsed == "firesignal" then
            pcall(function() firesignal(heaterTop.MouseButton1Up) end)
        elseif methodUsed:find("exec") then
            pcall(function() mouse1release() end)
        else
            VIMRelease()
        end
        
        meltActive = false
    end)
end

local function StopMelt()
    meltActive = false
    VIMRelease()
    if meltThread then pcall(function() task.cancel(meltThread) end); meltThread = nil end
end

-- ================================================================
-- FASE 2: POUR — Seguir zona amarilla (YA FUNCIONA EN v1)
-- ================================================================
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
    
    local screenCenter = Vector2.new(500, 300)
    pcall(function()
        local fp = frame.AbsolutePosition
        local fs = frame.AbsoluteSize
        screenCenter = Vector2.new(fp.X + fs.X/2, fp.Y + fs.Y/2)
    end)
    
    pourThread = task.spawn(function()
        while pourActive and PourMG and PourMG.Visible do
            local areaY, lineY = 0.5, 0.5
            pcall(function() areaY = area.Position.Y.Scale end)
            pcall(function() lineY = line.Position.Y.Scale end)
            
            local areaHeight = 0.200
            pcall(function() areaHeight = area.Size.Y.Scale end)
            local areaCenter = areaY + areaHeight / 2
            local diff = lineY - areaCenter
            
            if diff > POUR_THRESHOLD then
                if not mouseIsDown then VIMPress(screenCenter.X, screenCenter.Y) end
            elseif diff < -POUR_THRESHOLD then
                if mouseIsDown then VIMRelease() end
            end
            
            SetStatus(string.format("POUR — L:%.2f A:%.2f %s",
                lineY, areaCenter, mouseIsDown and "▲HOLD" or "▼FREE"),
                Color3.fromRGB(100, 200, 255))
            
            task.wait()
        end
        VIMRelease()
        pourActive = false
    end)
end

local function StopPour()
    pourActive = false
    VIMRelease()
    if pourThread then pcall(function() task.cancel(pourThread) end); pourThread = nil end
end

-- ================================================================
-- FASE 3+4: HAMMER + CIRCLES
-- Los círculos (TextButton) aparecen como hijos DIRECTOS de HammerMinigame
-- Cada uno tiene Position.Offset = posición random sobre el arma
-- Circle.Size empieza en 2.5 y se encoge a 0
-- Click cuando Circle.Size ≈ 1.1 para "Perfect"
-- ================================================================
local hammerActive = false
local hammerThread = nil
local circleConn = nil
local circlesHandled = 0

local function HandleCircle(btn)
    task.spawn(function()
        if not btn or not btn.Parent then return end
        
        -- Esperar que Circle hijo aparezca
        local circle = nil
        for i = 1, 60 do
            for _, ch in pairs(btn:GetChildren()) do
                if ch.Name == "Circle" and ch:IsA("ImageLabel") then
                    circle = ch
                    break
                end
            end
            if circle then break end
            task.wait(0.03)
        end
        
        if not circle then
            -- Sin Circle, click directo como fallback
            pcall(function()
                local bx, by = ElemCenter(btn)
                VIMClick(bx, by)
                circlesHandled = circlesHandled + 1
            end)
            return
        end
        
        -- Monitorear Circle.Size y clickear en zona perfecta
        local clicked = false
        while not clicked and hammerActive do
            local exists = pcall(function() return circle.Parent and btn.Parent end)
            if not exists then break end
            
            local sz = 2.5
            pcall(function() sz = circle.Size.X.Scale end)
            
            if sz <= CIRCLE_PERFECT_ZONE and sz >= CIRCLE_MIN_SIZE then
                -- ¡ZONA PERFECTA!
                pcall(function()
                    local bx, by = ElemCenter(btn)
                    VIMClick(bx + math.random(-2,2), by + math.random(-2,2))
                end)
                clicked = true
                circlesHandled = circlesHandled + 1
                SetStatus(string.format("CIRCLES — ✨ Perfect #%d (%.2f)", circlesHandled, sz),
                    Color3.fromRGB(0, 255, 100))
                    
            elseif sz < CIRCLE_MIN_SIZE and sz > 0.02 then
                -- Late click
                pcall(function()
                    local bx, by = ElemCenter(btn)
                    VIMClick(bx, by)
                end)
                clicked = true
                circlesHandled = circlesHandled + 1
                SetStatus(string.format("CIRCLES — ⚡ Late #%d (%.2f)", circlesHandled, sz),
                    Color3.fromRGB(255, 150, 0))
            end
            
            if not clicked then task.wait() end
        end
    end)
end

local function PlayHammer()
    if hammerActive then return end
    hammerActive = true
    circlesHandled = 0
    SetStatus("HAMMER — Esperando círculos...", Color3.fromRGB(255, 200, 50))
    
    -- Escuchar nuevos TextButtons (son hijos DIRECTOS de HammerMinigame)
    circleConn = HammerMG.ChildAdded:Connect(function(obj)
        if not hammerActive then return end
        if obj:IsA("TextButton") then
            task.wait(0.08) -- Esperar que Circle/Border/Frame spawnen como hijos
            HandleCircle(obj)
        end
    end)
    
    -- Check existing
    for _, child in pairs(HammerMG:GetChildren()) do
        if child:IsA("TextButton") then
            HandleCircle(child)
        end
    end
    
    -- Thread para actualizar status
    hammerThread = task.spawn(function()
        while hammerActive and HammerMG and HammerMG.Visible do
            if circlesHandled == 0 then
                SetStatus("HAMMER — Esperando círculos...", Color3.fromRGB(255, 200, 50))
            else
                SetStatus(string.format("HAMMER — %d círculos hechos", circlesHandled),
                    Color3.fromRGB(200, 255, 100))
            end
            task.wait(0.3)
        end
        hammerActive = false
    end)
end

local function StopHammer()
    hammerActive = false
    if hammerThread then pcall(function() task.cancel(hammerThread) end); hammerThread = nil end
    if circleConn then circleConn:Disconnect(); circleConn = nil end
end

-- ============ GAME DETECTION ============
local function SetupGameDetection()
    if not ForgeGui then return end
    
    if MeltMG then
        MeltMG:GetPropertyChangedSignal("Visible"):Connect(function()
            if MeltMG.Visible then
                task.wait(2.0) -- Countdown 3,2,1,GO + entrada animación
                PlayMelt()
            else
                StopMelt()
                SetStatus("MELT ✅", Color3.fromRGB(0, 255, 100))
            end
        end)
    end
    
    if PourMG then
        PourMG:GetPropertyChangedSignal("Visible"):Connect(function()
            if PourMG.Visible then
                task.wait(2.0)
                PlayPour()
            else
                StopPour()
                SetStatus("POUR ✅", Color3.fromRGB(0, 255, 100))
            end
        end)
    end
    
    if HammerMG then
        HammerMG:GetPropertyChangedSignal("Visible"):Connect(function()
            if HammerMG.Visible then
                task.wait(2.0)
                PlayHammer()
            else
                StopHammer()
                SetStatus(string.format("HAMMER ✅ (%d círculos)", circlesHandled),
                    Color3.fromRGB(0, 255, 100))
            end
        end)
    end
    
    SetStatus("v3.1 LISTO — Inicia la forja ⚒️", Color3.fromRGB(150, 255, 150))
end

-- ============ INIT ============
task.spawn(function()
    if not ForgeGui then
        SetStatus("Esperando Forge...", Color3.fromRGB(255, 200, 50))
        local t = 0
        while not ForgeGui and t < 120 do task.wait(0.5); FindForge(); t = t + 1 end
    end
    if ForgeGui then
        SetupGameDetection()
        if MeltMG and MeltMG.Visible then task.wait(0.5); PlayMelt() end
        if PourMG and PourMG.Visible then task.wait(0.5); PlayPour() end
        if HammerMG and HammerMG.Visible then task.wait(0.5); PlayHammer() end
    else
        SetStatus("ERROR: Forge no encontrado", Color3.fromRGB(255, 0, 0))
    end
end)

SG.Destroying:Connect(function() StopMelt(); StopPour(); StopHammer() end)
