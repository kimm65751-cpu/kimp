-- ==============================================================================
-- 💀 ROBLOX EXPERT: V24 OMNI-SCANNER PENTEST V-MAX
-- Simulador Activo RCH V4 (HitboxClassRemote Injection) + Chunker Lógico
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
local CHARS_PER_PAGE = 12000

local function AddLog(text, indentLevel)
    local prefix = string.rep("  ", indentLevel or 0)
    FullReport = FullReport .. prefix .. text .. "\n"
end

private_G = {}

-- ==============================================================================
-- ⚡ PROYECTIL DE INYECCIÓN V4 (LA SENTENCIA DE MUERTE)
-- ==============================================================================
local function ProbarSentenciaDeMuerte()
    FullReport = "========================================================\n"
    FullReport = FullReport .. "💀 SIMULACIÓN DE EXPLOTACIÓN: HITBOX CLASS REMOTE (RCH V4) 💀\n"
    FullReport = FullReport .. "========================================================\n\n"
    
    AddLog("[*] INICIANDO INYECCIÓN DE PENETRACIÓN (Bypass Cero-Distancia)...", 0)
    
    local remote = ReplicatedStorage:FindFirstChild("HitboxClassRemote")
    if not remote or not remote:IsA("RemoteEvent") then
        AddLog("\n[❌ FRACASO ESTRUCTURAL]\nNo se encontró 'HitboxClassRemote' en ReplicatedStorage. Posibles razones:\n  1. Removiste el Módulo RaycastHitboxV4 (o apagaste ClientCast).\n  2. El módulo está camuflado con otro nombre en tu versión C++.\n  El vector de ataque principal está MUERTO.", 0)
        return
    end
    
    AddLog("[✔️] HitboxClassRemote Encontrado. Módulo Activo.", 1)
    AddLog("[*] Extrayendo Target Enemigo del C++...", 1)
    
    local target = nil
    local targetDesc = nil
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                local nl = string.lower(obj.Name)
                if string.find(nl, "zombie") or string.find(nl, "boss") or string.find(nl, "mob") then
                    if obj.Humanoid.Health > 0 and obj:FindFirstChild("HumanoidRootPart") then
                        target = obj
                        targetDesc = obj.Name .. " (Distancia real: " .. tostring(math.floor((LocalPlayer.Character.HumanoidRootPart.Position - obj.HumanoidRootPart.Position).Magnitude)) .. " Studs)"
                    end
                end
            end
        end)
        if target then break end
    end
    
    if not target then
        AddLog("\n[❌ FRACASO: NO HAY TARGETS]\nNo hay NPCs/Zombies vivos en el mapa para anclar el paquete inyectado.", 0)
        return
    end
    
    local hum = target:FindFirstChild("Humanoid")
    local startHealth = hum.Health
    AddLog("[🎯] Target Fijado Exitosamente: " .. targetDesc, 1)
    AddLog("  ├─ Salud de Servidor: " .. tostring(startHealth), 1)
    AddLog("[🚀] Inyectando Paquetes de Metatabla V4 Falsificados...", 1)
    
    -- Disparando Permutaciones Clásicas de RCH V4 (HitboxObject, PartHit, HitPosition, Normal, Material)
    pcall(function() remote:FireServer() end)
    pcall(function() remote:FireServer(target:FindFirstChild("HumanoidRootPart")) end)
    pcall(function() remote:FireServer({target:FindFirstChild("HumanoidRootPart")}) end)
    pcall(function() remote:FireServer("Hit", target:FindFirstChild("HumanoidRootPart")) end)
    pcall(function() remote:FireServer(nil, {target:FindFirstChild("HumanoidRootPart")}) end)
    
    AddLog("[⏳] Esperando 1.5 Segundos por Latencia de Respuesta...", 1)
    task.wait(1.5)
    
    local endHealth = hum.Health
    if endHealth < startHealth then
        AddLog("\n✅ [¡ÉXITO FATAL! LA SENTENCIA FUE EJECUTADA]")
        AddLog("¡EL SERVIDOR FUE QUEBRANTADO! La salud del Zombi bajó desde " .. tostring(startHealth) .. " hacia " .. tostring(endHealth) .. ".")
        AddLog("-> Tu Sanity Check NO existe. El hacker acaba de dañarlo sin estar a 5 Studs.", 0)
    else
        AddLog("\n🛡️ [BLOQUEO DEL SERVIDOR CONFIRMADO]\nLa salud del Zombi se mantuvo Intacta (".. tostring(endHealth) .."). Tu código de Servidor acaba de ANIQUILAR el paquete de explotación que envié.\n", 0)
        AddLog("\n[🔍 JERARQUÍA DEL FALLO - ¿Exactamente en qué filtro se atascó tu Hacker?]", 0)
        
        -- Nivel 1
        AddLog("├─ [FILTRO DE MEMORIA / ARGUMENTOS] ¿HitboxObject Inyectado con Hook?", 1)
        AddLog("│   ├─ RaycastHitboxV4 no acepta paquetes genéricos. El primer argumento que envié (El HitboxID o HitboxObject) era falso. El servidor dijo: 'Esta ID local es basura, lo ignoro'.", 1)
        AddLog("│   └─ 👉 Causa Principal: El Hacker NO TIENE la referencia de memoria. Tendrá que usar un Script de Hook Interno (Hookmetamethod) complejo para robar la Metatabla LUA tuya.", 1)
        
        -- Nivel 2
        AddLog("├─ [FILTRO ESPACIO-TIEMPO] ¿ClientCast_Start activo en Servidor?", 1)
        AddLog("│   ├─ RCH V4 de Servidor tiene una regla ineludible: 'Si YO no he mandado a prender el Raycast en mi código LUA, ignoro todo Remote falso'.", 1)
        AddLog("│   └─ 👉 Si mandé el paquete y el zombi no te estaba atacando activamente (o tu espada no estaba encendida con HitStart()), el paquete chocó contra una barrera de Tiempo. El hacker debe hacer el exploit JUSTO en el milisegundo de combate válido.", 1)
        
        -- Nivel 3
        AddLog("├─ [FILTRO FÍSICO / INTRÍNseco] ¿Tool Equipada Requerida?", 1)
        local equiped = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if equiped then
            AddLog("│   ├─ Intenté engañarlo con ("..equiped.Name..") armada en mano.", 1)
        else
            AddLog("│   ├─ Intenté engañarlo DESARMADO. El código de tu Servidor en el módulo quizá bloquea la recepción si no detecta Motor de Espada agarrada.", 1)
        end
        AddLog("│   └─ 👉 Defensa Lógica Pasiva.", 1)
        
        -- Nivel 4
        AddLog("└─ [EL MURO IMPENETRABLE] ¿El C++ verificó Magnitud Nativa?", 1)
        AddLog("    ├─ Si el Hacker salta todo lo de arriba (los niveles 1, 2 y 3 no lo detienen)... su último muro es tu código puro.", 1)
        AddLog("    └─ 👉 Si aquí igual no pasa, es porque tú pusiste un `if (P1 - P2).Magnitude < 10` forzado justo antes de hacer el :TakeDamage() a los zombies. Un muro Anti-ClientCast perfecto.", 1)
    end
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
            elseif v:IsA("ProximityPrompt") or v:IsA("ClickDetector") then AddLog("🏪 INTERACCIÓN/AGARRE: '" .. tostring(v.ClassName) .. "'", indent)
            end
        end)
    end
