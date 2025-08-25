local EHI = EHI
local Color = Color

---@generic T: table
---@param super T? A base class which `class` will derive from
---@return T
function _G.ehi_achievement_class(super)
    local klass = class(super)
    klass._popup_type = "achievement"
    klass._forced_icon_color = EHIAchievementTracker._forced_icon_color
    klass._show_started = EHIAchievementTracker._show_started
    klass._show_failed = EHIAchievementTracker._show_failed
    klass._show_desc = EHIAchievementTracker._show_desc
    klass.ShowStartedPopup = EHIAchievementTracker.ShowStartedPopup
    klass.ShowFailedPopup = EHIAchievementTracker.ShowFailedPopup
    klass.ShowAchievementDescription = EHIAchievementTracker.ShowAchievementDescription
    klass.PrepareHint = EHIAchievementTracker.PrepareHint
    klass.PlayerSpawned = EHIAchievementTracker.PlayerSpawned
    return klass
end

---@class EHIAchievementTracker : EHIWarningTracker
---@field super EHIWarningTracker
EHIAchievementTracker = class(EHIWarningTracker)
EHIAchievementTracker._popup_type = "achievement"
EHIAchievementTracker._forced_icon_color = { EHI:GetColorFromOption("unlockables", "achievement") }
EHIAchievementTracker._show_started = EHI:GetUnlockableOption("show_achievement_started_popup")
EHIAchievementTracker._show_failed = EHI:GetUnlockableOption("show_achievement_failed_popup")
EHIAchievementTracker._show_desc = EHI:GetUnlockableOption("show_achievement_description")
function EHIAchievementTracker:post_init(params)
    self._beardlib = params.beardlib
    self:ShowStartedPopup(params.delay_popup)
    self:ShowAchievementDescription(params.delay_popup)
    self:PrepareHint(params)
end

---@param params EHITracker.params
function EHIAchievementTracker:PrepareHint(params)
    local id = self._id or params.id
    if self._beardlib then
        params.hint = EHI._cache.Beardlib[id].name
        self._hint_no_localization = true
    else
        params.hint = "achievement_" .. id
        self._hint_vanilla_localization = true
    end
end

---@param success boolean?
function EHIAchievementTracker:delete_with_delay(success)
    self.update = self.update_fade
    self:StopAndSetTextColor(success and Color.green or Color.red)
    self:AddTrackerToUpdate()
    self:AnimateBG()
end

function EHIAchievementTracker:SetCompleted()
    self._achieved_popup_showed = true
    self:delete_with_delay(true)
end

function EHIAchievementTracker:SetFailed()
    self:delete_with_delay()
    self:ShowFailedPopup()
end

function EHIAchievementTracker:pre_destroy()
    self:ShowFailedPopup()
end

---@param delay_popup boolean?
function EHIAchievementTracker:ShowStartedPopup(delay_popup)
    if delay_popup or self._started_popup_showed or self._failed_on_sync or not self._show_started then ---@diagnostic disable-line
        return
    elseif self._popup_type == "sidejob" then
        managers.hud:ShowSideJobStartedPopup(self._id, self._daily_job, self._desc) ---@diagnostic disable-line
    elseif self._popup_type == "trophy" then
        managers.hud:ShowTrophyStartedPopup(self._id)
    else
        managers.hud:ShowAchievementStartedPopup(self._id, self._beardlib)
    end
    self._started_popup_showed = true
end

function EHIAchievementTracker:ShowFailedPopup()
    if self._failed_popup_showed or self._achieved_popup_showed or self._no_failure or not self._show_failed then ---@diagnostic disable-line
        return
    elseif self._popup_type == "sidejob" then
        managers.hud:ShowSideJobFailedPopup(self._id, self._daily_job, self._desc) ---@diagnostic disable-line
    elseif self._popup_type == "trophy" then
        managers.hud:ShowTrophyFailedPopup(self._id)
    else
        managers.hud:ShowAchievementFailedPopup(self._id, self._beardlib)
    end
    self._failed_popup_showed = true
end

---@param delay_popup boolean?
function EHIAchievementTracker:ShowAchievementDescription(delay_popup)
    if delay_popup or self._desc_showed or self._failed_on_sync or not self._show_desc then ---@diagnostic disable-line
        return
    elseif self._popup_type == "achievement" then
        managers.hud:ShowAchievementDescription(self._id, self._beardlib)
    elseif self._popup_type == "sidejob" then
        managers.hud:ShowSideJobDescription(self._id, self._daily_job) ---@diagnostic disable-line
    else
        managers.hud:ShowTrophyDescription(self._id)
    end
    self._desc_showed = true
end

function EHIAchievementTracker:PlayerSpawned()
    EHIAchievementTracker.super.PlayerSpawned(self)
    self:ShowStartedPopup()
    self:ShowAchievementDescription()
end

