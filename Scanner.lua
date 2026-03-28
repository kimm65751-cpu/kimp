-- ==============================================================================
-- 🎰 RACE SPIN SNIPER V1.5 (EXPLOIT: GIROS INFINITOS)
-- Intercepta el Reroll. Si la raza NO es la deseada, BLOQUEA la respuesta.
-- El juego se cuelga, sales, entras, y tu giro NO se gastó.
-- Si la raza SÍ es la deseada, la deja pasar y se guarda normalmente.
-- ==============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- RAZAS OBJETIVO (Edita esta tabla)
-- ==========================================
local RAZAS_DESEADAS = {
    ["Archangel"] = true,   -- 0.1%
    ["Demon"] = true,       -- 0.5%
    ["Angel"] = true,       -- 0.5%
}

-- ==========================================
-- GUI
-- ==========================================
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "RaceAnalyzerUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RaceAnalyzerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 420, 0, 400)
Panel.Position = UDim2.new(0, 20, 0.5, -200)
Panel.BackgroundColor3 = Color3.fromRGB(10, 5, 20)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(255, 50, 50)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Title.Text = " 🎯 RACE SNIPER V1.5 (GIROS GRATIS)"
Title.TextColor3 = Color3.fromRGB(255, 200, 200)
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
CloseBtn.TextSize = 16
CloseBtn.Parent = Panel
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- ACTIVAR TRAMPA
local ArmBtn = Instance.new("TextButton")
ArmBtn.Size = UDim2.new(1, -8, 0, 45)
ArmBtn.Position = UDim2.new(0, 4, 0, 35)
ArmBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
ArmBtn.Text = "🔫 ARMAR SNIPER (luego presiona Reiniciar en el juego)"
ArmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ArmBtn.Font = Enum.Font.Code
ArmBtn.TextSize = 12
ArmBtn.TextWrapped = true
ArmBtn.Parent = Panel

-- RESULTADO GRANDE
local ResultLabel = Instance.new("TextLabel")
ResultLabel.Size = UDim2.new(1, -8, 0, 60)
ResultLabel.Position = UDim2.new(0, 4, 0, 85)
ResultLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
ResultLabel.Text = "⏳ Esperando... Arma el Sniper y presiona Reiniciar."
ResultLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ResultLabel.TextSize = 16
ResultLabel.Font = Enum.Font.Code
ResultLabel.TextWrapped = true
ResultLabel.Parent = Panel
Instance.new("UICorner", ResultLabel).CornerRadius = UDim.new(0, 6)

-- INFO DE OBJETIVOS
local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(1, -8, 0, 20)
TargetLabel.Position = UDim2.new(0, 4, 0, 150)
TargetLabel.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
TargetLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
TargetLabel.Font = Enum.Font.Code
TargetLabel.TextSize = 10
TargetLabel.TextWrapped = true
TargetLabel.Parent = Panel

local targetNames = {}
for k, _ in pairs(RAZAS_DESEADAS) do table.insert(targetNames, k) end
TargetLabel.Text = "🎯 Acepta: " .. table.concat(targetNames, ", ")

-- LOG
local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -8, 1, -210)
LogScroll.Position = UDim2.new(0, 4, 0, 175)
LogScroll.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
LogScroll.ScrollBarThickness = 6
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.Parent = Panel
Instance.new("UIListLayout", LogScroll).Padding = UDim.new(0, 2)

-- Botones inferiores
local ControlsFrame = Instance.new("Frame")
ControlsFrame.Size = UDim2.new(1, -8, 0, 28)
ControlsFrame.Position = UDim2.new(0, 4, 1, -32)
ControlsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ControlsFrame.Parent = Panel

local SaveTxtBtn = Instance.new("TextButton")
SaveTxtBtn.Size = UDim2.new(1, 0, 1, 0)
SaveTxtBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
SaveTxtBtn.Text = "💾 GUARDAR LOG .TXT"
SaveTxtBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveTxtBtn.Font = Enum.Font.Code
SaveTxtBtn.TextSize = 11
SaveTxtBtn.Parent = ControlsFrame

-- ==========================================
-- SISTEMA DE LOGS (Escribe al .txt en tiempo real)
-- ==========================================
local MasterLogList = {}
local LOG_FILENAME = "RaceSpinLog.txt"

local function WriteToFile(text)
    pcall(function()
        if writefile then
            local ok, existing = pcall(readfile, LOG_FILENAME)
            if ok and type(existing) == "string" then
                writefile(LOG_FILENAME, existing .. text .. "\n")
            else
                writefile(LOG_FILENAME, text .. "\n")
            end
        end
    end)
end

local function AddLog(logType, message, color)
    local fullString = "[" .. os.date("%H:%M:%S") .. "] [" .. logType .. "] " .. message
    table.insert(MasterLogList, fullString)
    WriteToFile(fullString)
    if #MasterLogList > 300 then table.remove(MasterLogList, 1) end
    task.defer(function()
        pcall(function()
            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1, -4, 0, 0)
            txt.BackgroundTransparency = 1
            txt.Text = fullString
            txt.TextColor3 = color or Color3.fromRGB(200, 200, 200)
            txt.Font = Enum.Font.Code
            txt.TextSize = 10
            txt.TextXAlignment = Enum.TextXAlignment.Left
            txt.TextWrapped = true
            txt.Parent = LogScroll
            local tsz = game:GetService("TextService"):GetTextSize(txt.Text, txt.TextSize, txt.Font, Vector2.new(LogScroll.AbsoluteSize.X - 15, math.huge))
            txt.Size = UDim2.new(1, -4, 0, tsz.Y + 4)
            LogScroll.CanvasPosition = Vector2.new(0, 999999)
        end)
    end)
