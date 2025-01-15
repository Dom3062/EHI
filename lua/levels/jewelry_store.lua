local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local Status = EHI.Const.Trackers.Achievement.Status
local triggers = {
    [101541] = { time = 2, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning, hint = Hints.LootTimed },
    [101558] = { time = 5, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning, hint = Hints.LootTimed },
    [101601] = { time = 7, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning, hint = Hints.LootTimed },

    [103172] = { time = 45 + 830/30, id = "Van", icons = Icon.CarEscape, hint = Hints.LootEscape },
    [103182] = { time = 600/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootEscape },
    [103181] = { time = 580/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootEscape },
    [101770] = { time = 650/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootEscape }
}
local other = {}
if EHI:IsEscapeChanceEnabled() then
    other[101433] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
    local start_chance = EHI:GetValueBasedOnDifficulty({
        normal = 25,
        hard = 27,
        veryhard = 32,
        overkill_or_above = 36
    })
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi_escape:AddEscapeChanceTracker(dropin, start_chance)
    end)
end
if EHI:GetWaypointOption("show_waypoints_escape") then
    other[103183] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 103194 } }
    other[103182] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 103193 } }
    other[103181] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 103192 } }
    other[101770] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 101776 } }
end
if EHI:IsLootCounterVisible() then
    local jewelry = { 102948, 102949, 102950, 100005, 100006, 100013, 100014, 100007, 100008 }
    other[100073] = EHI:AddLootCounter3(function(...)
        local jewelry_to_subtract = 0
        for _, jewelry_id in ipairs(jewelry) do
            if managers.game_play_central:IsMissionUnitDisabled(jewelry_id) then
                jewelry_to_subtract = jewelry_to_subtract + 1
            end
        end
        EHI:ShowLootCounterNoChecks({
            max = 10 - jewelry_to_subtract,
            max_random = EHI:IsDifficultyOrAbove(EHI.Difficulties.Mayhem) and 2 or 0,
            client_from_start = true
        })
    end, true)
    other[102029] = EHI:AddCustomCode(function(self)
        self._loot:SetLootCounterMaxRandom(2)
    end)
    if EHI:IsBetweenDifficulties(EHI.Difficulties.VeryHard, EHI.Difficulties.OVERKILL) then
        other[102131] = other[102029]
    end
    other[102182] = EHI:AddCustomCode(function(self)
        self._loot:RandomLootSpawned(1)
        self._loot:RandomLootDeclined(1)
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
            { amount = 2000, timer = 120, stealth = true },
            { amount = 6000, stealth = true },
            { amount = 8000, loud = true, escape_chance = { start_chance = EHI:GetValueBasedOnDifficulty({
                normal = 25,
                hard = 27,
                veryhard = 32,
                overkill_or_above = 36
            }), kill_add_chance = 5 } }
        }
    }
})