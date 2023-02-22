local EHI = EHI
local achievements =
{
    fort_4 =
    {
        elements =
        {
            [100107] = { time = 240, class = EHI.Trackers.Achievement },
            [101412] = { special_function = EHI.SpecialFunctions.SetAchievementComplete }
        },
        load_sync = function(self)
            self:AddTimedAchievementTracker("fort_4", 240)
        end
    }
}

EHI:ParseTriggers({
    achievement = achievements
})

local DisableWaypoints = {}
for i = 0, 4800, 300 do
    DisableWaypoints[EHI:GetInstanceElementID(100012, i)] = true
end
EHI:DisableWaypoints(DisableWaypoints)