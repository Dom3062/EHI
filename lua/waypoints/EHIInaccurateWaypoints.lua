local color = EHI:GetColorFromOption("tracker_waypoint", "inaccurate")
---@class EHIInaccurateWaypoint : EHIWaypoint
---@field super EHIWaypoint
EHIInaccurateWaypoint = class(EHIWaypoint)
EHIInaccurateWaypoint._default_color = color
function EHIInaccurateWaypoint:post_init(params)
    self:SetColor()
end

---@param time number
function EHIInaccurateWaypoint:SetAccurate(time)
    self._default_color = Color.white
    self:SetColor()
    self:SetTime(time)
end

---@class EHIInaccuratePausableWaypoint: EHIPausableWaypoint
EHIInaccuratePausableWaypoint = class(EHIPausableWaypoint)
EHIInaccuratePausableWaypoint._default_color = color
EHIInaccuratePausableWaypoint.SetAccurate = EHIInaccurateWaypoint.SetAccurate

---@class EHIInaccurateWarningWaypoint: EHIWarningWaypoint
EHIInaccurateWarningWaypoint = class(EHIWarningWaypoint)
EHIInaccurateWarningWaypoint._default_color = color
EHIInaccurateWarningWaypoint.SetAccurate = EHIInaccurateWaypoint.SetAccurate
function EHIInaccurateWarningWaypoint:post_init(params)
    self:SetColor()
end