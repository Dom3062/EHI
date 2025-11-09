---@class EHIWaypointManager
local EHIWaypointManager = ...
local original =
{
    _create_waypoint_data = EHIWaypointManager._create_waypoint_data
}

EHIWaypointManager._font = tweak_data.menu.medium_font
EHIWaypointManager._font_id = Idstring(EHIWaypointManager._font)
EHIWaypointManager._timer_font_size = 20
EHIWaypointManager._distance_font_size = 32
EHIWaypointManager._vanilla_waypoint_show_distance = true
---@param data AddWaypointTable|ElementWaypointTrigger|WaypointInitData
function EHIWaypointManager:_create_waypoint_data(data)
    data.distance = true
    return original._create_waypoint_data(self, data)
end

EHIWaypoint._default_color = tweak_data.hud.prime_color

return EHIWaypointManager