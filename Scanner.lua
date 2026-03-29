-- ==============================================================================
-- 🔬 FORGE DEEP ANALYZER V2.0 — SIN hookmetamethod
-- ==============================================================================
-- Usa: decompile() + getgc() + getconnections()
-- NO usa hookmetamethod. NO rompe interacción con NPCs.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "ForgeDeepUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ForgeDeepUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 400)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 15)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 200, 255)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -110, 0, 28)
Title.BackgroundColor3 = Color3.fromRGB(0, 30, 50)
Title.Text = " 🔬 FORGE DEEP ANALYZER V2.0"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.TextSize = 12
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0, 70, 0, 28)
SaveBtn.Position = UDim2.new(1, -110, 0, 0)
SaveBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
SaveBtn.Text = "💾 SAVE"
SaveBtn.TextColor3 = Color3.new(1,1,1)
SaveBtn.Font = Enum.Font.Code
SaveBtn.TextSize = 11
SaveBtn.Parent = MainFrame

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -38, 0, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(180, 150, 0)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.Font = Enum.Font.Code
MinBtn.TextSize = 16
MinBtn.Parent = MainFrame

-- Botones de análisis
local BtnFrame = Instance.new("Frame")
BtnFrame.Size = UDim2.new(1, -8, 0, 26)
BtnFrame.Position = UDim2.new(0, 4, 0, 30)
BtnFrame.BackgroundTransparency = 1
BtnFrame.Parent = MainFrame

local OutputScroll = Instance.new("ScrollingFrame")
OutputScroll.Size = UDim2.new(1, -8, 1, -62)
OutputScroll.Position = UDim2.new(0, 4, 0, 58)
OutputScroll.BackgroundColor3 = Color3.fromRGB(3, 3, 6)
OutputScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
OutputScroll.ScrollBarThickness = 5
OutputScroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Parent = OutputScroll
UIList.Padding = UDim.new(0, 1)
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    OutputScroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 10)
end)

local isMin = false
MinBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    MainFrame.Size = isMin and UDim2.new(0, 520, 0, 28) or UDim2.new(0, 520, 0, 400)
    OutputScroll.Visible = not isMin
    BtnFrame.Visible = not isMin
end)

local FullLog = "=== FORGE DEEP ANALYZER V2.0 ===\n\n"
local msgCount = 0

local SAVE_FILE = "info3.txt"

local function AutoSave()
    pcall(function() writefile(SAVE_FILE, FullLog) end)
end

SaveBtn.MouseButton1Click:Connect(function()
    AutoSave()
    SaveBtn.Text = "✅"
    task.delay(1, function() SaveBtn.Text = "💾 SAVE" end)
end)

local function L(text, color)
    FullLog = FullLog .. text .. "\n"
    msgCount = msgCount + 1
    if msgCount % 3 == 0 then AutoSave() end
    if msgCount > 600 then return end
    task.defer(function()
        pcall(function()
            local msg = Instance.new("TextLabel")
            msg.Size = UDim2.new(1, -6, 0, 14)
            msg.BackgroundTransparency = 1
            msg.Text = text
            msg.TextColor3 = color or Color3.fromRGB(180, 180, 180)
            msg.TextSize = 9
            msg.Font = Enum.Font.Code
            msg.TextXAlignment = Enum.TextXAlignment.Left
            msg.TextWrapped = true
            msg.Parent = OutputScroll
            msg.Size = UDim2.new(1, -6, 0, msg.TextBounds.Y + 2)
            OutputScroll.CanvasPosition = Vector2.new(0, 99999)
        end)
    end)
end

