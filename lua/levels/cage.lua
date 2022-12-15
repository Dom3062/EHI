local EHI = EHI
local achievements =
{
    fort_4 =
    {
        elements =
        {
            [100107] = { time = 240, class = EHI.Trackers.Achievement }
        },
        load_sync = function(self)
            self:AddTimedAchievementTracker("fort_4", 240)
        end
    }
}

EHI:ParseTriggers({
    mission = {},
    achievement = achievements
})