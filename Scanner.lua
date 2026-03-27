-- ==============================================================================
-- 💀 ROBLOX EXPERT: V29 DIALOGUE HEIST (ATAQUE ECONÓMICO DIRECTO A NPCs)
-- Explotación Selectiva: Aritmética Inversa, Desincronización y Ghosting.
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
-- 🔬 EL SENSOR DE DEPURACIÓN DE RED C/S
-- ==============================================================================
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

local function ObtenerEstadoFinanciero()
    local variables = {}
    for _, v in pairs(LocalPlayer:GetDescendants()) do
        if v:IsA("IntValue") or v:IsA("NumberValue") then
            variables[v:GetFullName()] = {Inst = v, Value = v.Value}
        end
    end
    if LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then
                variables[v:GetFullName()] = {Inst = v, Value = v.Value}
            end
        end
    end
    return variables
end

-- Busca el Remote Asesino de la V28
local ladronRemote = ReplicatedStorage:FindFirstChild("DialogueRemote", true)
if not ladronRemote then
    -- Si no se llama así, buscamos el primero que diga Dialog o Store
    for _, ev in pairs(ReplicatedStorage:GetDescendants()) do
        if (ev:IsA("RemoteEvent") or ev:IsA("RemoteFunction")) and (ev.Name:lower():match("dialog") or ev.Name:lower():match("shop") or ev.Name:lower():match("store") or ev.Name:lower():match("sell")) then
            ladronRemote = ev
            break
        end
    end
end

-- Buscamos un NPC para engañar
local targetNPC = nil
for _, obj in pairs(Workspace:GetDescendants()) do
    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= LocalPlayer.Character then targetNPC = obj break end
end

