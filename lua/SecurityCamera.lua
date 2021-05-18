if EHI._hooks.SecurityCamera then
	return
else
	EHI._hooks.SecurityCamera = true
end

local original =
{
    init = SecurityCamera.init,
    _start_tape_loop = SecurityCamera._start_tape_loop,
    destroy = SecurityCamera.destroy
}

function SecurityCamera:init(unit)
    original.init(self, unit)
    self._ehi_key = tostring(unit:key())
end

function SecurityCamera:_start_tape_loop(tape_loop_t)
    original._start_tape_loop(self, tape_loop_t)
    managers.ehi:AddTracker({
        id = self._ehi_key,
        time = tape_loop_t + 5,
        icons = { "camera_loop" },
        class = "EHIWarningTracker"
    })
end

function SecurityCamera:destroy(unit)
    original.destroy(self, unit)
    managers.hud:RemoveTracker(self._ehi_key)
end