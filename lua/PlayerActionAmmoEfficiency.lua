local EHI = EHI
if EHI:CheckLoadHook("PlayerActionAmmoEfficiency") or not EHI:GetBuffAndOption("ammo_efficiency") then
    return
end

local original = PlayerAction.AmmoEfficiency.Function
PlayerAction.AmmoEfficiency.Function = function(player_manager, target_headshots, bullet_refund, target_time, ...)
    managers.ehi_buff:AddBuff("ammo_efficiency", target_time - Application:time())
    original(player_manager, target_headshots, bullet_refund, target_time, ...)
    managers.ehi_buff:RemoveBuff("ammo_efficiency")
end