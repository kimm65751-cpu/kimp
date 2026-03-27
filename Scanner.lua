-- ==============================================================================
-- 💀 ROBLOX EXPERT: SMART PROP ANALYZER V15.1 (MODO CIENTÍFICO)
-- Auditoría estricta de variables no-ancladas para inventario de Munición.
-- ==============================================================================

local SCRIPT_URL = "https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- 🧩 CORE LOGGER
local Analyzer = { Logs = {} }

function Analyzer:Clear()
    self.Logs = {}
    if self.UI_LogBox then self.UI_LogBox.Text = "" end
end

function Analyzer:Log(txt)
    print("[CRACKER-SCAN] " .. tostring(txt))
    table.insert(self.Logs, txt)
    pcall(function()
        if self.UI_LogBox then
            self.UI_LogBox.Text = self.UI_LogBox.Text .. "\n" .. tostring(txt)
        end
    end)
    pcall(function()
        local scroll = self.UI_LogBox.Parent
        scroll.CanvasPosition = Vector2.new(0, 99999)
    end)
end

-- ==============================================================================
-- 🔍 EL ESCÁNER INTELIGENTE DE MUNICIÓN FÍSICA
-- ==============================================================================
local function EscanearProyectilesReales()
    Analyzer:Clear()
    Analyzer:Log("🔍 INICIANDO AUDITORÍA FORENSE DE OBJETOS C++...\n")
    
    local totalFound = 0
    local discardedHumanoids = 0
    local discardedWelds = 0
    local discardedMap = 0
    local validAmmo = 0
    
    local TypeCount = {}
    local validProps = {} -- Guardar referencias reales
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Anchored then
            totalFound = totalFound + 1
            local isValid = true
            
            -- Filtro 1: Descartar piezas que pertenecen a un modelo vivo (Jugador/NPC)
            local current = obj
            local isCharacterPart = false
            while current and current ~= Workspace do
                if current:FindFirstChild("Humanoid") then
                    isCharacterPart = true
                    break
                end
                if current:IsA("Accessory") or current:IsA("Tool") or current:IsA("Hat") then
                    isCharacterPart = true
                    break
                end
                current = current.Parent
            end
            
            if isCharacterPart then
                discardedHumanoids = discardedHumanoids + 1
                isValid = false
            end
            
            -- Filtro 2: Descartar terreno y placas base
            if isValid and (obj.Name == "Baseplate" or obj.Name == "Terrain") then
                discardedMap = discardedMap + 1
                isValid = false
            end
            
            -- Filtro 3: Comprobar Joints (Welds). Si está pegado a un jugador, fallidero Suicide-Bombing.
            if isValid then
                for _, joint in pairs(obj:GetJoints()) do
                    if joint:IsA("JointInstance") then
                        -- Si está soldado a algo más que no sea el mapa, ignorarlo por seguridad extrema
                        local attachTo = joint.Part0 == obj and joint.Part1 or joint.Part0
                        if attachTo and attachTo.Parent and attachTo.Parent:FindFirstChild("Humanoid") then
                            discardedWelds = discardedWelds + 1
                            isValid = false
                            break
                        end
                    end
                end
            end
            
            -- Si pasó todos los filtros, es una pura Piedra o Mineral C++ (Ammo Real)
            if isValid then
                validAmmo = validAmmo + 1
                local itemName = obj.Name .. " (Clase: " .. obj.ClassName .. ")"
                TypeCount[itemName] = (TypeCount[itemName] or 0) + 1
                table.insert(validProps, obj)
            end
        end
    end
    
    -- REPORTE DETALLADO
    Analyzer:Log("📊 RESULTADOS DEL DIAGNÓSTICO DE LA PARADOJA V15:")
    Analyzer:Log("=========================================")
    Analyzer:Log("Objetos Sueltos Brutos: " .. tostring(totalFound))
    Analyzer:Log("❌ Descartados (Jugadores/NPC/Armas): " .. tostring(discardedHumanoids))
    Analyzer:Log("❌ Descartados (Soldadura/Weld de Personaje): " .. tostring(discardedWelds))
    Analyzer:Log("❌ Descartados (Restos del Mapa): " .. tostring(discardedMap))
    Analyzer:Log("=========================================")
    Analyzer:Log("✅ BALAS TELEQUINÉTICAS PURAS (" ..tostring(validAmmo).. "):\n")
    
    if validAmmo > 0 then
        -- Listar el inventario de Ammo real
        for name, qt in pairs(TypeCount) do
            Analyzer:Log(" -> " .. tostring(qt) .. "x " .. tostring(name))
        end
        Analyzer:Log("\n💡 CONCLUSIÓN: Tienes " .. tostring(validAmmo) .. " proyectiles físicos comprobados que NO están soldados a ti. Si le das a LANZAR MUNICIÓN en el botón de abajo, sólo usará estos objetos puros sin arrastrarte.")
        getgenv().AmmoCache = validProps
    else
        Analyzer:Log("💀 CONCLUSIÓN MORTAL: Tras filtrar tus sombreros y armas... Quedan 0 Objetos en el mapa. Significa que los creadores anclaron literalmente CADA ÁTOMO. No podemos construir el Cañón.")
        getgenv().AmmoCache = nil
    end