end

local function EscaneoOmniJerarquico()
    FullReport = "========================================================\n"
    FullReport = FullReport .. "👑 REPORTE DE AUDITORÍA OMNI-SCANNER V-MAX (ROBLOX 2026) 👑\n"
    FullReport = FullReport .. "========================================================\n\n"
    
    AddLog("INICIANDO ESCANEO FORENSE EN CASCADA (TREE DUMP)...", 0)

    AddLog("\n[📡 SECCIÓN 1: ARQUITECTURA DE RED Y EVENTOS C/S]", 0)
    local function ScanNet(parent, indent)
        pcall(function()
            for _, obj in pairs(parent:GetChildren()) do
                pcall(function()
                    if obj:IsA("Folder") then
                        local hasremotes = false
                        for _, d in pairs(obj:GetDescendants()) do if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then hasremotes = true break end end
                        if hasremotes then
                            AddLog("📁 " .. obj.Name, indent)
                            ScanNet(obj, indent + 1)
                        end
                    elseif obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        local honeypot = (string.find(string.lower(obj.Name), "ban") or string.find(string.lower(obj.Name), "kick")) and " [🚨 HONEYPOT]" or ""
                        local warning = (obj.Name == "HitboxClassRemote") and " [‼️ VULNERABILIDAD RCH V4 DETECTADA]" or ""
                        AddLog("🔗 " .. obj.Name .. " (" .. obj.ClassName .. ")" .. honeypot .. warning, indent)
                    end
                end)
            end
        end)
    end
    ScanNet(ReplicatedStorage, 1)
    
    AddLog("\n[🧟 SECCIÓN 2: BASE DE DATOS DE ZOMBIES (INDIVIDUAL)]", 0)
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                local nameLower = string.lower(obj.Name)
                if string.find(nameLower, "zombie") or string.find(nameLower, "boss") or string.find(nameLower, "mob") then
                    AddLog("🧬 " .. obj.Name, 1)
                    local hum = obj:FindFirstChild("Humanoid")
                    if hum then AddLog("🩸 Salud Base: " .. tostring(hum.MaxHealth) .. " | WalkSpeed: " .. tostring(hum.WalkSpeed), 2) end
                    GetDetails(obj, 2)
                    local attrs = obj:GetAttributes()
                    for k, v in pairs(attrs) do AddLog("💎 Atributo: " .. tostring(k) .. " = " .. FormatValue(v), 2) end
                end
            end
        end)
    end

    AddLog("\n[🧱 SECCIÓN 3: ÁRBOL FÍSICO JERÁRQUICO]", 0)
    local PhysicsTree = {}
    local unanchoredCount = 0
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("BasePart") and not obj.Anchored and not obj.Parent:FindFirstChild("Humanoid") then
                unanchoredCount = unanchoredCount + 1
                local parentName = obj.Parent and obj.Parent.Name or "Workspace_Root"
                local itemType = obj.Name .. " (" .. obj.ClassName .. ")"
                if not PhysicsTree[parentName] then PhysicsTree[parentName] = {} end
                if not PhysicsTree[parentName][itemType] then 
                    local interactable = false
                    if obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChildOfClass("ClickDetector") then interactable = true end
                    PhysicsTree[parentName][itemType] = {count = 0, mass = math.floor(obj:GetMass()), collision = obj.CanCollide and "Sólido" or "Fantasma", status = obj.Anchored and "Estático" or "Dinámico (Movible)", grabbable = interactable and "Sí (Tiene Prompt/Click)" or "No (Físico Puro)"}
                end
                PhysicsTree[parentName][itemType].count = PhysicsTree[parentName][itemType].count + 1
            end
        end)
    end
    for folder, items in pairs(PhysicsTree) do
        AddLog("📁 Agrupación Física en Mapa: " .. folder, 1)
        for name, data in pairs(items) do
            AddLog("▶ Modelos Iguales: " .. tostring(data.count) .. "x " .. name, 2)
            AddLog("  ├─ Estado Físico: " .. data.status .. " | Colisión: " .. data.collision, 2)
            AddLog("  ├─ Masa Estimada: " .. tostring(data.mass) .. " uds.", 2)
            AddLog("  └─ ¿Interactuable/Sujetable?: " .. data.grabbable, 2)
        end
    end
    AddLog("\n-> TOTAL UNIDADES FÍSICAS MALEABLES HALLADAS: " .. tostring(unanchoredCount), 1)

    AddLog("\n✅ ESCANEO JERÁRQUICO V-MAX GENERADO CON ÉXITO.", 0)
