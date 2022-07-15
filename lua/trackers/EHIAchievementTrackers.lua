local EHI = EHI
local show_failed = EHI:GetOption("show_achievement_failed_popup")
local show_started = EHI:GetOption("show_achievement_started_popup")
local AchievementFailed = "ACHIEVEMENT FAILED!"
local AchievementStarted = "ACHIEVEMENT STARTED!"
local function ShowFailedPopup(tracker)
    if tracker._failed_popup_showed or tracker._achieved_popup_showed or tracker._no_failure then
        return
    end
    tracker._failed_popup_showed = true
    local id = tracker._id
    managers.hud:custom_ingame_popup_text(AchievementFailed, managers.localization:to_upper_text("achievement_" .. id), EHI:GetAchievementIconString(id))
end
local function ShowStartedPopup(tracker)
    if tracker._delay_popup then
        EHI:AddCallback("DelayAchievementStartedPopup", callback(tracker, tracker, "ShowStartedPopup"))
        return
    end
    local id = tracker._id
    managers.hud:custom_ingame_popup_text(AchievementStarted, managers.localization:to_upper_text("achievement_" .. id), EHI:GetAchievementIconString(id))
end
local lerp = math.lerp
local sin = math.sin
local Color = Color
if show_failed then
    EHI:SetNotificationAlert(AchievementFailed)
end
if show_started then
    EHI:SetNotificationAlert(AchievementStarted, nil, Color.green)
end

EHIAchievementTracker = class(EHIWarningTracker)
if show_started then
    function EHIAchievementTracker:init(panel, params)
        EHIAchievementTracker.super.init(self, panel, params)
        ShowStartedPopup(self)
    end
end
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
        ShowFailedPopup(self)
    end
end

if show_failed then
    function EHIAchievementTracker:delete()
        ShowFailedPopup(self)
        EHIAchievementTracker.super.delete(self)
    end
end

EHIAchievementProgressTracker = class(EHIProgressTracker)
function EHIAchievementProgressTracker:init(panel, params)
    self._no_failure = params.no_failure
    self._delay_popup = params.delay_popup
    EHIAchievementProgressTracker.super.init(self, panel, params)
    if show_started then
        ShowStartedPopup(self)
    end
end
if show_failed then
    function EHIAchievementProgressTracker:SetCompleted(force)
        self._achieved_popup_showed = true
        EHIAchievementProgressTracker.super.SetCompleted(self, force)
    end

    function EHIAchievementProgressTracker:SetFailed()
        EHIAchievementProgressTracker.super.SetFailed(self)
        ShowFailedPopup(self)
    end
end
function EHIAchievementProgressTracker:ShowStartedPopup()
    self._delay_popup = false
    ShowStartedPopup(self)
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

EHIAchievementUnlockTracker = class(EHIWarningTracker)
if show_started then
    function EHIAchievementUnlockTracker:init(panel, params)
        EHIAchievementUnlockTracker.super.init(self, panel, params)
        ShowStartedPopup(self)
    end
end
function EHIAchievementUnlockTracker:update(t, dt)
    if self._fade then
        self._fade_time = self._fade_time - dt
        if self._fade_time <= 0 then
            if show_failed then
                ShowFailedPopup(self)
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
        ShowFailedPopup(self)
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
    elseif self._status == "ready" or self._status == "loud" or self._status == "push" or self._status == "hack" or self._status == "land" or self._status ==  "find" then
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
        ShowFailedPopup(self)
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
    if show_started then
        ShowStartedPopup(self)
    end
end

function EHIAchievementBagValueTracker:OverridePanel(params)
    self._panel:set_w(self._panel:w() * 2)
    self._time_bg_box:set_w(self._time_bg_box:w() * 2)
    self._text:set_w(self._time_bg_box:w())
    self:FitTheText()
    if self._icon1 then
        self._icon1:set_x(self._icon1:x() * 2)
    end
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
        ShowFailedPopup(self)
    end
end