end

SaveTxtBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local r = "=== RACE SNIPER V1.5 LOG ===\n" .. os.date("%Y-%m-%d %H:%M:%S") .. "\n\n"
        for _, l in ipairs(MasterLogList) do r = r .. l .. "\n" end
        writefile(LOG_FILENAME, r)
        SaveTxtBtn.Text = "✅ GUARDADO"
    end)
    task.delay(3, function() pcall(function() SaveTxtBtn.Text = "💾 GUARDAR LOG .TXT" end) end)
end)

-- ==========================================
-- SNIPER: Hook de __namecall
-- ==========================================
local SniperArmado = false
local OriginalNamecall = nil

ArmBtn.MouseButton1Click:Connect(function()
    SniperArmado = not SniperArmado
    
    if SniperArmado then
        ArmBtn.Text = "🔴 SNIPER ARMADO - Presiona REINICIAR en el juego"
        ArmBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        ResultLabel.Text = "🔴 ARMADO. Ve al menú de razas y presiona Reiniciar."
        ResultLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        ResultLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 0)
        
        AddLog("SNIPER", "🔴 SNIPER ARMADO.", Color3.fromRGB(255, 100, 100))
        AddLog("SNIPER", "Acepta: " .. table.concat(targetNames, ", "), Color3.fromRGB(255, 200, 0))
        AddLog("SNIPER", "Ahora presiona Reiniciar en el menú de Carreras.", Color3.fromRGB(255, 255, 0))
        
        if not OriginalNamecall then
            OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                
                if not SniperArmado then
                    return OriginalNamecall(self, ...)
                end
                
                -- Solo interceptar InvokeServer del Reroll
                if method == "InvokeServer" and not checkcaller() then
                    local selfName = ""
                    pcall(function() selfName = self.Name end)
                    
                    if selfName == "Reroll" then
                        -- Llamar al servidor para ver qué raza nos da
                        local raza = OriginalNamecall(self, ...)
                        local razaStr = tostring(raza)
                        
                        -- Guardar resultado al .txt INMEDIATAMENTE
                        pcall(function()
                            WriteToFile("[" .. os.date("%H:%M:%S") .. "] [SNIPER] Servidor dijo: " .. razaStr)
                        end)
                        
                        if RAZAS_DESEADAS[razaStr] then
                            -- ✅ RAZA DESEADA → Dejar pasar
                            pcall(function()
                                WriteToFile("[" .. os.date("%H:%M:%S") .. "] [SNIPER] 🏆 ACEPTADA: " .. razaStr)
                            end)
                            task.spawn(function()
                                ResultLabel.Text = "🏆🏆🏆 " .. razaStr .. " 🏆🏆🏆"
                                ResultLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                                ResultLabel.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
                                AddLog("SNIPER", "🏆 RAZA ACEPTADA: " .. razaStr, Color3.fromRGB(0, 255, 0))
                            end)
                            return raza
                        else
                            -- ❌ RAZA NO DESEADA → TELEPORT INSTANTÁNEO
                            pcall(function()
                                WriteToFile("[" .. os.date("%H:%M:%S") .. "] [SNIPER] ❌ Rechazada: " .. razaStr .. " → TELEPORTANDO...")
                            end)
                            task.spawn(function()
                                ResultLabel.Text = "❌ " .. razaStr .. " → TELEPORTANDO..."
                                ResultLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                            end)
                            -- Teleport instantáneo al mismo juego (no da tiempo de guardar)
                            pcall(function()
                                game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
                            end)
                            -- Si el teleport falla, congelar como respaldo
                            task.wait(0.2)
                            while true do end
                        end
                    end
                end
                
                return OriginalNamecall(self, ...)
            end)
        end
    else
        ArmBtn.Text = "🔫 ARMAR SNIPER (luego presiona Reiniciar en el juego)"
        ArmBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
        ResultLabel.Text = "⏳ Sniper desarmado."
        ResultLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        ResultLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        AddLog("SNIPER", "⚪ Sniper desarmado.", Color3.fromRGB(150, 150, 150))
    end
end)

-- ==========================================
-- INICIALIZACIÓN
-- ==========================================
pcall(function() writefile(LOG_FILENAME, "=== RACE SNIPER V1.5 INICIADO " .. os.date("%Y-%m-%d %H:%M:%S") .. " ===\n") end)

AddLog("SISTEMA", "🎯 RACE SNIPER V1.5 cargado.", Color3.fromRGB(150, 255, 150))
AddLog("SISTEMA", "═══════════════════════════════════", Color3.fromRGB(255, 200, 100))
AddLog("SISTEMA", "CÓMO FUNCIONA:", Color3.fromRGB(255, 255, 200))
AddLog("SISTEMA", "1. Presiona ARMAR SNIPER (se pone rojo).", Color3.fromRGB(255, 255, 200))
AddLog("SISTEMA", "2. Ve al menú de Carreras y presiona Reiniciar.", Color3.fromRGB(255, 255, 200))
AddLog("SISTEMA", "3. Si la raza es buena → se acepta y se guarda.", Color3.fromRGB(0, 255, 0))
AddLog("SISTEMA", "4. Si la raza es mala → se BLOQUEA, el juego se pega.", Color3.fromRGB(255, 80, 80))
AddLog("SISTEMA", "5. Sales del juego, entras de nuevo = GIRO GRATIS.", Color3.fromRGB(255, 255, 0))
AddLog("SISTEMA", "═══════════════════════════════════", Color3.fromRGB(255, 200, 100))
AddLog("SISTEMA", "🎯 Acepta: " .. table.concat(targetNames, ", "), Color3.fromRGB(255, 200, 0))
