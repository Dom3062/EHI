local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local dw_and_above = EHI:IsDifficultyOrAbove("death_wish")
local pink_car = { { icon = Icon.Car, color = Color("D983D1") }, "pd2_goto" }
local triggers = {
    [100107] = { id = "rvd_9", class = TT.AchievementNotification, exclude_from_sync = true },
    [100839] = { id = "rvd_9", special_function = SF.SetAchievementFailed },
    [100869] = { id = "rvd_9", special_function = SF.SetAchievementComplete },

    [100179] = { time = 1 + 9.5 + 11 + 1 + 30, id = "AssaultDelay", class = TT.AssaultDelay },

    [100727] = { time = 6 + 18 + 8.5 + 30 + 25 + 375/30, id = "Escape", icons = Icon.CarEscape },
    [100057] = { time = 60, id = "rvd_10", class = TT.Achievement, condition = dw_and_above and show_achievement, special_function = SF.ShowAchievementFromStart, exclude_from_sync = true },
    [100169] = { time = 17 + 1 + 310/30, id = "PinkArrival", icons = pink_car },
    --260/30 anim_crash_02
    --310/30 anim_crash_04
    --201/30 anim_crash_05
    --284/30 anim_crash_03

    [100247] = { id = "rvd_10", special_function = SF.SetAchievementComplete },

    [100207] = { time = 260/30, id = "Escape", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [100209] = { time = 250/30, id = "Escape", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },

    [101114] = { time = 260/30, id = "PinkArrival", icons = pink_car, special_function = SF.SetTimeOrCreateTracker },
    [101127] = { time = 201/30, id = "PinkArrival", icons = pink_car, special_function = SF.SetTimeOrCreateTracker },
    [101108] = { time = 284/30, id = "PinkArrival", icons = pink_car, special_function = SF.SetTimeOrCreateTracker }
}

EHI:ParseTriggers(triggers)