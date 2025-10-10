---@generic T: table
---@param super T? A base achievement class
---@return T
local function ehi_unlockable_class(super)
    local klass = class(super)
    klass._show_started = false
    klass._show_failed = false
    klass._show_desc = false
    klass.CreateIcon = EHIUnlockableTracker.CreateIcon
    klass.PrepareHint = EHIUnlockableTracker.PrepareHint
    klass.PlayerSpawned = EHIUnlockableTracker.PlayerSpawned
    klass.ShowStartedPopup = EHIUnlockableTracker.ShowStartedPopup
    klass._ShowStartedPopup = EHIUnlockableTracker._ShowStartedPopup
    klass.ShowFailedPopup = EHIUnlockableTracker.ShowFailedPopup
    klass._ShowFailedPopup = EHIUnlockableTracker._ShowFailedPopup
    klass.ShowUnlockableDescription = EHIUnlockableTracker.ShowUnlockableDescription
    klass._ShowUnlockableDescription = EHIUnlockableTracker._ShowUnlockableDescription
    return klass
end

---@class EHIUnlockableTracker : EHIWarningTracker
---@field _forced_icon_color Color[]?
---@field super EHIWarningTracker
EHIUnlockableTracker = class(EHIWarningTracker)
EHIUnlockableTracker._show_started = false
EHIUnlockableTracker._show_failed = false
EHIUnlockableTracker._show_desc = false
function EHIUnlockableTracker:CreateIcon(i, i_pos, texture, texture_rect, x, visible, color, ...)
    EHIUnlockableTracker.super.CreateIcon(self, i, i_pos, texture, texture_rect, x, visible, self._forced_icon_color and self._forced_icon_color[i_pos] or color, ...)
end

function EHIUnlockableTracker:post_init(params)
    self:ShowStartedPopup(params.delay_popup)
    self:ShowUnlockableDescription(params.delay_popup)
    self:PrepareHint(params)
end

---@param params EHITracker.params
function EHIUnlockableTracker:PrepareHint(params)
end

function EHIUnlockableTracker:PlayerSpawned()
    EHIUnlockableTracker.super.PlayerSpawned(self)
    self:ShowStartedPopup()
    self:ShowUnlockableDescription()
end

function EHIUnlockableTracker:SetCompleted()
    self._achieved_popup_showed = true
    self:delete_with_delay(true)
end

function EHIUnlockableTracker:SetFailed()
    self:delete_with_delay()
    self:ShowFailedPopup()
end

---@param delay_popup boolean?
function EHIUnlockableTracker:ShowStartedPopup(delay_popup)
    if delay_popup or self._started_popup_showed or self._failed_on_sync or not self._show_started then ---@diagnostic disable-line
        return
    end
    self:_ShowStartedPopup()
    self._started_popup_showed = true
end

function EHIUnlockableTracker:_ShowStartedPopup()
end

function EHIUnlockableTracker:ShowFailedPopup()
    if self._failed_popup_showed or self._achieved_popup_showed or self._no_failure or not self._show_failed then ---@diagnostic disable-line
        return
    end
    self:_ShowFailedPopup()
    self._failed_popup_showed = true
end

function EHIUnlockableTracker:_ShowFailedPopup()
end

---@param delay_popup boolean?
function EHIUnlockableTracker:ShowUnlockableDescription(delay_popup)
    if delay_popup or self._desc_showed or self._failed_on_sync or not self._show_desc then ---@diagnostic disable-line
        return
    end
    self:_ShowUnlockableDescription()
    self._desc_showed = true
end

function EHIUnlockableTracker:_ShowUnlockableDescription()
end

---@param success boolean?
function EHIUnlockableTracker:delete_with_delay(success)
    self.update = self.update_fade
    self:StopAndSetTextColor(success and Color.green or Color.red)
    self:AnimateBG()
end

function EHIUnlockableTracker:pre_destroy()
    self:ShowFailedPopup()
end

---@class EHIUnlockableProgressTracker : EHIProgressTracker, EHIUnlockableTracker
---@field super EHIProgressTracker
EHIUnlockableProgressTracker = ehi_unlockable_class(EHIProgressTracker)
function EHIUnlockableProgressTracker:post_init(params)
    self._no_failure = params.no_failure
    EHIUnlockableProgressTracker.super.post_init(self, params)
    EHIUnlockableTracker.post_init(self, params)
end

function EHIUnlockableProgressTracker:SetCompleted(force)
    self._achieved_popup_showed = true
    EHIUnlockableProgressTracker.super.SetCompleted(self, force)
end

function EHIUnlockableProgressTracker:SetFailed()
    EHIUnlockableProgressTracker.super.SetFailed(self)
    if self._status_is_overridable then
        self._achieved_popup_showed = nil
    end
    self:ShowFailedPopup()
end

---@class EHIUnlockableTimedProgressTracker : EHITimedProgressTracker, EHIUnlockableTracker
---@field super EHITimedProgressTracker
EHIUnlockableTimedProgressTracker = ehi_unlockable_class(EHITimedProgressTracker)
EHIUnlockableTimedProgressTracker._warning_color = EHIWarningTracker._warning_color
EHIUnlockableTimedProgressTracker.update = EHIWarningTracker.update
EHIUnlockableTimedProgressTracker.AnimateColor = EHIWarningTracker.AnimateColor
---@param class EHIUnlockableTimedProgressTracker
EHIUnlockableTimedProgressTracker._anim_warning = function(o, old_color, color, start_t, class)
    local c = Color(old_color.r, old_color.g, old_color.b)
    local progress = class._progress_text
    local t = 1
    while true do
        while t > 0 do
            t = t - coroutine.yield()
            local n = math.sin(t * 180)
            c.r = math.lerp(old_color.r, color.r, n)
            c.g = math.lerp(old_color.g, color.g, n)
            c.b = math.lerp(old_color.b, color.b, n)
            o:set_color(c)
            progress:set_color(c)
        end
        t = 1
    end
end
function EHIUnlockableTimedProgressTracker:post_init(params)
    self:SetBGSize()
    self._progress_text = self:CreateText({
        text = self:FormatProgress(),
        w = self._bg_box:w() / 2,
        left = 0,
        FitTheText = true
    })
    self._text:set_left(self._progress_text:right())
    self._needs_update = not params.start_paused
    EHIUnlockableTracker.post_init(self, params)
end

function EHIUnlockableTimedProgressTracker:SetTextColor(color, ...)
    if self._status then
        self._text:stop()
    end
    self._text:set_color(color or Color.white)
    EHIUnlockableTimedProgressTracker.super.SetTextColor(self, color, ...)
end