-- EVOMON SCANNER v5 - Estrategia nueva: acumula en RAM, escribe una sola vez
local svc = game:GetService
local Players = svc("Players")
local CoreGui = svc("CoreGui")

local LP = Players.LocalPlayer
if not LP then
    LP = Players.PlayerAdded:Wait()
end

-- =====================================================
-- BUFFER EN RAM - se llena primero, luego se escribe
-- =====================================================
local buffer = {}
local function add(s)
    table.insert(buffer, tostring(s))
    print(">>SCAN>> " .. tostring(s))
end

-- =====================================================
-- GUI MINIMA
-- =====================================================
local gui
pcall(function()
    gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "ScanV5"
    gui.ResetOnSpawn = false
end)
if not gui or not gui.Parent then
    gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
    gui.Name = "ScanV5"
    gui.ResetOnSpawn = false
end

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,300,0,120)
frame.Position = UDim2.new(0.5,-150,0,5)
frame.BackgroundColor3 = Color3.fromRGB(10,10,15)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,0,0,30)
status.BackgroundTransparency = 1
status.Text = "SCAN V5 - presiona el boton"
status.TextColor3 = Color3.fromRGB(180,220,255)
status.Font = Enum.Font.GothamBold
status.TextSize = 11
status.TextWrapped = true

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(1,-10,0,34)
btn.Position = UDim2.new(0,5,0,32)
btn.BackgroundColor3 = Color3.fromRGB(41,128,185)
btn.Text = "ESCANEAR Y GUARDAR EvomonQA_ScanData.txt"
btn.TextColor3 = Color3.fromRGB(255,255,255)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 11
btn.TextWrapped = true
btn.BorderSizePixel = 0
Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

local result = Instance.new("TextLabel", frame)
result.Size = UDim2.new(1,-10,0,40)
result.Position = UDim2.new(0,5,0,72)
result.BackgroundTransparency = 1
result.Text = "Esperando..."
result.TextColor3 = Color3.fromRGB(200,200,200)
result.Font = Enum.Font.Code
result.TextSize = 9
result.TextWrapped = true
result.TextXAlignment = Enum.TextXAlignment.Left

-- =====================================================
-- SCAN + WRITE AL CLICK
-- =====================================================
btn.MouseButton1Click:Connect(function()
    btn.Text = "Escaneando..."
    btn.BackgroundColor3 = Color3.fromRGB(100,100,100)
    status.Text = "Recolectando datos..."
    buffer = {}

    task.spawn(function()
        add("=== EVOMON SCAN " .. os.date("%Y-%m-%d %H:%M:%S") .. " ===")

        -- Jugadores
        add("[PLAYERS]")
        local pnames = {}
        for _, p in ipairs(Players:GetPlayers()) do
            pnames[p.Name] = true
            add("P|" .. p.Name)
        end

        -- NPCs
        add("[NPCS]")
        local nc = 0
        for _, o in ipairs(workspace:GetDescendants()) do
            if o:IsA("Model") and not pnames[o.Name] then
                local hrp = o:FindFirstChild("HumanoidRootPart")
                local hum = o:FindFirstChildOfClass("Humanoid")
                if hrp and hum then
                    local d = -1
                    local c = LP.Character
                    if c and c:FindFirstChild("HumanoidRootPart") then
                        d = math.floor((hrp.Position - c.HumanoidRootPart.Position).Magnitude)
                    end
                    add("NPC|" .. o.Name .. "|" .. d .. "st|" .. o:GetFullName())
                    nc = nc + 1
                end
            end
        end
        add("NPC_TOTAL=" .. nc)

        -- Botones GUI
        add("[BUTTONS]")
        local pg = LP:FindFirstChildOfClass("PlayerGui")
        if pg then
            local bc = 0
            for _, o in ipairs(pg:GetDescendants()) do
                if o:IsA("TextButton") or o:IsA("ImageButton") then
                    local v = o.Visible and "V" or "H"
                    local t = ""
                    if o:IsA("TextButton") then t = o.Text end
                    add("BTN|" .. v .. "|" .. o.Name .. "|" .. t)
                    bc = bc + 1
                end
            end
            add("BTN_TOTAL=" .. bc)
        end

        -- RemoteEvents
        add("[REMOTES]")
        local kw = {"battle","catch","escape","flee","pity","summon",
                    "monster","capture","operate","enter","settle","wild"}
        local rc = 0
        for _, o in ipairs(game:GetDescendants()) do
            if o:IsA("RemoteEvent") or o:IsA("RemoteFunction") then
                local n = string.lower(o.Name)
                for _, k in ipairs(kw) do
                    if string.find(n, k) then
                        add("REM|" .. o.ClassName .. "|" .. o.Name .. "|" .. o:GetFullName())
                        rc = rc + 1
                        break
                    end
                end
            end
        end
        add("REM_TOTAL=" .. rc)

        -- ProximityPrompts
        add("[PROXPROMPTS]")
        local pc = 0
        for _, o in ipairs(workspace:GetDescendants()) do
            if o:IsA("ProximityPrompt") then
                add("PP|" .. o.ActionText .. "|" .. tostring(o.Enabled) .. "|" .. o:GetFullName())
                pc = pc + 1
            end
        end
        add("PP_TOTAL=" .. pc)

        -- Valores jugador
        add("[PLAYERVALS]")
        local function sv(f, pre)
            for _, v in ipairs(f:GetChildren()) do
                if v:IsA("ValueBase") then
                    add("VAL|" .. pre .. v.Name .. "=" .. tostring(v.Value))
                elseif v:IsA("Folder") then
                    sv(v, pre .. v.Name .. "/")
                end
            end
        end
        sv(LP, "")

        add("[END]")

        -- =====================================================
        -- ESCRIBIR ARCHIVO - un solo writefile con todo el buffer
        -- =====================================================
        local content = table.concat(buffer, "\n")
        local fname = "EvomonQA_ScanData.txt"
        local saved = false
        local method = "ninguno"

        -- Intento 1: writefile directo
        if not saved and writefile then
            local ok = pcall(writefile, fname, content)
            if ok then saved = true method = "writefile" end
        end

        -- Intento 2: writefile con ruta alternativa
        if not saved and writefile then
            local ok = pcall(writefile, "workspace/" .. fname, content)
            if ok then saved = true method = "writefile+path" end
        end

        -- Intento 3: appendfile linea por linea sobre el LiveReport existente
        if not saved and appendfile then
            local ok = pcall(function()
                appendfile("EvomonQA_LiveReport.txt", "\n\n" .. content)
            end)
            if ok then
                saved = true
                fname = "EvomonQA_LiveReport.txt (al final)"
                method = "appendfile->LiveReport"
            end
        end

        -- Resultado
        if saved then
            result.Text = "✔ Guardado en: " .. fname .. "\nMetodo: " .. method
            result.TextColor3 = Color3.fromRGB(100,255,100)
            btn.Text = "LISTO: " .. method
            btn.BackgroundColor3 = Color3.fromRGB(39,174,96)
        else
            result.Text = "✘ No se pudo guardar.\nRevisa Output del executor.\n" .. #buffer .. " lineas en consola."
            result.TextColor3 = Color3.fromRGB(255,100,100)
            btn.Text = "Sin acceso a archivos"
            btn.BackgroundColor3 = Color3.fromRGB(192,57,43)
        end

        status.Text = #buffer .. " lineas | " .. nc .. " NPCs | " .. rc .. " Remotes | " .. pc .. " PPs"
    end)
end)
