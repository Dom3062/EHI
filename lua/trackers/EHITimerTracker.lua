EHITimerTracker = EHITimerTracker or class(EHITracker)
EHITimerTracker._update = false
function EHITimerTracker:init(panel, params)
    if params.icons[1].icon then
        params.icons[2] = { icon = "faster", visible = false, alpha = 0.25 }
        params.icons[3] = { icon = "silent", visible = false, alpha = 0.25 }
        params.icons[4] = { icon = "restarter", visible = false, alpha = 0.25 }
    end
    self.theme = params.theme
    EHITimerTracker.super.init(self, panel, params)
    self:SetUpgradeable(false)
    self._paused = false
    self._jammed = false
    self._not_powered = false
    if params.upgrades then
        self:SetUpgradeable(true)
        self:SetUpgrades(params.upgrades)
    end
    if params.autorepair ~= nil then
        self:SetAutorepair(params.autorepair)
    end
end

function EHITimerTracker:SetTimeNoAnim(time) -- No fit text function needed, these timers just run down
    self._time = time
    self._text:set_text(self:Format())
end

function EHITimerTracker:SetDone()
    self._text:set_text("DONE")
    self:FitTheText()
end

function EHITimerTracker:SetUpgradeable(upgradeable)
    self._upgradeable = upgradeable
    if self._icon2 then
        self._icon2:set_visible(upgradeable)
        self._icon3:set_visible(upgradeable)
        self._icon4:set_visible(upgradeable)
    end
    if upgradeable then
        self._panel_override_w = self._panel:w()
        self._parent_class:ChangeTrackerWidth(self._id, self._panel_override_w)
    else
        self._panel_override_w = self._time_bg_box:w() + (38 * self._scale) -- 32 (icon size) + 6 (gap)
        self._parent_class:ChangeTrackerWidth(self._id, self._panel_override_w)
    end
end

function EHITimerTracker:SetUpgrades(upgrades)
    if not (self._upgradeable and upgrades) then
        return
    end
    local icon_definition =
    {
        faster = 2,
        silent = 3,
        restarter = 4
    }
    for upgrade, level in pairs(upgrades) do
        if level > 0 then
            local icon = self["_icon" .. tostring(icon_definition[upgrade])]
            if icon then
                icon:set_color(self:GetUpgradeColor(level))
                icon:set_alpha(1)
            end
        end
    end
end

function EHITimerTracker:GetUpgradeColor(level)
    if not self.theme then
        return TimerGui.upgrade_colors["upgrade_color_" .. level]
    end
    local theme = TimerGui.themes[self.theme]
    return theme and theme["upgrade_color_" .. level] or TimerGui.upgrade_colors["upgrade_color_" .. level]
end

function EHITimerTracker:SetAutorepair(state)
    self._icon1:set_color(state and tweak_data.ehi.color.DrillAutorepair or Color.white)
end

function EHITimerTracker:SetJammed(jammed)
    self._jammed = jammed
    self:SetTextColor()
end

function EHITimerTracker:SetPowered(powered)
    self._not_powered = not powered
    self:SetTextColor()
end

function EHITimerTracker:SetTextColor()
    if self._jammed or self._not_powered then
        self._text:set_color(Color.red)
    else
        self._text:set_color(Color.white)
    end
end