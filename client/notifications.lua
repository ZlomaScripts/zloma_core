-- ZLOMA CORE - Client Notification Wrapper
-- Unified interface for ESX, esx_notify, QBCore, ox_lib, mythic, t-notify, okok,
-- wasabi_notify, fl-notify, brutal_notify, is_ui, lation_ui, g-notifications, vms_notifyv2, wasabi_uikit
-- Customer-friendly: Works with any notification system, beautiful fallback UI

local NotificationType = nil

-- Initialize notification detection
CreateThread(function()
    Wait(ZlomaCore.Config.Timeouts.DetectionWait or 200) -- Wait for init.lua to finish detection
    NotificationType = ZlomaCore.Cache.Notification
    
    if NotificationType then
        ZlomaCore.Debug(string.format("Notification system loaded: %s", NotificationType))
    else
        print("^3[ZLOMA WARNING]^0 No notification system detected. Using built-in fallback.")
        NotificationType = 'builtin' -- Fallback to built-in GTA notifications
    end
end)

-- ============================================================================
-- ADD NEW NOTIFICATION SUPPORT HERE
-- ============================================================================
-- To add support for a new notification system:
-- 1. Add detection in shared/config.lua -> ZlomaCore.DetectNotification()
-- 2. Add the notification name to ZlomaCore.Config.Manual.Notification options
-- 3. Add elseif block in Notify() below
--
-- Template:
-- elseif NotificationType == 'your-notify' then
--     exports['your-notify']:Notify(msg, notifyType, duration)
-- ============================================================================

