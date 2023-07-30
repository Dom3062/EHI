local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local zone_delay = 12
local LootDropWaypoint = { icon = Icon.LootDrop, position_by_element_and_remove_vanilla_waypoint = 104215 }
---@type ParseTriggerTable
local triggers = {
    [104176] = { time = 25 + zone_delay, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning, waypoint = deep_clone(LootDropWaypoint) },
    [104178] = { time = 35 + zone_delay, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning, waypoint = deep_clone(LootDropWaypoint) },

    [103172] = { time = 2 + 830/30, id = "Van", icons = Icon.CarEscape },
    [103183] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 103194 } },
    [103182] = { special_function = SF.Trigger, data = { 1031821, 1031822 } },
    [1031821] = { time = 600/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [1031822] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 103193 } },
    [103181] = { special_function = SF.Trigger, data = { 1031811, 1031812 } },
    [1031811] = { time = 580/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [1031812] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 103192 } },
    [101770] = { special_function = SF.Trigger, data = { 1017701, 1017702 } },
    [1017701] = { time = 650/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [1017702] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 101776 } }
}

---@type ParseAchievementTable
local achievements =
{
    lets_do_this =
    {
        elements =
        {
            [100073] = { time = 36, class = TT.Achievement },
            [101784] = { special_function = SF.SetAchievementComplete },
        },
        load_sync = function(self)
            self._trackers:AddTimedAchievementTracker("lets_do_this", 36)
        end
    },
    cac_12 =
    {
        elements =
        {
            [100074] = { status = "alarm", class = TT.AchievementStatus, special_function = EHI:RegisterCustomSpecialFunction(function(self, trigger, ...)
                if self:InteractionExists("circuit_breaker_off") then
                    self:CheckCondition(trigger)
                end
            end) },
            [104406] = { status = "finish", special_function = SF.SetAchievementStatus },
            [104408] = { special_function = SF.SetAchievementComplete },
            [104409] = { special_function = SF.SetAchievementFailed },
            [103116] = { special_function = SF.SetAchievementFailed }
        }
    }
}

local other =
{
    [104176] = EHI:AddAssaultDelay({ time = 25 + 90 }),
    [104178] = EHI:AddAssaultDelay({ time = 35 + 90 })
}
if EHI:GetOption("show_escape_chance") then
    local start_chance = 30 -- Normal
    if EHI:IsDifficulty(EHI.Difficulties.Hard) then
        start_chance = 33
    elseif EHI:IsDifficulty(EHI.Difficulties.VeryHard) then
        start_chance = 35
    elseif EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) then
        start_chance = 37
    end
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi_escape:AddEscapeChanceTracker(dropin, start_chance)
    end)
    other[101614] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:AddXPBreakdown({
    objective =
    {
        escape =
        {
            { amount = 4000, timer = 120, stealth = true },
            { amount = 10000, stealth = true },
            { amount = 10000, loud = true }
        }
    }
})