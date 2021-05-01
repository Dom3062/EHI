local function FixIcon(icon)
    if icon == "pd2_hack" then
        return "wp_hack"
    elseif icon == "pd2_saw" then
        return "pd2_generic_saw"
    else
        return icon
    end
end

EHITimerTracker = EHITimerTracker or class(EHITracker)
function EHITimerTracker:init(panel, params)
    if params.icons[1].icon then
        params.icons[1].icon = FixIcon(params.icons[1].icon)
        params.icons[1].visible = true
        params.icons[2] = { icon = "faster", visible = false, alpha = 0.25 }
        params.icons[3] = { icon = "silent", visible = false, alpha = 0.25 }
        params.icons[4] = { icon = "restarter", visible = false, alpha = 0.25 }
    else
        params.icons[1] = FixIcon(params.icons[1])
    end
    self.theme = params.theme
    EHITimerTracker.super.init(self, panel, params)
    self:SetUpgradeable(false)
    self._paused = false
    self._jammed = false
    self._not_powered = false
    local upgrades = self._parent_class:GetAndRemoveFromCache(self._id)
    if upgrades then
        self:SetUpgradeable(true)
        self:SetUpgrades(upgrades)
    end
end

function EHITimerTracker:update(t, dt)
    if self._paused or self._jammed or self._not_powered then
        return
    end
    self._time = self._time - dt
    self._text:set_text(self:Format())
    if self._time <= 0 then
        self._text:set_text("DONE")
        self:FitTheText()
        self._parent_class:RemoveTrackerFromUpdate(self._id)
    end
end

function EHITimerTracker:SetUpgradeable(upgradeable)
    self._upgradeable = upgradeable
    if self._icon2 then
        self._icon2:set_visible(upgradeable)
        self._icon3:set_visible(upgradeable)
        self._icon4:set_visible(upgradeable)
    end
end

function EHITimerTracker:SetUpgrades(upgrades)
    if not self._upgradeable then
        return
    end
    local icon_definition =
    {
        ["faster"] = 2,
        ["silent"] = 3,
        ["restarter"] = 4
    }
	for upgrade, level in pairs(upgrades) do
		if level > 0 then
            local icon = self["_icon" .. tostring(icon_definition[upgrade])]
			icon:set_color(self:GetUpgradeColor(level))
            icon:set_alpha(1)
		end
	end
    local timer_multiplier = tweak_data.upgrades.values.player.drill_speed_multiplier[upgrades.faster]
    if timer_multiplier then
        self:SetTimerMultiplier(timer_multiplier)
    end
end

function EHITimerTracker:GetUpgradeColor(level)
    if not self.theme then
        return TimerGui.upgrade_colors["upgrade_color_" .. level]
    end
    local theme = TimerGui.themes[self.theme]
    return theme and theme["upgrade_color_" .. level] or TimerGui.upgrade_colors["upgrade_color_" .. level]
end

function EHITimerTracker:SetTimerMultiplier(multiplier)
    local decrease_time = true
    if self._faster_level and multiplier >= self._faster_level then
        decrease_time = false
    end
    if decrease_time then
        local time_diff = (self._faster_level or 1) - multiplier
        local decrease = 1 - time_diff
        self._time = self._time * decrease
        if self._faster_level then
            self:AnimateBG()
        end
        self._faster_level = multiplier
    end
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

function EHITimerTracker:Sync(new_time)
end