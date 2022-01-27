local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local van_delay = 674/30
local triggers = {
    [101880] = { time = 120 + van_delay },
    [101881] = { time = 100 + van_delay },
    [101882] = { time = 80 + van_delay },
    [101883] = { time = 60 + van_delay },

    [100916] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement },

    [100214] = { id = 100233, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(1200, -4328, 99.9998) } },
    [100215] = { id = 100008, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(1182, 4211, 99.9998) } }
}
EHI:AddOnAlarmCallback(function(dropin)
    managers.ehi:AddEscapeChanceTracker(dropin, 15)
end)

EHI:ParseTriggers(triggers, "Escape", Icon.CarEscape)