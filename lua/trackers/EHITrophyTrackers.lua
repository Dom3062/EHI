local EHI = EHI
local show_failed = EHI:GetUnlockableOption("show_trophy_failed_popup")
local show_started = EHI:GetUnlockableOption("show_trophy_started_popup")
local function ShowFailedPopup(tracker)
    if tracker._failed_popup_showed or tracker._achieved_popup_showed or tracker._no_failure then
        return
    end
    tracker._failed_popup_showed = true
    managers.hud:ShowTrophyFailedPopup(tracker._id)
end
local function ShowStartedPopup(tracker)
    if tracker._delay_popup then
        EHI:AddCallback(EHI.CallbackMessage.Spawned, callback(tracker, tracker, "ShowStartedPopup"))
        return
    end
    managers.hud:ShowTrophyStartedPopup(tracker._id)
end
local Color = Color
if show_failed then
    EHI:SetNotificationAlert("TROPHY FAILED!", "ehi_popup_trophy_failed")
end
if show_started then
    EHI:SetNotificationAlert("TROPHY STARTED!", "ehi_popup_trophy_started", Color.green)
end

EHITrophyTracker = class(EHIWarningTracker)
if show_started then
    function EHITrophyTracker:init(panel, params)
        EHITrophyTracker.super.init(self, panel, params)
        ShowStartedPopup(self)
    end
end
EHITrophyTracker.update = EHIAchievementTracker.update
EHITrophyTracker.SetCompleted = EHIAchievementTracker.SetCompleted
function EHITrophyTracker:SetFailed()
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
    function EHITrophyTracker:delete()
        ShowFailedPopup(self)
        EHITrophyTracker.super.delete(self)
    end
end