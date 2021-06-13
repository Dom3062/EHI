EHIAchievementNotificationTracker = EHIAchievementNotificationTracker or class(EHIAchievementTracker)
EHIAchievementNotificationTracker._update = false
function EHIAchievementNotificationTracker:init(panel, params)
    self._status = params.status or "ok"
    self._fade_time = 5
    EHIAchievementNotificationTracker.super.init(self, panel, params)
end

function EHIAchievementNotificationTracker:update(t, dt)
    self._fade_time = self._fade_time - dt
    if self._fade_time <= 0 then
        self:delete()
    end
end

function EHIAchievementNotificationTracker:SetText(text)
    self._text:set_text(string.upper(text))
    self:FitTheText()
end

function EHIAchievementNotificationTracker:SetTextColor(color)
    local c
    if color then
        c = color
    elseif self._status == "ok" or self._status == "done" or self._status == "pass" then
        c = Color.green
    else
        c = Color.red
    end
    EHIAchievementNotificationTracker.super.SetTextColor(self, c)
end

function EHIAchievementNotificationTracker:SetStatus(status)
    self._status = status
    self:SetText(status)
    self:SetTextColor()
    self:AnimateBG()
end

function EHIAchievementNotificationTracker:SetCompleted()
    self:SetStatus("done")
    self:AddTrackerToUpdate()
end

function EHIAchievementNotificationTracker:SetFailed()
    self:SetStatus("fail")
    self:AddTrackerToUpdate()
end