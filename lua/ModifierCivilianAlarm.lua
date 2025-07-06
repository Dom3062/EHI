local EHI = EHI
if EHI:CheckLoadHook("ModifierCivilianAlarm") or not EHI:GetTrackerOption("show_mission_trackers") then
    return
end

local original =
{
    init = ModifierCivilianAlarm.init,
    OnCivilianKilled = ModifierCivilianAlarm.OnCivilianKilled
}

function ModifierCivilianAlarm:init(...)
    original.init(self, ...)
    if tweak_data.levels:IsStealthAvailable() then
        EHI:AddOnSpawnedCallback(callback(self, self, "OnPlayerSpawned"))
    end
end

function ModifierCivilianAlarm:OnPlayerSpawned()
    if not EHI:IsPlayingFromStart() then
        return
    end
    managers.ehi_tracker:AddTracker({
        id = "ModifierCivilianAlarm",
        icons = { { icon = "pager_icon", color = Color(255, 255, 165, 0) / 255 } },
        count = self:value(),
        remove_on_alarm = true,
        hint = "modifier_civilian_alarm",
        class = EHI.Trackers.Counter
    })
end

function ModifierCivilianAlarm:OnCivilianKilled(...)
    managers.ehi_tracker:DecreaseCount("ModifierCivilianAlarm")
    original.OnCivilianKilled(self, ...)
end