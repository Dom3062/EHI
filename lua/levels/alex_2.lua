local EHI, EM = EHI, managers.ehi_manager
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local other =
{
    [104488] = EHI:AddAssaultDelay({ control = 16, special_function = SF.SetTimeOrCreateTracker }),
    [104489] = EHI:AddAssaultDelay({ control = 16, special_function = SF.AddTrackerIfDoesNotExist }),
    -- Police ambush
    [104535] = { special_function = SF.Trigger, data = { 1045351, 1045352 } },
    [1045351] = EHI:AddAssaultDelay({ special_function = SF.SetTimeOrCreateTracker }), -- 30s
    [1045352] = { special_function = SF.RemoveTrigger, data = { 104488, 104489 } }
}
if EHI:IsLootCounterVisible() then
    local loot_trigger = EHI:AddLootCounter3(function(self, trigger, element, ...) ---@param element ElementJobValue
        local spawned = element._values.value
        EHI:ShowLootCounterNoChecks({
            max = spawned + math.max(0, spawned - 3),
            max_random = 1,
            carry_data =
            {
                loot = true,
                no_loot = true
            },
            skip_offset = true
        })
    end)
    for i = 103715, 103724, 1 do
        other[i] = loot_trigger
    end
end
if EHI:GetOption("show_escape_chance") then
    other[100342] = EHI:AddEscapeChance(25, true)
end
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[104496] = { time = 120, count_on_refresh = 1, id = "Snipers", class = TT.Sniper.TimedCount }
    other[100063] = { time = 90, id = "Snipers", special_function = EHI.Manager:RegisterCustomSF(function(self, trigger, ...)
        local id = trigger.id
        if self._trackers:CallFunction2(id, "SetRespawnTime", trigger.time) then
            self._trackers:AddTracker({
                id = id,
                time = trigger.time,
                count_on_refresh = 1,
                class = TT.Sniper.TimedCount,
                hint = Hints.EnemySnipers
            })
        end
    end)}
end

EHI.Manager:ParseTriggers({
    other = other
})
EHI:AddOnAlarmCallback(function(dropin)
    if dropin then
        EM:Trigger(100342)
        return
    end
    managers.ehi_assault:StartAssaultCountdown(75 + 15 + 30, true)
end)
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 4000, name = "rats2_info_destroyed" },
        { _or = true },
        { amount = 6000, name = "rats2_trade" },
        { _or = true },
        { amount = 6000 + 4000, name = "rats2_trade_and_steal" } -- Previous XP is counted too
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
                    rats2_trade_and_steal = true
                }
            }
        }
    }
})