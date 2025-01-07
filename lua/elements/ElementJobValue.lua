local EHI = EHI
if EHI:CheckLoadHook("ElementJobValue") or not (EHI:GetUnlockableAndOption("show_achievements") and EHI:GetUnlockableOption("show_achievements_other")) then
    return
end

Hooks:PostHook(ElementJobValue, "init", "EHI_ElementJobValue_init", function(self, ...)
    if self._values.save and self._values.key then
        if table.contains(tweak_data.achievement.collection_achievements.xm20_1.collection, self._values.key) and EHI:IsAchievementLocked2("xm20_1") then
            self:ehi_activate_collection("xm20_1", tweak_data.achievement.collection_achievements.xm20_1.collection)
        elseif table.contains(tweak_data.achievement.collection_achievements.pent_11.collection, self._values.key) and EHI:IsAchievementLocked2("pent_11") then
            self:ehi_activate_collection("pent_11", tweak_data.achievement.collection_achievements.pent_11.collection)
        end
    end
end)

---@param achievement_id string
---@param keys string[]
function ElementJobValue:ehi_activate_collection(achievement_id, keys)
    Hooks:PreHook(MissionManager, "on_set_saved_job_value", "EHI_" .. achievement_id .. "_Achievement",
    ---@param key string
    ---@param value number
    function(mm, key, value)
        if table.contains(keys, key) and value == 1 then
            local progress, max = 0, 0
            for _, item in ipairs(keys) do
                max = max + 1 -- To not rely on hardcoded max number
                if Global.mission_manager.saved_job_values[item] then
                    progress = progress + 1
                end
            end
            if progress == max then
                return
            end
            managers.hud:custom_ingame_popup_text(managers.localization:to_upper_text("achievement_" .. achievement_id), tostring(progress) .. "/" .. tostring(max), EHI:GetAchievementIconString(achievement_id))
        end
    end)
end