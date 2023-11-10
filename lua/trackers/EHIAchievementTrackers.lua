local EHI = EHI
local Color = Color

---@class EHIAchievementTracker : EHIWarningTracker
---@field super EHIWarningTracker
EHIAchievementTracker = class(EHIWarningTracker)
EHIAchievementTracker._popup_type = "achievement"
EHIAchievementTracker._show_started = EHI:GetUnlockableOption("show_achievement_started_popup")
EHIAchievementTracker._show_failed = EHI:GetUnlockableOption("show_achievement_failed_popup")
EHIAchievementTracker._show_desc = EHI:GetUnlockableOption("show_achievement_description")
---@param params EHITracker_params
function EHIAchievementTracker:post_init(params)
    self._beardlib = params.beardlib
    if self._show_started then
        self:ShowStartedPopup()
    end
    if self._show_desc then
        self:ShowAchievementDescription()
    end
    self:PrepareHint(params)
end

---@param params EHITracker_params
function EHIAchievementTracker:PrepareHint(params)
    local id = self._id or params.id
    if self._beardlib then
        params.hint = EHI._cache.Beardlib[id].name
    else
        params.hint = "achievement_" .. id
    end
    params.hint_vanilla_localization = true
end

function EHIAchievementTracker:SetCompleted()
    self._text:stop()
    self.update = self.update_fade
    self._achieved_popup_showed = true
    self:SetTextColor(Color.green)
    self:AnimateBG()
end

function EHIAchievementTracker:SetFailed()
    self._text:stop()
    self.update = self.update_fade
    self:SetTextColor(Color.red)
    self:AnimateBG()
    if self._show_failed then
        self:ShowFailedPopup()
    end
end

function EHIAchievementTracker:delete()
    if self._show_failed then
        self:ShowFailedPopup()
    end
    EHIAchievementTracker.super.delete(self)
end

---@param delay_popup boolean?
function EHIAchievementTracker:ShowStartedPopup(delay_popup)
    if delay_popup or self._started_popup_showed or self._failed_on_sync then ---@diagnostic disable-line
        return
    end
    if self._popup_type == "daily" then
        managers.hud:ShowDailyStartedPopup(self._id)
    elseif self._popup_type == "trophy" then
        managers.hud:ShowTrophyStartedPopup(self._id)
    else
        managers.hud:ShowAchievementStartedPopup(self._id, self._beardlib)
    end
    self._started_popup_showed = true
end

function EHIAchievementTracker:ShowFailedPopup()
    if self._failed_popup_showed or self._achieved_popup_showed or self._no_failure then ---@diagnostic disable-line
        return
    end
    self._failed_popup_showed = true
    if self._popup_type == "daily" then
        managers.hud:ShowDailyFailedPopup(self._id)
    elseif self._popup_type == "trophy" then
        managers.hud:ShowTrophyFailedPopup(self._id)
    else
        managers.hud:ShowAchievementFailedPopup(self._id, self._beardlib)
    end
end

---@param delay_popup boolean?
function EHIAchievementTracker:ShowAchievementDescription(delay_popup)
    if delay_popup or self._desc_showed or self._failed_on_sync then ---@diagnostic disable-line
        return
    end
    if self._popup_type == "achievement" then
        managers.hud:ShowAchievementDescription(self._id, self._beardlib)
    else
        managers.hud:ShowTrophyDailyDescription(self._id)
    end
    self._desc_showed = true
end

function EHIAchievementTracker:PlayerSpawned()
    EHIAchievementTracker.super.PlayerSpawned(self)
    if self._show_started then
        self:ShowStartedPopup()
    end
    if self._show_desc then
        self:ShowAchievementDescription()
    end
end

---@class EHIAchievementProgressTracker : EHIProgressTracker, EHIAchievementTracker
---@field super EHIProgressTracker
EHIAchievementProgressTracker = class(EHIProgressTracker)
EHIAchievementProgressTracker._popup_type = "achievement"
EHIAchievementProgressTracker._show_started = EHIAchievementTracker._show_started
EHIAchievementProgressTracker._show_failed = EHIAchievementTracker._show_failed
EHIAchievementProgressTracker._show_desc = EHIAchievementTracker._show_desc
EHIAchievementProgressTracker.ShowStartedPopup = EHIAchievementTracker.ShowStartedPopup
EHIAchievementProgressTracker.ShowFailedPopup = EHIAchievementTracker.ShowFailedPopup
EHIAchievementProgressTracker.ShowAchievementDescription = EHIAchievementTracker.ShowAchievementDescription
EHIAchievementProgressTracker.PrepareHint = EHIAchievementTracker.PrepareHint
EHIAchievementProgressTracker.PlayerSpawned = EHIAchievementTracker.PlayerSpawned
---@param panel Panel
---@param params EHITracker_params
---@param parent_class EHITrackerManager
function EHIAchievementProgressTracker:init(panel, params, parent_class)
    self._no_failure = params.no_failure
    self._beardlib = params.beardlib
    self:PrepareHint(params)
    EHIAchievementProgressTracker.super.init(self, panel, params, parent_class)
    if self._show_started then
        self:ShowStartedPopup(params.delay_popup)
    end
    if self._show_desc then
        self:ShowAchievementDescription(params.delay_popup)
    end
end

