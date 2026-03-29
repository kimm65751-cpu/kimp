-- ==============================================================================
-- 👑 DELTA MASTER ANALYZER 2026 (INDUSTRY STANDARD)
-- ==============================================================================
-- Utilizando las API más agresivas y correctas de Delta (getloadedmodules, 
-- getscenv, saveinstance, getnilinstances) para destripar la memoria activa.
-- Este no lee el código estático, lee la memoria RAM del juego en tiempo real.
-- ==============================================================================

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local DumpFile = "DeltaMasterDump_2026.txt"
pcall(function() if writefile then writefile(DumpFile, "=== 👑 DELTA MASTER ANALYZER 2026 ===\n\n") end end)

local function AppendLog(str)
    task.spawn(function()
        pcall(function()
            if appendfile then appendfile(DumpFile, str .. "\n")
            elseif writefile then writefile(DumpFile, readfile(DumpFile) .. str .. "\n") end
        end)
    end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaAnalyzerUI"
ScreenGui.Parent = pcall(function() return game:GetService("CoreGui").Name end) and game:GetService("CoreGui") or LP:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 450, 0, 150)
Frame.Position = UDim2.new(0.5, -225, 0.8, 0)
Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = " 👑 DELTA MASTER ANALYZER 2026"
Title.Font = Enum.Font.Code

local Status = Instance.new("TextLabel", Frame)
Status.Size = UDim2.new(1, 0, 1, -30)
Status.Position = UDim2.new(0, 0, 0, 30)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(0, 255, 100)
Status.Text = "Iniciando barrido de memoria..."
Status.Font = Enum.Font.Code

task.spawn(function()
    AppendLog("=========== [1] MÓDULOS CARGADOS EN MEMORIA (getloadedmodules) ===========")
    Status.Text = "Extrayendo módulos inicializados..."
    pcall(function()
        local modules = getloadedmodules()
        for i, mod in ipairs(modules) do
            local nameLower = string.lower(mod.Name)
            if string.find(nameLower, "character") or string.find(nameLower, "forge") or string.find(nameLower, "tutorial") then
                AppendLog("📦 Módulo Activo: " .. mod:GetFullName())
                -- Requerimos el módulo activo real para ver su tabla de metadatos en vivo
                local s, req = pcall(function() return require(mod) end)
                if s and type(req) == "table" then
                    AppendLog("   -> Tabla del Singleton obtenida en RAM. Llaves vivas:")
                    for key, val in pairs(req) do
                        local valType = type(val)
                        if valType == "function" or valType == "table" or valType == "string" or valType == "number" or valType == "boolean" then
                            AppendLog("      ["..valType.."] " .. tostring(key) .. " = " .. tostring(val))
                        end
                    end
                end
            end
        end
    end)
    task.wait(1)

    AppendLog("\n=========== [2] INSTANCIAS OCULTAS (getnilinstances) ===========")
    Status.Text = "Buscando scripts ocultos en Nil..."
    pcall(function()
        for _, inst in pairs(getnilinstances()) do
            if inst:IsA("LocalScript") or inst:IsA("ModuleScript") then
                AppendLog("👻 Instancia Fantasma: " .. inst.Name .. " (Clase: " .. inst.ClassName .. ")")
            end
        end
    end)
    task.wait(1)

    AppendLog("\n=========== [3] CONEXIONES Y VALORES (getconnections & getconstants) ===========")
    Status.Text = "Interceptando Remotes y Señales..."
    local searchAreas = {RS, LP.PlayerGui, LP.Character}
    for _, area in ipairs(searchAreas) do
        if area then
            for _, obj in ipairs(area:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("BindableEvent") then
                    pcall(function()
                        local ev = (obj:IsA("RemoteEvent") or obj:IsA("BindableEvent")) and obj.Event or obj.OnClientInvoke
                        local cons = getconnections(ev)
                        if #cons > 0 then
                            AppendLog("📡 [Red/Local] " .. obj:GetFullName() .. " tiene " .. #cons .. " oyentes:")
                            for i, con in ipairs(cons) do
                                local info = debug.getinfo(con.Function)
                                AppendLog("   -> Escuchado en: " .. (info.short_src or "Unknown") .. " Línea: " .. tostring(info.linedefined))
                                
                                local consts = debug.getconstants(con.Function)
                                local strConsts = ""
                                for _, c in pairs(consts) do
                                    if type(c)=="string" and #c > 2 and #c < 20 then strConsts = strConsts .. c .. ", " end
                                end
                                if strConsts ~= "" then AppendLog("      Constantes: " .. strConsts) end
                            end
                        end
                    end)
                end
            end
        end
    end
    task.wait(1)

    AppendLog("\n=========== [4] DECOMPILACIÓN TOTAL (saveinstance) ===========")
    Status.Text = "Guardando el juego completo en tu disco (saveinstance)..."
    pcall(function()
        AppendLog("⚠️ Ejecutando saveinstance(). El juego será copiado a tu carpeta de workspace como un archivo .rbxlx")
        saveinstance({
            mode = "optimized",
            noscripts = false,
            decompile = true,
            decomptype = "new",
            timeout = 30000
        })
        AppendLog("✅ saveinstance() completado o en progreso (Revisa la carpeta de tu ejecutor).")
    end)

    Status.Text = "✅ ¡ANÁLISIS MASTER COMPLETADO!\n1. Revisa DeltaMasterDump_2026.txt\n2. Revisa el archivo .rbxlx creado."
    task.wait(4)
    ScreenGui:Destroy()
end)