---@class EHIAchievementUnlockTracker : EHIAchievementTracker
---@field super EHIAchievementTracker
EHIAchievementUnlockTracker = class(EHIAchievementTracker)
EHIAchievementUnlockTracker._show_completion_color = true
EHIAchievementUnlockTracker.delete = EHIAchievementUnlockTracker.super.super.delete
EHIAchievementUnlockTracker.SetCompleted = function(...) end

---@class EHIAchievementProgressTracker : EHIProgressTracker, EHIAchievementTracker
---@field super EHIProgressTracker
EHIAchievementProgressTracker = ehi_achievement_class(EHIProgressTracker)
function EHIAchievementProgressTracker:init(panel, params)
    self._no_failure = params.no_failure
    self._beardlib = params.beardlib
    self._loot_parent = params.loot_parent --[[@as EHILootManager?]]
    self:PrepareHint(params)
    EHIAchievementProgressTracker.super.init(self, panel, params)
    self:ShowStartedPopup(params.delay_popup)
    self:ShowAchievementDescription(params.delay_popup)
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
    self:ShowFailedPopup()
end

---@param counter AchievementBagValueCounterTable|AchievementLootCounterTable
function EHIAchievementProgressTracker:AddLootListener(counter)
    if self._loot_parent then
        counter.achievement = counter.achievement or self._id
        counter.no_sync = true
        self._loot_parent:AddAchievementListener(counter, self._max)
    end
end

function EHIAchievementProgressTracker:pre_destroy()
    if self._loot_parent then
        self._loot_parent:RemoveListener(self._id)
    end
end

---@class EHIAchievementProgressGroupTracker : EHIProgressGroupTracker, EHIAchievementTracker, EHIAchievementProgressTracker
EHIAchievementProgressGroupTracker = ehi_achievement_class(EHIProgressGroupTracker)
EHIAchievementProgressGroupTracker.AddLootListener = EHIAchievementProgressTracker.AddLootListener
function EHIAchievementProgressGroupTracker:init(panel, params)
    self._beardlib = params.beardlib
    self:PrepareHint(params)
    EHIAchievementProgressGroupTracker.super.init(self, panel, params)
    self:ShowStartedPopup(params.delay_popup)
    self:ShowAchievementDescription(params.delay_popup)
end

---@class EHIAchievementBagValueTracker : EHINeededValueTracker, EHIAchievementTracker
---@field super EHINeededValueTracker
EHIAchievementBagValueTracker = ehi_achievement_class(EHINeededValueTracker)
function EHIAchievementBagValueTracker:post_init(params)
    self._beardlib = params.beardlib
    self:ShowStartedPopup(params.delay_popup)
    self:ShowAchievementDescription(params.delay_popup)
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
EHIAchievementStatusTracker._needs_update = false
EHIAchievementStatusTracker._green_status =
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
EHIAchievementStatusTracker._yellow_status =
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
function EHIAchievementStatusTracker:init(panel, params)
    self._status = params.status or "ok"
    EHIAchievementStatusTracker.super.init(self, panel, params)
    self:SetTextColor()
end

function EHIAchievementStatusTracker:Format()
    local status = "ehi_status_" .. self._status
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
    self:ShowFailedPopup()
end

---@param color Color?
function EHIAchievementStatusTracker:SetTextColor(color)
    local c
    if color then
        c = color
    elseif self._green_status[self._status] then
        c = Color.green
    elseif self._yellow_status[self._status] then
        c = Color.yellow
    else
        c = Color.red
    end
    EHIAchievementStatusTracker.super.SetTextColor(self, c)
end

---@class EHIAchievementLootCounterTracker : EHIProgressTracker, EHIAchievementTracker
---@field super EHIProgressTracker
EHIAchievementLootCounterTracker = ehi_achievement_class(EHIProgressTracker)
EHIAchievementLootCounterTracker._PlayerSpawned = EHIAchievementTracker.PlayerSpawned
EHIAchievementLootCounterTracker._show_popup = EHI:GetOption("show_all_loot_secured_popup")
function EHIAchievementLootCounterTracker:init(panel, params)
    self._no_failure = params.no_failure
    self._beardlib = params.beardlib
    self._loot_counter_on_fail = params.loot_counter_on_fail
    params.icons[2] = "pd2_loot"
    if params.start_silent then
        if self._ONE_ICON then
            self._achievement_icon = params.icons[1]
            params.first_icon_pos = 2
        else
            local achievement_icon = params.icons[1]
            params.icons[1] = { icon = achievement_icon, visible = false }
        end
        params.hint = "loot_counter"
        self._silent_start = true
    else
        self:PrepareHint(params)
        self:ShowStartedPopup(params.delay_popup)
        self:ShowAchievementDescription(params.delay_popup)
    end
    EHIAchievementLootCounterTracker.super.init(self, panel, params)
    if params.start_silent and self._icons[2] then
        if self._ICON_LEFT_SIDE_START and self._HORIZONTAL_ALIGNMENT then
            self._bg_box:set_x(self._bg_box:x() - self._icon_gap_size_scaled)
        end
        if not self._VERTICAL_ANIM_W_LEFT or (self._VERTICAL_ANIM_W_LEFT and not self._ICON_LEFT_SIDE_START) then
            self._icons[2]:set_x(self._icons[1]:x())
        end
    end
