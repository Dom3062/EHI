local color = tweak_data.ehi.color.InaccurateColor
EHIInaccurateWarningTracker = EHIInaccurateWarningTracker or class(EHIWarningTracker)
function EHIInaccurateWarningTracker:init(panel, params)
    params.text_color = color
    EHIInaccurateWarningTracker.super.init(self, panel, params)
end

function EHIInaccurateWarningTracker:AnimateWarning()
    self._text:animate(function(o)
        while true do
            local t = 0

            while t < 1 do
                t = t + coroutine.yield()
                local n = 1 - math.sin(t * 180)
                local g = math.lerp(color.g, 0, n)

                o:set_color(Color(1, g, 0))
            end
        end
    end)
end