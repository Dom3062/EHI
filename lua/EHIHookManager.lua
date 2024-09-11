local EHI = EHI

---@class EHIHookManager
EHIHookManager = {}
EHIHookManager._element_hook_function = EHI:IsClient() and "client_on_executed" or "on_executed"
---@param ehi_tracker EHITrackerManager
---@param ehi_loot EHILootManager
function EHIHookManager:new(ehi_tracker, ehi_loot)
    self._trackers = ehi_tracker
    self._loot = ehi_loot
    return self
end

---@param element MissionScriptElement
---@param post_call fun(element: MissionScriptElement, instigator: Unit?)
function EHIHookManager:HookElement(element, post_call)
    Hooks:PostHook(element, self._element_hook_function, string.format("EHI_Element_%d", element._id), post_call)
end

---@param element MissionScriptElement
---@param pre_call fun(element: MissionScriptElement, instigator: Unit?)
function EHIHookManager:PrehookElement(element, pre_call)
    Hooks:PreHook(element, self._element_hook_function, string.format("EHI_Prehook_Element_%d", element._id), pre_call)
end

---@param id number
function EHIHookManager:UnhookElement(id)
    Hooks:RemovePostHook(string.format("EHI_Element_%d", id))
end

---@param tracker_id string
---@param weapon_id string?
---@param no_civilian boolean?
---@param custom_f fun(sm: StatisticsManager, data: table)
---@overload fun(self: self, tracker_id: string, weapon_id: string)
---@overload fun(self: self, tracker_id: string, weapon_id: string, no_civilian: boolean)
function EHIHookManager:HookKillFunction(tracker_id, weapon_id, no_civilian, custom_f)
    if custom_f then
        Hooks:PostHook(StatisticsManager, "killed", string.format("EHI_%s_killed", tracker_id), custom_f)
    elseif no_civilian then
        Hooks:PostHook(StatisticsManager, "killed", string.format("EHI_%s_%s_killed", tracker_id, weapon_id), function(sm, data)
            if data.variant ~= "melee" and not CopDamage.is_civilian(data.name) then
                local name_id, _ = sm:_get_name_id_and_throwable_id(data.weapon_unit)
                if name_id == weapon_id then
                    self._trackers:IncreaseTrackerProgress(tracker_id)
                end
            end
        end)
    else
        Hooks:PostHook(StatisticsManager, "killed", string.format("EHI_%s_%s_killed", tracker_id, weapon_id), function(sm, data)
            if data.variant ~= "melee" then
                local name_id, _ = sm:_get_name_id_and_throwable_id(data.weapon_unit)
                if name_id == weapon_id then
                    self._trackers:IncreaseTrackerProgress(tracker_id)
                end
            end
        end)
    end
end

---@param id string
---@param trophy { carry_id: string|string[] }
---@param icon string
function EHIHookManager:HookSecuredBag(id, trophy, icon)
    local progress, max = EHI:GetSHSideJobProgressAndMax(id)
    local current_progress = progress
    self._loot:AddEventListener(id, function(loot)
        local new_current_progress = progress + loot:GetSecuredBagsTypeAmount(trophy.carry_id)
        if current_progress == new_current_progress then
            return
        elseif new_current_progress < max then
            managers.hud:custom_ingame_popup_text(managers.localization:to_upper_text(id), tostring(new_current_progress) .. "/" .. tostring(max), icon)
            current_progress = new_current_progress
        else
            self._loot:RemoveEventListener(id)
        end
    end)
end

---@param id string
---@param icon string?
function EHIHookManager:HookMissionEndCSMAward(id, icon)
    local progress, max = EHI:GetSHSideJobProgressAndMax(id)
    if progress + 1 < max then
        icon = icon or "milestone_trophy"
        Hooks:PostHook(CustomSafehouseManager, "award", string.format("EHI_%s_AwardProgress", id), function(csm, id_stat)
            if id_stat == id then
                managers.hud:custom_ingame_popup_text(managers.localization:to_upper_text(id), tostring(progress + 1) .. "/" .. tostring(max), icon)
            end
        end)
    end
end

---@param id string
---@param f fun(am: AchievmentManager, stat: string, value: number?)
function EHIHookManager:HookAchievementAwardProgress(id, f)
    Hooks:PostHook(AchievmentManager, "award_progress", string.format("EHI_%s_AwardProgress", id), f)
end