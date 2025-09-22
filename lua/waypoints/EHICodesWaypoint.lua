---@class EHICodeWaypoint : EHIWaypoint, EHICodeTracker
---@field super EHIWaypoint
EHICodeWaypoint = class(EHIWaypoint)
EHICodeWaypoint._force_format = true
EHICodeWaypoint._needs_update = false
EHICodeWaypoint.Format = EHICodeTracker.Format
EHICodeWaypoint.SetCodePart = EHICodeTracker.SetCodePart
function EHICodeWaypoint:SetCode(code)
    self._gui:set_text(self:Format(code))
end

---@class EHIColoredCodesWaypoint : EHIWaypointsLessWaypoint, EHICodeTracker
---@field super EHIWaypointsLessWaypoint
EHIColoredCodesWaypoint = class(EHIWaypointsLessWaypoint)
EHIColoredCodesWaypoint._needs_update = false
EHIColoredCodesWaypoint.Format = EHICodeTracker.Format
---@param color Color
---@param code string
function EHIColoredCodesWaypoint:WaypointCreated(waypoint, color, code)
    waypoint.gui:set_text(self:Format(code))
    for _, object in pairs(waypoint) do
        object:set_color(color or Color.white)
    end
end