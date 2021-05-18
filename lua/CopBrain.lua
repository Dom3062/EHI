if EHI._hooks.CopBrain then
    return
else
    EHI._hooks.CopBrain = true
end

local original =
{
    clbk_alarm_pager = CopBrain.clbk_alarm_pager,
    on_alarm_pager_interaction = CopBrain.on_alarm_pager_interaction
}

--[[function CopBrain:clbk_alarm_pager(ignore_this, data)
    original.clbk_alarm_pager(self, ignore_this, data)
    if self._unit:interaction().tweak_data == "corpse_alarm_pager" and not self._pager_has_run then
        self._pager_has_run = true
        managers.ehi:AddPagerTracker({
            id = "pager_" .. tostring(self._unit:key()),
            class = "EHIPagerTracker"
        })
    end
end]]

function CopBrain:on_alarm_pager_interaction(status, player)
    original.on_alarm_pager_interaction(self, status, player)
    local id = "pager_" .. tostring(self._unit:key())
    if status == "started" then
        managers.ehi:CallFunction(id, "SetAnswered")
    else
        managers.ehi:RemoveTracker(id)
    end
end