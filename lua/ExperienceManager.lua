if EHI:CheckHook("ExperienceManager") then
    return
end

local original =
{
    init = ExperienceManager.init,
    give_experience = ExperienceManager.give_experience,
    load = ExperienceManager.load,
    reset = ExperienceManager.reset
}

function ExperienceManager:init(...)
    original.init(self, ...)
    managers.ehi_experience:ExperienceInit(self)
end

function ExperienceManager:give_experience(...)
    local return_data = original.give_experience(self, ...)
    managers.ehi_experience:ExperienceReload(self)
    return return_data
end

function ExperienceManager:load(...)
    original.load(self, ...)
    managers.ehi_experience:ExperienceReload(self)
end

function ExperienceManager:reset(...)
    original.reset(self, ...)
    managers.ehi_experience:ExperienceReload(self)
end