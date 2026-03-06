-- ZLOMA CORE - Shared Configuration & Auto-Detection
-- Auto-detects all systems at runtime - no manual configuration needed
-- Customer-friendly: Works out of the box with any combination of systems

ZlomaCore = {}
ZlomaCore.Config = {}

-- Detected systems (cached at runtime)
ZlomaCore.Cache = {
    Framework = nil,
    Inventory = nil,
    Billing = nil,
    Notification = nil,
    Keys = nil,
    Target = nil,
    Fuel = nil,
    Society = nil  -- Society/Banking system cache
}

-- Debug mode (set to true for detailed console logs)
ZlomaCore.Config.Debug = false

-- ======================================================
-- TIMEOUT CONFIGURATION
-- Centralized timeout values for easy adjustment
-- ======================================================
ZlomaCore.Config.Timeouts = {
    CallbackDefault = 5000,   -- Default callback timeout (ms)
    InitWait = 500,           -- Wait time for system initialization (ms)
    DetectionWait = 200,      -- Wait time for detection loops (ms)
    PollingInterval = 50      -- Polling interval for callbacks (ms)
}

-- ======================================================
-- MANUAL CONFIGURATION (Advanced Users)
-- Set to 'auto' for automatic detection, or specify exact system name
-- ======================================================
ZlomaCore.Config.Manual = {
    Framework = 'auto',    -- 'auto', 'ESX', 'QBCore', 'QBox'
    Inventory = 'auto',    -- 'auto', 'ox_inventory', 'qb-inventory', 'qs-inventory', 'ps-inventory', 'codem-inventory', 'tgiann-inventory', 'origen-inventory', 'core_inventory', 'ak47_inventory', 'jaksam_inventory', 'jpr-inventory', 'S-Inventory'
    Billing = 'auto',      -- 'auto', 'okokBilling', 'okok_billing', 'esx_billing', 'qb-billing'
    Notification = 'auto', -- 'auto', 'ox_lib', 'mythic', 't-notify', 'okok', 'esx_notify', 'QBCore', 'ESX', 'wasabi_notify', 'fl-notify', 'brutal_notify', 'is_ui', 'lation_ui', 'g-notifications', 'vms_notifyv2', 'wasabi_uikit'
    Keys = 'auto',         -- 'auto', 'zloma_keys', 'qb-vehiclekeys', 'wasabi_carlock', 'cd_garage', 'jaksam', 'Renewed-Vehiclekeys', 'MrNewbVehicleKeys', 'qbx_vehiclekeys', 'qs-vehiclekeys', 'tgiann-hotwire', 'ak47_vehiclekeys', 'ak47_qb_vehiclekeys', 'mk_vehiclekeys', 'filo_vehiclekey', 'is_carkeys', 'LifeSaver_KeySystem', 'brutal_carkeys', 'ic3d_vehiclekeys', 'mm_carkeys', 'rd_vehiclekeys', 'p_carkeys'
    Target = 'auto',       -- 'auto', 'ox_target', 'qb-target', 'qtarget'
    Fuel = 'auto',         -- 'auto', 'lc_fuel', 'qb-fuel', 'LegacyFuel', 'ox_fuel', 'lj-fuel', 'ps-fuel', 'cdn-fuel', 'Renewed-Fuel', 'okokGasStation', 'qs-fuelstations', 'rcore_fuel', 'x-fuel', 'stg-fuel', 'ti_fuel', 'esx-sna-fuel', 'ND_Fuel', 'myFuel'
    Society = 'auto'       -- 'auto', 'esx_addonaccount', 'qb-banking', 'okokBanking', 'wasabi_banking', 'qs-banking', 'Renewed-Banking', 'RxBanking', 'nfs-billing', 'crm-banking', 'kartik-banking', 'snipe-banking', 'tgg-banking', 'fd_banking', 'vms_bossmenu', 'xnr-bossmenu', 'nass_bossmenu', 'sd-multijob', 'p_banking'
}

-- ======================================================
-- AUTO-DETECTION FUNCTIONS
-- ======================================================

