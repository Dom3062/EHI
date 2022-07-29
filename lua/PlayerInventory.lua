local EHI = EHI
if EHI._hooks.PlayerInventory then
    return
else
    EHI._hooks.PlayerInventory = true
end

if EHI:GetOption("show_buffs") then
    local buff_original =
    {
        _start_jammer_effect = PlayerInventory._start_jammer_effect,
        _start_feedback_effect = PlayerInventory._start_feedback_effect
    }
    function PlayerInventory:_start_jammer_effect(end_time, ...)
        buff_original._start_jammer_effect(self, end_time, ...)
        if not end_time and managers.player:player_unit() == self._unit then
            managers.ehi_buff:AddBuff("HackerJammerEffect", self:get_jammer_time())
        end
    end

    function PlayerInventory:_start_feedback_effect(end_time, ...)
        buff_original._start_feedback_effect(self, end_time, ...)
        if not end_time and managers.player:player_unit() == self._unit then
            managers.ehi_buff:AddBuff("HackerFeedbackEffect", self:get_jammer_time())
        end
    end
end

if not EHI:GetOption("show_equipment_tracker") then
    return
end

local jammer = EHI:GetOption("show_equipment_ecmjammer")

if not jammer then
    return
end

local original =
{
    load = PlayerInventory.load
}

function PlayerInventory:load(data, ...)
    original.load(self, data, ...)
    if data._jammer_data and data._jammer_data.effect == "jamming" and jammer then
        local color = Color.white
        local peer_id = 0
        local peer = managers.network:session():peer_by_unit(self._unit)
        if peer then
            peer_id = peer:id()
            color = EHI:GetPeerColorByPeerID(peer_id)
        end
        if managers.ehi:TrackerExists("ECMJammer") then
            managers.ehi:CallFunction("ECMJammer", "SetTimeIfLower", data._jammer_data.t, peer_id)
        else
            managers.ehi:AddTracker({
                id = "ECMJammer",
                time = data._jammer_data.t,
                icons = { { icon = "ecm_jammer", color = color } },
                exclude_from_sync = true,
                class = "EHIECMTracker"
            })
        end
    end
end

original._start_jammer_effect = PlayerInventory._start_jammer_effect
function PlayerInventory:_start_jammer_effect(end_time, ...)
    if end_time then
        original._start_jammer_effect(self, end_time, ...)
        return
    end
    local jammer_time = self:get_jammer_time()
    if jammer_time == 0 then
        original._start_jammer_effect(self, end_time, ...)
        return
    end
    local peer_id = 0
    local peer = managers.network:session():peer_by_unit(self._unit)
    if peer then
        peer_id = peer:id()
    end
    if managers.ehi:TrackerExists("ECMJammer") then
        managers.ehi:CallFunction("ECMJammer", "SetTimeIfLower", jammer_time, peer_id)
    else
        managers.ehi:AddTracker({
            id = "ECMJammer",
            time = jammer_time,
            icons = { { icon = "ecm_jammer", color = EHI:GetPeerColorByPeerID(peer_id) } },
            exclude_from_sync = true,
            class = "EHIECMTracker"
        })
    end
    original._start_jammer_effect(self, end_time, ...)
end