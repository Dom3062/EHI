local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local drill_delay = 30 + 2 + 1.5
local escape_delay = 3 + 27 + 1
local triggers = {
    [101855] = { time = 120 + drill_delay, id = "LanceDrop", icons = Icon.HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist },
    [101854] = { time = 90 + drill_delay, id = "LanceDrop", icons = Icon.HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist },
    [101853] = { time = 60 + drill_delay, id = "LanceDrop", icons = Icon.HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist },
    [101849] = { time = 30 + drill_delay, id = "LanceDrop", icons = Icon.HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist },
    [101844] = { time = drill_delay, id = "LanceDrop", icons = Icon.HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist },

    [102223] = { time = 90 + escape_delay, id = "Escape", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist },
    [102188] = { time = 60 + escape_delay, id = "Escape", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist },
    [102187] = { time = 45 + escape_delay, id = "Escape", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist },
    [102186] = { time = 30 + escape_delay, id = "Escape", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist },
    [102190] = { time = escape_delay, id = "Escape", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
}

EHI:ParseTriggers(triggers)