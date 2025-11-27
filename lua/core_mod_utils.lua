if EHI.ModUtils then
    return
end
EHI.ModUtils = {}
EHI.ModUtils._restoration_vanilla_levels_bs = { -- Restoration Mod Overhaul bs
    alex_2_res = true,
    four_stores_remixed = true
}

function EHI.ModUtils:SWAYRMod_EscapeVehicleWillReturn()
    if EHI.IsHost and SWAYRMod and SWAYRMod.included(Global.game_settings.level_id) then
        return false
    end
    return true -- Don't touch it!
end

---@param pager_count number
function EHI.ModUtils:SELH_GetModifiedPagerCount(pager_count)
    if NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY == "Stealth Every Loud Heist" and _G["stealth all heists"] then
        return _G["stealth all heists"].pager_data[Global.game_settings.level_id] or pager_count
    end
    return pager_count
end

---@param f fun(peer_id: integer, color: Color)
function EHI.ModUtils:AddCustomNameColorSyncCallback(f)
    if not (CustomNameColor and CustomNameColor.ModID) then
        return
    elseif not self._custom_color_sync_callback then
        self._custom_color_sync_callback = CallbackEventHandler:new()
        if not Global.game_settings.single_player then
            managers.ehi_sync:AddReceiveHook(CustomNameColor.ModID, "EHI_CustomNameColor_ColorSync", function(data, sender)
                if data and data ~= "" then
                    local col = NetworkHelper:StringToColour(data)
                    self._custom_color_sync_callback:dispatch(sender, col)
                end
            end)
        end
        Hooks:PostHook(CustomNameColor, "SetLocalColors", "EHI_CustomNameColor_SetLocalColors", function(...)
            local id = managers.network:session():local_peer():id()
            self._custom_color_sync_callback:dispatch(id, tweak_data.chat_colors[id])
        end)
    end
    self._custom_color_sync_callback:add(f)
end