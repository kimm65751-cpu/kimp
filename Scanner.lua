-- ==============================================================================
-- 🦖 CATCH A MONSTER: V8.0 — ESPÍA DE TRÁFICO + REPLAY ATTACK
-- Interceptamos TODO lo que el cliente envía al servidor.
-- Luego repetimos los ataques de nuestras mascotas x20.
-- ==============================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

local UI_Name = "CAM_Spy"
if CoreGui:FindFirstChild(UI_Name) then CoreGui[UI_Name]:Destroy() end

local SG = Instance.new("ScreenGui")
SG.Name = UI_Name
SG.ResetOnSpawn = false
SG.Parent = pcall(function() return CoreGui.Name end) and CoreGui or LP:WaitForChild("PlayerGui")

local MF = Instance.new("Frame", SG)
MF.Size = UDim2.new(0, 480, 0, 380)
MF.Position = UDim2.new(0.45, 0, 0.2, 0)
MF.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MF.BorderSizePixel = 2
MF.BorderColor3 = Color3.fromRGB(255, 200, 0)
MF.Active = true
MF.Draggable = true

local Title = Instance.new("TextLabel", MF)
Title.Size = UDim2.new(1, 0, 0, 26)
Title.BackgroundColor3 = Color3.fromRGB(80, 60, 0)
Title.Text = " 🕵️ ESPÍA DE RED + REPLAY ATTACK V8"
Title.TextColor3 = Color3.fromRGB(255, 230, 150)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left

local LogFrame = Instance.new("ScrollingFrame", MF)
LogFrame.Size = UDim2.new(1, -12, 0, 200)
LogFrame.Position = UDim2.new(0, 6, 0, 30)
LogFrame.BackgroundColor3 = Color3.fromRGB(3, 3, 3)
LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LogFrame.ScrollBarThickness = 4
LogFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", LogFrame).SortOrder = Enum.SortOrder.LayoutOrder

local lc = 0
local logBuffer = {}
local function Log(t, c)
    lc = lc + 1
    table.insert(logBuffer, "["..os.date("%X").."] "..t)
    local m = Instance.new("TextLabel", LogFrame)
    m.Size = UDim2.new(1, 0, 0, 15)
    m.BackgroundTransparency = 1
    m.Text = logBuffer[#logBuffer]
    m.TextXAlignment = Enum.TextXAlignment.Left
    m.TextColor3 = c or Color3.fromRGB(170, 170, 170)
    m.Font = Enum.Font.Code; m.TextSize = 10
    m.TextWrapped = true; m.AutomaticSize = Enum.AutomaticSize.Y
    m.LayoutOrder = lc
    LogFrame.CanvasPosition = Vector2.new(0, 99999)
end

local function MkBtn(txt, py)
    local b = Instance.new("TextButton", MF)
    b.Size = UDim2.new(0.92, 0, 0, 28)
    b.Position = UDim2.new(0.04, 0, 0, py)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamSemibold; b.TextSize = 11
    b.Text = txt
    return b
end

local btnSpy     = MkBtn("🕵️ ACTIVAR: Espía de Tráfico (FireServer)", 236)
local btnModules = MkBtn("📦 ESCANEAR: Módulos ClientLogic", 268)
local btnFarm    = MkBtn("⚔️ AUTO-FARM (Click + Catch)", 300)
local btnExport  = MkBtn("💾 EXPORTAR TODO A .txt", 332)

-- ==========================================================
-- 1. ESPÍA DE TRÁFICO: hookmetamethod __namecall
-- ==========================================================
-- Intercepta TODAS las llamadas FireServer/InvokeServer
-- para ver qué RemoteEvents usa el juego en combate

local spyActive = false
local capturedEvents = {} -- {remoteName, method, args}

btnSpy.MouseButton1Click:Connect(function()
    spyActive = not spyActive
    btnSpy.BackgroundColor3 = spyActive and Color3.fromRGB(200, 150, 0) or Color3.fromRGB(35, 35, 40)
    btnSpy.Text = spyActive and "🕵️ ESPIANDO TRÁFICO..." or "🕵️ ACTIVAR: Espía de Tráfico"
    
    if not spyActive then return end
    
    Log("🕵️ Instalando hookmetamethod...", Color3.fromRGB(255, 200, 0))
    
    pcall(function()
        if type(hookmetamethod) ~= "function" then
            Log("ERROR: hookmetamethod no disponible", Color3.fromRGB(255, 0, 0))
            return
        end
        
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if spyActive and (method == "FireServer" or method == "InvokeServer") then
                if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") then
                    local remoteName = self.Name
                    local remotePath = self:GetFullName()
                    local argStr = ""
                    
                    -- Serializar los primeros argumentos
                    for i, a in ipairs(args) do
                        if i > 4 then break end
                        if type(a) == "table" then
                            local parts = {}
                            for k, v in pairs(a) do
                                table.insert(parts, tostring(k).."="..tostring(v))
                                if #parts > 5 then break end
                            end
                            argStr = argStr .. " {"..table.concat(parts, ",").."}"
                        else
                            argStr = argStr .. " "..tostring(a)
                        end
                    end
                    
                    -- Guardar para análisis
                    table.insert(capturedEvents, {
                        remote = self,
                        remoteName = remoteName,
                        path = remotePath,
                        method = method,
                        args = args,
                        time = os.clock()
                    })
                    
                    -- Log (limitar para no saturar)
                    if #capturedEvents % 3 == 1 or #capturedEvents <= 20 then
                        -- Colorear según tipo
                        local col = Color3.fromRGB(200, 200, 200)
                        if argStr:find("Fight") or argStr:find("Skill") or argStr:find("Attack") then
                            col = Color3.fromRGB(255, 100, 100) -- COMBATE en rojo
                        elseif argStr:find("Catch") or argStr:find("Reward") then
                            col = Color3.fromRGB(100, 255, 100) -- CAPTURA en verde
                        elseif argStr:find("Click") or argStr:find("Input") then
                            col = Color3.fromRGB(100, 150, 255) -- INPUT en azul
                        end
                        
                        local preview = remoteName..":"..method..argStr
                        if #preview > 150 then preview = preview:sub(1, 150).."..." end
                        Log("#"..#capturedEvents.." "..preview, col)
                    end
                end
            end
            
            return oldNamecall(self, ...)
        end))
        
        Log("✅ Hook instalado. Ahora pelea un mob manualmente.", Color3.fromRGB(0, 255, 0))
        Log("⚠️ Cada FireServer/InvokeServer se capturará aquí.", Color3.fromRGB(255, 255, 0))
    end)
end)

