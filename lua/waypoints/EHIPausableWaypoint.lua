---@class EHIPausableWaypoint : EHIWaypoint
---@field super EHIWaypoint
EHIPausableWaypoint = class(EHIWaypoint)
EHIPausableWaypoint._paused_color = EHI:GetColorFromOption("tracker_waypoint", "pause")
---@param params table
function EHIPausableWaypoint:post_init(params)
    self._update = not params.paused
    self:_set_pause(not self._update)
end

---@param pause boolean
function EHIPausableWaypoint:SetPaused(pause)
    self:_set_pause(pause)
    if pause then
        self:RemoveWaypointFromUpdate()
    else
        self:AddWaypointToUpdate()
    end
end

function EHIPausableWaypoint:_set_pause(pause)
    self._paused = pause
    self:SetColor()
end

function EHIPausableWaypoint:SetColor(color)
    color = self._paused and self._paused_color or (color or self._default_color)
    EHIPausableWaypoint.super.SetColor(self, color)
end