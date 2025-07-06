---@class EHIPermanentHealthRegenBuffTracker : EHIHealthRegenBuffTracker
---@field super EHIHealthRegenBuffTracker
EHIPermanentHealthRegenBuffTracker = class(EHIHealthRegenBuffTracker)
EHIPermanentHealthRegenBuffTracker.CanDeleteOnFalseSkillCheck = EHIPermanentBuffTracker.CanDeleteOnFalseSkillCheck
function EHIPermanentHealthRegenBuffTracker:SkillCheck()
    if not (managers.player:has_category_upgrade("player", "hostage_health_regen_addend") or managers.player:has_category_upgrade("player", "passive_health_regen")) then
        return false
    end
    self:SetPersistent()
    return EHIPermanentHealthRegenBuffTracker.super.SkillCheck(self)
end