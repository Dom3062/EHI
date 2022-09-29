local EHI = EHI
local show_failed = EHI:GetUnlockableOption("show_achievement_failed_popup")
local show_started = EHI:GetUnlockableOption("show_achievement_started_popup")
local function ShowFailedPopup(tracker)
    if tracker._failed_popup_showed or tracker._achieved_popup_showed or tracker._no_failure then
        return
    end
    tracker._failed_popup_showed = true
    managers.hud:ShowAchievementFailedPopup(tracker._id)
end
local function ShowStartedPopup(tracker)
    if tracker._delay_popup then
        EHI:AddCallback(EHI.CallbackMessage.Spawned, callback(tracker, tracker, "ShowStartedPopup"))
        return
    end
    managers.hud:ShowAchievementStartedPopup(tracker._id)
end
local lerp = math.lerp
local sin = math.sin
local Color = Color
if show_failed then
    EHI:SetNotificationAlert("ACHIEVEMENT FAILED!", "ehi_popup_achievement_failed")
end
if show_started then
    EHI:SetNotificationAlert("ACHIEVEMENT STARTED!", "ehi_popup_achievement_started", Color.green)
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
        self:SetStatusText("finish")
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

EHIAchievementBagValueTracker = class(EHINeededValueTracker)
if show_started then
    function EHIAchievementBagValueTracker:init(panel, params)
        EHIAchievementBagValueTracker.super.init(self, panel, params)
        self._delay_popup = params.delay_popup
        ShowStartedPopup(self)
    end

    function EHIAchievementBagValueTracker:ShowStartedPopup()
        self._delay_popup = false
        ShowStartedPopup(self)
    end
end

function EHIAchievementBagValueTracker:SetCompleted(force)
    EHIAchievementBagValueTracker.super.SetCompleted(self, force)
    self._achieved_popup_showed = true
end

if show_failed then
    function EHIAchievementBagValueTracker:SetFailed()
        EHIAchievementBagValueTracker.super.SetFailed(self)
        ShowFailedPopup(self)
    end
end

local show_status_changed_popup = false
EHIAchievementStatusTracker = class(EHIAchievementTracker)
EHIAchievementStatusTracker._update = false
function EHIAchievementStatusTracker:init(panel, params)
    self._status = params.status or "ok"
    self._fade_time = 5
    EHIAchievementStatusTracker.super.init(self, panel, params)
    self:SetTextColor()
end

function EHIAchievementStatusTracker:update(t, dt)
    self._fade_time = self._fade_time - dt
    if self._fade_time <= 0 then
        self:delete()
    end
end

function EHIAchievementStatusTracker:Format()
    local status = "ehi_achievement_" .. self._status
    if LocalizationManager._custom_localizations[status] then
        return managers.localization:text(status)
    else
        return string.upper(self._status)
    end
end

function EHIAchievementStatusTracker:SetStatus(status)
    if self._dont_override_status or self._status == status then
        return
    end
    self._status = status
    self:SetStatusText(status)
    self:SetTextColor()
    self:AnimateBG()
    if show_status_changed_popup and status ~= "done" and status ~= "fail" then
        managers.hud:custom_ingame_popup_text("")
    end
end

function EHIAchievementStatusTracker:SetCompleted()
    self._exclude_from_sync = true
    self:SetStatus("done")
    self:AddTrackerToUpdate()
    self._dont_override_status = true
    self._achieved_popup_showed = true
end

function EHIAchievementStatusTracker:SetFailed()
    self._exclude_from_sync = true
    self:SetStatus("fail")
    self:AddTrackerToUpdate()
    self._dont_override_status = true
    if show_failed then
        ShowFailedPopup(self)
    end
end

local green_status =
{
    ok = true,
    done = true,
    pass = true,
    finish = true,
    destroy = true,
    defend = true,
    no_down = true,
    secure = true
}
local yellow_status =
{
    alarm = true,
    ready = true,
    loud = true,
    push = true,
    hack = true,
    land = true,
    find = true,
    bring = true,
    mark = true
}
function EHIAchievementStatusTracker:SetTextColor(color)
    local c
    if color then
        c = color
    elseif green_status[self._status] then
        c = Color.green
    elseif yellow_status[self._status] then
        c = Color.yellow
    else
        c = Color.red
    end
    EHIAchievementStatusTracker.super.SetTextColor(self, c)
end
if show_status_changed_popup then
    for status, _ in pairs(green_status) do
        EHI:SetNotificationAlert("ACHIEVEMENT STATUS", "ehi_achievement_" .. status, Color.green)
    end
    for status, _ in pairs(yellow_status) do
        EHI:SetNotificationAlert("ACHIEVEMENT STATUS", "ehi_achievement_" .. status, Color.yellow)
    end
end