local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local VanCrashChance = { Icon.Car, Icon.Fire }
local assault_delay = 15 + 1 + 30
local triggers = {
    [104488] = { time = assault_delay, id = "FirstAssaultDelay", icons = Icon.FirstAssaultDelay, class = TT.Warning, special_function = SF.SetTimeOrCreateTracker },
    [104489] = { time = assault_delay, id = "FirstAssaultDelay", icons = Icon.FirstAssaultDelay, class = TT.Warning, special_function = SF.AddTrackerIfDoesNotExist },

    [100342] = { chance = 25, id = "EscapeChance", icons = VanCrashChance, class = TT.Chance }
}

EHI:ParseTriggers(triggers)