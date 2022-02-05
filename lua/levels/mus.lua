local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local delay = 5
local gas_delay = 0.5
local triggers = {
    [102442] = { time = 130 + delay, special_function = SF.AddTrackerIfDoesNotExist },
    [102441] = { time = 120 + delay, special_function = SF.AddTrackerIfDoesNotExist },
    [102434] = { time = 110 + delay, special_function = SF.AddTrackerIfDoesNotExist },
    [102433] = { time = 80 + delay, special_function = SF.AddTrackerIfDoesNotExist },
    [100840] = { time = 600, id = "bat_4", class = TT.Achievement },

    [102065] = { time = 50 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas } },
    [102067] = { time = 65 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas } },
    [102068] = { time = 80 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas } },
    [102069] = { time = 95 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas } },
    [102070] = { time = 110 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas } },
    [102071] = { time = 125 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas } },
    [102072] = { time = 140 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas } }
}

EHI:ParseTriggers(triggers, "Escape", Icon.HeliEscape)
EHI:ShowAchievementLootCounter({
    achievement = "bat_3",
    max = 10,
    exclude_from_sync = true,
    counter =
    {
        check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
        loot_type = { "mus_artifact_paint", "mus_artifact" }
    }
})