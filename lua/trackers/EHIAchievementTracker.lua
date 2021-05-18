EHIAchievementTracker = EHIAchievementTracker or class(EHIWarningTracker)
EHIAchievementTracker._type = "achievement"
function EHIAchievementTracker:update(t, dt)
    if self._fade then
        self._fade_time = self._fade_time - dt
        if self._fade_time <= 0 then
            self:delete()
        end
        return
    end
    EHIAchievementTracker.super.update(self, t, dt)
end

function EHIAchievementTracker:SetCompleted()
    self._text:stop()
    self._fade_time = 5
    self._fade = true
    self:SetTextColor(Color.green)
    self:AnimateBG()
end

function EHIAchievementTracker:SetFailed()
    self._text:stop()
    self._fade_time = 5
    self._fade = true
    self:SetTextColor(Color.red)
    self:AnimateBG()
end