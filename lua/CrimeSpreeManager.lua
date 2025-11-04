if EHI:CheckHook("CrimeSpreeManager") then
    return
end

Hooks:PostHook(CrimeSpreeManager, "_setup_global_from_mission_id", "EHI_CrimeSpreeManager_setup_global_from_mission_id", function(self, mission_id, ...)
    local mission_data = self:get_mission(mission_id)
    if mission_data and mission_data.level.level_id then
        if EHI.ModUtils._restoration_vanilla_levels_bs[mission_data.level.level_id] then -- Restoration Mod Overhaul bs
            Global.EHI_VanillaHeist = true
        else
            local level = tweak_data.levels[mission_data.level.level_id] or {}
            Global.EHI_VanillaHeist = not level.custom
        end
    end
end)