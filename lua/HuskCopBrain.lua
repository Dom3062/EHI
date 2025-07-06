if EHI:CheckLoadHook("HuskCopBrain") or EHI.IsHost or ((not EHI:CanShowCivilianCountTracker() or EHI:GetOption("civilian_count_tracker_format") == 1) or not EHI:GetTrackerOption("show_hostage_count_tracker")) then
    return
end

local original = HuskCopBrain.sync_net_event
---@param event_id number
function HuskCopBrain:sync_net_event(event_id, ...)
    original(self, event_id, ...)
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
    end
end