function ZlomaCore.DetectFramework()
    local manual = ZlomaCore.Config.Manual.Framework

    -- Use manual if not 'auto'
    if manual and manual ~= 'auto' then
        ZlomaCore.Debug(string.format("Using manual framework: %s", manual))
        return manual
    end

    -- Auto-detect
    if GetResourceState('es_extended') == 'started' then
        return 'ESX'
    elseif GetResourceState('qb-core') == 'started' then
        return 'QBCore'
    elseif GetResourceState('qbx_core') == 'started' or GetResourceState('qbx-core') == 'started' then
        return 'QBox'
    end
    return nil
end

function ZlomaCore.DetectInventory()
    local manual = ZlomaCore.Config.Manual.Inventory

    -- Use manual if not 'auto'
    if manual and manual ~= 'auto' then
        ZlomaCore.Debug(string.format("Using manual inventory: %s", manual))
        return manual
    end

    -- ============================================================================
    -- ADD NEW INVENTORY SUPPORT HERE
    -- ============================================================================
    -- To add support for a new inventory system:
    -- 1. Add elseif block below with GetResourceState check
    -- 2. Add the inventory name to ZlomaCore.Config.Manual.Inventory comment above
    -- 3. Implement HasItem, GetItemCount, AddItem, RemoveItem, GetInventory in server/inventory.lua
    -- 4. Optionally add client-side support in client/inventory.lua
    -- ============================================================================
    
    -- Auto-detect (priority order)
    if GetResourceState('ox_inventory') == 'started' then
        return 'ox_inventory'
    elseif GetResourceState('tgiann-inventory') == 'started' then
        return 'tgiann-inventory'
    elseif GetResourceState('origen_inventory') == 'started' or GetResourceState('origen-inventory') == 'started' then
        return 'origen-inventory'
    elseif GetResourceState('qb-inventory') == 'started' then
        return 'qb-inventory'
    elseif GetResourceState('qs-inventory') == 'started' then
        return 'qs-inventory'
    elseif GetResourceState('ps-inventory') == 'started' then
        return 'ps-inventory'
    elseif GetResourceState('codem-inventory') == 'started' then
        return 'codem-inventory'
    elseif GetResourceState('core_inventory') == 'started' then
        return 'core_inventory'
    elseif GetResourceState('ak47_inventory') == 'started' then
        return 'ak47_inventory'
    elseif GetResourceState('jaksam_inventory') == 'started' then
        return 'jaksam_inventory'
    elseif GetResourceState('jpr-inventory') == 'started' then
        return 'jpr-inventory'
    elseif GetResourceState('S-Inventory') == 'started' or GetResourceState('S-inventory') == 'started' then
        return 'S-Inventory'
    end
    return nil
end

function ZlomaCore.DetectBilling()
    local manual = ZlomaCore.Config.Manual.Billing

    -- Use manual if not 'auto'
    if manual and manual ~= 'auto' then
        ZlomaCore.Debug(string.format("Using manual billing: %s", manual))
        return manual
    end

    -- Auto-detect
    if GetResourceState('okokBilling') == 'started' then
        return 'okokBilling'
    elseif GetResourceState('okok_billing') == 'started' then
        return 'okok_billing'
    elseif GetResourceState('esx_billing') == 'started' then
        return 'esx_billing'
    elseif GetResourceState('qb-billing') == 'started' then
        return 'qb-billing'
    end
    return nil
end