function EHIAchievementProgressTracker:SetCompleted(force)
    self._achieved_popup_showed = true
    EHIAchievementProgressTracker.super.SetCompleted(self, force)
end

function EHIAchievementProgressTracker:SetFailed()
    EHIAchievementProgressTracker.super.SetFailed(self)
    if self._status_is_overridable then
        self._achieved_popup_showed = nil
    end
    if self._show_failed then
        self:ShowFailedPopup()
    end
end

---@class EHIAchievementUnlockTracker : EHIWarningTracker, EHIAchievementTracker
---@field super EHIWarningTracker
EHIAchievementUnlockTracker = class(EHIWarningTracker)
EHIAchievementUnlockTracker._popup_type = "achievement"
EHIAchievementUnlockTracker._show_completion_color = true
EHIAchievementUnlockTracker._show_started = EHIAchievementTracker._show_started
EHIAchievementUnlockTracker._show_failed = EHIAchievementTracker._show_failed
EHIAchievementUnlockTracker._show_desc = EHIAchievementTracker._show_desc
EHIAchievementUnlockTracker.ShowStartedPopup = EHIAchievementTracker.ShowStartedPopup
EHIAchievementUnlockTracker.ShowAchievementDescription = EHIAchievementTracker.ShowAchievementDescription
EHIAchievementUnlockTracker.SetFailed = EHIAchievementTracker.SetFailed
EHIAchievementUnlockTracker.PrepareHint = EHIAchievementTracker.PrepareHint
EHIAchievementUnlockTracker.PlayerSpawned = EHIAchievementTracker.PlayerSpawned
---@param params EHITracker_params
function EHIAchievementUnlockTracker:post_init(params)
    self._beardlib = params.beardlib
    if self._show_started then
        self:ShowStartedPopup()
    end
    if self._show_desc then
        self:ShowAchievementDescription()
    end
    self:PrepareHint(params)
end

---@class EHIAchievementBagValueTracker : EHINeededValueTracker, EHIAchievementTracker
---@field super EHINeededValueTracker
EHIAchievementBagValueTracker = class(EHINeededValueTracker)
EHIAchievementBagValueTracker._popup_type = "achievement"
EHIAchievementBagValueTracker._show_started = EHIAchievementTracker._show_started
EHIAchievementBagValueTracker._show_failed = EHIAchievementTracker._show_failed
EHIAchievementBagValueTracker._show_desc = EHIAchievementTracker._show_desc
EHIAchievementBagValueTracker.ShowStartedPopup = EHIAchievementTracker.ShowStartedPopup
EHIAchievementBagValueTracker.ShowFailedPopup = EHIAchievementTracker.ShowFailedPopup
EHIAchievementBagValueTracker.ShowAchievementDescription = EHIAchievementTracker.ShowAchievementDescription
EHIAchievementBagValueTracker.PrepareHint = EHIAchievementTracker.PrepareHint
EHIAchievementBagValueTracker.PlayerSpawned = EHIAchievementTracker.PlayerSpawned
---@param params EHITracker_params
function EHIAchievementBagValueTracker:post_init(params)
    self._beardlib = params.beardlib
    if self._show_started then
        self:ShowStartedPopup(params.delay_popup)
    end
    if self._show_desc then
        self:ShowAchievementDescription(params.delay_popup)
    end
    self:PrepareHint(params)
end

function EHIAchievementBagValueTracker:SetCompleted(force)
    EHIAchievementBagValueTracker.super.SetCompleted(self, force)
    self._achieved_popup_showed = true
end

function EHIAchievementBagValueTracker:SetFailed()
    EHIAchievementBagValueTracker.super.SetFailed(self)
    if self._show_failed then
        self:ShowFailedPopup()
    end
end

---@class EHIAchievementStatusTracker : EHIAchievementTracker
---@field super EHIAchievementTracker
EHIAchievementStatusTracker = class(EHIAchievementTracker)
EHIAchievementStatusTracker.update = EHIAchievementStatusTracker.update_fade
EHIAchievementStatusTracker._update = false
---@param panel Panel
---@param params EHITracker_params
---@param parent_class EHITrackerManager
function EHIAchievementStatusTracker:init(panel, params, parent_class)
    self._status = params.status or "ok"
    EHIAchievementStatusTracker.super.init(self, panel, params, parent_class)
    self:SetTextColor()
end

function EHIAchievementStatusTracker:Format()
    local status = "ehi_achievement_" .. self._status
    if LocalizationManager._custom_localizations[status] then
        return managers.localization:text(status)
    else
        return string.upper(self._status)
    end
end

---@param status string
function EHIAchievementStatusTracker:SetStatus(status)
    if self._dont_override_status or self._status == status then
        return
    end
    self._status = status
    self:SetStatusText(status)
    self:SetTextColor()
    self:AnimateBG()
end

function EHIAchievementStatusTracker:SetCompleted()
    self:SetStatus("done")
    self:AddTrackerToUpdate()
    self._dont_override_status = true
    self._achieved_popup_showed = true
end

function EHIAchievementStatusTracker:SetFailed()
    self:SetStatus("fail")
    self:AddTrackerToUpdate()
    self._dont_override_status = true
    if self._show_failed then
        self:ShowFailedPopup()
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
    mark = true,
    objective = true
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