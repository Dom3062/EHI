local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local van_delay = 363/30
local triggers = {
    [100215] = { time = 120 + van_delay, hint = Hints.LootEscape },
    [100216] = { time = 100 + van_delay, hint = Hints.LootEscape },
    [100218] = { time = 80 + van_delay, hint = Hints.LootEscape },
    [100219] = { time = 60 + van_delay, hint = Hints.LootEscape },

    -- Heli
    [102200] = { time = 23, special_function = SF.SetTimeOrCreateTracker }
}
local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 30 })
}
if EHI:IsEscapeChanceEnabled() then
    other[101620] = managers.ehi_escape:IncreaseChanceFromTrigger() -- +5%
    other[101620].trigger_once = true
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
            }
        })
        managers.ehi_loot:SetCountOfArmoredTransports(count)
    end
    other[100238] = { special_function = SF.CustomCode, f = LootCounter, arg = 1 }
    other[101197] = { special_function = SF.CustomCode, f = LootCounter, arg = 2 }
    other[101199] = { special_function = SF.CustomCode, f = LootCounter, arg = 3 }
    other[101204] = { special_function = SF.CustomCode, f = LootCounter, arg = 4 }
    EHI:ShowLootCounterWaypoint({ element = { 100233, 100008, 100020, 102650 } })
end
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100015] = { chance = 10, time = 1 + 35 + 30, on_fail_refresh_t = 30, on_success_refresh_t = 20 + 35 + 30, id = "Snipers", class = TT.Sniper.Loop, trigger_once = true, sniper_count = 2 }
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end
if EHI:GetWaypointOption("show_waypoints_escape") then
    other[102200] = { special_function = SF.ShowWaypoint, data = { icon = Icon.LootDrop, position_from_element = 102650 } }
    other[100214] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 100233 } }
end
tweak_data.ehi.functions.achievements.armored_4()
EHI.Mission:ParseTriggers({ mission = triggers, other = other }, "Escape", { Icon.Escape, Icon.LootDrop })
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