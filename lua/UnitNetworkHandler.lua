local EHI = EHI
if EHI._hooks.UnitNetworkHandler then
    return
else
    EHI._hooks.UnitNetworkHandler = true
end

if not EHI:GetOption("show_pager_callback") then
    return
end

local _f_alarm_pager_interaction = UnitNetworkHandler.alarm_pager_interaction
function UnitNetworkHandler:alarm_pager_interaction(u_id, tweak_table, status, sender, ...)
    EHI:Log("AlarmPagerInteraction")
    if self._verify_gamestate(self._gamestate_filter.any_ingame) then
        EHI:Log("VerifyGameState")
        local unit_data = managers.enemy:get_corpse_unit_data_from_id(u_id)
        if unit_data and unit_data.unit:interaction():active() and unit_data.unit:interaction().tweak_data == tweak_table and self._verify_sender(sender) then
            EHI:Log("Condition is true")
            local id = "pager_" .. tostring(unit_data.unit:key())
            if status == 1 then
                EHI:Log("Answered")
                managers.ehi:CallFunction(id, "SetAnswered")
            else
                EHI:Log("Nope")
                managers.ehi:RemoveTracker(id)
            end
        end
    end
    return _f_alarm_pager_interaction(self, u_id, tweak_table, status, sender, ...)
end