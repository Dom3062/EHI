---@class EHIWaypointManager
local EHIWaypointManager = ...
EHIWaypointManager._font = tweak_data.menu.medium_font
EHIWaypointManager._font_id = Idstring(EHIWaypointManager._font)
EHIWaypointManager._timer_font_size = 20
EHIWaypointManager._distance_font_size = 32
EHIWaypointManager._vanilla_waypoint_show_distance = true

EHIWaypoint._default_color = tweak_data.hud.prime_color

return EHIWaypointManager