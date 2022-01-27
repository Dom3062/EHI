local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [102064] = { time = 60 + 1 + 30, id = "FirstAssaultDelay", icons = EHI.Icons.FirstAssaultDelay, class = TT.Warning, special_function = SF.RemoveTriggerWhenExecuted },
    [101282] = { time = 60, id = "cac_24", class = TT.Achievement, exclude_from_sync = true },
    [101285] = { id = "cac_24", special_function = SF.SetAchievementComplete }
}

EHI:ParseTriggers(triggers)