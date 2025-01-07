local EHI = EHI
if EHI:CheckLoadHook("PlayerActionExpertHandling") or not EHI:GetBuffAndOption("desperado") then
    return
end

local original = PlayerAction.ExpertHandling.Function
PlayerAction.ExpertHandling.Function = function(player_manager, accuracy_bonus, max_stacks, max_time, ...)
    managers.ehi_buff:AddBuff("desperado", max_time - Application:time())
    original(player_manager, accuracy_bonus, max_stacks, max_time, ...)
    managers.ehi_buff:RemoveBuff("desperado")
end