local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local other = {
    [102064] = EHI:AddAssaultDelay({ time = 60 + 1 + 30, trigger_times = 1 })
}

local achievements =
{
    [101282] = { time = 60, id = "cac_24", class = TT.Achievement },
    [101285] = { id = "cac_24", special_function = SF.SetAchievementComplete }
}

EHI:ParseTriggers({}, achievements, other)