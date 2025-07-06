local EHI = EHI
if EHI:CheckHook("JobManager") then
    return
end

function JobManager:IsPlayingMultidayHeist()
    if not self._global.current_job then
        return false
    elseif self._global.current_job.current_stage == 1 then
        return false
    elseif string.sub(self._global.current_job.job_id, 1, -4) == "dayselect_random_" then -- `Any Day Any Heist` mod check
        return self:on_last_stage()
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
        if EHI.ModUtils._restoration_vanilla_levels_bs[level_id] then -- Restoration Mod Overhaul bs
            Global.game_settings.ehi_vanilla_heist = true
        else
            local level = tweak_data.levels[level_id] or {}
            Global.game_settings.ehi_vanilla_heist = not level.custom
        end
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
    Hooks:PostHook(JobManager, "set_current_stage", "EHI_JobManager_set_current_stage", UpdateVanillaLevelSetting)
end