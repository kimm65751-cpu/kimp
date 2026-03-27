
-- ==============================================================================
-- 💀 ROBLOX EXPERT: V23 OMNI-SCANNER (FILE-EXPORTER & PAGINACIÓN MANUAL)
-- Diseñado para evadir el colapso de Portapapeles (setclipboard) de Android/Delta.
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
local CHARS_PER_PAGE = 12000 -- Limite seguro para evitar crasheo de TextBox

local function AddLog(text, indentLevel)
    local prefix = string.rep("  ", indentLevel or 0)
    FullReport = FullReport .. prefix .. text .. "\n"
end

-- ==============================================================================
-- ⚙️ MOTOR DEL OMNI-SCANNER V23 (A PRUEBA DE CRASHES)
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
    FullReport = FullReport .. "👑 REPORTE DE AUDITORÍA OMNI-SCANNER V23 (ROBLOX 2026) 👑\n"
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
    
    -- SISTEMA DE PAGINACIÓN DE EMERGENICA (CHUNKER)
    Pages = {}
    local startIdx = 1
    while startIdx <= #FullReport do
        local endIdx = startIdx + CHARS_PER_PAGE - 1
        table.insert(Pages, string.sub(FullReport, startIdx, endIdx))
        startIdx = endIdx + 1
    end
    CurrentPage = 1
end

