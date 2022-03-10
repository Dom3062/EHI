local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local heli_delay = 26 + 6
local element_sync_triggers =
{
    [103569] = { time = 25, id = "CFOFall", icons = { "hostage", "pd2_goto" }, hook_element = 100438 }
}
local triggers = {
    [100276] = { time = 25 + 3 + 11, id = "CFOInChopper", icons = { Icon.Heli, "pd2_goto" } },

    [101343] = { time = 30, id = "KeypadReset", icons = { "restarter" } },

    [102259] = { id = "dah_8", special_function = SF.SetAchievementComplete },

    [104875] = { time = 45 + heli_delay, id = "HeliEscapeLoud", icons = Icon.HeliEscapeNoLoot },
    [103159] = { time = 30 + heli_delay, id = "HeliEscapeLoud", icons = Icon.HeliEscapeNoLoot },

    [102261] = { id = "dah_8", special_function = SF.IncreaseProgress }
}
if Network:is_client() then
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end

EHI:ParseTriggers(triggers)
if EHI:IsDifficultyOrAbove("overkill") then
    EHI:ShowAchievementLootCounter({
        achievement = "dah_8",
        max = 12,
        exclude_from_sync = true,
        counter =
        {
            check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
            loot_type = "diamondheist_big_diamond"
        },
        sync_only = true
    })
    EHI:AddOnAlarmCallback(function()
        managers.ehi:SetAchievementFailed("dah_8")
    end)
end