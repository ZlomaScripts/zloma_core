--[[
    zloma_core - Server Fuel System Wrapper
    
    Server-side fuel functions for systems that use Entity State Bags (lc_fuel, ox_fuel, etc.)
    State bags are server-authoritative, so setting fuel server-side ensures proper sync.
    
    NOTE: For most fuel systems, CLIENT-SIDE SetFuel is the primary method (immediate).
    Server-side is used as a backup/sync mechanism only.
    
    Supported:
    lc_fuel, qb-fuel, ox_fuel, LegacyFuel, lj-fuel, ps-fuel, cdn-fuel, Renewed-Fuel, okokGasStation,
    qs-fuelstations, rcore_fuel, x-fuel, stg-fuel, ti_fuel, esx-sna-fuel, ND_Fuel, myFuel
]]

-- ============================================================================
-- Fuel System Detection (Uses ZlomaCore.Cache)
-- ============================================================================

local activeFuelSystem = nil

-- Initialize fuel system from cache
CreateThread(function()
    Wait(ZlomaCore.Config.Timeouts.DetectionWait or 200)
    activeFuelSystem = ZlomaCore.Cache.Fuel
    
    if activeFuelSystem then
        ZlomaCore.Debug(string.format("[SERVER] Fuel system loaded: %s", activeFuelSystem))
    else
        ZlomaCore.Debug('[zloma_core] [SERVER] No external fuel system detected, using native GTA fuel')
    end
end)

-- ============================================================================
-- Server-Side Fuel Functions
-- ============================================================================

--- Set vehicle fuel level (server-side — backup, state bag sync)
--- @param vehicle number|string - Vehicle entity or network ID
--- @param fuelLevel number - Fuel level to set (0-100)
function SetVehicleFuel(vehicle, fuelLevel)
    -- Convert netId to entity if needed
    local entity = vehicle
    if type(vehicle) == 'string' or vehicle > 65535 then
        entity = NetworkGetEntityFromNetworkId(vehicle)
    end
    
    if not entity or entity == 0 or not DoesEntityExist(entity) then 
        if ZlomaCore.Config.Debug then
            print('[zloma_core] [SERVER] SetVehicleFuel: Invalid entity')
        end
        return false
    end
    
    fuelLevel = fuelLevel or 100
    
    -- NOTE: SetVehicleFuelLevel is a CLIENT-SIDE native only.
    -- On the server, we use Entity state bags for fuel sync.
    Entity(entity).state:set('fuel', fuelLevel, true)
    
    -- Also set for external fuel system if available
    if activeFuelSystem then
        local success = pcall(function()
            -- State bag-based fuel systems (server-authoritative)
            if activeFuelSystem == 'lc_fuel' then
                Entity(entity).state.fuel = fuelLevel
            elseif activeFuelSystem == 'qb-fuel' then
                -- qb-fuel exports are client-side; keep server sync authoritative via state bag.
                Entity(entity).state.fuel = fuelLevel
            elseif activeFuelSystem == 'ox_fuel' then
                Entity(entity).state.fuel = fuelLevel
            -- Export-based fuel systems
            elseif activeFuelSystem == 'LegacyFuel' then
                exports['LegacyFuel']:SetFuel(entity, fuelLevel)
            elseif activeFuelSystem == 'lj-fuel' then
                exports['lj-fuel']:SetFuel(entity, fuelLevel)
            elseif activeFuelSystem == 'ps-fuel' then
                exports['ps-fuel']:SetFuel(entity, fuelLevel)
            elseif activeFuelSystem == 'cdn-fuel' then
                exports['cdn-fuel']:SetFuel(entity, fuelLevel)
            elseif activeFuelSystem == 'Renewed-Fuel' then
                exports['Renewed-Fuel']:SetFuel(entity, fuelLevel)
            elseif activeFuelSystem == 'okokGasStation' then
                exports['okokGasStation']:SetFuel(entity, fuelLevel)
            elseif activeFuelSystem == 'qs-fuelstations' then
                exports['qs-fuelstations']:SetFuel(entity, fuelLevel)
            elseif activeFuelSystem == 'rcore_fuel' then
                exports['rcore_fuel']:SetVehicleFuel(entity, fuelLevel)
            elseif activeFuelSystem == 'x-fuel' then
                exports['x-fuel']:SetFuel(entity, fuelLevel)
            elseif activeFuelSystem == 'stg-fuel' then
                exports['stg-fuel']:SetFuel(entity, fuelLevel)
            elseif activeFuelSystem == 'ti_fuel' then
                exports['ti_fuel']:SetFuel(entity, fuelLevel)
            elseif activeFuelSystem == 'esx-sna-fuel' then
                exports['esx-sna-fuel']:SetFuel(entity, fuelLevel)
            elseif activeFuelSystem == 'ND_Fuel' then
                -- ND_Fuel uses decorators, use state bag for server-side sync
                Entity(entity).state:set('fuel', fuelLevel, true)
            elseif activeFuelSystem == 'myFuel' then
                exports['myFuel']:SetFuel(entity, fuelLevel)
            end
        end)
        
        if not success and ZlomaCore.Config.Debug then
            print('[zloma_core] [SERVER] SetVehicleFuel: Failed to set fuel for ' .. activeFuelSystem)
        end
    end
    
    return true