-- ==========================================
-- ANÁLISIS 1: DECOMPILE — Leer código fuente del forge
-- ==========================================
local function AnalisisDecompile()
    L("\n═══ ANÁLISIS 1: DECOMPILE (código fuente) ═══", Color3.fromRGB(255, 100, 0))
    
    if not decompile then
        L("❌ decompile() no disponible en este executor", Color3.fromRGB(255, 50, 50))
        return
    end
    
    -- Buscar scripts de forja en PlayerGui
    local forgeScripts = {}
    for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
        if string.find(string.lower(gui.Name), "forge") then
            for _, desc in pairs(gui:GetDescendants()) do
                if desc:IsA("LocalScript") or desc:IsA("ModuleScript") then
                    table.insert(forgeScripts, desc)
                end
            end
        end
    end
    
    -- Buscar en ReplicatedStorage
    for _, desc in pairs(ReplicatedStorage:GetDescendants()) do
        if (desc:IsA("ModuleScript") or desc:IsA("LocalScript")) then
            local nl = string.lower(desc.Name)
            if string.find(nl, "forge") or string.find(nl, "minigame") or string.find(nl, "sequence") then
                table.insert(forgeScripts, desc)
            end
        end
    end
    
    -- Buscar en StarterPlayerScripts
    local sps = game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")
    if sps then
        for _, desc in pairs(sps:GetDescendants()) do
            if (desc:IsA("LocalScript") or desc:IsA("ModuleScript")) and string.find(string.lower(desc.Name), "forge") then
                table.insert(forgeScripts, desc)
            end
        end
    end
    
    L("  Encontrados: " .. #forgeScripts .. " scripts de forja", Color3.fromRGB(100, 255, 100))
    
    for _, script in pairs(forgeScripts) do
        L("\n📜 " .. script.ClassName .. ": " .. script:GetFullName(), Color3.fromRGB(255, 200, 50))
        local ok, source = pcall(function() return decompile(script) end)
        if ok and source then
            -- Guardar código completo en archivo separado
            local safeName = string.gsub(script.Name, "[^%w]", "_")
            pcall(function() writefile("forge_script_" .. safeName .. ".lua", source) end)
            L("  ✅ Decompilado! Guardado en forge_script_" .. safeName .. ".lua", Color3.fromRGB(100, 255, 100))
            
            -- Buscar palabras clave importantes
            local keywords = {"ChangeSequence", "Melt", "Pour", "Hammer", "Water", "Showcase", "EndForge",
                "WalkSpeed", "ClientTime", "RequiredTime", "StartTime", "Perfect", "Bad", "Score",
                "Minigame", "sequence", "phase", "ForceDialogue", "InvokeServer"}
            for _, kw in pairs(keywords) do
                if string.find(source, kw) then
                    L("  🔑 Contiene: \"" .. kw .. "\"", Color3.fromRGB(255, 255, 100))
                    -- Encontrar la línea
                    for line in string.gmatch(source, "[^\n]+") do
                        if string.find(line, kw) then
                            local trimmed = string.sub(string.gsub(line, "^%s+", ""), 1, 120)
                            L("     → " .. trimmed, Color3.fromRGB(200, 200, 150))
                            break
                        end
                    end
                end
            end
        else
            L("  ❌ Error: " .. tostring(source), Color3.fromRGB(255, 50, 50))
        end
    end
end

-- ==========================================
-- ANÁLISIS 2: GETGC — Buscar funciones de forge en memoria
-- ==========================================
local function AnalisisGetGC()
    L("\n═══ ANÁLISIS 2: GETGC (funciones en memoria) ═══", Color3.fromRGB(255, 100, 255))
    
    if not getgc then
        L("❌ getgc() no disponible en este executor", Color3.fromRGB(255, 50, 50))
        return
    end
    
    local gc = getgc(true) -- true = incluir tablas
    local forgeItems = {}
    
    for _, v in pairs(gc) do
        if type(v) == "function" then
            local info = debug.getinfo(v)
            if info and info.source then
                local sl = string.lower(info.source)
                if string.find(sl, "forge") or string.find(sl, "minigame") or string.find(sl, "sequence") then
                    table.insert(forgeItems, {type = "function", value = v, info = info})
                end
            end
        elseif type(v) == "table" then
            -- Buscar tablas que tengan claves de forja
            local hasForge = false
            for k, _ in pairs(v) do
                if type(k) == "string" then
                    local kl = string.lower(k)
                    if kl == "melt" or kl == "pour" or kl == "hammer" or kl == "water" or kl == "showcase"
                        or kl == "endforge" or kl == "changesequence" or kl == "requiredtime" or kl == "starttime"
                        or kl == "clienttime" or kl == "forging" or kl == "minigame" then
                        hasForge = true
                        break
                    end
                end
            end
            if hasForge then
                table.insert(forgeItems, {type = "table", value = v})
            end
        end
    end
    
    L("  Encontrados: " .. #forgeItems .. " items en GC", Color3.fromRGB(100, 255, 100))
    
    for i, item in ipairs(forgeItems) do
        if i > 30 then L("  ... (+" .. (#forgeItems - 30) .. " más)"); break end
        
        if item.type == "function" then
            local info = item.info
            L("  🔧 Función: " .. (info.name or "anon") .. " @ " .. (info.source or "?") .. ":" .. (info.currentline or "?"), Color3.fromRGB(200, 150, 255))
            -- Obtener upvalues
            if getupvalues then
                local ok, ups = pcall(function() return getupvalues(item.value) end)
                if ok and ups then
                    for k, v in pairs(ups) do
                        if type(v) ~= "function" and type(v) ~= "userdata" then
                            L("    upval[" .. tostring(k) .. "] = " .. tostring(v), Color3.fromRGB(180, 150, 220))
                        end
                    end
                end
            end
        elseif item.type == "table" then
            L("  📦 Tabla con claves de forja:", Color3.fromRGB(200, 200, 100))
            local c = 0
            for k, v in pairs(item.value) do
                c = c + 1
                if c > 15 then L("    ... (más claves)"); break end
                L("    [" .. tostring(k) .. "] = " .. tostring(v), Color3.fromRGB(220, 220, 150))
            end
        end
    end
end

-- ==========================================
-- ANÁLISIS 3: GETCONNECTIONS — Conexiones de remotes de forja
-- ==========================================
local function AnalisisConnections()
    L("\n═══ ANÁLISIS 3: GETCONNECTIONS (remotes) ═══", Color3.fromRGB(100, 255, 100))
    
    if not getconnections then
        L("❌ getconnections() no disponible en este executor", Color3.fromRGB(255, 50, 50))
        return
    end
    
    -- Buscar remotes de forja
    local forgeRemotes = {}
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
            local nl = string.lower(v.Name .. v:GetFullName())
            if string.find(nl, "forge") or string.find(nl, "sequence") or string.find(nl, "changesequence") then
                table.insert(forgeRemotes, v)
            end
        end
    end
    
    L("  Encontrados: " .. #forgeRemotes .. " remotes de forja", Color3.fromRGB(100, 255, 100))
    
    for _, remote in pairs(forgeRemotes) do
        L("\n📡 " .. remote.ClassName .. ": " .. remote:GetFullName(), Color3.fromRGB(255, 200, 50))
        
        if remote:IsA("RemoteEvent") then
            local ok, conns = pcall(function() return getconnections(remote.OnClientEvent) end)
            if ok and conns then
                L("  Conexiones OnClientEvent: " .. #conns, Color3.fromRGB(100, 255, 100))
                for i, conn in pairs(conns) do
                    if i > 5 then break end
                    local funcInfo = ""
                    if conn.Function then
                        local info = debug.getinfo(conn.Function)
                        funcInfo = (info.source or "?") .. ":" .. (info.currentline or "?")
                        L("  [" .. i .. "] " .. funcInfo .. " (Enabled=" .. tostring(conn.Enabled) .. ")", Color3.fromRGB(200, 200, 200))
                        
                        -- Decompile la función conectada
                        if decompile then
                            local ok2, src = pcall(function() return decompile(conn.Function) end)
                            if ok2 and src then
                                pcall(function() writefile("forge_conn_" .. remote.Name .. "_" .. i .. ".lua", src) end)
                                L("    ✅ Decompilado → forge_conn_" .. remote.Name .. "_" .. i .. ".lua", Color3.fromRGB(100, 255, 100))
                                -- Mostrar primeras líneas relevantes
                                local lineCount = 0
                                for line in string.gmatch(src, "[^\n]+") do
                                    lineCount = lineCount + 1
                                    if lineCount <= 5 then
                                        L("    " .. string.sub(line, 1, 100), Color3.fromRGB(150, 200, 150))
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- También buscar en Knit Services
    L("\n📡 Buscando ChangeSequence en Knit...", Color3.fromRGB(255, 200, 50))
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteFunction") and string.find(string.lower(v.Name), "changesequence") then
            L("  🎯 ENCONTRADO: " .. v:GetFullName(), Color3.fromRGB(255, 100, 100))
        end
    end
end

-- ==========================================
-- ANÁLISIS 4: ESCANEAR SCRIPTS ACTIVOS EN PLAYERGUI
-- ==========================================
local function AnalisisPlayerGui()
    L("\n═══ ANÁLISIS 4: SCRIPTS ACTIVOS EN PLAYERGUI ═══", Color3.fromRGB(255, 255, 100))
    
    for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
        local nl = string.lower(gui.Name)
        if string.find(nl, "forge") or string.find(nl, "minigame") or string.find(nl, "craft") then
            L("🖥️ " .. gui.ClassName .. ": " .. gui.Name .. " Enabled=" .. tostring(gui.Enabled), Color3.fromRGB(255, 255, 100))
            
            local scripts = {}
            for _, desc in pairs(gui:GetDescendants()) do
                if desc:IsA("LocalScript") then
                    table.insert(scripts, desc)
                    L("  📜 LocalScript: " .. desc:GetFullName() .. " Disabled=" .. tostring(desc.Disabled), Color3.fromRGB(200, 200, 100))
                elseif desc:IsA("ModuleScript") then
                    table.insert(scripts, desc)
                    L("  📦 ModuleScript: " .. desc:GetFullName(), Color3.fromRGB(200, 200, 100))
                end
            end
            
            -- Decompile cada uno
            if decompile then
                for _, s in pairs(scripts) do
                    local ok, source = pcall(function() return decompile(s) end)
                    if ok and source then
                        local safeName = string.gsub(s:GetFullName(), "[^%w]", "_")
                        pcall(function() writefile("forge_gui_" .. safeName .. ".lua", source) end)
                        L("  ✅ Decompilado: forge_gui_" .. safeName .. ".lua (" .. #source .. " chars)", Color3.fromRGB(100, 255, 100))
                    end
                end
            end
        end
    end
end

-- ==========================================
-- CREAR BOTONES
-- ==========================================
local analyses = {
    {"📜 DECOMPILE", AnalisisDecompile, Color3.fromRGB(255, 100, 0)},
    {"🧠 GETGC", AnalisisGetGC, Color3.fromRGB(255, 100, 255)},
    {"🔗 CONNECTIONS", AnalisisConnections, Color3.fromRGB(100, 255, 100)},
    {"🖥️ PLAYERGUI", AnalisisPlayerGui, Color3.fromRGB(255, 255, 100)},
}

for i, a in ipairs(analyses) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 123, 0, 22)
    btn.Position = UDim2.new(0, (i-1) * 127, 0, 2)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    btn.Text = a[1]
    btn.TextColor3 = a[3]
    btn.TextSize = 10
    btn.Font = Enum.Font.Code
    btn.Parent = BtnFrame
    
    btn.MouseButton1Click:Connect(function()
        btn.Text = "⏳..."
        task.spawn(function()
            a[2]()
            btn.Text = a[1]
            AutoSave()
        end)
    end)
end

-- AUTO-EJECUTAR todos los análisis en secuencia al iniciar
task.spawn(function()
    task.wait(1)
    L("\n🔄 AUTO-EJECUTANDO todos los análisis...", Color3.fromRGB(0, 255, 255))
    AutoSave()
    
    L("\n▶ [1/4] DECOMPILE...", Color3.fromRGB(255, 100, 0))
    pcall(AnalisisDecompile)
    AutoSave()
    task.wait(1)
    
    L("\n▶ [2/4] GETGC...", Color3.fromRGB(255, 100, 255))
    pcall(AnalisisGetGC)
    AutoSave()
    task.wait(1)
    
    L("\n▶ [3/4] CONNECTIONS...", Color3.fromRGB(100, 255, 100))
    pcall(AnalisisConnections)
    AutoSave()
    task.wait(1)
    
    L("\n▶ [4/4] PLAYERGUI...", Color3.fromRGB(255, 255, 100))
    pcall(AnalisisPlayerGui)
    AutoSave()
    
    L("\n✅ TODOS LOS ANÁLISIS COMPLETADOS. Guardado en " .. SAVE_FILE, Color3.fromRGB(0, 255, 0))
    AutoSave()
end)

-- ==========================================
-- ESCUCHAR FORGE REMOTES PASIVAMENTE (como V1.2)
-- ==========================================
local startTime = tick()
for _, v in pairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA("RemoteEvent") then
        local nl = string.lower(v.Name .. v:GetFullName())
        if string.find(nl, "forge") or string.find(nl, "sequence") or string.find(nl, "progress") then
            v.OnClientEvent:Connect(function(...)
                local args = {...}
                local t = string.format("%.2f", tick() - startTime)
                task.defer(function()
                    local argStr = ""
                    for i, val in ipairs(args) do
                        if type(val) == "table" then
                            for k, va in pairs(val) do argStr = argStr .. tostring(k) .. "=" .. tostring(va) .. ", " end
                        else
                            argStr = argStr .. tostring(val) .. " "
                        end
                    end
                    L("[" .. t .. "s] 📡 " .. v.Name .. ": " .. argStr, Color3.fromRGB(0, 255, 100))
                end)
            end)
        end
    end
end

-- Monitor WalkSpeed
task.spawn(function()
    local lastWS = nil
    while ScreenGui.Parent do
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum and lastWS ~= hum.WalkSpeed then
            local t = string.format("%.2f", tick() - startTime)
            L("[" .. t .. "s] 🚶 WalkSpeed: " .. tostring(lastWS) .. " → " .. tostring(hum.WalkSpeed), Color3.fromRGB(200, 200, 255))
            lastWS = hum.WalkSpeed
        end
        task.wait(0.5)
    end
end)

L("═══════════════════════════════════════════", Color3.fromRGB(0, 200, 255))
L("  🔬 FORGE DEEP ANALYZER V2.0 LISTO", Color3.fromRGB(0, 200, 255))
L("  Guarda automático en " .. SAVE_FILE, Color3.fromRGB(200, 200, 200))
L("  Auto-ejecutando los 4 análisis...", Color3.fromRGB(0, 255, 255))
L("═══════════════════════════════════════════\n", Color3.fromRGB(0, 200, 255))
AutoSave()
