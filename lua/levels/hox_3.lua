local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local CF = EHI.ConditionFunctions
local TT = EHI.Trackers
local drill_delay = 30 + 2 + 1.5
local escape_delay = 3 + 27 + 1
local ShowWaypoint = EHI:GetFreeCustomSpecialFunctionID()
local triggers = {
    [101855] = { time = 120 + drill_delay, id = "LanceDrop", icons = Icon.HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist },
    [101854] = { time = 90 + drill_delay, id = "LanceDrop", icons = Icon.HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist },
    [101853] = { time = 60 + drill_delay, id = "LanceDrop", icons = Icon.HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist },
    [101849] = { time = 30 + drill_delay, id = "LanceDrop", icons = Icon.HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist },
    [101844] = { special_function = SF.Trigger, data = { 1018441, 1018442 } },
    [1018441] = { time = drill_delay, id = "LanceDrop", icons = Icon.HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist },
    [1018442] = { time = 25, id = "ForcedAlarm", icons = { Icon.Alarm }, class = TT.Warning, condition_function = CF.IsStealth },
    [EHI:GetInstanceElementID(100008, 2835)] = { id = EHI:GetInstanceElementID(100002, 2835), special_function = ShowWaypoint, data = { icon = Icon.Drill } },

    [102223] = { time = 90 + escape_delay, id = "Escape", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist },
    [102188] = { time = 60 + escape_delay, id = "Escape", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist },
    [102187] = { time = 45 + escape_delay, id = "Escape", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist },
    [102186] = { time = 30 + escape_delay, id = "Escape", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist },
    [102190] = { time = escape_delay, id = "Escape", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist },
    [EHI:GetInstanceElementID(100004, 2910)] = { id = EHI:GetInstanceElementID(100009, 2910), special_function = ShowWaypoint, data = { icon = Icon.Escape } },
}

EHI:ParseTriggers(triggers)
EHI:RegisterCustomSpecialFunction(ShowWaypoint, function(id, trigger, element, enabled)
    trigger.data.distance = true
    trigger.data.state = "sneak_present"
    trigger.data.present_timer = 0
    trigger.data.no_sync = true
    local e = managers.mission:get_element_by_id(trigger.id)
    if e then
        trigger.data.position = e._values.position
    else
        trigger.data.position = Vector3()
    end
    managers.hud:add_waypoint(trigger.id, trigger.data)
end)
EHI:AddOnAlarmCallback(function(dropin)
    managers.ehi:RemoveTracker("ForcedAlarm")
end)