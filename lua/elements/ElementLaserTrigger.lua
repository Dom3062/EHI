local EHI = EHI
if EHI._hooks.ElementLaserTrigger then
    return
else
    EHI._hooks.ElementLaserTrigger = true
end

if not EHI:GetOption("show_laser_tracker") then
    return
end

local original =
{
    init = ElementLaserTrigger.init,
    add_callback = ElementLaserTrigger.add_callback,
    remove_callback = ElementLaserTrigger.remove_callback,
    load = ElementLaserTrigger.load
}

function ElementLaserTrigger:init(...)
    original.init(self, ...)
    self._ehi_id = self._id .. "_laser"
end

function ElementLaserTrigger:add_callback()
    if not self._callback and self._is_cycled then
        managers.ehi:AddLaserTracker({
            id = self._ehi_id,
            time = self._values.cycle_interval,
            class = "EHILaserTracker"
        })
    end
    original.add_callback(self)
end

function ElementLaserTrigger:remove_callback()
    original.remove_callback(self)
	managers.ehi:RemoveTracker(self._ehi_id)
end

function ElementLaserTrigger:load(data)
    original.load(self, data)
    managers.ehi:CallFunction(self._ehi_id, "UpdateInterval", self._next_cycle_t)
end