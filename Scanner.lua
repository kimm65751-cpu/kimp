-- FORENSE DEBUG V3 - Muestra todo en pantalla dentro del juego
-- No necesitas abrir ninguna consola

local log = ""
local function step(msg)
    log = log .. "\n" .. msg
end

step("1. Script iniciado")

local ok1, Players = pcall(game.GetService, game, "Players")
step("2. Players: " .. tostring(ok1) .. " = " .. tostring(Players))

local ok2, LocalPlayer = pcall(function() return Players.LocalPlayer end)
step("3. LocalPlayer: " .. tostring(ok2) .. " = " .. tostring(LocalPlayer))

local sg = Instance.new("ScreenGui")
sg.Name = "ForenseDebugV3"
sg.ResetOnSpawn = false
step("4. ScreenGui creado")

local okCG = pcall(function() sg.Parent = game:GetService("CoreGui") end)
step("5. CoreGui parent: " .. tostring(okCG) .. " | sg.Parent=" .. tostring(sg.Parent))

if not okCG and ok2 and LocalPlayer then
    local okPG = pcall(function()
        local pg = LocalPlayer:WaitForChild("PlayerGui", 5)
        sg.Parent = pg
    end)
    step("6. PlayerGui fallback: " .. tostring(okPG) .. " | sg.Parent=" .. tostring(sg.Parent))
end

step("7. Creando Frame...")

local f = Instance.new("Frame")
f.Size = UDim2.new(0, 500, 0, 300)
f.Position = UDim2.new(0.5, -250, 0.5, -150)
f.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
f.BorderSizePixel = 3
f.BorderColor3 = Color3.fromRGB(255, 200, 0)
f.Active = true
f.Draggable = true
f.Parent = sg

step("8. Frame parentado a sg")

local lbl = Instance.new("TextLabel")
lbl.Size = UDim2.new(1, -10, 1, -10)
lbl.Position = UDim2.new(0, 5, 0, 5)
lbl.BackgroundTransparency = 1
lbl.Text = "FORENSE DEBUG\n" .. log
lbl.TextColor3 = Color3.fromRGB(255, 255, 100)
lbl.Font = Enum.Font.Code
lbl.TextSize = 13
lbl.TextXAlignment = Enum.TextXAlignment.Left
lbl.TextYAlignment = Enum.TextYAlignment.Top
lbl.TextWrapped = true
lbl.Parent = f

local xb = Instance.new("TextButton")
xb.Size = UDim2.new(0, 40, 0, 30)
xb.Position = UDim2.new(1, -42, 0, 2)
xb.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
xb.Text = "X"
xb.TextColor3 = Color3.fromRGB(255,255,255)
xb.Font = Enum.Font.Code
xb.Parent = f
xb.MouseButton1Click:Connect(function() sg:Destroy() end)