-- EXPORT: Notify(msg, type, duration) OR Notify({title, description, type, duration})
-- Universal notification function supporting both formats:
-- Format 1 (legacy): msg (string), type (string), duration (number)
-- Format 2 (ox_lib): {title, description, type, duration} (table)
-- Returns: nil
exports('Notify', function(msg, notifyType, duration)
    -- Check if first parameter is a table (ox_lib format)
    if type(msg) == 'table' then
        local options = msg
        msg = options.description or options.message or options.text
        notifyType = options.type or 'info'
        duration = options.duration or 5000
        
        -- If ox_lib format and ox_lib is available, pass directly
        if NotificationType == 'ox_lib' then
            exports['ox_lib']:notify(options)
            return
        end
    end
    
    if not msg then
        print("^1[ZLOMA ERROR]^0 Notify - Message is required")
        return
    end

    notifyType = notifyType or 'info'
    duration = duration or 5000

    if NotificationType == 'ox_lib' then
        exports['ox_lib']:notify({
            title = notifyType:upper(),
            description = msg,
            type = notifyType,
            duration = duration
        })
    
    -- NEW: wasabi_notify support
    elseif NotificationType == 'wasabi_notify' then
        -- wasabi_notify uses: notify(title, msg, duration, type)
        -- type can be: 'success', 'error', 'warning', 'info'
        local wasabiType = notifyType
        if notifyType == 'inform' then wasabiType = 'info' end
        exports.wasabi_notify:notify(wasabiType:upper(), msg, duration, wasabiType)
    
    -- NEW: fl-notify support
    elseif NotificationType == 'fl-notify' then
        -- fl-notify uses: Notify(title, subtitle, content, duration, type, position)
        local flType = notifyType
        if notifyType == 'info' then flType = 'inform' end
        exports['fl-notify']:Notify(notifyType:upper(), '', msg, duration, flType, 'top-right')
        
    elseif NotificationType == 'mythic' then
        local mythicType = notifyType
        if notifyType == 'error' then mythicType = 'error' end
        if notifyType == 'success' then mythicType = 'success' end
        if notifyType == 'info' then mythicType = 'inform' end
        if notifyType == 'warning' then mythicType = 'warning' end -- Fixed: was 'error'
        
        exports['mythic_notify']:DoHudText(mythicType, msg)
        
    elseif NotificationType == 't-notify' then
        local tnotifyType = notifyType
        if notifyType == 'error' then tnotifyType = 'error' end
        if notifyType == 'success' then tnotifyType = 'success' end
        if notifyType == 'info' then tnotifyType = 'info' end
        if notifyType == 'warning' then tnotifyType = 'warning' end
        
        exports['t-notify']:Custom({
            style = tnotifyType,
            message = msg,
            duration = duration
        })
        
    elseif NotificationType == 'okok' then
        exports['okokNotify']:Alert('NOTIFICATION', msg, duration, notifyType)
        
    elseif NotificationType == 'QBCore' then
        local qbType = 'primary'
        if notifyType == 'error' then qbType = 'error' end
        if notifyType == 'success' then qbType = 'success' end
        if notifyType == 'info' then qbType = 'primary' end
        if notifyType == 'warning' then qbType = 'warning' end
        
        TriggerEvent('QBCore:Notify', msg, qbType, duration)
        
    elseif NotificationType == 'esx_notify' then
        local esxNotifyType = 'info'
        if notifyType == 'error' then esxNotifyType = 'error' end
        if notifyType == 'success' then esxNotifyType = 'success' end
        if notifyType == 'info' then esxNotifyType = 'info' end
        if notifyType == 'warning' then esxNotifyType = 'warning' end
        
        exports['esx_notify']:Notify(esxNotifyType, duration, msg)
        
    elseif NotificationType == 'ESX' then
        local esxType = 'info'
        if notifyType == 'error' then esxType = 'error' end
        if notifyType == 'success' then esxType = 'success' end
        if notifyType == 'info' then esxType = 'info' end
        if notifyType == 'warning' then esxType = 'warning' end
        
        TriggerEvent('esx:showNotification', msg, esxType, duration)
    
    elseif NotificationType == 'brutal_notify' then
        exports['brutal_notify']:SendAlert('Notification', msg, duration, notifyType)
    
    elseif NotificationType == 'is_ui' then
        exports['is_ui']:Notify(msg, nil, duration, notifyType)
    
    elseif NotificationType == 'lation_ui' then
        local lationType = notifyType
        if notifyType == 'info' then lationType = 'inform' end
        exports.lation_ui:notify({
            message = msg,
            type = lationType
        })
    
    elseif NotificationType == 'g-notifications' then
        local gType = notifyType
        if notifyType == 'inform' then gType = 'info' end
        exports['g-notifications']:Notify({
            title = 'Notification',
            description = msg,
            type = gType or 'info'
        })
    
    elseif NotificationType == 'vms_notifyv2' then
        exports['vms_notifyv2']:Notification({
            description = msg
        })
    
    elseif NotificationType == 'wasabi_uikit' then
        local uikitType = notifyType
        if notifyType == 'inform' then uikitType = 'info' end
        exports.wasabi_uikit:Notification({
            title = msg,
            type = uikitType
        })
    
    else
        -- Fallback: Built-in GTA notification (always works)
        SetNotificationTextEntry('STRING')
        AddTextComponentString(msg)
        DrawNotification(false, true)
    end

    ZlomaCore.Debug(string.format("Notification sent: [%s] %s", notifyType, msg))
end)

-- Alternative: Advanced notification with title support (optional)
exports('NotifyAdvanced', function(title, msg, notifyType, duration)
    if not msg then
        print("^1[ZLOMA ERROR]^0 NotifyAdvanced - Message is required")
        return
    end

    notifyType = notifyType or 'info'
    title = title or notifyType:upper()
    duration = duration or 5000

    if NotificationType == 'ox_lib' then
        exports['ox_lib']:notify({
            title = title,
            description = msg,
            type = notifyType,
            duration = duration
        })
    else
        -- Fallback to regular notify with combined message
        local combined = string.format("^3%s^0\n%s", title, msg)
        exports['zloma_core']:Notify(combined, notifyType, duration)
    end
end)

-- Client event for server-triggered notifications
RegisterNetEvent('zloma_core:client:notify', function(msg, type, duration)
    exports['zloma_core']:Notify(msg, type, duration)
end)

RegisterNetEvent('zloma_core:client:notifyAdvanced', function(title, msg, type, duration)
    exports['zloma_core']:NotifyAdvanced(title, msg, type, duration)
end)

-- Event handler for server-triggered notifications
RegisterNetEvent('zloma_core:notify')
AddEventHandler('zloma_core:notify', function(data)
    if not data then return end
    
    -- Call the Notify export with the data
    exports['zloma_core']:Notify(data)
end)
