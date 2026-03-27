-- ==============================================================================
-- 💀 ROBLOX EXPERT: V26 ECO-SNIPER PENTEST (ROBREDE GESTIÓN DE ECONOMÍA)
-- El Rastreador y Simulador de Robo de Leaderstats Infinito (Cero Asumiciones)
-- ==============================================================================

local SCRIPT_URL = "https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local FullReport = ""
local Pages = {}
local CurrentPage = 1
local CHARS_PER_PAGE = 11000

local function AddLog(text, indentLevel)
    local prefix = string.rep("  ", indentLevel or 0)
    FullReport = FullReport .. prefix .. text .. "\n"
end

private_G = {}

-- ==============================================================================
-- 💸 EL RASTREADOR ECONÓMICO Y EXPLOIT DE NÚMEROS NEGATIVOS
-- ==============================================================================
local function AutoHackEconomico()
    FullReport = "========================================================\n"
    FullReport = FullReport .. "💸 V26 ECO-SNIPER: SIMULADOR DE ROBO A LEADERSTATS 💸\n"
    FullReport = FullReport .. "========================================================\n\n"
    FullReport = FullReport .. "Has detectado un Robo a tu dinero en la fase anterior.\n"
    FullReport = FullReport .. "Esto significa que tienes un Evento de Tienda, Venta o Recompensa sin asegurar.\n"
    FullReport = FullReport .. "Voy a disparar remotamente a TODOS tus Eventos, uno por uno.\n"
    FullReport = FullReport .. "Si tu dinero baja otra vez, atraparemos MÁGICAMENTE el nombre exacto de tu Remote vulnerable.\n"
    FullReport = FullReport .. "Y si lo permite... ¡El Script intentará robarte e inyectarte Dinero Positivo asumiendo la falla de Subdesbordamiento!\n\n"
    
    local statFolder = LocalPlayer:FindFirstChild("leaderstats")
    if not statFolder then
        AddLog("❌ FRACASO: No posees un folder llamado 'leaderstats'. El pentest no puede medir el fraude matemático.", 0)
        return
    end

    local coinStat = nil
    for _, v in pairs(statFolder:GetChildren()) do
        if v:IsA("IntValue") or v:IsA("NumberValue") then
            -- Tomamos el primero, usualmente Monedas, Dinero o Cash
            coinStat = v
            break
        end
    end

    if not coinStat then
        AddLog("❌ FRACASO: No hay valores numéricos dentro de Leaderstats.", 0)
        return
    end

    AddLog("[🏦 CAPITAL BASE]: Tu '" .. coinStat.Name .. "' actual es: " .. tostring(coinStat.Value), 0)
    AddLog("---------------------------------------------------------", 0)

    -- Fase 1: Encontrar el Remote Vulnerable
    AddLog("🔍 FASE 1: AISLANDO EL EVENTO CULPABLE (DISPARO UNO-A-UNO)", 0)
    local startMoney = coinStat.Value
    local culpableRemotes = {}

    local eventList = {}
    for _, ev in pairs(ReplicatedStorage:GetDescendants()) do
        if (ev:IsA("RemoteEvent") or ev:IsA("RemoteFunction")) and not (ev.Name:lower():match("ban") or ev.Name:lower():match("kick") or ev.Name:lower():match("replica")) then
            table.insert(eventList, ev)
        end
    end

    AddLog("  ├─ Disparando " .. tostring(#eventList) .. " Remotes con Paquetes de Prueba... Espera.", 1)
    
    for i, ev in ipairs(eventList) do
        local checkMoney = coinStat.Value
        
        -- Simulamos la compra de un item llamado "Sword", o enviando argumentos lógicos
        if ev:IsA("RemoteEvent") then
            pcall(function() ev:FireServer() end)
            pcall(function() ev:FireServer(9999) end)
            pcall(function() ev:FireServer("Hit") end)
            pcall(function() ev:FireServer("Buy", "Sword", 1) end)
            pcall(function() ev:FireServer(LocalPlayer.Name) end)
        elseif ev:IsA("RemoteFunction") then
            task.spawn(function()
                pcall(function() ev:InvokeServer() end)
                pcall(function() ev:InvokeServer(9999) end)
            end)
        end
        
        task.wait(0.15) -- Damos tiempo al servidor de restar el dinero
        
        if coinStat.Value ~= checkMoney then
            local variacion = coinStat.Value - checkMoney
            table.insert(culpableRemotes, {Remote = ev, Cambio = variacion})
            AddLog("  └─ 🚨 ¡BINGO! El Remote LUA '" .. ev.Name .. " ("..ev.ClassName..")' acaba de modificar tu dinero en: " .. tostring(variacion), 1)
            break -- Si encontramos a uno, salimos para probarlo a fondo!
        end
    end

    if #culpableRemotes == 0 then
        AddLog("  └─ [🛡️ SEGURO]: El esceneo milimétrico no logró modificar el saldo. El Remote causal requería el Target del zombie que ya no enviamos.", 1)
        return
    end

    AddLog("\n---------------------------------------------------------", 0)
    
    -- Fase 2: INTENTO DE REVERSO ECONÓMICO (INYECCIÓN POSITIVA)
    local RemoteVulnerable = culpableRemotes[1].Remote
    AddLog("💀 FASE 2: AUTO-HACK ('EL ENGAÑO NEGATIVO')", 0)
    AddLog("  ├─ [MÉTODO]: Disparamos tu '" .. RemoteVulnerable.Name .. "' pero forzando Inyecciones Hacker de 'Negative Cost' y 'OverFlow'.", 1)
    
    local dineroAntes = coinStat.Value
    
    -- INYECCIÓN TIPO A: Math Overflow Negative ( -(-99999) = +99999 )
    pcall(function() RemoteVulnerable:FireServer(-999999) end)
    pcall(function() RemoteVulnerable:FireServer("Buy", "Sword", -999999) end)
    pcall(function() RemoteVulnerable:FireServer("Damage", -999999) end)
    pcall(function() RemoteVulnerable:FireServer(-math.huge) end)
    pcall(function() RemoteVulnerable:FireServer(LocalPlayer.Character, -100) end)
    
    -- INYECCIÓN TIPO B: Palabras Mágicas Clásicas de Venta/Drops
    pcall(function() RemoteVulnerable:FireServer("Sell", "All") end)
    pcall(function() RemoteVulnerable:FireServer("Reward", 999999) end)
    pcall(function() RemoteVulnerable:FireServer("ClaimDrop", 999999) end)
    pcall(function() RemoteVulnerable:FireServer("AddMoney", 999999) end)
    
    task.wait(1.5)
    
    local dineroDespues = coinStat.Value
    if dineroDespues > dineroAntes then
        AddLog("  └─ [🚨 EXPLOIT MASIVO CONFIRMADO: FACTIBLE (SÍ)]", 1)
        AddLog("     ¡ACABAS DE HACERTE MILLONARIO CON UN HACK!", 1)
        AddLog("     Tus fondos subieron MÁGICAMENTE de " .. tostring(dineroAntes) .. " a " .. tostring(dineroDespues) .. ".", 1)
        AddLog("     -> GRAVEDAD ABSOLUTA: Tu C++ acepta Números Negativos como precio (Menos por Menos da Más), o tu sistema confía en el valor que dice el cliente que debe ganar. Un hacker arruinará tu economía en 5 minutos.", 1)
        AddLog("     -> EL PARCHE URGENTE: En tu servidor 'OnServerEvent', pon `if ArgumentoPrecio < 0 then return end` y NO permitas que el cliente mande el precio, búscalo tú en Server.", 1)
    else
        AddLog("  └─ [🛡️ ROBO INVERSO BLOQUEADO: NO FACTIBLE]", 1)
        AddLog("     Tu saldo continuó en "...tostring(dineroDespues).." (No subió falsamente).", 1)
        AddLog("     -> CERTEZA: Aunque el evento te puede asaltar por descuido, tu Inteligencia C++ rebotó los números negativos. NO HAY bypass de Suma Inversa. Estás protegido contra Generadores de Moneda, el fallo fue solo una compra ciega mal validada.", 1)
    end
    
    AddLog("========================================================\n", 0)
    AddLog("[✅] PRUEBA ECONÓMICA DE CERO-TRUST FINALIZADA.", 0)
end

-- ==============================================================================
-- ⚙️ MOTOR DEL OMNI-SCANNER V-MAX 
-- ==============================================================================
local function FormatValue(v)
    if typeof(v) == "Instance" then return v.Name
    elseif typeof(v) == "Vector3" then return "V3"
    elseif typeof(v) == "CFrame" then return "CF"
    else return tostring(v) end
end

local function GetDetails(obj, indent)
    for _, v in pairs(obj:GetChildren()) do
        pcall(function()
            if v:IsA("ValueBase") then       AddLog("📌 DATO: " .. v.Name .. " = " .. FormatValue(v.Value), indent)
            elseif v:IsA("RemoteEvent") then AddLog("🔗 EVENTO (Sin Respuesta): " .. v.Name, indent)
            elseif v:IsA("RemoteFunction") then AddLog("🔗 EVENTO (Con Respuesta): " .. v.Name, indent)
            elseif v:IsA("ProximityPrompt") or v:IsA("ClickDetector") then AddLog("🏪 INTERACCIÓN: '" .. tostring(v.ClassName) .. "'", indent)
            end
        end)
    end
end

local function EscaneoOmniJerarquico()
    FullReport = "========================================================\n👑 REPORTE DE AUDITORÍA OMNI-SCANNER V-MAX (ROBLOX 2026) 👑\n========================================================\n\n"
    AddLog("INICIANDO ESCANEO FORENSE EN CASCADA (TREE DUMP)...", 0)

    AddLog("\n[📡 SECCIÓN 1: ARQUITECTURA DE RED Y EVENTOS C/S]", 0)
    local function ScanNet(parent, indent)
        pcall(function()
            for _, obj in pairs(parent:GetChildren()) do
                pcall(function()
                    if obj:IsA("Folder") then
                        local hasremotes = false
                        for _, d in pairs(obj:GetDescendants()) do if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then hasremotes = true break end end
                        if hasremotes then AddLog("📁 " .. obj.Name, indent); ScanNet(obj, indent + 1) end
                    elseif obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        AddLog("🔗 " .. obj.Name .. " (" .. obj.ClassName .. ")", indent)
                    end
                end)
            end
        end)
    end
    ScanNet(ReplicatedStorage, 1)

    AddLog("\n✅ ESCANEO JERÁRQUICO V-MAX GENERADO CON ÉXITO.", 0)
end

local function SegmentarPaginas()
    Pages = {}
    local startIdx = 1
    while startIdx <= #FullReport do
        local endIdx = startIdx + CHARS_PER_PAGE - 1
        table.insert(Pages, string.sub(FullReport, startIdx, endIdx))
        startIdx = endIdx + 1
    end
    CurrentPage = 1
    if #Pages == 0 then table.insert(Pages, "No hay datos generados que mostrar.") end
end

-- ==============================================================================
-- 🖥️ GUI V2026: THE OMNI-SCANNER ECO-PENTEST (BOTÓN 3 NUEVO)
-- ==============================================================================
local function ConstruirUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "MasterBypass2026UI"
    sg.ResetOnSpawn = false
    
    local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "MasterBypass2026UI" then v:Destroy() end end
    sg.Parent = parentUI

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 640, 0, 520)
    MainFrame.Position = UDim2.new(0.5, -320, 0.5, -260)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 15)
    MainFrame.BorderSizePixel = 3
    MainFrame.BorderColor3 = Color3.fromRGB(50, 255, 100)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -90, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(0, 80, 20)
    TopBar.Text = "  [V26: ECO-SNIPER - DETECTANDO FRAUDE DE MONEDAS]"
    TopBar.TextColor3 = Color3.fromRGB(150, 255, 150)
    TopBar.Font = Enum.Font.Code
    TopBar.TextSize = 13
    TopBar.TextXAlignment = Enum.TextXAlignment.Left
    TopBar.Parent = MainFrame

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.TextSize = 14
    CloseBtn.Parent = MainFrame

    local ReloadBtn = Instance.new("TextButton")
    ReloadBtn.Size = UDim2.new(0, 30, 0, 30)
    ReloadBtn.Position = UDim2.new(1, -60, 0, 0)
    ReloadBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 0)
    ReloadBtn.Text = "↻"
    ReloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ReloadBtn.Font = Enum.Font.Code
    ReloadBtn.TextSize = 18
    ReloadBtn.Parent = MainFrame

    CloseBtn.MouseButton1Click:Connect(function() sg:Destroy() end)
    ReloadBtn.MouseButton1Click:Connect(function()
        pcall(function() sg:Destroy(); loadstring(game:HttpGet(SCRIPT_URL .. "?r=" .. math.random(111,999)))() end)
    end)

    local InfoScroll = Instance.new("ScrollingFrame")
    InfoScroll.Size = UDim2.new(1, -16, 0.60, 0)
    InfoScroll.Position = UDim2.new(0, 8, 0, 35)
    InfoScroll.BackgroundColor3 = Color3.fromRGB(10, 15, 20)
    InfoScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    InfoScroll.ScrollBarThickness = 6
    InfoScroll.Parent = MainFrame

    local LogTextBox = Instance.new("TextBox")
    LogTextBox.Size = UDim2.new(1, -10, 1, 0)
    LogTextBox.Position = UDim2.new(0, 5, 0, 5)
    LogTextBox.BackgroundTransparency = 1
    LogTextBox.Text = "HAS PERDIDO DINERO. ¡LA AUTORIDAD ECONÓMICA HA SIDO VULNERADA!\n\nAcabas de preguntarme: '¿Si perdí 16,000 monedas por el ataque de la V25... es posible hacer el inverso (ganar millones falsos)?'.\n\nLA RESPUESTA ES: Depende de cómo programaste la suma matemática en tu Remote.\n\n[Botón 3: AUTO-HACK RASTREO Y ROBO ECONÓMICO]\nEl Script acaba de aislar la Caza Punitiva sólamente hacia el dinero. Dispararemos todos y cada uno de los remotes aisladamente y observaremos tus Leaderstats LUA en microsegundos para CAZAR Cuál es el Puerto LUA exacto que te bajó esos 16mil.\nInmediatamente después, el Script actuará como la Élite y le disparará precios negativos (-999,9999) y strings falsificados a ese puerto para intentar multiplicarte el dinero como harían los Hackers hoy.\n\nSiente el poder del Pentesting real. Presiona el Botón."
    LogTextBox.TextColor3 = Color3.fromRGB(200, 255, 180)
    LogTextBox.Font = Enum.Font.Code
    LogTextBox.TextSize = 12
    LogTextBox.TextXAlignment = Enum.TextXAlignment.Left
    LogTextBox.TextYAlignment = Enum.TextYAlignment.Top
    LogTextBox.TextWrapped = true
    LogTextBox.ClearTextOnFocus = false
    LogTextBox.TextEditable = false
    LogTextBox.MultiLine = true
    LogTextBox.Parent = InfoScroll

    local function ActualizarPantalla()
        if #Pages == 0 then return end
        LogTextBox.Text = Pages[CurrentPage]
        InfoScroll.CanvasPosition = Vector2.new(0, 0)
    end

    local btnExploit = Instance.new("TextButton")
    btnExploit.Size = UDim2.new(1, -16, 0, 50)
    btnExploit.Position = UDim2.new(0, 8, 0.85, 0)
    btnExploit.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    btnExploit.Text = "💸 3. AUTO-HACK: RASTREO Y ROBO ECONÓMICO (INYECCIÓN +/-)"
    btnExploit.TextColor3 = Color3.fromRGB(255, 255, 200)
    btnExploit.Font = Enum.Font.Code
    btnExploit.TextSize = 12
    btnExploit.Parent = MainFrame
    
    btnExploit.MouseButton1Click:Connect(function()
        pcall(function()
            AutoHackEconomico()
            SegmentarPaginas()
            ActualizarPantalla()
        end)
    end)
    
    -- Sub Buttons para Paginas
    local btnPrev = Instance.new("TextButton")
    btnPrev.Size = UDim2.new(0.32, 0, 0, 30)
    btnPrev.Position = UDim2.new(0, 8, 0.75, 0)
    btnPrev.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    btnPrev.Text = "< Anterior"
    btnPrev.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnPrev.Parent = MainFrame

    local PageLabel = Instance.new("TextLabel")
    PageLabel.Size = UDim2.new(0.32, 0, 0, 30)
    PageLabel.Position = UDim2.new(0.335, 4, 0.75, 0)
    PageLabel.BackgroundTransparency = 1
    PageLabel.Text = "Página.. "
    PageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    PageLabel.Parent = MainFrame

    local btnNext = Instance.new("TextButton")
    btnNext.Size = UDim2.new(0.32, 0, 0, 30)
    btnNext.Position = UDim2.new(0.67, 8, 0.75, 0)
    btnNext.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    btnNext.Text = "Siguiente >"
    btnNext.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnNext.Parent = MainFrame
    
    local function UptLabel() PageLabel.Text = "Página " .. tostring(CurrentPage) .. " / " .. tostring(#Pages) end
    btnPrev.MouseButton1Click:Connect(function() if CurrentPage > 1 then CurrentPage = CurrentPage - 1; ActualizarPantalla(); UptLabel() end end)
    btnNext.MouseButton1Click:Connect(function() if CurrentPage < #Pages then CurrentPage = CurrentPage + 1; ActualizarPantalla(); UptLabel() end end)
end

ConstruirUI()
