local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local SetTimeIfEnabled = EHI:GetFreeCustomSpecialFunctionID()
local ShowWaypoint = EHI:GetFreeCustomSpecialFunctionID()
local EscapeWaypointID = EHI:GetInstanceElementID(100043, 2900)
local EscapeWaypoint = { id = EscapeWaypointID, special_function = ShowWaypoint, data = { icon = Icon.Car } }
local triggers = {
    [100918] = { time = 11 + 3.5 + 100 + 1330/30, id = "Escape", icons = Icon.CarEscape },
    [101892] = EscapeWaypoint,
    [101727] = { time = 1283/30, id = "Escape", icons = Icon.CarEscape, special_function = SetTimeIfEnabled },
    [101933] = EscapeWaypoint,
    [101706] = { time = 895/30, id = "Escape", icons = Icon.CarEscape, special_function = SetTimeIfEnabled },
    [101394] = EscapeWaypoint,
    [105792] = { time = 20, id = "FireApartment1", icons = { Icon.Fire, Icon.Wait } },
    [105804] = { time = 20, id = "FireApartment2", icons = { Icon.Fire, Icon.Wait } },
    [105824] = { time = 20, id = "FireApartment3", icons = { Icon.Fire, Icon.Wait } },
    [105840] = { time = 20, id = "FireApartment4", icons = { Icon.Fire, Icon.Wait } }
}

if Network:is_client() then
    triggers[101748] = { time = 1330/30, id = "Escape", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker }
end

local achievements =
{
    [EHI:GetInstanceElementID(100010, 2900)] = { time = 60, id = "peta_2", class = TT.Achievement },
    [EHI:GetInstanceElementID(100080, 2900)] = { id = "peta_2", special_function = SF.SetAchievementComplete }
}

EHI:ParseTriggers(triggers, achievements)

local DisableWaypoints = {}
for i = 3300, 3525, 75 do
    DisableWaypoints[EHI:GetInstanceElementID(100039, i)] = true -- Saw icon
end
for i = 3600, 3750, 75 do
    DisableWaypoints[EHI:GetInstanceElementID(100020, i)] = true -- Drill icon
end
EHI:DisableWaypoints(DisableWaypoints)
EHI:RegisterCustomSpecialFunction(SetTimeIfEnabled, function(id, trigger, element, enabled)
    if enabled then
        if managers.ehi:TrackerExists(trigger.id) then
            managers.ehi:SetTrackerTime(trigger.id, trigger.time)
        else
            EHI:CheckCondition(id)
        end
    end
end)
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