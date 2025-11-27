local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local Status = EHI.Const.Trackers.Achievement.Status
local VanDriveAwayIcon = EHI.TrackerUtils:GetTrackerIcons(Icon.CarWait, { { icon = Icon.Car, color = Color.red } })
local escape_chance_start = EHI:GetValueBasedOnDifficulty({
    normal = 25,
    hard = 27,
    veryhard = 32,
    overkill_or_above = 36
})
local triggers = {
    [101541] = { time = 2, id = "VanDriveAway", icons = VanDriveAwayIcon, class = TT.Warning, hint = Hints.LootTimed },
    [101558] = { time = 5, id = "VanDriveAway", icons = VanDriveAwayIcon, class = TT.Warning, hint = Hints.LootTimed },
    [101601] = { time = 7, id = "VanDriveAway", icons = VanDriveAwayIcon, class = TT.Warning, hint = Hints.LootTimed },

    [103172] = { time = 45 + 830/30, id = "Van", icons = Icon.CarEscape, hint = Hints.LootEscape },
    [103182] = { time = 600/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootEscape },
    [103181] = { time = 580/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootEscape },
    [101770] = { time = 650/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootEscape }
}
local other =
{
    [100149] = EHI:AddAssaultDelay({ control = 7 + 80 })
}
if EHI:IsEscapeChanceEnabled() then
    other[101433] = managers.ehi_escape:IncreaseChanceFromTrigger() -- +5%
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi_escape:AddEscapeChanceTracker(dropin, escape_chance_start)
    end)
end
if EHI:GetWaypointOption("show_waypoints_escape") then
    other[103183] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 103216 } }
    other[103182] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 103217 } }
    other[103181] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 103218 } }
    other[101770] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 103219 } }
end
if EHI:IsLootCounterVisible() then
    local jewelry = { 102948, 102949, 102950, 100005, 100006, 100013, 100014, 100007, 100008 }
    other[100073] = EHI:AddLootCounter2(function()
        local jewelry_to_subtract = table.list_count(jewelry, function(id)
            return managers.game_play_central:IsMissionUnitDisabled(id)
        end)
        EHI:ShowLootCounterNoChecks({
            max = 10 - jewelry_to_subtract,
            -- If a drawer is missing, then a safe is here (random on Very Hard / OVERKILL, 100% chance on Mayhem+)
            -- 50% chance for other difficulties (also for Very Hard / OVERKILL if the first initial chance did not succeed) is in element 102029
            max_random = managers.game_play_central:IsMissionUnitDisabled(102186) and 2 or 0,
            client_from_start = true
        })
    end, { element = { 103216, 103217, 103218, 103219, 101155 } }, nil, true)
    other[102029] = EHI:AddCustomCode(function(self)
        self._loot:SetLootCounterMaxRandom(2)
    end)
    other[102131] = other[102029]
    other[102145] = other[102029]
    other[102182] = EHI:AddCustomCode(function(self)
        self._loot:RandomLootSpawnedAndDeclined(1, 2)
    end)
    other[102183] = EHI:AddCustomCode(function(self)
        self._loot:RandomLootSpawned(2)
    end)
end

---@type ParseAchievementTable
local achievements =
{
    ameno_7 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [100073] = { status = Status.Loud, class = TT.Achievement.Status },
            [100624] = { special_function = SF.SetAchievementFailed },
            [100634] = { special_function = SF.SetAchievementComplete },
            [100149] = { status = Status.Defend, special_function = SF.SetAchievementStatus }
        }
    }
}
tweak_data.ehi.functions.achievements.eng_X("eng_1") -- "The only one that is true" achievement
EHI.Mission:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:AddXPBreakdown({
    objective =
    {
        escape =
        {
            { amount = 2000, timer = 120, stealth = true },
            { amount = 6000, stealth = true },
            { amount = 8000, loud = true, escape_chance = { start_chance = escape_chance_start, kill_add_chance = 5 } }
        }
    }
})