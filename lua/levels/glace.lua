local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove("overkill")
local triggers = {
    [102368] = { id = "PickUpBalloonFirstTry", icons = { "pd2_defend" }, class = TT.Pausable, special_function = SF.GetElementTimerAccurate, element = 102333 },
    [104290] = { id = "PickUpBalloonFirstTry", special_function = SF.PauseTracker },
    [103517] = { id = "PickUpBalloonFirstTry", special_function = SF.UnpauseTracker },
    [101205] = { id = "PickUpBalloonFirstTry", special_function = SF.UnpauseTracker },
    [102370] = { id = "PickUpBalloonSecondTry", icons = { "pd2_escape" }, class = TT.Pausable, special_function = SF.GetElementTimerAccurate, element = 100732 },

    [101732] = { special_function = SF.Trigger, data = { 1017321, 1017322 } },
    [1017321] = { id = "glace_9", status = "ready", class = TT.AchievementNotification, condition = show_achievement and ovk_and_up, exclude_from_sync = true },
    [1017322] = { max = 6, id = "glace_10", class = TT.AchievementProgress, exclude_from_sync = true },
    [105758] = { id = "glace_9", special_function = SF.SetAchievementFailed },
    [105756] = { id = "glace_9", status = "ok", special_function = SF.SetAchievementStatus },
    [105759] = { id = "glace_9", special_function = SF.SetAchievementComplete },
    [105761] = { id = "glace_10", special_function = SF.IncreaseProgress }, -- ElementInstanceOutputEvent
    [105721] = { id = "glace_10", special_function = SF.IncreaseProgress } -- ElementEnemyDummyTrigger
}
if Network:is_client() then
    triggers[102368].time = 120
    triggers[102368].random_time = 10
    triggers[102368].delay_only = true
    triggers[102368].class = "EHIInaccuratePausableTracker"
    triggers[102368].synced = { class = TT.Pausable }
    triggers[102368].special_function = SF.AddTrackerIfDoesNotExist
    EHI:AddSyncTrigger(102368, triggers[102368])
    triggers[102371] = { time = 60, id = "PickUpBalloonFirstTry", icons = { "pd2_defend" }, class = TT.Pausable, special_function = SF.SetTrackerAccurate }
    triggers[102366] = { time = 30, id = "PickUpBalloonFirstTry", icons = { "pd2_defend" }, class = TT.Pausable, special_function = SF.SetTrackerAccurate }
    triggers[103039] = { time = 20, id = "PickUpBalloonFirstTry", icons = { "pd2_defend" }, class = TT.Pausable, special_function = SF.SetTrackerAccurate }
    triggers[102370].time = 35
    triggers[102370].random_time = 10
    triggers[102370].delay_only = true
    triggers[102370].class = "EHIInaccuratePausableTracker"
    triggers[102370].synced = { class = TT.Pausable }
    triggers[102370].special_function = SF.AddTrackerIfDoesNotExist
    EHI:AddSyncTrigger(102370, triggers[102370])
    triggers[103038] = { time = 20, id = "PickUpBalloonSecondTry", icons = { "pd2_escape" }, class = TT.Pausable, special_function = SF.SetTrackerAccurate }
end

EHI:ParseTriggers(triggers)