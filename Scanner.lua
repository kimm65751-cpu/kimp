-- ==============================================================================
-- 🕵️ ANALIZADOR DE PARÁLISIS ABSOLUTO (METAMETODO __NEWINDEX)
-- ==============================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- GUI
-- ==========================================
local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "ParalysisAnalyzer" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ParalysisAnalyzer"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 500, 0, 400)
Panel.Position = UDim2.new(0, 20, 0.5, -200)
Panel.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
Panel.BorderSizePixel = 2
Panel.BorderColor3 = Color3.fromRGB(255, 100, 50)
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(80, 20, 40)
Title.Text = " 🕵️ RASTREADOR DE PARÁLISIS (NÚCLEO)"
Title.TextColor3 = Color3.fromRGB(255, 200, 220)
Title.TextSize = 13
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Panel

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.Code
CloseBtn.Parent = Panel
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(1, 0, 0, 30)
CopyBtn.Position = UDim2.new(0, 0, 1, -30)
CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
CopyBtn.Text = "📋 COPIAR ANÁLISIS"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.Code
CopyBtn.TextSize = 12
CopyBtn.Parent = Panel

local TermScroll = Instance.new("ScrollingFrame")
TermScroll.Size = UDim2.new(1, -10, 1, -70)
TermScroll.Position = UDim2.new(0, 5, 0, 35)
TermScroll.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
TermScroll.ScrollBarThickness = 6
TermScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
TermScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TermScroll.Parent = Panel
Instance.new("UIListLayout", TermScroll).Padding = UDim.new(0, 2)

local LogHistory = {}
local function Log(texto, color)
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, -4, 0, 0)
    msg.BackgroundTransparency = 1
    msg.Text = "[" .. os.date("%H:%M:%S") .. "] " .. texto
    msg.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    msg.Font = Enum.Font.Code
    msg.TextSize = 11
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.TextWrapped = true
    msg.Parent = TermScroll
    local tsz = game:GetService("TextService"):GetTextSize(msg.Text, msg.TextSize, msg.Font, Vector2.new(TermScroll.AbsoluteSize.X-15, math.huge))
    msg.Size = UDim2.new(1, -4, 0, tsz.Y + 2)
    TermScroll.CanvasPosition = Vector2.new(0, 999999)
    table.insert(LogHistory, msg.Text)
end

CopyBtn.MouseButton1Click:Connect(function() pcall(function() setclipboard(table.concat(LogHistory, "\n")) end) end)

-- ==========================================
-- HOOK DE NÚCLEO FÍSICO (__NEWINDEX)
-- ==========================================
Log("🔴 HOOK DE PARÁLISIS ACTIVADO.", Color3.fromRGB(255, 100, 100))
Log("🗣️ Ve y habla/vende a Sey. Si algún script toca tu RootPart, Cámara o Velocidad, será expuesto.", Color3.fromRGB(255, 255, 100))
Log("--------------------------------------------------", Color3.fromRGB(100, 100, 100))

local OriginalNewIndex
OriginalNewIndex = hookmetamethod(game, "__newindex", function(t, k, v)
    -- Si el intento de cambio proviene del juego (y no del exploit)
    if not checkcaller() then
        
        -- CASO 1: Anclaron tu cuerpo
        if t:IsA("BasePart") and t.Name == "HumanoidRootPart" and k == "Anchored" and v == true then
            task.spawn(function()
                Log("☠️ ¡SABOTAJE! Un script congeló tu cuerpo (Anchored=true)", Color3.fromRGB(255, 50, 50))
                local trace = debug.traceback()
                for line in string.gmatch(trace, "[^\r\n]+") do
                    if string.find(line, "Player") or string.find(line, "ReplicatedStorage") then
                        Log("   -> " .. line, Color3.fromRGB(255, 150, 150))
                    end
                end
            end)
        end
        
        -- CASO 2: Secuestraron tu cámara
        if t:IsA("Camera") and k == "CameraType" and v ~= Enum.CameraType.Custom then
            task.spawn(function()
                Log("🎥 ¡SECUESTRO! Un script alteró la cámara a: " .. tostring(v), Color3.fromRGB(50, 255, 255))
                local trace = debug.traceback()
                for line in string.gmatch(trace, "[^\r\n]+") do
                    if string.find(line, "Player") or string.find(line, "ReplicatedStorage") then
                        Log("   -> " .. line, Color3.fromRGB(150, 255, 255))
                    end
                end
            end)
        end
        
        -- CASO 3: Te dejaron sin velocidad de movimiento
        if t:IsA("Humanoid") and k == "WalkSpeed" and v == 0 then
            task.spawn(function()
                Log("♿ ¡PARÁLISIS! WalkSpeed reducida a 0", Color3.fromRGB(255, 100, 255))
                local trace = debug.traceback()
                for line in string.gmatch(trace, "[^\r\n]+") do
                    if string.find(line, "Player") or string.find(line, "ReplicatedStorage") then
                        Log("   -> " .. line, Color3.fromRGB(255, 150, 255))
                    end
                end
            end)
        end

    end
    
    return OriginalNewIndex(t, k, v)
end)
