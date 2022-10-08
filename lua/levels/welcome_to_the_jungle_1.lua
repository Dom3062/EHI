local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local other = {
    [102064] = { time = 60 + 1 + 30, id = "AssaultDelay", class = TT.AssaultDelay, special_function = SF.RemoveTriggerWhenExecuted, condition = EHI:GetOption("show_assault_delay_tracker") }
}

local achievements =
{
    [101282] = { time = 60, id = "cac_24", class = TT.Achievement },
    [101285] = { id = "cac_24", special_function = SF.SetAchievementComplete }
}

EHI:ParseTriggers({}, achievements, other)