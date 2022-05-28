local EHI = EHI
local show_failed = EHI:GetOption("show_achievement_failed_popup")
local AchievementFailed = "ACHIEVEMENT FAILED"
local function ShowPopup(tracker)
    if tracker._failed_popup_showed or tracker._achieved_popup_showed then
        return
    end
    tracker._failed_popup_showed = true
    local id = tracker._id
    managers.hud:custom_ingame_popup_text(AchievementFailed, managers.localization:to_upper_text("achievement_" .. id), EHI:GetAchievementIconString(id))
end
local lerp = math.lerp
local sin = math.sin
local Color = Color
if show_failed then
    local _f_init = HudChallengeNotification.init
    if VoidUI and VoidUI.options.enable_challanges then
        function HudChallengeNotification:init(title, ...)
            _f_init(self, title, ...)
            if title and title == AchievementFailed then
                for i, d in ipairs(self._hud:children()) do
                    if d.panel then
                        for ii, dd in ipairs(d:children()) do
                            if dd.set_image then
                                dd:set_color(Color.red)
                            end
                        end
                    end
                end
            end
        end
    else
        function HudChallengeNotification:init(title, ...)
            _f_init(self, title, ...)
            if title and title == AchievementFailed and self._box then
                for i, d in ipairs(self._box:children()) do
                    if d.set_image then
                        d:set_color(Color.red)
                    end
                end
            end
        end
    end
end

EHIAchievementTracker = class(EHIWarningTracker)
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
    self._exclude_from_sync = true
    self._text:stop()
    self._fade_time = 5
    self._fade = true
    self._achieved_popup_showed = true
    self:SetTextColor(Color.green)
    self:AnimateBG()
end

function EHIAchievementTracker:SetFailed()
    self._exclude_from_sync = true
    self._text:stop()
    self._fade_time = 5
    self._fade = true
    self:SetTextColor(Color.red)
    self:AnimateBG()
    if show_failed then
        ShowPopup(self)
    end
end

if show_failed then
    function EHIAchievementTracker:delete()
        ShowPopup(self)
        EHIAchievementTracker.super.delete(self)
    end
end

EHIAchievementProgressTracker = class(EHIProgressTracker)
if show_failed then
    function EHIAchievementProgressTracker:SetCompleted(force)
        self._achieved_popup_showed = true
        EHIAchievementProgressTracker.super.SetCompleted(self, force)
    end

    function EHIAchievementProgressTracker:SetFailed()
        EHIAchievementProgressTracker.super.SetFailed(self)
        ShowPopup(self)
    end
end

EHIAchievementDoneTracker = class(EHIAchievementTracker)
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
        self:SetCompleted()
        self._text:set_text("FINISH")
        self:FitTheText()
        self:RemoveTrackerFromUpdate()
    end
end

EHIAchievementObtainableTracker = class(EHIAchievementTracker)
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

EHIAchievementUnlockTracker = class(EHIWarningTracker)
function EHIAchievementUnlockTracker:update(t, dt)
    if self._fade then
        self._fade_time = self._fade_time - dt
        if self._fade_time <= 0 then
            if show_failed then
                ShowPopup(self)
            end
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
                local n = 1 - sin(t * 180)
                --local r = lerp(1, 0, n)
                local g = lerp(1, 0, n)

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
    if show_failed then
        ShowPopup(self)
    end
end

EHIAchievementNotificationTracker = class(EHIAchievementTracker)
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

function EHIAchievementNotificationTracker:SetText()
    self._text:set_text(self:Format())
    self:FitTheText()
end

function EHIAchievementNotificationTracker:SetTextColor(color)
    local c
    if color then
        c = color
    elseif self._status == "ok" or self._status == "done" or self._status == "pass" or self._status == "finish" or self._status == "destroy" then
        c = Color.green
    elseif self._status == "ready" or self._status == "loud" or self._status == "push" or self._status == "hack" then
        c = Color.yellow
    else
        c = Color.red
    end
    EHIAchievementNotificationTracker.super.SetTextColor(self, c)
end

function EHIAchievementNotificationTracker:SetStatus(status)
    if self._dont_override_status then
        return
    end
    self._status = status
    self:SetText()
    self:SetTextColor()
    self:AnimateBG()
