local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local delay = 17 + 30 + 450/30 -- Boat escape; Van escape is in CoreElementUnitSequence
local triggers = {
    [100259] = { time = 120 + delay },
    [100258] = { time = 100 + delay },
    [100257] = { time = 80 + delay },
    [100209] = { time = 60 + delay },

    [100215] = { time = 674/30, special_function = SF.SetTimeOrCreateTracker },
    [100216] = { time = 543/30, special_function = SF.SetTimeOrCreateTracker },

    [104800] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
}
EHI:AddOnAlarmCallback(function(dropin)
    managers.ehi:AddEscapeChanceTracker(dropin, 15)
end)

EHI:ParseTriggers(triggers, "Escape", { Icon.Escape, Icon.LootDrop })