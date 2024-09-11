local EHI = EHI
if EHI:CheckLoadHook("QuickCsGrenade") or not EHI:GetOption("show_mission_trackers") then
    return
end
local Icon = EHI.Icons
local show_waypoint, show_waypoint_only = EHI:GetWaypointOptionWithOnly("show_waypoints_mission")

local _f_detonate = QuickCsGrenade.detonate
function QuickCsGrenade:detonate(...)
    _f_detonate(self, ...)
    local key = tostring(self._unit:key())
    if not show_waypoint_only then
        managers.ehi_tracker:AddTracker({
            id = key,
            time = self._duration,
            icons = { Icon.Turret, Icon.Teargas },
            hint = "sentry_teargas"
        })
    end
    if show_waypoint then
        managers.ehi_waypoint:AddWaypoint(key, {
            time = self._duration,
            icon = Icon.Teargas,
            position = self._unit:position()
        })
    end
end