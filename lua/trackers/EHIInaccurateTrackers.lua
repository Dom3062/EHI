local color = EHI:GetTWColor("inaccurate")
local Color = Color
EHIInaccurateTracker = class(EHITracker)
EHIInaccurateTracker._tracker_type = "inaccurate"
EHIInaccurateTracker._text_color = color
function EHIInaccurateTracker:SetTrackerAccurate(time)
    self._text_color = Color.white
    EHIInaccurateTracker.super.SetTrackerAccurate(self, time)
end

EHIInaccuratePausableTracker = class(EHIPausableTracker)
EHIInaccuratePausableTracker._tracker_type = "inaccurate"
EHIInaccuratePausableTracker._text_color = color
function EHIInaccuratePausableTracker:SetTrackerAccurate(time)
    self._text_color = Color.white
    EHIInaccuratePausableTracker.super.SetTrackerAccurate(self, time)
end

EHIInaccurateWarningTracker = class(EHIWarningTracker)
EHIInaccurateWarningTracker._tracker_type = "inaccurate"
EHIInaccurateWarningTracker._text_color = color
function EHIInaccurateWarningTracker:SetTrackerAccurate(time)
    self._text_color = Color.white
    EHIInaccurateWarningTracker.super.SetTrackerAccurate(self, time)
end