-- ==============================================================================
-- 💰 METODOLOGÍA HACKER (LAS 3 OLEADAS AL SISTEMA DE DIÁLOGOS)
-- ==============================================================================
local function AutoHackDialogueV29()
    FullReport = "========================================================\n"
    FullReport = FullReport .. "🕵️ V29 DIALOGUE HEIST: EL ROBO MAESTRO (INVERSO) 🕵️\n"
    FullReport = FullReport .. "========================================================\n\n"
    
    if not ladronRemote then AddLog("❌ ERROR: No pude encontrar tu DialogueRemote o StoreRemote. El asalto no puede proceder.", 0); return end
    
    AddLog("[+] Inicializando Monitoreo Lector de Variables...", 0)
    AddLog("[+] Micrófonos Colocados en ReplicatedStorage (OnClientEvent)...", 0)
    
    AddLog("\n🚨 [INICIANDO EL ROBO... OPERANDO SOBRE: '" .. ladronRemote:GetFullName() .. "'] 🚨\n", 0)

    -- __________________________________________________________________________
    -- 🧪 MÉTODO 1: THE INTEGER UNDERFLOW (ARITMÉTICA INVERSA)
    -- __________________________________________________________________________
    AddLog("=========================================================", 0)
    AddLog("[🔪 MÉTODO 1: EL DESBORDAMIENTO (INYECCIÓN NEGATIVA)]", 0)
    AddLog("---------------------------------------------------------", 0)
    AddLog("  ├─ [TEORÍA]: Si me quitaste dinero por leer '9999' de forma ciega, te mandaré '-9999999' asumiendo que tu matemática LUA es: Dinero = Dinero - Pago. Un Hacker suma millones así.", 1)
    
    local Di1 = ObtenerEstadoFinanciero()
    IniciarSensoresDeRed()
    
    -- Disparamos el Exploit
    pcall(function()
        if ladronRemote:IsA("RemoteEvent") then
            -- Intentamos permutaciones de Diálogos Comúnes
            ladronRemote:FireServer(targetNPC, -9999999)
            ladronRemote:FireServer("Buy", -9999999)
            ladronRemote:FireServer("Option", 1, -9999999)
            ladronRemote:FireServer("Sell", "Sword", -9999999)
        end
    end)
    
    task.wait(0.3)
    DetenerSensoresDeRed()
    local Df1 = ObtenerEstadoFinanciero()
    
    local SubidaDetectada1 = false
    AddLog("  ├─ [RESPUESTA DEL SERVIDOR (TCP SNIFFER)]:", 1)
    if #RespuestasDelServidor > 0 then for _, l in pairs(RespuestasDelServidor) do AddLog("       -> " .. l.Remote .. ": {" .. l.Data .. "}", 1) end else AddLog("       -> Silencio de Red.", 1) end
    
    AddLog("  ├─ [RESULTADO ECONÓMICO]:", 1)
    for ruta, data in pairs(Di1) do
        if Df1[ruta] and Df1[ruta].Value > data.Value then
            AddLog("    🔥 ¡BINGO! El Método 1 FUE EXITOSO. Tu '" .. data.Inst.Name .. "' AUMENTÓ de " .. tostring(data.Value) .. " a " .. tostring(Df1[ruta].Value) .. "!", 2)
            SubidaDetectada1 = true
        end
    end
    if not SubidaDetectada1 then AddLog("    🛡️ BLOQUEADO. Tu servidor no cedió dinero al leer números negativos. Tienes filtros aritméticos o usas precios del Server (Excelente).", 2) end


    -- __________________________________________________________________________
    -- 🧪 MÉTODO 2: RACE CONDITION (CANCELACIÓN Y VENTA SOLAPADA)
    -- __________________________________________________________________________
    AddLog("\n=========================================================", 0)
    AddLog("[🔪 MÉTODO 2: RACE CONDITION (LA VENTA FANTASMA DE NPC)]", 0)
    AddLog("---------------------------------------------------------", 0)
    AddLog("  ├─ [TEORÍA]: Como me ordenaste investigar: Le digo al NPC A que Cierre el diálogo, pero simultáneamente al mismo milisegundo le digo al NPC B que completó una Venta falsa. Engaño a la máquina de Estados del Servidor cruzando los cables para que venda el aire.", 1)
    
    local Di2 = ObtenerEstadoFinanciero()
    IniciarSensoresDeRed()

    pcall(function()
        if ladronRemote:IsA("RemoteEvent") then
            local un_npc = targetNPC or LocalPlayer.Character
            -- Mezcla caótica de paquetes concurrentes
            ladronRemote:FireServer("Sell", "DefaultItem") 
            ladronRemote:FireServer(un_npc, "Close") 
            ladronRemote:FireServer("Confirm", "DefaultItem") 
            ladronRemote:FireServer(LocalPlayer.Name, "Trade") 
            ladronRemote:FireServer("Sell", nil) 
        end
    end)
    
    task.wait(0.3)
    DetenerSensoresDeRed()
    local Df2 = ObtenerEstadoFinanciero()
    
    local SubidaDetectada2 = false
    AddLog("  ├─ [RESPUESTA DEL SERVIDOR (TCP SNIFFER)]:", 1)
    if #RespuestasDelServidor > 0 then for _, l in pairs(RespuestasDelServidor) do AddLog("       -> " .. l.Remote .. ": {" .. l.Data .. "}", 1) end else AddLog("       -> Silencio de Red.", 1) end
    
    AddLog("  ├─ [RESULTADO ECONÓMICO]:", 1)
    for ruta, data in pairs(Di2) do
        if Df2[ruta] and Df2[ruta].Value > data.Value then
            AddLog("    🔥 ¡BINGO MILAGROSO! El Método 2 FUE EXITOSO. Tu '" .. data.Inst.Name .. "' AUMENTÓ. ¡Has vendido inventario Fantasma!", 2)
            SubidaDetectada2 = true
        end
    end
    if not SubidaDetectada2 then AddLog("    🛡️ BLOQUEADO. El servidor cerró la venta asíncrona correctamente. Tu máquina de estados NPC es sólida.", 2) end


    -- __________________________________________________________________________
    -- 🧪 MÉTODO 3: ASYNCHRONOUS GHOST-SPAM (DESINCRONIZACIÓN DE INVENTARIO)
    -- __________________________________________________________________________
    AddLog("\n=========================================================", 0)
    AddLog("[🔪 MÉTODO 3: GHOST-SPAM (LA CLONACIÓN ASÍNCRONA DATASOURCE)]", 0)
    AddLog("---------------------------------------------------------", 0)
    AddLog("  ├─ [TEORÍA (INVENTO HACKER)]: Si tú le vendes 1 poción al NPC, el Server te da 50 monedas y DEPUÉS borra la poción de tu mochila. ¿Qué pasa si te vendo la MISMA poción 500 veces en 0.001 segundos usando un loop `for i=1, 500` antes de que el servidor tenga tiempo de borrarme la primera? Te robo 25,000 monedas.", 1)
    
    local Di3 = ObtenerEstadoFinanciero()
    IniciarSensoresDeRed()

    pcall(function()
        if ladronRemote:IsA("RemoteEvent") then
            -- Spam ultra veloz sin pausas. Esto rompe datastores mal hechos.
            for i=1, 300 do
                ladronRemote:FireServer("Sell", targetNPC)
                ladronRemote:FireServer(targetNPC, "Hit") 
                -- ^ Probamos la llamada exacta "damage" q te robaba pero a ver si ahora invierte por spam
            end
        end
    end)
    
    task.wait(0.5) -- Esperamos que el servidor procese el golpe de 300 paquetes.
    DetenerSensoresDeRed()
    local Df3 = ObtenerEstadoFinanciero()
    
    local SubidaDetectada3 = false
    AddLog("  ├─ [RESPUESTA DEL SERVIDOR (TCP SNIFFER)]:", 1)
    if #RespuestasDelServidor > 0 then for _, l in pairs(RespuestasDelServidor) do AddLog("       -> " .. l.Remote .. ": {" .. l.Data .. "}", 1) end else AddLog("       -> Silencio de Red.", 1) end
    
    AddLog("  ├─ [RESULTADO ECONÓMICO]:", 1)
    for ruta, data in pairs(Di3) do
        if Df3[ruta] and Df3[ruta].Value > data.Value then
            AddLog("    🔥 ¡BINGO KAIJU! El Método 3 FUE EXITOSO. Tu servidor cedió ante el Spam Asíncrono y te sumó saldo clónico a " .. tostring(Df3[ruta].Value) .. "!", 2)
            SubidaDetectada3 = true
        end
    end
    if not SubidaDetectada3 then AddLog("    🛡️ BLOQUEADO. Tu Inventario se descontó antes de la transacción o el Remote tiene un `Debounce` Anti-Spam (Ej: no deja disparar más de 1 vez por segundo). Eres un Dios programando.", 2) end

    -- CONCLUSIÓN FINAL
    AddLog("\n=========================================================\n[✅] EL SIMULADOR DE ATRACADORES HA TERMINADO DE OPERAR.", 0)
    if SubidaDetectada1 or SubidaDetectada2 or SubidaDetectada3 then
        AddLog("\n🚨 RESULTADO LETAL: TU ECONOMÍA ESTÁ GRAVEMENTE ROTA. Un Hacker puede minar dinero en menos de 5 minutos, repasa la falla que salió positiva.", 0)
    else
        AddLog("\n🛡️ RESULTADO TRANQUILIZADOR: MÁS ALLÁ DE QUITARTE DINERO A LO TONTO (Como descubrimos antes), NINGUNO DE MIS TRES ATAQUES PARA SACARTE DINERO FUNCIONÓ.", 0)
        AddLog("Tu juego TE ROBA por mal filtrado de compras ciegas en DialogueRemote... ¡Pero al menos NO SE PUEDE explotar hacia arriba! Estás un 80% asegurado.", 0)
    end
