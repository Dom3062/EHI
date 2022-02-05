local Icon = EHI.Icons
local triggers = {
    [101505] = { time = 10, id = "TruckDoorOpens", icons = { "pd2_door" } },
    -- There are a lot of delays in the ID. Using average instead (5.2)
    [101806] = { time = 20 + 5.2, id = "ChemicalsDrop", icons = { Icon.Heli, "pd2_methlab", "pd2_goto" } },

    [101936] = { time = 30 + 12, id = "Escape", icons = Icon.HeliEscapeNoLoot }
}

EHI:ParseTriggers(triggers)