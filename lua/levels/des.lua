local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove("overkill")
local triggers = {
    [103391] = { id = "uno_5", special_function = SF.IncreaseProgress },
    [103395] = { id = "uno_5", special_function = SF.SetAchievementFailed },

    [103025] = { time = 3, id = "des_11", class = TT.Achievement },
    [102822] = { id = "des_11", special_function = SF.SetAchievementComplete },
    [100716] = { time = 30, id = "ChemLabThermite", icons = { Icon.Fire } },

    [100296] = { max = 2, id = "uno_5", class = TT.AchievementProgress, condition = show_achievement and ovk_and_up },
    [100423] = { time = 60 + 25 + 3, id = "EscapeHeli", icons = Icon.HeliEscape },
    -- 60s delay after flare has been placed
    -- 25s to land
    -- 3s to open the heli doors

    [102593] = { time = 30, id = "ChemSetReset", icons = { "restarter" } },
    [101217] = { time = 30, id = "ChemSetInterrupted", icons = { "restarter" }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "ChemSetCooking" } },
    [102595] = { time = 30, id = "ChemSetCooking", icons = { "pd2_defend" } },

    [102009] = { time = 60, id = "Crane", icons = { "equipment_winch_hook" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [101702] = { id = "Crane", special_function = SF.PauseTracker }
}
if Network:is_client() then
    triggers[100564] = { time = 25 + 3, id = "EscapeHeli", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    -- Not worth adding the 3s delay here
end

EHI:ParseTriggers(triggers)