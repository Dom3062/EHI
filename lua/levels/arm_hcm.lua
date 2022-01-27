local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local van_delay = 363/30
local triggers = {
    [100215] = { time = 120 + van_delay },
    [100216] = { time = 100 + van_delay },
    [100218] = { time = 80 + van_delay },
    [100219] = { time = 60 + van_delay },

    -- Heli
    [102200] = { special_function = SF.Trigger, data = { 1022001, 1022002 } },
    [1022001] = { time = 23, special_function = SF.SetTimeOrCreateTracker },
    [1022002] = { id = 102650, special_function = SF.ShowWaypoint, data = { icon = Icon.LootDrop, position = Vector3(2600, -824, 1950) } },

    [100214] = { id = 100233, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(2316.1, 6102.57, 1500.15) } },

    [101620] = { special_function = SF.Trigger, data = { 1016201, 1016202 } },
    [1016201] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElementSpecify, element = 101620 },
    [1016202] = { special_function = SF.RemoveTriggers, data = { 101620 } }
}
EHI:AddOnAlarmCallback(function(dropin)
    managers.ehi:AddEscapeChanceTracker(dropin, 10)
end)

EHI:ParseTriggers(triggers, "Escape", { Icon.Escape, Icon.LootDrop })