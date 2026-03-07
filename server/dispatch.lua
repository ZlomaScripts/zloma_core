-- ZLOMA CORE - Server Dispatch Wrapper
-- Unified interface for supported police dispatch systems

local function NormalizeDispatchJobs(job)
    if type(job) == 'table' and #job > 0 then
        return job
    end

    if type(job) == 'string' and job ~= '' then
        return { job }
    end

    return { 'police' }
end

local function GetDispatchCoords(source, coords)
    if coords then
        return coords
    end

    local playerPed = GetPlayerPed(source)
    if playerPed and playerPed > 0 then
        return GetEntityCoords(playerPed)
    end

    return vec3(0.0, 0.0, 0.0)
end

local function GetDispatchStreet(coords)
    local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    if streetHash and streetHash ~= 0 then
        return GetStreetNameFromHashKey(streetHash)
    end

    return ''
end

local function GetDispatchSystem()
    local dispatch = ZlomaCore.Cache.Dispatch

    if dispatch and GetResourceState(dispatch) == 'started' then
        return dispatch
    end

    dispatch = ZlomaCore.DetectDispatch()
    ZlomaCore.Cache.Dispatch = dispatch
    return dispatch
end

local function SendPsDispatchAlert(coords, jobs, data)
    TriggerEvent('ps-dispatch:server:notify', {
        message = data.title,
        codeName = 'NONE',
        code = data.code,
        icon = data.icon or 'fa-solid fa-bell',
        priority = data.priority == 'high' and 1 or 2,
        coords = vector3(coords.x, coords.y, coords.z),
        alertTime = data.time,
        alert = {
            radius = 0,
            sprite = data.blip.sprite,
            scale = data.blip.scale,
            color = data.blip.color,
            flash = data.priority == 'high',
        },
        jobs = jobs
    })
end

local function SendCdDispatchAlert(coords, jobs, data)
    TriggerClientEvent('cd_dispatch:AddNotification', -1, {
        job_table = jobs,
        coords = vec3(coords.x, coords.y, coords.z),
        title = data.code,
        message = data.title,
        unique_id = tostring(math.random(1000000, 9999999)),
        sound = 1,
        blip = {
            sprite = data.blip.sprite,
            scale = data.blip.scale,
            colour = data.blip.color,
            flashes = data.priority == 'high',
            text = ('%s - %s'):format(data.code, data.title),
            time = data.time,
            radius = 0,
        }
    })
end

local function SendQsDispatchAlert(coords, jobs, data)
    TriggerEvent('qs-dispatch:server:CreateDispatchCall', {
        job = jobs,
        callLocation = vector3(coords.x, coords.y, coords.z),
        callCode = { code = data.code, snippet = data.code },
        message = data.title,
        flashes = data.priority == 'high',
        blip = {
            sprite = data.blip.sprite,
            scale = data.blip.scale,
            colour = data.blip.color,
            flashes = data.priority == 'high',
            text = data.title,
            time = data.time * 60 * 1000,
        }
    })
end

local function SendTkDispatchAlert(coords, jobs, data)
    exports['tk_dispatch']:addCall({
        title = data.title,
        code = data.code,
        priority = data.priority or 'normal',
        coords = vector3(coords.x, coords.y, coords.z),
        showTime = data.notify,
        jobs = jobs,
        blip = {
            sprite = data.blip.sprite,
            scale = data.blip.scale,
            color = data.blip.color,
            flash = data.priority == 'high',
            shortRange = true
        }
    })
end

local function SendRcoreDispatchAlert(coords, jobs, data)
    TriggerEvent('rcore_dispatch:server:sendAlert', {
        code = data.code,
        default_priority = data.priority or 'normal',
        coords = vec3(coords.x, coords.y, coords.z),
        job = jobs,
        text = data.title,
        type = 'alerts',
        blip_time = data.time,
        blip = {
            sprite = data.blip.sprite,
            scale = data.blip.scale,
            colour = data.blip.color,
            text = data.title,
        }
    })
end

local function SendLbTabletAlert(coords, jobs, data)
    local priority = data.priority or 'low'
    if priority == 'normal' then priority = 'low' end
    if priority == 'risk' then priority = 'high' end
    if priority ~= 'low' and priority ~= 'medium' and priority ~= 'high' then
        priority = 'low'
    end

    exports['lb-tablet']:AddDispatch({
        priority = priority,
        code = data.code,
        title = data.title,
        description = data.description,
        location = { label = data.street, coords = vec2(coords.x, coords.y) },
        time = data.time * 60,
        job = jobs[1] or 'police',
        blip = {
            sprite = data.blip.sprite,
            size = data.blip.scale,
            color = data.blip.color,
            shortRange = true,
            label = data.title,
        }
    })
end

