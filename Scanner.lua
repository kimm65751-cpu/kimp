-- TEST MINIMO - Solo abre una ventana
-- Si aparece esta ventana, el executor funciona correctamente
local sg = Instance.new("ScreenGui")
sg.Name = "ForenseTest"
sg.ResetOnSpawn = false

local ok = pcall(function()
    sg.Parent = game:GetService("CoreGui")
end)
if not ok then
    sg.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui", 5)
end

local f = Instance.new("Frame")
f.Size = UDim2.new(0, 350, 0, 120)
f.Position = UDim2.new(0.5, -175, 0.3, 0)
f.BackgroundColor3 = Color3.fromRGB(160, 10, 10)
f.BorderSizePixel = 3
f.BorderColor3 = Color3.fromRGB(255, 200, 0)
f.Active = true
f.Draggable = true
f.Parent = sg

local lbl = Instance.new("TextLabel")
lbl.Size = UDim2.new(1, 0, 1, 0)
lbl.BackgroundTransparency = 1
lbl.Text = "✅ FORENSE TEST OK\nSi ves esto, el script ejecuta bien.\nDime si aparece este cuadro rojo."
lbl.TextColor3 = Color3.fromRGB(255, 255, 100)
lbl.Font = Enum.Font.Code
lbl.TextSize = 13
lbl.TextWrapped = true
lbl.Parent = f

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 40, 0, 30)
close.Position = UDim2.new(1, -42, 0, 2)
close.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255,255,255)
close.Font = Enum.Font.Code
close.Parent = f
close.MouseButton1Click:Connect(function() sg:Destroy() end)
