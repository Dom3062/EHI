if EHI._hooks.GroupAIStateBesiege then
	return
else
	EHI._hooks.GroupAIStateBesiege = true
end

local _f_set_phalanx_damage_reduction_buff = GroupAIStateBesiege.set_phalanx_damage_reduction_buff
function GroupAIStateBesiege:set_phalanx_damage_reduction_buff(damage_reduction)
    _f_set_phalanx_damage_reduction_buff(self, damage_reduction)
    managers.hud.ehi:SetChance("PhalanxDamageReduction", (EHI:RoundNumber(damage_reduction or 0, 0.01) * 100))
end