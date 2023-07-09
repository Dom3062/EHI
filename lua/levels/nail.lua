local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local triggers = {
    [101505] = { time = 10, id = "TruckDoorOpens", icons = { Icon.Door } },
    -- There are a lot of delays in the ID. Using average instead (5.2)
    [101806] = { time = 20 + 5.2, id = "ChemicalsDrop", icons = { Icon.Heli, Icon.Methlab, Icon.Goto } },

    [101936] = { time = 30 + 12, id = "Escape", icons = Icon.HeliEscapeNoLoot }
}

local other =
{
    [101612] = EHI:AddAssaultDelay({ time = 30 + 30 }),
    [101613] = EHI:AddAssaultDelay({ time = 30, special_function = SF.SetTimeOrCreateTracker })
}

EHI:ParseTriggers({ mission = triggers, other = other })

local tbl =
{
    --levels/instances/unique/nail_cloaker_safe
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    [EHI:GetInstanceUnitID(100014, 5020)] = { ignore = true },
    [EHI:GetInstanceUnitID(100056, 5020)] = { ignore = true },
    [EHI:GetInstanceUnitID(100226, 5020)] = { ignore = true },
    [EHI:GetInstanceUnitID(100227, 5020)] = { icons = { Icon.Vault }, remove_on_pause = true, completion = true }
}
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 2000, name = "lab_rats_added_ephedrin_pill" },
        { amount = 1000, name = "lab_rats_added_correct_ingredient" },
        { amount = 500, name = "lab_rats_bagged_meth" },
        { amount = 30000, name = "lab_rats_safe_event_1", optional = true },
        { amount = 22500, name = "lab_rats_safe_event_2", optional = true },
        { amount = 15000, name = "lab_rats_safe_event_3", optional = true },
        { escape = 5000 }
    },
    loot =
    {
        meth_half = 500,
    },
    no_total_xp = true
})