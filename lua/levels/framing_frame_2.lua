local EHI = EHI
local Icon = EHI.Icons
local triggers = {
    [103712] = { time = 25, id = "HeliTrade", icons = { Icon.Heli, Icon.LootDrop } }
}

local other =
{
    [102557] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
}

EHI:ParseTriggers(triggers, nil, other)
EHI:AddOnAlarmCallback(function(dropin)
    managers.ehi:AddEscapeChanceTracker(dropin, 24)
end)