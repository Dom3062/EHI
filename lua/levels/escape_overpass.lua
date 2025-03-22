local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local AddToCache = EHI.Manager:RegisterCustomSF(function(self, trigger, ...)
    self._cache[trigger.id] = trigger.data
end)
local GetFromCache = EHI.Manager:RegisterCustomSF(function(self, trigger, ...)
    local data = table.remove_key(self._cache, trigger.id) --[[@as { icon: string }? ]]
    if data and data.icon then
        trigger.icons[1] = data.icon
        if data.icon == Icon.Heli then
            trigger.waypoint = nil
        end
    else
        trigger.waypoint = nil
    end
    self:CreateTracker(trigger)
end)
local triggers = {
    [101145] = { time = 180, special_function = GetFromCache, icons = { "pd2_question", Icon.Escape, Icon.LootDrop }, hint = Hints.LootEscape, waypoint = { icon = Icon.Car, position_from_element = 102141 } },
    [101158] = { time = 240, special_function = GetFromCache, icons = { "pd2_question", Icon.Escape, Icon.LootDrop }, hint = Hints.LootEscape, waypoint = { icon = Icon.Car, position_from_element = 102141 } },
    [101977] = { special_function = AddToCache, data = { icon = Icon.Heli } },
    [101978] = { special_function = AddToCache, data = { icon = Icon.Heli } },
    [101979] = { special_function = AddToCache, data = { icon = Icon.Car } }
}

if EHI.IsClient then
    triggers[101515] = { time = 175, icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101532] = { time = 115, icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[102089] = { time = 60, icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101521] = { time = 30, icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101513] = { time = 175, icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist, waypoint = { icon = Icon.Car, position_from_element = 102141 } }
    triggers[101534] = { time = 115, icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist, waypoint = { icon = Icon.Car, position_from_element = 102141 } }
    triggers[102090] = { time = 60, icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist, waypoint = { icon = Icon.Car, position_from_element = 102141 } }
    triggers[101571] = { time = 30, icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist, waypoint = { icon = Icon.Car, position_from_element = 102141 } }
end

---@type ParseAchievementTable
local achievements =
{
    you_shall_not_pass =
    {
        elements =
        {
            [101148] = { status = EHI.Const.Trackers.Achievement.Status.Defend, class = TT.Achievement.Status },
            [102471] = { special_function = SF.SetAchievementFailed },
            [100426] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local other =
{
    [101975] = EHI:AddAssaultDelay({ control = 15, trigger_once = true })
}
if EHI:IsLootCounterVisible() then
    other[102564] = EHI:AddLootCounter4(function(self, ...)
        if not self._cache.CreateCounter then
            EHI:ShowLootCounterNoChecks({ skip_offset = true })
            self._cache.CreateCounter = true
        end
        self._loot:IncreaseLootCounterProgressMax()
    end, { element = { 102121, 102125, 102140 } })
end
if EHI:GetWaypointOption("show_waypoints_escape") then
    other[102110] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position_from_element = 102120 } } -- Heli
    other[102130] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position_from_element = 102138 } } -- Heli
end
EHI.Manager:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
}, "Escape")

EHI:AddXPBreakdown({
    objective =
    {
        escape = 8000
    },
    no_total_xp = true
})