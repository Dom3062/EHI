local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [101176] = { time = 67 + 400/30, id = "WinchInteract", icons = { Icon.Heli, Icon.Winch } },
    [106390] = { time = 6 + 30 + 25 + 15 + 2.5, id = "C4", icons = Icon.HeliDropC4 },
    -- 6s delay before Bile speaks
    -- 30s delay before random logic
    -- 25s delay to execute random logic
    -- Random logic has defined 2 heli fly ins
    -- First is shorter (6.5 + 76/30) 76/30 => 2.533333 (rounded to 2.5 in Mission Script)
    -- Second is longer (15 + 76/30)
    -- Second animation is counted in this trigger, the first is in CoreElementUnitSequence.lua.
    -- If the first fly in is selected, the tracker is updated to reflect that

    [100107] = { max = 2, id = "moon_4", class = TT.AchievementProgress, special_function = SF.RemoveTriggerAndShowAchievement },

    [100647] = { time = 10, id = "SantaTalk", icons = { "pd2_talk" }, special_function = SF.ExecuteIfElementIsEnabled },
    [100159] = { time = 5 + 7 + 7.3, id = "Escape", icons = { "pd2_escape" }, special_function = SF.ExecuteIfElementIsEnabled },

    [104219] = { id = "moon_4", special_function = SF.IncreaseProgress }, -- Chains
    [104220] = { id = "moon_4", special_function = SF.IncreaseProgress }, -- Dallas

    [100578] = { time = 9, id = "C4", icons = { Icon.Heli, Icon.C4, "pd2_goto" }, special_function = SF.SetTimeOrCreateTracker }
}

EHI:ParseTriggers(triggers)