end

function EHIAchievementNotificationTracker:SetCompleted()
    self._exclude_from_sync = true
    self:SetStatus("done")
    self:AddTrackerToUpdate()
    self._dont_override_status = true
    self._achieved_popup_showed = true
end

function EHIAchievementNotificationTracker:SetFailed()
    self._exclude_from_sync = true
    self:SetStatus("fail")
    self:AddTrackerToUpdate()
    self._dont_override_status = true
    if show_failed then
        ShowPopup(self)
    end
end

EHIAchievementBagValueTracker = class(EHIProgressTracker)
EHIAchievementBagValueTracker._update = false
function EHIAchievementBagValueTracker:init(panel, params)
    self._secured = 0
    self._secured_formatted = "0"
    self._to_secure = params.to_secure or 0
    self._to_secure_formatted = self:FormatNumber(self._to_secure)
    EHIAchievementBagValueTracker.super.init(self, panel, params)
end

function EHIAchievementBagValueTracker:Format()
    return "$" .. self._secured_formatted .. "/$" .. self._to_secure_formatted
end

function EHIAchievementBagValueTracker:FormatNumber(n)
    local divisor = 1
    local post_fix = ""
    if n >= 1000000 then
        divisor = 1000000
        post_fix = "M"
    elseif n >= 1000 then
        divisor = 1000
        post_fix = "K"
    end
    return tostring(n / divisor) .. post_fix
end

function EHIAchievementBagValueTracker:SetProgress(progress)
    if self._secured ~= progress and not self._disable_counting then
        self._secured = progress
        self._secured_formatted = self:FormatNumber(progress)
        self._text:set_text(self:Format())
        self:FitTheText()
        if self._flash then
            self:AnimateBG(self._flash_times)
        end
        self:SetCompleted()
    end
end

function EHIAchievementBagValueTracker:IncreaseProgress(progress)
    self:SetProgress(self._secured + (progress or 1))
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
        self._disable_counting = true
        self._achieved_popup_showed = true
    end
end

function EHIAchievementBagValueTracker:SetFailed()
    if self._status and not self._status_is_overridable then
        return
    end
    self._exclude_from_sync = true
    self:SetTextColor(Color.red)
    self._status = "failed"
    self._parent_class:AddTrackerToUpdate(self._id, self)
    self:AnimateBG()
    self._disable_counting = true
    if show_failed then
        ShowPopup(self)
    end
end

EHIAchievementTimedProgressTracker = class(EHIWarningTracker)
EHIAchievementTimedProgressTracker._update = false
function EHIAchievementTimedProgressTracker:init(panel, params)
    self._max = params.max or 0
    self._progress = params.progress or 0
    self._previous_progress = self._progress
    self._flash = not params.dont_flash
    self._flash_max = not params.dont_flash_max
    self._remove_after_reaching_counter_target = params.remove_after_reaching_target ~= false
    --self._set_color_bad_when_reached = params.set_color_bad_when_reached
    self._flash_times = params.flash_times or 3
    self._status_is_overridable = params.status_is_overridable
    if params.start_counting then
        self._update = true
    end
    EHIAchievementTimedProgressTracker.super.init(self, panel, params)
end

function EHIAchievementTimedProgressTracker:OverridePanel(params)
    self._panel:set_w(self._panel:w() * 2)
    self._time_bg_box:set_w(self._time_bg_box:w() * 2)
    self._progress_text = self._time_bg_box:text({
        name = "text2",
        text = self:FormatProgress(),
        align = "center",
        vertical = "center",
        w = self._time_bg_box:w() / 2,
        h = self._time_bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h() * self._text_scale,
        color = params.text_color or Color.white
    })
    self:FitTheText(self._progress_text)
    self._progress_text:set_left(0)
    self._text:set_left(self._progress_text:right())
    if self._icon1 then
        self._icon1:set_x(self._icon1:x() * 2)
    end
end

function EHIAchievementTimedProgressTracker:FormatProgress()
    return self._progress .. "/" .. self._max
end

