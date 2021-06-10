EHIAnimatedTracker = EHIAnimatedTracker or class(EHITracker)
function EHIAnimatedTracker:init(panel, params)
    EHIAnimatedTracker.super.init(self, panel, params)
    self:Animate()
end

function EHIAnimatedTracker:Animate()
    self._icon1:animate(function(o)
        while true do
            local t = 1
            while t > 0 do
                t = t - coroutine.yield()
                o:set_color(Color(1 * t, 0, 1 - (1 * t)))
            end
            t = 0
            while t < 1 do
                t = t + coroutine.yield()
                o:set_color(Color(1 * t, 0, 1 - (1 * t)))
            end
        end
    end)
end

function EHIAnimatedTracker:destroy()
    if self._icon1 and alive(self._icon1) then
        self._icon1:stop()
    end
    EHIAnimatedTracker.super.destroy(self)
end