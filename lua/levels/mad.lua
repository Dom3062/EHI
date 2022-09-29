local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers = {
    [100891] = { time = 320/30 + 5, random_time = 5, id = "EMPBombDrop", icons = { Icon.Goto } },

    [EHI:GetInstanceElementID(100019, 3150)] = { time = 90, id = "Scan", icons = { "mad_scan" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [EHI:GetInstanceElementID(100049, 3150)] = { id = "Scan", special_function = SF.PauseTracker },
    [EHI:GetInstanceElementID(100030, 3150)] = { id = "Scan", special_function = SF.RemoveTracker }, -- Just in case

    [EHI:GetInstanceElementID(100013, 1350)] = { time = 120, id = "EMP", icons = { Icon.Defend }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [EHI:GetInstanceElementID(100023, 1350)] = { id = "EMP", special_function = SF.PauseTracker }
}
if Network:is_client() then
    triggers[101410] = { id = "Scan", special_function = SF.RemoveTracker } -- Just in case
end

local achievements =
{
    [100547] = { special_function = SF.Trigger, data = { 1005471, 1005472 } },
    [1005471] = { id = "mad_2", status = "no_down", class = TT.AchievementStatus, difficulty_pass = ovk_and_up, exclude_from_sync = true },
    [1005472] = { id = "cac_13", class = TT.AchievementStatus, difficulty_pass = ovk_and_up, exclude_from_sync = true },

    [101400] = { id = "mad_2", special_function = SF.SetAchievementFailed },
    [101823] = { id = "mad_2", special_function = SF.SetAchievementComplete },

    [101925] = { id = "cac_13", special_function = SF.SetAchievementFailed },
    [101924] = { id = "cac_13", special_function = SF.SetAchievementComplete }
}

local dailies = nil
if EHI:IsDailyAvailable("daily_cake") then
    dailies =
    {
        [101906] = { time = 1200, id = "daily_cake", icons = { Icon.Escape }, class = TT.Daily, difficulty_pass = ovk_and_up, exclude_from_sync = true },
        [101898] = { id = "daily_cake", special_function = SF.SetAchievementComplete }
    }
end

local DisableWaypoints =
{
    [EHI:GetInstanceElementID(100112, 7315)] = true, -- Defend
    [EHI:GetInstanceElementID(100112, 7615)] = true -- Defend
}
EHI:DisableWaypoints(DisableWaypoints)
EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    daily = dailies
})