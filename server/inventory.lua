-- ZLOMA CORE - Server Inventory Wrapper
-- Unified interface for ox_inventory, qb-inventory, qs-inventory, ps-inventory, codem-inventory,
-- tgiann-inventory, origen-inventory, core_inventory, ak47_inventory, jaksam_inventory, jpr-inventory, S-Inventory
-- Customer-friendly: Version-agnostic, graceful fallbacks, detailed error logging

local InventoryType = nil

-- Initialize inventory detection
CreateThread(function()
    Wait(ZlomaCore.Config.Timeouts.InitWait or 500) -- Wait for config initialization
    InventoryType = ZlomaCore.Cache.Inventory

    if InventoryType then
        ZlomaCore.Debug(string.format("Inventory system loaded: %s", InventoryType))
    else
        print("^3[ZLOMA WARNING]^0 No inventory system detected. Inventory functions will not work.")
    end
end)

-- ============================================================================
-- ADD NEW INVENTORY SUPPORT HERE
-- ============================================================================
-- To add support for a new inventory system:
-- 1. Add detection in shared/config.lua -> ZlomaCore.DetectInventory()
-- 2. Add the inventory name to ZlomaCore.Config.Manual.Inventory options
-- 3. Add elseif blocks in HasItem, GetItemCount, AddItem, RemoveItem, GetInventory below
--
-- Template:
-- elseif InventoryType == 'your-inventory' then
--     return exports['your-inventory']:YourExportFunction(source, item)
-- ============================================================================

-- EXPORT: HasItem(source, item, count) - Check if player has item with minimum count
-- Returns: true/false
exports('HasItem', function(source, item, count)
    if not InventoryType then
        ZlomaCore.Warn("Inventory", "HasItem")
        return false
    end

    count = count or 1

    if InventoryType == 'ox_inventory' then
        local itemCount = exports.ox_inventory:GetItemCount(source, item)
        return itemCount >= count
    elseif InventoryType == 'qb-inventory' then
        -- OPTIMIZED: Use HasItem export if available (recommended by docs)
        if exports['qb-inventory'] and exports['qb-inventory'].HasItem then
            return exports['qb-inventory']:HasItem(source, item, count)
        end
        -- Fallback to Player.Functions
        local Player = exports['zloma_core']:GetPlayer(source)
        if not Player then return false end
        local itemData = Player.Functions.GetItemByName(item)
        if itemData then
            return itemData.amount >= count
        end
        return false
    
    -- NEW: tgiann-inventory support
    elseif InventoryType == 'tgiann-inventory' then
        local itemCount = exports['tgiann-inventory']:GetItemCount(source, item)
        return itemCount >= count
    
    -- NEW: origen-inventory support
    elseif InventoryType == 'origen-inventory' then
        local itemCount = exports['origen_inventory']:GetItemCount(source, item)
        return itemCount >= count
        
    elseif InventoryType == 'qs-inventory' then
        local itemCount = exports['qs-inventory']:GetItemTotalAmount(source, item)
        return itemCount >= count
    elseif InventoryType == 'ps-inventory' then
        local Player = exports['zloma_core']:GetPlayer(source)
        if not Player then return false end

        local itemData = Player.Functions.GetItemByName(item)
        if itemData then
            return itemData.amount >= count
        end
        return false
    elseif InventoryType == 'codem-inventory' then
        local itemData = exports['codem-inventory']:GetItemByName(source, item)
        if itemData then
            return itemData.amount >= count
        end
        return false
    
    elseif InventoryType == 'core_inventory' then
        local itemCount = exports.core_inventory:getItemCount(source, item)
        return (itemCount or 0) >= count
    
    elseif InventoryType == 'ak47_inventory' then
        local itemCount = exports['ak47_inventory']:getItemCount(source, 'count', item)
        return (itemCount or 0) >= count
    
    elseif InventoryType == 'jaksam_inventory' then
        local itemCount = exports['jaksam_inventory']:getTotalItemAmount(source, item)
        return (itemCount or 0) >= count
    
    elseif InventoryType == 'jpr-inventory' then
        local itemCount = exports['jpr-inventory']:GetItemCount(source, item)
        return (itemCount or 0) >= count
    
    elseif InventoryType == 'S-Inventory' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            local itemData = xPlayer.getInventoryItem(item)
            return itemData and (itemData.count or 0) >= count
        end
        return false
    end

    return false
end)