end

function EHIAchievementLootCounterTracker:pre_init(params)
    EHIAchievementLootCounterTracker.super.pre_init(self, params)
    self._offset = params.offset or 0
    self._loot_parent = params.loot_parent --[[@as EHILootManager]]
end

function EHIAchievementLootCounterTracker:PositionHint(x, y)
    if self._silent_start and self._icons[2] and self._ICON_LEFT_SIDE_START and self._VERTICAL_ANIM_W_LEFT then
        x = x + self._icon_gap_size_scaled
    end
    EHIAchievementLootCounterTracker.super.PositionHint(self, x, y)
end

function EHIAchievementLootCounterTracker:PlayerSpawned()
    if self._silent_start then
        EHIAchievementLootCounterTracker.super.PlayerSpawned(self)
        return
    end
    self:_PlayerSpawned()
end

function EHIAchievementLootCounterTracker:DelayForcedDelete()
    EHIAchievementLootCounterTracker.super.DelayForcedDelete(self)
    self._show_finish_after_reaching_target = nil
    if self:CanShowLootSecuredPopup() then
        self:ShowLootSecuredPopup()
    end
end

function EHIAchievementLootCounterTracker:SetCompleted(...)
    self._achieved_popup_showed = true
    EHIAchievementLootCounterTracker.super.SetCompleted(self, ...)
end

function EHIAchievementLootCounterTracker:SetFailed()
    if self._loot_counter_on_fail then
        self:AnimateBG()
        self._hint_vanilla_localization = nil
        self._hint_no_localization = nil
        self:UpdateHint("loot_counter")
        if self._icons[2] then
            self:RemoveIconAndAnimateMovement(1, true)
        else
            self:SetIconColor(Color.white)
            self:SetIcon("pd2_loot")
        end
        self._show_finish_after_reaching_target = nil
        self._status = nil
        self._disable_counting = false
        self:SetProgress(self._progress)
    else
        EHIAchievementLootCounterTracker.super.SetFailed(self)
    end
    if self._status_is_overridable then
        self._achieved_popup_showed = nil
    end
    self:ShowFailedPopup()
end

function EHIAchievementLootCounterTracker:SetFailed2()
    if self._failed_allowed then
        self:SetFailed()
    end
end

function EHIAchievementLootCounterTracker:SetFailedSilent()
    self._show_failed = nil
    self._show_finish_after_reaching_target = nil
    self._hint_vanilla_localization = nil
    self:UpdateHint("loot_counter")
    self:SetFailed()
end

function EHIAchievementLootCounterTracker:SetStarted()
    self._failed_allowed = self._silent_start
    if self._silent_start then
        self._hint_vanilla_localization = true
        self:UpdateHint("achievement_" .. self._id)
    end
    self:ShowStartedPopup()
    self._icons[1]:set_visible(true)
    if self._icons[2] then
        self._icons[2]:set_visible(true)
        self:SetMovement(self._anim_params.IconCreated)
    else
        self:SetIconColor(self._forced_icon_color[1])
        self:SetIcon(self._achievement_icon)
    end
    self:ShowAchievementDescription()
end

function EHIAchievementLootCounterTracker:SetProgress(progress)
    local fixed_progress = progress - self._offset
    EHIAchievementLootCounterTracker.super.SetProgress(self, fixed_progress)
end

function EHIAchievementLootCounterTracker:Finalize()
    local progress = self._progress
    self._progress = self._progress - self._offset
    EHIAchievementLootCounterTracker.super.Finalize(self)
    self._progress = progress
end

function EHIAchievementLootCounterTracker:SetCompleted(...)
    EHIAchievementLootCounterTracker.super.SetCompleted(self, ...)
    if self:CanShowLootSecuredPopup() then
        self:ShowLootSecuredPopup()
    end
end

function EHIAchievementLootCounterTracker:CanShowLootSecuredPopup()
    return self._show_popup and not self._popup_showed and not self._show_finish_after_reaching_target
end

function EHIAchievementLootCounterTracker:ShowLootSecuredPopup()
    self._popup_showed = true
    self.update = self.update_fade
    managers.hud:custom_ingame_popup_text("LOOT COUNTER", managers.localization:text("ehi_popup_all_loot_secured"), "EHI_Loot")
end

---@param max number
function EHIAchievementLootCounterTracker:SetProgressMax(max)
    EHIAchievementLootCounterTracker.super.SetProgressMax(self, max)
    self._disable_counting = nil
    self:VerifyStatus()
end

function EHIAchievementLootCounterTracker:VerifyStatus()
    if self._progress == self._max then
        self:SetCompleted()
    end
end

function EHIAchievementLootCounterTracker:pre_destroy()
    self._loot_parent:RemoveListener(self._id)
end