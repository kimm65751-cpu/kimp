-- ==============================================================================
-- ⚔️ FORGE AUTOPLAYER v5.0 — BASADO EN V8.18 QUE FUNCIONABA
-- ==============================================================================
-- El V8.18 pasaba los juegos usando InvokeServer para saltar cada fase.
-- El problema era que OCULTABA la UI y dejaba pegado al jugador.
-- 
-- v5.0: Usa el MISMO método pero SIN OCULTAR nada:
-- 1. Intercepta ChangeSequence("Melt") via __namecall
-- 2. Deja que la UI del minijuego se muestre normalmente
-- 3. Espera el tiempo necesario (tras countdown 3,2,1,GO)
-- 4. InvokeServer() para avanzar a la siguiente fase
-- 5. Para Hammer: spammea RemoteFunction con "Perfect" × 25
-- 6. Al llegar a Water, suelta el control
-- 7. En Close: restaura ForgeActive + WalkSpeed
-- ==============================================================================

local SCRIPT_VERSION = "V5.0 — VISIBLE SKIP"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ============ UI ============
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in pairs(parentUI:GetChildren()) do if v.Name == "AutoForgeUI" then v:Destroy() end end

local SG = Instance.new("ScreenGui"); SG.Name = "AutoForgeUI"; SG.ResetOnSpawn = false
SG.DisplayOrder = 1000; SG.Parent = parentUI

local SB = Instance.new("TextLabel")
SB.Size = UDim2.new(0,420,0,28); SB.Position = UDim2.new(0.5,-210,0,4)
SB.BackgroundColor3 = Color3.fromRGB(10,10,20); SB.BorderColor3 = Color3.fromRGB(50,200,100)
SB.BorderSizePixel = 2; SB.TextColor3 = Color3.fromRGB(150,255,150)
SB.TextSize = 11; SB.Font = Enum.Font.Code; SB.TextXAlignment = Enum.TextXAlignment.Left
SB.Text = " ⚔️ FORGE v5.0 | Activar y ve a la forja"; SB.Parent = SG

local function S(t,c) pcall(function() SB.Text = " ⚔️ "..t; SB.TextColor3 = c or Color3.fromRGB(150,255,150) end) end

-- ============ STATE ============
local BotActivo = true
local BotBypassingNetwork = false
local RondaActiva = false
local WAIT_TIME = 3.0  -- Tiempo a esperar tras cada fase (countdown + margen)

-- ============ SAFE INVOKE ============
local function SafeInvoke(forgeRF, phase)
    BotBypassingNetwork = true
    local ok, result = pcall(function()
        return forgeRF:InvokeServer(phase, {ClientTime = workspace:GetServerTimeNow()})
    end)
    BotBypassingNetwork = false
    if ok then
        S(string.format("✅ InvokeServer('%s') OK", phase), Color3.fromRGB(0,255,100))
    else
        S(string.format("❌ InvokeServer('%s') FAIL", phase), Color3.fromRGB(255,0,0))
    end
    return ok, result
end

