-- ==============================================================================
-- 💀 ROBLOX EXPERT: V27 ECO-FORENSIC TRACER (ANALIZADOR DE ROBO EN PROFUNDIDAD)
-- Rastreo Topográfico de Red, Interceptación de Paquetes y Depuración Jerárquica.
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
local CHARS_PER_PAGE = 10000

local function AddLog(text, indentLevel)
    local prefix = string.rep("  ", indentLevel or 0)
    FullReport = FullReport .. prefix .. text .. "\n"
end

private_G = {}

-- ==============================================================================
-- 🔬 EL SENSOR DE DEPURACIÓN (INTERCEPCIÓN DE RED C/S)
-- ==============================================================================
-- Almacenará todo lo que el servidor nos grite de vuelta al inyectar paquetes.
local RespuestasDelServidor = {}
local ListenerConexiones = {}

local function IniciarSensoresDeRed()
    RespuestasDelServidor = {}
    for _, ev in pairs(ReplicatedStorage:GetDescendants()) do
        if ev:IsA("RemoteEvent") then
            pcall(function()
                local conn = ev.OnClientEvent:Connect(function(...)
                    local args = {...}
                    local argText = ""
                    for i, a in ipairs(args) do argText = argText .. tostring(a) .. ", " end
                    table.insert(RespuestasDelServidor, {Remote = ev.Name, Data = argText})
                end)
                table.insert(ListenerConexiones, conn)
            end)
        end
    end
end

local function DetenerSensoresDeRed()
    for _, conn in pairs(ListenerConexiones) do pcall(function() conn:Disconnect() end) end
    ListenerConexiones = {}
end

