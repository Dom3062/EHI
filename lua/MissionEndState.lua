if EHI._hooks.MissionEndState then
    return
else
    EHI._hooks.MissionEndState = true
end

local original =
{
    at_enter = MissionEndState.at_enter
}
function MissionEndState:at_enter(...)
    original.at_enter(self, ...)
    managers.ehi:HidePanel()
end