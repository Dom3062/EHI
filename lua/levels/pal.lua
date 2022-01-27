local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local element_sync_triggers =
{
    [102887] = { time = 1800/30, id = "HeliCage", icons = { Icon.Heli, Icon.LootDrop }, hook_element = 102892 }
}
local triggers = {
    --[100240] = { id = "PAL", special_function = SF.RemoveTracker },
    [102502] = { time = 60, id = "PAL", icons = { Icon.Money }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [102505] = { id = "PAL", special_function = SF.RemoveTracker },
    [102749] = { id = "PAL", special_function = SF.PauseTracker },
    [102738] = { id = "PAL", special_function = SF.PauseTracker },
    [102744] = { id = "PAL", special_function = SF.UnpauseTracker },
    [102826] = { id = "PAL", special_function = SF.RemoveTracker },

    [102301] = { time = 15, id = "Trap", icons = { "pd2_c4" }, class = TT.Warning },
    [101566] = { id = "Trap", special_function = SF.RemoveTracker },

    [101230] = { time = 120, id = "Water", icons = { "pd2_water_tap" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [101231] = { id = "Water", special_function = SF.PauseTracker }
}
local heli = { id = "HeliCageDelay", icons = { Icon.Heli, Icon.LootDrop, "faster" }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "HeliCage" }, class = TT.Warning }
local sync_triggers = {
    [EHI:GetInstanceElementID(100013, 4700)] = heli,
    [EHI:GetInstanceElementID(100013, 4750)] = heli,
    [EHI:GetInstanceElementID(100013, 4800)] = heli,
    [EHI:GetInstanceElementID(100013, 4850)] = heli
}
if Network:is_client() then
    triggers[102892] = { time = 1800/30 + 120, random_time = 60, id = "HeliCage", icons = { Icon.Heli, Icon.LootDrop }, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[EHI:GetInstanceElementID(100013, 4700)] = { time = 180, random_time = 60, id = "HeliCageDelay", icons = { Icon.Heli, Icon.LootDrop, "faster" }, special_function = SF.PAL_ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists, data = { id = "HeliCage" }, class = TT.Warning }
    triggers[EHI:GetInstanceElementID(100013, 4750)] = { time = 180, random_time = 60, id = "HeliCageDelay", icons = { Icon.Heli, Icon.LootDrop, "faster" }, special_function = SF.PAL_ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists, data = { id = "HeliCage" }, class = TT.Warning }
    triggers[EHI:GetInstanceElementID(100013, 4800)] = { time = 180, random_time = 60, id = "HeliCageDelay", icons = { Icon.Heli, Icon.LootDrop, "faster" }, special_function = SF.PAL_ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists, data = { id = "HeliCage" }, class = TT.Warning }
    triggers[EHI:GetInstanceElementID(100013, 4850)] = { time = 180, random_time = 60, id = "HeliCageDelay", icons = { Icon.Heli, Icon.LootDrop, "faster" }, special_function = SF.PAL_ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists, data = { id = "HeliCage" }, class = TT.Warning }
    EHI:SetSyncTriggers(sync_triggers)
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(sync_triggers, nil, nil, "base")
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end

EHI:ParseTriggers(triggers)