function EHIAchievementTimedProgressTracker:update(t, dt)
    if self._fade_time then
        self._fade_time = self._fade_time - dt
        if self._fade_time <= 0 then
            if show_failed then
                ShowPopup(self)
            end
            self:delete()
        end
        return
    end
    EHIAchievementTimedProgressTracker.super.update(self, t, dt)
end

function EHIAchievementTimedProgressTracker:AnimateWarning()
    if self._text and alive(self._text) then
        self._text:animate(function(o)
            while true do
                local t = 0
                while t < 1 do
                    t = t + coroutine.yield()
                    local n = 1 - sin(t * 180)
                    --local r = lerp(1, 0, n)
                    local g = lerp(1, 0, n)
                    local c = Color(1, g, g)
                    o:set_color(c)
                    self._progress_text:set_color(c)
                end
            end
        end)
    end
end

function EHIAchievementTimedProgressTracker:SetProgressMax(max)
    self._max = max
    self._progress_text:set_text(self:FormatProgress())
    if self._flash_max then
        self:AnimateBG(self._flash_times)
    end
end

function EHIAchievementTimedProgressTracker:IncreaseProgressMax(progress)
    self:SetProgressMax(self._max + (progress or 1))
end

function EHIAchievementTimedProgressTracker:SetProgress(progress)
    if self._progress ~= progress and not self._disable_counting then
        self._progress = progress
        self._progress_text:set_text(self:FormatProgress())
        self:FitTheText(self._progress_text)
        if self._flash then
            self:AnimateBG(self._flash_times)
        end
        --[[if self._set_color_bad_when_reached then
            self:SetBad()
        else
            self:SetCompleted()
        end]]
    end
end

function EHIAchievementTimedProgressTracker:IncreaseProgress(progress)
    self:SetProgress(self._progress + (progress or 1))
end

function EHIAchievementTimedProgressTracker:SetProgressRemaining(remaining)
    self:SetProgress(self._max - remaining)
end

function EHIAchievementTimedProgressTracker:SetCompleted(force)
    if (self._progress == self._max and not self._status) or force then
        self._exclude_from_sync = true
        self._status = "completed"
        self._text:stop()
        self:SetTextColor(Color.green)
        if self._remove_after_reaching_counter_target or force then
            self._fade_time = 5
            if not self._update then
                self._parent_class:AddTrackerToUpdate(self._id, self)
            end
        else
            self._progress_text:set_text("FINISH")
            self:FitTheText(self._progress_text)
        end
        self._disable_counting = true
        self._achieved_popup_showed = true
    end
end

function EHIAchievementTimedProgressTracker:SetBad()
    if self._progress == self._max then
        self:SetTextColor(tweak_data.ehi.color.Inaccurate)
    end
end

function EHIAchievementTimedProgressTracker:Finalize()
    if self._progress == self._max then
        self:SetCompleted(true)
    else
        self:SetFailed()
    end
end

function EHIAchievementTimedProgressTracker:SetFailed()
    if self._status and not self._status_is_overridable then
        return
    end
    self._exclude_from_sync = true
    self._text:stop()
    self:SetTextColor(Color.red)
    self._status = "failed"
    if not self._update then
        self._parent_class:AddTrackerToUpdate(self._id, self)
    end
    self:AnimateBG()
    self._disable_counting = true
    self._fade_time = 5
    if show_failed then
        ShowPopup(self)
    end
end

function EHIAchievementTimedProgressTracker:GetProgress()
    return self._progress
end

function EHIAchievementTimedProgressTracker:SetTextColor(color)
    EHIAchievementTimedProgressTracker.super.SetTextColor(self, color)
    self._progress_text:set_color(color)
end

EHIAchievementTimedMoneyCounterTracker = class(EHIWarningTracker)
function EHIAchievementTimedMoneyCounterTracker:init(panel, params)
    self._secured = 0
    self._secured_formatted = "0"
    self._to_secure = params.to_secure or 0
    self._to_secure_formatted = self:FormatNumber2(self._to_secure)
    EHIAchievementTimedMoneyCounterTracker.super.init(self, panel, params)
end

