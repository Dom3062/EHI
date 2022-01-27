local van_delay = 674/30
local triggers = {
    [101235] = { time = 120 + van_delay },
    [100257] = { time = 100 + van_delay },
    [100209] = { time = 80 + van_delay },
    [100208] = { time = 60 + van_delay },

    [100677] = { id = "EscapeChance", special_function = EHI.SpecialFunctions.IncreaseChanceFromElement }
}
EHI:AddOnAlarmCallback(function(dropin)
    managers.ehi:AddEscapeChanceTracker(dropin, 10)
end)

EHI:ParseTriggers(triggers, "Escape", EHI.Icons.CarEscape)