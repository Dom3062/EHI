local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
---@type ParseAchievementTable
local achievements = {
    hunter_fall =
    {
        elements =
        {
            [100077] = { time = 62, class = TT.Achievement.Base, condition_function = EHI.ConditionFunctions.PlayingFromStart }
        }
    }
}
EHI:PreparseBeardlibAchievements(achievements, "hunter_all")

EHI.Mission:ParseTriggers({
    achievement = achievements
})