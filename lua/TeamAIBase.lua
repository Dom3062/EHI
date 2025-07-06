local EHI = EHI
if EHI:CheckLoadHook("TeamAIBase") or not EHI:GetOption("show_buffs") then
    return
end

local original =
{
    set_loadout = TeamAIBase.set_loadout,
    remove_upgrades = TeamAIBase.remove_upgrades
}

---@param loadout { skill: string?, ability: string? }?
function TeamAIBase:set_loadout(loadout, ...)
    original.set_loadout(self, loadout, ...)
    if not loadout then
        return
    end
    EHI:CallCallback(EHI.CallbackMessage.TeamAISkillChange, loadout.skill or "none", "add")
    EHI:CallCallback(EHI.CallbackMessage.TeamAIAbilityChange, loadout.ability or "none", "add")
end

function TeamAIBase:remove_upgrades(...)
    if not self._loadout then
        original.remove_upgrades(self, ...)
        return
    end
    local skill = self._loadout.skill
    local ability = self._loadout.ability
    original.remove_upgrades(self, ...)
    EHI:CallCallback(EHI.CallbackMessage.TeamAISkillChange, skill or "none", "remove")
    EHI:CallCallback(EHI.CallbackMessage.TeamAIAbilityChange, ability or "none", "remove")
end