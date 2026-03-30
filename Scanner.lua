-- ==============================================================================
-- ⚔️ FORGE AUTOPLAYER v5.1 — ZERO HOOKS (sin hookmetamethod)
-- ==============================================================================
-- Detecta las fases por UI (Visible) y llama InvokeServer directamente.
-- NO usa hookmetamethod, hookfunction, ni ningún hook.
-- Solo observa + llama remotes cuando detecta la fase.
-- ==============================================================================

local SCRIPT_VERSION = "V5.1 — ZERO HOOKS"

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

-- ============ UI ============
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or PG
for _, v in pairs(parentUI:GetChildren()) do if v.Name == "AutoForgeUI" then v:Destroy() end end

local SG = Instance.new("ScreenGui"); SG.Name = "AutoForgeUI"; SG.ResetOnSpawn = false
SG.DisplayOrder = 1000; SG.Parent = parentUI

local SB = Instance.new("TextLabel")
SB.Size = UDim2.new(0,420,0,28); SB.Position = UDim2.new(0.5,-210,0,4)
SB.BackgroundColor3 = Color3.fromRGB(10,10,20); SB.BorderColor3 = Color3.fromRGB(50,200,100)
SB.BorderSizePixel = 2; SB.TextColor3 = Color3.fromRGB(150,255,150)
SB.TextSize = 11; SB.Font = Enum.Font.Code; SB.TextXAlignment = Enum.TextXAlignment.Left
SB.Text = " ⚔️ FORGE v5.1 ZERO HOOKS"; SB.Parent = SG

local function S(t,c) pcall(function() SB.Text = " ⚔️ "..t; SB.TextColor3 = c or Color3.fromRGB(150,255,150) end) end

-- ============ FIND REMOTES ============
-- ChangeSequence RemoteFunction (para avanzar fases)
local changeSeqRF = nil
pcall(function()
    changeSeqRF = RS.Knit.Services.ForgeService.RF.ChangeSequence
end)
if not changeSeqRF then
    -- Buscar por nombre
    pcall(function()
        for _, v in pairs(RS:GetDescendants()) do
            if v.Name == "ChangeSequence" and v:IsA("RemoteFunction") then
                changeSeqRF = v
                break
            end
        end
    end)
end

-- HammerMinigame RemoteFunction (para enviar Perfects)
local hammerRF = nil
pcall(function()
    hammerRF = RS.Controllers.ForgeController.HammerMinigame.RemoteFunction
end)
if not hammerRF then
    pcall(function()
        for _, v in pairs(RS:GetDescendants()) do
            if v:IsA("RemoteFunction") and string.find(v:GetFullName(), "HammerMinigame") then
                hammerRF = v
                break
            end
        end
    end)
end

S(string.format("Remotes: CS=%s HM=%s", 
    changeSeqRF and "✅" or "❌", 
    hammerRF and "✅" or "❌"), Color3.fromRGB(200,200,255))

-- ============ CONFIG ============
local WAIT_AFTER_VISIBLE = 3.5  -- Esperar countdown 3,2,1,GO + margen

