-- ZLOMA CORE - Client Target Wrapper
-- Unified interface for ox_target, qb-target, qtarget
-- Customer-friendly: Consistent API across all targeting systems

local TargetType = nil

-- ============================================================================
-- EVENT REGISTRY SYSTEM - Memory Leak Prevention
-- ============================================================================
-- Tracks all dynamically registered events for proper cleanup
local registeredEvents = {}
local globalVehicleEventNames = {}

-- Cleanup function to remove registered event handlers
local function CleanupTargetEvent(eventName)
    if registeredEvents[eventName] then
        RemoveEventHandler(registeredEvents[eventName])
        registeredEvents[eventName] = nil
        ZlomaCore.Debug(string.format("Cleaned up target event: %s", eventName))
    end
end

-- Cleanup all registered events (called on resource stop)
local function CleanupAllTargetEvents()
    local count = 0
    for eventName, handler in pairs(registeredEvents) do
        RemoveEventHandler(handler)
        count = count + 1
    end
    registeredEvents = {}
    if count > 0 then
        print(string.format("^3[ZLOMA CLEANUP]^0 Removed %d registered target events", count))
    end
end

local GlobalTargetLabels = {}

local function CleanupGlobalVehicleTargets()
    if TargetType == 'qb-target' and #GlobalTargetLabels > 0 then
        exports['qb-target']:RemoveGlobalType(2, GlobalTargetLabels)
    end

    for _, eventName in ipairs(globalVehicleEventNames) do
        CleanupTargetEvent(eventName)
    end

    globalVehicleEventNames = {}
    GlobalTargetLabels = {}
end

-- Initialize target detection
CreateThread(function()
    Wait(500) -- Wait longer for target system to fully load
    TargetType = ZlomaCore.Cache.Target

    -- Additional validation for ox_target
    if TargetType == 'ox_target' then
        local maxWait = 0
        while not exports.ox_target and maxWait < 5000 do
            Wait(100)
            maxWait = maxWait + 100
        end
    end

    if TargetType then
        ZlomaCore.Debug(string.format("Target system loaded: %s", TargetType))
    else
        print("^3[ZLOMA WARNING]^0 No target system detected. Target functions will not work.")
    end
end)

-- EXPORT: GetTargetSystem() - Get current target system name
-- Returns: 'ox_target', 'qb-target', 'qtarget', or nil if none detected
exports('GetTargetSystem', function()
    return TargetType
end)

exports('SetTargetingEnabled', function(enabled)
    if not TargetType then
        ZlomaCore.Warn('Target', 'SetTargetingEnabled')
        return false
    end

    if TargetType == 'ox_target' and exports.ox_target then
        exports.ox_target:disableTargeting(not enabled)
        return true
    end

    return true
end)

-- EXPORT: AddEntity(entity, options) - Add target options to entity
-- entity: Entity handle or array of entities
-- options: Table of target options (standardized format)
-- Returns: true if successful, false otherwise
-- Helper: Dynamic Event Registry for qb-target/qtarget compatibility
-- These frameworks require an event string, they cannot handle direct function callbacks
-- ============================================================================
-- ADD NEW TARGET SUPPORT HERE
-- ============================================================================
-- To add support for a new target system:
-- 1. Add detection in shared/config.lua -> ZlomaCore.DetectTarget()
-- 2. Add the target name to ZlomaCore.Config.Manual.Target options
-- 3. Add elseif blocks in AddEntity, AddBoxZone, AddSphereZone, AddGlobalVehicle, RemoveZone
-- ============================================================================
local function RegisterTargetEvent(action)
    if type(action) == 'string' then return action end -- Already string? Return it

    local actionType = type(action)
    
    -- Handle FiveM function references (tables with __cfx_functionReference)
    -- These are serialized functions that need special handling
    if actionType == 'table' and action.__cfx_functionReference then
        -- This is a CFX function reference - we can call it directly as a function
        -- FiveM will handle the deserialization
        local cfxRef = action
        local eventName = string.format('zloma_core:target:%s_%s', GetGameTimer(), math.random(1000, 9999))
        
        RegisterNetEvent(eventName)
        local handler = AddEventHandler(eventName, function(...)
            -- CFX function references are callable
            cfxRef(...)
        end)
        
        -- Track for cleanup
        registeredEvents[eventName] = handler
        
        return eventName
    end
    
    -- Allow function, table (export ref), or userdata (ref)
    if actionType ~= 'function' and actionType ~= 'table' and actionType ~= 'userdata' then
        return nil
    end

    local eventName = string.format('zloma_core:target:%s_%s', GetGameTimer(), math.random(1000, 9999))

    RegisterNetEvent(eventName)
    local handler = AddEventHandler(eventName, function(...)
        action(...)
    end)
    
    -- Track for cleanup
    registeredEvents[eventName] = handler

    return eventName
