EHIAchievementProgressTracker = EHIAchievementProgressTracker or class(EHIProgressTracker)
EHIAchievementProgressTracker._type = "achievement"
function EHIAchievementProgressTracker:SetFailed()
    self:SetTextColor(Color.red)
    self._parent_class:AddTrackerToUpdate(self._id, self)
    self:AnimateBG()
end