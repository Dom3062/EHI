if EHI._hooks.SecurityLockGui then
	return
else
	EHI._hooks.SecurityLockGui = true
end

if not EHI:GetOption("show_timers") then
    return
end

local original =
{
    init = SecurityLockGui.init,
    _start = SecurityLockGui._start,
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
    managers.ehi:AddTracker({
        id = self._ehi_key,
        time = self._current_timer,
        icons = { { icon = "wp_hack" } },
        exclude_from_sync = true,
        class = "EHITimerTracker"
    })
end

function SecurityLockGui:_set_powered(powered, ...)
    original._set_powered(self, powered, ...)
    managers.ehi:SetTimerPowered(self._ehi_key, powered)
end

function SecurityLockGui:_set_done(bar, ...)
    original._set_done(self, bar, ...)
    managers.ehi:RemoveTracker(self._ehi_key)
    if self._started then
        managers.ehi:RemoveTracker(self._ehi_bar_key)
    end
end

function SecurityLockGui:destroy(...)
    original.destroy(self, ...)
	managers.ehi:RemoveTracker(self._ehi_key)
    managers.ehi:RemoveTracker(self._ehi_bar_key)
end