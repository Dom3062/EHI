local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local other = {
    [102064] = EHI:AddAssaultDelay({ time = 60 + 1 + 30, trigger_times = 1 })
}

local achievements =
{
    cac_24 =
    {
        elements =
        {
            [101282] = { time = 60, class = TT.Achievement },
            [101285] = { special_function = SF.SetAchievementComplete }
        }
    }
}

EHI:ParseTriggers({
    achievement = achievements,
    other = other
})