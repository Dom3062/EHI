local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
---@param self EHIMissionElementTrigger
---@param trigger ElementTrigger
local function ShowEscapeWaypoint(self, trigger)
    self._waypoints:AddWaypoint(trigger.id, {
        time = trigger.time,
        icon = Icon.LootDrop,
        position = Vector3()
    })
end
local UpdateEscapeWaypointPosition = EHI.Trigger:RegisterCustomSF(function(self, trigger, ...)
    self._waypoints:SetWaypointPosition("Escape", self._mission:GetElementPositionOrDefault(trigger.waypoint_id))
end)
---@type ParseTriggerTable
local triggers = {
    [102449] = { time = 240, hint = Hints.LootEscape, waypoint_f = ShowEscapeWaypoint },
    [102450] = { time = 180, hint = Hints.LootEscape, waypoint_f = ShowEscapeWaypoint },
    [102451] = { time = 300, hint = Hints.LootEscape, waypoint_f = ShowEscapeWaypoint },

    [100779] = { waypoint_id = 100786, special_function = UpdateEscapeWaypointPosition },
    [100780] = { waypoint_id = 100783, special_function = UpdateEscapeWaypointPosition },
    [100781] = { waypoint_id = 100784, special_function = UpdateEscapeWaypointPosition },
    [100782] = { waypoint_id = 100785, special_function = UpdateEscapeWaypointPosition }
}

if EHI.IsClient then
    triggers[100606] = { time = 240, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.LootEscape }
    triggers[100593] = { time = 180, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.LootEscape }
    triggers[100607] = { time = 120, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.LootEscape }
    triggers[100601] = { time = 60, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.LootEscape }
    triggers[100602] = { time = 30, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.LootEscape }
end

---@type ParseAchievementTable
local achievements =
{
    king_of_the_hill =
    {
        elements =
        {
            [102444] = { status = EHI.Const.Trackers.Achievement.Status.Defend, class = TT.Achievement.Status },
            [101297] = { special_function = SF.SetAchievementFailed },
            [101343] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local other =
{
    [102444] = EHI:AddAssaultDelay({ control = 25 })
}
if EHI:IsLootCounterVisible() then
    other[102293] = EHI:AddLootCounter4(function(self, ...)
        if not self._cache.CreateCounter then
            EHI:ShowLootCounterNoChecks({ skip_offset = true })
            self._cache.CreateCounter = true
        end
        self._loot:IncreaseLootCounterProgressMax()
    end, { element = { 101918, 101942, 101943, 101945 } })
end
if EHI:GetWaypointOption("show_waypoints_escape") then
    other[101285] = { special_function = SF.ShowWaypoint, data = { skip_if_waypoint_exists = "Escape", icon = Icon.Car, position_from_element = 100786 } }
    other[101286] = { special_function = SF.ShowWaypoint, data = { skip_if_waypoint_exists = "Escape", icon = Icon.Car, position_from_element = 100783 } }
    other[101287] = { special_function = SF.ShowWaypoint, data = { skip_if_waypoint_exists = "Escape", icon = Icon.Car, position_from_element = 100784 } }
    other[101284] = { special_function = SF.ShowWaypoint, data = { skip_if_waypoint_exists = "Escape", icon = Icon.Car, position_from_element = 100785 } }
end
EHI.Mission:ParseTriggers({ mission = triggers, achievement = achievements, other = other }, "Escape", Icon.CarEscape)

tweak_data.ehi.functions.achievements.armored_4()
tweak_data.ehi.functions.achievements.uno_1()
EHI:AddXPBreakdown({
    objective =
    {
        escape = 8000
    },
    no_total_xp = true
})