local color = tweak_data.ehi.color.Inaccurate
EHIInaccurateTracker = EHIInaccurateTracker or class(EHITracker)
EHIInaccurateTracker._tracker_type = "inaccurate"
function EHIInaccurateTracker:init(panel, params)
    params.text_color = color
    EHIInaccurateTracker.super.init(self, panel, params)
end