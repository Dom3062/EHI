EHIPausableTracker = EHIPausableTracker or class(EHITracker)
function EHIPausableTracker:init(panel, params)
    EHIPausableTracker.super.init(self, panel, params)
    self._paused = params.paused
    self._pause_sync = params.paused and Application:time() or 0
    self:SetTextColor()
end

function EHIPausableTracker:update(t, dt)
    if self._paused then
        return
    end
    EHIPausableTracker.super.update(self, t, dt)
end

function EHIPausableTracker:SetPause(pause)
    self._paused = pause
    self:SetTextColor()
    self:RecalculateSyncTime(pause)
end

if Network:is_server() then
    EHIPausableTracker.RecalculateSyncTime = function (self, pause) end
else
    EHIPausableTracker.RecalculateSyncTime = function (self, pause)
        if pause then
            self._pause_sync = Application:time()
        else
            self._last_sync = self._last_sync + (Application:time() - self._pause_sync)
            self._start_time = self._last_sync
            self._end_time = self._last_sync + self._time
        end
    end
end

function EHIPausableTracker:SetTextColor(color)
    self._text:set_color(self._paused and Color.red or (color or Color.white))
end

function EHIPausableTracker:Sync(new_time)
    if self._paused then
        self._pause_sync = Application:time()
        self._last_sync = new_time
        self._start_time = self._time
        self._end_time = new_time + self._time
        return
    end
    EHIPausableTracker.super.Sync(self, new_time)
end