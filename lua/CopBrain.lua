local EHI = EHI
if EHI._hooks.CopBrain then
    return
else
    EHI._hooks.CopBrain = true
end

if not EHI:GetOption("show_pager_callback") then
    return
end

local original =
{
    on_alarm_pager_interaction = CopBrain.on_alarm_pager_interaction
}

function CopBrain:on_alarm_pager_interaction(status, ...)
    original.on_alarm_pager_interaction(self, status, ...)
    local id = "pager_" .. tostring(self._unit:key())
    if status == "started" then
        managers.ehi:CallFunction(id, "SetAnswered")
    else
        managers.ehi:RemoveTracker(id)
    end
end