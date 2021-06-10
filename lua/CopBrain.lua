if EHI._hooks.CopBrain then
    return
else
    EHI._hooks.CopBrain = true
end

local original =
{
    on_alarm_pager_interaction = CopBrain.on_alarm_pager_interaction
}

function CopBrain:on_alarm_pager_interaction(status, player)
    original.on_alarm_pager_interaction(self, status, player)
    local id = "pager_" .. tostring(self._unit:key())
    if status == "started" then
        managers.ehi:CallFunction(id, "SetAnswered")
    else
        managers.ehi:RemoveTracker(id)
    end
end