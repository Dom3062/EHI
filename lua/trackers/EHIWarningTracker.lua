EHIWarningTracker = EHIWarningTracker or class(EHITracker)
function EHIWarningTracker:update(t, dt)
    EHIWarningTracker.super.update(self, t, dt)
    if self._time <= 10 and not self._time_warning then
        self._time_warning = true
        self:AnimateWarning()
    end
end

function EHIWarningTracker:AnimateWarning()
    self._text:animate(function(o)
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
    end)
end

function EHIWarningTracker:destroy()
    if self._text and alive(self._text) then
        self._text:stop()
    end
    EHIWarningTracker.super.destroy(self)
end