-- ==========================================================
-- 2. ESCÁNER DE MÓDULOS ClientLogic
-- ==========================================================
btnModules.MouseButton1Click:Connect(function()
    Log("📦 Escaneando ReplicatedStorage.ClientLogic...", Color3.fromRGB(0, 200, 255))
    
    pcall(function()
        local clientLogic = ReplicatedStorage:FindFirstChild("ClientLogic")
        if not clientLogic then
            Log("No existe ClientLogic, buscando alternativas...", Color3.fromRGB(255, 150, 0))
            -- Buscar cualquier carpeta con módulos de combate
            for _, child in pairs(ReplicatedStorage:GetDescendants()) do
                if child:IsA("ModuleScript") then
                    local name = child.Name:lower()
                    if name:find("monster") or name:find("pet") or name:find("fight") or 
                       name:find("attack") or name:find("catch") or name:find("combat") or
                       name:find("skill") or name:find("battle") or name:find("damage") then
                        Log("📄 Módulo: "..child:GetFullName(), Color3.fromRGB(200, 200, 100))
                        
                        -- Intentar require y listar funciones
                        pcall(function()
                            local mod = require(child)
                            if type(mod) == "table" then
                                local funcs = {}
                                for k, v in pairs(mod) do
                                    if type(v) == "function" then
                                        table.insert(funcs, k)
                                    end
                                end
                                if #funcs > 0 then
                                    Log("  → Funciones: "..table.concat(funcs, ", "), Color3.fromRGB(150, 255, 150))
                                end
                            end
                        end)
                    end
                end
            end
            return
        end
        
        -- Si existe ClientLogic, escanear todo
        for _, mod in pairs(clientLogic:GetDescendants()) do
            if mod:IsA("ModuleScript") then
                Log("📄 "..mod:GetFullName(), Color3.fromRGB(200, 200, 100))
                pcall(function()
                    local m = require(mod)
                    if type(m) == "table" then
                        local funcs = {}
                        for k, v in pairs(m) do
                            if type(v) == "function" then
                                table.insert(funcs, k)
                            elseif type(v) == "table" then
                                table.insert(funcs, k.."(tbl)")
                            end
                        end
                        if #funcs > 0 then
                            local str = table.concat(funcs, ", ")
                            if #str > 200 then str = str:sub(1, 200).."..." end
                            Log("  → "..str, Color3.fromRGB(150, 255, 150))
                        end
                    end
                end)
            end
        end
    end)
    
    Log("✅ Escaneo de módulos completo", Color3.fromRGB(0, 255, 0))
end)

