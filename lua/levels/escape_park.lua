local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [102444] = { id = "king_of_the_hill", class = TT.AchievementNotification },
    [101297] = { id = "king_of_the_hill", special_function = SF.SetAchievementFailed },
    [101343] = { id = "king_of_the_hill", special_function = SF.SetAchievementComplete },
    [102449] = { time = 240 },
    [102450] = { time = 180 },
    [102451] = { time = 300 }
}

EHI:ParseTriggers(triggers, "Escape", EHI.Icons.CarEscape)