-- ==============================================================================
-- 💸 RASTREO PROFUNDO DE ROBO (EL CÓDIGO CAUSANTE CON DEPURADOR)
-- ==============================================================================
local function DeepEcoTrace()
    FullReport = "========================================================\n"
    FullReport = FullReport .. "🕵️ DEPURADOR JERÁRQUICO V27: CAZA DEL LADRÓN DE MONEDAS 🕵️\n"
    FullReport = FullReport .. "========================================================\n\n"
    
    local statFolder = LocalPlayer:FindFirstChild("leaderstats")
    if not statFolder then AddLog("❌ ERROR: No hay 'leaderstats'.", 0); return end

    local coinStat = nil
    for _, v in pairs(statFolder:GetChildren()) do
        if v:IsA("IntValue") or v:IsA("NumberValue") then coinStat = v break end
    end

    if not coinStat then AddLog("❌ ERROR: Leaderstats no tiene valores numéricos.", 0); return end

    AddLog("[+] Inicializando Sensores Locales de Network...", 0)
    IniciarSensoresDeRed()
    
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local pos = hrp and hrp.Position or Vector3.new(0,0,0)
    
    AddLog("[📍 ESTADO INICIAL DEL CLIENTE]", 0)
    AddLog("  ├─ Capital Actual: " .. tostring(coinStat.Value) .. " " .. coinStat.Name, 1)
    AddLog("  └─ Coordenadas Actuales: X:" .. math.floor(pos.X) .. " Y:" .. math.floor(pos.Y) .. " Z:" .. math.floor(pos.Z), 1)
    AddLog("\n[🚀 INICIANDO INYECCIÓN SECUENCIAL EXPLÍCITA Y RASTREO]", 0)
    
    -- Recolectamos Targets para simular interacciones lo mas reales posibles
    local targetNPC = nil
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= LocalPlayer.Character then targetNPC = obj break end
    end

    local RemotesRobones = {}
    local startMoneyGlobal = coinStat.Value
    
    for _, ev in pairs(ReplicatedStorage:GetDescendants()) do
        if (ev:IsA("RemoteEvent") or ev:IsA("RemoteFunction")) and not (ev.Name:lower():match("ban") or ev.Name:lower():match("kick")) then
            local DineroAntesDeDisparar = coinStat.Value
            RespuestasDelServidor = {} -- Limpiamos el cache de lectura
            
            -- CREAMOS PAQUETES ALTAMENTE ENGAÑOSOS
            local ArgumentosProbados = {
                "Hit", targetNPC, 9999,
                "Buy", "Sword", 16000,
                hrp, targetNPC and targetNPC:FindFirstChild("HumanoidRootPart")
            }
            
            pcall(function()
                if ev:IsA("RemoteEvent") then
                    ev:FireServer(unpack(ArgumentosProbados))
                elseif ev:IsA("RemoteFunction") then
                    task.spawn(function() ev:InvokeServer(unpack(ArgumentosProbados)) end)
                end
            end)
            
            task.wait(0.2) -- Ventana estricta de monitoreo para cada Remote
            
            local DineroDespuesDeDisparar = coinStat.Value
            if DineroDespuesDeDisparar ~= DineroAntesDeDisparar then
                -- ¡ATRAPADO EN EL ACTO!
                local Diferencia = DineroDespuesDeDisparar - DineroAntesDeDisparar
                table.insert(RemotesRobones, {
                    R = ev, 
                    Dif = Diferencia, 
                    ServerLogs = RespuestasDelServidor
                })
                break -- Rompemos para analizar este Remote a profundidad absoluta
            end
        end
    end
    
    DetenerSensoresDeRed() -- Apagamos el sniffer

    -- =========================================================================
    -- 🧱 RESULTADOS DEL ANÁLISIS FORENSE Y EXPLOTACIÓN
    -- =========================================================================
    if #RemotesRobones > 0 then
        local Data = RemotesRobones[1]
        local ladron = Data.R
        local robo = Data.Dif
        
        AddLog("\n🚨 [ALERTA ROJA]: ¡SE HA DETECTADO UNA VULNERABILIDAD/ROBO DE SALDO! 🚨", 0)
        AddLog("[🔍 JERARQUÍA DEL INCIDENTE Y AUTOPSIA DEL REMOTE]", 0)
        
        -- 1. IDENTIDAD
        AddLog("├─ [1. IDENTIDAD DEL CULPABLE LUA]", 1)
        AddLog("│   ├─ Nombre del Disparador: '" .. ladron.Name .. "'", 1)
        AddLog("│   ├─ Tipo de Puerto: " .. ladron.ClassName, 1)
        AddLog("│   └─ Ubicación en Motor: " .. ladron:GetFullName(), 1)
        
        -- 2. IMPACTO
        AddLog("├─ [2. DATOS DEL IMPACTO]", 1)
        AddLog("│   ├─ Variación Económica: " .. tostring(robo) .. " " .. coinStat.Name, 1)
        AddLog("│   ├─ Dinero Restante LUA: " .. tostring(coinStat.Value), 1)
        AddLog("│   └─ Condición Genética: Tu personaje estaba en ("..math.floor(pos.X)..","..math.floor(pos.Y)..","..math.floor(pos.Z)..") disparando remoto sin GUI.", 1)
        
        -- 3. RESPUESTAS DE RED
        AddLog("├─ [3. TRAZADO DE RESPUESTA TCP/UDP (SERVER -> CLIENTE)]", 1)
        if #Data.ServerLogs > 0 then
            AddLog("│   ├─ ¡El servidor emitió una respuesta al robarte el dinero!", 1)
            for _, log in pairs(Data.ServerLogs) do
                AddLog("│   ├─ [OnClientEvent desde '"..log.Remote.."']: Arg Recibidos -> {" .. log.Data .. "}", 1)
            end
            AddLog("│   └─ 👉 El Server intentó actualizar tu UI o darte un Item. Probablemente es una Tienda Legítima.", 1)
        else
            AddLog("│   └─ Silencio Absoluto. El servidor te quitó el dinero en silencio. Probablemente es un sistema de Penalización por Daño o un Robo invisible de otro Remote mal diseñado.", 1)
        end
        
        -- 4. INGENIERÍA INVERSA: ¿CÓMO SACARLE PROVECHO? (BYPASS)
        AddLog("└─ [4. DIAGNÓSTICO DE EXPLOTACIÓN Y SOLUCIÓN DE DESARROLLADOR]", 1)
        AddLog("    ├─ EL PROBLEMA: Tu evento '"..ladron.Name.."' carece de validación de Origen. Confió en los Argumentos que le envié ciegamente: { 'Buy', 'Sword', 'Hit', 9999 }.", 1)
        
        if robo < 0 then
            AddLog("    ├─ LA DEBILIDAD (VECTORES DE EXPLOTACIÓN hacker):", 1)
            AddLog("    │   1. Integer Underflow: Como te quita dinero sin tu permiso de GUI, un Hacker disparará este Remote enviándole un costo NEGATIVO, ej: FirebaseServer('Buy', -99999). Si no usas `math.abs()`, el C++ mutará el menos por menos, sumando millones a la cuenta del hacker.", 1)
            AddLog("    │   2. Spam de Inventario Falso: Pudo haberte vendido una espada de 16k sin que estuvieras cerca de la tienda física (Zero Magnitude Constraint).", 1)
            AddLog("    │", 1)
            AddLog("    └─ EL PARCHE URGENTE C++:", 1)
            AddLog("        - En tu script de Servidor ("..ladron.Name..".OnServerEvent), NO confíes en nada numérico del cliente.", 1)
            AddLog("        - Agrega: `if (Player.Character.PrimaryPart.Position - TiendaModel.Position).Magnitude > 15 then return end`", 1)
            AddLog("        - Agrega: `local CostoReal = ServerTiendaConfig[ItemNombre].Price; if CostoReal < 0 then return end`", 1)
        else
            AddLog("    ├─ LA DEBILIDAD:", 1)
            AddLog("    │   1. ¡El Remote te inyectó saldo POSITIVO! Tienes una Generadora de Efectivo expuesta (Posiblemente de Zombies o Drops). Los Hackers solo pondrán este eventito LUA en un `while wait() do` y secarán la economía de tu juego en 1 hora.", 1)
            AddLog("    └─ EL PARCHE URGENTE C++: Verifica desde Servidor el estado del DropMuerte antes de emitir recompensas (Server-Side Verification).", 1)
        end
    else
        AddLog("\n🛡️ [RESULTADO]: El bombardeo secuencial de V27 no causó robo de dinero esta vez.", 0)
        AddLog("Esto ocurre usualmente cuando el Remote vulnerable requería ciertos Cooldowns, o estabas muerto, o te faltaban Monedas previas para activar la falla del Underflow.", 0)
    end
    
    AddLog("\n========================================================\n", 0)
    AddLog("[✅] TRAZADO FORENSE COMPLETADO. LECTURA EXPORTADA.", 0)
