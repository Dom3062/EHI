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
---@param id number
---@param icon nil
---@param position nil
---@param color Color
---@param code string
function EHIColoredCodesWaypoint:CreateWaypoint(id, icon, position, color, code)
    EHIColoredCodesWaypoint.super.CreateWaypoint(self, id, "code", EHI.Mission:GetUnitPositionOrDefault(id), color, code)
end

---@param color Color
---@param code string
function EHIColoredCodesWaypoint:WaypointCreated(waypoint, color, code)
    waypoint.gui:set_text(self:Format(code))
    for _, object in pairs(waypoint) do
        object:set_color(color or Color.white)
    end
end