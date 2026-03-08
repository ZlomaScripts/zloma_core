fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Zloma'
description 'ZLOMA CORE - Universal framework wrapper for ESX/QBCore/QBox'
version '1.0.0'

dependencies {
    'ox_lib',
    'oxmysql'
}

shared_scripts {
    '@ox_lib/init.lua',

    'shared/config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/framework.lua',
    'server/inventory.lua',
    'server/billing.lua',
    'server/callbacks.lua',
    'server/dispatch.lua',
    'server/fuel.lua'
}

client_scripts {
    'client/init.lua',      -- Initialize detection FIRST
    'client/appearance.lua',
    'client/inventory.lua', -- Added generic client inventory wrapper
    'client/notifications.lua',
    'client/keys.lua',
    'client/target.lua',
    'client/fuel.lua', -- Fuel system wrapper
    'client/callbacks.lua'
}

-- ════════════════════════════════════════════════════════════════════════════════
-- CLIENT EXPORTS (declared for anticheat compatibility)
-- ════════════════════════════════════════════════════════════════════════════════
exports {
    -- init.lua
    'IsAdmin',
    'GetPlayerJob',
    'GetPlayerGang',
    'GetAppearanceSystem',
    'GetCurrentSkin',
    'SetPlayerSkin',
    'SetPlayerClothing',
    'OpenWardrobe',
    -- inventory.lua
    'GetInventory',
    'HasItem',
    -- notifications.lua
    'Notify',
    'NotifyAdvanced',
    -- keys.lua
    'GiveKeys',
    'RemoveKeys',
    'HasKeys',
    -- target.lua
    'GetTargetSystem',
    'AddEntity',
    'AddBoxZone',
    'AddSphereZone',
    'RemoveEntity',
    'AddGlobalVehicle',
    'RemoveZone',
    'SetTargetingEnabled',
    -- fuel.lua
    'GetVehicleFuel',
    'SetVehicleFuel',
    'GetFuelSystem'
}

-- ════════════════════════════════════════════════════════════════════════════════
-- SERVER EXPORTS (declared for anticheat compatibility)
-- ════════════════════════════════════════════════════════════════════════════════
server_exports {
    -- framework.lua
    'GetFrameworkType',
    'GetPlayer',
    'GetPlayerMoney',
    'RemoveMoney',
    'AddMoney',
    'GetPlayerJob',
    'GetPlayerGang',
    'GetIdentifier',
    'GetCharacterName',
    'GetPlayerFromIdentifier',
    'IsAdmin',
    'Notify',
    'GiveVehicleKeys',
    'RemoveVehicleKeys',
    'GetSocietyMoney',
    'AddSocietyMoney',
    'RemoveSocietyMoney',
    'GetSocietySystem',
    'SetPlayerJob',
    'GetAllJobs',
    'GetAllGangs',
    'GetJobGrades',
    'GetOnlinePlayers',
    'GetPlayerGroup',
    'CreateUseableItem',
    'GetOfflinePlayerJob',
    'SetOfflinePlayerJob',
    'GetDispatchSystem',
    'SendDispatchAlert',
    -- fuel.lua
    'SetVehicleFuel',
    'GetVehicleFuel',
    'GetFuelSystem',
    -- billing.lua
    'SendBill',
    'GetBills',
    -- inventory.lua
    'HasItem',
    'GetItemCount',
    'AddItem',
    'RemoveItem',
    'GetInventory',
    'GetItemMetadata',
    'GetInventorySystem',
    'SupportsStashes',
    'RegisterStash',
    'OpenStash',
    'GetStashItems'
}

-- Provides unified interface for all zloma scripts
-- Automatically detects and wraps: frameworks, inventories, billing, notifications, keys, targets
-- Version-agnostic and plug-and-play design minimizes support needs
