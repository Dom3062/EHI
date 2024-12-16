local EHI = EHI
if EHI:CheckHook("JobManager") then
    return
end

---@class JobManager
---@field _global { current_job: { current_stage: number, job_id: string, stages: number, job_wrapper_id: string? } }
---@field current_contact_id fun(self: self): string
---@field current_difficulty_stars fun(self: self): number
---@field current_job_id fun(self: self): string
---@field current_job_stars fun(self: self): number
---@field get_ghost_bonus fun(self: self): number
---@field get_job_heat_multipliers fun(self: self, job_id: string): number?
---@field has_active_job fun(self: self): boolean
---@field is_current_job_professional fun(self: self): boolean
---@field is_level_christmas fun(self: self, level_id: string): boolean
---@field on_last_stage fun(self: self): boolean
---@field current_level_wave_count fun(self: self): number

function JobManager:IsPlayingMultidayHeist()
    if not self._global.current_job then
        return false
    elseif self._global.current_job.current_stage == 1 then
        return false
    elseif string.sub(self._global.current_job.job_id, 1, -4) == "dayselect_random_" then -- `Any Day Any Heist` mod check
        return self._global.current_job.current_stage == self._global.current_job.stages
    end
    return self._global.current_job.stages >= 2
end

local original =
{
    activate_job = JobManager.activate_job
}

---@param self JobManager
local function UpdateVanillaLevelSetting(self)
    local job = tweak_data.narrative.jobs[self._global.current_job.job_id] or {}
    if job and job.chain and job.chain[self._global.current_job.current_stage] then
        local level_id = job.chain[self._global.current_job.current_stage].level_id or ""
        local level = tweak_data.levels[level_id] or {}
        Global.game_settings.ehi_vanilla_heist = not level.custom
    end
end

function JobManager:activate_job(...)
    local result = original.activate_job(self, ...)
    if result and self._global.current_job then
        UpdateVanillaLevelSetting(self)
    end
    return result
end

if EHI.IsHost then
    original.next_stage = JobManager.next_stage
    function JobManager:next_stage(...)
        if not self:has_active_job() then
            return
        end
        local current_stage = self._global.current_job.current_stage
        original.next_stage(self, ...)
        if current_stage ~= self._global.current_job.current_stage then
            UpdateVanillaLevelSetting(self)
        end
    end
else
    original.set_current_stage = JobManager.set_current_stage
    function JobManager:set_current_stage(...)
        original.set_current_stage(self, ...)
        UpdateVanillaLevelSetting(self)
    end
end