local lerp = math.lerp
local sin = math.sin
local Color = Color
local function anim(o)
    while true do
        local t = 1
        while t > 0 do
            t = t - coroutine.yield()
            local n = sin(t * 180)
            local g = lerp(1, 0, n)
            o:set_color(Color(1, g, g))
        end
    end
end
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
        self._text:animate(anim)
    end
end

function EHIWarningTracker:Run(t)
    self._time_warning = false
    EHIWarningTracker.super.Run(self, t)
end

function EHIWarningTracker:delete()
    if self._text and alive(self._text) then
        self._text:stop()
    end
    EHIWarningTracker.super.delete(self)
end