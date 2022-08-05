EHILootTracker = class(EHIProgressTracker)
function EHILootTracker:init(panel, params)
    self._offset = params.offset or 0
    self._stay_on_screen = params.stay_on_screen
    EHILootTracker.super.init(self, panel, params)
    self._remove_after_reaching_counter_target = not self._stay_on_screen
end

function EHILootTracker:SetProgress(progress)
    local fixed_progress = progress - self._offset
    EHILootTracker.super.SetProgress(self, fixed_progress)
end

function EHILootTracker:Finalize()
    local progress = self._progress
    self._progress = self._progress - self._offset
    EHILootTracker.super.Finalize(self)
    self._progress = progress
end

function EHILootTracker:SetCompleted(force)
    EHILootTracker.super.SetCompleted(self, force)
    if self._stay_on_screen and self._status then
        self._text:set_text(self:Format())
        self:FitTheText()
        self._status = nil
    end
end

function EHILootTracker:SetProgressMax(max)
    EHILootTracker.super.SetProgressMax(self, max)
    self:SetTextColor(Color.white)
    self._disable_counting = nil
end