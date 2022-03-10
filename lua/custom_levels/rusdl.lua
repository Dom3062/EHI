local triggers = {
    [100114] = { time = 17 * 18, id = "Thermite", icons = { "pd2_fire" } },
    [100138] = { time = 20, id = "ObjectiveWait", icons = { "faster" } }
}

EHI:ParseTriggers(triggers)
EHI:ShowLootCounter(20)