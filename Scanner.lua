-- ============ HOOK SEGURO (OPTIMIZADO) ============

local OriginalNamecall
OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    -- Evitar interferir con nuestro propio código
    if checkcaller() then
        return OriginalNamecall(self, ...)
    end

    -- Solo interceptar tráfico de red relevante
    if method ~= "FireServer" and method ~= "InvokeServer" then
        return OriginalNamecall(self, ...)
    end

    -- Obtener nombre completo
    local fullName = ""
    pcall(function()
        fullName = self:GetFullName()
    end)

    local nameLower = string.lower(fullName)

    -- ✅ FILTRO FUERTE (ANTI-ROMPER NPCs)
    local allowedKeywords = {
        "forge",
        "minigame",
        "melt",
        "hammer",
        "pour"
    }

    local isRelevant = false
    for _, kw in ipairs(allowedKeywords) do
        if string.find(nameLower, kw) then
            isRelevant = true
            break
        end
    end

    -- ❌ Si NO es relevante → NO tocar
    if not isRelevant then
        return OriginalNamecall(self, ...)
    end

    -- ============ EJECUCIÓN SEGURA ============

    -- 🔹 FireServer (no bloquea)
    if method == "FireServer" then
        task.spawn(function()
            local argPreview = ""
            for i, v in ipairs(args) do
                local val = typeof(v) == "table" and "{table}" or tostring(v)
                argPreview = argPreview .. "Arg" .. i .. "=" .. val .. " "
            end

            AddLog("NET_OUT", method .. " → " .. self.Name .. " | " .. argPreview,
                Color3.fromRGB(255, 120, 120))
        end)

        return OriginalNamecall(self, ...)
    end

    -- 🔹 InvokeServer (⚠️ MUY DELICADO)
    if method == "InvokeServer" then
        local results = {OriginalNamecall(self, ...)} -- ejecutar primero

        task.spawn(function()
            local argPreview = ""
            for i, v in ipairs(args) do
                local val = typeof(v) == "table" and "{table}" or tostring(v)
                argPreview = argPreview .. "Arg" .. i .. "=" .. val .. " "
            end

            local retPreview = ""
            for i, v in ipairs(results) do
                local val = typeof(v) == "table" and "{table}" or tostring(v)
                retPreview = retPreview .. "Ret" .. i .. "=" .. val .. " "
            end

            AddLog("NET_CALL",
                self.Name .. " | " .. argPreview .. " → " .. retPreview,
                Color3.fromRGB(120, 255, 120))
        end)

        return unpack(results)
    end

    return OriginalNamecall(self, ...)
end)
