local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [100247] = { time = 180 },
    [100248] = { time = 120 },
    [100287] = { time = 30, id = "frappucino_to_go_please", class = TT.Achievement },
    [101379] = { id = "frappucino_to_go_please", special_function = SF.SetAchievementComplete },

    [100154] = { id = 100318, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(-3900, -2200, 650) } },
    [100157] = { id = 100314, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(2800, 2750, 623) } },
    [100156] = { id = 100367, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(-1450, -3850, 650) } },
}

EHI:ParseTriggers(triggers, "Escape", Icon.CarEscape)