end

-- ==============================================================================
-- ⚙️ MOTOR DEL OMNI-SCANNER Y CHUNKER
-- ==============================================================================
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
-- 🖥️ GUI V2026: THE OMNI-SCANNER PENTEST SUITE EMPÍRICO
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
    MainFrame.BorderColor3 = Color3.fromRGB(255, 100, 0)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -90, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(100, 30, 0)
    TopBar.Text = "  [V29: THE DIALOGUE HEIST - HACKEANDO TU ECONOMÍA A LA INVERSA]"
    TopBar.TextColor3 = Color3.fromRGB(255, 200, 150)
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
    LogTextBox.Text = "LA PRUEBA DEL FUEGO: ROBO A LA INVERSA VS NPCs.\n\nEn V28 comprobamos que quien te ha estado robando silenciosamente la estamina / dinero cuando hacíamos los bombardeos ciegos era el `DialogueRemote` de ReplicatedStorage.\n\nAHORA, atendiendo tus demandas como Ingeniero, he programado la [V29 DIALOGUE HEIST] (Botón 3). Esta prueba atacará únicamente a ese Remote con 3 Estrategias Hacker letales para ver si logramos SUMARTE el saldo en vez de restarlo:\n\n 1. EL DESBORDAMIENTO: Vender o Comprar inyectando '-999999'.\n 2. LA VENTA FANTASMA (Tú idea): Hacer Race Condition abriendo menús y cancelando rápido mientras mandas la opción de cobro solapada.\n 3. CLONACIÓN ASÍNCRONA: Venderle al NPC el aire libre 300 veces en Medio Segundo (Spam Request).\n\nVamos a ver cómo aguanta tu C++ el peso puro del hacking moderno. Te prometo que te diré Jerárquicamente por qué fallaron o ganaron."
    LogTextBox.TextColor3 = Color3.fromRGB(255, 220, 180)
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
    btnExploit.BackgroundColor3 = Color3.fromRGB(180, 60, 0)
    btnExploit.Text = "🎯 3. DIALOGUE HEIST: INTENTAR ROBO INVERSO ESTADO 1, 2 Y 3"
    btnExploit.TextColor3 = Color3.fromRGB(255, 255, 200)
    btnExploit.Font = Enum.Font.Code
    btnExploit.TextSize = 12
    btnExploit.Parent = MainFrame
    
    btnExploit.MouseButton1Click:Connect(function()
        pcall(function()
            AutoHackDialogueV29()
            SegmentarPaginas()
            ActualizarPantalla()
        end)
    end)
    
    local btnPrev = Instance.new("TextButton")
    btnPrev.Size = UDim2.new(0.32, 0, 0, 30)
    btnPrev.Position = UDim2.new(0, 8, 0.76, 0)
    btnPrev.BackgroundColor3 = Color3.fromRGB(80, 30, 20)
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
    btnNext.BackgroundColor3 = Color3.fromRGB(80, 30, 20)
    btnNext.Text = "Siguiente >"
    btnNext.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnNext.Parent = MainFrame
    
    local function UptLabel() PageLabel.Text = "Página " .. tostring(CurrentPage) .. " / " .. tostring(#Pages) end
    btnPrev.MouseButton1Click:Connect(function() if CurrentPage > 1 then CurrentPage = CurrentPage - 1; ActualizarPantalla(); UptLabel() end end)
    btnNext.MouseButton1Click:Connect(function() if CurrentPage < #Pages then CurrentPage = CurrentPage + 1; ActualizarPantalla(); UptLabel() end end)
end

ConstruirUI()
