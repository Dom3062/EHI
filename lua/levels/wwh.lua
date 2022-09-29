local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers = {
    [100322] = { time = 120, id = "Fuel", icons = { Icon.Water }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [100323] = { id = "Fuel", special_function = SF.PauseTracker }
}

if Network:is_client() then
    triggers[100047] = { time = 60, id = "Fuel", icons = { Icon.Water }, class = TT.Pausable, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[100049] = { time = 30, id = "Fuel", icons = { Icon.Water }, class = TT.Pausable, special_function = SF.AddTrackerIfDoesNotExist }
end

local DisableWaypoints = {}

for i = 6850, 7525, 225 do
    DisableWaypoints[EHI:GetInstanceElementID(100021, i)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100022, i)] = true -- Fix
end

local achievements =
{
    [100946] = { max = 4, id = "wwh_10", class = TT.AchievementProgress },
    [100012] = { id = "wwh_9", status = "defend", class = TT.AchievementStatus, difficulty_pass = ovk_and_up },
    [101250] = { id = "wwh_9", special_function = SF.SetAchievementFailed },
    [100082] = { id = "wwh_9", special_function = SF.SetAchievementComplete },
    [101226] = { id = "wwh_10", special_function = SF.IncreaseProgress }
}

local other =
{
    [100946] = { time = 10 + 5 + 3 + 30, id = "AssaultDelay", class = TT.AssaultDelay, condition = EHI:GetOption("show_assault_delay_tracker") }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:DisableWaypoints(DisableWaypoints)
EHI:ShowLootCounter({ max = 8 })
EHI._cache.diff = 1