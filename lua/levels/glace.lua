local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
---@type ParseTriggerTable
local triggers = {
    [102368] = { id = "PickUpBalloonFirstTry", icons = { Icon.Defend }, class = TT.Pausable, special_function = SF.GetElementTimerAccurate, element = 102333 },
    [104290] = { id = "PickUpBalloonFirstTry", special_function = SF.PauseTracker },
    [103517] = { id = "PickUpBalloonFirstTry", special_function = SF.UnpauseTracker },
    [101205] = { id = "PickUpBalloonFirstTry", special_function = SF.UnpauseTracker },
    [102370] = { id = "PickUpBalloonSecondTry", icons = { Icon.Escape }, class = TT.Pausable, special_function = SF.GetElementTimerAccurate, element = 100732 }
}
if EHI:IsClient() then
    triggers[102368].client = { time = 120, random_time = 10 }
    triggers[102371] = { time = 60, id = "PickUpBalloonFirstTry", icons = { Icon.Defend }, class = TT.Pausable, special_function = SF.SetTrackerAccurate }
    triggers[102366] = { time = 30, id = "PickUpBalloonFirstTry", icons = { Icon.Defend }, class = TT.Pausable, special_function = SF.SetTrackerAccurate }
    triggers[103039] = { time = 20, id = "PickUpBalloonFirstTry", icons = { Icon.Defend }, class = TT.Pausable, special_function = SF.SetTrackerAccurate }
    triggers[102370].client = { time = 35, random_time = 10 }
    triggers[103038] = { time = 20, id = "PickUpBalloonSecondTry", icons = { Icon.Escape }, class = TT.Pausable, special_function = SF.SetTrackerAccurate }
end

---@type ParseAchievementTable
local achievements =
{
    glace_9 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [101732] = { status = "find", class = TT.Achievement.Status },
            [105758] = { special_function = SF.SetAchievementFailed },
            [105756] = { status = "ok", special_function = SF.SetAchievementStatus },
            [105759] = { special_function = SF.SetAchievementComplete }
        }
    },
    glace_10 =
    {
        elements =
        {
            [101732] = { max = 6, class = TT.Achievement.Progress },
            [105761] = { special_function = SF.IncreaseProgress }, -- ElementInstanceOutputEvent
            [105721] = { special_function = SF.IncreaseProgress } -- ElementEnemyDummyTrigger
        }
    },
    uno_4 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [100765] = { status = "destroy", class = TT.Achievement.Status },
            [103397] = { special_function = SF.SetAchievementComplete },
            [102323] = { special_function = SF.SetAchievementFailed }
        }
    }
}

local other =
{
    [101132] = EHI:AddAssaultDelay({ time = 59 + 30 }),
    [100487] = EHI:AddAssaultDelay({ time = 30, special_function = SF.SetTimeOrCreateTracker })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 8000, name = "green_bridge_prisoner_found" },
        { amount = 6000, name = "green_bridge_prisoner_escorted" },
        { amount = 6000, name = "green_bridge_prisoner_defended" },
        { escape = 4000 }
    },
    loot_all = 1000,
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot_all = { max = 4 }
            }
        }
    }
})