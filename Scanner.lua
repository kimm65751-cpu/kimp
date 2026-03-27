-- ==============================================================================
-- 🔬 FORENSE SCANNER V2.0 — ADAPTADO A "STEAL A BRAINROT"
-- Auto-detecta estructura de red (Wally/Net/Knit/Custom)
-- GUI SIEMPRE carga (toda lógica peligrosa en pcall)
-- ==============================================================================

-- ╔══════════════════════════════════════════════════════╗
-- ║  SERVICIOS (100% SEGURO)                            ║
-- ╚══════════════════════════════════════════════════════╝
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- ╔══════════════════════════════════════════════════════╗
-- ║  MOTOR DE REPORTE (SIN GUI — PURO TEXTO)            ║
-- ╚══════════════════════════════════════════════════════╝
local Report = {}       -- Array de {seccion, lineas[]}
local CurrentSection = nil

local function NewSection(icon, title)
    CurrentSection = {title = icon .. " " .. title, lines = {}}
    table.insert(Report, CurrentSection)
end

local function Log(text, indent)
    if not CurrentSection then NewSection("📋", "General") end
    local prefix = string.rep("  ", indent or 0)
    table.insert(CurrentSection.lines, prefix .. text)
end

local function SafeValue(v)
    local ok, result = pcall(function()
        if typeof(v) == "Instance" then return v.Name .. " (" .. v.ClassName .. ")"
        elseif typeof(v) == "Vector3" then return string.format("V3(%.1f,%.1f,%.1f)", v.X, v.Y, v.Z)
        elseif typeof(v) == "CFrame" then return "CFrame"
        elseif typeof(v) == "Color3" then return string.format("RGB(%d,%d,%d)", math.floor(v.R*255), math.floor(v.G*255), math.floor(v.B*255))
        elseif typeof(v) == "BrickColor" then return "BrickColor:" .. tostring(v)
        elseif type(v) == "table" then return "{table:" .. #v .. " items}"
        else return tostring(v) end
    end)
    return ok and result or "???"
end