-- EXPORT: GetItemCount(source, item) - Get exact item quantity
-- Returns: Number (0 if not found)
exports('GetItemCount', function(source, item)
    if not InventoryType then
        ZlomaCore.Warn("Inventory", "GetItemCount")
        return 0
    end

    if InventoryType == 'ox_inventory' then
        return exports.ox_inventory:GetItemCount(source, item)
    elseif InventoryType == 'qb-inventory' then
        local Player = exports['zloma_core']:GetPlayer(source)
        if not Player then return 0 end

        local itemData = Player.Functions.GetItemByName(item)
        return itemData and itemData.amount or 0
    
    -- NEW: tgiann-inventory support
    elseif InventoryType == 'tgiann-inventory' then
        return exports['tgiann-inventory']:GetItemCount(source, item) or 0
    
    -- NEW: origen-inventory support
    elseif InventoryType == 'origen-inventory' then
        return exports['origen_inventory']:GetItemCount(source, item) or 0
        
    elseif InventoryType == 'qs-inventory' then
        return exports['qs-inventory']:GetItemTotalAmount(source, item)
    elseif InventoryType == 'ps-inventory' then
        local Player = exports['zloma_core']:GetPlayer(source)
        if not Player then return 0 end

        local itemData = Player.Functions.GetItemByName(item)
        return itemData and itemData.amount or 0
    elseif InventoryType == 'codem-inventory' then
        local itemData = exports['codem-inventory']:GetItemByName(source, item)
        return itemData and itemData.amount or 0
    
    elseif InventoryType == 'core_inventory' then
        return exports.core_inventory:getItemCount(source, item) or 0
    
    elseif InventoryType == 'ak47_inventory' then
        return exports['ak47_inventory']:getItemCount(source, 'count', item) or 0
    
    elseif InventoryType == 'jaksam_inventory' then
        return exports['jaksam_inventory']:getTotalItemAmount(source, item) or 0
    
    elseif InventoryType == 'jpr-inventory' then
        return exports['jpr-inventory']:GetItemCount(source, item) or 0
    
    elseif InventoryType == 'S-Inventory' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            local itemData = xPlayer.getInventoryItem(item)
            return itemData and itemData.count or 0
        end
        return 0
    end

    return 0
end)

