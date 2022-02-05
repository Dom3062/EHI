local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local very_hard_and_up = EHI:IsDifficultyOrAbove("very_hard")
local triggers = {
    [100212] = { max = 6, id = "cac_21", class = TT.AchievementProgress, condition = show_achievement and very_hard_and_up, special_function = SF.ShowAchievementFromStart, exclude_from_sync = true },
    [100224] = { id = "cac_21", special_function = SF.IncreaseProgress },
    [100181] = { special_function = SF.CustomCode, f = function()
        EHI:CallCallback("hvhCleanUp")
    end}
}

EHI:ParseTriggers(triggers)