local EHI = EHI
if EHI:CheckLoadHook("PlayerMaskOff") or not EHI:GetBuffAndOption("interact") then
    return
end

local original =
{
    _start_action_state_standard = PlayerMaskOff._start_action_state_standard,
    _interupt_action_start_standard = PlayerMaskOff._interupt_action_start_standard
}
function PlayerMaskOff:_start_action_state_standard(t, ...)
    original._start_action_state_standard(self, t, ...)
    managers.ehi_buff:AddBuff("Interact", self._start_standard_expire_t - t)
end

function PlayerMaskOff:_interupt_action_start_standard(t, input, complete, ...)
    if not complete then
        managers.ehi_buff:RemoveAndResetBuff("Interact")
    end
    original._interupt_action_start_standard(self, t, input, complete, ...)
end