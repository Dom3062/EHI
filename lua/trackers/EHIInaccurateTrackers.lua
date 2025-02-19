local color = EHI:GetColorFromOption("tracker_waypoint", "inaccurate")
local Color = Color
---@class EHIInaccurateTracker : EHITracker
---@field super EHITracker
EHIInaccurateTracker = class(EHITracker)
EHIInaccurateTracker._tracker_type = "inaccurate"
EHIInaccurateTracker._text_color = color
function EHIInaccurateTracker:SetAccurate(...)
    self._text_color = Color.white
    EHIInaccurateTracker.super.SetAccurate(self, ...)
end

---@class EHIInaccuratePausableTracker : EHIPausableTracker
---@field super EHIPausableTracker
EHIInaccuratePausableTracker = class(EHIPausableTracker)
EHIInaccuratePausableTracker._tracker_type = "inaccurate"
EHIInaccuratePausableTracker._text_color = color
function EHIInaccuratePausableTracker:SetAccurate(...)
    self._text_color = Color.white
    EHIInaccuratePausableTracker.super.SetAccurate(self, ...)
end

---@class EHIInaccurateWarningTracker : EHIWarningTracker
---@field super EHIWarningTracker
EHIInaccurateWarningTracker = class(EHIWarningTracker)
EHIInaccurateWarningTracker._tracker_type = "inaccurate"
EHIInaccurateWarningTracker._text_color = color
function EHIInaccurateWarningTracker:SetAccurate(...)
    self._text_color = Color.white
    EHIInaccurateWarningTracker.super.SetAccurate(self, ...)
end