if not Global.load_level then
    return
end

if EHI._hooks.JobManager then
    return
else
    EHI._hooks.JobManager = true
end

if EHI:IsXPTrackerDisabled() then
    return
end

local _f_init = JobManager.init
function JobManager:init(...)
    _f_init(self, ...)
    local data = {}
    data.job_stars = self:current_job_stars()
    data.difficulty_stars = self:current_difficulty_stars()
    data.stealth_bonus = self:get_ghost_bonus()
    data.level_id = self:current_level_id()
    data.projob_multiplier = 1
    if self:is_current_job_professional() then
        data.projob_multiplier = tweak_data:get_value("experience_manager", "pro_job_multiplier") or 1
    end
    local heat = self:get_job_heat_multipliers(self:current_job_id())
    data.heat = heat and heat ~= 0 and heat or 1
    managers.experience:SetJobData(data)
end