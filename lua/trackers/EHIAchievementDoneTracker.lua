EHIAchievementDoneTracker = EHIAchievementDoneTracker or class(EHIAchievementTracker)
EHIAchievementDoneTracker._type = "achievement"
function EHIAchievementDoneTracker:init(panel, params)
    EHIAchievementDoneTracker.super.init(self, panel, params)
end

function EHIAchievementDoneTracker:update(t, dt)
    if self._fade then
        self._fade_time = self._fade_time - dt
        if self._fade_time <= 0 then
            self:delete()
        end
        return
    end
    self._time = self._time - dt
    self._text:set_text(self:Format())
    if self._time <= 0 then
        self._text:set_text("DONE")
        self:FitTheText()
        self:SetCompleted()
        self:RemoveTrackerFromUpdate()
    end
end