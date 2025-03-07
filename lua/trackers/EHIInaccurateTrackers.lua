local color = EHI:GetColorFromOption("tracker_waypoint", "inaccurate")
local Color = Color
---@class EHIInaccurateTracker : EHITracker
---@field super EHITracker
EHIInaccurateTracker = class(EHITracker)
EHIInaccurateTracker._text_color = color
---@param time number
function EHIInaccurateTracker:SetAccurate(time)
    self._text_color = Color.white
    self:SetTextColor()
    self:SetTimeNoAnim(time)
end

---@class EHIInaccuratePausableTracker : EHIPausableTracker
---@field super EHIPausableTracker
EHIInaccuratePausableTracker = class(EHIPausableTracker)
EHIInaccuratePausableTracker._text_color = color
EHIInaccuratePausableTracker.SetAccurate = EHIInaccurateTracker.SetAccurate

---@class EHIInaccurateWarningTracker : EHIWarningTracker
---@field super EHIWarningTracker
EHIInaccurateWarningTracker = class(EHIWarningTracker)
EHIInaccurateWarningTracker._text_color = color
EHIInaccurateWarningTracker.SetAccurate = EHIInaccurateTracker.SetAccurate