local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove("overkill")
local triggers = {
    [100891] = { time = 15.33, id = "emp_bomp_drop", icons = { "pd2_goto" } },
    [101906] = { time = 1200, id = "daily_cake", icons = { Icon.Trophy }, class = TT.Warning, condition = ovk_and_up, exclude_from_sync = true },
    [100547] = { special_function = SF.Trigger, data = { 1005471, 1005472 } },
    [1005471] = { id = "mad_2", class = TT.AchievementNotification, condition = show_achievement and ovk_and_up, exclude_from_sync = true },
    [1005472] = { id = "cac_13", class = TT.AchievementNotification, condition = show_achievement and ovk_and_up, exclude_from_sync = true },

    [EHI:GetInstanceElementID(100019, 3150)] = { time = 90, id = "Scan", icons = { "mad_scan" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [EHI:GetInstanceElementID(100049, 3150)] = { id = "Scan", special_function = SF.PauseTracker },
    [EHI:GetInstanceElementID(100030, 3150)] = { id = "Scan", special_function = SF.RemoveTracker }, -- Just in case

    [EHI:GetInstanceElementID(100013, 1350)] = { time = 120, id = "EMP", icons = { "pd2_defend" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [EHI:GetInstanceElementID(100023, 1350)] = { id = "EMP", special_function = SF.PauseTracker },

    [101400] = { id = "mad_2", special_function = SF.SetAchievementFailed },
    [101823] = { id = "mad_2", special_function = SF.SetAchievementComplete },

    [101925] = { id = "cac_13", special_function = SF.SetAchievementFailed },
    [101924] = { id = "cac_13", special_function = SF.SetAchievementComplete }
}
if Network:is_client() then
    triggers[101410] = { id = "Scan", special_function = SF.RemoveTracker } -- Just in case
end

EHI:ParseTriggers(triggers)