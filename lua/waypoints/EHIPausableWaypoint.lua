---@class EHIPausableWaypoint : EHIWaypoint
---@field super EHIWaypoint
EHIPausableWaypoint = class(EHIWaypoint)
EHIPausableWaypoint._paused_color = EHI:GetColorFromOption("tracker_waypoint", "pause")
function EHIPausableWaypoint:pre_init(params)
    self._force_format = params.paused
    self._needs_update = not params.paused
end

---@param params table
function EHIPausableWaypoint:post_init(params)
    self:_set_pause(not self._needs_update)
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