local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local inspect = 30
local escape = 23 + 7
local triggers = {
    [100266] = { time = 30 + inspect, id = "Inspect", icons = { Icon.Wait }, special_function = SF.SetTimeOrCreateTracker },
    [100271] = { time = 45 + inspect, id = "Inspect", icons = { Icon.Wait }, special_function = SF.SetTimeOrCreateTracker },
    [100273] = { time = 60 + inspect, id = "Inspect", icons = { Icon.Wait }, special_function = SF.SetTimeOrCreateTracker },
    [103319] = { time = 75 + inspect, id = "Inspect", icons = { Icon.Wait }, special_function = SF.AddTrackerIfDoesNotExist },
    [100265] = { time = 45 + 75 + inspect, id = "Inspect", icons = { Icon.Wait } },

    --[103132] = { time = 330 + 240, id = "Refuel", icons = { "restarter" } },

    [103132] = { time = 330 + 240, id = "HeliArrival", icons = Icon.HeliLootDrop }, -- Includes heli refuel (330s)
    [100372] = { time = 150, id = "HeliArrival", icons = Icon.HeliLootDrop, special_function = SF.AddTrackerIfDoesNotExist },
    [100371] = { time = 120, id = "HeliArrival", icons = Icon.HeliLootDrop, special_function = SF.AddTrackerIfDoesNotExist },
    [100363] = { time = 90, id = "HeliArrival", icons = Icon.HeliLootDrop, special_function = SF.AddTrackerIfDoesNotExist },
    [100355] = { time = 60, id = "HeliArrival", icons = Icon.HeliLootDrop, special_function = SF.AddTrackerIfDoesNotExist },

    -- Heli escape
    [100898] = { time = 15 + escape, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot },
    [100902] = { time = 30 + escape, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot },
    [100904] = { time = 45 + escape, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot },
    [100905] = { time = 60 + escape, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot }
}

EHI:ParseTriggers(triggers)