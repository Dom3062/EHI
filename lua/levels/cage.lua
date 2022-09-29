local EHI = EHI
local achievements = {
    [100107] = { time = 240, id = "fort_4", class = EHI.Trackers.Achievement }
}

EHI:ParseTriggers({
    mission = {},
    achievement = achievements
})
if EHI:ShowMissionAchievements() then
    EHI:AddLoadSyncFunction(function(self)
        self:AddTimedAchievementTracker("fort_4", 240)
    end)
end