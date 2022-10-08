local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local achievements = {
    [100077] = { time = 62, id = "hunter_fall", icons = { "ehi_hunter_fall" }, class = TT.Achievement, special_function = SF.ShowAchievementFromStart, condition = EHI:IsBeardLibAchievementLocked("hunter_all", "hunter_fall") and EHI:ShowMissionAchievements(), beardlib = true }
}

EHI:ParseTriggers({
    mission = {},
    achievement = achievements
})