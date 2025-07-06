---@class EHIMeleeChargeBuffTracker : EHIBuffTracker
---@field super EHIBuffTracker
EHIMeleeChargeBuffTracker = class(EHIBuffTracker)
EHIMeleeChargeBuffTracker._inverted_progress = true
function EHIMeleeChargeBuffTracker:update(dt)
    self._time = self._time - dt
    self._hint:set_text(self:Format())
    local progress = 1 - (self._time / self._time_set)
    self._text:set_text(string.format("%.0d%%", progress * 100))
    self._progress_bar.red = progress
    self._progress:set_color(self._progress_bar)
    if self._time <= 0 then
        self:RemoveBuffFromUpdate()
        self._hint:set_text("")
    end
end

function EHIMeleeChargeBuffTracker:Activate(...)
    self._text:set_text("0%")
    self._progress_bar.red = 0
    self._progress:set_color(self._progress_bar)
    EHIMeleeChargeBuffTracker.super.Activate(self, ...)
    self._hint:set_text(self:Format())
end

---@class EHIPersistentMeleeChargeBuffTracker : EHIMeleeChargeBuffTracker
---@field super EHIMeleeChargeBuffTracker
EHIPersistentMeleeChargeBuffTracker = class(EHIMeleeChargeBuffTracker)
function EHIPersistentMeleeChargeBuffTracker:Extend(...)
    EHIPersistentMeleeChargeBuffTracker.super.Extend(self, ...)
    self._parent_class:_add_buff_to_update(self)
end

function EHIPersistentMeleeChargeBuffTracker:Deactivate()
    self._parent_class:_remove_buff_from_update(self._id)
end

function EHIPersistentMeleeChargeBuffTracker:DeactivateAndReset()
    self:Deactivate()
    self._text:set_text("0%")
    self._hint:set_text("")
    self._progress_bar.red = 0
    self._progress:set_color(self._progress_bar)
end

function EHIPersistentMeleeChargeBuffTracker:PreUpdate()
    self._parent_class:AddBuffNoUpdate(self._id)
    self._active = true
    self._text:set_text("0%")
end