function EHIAchievementTimedMoneyCounterTracker:OverridePanel(params)
    self._panel:set_w(self._panel:w() * 2)
    self._time_bg_box:set_w(self._time_bg_box:w() * 2)
    self._money_text = self._time_bg_box:text({
        name = "text2",
        text = self:FormatNumber(),
        align = "center",
        vertical = "center",
        w = self._time_bg_box:w() / 2,
        h = self._time_bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h() * self._text_scale,
        color = params.text_color or Color.white
    })
    self:FitTheText(self._money_text)
    self._money_text:set_left(0)
    self._text:set_left(self._money_text:right())
    if self._icon1 then
        self._icon1:set_x(self._icon1:x() * 2)
    end
end

function EHIAchievementTimedMoneyCounterTracker:update(t, dt)
    if self._fade_time then
        self._fade_time = self._fade_time - dt
        if self._fade_time <= 0 then
            if show_failed then
                ShowPopup(self)
            end
            self:delete()
        end
        return
    end
    EHIAchievementTimedMoneyCounterTracker.super.update(self, t, dt)
end

function EHIAchievementTimedMoneyCounterTracker:FormatNumber2(n)
    local divisor = 1
    local post_fix = ""
    if n >= 1000000 then
        divisor = 1000000
        post_fix = "M"
    elseif n >= 1000 then
        divisor = 1000
        post_fix = "K"
    end
    return tostring(n / divisor) .. post_fix
end

function EHIAchievementTimedMoneyCounterTracker:FormatNumber()
    return "$" .. self._secured_formatted .. "/$" .. self._to_secure_formatted
end

function EHIAchievementTimedMoneyCounterTracker:AnimateWarning()
    if self._text and alive(self._text) then
        self._text:animate(function(o)
            while true do
                local t = 0
                while t < 1 do
                    t = t + coroutine.yield()
                    local n = 1 - sin(t * 180)
                    --local r = lerp(1, 0, n)
                    local g = lerp(1, 0, n)
                    local c = Color(1, g, g)
                    o:set_color(c)
                    self._money_text:set_color(c)
                end
            end
        end)
    end
end

function EHIAchievementTimedMoneyCounterTracker:SetProgress(progress)
    if self._secured ~= progress and not self._disable_counting then
        self._secured = progress
        self._secured_formatted = self:FormatNumber2(progress)
        self._money_text:set_text(self:FormatNumber())
        self:FitTheText(self._money_text)
        if self._flash then
            self:AnimateBG(self._flash_times)
        end
        self:SetCompleted()
    end
end

function EHIAchievementTimedMoneyCounterTracker:IncreaseProgress(progress)
    self:SetProgress(self._secured + (progress or 1))
end

function EHIAchievementTimedMoneyCounterTracker:SetCompleted(force)
    if (self._secured >= self._to_secure and not self._status) or force then
        self._status = "completed"
        self._text:stop()
        self:SetTextColor(Color.green)
        if self._remove_after_reaching_counter_target or force then
            self._fade_time = 5
            if not self._update then
                self._parent_class:AddTrackerToUpdate(self._id, self)
            end
        else
            self._money_text:set_text("FINISH")
            self:FitTheText(self._money_text)
        end
        self._disable_counting = true
        self._achieved_popup_showed = true
    end
end

function EHIAchievementTimedMoneyCounterTracker:SetFailed()
    if self._status and not self._status_is_overridable then
        return
    end
    self._exclude_from_sync = true
    self._text:stop()
    self:SetTextColor(Color.red)
    self._status = "failed"
    self._fade_time = 5
    if not self._update then
        self._parent_class:AddTrackerToUpdate(self._id, self)
    end
    self:AnimateBG()
    self._disable_counting = true
    if show_failed then
        ShowPopup(self)
    end
end

function EHIAchievementTimedMoneyCounterTracker:SetTextColor(color)
    EHIAchievementBagValueTracker.super.SetTextColor(self, color)
    self._money_text:set_color(color)
end

function EHIAchievementTimedMoneyCounterTracker:ResetFontSize(text)
    text:set_font_size(self._panel:h() * self._text_scale)
end

function EHIAchievementTimedMoneyCounterTracker:FitTheText(text)
    text = text or self._text
    self:ResetFontSize(text)
    local w = select(3, text:text_rect())
    if w > text:w() then
        text:set_font_size(text:font_size() * (text:w() / w) * self._text_scale)
    end
end