if EHI._hooks.TimerGui then
	return
else
	EHI._hooks.TimerGui = true
end

if not EHI:GetOption("show_timers") then
    return
end

local original =
{
    init = TimerGui.init,
    set_background_icons = TimerGui.set_background_icons,
    set_timer_multiplier = TimerGui.set_timer_multiplier,
    _start = TimerGui._start,
    _set_done = TimerGui._set_done,
    _set_jammed = TimerGui._set_jammed,
    _set_powered = TimerGui._set_powered,
    set_visible = TimerGui.set_visible,
    destroy = TimerGui.destroy,
    hide = TimerGui.hide
}

local level_id = Global.game_settings.level_id
local remove_on_power_off = false
if level_id == "des" then -- Henry's Rock
    remove_on_power_off = true
end

function TimerGui:init(unit, ...)
    self._ehi_key = tostring(unit:key())
    self._ehi_icon = unit:base().is_drill and "drill" or unit:base().is_hacking_device and "hack" or unit:base().is_saw and "saw" or "timer"
    original.init(self, unit, ...)
end

function TimerGui:set_background_icons(background_icons)
    local skills = self._unit:base().get_skill_upgrades and self._unit:base():get_skill_upgrades()

    if skills and table.size(background_icons or {}) > 0 then
        local upgrade_table = {
            restarter = (skills.auto_repair_level_1 or 0) + (skills.auto_repair_level_2 or 0),
            faster = (skills.speed_upgrade_level or 0),
            silent = (skills.reduced_alert and 1 or 0) + (skills.silent_drill and 1 or 0)
        }

        if managers.ehi:TrackerExists(self._ehi_key) then
            managers.ehi:CallFunction(self._ehi_key, "SetUpgradeable", true)
            managers.hud:SetUpgrades(self._ehi_key, upgrade_table)
        else
            managers.hud:AddToCache(self._ehi_key, upgrade_table)
        end
    end

    original.set_background_icons(self, background_icons)
end

function TimerGui:_start(timer)
    original._start(self, timer)
    if managers.ehi:TrackerExists(self._ehi_key) then
        managers.hud:SetTimerJammed(self._ehi_key, false)
        managers.hud:SetTimerPowered(self._ehi_key, true)
    else
        managers.ehi:AddTracker({
            id = self._ehi_key,
            time = self._current_timer,
            icons = { { icon = "pd2_" .. self._ehi_icon } },
            theme = self.THEME,
            class = "EHITimerTracker"
        })
    end
end

function TimerGui:_set_done()
    managers.ehi:RemoveTracker(self._ehi_key)
    original._set_done(self)
end

function TimerGui:_set_jammed(jammed, ...)
    managers.hud:SetTimerJammed(self._ehi_key, jammed)
    original._set_jammed(self, jammed, ...)
end

function TimerGui:_set_powered(powered, ...)
    if powered == false and remove_on_power_off then
        managers.ehi:RemoveTracker(self._ehi_key)
    end
    managers.hud:SetTimerPowered(self._ehi_key, powered)
    original._set_powered(self, powered, ...)
end

function TimerGui:set_visible(visible)
    if visible == false then
        managers.ehi:RemoveTracker(self._ehi_key)
    end
    original.set_visible(self, visible)
end

function TimerGui:hide()
    managers.ehi:RemoveTracker(self._ehi_key)
    original.hide(self)
end

function TimerGui:destroy(...)
    managers.ehi:RemoveTracker(self._ehi_key)
    original.destroy(self, ...)
end