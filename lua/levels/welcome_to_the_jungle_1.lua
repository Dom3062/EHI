local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local other = {
    [102064] = EHI:AddAssaultDelay({ control = 60 + 1, trigger_once = true })
}

---@type ParseAchievementTable
local achievements =
{
    cac_24 =
    {
        elements =
        {
            [101282] = { time = 60, class = TT.Achievement.Base },
            [101285] = { special_function = SF.SetAchievementComplete }
        },
        sync_params = { from_start = true }
    }
}

EHI.Manager:ParseTriggers({
    achievement = achievements,
    other = other
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 1500, name = "big_oil_intel_pickup", times = 3, optional = true },
        { amount = 6000, name = "twh_safe_open", times = 1 },
        { escape = {
            { amount = 6000, stealth = true, ghost_bonus = tweak_data.levels:GetLevelStealthBonus() },
            { amount = 6000, loud = true },
        }}
    },
    total_xp_override =
    {
        params =
        {
            min_max = {
                bonus_xp = { min_max = 6000 }
            }
        }
    }
})