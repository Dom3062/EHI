if EHI._hooks.SecurityCamera then
	return
else
	EHI._hooks.SecurityCamera = true
end

local show_waypoint = EHI:GetWaypointOption("show_waypoints_cameras")
local show_waypoint_only = show_waypoint and EHI:GetWaypointOption("show_waypoints_only")

local original =
{
    init = SecurityCamera.init,
    _start_tape_loop = SecurityCamera._start_tape_loop,
    destroy = SecurityCamera.destroy
}

function SecurityCamera:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = tostring(unit:key())
end

function SecurityCamera:_start_tape_loop(tape_loop_t, ...)
    original._start_tape_loop(self, tape_loop_t, ...)
    if not show_waypoint_only then
        managers.ehi:AddTracker({
            id = self._ehi_key,
            time = tape_loop_t + 5,
            icons = { "camera_loop" },
            exclude_from_sync = true,
            class = "EHIWarningTracker"
        })
    end
    if show_waypoint then
        managers.ehi_waypoint:AddWaypoint(self._ehi_key, {
            time = tape_loop_t + 5,
            icon = { "camera_loop" },
            unit = self._unit,
            warning = true
        })
    end
end

function SecurityCamera:destroy(unit, ...)
    original.destroy(self, unit, ...)
    managers.ehi:RemoveTracker(self._ehi_key)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
end