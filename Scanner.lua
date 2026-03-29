-- ==============================================================================
-- 🔬 SNAPSHOT FINAL DE FORJA V3.0 — Cero Namecall, 100% Preciso
-- ==============================================================================
-- Engancha directamente los InvokeServer individuales sin tocar ProximityPrompts.
-- NO interfiere con NPCs.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local parentUI = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in ipairs(parentUI:GetChildren()) do if v.Name == "ForgeSnapUI" then v:Destroy() end end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ForgeSnapUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentUI

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 320)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 5, 15)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 100)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -75, 0, 28)
Title.BackgroundColor3 = Color3.fromRGB(0, 50, 20)
Title.Text = " 🔬 SNAPSHOT FINAL FORJA (HOOK DIRECTO)"
Title.TextColor3 = Color3.fromRGB(0, 255, 100)
Title.TextSize = 11
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0, 75, 0, 28)
SaveBtn.Position = UDim2.new(1, -75, 0, 0)
SaveBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
SaveBtn.Text = "💾 GUARDAR"
SaveBtn.TextColor3 = Color3.new(1,1,1)
SaveBtn.Font = Enum.Font.Code
SaveBtn.Parent = MainFrame

local OutputScroll = Instance.new("ScrollingFrame")
OutputScroll.Size = UDim2.new(1, -8, 1, -34)
OutputScroll.Position = UDim2.new(0, 4, 0, 30)
OutputScroll.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
OutputScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
OutputScroll.ScrollBarThickness = 5
OutputScroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Parent = OutputScroll
UIList.Padding = UDim.new(0, 2)
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    OutputScroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 10)
end)

local FullLog = "=== SNAPSHOT FINAL DE FORJA V3.0 ===\nInicio: " .. os.date() .. "\n\n"
local msgCount = 0

SaveBtn.MouseButton1Click:Connect(function()
    pcall(function() writefile("forge_final.txt", FullLog) end)
    SaveBtn.Text = "✅ LISTO"
    task.delay(1, function() SaveBtn.Text = "💾 GUARDAR" end)
end)

local startTime = workspace:GetServerTimeNow()

local function Dump(v)
    if typeof(v) == "Instance" then return "["..v.ClassName.."] "..v.Name end
    if v == nil then return "nil" end
    if type(v) == "table" then
        local s = "{"
        for k, val in pairs(v) do
            if type(val) == "table" then
                s = s .. tostring(k) .. "={...}, "
            else
                s = s .. tostring(k) .. "=" .. tostring(val) .. ", "
            end
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
    
    if msgCount % 5 == 0 then
        pcall(function() writefile("forge_final.txt", FullLog) end)
    end
    
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
-- HOOK FUNCTION DIRECTO a los 5 Remotes Clave
-- ==========================================
L("Buscando remotes descubiertos...", Color3.fromRGB(200, 200, 200))

local remotes = {}
for _, v in pairs(ReplicatedStorage:GetDescendants()) do
    local name = v.Name
    if v:IsA("RemoteFunction") then
        if name == "ChangeSequence" or name == "StartForge" or name == "EndForge" or 
           (name == "RemoteFunction" and v.Parent and v.Parent.Name == "HammerMinigame") or
           name == "Forge" then
            table.insert(remotes, v)
        end
    end
end

L("Encontrados " .. #remotes .. " remotes de forja. Aplicando hooks...", Color3.fromRGB(100, 255, 100))

if not hookfunction then
    L("❌ hookfunction no disponible. El sniffer no funcionará.", Color3.fromRGB(255, 50, 50))
else
    local hooks = {}
    
    for _, remote in pairs(remotes) do
        local originalFunc
        originalFunc = hookfunction(remote.InvokeServer, function(self, ...)
            local args = {...}
            
            -- Reportar argumentos al instante fuera del hilo principal para no congelar
            task.spawn(function()
                local argStr = ""
                for i = 1, #args do argStr = argStr .. Dump(args[i]) .. " " end
                L("📤 ENVIADO: " .. self.Name .. " => " .. argStr, Color3.fromRGB(255, 150, 50))
            end)
            
            -- Ejecutar original y capturar resultado
            local results = {originalFunc(self, ...)}
            
            task.spawn(function()
                local refStr = ""
                for i = 1, #results do refStr = refStr .. Dump(results[i]) .. " " end
                L("📥 RESPUESTA de " .. self.Name .. " => " .. refStr, Color3.fromRGB(50, 200, 255))
            end)
            
            return unpack(results)
        end)
        L(" ✅ Hooked: " .. remote.Name .. " (" .. remote.Parent.Name .. ")", Color3.fromRGB(150, 255, 150))
    end
end

L("\n✅ TODO LISTO.\nVe a la forja, interactúa, y completa la espada normalmente.", Color3.fromRGB(0, 255, 100))
L("NO interferirá con la proximidad. Guardando en forge_final.txt", Color3.fromRGB(200, 200, 200))
