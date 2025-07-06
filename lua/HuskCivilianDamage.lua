if EHI:CheckLoadHook("HuskCivilianDamage") or EHI.IsHost or ((not EHI:CanShowCivilianCountTracker() or EHI:GetOption("civilian_count_tracker_format") == 1) or not EHI:GetTrackerOption("show_hostage_count_tracker")) then
    return
end

local original = HuskCivilianDamage.die
function HuskCivilianDamage:die(...)
    local key = self._unit:key()
    managers.ehi_tracker:CallFunction("CivilianCount", "CivilianUntied", key)
    managers.ehi_tracker:CallFunction("HostageCount", "CivilianUntied", key)
    original(self, ...)
end