local EHI = EHI
if EHI._hooks.CivilianDamage then
    return
else
    EHI._hooks.CivilianDamage = true
end
if not EHI:GetOption("show_trade_delay") then
    return
end

if EHI:GetOption("show_trade_delay_option") == 2 then
    return
end

local function AddTracker(peer_id)
    if EHI:GetOption("show_trade_delay_other_players_only") and peer_id == managers.network:session():local_peer():id() then
        return
    end
    local tweak_data = tweak_data.player.damage
    local delay = tweak_data.base_respawn_time_penalty + tweak_data.respawn_time_penalty
    if managers.ehi:TrackerExists("CustodyTime") then
        local tracker = managers.ehi:GetTracker("CustodyTime")
        if tracker then
            if tracker:PeerExists(peer_id) then
                tracker:IncreasePeerCustodyTime(peer_id, tweak_data.respawn_time_penalty)
            else
                tracker:AddPeerCustodyTime(peer_id, delay)
            end
        end
    else
        managers.ehi:AddCustodyTimeTrackerAndAddPeerCustodyTime(peer_id, delay)
    end
end

local _f_on_damage_received = CivilianDamage._on_damage_received
function CivilianDamage:_on_damage_received(damage_info)
    _f_on_damage_received(self, damage_info)
    local attacker_unit = damage_info and damage_info.attacker_unit
    if damage_info.result.type == "death" and attacker_unit then
        local peer_id = managers.criminals:character_peer_id_by_unit(attacker_unit)
        if peer_id then
            AddTracker(peer_id)
        end
    end
end