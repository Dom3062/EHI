local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers = {
    [102368] = { id = "PickUpBalloonFirstTry", icons = { Icon.Defend }, class = TT.Pausable, special_function = SF.GetElementTimerAccurate, element = 102333 },
    [104290] = { id = "PickUpBalloonFirstTry", special_function = SF.PauseTracker },
    [103517] = { id = "PickUpBalloonFirstTry", special_function = SF.UnpauseTracker },
    [101205] = { id = "PickUpBalloonFirstTry", special_function = SF.UnpauseTracker },
    [102370] = { id = "PickUpBalloonSecondTry", icons = { Icon.Escape }, class = TT.Pausable, special_function = SF.GetElementTimerAccurate, element = 100732 }
}
if EHI:IsClient() then
    triggers[102368].time = 120
    triggers[102368].random_time = 10
    triggers[102368].delay_only = true
    triggers[102368].class = TT.InaccuratePausable
    triggers[102368].synced = { class = TT.Pausable }
    triggers[102368].special_function = SF.AddTrackerIfDoesNotExist
    EHI:AddSyncTrigger(102368, triggers[102368])
    triggers[102371] = { time = 60, id = "PickUpBalloonFirstTry", icons = { Icon.Defend }, class = TT.Pausable, special_function = SF.SetTrackerAccurate }
    triggers[102366] = { time = 30, id = "PickUpBalloonFirstTry", icons = { Icon.Defend }, class = TT.Pausable, special_function = SF.SetTrackerAccurate }
    triggers[103039] = { time = 20, id = "PickUpBalloonFirstTry", icons = { Icon.Defend }, class = TT.Pausable, special_function = SF.SetTrackerAccurate }
    triggers[102370].time = 35
    triggers[102370].random_time = 10
    triggers[102370].delay_only = true
    triggers[102370].class = TT.InaccuratePausable
    triggers[102370].synced = { class = TT.Pausable }
    triggers[102370].special_function = SF.AddTrackerIfDoesNotExist
    EHI:AddSyncTrigger(102370, triggers[102370])
    triggers[103038] = { time = 20, id = "PickUpBalloonSecondTry", icons = { Icon.Escape }, class = TT.Pausable, special_function = SF.SetTrackerAccurate }
end

local achievements =
{
    [101732] = { special_function = SF.Trigger, data = { 1017321, 1017322 } },
    [1017321] = { id = "glace_9", status = "find", class = TT.AchievementStatus, difficulty_pass = ovk_and_up },
    [1017322] = { max = 6, id = "glace_10", class = TT.AchievementProgress },
    [105758] = { id = "glace_9", special_function = SF.SetAchievementFailed },
    [105756] = { id = "glace_9", status = "ok", special_function = SF.SetAchievementStatus },
    [105759] = { id = "glace_9", special_function = SF.SetAchievementComplete },
    [105761] = { id = "glace_10", special_function = SF.IncreaseProgress }, -- ElementInstanceOutputEvent
    [105721] = { id = "glace_10", special_function = SF.IncreaseProgress }, -- ElementEnemyDummyTrigger

    [100765] = { status = "destroy", id = "uno_4", class = TT.AchievementStatus },
    -- Very Hard or above check in the mission script
    -- Reported here: https://steamcommunity.com/app/218620/discussions/14/3386156547847005343/
    [103397] = { id = "uno_4", special_function = SF.SetAchievementComplete },
    [102323] = { id = "uno_4", special_function = SF.SetAchievementFailed }
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