local EHI, EM = EHI, EHIManager
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local assault_delay = 15 + 1 + 30
local other =
{
    [104488] = EHI:AddAssaultDelay({ time = assault_delay, special_function = SF.SetTimeOrCreateTracker }),
    [104489] = EHI:AddAssaultDelay({ time = assault_delay, special_function = SF.AddTrackerIfDoesNotExist }),
    -- Police ambush
    [104535] = { special_function = SF.Trigger, data = { 1045351, 1045352 } },
    [1045351] = EHI:AddAssaultDelay({ time = 30, special_function = SF.SetTimeOrCreateTracker }),
    [1045352] = { special_function = SF.RemoveTrigger, data = { 104488, 104489 } }
}
if EHI:IsLootCounterVisible() then
    local loot_trigger = { special_function = EHI:RegisterCustomSpecialFunction(function(self, trigger, element, ...)
        ---@type LootCounterSequenceTriggersTable
        local SafeTriggers =
        {
            -- gen_interactable_sec_safe_05x05 - 7
            -- gen_interactable_sec_safe_2x05 - 5
            -- gen_interactable_sec_safe_1x1 - 2
            -- gen_interactable_sec_safe_1x05 - 2
            loot =
            {
                "spawn_loot_money"
            },
            no_loot =
            {
                "spawn_loot_value_a",
                "spawn_loot_value_d",
                "spawn_loot_value_e",
                "spawn_loot_crap_b",
                "spawn_loot_crap_c",
                "spawn_loot_crap_d"
            }
        }
        local spawned = element._values.value
        EHI:ShowLootCounterNoChecks({
            max = spawned + math.max(0, spawned - 3),
            max_random = 1,
            sequence_triggers =
            {
                [103640] = SafeTriggers,
                [103641] = SafeTriggers,
                [101741] = SafeTriggers,
                [101751] = SafeTriggers,
                [103645] = SafeTriggers,
                [103646] = SafeTriggers,
                [103647] = SafeTriggers,
                [103648] = SafeTriggers,
                [103649] = SafeTriggers,
                [103650] = SafeTriggers,
                [103651] = SafeTriggers,
                [103777] = SafeTriggers,
                [103643] = SafeTriggers,
                [101099] = SafeTriggers,
                [101031] = SafeTriggers,
                [101211] = SafeTriggers
            }
        })
    end)}
    for i = 103715, 103724, 1 do
        other[i] = loot_trigger
    end
end
if EHI:GetOption("show_escape_chance") then
    other[100342] = { special_function = EHI:RegisterCustomSpecialFunction(function(self, ...)
        self._escape:AddChanceWhenDoesNotExists(false, 25)
    end) }
end
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[104496] = { time = 120, count_on_refresh = 1, id = "Snipers", class = TT.Sniper.TimedCount }
    other[100063] = { time = 90, id = "Snipers", special_function = EHI:RegisterCustomSpecialFunction(function(self, trigger, ...)
        if self._trackers:TrackerExists(trigger.id) then
            self._trackers:CallFunction(trigger.id, "SetRespawnTime", trigger.time)
        else
            self._trackers:AddTracker({
                id = trigger.id,
                time = trigger.time,
                count_on_refresh = 1,
                class = TT.Sniper.TimedCount
            })
        end
    end)}
end

EHI:ParseTriggers({
    other = other
})
local CombineAssault = EHI:CombineAssaultDelayAndAssaultTime()
local ShowAssaultDelay = EHI:GetOption("show_assault_delay_tracker") or CombineAssault
EHI:AddOnAlarmCallback(function(dropin)
    if dropin then
        EM:Trigger(100342)
        return
    end
    if not ShowAssaultDelay or (EM._trackers:TrackerExists("AssaultDelay") or EM._trackers:TrackerExists("Assault")) then
        return
    end
    EM._trackers:AddTracker({
        id = CombineAssault and "Assault" or "AssaultDelay",
        time = 75 + 15 + 30,
        class = CombineAssault and TT.Assault.Assault or TT.Assault.Delay
    })
end)
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 4000, name = "rats2_info_destroyed" },
        { amount = 6000, name = "rats2_trade" },
        { amount = 4000, name = "rats2_trade_and_steal" }
    },
    total_xp_override =
    {
        params =
        {
            min =
            {
                objectives =
                {
                    rats2_info_destroyed = true
                }
            },
            max =
            {
                objectives =
                {
                    rats2_trade = true,
                    rats2_trade_and_steal = true
                }
            }
        }
    }
})