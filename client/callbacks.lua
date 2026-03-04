-- ZLOMA CORE - Client Callbacks
-- Lightweight callback system for server-client communication

local callbacks = {}
local callbackResponses = {}
local currentRequestId = math.mininteger

-- Error messages
local SC_TIMEOUT = "ServerCallback \"%s\" timed out after %sms!"
local SC_DOES_NOT_EXIST = "ServerCallback \"%s\" does not exist!"
local CC_DOES_NOT_EXIST = "ClientCallback \"%s\" does not exist!"

-- Utility: log error
local function LogError(text, ...)
    print(("^1[ZLOMA CORE ERROR]^0 " .. text):format(...))
end

-- Register a client callback
---@param name string Callback name
---@param callback function Callback function(...)
function ZlomaCore.RegisterClientCallback(name, callback)
    assert(name and type(name) == "string", "Callback name must be a string!")
    assert(callback and type(callback) == "function", "Callback must be a function!")
    callbacks[name] = callback
end

-- Remove a client callback
---@param name string Callback name
function ZlomaCore.RemoveClientCallback(name)
    callbacks[name] = nil
end

-- Trigger a server callback with timeout
---@param name string Callback name
---@param timeout number|nil Timeout in milliseconds (default 5000)
---@vararg any Arguments to pass
---@return any Callback result
function ZlomaCore.TriggerServerCallback(name, timeout, ...)
    assert(name and type(name) == "string", "Callback name must be a string!")
    timeout = timeout or 5000

    local requestId = currentRequestId
    currentRequestId = currentRequestId + 1
    if currentRequestId >= math.maxinteger then
        currentRequestId = math.mininteger
    end

    TriggerServerEvent("ZlomaCore:sc", name, requestId, { ... })

    local requestName = name .. tostring(requestId)
    callbackResponses[requestName] = true

    local endTime = GetGameTimer() + timeout
    while callbackResponses[requestName] == true do
        Wait(50) -- Optimized: 50ms instead of 0ms to reduce CPU load
        if GetGameTimer() > endTime then
            callbackResponses[requestName] = "ERROR"
            LogError(SC_TIMEOUT, name, timeout)
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

-- Execute client callback (from server)
RegisterNetEvent("ZlomaCore:cc", function(name, requestId, data)
    if not callbacks[name] then
        LogError(CC_DOES_NOT_EXIST, name)
        TriggerServerEvent("ZlomaCore:ccError", name, requestId)
        return
    end

    local returnData = table.pack(pcall(callbacks[name], table.unpack(data)))
    if not returnData[1] then
        LogError("ClientCallback \"%s\" error: %s", name, returnData[2])
        TriggerServerEvent("ZlomaCore:ccError", name, requestId)
        return
    end

    table.remove(returnData, 1)
    TriggerServerEvent("ZlomaCore:ccResponse", name .. tostring(requestId), returnData)
end)

-- Receive server callback response
RegisterNetEvent("ZlomaCore:scResponse", function(requestName, data)
    if callbackResponses[requestName] == nil then return end
    callbackResponses[requestName] = data
end)

-- Server callback error
RegisterNetEvent("ZlomaCore:scError", function(name, requestId, errorMsg)
    local requestName = name .. tostring(requestId)
    if callbackResponses[requestName] == nil then return end
    callbackResponses[requestName] = "ERROR"
    if errorMsg then
        LogError("ServerCallback \"%s\" error: %s", name, errorMsg)
    else
        LogError(SC_DOES_NOT_EXIST, name)
    end
end)

-- Exports for external use
exports("RegisterClientCallback", ZlomaCore.RegisterClientCallback)
exports("RemoveClientCallback", ZlomaCore.RemoveClientCallback)
exports("TriggerServerCallback", ZlomaCore.TriggerServerCallback)