-- ============ KNIT CONTROLLER ============
local ForgeController = nil
pcall(function()
    local Knit = require(RS:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"))
    ForgeController = Knit.GetController("ForgeController")
end)

-- ============ SKIP FUNCTION ============
local function SkipToPhase(phaseName)
    if not changeSeqRF then
        S("ERROR: No ChangeSequence RF", Color3.fromRGB(255,0,0))
        return false, nil
    end
    
    S(string.format("→ InvokeServer('%s')...", phaseName), Color3.fromRGB(255,255,0))
    
    local ok, result = pcall(function()
        return changeSeqRF:InvokeServer(phaseName, {ClientTime = workspace:GetServerTimeNow()})
    end)
    
    if ok then
        S(string.format("✅ '%s' aceptado por servidor", phaseName), Color3.fromRGB(0,255,100))
        -- Decirle al controller local que cambie la secuencia
        if ForgeController and result then
            pcall(function() ForgeController:ChangeSequence(phaseName, result) end)
        end
    else
        S(string.format("❌ '%s' rechazado: %s", phaseName, tostring(result)), Color3.fromRGB(255,0,0))
    end
    
    return ok, result
end

-- ============ SPAM HAMMER PERFECTS ============
local function SpamHammerPerfects(count)
    if not hammerRF then
        S("HAMMER — No RemoteFunction, skip", Color3.fromRGB(255,150,0))
        return
    end
    
    S(string.format("HAMMER — Enviando %d Perfects...", count), Color3.fromRGB(150,0,255))
    for i = 1, count do
        pcall(function() hammerRF:InvokeServer({Name = "Perfect"}) end)
        S(string.format("HAMMER — Perfect %d/%d", i, count), Color3.fromRGB(150,0,255))
        task.wait(0.05)
    end
    S(string.format("HAMMER — %d Perfects enviados ✅", count), Color3.fromRGB(0,255,100))
end

-- ============ RESTORE MOVEMENT ============
local function RestoreMovement()
    pcall(function()
        local Knit = require(RS:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"))
        local fc = Knit.GetController("ForgeController")
        if fc then fc.ForgeActive = false end
        
        local cc = Knit.GetController("CharacterController")
        if cc then
            cc.WalkSpeed = 16
            if cc.SetWalkSpeed then cc:SetWalkSpeed(16) end
        end
    end)
    
    -- Fallback: forzar Humanoid
    pcall(function()
        LP.Character.Humanoid.WalkSpeed = 16
    end)
    
    S("✅ Movimiento restaurado!", Color3.fromRGB(0,255,100))
end

-- ============ MAIN: DETECTAR FASES POR UI ============
local ForgeGui = nil
local MeltMG, PourMG, HammerMG = nil, nil, nil
local forgeRunning = false

local function OnForgeDetected()
    if forgeRunning then return end
    forgeRunning = true
    
    task.spawn(function()
        -- FASE 1: MELT detectado → esperar countdown → saltar a Pour
        S("FASE 1: MELT — Countdown...", Color3.fromRGB(255,200,50))
        task.wait(WAIT_AFTER_VISIBLE)
        
        local ok1, _ = SkipToPhase("Pour")
        if not ok1 then forgeRunning = false; return end
        
        -- Esperar que PourMinigame sea visible
        S("Esperando POUR UI...", Color3.fromRGB(100,200,255))
        local pourWait = 0
        while pourWait < 30 do
            if PourMG and PourMG.Visible then break end
            task.wait(0.1)
            pourWait = pourWait + 0.1
        end
        
        -- FASE 2: POUR → esperar countdown → saltar a Hammer
        S("FASE 2: POUR — Countdown...", Color3.fromRGB(100,200,255))
        task.wait(WAIT_AFTER_VISIBLE)
        
        local ok2, _ = SkipToPhase("Hammer")
        if not ok2 then forgeRunning = false; return end
        
        -- Esperar que HammerMinigame sea visible
        S("Esperando HAMMER UI...", Color3.fromRGB(255,200,50))
        local hammerWait = 0
        while hammerWait < 30 do
            if HammerMG and HammerMG.Visible then break end
            task.wait(0.1)
            hammerWait = hammerWait + 0.1
        end
        
        -- FASE 3: HAMMER → esperar countdown → spam Perfects
        S("FASE 3: HAMMER — Countdown...", Color3.fromRGB(255,200,50))
        task.wait(WAIT_AFTER_VISIBLE)
        
        SpamHammerPerfects(25)
        task.wait(0.5)
        
        -- FASE 4: WATER
        local ok3, _ = SkipToPhase("Water")
        if ok3 then
            S("FASE 4: WATER — Animación corriendo...", Color3.fromRGB(100,200,255))
            -- Water es auto, esperar
            task.wait(5)
        end
        
        -- Restaurar movimiento
        task.wait(2)
        RestoreMovement()
        forgeRunning = false
    end)
end

-- ============ SETUP DETECTION ============
local function SetupDetection()
    ForgeGui = PG:FindFirstChild("Forge")
    if ForgeGui then
        MeltMG = ForgeGui:FindFirstChild("MeltMinigame")
        PourMG = ForgeGui:FindFirstChild("PourMinigame")
        HammerMG = ForgeGui:FindFirstChild("HammerMinigame")
    end
    
    if not ForgeGui then
        S("Esperando Forge GUI...", Color3.fromRGB(255,200,50))
        PG.ChildAdded:Connect(function(c)
            if c.Name == "Forge" then
                task.wait(0.5)
                ForgeGui = c
                MeltMG = c:FindFirstChild("MeltMinigame")
                PourMG = c:FindFirstChild("PourMinigame")
                HammerMG = c:FindFirstChild("HammerMinigame")
                SetupMinigameListeners()
            end
        end)
        return
    end
    
    SetupMinigameListeners()
end

function SetupMinigameListeners()
    if MeltMG then
        MeltMG:GetPropertyChangedSignal("Visible"):Connect(function()
            if MeltMG.Visible and not forgeRunning then
                OnForgeDetected()
            end
        end)
    end
    
    -- Si ya es visible (hot reload)
    if MeltMG and MeltMG.Visible and not forgeRunning then
        OnForgeDetected()
    end
    
    S("v5.1 LISTO — Ve a la forja ⚒️", Color3.fromRGB(150,255,150))
end

SetupDetection()

-- Cleanup
SG.Destroying:Connect(function()
    forgeRunning = false
end)
