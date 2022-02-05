local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [101392] = { time = 120, id = "FireEvidence", icons = { "pd2_fire" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [101588] = { id = "FireEvidence", special_function = SF.PauseTracker },

    [103735] = { id = "pex_11", special_function = SF.IncreaseProgress },

    [101460] = { time = 18, id = "DoorBreach", icons = { "pd2_door" } },

    [101389] = { time = 120 + 20 + 4, id = "HeliEscape", icons = { Icon.Heli, "equipment_winch_hook" } }
}
for _, index in ipairs({ 5300, 6300, 7300 }) do
    triggers[EHI:GetInstanceElementID(100025, index)] = { time = 120, id = "ArmoryHack", icons = { "wp_hack" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists }
    triggers[EHI:GetInstanceElementID(100026, index)] = { id = "ArmoryHack", special_function = SF.PauseTracker }
end
if Network:is_client() then
    triggers[100233] = { time = 20 + 4, id = "HeliEscape", icons = { Icon.Heli, "equipment_winch_hook" }, special_function = SF.AddTrackerIfDoesNotExist }
end
local DisableWaypoints =
{
    -- pex_evidence_room_1
    [EHI:GetInstanceElementID(100080, 13300)] = true, -- Defend
    [EHI:GetInstanceElementID(100084, 13300)] = true, -- Fix
    -- pex_evidence_room_2
    [EHI:GetInstanceElementID(100072, 14300)] = true, -- Defend
    [EHI:GetInstanceElementID(100079, 14300)] = true -- Fix
    -- Why they use 2 instances for one objective ???
}

EHI:ParseTriggers(triggers)
EHI:DisableWaypoints(DisableWaypoints)
EHI:ShowAchievementLootCounter({ -- Loot
    achievement = "pex_10",
    max = 6,
    exclude_from_sync = true,
    show_loot_counter = true
})
EHI:ShowAchievementLootCounter({ -- Medals
    achievement = "pex_11",
    max = 7,
    exclude_from_sync = true,
    no_counting = true
})