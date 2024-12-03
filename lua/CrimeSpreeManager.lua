if EHI:CheckHook("CrimeSpreeManager") then
    return
end

Hooks:PostHook(CrimeSpreeManager, "_setup_global_from_mission_id", "EHI_CrimeSpreeManager_setup_global_from_mission_id", function(self, mission_id, ...)
    local mission_data = self:get_mission(mission_id)
    if mission_data and mission_data.level.level_id then
        local level = tweak_data.levels[mission_data.level.level_id] or {}
        Global.game_settings.ehi_vanilla_heist = not level.custom
    end
end)