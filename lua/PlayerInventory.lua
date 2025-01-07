local EHI = EHI
if EHI:CheckLoadHook("PlayerInventory") then
    return
end

if EHI:GetOption("show_buffs") then
    if EHI:GetBuffDeckOption("hacker", "pecm_jammer") then
        local original_start_jammer_effect = PlayerInventory._start_jammer_effect
        function PlayerInventory:_start_jammer_effect(end_time, ...)
            local result = original_start_jammer_effect(self, end_time, ...)
            end_time = end_time or self:get_jammer_time()
            if result and end_time > 0 and self._unit:base().is_local_player then
                managers.ehi_buff:AddBuff("HackerJammerEffect", end_time)
            end
            return result
        end
    end
    if EHI:GetBuffDeckOption("hacker", "pecm_feedback") then
        local original_start_feedback_effect = PlayerInventory._start_feedback_effect
        function PlayerInventory:_start_feedback_effect(end_time, ...)
            local result = original_start_feedback_effect(self, end_time, ...)
            end_time = end_time or self:get_jammer_time()
            if result and end_time > 0 and self._unit:base().is_local_player then
                managers.ehi_buff:AddBuff("HackerFeedbackEffect", end_time)
            end
            return result
        end
    end
end

if not EHI:GetEquipmentOption("show_equipment_ecmjammer") then
    return
end

local original =
{
    _start_jammer_effect = PlayerInventory._start_jammer_effect
}

function PlayerInventory:_start_jammer_effect(end_time, ...)
    local result = original._start_jammer_effect(self, end_time, ...)
    end_time = end_time or self:get_jammer_time()
    if result and end_time > 0 then
        local peer = managers.network:session():peer_by_unit(self._unit)
        local peer_id = peer and peer:id() or 0
        if managers.ehi_tracker:CallFunction2("ECMJammer", "SetTimeIfLower", end_time, peer_id) then
            managers.ehi_tracker:AddTracker({
                id = "ECMJammer",
                time = end_time,
                icons = { { icon = "ecm_jammer", peer_id = peer_id } },
                hint = "ecm_jammer",
                class = "EHIECMTracker"
            })
        end
    end
    return result
end