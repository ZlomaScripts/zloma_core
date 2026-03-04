-- ZLOMA CORE - Client Inventory Wrapper
-- Unified interface for client-side inventory checks
-- Supports: ox_inventory, qb-inventory, qs-inventory, ps-inventory, lj-inventory,
-- codem-inventory, tgiann-inventory, origen-inventory, core_inventory, ak47_inventory,
-- jaksam_inventory, jpr-inventory, S-Inventory

local InventoryType = nil

-- ============================================================================
-- QBCore Object Caching (OPTIMIZATION)
-- ============================================================================
-- Cache QBCore object at initialization instead of every function call
local QBCore = nil
local ESX = nil

-- Initialize inventory detection and cache framework objects
CreateThread(function()
    Wait(ZlomaCore.Config.Timeouts.InitWait or 1000) -- Wait for frameworks to load
    
    -- Use ZlomaCore.Cache if available, otherwise detect locally
    InventoryType = ZlomaCore.Cache.Inventory
    
    if not InventoryType then
        -- Fallback local detection
        if GetResourceState('ox_inventory') == 'started' then
            InventoryType = 'ox_inventory'
        elseif GetResourceState('tgiann-inventory') == 'started' then
            InventoryType = 'tgiann-inventory'
        elseif GetResourceState('origen_inventory') == 'started' or GetResourceState('origen-inventory') == 'started' then
            InventoryType = 'origen-inventory'
        elseif GetResourceState('core_inventory') == 'started' then
            InventoryType = 'core_inventory'
        elseif GetResourceState('ak47_inventory') == 'started' then
            InventoryType = 'ak47_inventory'
        elseif GetResourceState('jaksam_inventory') == 'started' then
            InventoryType = 'jaksam_inventory'
        elseif GetResourceState('jpr-inventory') == 'started' then
            InventoryType = 'jpr-inventory'
        elseif GetResourceState('S-Inventory') == 'started' then
            InventoryType = 'S-Inventory'
        elseif GetResourceState('qb-inventory') == 'started' or GetResourceState('ps-inventory') == 'started' or GetResourceState('lj-inventory') == 'started' then
            InventoryType = 'qb-inventory'
        elseif GetResourceState('qs-inventory') == 'started' then
            InventoryType = 'qs-inventory'
        elseif GetResourceState('codem-inventory') == 'started' then
            InventoryType = 'codem-inventory'
        end
    end
    
    -- Cache QBCore object ONCE at initialization (OPTIMIZATION)
    if GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
    end
    
    -- Cache ESX object for S-Inventory
    if InventoryType == 'S-Inventory' and GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
    end

    if InventoryType then
        ZlomaCore.Debug(string.format("Client Inventory loaded: %s", InventoryType))
    end
end)

-- ============================================================================
-- ADD NEW INVENTORY SUPPORT HERE (Client Side)
-- ============================================================================
-- To add client-side support for a new inventory:
-- 1. Add detection in the CreateThread above
-- 2. Add elseif block in GetInventory() below
-- ============================================================================

-- EXPORT: GetInventory() - Get player's full inventory (Client Side)
-- Returns: Table of items (normalized as best as possible)
exports('GetInventory', function()
    local items = {}

    if InventoryType == 'ox_inventory' then
        -- ox_inventory client export
        if exports.ox_inventory.GetPlayerItems then
            items = exports.ox_inventory:GetPlayerItems()
        end
    
    -- NEW: tgiann-inventory support
    elseif InventoryType == 'tgiann-inventory' then
        if exports['tgiann-inventory'].GetPlayerItems then
            items = exports['tgiann-inventory']:GetPlayerItems()
        end
    
    -- NEW: origen-inventory support
    elseif InventoryType == 'origen-inventory' then
        if exports['origen_inventory'].GetPlayerItems then
            items = exports['origen_inventory']:GetPlayerItems()
        end
        
    elseif InventoryType == 'qb-inventory' then
        -- QBCore / PS / LJ - Get data from cached QBCore object
        -- OPTIMIZED: Uses cached QBCore instead of fetching every call
        if QBCore and QBCore.Functions and QBCore.Functions.GetPlayerData then
            local playerData = QBCore.Functions.GetPlayerData()
            if playerData and playerData.items then
                items = playerData.items
            end
        end
    elseif InventoryType == 'qs-inventory' then
        -- QS Inventory - Client Export
        if exports['qs-inventory'].GetInventory then
            items = exports['qs-inventory']:GetInventory()
        end
    elseif InventoryType == 'codem-inventory' then
        -- Codem might not have client export easily accessible
        if exports['codem-inventory'].GetInventory then
            items = exports['codem-inventory']:GetInventory()
        end
    
    elseif InventoryType == 'core_inventory' then
        -- core_inventory does not have a full inventory client export
        -- Cannot retrieve full inventory client-side
        ZlomaCore.Debug("core_inventory: Full inventory not available client-side")
    
    elseif InventoryType == 'ak47_inventory' then
        -- ak47_inventory does not have a full inventory client export
        ZlomaCore.Debug("ak47_inventory: Full inventory not available client-side")
    
    elseif InventoryType == 'jaksam_inventory' then
        -- jaksam_inventory does not have a full inventory client export
        ZlomaCore.Debug("jaksam_inventory: Full inventory not available client-side")
    
    elseif InventoryType == 'jpr-inventory' then
        -- jpr-inventory uses QBCore PlayerData
        if QBCore and QBCore.Functions and QBCore.Functions.GetPlayerData then
            local playerData = QBCore.Functions.GetPlayerData()
            if playerData and playerData.items then
                items = playerData.items
            end
        end
    
    elseif InventoryType == 'S-Inventory' then
        -- S-Inventory uses ESX player data
        if ESX then
            local playerData = ESX.GetPlayerData()
            if playerData and playerData.inventory then
                items = playerData.inventory
            end
        end
    end

    -- Normalize Metadata (info -> metadata) for generic scripts
    if items then
        -- items might be an array (ox) or dictionary (qb - slots)
        for _, item in pairs(items) do
            if item.info and not item.metadata then
                item.metadata = item.info
            end
        end
    end

    return items
end)

-- EXPORT: HasItem(item, count, metadata) - Client side check
-- Useful for fast checks in loops/UI
exports('HasItem', function(item, count, metadata)
    local items = exports['zloma_core']:GetInventory()
    count = count or 1

    local foundCount = 0

    for _, invItem in pairs(items) do
        if invItem.name == item then
            -- Optional metadata check
            local metaMatch = true
            if metadata then
                if not invItem.metadata then
                    metaMatch = false
                else
                    for k, v in pairs(metadata) do
                        if invItem.metadata[k] ~= v then
                            metaMatch = false
                            break
                        end
                    end
                end
            end

            if metaMatch then
                foundCount = foundCount + (invItem.count or invItem.amount or 1)
            end
        end
    end

    return foundCount >= count
end)
