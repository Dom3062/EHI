if not Global.load_level then
    return
end

if EHI._hooks.MutatorsManager then
    return
else
    EHI._hooks.MutatorsManager = true
end

if EHI:IsXPTrackerDisabled() then
    return
end

local _f_init = MutatorsManager.init
function MutatorsManager:init()
    _f_init(self)
    if not self:can_mutators_be_active() then
        return
    end
    managers.experience:SetMutatorData(self:get_experience_reduction())
end