function ZlomaCore.DetectNotification()
    local manual = ZlomaCore.Config.Manual.Notification

    -- Use manual if not 'auto'
    if manual and manual ~= 'auto' then
        ZlomaCore.Debug(string.format("Using manual notification: %s", manual))
        return manual
    end

    -- ============================================================================
    -- ADD NEW NOTIFICATION SUPPORT HERE
    -- ============================================================================
    -- To add support for a new notification system:
    -- 1. Add elseif block below with GetResourceState check
    -- 2. Add the notification name to ZlomaCore.Config.Manual.Notification comment above
    -- 3. Implement Notify function in client/notifications.lua
    -- ============================================================================
    
    -- Auto-detect (priority order - most feature-rich first)
    if GetResourceState('ox_lib') == 'started' then
        return 'ox_lib'
    elseif GetResourceState('wasabi_notify') == 'started' then
        return 'wasabi_notify'
    elseif GetResourceState('wasabi_uikit') == 'started' then
        return 'wasabi_uikit'
    elseif GetResourceState('fl-notify') == 'started' then
        return 'fl-notify'
    elseif GetResourceState('brutal_notify') == 'started' then
        return 'brutal_notify'
    elseif GetResourceState('is_ui') == 'started' then
        return 'is_ui'
    elseif GetResourceState('lation_ui') == 'started' then
        return 'lation_ui'
    elseif GetResourceState('g-notifications') == 'started' then
        return 'g-notifications'
    elseif GetResourceState('vms_notifyv2') == 'started' then
        return 'vms_notifyv2'
    elseif GetResourceState('mythic_notify') == 'started' then
        return 'mythic'
    elseif GetResourceState('t-notify') == 'started' then
        return 't-notify'
    elseif GetResourceState('okokNotify') == 'started' then
        return 'okok'
    elseif GetResourceState('esx_notify') == 'started' then
        return 'esx_notify'
    elseif GetResourceState('qb-core') == 'started' then
        return 'QBCore'
    elseif GetResourceState('es_extended') == 'started' then
        return 'ESX'
    end
    return nil
end

function ZlomaCore.DetectKeys()
    local manual = ZlomaCore.Config.Manual.Keys

    -- Use manual if not 'auto'
    if manual and manual ~= 'auto' then
        ZlomaCore.Debug(string.format("Using manual keys: %s", manual))
        return manual
    end

    -- ============================================================================
    -- ADD NEW KEYS SUPPORT HERE
    -- ============================================================================
    -- To add support for a new keys system:
    -- 1. Add elseif block below with GetResourceState check
    -- 2. Add the keys name to ZlomaCore.Config.Manual.Keys comment above
    -- 3. Implement GiveKeys, RemoveKeys, HasKeys in client/keys.lua
    -- ============================================================================
    
    -- Auto-detect
    if GetResourceState('zloma_keys') == 'started' then
        return 'zloma_keys'
    elseif GetResourceState('Renewed-Vehiclekeys') == 'started' then
        return 'Renewed-Vehiclekeys'
    elseif GetResourceState('MrNewbVehicleKeys') == 'started' then
        return 'MrNewbVehicleKeys'
    elseif GetResourceState('qbx_vehiclekeys') == 'started' then
        return 'qbx_vehiclekeys'
    elseif GetResourceState('qb-vehiclekeys') == 'started' then
        return 'qb-vehiclekeys'
    elseif GetResourceState('qs-vehiclekeys') == 'started' then
        return 'qs-vehiclekeys'
    elseif GetResourceState('wasabi_carlock') == 'started' then
        return 'wasabi_carlock'
    elseif GetResourceState('cd_garage') == 'started' then
        return 'cd_garage'
    elseif GetResourceState('jaksam-vehicles-keys') == 'started' or GetResourceState('vehicles_keys') == 'started' then
        return 'jaksam'
    elseif GetResourceState('tgiann-hotwire') == 'started' then
        return 'tgiann-hotwire'
    elseif GetResourceState('ak47_vehiclekeys') == 'started' then
        return 'ak47_vehiclekeys'
    elseif GetResourceState('ak47_qb_vehiclekeys') == 'started' then
        return 'ak47_qb_vehiclekeys'
    elseif GetResourceState('mk_vehiclekeys') == 'started' then
        return 'mk_vehiclekeys'
    elseif GetResourceState('filo_vehiclekey') == 'started' then
        return 'filo_vehiclekey'
    elseif GetResourceState('is_carkeys') == 'started' or GetResourceState('is_vehiclekeys') == 'started' then
        return 'is_carkeys'
    elseif GetResourceState('LifeSaver_KeySystem') == 'started' then
        return 'LifeSaver_KeySystem'
    elseif GetResourceState('brutal_carkeys') == 'started' then
        return 'brutal_carkeys'
    elseif GetResourceState('ic3d_vehiclekeys') == 'started' then
        return 'ic3d_vehiclekeys'
    elseif GetResourceState('mm_carkeys') == 'started' then
        return 'mm_carkeys'
    elseif GetResourceState('rd_vehiclekeys') == 'started' then
        return 'rd_vehiclekeys'
    elseif GetResourceState('p_carkeys') == 'started' then
        return 'p_carkeys'
    end
    return nil
