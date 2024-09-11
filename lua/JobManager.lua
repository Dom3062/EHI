local EHI = EHI
if EHI:CheckLoadHook("JobManager") then
    return
end

---@class JobManager
---@field _global table
---@field current_contact_id fun(self: self): string
---@field current_difficulty_stars fun(self: self): number
---@field current_job_id fun(self: self): string
---@field current_job_stars fun(self: self): number
---@field get_ghost_bonus fun(self: self): number
---@field get_job_heat_multipliers fun(self: self, job_id: string): number?
---@field is_current_job_professional fun(self: self): boolean
---@field is_level_christmas fun(self: self, level_id: string): boolean
---@field on_last_stage fun(self: self): boolean
---@field current_level_wave_count fun(self: self): number

function JobManager:IsPlayingMultidayHeist()
    if not self._global.current_job then
        return false
    elseif self._global.current_job.current_stage == 1 then
        return false
    elseif string.sub(self._global.current_job.job_id or "", 1, -4) == "dayselect_random_" then -- `Any Day Any Heist` mod check
        return self._global.current_job.current_stage == self._global.current_job.stages
    end
    return self._global.current_job.stages >= 2
end