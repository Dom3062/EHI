local EHI = EHI
if EHI:CheckLoadHook("MutatorsManager") then
    return
end

local _f_init = MutatorsManager.init
function MutatorsManager:init()
    _f_init(self)
    if not self:can_mutators_be_active() then
        return
    end
    local function check() -- Copy of MutatorsManager:are_achievements_disabled() but without 'if game_state_machine:current_state_name() ~= "menu_main" then' because it crashes during load
        for _, mutator in pairs(self:mutators()) do
            if mutator:is_active() and mutator.disables_achievements then
                return true
            end
        end
        return false
    end
    EHI._cache.UnlockablesAreDisabled = check()
    local data = {}
    data.xp_reduction = self:get_experience_reduction()
    data.MutatorPiggyBank = self:is_mutator_active(MutatorPiggyBank)
    data.MutatorCG22 = self:is_mutator_active(MutatorCG22)
    if managers.experience.SetMutatorData then
        managers.experience:SetMutatorData(data)
    end
end