end

-- EXPORT: AddEntity(entity, options) - Add target options to entity
-- entity: Entity handle or array of entities
-- options: Table of target options (standardized format)
-- Returns: true if successful, false otherwise
exports('AddEntity', function(entity, options)
    if not entity or not options then
        print("^1[ZLOMA ERROR]^0 AddEntity - Entity and options are required")
        return false
    end

    if not TargetType then
        ZlomaCore.Warn("Target", "AddEntity")
        return false
    end

    -- Standardize options format
    -- Expected format: { name, icon, label, action, canInteract, distance }
    local success = false

    if TargetType == 'ox_target' then
        -- ox_target format
        local oxOptions = {}
        for _, opt in ipairs(options) do
                -- Pass canInteract directly - ox_target handles errors internally
            -- Avoiding pcall wrapper here prevents WaveShield anticheat conflicts
            local safeCanInteract = opt.canInteract

            local action = opt.onSelect or opt.action
            
            -- Pass action directly - ox_target already wraps callbacks in pcall
            -- NOTE: Functions passed through exports become tables, so we need to handle both
            local safeAction = nil
            if type(action) == 'function' or type(action) == 'table' then
                safeAction = action
            end
            
            local oxOpt = {
                name = opt.name,
                icon = opt.icon or 'fas fa-hand',
                label = opt.label,
                canInteract = safeCanInteract,
                distance = opt.distance or 2.5
            }

            if type(action) == 'string' then
                oxOpt.event = action
            elseif safeAction then
                oxOpt.onSelect = safeAction
            end

            table.insert(oxOptions, oxOpt)
        end

        if exports.ox_target then
            exports.ox_target:addLocalEntity(entity, oxOptions)
            success = true
            ZlomaCore.Debug(string.format("ox_target: Added entity target with %s options", #options))
        end
    elseif TargetType == 'qb-target' then
        -- qb-target format
        local qbOptions = {
            options = {},
            distance = (options[1] and options[1].distance) or 2.5
        }

        for _, opt in ipairs(options) do
            -- Convert function to dynamic event
            -- support event, onSelect, or action keys
            local actionOrEvent = opt.event or opt.onSelect or opt.action
            local eventName = RegisterTargetEvent(actionOrEvent)

            -- Wrap canInteract to prevent crashes and adapt arguments
            -- qb-target passes (entity, distance, data)
            local safeCanInteract = nil
            if opt.canInteract then
                safeCanInteract = function(entity, distance, data)
                    local success, result = pcall(function()
                        -- qb-target may occasionally evaluate global options with an
                        -- invalid/culled handle; treat that as non-interactable.
                        if type(entity) ~= 'number' or entity <= 0 or not DoesEntityExist(entity) then
                            return false
                        end

                        -- Explicitly get coords to avoid table math errors
                        -- Ignoring 'data' argument from qb-target for coords
                        local coords = GetEntityCoords(entity)
                        local name = ""
                        if type(data) == 'table' then
                            name = data.name or data.label or ""
                        end
                        return opt.canInteract(entity, distance, coords, name)
                    end)

                    if not success then
                        local optName = opt.label or opt.name or 'unknown'
                        print("^1[ZLOMA ERROR] Entity Target CanInteract Crash [" .. tostring(optName) .. "]: " .. tostring(result) .. "^0")
                        return false
                    end
                    return result
                end
            end

            table.insert(qbOptions.options, {
                type = "client",   -- Required: Tell qb-target this is a client event
                event = eventName, -- Pass the generated event name
                icon = opt.icon or 'fas fa-hand',
                label = opt.label,
                canInteract = safeCanInteract
            })
        end

        -- qb-target requires non-empty options table
        if #qbOptions.options == 0 then
            print("^1[ZLOMA ERROR]^0 AddEntity - No target options provided for qb-target")
            return false
        end

        exports['qb-target']:AddTargetEntity(entity, qbOptions)
        success = true
        ZlomaCore.Debug(string.format("qb-target: Added entity target with %s options", #options))
    elseif TargetType == 'qtarget' then
        -- qtarget format (similar to qb-target)
        local qtOptions = {
            options = {},
            distance = options[1].distance or 2.5
        }

        for _, opt in ipairs(options) do
            local eventName = RegisterTargetEvent(opt.onSelect or opt.action)

            table.insert(qtOptions.options, {
                type = "client",
                event = eventName,
                icon = opt.icon or 'fas fa-hand',
                label = opt.label,
                canInteract = opt.canInteract
            })
        end

        exports['qtarget']:AddTargetEntity(entity, qtOptions)
        success = true
        ZlomaCore.Debug(string.format("qtarget: Added entity target with %s options", #options))
    end

    return success
end)

-- EXPORT: AddBoxZone(name, coords, options) - Add target box zone
-- name: Unique zone name
-- coords: vector3 coordinates
-- options: Table with size, heading, debugPoly, and target options
-- Returns: true if successful, false otherwise
exports('AddBoxZone', function(name, coords, options)
    if not name or not coords or not options then
        print("^1[ZLOMA ERROR]^0 AddBoxZone - Name, coords, and options are required")
        return false
    end

    if not TargetType then
        ZlomaCore.Warn("Target", "AddBoxZone")
        return false
    end

    local success = false

    if TargetType == 'ox_target' then
        -- ox_target zone format
        local oxOptions = {}
        for _, opt in ipairs(options.targetOptions or {}) do
            -- Pass canInteract directly - ox_target handles errors internally
            -- Avoiding pcall wrapper here prevents WaveShield anticheat conflicts
            table.insert(oxOptions, {
                name = opt.name,
                icon = opt.icon or 'fas fa-hand',
                label = opt.label,
                onSelect = opt.onSelect or opt.action,
                canInteract = opt.canInteract,
                distance = opt.distance or 2.5
            })
        end

        exports.ox_target:addBoxZone({
            name = name,
            coords = coords,
            size = options.size or vec3(2, 2, 2),
            rotation = options.heading or 0,
            debug = options.debugPoly or false,
            options = oxOptions
        })
        success = true
        ZlomaCore.Debug(string.format("ox_target: Added box zone '%s'", name))
    elseif TargetType == 'qb-target' then
        -- qb-target zone format
        local qbOptions = {
            name = name,
            debugPoly = options.debugPoly or false,
            minZ = coords.z - (options.size.z or 1),
            maxZ = coords.z + (options.size.z or 1),
        }

        local qbTargetOptions = {} -- Separate options array for qb-target zone
        for _, opt in ipairs(options.targetOptions or {}) do
            local eventName = RegisterTargetEvent(opt.onSelect or opt.action)

            local safeCanInteract = nil
            if opt.canInteract then
                safeCanInteract = function(entity, distance, data)
                    local ok, result = pcall(function()
                        local coords = nil
                        if type(entity) == 'number' and entity > 0 and DoesEntityExist(entity) then
                            coords = GetEntityCoords(entity)
                        end

                        local name = ""
                        if type(data) == 'table' then
                            name = data.name or data.label or ""
                        end

                        return opt.canInteract(entity, distance, coords, name)
                    end)

                    if not ok then
                        local optName = opt.label or opt.name or 'unknown'
                        print("^1[ZLOMA ERROR] Zone Target CanInteract Crash [" .. tostring(optName) .. "]: " .. tostring(result) .. "^0")
                        return false
                    end

                    return result
                end
            end

            table.insert(qbTargetOptions, {
                type = "client",
                event = eventName,
                icon = opt.icon or 'fas fa-hand',
                label = opt.label,
                canInteract = safeCanInteract
            })
        end

        -- qb-target requires non-empty options table
        if #qbTargetOptions == 0 then
            print("^1[ZLOMA ERROR]^0 AddBoxZone - No target options provided for qb-target")
            return nil
        end

        -- qb-target expects targetoptions as { options = {...}, distance = ... }
        local targetOptionsWrapper = {
            options = qbTargetOptions,
            distance = (options.targetOptions[1] and options.targetOptions[1].distance) or 2.5
        }

        exports['qb-target']:AddBoxZone(
            name,
            coords,
            options.size.x or 2,
            options.size.y or 2,
            {
                name = name,
                heading = options.heading or 0,
                debugPoly = options.debugPoly or false,
                minZ = qbOptions.minZ,
                maxZ = qbOptions.maxZ,
            },
            targetOptionsWrapper -- Pass wrapped options
        )
        success = true
        ZlomaCore.Debug(string.format("qb-target: Added box zone '%s'", name))
    elseif TargetType == 'qtarget' then
        -- qtarget zone format (similar to qb-target)
        local qtOptions = {
            name = name,
            debugPoly = options.debugPoly or false,
            minZ = coords.z - (options.size.z or 1),
            maxZ = coords.z + (options.size.z or 1),
        }

        local qtTargetOptions = {}
        for _, opt in ipairs(options.targetOptions or {}) do
            local eventName = RegisterTargetEvent(opt.onSelect or opt.action)
            table.insert(qtTargetOptions, {
                type = "client",
                event = eventName,
                icon = opt.icon or 'fas fa-hand',
                label = opt.label,
                canInteract = opt.canInteract
            })
        end

        exports['qtarget']:AddBoxZone(
            name,
            coords,
            options.size.x or 2,
            options.size.y or 2,
            {
                name = name,
                heading = options.heading or 0,
                debugPoly = options.debugPoly or false,
                minZ = qtOptions.minZ,
                maxZ = qtOptions.maxZ,
            },
            qtTargetOptions
        )
        success = true
        ZlomaCore.Debug(string.format("qtarget: Added box zone '%s'", name))
    end

    return success
end)

-- EXPORT: AddSphereZone(options) - Add target sphere zone (ox_target style)
-- options: Table with name, coords, radius, options, debug
-- Returns: zoneId if successful, nil otherwise
exports('AddSphereZone', function(options)
    if not options or not options.coords then
        print("^1[ZLOMA ERROR]^0 AddSphereZone - Options with coords required")
        return nil
    end

    -- Validate options.options exists and is a non-empty table
    if not options.options or type(options.options) ~= 'table' then
        print("^1[ZLOMA ERROR]^0 AddSphereZone - options.options must be a table, got: " .. type(options.options))
        return nil
    end
    
    if #options.options == 0 then
        print("^1[ZLOMA ERROR]^0 AddSphereZone - options.options is empty")
        return nil
    end

    if not TargetType then
        ZlomaCore.Warn("Target", "AddSphereZone")
        return nil
    end

    local name = options.name or ("sphere_" .. math.random(10000, 99999))

    if TargetType == 'ox_target' then
        -- ox_target accepts sphere zone directly
        local zoneId = exports.ox_target:addSphereZone(options)
        ZlomaCore.Debug(string.format("ox_target: Added sphere zone '%s'", name))
        return zoneId
    elseif TargetType == 'qb-target' or TargetType == 'qtarget' then
        -- Convert sphere to box for qb-target/qtarget
        local radius = options.radius or 1.0
        local targetExport = TargetType == 'qb-target' and exports['qb-target'] or exports['qtarget']

        -- Convert options with event registry
        local convertedOptions = {}
        if options.options then
            for _, opt in ipairs(options.options) do
                local eventName = RegisterTargetEvent(opt.onSelect or opt.action) -- Checking both as Wrapper uses 'onSelect' for ox mappings sometimes

                local safeCanInteract = nil
                if opt.canInteract then
                    safeCanInteract = function(entity, distance, data)
                        local ok, result = pcall(function()
                            local coords = nil
                            if type(entity) == 'number' and entity > 0 and DoesEntityExist(entity) then
                                coords = GetEntityCoords(entity)
                            end

                            local name = ""
                            if type(data) == 'table' then
                                name = data.name or data.label or ""
                            end

                            return opt.canInteract(entity, distance, coords, name)
                        end)

                        if not ok then
                            local optName = opt.label or opt.name or 'unknown'
                            print("^1[ZLOMA ERROR] Zone Target CanInteract Crash [" .. tostring(optName) .. "]: " .. tostring(result) .. "^0")
                            return false
                        end

                        return result
                    end
                end

                table.insert(convertedOptions, {
                    type = "client",
                    event = eventName,
                    icon = opt.icon or 'fas fa-dot-circle',
                    label = opt.label,
                    canInteract = safeCanInteract
                })
            end
        end

        -- qb-target/qtarget requires non-empty options table
        if #convertedOptions == 0 then
            print("^1[ZLOMA ERROR]^0 AddSphereZone - No target options provided for " .. TargetType)
            return nil
        end

        -- qb-target expects targetoptions as { options = {...}, distance = ... }
        local targetOptions = {
            options = convertedOptions,
            distance = (options.options[1] and options.options[1].distance) or 2.5
        }

        targetExport:AddCircleZone(
            name,
            options.coords,
            radius,
            {
                name = name,
                debugPoly = options.debug or false,
                useZ = true
            },
            targetOptions
        )
        ZlomaCore.Debug(string.format("%s: Added circle zone '%s'", TargetType, name))
        return name
    end

    return nil
end)

-- EXPORT: RemoveEntity(entity, optionNames) - Remove target options from entity
-- entity: Entity handle
-- optionNames: String or table of option names to remove
-- Returns: true if successful, false otherwise
exports('RemoveEntity', function(entity, optionNames)
    if not entity then
        print("^1[ZLOMA ERROR]^0 RemoveEntity - Entity is required")
        return false
    end

    if not TargetType then
        ZlomaCore.Warn("Target", "RemoveEntity")
        return false
    end

    -- Normalize optionNames to table
    if type(optionNames) == 'string' then
        optionNames = { optionNames }
    end

    local success = false

    if TargetType == 'ox_target' then
        if exports.ox_target then
            exports.ox_target:removeLocalEntity(entity, optionNames)
            success = true
            ZlomaCore.Debug(string.format("ox_target: Removed entity target options: %s", table.concat(optionNames or {}, ', ')))
        end
    elseif TargetType == 'qb-target' then
        -- qb-target: RemoveTargetEntity removes all options from entity
        exports['qb-target']:RemoveTargetEntity(entity)
        success = true
        ZlomaCore.Debug("qb-target: Removed entity target")
    elseif TargetType == 'qtarget' then
        exports['qtarget']:RemoveTargetEntity(entity)
        success = true
        ZlomaCore.Debug("qtarget: Removed entity target")
    end

    return success
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    CleanupGlobalVehicleTargets()

    -- Cleanup all dynamically registered events (MEMORY LEAK FIX)
    CleanupAllTargetEvents()

    if TargetType == 'qb-target' then
        if #GlobalTargetLabels > 0 then
            -- Remove global vehicle options (Type 2)
            exports['qb-target']:RemoveGlobalType(2, GlobalTargetLabels)
            print(string.format("^3[ZLOMA CLEANUP]^0 Removed %d qb-target global options", #GlobalTargetLabels))
        end
    end
end)

-- EXPORT: AddGlobalVehicle(options) - Add target to all vehicles
-- options: Table of target options
-- Returns: true if successful, false otherwise
exports('AddGlobalVehicle', function(options)
    if not options then
        print("^1[ZLOMA ERROR]^0 AddGlobalVehicle - Options are required")
        return false
    end

    if not TargetType then
        ZlomaCore.Warn("Target", "AddGlobalVehicle")
        return false
    end

    local success = false

    if TargetType == 'ox_target' then
        -- ox_target global vehicle
        local oxOptions = {}
        for _, opt in ipairs(options) do
            table.insert(oxOptions, {
                name = opt.name,
                icon = opt.icon or 'fas fa-car',
                label = opt.label,
                onSelect = opt.onSelect or opt.action,
                canInteract = opt.canInteract,
                distance = opt.distance or 2.5,
                bones = opt.bones
            })
        end

        exports.ox_target:addGlobalVehicle(oxOptions)
        success = true
        ZlomaCore.Debug("ox_target: Added global vehicle target")
    elseif TargetType == 'qb-target' then
        CleanupGlobalVehicleTargets()

        -- qb-target global vehicle
        local qbOptions = {}

        for _, opt in ipairs(options) do
            -- support event, onSelect, or action keys
            local actionOrEvent = opt.event or opt.onSelect or opt.action
            local eventName = RegisterTargetEvent(actionOrEvent)
            if eventName and type(eventName) == 'string' and eventName:find('^zloma_core:target:') then
                table.insert(globalVehicleEventNames, eventName)
            end

            -- Wrap canInteract to prevent crashes and adapt arguments
            -- qb-target passes (entity, distance, data)
            -- We adapt this to (entity, distance, coords, name, bone)
            local safeCanInteract = nil
            if opt.canInteract then
                safeCanInteract = function(entity, distance, data)
                    local success, result = pcall(function()
                        -- qb-target may occasionally evaluate global options with an
                        -- invalid/culled handle; treat that as non-interactable.
                        if type(entity) ~= 'number' or entity <= 0 or not DoesEntityExist(entity) then
                            return false
                        end

                        -- Explicitly get coords to avoid table math errors
                        -- Ignoring 'data' argument from qb-target for coords
                        local coords = GetEntityCoords(entity)
                        local name = ""
                        if type(data) == 'table' then
                            name = data.name or data.label or ""
                        end
                        return opt.canInteract(entity, distance, coords, name)
                    end)

                    if not success then
                        local optName = opt.label or opt.name or 'unknown'
                        print("^1[ZLOMA ERROR] Target CanInteract Crash [" .. tostring(optName) .. "]: " .. tostring(result) .. "^0")
                        return false
                    end
                    return result
                end
            end

            -- Track label for cleanup
            if opt.label then
                table.insert(GlobalTargetLabels, opt.label)
            end

            table.insert(qbOptions, {
                type = "client",
                event = eventName,
                icon = opt.icon or 'fas fa-car',
                label = opt.label,
                canInteract = safeCanInteract,
                bones = opt.bones
            })
        end

        if #qbOptions > 0 then
            -- Wrap in table for qb-target compatibility
            local globalOptions = {
                options = qbOptions,
                distance = (options[1] and options[1].distance) or 2.5
            }

            -- Always use colon notation for consistent behavior with qb-target
            exports['qb-target']:AddGlobalVehicle(globalOptions)

            success = true
            ZlomaCore.Debug("qb-target: Added global vehicle target")
        else
            ZlomaCore.Debug("qb-target: No options generated for AddGlobalVehicle")
        end
    elseif TargetType == 'qtarget' then
        CleanupGlobalVehicleTargets()

        -- qtarget global vehicle
        local qtOptions = {}
        for _, opt in ipairs(options) do
            local eventName = RegisterTargetEvent(opt.onSelect or opt.action)
            if eventName and type(eventName) == 'string' and eventName:find('^zloma_core:target:') then
                table.insert(globalVehicleEventNames, eventName)
            end
            table.insert(qtOptions, {
                type = "client",
                event = eventName,
                icon = opt.icon or 'fas fa-car',
                label = opt.label,
                canInteract = opt.canInteract,
                bones = opt.bones
            })
        end

        exports['qtarget']:AddGlobalVehicle(qtOptions)
        success = true
        ZlomaCore.Debug("qtarget: Added global vehicle target")
    end

    return success
end)

-- EXPORT: RemoveZone(name) - Remove target zone
-- name: Zone name to remove
-- Returns: true if successful, false otherwise
exports('RemoveZone', function(name)
    if not name then
        print("^1[ZLOMA ERROR]^0 RemoveZone - Name is required")
        return false
    end

    if not TargetType then
        ZlomaCore.Warn("Target", "RemoveZone")
        return false
    end

    local success = false

    if TargetType == 'ox_target' then
        exports.ox_target:removeZone(name)
        success = true
        ZlomaCore.Debug(string.format("ox_target: Removed zone '%s'", name))
    elseif TargetType == 'qb-target' then
        exports['qb-target']:RemoveZone(name)
        success = true
        ZlomaCore.Debug(string.format("qb-target: Removed zone '%s'", name))
    elseif TargetType == 'qtarget' then
        exports['qtarget']:RemoveZone(name)
        success = true
        ZlomaCore.Debug(string.format("qtarget: Removed zone '%s'", name))
    end

    return success
end)