-- EXPORT: AddItem(source, item, count, metadata) - Add item to player inventory
-- Returns: true if successful, false otherwise
exports('AddItem', function(source, item, count, metadata)
    if not InventoryType then
        ZlomaCore.Warn("Inventory", "AddItem")
        return false
    end

    count = count or 1
    metadata = metadata or {}

    local success = false

    if InventoryType == 'ox_inventory' then
        success = exports.ox_inventory:AddItem(source, item, count, metadata)
    elseif InventoryType == 'qb-inventory' then
        local Player = exports['zloma_core']:GetPlayer(source)
        if not Player then return false end
        success = Player.Functions.AddItem(item, count, false, metadata)
    
    -- NEW: tgiann-inventory support
    elseif InventoryType == 'tgiann-inventory' then
        success = exports['tgiann-inventory']:AddItem(source, item, count, nil, metadata)
    
    -- NEW: origen-inventory support
    elseif InventoryType == 'origen-inventory' then
        success = exports['origen_inventory']:AddItem(source, item, count, metadata)
        
    elseif InventoryType == 'qs-inventory' then
        -- FIXED: Correct parameter order for qs-inventory: AddItem(source, item, count, slot, metadata)
        success = exports['qs-inventory']:AddItem(source, item, count, nil, metadata)
    elseif InventoryType == 'ps-inventory' then
        local Player = exports['zloma_core']:GetPlayer(source)
        if not Player then return false end
        success = Player.Functions.AddItem(item, count, false, metadata)
    elseif InventoryType == 'codem-inventory' then
        success = exports['codem-inventory']:AddItem(source, item, count, metadata)
    
    elseif InventoryType == 'core_inventory' then
        exports['core_inventory']:addItem(source, item, count, metadata)
        success = true
    
    elseif InventoryType == 'ak47_inventory' then
        exports['ak47_inventory']:AddItem(source, item, count, nil, metadata)
        success = true
    
    elseif InventoryType == 'jaksam_inventory' then
        exports['jaksam_inventory']:addItem(source, item, count, metadata)
        success = true
    
    elseif InventoryType == 'jpr-inventory' then
        exports['jpr-inventory']:AddItem(source, item, count, nil, metadata)
        success = true
    
    elseif InventoryType == 'S-Inventory' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.addInventoryItem(item, count)
            success = true
        end
    end

    if success then
        ZlomaCore.Debug(string.format("Added %sx %s to player %s", count, item, source))
    else
        ZlomaCore.Debug(string.format("Failed to add %sx %s to player %s", count, item, source))
    end

    return success
end)

-- EXPORT: RemoveItem(source, item, count, metadata, slot) - Remove item from player inventory
-- Returns: true if successful, false otherwise
exports('RemoveItem', function(source, item, count, metadata, slot)
    if not InventoryType then
        ZlomaCore.Warn("Inventory", "RemoveItem")
        return false
    end

    count = count or 1
    local success = false

    if InventoryType == 'ox_inventory' then
        success = exports.ox_inventory:RemoveItem(source, item, count, metadata, slot)
    elseif InventoryType == 'qb-inventory' then
        local Player = exports['zloma_core']:GetPlayer(source)
        if not Player then return false end
        -- QBCore RemoveItem(item, amount, slot)
        success = Player.Functions.RemoveItem(item, count, slot)
    
    -- NEW: tgiann-inventory support
    elseif InventoryType == 'tgiann-inventory' then
        success = exports['tgiann-inventory']:RemoveItem(source, item, count, slot, metadata)
    
    -- NEW: origen-inventory support
    elseif InventoryType == 'origen-inventory' then
        success = exports['origen_inventory']:RemoveItem(source, item, count)
        
    elseif InventoryType == 'qs-inventory' then
        -- qs-inventory RemoveItem(source, item, count, slot, metadata) - best guess standardization
        if exports['qs-inventory'].RemoveItem then
            -- Try standard signature if available, otherwise fallback to simple
            pcall(function()
                success = exports['qs-inventory']:RemoveItem(source, item, count, slot, metadata)
            end)
            if not success then
                success = exports['qs-inventory']:RemoveItem(source, item, count)
            end
        else
            success = false
        end
    elseif InventoryType == 'ps-inventory' then
        local Player = exports['zloma_core']:GetPlayer(source)
        if not Player then return false end
        success = Player.Functions.RemoveItem(item, count, slot)
    elseif InventoryType == 'codem-inventory' then
        success = exports['codem-inventory']:RemoveItem(source, item, count)
    
    elseif InventoryType == 'core_inventory' then
        exports['core_inventory']:removeItem(source, item, count)
        success = true
    
    elseif InventoryType == 'ak47_inventory' then
        exports['ak47_inventory']:RemoveItem(source, item, count)
        success = true
    
    elseif InventoryType == 'jaksam_inventory' then
        exports['jaksam_inventory']:removeItem(source, item, count)
        success = true
    
    elseif InventoryType == 'jpr-inventory' then
        exports['jpr-inventory']:RemoveItem(source, item, count)
        success = true
    
    elseif InventoryType == 'S-Inventory' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.removeInventoryItem(item, count)
            success = true
        end
    end

    if success then
        ZlomaCore.Debug(string.format("Removed %sx %s from player %s", count, item, source))
    else
        ZlomaCore.Debug(string.format("Failed to remove %sx %s from player %s (insufficient qty?)", count, item, source))
    end

    return success
end)

