local EHI = EHI
if EHI:CheckLoadHook("MissionEndState") then
    return
end

local original =
{
    at_enter = MissionEndState.at_enter
}
function MissionEndState:at_enter(...)
    original.at_enter(self, ...)
    managers.ehi:HidePanel()
    if managers.experience.BlockXPUpdate then
        managers.experience:BlockXPUpdate()
    end
end