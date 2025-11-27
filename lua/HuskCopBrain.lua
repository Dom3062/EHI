if EHI:CheckLoadHook("HuskCopBrain") or EHI.IsHost or not (EHI:CanShowCivilianCountTracker() or EHI:GetTrackerOption("show_hostage_count_tracker")) or (EHI:GetOption("civilian_count_tracker_format") == 1 and EHI:GetOption("hostage_count_tracker_format") == 1) then
    return
end

local original =
{
    clbk_death = HuskCopBrain.clbk_death,
    sync_net_event = HuskCopBrain.sync_net_event,
    pre_destroy = HuskCopBrain.pre_destroy
}

function HuskCopBrain:clbk_death(...)
    if self._is_hostage then
        local key = self._unit:key()
        managers.ehi_tracker:CallFunction("CivilianCount", "CivilianUntied", key)
        managers.ehi_tracker:CallFunction("HostageCount", self._is_civilian and "CivilianUntied" or "PoliceUntied", key)
    end
    original.clbk_death(self, ...)
end

---@param event_id number
function HuskCopBrain:sync_net_event(event_id, ...)
    original.sync_net_event(self, event_id, ...)
    if self._dead then
        return
    elseif event_id == self._NET_EVENTS.surrender_civilian_tied then
        local key = self._unit:key()
        managers.ehi_tracker:CallFunction("CivilianCount", "CivilianTied", key)
        managers.ehi_tracker:CallFunction("HostageCount", "CivilianTied", key)
    elseif event_id == self._NET_EVENTS.surrender_civilian_untied then
        local key = self._unit:key()
        managers.ehi_tracker:CallFunction("CivilianCount", "CivilianUntied", key)
        managers.ehi_tracker:CallFunction("HostageCount", "CivilianUntied", key)
    elseif event_id == self._NET_EVENTS.surrender_cop_tied then
        -- During debugging, tied civilians were synced as cops and then as civilians (not sure why???????)
        -- From console:
        -- [EHI] [HuskCopBrain] PoliceTied
        -- [EHI] [EHIHostageCountTracker] PoliceTied
        -- [EHI] [HuskCopBrain] CivilianTied
        -- [EHI] [EHIHostageCountTracker] CivilianTied - blocked!
        managers.ehi_tracker:CallFunction("HostageCount", self._is_civilian and "CivilianTied" or "PoliceTied", self._unit:key())
    elseif event_id == self._NET_EVENTS.surrender_cop_untied then
        managers.ehi_tracker:CallFunction("HostageCount", self._is_civilian and "CivilianUntied" or "PoliceUntied", self._unit:key())
    end
end

function HuskCopBrain:pre_destroy(...)
    if self._is_hostage then
        local key = self._unit:key()
        managers.ehi_tracker:CallFunction("CivilianCount", "CivilianUntied", key)
        managers.ehi_tracker:CallFunction("HostageCount", self._is_civilian and "CivilianUntied" or "PoliceUntied", key)
    end
    original.pre_destroy(self, ...)
end