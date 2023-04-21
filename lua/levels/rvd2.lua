local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local element_sync_triggers =
{
    [101374] = { id = "VaultTeargas", icons = { Icon.Teargas }, hook_element = 101377 }
}
local triggers = {
    [100903] = { time = 120, id = "LiquidNitrogen", icons = { Icon.LiquidNitrogen }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1009031 } },
    [1009031] = { time = 63 + 6 + 4 + 30 + 24 + 3, id = "HeliC4", icons = Icon.HeliDropC4 },

    [100699] = { time = 8 + 25 + 13, id = "ObjectiveWait", icons = { Icon.Wait } },

    [100939] = { time = 5, id = "C4Vault", icons = { Icon.C4 } },
    [EHI:GetInstanceElementID(100020, 6700)] = { time = 5, id = "C4Escape", icons = { Icon.C4 } }
}
if EHI:IsClient() then
    triggers[101366] = { time = 5 + 40, random_time = 10, id = "VaultTeargas", icons = { Icon.Teargas } }
    EHI:SetSyncTriggers(element_sync_triggers)
    local LiquidNitrogen = EHI:GetFreeCustomSpecialFunctionID()
    triggers[101498] = { time = 6 + 4 + 30 + 24 + 3, special_function = LiquidNitrogen }
    triggers[100035] = { time = 4 + 30 + 24 + 3, special_function = LiquidNitrogen }
    triggers[101630] = { time = 30 + 24 + 3, special_function = LiquidNitrogen }
    triggers[101629] = { time = 24 + 3, special_function = LiquidNitrogen }
    EHI:RegisterCustomSpecialFunction(LiquidNitrogen, function(trigger, ...)
        if managers.ehi:TrackerDoesNotExist("LiquidNitrogen") then
            managers.ehi:AddTracker({
                id = "LiquidNitrogen",
                time = trigger.time - 10,
                icons = { Icon.LiquidNitrogen }
            })
        end
        if managers.ehi:TrackerDoesNotExist("HeliC4") then
            managers.ehi:AddTracker({
                id = "HeliC4",
                time = trigger.time,
                icons = Icon.HeliDropC4
            })
        end
    end)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end
local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 30 + 30 })
}

EHI:ParseTriggers({ mission = triggers, other = other })
EHI:ShowAchievementLootCounter({
    achievement = "rvd_11",
    max = 19,
    counter =
    {
        check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
        loot_type = { "diamonds_dah", "diamonds" }
    }
})

local DisableWaypoints =
{
    [101768] = true, -- Defend PC
    [101765] = true, -- Fix PC

    [EHI:GetInstanceElementID(100034, 7300)] = true, -- Defend Hackbox
    [EHI:GetInstanceElementID(100031, 7300)] = true -- Fix Hackbox
    -- Second instance is not used, no need to have the waypoints here
}
EHI:DisableWaypoints(DisableWaypoints)
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 6000, name = "rvd2_hacking_done" },
        { amount = 2000, name = "vault_drills_done" },
        { amount = 4000, name = "rvd2_vault_frozen" },
        { amount = 2000, name = "c4_set_up" },
        { escape = 1000 }
    },
    loot_all = 500,
    total_xp_override =
    {
        params =
        {
            min =
            {
                objectives = true,
                loot_all = { times = 6 }
            },
            no_max = true
        }
    }
})