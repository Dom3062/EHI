local EHI = EHI
if EHI._hooks.ECMJammerBase then
    return
else
    EHI._hooks.ECMJammerBase = true
end

if not EHI:GetOption("show_equipment_tracker") then
    return
end

local original =
{
    spawn = ECMJammerBase.spawn,
    set_server_information = ECMJammerBase.set_server_information,
    set_owner = ECMJammerBase.set_owner,
    sync_setup = ECMJammerBase.sync_setup,
    destroy = ECMJammerBase.destroy
}

function ECMJammerBase.spawn(pos, rot, battery_life_upgrade_lvl, owner, peer_id, ...)
    local unit = original.spawn(pos, rot, battery_life_upgrade_lvl, owner, peer_id, ...)
    unit:base():SetPeerID(peer_id or 0)
	return unit
end

function ECMJammerBase:set_server_information(peer_id, ...)
    original.set_server_information(self, peer_id, ...)
    self:SetPeerID(peer_id)
end

function ECMJammerBase:sync_setup(upgrade_lvl, peer_id, ...)
    original.sync_setup(self, upgrade_lvl, peer_id, ...)
    self:SetPeerID(peer_id)
end

function ECMJammerBase:set_owner(owner, ...)
    original.set_owner(self, owner, ...)
    self:SetPeerID(self._owner_id or 0)
    managers.ehi:CallFunction("ECMJammer", "UpdateOwnerID", self._ehi_peer_id)
    managers.ehi:CallFunction("ECMFeedback", "UpdateOwnerID", self._ehi_peer_id)
end

function ECMJammerBase:SetPeerID(peer_id)
    self._ehi_peer_id = peer_id
end

if EHI:GetOption("show_equipment_ecmjammer") then
    original.set_active = ECMJammerBase.set_active
    function ECMJammerBase:set_active(active, ...)
        original.set_active(self, active, ...)
        if active then
            local battery_life = self:battery_life()
            if battery_life == 0 then
                return
            end
            if managers.ehi:TrackerExists("ECMJammer") then
                managers.ehi:CallFunction("ECMJammer", "SetTimeIfLower", battery_life, self._ehi_peer_id, self._unit)
            else
                managers.ehi:AddTracker({
                    id = "ECMJammer",
                    time = battery_life,
                    icons = { { icon = "ecm_jammer", color = EHI:GetPeerColorByPeerID(self._ehi_peer_id) } },
                    unit = self._unit,
                    exclude_from_sync = true,
                    class = "EHIECMTracker"
                })
            end
        end
    end
end

if EHI:GetOption("show_equipment_ecmfeedback") then
    original._set_feedback_active = ECMJammerBase._set_feedback_active
    function ECMJammerBase:_set_feedback_active(state, ...)
        original._set_feedback_active(self, state, ...)
        if state and self._feedback_duration then
            if managers.ehi:TrackerExists("ECMFeedback") then
                managers.ehi:CallFunction("ECMFeedback", "SetTimeIfLower", self._feedback_duration, self._ehi_peer_id, self._unit)
            else
                managers.ehi:AddTracker({
                    id = "ECMFeedback",
                    time = self._feedback_duration,
                    icons = { { icon = "ecm_feedback", color = EHI:GetPeerColorByPeerID(self._ehi_peer_id) } },
                    unit = self._unit,
                    exclude_from_sync = true,
                    class = "EHIECMTracker"
                })
            end
        end
    end
end

function ECMJammerBase:destroy(...)
    original.destroy(self, ...)
    managers.ehi:CallFunction("ECMJammer", "Destroyed", self._unit)
    managers.ehi:CallFunction("ECMFeedback", "Destroyed", self._unit)
end