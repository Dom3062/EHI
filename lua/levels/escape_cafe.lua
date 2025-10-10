local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local ehi_functions = tweak_data.ehi.functions
local triggers = {
    [100247] = { time = 180, hint = Hints.LootEscape },
    [100248] = { time = 120, hint = Hints.LootEscape }
}

---@type ParseAchievementTable
local achievements =
{
    frappucino_to_go_please =
    {
        elements =
        {
            [100287] = { time = 30, class = TT.Achievement.Base },
            [101379] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local other =
{
    [100968] = EHI:AddLootCounter(ehi_functions.ShowNumberOfLootbagsOnTheGround, { element = { 100309, 100364, 101272 } }),
    [100969] = EHI:AddLootCounter(ehi_functions.ShowNumberOfLootbagsOnTheGround), -- No need to copy Waypoint elements, it will just spam BLT log
    [100970] = EHI:AddLootCounter(ehi_functions.ShowNumberOfLootbagsOnTheGround)
}
if EHI:GetWaypointOption("show_waypoints_escape") then
    other[100154] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 100318 } }
    other[100157] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 100314 } }
    other[100156] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 100367 } }
end

-- Bugged because one loot bag is not counted
-- Reported in:
-- https://steamcommunity.com/app/218620/discussions/14/3834297051382791123/
--[[if EHI:IsLootCounterVisible() then
    local CreateCounter = true
    other[101419] = EHI:AddLootCounter4(function(self, ...)
        if CreateCounter then
            EHI:ShowLootCounterNoChecks({})
            CreateCounter = false
        end
        self._loot:IncreaseLootCounterProgressMax()
    end)
end]]

EHI.Mission:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other,
    assault = { diff = 0.5 }
}, "Escape", Icon.CarEscape)

ehi_functions.achievements.uno_1()
EHI:AddXPBreakdown({
    objective =
    {
        escape = 6000
    },
    no_total_xp = true
})