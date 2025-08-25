local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers

---@type ParseAchievementTable
local achievements =
{
    cac_21 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard),
        elements =
        {
            [100212] = { max = 6, class = TT.Achievement.Progress, status_is_overridable = false, condition_function = EHI.ConditionFunctions.PlayingFromStart },
            [100224] = { special_function = SF.IncreaseProgress },
            [100181] = { special_function = SF.CustomCodeDelayed, t = 2, f = function()
                managers.ehi_unlockable:SetAchievementFailed("cac_21")
            end}
        }
    }
}
EHI.Mission:ParseTriggers({
    achievement = achievements
})
EHI:ShowLootCounter({ no_max = true }, { element =
{
    EHI:GetInstanceElementID(100013, 12294),
    EHI:GetInstanceElementID(100013, 12394),
    EHI:GetInstanceElementID(100013, 12794),
    EHI:GetInstanceElementID(100013, 12894)
}, present_timer = 0 })

local tbl =
{
    --units/pd2_dlc_chill/props/chl_prop_timer_large/chl_prop_timer_large
    [100007] = { ignore = true },
    [100827] = { ignore = true },
    [100888] = { ignore = true },
    [100889] = { ignore = true },
    [100891] = { ignore = true },
    [100892] = { ignore = true },
    [100176] = { ignore = true },
    [100177] = { ignore = true },

    --units/pd2_dlc_chill/props/chl_prop_timer_small/chl_prop_timer_small
    [100029] = { ignore = true },
    [100878] = { ignore = true }
}
EHI.Unit:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objective =
    {
        escape = 2000
    },
    loot_all = 1000
})