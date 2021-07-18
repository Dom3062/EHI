EHIAchievementTracker = EHIAchievementTracker or class(EHIWarningTracker)
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

EHIAchievementProgressTracker = EHIAchievementProgressTracker or class(EHIProgressTracker)

EHIAchievementDoneTracker = EHIAchievementDoneTracker or class(EHIAchievementTracker)
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

EHIAchievementUnlockTracker = EHIAchievementUnlockTracker or class(EHIWarningTracker)
function EHIAchievementUnlockTracker:update(t, dt)
    if self._fade then
        self._fade_time = self._fade_time - dt
        if self._fade_time <= 0 then
            self:delete()
        end
        return
    end
    EHIAchievementUnlockTracker.super.update(self, t, dt)
end

function EHIAchievementUnlockTracker:AnimateWarning()
    self._text:animate(function(o)
        while true do
            local t = 0

            while t < 1 do
                t = t + coroutine.yield()
                local n = 1 - math.sin(t * 180)
                --local r = math.lerp(1, 0, n)
                local g = math.lerp(1, 0, n)

                o:set_color(Color(g, 1, g))
            end
        end
    end)
end

function EHIAchievementUnlockTracker:SetFailed()
    self._text:stop()
    self._fade_time = 5
    self._fade = true
    self:SetTextColor(Color.red)
    self:AnimateBG()
end

EHIAchievementNotificationTracker = EHIAchievementNotificationTracker or class(EHIAchievementTracker)
EHIAchievementNotificationTracker._update = false
function EHIAchievementNotificationTracker:init(panel, params)
    self._status = params.status or "ok"
    self._fade_time = 5
    EHIAchievementNotificationTracker.super.init(self, panel, params)
    self:SetTextColor()
end

function EHIAchievementNotificationTracker:update(t, dt)
    self._fade_time = self._fade_time - dt
    if self._fade_time <= 0 then
        self:delete()
    end
end

function EHIAchievementNotificationTracker:Format()
    return string.upper(self._status)
end

function EHIAchievementNotificationTracker:SetText(text)
    self._text:set_text(string.upper(text))
    self:FitTheText()
end

function EHIAchievementNotificationTracker:SetTextColor(color)
    local c
    if color then
        c = color
    elseif self._status == "ok" or self._status == "done" or self._status == "pass" or self._status == "finish" then
        c = Color.green
    elseif self._status == "ready" then
        c = Color.yellow
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

EHIAchievementBagValueTracker = EHIAchievementBagValueTracker or class(EHIProgressTracker)
EHIAchievementBagValueTracker._update = false
function EHIAchievementBagValueTracker:init(panel, params)
    self._secured = 0
    self._to_secure = params.to_secure or 0
    EHIAchievementBagValueTracker.super.init(self, panel, params)
end

function EHIAchievementBagValueTracker:Format()
    return "$" .. self._secured .. "/$" .. self._to_secure
end

function EHIAchievementBagValueTracker:SetCompleted(force)
    if (self._secured >= self._to_secure and not self._status) or force then
        self._status = "completed"
        self:SetTextColor(Color.green)
        if self._remove_after_reaching_counter_target or force then
            self._parent_class:AddTrackerToUpdate(self._id, self)
        else
            self._text:set_text("FINISH")
            self:FitTheText()
        end
    end
end