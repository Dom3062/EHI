local color = EHI:GetTWColor("inaccurate")
EHIInaccurateWaypoint = class(EHIWaypoint)
EHIInaccurateWaypoint._default_color = color
function EHIInaccurateWaypoint:init(...)
    EHIInaccurateWaypoint.super.init(self, ...)
    self:SetColor()
end

function EHIInaccurateWaypoint:SetWaypointAccurate(time)
    self._default_color = Color.white
    self:SetColor()
    self:SetTime(time)
end

EHIInaccuratePausableWaypoint = class(EHIPausableWaypoint)
EHIInaccuratePausableWaypoint._default_color = color
EHIInaccuratePausableWaypoint.SetWaypointAccurate = EHIInaccurateWaypoint.SetWaypointAccurate

EHIInaccurateWarningWaypoint = class(EHIWarningWaypoint)
EHIInaccurateWarningWaypoint._default_color = color
EHIInaccurateWarningWaypoint.SetWaypointAccurate = EHIInaccurateWaypoint.SetWaypointAccurate