end

-- ==============================================================================
-- 🔫 CAÑÓN SEGURO V15.1 (Sólo usa la Caché Validada)
-- ==============================================================================
getgenv().PropTelekinesis = false

local function DispararBalon()
    if getgenv().PropTelekinesis then return end
    
    if not getgenv().AmmoCache or #getgenv().AmmoCache == 0 then
        return Analyzer:Log("❌ ERROR: Primero debes usar el Escáner Inteligente, o usar el Escáner comprobó que hay 0 balas.")
    end
    
    getgenv().PropTelekinesis = true
    Analyzer:Log("🔥 INICIANDO DESCARGA TELEQUINÉTICA C/ " .. tostring(#getgenv().AmmoCache) .. " PROYECTILES 🔥")
    
    local ammo = getgenv().AmmoCache
    
    task.spawn(function()
        while getgenv().PropTelekinesis do
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                -- Apuntar al enemigo más cercano
                local target = nil
                local distM = 99999
                for _, z in pairs(Workspace:GetDescendants()) do
                    if z:IsA("Model") and string.find(string.lower(z.Name), "zombie") and z ~= char then
                        local zHum = z:FindFirstChild("Humanoid")
                        local zRoot = z:FindFirstChild("HumanoidRootPart")
                        if zHum and zHum.Health > 0 and zRoot then
                            local d = (zRoot.Position - root.Position).Magnitude
                            if d < distM then distM = d; target = zRoot end
                        end
                    end
                end

                if target then
                    for _, obj in ipairs(ammo) do
                        if obj and obj.Parent then
                            -- Bombardeo dentro del hitbox del zombi
                            obj.CFrame = target.CFrame * CFrame.new(math.random(-1,1), math.random(-1,1), math.random(-1,1))
                            obj.AssemblyLinearVelocity = Vector3.new(0, -9999, 0)
                            obj.AssemblyAngularVelocity = Vector3.new(9999, 9999, 9999)
                        end
                    end
                end
            end)
            task.wait(0.02)
        end
    end)
end

local function DetenerDisparo()
    getgenv().PropTelekinesis = false
    Analyzer:Log("🛑 Cañón Apagado.")
end

-- ==============================================================================
-- 🖥️ GUI V2026: EL LABORATORIO INTELIGENTE
-- ==============================================================================
local function ConstruirUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "MasterBypass2026UI"
    sg.ResetOnSpawn = false
    
    local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "MasterBypass2026UI" then v:Destroy() end end
    sg.Parent = parentUI

    -- 📐 REDUCIDO DRÁSTICAMENTE (LDPlayer Formato)
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 560, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -280, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    MainFrame.BorderSizePixel = 3
    MainFrame.BorderColor3 = Color3.fromRGB(0, 200, 150)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -90, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(0, 50, 40)
    TopBar.Text = "  [V15.1: SMART PROP ANALYZER - MODO CIENTÍFICO]"
    TopBar.TextColor3 = Color3.fromRGB(150, 255, 200)
    TopBar.Font = Enum.Font.Code
    TopBar.TextSize = 13
    TopBar.TextXAlignment = Enum.TextXAlignment.Left
    TopBar.Parent = MainFrame

    local ReloadBtn = Instance.new("TextButton")
    ReloadBtn.Size = UDim2.new(0, 30, 0, 30)
    ReloadBtn.Position = UDim2.new(1, -90, 0, 0)
    ReloadBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 0)
    ReloadBtn.Text = "↻"
    ReloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ReloadBtn.Font = Enum.Font.Code
    ReloadBtn.TextSize = 18
    ReloadBtn.Parent = MainFrame

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    MinimizeBtn.Position = UDim2.new(1, -60, 0, 0)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 150)
    MinimizeBtn.Text = "_"
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.Font = Enum.Font.Code
    MinimizeBtn.TextSize = 14
    MinimizeBtn.Parent = MainFrame

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.TextSize = 14
    CloseBtn.Parent = MainFrame

    CloseBtn.MouseButton1Click:Connect(function() pcall(DetenerDisparo) sg:Destroy() end)
    MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)
    ReloadBtn.MouseButton1Click:Connect(function()
        pcall(function() sg:Destroy(); loadstring(game:HttpGet(SCRIPT_URL .. "?r=" .. math.random(111,999)))() end)
    end)

    local InfoScroll = Instance.new("ScrollingFrame")
    InfoScroll.Size = UDim2.new(1, -16, 0.5, 0)
    InfoScroll.Position = UDim2.new(0, 8, 0, 35)
    InfoScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    InfoScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    InfoScroll.ScrollBarThickness = 6
    InfoScroll.Parent = MainFrame

    local LogText = Instance.new("TextLabel")
    LogText.Size = UDim2.new(1, -10, 1, 0)
    LogText.Position = UDim2.new(0, 5, 0, 5)
    LogText.BackgroundTransparency = 1
    LogText.Text = "Tienes el honor de la verdad. Al intentar lanzar '363 Objetos Ciegos' en la versión anterior... El código agarró tu propia Gorra y la de los zombies, y al estar soldadas (Welds) a tu cuerpo, TE LANZÓ A TI MISMO COMO BOMBA suicida contra el Zombi, generando el Anti-TP Kick por velocidad excedida.\n\nEl Tornado Havok (Volar rotando) sufrió de la 'Tercera Ley de Newton'. Cuando chocaste a mach 10 contra la masa gorda del zombi, él te repelió hacia atrás, llevándote fuera de la atmósfera como una bala y el servidor te baneó por Anti-TP. Lo he cancelado por tu seguridad.\n\nHe construido entonces el SMART PROP ANALYZER V15.1. Pulsa el botón 1 para diseccionar los 363 objetos, descartar tus accesorios y armas para no suicidarnos, y crear una lista Blanca Exclusiva en caché. Si logramos obtener Balas Legítimas que no te pertenezcan a ti, podrás encender de forma limpia el Tiro Telequinético (Botón 2)."
    LogText.TextColor3 = Color3.fromRGB(180, 255, 220)
    LogText.Font = Enum.Font.Code
    LogText.TextSize = 12
    LogText.TextXAlignment = Enum.TextXAlignment.Left
    LogText.TextYAlignment = Enum.TextYAlignment.Top
    LogText.TextWrapped = true
    LogText.Parent = InfoScroll

    -- Botones V15.1
    local btnScan = Instance.new("TextButton")
    btnScan.Size = UDim2.new(1, -16, 0, 50)
    btnScan.Position = UDim2.new(0, 8, 0.62, 0)
    btnScan.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
    btnScan.Text = "📊 1. ESCUDRIÑAR Y FILTRAR OBJETOS DEL JUEGO (MÁXIMA SEGURIDAD)"
    btnScan.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnScan.Font = Enum.Font.Code
    btnScan.TextSize = 13
    btnScan.Parent = MainFrame

    local btnFire = Instance.new("TextButton")
    btnFire.Size = UDim2.new(1, -16, 0, 50)
    btnFire.Position = UDim2.new(0, 8, 0.62, 55)
    btnFire.BackgroundColor3 = Color3.fromRGB(150, 60, 0)
    btnFire.Text = "💥 2. DISPARAR MUNICIÓN VALIDADA (PROYECTILES LIMPIOS) 💥"
    btnFire.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnFire.Font = Enum.Font.Code
    btnFire.TextSize = 13
    btnFire.Parent = MainFrame

    btnScan.MouseButton1Click:Connect(function() pcall(EscanearProyectilesReales) end)
    
    btnFire.MouseButton1Click:Connect(function()
        pcall(function()
            if getgenv().PropTelekinesis then
                DetenerDisparo()
                btnFire.Text = "💥 2. DISPARAR MUNICIÓN VALIDADA (PROYECTILES LIMPIOS) 💥"
                btnFire.BackgroundColor3 = Color3.fromRGB(150, 60, 0)
            else
                DispararBalon()
                if getgenv().PropTelekinesis then
                    btnFire.Text = "🛑 DETENER FUEGO TELEQUINÉTICO"
                    btnFire.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
                end
            end
        end)
    end)
end

ConstruirUI()
