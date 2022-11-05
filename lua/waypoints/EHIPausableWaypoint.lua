EHIPausableWaypoint = class(EHIWaypoint)
function EHIPausableWaypoint:init(waypoint, params)
    EHIPausableWaypoint.super.init(self, waypoint, params)
    self._paused = params.paused
end

function EHIPausableWaypoint:update(t, dt)
    if self._paused then
        return
    end
    EHIPausableWaypoint.super.update(self, t, dt)
end

function EHIPausableWaypoint:SetPaused(pause)
    self._paused = pause
    self:SetColor(pause and Color.red or self._default_color)
end