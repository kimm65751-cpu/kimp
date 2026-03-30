-- ==============================================================================
-- ⚔️ FORGE AUTOPLAYER v4.0 — REESCRITURA TOTAL
-- ==============================================================================
-- MELT:   getconnections para disparar callbacks reales del Heater
-- POUR:   VIM press/release (FUNCIONA, no tocar)
-- HAMMER: VIM click en el viewport 3D para romper + ChildAdded para círculos
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- ============ CONFIG ============
local POUR_THRESHOLD = 0.06
local CIRCLE_PERFECT_ZONE = 1.15
local CIRCLE_MIN_SIZE = 0.60

-- ============ UI ============
local CG = game:GetService("CoreGui")
local parentUI = pcall(function() return CG.Name end) and CG or PG
for _, v in pairs(parentUI:GetChildren()) do if v.Name == "AutoForgeUI" then v:Destroy() end end

local SG = Instance.new("ScreenGui"); SG.Name = "AutoForgeUI"; SG.ResetOnSpawn = false
SG.DisplayOrder = 1000; SG.Parent = parentUI

local SB = Instance.new("TextLabel")
SB.Size = UDim2.new(0,420,0,28); SB.Position = UDim2.new(0.5,-210,0,4)
SB.BackgroundColor3 = Color3.fromRGB(10,10,20); SB.BorderColor3 = Color3.fromRGB(50,200,100)
SB.BorderSizePixel = 2; SB.TextColor3 = Color3.fromRGB(150,255,150)
SB.TextSize = 11; SB.Font = Enum.Font.Code; SB.TextXAlignment = Enum.TextXAlignment.Left
SB.Text = " ⚔️ AUTO v4.0"; SB.Parent = SG

local function S(t,c) pcall(function() SB.Text = " ⚔️ "..t; SB.TextColor3 = c or Color3.fromRGB(150,255,150) end) end

-- ============ VIM ============
local mDown = false
local mX, mY = 0, 0

local function VPress(x,y) mX,mY=x,y; mDown=true; VIM:SendMouseButtonEvent(x,y,0,true,game,0) end
local function VRelease() mDown=false; VIM:SendMouseButtonEvent(mX,mY,0,false,game,0) end
local function VClick(x,y)
    VIM:SendMouseButtonEvent(x,y,0,true,game,0)
    task.wait(0.02)
    VIM:SendMouseButtonEvent(x,y,0,false,game,0)
end

local function Center(e)
    local p=e.AbsolutePosition; local s=e.AbsoluteSize
    return p.X+s.X/2, p.Y+s.Y/2
end

-- ============ FORGE GUI ============
local FG, Melt, Pour, Hammer

local function FindForge()
    FG = PG:FindFirstChild("Forge")
    if FG then
        Melt = FG:FindFirstChild("MeltMinigame")
        Pour = FG:FindFirstChild("PourMinigame")
        Hammer = FG:FindFirstChild("HammerMinigame")
        return true
    end
    return false
end

FindForge()
if not FG then PG.ChildAdded:Connect(function(c) if c.Name=="Forge" then task.wait(0.5); FindForge() end end) end

-- ================================================================
-- MELT — getconnections para disparar callbacks reales
-- ================================================================
local meltOn = false
local meltTh = nil

