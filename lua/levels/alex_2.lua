local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local VanCrashChance = { { icon = Icon.Car, color = Color.red } }
local assault_delay = 15 + 1 + 30
local ShowAssaultDelay = EHI:GetOption("show_assault_delay_tracker")
local other =
{
    [104488] = { time = assault_delay, id = "AssaultDelay", class = TT.AssaultDelay, special_function = SF.SetTimeOrCreateTracker, condition = ShowAssaultDelay },
    [104489] = { time = assault_delay, id = "AssaultDelay", class = TT.AssaultDelay, special_function = SF.AddTrackerIfDoesNotExist, condition = ShowAssaultDelay },
    -- Police ambush
    [104535] = { time = 30, id = "AssaultDelay", class = TT.AssaultDelay, special_function = SF.SetTimeOrCreateTracker, condition = ShowAssaultDelay },

    [100342] = { chance = 25, id = "EscapeChance", icons = VanCrashChance, class = TT.Chance },

    [103696] = { special_function = SF.CustomCode, f = function()
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
        local spawned = managers.ehi:CountLootbagsOnTheGround()
        local additional_loot = math.max(0, spawned - 3)
        EHI:ShowLootCounter({
            max = spawned,
            additional_loot = additional_loot,
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
    end}
}

EHI:ParseTriggers({}, nil, other)
EHI:AddOnAlarmCallback(function(dropin)
    if dropin or not ShowAssaultDelay then
        return
    end
    managers.ehi:AddTracker({
        id = "AssaultDelay",
        time = 75 + 15 + 30,
        class = TT.AssaultDelay
    })
end)