local obj_delay = { time = 30, id = "ObjectiveDelay", icons = { "faster" } }
local triggers = {
    [100404] = obj_delay,
    [100405] = obj_delay,
    [101181] = { time = 30, id = "ChemSetReset", icons = { "restarter" } },
    [101182] = { time = 30, id = "ChemSetCooking", icons = { "pd2_methlab" } },
    [101088] = { time = 84, id = "HeliEscape", icons = EHI.Icons.HeliEscapeNoLoot }
}

EHI:ParseTriggers(triggers)