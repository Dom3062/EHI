local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove("overkill")
local kills = 7 -- Normal + Hard
if EHI:IsBetweenDifficulties("very_hard", "overkill") then
    -- Very Hard + OVERKILL
    kills = 10
elseif EHI:IsDifficultyOrAbove("mayhem") then
    -- Mayhem+
    kills = 15
end
local triggers = {
    [100001] = { time = 30, id = "BileArrival", icons = { Icon.Heli, Icon.C4 } },
    [100182] = { id = "SniperDeath", special_function = SF.RemoveTracker },
    [104555] = { id = "SniperDeath", special_function = SF.IncreaseProgress },
    [100147] = { time = 18.2, id = "HeliWinchLoop", icons = { Icon.Heli, "equipment_winch_hook", Icon.Loop }, special_function = SF.ExecuteIfElementIsEnabled },
    [102181] = { id = "HeliWinchLoop", special_function = SF.RemoveTracker },

    [100809] = { time = 60, id = "cac_9", class = TT.Achievement, condition = ovk_and_up and show_achievement, special_function = SF.RemoveTriggerAndShowAchievement, exclude_from_sync = true },

    [100068] = { max = kills, id = "SniperDeath", icons = { "sniper", "pd2_kill" }, class = TT.Progress },
    [103446] = { time = 20 + 6 + 4, id = "HeliDropsC4", icons = { Icon.Heli, "pd2_c4", "pd2_goto" } },
    [100082] = { time = 40, id = "HeliComesWithMagnet", icons = { Icon.Heli, "equipment_winch_hook" } },

    [104859] = { id = "flat_2", special_function = SF.SetAchievementComplete },
    [100805] = { id = "cac_9", special_function = SF.SetAchievementComplete },

    [100206] = { time = 30, id = "LoweringTheWinch", icons = { Icon.Heli, "equipment_winch_hook", "pd2_goto" } },

    [100049] = { time = 20, id = "flat_2", class = TT.Achievement },
    [102001] = { time = 5, id = "C4Explosion", icons = { "pd2_c4" } }
}

EHI:ParseTriggers(triggers)