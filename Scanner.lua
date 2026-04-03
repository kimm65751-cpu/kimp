-- TEST MÍNIMO: Solo crea GUI y dice si funcionó
local gui = Instance.new("ScreenGui")
gui.Name = "CAM_Test"
gui.ResetOnSpawn = false
gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 100)
frame.Position = UDim2.new(0.5, -150, 0.5, -50)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
frame.BorderSizePixel = 3

local label = Instance.new("TextLabel", frame)
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.Text = "✅ GUI FUNCIONA (V9.5)"
label.TextColor3 = Color3.fromRGB(0, 255, 0)
label.Font = Enum.Font.GothamBold
label.TextSize = 18
