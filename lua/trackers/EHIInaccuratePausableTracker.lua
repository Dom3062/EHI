local color = tweak_data.ehi.color.Inaccurate
EHIInaccuratePausableTracker = EHIInaccuratePausableTracker or class(EHIPausableTracker)
function EHIInaccuratePausableTracker:init(panel, params)
    params.text_color = color
    EHIInaccuratePausableTracker.super.init(self, panel, params)
end

function EHIInaccuratePausableTracker:SetTextColor()
    self._text:set_color(self._paused and Color.red or color)
end

function EHIInaccuratePausableTracker:SetTrackerAccurate(time)
    color = Color.white
    self:SetTextColor()
    self:SetTimeNoAnim(time)
end