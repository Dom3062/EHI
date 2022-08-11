local EHI = EHI
local Icon = EHI.Icons
local TT = EHI.Trackers
local SF = EHI.SpecialFunctions
local triggers = {
    [102611] = { time = 1, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning },
    [102612] = { time = 3, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning },
    [102613] = { time = 5, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning },

    [100750] = { time = 120 + 80, id = "Van", icons = Icon.CarEscape },
    [101568] = { time = 20, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [101569] = { time = 40, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [101572] = { time = 60, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [101573] = { time = 80, id = "Van", icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist }
}
EHI:AddOnAlarmCallback(function(dropin)
    managers.ehi:AddEscapeChanceTracker(dropin, 10)
end)

local achievements =
{
    [100108] = { id = "uno_2", class = TT.AchievementStatus, difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) },
    [101492] = { id = "uno_2", status = "secure", special_function = SF.SetAchievementStatus },
    [102206] = { id = "uno_2", special_function = SF.SetAchievementFailed },
    [102207] = { id = "uno_2", special_function = SF.SetAchievementComplete }
}

local other =
{
    [102622] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
}

EHI:ParseTriggers(triggers, achievements, other)
--EHI:ShowLootCounter({ max = 18 })