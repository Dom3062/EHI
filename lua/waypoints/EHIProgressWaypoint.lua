---@class EHIProgressWaypoint : EHIWaypoint, EHIProgressTracker
---@field super EHIWaypoint
EHIProgressWaypoint = class(EHIWaypoint)
EHIProgressWaypoint._needs_update = false
EHIProgressWaypoint._force_format = true
EHIProgressWaypoint.Format = EHIProgressTracker.Format
EHIProgressWaypoint.update = EHIProgressWaypoint.update_fade
EHIProgressWaypoint.FormatProgress = EHIProgressTracker.FormatProgress
EHIProgressWaypoint.IncreaseProgress = EHIProgressTracker.IncreaseProgress
EHIProgressWaypoint.IncreaseProgressMax = EHIProgressTracker.IncreaseProgressMax
EHIProgressWaypoint.DecreaseProgressMax = EHIProgressTracker.DecreaseProgressMax
function EHIProgressWaypoint:pre_init(params)
    self._max = params.max or 0
    self._progress = params.progress or 0
end

---@param progress number?
function EHIProgressWaypoint:DecreaseProgress(progress)
    self:SetProgress(self._progress - (progress or 1))
    self._disable_counting = false
end

---@param progress number
function EHIProgressWaypoint:SetProgress(progress)
    if self._progress ~= progress and not self._disable_counting then
        self._progress = progress
        self._gui:set_text(self:FormatProgress())
        if self._progress == self._max then
            self:SetCompleted()
        end
    end
end

---@param max number
function EHIProgressWaypoint:SetProgressMax(max)
    self._max = max
    self._gui:set_text(self:FormatProgress())
end

function EHIProgressWaypoint:SetCompleted()
    self:SetColor(Color.green)
    self:AddWaypointToUpdate()
end