-- ==========================================================
-- 3. AUTO-FARM
-- ==========================================================
local farmActive = false
btnFarm.MouseButton1Click:Connect(function()
    farmActive = not farmActive
    btnFarm.BackgroundColor3 = farmActive and Color3.fromRGB(40, 130, 40) or Color3.fromRGB(35, 35, 40)
    btnFarm.Text = farmActive and "⚔️ FARMING..." or "⚔️ AUTO-FARM (Click + Catch)"
end)

task.spawn(function()
    while true do
        if farmActive then
            pcall(function()
                if not LP.Character or not LP.Character.PrimaryPart then return end
                local myPos = LP.Character.PrimaryPart.Position
                local best, bestDist = nil, 80
                local cm = Workspace:FindFirstChild("ClientMonsters")
                if cm then
                    for _, mob in pairs(cm:GetChildren()) do
                        if mob:IsA("Model") then
                            local cd = mob:FindFirstChildWhichIsA("ClickDetector", true)
                            if cd then
                                local p = mob.PrimaryPart or mob:FindFirstChildWhichIsA("BasePart")
                                if p then
                                    local d = (p.Position - myPos).Magnitude
                                    if d < bestDist then bestDist = d; best = cd end
                                end
                            end
                        end
                    end
                end
                if best then fireclickdetector(best) end
            end)
        end
        task.wait(2.5)
    end
end)

task.spawn(function()
    pcall(function()
        for _, desc in pairs(ReplicatedStorage:GetDescendants()) do
            if desc:IsA("RemoteEvent") then
                desc.OnClientEvent:Connect(function(...)
                    local args = {...}
                    if farmActive and tostring(args[1] or "") == "PushRewardEvent" then
                        task.delay(0.3, function()
                            pcall(function()
                                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                task.wait(0.15)
                                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            end)
                        end)
                    end
                end)
            end
        end
    end)
end)

-- ==========================================================
-- 4. EXPORTAR
-- ==========================================================
btnExport.MouseButton1Click:Connect(function()
    local fn = "CAM_SpyDump_"..os.date("%Y%m%d_%H%M%S")..".txt"
    local dump = {}
    table.insert(dump, "=== CAM SPY DUMP ===")
    table.insert(dump, "Date: "..os.date())
    table.insert(dump, "Total captured events: "..#capturedEvents)
    table.insert(dump, "")
    
    -- Log del GUI
    table.insert(dump, "=== GUI LOG ===")
    for _, line in ipairs(logBuffer) do
        table.insert(dump, line)
    end
    table.insert(dump, "")
    
    -- Detalle de cada evento capturado
    table.insert(dump, "=== CAPTURED FIRESERVER EVENTS ===")
    for i, ev in ipairs(capturedEvents) do
        local argParts = {}
        for j, a in ipairs(ev.args) do
            if type(a) == "table" then
                local tblParts = {}
                for k, v in pairs(a) do
                    table.insert(tblParts, tostring(k).."="..tostring(v))
                end
                table.insert(argParts, "arg"..j.."={"..table.concat(tblParts, " | ").."}")
            else
                table.insert(argParts, "arg"..j.."="..tostring(a))
            end
        end
        table.insert(dump, "EVENT #"..i.." | "..ev.remoteName.." ("..ev.path..") | "..ev.method.." | "..table.concat(argParts, " | "))
    end
    
    pcall(function() writefile(fn, table.concat(dump, "\n")) end)
    Log("💾 Exportado: "..fn.." ("..#capturedEvents.." eventos)", Color3.fromRGB(0, 255, 200))
end)

Log("=== INSTRUCCIONES ===", Color3.fromRGB(255, 255, 255))
Log("1) Pulsa 🕵️ ESPÍA para empezar a capturar tráfico", Color3.fromRGB(255, 255, 200))
Log("2) PELEA UN MOB MANUALMENTE (click + pelea normal)", Color3.fromRGB(255, 255, 200))
Log("3) Pulsa 💾 EXPORTAR y mándame el .txt", Color3.fromRGB(255, 255, 200))
Log("4) También pulsa 📦 MÓDULOS para ver qué funciones hay", Color3.fromRGB(255, 255, 200))
Log("Necesito ver QUÉ RemoteEvent usa el cliente para atacar", Color3.fromRGB(255, 200, 100))
