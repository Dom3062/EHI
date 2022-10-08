local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
dofile(EHI.LuaPath .. "levels/run.lua")
-- Triggers
EHI:UnhookTrigger(100144) -- Does not work in reworked version
EHI:UnhookTrigger(102876) -- Needs to be reworked -> 1st gas can
local triggers =
{
    -- Creates Fire tracker -> 1028762, copy of 100144
    -- Runs original trigger in run.lua -> 1028761
    -- Increases Gas count (original trigger in run.lua) -> 1
    [102876] = { special_function = SF.Trigger, data = { 1028762, 1028761, 1 } },
    [1028762] = { id = "GasAmount", class = "EHIGasTracker" }
}
if EHI:MissionTrackersAndWaypointEnabled() then
    triggers[102876].data[4] = 3
end

-- Achievements
local achievements =
{
    [100145] = { id = "run_9", special_function = SF.SetAchievementFailed },

    -- Difficulty is bugged, difficulty_overkill is not OVERKILL!, it is Very Hard
    [102426] = { time = 817, id = "str_speedrun", icons = { "ehi_str_speedrun" }, class = TT.Achievement, condition = EHI:ShowMissionAchievements() and EHI:IsBeardLibAchievementLocked("street_new_achievements", "str_speedrun") and EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard), beardlib = true },
    [100553] = { id = "str_speedrun", special_function = SF.SetAchievementComplete }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})