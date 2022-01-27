local Icon = EHI.Icons
local escape_delay = 18
local triggers = {
    [102873] = { time = 36 + 5 + 3 + 60 + 30 + 38 + 7, id = "VanPickupLoot", icons = Icon.CarLootDrop },

    [101256] = { time = 28 + 3 + 10 + 10, id = "CarEscape", icons = Icon.CarEscapeNoLoot },

    [101218] = { time = 180 + escape_delay, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot },
    [101219] = { time = 120 + escape_delay, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot },
    [101221] = { time = 60 + escape_delay, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot },
}

EHI:ParseTriggers(triggers)