local orange_5 = class(EHIAchievementProgressTracker)
function orange_5:Finalize()
    if self._progress < self._max then
        self:SetFailed()
    end
end

local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local triggers = {
    [100866] = { time = 5, id = "C4Explosion", icons = { Icon.C4 }, hint = Hints.Explosion }
}

local mayhem_and_up = EHI:IsMayhemOrAbove()
---@type ParseAchievementTable
local achievements =
{
    orange_4 =
    {
        difficulty_pass = mayhem_and_up,
        elements =
        {
            [EHI:GetInstanceElementID(100459, 21700)] = { time = 284, class = TT.Achievement.Base },
            [EHI:GetInstanceElementID(100461, 21700)] = { special_function = SF.SetAchievementComplete },
        }
    },
    orange_5 =
    {
        difficulty_pass = mayhem_and_up,
        elements =
        {
            [100279] = { max = 15, class_table = orange_5, status_is_overridable = true, show_finish_after_reaching_target = true },
            [EHI:GetInstanceElementID(100471, 21700)] = { special_function = SF.SetAchievementFailed },
            [EHI:GetInstanceElementID(100474, 21700)] = { special_function = SF.IncreaseProgress },
            [EHI:GetInstanceElementID(100005, 12200)] = { special_function = SF.FinalizeAchievement }
        }
    }
}
local other =
{
    [101315] = EHI:AddAssaultDelay({}) -- 30s
}
EHI.Mission:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
local waypoint_elements = {}
table.insert(waypoint_elements, EHI:GetInstanceElementID(100016, 1800))
table.insert(waypoint_elements, EHI:GetInstanceElementID(100016, 1900))
for i = 7000, 7300, 100 do
    table.insert(waypoint_elements, EHI:GetInstanceElementID(100016, i))
end
for i = 10800, 12100, 100 do
    table.insert(waypoint_elements, EHI:GetInstanceElementID(100016, i))
end
table.insert(waypoint_elements, EHI:GetInstanceElementID(100016, 3900))
EHI:ShowLootCounter({
    max_bags_for_level =
    {
        mission_xp = 8000,
        xp_per_bag_all = 850,
        objective_triggers = { 102461 }
    },
    no_max = true
}, { element = waypoint_elements })

EHI.Unit:UpdateUnits({
    --units/pd2_dlc_chill/props/chl_prop_timer_large/chl_prop_timer_large
    [400003] = { ignore = true }
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 6000, name = "prison_entered" },
        { escape = 8000 }
    },
    loot_all = 850,
    total_xp_override =
    {
        params =
        {
            min =
            {
                objectives = true
            },
            max_level = true,
            max_level_bags_with_objectives = true
        }
    }
})