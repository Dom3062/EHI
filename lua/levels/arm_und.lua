local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local van_delay = 674/30
local preload =
{
    { hint = EHI.Hints.LootEscape } -- Escape
}
local triggers = {
    [101235] = { run = { time = 120 + van_delay } },
    [100257] = { run = { time = 100 + van_delay } },
    [100209] = { run = { time = 80 + van_delay } },
    [100208] = { run = { time = 60 + van_delay } },

    [100214] = { run = { time = van_delay }, special_function = SF.AddTrackerIfDoesNotExist },
    [100215] = { run = { time = van_delay }, special_function = SF.AddTrackerIfDoesNotExist },
    [100216] = { run = { time = van_delay }, special_function = SF.AddTrackerIfDoesNotExist }
}
local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 60 })
}
if EHI:IsEscapeChanceEnabled() then
    other[100677] = managers.ehi_escape:IncreaseChanceFromTrigger() -- +5%
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi_escape:AddEscapeChanceTracker(dropin, 10)
    end)
end
if EHI:IsLootCounterVisible() then
    ---@param count number
    local function LootCounter(count)
        EHI:ShowLootCounterNoChecks({
            max_random = count * 9,
            carry_data =
            {
                at_loot = true,
                no_at_loot = true
            },
            client_from_start = true
        })
        managers.ehi_loot:SetCountOfArmoredTransports(count)
    end
    other[100238] = { special_function = SF.CustomCode, f = LootCounter, arg = 1 }
    other[101231] = { special_function = SF.CustomCode, f = LootCounter, arg = 2 }
    other[101947] = { special_function = SF.CustomCode, f = LootCounter, arg = 3 }
    other[102037] = { special_function = SF.CustomCode, f = LootCounter, arg = 4 }
    EHI:ShowLootCounterWaypoint({ element = { 100233, 100008, 100020, 101268, 101273 } })
end
if EHI:GetWaypointOption("show_waypoints_escape") then
    other[100214] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 100233 } }
    other[100215] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 101268 } }
    other[100216] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 100008 } }
end
tweak_data.ehi.functions.achievements.armored_4()
EHI.Mission:ParseTriggers({ mission = triggers, other = other, preload = preload }, "Escape", Icon.CarEscape)
local MinBags = EHI:GetValueBasedOnDifficulty({
    normal = 2,
    hard = 3,
    veryhard = 4,
    overkill_or_above = 5
})
EHI:AddXPBreakdown({
    objective =
    {
        escape = 12000
    },
    loot_all = 1000,
    total_xp_override =
    {
        params =
        {
            min_max = { loot_all = { min = MinBags, max = 16 } }
        }
    }
})