local EHI = EHI
local SF = EHI.SpecialFunctions
local LootCounter = EHI:GetOption("show_loot_counter")
local other =
{
    [100107] = { special_function = SF.CustomCode, trigger_times = 1, f = function()
        if not LootCounter then
            return
        end
        EHI:ShowLootCounterNoCheck({
            max = 6,
            max_random = 7
        })
    end},
    [100109] = { special_function = SF.CustomCode, f = function() -- Alarm
        if not LootCounter then
            return
        end
        managers.ehi:CallFunction("LootCounter", "RandomLootDeclined", 7)
    end},
    [107260] = { special_function = SF.CustomCode, f = function()
        if not LootCounter then
            return
        end
        managers.ehi:CallFunction("LootCounter", "RandomLootSpawned", 7)
    end},
    [100116] = EHI:AddAssaultDelay({ time = 60 + 30 })
}

EHI:ParseTriggers({
    other = other
})

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
    counter =
    {
        check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
        loot_type = "money"
    }
})