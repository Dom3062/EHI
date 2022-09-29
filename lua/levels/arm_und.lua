local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local van_delay = 674/30
local triggers = {
    [101235] = { time = 120 + van_delay },
    [100257] = { time = 100 + van_delay },
    [100209] = { time = 80 + van_delay },
    [100208] = { time = 60 + van_delay },

    [1] = { time = van_delay, special_function = SF.AddTrackerIfDoesNotExist },
    [100214] = { special_function = SF.Trigger, data = { 1, 1002141 } },
    [1002141] = { id = 100233, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(5683, -3296, 397.65) } },
    [100215] = { special_function = SF.Trigger, data = { 1, 1002151 } },
    [1002151] = { id = 101268, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(-6250, -2700, 481.755) } },
    [100216] = { special_function = SF.Trigger, data = { 1, 1002161 } },
    [1002161] = { id = 100008, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(-6708, 2397, 392) } }
}
if EHI:GetOption("show_escape_chance") then
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi:AddEscapeChanceTracker(dropin, 10)
    end)
end

local other =
{
    [100677] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement },
}

EHI:ParseTriggers({ mission = triggers, other = other }, "Escape", Icon.CarEscape)