local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers = {
    [100946] = { max = 4, id = "wwh_10", class = TT.AchievementProgress },
    [100944] = { id = "wwh_9", status = "defend", class = TT.AchievementStatus, difficulty_pass = ovk_and_up },
    [101250] = { id = "wwh_9", special_function = SF.SetAchievementFailed },
    [100082] = { id = "wwh_9", special_function = SF.SetAchievementComplete },
    [100322] = { time = 120, id = "Fuel", icons = { "pd2_water_tap" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [100323] = { id = "Fuel", special_function = SF.PauseTracker },
    [101226] = { id = "wwh_10", special_function = SF.IncreaseProgress }
}

local DisableWaypoints = {}

for i = 6850, 7525, 225 do
    DisableWaypoints[EHI:GetInstanceElementID(100021, i)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100022, i)] = true -- Fix
end

EHI:ParseTriggers(triggers)
EHI:DisableWaypoints(DisableWaypoints)
EHI:ShowLootCounter({ max = 8 })