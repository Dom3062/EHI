local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local start_delay = 1
local delay = 20 + (math.random() * (7.5 - 6.2) + 6.2)
local HeliDropLootZone = { Icon.Heli, Icon.LootDrop, Icon.Goto }
local triggers = {
    [101931] = { time = 90 + delay, id = "CageDrop", icons = HeliDropLootZone, special_function = SF.SetTimeOrCreateTracker },
    [101932] = { time = 120 + delay, id = "CageDrop", icons = HeliDropLootZone, special_function = SF.SetTimeOrCreateTracker },
    [101929] = { time = 30 + 150 + delay, id = "CageDrop", icons = HeliDropLootZone },
    [102921] = { id = 101929, special_function = SF.RemoveTrigger },

    [103060] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Loot, position_by_element = 103444 } },
    [103061] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Loot, position_by_element = 103438 } },
    [104809] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Loot, position_by_element = 103443 } },

    [101959] = { time = 90 + start_delay, id = "Plane", icons = { Icon.Heli, Icon.Wait }, special_function = SF.SetTimeOrCreateTracker },
    [101960] = { time = 120 + start_delay, id = "Plane", icons = { Icon.Heli, Icon.Wait }, special_function = SF.SetTimeOrCreateTracker },
    [101961] = { time = 150 + start_delay, id = "Plane", icons = { Icon.Heli, Icon.Wait }, special_function = SF.SetTimeOrCreateTracker },

    [102796] = { time = 10, id = "ObjectiveWait", icons = { Icon.Wait } },

    [102975] = { special_function = SF.Trigger, data = { 1029751, 1029752 } },
    [1029751] = { chance = 5, id = "CorrectPaperChance", icons = { "equipment_files" }, class = TT.Chance },
    [1029752] = { time = 30, id = "GenSecArrivalWarning", icons = { Icon.Phone, "pd2_generic_look" }, class = TT.Warning },
    [102986] = { special_function = SF.RemoveTracker, data = { "CorrectPaperChance", "GenSecArrivalWarning" } },
    [102985] = { amount = 25, id = "CorrectPaperChance", special_function = SF.IncreaseChance },
    [102937] = { time = 30, id = "GenSecArrival", icons = { { icon = Icon.Car, color = Color.red } }, class = TT.Warning, trigger_times = 1 },

    [102995] = { time = 30, id = "CallAgain", icons = { Icon.Phone, Icon.Loop } },
    [102996] = { time = 50, id = "CallAgain", icons = { Icon.Phone, Icon.Loop } },
    [102997] = { time = 60, id = "CallAgain", icons = { Icon.Phone, Icon.Loop } },
    [102940] = { time = 10, id = "AnswerPhone", icons = { Icon.Phone }, class = TT.Warning },
    [102945] = { id = "AnswerPhone", special_function = SF.RemoveTracker }
}
EHI:AddOnAlarmCallback(function()
    local remove = {
        "CorrectPaperChance",
        "GenSecArrivalWarning",
        "GenSecArrival",
        "CallAgain",
        "AnswerPhone"
    }
    for _, tracker in ipairs(remove) do
        managers.ehi:RemoveTracker(tracker)
    end
end)

EHI:ParseTriggers({ mission = triggers })

local tbl =
{
    --units/payday2/equipment/gen_interactable_lance_large/gen_interactable_lance_large
    [101570] = { remove_vanilla_waypoint = true, waypoint_id = 102899 },
    --units/payday2/props/gen_prop_security_timelock/gen_prop_security_timelock
    [101936] = { icons = { Icon.Vault }, remove_on_pause = true, remove_vanilla_waypoint = true, waypoint_id = 102901 }
}
EHI:UpdateUnits(tbl)
local xp_override =
{
    params =
    {
        min =
        {
            objectives = true,
            loot_all = { times = 1 }
        },
        no_max = true
    }
}
EHI:AddXPBreakdown({
    tactic =
    {
        stealth =
        {
            objectives =
            {
                { amount = 4000, name = "timelock_done" },
                { amount = 500, name = "phone_answered", times = 4 },
                { escape = 1000 }
            },
            loot_all = 1000,
            total_xp_override = xp_override
        },
        loud =
        {
            objectives =
            {
                { amount = 7000, name = "thermaldrill_done" },
                { amount = 3000, name = "cage_assembled" },
                { escape = 2000 }
            },
            loot_all = 1000,
            total_xp_override = xp_override
        }
    }
})