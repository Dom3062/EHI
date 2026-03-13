if EHI.ModUtils then
    return
end
EHI.ModUtils = {}
EHI.ModUtils._restoration_vanilla_levels_bs = { -- Restoration Mod Overhaul bs
    alex_2_res = true,
    four_stores_remixed = true
}
function EHI.ModUtils:post_init()
    if self.__custom_color_sync_callback then
        self:_CreateCNCSyncCallback()
    end
end

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

---@param id string
---@param f fun(peer_id: integer, color: Color)
function EHI.ModUtils:AddCustomNameColorSyncCallback(id, f)
    if not (CustomNameColor and CustomNameColor.ModID) then
        return
    elseif not self._custom_color_sync_callback then
        if not ListenerHolder then
            self.__custom_color_sync_callback = self.__custom_color_sync_callback or {}
            self.__custom_color_sync_callback[id] = f
            return
        end
        self:_CreateCNCSyncCallback()
    end
    self._custom_color_sync_callback:add(id, f)
end

function EHI.ModUtils:_CreateCNCSyncCallback()
    self._custom_color_sync_callback = ListenerHolder:new()
    if not Global.game_settings.single_player then
        managers.ehi_sync:AddReceiveHook(CustomNameColor.ModID, "EHI_CustomNameColor_ColorSync", function(data, sender)
            if data and data ~= "" then
                local col = NetworkHelper:StringToColour(data)
                self._custom_color_sync_callback:call(sender, col)
            end
        end)
    end
    Hooks:PostHook(CustomNameColor, "SetLocalColors", "EHI_CustomNameColor_SetLocalColors", function(...)
        local local_id = managers.network:session():local_peer():id()
        self._custom_color_sync_callback:call(local_id, tweak_data.chat_colors[local_id])
    end)
    if self.__custom_color_sync_callback then
        for key, f in pairs(self.__custom_color_sync_callback) do
            self._custom_color_sync_callback:add(key, f)
        end
        self.__custom_color_sync_callback = nil
    end
end

---@param id string
function EHI.ModUtils:RemoveCustomNameColorSyncCallback(id)
    if self._custom_color_sync_callback then
        self._custom_color_sync_callback:remove(id)
    elseif self.__custom_color_sync_callback then
        self.__custom_color_sync_callback[id] = nil
    end
end