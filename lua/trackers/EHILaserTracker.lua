EHILaserTracker = EHILaserTracker or class(EHITracker)
function EHILaserTracker:init(panel, params)
    self._next_cycle_t = params.time
    params.icons = { EHI.Icons.Lasers }
    EHILaserTracker.super.init(self, panel, params)
end

function EHILaserTracker:update(t, dt)
    self._time = self._time - dt
    self._text:set_text(self:Format())
    if self._time <= 0 then
        self._time = self._next_cycle_t
    end
end

function EHILaserTracker:UpdateInterval(t)
    self._time = t
end