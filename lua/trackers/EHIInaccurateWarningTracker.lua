local color = tweak_data.ehi.color.Inaccurate
local lerp = math.lerp
local sin = math.sin
local Color = Color
EHIInaccurateWarningTracker = class(EHIWarningTracker)
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
                    local n = 1 - sin(t * 180)
                    --local r = lerp(1, 0, n)
                    local g = lerp(1, 0, n)

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
                    local n = 1 - sin(t * 180)
                    local g = lerp(color.g, 0, n)

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