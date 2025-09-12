local EHI = EHI

---@class EHIHookManager
local EHIHookManager = {}
EHIHookManager._cop_damage_hook = "EHI_EHIHookManager_CopDamage__on_damage_received"
EHIHookManager._element_hook_function = EHI.IsClient and "client_on_executed" or "on_executed"
---@param ehi_tracker EHITrackerManager
---@param ehi_loot EHILootManager
function EHIHookManager:post_init(ehi_tracker, ehi_loot)
    self._trackers = ehi_tracker
    self._loot = ehi_loot
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
                    self._trackers:IncreaseProgress(tracker_id)
                end
            end
        end)
    else
        Hooks:PostHook(StatisticsManager, "killed", string.format("EHI_%s_%s_killed", tracker_id, weapon_id), function(sm, data)
            if data.variant ~= "melee" then
                local name_id, _ = sm:_get_name_id_and_throwable_id(data.weapon_unit)
                if name_id == weapon_id then
                    self._trackers:IncreaseProgress(tracker_id)
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
    self._loot:AddListener(id, function(loot)
        local new_current_progress = progress + loot:GetSecuredBagsTypeAmount(trophy.carry_id)
        if current_progress == new_current_progress then
            return
        elseif new_current_progress < max then
            managers.hud:custom_ingame_popup_text(managers.localization:to_upper_text(id), tostring(new_current_progress) .. "/" .. tostring(max), icon)
            current_progress = new_current_progress
        else
            self._loot:RemoveListener(id)
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

---@param id string
---@param f fun(am: AchievmentManager, stat: string, value: number?)
function EHIHookManager:HookChallengeAwardProgress(id, f)
    Hooks:PostHook(ChallengeManager, "award_progress", string.format("EHI_%s_AwardProgress", id), f)
end

---@param id string
---@param f fun(self: CopDamage, damage_info: CopDamage.AttackData, attacker_unit: UnitPlayer|UnitTeamAI)
function EHIHookManager:AddCopDamageListener(id, f)
    if not self._cop_damage_listener then
        self._cop_damage_listener = ListenerHolder:new()
        Hooks:PostHook(CopDamage, "_on_damage_received", self._cop_damage_hook, function(c_dmg, damage_info, ...) ---@param damage_info CopDamage.AttackData
            local realAttacker = damage_info.attacker_unit
            if alive(realAttacker) then
                local base = realAttacker:base()
                if base then
                    if base.thrower_unit then
                        realAttacker = base.thrower_unit
                    elseif base.sentry_gun then
                        realAttacker = base:get_owner()
                    end
                end
            end
            local damage = damage_info.damage
            if type(damage) ~= 'number'  -- Dragon's breath crash
                or damage_info.variant == 'stun'	-- Stun a convert crash with concussion grenade
                or damage == 0			-- Stun a shield crash with concussion grenade
                or type(realAttacker) == "function"
            then
                return
            end
            self._cop_damage_listener:call(c_dmg, damage_info, realAttacker)
        end)
    end
    self._cop_damage_listener:add(id, f)
end

---@param id string
---@param keep_if_empty boolean?
function EHIHookManager:RemoveCopDamageListener(id, keep_if_empty)
    if not self._cop_damage_listener then
        return
    end
    self._cop_damage_listener:remove(id)
    if self._cop_damage_listener:is_empty() and not keep_if_empty then
        self._cop_damage_listener = nil
        Hooks:RemovePostHook(self._cop_damage_hook)
    end
end

---@param id string
function EHIHookManager:HasCopDamageListener(id)
    if not (self._cop_damage_listener and self._cop_damage_listener._listeners) then
        return false
    end
    return self._cop_damage_listener._listeners[id] ~= nil
end

---Adds listener to human players whenever they shoot their weapon, useful for tracking accuracy
---@param f fun(peer_id: integer, bullets_subtracted: integer)
function EHIHookManager:AddShotWithAWeaponListener(f)
    if not self._shot_with_weapon_listener then
        self._shot_with_weapon_listener = CallbackEventHandler:new()
        local my_peer_id = managers.network:session():local_peer():id()
        Hooks:PreHook(HUDTeammate, "set_ammo_amount_by_type", "EHI_EHIHookManager_HUDTeammate_set_ammo_amount_by_type", function(hud, type, max_clip, current_clip, current_left, ...)
            local clip = "__last_clip_" .. type
            local cc = hud[clip] or 0
            if current_clip < cc then
                self._shot_with_weapon_listener:dispatch(hud._peer_id or my_peer_id or 0, cc - current_clip)
            end
            hud[clip] = current_clip
        end)
        Hooks:PostHook(HUDTeammate, "remove_panel", "EHI_EHIHookManager_HUDTeammate_remove_panel", function(hud, ...)
            hud["__last_clip_primary"] = 0
            hud["__last_clip_secondary"] = 0
        end)
    end
    self._shot_with_weapon_listener:add(f)
end

return EHIHookManager