end

function ZlomaCore.DetectTarget()
    local manual = ZlomaCore.Config.Manual.Target

    -- Use manual if not 'auto'
    if manual and manual ~= 'auto' then
        ZlomaCore.Debug(string.format("Using manual target: %s", manual))
        return manual
    end

    -- ============================================================================
    -- ADD NEW TARGET SUPPORT HERE
    -- ============================================================================
    -- To add support for a new target system:
    -- 1. Add elseif block below with GetResourceState check
    -- 2. Add the target name to ZlomaCore.Config.Manual.Target comment above
    -- 3. Implement AddEntity, AddBoxZone, AddSphereZone, AddGlobalVehicle, RemoveZone in client/target.lua
    -- ============================================================================
    
    -- Auto-detect
    if GetResourceState('ox_target') == 'started' then
        return 'ox_target'
    elseif GetResourceState('qb-target') == 'started' then
        return 'qb-target'
    elseif GetResourceState('qtarget') == 'started' then
        return 'qtarget'
    end
    return nil
end

-- ============================================================================
-- FUEL DETECTION
-- ============================================================================
function ZlomaCore.DetectFuel()
    local manual = ZlomaCore.Config.Manual.Fuel

    -- Use manual if not 'auto'
    if manual and manual ~= 'auto' then
        ZlomaCore.Debug(string.format("Using manual fuel: %s", manual))
        return manual
    end

    -- ============================================================================
    -- ADD NEW FUEL SUPPORT HERE
    -- ============================================================================
    -- To add support for a new fuel system:
    -- 1. Add elseif block below with GetResourceState check
    -- 2. Add the fuel name to ZlomaCore.Config.Manual.Fuel comment above
    -- 3. Add elseif block in client/fuel.lua -> GetVehicleFuel()
    -- 4. Add elseif block in client/fuel.lua -> SetVehicleFuel()
    -- ============================================================================
    
    -- Auto-detect (priority order)
    if GetResourceState('lc_fuel') == 'started' then
        return 'lc_fuel'
    elseif GetResourceState('qb-fuel') == 'started' then
        return 'qb-fuel'
    elseif GetResourceState('LegacyFuel') == 'started' then
        return 'LegacyFuel'
    elseif GetResourceState('ox_fuel') == 'started' then
        return 'ox_fuel'
    elseif GetResourceState('lj-fuel') == 'started' then
        return 'lj-fuel'
    elseif GetResourceState('ps-fuel') == 'started' then
        return 'ps-fuel'
    elseif GetResourceState('cdn-fuel') == 'started' then
        return 'cdn-fuel'
    elseif GetResourceState('Renewed-Fuel') == 'started' then
        return 'Renewed-Fuel'
    elseif GetResourceState('okokGasStation') == 'started' then
        return 'okokGasStation'
    elseif GetResourceState('qs-fuelstations') == 'started' then
        return 'qs-fuelstations'
    elseif GetResourceState('rcore_fuel') == 'started' then
        return 'rcore_fuel'
    elseif GetResourceState('x-fuel') == 'started' then
        return 'x-fuel'
    elseif GetResourceState('stg-fuel') == 'started' then
        return 'stg-fuel'
    elseif GetResourceState('ti_fuel') == 'started' then
        return 'ti_fuel'
    elseif GetResourceState('esx-sna-fuel') == 'started' then
        return 'esx-sna-fuel'
    elseif GetResourceState('ND_Fuel') == 'started' then
        return 'ND_Fuel'
    elseif GetResourceState('myFuel') == 'started' then
        return 'myFuel'
    end
    return nil
end