-- ============ MAIN FORGE SEQUENCE ============
local function RunForgeAssist(forgeRF, initialMeltData)
    task.spawn(function()
        local Knit = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"))
        local ForgeController = Knit.GetController("ForgeController")
        
        -- ========== FASE 1: MELT ==========
        S("FASE 1: MELT — Esperando countdown...", Color3.fromRGB(255,200,50))
        
        -- Esperar que aparezca el minijuego (SIN OCULTAR)
        local meltFound = false
        for i = 1, 100 do
            for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                if string.find(string.lower(v.Name), "melt") and string.find(string.lower(v.Name), "minigame") then
                    if (v:IsA("GuiObject") and v.Visible) or (v:IsA("ScreenGui") and v.Enabled) then
                        meltFound = true
                        break
                    end
                end
            end
            if meltFound then break end
            task.wait(0.05)
        end
        
        -- Esperar que pase el countdown (visible para el jugador)
        S("MELT — Countdown corriendo... (visible)", Color3.fromRGB(255,200,50))
        task.wait(WAIT_TIME)
        
        -- ===== SALTAR A POUR =====
        local s1, pourData = SafeInvoke(forgeRF, "Pour")
        if s1 and pourData then
            S("→ Avanzando a POUR", Color3.fromRGB(0,255,100))
            pcall(function() ForgeController:ChangeSequence("Pour", pourData) end)
            
            -- ========== FASE 2: POUR ==========
            S("FASE 2: POUR — Esperando countdown...", Color3.fromRGB(100,200,255))
            
            -- Esperar que aparezca
            local pourFound = false
            for i = 1, 100 do
                for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                    if string.find(string.lower(v.Name), "pour") and string.find(string.lower(v.Name), "minigame") then
                        if (v:IsA("GuiObject") and v.Visible) or (v:IsA("ScreenGui") and v.Enabled) then
                            pourFound = true
                            break
                        end
                    end
                end
                if pourFound then break end
                task.wait(0.05)
            end
            
            S("POUR — Countdown corriendo... (visible)", Color3.fromRGB(100,200,255))
            task.wait(WAIT_TIME)
            
            -- ===== SALTAR A HAMMER =====
            local s2, hammerData = SafeInvoke(forgeRF, "Hammer")
            if s2 and hammerData then
                S("→ Avanzando a HAMMER", Color3.fromRGB(0,255,100))
                pcall(function() ForgeController:ChangeSequence("Hammer", hammerData) end)
                
                -- ========== FASE 3: HAMMER (Perfects por red) ==========
                S("FASE 3: HAMMER — Esperando countdown...", Color3.fromRGB(255,200,50))
                
                local hammerFound = false
                for i = 1, 100 do
                    for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                        if string.find(string.lower(v.Name), "hammer") and string.find(string.lower(v.Name), "minigame") then
                            if (v:IsA("GuiObject") and v.Visible) or (v:IsA("ScreenGui") and v.Enabled) then
                                hammerFound = true
                                break
                            end
                        end
                    end
                    if hammerFound then break end
                    task.wait(0.05)
                end
                
                task.wait(WAIT_TIME)
                
                -- SPAM PERFECTS por RemoteFunction
                local hammerRF = nil
                pcall(function()
                    hammerRF = ReplicatedStorage.Controllers.ForgeController.HammerMinigame.RemoteFunction
                end)
                
                if hammerRF then
                    S("HAMMER — Spammeando 25 Perfects...", Color3.fromRGB(150,0,255))
                    for i = 1, 25 do
                        pcall(function() hammerRF:InvokeServer({Name = "Perfect"}) end)
                        task.wait(0.05)
                    end
                    S("HAMMER — 25 Perfects enviados ✅", Color3.fromRGB(0,255,100))
                else
                    S("HAMMER — RemoteFunction no encontrado, esperando...", Color3.fromRGB(255,150,0))
                    task.wait(3)
                end
                
                -- ========== FASE 4: WATER ==========
                local s3, waterData = SafeInvoke(forgeRF, "Water")
                if s3 and waterData then
                    S("→ Avanzando a WATER", Color3.fromRGB(0,255,100))
                    pcall(function() ForgeController:ChangeSequence("Water", waterData) end)
                    S("WATER — Animación corriendo (natural)", Color3.fromRGB(100,200,255))
                    -- Water es automático, solo esperar
                end
            end
        end
        
        S("✅ Forja completa — esperando Close", Color3.fromRGB(0,255,100))
    end)
end

-- ============ HOOKMETAMETHOD ============
-- Interceptar ChangeSequence para iniciar el bot
-- PERO no ocultar nada — todo visible
local OriginalNamecall
OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and method == "InvokeServer" then
        local fullName = ""
        pcall(function() fullName = self:GetFullName() end)
        
        if string.find(string.lower(fullName), "changesequence") then
            local phaseName = tostring(args[1])
            
            -- Cuando el juego envía "Melt" = inicio de la forja
            if phaseName == "Melt" and BotActivo then
                local RetTuple = {OriginalNamecall(self, ...)}
                
                if not RondaActiva then
                    RondaActiva = true
                    S("🔥 FORJA DETECTADA — Bot activado", Color3.fromRGB(255,255,0))
                    task.spawn(function() RunForgeAssist(self, RetTuple[1]) end)
                end
                
                return unpack(RetTuple)
            end
            
            -- Bloquear ChangeSequence nativos rezagados (Pour, Hammer, Water)
            -- Solo dejar pasar los que el BOT envía
            if RondaActiva and (phaseName == "Pour" or phaseName == "Hammer" or phaseName == "Water") then
                if BotBypassingNetwork then
                    return OriginalNamecall(self, ...)
                else
                    -- Bloquear el nativo rezagado
                    return nil
                end
            end
            
            -- Close = fin de la forja
            if phaseName == "Close" then
                RondaActiva = false
                pcall(function()
                    local Knit = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"))
                    local fc = Knit.GetController("ForgeController")
                    if fc then fc.ForgeActive = false end
                    
                    local cc = Knit.GetController("CharacterController")
                    if cc then
                        cc.WalkSpeed = 16
                        if cc.SetWalkSpeed then cc:SetWalkSpeed(16) end
                    end
                end)
                S("✅ FORJA TERMINADA — Libre!", Color3.fromRGB(0,255,100))
            end
        end
    end
    
    return OriginalNamecall(self, ...)
end)

S("v5.0 ACTIVO — Ve a la forja ⚒️", Color3.fromRGB(150,255,150))
