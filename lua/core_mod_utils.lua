if EHI.ModUtils then
    return
end
EHI.ModUtils = {}
EHI.ModUtils._restoration_vanilla_levels_bs = { -- Restoration Mod Overhaul bs
    alex_2_res = true,
    four_stores_remixed = true
}

function EHI.ModUtils:SWAYRMod_EscapeVehicleWillReturn()
    return EHI.IsHost and SWAYRMod and SWAYRMod.included(Global.game_settings.level_id)
end

---@param pager_count number
function EHI.ModUtils:SELH_GetModifiedPagerCount(pager_count)
    if NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY == "Stealth Every Loud Heist" and _G["stealth all heists"] then
        return _G["stealth all heists"].pager_data[Global.game_settings.level_id] or pager_count
    end
    return pager_count
end