-- ============================================================================
-- SOCIETY/BANKING DETECTION
-- ============================================================================
function ZlomaCore.DetectSociety()
    local manual = ZlomaCore.Config.Manual.Society

    -- Use manual if not 'auto'
    if manual and manual ~= 'auto' then
        ZlomaCore.Debug(string.format("Using manual society: %s", manual))
        return manual
    end

    -- Auto-detect (priority order - dedicated banking first, then boss menus)
    if GetResourceState('esx_addonaccount') == 'started' then
        return 'esx_addonaccount'
    elseif GetResourceState('qb-banking') == 'started' then
        return 'qb-banking'
    elseif GetResourceState('okokBanking') == 'started' then
        return 'okokBanking'
    elseif GetResourceState('wasabi_banking') == 'started' then
        return 'wasabi_banking'
    elseif GetResourceState('qs-banking') == 'started' then
        return 'qs-banking'
    elseif GetResourceState('Renewed-Banking') == 'started' then
        return 'Renewed-Banking'
    elseif GetResourceState('RxBanking') == 'started' then
        return 'RxBanking'
    elseif GetResourceState('crm-banking') == 'started' then
        return 'crm-banking'
    elseif GetResourceState('kartik-banking') == 'started' then
        return 'kartik-banking'
    elseif GetResourceState('snipe-banking') == 'started' then
        return 'snipe-banking'
    elseif GetResourceState('tgg-banking') == 'started' then
        return 'tgg-banking'
    elseif GetResourceState('fd_banking') == 'started' then
        return 'fd_banking'
    elseif GetResourceState('nfs-billing') == 'started' then
        return 'nfs-billing'
    elseif GetResourceState('p_banking') == 'started' then
        return 'p_banking'
    elseif GetResourceState('nfs-banking') == 'started' then
        return 'nfs-banking'
    elseif GetResourceState('vms_bossmenu') == 'started' then
        return 'vms_bossmenu'
    elseif GetResourceState('xnr-bossmenu') == 'started' then
        return 'xnr-bossmenu'
    elseif GetResourceState('nass_bossmenu') == 'started' or GetResourceState('nass_bosmenu') == 'started' then
        return 'nass_bossmenu'
    elseif GetResourceState('sd-multijob') == 'started' then
        return 'sd-multijob'
    end
    return nil
end

-- Initialize detection on resource start
function ZlomaCore.Initialize()
    ZlomaCore.Cache.Framework = ZlomaCore.DetectFramework()
    ZlomaCore.Cache.Inventory = ZlomaCore.DetectInventory()
    ZlomaCore.Cache.Billing = ZlomaCore.DetectBilling()
    ZlomaCore.Cache.Notification = ZlomaCore.DetectNotification()
    ZlomaCore.Cache.Keys = ZlomaCore.DetectKeys()
    ZlomaCore.Cache.Target = ZlomaCore.DetectTarget()
    ZlomaCore.Cache.Fuel = ZlomaCore.DetectFuel()
    ZlomaCore.Cache.Society = ZlomaCore.DetectSociety()

    -- Console output
    print("^2========================================^0")
    print("^2ZLOMA CORE v1.0.0 - System Detection^0")
    print("^2========================================^0")
    print(string.format("^3Framework:^0 %s", ZlomaCore.Cache.Framework or "^1NONE DETECTED^0"))
    print(string.format("^3Inventory:^0 %s", ZlomaCore.Cache.Inventory or "^1NONE DETECTED^0"))
    print(string.format("^3Billing:^0 %s", ZlomaCore.Cache.Billing or "^1NONE DETECTED^0"))
    print(string.format("^3Notification:^0 %s", ZlomaCore.Cache.Notification or "^1NONE DETECTED^0"))
    print(string.format("^3Keys:^0 %s", ZlomaCore.Cache.Keys or "^1NONE DETECTED^0"))
    print(string.format("^3Target:^0 %s", ZlomaCore.Cache.Target or "^1NONE DETECTED^0"))
    print(string.format("^3Fuel:^0 %s", ZlomaCore.Cache.Fuel or "^1NONE DETECTED^0"))
    print(string.format("^3Society:^0 %s", ZlomaCore.Cache.Society or "^1NONE DETECTED^0"))
    print("^2========================================^0")
end

-- Utility: Safe print with debug check
function ZlomaCore.Debug(message)
    if ZlomaCore.Config.Debug then
        print("^5[ZLOMA DEBUG]^0 " .. message)
    end
end

-- Utility: Warning message for missing systems
function ZlomaCore.Warn(system, action)
    print(string.format("^3[ZLOMA WARNING]^0 %s not detected - %s action skipped", system, action))
end
