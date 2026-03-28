-- ==============================================================================
-- 💰 AUTO-VENDEDOR EXPLIOT V1.0 (FORGOTTEN KINGDOM)
-- Vende remotamente sin acercarte a Sey Codicioso. 
-- Bypassea la UI y manda los remotos directamente al servidor.
-- ==============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- BUSCANDO LOS REMOTOS VULNERABLES
-- ==========================================
local RF_RunCommand = nil
local RF_ForceDialogue = nil
local NPC_Sey = nil

-- Tarea: Buscar Sey en Workspace
for _, obj in pairs(Workspace:GetDescendants()) do
    if obj:IsA("Model") and (obj.Name == "Greedy Cey" or string.find(string.lower(obj.Name), "cey") or string.find(string.lower(obj.Name), "sey")) then
        NPC_Sey = obj
        break
    end
end

-- Tarea: Buscar los remotos en ReplicatedStorage
for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteFunction") then
        if obj.Name == "RunCommand" then
            RF_RunCommand = obj
        elseif obj.Name == "ForceDialogue" then
            RF_ForceDialogue = obj
        end
    end
end

-- ==========================================
-- LISTA DE TRASH / MISC EN INGLÉS
-- (Basado en el Basket interceptado y RPGs comunes)
-- ==========================================
local TrashItemsBasket = {
    Basket = {
        ["Small Essence"] = 9999,   -- Esencia pequeña
        ["Cobalt"] = 9999,          -- Cobalto
        ["Quartz"] = 9999,          -- Cuarzo
        ["Diamond"] = 9999,         -- Diamante
        ["Emerald"] = 9999,         -- Esmeralda
        ["Topaz"] = 9999,           -- Topaz
        ["Amethyst"] = 9999,        -- Ametista
        ["Sapphire"] = 9999,        -- Zafiro
        ["Lapis Lazuli"] = 9999,    -- Lapis Lazuli
        ["Cuprite"] = 9999,         -- Cuprita
        ["Titanium"] = 9999,        -- Titánio
        ["Excrement"] = 9999,       -- Excremento
        ["Bananite"] = 9999,        -- Bananita
        ["Cartonite"] = 9999,       -- Cartonita
        ["Boneita"] = 9999,         -- Boneita
        ["Aite"] = 9999,            -- Aite
        ["Fichillium"] = 9999,      -- Fichillium
    }
}

-- ==========================================
-- GUI
-- ==========================================
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "AutoVendedorUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoVendedorUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 350, 0, 250)
Panel.Position = UDim2.new(0, 20, 0.5, -125)
Panel.BackgroundColor3 = Color3.fromRGB(15, 20, 15)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(100, 255, 100)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(20, 80, 20)
Title.Text = " 💰 AUTO-VENDEDOR REMOTO V1.0"
Title.TextColor3 = Color3.fromRGB(200, 255, 200)
Title.TextSize = 13
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Panel

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.Code
CloseBtn.Parent = Panel
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local StatusTxt = Instance.new("TextLabel")
StatusTxt.Size = UDim2.new(1, -20, 0, 40)
StatusTxt.Position = UDim2.new(0, 10, 0, 40)
StatusTxt.BackgroundTransparency = 1
StatusTxt.TextColor3 = Color3.fromRGB(255, 255, 100)
StatusTxt.Font = Enum.Font.Code
StatusTxt.TextSize = 12
StatusTxt.TextWrapped = true
StatusTxt.Text = "Buscando vulnerabilidades...\n" .. 
                 (RF_RunCommand and "✅ RunCommand " or "❌ RunCommand ") .. 
                 (NPC_Sey and "✅ NPC_Sey " or "❌ NPC_Sey")
StatusTxt.Parent = Panel

-- ==========================================
-- BOTONES DE EXPLOIT
-- ==========================================

-- METODO 1: RunCommand
local BtnRunCommand = Instance.new("TextButton")
BtnRunCommand.Size = UDim2.new(1, -20, 0, 45)
BtnRunCommand.Position = UDim2.new(0, 10, 0, 90)
BtnRunCommand.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
BtnRunCommand.Text = "🔥 EXPLOIT 1: INYECTAR BASKET (AUTO)\nVende items listados desde cualquier lugar"
BtnRunCommand.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnRunCommand.Font = Enum.Font.Code
BtnRunCommand.TextSize = 11
BtnRunCommand.Parent = Panel

BtnRunCommand.MouseButton1Click:Connect(function()
    if not RF_RunCommand then
        StatusTxt.Text = "❌ Remoto RunCommand no encontrado."
        return
    end
    
    StatusTxt.Text = "⏳ Inyectando Basket..."
    
    task.spawn(function()
        local exito, resp = pcall(function()
            return RF_RunCommand:InvokeServer("SellConfirm", TrashItemsBasket)
        end)
        
        if exito then
            StatusTxt.Text = "✅ Inyección terminada! Revisa si conseguiste dinero."
        else
            StatusTxt.Text = "❌ Error en inyección: " .. tostring(resp)
        end
    end)
end)

-- METODO 2: ForceDialogue
local BtnForceSync = Instance.new("TextButton")
BtnForceSync.Size = UDim2.new(1, -20, 0, 45)
BtnForceSync.Position = UDim2.new(0, 10, 0, 145)
BtnForceSync.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
BtnForceSync.Text = "💬 EXPLOIT 2: FORZAR DIALOGO MISC\nFuerza la venta de toda la basura al NPC"
BtnForceSync.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnForceSync.Font = Enum.Font.Code
BtnForceSync.TextSize = 11
BtnForceSync.Parent = Panel

BtnForceSync.MouseButton1Click:Connect(function()
    if not RF_ForceDialogue or not NPC_Sey then
        StatusTxt.Text = "❌ Remoto ForceDialogue o NPC no encontrados."
        return
    end
    
    StatusTxt.Text = "⏳ Forzando dialogo a Sey..."
    
    task.spawn(function()
        local exito, resp = pcall(function()
            return RF_ForceDialogue:InvokeServer(NPC_Sey, "SellConfirmMisc")
        end)
        
        if exito then
            StatusTxt.Text = "✅ Diálogo Forzado enviado con éxito."
        else
            StatusTxt.Text = "❌ Error en dialogo: " .. tostring(resp)
        end
    end)
end)

local Disclaimer = Instance.new("TextLabel")
Disclaimer.Size = UDim2.new(1, -20, 0, 30)
Disclaimer.Position = UDim2.new(0, 10, 1, -30)
Disclaimer.BackgroundTransparency = 1
Disclaimer.TextColor3 = Color3.fromRGB(150, 150, 150)
Disclaimer.Font = Enum.Font.Code
Disclaimer.TextSize = 10
Disclaimer.Text = "Ambos métodos son pasivos y no mueven a tu personaje."
Disclaimer.Parent = Panel