-- ==============================================================================
-- 🖥️ GUI V2026: THE OMNI-SCANNER V23 (PAGINADOR TEXTBOX & FILE-WRITER)
-- ==============================================================================
local function ConstruirUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "MasterBypass2026UI"
    sg.ResetOnSpawn = false
    
    local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "MasterBypass2026UI" then v:Destroy() end end
    sg.Parent = parentUI

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 640, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -320, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
    MainFrame.BorderSizePixel = 3
    MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = sg

    local TopBar = Instance.new("TextLabel")
    TopBar.Size = UDim2.new(1, -90, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(0, 50, 80)
    TopBar.Text = "  [V23: FILE-EXPORTER Y PAGINACIÓN DE RESCATE]"
    TopBar.TextColor3 = Color3.fromRGB(150, 255, 255)
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

    CloseBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

    local InfoScroll = Instance.new("ScrollingFrame")
    InfoScroll.Size = UDim2.new(1, -16, 0.65, 0)
    InfoScroll.Position = UDim2.new(0, 8, 0, 35)
    InfoScroll.BackgroundColor3 = Color3.fromRGB(10, 15, 20)
    InfoScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    InfoScroll.ScrollBarThickness = 6
    InfoScroll.Parent = MainFrame

    -- AHORA ES UN TEXTBOX SELECCIONABLE CON EL MOUSE
    local LogTextBox = Instance.new("TextBox")
    LogTextBox.Size = UDim2.new(1, -10, 1, 0)
    LogTextBox.Position = UDim2.new(0, 5, 0, 5)
    LogTextBox.BackgroundTransparency = 1
    LogTextBox.Text = "El Botón de 'Copiar' (setclipboard) está ROTO en tu Ejecutor Android/LDPlayer. No puede hablarse con Windows.\n\nSOLUCIÓN 1 (ARCHIVO LÓGICO): Pulsa Escanear. Luego dale a [GUARDAR ARCHIVO .TXT]. Esto creará un archivo llamado 'OmniScan_Reporte.txt' directamente en la carpeta 'workspace' o 'scripts' de tu Emulador.\n\nSOLUCIÓN 2 (COPIA MANUAL SEGURA): He cortado el monstruoso texto en Múltiples Páginas pequeñas. Al terminar el Escaneo, esta pantalla se volverá un Cuadro de Texto seleccionable. Simplemente haz CLIC aquí, presiona CTRL+A para sombrearlo de azul, y CTRL+C para copiarlo manualmente. Luego usa los Botones [Siguiente >] para copiar la Página 2, la Página 3, etc."
    LogTextBox.TextColor3 = Color3.fromRGB(200, 255, 150)
    LogTextBox.Font = Enum.Font.Code
    LogTextBox.TextSize = 12
    LogTextBox.TextXAlignment = Enum.TextXAlignment.Left
    LogTextBox.TextYAlignment = Enum.TextYAlignment.Top
    LogTextBox.TextWrapped = true
    LogTextBox.ClearTextOnFocus = false
    LogTextBox.TextEditable = false
    LogTextBox.MultiLine = true
    LogTextBox.Parent = InfoScroll

    local PageLabel = Instance.new("TextLabel")
    PageLabel.Size = UDim2.new(1, 0, 0, 20)
    PageLabel.Position = UDim2.new(0, 0, 0.72, 0)
    PageLabel.BackgroundTransparency = 1
    PageLabel.Text = "Página 0 / 0"
    PageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    PageLabel.Font = Enum.Font.Code
    PageLabel.TextSize = 14
    PageLabel.Parent = MainFrame

    local btnPrev = Instance.new("TextButton")
    btnPrev.Size = UDim2.new(0.2, 0, 0, 30)
    btnPrev.Position = UDim2.new(0, 8, 0.76, 0)
    btnPrev.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    btnPrev.Text = "< Anterior"
    btnPrev.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnPrev.Parent = MainFrame

    local btnNext = Instance.new("TextButton")
    btnNext.Size = UDim2.new(0.2, 0, 0, 30)
    btnNext.Position = UDim2.new(0.8, -8, 0.76, 0)
    btnNext.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    btnNext.Text = "Siguiente >"
    btnNext.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnNext.Parent = MainFrame

    local btnScan = Instance.new("TextButton")
    btnScan.Size = UDim2.new(0.48, 0, 0, 50)
    btnScan.Position = UDim2.new(0, 8, 0.85, 0)
    btnScan.BackgroundColor3 = Color3.fromRGB(150, 80, 0)
    btnScan.Text = "🌳 1. INICIAR OMNI-SCAN JERÁRQUICO"
    btnScan.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnScan.Font = Enum.Font.Code
    btnScan.TextSize = 12
    btnScan.Parent = MainFrame

    local btnSave = Instance.new("TextButton")
    btnSave.Size = UDim2.new(0.48, 0, 0, 50)
    btnSave.Position = UDim2.new(0.5, 4, 0.85, 0)
    btnSave.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    btnSave.Text = "💾 2. GUARDAR ARCHIVO .TXT"
    btnSave.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnSave.Font = Enum.Font.Code
    btnSave.TextSize = 12
    btnSave.Parent = MainFrame

    local function ActualizarPantalla()
        if #Pages == 0 then return end
        LogTextBox.Text = Pages[CurrentPage]
        PageLabel.Text = "Página " .. tostring(CurrentPage) .. " / " .. tostring(#Pages)
        InfoScroll.CanvasPosition = Vector2.new(0, 0)
    end

    btnPrev.MouseButton1Click:Connect(function()
        if CurrentPage > 1 then CurrentPage = CurrentPage - 1; ActualizarPantalla() end
    end)

    btnNext.MouseButton1Click:Connect(function()
        if CurrentPage < #Pages then CurrentPage = CurrentPage + 1; ActualizarPantalla() end
    end)

    btnScan.MouseButton1Click:Connect(function()
        pcall(function()
            EscaneoOmniJerarquico()
            ActualizarPantalla()
        end)
    end)
    
    btnSave.MouseButton1Click:Connect(function()
        pcall(function()
            if writefile then
                writefile("OmniScan_Report.txt", FullReport)
                btnSave.Text = "✅ ¡GUARDADO EN CARPETA 'WORKSPACE'!"
                btnSave.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            else
                Warn("Tu exploit no soporta writefile(). Usa la copia manual de páginas arriba.")
                btnSave.Text = "¡Falla de writefile!"
            end
            task.wait(3)
            btnSave.Text = "💾 2. GUARDAR ARCHIVO .TXT"
            btnSave.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        end)
    end)
end

ConstruirUI()
