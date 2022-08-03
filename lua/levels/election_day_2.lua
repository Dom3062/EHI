local EHI = EHI
local tbl =
{
    --units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b
    [103064] = { remove_vanilla_waypoint = true, waypoint_id = 103082 },
    [103065] = { remove_vanilla_waypoint = true, waypoint_id = 103083 },
    [103066] = { remove_vanilla_waypoint = true, waypoint_id = 103084 }
}
EHI:UpdateUnits(tbl)
EHI:ShowAchievementLootCounter({
    achievement = "bob_4",
    max = 6,
    exclude_from_sync = true,
    show_loot_counter = true
})