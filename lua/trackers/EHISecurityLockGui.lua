EHISecurityLockGuiTracker = EHISecurityLockGuiTracker or class(EHIProgressTracker)
function EHISecurityLockGuiTracker:SetHackTime(time)
end

function EHISecurityLockGuiTracker:SetTimeNoAnim(time) -- No fit text function needed, these timers just run down
    self._time = time
    self._time_text:set_text(self:Format())
    if time <= 0 and not self._done_text then
        self._done_text = true
        self._time_text:set_text("DONE")
    end
end