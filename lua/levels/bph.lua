local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers = {
    [100109] = { max = (ovk_and_up and 40 or 30), id = "EnemyDeathShowers", icons = { "pd2_kill" }, flash_times = 1, class = TT.Progress },
    [101433] = { id = "EnemyDeathShowers", special_function = SF.RemoveTracker },

    [101815] = { time = 10, id = "MoveWalkway", icons = { Icon.Wait } },

    [101221] = { time = 11, id = "Thermite1", icons = { Icon.Fire } },
    [101714] = { time = 11, id = "Thermite2", icons = { Icon.Fire } },
    [101715] = { time = 11, id = "Thermite3", icons = { Icon.Fire } },
    [101716] = { time = 11, id = "Thermite4", icons = { Icon.Fire } },

    [101137] = { max = 10, id = "EnemyDeathOutside", icons = { "pd2_kill" }, flash_times = 1, class = TT.Progress },
    [101405] = { id = "EnemyDeathOutside", special_function = SF.RemoveTracker },

    [101339] = { id = "EnemyDeathShowers", special_function = SF.IncreaseProgress },
    [101412] = { id = "EnemyDeathOutside", special_function = SF.IncreaseProgress }
}

local achievements =
{
    [101742] = { max = 3, id = "bph_10", class = TT.AchievementProgress, special_function = SF.RemoveTriggerAndShowAchievement, difficulty_pass = ovk_and_up },
    [101885] = { id = "bph_10", special_function = SF.SetAchievementFailed },
    [102171] = { id = "bph_10", special_function = SF.IncreaseProgress }
}

EHI:ParseTriggers(triggers, achievements)