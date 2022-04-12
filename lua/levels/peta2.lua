local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove("overkill")
local mayhem_and_up = EHI:IsDifficultyOrAbove("mayhem")
local goat_pick_up = { Icon.Heli, Icon.Interact }
local triggers = {
    [100109] = { time = 100 + 30, id = "AssaultDelay", class = TT.AssaultDelay },

    [100002] = { max = (mayhem_and_up and 15 or 13), id = "peta_5", class = TT.AchievementProgress, condition = show_achievement and ovk_and_up },
    [102211] = { id = "peta_5", special_function = SF.IncreaseProgress },
    [100580] = { special_function = SF.CustomCode, f = function()
        EHI:DelayCall("peta_5_finalize", 2, function()
            managers.ehi:CallFunction("peta_5", "Finalize")
        end)
    end},

    -- Formerly 5 minutes
    [101540] = { time = 240, id = "peta_3", class = TT.Achievement },
    [101533] = { id = "peta_3", special_function = SF.SetAchievementComplete },

    [EHI:GetInstanceElementID(100022, 2850)] = { time = 180 + 6.9, id = "BagsDropin", icons = Icon.HeliDropBag },
    [EHI:GetInstanceElementID(100022, 3150)] = { time = 180 + 6.9, id = "BagsDropin", icons = Icon.HeliDropBag },
    [EHI:GetInstanceElementID(100022, 3450)] = { time = 180 + 6.9, id = "BagsDropin", icons = Icon.HeliDropBag },
    [100581] = { time = 9 + 30 + 6.9, id = "BagsDropinAgain", icons = Icon.HeliDropBag, special_function = SF.ExecuteIfElementIsEnabled },
    [EHI:GetInstanceElementID(100072, 3750)] = { time = 120 + 6.5, id = "PilotComingIn", icons = goat_pick_up, special_function = SF.ExecuteIfElementIsEnabled },
    [EHI:GetInstanceElementID(100072, 4250)] = { time = 120 + 6.5, id = "PilotComingIn", icons = goat_pick_up, special_function = SF.ExecuteIfElementIsEnabled },
    [EHI:GetInstanceElementID(100072, 4750)] = { time = 120 + 6.5, id = "PilotComingIn", icons = goat_pick_up, special_function = SF.ExecuteIfElementIsEnabled },
    [EHI:GetInstanceElementID(100099, 3750)] = { time = 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = SF.ExecuteIfElementIsEnabled },
    [EHI:GetInstanceElementID(100099, 4250)] = { time = 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = SF.ExecuteIfElementIsEnabled },
    [EHI:GetInstanceElementID(100099, 4750)] = { time = 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = SF.ExecuteIfElementIsEnabled },

    [101720] = { time = 80, id = "Bridge", icons = { "faster" }, special_function = SF.UnpauseTrackerIfExists, class = TT.Pausable },
    [101718] = { id = "Bridge", special_function = SF.PauseTracker },

    [EHI:GetInstanceElementID(100011, 3750)] = { time = 15 + 1 + 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = SF.ReplaceTrackerWithTracker, data = { id = "PilotComingIn" } },
    [EHI:GetInstanceElementID(100011, 4250)] = { time = 15 + 1 + 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = SF.ReplaceTrackerWithTracker, data = { id = "PilotComingIn" } },
    [EHI:GetInstanceElementID(100011, 4750)] = { time = 15 + 1 + 60 + 6.5, id = "PilotComingInAgain", icons = goat_pick_up, special_function = SF.ReplaceTrackerWithTracker, data = { id = "PilotComingIn" } }
}

EHI:ParseTriggers(triggers)