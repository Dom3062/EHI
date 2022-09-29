local EHI = EHI
local show_failed = EHI:GetUnlockableOption("show_daily_failed_popup")
local show_started = EHI:GetUnlockableOption("show_daily_started_popup")
local function ShowFailedPopup(tracker)
    if tracker._failed_popup_showed or tracker._achieved_popup_showed or tracker._no_failure then
        return
    end
    tracker._failed_popup_showed = true
    managers.hud:ShowDailyFailedPopup(tracker._id)
end
local function ShowStartedPopup(tracker)
    if tracker._delay_popup then
        EHI:AddCallback(EHI.CallbackMessage.Spawned, callback(tracker, tracker, "ShowStartedPopup"))
        return
    end
    managers.hud:ShowDailyStartedPopup(tracker._id)
end
local Color = Color
if show_failed then
    EHI:SetNotificationAlert("DAILY SIDE JOB FAILED!", "ehi_popup_daily_failed")
end
if show_started then
    EHI:SetNotificationAlert("DAILY SIDE JOB STARTED!", "ehi_popup_daily_started", Color.green)
end

EHIDailyTracker = class(EHIWarningTracker)
if show_started then
    function EHIDailyTracker:init(panel, params)
        EHIDailyTracker.super.init(self, panel, params)
        ShowStartedPopup(self)
    end
end
EHIDailyTracker.update = EHIAchievementTracker.update
EHIDailyTracker.SetCompleted = EHIAchievementTracker.SetCompleted
function EHIDailyTracker:SetFailed()
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
    function EHIDailyTracker:delete()
        ShowFailedPopup(self)
        EHIDailyTracker.super.delete(self)
    end
end

EHIDailyProgressTracker = class(EHIProgressTracker)
function EHIDailyProgressTracker:init(panel, params)
    self._no_failure = params.no_failure
    self._delay_popup = params.delay_popup
    EHIDailyProgressTracker.super.init(self, panel, params)
    if show_started then
        ShowStartedPopup(self)
    end
end
if show_failed then
    function EHIDailyProgressTracker:SetCompleted(force)
        self._achieved_popup_showed = true
        EHIDailyProgressTracker.super.SetCompleted(self, force)
    end

    function EHIDailyProgressTracker:SetFailed()
        EHIDailyProgressTracker.super.SetFailed(self)
        ShowFailedPopup(self)
    end
end
function EHIDailyProgressTracker:ShowStartedPopup()
    self._delay_popup = false
    ShowStartedPopup(self)
end