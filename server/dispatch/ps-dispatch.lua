ZlomaCore.DispatchAdapters['ps-dispatch'] = function(_, coords, jobs, data)
    TriggerEvent('ps-dispatch:server:notify', {
        message = data.description or data.title,
        -- Must match an entry in ps-dispatch Config.Dispatch.
        codeName = data.psCodeName,
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
