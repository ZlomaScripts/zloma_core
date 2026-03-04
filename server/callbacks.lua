-- ZLOMA CORE - Server Callbacks
-- Lightweight callback system for server-client communication
-- Migrated essential functionality from kimi_callbacks

local callbacks = {}
local callbackResponses = {}
local currentRequestId = math.mininteger

-- Error messages
local CC_TIMEOUT = "ClientCallback \"%s\" timed out after %sms!"
local CC_DOES_NOT_EXIST = "ClientCallback \"%s\" does not exist!"
local SC_DOES_NOT_EXIST = "ServerCallback \"%s\" does not exist!"

-- Utility: log error
local function LogError(text, ...)
    print(("^1[ZLOMA CORE ERROR]^0 " .. text):format(...))
end

-- Register a server callback
---@param name string Callback name
---@param callback function Callback function(source, ...)
function ZlomaCore.RegisterCallback(name, callback)
    assert(name and type(name) == "string", "Callback name must be a string!")
    assert(callback and type(callback) == "function", "Callback must be a function!")
    callbacks[name] = callback
end

-- Remove a server callback
---@param name string Callback name
function ZlomaCore.RemoveCallback(name)
    callbacks[name] = nil
end

-- Trigger a client callback with timeout
---@param name string Callback name
---@param playerId number Player server ID
---@param timeout number Timeout in milliseconds
---@vararg any Arguments to pass
---@return any Callback result
function ZlomaCore.TriggerClientCallback(name, playerId, timeout, ...)
    assert(name and type(name) == "string", "Callback name must be a string!")
    assert(playerId and type(playerId) == "number", "Player ID must be a number!")
    timeout = timeout or 5000

    local requestId = currentRequestId
    currentRequestId = currentRequestId + 1
    if currentRequestId >= math.maxinteger then
        currentRequestId = math.mininteger
    end

    TriggerClientEvent("ZlomaCore:cc", playerId, name, requestId, { ... })

    local requestName = name .. tostring(requestId)
    callbackResponses[requestName] = true

    local endTime = GetGameTimer() + timeout
    while callbackResponses[requestName] == true do
        Wait(50) -- Optimized: 50ms instead of 0ms to reduce CPU load
        if GetGameTimer() > endTime then
            callbackResponses[requestName] = "ERROR"
            LogError(CC_TIMEOUT, name, timeout)
            break
        end
    end

    if callbackResponses[requestName] == "ERROR" then
        callbackResponses[requestName] = nil
        return nil
    end

    local data = callbackResponses[requestName]
    callbackResponses[requestName] = nil
    return table.unpack(data)
end

-- Execute server callback (from client)
RegisterNetEvent("ZlomaCore:sc", function(name, requestId, data)
    local src = source

    if not callbacks[name] then
        LogError(SC_DOES_NOT_EXIST, name)
        TriggerClientEvent("ZlomaCore:scError", src, name, requestId)
        return
    end

    local returnData = table.pack(pcall(callbacks[name], src, table.unpack(data)))
    if not returnData[1] then
        LogError("ServerCallback \"%s\" error: %s", name, returnData[2])
        TriggerClientEvent("ZlomaCore:scError", src, name, requestId, returnData[2])
        return
    end

    table.remove(returnData, 1)
    TriggerClientEvent("ZlomaCore:scResponse", src, name .. tostring(requestId), returnData)
end)

-- Receive client callback response
RegisterNetEvent("ZlomaCore:ccResponse", function(requestName, data)
    if callbackResponses[requestName] == nil then return end
    callbackResponses[requestName] = data
end)

-- Client callback error
RegisterNetEvent("ZlomaCore:ccError", function(name, requestId)
    local requestName = name .. tostring(requestId)
    if callbackResponses[requestName] == nil then return end
    callbackResponses[requestName] = "ERROR"
    LogError(CC_DOES_NOT_EXIST, name)
end)

-- ============================================================================
-- OX_LIB CALLBACKS (for compatibility with resources using ox_lib)
-- ============================================================================

-- Check if ox_lib is available
if lib and lib.callback then
    -- Get player job callback (used by zloma_garages police impound)
    lib.callback.register('zloma_core:getPlayerJob', function(source)
        local job = exports['zloma_core']:GetPlayerJob(source)
        return job
    end)
end

-- Exports for external use
exports("RegisterCallback", ZlomaCore.RegisterCallback)
exports("RemoveCallback", ZlomaCore.RemoveCallback)
exports("TriggerClientCallback", ZlomaCore.TriggerClientCallback)