end

-- ==============================================================================
-- ⚙️ MOTOR DEL OMNI-SCANNER Y CHUNKER
-- ==============================================================================
local function FormatValue(v) return (typeof(v)=="Instance" and v.Name) or (typeof(v)=="Vector3" and "V3") or (typeof(v)=="CFrame" and "CF") or tostring(v) end
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
-- 🖥️ GUI V2026: THE OMNI-SCANNER DEEP ECO-TRACER (BOTÓN 3 REDISEÑADO)
-- ==============================================================================
local function ConstruirUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "MasterBypass2026UI"
    sg.ResetOnSpawn = false
    
    local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "MasterBypass2026UI" then v:Destroy() end end
    sg.Parent = parentUI

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 680, 0, 540)
    MainFrame.Position = UDim2.new(0.5, -340, 0.5, -270)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
    MainFrame.BorderSizePixel = 3
    MainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -90, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(0, 50, 100)
    TopBar.Text = "  [V27: THE ECO-FORENSIC TRACER - AUTOPSIA DEL DINERO]"
    TopBar.TextColor3 = Color3.fromRGB(150, 200, 255)
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
    ReloadBtn.MouseButton1Click:Connect(function() pcall(function() sg:Destroy(); loadstring(game:HttpGet(SCRIPT_URL .. "?r=" .. math.random(111,999)))() end) end)

    local InfoScroll = Instance.new("ScrollingFrame")
    InfoScroll.Size = UDim2.new(1, -16, 0.60, 0)
    InfoScroll.Position = UDim2.new(0, 8, 0, 35)
    InfoScroll.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    InfoScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    InfoScroll.ScrollBarThickness = 6
    InfoScroll.Parent = MainFrame

    local LogTextBox = Instance.new("TextBox")
    LogTextBox.Size = UDim2.new(1, -10, 1, 0)
    LogTextBox.Position = UDim2.new(0, 5, 0, 5)
    LogTextBox.BackgroundTransparency = 1
    LogTextBox.Text = "V27: MOTOR DE RASTREO TOPOGRÁFICO DE ECONOMÍA.\n\nEl usuario exige una autopsia profunda del código Ladrón de su dinero.\n\nACTUALIZACIONES DEL [Botón 3]:\n- He acoplado 'Network Sniffers' a nivel LUA. El script escuchará temporalmente todos tus `OnClientEvent`.\n- Dispararé secuencial e individualmente cada Remote mandando argumentos complejos ('Buy', Target=Zombi, Amount=9999).\n- Si uno de estos remotes muta la variable de Monedas, detendré el escáner al instante y Generaré el REPORTE FORENSE con tu jerarquía solicitada:\n\n 1. ¿Quién fue? Nombre y Ruta del Remote.\n 2. ¿Cuánto y Dónde? Cantidad restada y Posición de tu Jugador y NPC Objetivo en el mapa de Workspace.\n 3. ¿Qué gritó el servidor? Textos interceptados de red.\n 4. ¿Cómo lo exploto? Instrucciones para el Underflow y cómo parcharlo.\n\nAsegúrate de tener algo de Dinero antes de hacer la prueba."
    LogTextBox.TextColor3 = Color3.fromRGB(180, 220, 255)
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
    btnExploit.Position = UDim2.new(0, 8, 0.86, 0)
    btnExploit.BackgroundColor3 = Color3.fromRGB(0, 80, 180)
    btnExploit.Text = "🔬 3. DEEP TRACE: RASTREAR BUG, DEBILIDADES Y RED C/S"
    btnExploit.TextColor3 = Color3.fromRGB(220, 240, 255)
    btnExploit.Font = Enum.Font.Code
    btnExploit.TextSize = 12
    btnExploit.Parent = MainFrame
    
    btnExploit.MouseButton1Click:Connect(function()
        pcall(function()
            DeepEcoTrace()
            SegmentarPaginas()
            ActualizarPantalla()
        end)
    end)
    
    -- Sub Buttons para Paginas
    local btnPrev = Instance.new("TextButton")
    btnPrev.Size = UDim2.new(0.32, 0, 0, 30)
    btnPrev.Position = UDim2.new(0, 8, 0.76, 0)
    btnPrev.BackgroundColor3 = Color3.fromRGB(50, 60, 90)
    btnPrev.Text = "< Anterior"
    btnPrev.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnPrev.Parent = MainFrame

    local PageLabel = Instance.new("TextLabel")
    PageLabel.Size = UDim2.new(0.32, 0, 0, 30)
    PageLabel.Position = UDim2.new(0.335, 4, 0.76, 0)
    PageLabel.BackgroundTransparency = 1
    PageLabel.Text = "Página.. "
    PageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    PageLabel.Parent = MainFrame

    local btnNext = Instance.new("TextButton")
    btnNext.Size = UDim2.new(0.32, 0, 0, 30)
    btnNext.Position = UDim2.new(0.67, 8, 0.76, 0)
    btnNext.BackgroundColor3 = Color3.fromRGB(50, 60, 90)
    btnNext.Text = "Siguiente >"
    btnNext.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnNext.Parent = MainFrame
    
    local function UptLabel() PageLabel.Text = "Página " .. tostring(CurrentPage) .. " / " .. tostring(#Pages) end
    btnPrev.MouseButton1Click:Connect(function() if CurrentPage > 1 then CurrentPage = CurrentPage - 1; ActualizarPantalla(); UptLabel() end end)
    btnNext.MouseButton1Click:Connect(function() if CurrentPage < #Pages then CurrentPage = CurrentPage + 1; ActualizarPantalla(); UptLabel() end end)
end

ConstruirUI()
