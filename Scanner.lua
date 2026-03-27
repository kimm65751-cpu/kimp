-- ==============================================================================
-- 💀 ROBLOX EXPERT: V22 OMNI-SCANNER V-MAX (ÁRBOL JERÁRQUICO + COPIADO)
-- Anti-Crashes Integrado (Pcalls Extra) + Botón de Copiado Restaurado.
-- ==============================================================================

local SCRIPT_URL = "https://raw.githubusercontent.com/kimm65751-cpu/kimp/refs/heads/main/Scanner.lua"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local FullReport = ""

local function AddLog(text, indentLevel)
    local prefix = string.rep("  ", indentLevel or 0)
    FullReport = FullReport .. prefix .. text .. "\n"
end

-- ==============================================================================
-- ⚙️ MOTOR DEL OMNI-SCANNER V-MAX (A PRUEBA DE CRASHES)
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
            elseif v:IsA("ProximityPrompt") then AddLog("🏪 INTERACCIÓN: '" .. tostring(v.ActionText) .. "'", indent)
            elseif v:IsA("ClickDetector") then AddLog("🏪 AGARABLE: '" .. tostring(v.ClassName) .. "'", indent)
            end
        end)
    end
end

local function EscaneoOmniJerarquico()
    FullReport = "========================================================\n"
    FullReport = FullReport .. "👑 REPORTE DE AUDITORÍA OMNI-SCANNER V-MAX (ROBLOX 2026) 👑\n"
    FullReport = FullReport .. "========================================================\n\n"
    
    AddLog("INICIANDO ESCANEO FORENSE EN CASCADA (TREE DUMP)...", 0)

    -- ------------------------------------------------------------------
    -- 1. ANÁLISIS DE NETWORK / REMOTES (ESPECIALIZADO)
    -- ------------------------------------------------------------------
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
    
    -- ------------------------------------------------------------------
    -- 2. ANÁLISIS DE MOBS Y BASE DE DATOS ZOMBIE
    -- ------------------------------------------------------------------
    AddLog("\n[🧟 SECCIÓN 2: BASE DE DATOS DE ZOMBIES (INDIVIDUAL)]", 0)
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                local nameLower = string.lower(obj.Name)
                if string.find(nameLower, "zombie") or string.find(nameLower, "boss") or string.find(nameLower, "mob") then
                    AddLog("🧬 " .. obj.Name, 1)
                    local hum = obj:FindFirstChild("Humanoid")
                    if hum then
                        AddLog("🩸 Salud Base: " .. tostring(hum.MaxHealth) .. " | WalkSpeed: " .. tostring(hum.WalkSpeed), 2)
                    end
                    GetDetails(obj, 2)
                    
                    local hasTouch = false
                    for _, v in pairs(obj:GetDescendants()) do 
                        if v:IsA("TouchTransmitter") then hasTouch = true end
                        if v:IsA("ValueBase") then AddLog("💎 Atributo Interno: " .. v.Name .. " = " .. FormatValue(v.Value), 2) end
                    end
                    if hasTouch then AddLog("⚔️ Usa TouchTransmitters (.Touched activo).", 2) else AddLog("⚔️ Usa Magnitude (Matemático Puro).", 2) end
                    
                    local attrs = obj:GetAttributes()
                    for k, v in pairs(attrs) do AddLog("💎 Atributo Oculto (Propiedad): " .. tostring(k) .. " = " .. FormatValue(v), 2) end
                end
            end
        end)
    end

    -- ------------------------------------------------------------------
    -- 3. ECONOMÍA, TIENDAS, EVENTOS HUMANOS Y DROP RATES
    -- ------------------------------------------------------------------
    AddLog("\n[💰 SECCIÓN 3: TIENDAS, ECONOMÍA Y DROPS]", 0)
    for _, obj in pairs(Workspace:GetDescendants()) do
        pcall(function()
            local nameLower = string.lower(obj.Name)
            if obj:IsA("Model") and (string.find(nameLower, "shop") or string.find(nameLower, "npc") or string.find(nameLower, "store") or string.find(nameLower, "vendor")) then
                AddLog(" 🏪 Tienda/NPC Hallado: " .. obj.Name, 1)
                for _, prompt in pairs(obj:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        AddLog("   - Interacción: '" .. tostring(prompt.ActionText) .. "' (Rango: " .. tostring(prompt.MaxActivationDistance) .. ")", 2)
                    elseif prompt:IsA("ValueBase") then
                        AddLog("   - Dato Comercial: " .. prompt.Name .. " = " .. FormatValue(prompt.Value), 2)
                    end
                end
            elseif string.find(nameLower, "chest") or string.find(nameLower, "drop") or string.find(nameLower, "rate") then
                 AddLog(" 💎 Loot/Cofre Detectado: " .. obj.Name, 1)
                 for _, v in pairs(obj:GetDescendants()) do
                     if v:IsA("NumberValue") or v:IsA("IntValue") then
                         AddLog("   - Probabilidad/Valor: " .. v.Name .. " = " .. FormatValue(v.Value), 2)
                     end
                 end
            end
        end)
    end

    -- ------------------------------------------------------------------
    -- 4. ÁRBOL FÍSICO (OBJETOS SUELTOS Y TELEKINESIS)
    -- ------------------------------------------------------------------
    AddLog("\n[🧱 SECCIÓN 4: ÁRBOL DE OBJETOS FÍSICOS (TELEKINESIS LUA)]", 0)
    AddLog("Detallando qué objetos se pueden mover libremente, su Masa y Estados de Agarre:", 0)
    
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
                    
                    PhysicsTree[parentName][itemType] = {
                        count = 0, 
                        mass = math.floor(obj:GetMass()),
                        collision = obj.CanCollide and "Sólido" or "Fantasma",
                        status = obj.Anchored and "Estático" or "Dinámico (Movible)",
                        grabbable = interactable and "Sí (Tiene Prompt/Click)" or "No (Físico Puro)"
                    }
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
            AddLog("  ├─ Masa Estimada: " .. tostring(data.mass) .. " uds. de motor.", 2)
            AddLog("  └─ ¿Interactuable/Sujetable?: " .. data.grabbable, 2)
        end
    end
    AddLog("\n-> TOTAL UNIDADES FÍSICAS MALEABLES HALLADAS: " .. tostring(unanchoredCount), 1)

    -- ------------------------------------------------------------------
    -- 5. ANÁLISIS DEL PERSONAJE CLIENTE Y LÓGICA LOCAL
    -- ------------------------------------------------------------------
    AddLog("\n[👤 SECCIÓN 5: TU AVATAR E INVENTARIO]", 0)
    pcall(function()
        if LocalPlayer.Character then
            AddLog("🟢 Personaje Vivo: " .. LocalPlayer.Character.Name, 1)
            GetDetails(LocalPlayer.Character, 2)
        end
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            AddLog("🎒 Inventario Local (Tools):", 1)
            for _, tool in pairs(backpack:GetChildren()) do
                AddLog("⚔️ " .. tool.Name, 2)
                GetDetails(tool, 3)
            end
        end
        local leader = LocalPlayer:FindFirstChild("leaderstats")
        if leader then
            AddLog("📊 Stats/Monedas (Leaderstats):", 1)
            GetDetails(leader, 2)
        end
    end)

    AddLog("\n========================================================", 0)
    AddLog("✅ ESCANEO JERÁRQUICO COMPLETO GENERADO CON ÉXITO.", 0)
end

-- ==============================================================================
-- 🖥️ GUI V2026: THE OMNI-SCANNER V-MAX
-- ==============================================================================
local function ConstruirUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "MasterBypass2026UI"
    sg.ResetOnSpawn = false
    
    local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "MasterBypass2026UI" then v:Destroy() end end
    sg.Parent = parentUI

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 600, 0, 480)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -240)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
    MainFrame.BorderSizePixel = 3
    MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 100)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -90, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
    TopBar.Text = "  [V22: OMNI-SCANNER V-MAX DEV-AUDITOR]"
    TopBar.TextColor3 = Color3.fromRGB(150, 255, 150)
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

    CloseBtn.MouseButton1Click:Connect(function() sg:Destroy() end)
    MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)
    ReloadBtn.MouseButton1Click:Connect(function()
        pcall(function() sg:Destroy(); loadstring(game:HttpGet(SCRIPT_URL .. "?r=" .. math.random(111,999)))() end)
    end)

    local InfoScroll = Instance.new("ScrollingFrame")
    InfoScroll.Size = UDim2.new(1, -16, 0.70, 0)
    InfoScroll.Position = UDim2.new(0, 8, 0, 35)
    InfoScroll.BackgroundColor3 = Color3.fromRGB(10, 15, 20)
    InfoScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    InfoScroll.ScrollBarThickness = 6
    InfoScroll.Parent = MainFrame

    -- PANTALLA DE PRE-VISUALIZACIÓN V-MAX
    local LogText = Instance.new("TextLabel")
    LogText.Size = UDim2.new(1, -10, 1, 0)
    LogText.Position = UDim2.new(0, 5, 0, 5)
    LogText.BackgroundTransparency = 1
    LogText.Text = "V22: DUMPER JERÁRQUICO V-MAX.\n\nHe restaurado tu Botón de Copiar y he envuelto la recursividad del motor con pcalls para evitar que el escaneo colapse si choca contra carpetas de Roblox bloqueadas.\n\nAdemás, añadí las Secciones de Tiendas, Mobs, Interacciones y Físicas juntas. Cuando presiones [ESCANEAR], verás una pequeña vista previa aquí.\n\nPero para que la interfaz no crashee por superar los 16,000 límites de caracteres de la GUI de Roblox, EL REPORTE ABSOLUTO COMPLETO SÓLO SE INYECTARÁ A TU PORTAPAPELES CUANDO LE DES A [COPIAR REPORTE]."
    LogText.TextColor3 = Color3.fromRGB(200, 255, 150)
    LogText.Font = Enum.Font.Code
    LogText.TextSize = 12
    LogText.TextXAlignment = Enum.TextXAlignment.Left
    LogText.TextYAlignment = Enum.TextYAlignment.Top
    LogText.TextWrapped = true
    LogText.Parent = InfoScroll

    local function ActualizarPantalla()
        if string.len(FullReport) > 10000 then
            LogText.Text = string.sub(FullReport, 1, 10000) .. "\n\n... [¡ATENCIÓN! EL TEXTO DE AUDITORÍA ES DEMASIADO GRANDE. HE TRUNCADO LA VISUALIZACIÓN PARA NO CONGELAR TU JUEGO. USA EL BOTÓN DE ABAJO PARA COPIARLO ENTERO A TU BLOC DE NOTAS!]"
        else
            LogText.Text = FullReport
        end
        InfoScroll.CanvasPosition = Vector2.new(0, 0)
    end

    local btnScan = Instance.new("TextButton")
    btnScan.Size = UDim2.new(0.48, 0, 0, 50)
    btnScan.Position = UDim2.new(0, 8, 0.85, 0)
    btnScan.BackgroundColor3 = Color3.fromRGB(150, 80, 0)
    btnScan.Text = "🌳 1. INICIAR OMNI-SCAN JERÁRQUICO"
    btnScan.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnScan.Font = Enum.Font.Code
    btnScan.TextSize = 11
    btnScan.Parent = MainFrame

    local btnCopy = Instance.new("TextButton")
    btnCopy.Size = UDim2.new(0.48, 0, 0, 50)
    btnCopy.Position = UDim2.new(0.5, 4, 0.85, 0)
    btnCopy.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    btnCopy.Text = "📋 2. COPIAR REPORTE COMPLETO"
    btnCopy.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnCopy.Font = Enum.Font.Code
    btnCopy.TextSize = 11
    btnCopy.Parent = MainFrame

    btnScan.MouseButton1Click:Connect(function()
        pcall(function()
            EscaneoOmniJerarquico()
            ActualizarPantalla()
        end)
    end)
    
    btnCopy.MouseButton1Click:Connect(function()
        pcall(function()
            if setclipboard then
                setclipboard(FullReport) -- Exporta la matriz masiva completa (Sin truncar) al entorno de Windows.
                btnCopy.Text = "✅ ¡COPIADO EXITOSAMENTE A WINDOWS!"
                btnCopy.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                task.wait(2)
                btnCopy.Text = "📋 2. COPIAR REPORTE COMPLETO"
                btnCopy.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
            else
                Warn("Tu exploit no soporta setclipboard(). Asegúrate de estar en Desktop.")
            end
        end)
    end)
end

ConstruirUI()
