EHIAchievementObtainableTracker = EHIAchievementObtainableTracker or class(EHIAchievementTracker)
function EHIAchievementObtainableTracker:init(panel, params)
    EHIAchievementTracker.super.init(self, panel, params)
    self._not_obtainable = not params.obtainable
    self:SetTextColor()
end

function EHIAchievementObtainableTracker:update(t, dt)
    if self._not_obtainable then
        self._time = self._time - dt
        self._text:set_text(self:Format())
        if self._time <= 0 then
            self:delete()
        end
        return
    end
    EHIAchievementObtainableTracker.super.update(self, t, dt)
end

function EHIAchievementObtainableTracker:ToggleObtainable()
    self:SetObtainable(self._not_obtainable)
end

function EHIAchievementObtainableTracker:SetObtainable(obtainable)
    self._not_obtainable = not obtainable
    self:SetTextColor()
end

function EHIAchievementObtainableTracker:SetTextColor(color)
    if self._not_obtainable then
        self._text:stop()
        self._text:set_color(Color.red)
    else
        self._text:set_color(color or Color.white)
        if self._time <= 10 then
            self:AnimateWarning()
        end
    end
end