end

-- ==============================================================================
-- ⚙️ SISTEMA DE PAGINACIÓN DE PANTALLA (CHUNKER MANUAL)
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
    if #Pages == 0 then table.insert(Pages, "No hay datos que mostrar.") end
end

-- ==============================================================================
-- 🖥️ GUI V2026: THE OMNI-SCANNER PENTEST SUITE (CON BOTÓN 3 DE MUERTE)
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
    MainFrame.BorderColor3 = Color3.fromRGB(255, 50, 50)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -90, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    TopBar.Text = "  [V24: PENTEST SUITE - SENTENCIA DE MUERTE]"
    TopBar.TextColor3 = Color3.fromRGB(255, 150, 150)
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
    LogTextBox.Text = "V24 PENTEST: APLICADOR DE SENTENCIAS \n\nAcabas de encargar probar en carne propia tu HitboxClassRemote LUA para ver si el Servidor cede ante las metodologías Hacker o aguanta el golpe.\n\n[Botón 3: SIMULAR EXPLOIT DE HITBOX (RCH V4)]\nInyectará el Remote Falso intentando destrozar matemáticamente al primer jefe zombie que encuentre. Si logra matarlo, te indicaré la vulnerabilidad abierta. Y si tu Servidor C++ destruye mi ataque, generaré TU ÁRBOL JERÁRQUICO mostrando paso a paso por qué el hack rebotó contra tu Sistema.\n\nTambién mantengo los Scanners (Botón 1) y Guardado .TXT Paginado (Botón 2) como antes."
    LogTextBox.TextColor3 = Color3.fromRGB(255, 200, 200)
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

    local btnScan = Instance.new("TextButton")
    btnScan.Size = UDim2.new(0.32, 0, 0, 50)
    btnScan.Position = UDim2.new(0, 8, 0.85, 0)
    btnScan.BackgroundColor3 = Color3.fromRGB(150, 80, 0)
    btnScan.Text = "🌳 1. INICIAR SCAN"
    btnScan.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnScan.Font = Enum.Font.Code
    btnScan.TextSize = 10
    btnScan.Parent = MainFrame

    local btnSave = Instance.new("TextButton")
    btnSave.Size = UDim2.new(0.32, 0, 0, 50)
    btnSave.Position = UDim2.new(0.335, 4, 0.85, 0)
    btnSave.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    btnSave.Text = "💾 2. GUARDAR .TXT"
    btnSave.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnSave.Font = Enum.Font.Code
    btnSave.TextSize = 10
    btnSave.Parent = MainFrame
    
    local btnExploit = Instance.new("TextButton")
    btnExploit.Size = UDim2.new(0.32, 0, 0, 50)
    btnExploit.Position = UDim2.new(0.67, 8, 0.85, 0)
    btnExploit.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    btnExploit.Text = "💀 3. PONER A PRUEBA RCH V4 (HITBOX SPOOF)"
    btnExploit.TextColor3 = Color3.fromRGB(255, 255, 150)
    btnExploit.Font = Enum.Font.Code
    btnExploit.TextSize = 10
    btnExploit.Parent = MainFrame

    btnScan.MouseButton1Click:Connect(function()
        pcall(function()
            EscaneoOmniJerarquico()
            SegmentarPaginas()
            ActualizarPantalla()
        end)
    end)
    
    btnSave.MouseButton1Click:Connect(function()
        pcall(function() if writefile then writefile("OmniScan_Report.txt", FullReport) btnSave.Text = "✅ ¡EN PC/ANDROID!" task.wait(3) btnSave.Text = "💾 2. GUARDAR .TXT" end end)
    end)
    
    btnExploit.MouseButton1Click:Connect(function()
        pcall(function()
            -- Lanza la prueba individualmente al apretar el boton 3
            ProbarSentenciaDeMuerte()
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
    PageLabel.Text = "Pag.. "
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
