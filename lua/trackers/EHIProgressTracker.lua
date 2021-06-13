EHIProgressTracker = EHIProgressTracker or class(EHITracker)
EHIProgressTracker._update = false
function EHIProgressTracker:init(panel, params)
    self._max = params.max or 0
    self._progress = params.progress or 0
    self._previous_progress = self._progress
    self._flash = not params.dont_flash
    self._remove_after_reaching_counter_target = params.remove_after_reaching_target ~= false
    self._set_color_bad_when_reached = params.set_color_bad_when_reached
    self._flash_times = params.flash_times or 3
    self._status_is_overridable = params.status_is_overridable
    EHIProgressTracker.super.init(self, panel, params)
    self._time = 5
end

function EHIProgressTracker:update(t, dt)
    self._time = self._time - dt
    if self._time <= 0 then
        self:delete()
    end
end

function EHIProgressTracker:Sync(new_time)
end

function EHIProgressTracker:Format()
    return self._progress .. "/" .. self._max
end

function EHIProgressTracker:SetProgressMax(max)
    self._max = max
    self._text:set_text(self:Format())
    if self._flash then
        self:AnimateBG(self._flash_times)
    end
end

function EHIProgressTracker:IncreaseProgressMax()
    self:SetProgressMax(self._max + 1)
end

function EHIProgressTracker:SetProgress(progress)
    self._progress = progress
    self._text:set_text(self:Format())
    if self._flash and self._previous_progress ~= self._progress then
        self:AnimateBG(self._flash_times)
    end
    if self._set_color_bad_when_reached then
        self:SetBad()
    else
        self:SetCompleted()
    end
    self._previous_progress = self._progress
end

function EHIProgressTracker:IncreaseProgress()
    self:SetProgress(self._progress + 1)
end

function EHIProgressTracker:SetProgressRemaining(remaining)
    self:SetProgress(self._max - remaining)
end

function EHIProgressTracker:SetCompleted(force)
    if (self._progress == self._max and not self._status) or force then
        self._status = "completed"
        self:SetTextColor(Color.green)
        if self._remove_after_reaching_counter_target then
            self._parent_class:AddTrackerToUpdate(self._id, self)
        end
    end
end

function EHIProgressTracker:SetBad()
    if self._progress == self._max then
        self:SetTextColor(tweak_data.ehi.color.InaccurateColor)
    end
end