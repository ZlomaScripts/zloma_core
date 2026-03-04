-- ZLOMA CORE - Server Billing Wrapper
-- Unified interface for okokBilling, okok_billing, esx_billing, qb-billing
-- Customer-friendly: Multi-system support with intelligent fallbacks

local BillingType = nil

-- Initialize billing detection
CreateThread(function()
    Wait(ZlomaCore.Config.Timeouts.InitWait or 500) -- Wait for config initialization
    BillingType = ZlomaCore.Cache.Billing
    
    if BillingType then
        ZlomaCore.Debug(string.format("Billing system loaded: %s", BillingType))
    else
        print("^3[ZLOMA WARNING]^0 No billing system detected. Billing functions will not work.")
    end
end)

-- ============================================================================
-- ADD NEW BILLING SUPPORT HERE
-- ============================================================================
-- To add support for a new billing system:
-- 1. Add detection in shared/config.lua -> ZlomaCore.DetectBilling()
-- 2. Add the billing name to ZlomaCore.Config.Manual.Billing options
-- 3. Add elseif blocks in SendBill() and GetBills() below
--
-- Template:
-- elseif BillingType == 'your-billing' then
--     TriggerEvent('your-billing:sendBill', source, target, amount, reason)
--     success = true
-- ============================================================================

-- EXPORT: SendBill(source, target, amount, reason, society) - Send invoice to player
-- source: Player sending the bill (invoicer)
-- target: Player receiving the bill (recipient)
-- amount: Bill amount
-- reason: Bill description
-- society: Society/job name (optional, for some systems)
-- Returns: true if successful, false otherwise
exports('SendBill', function(source, target, amount, reason, society)
    if not BillingType then
        ZlomaCore.Warn("Billing", "SendBill")
        return false
    end

    -- Validate inputs
    if not source or not target or not amount or not reason then
        print("^1[ZLOMA ERROR]^0 SendBill - Missing required parameters")
        return false
    end

    local success = false

    if BillingType == 'okokBilling' or BillingType == 'okok_billing' then
        -- okokBilling format
        TriggerEvent('okokBilling:CreateInvoice', source, target, amount, reason, society or 'unknown')
        success = true
        ZlomaCore.Debug(string.format("okokBilling: Sent $%s bill from %s to %s (Reason: %s)", amount, source, target, reason))
        
    elseif BillingType == 'esx_billing' then
        -- ESX Billing format
        local senderName = GetPlayerName(source)
        TriggerEvent('esx_billing:sendBill', target, society or 'mechanic', senderName, amount)
        success = true
        ZlomaCore.Debug(string.format("esx_billing: Sent $%s bill from %s to %s (Society: %s)", amount, source, target, society))
        
    elseif BillingType == 'qb-billing' then
        -- QB Billing format
        local senderName = GetPlayerName(source)
        TriggerEvent('qb-billing:server:sendBill', target, amount, reason, senderName)
        success = true
        ZlomaCore.Debug(string.format("qb-billing: Sent $%s bill from %s to %s (Reason: %s)", amount, source, target, reason))
    end

    return success
end)

-- EXPORT: GetBills(source) - Get all unpaid bills for player
-- Returns: Array of bills or empty table
-- Note: This function has limited support as not all billing systems provide this
exports('GetBills', function(source)
    if not BillingType then
        ZlomaCore.Warn("Billing", "GetBills")
        return {}
    end

    if BillingType == 'okokBilling' or BillingType == 'okok_billing' then
        -- okokBilling uses MySQL directly - need callback
        local bills = {}
        local p = promise.new()
        
        -- Attempt to fetch bills from okokBilling
        -- Note: This requires okokBilling to expose its data or we query MySQL
        -- Since we want version-agnostic approach, return empty for now
        ZlomaCore.Debug("GetBills for okokBilling requires direct database access")
        p:resolve(bills)
        
        return Citizen.Await(p)
        
    elseif BillingType == 'esx_billing' then
        -- ESX Billing stores in database - requires callback
        local bills = {}
        local p = promise.new()
        
        TriggerEvent('esx_billing:getBills', source, function(result)
            p:resolve(result or {})
        end)
        
        return Citizen.Await(p)
        
    elseif BillingType == 'qb-billing' then
        -- QB Billing - requires callback or export
        ZlomaCore.Debug("GetBills for qb-billing may require custom implementation")
        return {}
    end

    return {}
end)

-- Alternative: Server event for sending bills (for client-side calls)
RegisterNetEvent('zloma_core:server:sendBill', function(target, amount, reason, society)
    local source = source
    exports['zloma_core']:SendBill(source, target, amount, reason, society)
end)

