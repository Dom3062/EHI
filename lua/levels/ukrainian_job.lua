local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local Status = EHI.Const.Trackers.Achievement.Status
local zone_delay = 12
---@param self EHIManager
---@param trigger ElementTrigger
local function VanDriveAwayWP(self, trigger)
    self._loot:ReplaceWaypoint(104215, true)
    self._waypoints:AddWaypoint(trigger.id, {
        time = trigger.time,
        icon = Icon.LootDrop,
        position = self:GetElementPositionOrDefault(104215),
        remove_vanilla_waypoint = 104215,
        class = self.Waypoints.Warning
    })
end
---@type ParseTriggerTable
local triggers = {
    [104176] = { time = 25 + zone_delay, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning, waypoint_f = VanDriveAwayWP, hint = Hints.LootTimed },
    [104178] = { time = 35 + zone_delay, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning, waypoint_f = VanDriveAwayWP, hint = Hints.LootTimed },

    [103172] = { time = 2 + 830/30, id = "Van", icons = Icon.CarEscape, hint = Hints.LootEscape },
    [103182] = { time = 600/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootEscape },
    [103181] = { time = 580/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootEscape },
    [101770] = { time = 650/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootEscape }
}

---@type ParseAchievementTable
local achievements =
{
    lets_do_this =
    {
        elements =
        {
            [100073] = { time = 36, class = TT.Achievement.Base },
            [101784] = { special_function = SF.SetAchievementComplete },
        },
        load_sync = function(self)
            self._unlockable:AddTimedAchievementTracker("lets_do_this", 36)
        end
    },
    cac_12 =
    {
        elements =
        {
            [100074] = { status = Status.Alarm, class = TT.Achievement.Status, special_function = EHI.Manager:RegisterCustomSF(function(self, trigger, ...)
                if self:InteractionExists("circuit_breaker_off") then
                    self:CreateTracker(trigger)
                end
            end) },
            [104406] = { status = Status.Finish, special_function = SF.SetAchievementStatus },
            [104408] = { special_function = SF.SetAchievementComplete },
            [104409] = { special_function = SF.SetAchievementFailed },
            [103116] = { special_function = SF.SetAchievementFailed }
        },
        sync_params = { from_start = true }
    }
}

local other =
{
    [104176] = EHI:AddAssaultDelay({ control = 25 + 90 }),
    [104178] = EHI:AddAssaultDelay({ control = 35 + 90 })
}
if EHI:IsLootCounterVisible() then
    other[100073] = EHI:AddLootCounter(function()
        EHI:ShowLootCounterNoChecks({ max = 10, client_from_start = true })
    end, { element = { 103216, 103217, 103218, 103219, 104215 } }, true, function(self)
        local jewelry = { 102948, 102949, 102950, 100005, 100006, 100013, 100014, 100007, 100008 }
        local jewelry_to_subtract = 0
        for _, jewelry_id in ipairs(jewelry) do
            if managers.game_play_central:IsMissionUnitDisabled(jewelry_id) then
                jewelry_to_subtract = jewelry_to_subtract + 1
            end
        end
        EHI:ShowLootCounterNoChecks({ max = 10 - jewelry_to_subtract, client_from_start = true })
        self._loot:SyncSecuredLoot()
    end, true)
    local DecreaseProgressMax = EHI.Manager:RegisterCustomSF(function(self, ...)
        self._loot:DecreaseLootCounterProgressMax()
    end)
    other[101613] = { special_function = DecreaseProgressMax }
    other[101617] = { special_function = DecreaseProgressMax }
    other[101637] = { special_function = DecreaseProgressMax }
    other[101754] = { special_function = DecreaseProgressMax }
    other[101852] = { special_function = DecreaseProgressMax }
    other[102018] = { special_function = DecreaseProgressMax }
    other[102091] = { special_function = DecreaseProgressMax }
    other[102098] = { special_function = DecreaseProgressMax }
    other[102126] = { special_function = DecreaseProgressMax }
end
if EHI:IsEscapeChanceEnabled() then
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
if EHI:GetWaypointOption("show_waypoints_escape") then
    other[103183] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 103194 } }
    other[103182] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 103193 } }
    other[103181] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 103192 } }
    other[101770] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 101776 } }
end
EHI.Manager:ParseTriggers({
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
            { amount = 10000, loud = true, escape_chance = { start_chance = EHI:GetValueBasedOnDifficulty({
                normal = 30,
                hard = 33,
                veryhard = 35,
                overkill_or_above = 37
            }), kill_add_chance = 5 } }
        }
    }
})