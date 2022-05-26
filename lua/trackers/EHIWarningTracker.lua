local lerp = math.lerp
local sin = math.sin
local Color = Color
EHIWarningTracker = class(EHITracker)
function EHIWarningTracker:update(t, dt)
    EHIWarningTracker.super.update(self, t, dt)
    if self._time <= 10 and not self._time_warning then
        self._time_warning = true
        self:AnimateWarning()
    end
end

function EHIWarningTracker:AnimateWarning()
    if self._text and alive(self._text) then
        self._text:animate(function(o)
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
        end)
    end
end

function EHIWarningTracker:destroy()
    if self._text and alive(self._text) then
        self._text:stop()
    end
    EHIWarningTracker.super.destroy(self)
end