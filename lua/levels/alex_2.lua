local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local VanCrashChance = { Icon.Car, Icon.Fire }
local assault_delay = 15 + 1 + 30
local triggers = {
    [104488] = { time = assault_delay, id = "AssaultDelay", class = TT.AssaultDelay, special_function = SF.SetTimeOrCreateTracker },
    [104489] = { time = assault_delay, id = "AssaultDelay", class = TT.AssaultDelay, special_function = SF.AddTrackerIfDoesNotExist },

    [100342] = { chance = 25, id = "EscapeChance", icons = VanCrashChance, class = TT.Chance },

    -- Police ambush
    [104535] = { time = 30, id = "AssaultDelay", class = TT.AssaultDelay, special_function = SF.SetTimeOrCreateTracker }
}

EHI:ParseTriggers(triggers)
EHI:AddOnAlarmCallback(function(dropin)
    if dropin then
        return
    end
    managers.ehi:AddTracker({
        id = "AssaultDelay",
        time = 75 + 15 + 30,
        class = TT.AssaultDelay
    })
end)