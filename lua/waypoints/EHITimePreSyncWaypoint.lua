---@class EHITimePreSyncWaypoint : EHIWaypoint
---@field super EHIWaypoint
EHITimePreSyncWaypoint = class(EHIWaypoint)
EHITimePreSyncWaypoint._text_color = Color(0, 1, 1)
function EHITimePreSyncWaypoint:post_init(params)
    self:SetColor(self._text_color)
end

function EHITimePreSyncWaypoint:SetTime(...)
    EHITimePreSyncWaypoint.super.SetTime(self, ...)
    self:SetColor()
end