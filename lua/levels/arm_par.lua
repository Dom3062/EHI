local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local van_delay = 543/30
local triggers = {
    [100258] = { time = 120 + van_delay },
    [100257] = { time = 100 + van_delay },
    [100209] = { time = 80 + van_delay },
    [100208] = { time = 60 + van_delay },

    [1] = { time = van_delay, special_function = SF.AddTrackerIfDoesNotExist },
    [100214] = { special_function = SF.Trigger, data = { 1, 1002141 } },
    [1002141] = { id = 100233, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(-4332, 3740, -100.001) } },
    [100215] = { special_function = SF.Trigger, data = { 1, 1002151 } },
    [1002151] = { id = 100008, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(3913, 386, -79.9999) } },
    [100216] = { special_function = SF.Trigger, data = { 1, 1002161 } },
    [1002161] = { id = 100020, special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position = Vector3(-3723, -3906, -100) } },
}
if EHI:GetOption("show_escape_chance") then
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi:AddEscapeChanceTracker(false, 15)
    end)
end

if EHI:IsClient() then
    triggers[102379] = { time = 30 + van_delay, special_function = SF.AddTrackerIfDoesNotExist }
end

EHI:ParseTriggers({ mission = triggers }, "Escape", Icon.CarEscape)