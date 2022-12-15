local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local achievements = {
    hunter_fall =
    {
        beardlib = true,
        package = "hunter_all",
        elements =
        {
            [100077] = { time = 62, icons = { "ehi_hunter_fall" }, class = TT.Achievement, special_function = SF.ShowAchievementFromStart }
        }
    }
}

EHI:ParseTriggers({
    mission = {},
    achievement = achievements
})