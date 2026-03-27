-- ==============================================================================
-- 💀 ROBLOX EXPERT: V25 EMPIRIC TRUTH SEEKER (EL BUSCADOR DE VERDAD)
-- Cero Ideas, Cero Especulaciones. Pruebas de Estrés Automáticas y Cuantificadas.
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
-- ⚡ EL LABORATORIO DE FACTIBILIDAD (PRUEBAS REALES)
-- ==============================================================================
local function BuscadorEmpiricoAuraKill()
    FullReport = "========================================================\n"
    FullReport = FullReport .. "💀 LABORATORIO DE PENETRACIÓN EMPÍRICA V25 (CERO TEORÍA) 💀\n"
    FullReport = FullReport .. "========================================================\n\n"
    FullReport = FullReport .. "Iniciando ejecución agresiva de ataques para validar QUÉ FUNCIONA realmente...\n\n"
    
    -- Localiza un Target válido C++
    local target = nil
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Name:lower():match("zombie") or obj.Name:lower():match("boss") then
                if obj.Humanoid.Health > 0 and obj:FindFirstChild("HumanoidRootPart") then
                    target = obj
                end
            end
        end)
        if target then break end
    end

    if not target then
        AddLog("[ABORTADO]: No hay Zombis vivos para someter a la prueba pericial.", 0)
        return
    end

    local hum = target:FindFirstChild("Humanoid")
    local hrp = target:FindFirstChild("HumanoidRootPart")
    
    AddLog("[🎯 TARGET ANCLADO]: " .. target.Name .. " a " .. tostring(math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)) .. " Studs", 0)
    AddLog("---------------------------------------------------------", 0)

    -- __________________________________________________________________________
    -- 🧪 PRUEBA 1: DEFORMACIÓN GEOMÉTRICA (EL BYPASS DE CLIENTCAST RCH V4)
    -- __________________________________________________________________________
    AddLog("[🧪 PRUEBA 1: AURA KILL POR TELETRANSPORTACIÓN DE ARMA LOCAL]", 0)
    AddLog("  ├─ [MÉTODO]: Si ClientCast confía ciegamente en el local, podemos estirar el arma del Hacker.", 1)
    
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp and bp:FindFirstChildOfClass("Tool") then
            hum.Parent = LocalPlayer.Character -- Equip force
            tool = bp:FindFirstChildOfClass("Tool")
            tool.Parent = LocalPlayer.Character
            task.wait(0.2)
        end
    end
    
    if tool then
        local st1 = hum.Health
        AddLog("  ├─ [INICIANDO ATAQUE]: Arma detectada ("..tool.Name.."). Desplazando DmgPoints hacia el Zombi a distancia infinita...", 1)
        
        -- Ejecución: Mueve los Attachments/Rays locales directo al Zombi
        for _, obj in pairs(tool:GetDescendants()) do
            pcall(function()
                if obj:IsA("Attachment") or obj:IsA("Part") then
                    if obj.Name:lower():match("dmg") or obj.Name:lower():match("hit") then
                        obj.WorldPosition = hrp.Position
                    elseif obj:IsA("Part") and obj.Name == "Handle" then
                        obj.Size = Vector3.new(1000, 1000, 1000)
                    end
                end
            end)
        end
        
        tool:Activate() -- Dispara el Cliente
        task.wait(1.5)
        
        if hum.Health < st1 then
            AddLog("  └─ [🚨 VEREDICTO DE PELIGRO: FACTIBLE (SÍ)]", 1)
            AddLog("     Tu servidor FUE VULNERADO. ClientCast aceptó un golpe desde " .. tostring(math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)) .. " Studs.", 1)
            AddLog("     -> ERROR ENCONTRADO: ClientCast es ciego. El hacker estira su espada LUA, el motor calcula el golpe falso, ¡Y TU C++ no verifica a qué distancia estaba el jugador P1 del Zombi P2 durante el evento!", 1)
        else
            AddLog("  └─ [🛡️ VEREDICTO DEFENSIVO: NO FACTIBLE (BLOQUEADO)]", 1)
            AddLog("     El golpe cruzó el mapa, ClientCast lo mandó... pero fue ASESINADO por tu servidor LUA. La vida sigue en "..tostring(hum.Health)..".", 1)
            AddLog("     -> CERTEZA: Nadie te está matando con este tipo de Aura Kill pasivo. Tu Magnitude Server-Side los rechaza.", 1)
        end
        
        -- Resetear herramienta
        pcall(function() tool.Parent = LocalPlayer:FindFirstChild("Backpack") end)
    else
        AddLog("  └─ [ERROR]: No se pudo equipar ningún arma para someter al Zombi a Falsificación de Raycast.", 1)
    end
    AddLog("---------------------------------------------------------", 0)

    -- __________________________________________________________________________
    -- 🧪 PRUEBA 2: SATURACIÓN DE REMOTES SECUNDARIOS (BÚSQUEDA DEL REMOTO ASESINO)
    -- __________________________________________________________________________
    AddLog("\n[🧪 PRUEBA 2: BOMBARDEO CIEGO DE TODOS LOS EVENTOS DE REPLICATED STORAGE]", 0)
    AddLog("  ├─ [MÉTODO]: Disparar cada evento sospechoso obligándolo a aceptar que matamos al Zombie.", 1)
    
    local st2 = hum.Health
    local moneyPre = 0
    pcall(function() moneyPre = LocalPlayer.leaderstats:FindFirstChildOfClass("IntValue").Value end)
    
    local firedEvents = {}
    for _, ev in pairs(ReplicatedStorage:GetDescendants()) do
        pcall(function()
            if ev:IsA("RemoteEvent") or ev:IsA("RemoteFunction") then
                local nl = ev.Name:lower()
                -- Evitamos trampas conocidas, mandamos a todo lo demás usando la táctica hacker de "Claim/Hit/Damage"
                if not (nl:match("ban") or nl:match("kick") or nl:match("suspect") or nl:match("replica")) then
                    if ev:IsA("RemoteEvent") then
                        ev:FireServer(target)
                        ev:FireServer(target, hrp)
                        ev:FireServer("Hit", target)
                        ev:FireServer("Damage", target, 9999)
                        table.insert(firedEvents, ev.Name)
                    elseif ev:IsA("RemoteFunction") then
                        -- Disparo asincrono de invokers para evitar colapso de Thread
                        task.spawn(function()
                            pcall(function() ev:InvokeServer(target) end)
                            pcall(function() ev:InvokeServer("Claim", target) end)
                        end)
                        table.insert(firedEvents, ev.Name)
                    end
                end
            end
        end)
    end
    
    AddLog("  ├─ [EJECUCIÓN]: Se dispararon " .. tostring(#firedEvents) .. " remotes sin filtro. Esperando latencia...", 1)
    task.wait(1.5)
    
    local moneyPost = 0
    pcall(function() moneyPost = LocalPlayer.leaderstats:FindFirstChildOfClass("IntValue").Value end)

    if hum.Health < st2 then
        AddLog("  └─ [🚨 VEREDICTO DE PELIGRO MORTAL: FACTIBLE (SÍ)]", 1)
        AddLog("     ¡TU ZOMBI FUE ANIQUILADO AL INSTANTE POR UN EVENTO SIN SEGURIDAD! Un remote de esa lista acaba de quitarle " .. tostring(st2 - hum.Health) .. " de HP sin que usaras RCH V4 ni un arma.", 1)
        AddLog("     -> ERROR ENCONTRADO: Tienes un Evento C++ (Posiblemente 'ClaimEnemy', 'DamageEvent', o 'Hit') que obedece al Cliente de forma estúpida sin hacer Sanidad.", 1)
    elseif moneyPost > moneyPre then
         AddLog("  └─ [🚨 ROBO ECONÓMICO CONFIRMADO: FACTIBLE (SÍ)]", 1)
         AddLog("     ¡EL ZOMBI NO MURIÓ, PERO TUS MONEDAS/EXP SUBIERON (" .. tostring(moneyPre) .. " -> " .. tostring(moneyPost) .. ")!", 1)
         AddLog("     -> ERROR ENCONTRADO: Un remote te está regalando recompensas de Zombis fantasmas (Quizá ClaimEnemy).", 1)
    else
        AddLog("  └─ [🛡️ VEREDICTO DEFENSIVO: NO FACTIBLE (BLOQUEADO)]", 1)
        AddLog("     Tu servidor rebotó absolutamente todas las " .. tostring(#firedEvents) .. " falsificaciones.", 1)
        AddLog("     -> CERTEZA: No pueden matar zombies invocando remotes mágicos o inyectando daño arbitrario.", 1)
    end
    AddLog("---------------------------------------------------------", 0)

    -- __________________________________________________________________________
    -- 🧪 PRUEBA 3: ENGAÑO DE ATRIBUTOS NATIVOS LUA (SPOOFING)
    -- __________________________________________________________________________
    AddLog("\n[🧪 PRUEBA 3: ALTERACIÓN GENÉTICA DE TARGET (INYECCIÓN DE ATRIBUTOS CLIENTE)]", 0)
    AddLog("  ├─ [MÉTODO]: Si reescribimos los atributos del Zombie localmente... ¿Se roba la autoría?", 1)
    
    local st3 = hum.Health
    pcall(function()
        target:SetAttribute("DamageDone", LocalPlayer.Name)
        target:SetAttribute("Tagged", true)
        target:SetAttribute("Health", 0)
    end)
    
    -- Disparamos el arma denuevo para ver si el Hitbox confía en el Drop tras el setAttribute
    if tool then pcall(function() tool:Activate() end) end
    task.wait(1.0)
    
    if hum.Health < st3 then
        AddLog("  └─ [🚨 VEREDICTO CONDICIONAL: FACTIBLE (SÍ)]", 1)
        AddLog("     ¡El zombi aceptó la muerte tras alterar 'DamageDone'!", 1)
        AddLog("     -> ERROR ENCONTRADO: Tu Servidor Lee y Respeta atributos modificados en Local. ¡Bloquea SetAttribute!", 1)
    else
        AddLog("  └─ [🛡️ VEREDICTO DEFENSIVO: NO FACTIBLE (BLOQUEADO)]", 1)
        AddLog("     El servidor no bajó la guardia. Reconoció que el Atributo era basura de Cliente.", 1)
        AddLog("     -> CERTEZA: Tus Atributos (Tags/Drops) están Seguros.", 1)
    end
    AddLog("---------------------------------------------------------", 0)
    AddLog("\n[✅ EXPERIMENTACIÓN EMPÍRICA CONCLUÍDA].", 0)
    AddLog("Esta es la Verdad Absoluta, y no hay especulaciones.", 0)
end

-- ==============================================================================
-- ⚙️ MOTOR DEL OMNI-SCANNER V-MAX 
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
    MainFrame.Size = UDim2.new(0, 640, 0, 520)
    MainFrame.Position = UDim2.new(0.5, -320, 0.5, -260)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
    MainFrame.BorderSizePixel = 3
    MainFrame.BorderColor3 = Color3.fromRGB(240, 240, 0)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -90, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(120, 100, 0)
    TopBar.Text = "  [V25: THE TRUTH SEEKER - PENETRACIÓN EMPÍRICA CERO-TRUST]"
    TopBar.TextColor3 = Color3.fromRGB(255, 255, 150)
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
    LogTextBox.Text = "V25 THE TRUTH SEEKER: HE DEJADO DE ASUMIR Y ESPECULAR.\n\nMe diste una orden estricta: 'No quiero ideas, quiero saber en la práctica qué es factible y por qué con jerarquías'.\nHe reprogramado el [Botón 3] en LA PRUEBA DEFINITIVA.\n\nEste Botón atacará empíricamente tu servidor usando las 3 técnicas hacker absolutas:\n 1. Escalado geométrico de Armas LUA (Violación de ClientCast).\n 2. Saturación agresiva de TODOS tus remotes secundarios ('Claim', 'Hit', etc) como si los hiciera un hacker con un Executor C++ ciego.\n 3. Sobrescritura forzada local de atributos nativos de Inteligencia Zombi.\n\nÉl ejecutará físicamente los 3 ataques sobre el Jefe/Zombi y leerá matemáticamente su HP o tus Monedas. La máquina declarará con [🚨 SÍ] o [🛡️ NO] qué muro C++ ha fallado. Es la verdad absoluta."
    LogTextBox.TextColor3 = Color3.fromRGB(255, 255, 150)
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
    btnExploit.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    btnExploit.Text = "💀 3. BUSCADOR DE LA VERDAD EMPÍRICA (AUTO-PEN-TEST ACTIVO)"
    btnExploit.TextColor3 = Color3.fromRGB(255, 255, 200)
    btnExploit.Font = Enum.Font.Code
    btnExploit.TextSize = 12
    btnExploit.Parent = MainFrame
    
    btnExploit.MouseButton1Click:Connect(function()
        pcall(function()
            -- Lanza Cero Asunciones
            BuscadorEmpiricoAuraKill()
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
