local EHI = EHI
if EHI:CheckLoadHook("SecurityLockGui") or not EHI:GetTrackerWaypointHudlistOption("show_timers", "show_waypoints_timers", "show_timers") then
    return
end

local HackIcon = EHI.Icons.PCHack
local TimerClass = EHI.Trackers.Timer

local show_tracker, show_waypoint, show_hudlist = EHI:GetShowTrackerWaypointAndHudlist("show_timers", "show_waypoints_timers", "show_timers")

local original =
{
    init = SecurityLockGui.init,
    _start = SecurityLockGui._start,
    update = SecurityLockGui.update,
    _set_powered = SecurityLockGui._set_powered,
    _set_done = SecurityLockGui._set_done,
    destroy = SecurityLockGui.destroy
}

---@param unit UnitDigitalTimer
function SecurityLockGui:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = tostring(unit:key())
    if show_tracker then
        EHI:OptionAndLoadTracker("show_timers")
    end
    if show_waypoint then
        EHI:OptionAndLoadWaypoint("show_timers")
    end
end

function SecurityLockGui:_start(...)
    original._start(self, ...)
    if show_tracker then
        if self._bars > 1 and self._current_bar then
            if managers.ehi_tracker:CallFunction2(self._ehi_key, "SetProgress", self._current_bar) then
                managers.ehi_tracker:AddTracker({
                    id = self._ehi_key,
                    progress = self._current_bar,
                    max = self._bars,
                    show_progress_on_finish = true,
                    icons = { HackIcon },
                    hint = "hack",
                    class = TimerClass.Progress
                })
            end
            managers.ehi_tracker:CallFunction(self._ehi_key, "StartTimer", self._current_timer, true)
        else
            managers.ehi_tracker:AddTracker({
                id = self._ehi_key,
                time = self._current_timer,
                icons = { HackIcon },
                hint = "hack",
                class = TimerClass.Base
            })
        end
    end
    if show_waypoint then
        local interact = self._unit:interaction()
        managers.ehi_waypoint:AddWaypoint(self._ehi_key, {
            time = self._current_timer,
            icon = HackIcon,
            position = interact and interact:interact_position() or self._unit:position(),
            class = "EHITimerWaypoint"
        })
    end
    if show_hudlist then
        managers.ehi_hudlist:CallLeftListItemFunction("Timer", "AddTimer", {
            id = self._ehi_key,
            time = self._current_timer,
            icon = HackIcon,
            has_progress = self._bars > 1 and self._current_bar,
            max = self._bars,
            progress = self._current_bar,
            hint = "process"
        })
    end
end

if show_tracker and show_waypoint and show_hudlist then
    function SecurityLockGui:update(...)
        managers.ehi_timer:UpdateTimer(self._ehi_key, self._current_timer)
        managers.ehi_hudlist:CallLeftListItemFunction("Timer", "UpdateTimer", self._ehi_key, self._current_timer)
        original.update(self, ...)
    end
elseif show_tracker and show_waypoint then
    function SecurityLockGui:update(...)
        managers.ehi_timer:UpdateTimer(self._ehi_key, self._current_timer)
        original.update(self, ...)
    end
elseif show_tracker and show_hudlist then
    function SecurityLockGui:update(...)
        managers.ehi_tracker:SetTimeNoAnim(self._ehi_key, self._current_timer)
        managers.ehi_hudlist:CallLeftListItemFunction("Timer", "UpdateTimer", self._ehi_key, self._current_timer)
        original.update(self, ...)
    end
elseif show_waypoint and show_hudlist then
    function SecurityLockGui:update(...)
        managers.ehi_waypoint:SetTime(self._ehi_key, self._current_timer)
        managers.ehi_hudlist:CallLeftListItemFunction("Timer", "UpdateTimer", self._ehi_key, self._current_timer)
        original.update(self, ...)
    end
elseif show_waypoint then
    function SecurityLockGui:update(...)
        managers.ehi_waypoint:SetTime(self._ehi_key, self._current_timer)
        original.update(self, ...)
    end
elseif show_tracker then
    function SecurityLockGui:update(...)
        managers.ehi_tracker:SetTimeNoAnim(self._ehi_key, self._current_timer)
        original.update(self, ...)
    end
else
    function SecurityLockGui:update(...)
        managers.ehi_hudlist:CallLeftListItemFunction("Timer", "UpdateTimer", self._ehi_key, self._current_timer)
        original.update(self, ...)
    end
end

function SecurityLockGui:_set_powered(powered, ...)
    original._set_powered(self, powered, ...)
    managers.ehi_timer:SetPowered(self._ehi_key, powered)
    managers.ehi_hudlist:CallLeftListItemFunction("Timer", "SetPowered", self._ehi_key, powered)
end

function SecurityLockGui:_set_done(...)
    original._set_done(self, ...)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
    if self._started then
        managers.ehi_tracker:RemoveTracker(self._ehi_key)
        managers.ehi_hudlist:CallLeftListItemFunction("Timer", "RemoveTimer", self._ehi_key)
    else
        managers.ehi_tracker:CallFunction(self._ehi_key, "StopTimer")
        managers.ehi_hudlist:CallLeftListItemFunction("Timer", "RemoveTimer", self._ehi_key)
    end
end

function SecurityLockGui:destroy(...)
    managers.ehi_tracking:Remove(self._ehi_key)
    managers.ehi_hudlist:CallLeftListItemFunction("Timer", "RemoveTimer", self._ehi_key)
    original.destroy(self, ...)
end