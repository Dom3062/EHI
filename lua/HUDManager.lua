local EHI = EHI
if EHI._hooks.HUDManager then
    return
else
    EHI._hooks.HUDManager = true
end

if not EHI:ShouldDisableWaypoints() then
    return
end

function HUDManager:AddWaypointSoft(id, data)
    self._hud.stored_waypoints[id] = data
    self._hud.ehi_removed_waypoints = self._hud.ehi_removed_waypoints or {}
    self._hud.ehi_removed_waypoints[id] = true
end

function HUDManager:SoftRemoveWaypoint(id)
    local init_data = self._hud.waypoints[id].init_data
    self:remove_waypoint(id)
    self:AddWaypointSoft(id, init_data)
end

local _f_save = HUDManager.save
function HUDManager:save(data, ...)
    _f_save(self, data, ...)
    local state = data.HUDManager
    for id, _ in pairs(self._hud.ehi_removed_waypoints or {}) do
        if self._hud.stored_waypoints[id] then
            state.waypoints[id] = self._hud.stored_waypoints[id]
        end
    end
end

local _f_load = HUDManager.load
function HUDManager:load(data, ...)
    local state = data.HUDManager
    for id, _ in pairs(state.waypoints) do
        if EHI._cache.IgnoreWaypoints[id] then
            data.HUDManager.waypoints[id] = nil
        end
    end
    _f_load(self, data, ...)
end