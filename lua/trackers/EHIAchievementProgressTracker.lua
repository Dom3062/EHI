EHIAchievementProgressTracker = EHIAchievementProgressTracker or class(EHIProgressTracker)
EHIAchievementProgressTracker._type = "achievement"
function EHIAchievementProgressTracker:SetFailed()
    if self._status and not self._status_is_overridable then
        return
    end
    self:SetTextColor(Color.red)
    self._status = "failed"
    self._parent_class:AddTrackerToUpdate(self._id, self)
    self:AnimateBG()
end