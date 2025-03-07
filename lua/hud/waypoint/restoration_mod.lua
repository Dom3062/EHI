local original =
{
    AddWaypoint = EHIWaypointManager.AddWaypoint,
    AddWaypointlessWaypoint = EHIWaypointManager.AddWaypointlessWaypoint
}

EHIWaypointManager._font = Idstring(tweak_data.menu.medium_font)
EHIWaypointManager._timer_font_size = 20
EHIWaypointManager._distance_font_size = 32
---@param id string
---@param params AddWaypointTable|ElementWaypointTrigger
function EHIWaypointManager:AddWaypoint(id, params)
    params.distance = true
    original.AddWaypoint(self, id, params)
end

---@param id string
---@param params AddWaypointTable|ElementWaypointTrigger
function EHIWaypointManager:AddWaypointlessWaypoint(id, params)
    params.distance = true
    original.AddWaypointlessWaypoint(self, id, params)
end

EHIWaypoint._default_color = tweak_data.hud.prime_color