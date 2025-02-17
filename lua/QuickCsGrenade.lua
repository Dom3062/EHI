local EHI = EHI
if EHI:CheckLoadHook("QuickCsGrenade") or not EHI:GetTrackerOrWaypointOption("show_mission_trackers", "show_waypoints_mission") then
    return
end
local Icon = EHI.Icons
local show_tracker, show_waypoint = EHI:GetShowTrackerAndWaypoint("show_mission_trackers", "show_waypoints_mission")

local _f_detonate = QuickCsGrenade.detonate
function QuickCsGrenade:detonate(...)
    _f_detonate(self, ...)
    local key = tostring(self._unit:key())
    if show_tracker then
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