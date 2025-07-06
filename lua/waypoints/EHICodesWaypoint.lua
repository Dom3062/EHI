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

---@class EHIColoredCodesWaypoint : EHIWaypointLessWaypoint, EHICodeTracker
---@field super EHIWaypointLessWaypoint
EHIColoredCodesWaypoint = class(EHIWaypointLessWaypoint)
EHIColoredCodesWaypoint._needs_update = false
EHIColoredCodesWaypoint.Format = EHICodeTracker.Format
---@param id number
---@param icon nil
---@param position nil
---@param color Color
---@param code string
function EHIColoredCodesWaypoint:CreateWaypoint(id, icon, position, color, code)
    local waypoint = self._parent_class:_create_waypoint(id, "code", EHI.Mission:GetUnitPositionOrDefault(id))
    if waypoint then
        local data = {}
        data.gui = waypoint.timer_gui
        data.bitmap = waypoint.bitmap
        data.arrow = waypoint.arrow
        data.bitmap_world = waypoint.bitmap_world
        data.gui:set_text(self:Format(code))
        for _, object in pairs(data) do
            object:set_color(color or Color.white)
        end
        self._codes = self._codes or {}
        self._codes[id] = data
    end
end

function EHIColoredCodesWaypoint:destroy()
    EHIColoredCodesWaypoint.super.destroy(self)
    for id, _ in pairs(self._codes or {}) do
        self._parent_class._hud:remove_waypoint(id)
    end
end