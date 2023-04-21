EHICommon = class()
function EHICommon:init(ehi_manager, ehi_waypoints)
    self._ehi = ehi_manager
    self._waypoints = ehi_waypoints
end

function EHICommon:Exists(id)
    return self._ehi:TrackerExists(id) or self._waypoints:WaypointExists(id)
end

function EHICommon:Remove(id)
    self._ehi:ForceRemoveTracker(id)
    self._waypoints:RemoveWaypoint(id)
end

function EHICommon:SetPaused(id, pause)
    self._ehi:SetTrackerPaused(id, pause)
    self._waypoints:SetWaypointPause(id, pause)
end

function EHICommon:Pause(id)
    self:SetPaused(id, true)
end

function EHICommon:Unpause(id)
    self:SetPaused(id, false)
end

function EHICommon:Call(id, f, ...)
    self._ehi:CallFunction(id, f, ...)
    self._waypoints:CallFunction(id, f, ...)
end