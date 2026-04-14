local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local van_delay = 674/30
local preload =
{
    { hint = Hints.LootEscape } -- Escape
}
local triggers = {
    [101880] = { run = { time = 120 + van_delay } },
    [101881] = { run = { time = 100 + van_delay } },
    [101882] = { run = { time = 80 + van_delay } },
    [101883] = { run = { time = 60 + van_delay } }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 30 })
}
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
    other[102180] = { special_function = SF.CustomCode, f = LootCounter, arg = 2 }
    other[102181] = { special_function = SF.CustomCode, f = LootCounter, arg = 3 }
    other[102182] = { special_function = SF.CustomCode, f = LootCounter, arg = 4 }
    EHI:ShowLootCounterWaypoint({ element = { 100233, 100008, 100020 } })
end
if EHI:GetWaypointOption("show_waypoints_escape") then
    other[100214] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 100233 } }
    other[100215] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_from_element = 100008 } }
end
if EHI:IsEscapeChanceEnabled() then
    other[100916] = managers.ehi_escape:IncreaseChanceFromTrigger() -- +5%
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi_escape:AddEscapeChanceTracker(dropin, 15)
    end)
end
if EHI:GetLoadSniperTrackers() then
    other[100122] = { chance = 10, time = 60 + 1 + 25 + 35, on_fail_refresh_t = 35, on_success_refresh_t = 20 + 25 + 35, id = "Snipers", class = TT.Sniper.Loop, trigger_once = true, sniper_count = 2, special_function = SF.Snipers_CheckIfTrackerExists }
    other[100015] = EHI:CopyTrigger(other[100122], { time = 1 + 25 + 35 }, SF.AddTrackerIfDoesNotExist)
    other[100385] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100420] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[101934] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100418] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    if EHI.IsClient then
        EHI.Trigger:AddLoadSyncFunction(function(self)
            self._trackers:AddTracker({
                id = "Snipers",
                from_sync = true,
                count = EHISniperBase._alive_count,
                on_fail_refresh_t = 35,
                on_success_refresh_t = 20 + 25 + 35,
                sniper_count = 2,
                class = TT.Sniper.Loop
            })
        end)
    end
end
managers.ehi_hudlist:CallRightListItemFunction("Unit", "EnablePersistentSniperItem")
local MinBags = EHI:GetValueBasedOnDifficulty({
    normal = 2,
    hard = 3,
    veryhard = 4,
    overkill_or_above = 5
})
tweak_data.ehi.functions.achievements.armored_4()
EHI.Mission:ParseTriggers({ mission = triggers, other = other, preload = preload,
    assault =
    {
        diff_load_sync = function(self, assault_number, in_assault)
            if assault_number <= 0 or (assault_number == 1 and in_assault) then
                self._assault:SetDiff(0.65)
            elseif (assault_number == 1 and not in_assault) or (assault_number == 2 and in_assault) then
                self._assault:SetDiff(0.75)
            else
                self._assault:SetDiff(1)
            end
        end
    } }, "Escape", Icon.CarEscape)
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