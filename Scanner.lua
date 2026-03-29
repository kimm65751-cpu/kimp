-- ==============================================================================
-- 🔬 SNAPSHOT FINAL V4.0 — MODULE HOOKING (0% Namecall)
-- ==============================================================================
-- Intercepta las funciones nativas de los controladores de la forja.
-- NO toca los remotes. NO rompe ProximityPrompts.
-- ==============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "ForgeModuleSnapUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ForgeModuleSnapUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 320)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 5)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 100, 0)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -75, 0, 28)
Title.BackgroundColor3 = Color3.fromRGB(50, 20, 0)
Title.Text = " 🔬 SNAPSHOT V4.0 (MODULE HOOKING)"
Title.TextColor3 = Color3.fromRGB(255, 150, 50)
Title.TextSize = 11
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0, 75, 0, 28)
SaveBtn.Position = UDim2.new(1, -75, 0, 0)
SaveBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 0)
SaveBtn.Text = "💾 GUARDAR"
SaveBtn.TextColor3 = Color3.new(1,1,1)
SaveBtn.Font = Enum.Font.Code
SaveBtn.Parent = MainFrame

local OutputScroll = Instance.new("ScrollingFrame")
OutputScroll.Size = UDim2.new(1, -8, 1, -34)
OutputScroll.Position = UDim2.new(0, 4, 0, 30)
OutputScroll.BackgroundColor3 = Color3.fromRGB(8, 5, 5)
OutputScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
OutputScroll.ScrollBarThickness = 5
OutputScroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Parent = OutputScroll
UIList.Padding = UDim.new(0, 2)
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    OutputScroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 10)
end)

local FullLog = "=== SNAPSHOT FINAL V4.0 (MODULES) ===\nInicio: " .. os.date() .. "\n\n"
local msgCount = 0

SaveBtn.MouseButton1Click:Connect(function()
    pcall(function() writefile("forge_modules.txt", FullLog) end)
    SaveBtn.Text = "✅ LISTO"
    task.delay(1, function() SaveBtn.Text = "💾 GUARDAR" end)
end)

local startTime = workspace:GetServerTimeNow()

local function Dump(v)
    if typeof(v) == "Instance" then return "["..v.ClassName.."] "..v.Name end
    if typeof(v) == "function" then return "function" end
    if v == nil then return "nil" end
    if type(v) == "table" then
        local s = "{"
        for k, val in pairs(v) do
            if type(val) == "table" then s = s .. tostring(k) .. "={...}, "
            elseif type(val) == "function" then s = s .. tostring(k) .. "=func, "
            else s = s .. tostring(k) .. "=" .. tostring(val) .. ", " end
        end
        return s .. "}"
    end
    return tostring(v)
end

local function L(text, color)
    local timestamp = string.format("%.2fs", workspace:GetServerTimeNow() - startTime)
    local line = "[" .. timestamp .. "] " .. text
    FullLog = FullLog .. line .. "\n"
    msgCount = msgCount + 1
    
    if msgCount % 5 == 0 then pcall(function() writefile("forge_modules.txt", FullLog) end) end
    
    task.defer(function()
        pcall(function()
            local msg = Instance.new("TextLabel")
            msg.Size = UDim2.new(1, -6, 0, 14)
            msg.BackgroundTransparency = 1
            msg.Text = line
            msg.TextColor3 = color or Color3.fromRGB(180, 180, 180)
            msg.TextSize = 10
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
-- HOOK DE MODULE SCRIPTS
-- ==========================================
L("Buscando módulos de la forja...", Color3.fromRGB(200, 200, 200))

local function HookModule(modulePath)
    pcall(function()
        local mod = require(modulePath)
        if type(mod) == "table" then
            L("✅ Módulo hookeado: " .. modulePath.Name, Color3.fromRGB(100, 255, 100))
            for funcName, funcVal in pairs(mod) do
                if type(funcVal) == "function" then
                    local original = funcVal
                    mod[funcName] = function(...)
                        local args = {...}
                        -- Ocultar el argumento 'self' si es una tabla extensa
                        local logArgs = {}
                        for i=1, #args do
                            if type(args[i]) == "table" and args[i] == mod then logArgs[i] = "self" else logArgs[i] = args[i] end
                        end
                        task.spawn(function()
                            L("🔥 " .. modulePath.Name .. "." .. funcName .. "() => " .. Dump(logArgs), Color3.fromRGB(255, 180, 50))
                        end)
                        return original(...)
                    end
                end
            end
        end
    end)
end

-- Intentar adquirir todos los módulos relevantes
local controllers = ReplicatedStorage:WaitForChild("Controllers", 3)
if controllers then
    local forgeController = controllers:FindFirstChild("ForgeController")
    if forgeController then
        HookModule(forgeController)
        for _, child in pairs(forgeController:GetChildren()) do
            if child:IsA("ModuleScript") then
                HookModule(child)
            end
        end
    end
end

L("\n✅ TODO LISTO CON MODULE HOOKING.\nVe a forjar el arma de manera normal.", Color3.fromRGB(0, 255, 100))
L("Guardando datos en forge_modules.txt automágicamente.", Color3.fromRGB(200, 200, 200))
