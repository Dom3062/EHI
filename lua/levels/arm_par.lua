local van_delay = 543/30
local triggers = {
    [100258] = { time = 120 + van_delay },
    [100257] = { time = 100 + van_delay },
    [100209] = { time = 80 + van_delay },
    [100208] = { time = 60 + van_delay },

    -- Heli
    [102200] = { time = 23, special_function = EHI.SpecialFunctions.SetTimeOrCreateTracker }
}
EHI:AddOnAlarmCallback(function(dropin)
    managers.ehi:AddEscapeChanceTracker(false, 15)
end)

EHI:ParseTriggers(triggers, "Escape", { EHI.Icons.Escape, EHI.Icons.LootDrop })