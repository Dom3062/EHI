local EHI = EHI
if EHI._hooks.PlayerActionAmmoEfficiency then
    return
else
    EHI._hooks.PlayerActionAmmoEfficiency = true
end

if not EHI:GetOption("show_buffs") then
    return
end

if not EHI:GetBuffOption("ammo_efficiency") then
    return
end

local original = PlayerAction.AmmoEfficiency.Function
PlayerAction.AmmoEfficiency.Function = function(player_manager, target_headshots, bullet_refund, target_time)
    managers.ehi_buff:AddBuff2("ammo_efficiency", Application:time(), target_time)
    original(player_manager, target_headshots, bullet_refund, target_time)
end