local EHI = EHI
local Icon = EHI.Icons
local TT = EHI.Trackers
local SF = EHI.SpecialFunctions
local triggers = {
    [102611] = { time = 1, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning },
    [102612] = { time = 3, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning },
    [102613] = { time = 5, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning },

    [100750] = { time = 120 + 80, id = "Van", icons = Icon.CarEscape },
    [101568] = { time = 20, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [101569] = { time = 40, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [101572] = { time = 60, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker },
    [101573] = { time = 80, id = "Van", icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist },

    [102622] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
}
EHI:AddOnAlarmCallback(function(dropin)
    managers.ehi:AddEscapeChanceTracker(dropin, 10)
end)

EHI:ParseTriggers(triggers)
--EHI:ShowLootCounter({ max = 18 })