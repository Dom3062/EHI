local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local mayhem_and_up = EHI:IsDifficultyOrAbove("mayhem")
local triggers = {
    [EHI:GetInstanceElementID(100459, 21700)] = { time = 284, id = "orange_4", class = TT.Achievement, condition = mayhem_and_up and show_achievement, exclude_from_sync = true },
    [EHI:GetInstanceElementID(100461, 21700)] = { id = "orange_4", special_function = SF.SetAchievementComplete },
    [100279] = { max = 15, id = "orange_5", class = TT.AchievementProgress, status_is_overridable = true, remove_after_reaching_target = false, condition = mayhem_and_up and show_achievement, exclude_from_sync = true },
    [101725] = { time = 25 + 0.25 + 2 + 2.35, id = "C4", icons = Icon.HeliDropDrill },
    [EHI:GetInstanceElementID(100471, 21700)] = { id = "orange_5", special_function = SF.SetAchievementFailed },
    [100866] = { time = 5, id = "C4Explosion", icons = { Icon.C4 } },
    [EHI:GetInstanceElementID(100474, 21700)] = { id = "orange_5", special_function = SF.IncreaseProgress }
}

EHI:ParseTriggers(triggers)