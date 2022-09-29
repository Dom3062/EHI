local EHI = EHI
local Icon = EHI.Icons
local TT = EHI.Trackers
local triggers = {
    [100931] = { time = 23 },
    [104910] = { time = 24 },
    [100842] = { time = 50, id = "Lasers", icons = { Icon.Lasers }, class = TT.Warning }
}

EHI:ParseTriggers({ mission = triggers }, "Escape", Icon.HeliEscapeNoLoot)