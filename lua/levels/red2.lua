local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local CF = EHI.ConditionFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove("overkill")
local triggers = {
    [101299] = { time = 300, id = "Thermite", icons = { Icon.Fire }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1012991 } },
    [1012991] = { time = 90, id = "ThermiteShorterTime", icons = { Icon.Fire, Icon.Wait }, class = TT.Warning }, -- Triggered by 101299
    [101325] = { special_function = SF.TriggerIfEnabled, data = { 1013251, 1013252 } },
    [1013251] = { time = 180, id = "Thermite", icons = { Icon.Fire }, special_function = SF.SetTimeOrCreateTracker },
    [1013252] = { id = "ThermiteShorterTime", special_function = SF.RemoveTracker },
    [103373] = { time = 817, id = "green_3", class = TT.Achievement },
    [107072] = { id = "cac_10", special_function = SF.SetAchievementComplete },
    [101544] = { id = "cac_10", special_function = SF.RemoveTriggerAndStartAchievementCountdown },
    [101341] = { time = 30, id = "cac_10", class = TT.AchievementTimedProgressTracker, condition = show_achievement and ovk_and_up, condition_function = CF.IsLoud, dont_flash_max = true },
    [107066] = { id = "cac_10", special_function = SF.IncreaseProgressMax },
    [107067] = { id = "cac_10", special_function = SF.IncreaseProgress },
    [101684] = { time = 5.1, id = "C4", icons = { "pd2_c4" } },
    [102567] = { id = "green_3", special_function = SF.SetAchievementFailed }
}
local DisableWaypoints = {}
for i = 0, 300, 100 do
    -- Hacking PC (repair icon)
    DisableWaypoints[EHI:GetInstanceElementID(100024, i)] = true
end

EHI:ParseTriggers(triggers)
EHI:DisableWaypoints(DisableWaypoints)