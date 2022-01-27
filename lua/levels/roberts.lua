local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local start_delay = 1
local delay = 20 + (math.random() * (7.5 - 6.2) + 6.2)
local HeliDropLootZone = { Icon.Heli, Icon.LootDrop, "pd2_goto" }
local triggers = {
    [101931] = { time = 90 + delay, id = "CageDrop", icons = HeliDropLootZone, special_function = SF.SetTimeOrCreateTracker },
    [101932] = { time = 120 + delay, id = "CageDrop", icons = HeliDropLootZone, special_function = SF.SetTimeOrCreateTracker },
    [101929] = { time = 30 + 150 + delay, id = "CageDrop", icons = HeliDropLootZone },
    [102921] = { special_function = SF.RemoveTrigger, data = { 101929 } },

    [103060] = { id = 103444, special_function = SF.ShowWaypoint, data = { icon = "pd2_loot", position = Vector3(-3750.0, -300.0, 0.0) } },
    [103061] = { id = 103438, special_function = SF.ShowWaypoint, data = { icon = "pd2_loot", position = Vector3(1350.0, -4600.0, 0.0) } },
    [104809] = { id = 103443, special_function = SF.ShowWaypoint, data = { icon = "pd2_loot", position = Vector3(1600.0, 1400.0, 0.0) } },

    [101959] = { time = 90 + start_delay, id = "Plane", icons = { Icon.Heli, Icon.Wait }, special_function = SF.SetTimeOrCreateTracker },
    [101960] = { time = 120 + start_delay, id = "Plane", icons = { Icon.Heli, Icon.Wait }, special_function = SF.SetTimeOrCreateTracker },
    [101961] = { time = 150 + start_delay, id = "Plane", icons = { Icon.Heli, Icon.Wait }, special_function = SF.SetTimeOrCreateTracker },

    [102796] = { time = 10, id = "ObjectiveWait", icons = { "faster" } },

    [102975] = { special_function = SF.Trigger, data = { 1029751, 1029752 } },
    [1029751] = { chance = 5, id = "CorrectPaperChance", icons = { "equipment_files" }, class = TT.Chance },
    [1029752] = { time = 30, id = "GenSecArrivalWarning", icons = { Icon.Phone, "pd2_generic_look" }, class = TT.Warning },
    [102986] = { special_function = SF.RemoveTrackers, data = { "CorrectPaperChance", "GenSecArrivalWarning" } },
    [102985] = { amount = 25, id = "CorrectPaperChance", special_function = SF.IncreaseChance },
    [102937] = { time = 30, id = "GenSecArrival", icons = { { icon = Icon.Car, color = Color.red } }, class = TT.Warning, special_function = SF.RemoveTriggerWhenExecuted },

    [102995] = { time = 30, id = "CallAgain", icons = { Icon.Phone, "restarter" } },
    [102996] = { time = 50, id = "CallAgain", icons = { Icon.Phone, "restarter" } },
    [102997] = { time = 60, id = "CallAgain", icons = { Icon.Phone, "restarter" } },
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
    for _, tracker in pairs(remove) do
        managers.ehi:RemoveTracker(tracker)
    end
end)

EHI:ParseTriggers(triggers)