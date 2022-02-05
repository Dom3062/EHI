local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove("overkill")
local triggers = {
    -- First Assault Delay
    --[[[EHI:GetInstanceElementID(100003, 7950)] = { time = 3 + 12 + 12 + 4 + 20 + 30, id = "FirstAssaultDelay", icons = FirstAssaultDelay, class = TT.Warning, special_function = SF.RemoveTriggerWhenExecuted },
    [EHI:GetInstanceElementID(100024, 7950)] = { time = 12 + 12 + 4 + 20 + 30, id = "FirstAssaultDelay", icons = FirstAssaultDelay, class = TT.Warning, special_function = SF.AddTrackerIfDoesNotExist },
    [EHI:GetInstanceElementID(100053, 7950)] = { time = 12 + 4 + 20 + 30, id = "FirstAssaultDelay", icons = FirstAssaultDelay, class = TT.Warning, special_function = SF.AddTrackerIfDoesNotExist },
    [EHI:GetInstanceElementID(100026, 7950)] = { time = 4 + 20 + 30, id = "FirstAssaultDelay", icons = FirstAssaultDelay, class = TT.Warning, special_function = SF.AddTrackerIfDoesNotExist },
    [EHI:GetInstanceElementID(100179, 7950)] = { time = 20 + 30, id = "FirstAssaultDelay", icons = FirstAssaultDelay, class = TT.Warning, special_function = SF.AddTrackerIfDoesNotExist },
    [EHI:GetInstanceElementID(100295, 7950)] = { time = 30, id = "FirstAssaultDelay", icons = FirstAssaultDelay, class = TT.Warning, special_function = SF.AddTrackerIfDoesNotExist },]]

    [101989] = { special_function = SF.Trigger, data = { 1019891, 1019892 } },
    -- It was 7 minutes before the change
    [1019891] = { time = 360, id = "spa_5", class = TT.Achievement, condition = ovk_and_up and show_achievement, exclude_from_sync = true },
    [101997] = { id = "spa_5", special_function = SF.SetAchievementComplete },
    [1019892] = { max = 8, id = "spa_6", class = TT.AchievementProgress, remove_after_reaching_target = false, condition = ovk_and_up and show_achievement, exclude_from_sync = true },
    [101999] = { id = "spa_6", special_function = SF.IncreaseProgress },
    [102002] = { id = "spa_6", special_function = SF.FinalizeAchievement },

    [103419] = { id = "SniperDeath", special_function = SF.IncreaseProgress },

    [100681] = { time = 60, id = "CharonPickLock", icons = { "pd2_door" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [101430] = { id = "CharonPickLock", special_function = SF.PauseTracker },

    [102266] = { max = 6, id = "SniperDeath", icons = { "sniper", "pd2_kill" }, class = "EHIProgressTracker" },
    [100833] = { id = "SniperDeath", special_function = SF.RemoveTracker },

    [100549] = { time = 20, id = "ObjectiveWait", icons = { "faster" } },
    [101202] = { time = 15, id = "Escape", icons = Icon.CarEscape },
    [101313] = { time = 75, id = "Escape", icons = Icon.CarEscape }
}

EHI:ParseTriggers(triggers)
EHI:ShowLootCounter(4)