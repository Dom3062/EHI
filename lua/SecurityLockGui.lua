local EHI = EHI
if EHI._hooks.SecurityLockGui then
	return
else
	EHI._hooks.SecurityLockGui = true
end

if not EHI:GetOption("show_timers") then
    return
end

local show_waypoint = EHI:GetWaypointOption("show_waypoints_timers")
local show_waypoint_only = show_waypoint and EHI:GetWaypointOption("show_waypoints_only")

local original =
{
    init = SecurityLockGui.init,
    _start = SecurityLockGui._start,
    update = SecurityLockGui.update,
    _set_powered = SecurityLockGui._set_powered,
    _set_done = SecurityLockGui._set_done,
    destroy = SecurityLockGui.destroy
}

function SecurityLockGui:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = tostring(unit:key())
    self._ehi_bar_key = self._ehi_key .. "_bar"
end

function SecurityLockGui:_start(bar, ...)
    original._start(self, bar, ...)
    if self._bars > 1 then
        if managers.ehi:TrackerExists(self._ehi_bar_key) then
            managers.ehi:IncreaseTrackerProgress(self._ehi_bar_key)
        else
            managers.ehi:AddTracker({
                id = self._ehi_bar_key,
                icons = { "wp_hack" },
                class = "EHIProgressTracker",
                remove_after_reaching_target = false,
                exclude_from_sync = true,
                progress = bar,
                max = self._bars
            })
        end
    end
    if not show_waypoint_only then
        managers.ehi:AddTracker({
            id = self._ehi_key,
            time = self._current_timer,
            icons = { { icon = "wp_hack" } },
            exclude_from_sync = true,
            class = "EHITimerTracker"
        })
    end
    if show_waypoint then
        managers.ehi_waypoint:AddWaypoint(self._ehi_key, {
            time = self._current_timer,
            icon = "wp_hack",
            pause_timer = 1,
            type = "timer",
            position = self._unit:interaction() and self._unit:interaction():interact_position() or self._unit:position()
        })
    end
end

if show_waypoint_only then
    function SecurityLockGui:update(...)
        managers.ehi_waypoint:SetTimerWaypointTime(self._ehi_key, self._current_timer)
        original.update(self, ...)
    end
elseif show_waypoint then
    function SecurityLockGui:update(...)
        managers.ehi:SetTrackerTimeNoAnim(self._ehi_key, self._current_timer)
        managers.ehi_waypoint:SetTimerWaypointTime(self._ehi_key, self._current_timer)
        original.update(self, ...)
    end
else
    function SecurityLockGui:update(...)
        managers.ehi:SetTrackerTimeNoAnim(self._ehi_key, self._current_timer)
        original.update(self, ...)
    end
end

function SecurityLockGui:_set_powered(powered, ...)
    original._set_powered(self, powered, ...)
    managers.ehi:SetTimerPowered(self._ehi_key, powered)
    managers.ehi_waypoint:SetTimerWaypointPowered(self._ehi_key, powered)
end

function SecurityLockGui:_set_done(bar, ...)
    original._set_done(self, bar, ...)
    managers.ehi:RemoveTracker(self._ehi_key)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
    if self._started then
        managers.ehi:RemoveTracker(self._ehi_bar_key)
    end
end

function SecurityLockGui:destroy(...)
    managers.ehi:RemoveTracker(self._ehi_key)
    managers.ehi:RemoveTracker(self._ehi_bar_key)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
    original.destroy(self, ...)
end