end

--- Get vehicle fuel level (server-side)
--- @param vehicle number|string - Vehicle entity or network ID
--- @return number - Fuel level (0-100)
function GetVehicleFuel(vehicle)
    -- Convert netId to entity if needed
    local entity = vehicle
    if type(vehicle) == 'string' or vehicle > 65535 then
        entity = NetworkGetEntityFromNetworkId(vehicle)
    end
    
    if not entity or entity == 0 or not DoesEntityExist(entity) then 
        return 100 
    end
    
    -- Try active fuel system first
    if activeFuelSystem then
        local success, result = pcall(function()
            -- State bag-based systems
            if activeFuelSystem == 'lc_fuel' then
                return Entity(entity).state.fuel or 100
            elseif activeFuelSystem == 'qb-fuel' then
                return Entity(entity).state.fuel or 100
            elseif activeFuelSystem == 'ox_fuel' then
                return Entity(entity).state.fuel or 100
            -- Export-based systems
            elseif activeFuelSystem == 'LegacyFuel' then
                return exports['LegacyFuel']:GetFuel(entity)
            elseif activeFuelSystem == 'lj-fuel' then
                return exports['lj-fuel']:GetFuel(entity)
            elseif activeFuelSystem == 'ps-fuel' then
                return exports['ps-fuel']:GetFuel(entity)
            elseif activeFuelSystem == 'cdn-fuel' then
                return exports['cdn-fuel']:GetFuel(entity)
            elseif activeFuelSystem == 'Renewed-Fuel' then
                return exports['Renewed-Fuel']:GetFuel(entity)
            elseif activeFuelSystem == 'okokGasStation' then
                return exports['okokGasStation']:GetFuel(entity)
            elseif activeFuelSystem == 'qs-fuelstations' then
                return exports['qs-fuelstations']:GetFuel(entity)
            elseif activeFuelSystem == 'rcore_fuel' then
                return exports['rcore_fuel']:GetVehicleFuelPercentage(entity)
            elseif activeFuelSystem == 'x-fuel' then
                return exports['x-fuel']:GetFuel(entity)
            elseif activeFuelSystem == 'stg-fuel' then
                return exports['stg-fuel']:GetFuel(entity)
            elseif activeFuelSystem == 'ti_fuel' then
                return exports['ti_fuel']:GetFuel(entity)
            elseif activeFuelSystem == 'esx-sna-fuel' then
                return exports['esx-sna-fuel']:GetFuel(entity)
            elseif activeFuelSystem == 'myFuel' then
                return exports['myFuel']:GetFuel(entity)
            end
        end)
        
        if success and result then
            return result
        end
    end
    
    -- Fallback to native GTA fuel
    return GetVehicleFuelLevel(entity)
end

-- ============================================================================
-- Exports
-- ============================================================================

exports('SetVehicleFuel', SetVehicleFuel)
exports('GetVehicleFuel', GetVehicleFuel)
exports('GetFuelSystem', function() return activeFuelSystem end)
