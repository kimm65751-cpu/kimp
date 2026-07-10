-- =====================================================
-- EVOMON DEEP SCANNER v1
-- Corre esto PRIMERO, genera: EvomonQA_ScanData.txt
-- Luego usa ese .txt para el script principal
-- =====================================================

local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local LP      = Players.LocalPlayer

local OUT = "EvomonQA_ScanData.txt"
local lines = {}

local function w(s) table.insert(lines, s) end
local function save()
    local full = table.concat(lines, "\n")
    if writefile then writefile(OUT, full) end
    print("[SCANNER] Guardado en " .. OUT)
end

w("=== EVOMON DEEP SCANNER - " .. os.date("%Y-%m-%d %H:%M:%S") .. " ===")
w("")

-- =====================================================
-- 1. MONSTRUOS EN WORKSPACE
--    Filtra jugadores reales
-- =====================================================
w("--- [1] MODELOS EN WORKSPACE (NO-JUGADORES, CON HRP) ---")
local playerNames = {}
for _, p in ipairs(Players:GetPlayers()) do
    playerNames[p.Name] = true
end

local monsterCount = 0
for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
        if not playerNames[obj.Name] then
            local hrp = obj.HumanoidRootPart
            local char = LP.Character
            local dist = char and char:FindFirstChild("HumanoidRootPart")
                and math.floor((hrp.Position - char.HumanoidRootPart.Position).Magnitude)
                or -1
            -- Solo registrar los que tienen Humanoid (son NPC real)
            if obj:FindFirstChildOfClass("Humanoid") then
                w("  NPC | " .. obj.Name .. " | path=" .. obj:GetFullName() .. " | dist=" .. dist)
                monsterCount += 1
            end
            -- ProximityPrompts dentro del modelo
            for _, pp in ipairs(obj:GetDescendants()) do
                if pp:IsA("ProximityPrompt") then
                    w("    -> ProximityPrompt: " .. pp:GetFullName() .. " action=" .. pp.ActionText)
                end
            end
        end
    end
end
w("  TOTAL NPCs con Humanoid: " .. monsterCount)
w("")

-- =====================================================
-- 2. TODOS LOS BOTONES EN PLAYERGUI (visible e invisible)
-- =====================================================
w("--- [2] BOTONES EN PLAYERGUI (TextButton / ImageButton) ---")
local pg = LP:FindFirstChildOfClass("PlayerGui")
if pg then
    for _, obj in ipairs(pg:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            local vis = obj.Visible and "VISIBLE" or "hidden"
            local txt = obj:IsA("TextButton") and obj.Text or "(ImageButton)"
            w("  BTN[" .. vis .. "] name=" .. obj.Name .. " text=\"" .. txt .. "\" path=" .. obj:GetFullName())
        end
    end
else
    w("  ERROR: No se encontró PlayerGui")
end
w("")

-- =====================================================
-- 3. REMOTOS EN REPLICATEDSTORAGE (batalla, captura, pity)
-- =====================================================
w("--- [3] REMOTEEVENTS Y REMOTEFUNCTIONS EN RS ---")
local keywords = {
    "battle","catch","escape","flee","pity","summon",
    "monster","capture","operate","enter","settle","result"
}
for _, obj in ipairs(RS:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        local low = string.lower(obj.Name)
        for _, kw in ipairs(keywords) do
            if string.find(low, kw) then
                w("  REMOTE[" .. obj.ClassName .. "] " .. obj.Name .. " | " .. obj:GetFullName())
                break
            end
        end
    end
end
w("")

-- =====================================================
-- 4. PROXIMITYPPROMPTS EN WORKSPACE (para interactuar)
-- =====================================================
w("--- [4] PROXIMITYPROMPTS EN WORKSPACE ---")
for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("ProximityPrompt") then
        w("  PP | " .. obj.ActionText .. " | " .. obj:GetFullName())
    end
end
w("")

-- =====================================================
-- 5. VALORES DE PITY EN LEADERSTATS / DATASTORES
-- =====================================================
w("--- [5] LEADERSTATS Y VALORES DEL JUGADOR ---")
for _, child in ipairs(LP:GetChildren()) do
    if child:IsA("Folder") or child:IsA("Model") then
        w("  FOLDER: " .. child.Name)
        for _, v in ipairs(child:GetChildren()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") or v:IsA("StringValue") then
                w("    VALUE: " .. v.Name .. " = " .. tostring(v.Value))
            end
        end
    end
    if child:IsA("IntValue") or child:IsA("NumberValue") or child:IsA("StringValue") then
        w("  PLAYERVAL: " .. child.Name .. " = " .. tostring(child.Value))
    end
end
w("")

-- =====================================================
-- 6. TEXTLABELS CON "PITY" O "SHINY" O "PRISMATIC"
-- =====================================================
w("--- [6] TEXTLABELS CON PITY/SHINY/PRISMATIC ACTIVOS ---")
if pg then
    for _, obj in ipairs(pg:GetDescendants()) do
        if (obj:IsA("TextLabel") or obj:IsA("TextBox")) and obj.Text ~= "" then
            local t = string.lower(obj.Text)
            if string.find(t,"pity") or string.find(t,"shiny") or string.find(t,"prismatic")
               or string.find(t,"catch") or string.find(t,"captur") then
                w("  LABEL[" .. obj.Name .. "] text=\"" .. obj.Text .. "\" path=" .. obj:GetFullName())
            end
        end
    end
end
w("")

-- =====================================================
-- 7. ESTRUCTURA DE REPLICATEDSTORAGE (carpetas clave)
-- =====================================================
w("--- [7] CARPETAS EN REPLICATEDSTORAGE ---")
for _, child in ipairs(RS:GetChildren()) do
    w("  RS/" .. child.Name .. " (" .. child.ClassName .. ")")
    for _, sub in ipairs(child:GetChildren()) do
        w("    RS/" .. child.Name .. "/" .. sub.Name .. " (" .. sub.ClassName .. ")")
    end
end
w("")

-- =====================================================
-- 8. MODELOS EN RUNTIMECACHE (donde están los Pet0_N)
-- =====================================================
w("--- [8] RUNTIMECACHE - CREATURE MODEL CACHE ---")
local rc = workspace:FindFirstChild("RuntimeCache")
if rc then
    local srv = rc:FindFirstChild("RuntimeCacheServer")
    if srv then
        local mCache = srv:FindFirstChild("CreatureModelCache")
        if mCache then
            local seen = {}
            for _, folder in ipairs(mCache:GetChildren()) do
                for _, mdl in ipairs(folder:GetChildren()) do
                    if mdl:IsA("Model") and not seen[mdl.Name] then
                        seen[mdl.Name] = true
                        local hasHRP = mdl:FindFirstChild("HumanoidRootPart") ~= nil
                        local hasHum = mdl:FindFirstChildOfClass("Humanoid") ~= nil
                        w("  MODEL: " .. mdl.Name .. " | HRP=" .. tostring(hasHRP) .. " Hum=" .. tostring(hasHum) .. " | in " .. folder.Name)
                    end
                end
            end
        else
            w("  CreatureModelCache NO encontrado en RuntimeCacheServer")
        end
    end
    local cli = rc:FindFirstChild("RuntimeCacheClient")
    if cli then
        w("  RuntimeCacheClient hijos:")
        for _, c in ipairs(cli:GetChildren()) do
            w("    " .. c.Name .. " (" .. c.ClassName .. ")")
        end
    end
else
    w("  RuntimeCache NO existe en workspace")
end
w("")

w("=== FIN DEL SCANNER ===")
save()
print("[SCANNER] LISTO. Lee el archivo: " .. OUT)
