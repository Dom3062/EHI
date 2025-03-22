local EHI = EHI
if EHI:CheckLoadHook("ElementExperience") or EHI:IsXPTrackerDisabled() or _G.ch_settings then
    return
end

local original =
{
    init = ElementExperience.init,
    on_executed = ElementExperience.on_executed
}

function ElementExperience:init(...)
    original.init(self, ...)
    managers.ehi_experience:AddXPElement(self)
end

function ElementExperience:on_executed(...)
    if not self._values.enabled then
        return
    end
    managers.ehi_experience:MissionXPAwarded(self._values.amount)
    if EHI.debug.gained_experience.enabled then
        local s = string.format("`%s` ElementExperience %d: Gained %d XP", self._editor_name, self._id, self._values.amount)
        managers.chat:_receive_message(1, "[EHI]", s, Color.white)
        if EHI.debug.gained_experience.log then
            EHI:Log(s)
        end
    end
    original.on_executed(self, ...)
end