local EHI = EHI
---@type ParseAchievementTable
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
            self._trackers:AddTimedAchievementTracker("fort_4", 240)
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
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 3000, name = "correct_pc_hack" },
        { amount = 3000, name = "c4_set_up" },
        { amount = 1000, name = "car_shop_car_secured" },
        { escape = 3000 }
    },
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                objectives =
                {
                    car_shop_car_secured = { max = 4 }
                }
            }
        }
    }
})