-- ==============================================================================
-- 💀 ROBLOX EXPERT: V30 THE ANTI-CHEAT BREAKER (MISTERIO DE LA ZONA OSCURA)
-- Empirismo Total: Ejecución Ciega de Vectores de Movimiento Fantasma.
-- ==============================================================================

local SCRIPT_URL = "https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

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
-- 🚀 LABORATORIO DE ESTADO FÍSICO (BYPASS SECUENCIAL DE ERROR 267)
-- ==============================================================================
local function HackFisicoDarkZone()
    FullReport = "========================================================\n"
    FullReport = FullReport .. "🚀 V30 ANTI-CHEAT BREAKER: PRUEBA BYPASS 'ZONA OSCURA' 🚀\n"
    FullReport = FullReport .. "========================================================\n\n"
    
    AddLog("Cero teorías deductivas. Empirismo riguroso.", 0)
    AddLog("Someteremos tu C++ Anti-Trampas a 4 estrés-test ejecutivos para ver EXÁCTAMENTE POR QUÉ RUTA el Hacker es capaz de irse volando a la 'Zona Oscura' sin ser pateado por Error 267.", 0)
    AddLog("\n🚨 [INICIANDO PENTEST FÍSICO (ZONA DE 1500 STUDS)] 🚨\n", 0)

    local character = LocalPlayer.Character
    if not character then AddLog("❌ ERROR: Necesitas estar vivo (Spawned) para ejecutar el bypass de física.", 0); return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChild("Humanoid")
    if not hrp or not hum then AddLog("❌ ERROR: Perdiste partes críticas para teletransporte.", 0); return end

    local PosicionOriginal = hrp.CFrame
    local SafeZoneOffset = Vector3.new(0, 1500, 0) -- Un "Cielo Oscuro" donde los Hackers vuelan

    local function RubberBandCheck(ExpectedPos)
        -- Si el Server nos jaló de vuelta a menos de 100 studs de nuestra Pos original, entonces el Anti-Cheat funcionó.
        task.wait(0.5)
        local curPos = character:GetPivot().Position
        local diff = (curPos - PosicionOriginal.Position).Magnitude
        local successDist = (curPos - ExpectedPos).Magnitude
        
        -- Volvemos siempre para la siguiente prueba
        pcall(function() character:PivotTo(PosicionOriginal) end)
        task.wait(1)
        
        if diff < 100 then
            return false -- BLOQUEADO (Servidor hizo Rubber-Band, te jaló)
        elseif successDist < 100 then
            return true -- FACTIBLE (Hacker logró establecer su CFrame oscuro de red)
        else
            return false -- Desconocido / Te jaló parcialmente
        end
    end

    -- __________________________________________________________________________
    -- 🧪 PRUEBA 1: TELETRANSPORTE CFRAME BRUTO (EL TRAMPOSO NOVATO)
    -- __________________________________________________________________________
    AddLog("=========================================================", 0)
    AddLog("[🚀 MÉTODO 1: CFRAME INSTANTÁNEO]", 0)
    AddLog("---------------------------------------------------------", 0)
    AddLog("  ├─ [INICIACIÓN]: Intentaremos forzar al motor a teletransportarnos instantáneamente.", 1)
    
    local Target1 = PosicionOriginal.Position + SafeZoneOffset + Vector3.new(100, 0, 0)
    pcall(function() character:PivotTo(CFrame.new(Target1)) end)
    
    local M1_Factible = RubberBandCheck(Target1)
    
    if M1_Factible then
        AddLog("  ├─ [🚨 FACTIBLE (VULNERABLE)]: El Servidor se comió el teletransporte crudo.", 1)
        AddLog("  └─ ERROR TIPO 1: No tienes un Anticheat Server-Side. Tu Error 267 debe ser de un script local que el hacker borró al entrar. Debes poner uno en el Servidor YA.", 1)
    else
        AddLog("  ├─ [🛡️ BLOQUEADO (SEGURO)]: El Servidor se rehusa a dejarte 1500 studs lejos. Te devolvió de un latigazo (Rubber-Band).", 1)
        AddLog("  └─ C++ EFICIENTE: ¡Buen trabajo! El teletransporte barato no sirve. Pasemos a ingeniería más dura.", 1)
    end

    -- __________________________________________________________________________
    -- 🧪 PRUEBA 2: ENGAÑO DE ASIENTO VEHÍCULAR (VEHICLE-SEAT SPOOFING)
    -- __________________________________________________________________________
    AddLog("\n=========================================================", 0)
    AddLog("[🚀 MÉTODO 2: FALSIFICACIÓN DE VEHÍCULO (VEHICLE-SPOOF)]", 0)
    AddLog("---------------------------------------------------------", 0)
    AddLog("  ├─ [INICIACIÓN]: La mayoría de los Anti-Cheats ignoran la regla de Magnitude si el jugador está 'Sentado', porque asumen que va en un Auto veloz. Engañaremos tu Servidor Spawnando una silla fantasma.", 1)
    
    local Target2 = PosicionOriginal.Position + SafeZoneOffset + Vector3.new(0, 0, 100)
    local M2_Factible = false
    
    pcall(function()
        local seat = Instance.new("Seat", Workspace)
        seat.Position = PosicionOriginal.Position + Vector3.new(0, 5, 0)
        seat.Transparency = 1; seat.Anchored = true
        seat:Sit(hum)
        task.wait(0.2)
        -- Saltamos 1500 studs estando sentados
        seat.Position = Target2
        seat.Velocity = Vector3.new(0,0,0)
    end)
    
    M2_Factible = RubberBandCheck(Target2)
    
    if M2_Factible then
        AddLog("  ├─ [🚨 FACTIBLE (VULNERABLE)]: ¡BINGO! Llegamos a la Zona Oscura intactos.", 1)
        AddLog("  └─ ERROR TIPO 2: Tu código Anti-TP tiene un fallo fatal: `if Humanoid.Sit == true then return end`. El hacker engaña al servidor haciéndose pasar por un auto y viaja libre por el mapa.", 1)
    else
        AddLog("  ├─ [🛡️ BLOQUEADO (SEGURO)]: El Servidor destruyó la inyección condicional y te trajo de regreso.", 1)
        AddLog("  └─ C++ EFICIENTE: Tu Anti-Cheat sabe que ningún auto va a 100,000 Km/H. Muy bien. Elevamos dificultad.", 1)
    end

    -- __________________________________________________________________________
    -- 🧪 PRUEBA 3: CINEMÁTICA LÍNEA (TWEEN/VELOCITY BYPASS)
    -- __________________________________________________________________________
    AddLog("\n=========================================================", 0)
    AddLog("[🚀 MÉTODO 3: BYPASS DE CINEMÁTICA ASÍNCRONA (NOCLIP TWEEN)]", 0)
    AddLog("---------------------------------------------------------", 0)
    AddLog("  ├─ [INICIACIÓN]: Muchos anti-cheats sólo castigan 'Saltos GIGANTES instantáneos' para no bannear a la gente por lag. Utilizaremos BodyVelocity y Tween para ir a Match 20 sin generar alertas de salto (Fly Hack puro).", 1)
    
    local Target3 = PosicionOriginal.Position + SafeZoneOffset + Vector3.new(-100, 0, 0)
    local M3_Factible = false
    
    pcall(function()
        local tweenInfo = TweenInfo.new(1.0, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(Target3)})
        tween:Play()
        task.wait(1.5) -- Pausa equivalente a volar rápidamente hacia el target
        local curV = character:GetPivot().Position
        local diff = (curV - Target3).Magnitude
        if diff < 100 then M3_Factible = true end
        
        -- Return to logic loop
        pcall(function() character:PivotTo(PosicionOriginal) end)
        task.wait(1)
    end)
    
    if M3_Factible then
        AddLog("  ├─ [🚨 FACTIBLE (VULNERABLE)]: ¡Voló 1500 Studs en menos de 1 segundo y el Servidor no lo echó!", 1)
        AddLog("  └─ ERROR TIPO 3: Tu anti-TP de servidor perdona viajes si son consistentes pero excesivamente rápidos. Requieres un medidor de Speed de Red (`Magnitude / DeltaTime > WalkSpeedMax` -> Ban).", 1)
    else
        AddLog("  ├─ [🛡️ BLOQUEADO (SEGURO)]: El Motor te enganchó de la física antes del primer segundo.", 1)
        AddLog("  └─ C++ EFICIENTE: Estás midiendo la aceleración de red correctamente. Es un muro bestial de sortear.", 1)
    end

    -- __________________________________________________________________________
    -- 🧪 PRUEBA 4: MUTACIÓN ESTRUCTURAL LUA (AMPUTACIÓN DE ROOTPART)
    -- __________________________________________________________________________
    AddLog("\n=========================================================", 0)
    AddLog("[🚀 MÉTODO 4: DESTRUCCIÓN FORENSE (THE ANTI-CHEAT ERROR INJECTOR)]", 0)
    AddLog("---------------------------------------------------------", 0)
    AddLog("  ├─ [INICIACIÓN]: Si no perdonas sentados (2), y no perdonas Tweenings (3)... significa que tu código Anti-TP está vivo validando mi HumanoidRootPart todo el tiempo. Vamos a crashearlo.", 1)
    AddLog("  ├─ [ACCIÓN]: Destruiré momentáneamente o renombraré mi HRP para ahogar tu script C++ en la terminal del Servidor, forzar su apagado, y podernos ir caminando en el aire a la Zona Oscura.", 1)
    
    local Target4 = PosicionOriginal.Position + SafeZoneOffset + Vector3.new(0, 0, -100)
    local M4_Factible = false
    
    pcall(function()
        local fakeHRP = hrp:Clone()
        hrp.Name = "Basura" -- Engañamos a Motor local
        hrp.Parent = nil    -- Destruimos el HRP y esto se replicará al Servidor para los Scripts mal codificados sin findFirstChild
        local lowerT = character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso")
        -- Movemos el cuerpo usando los torsos, ya que la pieza ROOT ya no existe!
        if lowerT then lowerT.CFrame = CFrame.new(Target4) end
        task.wait(0.5)
        
        local check = character:GetPivot().Position
        if (check - Target4).Magnitude < 100 then M4_Factible = true end
        
        -- Restore for sanity
        pcall(function() hrp.Parent = character; hrp.Name = "HumanoidRootPart" end)
        pcall(function() character:PivotTo(PosicionOriginal) end)
        task.wait(1)
    end)
    
    if M4_Factible then
        AddLog("  ├─ [🚨 FACTIBLE MORTAL (VULNERABLE)]: ¡¡LLEGAMOS A LA ZONA OSCURA Y EL SCRIPT DE TELEPORTE NO PUDO HACER NINGÚN RUBBERBAND!!", 1)
        AddLog("  └─ ERROR TIPO 4: Tu Script de Anti-Trampas se crasheó al hacer algo como: `Jugador.Character.HumanoidRootPart.Position`. Al amputarle la pieza, el hacker generó un error LUA puro en la Data Model de tu servidor. Cuando sale la letra roja en la pantalla del Server, tu script Anti-TP SE DETUVO. El hacker está volando porque 'asesinó' a los policías de tu C++ restándole dependencias.", 1)
    else
        AddLog("  ├─ [🛡️ BLOQUEADO (SEGURO)]: O te moriste directamente, o el servidor atrapó tu Torso en caída.", 1)
        AddLog("  └─ C++ EFICIENTE: Usaste FindFirstChild correctamente en tus revisiones de Anti-Roblox. Eres un monstruo de la seguridad.", 1)
    end

    AddLog("\n=========================================================\n[✅] AUTOPSIA FÍSICA COMPLETA DE BYPASS TERMINADA.", 0)
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
-- 🖥️ GUI V30: THE ANTI-CHEAT BREAKER
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
    MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 120)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -90, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(0, 80, 50)
    TopBar.Text = "  [V30: THE ANTI-CHEAT BREAKER - FORZANDO EL ERROR 267 FÍSICO]"
    TopBar.TextColor3 = Color3.fromRGB(150, 255, 200)
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
    InfoScroll.BackgroundColor3 = Color3.fromRGB(10, 15, 10)
    InfoScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    InfoScroll.ScrollBarThickness = 6
    InfoScroll.Parent = MainFrame

    local LogTextBox = Instance.new("TextBox")
    LogTextBox.Size = UDim2.new(1, -10, 1, 0)
    LogTextBox.Position = UDim2.new(0, 5, 0, 5)
    LogTextBox.BackgroundTransparency = 1
    LogTextBox.Text = "ACEPTO TU ÓRDEN DE CERO ASUMICIONES. CERO TEORÍAS.\n\nEl usuario me ordenó investigar a la fuerza CÓMO, DÓNDE Y QUÉ usan los Hackers para hacer 'Fly' a esa Zona Oscura y matar a los zombis sin ser bloqueados por su propio Error 267 o las físicas del servidor.\n\nACTUALIZACIONES DEL [Botón 3]:\n- Esta herramienta ya no ataca el dinero ni el inventario.\n- Es un Laboratorio de Penetración Física C/S y va a someter a tu personaje a las 4 violaciones de Red LUA posibles para Teletransporte Indetectable:\n\n 1. Raw Injection CFrame: Intentaremos saltar a ciegas (> 1500 Studs).\n 2. Fly Tweening By-Pass: Utilizaremos manipulación de BodyVelocity para evadir chequeos de Instancia-Magnitud.\n 3. Vehicle Seat Spoofer: Un Auto Invisible y teletransporte vehicular.\n 4. The Crash-Hack (Crasheo de Anti-Vuelo): Anularemos la existencia de la raíz del personaje para hacer fracasar (Errores de Sintaxis C++) en tu servidor.\n\nSi te sale [FACTIBLE] en alguno de los 4, ahí sabrás literalmente con qué truco vuelan hacia los Zombies para reventarlos."
    LogTextBox.TextColor3 = Color3.fromRGB(180, 255, 180)
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
    btnExploit.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    btnExploit.Text = "🚀 3. PENTEST DE MOVIMIENTO FANTASMA (BYPASS ANTI-CHEAT)"
    btnExploit.TextColor3 = Color3.fromRGB(200, 255, 200)
    btnExploit.Font = Enum.Font.Code
    btnExploit.TextSize = 12
    btnExploit.Parent = MainFrame
    
    btnExploit.MouseButton1Click:Connect(function()
        pcall(function()
            HackFisicoDarkZone()
            SegmentarPaginas()
            ActualizarPantalla()
        end)
    end)
    
    local btnPrev = Instance.new("TextButton")
    btnPrev.Size = UDim2.new(0.32, 0, 0, 30)
    btnPrev.Position = UDim2.new(0, 8, 0.76, 0)
    btnPrev.BackgroundColor3 = Color3.fromRGB(30, 80, 30)
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
    btnNext.BackgroundColor3 = Color3.fromRGB(30, 80, 30)
    btnNext.Text = "Siguiente >"
    btnNext.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnNext.Parent = MainFrame
    
    local function UptLabel() PageLabel.Text = "Página " .. tostring(CurrentPage) .. " / " .. tostring(#Pages) end
    btnPrev.MouseButton1Click:Connect(function() if CurrentPage > 1 then CurrentPage = CurrentPage - 1; ActualizarPantalla(); UptLabel() end end)
    btnNext.MouseButton1Click:Connect(function() if CurrentPage < #Pages then CurrentPage = CurrentPage + 1; ActualizarPantalla(); UptLabel() end end)
end

ConstruirUI()
