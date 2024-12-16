if EHI.ModUtils then
    return
end
EHI.ModUtils = {}

function EHI.ModUtils:SWAYRMod_EscapeVehicleWillReturn()
    if EHI.IsHost and SWAYRMod and SWAYRMod.included(Global.game_settings.level_id) then
        return false
    end
    return true
end

---@param pager_count number
function EHI.ModUtils:SELH_GetModifiedPagerCount(pager_count)
    if NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY == "Stealth Every Loud Heist" and _G["stealth all heists"] then
        return _G["stealth all heists"].pager_data[Global.game_settings.level_id] or pager_count
    end
    return pager_count
end