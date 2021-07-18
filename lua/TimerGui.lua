local EHI = EHI
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
local ignore = {}
if level_id == "des" then -- Henry's Rock
    remove_on_power_off = true
elseif level_id == "sand" then -- The Ukrainian Prisoner Heist
    local function f()
        local editor_id = EHI:GetInstanceUnitID(100150, 9030)
        for _, unit in pairs(World:find_units_quick("all", 1)) do
            if unit and unit:editor_id() == editor_id then
                unit:timer_gui():OnAlarm()
            end
        end
        ignore[editor_id] = true
    end
    EHI:AddOnAlarmCallback(f)
end

function TimerGui:init(unit, ...)
    self._ehi_key = tostring(unit:key())
    self._ehi_icon = unit:base().is_drill and "drill" or unit:base().is_hacking_device and "hack" or unit:base().is_saw and "saw" or "timer"
    original.init(self, unit, ...)
end

function TimerGui:set_background_icons(background_icons, ...)
    local skills = self._unit:base().get_skill_upgrades and self._unit:base():get_skill_upgrades()

    if skills and table.size(background_icons or {}) > 0 then
        local upgrade_table = {
            restarter = (skills.auto_repair_level_1 or 0) + (skills.auto_repair_level_2 or 0),
            faster = (skills.speed_upgrade_level or 0),
            silent = (skills.reduced_alert and 1 or 0) + (skills.silent_drill and 1 or 0)
        }

        if managers.ehi:TrackerExists(self._ehi_key) then
            managers.ehi:SetTrackerUpgradeable(self._ehi_key, true)
            managers.ehi:SetTimerUpgrades(self._ehi_key, upgrade_table)
        else
            managers.ehi:AddToCache(self._ehi_key, upgrade_table)
        end
    end

    original.set_background_icons(self, background_icons, ...)
end

function TimerGui:_start(...)
    original._start(self, ...)
    if ignore[self._unit:editor_id()] then
        return
    end
    if managers.ehi:TrackerExists(self._ehi_key) then
        managers.ehi:SetTimerJammed(self._ehi_key, false)
        managers.ehi:SetTimerPowered(self._ehi_key, true)
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

function TimerGui:_set_done(...)
    managers.ehi:RemoveTracker(self._ehi_key)
    original._set_done(self, ...)
end

function TimerGui:_set_jammed(jammed, ...)
    managers.ehi:SetTimerJammed(self._ehi_key, jammed)
    original._set_jammed(self, jammed, ...)
end

function TimerGui:_set_powered(powered, ...)
    if powered == false and remove_on_power_off then
        managers.ehi:RemoveTracker(self._ehi_key)
    end
    managers.ehi:SetTimerPowered(self._ehi_key, powered)
    original._set_powered(self, powered, ...)
end

function TimerGui:set_visible(visible, ...)
    if visible == false then
        managers.ehi:RemoveTracker(self._ehi_key)
    end
    original.set_visible(self, visible, ...)
end

function TimerGui:hide(...)
    managers.ehi:RemoveTracker(self._ehi_key)
    original.hide(self, ...)
end

function TimerGui:destroy(...)
    managers.ehi:RemoveTracker(self._ehi_key)
    original.destroy(self, ...)
end

function TimerGui:OnAlarm()
    managers.ehi:RemoveTracker(self._ehi_key)
end