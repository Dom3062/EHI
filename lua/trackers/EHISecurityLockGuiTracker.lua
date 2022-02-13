EHISecurityLockGuiTracker = EHISecurityLockGuiTracker or class(EHIProgressTracker)
function EHISecurityLockGuiTracker:OverridePanel(params)
    self._time_text = self._time_bg_box:text({
        name = "time_text",
        text = EHISecurityLockGuiTracker.super.super.Format(self),
        align = "center",
        vertical = "center",
        w = self._time_bg_box:w(),
        h = self._time_bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
        font_size = self._panel:h() * self._text_scale,
        color = params.text_color or Color.white
    })
    self._time_text:set_left(self._time_bg_box:right())
end

function EHISecurityLockGuiTracker:SetHackTime(time)
    self._time = time
    local new_w = self._panel:w() * 3
    self:SetPanelW(new_w)
    self._time_bg_box:set_w(self._time_bg_box:w() * 2)
    self:FitTheTime()
    self._parent_class:ChangeTrackerWidth(self._id, self:GetPanelSize())
    self:SetIconX(self._time_bg_box:w() + (5 * self._scale))
end

function EHISecurityLockGuiTracker:RemoveHack()
    local new_w = self._panel:w() / 3
    self:SetPanelW(new_w)
    self._time_bg_box:set_w(self._time_bg_box:w() / 2)
    self._parent_class:ChangeTrackerWidth(self._id, self:GetPanelSize())
    self:SetIconX(self._time_bg_box:w() + (5 * self._scale))
end

function EHISecurityLockGuiTracker:GetPanelSize()
    return self._time_bg_box:w() + (37 * self._scale) -- 32 + 5 (gap)
end

function EHISecurityLockGuiTracker:SetTimeNoAnim(time) -- No fit text function needed, these timers just run down
    self._time = time
    self._time_text:set_text(EHISecurityLockGuiTracker.super.super.Format(self))
end

function EHISecurityLockGuiTracker:SetPowered(powered)
    self._not_powered = not powered
    self:SetTimeColor()
end

function EHISecurityLockGuiTracker:SetTimeColor()
    if self._not_powered then
        self._time_text:set_color(Color.red)
    else
        self._time_text:set_color(Color.white)
    end
end

function EHISecurityLockGuiTracker:ResetTimeFontSize()
    self._time_text:set_font_size(self._panel:h() * self._text_scale)
end

function EHISecurityLockGuiTracker:FitTheTime()
    self:ResetTimeFontSize()
    local w = select(3, self._time_text:text_rect())
    if w > self._time_text:w() then
        self._time_text:set_font_size(self._time_text:font_size() * (self._time_text:w() / w) * self._text_scale)
    end
end