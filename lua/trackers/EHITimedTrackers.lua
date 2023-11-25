---@class EHITimedChanceTracker : EHITracker, EHIChanceTracker
---@field super EHITracker
EHITimedChanceTracker = class(EHITracker)
EHITimedChanceTracker.pre_init = EHIChanceTracker.pre_init
EHITimedChanceTracker.IncreaseChance = EHIChanceTracker.IncreaseChance
EHITimedChanceTracker.DecreaseChance = EHIChanceTracker.DecreaseChance
EHITimedChanceTracker.SetChance = EHIChanceTracker.SetChance
EHITimedChanceTracker.FormatChance = EHIChanceTracker.FormatChance
function EHITimedChanceTracker:OverridePanel()
    self:PrecomputeDoubleSize()
    self._chance_text = self:CreateText({
        name = "chance_text",
        text = self:FormatChance()
    })
    self._text:set_left(self._chance_text:right())
    self._enabled = false
    self._refresh_on_delete = true
end

---@param params EHITracker.params
function EHITimedChanceTracker:post_init(params)
    if params.start_opened then
        self:SetBGSize(self._bg_box_double, "set")
        self:SetIconX()
    end
end

---@param t number?
function EHITimedChanceTracker:StartTimer(t)
    if t then
        self:SetTimeNoAnim(t)
    end
    self:AnimatePanelW(self._panel_double)
    self:ChangeTrackerWidth(self._bg_box_double + (self._icon_gap_size_scaled * self._n_of_icons))
    self:AnimIconX(self._bg_box_double + self._gap_scaled)
    self._bg_box:set_w(self._bg_box_double)
    self:AddTrackerToUpdate()
end

function EHITimedChanceTracker:StopTimer()
    self:AnimatePanelW(self._panel_w)
    self:ChangeTrackerWidth(self._bg_box_w + (self._icon_gap_size_scaled * self._n_of_icons))
    self:AnimIconX(self._bg_box_w + self._gap_scaled)
    self._bg_box:set_w(self._bg_box_w)
    self:RemoveTrackerFromUpdate()
end

---@class EHITimedWarningChanceTracker : EHITimedChanceTracker
---@field super EHITimedChanceTracker
EHITimedWarningChanceTracker = class(EHITimedChanceTracker)
EHITimedWarningChanceTracker._warning_color = EHIWarningTracker._warning_color
EHITimedWarningChanceTracker.update = EHIWarningTracker.update
EHITimedWarningChanceTracker.AnimateColor = EHIWarningTracker.AnimateColor
EHITimedWarningChanceTracker.SetTimeNoAnim = EHIWarningTracker.SetTimeNoAnim
EHITimedWarningChanceTracker.delete = EHIWarningTracker.delete

---@class EHITimedProgressTracker : EHIProgressTracker, EHITimedChanceTracker
---@field super EHIProgressTracker
EHITimedProgressTracker = class(EHIProgressTracker)
EHITimedProgressTracker.update = EHITracker.update
EHITimedProgressTracker.post_init = EHITracker.post_init
EHITimedProgressTracker.Format = EHITracker.Format
EHITimedProgressTracker.StartTimer = EHITimedChanceTracker.StartTimer
EHITimedProgressTracker.StopTimer = EHITimedChanceTracker.StopTimer
function EHITimedProgressTracker:OverridePanel()
    self:PrecomputeDoubleSize()
    self._progress_text = self:CreateText({
        name = "progress_text",
        text = self:FormatProgress()
    })
    self._text:set_left(self._progress_text:right())
    self._enabled = false
    self._refresh_on_delete = true
end

function EHITimedProgressTracker:Refresh()
    self:StopTimer()
end

---@param time number
function EHITimedProgressTracker:SetTimeNoAnim(time)
    EHITimedProgressTracker.super.SetTimeNoAnim(self, time)
    self:StartTimer()
end

---@param force boolean?
function EHITimedProgressTracker:SetCompleted(force)
    if force or not self._status then
        self.update = self.update_fade
        self._refresh_on_delete = nil
    end
    EHITimedProgressTracker.super.SetCompleted(self, force)
end

function EHITimedProgressTracker:SetFailed()
    if self._status and not self._status_is_overridable then
        return
    end
    self.update = self.update_fade
    self._refresh_on_delete = nil
    EHITimedProgressTracker.super.SetFailed(self)
end