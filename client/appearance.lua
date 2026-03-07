-- ZLOMA CORE - Client Appearance Wrapper
-- Unified interface for supported clothing and appearance resources.

local AppearanceType = nil

CreateThread(function()
    Wait(ZlomaCore.Config.Timeouts.DetectionWait or 200)
    AppearanceType = ZlomaCore.Cache.Appearance

    if AppearanceType then
        ZlomaCore.Debug(string.format("Appearance system loaded: %s", AppearanceType))
    else
        ZlomaCore.Debug('[zloma_core] No appearance system detected')
    end
end)

local function DecodeIfNeeded(data)
    if type(data) == 'string' then
        local success, decoded = pcall(json.decode, data)
        if success then
            return decoded
        end
    end

    return data
end

local function GetSkinchangerSkin(timeoutMs)
    local currentSkin = nil
    local startedAt = GetGameTimer()

    TriggerEvent('skinchanger:getSkin', function(skinData)
        currentSkin = skinData
    end)

    while currentSkin == nil and (GetGameTimer() - startedAt) < (timeoutMs or 2000) do
        Wait(1)
    end

    return currentSkin
end

local function OpenIlleniumWardrobe(title)
    lib.callback('illenium-appearance:server:getOutfits', false, function(outfits)
        if not outfits or #outfits == 0 then
            exports['zloma_core']:Notify('No saved outfits found', 'error')
            return
        end

        local menuOptions = {}
        for index = 1, #outfits do
            local outfit = outfits[index]
            menuOptions[#menuOptions + 1] = {
                title = outfit.name,
                description = outfit.model,
                onSelect = function()
                    TriggerEvent('illenium-appearance:client:changeOutfit', {
                        name = outfit.name,
                        model = outfit.model,
                        components = outfit.components,
                        props = outfit.props,
                        disableSave = false
                    })
                end
            }
        end

        lib.registerContext({
            id = 'zloma_core_wardrobe',
            title = title or 'Wardrobe',
            options = menuOptions
        })

        lib.showContext('zloma_core_wardrobe')
    end)

    return true
end

local function TryAppearanceAction(actions)
    for _, action in ipairs(actions) do
        local success, result = pcall(action)
        if success and result ~= false then
            return true
        end
    end

    return false
end

exports('GetAppearanceSystem', function()
    return AppearanceType
end)

exports('GetCurrentSkin', function()
    if not AppearanceType then
        ZlomaCore.Warn('Appearance', 'GetCurrentSkin')
        return nil
    end

    local ped = PlayerPedId()

    if AppearanceType == 'illenium-appearance' then
        return exports['illenium-appearance']:getPedAppearance(ped)
    elseif AppearanceType == 'qs-appearance' then
        return exports['qs-appearance']:getPedAppearance(ped)
    elseif AppearanceType == 'crm-appearance' then
        return exports['crm-appearance']:crm_get_ped_appearance(ped)
    elseif AppearanceType == 'rcore_clothing' then
        return exports['rcore_clothing']:getPlayerSkin(false)
    elseif AppearanceType == 'qb-clothing' or AppearanceType == 'esx_skin' or AppearanceType == 'p_appearance' then
        return GetSkinchangerSkin()
    end

    return nil
end)

exports('SetPlayerSkin', function(skinData)
    if not AppearanceType then
        ZlomaCore.Warn('Appearance', 'SetPlayerSkin')
        return false
    end

    local data = DecodeIfNeeded(skinData)
    if not data then
        return false
    end

    if AppearanceType == 'illenium-appearance' then
        exports['illenium-appearance']:setPlayerAppearance(data)
        return true
    elseif AppearanceType == 'qs-appearance' then
        exports['qs-appearance']:setPlayerAppearance(data)
        return true
    elseif AppearanceType == 'crm-appearance' then
        exports['crm-appearance']:crm_set_ped_appearance(PlayerPedId(), data)
        return true
    elseif AppearanceType == 'rcore_clothing' then
        exports['rcore_clothing']:setPlayerSkin(data)
        return true
    elseif AppearanceType == 'qb-clothing' then
        TriggerEvent('qb-clothing:client:loadPlayerClothing', data, nil)
        return true
    elseif AppearanceType == 'esx_skin' or AppearanceType == 'p_appearance' then
        TriggerEvent('skinchanger:loadSkin', data)
        return true
    elseif AppearanceType == 'tgiann-clothing' then
        TriggerEvent('tgiann-clothing:changeScriptClothe', data)
        return true
    end

    return false
end)

