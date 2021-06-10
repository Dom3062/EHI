local color = tweak_data.ehi.color.InaccurateColor
EHIInaccurateWarningTracker = EHIInaccurateWarningTracker or class(EHIWarningTracker)
function EHIInaccurateWarningTracker:init(panel, params)
    params.text_color = color
    EHIInaccurateWarningTracker.super.init(self, panel, params)
end

function EHIInaccurateWarningTracker:AnimateWarning()
    local anim
    if self._tracker_is_accurate then
        anim = function(o)
            while true do
                local t = 0

                while t < 1 do
                    t = t + coroutine.yield()
                    local n = 1 - math.sin(t * 180)
                    --local r = math.lerp(1, 0, n)
                    local g = math.lerp(1, 0, n)

                    o:set_color(Color(1, g, g))
                end
            end
        end
    else
        anim = function(o)
            while true do
                local t = 0

                while t < 1 do
                    t = t + coroutine.yield()
                    local n = 1 - math.sin(t * 180)
                    local g = math.lerp(color.g, 0, n)

                    o:set_color(Color(1, g, 0))
                end
            end
        end
    end
    self._text:animate(anim)
end

function EHIInaccurateWarningTracker:SetTrackerAccurate(time)
    self._tracker_is_accurate = true
    self:SetTextColor(Color.white)
    self:SetTimeNoAnim(time)
end