---@class EHIPhalanxDamageReductionTracker : EHITimedChanceTracker
---@field super EHITimedChanceTracker
EHIPhalanxDamageReductionTracker = class(EHITimedChanceTracker)
EHIPhalanxDamageReductionTracker._forced_icons = { "buff_shield" }
EHIPhalanxDamageReductionTracker._forced_hint_text = "damage_reduction"
EHIPhalanxDamageReductionTracker._SetChance = EHIChanceTracker.SetChance
function EHIPhalanxDamageReductionTracker:post_init(params)
    local tweak = tweak_data.group_ai.phalanx
    self._tweak_data = tweak and tweak.vip and tweak.vip.damage_reduction or {
        max = 0.5,
        increase_intervall = 5
    }
    self._refresh_on_delete = true
end

function EHIPhalanxDamageReductionTracker:SetChance(amount)
    if amount <= 0 then
        self:ForceDelete()
        return
    elseif amount == (self._tweak_data.max * 100) then
        self:StopTimer()
    elseif self._started then
        self:SetTimeNoAnim(self._tweak_data.increase_intervall + 0.4)
    else
        self:StartTimer(self._tweak_data.increase_intervall + 0.4)
    end
    self:_SetChance(amount)
end