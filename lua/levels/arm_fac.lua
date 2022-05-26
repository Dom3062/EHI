local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local delay = 17 + 30 + 450/30 -- Boat escape; Van escape is 100215 and 100216
local triggers = {
    [100259] = { time = 120 + delay },
    [100258] = { time = 100 + delay },
    [100257] = { time = 80 + delay },
    [100209] = { time = 60 + delay },

    [104800] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement },

    [100214] = { id = 100233, special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position = Vector3(-2274.11, -4387.6, 207.39) } },
    [100215] = { special_function = SF.Trigger, data = { 1002151, 1002152 } },
    [1002151] = { time = 674/30, special_function = SF.SetTimeOrCreateTracker },
    [1002152] = { id = 100008, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(3643, -4185, 331.9) } },
    [100216] = { special_function = SF.Trigger, data = { 1002161, 1002162 } },
    [1002161] = { time = 543/30, special_function = SF.SetTimeOrCreateTracker },
    [1002162] = { id = 100020, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(5412, -692, 300) } }
}
EHI:AddOnAlarmCallback(function(dropin)
    managers.ehi:AddEscapeChanceTracker(dropin, 15)
end)

EHI:ParseTriggers(triggers, "Escape", { Icon.Escape, Icon.LootDrop })