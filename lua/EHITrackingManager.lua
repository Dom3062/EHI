---@class EHITrackingManager
---@field _trackers EHITrackerManager
---@field _waypoints EHIWaypointManager
local EHITrackingManager = { _t = 0 }
---@param trackers EHITrackerManager
---@param waypoints EHIWaypointManager
function EHITrackingManager:post_init(trackers, waypoints)
    self._trackers = trackers
    self._waypoints = waypoints
end

---@param t number
function EHITrackingManager:LoadTime(t)
    self._t = t
    self._trackers._t = t
    self._waypoints._t = t
end

---@param dt number
function EHITrackingManager:update(t, dt)
    self._trackers:update(nil, dt)
    self._waypoints:update(dt)
end

---@param t number
function EHITrackingManager:update_client(t)
    local dt = t - self._t
    self._t = t
    self:update(nil, dt)
end

---@param id string
---@param new_id string
function EHITrackingManager:UpdateID(id, new_id)
    self._trackers:UpdateTrackerID(id, new_id)
    self._waypoints:UpdateWaypointID(id, new_id)
end

---@param id string
function EHITrackingManager:Exists(id)
    return self._trackers:Exists(id) or self._waypoints:WaypointExists(id)
end

---@param id string
function EHITrackingManager:DoesNotExist(id)
    return not self:Exists(id)
end

---@param id string
function EHITrackingManager:Remove(id)
    self._trackers:RemoveTracker(id)
    self._waypoints:RemoveWaypoint(id)
end

---@param timer_id string
---@param unit_id string
---@param remove boolean?
function EHITrackingManager:RemoveUnit(timer_id, unit_id, remove)
    self._trackers:CallFunction(timer_id, remove and "RemoveUnit" or "RemoveByID", unit_id)
    self._waypoints:RemoveWaypoint(unit_id)
end

---@param id string
function EHITrackingManager:ForceRemove(id)
    self._trackers:ForceRemoveTracker(id)
    self._waypoints:RemoveWaypoint(id)
end

---@param id string
---@param pause boolean
function EHITrackingManager:SetPaused(id, pause)
    self._trackers:SetPaused(id, pause)
    self._waypoints:SetPaused(id, pause)
end

---@param id string
function EHITrackingManager:Pause(id)
    self:SetPaused(id, true)
end

---@param id string
function EHITrackingManager:Unpause(id)
    self:SetPaused(id, false)
end

---@param id string
---@param t number
function EHITrackingManager:SetAccurate(id, t)
    self._trackers:SetAccurate(id, t)
    self._waypoints:SetAccurate(id, t)
end

---@param id string
---@param icon string
function EHITrackingManager:SetIcon(id, icon)
    self._trackers:SetIcon(id, icon)
    self._waypoints:SetWaypointIcon(id, icon)
end

---@param id string
---@param t number
function EHITrackingManager:SetTime(id, t)
    self._trackers:SetTime(id, t)
    self._waypoints:SetTime(id, t)
end

---@param id string
---@param t number
function EHITrackingManager:SetTimeNoAnim(id, t)
    self._trackers:SetTimeNoAnim(id, t)
    self._waypoints:SetTime(id, t)
end

---@param id string
---@param progress number
function EHITrackingManager:SetProgress(id, progress)
    self._trackers:SetProgress(id, progress)
    self._waypoints:SetProgress(id, progress)
end

---@param id string
function EHITrackingManager:IncreaseProgress(id)
    self._trackers:IncreaseProgress(id)
    self._waypoints:IncreaseProgress(id)
end

---@param id string
---@param max number?
function EHITrackingManager:IncreaseProgressMax(id, max)
    self._trackers:IncreaseProgressMax(id, max)
    self._waypoints:IncreaseProgressMax(id, max)
end

---@param id string
---@param max number?
function EHITrackingManager:DecreaseProgressMax(id, max)
    self._trackers:DecreaseProgressMax(id, max)
    self._waypoints:DecreaseProgressMax(id, max)
end

---@param id string
---@param amount number
function EHITrackingManager:IncreaseChance(id, amount)
    self._trackers:IncreaseChance(id, amount)
    self._waypoints:IncreaseChance(id, amount)
end

---@param id string
---@param f string
function EHITrackingManager:Call(id, f, ...)
    self._trackers:CallFunction(id, f, ...)
    self._waypoints:CallFunction(id, f, ...)
end

function EHITrackingManager:destroy()
    self._trackers:destroy()
    self._waypoints:destroy()
end

return EHITrackingManager