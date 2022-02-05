local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local element_sync_triggers =
{
    [101374] = { id = "VaultTeargas", icons = { Icon.Teargas }, hook_element = 101377 }
}
local triggers = {
    [100903] = { time = 120, id = "LiquidNitrogen", icons = { "equipment_liquid_nitrogen_canister" }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1009031 } },
    [1009031] = { time = 63 + 6 + 4 + 30 + 24 + 3, id = "HeliC4", icons = Icon.HeliDropC4 },

    [100699] = { time = 8 + 25 + 13, id = "ObjectiveWait", icons = { "faster" } },
}
if Network:is_client() then
    triggers[101366] = { time = 5 + 40, random_time = 10, id = "VaultTeargas", icons = { Icon.Teargas } }
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end

EHI:ParseTriggers(triggers)
EHI:ShowAchievementLootCounter({
    achievment = "rvd_11",
    max = 19,
    exclude_from_sync = true,
    counter =
    {
        check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
        loot_type = { "diamonds_dah", "diamonds" }
    }
})