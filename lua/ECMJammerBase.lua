local EHI = EHI
if EHI._hooks.ECMJammerBase then
    return
else
    EHI._hooks.ECMJammerBase = true
end

if not EHI:GetOption("show_equipment_tracker") then
    return
end

local original = {}

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
                managers.ehi:CallFunction("ECMJammer", "SetTimeIfLower", battery_life, self._owner_id)
            else
                managers.ehi:AddTracker({
                    id = "ECMJammer",
                    time = battery_life,
                    icons = { { icon = "ecm_jammer", color = EHI:GetPeerColorByPeerID(self._owner_id) } },
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
                managers.ehi:CallFunction("ECMFeedback", "SetTimeIfLower", self._feedback_duration, self._owner_id)
            else
                managers.ehi:AddTracker({
                    id = "ECMFeedback",
                    time = self._feedback_duration,
                    icons = { { icon = "ecm_feedback", color = EHI:GetPeerColorByPeerID(self._owner_id) } },
                    exclude_from_sync = true,
                    class = "EHIECMTracker"
                })
            end
        end
    end
end