-- EXPORT: GetInventory(source) - Get player's full inventory
-- Returns: Table of items (normalized structure where possible)
exports('GetInventory', function(source)
    if not InventoryType then
        ZlomaCore.Warn("Inventory", "GetInventory")
        return {}
    end

    local items = {}

    if InventoryType == 'ox_inventory' then
        return exports.ox_inventory:GetInventoryItems(source) or {}
    elseif InventoryType == 'qb-inventory' then
        local Player = exports['zloma_core']:GetPlayer(source)
        items = Player and Player.PlayerData.items or {}
    
    -- NEW: tgiann-inventory support
    elseif InventoryType == 'tgiann-inventory' then
        items = exports['tgiann-inventory']:GetInventory(source) or {}
    
    -- NEW: origen-inventory support
    elseif InventoryType == 'origen-inventory' then
        items = exports['origen_inventory']:GetInventory(source) or {}
        
    elseif InventoryType == 'qs-inventory' then
        items = exports['qs-inventory']:GetInventory(source) or {}
    elseif InventoryType == 'ps-inventory' then
        local Player = exports['zloma_core']:GetPlayer(source)
        items = Player and Player.PlayerData.items or {}
    elseif InventoryType == 'codem-inventory' then
        items = exports['codem-inventory']:GetInventory(source) or {}
    
    elseif InventoryType == 'core_inventory' then
        items = exports['core_inventory']:getItems(source) or {}
    
    elseif InventoryType == 'ak47_inventory' then
        items = exports['ak47_inventory']:GetInventoryItems(source) or {}
    
    elseif InventoryType == 'jaksam_inventory' then
        local inv = exports['jaksam_inventory']:getInventory(source)
        items = inv and inv.items or {}
    
    elseif InventoryType == 'jpr-inventory' then
        items = exports['jpr-inventory']:GetInventory(source) or {}
    
    elseif InventoryType == 'S-Inventory' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            items = xPlayer.getInventory() or {}
        end
    end

    -- Normalize 'info' to 'metadata' if missing (for QBCore/QS/PS)
    -- This ensures scripts like zloma_keys can read metadata uniformly
    if items then
        for _, item in pairs(items) do
            if item.info and not item.metadata then
                item.metadata = item.info
            end
        end
    end

    return items
end)


-- EXPORT: GetItemMetadata(source, item) - Get item metadata/info
-- Returns: Metadata table or nil
exports('GetItemMetadata', function(source, item)
    if not InventoryType then
        ZlomaCore.Warn("Inventory", "GetItemMetadata")
        return nil
    end

    if InventoryType == 'ox_inventory' then
        -- ox_inventory:GetInventoryItems returns table of items
        local items = exports.ox_inventory:GetInventoryItems(source)
        if items then
            for _, invItem in pairs(items) do
                if invItem.name == item then
                    return invItem.metadata
                end
            end
        end
    elseif InventoryType == 'qb-inventory' or InventoryType == 'ps-inventory' then
        local Player = exports['zloma_core']:GetPlayer(source)
        if not Player then return nil end

        local itemData = Player.Functions.GetItemByName(item)
        return itemData and itemData.info or nil
    elseif InventoryType == 'qs-inventory' then
        local itemData = exports['qs-inventory']:GetItemByName(source, item)
        return itemData and itemData.info or nil
    elseif InventoryType == 'codem-inventory' then
        local itemData = exports['codem-inventory']:GetItemByName(source, item)
        return itemData and itemData.info or nil
    end

    return nil
end)


-- ============================================================================
-- System Detection Export
-- ============================================================================

--- Get detected inventory system name
--- @return string|nil - Detected inventory system name or nil
exports('GetInventorySystem', function()
    return InventoryType
end)
