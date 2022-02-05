local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [100107] = { max = 4, id = "mex_9", class = TT.AchievementProgress },
    [101983] = { time = 15, id = "C4Trap", icons = { "pd2_c4" }, class = TT.Warning, special_function = SF.ExecuteIfElementIsEnabled },
    [101722] = { id = "C4Trap", special_function = SF.RemoveTracker },

    [102685] = { special_function = SF.Trigger, data = { 1026851, 1026852 } },
    [1026851] = { id = "Refueling", icons = { "pd2_water_tap" }, class = TT.Pausable, special_function = SF.MEX_CheckIfLoud, data = { yes = 121, no = 91 } },
    [1026852] = { special_function = SF.RemoveTriggers, data = { 102685 } },
    [102678] = { id = "Refueling", special_function = SF.UnpauseTracker },
    [102684] = { id = "Refueling", special_function = SF.PauseTracker }
}
for i = 101502, 101509, 1 do
    triggers[i] = { id = "mex_9", special_function = SF.IncreaseProgress }
end

EHI:ParseTriggers(triggers)