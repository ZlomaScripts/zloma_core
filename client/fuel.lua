--[[
    zloma_core - Client Fuel System Wrapper
    
    Universal fuel system wrapper supporting multiple fuel scripts.
    Auto-detects and wraps all popular fuel systems CLIENT-SIDE.
    
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
        ZlomaCore.Debug(string.format("Fuel system loaded: %s", activeFuelSystem))
    else
        ZlomaCore.Debug('[zloma_core] No external fuel system detected, using native GTA fuel')
    end
end)

-- ============================================================================
-- Fuel Functions (CLIENT-SIDE)
-- ============================================================================
-- ADD NEW FUEL SUPPORT HERE
-- ============================================================================
-- To add support for a new fuel system:
-- 1. Add the resource name to ZlomaCore.DetectFuel() in shared/config.lua
-- 2. Add elseif block in GetVehicleFuel() below
-- 3. Add elseif block in SetVehicleFuel() below
-- ============================================================================

--- Get vehicle fuel level (client-side)
--- @param vehicle number - Vehicle entity
--- @return number - Fuel level (0-100)
function GetVehicleFuel(vehicle)
    if not DoesEntityExist(vehicle) then 
        return 100 
    end
    
    -- Try active fuel system first
    if activeFuelSystem then
        local success, result = pcall(function()
            if activeFuelSystem == 'lc_fuel' then
                return exports['lc_fuel']:GetFuel(vehicle)
            elseif activeFuelSystem == 'qb-fuel' then
                return exports['qb-fuel']:GetFuel(vehicle)
            elseif activeFuelSystem == 'ox_fuel' then
                return Entity(vehicle).state.fuel or GetVehicleFuelLevel(vehicle)
            elseif activeFuelSystem == 'LegacyFuel' then
                return exports['LegacyFuel']:GetFuel(vehicle)
            elseif activeFuelSystem == 'lj-fuel' then
                return exports['lj-fuel']:GetFuel(vehicle)
            elseif activeFuelSystem == 'ps-fuel' then
                return exports['ps-fuel']:GetFuel(vehicle)
            elseif activeFuelSystem == 'cdn-fuel' then
                return exports['cdn-fuel']:GetFuel(vehicle)
            elseif activeFuelSystem == 'Renewed-Fuel' then
                return exports['Renewed-Fuel']:GetFuel(vehicle)
            elseif activeFuelSystem == 'okokGasStation' then
                return exports['okokGasStation']:GetFuel(vehicle)
            elseif activeFuelSystem == 'qs-fuelstations' then
                return exports['qs-fuelstations']:GetFuel(vehicle)
            elseif activeFuelSystem == 'rcore_fuel' then
                return exports['rcore_fuel']:GetVehicleFuelPercentage(vehicle)
            elseif activeFuelSystem == 'x-fuel' then
                return exports['x-fuel']:GetFuel(vehicle)
            elseif activeFuelSystem == 'stg-fuel' then
                return exports['stg-fuel']:GetFuel(vehicle)
            elseif activeFuelSystem == 'ti_fuel' then
                return exports['ti_fuel']:GetFuel(vehicle)
            elseif activeFuelSystem == 'esx-sna-fuel' then
                return exports['esx-sna-fuel']:GetFuel(vehicle)
            elseif activeFuelSystem == 'ND_Fuel' then
                return DecorGetFloat(vehicle, '_FUEL_LEVEL') or GetVehicleFuelLevel(vehicle)
            elseif activeFuelSystem == 'myFuel' then
                return exports['myFuel']:GetFuel(vehicle)
            end
        end)
        
        if success and result then
            return result
        end
    end
    
    -- Fallback to native GTA fuel
    return GetVehicleFuelLevel(vehicle)
end

--- Set vehicle fuel level (client-side — IMMEDIATE, used on spawn)
--- @param vehicle number - Vehicle entity
--- @param fuelLevel number - Fuel level to set (0-100)
function SetVehicleFuel(vehicle, fuelLevel)
    if not DoesEntityExist(vehicle) then 
        return 
    end
    
    fuelLevel = fuelLevel or 100
    
    -- Always set native fuel level first
    SetVehicleFuelLevel(vehicle, fuelLevel + 0.0)
    
    -- Also set for external fuel system if available
    if activeFuelSystem then
        pcall(function()
            if activeFuelSystem == 'lc_fuel' then
                exports['lc_fuel']:SetFuel(vehicle, fuelLevel)
            elseif activeFuelSystem == 'qb-fuel' then
                exports['qb-fuel']:SetFuel(vehicle, fuelLevel)
            elseif activeFuelSystem == 'ox_fuel' then
                Entity(vehicle).state.fuel = fuelLevel
                SetVehicleFuelLevel(vehicle, fuelLevel + 0.0)
            elseif activeFuelSystem == 'LegacyFuel' then
                exports['LegacyFuel']:SetFuel(vehicle, fuelLevel)
            elseif activeFuelSystem == 'lj-fuel' then
                exports['lj-fuel']:SetFuel(vehicle, fuelLevel)
            elseif activeFuelSystem == 'ps-fuel' then
                exports['ps-fuel']:SetFuel(vehicle, fuelLevel)
            elseif activeFuelSystem == 'cdn-fuel' then
                exports['cdn-fuel']:SetFuel(vehicle, fuelLevel)
            elseif activeFuelSystem == 'Renewed-Fuel' then
                exports['Renewed-Fuel']:SetFuel(vehicle, fuelLevel)
            elseif activeFuelSystem == 'okokGasStation' then
                exports['okokGasStation']:SetFuel(vehicle, fuelLevel)
            elseif activeFuelSystem == 'qs-fuelstations' then
                exports['qs-fuelstations']:SetFuel(vehicle, fuelLevel)
            elseif activeFuelSystem == 'rcore_fuel' then
                exports['rcore_fuel']:SetVehicleFuel(vehicle, fuelLevel)
            elseif activeFuelSystem == 'x-fuel' then
                exports['x-fuel']:SetFuel(vehicle, fuelLevel)
            elseif activeFuelSystem == 'stg-fuel' then
                exports['stg-fuel']:SetFuel(vehicle, fuelLevel)
            elseif activeFuelSystem == 'ti_fuel' then
                exports['ti_fuel']:SetFuel(vehicle, fuelLevel)
            elseif activeFuelSystem == 'esx-sna-fuel' then
                exports['esx-sna-fuel']:SetFuel(vehicle, fuelLevel)
            elseif activeFuelSystem == 'ND_Fuel' then
                DecorSetFloat(vehicle, '_FUEL_LEVEL', fuelLevel + 0.0)
                SetVehicleFuelLevel(vehicle, fuelLevel + 0.0)
            elseif activeFuelSystem == 'myFuel' then
                exports['myFuel']:SetFuel(vehicle, fuelLevel)
            end
        end)
    end
end

-- ============================================================================
-- Exports
-- ============================================================================

exports('GetVehicleFuel', GetVehicleFuel)
exports('SetVehicleFuel', SetVehicleFuel)
exports('GetFuelSystem', function() return activeFuelSystem end)