local function PlayMelt()
    if meltOn then return end
    meltOn = true
    
    meltTh = task.spawn(function()
        task.wait(0.8)
        
        local top = nil
        pcall(function() top = Melt.Heater.Top end)
        if not top then
            S("MELT — ERROR: no Heater.Top", Color3.fromRGB(255,0,0))
            meltOn = false; return
        end
        
        -- ===== MÉTODO: getconnections =====
        -- Disparar directamente las funciones conectadas al evento
        local conns = nil
        local hasGetConn = pcall(function() conns = getconnections(top.MouseButton1Down) end)
        
        if hasGetConn and conns and #conns > 0 then
            S(string.format("MELT — %d conexiones encontradas", #conns), Color3.fromRGB(0,255,100))
            
            while meltOn and Melt and Melt.Visible do
                -- Disparar TODAS las conexiones cada frame
                pcall(function()
                    for _, conn in pairs(getconnections(top.MouseButton1Down)) do
                        pcall(function() conn:Fire() end)
                    end
                end)
                
                local sz = 0
                pcall(function() sz = Melt.Bar.Area.Size.Y.Scale end)
                S(string.format("MELT — [getconn] Barra: %.0f%%", sz*100),
                    Color3.fromRGB(255, math.floor(200*math.min(sz,1)), 50))
                task.wait(0.08)
            end
            -- Fire MouseButton1Up connections to reset
            pcall(function()
                for _, conn in pairs(getconnections(top.MouseButton1Up)) do
                    pcall(function() conn:Fire() end)
                end
            end)
            meltOn = false; return
        end
        
        -- ===== FALLBACK: InputBegan on the button =====
        local ibConns = nil
        local hasIB = pcall(function() ibConns = getconnections(top.InputBegan) end)
        
        if hasIB and ibConns and #ibConns > 0 then
            S(string.format("MELT — %d InputBegan conns", #ibConns), Color3.fromRGB(0,255,100))
            
            while meltOn and Melt and Melt.Visible do
                pcall(function()
                    for _, conn in pairs(getconnections(top.InputBegan)) do
                        pcall(function()
                            conn:Fire({
                                UserInputType = Enum.UserInputType.MouseButton1,
                                UserInputState = Enum.UserInputState.Begin,
                                Position = Vector3.new(0,0,0)
                            })
                        end)
                    end
                end)
                
                local sz = 0
                pcall(function() sz = Melt.Bar.Area.Size.Y.Scale end)
                S(string.format("MELT — [InputBegan] Barra: %.0f%%", sz*100),
                    Color3.fromRGB(255, math.floor(200*math.min(sz,1)), 50))
                task.wait(0.08)
            end
            meltOn = false; return
        end
        
        -- ===== FALLBACK 2: Activated =====
        local actConns = nil
        local hasAct = pcall(function() actConns = getconnections(top.Activated) end)
        
        if hasAct and actConns and #actConns > 0 then
            S("MELT — Usando Activated", Color3.fromRGB(0,255,100))
            while meltOn and Melt and Melt.Visible do
                pcall(function()
                    for _, conn in pairs(getconnections(top.Activated)) do
                        pcall(function() conn:Fire() end)
                    end
                end)
                local sz = 0
                pcall(function() sz = Melt.Bar.Area.Size.Y.Scale end)
                S(string.format("MELT — [Activated] Barra: %.0f%%", sz*100),
                    Color3.fromRGB(255, math.floor(200*math.min(sz,1)), 50))
                task.wait(0.08)
            end
            meltOn = false; return
        end
        
        -- ===== ÚLTIMO INTENTO: VIM spam click en Heater =====
        S("MELT — Probando VIM spam...", Color3.fromRGB(255,200,0))
        while meltOn and Melt and Melt.Visible do
            local cx, cy = 200, 200
            pcall(function() cx, cy = Center(top) end)
            VClick(cx, cy)
            
            local sz = 0
            pcall(function() sz = Melt.Bar.Area.Size.Y.Scale end)
            S(string.format("MELT — [VIM] (%d,%d) Barra: %.0f%%", cx, cy, sz*100),
                Color3.fromRGB(255, math.floor(200*math.min(sz,1)), 50))
            task.wait(0.1)
        end
        
        meltOn = false
    end)
end

local function StopMelt()
    meltOn = false
    if meltTh then pcall(function() task.cancel(meltTh) end); meltTh = nil end
end

-- ================================================================
-- POUR — VIM press/release (FUNCIONA, no modificar)
-- ================================================================
local pourOn = false
local pourTh = nil

local function PlayPour()
    if pourOn then return end; pourOn = true
    S("POUR — Activo", Color3.fromRGB(100,200,255))
    
    local f, a, l
    pcall(function() f=Pour.Frame; a=f.Area; l=f.Line end)
    if not a or not l then S("POUR — ERROR",Color3.fromRGB(255,0,0)); pourOn=false; return end
    
    local sc = Vector2.new(500,300)
    pcall(function()
        local fp=f.AbsolutePosition; local fs=f.AbsoluteSize
        sc = Vector2.new(fp.X+fs.X/2, fp.Y+fs.Y/2)
    end)
    
    pourTh = task.spawn(function()
        while pourOn and Pour and Pour.Visible do
            local ay,ly = 0.5,0.5
            pcall(function() ay=a.Position.Y.Scale end)
            pcall(function() ly=l.Position.Y.Scale end)
            local ah=0.2; pcall(function() ah=a.Size.Y.Scale end)
            local ac = ay + ah/2
            local d = ly - ac
            if d > POUR_THRESHOLD then
                if not mDown then VPress(sc.X, sc.Y) end
            elseif d < -POUR_THRESHOLD then
                if mDown then VRelease() end
            end
            S(string.format("POUR — L:%.2f A:%.2f %s", ly, ac, mDown and "▲" or "▼"),
                Color3.fromRGB(100,200,255))
            task.wait()
        end
        VRelease(); pourOn = false
    end)
end

local function StopPour()
    pourOn = false; VRelease()
    if pourTh then pcall(function() task.cancel(pourTh) end); pourTh = nil end
end

-- ================================================================
-- HAMMER — DOS FASES:
-- Fase 3: ROMPER el arma (click 3D en viewport) 
-- Fase 4: CÍRCULOS (click en TextButton UI cuando Circle.Size ≈ 1.1)
-- ================================================================
local hammerOn = false
local hammerTh = nil
local circleConn = nil
local circlesN = 0
local inCirclePhase = false

local function HandleCircle(btn)
    task.spawn(function()
        if not btn or not btn.Parent then return end
        inCirclePhase = true
        
        local circle = nil
        for i = 1, 80 do
            for _, ch in pairs(btn:GetChildren()) do
                if ch.Name == "Circle" and ch:IsA("ImageLabel") then
                    circle = ch; break
                end
            end
            if circle then break end
            task.wait(0.02)
        end
        
        if not circle then
            pcall(function() local x,y = Center(btn); VClick(x,y) end)
            circlesN = circlesN + 1
            return
        end
        
        local clicked = false
        while not clicked and hammerOn do
            local exists = pcall(function() return circle.Parent and btn.Parent end)
            if not exists then break end
            
            local sz = 2.5
            pcall(function() sz = circle.Size.X.Scale end)
            
            if sz <= CIRCLE_PERFECT_ZONE and sz >= CIRCLE_MIN_SIZE then
                pcall(function()
                    local x,y = Center(btn)
                    VClick(x+math.random(-2,2), y+math.random(-2,2))
                end)
                clicked = true; circlesN = circlesN + 1
                S(string.format("CIRCLES — ✨ #%d (%.2f)", circlesN, sz), Color3.fromRGB(0,255,100))
            elseif sz < CIRCLE_MIN_SIZE and sz > 0.02 then
                pcall(function() local x,y = Center(btn); VClick(x,y) end)
                clicked = true; circlesN = circlesN + 1
                S(string.format("CIRCLES — ⚡ #%d (%.2f)", circlesN, sz), Color3.fromRGB(255,150,0))
            end
            if not clicked then task.wait() end
        end
    end)
end

local function PlayHammer()
    if hammerOn then return end
    hammerOn = true; circlesN = 0; inCirclePhase = false
    S("HAMMER — Rompiendo arma...", Color3.fromRGB(255,200,50))
    
    -- Escuchar círculos (Fase 4)
    circleConn = Hammer.ChildAdded:Connect(function(obj)
        if not hammerOn then return end
        if obj:IsA("TextButton") then
            task.wait(0.08)
            HandleCircle(obj)
        end
    end)
    for _, ch in pairs(Hammer:GetChildren()) do
        if ch:IsA("TextButton") then HandleCircle(ch) end
    end
    
    -- Fase 3: GOLPEAR el arma en el viewport 3D
    -- El arma es un modelo 3D, necesitamos click en su posición en pantalla
    -- Usamos el CENTRO del viewport como punto de click + variación
    hammerTh = task.spawn(function()
        local vpX = Camera.ViewportSize.X
        local vpY = Camera.ViewportSize.Y
        
        while hammerOn and Hammer and Hammer.Visible do
            if not inCirclePhase then
                -- Click en zona central del viewport donde está el arma
                -- Variar posición para cubrir el área del arma
                local cx = vpX/2 + math.random(-80, 80)
                local cy = vpY/2 + math.random(-40, 40)
                VClick(cx, cy)
                
                S(string.format("HAMMER — Golpeando (%d,%d) vp=%dx%d", 
                    cx, cy, vpX, vpY), Color3.fromRGB(255,200,50))
                task.wait(0.12)
            else
                S(string.format("CIRCLES — %d hechos", circlesN), Color3.fromRGB(200,150,255))
                task.wait(0.2)
            end
        end
        hammerOn = false
    end)
end

local function StopHammer()
    hammerOn = false; inCirclePhase = false
    if hammerTh then pcall(function() task.cancel(hammerTh) end); hammerTh = nil end
    if circleConn then circleConn:Disconnect(); circleConn = nil end
end

-- ============ DETECTION ============
local function Setup()
    if not FG then return end
    if Melt then
        Melt:GetPropertyChangedSignal("Visible"):Connect(function()
            if Melt.Visible then task.wait(2.0); PlayMelt()
            else StopMelt(); S("MELT ✅",Color3.fromRGB(0,255,100)) end
        end)
    end
    if Pour then
        Pour:GetPropertyChangedSignal("Visible"):Connect(function()
            if Pour.Visible then task.wait(2.0); PlayPour()
            else StopPour(); S("POUR ✅",Color3.fromRGB(0,255,100)) end
        end)
    end
    if Hammer then
        Hammer:GetPropertyChangedSignal("Visible"):Connect(function()
            if Hammer.Visible then task.wait(2.0); PlayHammer()
            else StopHammer(); S(string.format("HAMMER ✅ (%d)",circlesN),Color3.fromRGB(0,255,100)) end
        end)
    end
    S("v4.0 LISTO ⚒️", Color3.fromRGB(150,255,150))
end

task.spawn(function()
    if not FG then
        S("Esperando Forge...",Color3.fromRGB(255,200,50))
        for i=1,120 do task.wait(0.5); if FindForge() then break end end
    end
    if FG then
        Setup()
        if Melt and Melt.Visible then task.wait(0.5); PlayMelt() end
        if Pour and Pour.Visible then task.wait(0.5); PlayPour() end
        if Hammer and Hammer.Visible then task.wait(0.5); PlayHammer() end
    else S("ERROR: no Forge",Color3.fromRGB(255,0,0)) end
end)

SG.Destroying:Connect(function() StopMelt(); StopPour(); StopHammer() end)
