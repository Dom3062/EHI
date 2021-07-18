if not Global.load_level then
    return
end

if EHI._hooks.JobManager then
    return
else
    EHI._hooks.JobManager = true
end

if not EHI:GetOption("show_gained_xp") then
    return
end

if Global.game_settings and Global.game_settings.gamemode and Global.game_settings.gamemode == "crime_spree" then
    return
end

local _f_init = JobManager.init
function JobManager:init(...)
    _f_init(self, ...)
    managers.experience:SetStealthBonus(self:get_ghost_bonus() or 0)
    local projob_multiplier = 1
    if self:is_current_job_professional() then
        projob_multiplier = tweak_data:get_value("experience_manager", "pro_job_multiplier") or 1
    end
    managers.experience:SetProJobMultiplier(projob_multiplier)
    managers.experience:SetJobHeat(self:heat_to_experience_multiplier(self:current_job_heat()))
end