exports('SetPlayerClothing', function(clothingData)
    if not AppearanceType then
        ZlomaCore.Warn('Appearance', 'SetPlayerClothing')
        return false
    end

    local data = DecodeIfNeeded(clothingData)
    if not data then
        return false
    end

    if AppearanceType == 'illenium-appearance' then
        exports['illenium-appearance']:setPedComponents(PlayerPedId(), data.components or {})
        exports['illenium-appearance']:setPedProps(PlayerPedId(), data.props or {})
        return true
    elseif AppearanceType == 'qs-appearance' then
        exports['qs-appearance']:setPedComponents(PlayerPedId(), data.components or {})
        exports['qs-appearance']:setPedProps(PlayerPedId(), data.props or {})
        return true
    elseif AppearanceType == 'crm-appearance' then
        exports['crm-appearance']:crm_set_ped_clothing(PlayerPedId(), data.crm_clothing or {})
        exports['crm-appearance']:crm_set_ped_accessories(PlayerPedId(), data.crm_accessories or {})
        return true
    elseif AppearanceType == 'rcore_clothing' then
        exports['rcore_clothing']:setPlayerSkin(data)
        return true
    elseif AppearanceType == 'qb-clothing' then
        TriggerEvent('qb-clothing:client:loadOutfit', { outfitData = data })
        return true
    elseif AppearanceType == 'esx_skin' or AppearanceType == 'p_appearance' then
        local currentSkin = GetSkinchangerSkin()
        if not currentSkin then
            return false
        end

        TriggerEvent('skinchanger:loadClothes', currentSkin, data)
        return true
    elseif AppearanceType == 'tgiann-clothing' then
        TriggerEvent('tgiann-clothing:changeScriptClothe', data)
        return true
    end

    return false
end)

exports('OpenWardrobe', function(options)
    options = options or {}

    if not AppearanceType then
        exports['zloma_core']:Notify('No supported appearance system detected', 'error')
        return false
    end

    if AppearanceType == 'illenium-appearance' then
        return OpenIlleniumWardrobe(options.title)
    elseif AppearanceType == 'qb-clothing' then
        TriggerEvent('qb-clothing:client:openOutfitMenu')
        return true
    elseif AppearanceType == 'esx_skin' or AppearanceType == 'p_appearance' then
        TriggerEvent('esx_skin:openSaveableMenu')
        return true
    elseif AppearanceType == 'qs-appearance' then
        return TryAppearanceAction({
            function() return exports['qs-appearance']:OpenWardrobe() end,
            function() return exports['qs-appearance']:openOutfitMenu() end,
            function() TriggerEvent('qs-clothing:client:openOutfitMenu') return true end,
            function() TriggerEvent('qs-appearance:client:openOutfitMenu') return true end
        })
    elseif AppearanceType == 'crm-appearance' then
        return TryAppearanceAction({
            function() return exports['crm-appearance']:crm_open_outfit_menu() end,
            function() TriggerEvent('crm-appearance:client:openOutfitMenu') return true end
        })
    elseif AppearanceType == 'rcore_clothing' then
        return TryAppearanceAction({
            function() return exports['rcore_clothing']:openWardrobe() end,
            function() TriggerEvent('rcore_clothing:openOutfits') return true end,
            function() TriggerEvent('rcore_clothing:openWardrobe') return true end
        })
    elseif AppearanceType == 'tgiann-clothing' then
        return TryAppearanceAction({
            function() TriggerEvent('tgiann-clothing:openMenu') return true end,
            function() TriggerEvent('tgiann-clothing:openOutfitMenu') return true end
        })
    end

    exports['zloma_core']:Notify('Wardrobe opening is not available for the detected appearance system', 'error')
    return false
end)