---@class EHITimedChanceTracker : EHITracker, EHIChanceTracker
---@field super EHITracker
EHITimedChanceTracker = class(EHITracker)
EHITimedChanceTracker.pre_init = EHIChanceTracker.pre_init
EHITimedChanceTracker.IncreaseChance = EHIChanceTracker.IncreaseChance
EHITimedChanceTracker.IncreaseChanceIndex = EHIChanceTracker.IncreaseChanceIndex
EHITimedChanceTracker.DecreaseChance = EHIChanceTracker.DecreaseChance
EHITimedChanceTracker.SetChance = EHIChanceTracker.SetChance
EHITimedChanceTracker.FormatChance = EHIChanceTracker.FormatChance
EHITimedChanceTracker._anim_chance = EHIChanceTracker._anim_chance
function EHITimedChanceTracker:OverridePanel()
    self:PrecomputeDoubleSize()
    self._chance_text = self:CreateText({
        text = self:FormatChance()
    })
    self._text:set_left(self._chance_text:right())
    self._refresh_on_delete = true
end

function EHITimedChanceTracker:post_init(params)
    if params.start_opened then
        self:SetBGSize(self._bg_box_double, "set")
    elseif params.stop_timer_on_end then
        self._stop_timer_on_end = true
        self._needs_update = false
    end
end

---@param t number?
---@param no_update boolean?
function EHITimedChanceTracker:StartTimer(t, no_update)
    if self._started then
        return
    end
    self._started = true
    if t then
        self:SetTimeNoAnim(t)
    end
    self:AnimatePanelW(self._panel_double)
    self:ChangeTrackerWidth(self._bg_box_double + (self._icon_gap_size_scaled * self._n_of_icons))
    self._bg_box:set_w(self._bg_box_double)
    self:AnimIconsX()
    self:AnimateAdjustHintX(self._default_bg_size)
    if not no_update then
        self:AddTrackerToUpdate()
    end
end

function EHITimedChanceTracker:StopTimer()
    if not self._started then
        return
    end
    self._started = nil
    self:AnimatePanelW(self._panel_w)
    self:ChangeTrackerWidth(self._default_bg_size + (self._icon_gap_size_scaled * self._n_of_icons))
    self._bg_box:set_w(self._default_bg_size)
    self:AnimIconsX()
    self:AnimateAdjustHintX(-self._default_bg_size)
    self:RemoveTrackerFromUpdate()
end

function EHITimedChanceTracker:Refresh()
    if self._stop_timer_on_end then
        self:StopTimer()
    end
end

---@class EHITimedWarningChanceTracker : EHITimedChanceTracker
---@field super EHITimedChanceTracker
EHITimedWarningChanceTracker = class(EHITimedChanceTracker)
EHITimedWarningChanceTracker._warning_color = EHIWarningTracker._warning_color
EHITimedWarningChanceTracker.update = EHIWarningTracker.update
EHITimedWarningChanceTracker.AnimateColor = EHIWarningTracker.AnimateColor
EHITimedWarningChanceTracker.SetTimeNoAnim = EHIWarningTracker.SetTimeNoAnim
EHITimedWarningChanceTracker._anim_warning = EHIWarningTracker._anim_warning
EHITimedWarningChanceTracker._anim_chance = EHIChanceTracker._anim_chance

---@class EHITimedProgressTracker : EHIProgressTracker, EHITimedChanceTracker
---@field super EHIProgressTracker
EHITimedProgressTracker = class(EHIProgressTracker)
EHITimedProgressTracker.update = EHITracker.update
EHITimedProgressTracker.Format = EHITracker.Format
EHITimedProgressTracker.StartTimer = EHITimedChanceTracker.StartTimer
EHITimedProgressTracker.StopTimer = EHITimedChanceTracker.StopTimer
function EHITimedProgressTracker:post_init(params)
    self:PrecomputeDoubleSize()
    self._progress_text = self:CreateText({
        text = self:FormatProgress()
    })
    self._text:set_left(self._progress_text:right())
    self._refresh_on_delete = true
    self._remove_on_max_progress = params.remove_on_max_progress
end

function EHITimedProgressTracker:Refresh()
    if self._remove_on_max_progress and self._progress == self._max then
        self:ForceDelete()
    else
        self:StopTimer()
    end
end

function EHITimedProgressTracker:SetTimeNoAnim(time)
    EHITimedProgressTracker.super.SetTimeNoAnim(self, time)
    self:StartTimer()
end

function EHITimedProgressTracker:DelayForcedDelete()
    self.update = self.update_fade
    EHITimedProgressTracker.super.DelayForcedDelete(self)
end