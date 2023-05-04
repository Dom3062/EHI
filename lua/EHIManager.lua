EHIManager = class()
function EHIManager:init(ehi_tracker, ehi_waypoints)
    self._trackers = ehi_tracker
    self._waypoints = ehi_waypoints
    self._level_started_from_beginning = true
    self._t = 0
end

function EHIManager:init_finalize()
    managers.network:add_event_listener("EHIManagerDropIn", "on_set_dropin", callback(self, self, "DisableStartFromBeginning"))
end

function EHIManager:LoadTime(t)
    self._t = t
end

function EHIManager:AddLoadSyncFunction(f)
    self._load_sync = self._load_sync or {}
    self._load_sync[#self._load_sync + 1] = f
end

function EHIManager:AddFullSyncFunction(f)
    self._full_sync = self._full_sync or {}
    self._full_sync[#self._full_sync + 1] = f
end

function EHIManager:LoadSync()
    if self._level_started_from_beginning then
        for _, f in ipairs(self._full_sync or {}) do
            f(self)
        end
    else
        for _, f in ipairs(self._load_sync or {}) do
            f(self)
        end
        self._trackers:LoadSync()
    end
    -- Clear used memory
    self._full_sync = nil
    self._load_sync = nil
end

function EHIManager:DisableStartFromBeginning()
    self._level_started_from_beginning = false
end

function EHIManager:GetStartedFromBeginning()
    return self._level_started_from_beginning
end

function EHIManager:GetDropin()
    return not self:GetStartedFromBeginning()
end

function EHIManager:update(t, dt)
    self._trackers:update(t, dt)
    self._waypoints:update(t, dt)
end

function EHIManager:update_client(t)
    local dt = t - self._t
    self._t = t
    self:update(t, dt)
end

function EHIManager:Exists(id)
    return self._trackers:TrackerExists(id) or self._waypoints:WaypointExists(id)
end

function EHIManager:Remove(id)
    self._trackers:ForceRemoveTracker(id)
    self._waypoints:RemoveWaypoint(id)
end

function EHIManager:SetPaused(id, pause)
    self._trackers:SetTrackerPaused(id, pause)
    self._waypoints:SetWaypointPause(id, pause)
end

function EHIManager:Pause(id)
    self:SetPaused(id, true)
end

function EHIManager:Unpause(id)
    self:SetPaused(id, false)
end

function EHIManager:Call(id, f, ...)
    self._trackers:CallFunction(id, f, ...)
    self._waypoints:CallFunction(id, f, ...)
end

function EHIManager:destroy()
    self._trackers:destroy()
    self._waypoints:destroy()
end