-- ╔══════════════════════════════════════════════════════╗
-- ║  ESCANEO 1: INFO DEL JUEGO Y SERVIDOR               ║
-- ╚══════════════════════════════════════════════════════╝
local function ScanGameInfo()
    NewSection("🎮", "INFORMACIÓN DEL JUEGO Y SERVIDOR")
    
    pcall(function()
        Log("PlaceId: " .. tostring(game.PlaceId))
        Log("GameId: " .. tostring(game.GameId))
        Log("JobId: " .. (game.JobId ~= "" and game.JobId or "Studio/Local"))
    end)
    
    pcall(function()
        local info = MarketplaceService:GetProductInfo(game.PlaceId)
        if info then
            Log("Nombre: " .. tostring(info.Name))
            Log("Creador: " .. tostring(info.Creator.Name) .. " (Id: " .. tostring(info.Creator.Id) .. ")")
            Log("Descripcion: " .. string.sub(tostring(info.Description), 1, 200))
            Log("Actualizado: " .. tostring(info.Updated))
        end
    end)
    
    pcall(function()
        local players = Players:GetPlayers()
        local names = {}
        for _, p in ipairs(players) do table.insert(names, p.Name .. " (ID:" .. p.UserId .. ")") end
        Log("Jugadores: " .. #names)
        for _, n in ipairs(names) do Log("  👤 " .. n, 1) end
    end)
    
    pcall(function()
        Log("Objetos en Workspace: " .. tostring(#Workspace:GetDescendants()))
        Log("Objetos en ReplicatedStorage: " .. tostring(#ReplicatedStorage:GetDescendants()))
    end)
end

-- ╔══════════════════════════════════════════════════════╗
-- ║  ESCANEO 2: JUGADOR LOCAL COMPLETO                   ║
-- ╚══════════════════════════════════════════════════════╝
local function ScanLocalPlayer()
    NewSection("👤", "TU PERFIL DE JUGADOR")
    
    pcall(function()
        Log("Nombre: " .. LocalPlayer.Name .. " | DisplayName: " .. LocalPlayer.DisplayName)
        Log("UserId: " .. tostring(LocalPlayer.UserId))
        Log("AccountAge: " .. tostring(LocalPlayer.AccountAge) .. " dias")
        Log("MembershipType: " .. tostring(LocalPlayer.MembershipType))
        Log("TeamColor: " .. tostring(LocalPlayer.TeamColor))
    end)
    
    -- leaderstats
    pcall(function()
        local ls = LocalPlayer:FindFirstChild("leaderstats")
        if ls then
            Log("\n📊 LEADERSTATS:")
            for _, v in ipairs(ls:GetChildren()) do
                Log("  " .. v.Name .. " = " .. SafeValue(v.Value) .. " (" .. v.ClassName .. ")", 1)
            end
        else
            Log("⚠️ Sin leaderstats visibles")
        end
    end)
    
    -- Atributos del jugador
    pcall(function()
        local attrs = LocalPlayer:GetAttributes()
        local count = 0
        for _ in pairs(attrs) do count = count + 1 end
        if count > 0 then
            Log("\n💎 ATRIBUTOS DEL JUGADOR (" .. count .. "):")
            for k, v in pairs(attrs) do
                Log("  " .. tostring(k) .. " = " .. SafeValue(v), 1)
            end
        end
    end)
    
    -- Carpetas de datos internas
    pcall(function()
        local dataFolders = {}
        for _, child in ipairs(LocalPlayer:GetChildren()) do
            if child:IsA("Folder") or child:IsA("Configuration") then
                table.insert(dataFolders, child)
            end
        end
        if #dataFolders > 0 then
            Log("\n📁 CARPETAS DE DATOS EN PLAYER:")
            for _, folder in ipairs(dataFolders) do
                Log("📂 " .. folder.Name .. " (" .. #folder:GetChildren() .. " hijos)", 1)
                for _, item in ipairs(folder:GetDescendants()) do
                    pcall(function()
                        if item:IsA("ValueBase") then
                            Log("  📌 " .. item:GetFullName():gsub(LocalPlayer:GetFullName() .. ".", "") .. " = " .. SafeValue(item.Value), 2)
                        end
                    end)
                end
            end
        end
    end)
    
    -- Character
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            Log("\n🧍 PERSONAJE:")
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            if hum then
                Log("  Health: " .. tostring(hum.Health) .. "/" .. tostring(hum.MaxHealth), 1)
                Log("  WalkSpeed: " .. tostring(hum.WalkSpeed) .. " | JumpPower: " .. tostring(hum.JumpPower), 1)
                Log("  JumpHeight: " .. tostring(hum.JumpHeight), 1)
            end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                Log("  Posicion: " .. SafeValue(hrp.Position), 1)
            end
            
            -- Atributos del character
            local cAttrs = char:GetAttributes()
            for k, v in pairs(cAttrs) do
                Log("  💎 CharAttr: " .. tostring(k) .. " = " .. SafeValue(v), 1)
            end
        end
    end)
    
    -- Backpack/Tools
    pcall(function()
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp then
            Log("\n🎒 INVENTARIO (Backpack):")
            for _, tool in ipairs(bp:GetChildren()) do
                if tool:IsA("Tool") then
                    Log("⚔️ " .. tool.Name, 1)
                    Log("  ToolTip: " .. tostring(tool.ToolTip), 2)
                    Log("  CanBeDropped: " .. tostring(tool.CanBeDropped), 2)
                    Log("  RequiresHandle: " .. tostring(tool.RequiresHandle), 2)
                    -- Atributos del tool
                    for k, v in pairs(tool:GetAttributes()) do
                        Log("  💎 " .. tostring(k) .. " = " .. SafeValue(v), 2)
                    end
                    -- Scripts dentro del tool
                    for _, s in ipairs(tool:GetDescendants()) do
                        if s:IsA("LocalScript") or s:IsA("Script") or s:IsA("ModuleScript") then
                            Log("  📜 " .. s.Name .. " (" .. s.ClassName .. ")", 2)
                        end
                    end
                end
            end
        end
        -- Tools equipped on character
        local char = LocalPlayer.Character
        if char then
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    Log("⚔️ [EQUIPADO] " .. tool.Name, 1)
                end
            end
        end
    end)
end

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  ESCANEO 3: ARQUITECTURA DE RED (AUTO-DETECT DE FRAMEWORK) ║
-- ╚══════════════════════════════════════════════════════════════╝
local function ScanNetwork()
    NewSection("📡", "ARQUITECTURA DE RED (AUTO-DETECCIÓN)")
    
    -- Detectar framework
    pcall(function()
        local frameworks = {}
        
        -- Knit
        pcall(function()
            local knit = ReplicatedStorage:FindFirstChild("Shared")
            if knit then
                local pkg = knit:FindFirstChild("Packages")
                if pkg and pkg:FindFirstChild("Knit") then
                    table.insert(frameworks, "KNIT (RS.Shared.Packages.Knit)")
                end
            end
        end)
        
        -- Wally/Net
        pcall(function()
            local pkg = ReplicatedStorage:FindFirstChild("Packages")
            if pkg then
                local net = pkg:FindFirstChild("Net")
                if net then
                    table.insert(frameworks, "WALLY + NET LIBRARY (RS.Packages.Net)")
                else
                    table.insert(frameworks, "WALLY PACKAGES (RS.Packages)")
                end
            end
        end)
        
        -- AeroGameFramework
        pcall(function()
            if ReplicatedStorage:FindFirstChild("Aero") then
                table.insert(frameworks, "AERO GAME FRAMEWORK")
            end
        end)
        
        -- Custom events in RS root
        pcall(function()
            local rootRemotes = 0
            for _, c in ipairs(ReplicatedStorage:GetChildren()) do
                if c:IsA("RemoteEvent") or c:IsA("RemoteFunction") then
                    rootRemotes = rootRemotes + 1
                end
            end
            if rootRemotes > 0 then
                table.insert(frameworks, "REMOTES EN RAIZ (" .. rootRemotes .. ")")
            end
        end)
        
        if #frameworks > 0 then
            Log("🏗️ FRAMEWORKS DETECTADOS:")
            for _, f in ipairs(frameworks) do Log("  ▶ " .. f, 1) end
        else
            Log("⚠️ No se detectó framework conocido")
        end
    end)
    
    -- Escanear TODA la estructura de Red
    pcall(function()
        Log("\n🔗 MAPA COMPLETO DE REMOTES:")
        
        -- Categorizar remotes
        local categories = {} -- {categoria = {items}}
        
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            pcall(function()
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local fullPath = obj:GetFullName()
                    local shortPath = fullPath:gsub("ReplicatedStorage%.", "")
                    
                    -- Detectar si es un hash (ofuscado)
                    local isHash = #obj.Name > 40 and string.match(obj.Name, "^[a-f0-9]+$") ~= nil
                    
                    -- Categorizar por path
                    local category = "Otros"
                    if string.find(shortPath, "Net") then
                        -- Extraer subcategoría: RE/Tools/Cooldown -> "Tools"
                        local subCat = string.match(obj.Name, "^[RFE]+/([^/]+)")
                        if subCat then
                            category = "Net/" .. subCat
                        else
                            category = isHash and "Net/OFUSCADO (Hash)" or "Net/Otro"
                        end
                    elseif string.find(shortPath, "Service") then
                        category = "Services"
                    elseif string.find(shortPath, "Shared") then
                        category = "Shared"
                    else
                        local parentName = obj.Parent and obj.Parent.Name or "Root"
                        category = parentName
                    end
                    
                    if not categories[category] then categories[category] = {} end
                    
                    local displayName = obj.Name
                    if isHash then
                        displayName = "[HASH:" .. string.sub(obj.Name, 1, 12) .. "...]"
                    end
                    
                    table.insert(categories[category], {
                        name = displayName,
                        class = obj.ClassName,
                        fullName = shortPath,
                        isHash = isHash
                    })
                end
            end)
        end
        
        -- Mostrar por categoría
        local sortedCats = {}
        for cat in pairs(categories) do table.insert(sortedCats, cat) end
        table.sort(sortedCats)
        
        for _, cat in ipairs(sortedCats) do
            local items = categories[cat]
            local hashCount = 0
            local namedItems = {}
            for _, item in ipairs(items) do
                if item.isHash then hashCount = hashCount + 1
                else table.insert(namedItems, item) end
            end
            
            Log("\n📂 " .. cat .. " (" .. #items .. " remotes" .. (hashCount > 0 and ", " .. hashCount .. " ofuscados" or "") .. ")", 1)
            
            -- Mostrar los nombrados
            for _, item in ipairs(namedItems) do
                local icon = item.class == "RemoteEvent" and "🔴" or "🔵"
                Log(icon .. " " .. item.name .. " [" .. item.class .. "]", 2)
            end
            
            -- Resumir los hashes
            if hashCount > 0 then
                Log("🔒 + " .. hashCount .. " remotes OFUSCADOS (hashes SHA)", 2)
            end
        end
    end)
    
    -- Buscar remotes de interés para exploits
    pcall(function()
        Log("\n\n🎯 REMOTES DE INTERÉS (PARA SCRIPTING):")
        local keywords = {
            "tool", "steal", "coin", "cash", "money", "shop", "buy", "sell",
            "claim", "collect", "reward", "chest", "fuse", "fusion", "merge",
            "rebirth", "prestige", "upgrade", "pet", "equip", "damage",
            "hit", "attack", "kill", "spawn", "teleport", "speed",
            "inventory", "trade", "gift", "code", "redeem", "plot",
            "notification", "leaderboard"
        }
        
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            pcall(function()
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local nameLower = string.lower(obj.Name)
                    for _, kw in ipairs(keywords) do
                        if string.find(nameLower, kw) then
                            local icon = obj:IsA("RemoteEvent") and "🔴 RE" or "🔵 RF"
                            Log(icon .. " | " .. obj.Name .. " | Path: " .. obj:GetFullName():gsub("ReplicatedStorage%.", ""), 1)
                            break
                        end
                    end
                end
            end)
        end
    end)
end

-- ╔══════════════════════════════════════════════════════╗
-- ║  ESCANEO 4: ESTRUCTURA DEL WORKSPACE                 ║
-- ╚══════════════════════════════════════════════════════╝
local function ScanWorkspace()
    NewSection("🌍", "ESTRUCTURA DEL WORKSPACE")
    
    -- Carpetas principales
    pcall(function()
        Log("📁 HIJOS DIRECTOS DE WORKSPACE:")
        for _, child in ipairs(Workspace:GetChildren()) do
            pcall(function()
                local desc = #child:GetDescendants()
                local extra = ""
                if child:IsA("Model") then extra = " [Model]"
                elseif child:IsA("Folder") then extra = " [Folder]"
                elseif child:IsA("Camera") then extra = " [Camera]"
                elseif child:IsA("Terrain") then extra = " [Terrain]"
                elseif child:IsA("BasePart") then extra = " [Part]"
                elseif child:IsA("SpawnLocation") then extra = " [Spawn]"
                end
                Log("  " .. child.Name .. extra .. " (" .. desc .. " descendientes)", 1)
            end)
        end
    end)
    
    -- NPCs y Humanoids
    pcall(function()
        Log("\n🧍 MODELOS CON HUMANOID (NPCs/Mobs/Players):")
        local humanoidModels = {}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("Model") and obj:FindFirstChildWhichIsA("Humanoid") then
                    local hum = obj:FindFirstChildWhichIsA("Humanoid")
                    local isPlayer = false
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.Character == obj then isPlayer = true break end
                    end
                    if not isPlayer then
                        table.insert(humanoidModels, {
                            name = obj.Name,
                            health = hum.MaxHealth,
                            speed = hum.WalkSpeed,
                            parent = obj.Parent and obj.Parent.Name or "?",
                            attrs = obj:GetAttributes()
                        })
                    end
                end
            end)
        end
        
        -- Agrupar por nombre
        local groups = {}
        for _, m in ipairs(humanoidModels) do
            if not groups[m.name] then groups[m.name] = {count = 0, data = m} end
            groups[m.name].count = groups[m.name].count + 1
        end
        
        local sortedNames = {}
        for name in pairs(groups) do table.insert(sortedNames, name) end
        table.sort(sortedNames)
        
        for _, name in ipairs(sortedNames) do
            local g = groups[name]
            Log("🧬 " .. name .. " x" .. g.count .. " | HP:" .. tostring(g.data.health) .. " | Speed:" .. tostring(g.data.speed) .. " | En: " .. g.data.parent, 1)
            for k, v in pairs(g.data.attrs) do
                Log("  💎 " .. tostring(k) .. " = " .. SafeValue(v), 2)
            end
        end
        Log("Total NPCs/Mobs: " .. #humanoidModels)
    end)
    
    -- ProximityPrompts
    pcall(function()
        Log("\n🏪 ZONAS INTERACTIVAS (ProximityPrompts):")
        local prompts = {}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                pcall(function()
                    table.insert(prompts, {
                        action = obj.ActionText ~= "" and obj.ActionText or "(sin texto)",
                        object = obj.ObjectText ~= "" and obj.ObjectText or "",
                        parent = obj.Parent and obj.Parent.Name or "?",
                        range = obj.MaxActivationDistance,
                        holdDuration = obj.HoldDuration,
                        path = obj:GetFullName():gsub("Workspace%.", "")
                    })
                end)
            end
        end
        for _, p in ipairs(prompts) do
            Log("🏪 '" .. p.action .. "' " .. (p.object ~= "" and "(" .. p.object .. ")" or "") .. " en " .. p.parent, 1)
            Log("  Rango: " .. tostring(p.range) .. " | Hold: " .. tostring(p.holdDuration) .. "s", 2)
        end
        Log("Total Prompts: " .. #prompts)
    end)
    
    -- ClickDetectors
    pcall(function()
        local clicks = {}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ClickDetector") then
                pcall(function()
                    table.insert(clicks, obj.Parent and obj.Parent.Name or "?")
                end)
            end
        end
        if #clicks > 0 then
            Log("\n👆 CLICK DETECTORS (" .. #clicks .. "):")
            for _, name in ipairs(clicks) do Log("  " .. name, 1) end
        end
    end)
end

-- ╔══════════════════════════════════════════════════════╗
-- ║  ESCANEO 5: SISTEMA DE ECONOMÍA Y VALORES            ║
-- ╚══════════════════════════════════════════════════════╝
local function ScanEconomy()
    NewSection("💰", "ECONOMÍA, VALORES Y DATOS OCULTOS")
    
    -- Buscar ValueBases en todo el juego
    pcall(function()
        Log("📌 VALORES (ValueBase) EN REPLICATEDSTORAGE:")
        local count = 0
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            pcall(function()
                if obj:IsA("ValueBase") then
                    count = count + 1
                    if count <= 50 then
                        Log(obj:GetFullName():gsub("ReplicatedStorage%.", "") .. " = " .. SafeValue(obj.Value), 1)
                    end
                end
            end)
        end
        Log("Total ValueBases en RS: " .. count)
    end)
    
    -- Atributos en objetos clave
    pcall(function()
        Log("\n💎 OBJETOS CON ATRIBUTOS EN WORKSPACE:")
        local attrCount = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            pcall(function()
                local attrs = obj:GetAttributes()
                local hasAttrs = false
                for _ in pairs(attrs) do hasAttrs = true break end
                if hasAttrs then
                    attrCount = attrCount + 1
                    if attrCount <= 40 then
                        Log("🏷️ " .. obj.Name .. " (" .. obj.ClassName .. ") en " .. (obj.Parent and obj.Parent.Name or "?"), 1)
                        for k, v in pairs(attrs) do
                            Log("  " .. tostring(k) .. " = " .. SafeValue(v) .. " [" .. typeof(v) .. "]", 2)
                        end
                    end
                end
            end)
        end
        Log("Total objetos con atributos: " .. attrCount)
    end)
end

-- ╔══════════════════════════════════════════════════════╗
-- ║  ESCANEO 6: GUIs DEL CLIENTE                         ║
-- ╚══════════════════════════════════════════════════════╝
local function ScanGUIs()
    NewSection("🖥️", "GUIs DEL CLIENTE (PlayerGui)")
    
    pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then Log("⚠️ Sin PlayerGui"); return end
        
        for _, sg in ipairs(pg:GetChildren()) do
            if sg:IsA("ScreenGui") then
                pcall(function()
                    local frames = 0
                    local buttons = 0
                    local labels = 0
                    local images = 0
                    for _, d in ipairs(sg:GetDescendants()) do
                        if d:IsA("Frame") then frames = frames + 1
                        elseif d:IsA("TextButton") or d:IsA("ImageButton") then buttons = buttons + 1
                        elseif d:IsA("TextLabel") then labels = labels + 1
                        elseif d:IsA("ImageLabel") then images = images + 1
                        end
                    end
                    Log("🖥️ " .. sg.Name .. " | Enabled:" .. tostring(sg.Enabled) .. " | F:" .. frames .. " B:" .. buttons .. " L:" .. labels .. " I:" .. images, 1)
                end)
            end
        end
    end)
end

-- ╔══════════════════════════════════════════════════════╗
-- ║  ESCANEO 7: SCRIPTS Y SEGURIDAD                      ║
-- ╚══════════════════════════════════════════════════════╝
local function ScanSecurity()
    NewSection("🔒", "SEGURIDAD Y SCRIPTS DETECTADOS")
    
    -- Scripts en PlayerScripts
    pcall(function()
        local ps = LocalPlayer:FindFirstChild("PlayerScripts")
        if ps then
            Log("📜 SCRIPTS EN PLAYERSCRIPTS:")
            for _, s in ipairs(ps:GetDescendants()) do
                if s:IsA("LocalScript") or s:IsA("ModuleScript") then
                    pcall(function()
                        -- Filtrar los default de Roblox
                        local isDefault = string.find(s:GetFullName(), "PlayerModule") or 
                                         string.find(s:GetFullName(), "RbxCharacterSounds") or
                                         string.find(s:GetFullName(), "PlayerScriptsLoader")
                        if not isDefault then
                            Log("  📜 " .. s.Name .. " (" .. s.ClassName .. ") en " .. (s.Parent and s.Parent.Name or "?"), 1)
                        end
                    end)
                end
            end
        end
    end)
    
    -- Scripts en ReplicatedFirst (anti-cheat típico)
    pcall(function()
        local rf = game:GetService("ReplicatedFirst")
        Log("\n🛡️ SCRIPTS EN REPLICATED FIRST (posible anti-cheat):")
        for _, s in ipairs(rf:GetDescendants()) do
            pcall(function()
                if s:IsA("LocalScript") or s:IsA("ModuleScript") or s:IsA("Script") then
                    Log("  ⚠️ " .. s.Name .. " (" .. s.ClassName .. ")", 1)
                end
            end)
        end
        if #rf:GetChildren() == 0 then
            Log("  (Vacío — sin scripts anti-cheat en ReplicatedFirst)", 1)
        end
    end)
    
    -- Buscar nombres sospechosos de anti-cheat
    pcall(function()
        Log("\n🚨 DETECCIÓN HEURÍSTICA DE ANTI-CHEAT:")
        local acTerms = {"anticheat", "anti_cheat", "integrity", "security", "heartbeat_check", "validation", "servercheck"}
        local found = {}
        
        for _, container in ipairs({ReplicatedStorage, Workspace}) do
            for _, obj in ipairs(container:GetDescendants()) do
                pcall(function()
                    local n = string.lower(obj.Name)
                    for _, term in ipairs(acTerms) do
                        if string.find(n, term) then
                            table.insert(found, obj.Name .. " (" .. obj.ClassName .. ") en " .. (obj.Parent and obj.Parent.Name or "?"))
                            break
                        end
                    end
                end)
            end
        end
        
        if #found > 0 then
            for _, f in ipairs(found) do Log("  🚨 " .. f, 1) end
        else
            Log("  ✅ No se detectaron nombres típicos de anti-cheat", 1)
        end
    end)
end

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  EJECUTAR TODOS LOS ESCANEOS                                ║
-- ╚══════════════════════════════════════════════════════════════╝
local function RunFullScan(statusCallback)
    Report = {}
    
    if statusCallback then statusCallback("Escaneando info del juego...") end
    pcall(ScanGameInfo)
    
    if statusCallback then statusCallback("Escaneando tu perfil...") end
    pcall(ScanLocalPlayer)
    
    if statusCallback then statusCallback("Escaneando red (puede tardar)...") end
    pcall(ScanNetwork)
    task.wait() -- yield para evitar timeout
    
    if statusCallback then statusCallback("Escaneando mundo...") end
    pcall(ScanWorkspace)
    task.wait()
    
    if statusCallback then statusCallback("Escaneando economia...") end
    pcall(ScanEconomy)
    
    if statusCallback then statusCallback("Escaneando GUIs...") end
    pcall(ScanGUIs)
    
    if statusCallback then statusCallback("Escaneando seguridad...") end
    pcall(ScanSecurity)
    
    if statusCallback then statusCallback("¡Escaneo completo!") end
end

-- Generar texto plano del reporte
local function GenerateFullText()
    local text = ""
    text = text .. "================================================================\n"
    text = text .. "  FORENSE SCANNER V2.0 — REPORTE COMPLETO\n"
    text = text .. "  Juego: " .. tostring(game.PlaceId) .. " | " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
    text = text .. "================================================================\n\n"
    
    for _, section in ipairs(Report) do
        text = text .. "\n" .. string.rep("─", 60) .. "\n"
        text = text .. "  " .. section.title .. "\n"
        text = text .. string.rep("─", 60) .. "\n"
        for _, line in ipairs(section.lines) do
            text = text .. line .. "\n"
        end
    end
    
    text = text .. "\n================================================================\n"
    text = text .. "  FIN DEL REPORTE\n"
    text = text .. "================================================================\n"
    return text
end

-- ╔══════════════════════════════════════════════════════════════╗
-- ║  GUI V2.0 — ULTRA ROBUSTA (DRAG MANUAL, SIN DEPRECIADOS)   ║
-- ╚══════════════════════════════════════════════════════════════╝
local function BuildGUI()
    -- Padre seguro
    local guiParent
    pcall(function()
        local cg = game:GetService("CoreGui")
        local _ = cg.Name
        guiParent = cg
    end)
    if not guiParent then
        pcall(function() guiParent = LocalPlayer:WaitForChild("PlayerGui", 5) end)
    end
    if not guiParent then
        warn("[ForenseScanner] No se puede crear GUI!")
        return
    end

    -- Limpiar anterior
    pcall(function()
        for _, v in ipairs(guiParent:GetChildren()) do
            if v.Name == "_ForenseScanner_UI" then v:Destroy() end
        end
    end)

    local sg = Instance.new("ScreenGui")
    sg.Name = "_ForenseScanner_UI"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = guiParent

    -- Frame principal
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 660, 0, 520)
    main.Position = UDim2.new(0.5, -330, 0.5, -260)
    main.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
    main.BorderSizePixel = 0
    main.Active = true
    main.Parent = sg

    -- Borde glow
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 180, 255)
    stroke.Thickness = 2
    stroke.Parent = main

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = main

    -- ═══ DRAG MANUAL (SIN .Draggable) ═══
    local dragging, dragStart, startPos = false, nil, nil
    
    local topbar = Instance.new("Frame")
    topbar.Name = "TopBar"
    topbar.Size = UDim2.new(1, 0, 0, 36)
    topbar.BackgroundColor3 = Color3.fromRGB(15, 30, 50)
    topbar.BorderSizePixel = 0
    topbar.Parent = main
    Instance.new("UICorner", topbar).CornerRadius = UDim.new(0, 8)
    
    -- Fix corners: add un frame abajo del topbar para tapar las esquinas redondeadas inferiores
    local topBarFix = Instance.new("Frame")
    topBarFix.Size = UDim2.new(1, 0, 0, 10)
    topBarFix.Position = UDim2.new(0, 0, 1, -10)
    topBarFix.BackgroundColor3 = Color3.fromRGB(15, 30, 50)
    topBarFix.BorderSizePixel = 0
    topBarFix.Parent = topbar

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "  FORENSE SCANNER V2.0 — Steal a Brainrot"
    titleLabel.TextColor3 = Color3.fromRGB(100, 220, 255)
    titleLabel.Font = Enum.Font.Code
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topbar

    -- Botón cerrar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 36, 0, 36)
    closeBtn.Position = UDim2.new(1, -36, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.Code
    closeBtn.TextSize = 16
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = topbar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

    -- Botón minimizar
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 36, 0, 36)
    minBtn.Position = UDim2.new(1, -74, 0, 0)
    minBtn.BackgroundColor3 = Color3.fromRGB(150, 130, 20)
    minBtn.Text = "—"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.Font = Enum.Font.Code
    minBtn.TextSize = 16
    minBtn.BorderSizePixel = 0
    minBtn.Parent = topbar
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

    local minimized = false
    local restoreIcon = Instance.new("ImageButton")
    restoreIcon.Size = UDim2.new(0, 50, 0, 50)
    restoreIcon.Position = UDim2.new(0, 20, 0, 20)
    restoreIcon.BackgroundColor3 = Color3.fromRGB(20, 40, 60)
    restoreIcon.Visible = false
    restoreIcon.Active = true
    restoreIcon.Parent = sg
    Instance.new("UICorner", restoreIcon).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", restoreIcon).Color = Color3.fromRGB(0, 180, 255)
    
    local restoreLabel = Instance.new("TextLabel")
    restoreLabel.Size = UDim2.new(1, 0, 1, 0)
    restoreLabel.BackgroundTransparency = 1
    restoreLabel.Text = "FS"
    restoreLabel.TextColor3 = Color3.fromRGB(100, 220, 255)
    restoreLabel.Font = Enum.Font.Code
    restoreLabel.TextSize = 16
    restoreLabel.Parent = restoreIcon

    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        main.Visible = not minimized
        restoreIcon.Visible = minimized
    end)
    restoreIcon.MouseButton1Click:Connect(function()
        minimized = false
        main.Visible = true
        restoreIcon.Visible = false
    end)

    -- ═══ PESTAÑAS DE SECCIONES ═══
    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Size = UDim2.new(0, 160, 1, -90)
    tabScroll.Position = UDim2.new(0, 4, 0, 40)
    tabScroll.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
    tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabScroll.ScrollBarThickness = 4
    tabScroll.BorderSizePixel = 0
    tabScroll.Parent = main
    Instance.new("UICorner", tabScroll).CornerRadius = UDim.new(0, 6)
    local tabLayout = Instance.new("UIListLayout", tabScroll)
    tabLayout.Padding = UDim.new(0, 2)

    -- Contenido principal
    local contentScroll = Instance.new("ScrollingFrame")
    contentScroll.Size = UDim2.new(1, -174, 1, -90)
    contentScroll.Position = UDim2.new(0, 168, 0, 40)
    contentScroll.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
    contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentScroll.ScrollBarThickness = 6
    contentScroll.BorderSizePixel = 0
    contentScroll.Parent = main
    Instance.new("UICorner", contentScroll).CornerRadius = UDim.new(0, 6)
    local contentLayout = Instance.new("UIListLayout", contentScroll)
    contentLayout.Padding = UDim.new(0, 1)

    -- Status bar
    local statusBar = Instance.new("TextLabel")
    statusBar.Name = "StatusBar"
    statusBar.Size = UDim2.new(1, -8, 0, 20)
    statusBar.Position = UDim2.new(0, 4, 1, -48)
    statusBar.BackgroundTransparency = 1
    statusBar.Text = "Listo. Pulsa INICIAR SCAN para comenzar."
    statusBar.TextColor3 = Color3.fromRGB(150, 150, 180)
    statusBar.Font = Enum.Font.Code
    statusBar.TextSize = 11
    statusBar.TextXAlignment = Enum.TextXAlignment.Left
    statusBar.Parent = main

    -- Función para mostrar una sección
    local activeTab = nil

    local function ShowSection(sectionIdx)
        -- Limpiar contenido
        for _, c in ipairs(contentScroll:GetChildren()) do
            if c:IsA("TextLabel") then c:Destroy() end
        end
        contentScroll.CanvasPosition = Vector2.new(0, 0)
        
        if not Report[sectionIdx] then return end
        local section = Report[sectionIdx]
        
        -- Título
        local ht = Instance.new("TextLabel")
        ht.Name = "Header"
        ht.Size = UDim2.new(1, -10, 0, 30)
        ht.BackgroundColor3 = Color3.fromRGB(20, 40, 60)
        ht.Text = "  " .. section.title
        ht.TextColor3 = Color3.fromRGB(100, 220, 255)
        ht.Font = Enum.Font.Code
        ht.TextSize = 13
        ht.TextXAlignment = Enum.TextXAlignment.Left
        ht.BorderSizePixel = 0
        ht.Parent = contentScroll
        
        -- Líneas
        for i, line in ipairs(section.lines) do
            local lbl = Instance.new("TextLabel")
            lbl.Name = "Line_" .. i
            lbl.Size = UDim2.new(1, -10, 0, 0)
            lbl.AutomaticSize = Enum.AutomaticSize.Y
            lbl.BackgroundTransparency = (i % 2 == 0) and 0.95 or 1
            lbl.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
            lbl.Text = line
            lbl.TextWrapped = true
            lbl.RichText = false
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextYAlignment = Enum.TextYAlignment.Top
            lbl.Font = Enum.Font.Code
            lbl.TextSize = 11
            lbl.BorderSizePixel = 0
            lbl.Parent = contentScroll
            
            -- Colorear según contenido
            if string.find(line, "FALLA") or string.find(line, "ERROR") or string.find(line, "CRASHEA") then
                lbl.TextColor3 = Color3.fromRGB(255, 100, 100)
            elseif string.find(line, "⚠️") or string.find(line, "WARN") then
                lbl.TextColor3 = Color3.fromRGB(255, 230, 130)
            elseif string.find(line, "🚨") then
                lbl.TextColor3 = Color3.fromRGB(255, 150, 80)
            elseif string.find(line, "✅") then
                lbl.TextColor3 = Color3.fromRGB(100, 255, 100)
            elseif string.find(line, "📂") or string.find(line, "📁") then
                lbl.TextColor3 = Color3.fromRGB(130, 200, 255)
            elseif string.find(line, "🔴") then
                lbl.TextColor3 = Color3.fromRGB(255, 150, 150)
            elseif string.find(line, "🔵") then
                lbl.TextColor3 = Color3.fromRGB(150, 150, 255)
            else
                lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end
        
        -- Highlight tab activo
        if activeTab then
            pcall(function() activeTab.BackgroundColor3 = Color3.fromRGB(25, 25, 40) end)
        end
    end

    local function BuildTabs()
        for _, c in ipairs(tabScroll:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        
        for i, section in ipairs(Report) do
            local tabBtn = Instance.new("TextButton")
            tabBtn.Name = "Tab_" .. i
            tabBtn.Size = UDim2.new(1, -4, 0, 32)
            tabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
            tabBtn.Text = " " .. section.title
            tabBtn.TextColor3 = Color3.fromRGB(180, 200, 220)
            tabBtn.Font = Enum.Font.Code
            tabBtn.TextSize = 10
            tabBtn.TextXAlignment = Enum.TextXAlignment.Left
            tabBtn.TextTruncate = Enum.TextTruncate.AtEnd
            tabBtn.BorderSizePixel = 0
            tabBtn.AutoButtonColor = true
            tabBtn.Parent = tabScroll
            Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 4)
            
            tabBtn.MouseButton1Click:Connect(function()
                activeTab = tabBtn
                tabBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 100)
                ShowSection(i)
            end)
        end
    end

    -- ═══ BOTONES INFERIORES ═══
    local btnFrame = Instance.new("Frame")
    btnFrame.Size = UDim2.new(1, -8, 0, 38)
    btnFrame.Position = UDim2.new(0, 4, 1, -42)
    btnFrame.BackgroundTransparency = 1
    btnFrame.Parent = main

    local btnScan = Instance.new("TextButton")
    btnScan.Size = UDim2.new(0.32, -4, 1, 0)
    btnScan.Position = UDim2.new(0, 0, 0, 0)
    btnScan.BackgroundColor3 = Color3.fromRGB(0, 120, 80)
    btnScan.Text = "INICIAR SCAN"
    btnScan.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnScan.Font = Enum.Font.Code
    btnScan.TextSize = 12
    btnScan.BorderSizePixel = 0
    btnScan.Parent = btnFrame
    Instance.new("UICorner", btnScan).CornerRadius = UDim.new(0, 6)

    local btnSave = Instance.new("TextButton")
    btnSave.Size = UDim2.new(0.34, -4, 1, 0)
    btnSave.Position = UDim2.new(0.32, 4, 0, 0)
    btnSave.BackgroundColor3 = Color3.fromRGB(0, 80, 170)
    btnSave.Text = "GUARDAR .TXT"
    btnSave.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnSave.Font = Enum.Font.Code
    btnSave.TextSize = 12
    btnSave.BorderSizePixel = 0
    btnSave.Parent = btnFrame
    Instance.new("UICorner", btnSave).CornerRadius = UDim.new(0, 6)

    local btnCopy = Instance.new("TextButton")
    btnCopy.Size = UDim2.new(0.34, -4, 1, 0)
    btnCopy.Position = UDim2.new(0.66, 4, 0, 0)
    btnCopy.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
    btnCopy.Text = "COPIAR TODO"
    btnCopy.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnCopy.Font = Enum.Font.Code
    btnCopy.TextSize = 12
    btnCopy.BorderSizePixel = 0
    btnCopy.Parent = btnFrame
    Instance.new("UICorner", btnCopy).CornerRadius = UDim.new(0, 6)

    -- ═══ EVENTOS ═══
    local scanning = false
    
    btnScan.MouseButton1Click:Connect(function()
        if scanning then return end
        scanning = true
        btnScan.Text = "ESCANEANDO..."
        btnScan.BackgroundColor3 = Color3.fromRGB(180, 130, 0)
        
        task.spawn(function()
            RunFullScan(function(status)
                pcall(function() statusBar.Text = status end)
            end)
            
            pcall(function()
                BuildTabs()
                if #Report > 0 then ShowSection(1) end
                btnScan.Text = "RE-SCAN"
                btnScan.BackgroundColor3 = Color3.fromRGB(0, 120, 80)
                statusBar.Text = "Escaneo completado. " .. #Report .. " secciones generadas."
                scanning = false
            end)
        end)
    end)
    
    btnSave.MouseButton1Click:Connect(function()
        pcall(function()
            if #Report == 0 then statusBar.Text = "Primero ejecuta un scan!"; return end
            local text = GenerateFullText()
            if writefile then
                writefile("ForenseScan_" .. tostring(game.PlaceId) .. ".txt", text)
                btnSave.Text = "GUARDADO!"
                btnSave.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
                statusBar.Text = "Guardado en workspace: ForenseScan_" .. tostring(game.PlaceId) .. ".txt"
            else
                btnSave.Text = "SIN writefile"
                btnSave.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
            end
            task.delay(3, function()
                pcall(function()
                    btnSave.Text = "GUARDAR .TXT"
                    btnSave.BackgroundColor3 = Color3.fromRGB(0, 80, 170)
                end)
            end)
        end)
    end)
    
    btnCopy.MouseButton1Click:Connect(function()
        pcall(function()
            if #Report == 0 then statusBar.Text = "Primero ejecuta un scan!"; return end
            local text = GenerateFullText()
            if setclipboard then
                setclipboard(text)
                btnCopy.Text = "COPIADO!"
                btnCopy.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
            elseif toclipboard then
                toclipboard(text)
                btnCopy.Text = "COPIADO!"
                btnCopy.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
            else
                btnCopy.Text = "SIN CLIPBOARD"
                btnCopy.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
            end
            task.delay(3, function()
                pcall(function()
                    btnCopy.Text = "COPIAR TODO"
                    btnCopy.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
                end)
            end)
        end)
    end)
end

-- ═══ INICIAR ═══
pcall(BuildGUI)
print("[ForenseScanner V2.0] GUI cargada. Pulsa INICIAR SCAN.")
