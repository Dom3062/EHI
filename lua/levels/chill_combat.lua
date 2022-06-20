local EHI = EHI
if EHI:GetOption("show_achievement") and EHI:IsDifficultyOrAbove("death_wish") then
    local SF = EHI.SpecialFunctions
    local TT = EHI.Trackers
    local triggers = {
        [100979] = { id = "cac_30", class = TT.AchievementNotification, exclude_from_sync = true },
        [102831] = { id = "cac_30", special_function = SF.SetAchievementComplete },
        [102829] = { id = "cac_30", special_function = SF.SetAchievementFailed }
    }

    EHI:ParseTriggers(triggers)
end