local function SendKartikDispatchAlert(coords, jobs, data)
    local alertJobs = {}
    for _, jobName in ipairs(jobs) do
        alertJobs[jobName] = true
    end

    TriggerEvent('kartik-mdt:server:sendDispatchNotification', {
        title = data.title,
        code = data.code,
        description = data.description,
        sound = 'dispatch',
        x = coords.x,
        y = coords.y,
        z = coords.z,
        type = 'Alert',
        blip = {
            sprite = data.blip.sprite,
            color = data.blip.color,
            scale = data.blip.scale,
            length = data.time
        },
        jobs = alertJobs
    })
end

local function SendPiotreqDispatchAlert(source, data)
    exports['piotreq_gpt']:SendAlert(source, {
        title = data.title,
        code = data.code,
        icon = data.icon or 'fa-solid fa-bell',
        info = {
            { icon = 'fa-solid fa-road', isStreet = true },
        },
        blip = {
            scale = data.blip.scale,
            sprite = data.blip.sprite,
            category = data.blip.category,
            color = data.blip.color,
            hidden = data.blip.hidden,
            priority = data.blip.priority,
            short = data.blip.short,
            alpha = data.blip.alpha,
            name = data.blip.name
        },
        type = data.priority == 'high' and 'risk' or 'normal',
        canAnswer = data.code == '911',
        maxOfficers = data.maxOfficers,
        time = data.time,
        notifyTime = data.notify,
    })
end

local function SendOrigenDispatchAlert(coords, data)
    exports['origen_police']:SendAlert({
        coords = vec3(coords.x, coords.y, coords.z),
        title = data.title,
        type = 'GENERAL',
        message = data.code,
        job = 'police',
    })
end

local function BuildDispatchPayload(source, data)
    local coords = GetDispatchCoords(source, data.coords)
    local jobs = NormalizeDispatchJobs(data.job)
    local payload = {
        title = data.title or 'Dispatch Alert',
        code = data.code or '10-00',
        icon = data.icon or 'fa-solid fa-bell',
        priority = data.priority or 'medium',
        maxOfficers = data.maxOfficers or 4,
        time = data.time or 10,
        notify = data.notify or 5000,
        street = data.street or GetDispatchStreet(coords),
        description = data.description or ((data.code or '10-00') .. ' - ' .. (data.title or 'Dispatch Alert')),
        blip = {
            scale = data.blip and data.blip.scale or 1.2,
            sprite = data.blip and data.blip.sprite or 225,
            category = data.blip and data.blip.category or 1,
            color = data.blip and data.blip.color or 1,
            hidden = data.blip and data.blip.hidden or false,
            priority = data.blip and data.blip.priority or 5,
            short = data.blip and data.blip.short or true,
            alpha = data.blip and data.blip.alpha or 200,
            name = data.blip and data.blip.name or (data.title or 'Dispatch Alert')
        }
    }

    return coords, jobs, payload
end

local function SendDispatchAlert(source, data)
    local dispatch = GetDispatchSystem()
    if not dispatch then
        ZlomaCore.Warn('Dispatch', 'SendDispatchAlert')
        return false
    end

    if not source or type(source) ~= 'number' then
        print('^1[ZLOMA ERROR]^0 SendDispatchAlert requires a valid player source')
        return false
    end

    data = data or {}
    local coords, jobs, payload = BuildDispatchPayload(source, data)

    if dispatch == 'ps-dispatch' then
        SendPsDispatchAlert(coords, jobs, payload)
    elseif dispatch == 'cd_dispatch' or dispatch == 'cd_dispatch3d' then
        SendCdDispatchAlert(coords, jobs, payload)
    elseif dispatch == 'qs-dispatch' then
        SendQsDispatchAlert(coords, jobs, payload)
    elseif dispatch == 'tk_dispatch' then
        SendTkDispatchAlert(coords, jobs, payload)
    elseif dispatch == 'rcore_dispatch' then
        SendRcoreDispatchAlert(coords, jobs, payload)
    elseif dispatch == 'lb-tablet' then
        SendLbTabletAlert(coords, jobs, payload)
    elseif dispatch == 'kartik-mdt' then
        SendKartikDispatchAlert(coords, jobs, payload)
    elseif dispatch == 'piotreq_gpt' then
        SendPiotreqDispatchAlert(source, payload)
    elseif dispatch == 'origen_police' then
        SendOrigenDispatchAlert(coords, payload)
    else
        ZlomaCore.Warn('Dispatch', dispatch)
        return false
    end

    ZlomaCore.Debug(string.format('Dispatch sent via %s: %s', dispatch, payload.title))
    return true
end

exports('GetDispatchSystem', GetDispatchSystem)
exports('SendDispatchAlert', SendDispatchAlert)
