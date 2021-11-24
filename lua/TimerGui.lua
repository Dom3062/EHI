local EHI = EHI
if EHI._hooks.TimerGui then
	return
else
	EHI._hooks.TimerGui = true
end

if not EHI:GetOption("show_timers") then
    return
end

local show_waypoint = EHI:GetWaypointOption("show_waypoints_timers")
local show_waypoint_only = show_waypoint and EHI:GetWaypointOption("show_waypoints_only")

local original =
{
    init = TimerGui.init,
    set_background_icons = TimerGui.set_background_icons,
    set_timer_multiplier = TimerGui.set_timer_multiplier,
    _start = TimerGui._start,
    update = TimerGui.update,
    _set_done = TimerGui._set_done,
    _set_jammed = TimerGui._set_jammed,
    _set_powered = TimerGui._set_powered,
    set_visible = TimerGui.set_visible,
    destroy = TimerGui.destroy,
    hide = TimerGui.hide
}

function TimerGui:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = tostring(unit:key())
    self._ehi_icon = unit:base().is_drill and "pd2_drill" or unit:base().is_hacking_device and "wp_hack" or unit:base().is_saw and "pd2_generic_saw" or "faster"
end

function TimerGui:set_background_icons(background_icons, ...)
    original.set_background_icons(self, background_icons, ...)
    managers.ehi:SetTimerUpgrades(self._ehi_key, self:GetUpgrades())
end

function TimerGui:GetUpgrades()
    if self._unit:base()._disable_upgrades or not (self._unit:base().is_drill or self._unit:base().is_saw) or table.size(self._original_colors or {}) == 0 then
        return nil
    end
    local upgrade_table = nil
    local skills = self._unit:base().get_skill_upgrades and self._unit:base():get_skill_upgrades()
    if skills and table.size(self._original_colors or {}) > 0 then
        upgrade_table = {
            restarter = (skills.auto_repair_level_1 or 0) + (skills.auto_repair_level_2 or 0),
            faster = (skills.speed_upgrade_level or 0),
            silent = (skills.reduced_alert and 1 or 0) + (skills.silent_drill and 1 or 0)
        }
    end
    return upgrade_table
end

function TimerGui:StartTimer()
    if managers.ehi:TrackerExists(self._ehi_key) then
        managers.ehi:SetTimerJammed(self._ehi_key, false)
        managers.ehi:SetTimerPowered(self._ehi_key, true)
        managers.ehi_waypoint:SetTimerWaypointJammed(self._ehi_key, false)
        managers.ehi_waypoint:SetTimerWaypointPowered(self._ehi_key, true)
    else
        local autorepair = self._unit:base()._autorepair
        if not show_waypoint_only then
            managers.ehi:AddTracker({
                id = self._ehi_key,
                time = self._current_timer,
                icons = self._icons or { { icon = self._ehi_icon } },
                theme = self.THEME,
                exclude_from_sync = true,
                class = "EHITimerTracker",
                upgrades = self:GetUpgrades(),
                autorepair = autorepair
            })
        end
        if show_waypoint then
            managers.ehi_waypoint:AddWaypoint(self._ehi_key, {
                time = self._current_timer,
                icon = self._icons or self._ehi_icon,
                pause_timer = 1,
                type = "timer",
                position = self._unit:interaction() and self._unit:interaction():interact_position() or self._unit:position(),
                color = autorepair and tweak_data.ehi.color.DrillAutorepair or Color.white
            })
        end
    end
end

function TimerGui:_start(...)
    original._start(self, ...)
    if self._ignore then
        return
    end
    self:StartTimer()
end

if show_waypoint_only then
    function TimerGui:update(...)
        managers.ehi_waypoint:SetTimerWaypointTime(self._ehi_key, self._time_left)
        original.update(self, ...)
    end
elseif show_waypoint then
    function TimerGui:update(...)
        managers.ehi:SetTrackerTimeNoAnim(self._ehi_key, self._time_left)
        managers.ehi_waypoint:SetTimerWaypointTime(self._ehi_key, self._time_left)
        original.update(self, ...)
    end
else
    function TimerGui:update(...)
        managers.ehi:SetTrackerTimeNoAnim(self._ehi_key, self._time_left)
        original.update(self, ...)
    end
end

function TimerGui:_set_done(...)
    managers.ehi:RemoveTracker(self._ehi_key)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
    original._set_done(self, ...)
end

function TimerGui:_set_jammed(jammed, ...)
    managers.ehi:SetTimerJammed(self._ehi_key, jammed)
    managers.ehi_waypoint:SetTimerWaypointJammed(self._ehi_key, jammed)
    original._set_jammed(self, jammed, ...)
end

function TimerGui:_set_powered(powered, ...)
    if powered == false and self._remove_on_power_off then
        managers.ehi:RemoveTracker(self._ehi_key)
        managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
    end
    managers.ehi:SetTimerPowered(self._ehi_key, powered)
    managers.ehi_waypoint:SetTimerWaypointPowered(self._ehi_key, powered)
    original._set_powered(self, powered, ...)
end

function TimerGui:set_visible(visible, ...)
    if visible == false then
        managers.ehi:RemoveTracker(self._ehi_key)
        managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
    end
    original.set_visible(self, visible, ...)
end

function TimerGui:hide(...)
    managers.ehi:RemoveTracker(self._ehi_key)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
    original.hide(self, ...)
end

function TimerGui:destroy(...)
    managers.ehi:RemoveTracker(self._ehi_key)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
    original.destroy(self, ...)
end

function TimerGui:OnAlarm()
    self._ignore = true
    managers.ehi:RemoveTracker(self._ehi_key)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
end

function TimerGui:DisableOnSetVisible()
    self.set_visible = original.set_visible
    self._set_visible_disabled = true
end

function TimerGui:SetIcons(icons)
    self._icons = icons
end

function TimerGui:SetRemoveOnPowerOff(remove_on_power_off)
	self._remove_on_power_off = remove_on_power_off
end

function TimerGui:SetOnAlarm()
	EHI:AddOnAlarmCallback(callback(self, self, "OnAlarm"))
end

function TimerGui:Finalize()
    if self._ignore or (self._remove_on_power_off and not self._powered) then
        managers.ehi:RemoveTracker(self._ehi_key)
        managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
    elseif self._icons then
		managers.ehi:SetTrackerIcon(self._ehi_key, self._icons[1])
		managers.ehi_waypoint:SetWaypointIcon(self._ehi_key, self._icons[1])
    elseif self._set_visible_disabled and not self:is_visible() and (managers.ehi:TrackerDoesNotExist(self._ehi_key) or managers.ehi_waypoint:WaypointDoesNotExist(self._ehi_key)) then
        self:StartTimer()
	end
end