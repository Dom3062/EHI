local EHI = EHI
if EHI:CheckLoadHook("PlayerStandard") then
    return
end

local original = {}
local WeaponLib = EHI:IsModInstalled("WeaponLib", "Cpone")
if WeaponLib then -- Workaround for Buff Reload and Progress Reload not working / working incorrectly
    if EHI:GetOption("show_progress_reload") or EHI:GetBuffAndOption("reload") then
        local progress_reload, buff_reload = EHI:GetOption("show_progress_reload"), EHI:GetBuffAndOption("reload")
        Hooks:PreHook(PlayerStandard, "_update_reload_timers", "EHI_WeaponLib_pre_update_reload_timers", function(self, t, dt, ...) ---@param dt number
            if self._state_data.reload_expire_t and self._state_data.ehi_reload_handled then
                local exit_t = self._state_data.ehi_reload_exit_t or 0
                local new_t = (self._state_data.ehi_reload_t or 0) + dt
                if new_t >= exit_t or self._queue_reload_interupt then
                    if buff_reload and self._queue_reload_interupt then
                        managers.ehi_buff:RemoveAndResetBuff("Reload")
                    end
                    if progress_reload then
                        managers.hud:hide_interaction_bar(not self._queue_reload_interupt)
                    end
                    self._state_data.ehi_reload_t = nil
                    self._state_data.ehi_reload_exit_t = nil
                    self._state_data.ehi_reload_handled = nil
                    self._state_data.ehi_flicker_guard = self._queue_reload_interupt
                else
                    self._state_data.ehi_reload_t = new_t
                    if progress_reload then
                        managers.hud:set_interaction_bar_width(exit_t * (new_t / exit_t), exit_t)
                    end
                end
            end
        end)
        Hooks:PostHook(PlayerStandard, "_update_reload_timers", "EHI_WeaponLib_post_update_reload_timers", function(self, t, ...) ---@param t number
            if self._state_data.reload_expire_t and not self._state_data.ehi_reload_handled then
                if self._state_data.ehi_flicker_guard then
                    return
                end
                self._state_data.ehi_reload_handled = true
                local reload_t = self._state_data.reload_expire_t - t
                self._state_data.ehi_reload_t = 0
                self._state_data.ehi_reload_exit_t = reload_t
                if buff_reload then
                    managers.ehi_buff:AddBuff("Reload", reload_t)
                end
                if progress_reload then
                    managers.hud:show_interaction_bar(0, reload_t)
                end
            elseif self._state_data.ehi_flicker_guard then
                self._state_data.ehi_flicker_guard = nil
                self._state_data.ehi_reload_handled = nil
            end
        end)
        Hooks:PostHook(PlayerStandard, "destroy", "EHI_WeaponLib_destroy", function(self, ...)
            if self._state_data and self._state_data.reload_expire_t then
                self._state_data.ehi_reload_t = nil
                self._state_data.ehi_reload_handled = nil
                self._state_data.ehi_flicker_guard = nil
                if buff_reload then
                    managers.ehi_buff:RemoveAndResetBuff("Reload")
                end
                if progress_reload then
                    managers.hud:hide_interaction_bar()
                end
            end
        end)
    end
end
if EHI:GetOption("show_progress_reload") and not WeaponLib then
    Hooks:PostHook(PlayerStandard, "_start_action_reload", "EHI_ReloadInteract_start_action_reload", function(self, t, ...) ---@param t number
        if self._state_data.reload_expire_t then
            local reload_t = self._state_data.reload_expire_t - t
            self._state_data.ehi_reload_t = 0
            self._state_data.ehi_reload_exit_t = reload_t
            managers.hud:show_interaction_bar(0, reload_t)
        end
    end)
    Hooks:PreHook(PlayerStandard, "_update_reload_timers", "EHI_ReloadInteract_update_reload_timers", function(self, t, dt, ...) ---@param dt number
        if self._state_data.reload_expire_t then
            local exit_t = self._state_data.ehi_reload_exit_t or 0
            local new_t = (self._state_data.ehi_reload_t or 0) + dt
            if new_t >= exit_t or self._queue_reload_interupt then
                managers.hud:hide_interaction_bar(not self._queue_reload_interupt)
                self._state_data.ehi_reload_t = nil
                self._state_data.ehi_reload_exit_t = nil
            else
                self._state_data.ehi_reload_t = new_t
                managers.hud:set_interaction_bar_width(exit_t * (new_t / exit_t), exit_t)
            end
        end
    end)
    Hooks:PreHook(PlayerStandard, "_interupt_action_reload", "EHI_ReloadInteract_interupt_action_reload", function(self, ...)
        if self._state_data.reload_expire_t then
            self._state_data.ehi_reload_t = nil
            managers.hud:hide_interaction_bar()
        end
    end)
    Hooks:PostHook(PlayerStandard, "destroy", "EHI_ReloadInteract_destroy", function(self, ...)
        if self._state_data and self._state_data.reload_expire_t then
            self._state_data.ehi_reload_t = nil
            managers.hud:hide_interaction_bar()
        end
    end)
end

if EHI:GetOption("show_progress_melee") then
    Hooks:PostHook(PlayerStandard, "_start_action_melee", "EHI_MeleeInteract_start_action_melee", function(self, t, input, instant, ...) ---@param t number
        if instant then
            return
        end
        local melee_entry = managers.blackmarket:equipped_melee_weapon()
        local tweak = tweak_data.blackmarket.melee_weapons[melee_entry]
        local max_charge_time = tweak.stats.charge_time
        local t_charge = self._state_data.melee_attack_allowed_t - t + max_charge_time
        self._state_data.ehi_melee_progress = 0
        self._state_data.ehi_melee_max_t = t_charge + t
        self._state_data.ehi_melee_max_charge_time = t_charge
        managers.hud:show_interaction_bar(0, t_charge)
    end)
    ---@diagnostic disable
    original._update_melee_timers = PlayerStandard._update_melee_timers
    function PlayerStandard:_update_melee_timers(t, ...) ---@param t number
        original._update_melee_timers(self, t, ...)
        if self._state_data.meleeing then
            local t_left = self._state_data.ehi_melee_max_t - t
            local lerp = 1 - (t_left / self._state_data.ehi_melee_max_charge_time)
            self._state_data.ehi_melee_progress = lerp
            local max_time = self._state_data.ehi_melee_max_charge_time
            managers.hud:set_interaction_bar_width(max_time * lerp, max_time)
        end
    end
    ---@diagnostic enable
    Hooks:PreHook(PlayerStandard, "_interupt_action_melee", "EHI_MeleeInteract_interupt_action_melee", function(self, ...)
        if self._state_data.meleeing or self._state_data.melee_expire_t then
            managers.hud:hide_interaction_bar()
            self._state_data.ehi_melee_progress = nil
            self._state_data.ehi_melee_max_t = nil
            self._state_data.ehi_melee_max_charge_time = nil
        end
    end)
    Hooks:PostHook(PlayerStandard, "_do_melee_damage", "EHI_MeleeInteract_do_melee_damage", function(self, ...)
        managers.hud:hide_interaction_bar(self._state_data.ehi_melee_progress and self._state_data.ehi_melee_progress >= 1) -- VR fix
        self._state_data.ehi_melee_progress = nil
        self._state_data.ehi_melee_max_t = nil
        self._state_data.ehi_melee_max_charge_time = nil
    end)
end

if not EHI:GetOption("show_buffs") then
    return
end

--///////////////////--
--//  Sixth Sense  //--
--///////////////////--
if EHI:GetBuffOption("sixth_sense_initial") or EHI:GetBuffOption("sixth_sense_refresh") or EHI:GetBuffOption("sixth_sense_marked") then
    original._update_omniscience = PlayerStandard._update_omniscience
    EHI:AddOnAlarmCallback(function(dropin)
        if managers.ehi_buff then -- ResMod fix as the alarm callback is called before EHIBuffManager has a chance to initialize
            managers.ehi_buff:DeleteBuff("standstill_omniscience_initial")
            managers.ehi_buff:DeleteBuff("standstill_omniscience")
            managers.ehi_buff:DeleteBuff("standstill_omniscience_highlighted")
        end
        PlayerStandard._update_omniscience = original._update_omniscience
    end)
    -- Assume default, recomputed after spawn
    local computed_duration_civilian = 4.5
    local computed_duration_security = 13.5
    local target_resense_delay = tweak_data.player.omniscience.target_resense_t or 15
    local sense_latch, latch_t = false, 0
    EHI:AddOnSpawnedCallback(function()
        local playermanager = managers.player
        local ContourExt = ContourExt
        local tmp = ContourExt._types
        if tmp then
            local multiplier = playermanager:upgrade_value("player", "mark_enemy_time_multiplier", 1)
            local contour_type = playermanager:has_category_upgrade("player", "marked_enemy_extra_damage") and "mark_enemy_damage_bonus" or "mark_enemy"
            tmp = tmp[contour_type]
            if tmp then
                computed_duration_civilian = tmp.fadeout and (tmp.fadeout * multiplier) or 4.5
                computed_duration_security = tmp.fadeout_silent and (tmp.fadeout_silent * multiplier) or 13.5
            end
        end
    end)
    function PlayerStandard:_update_omniscience(t, ...)
        local previoustime = self._state_data.omniscience_t

        original._update_omniscience(self, t, ...)

        if previoustime and self._state_data.omniscience_t == nil then
            -- The game forbade the skill, kill the buffs (this does not run every frame due to the combined check in the above
            -- conditional clause)
            managers.ehi_buff:RemoveAndResetBuff("standstill_omniscience_initial")
            managers.ehi_buff:RemoveAndResetBuff("standstill_omniscience")
            managers.ehi_buff:RemoveAndResetBuff("standstill_omniscience_highlighted")
            sense_latch = false
            return
        end

        -- Player does not have the skill or alarm has been raised; do not set update function back to vanilla function as this will break the buff if the condition is true
        if previoustime == nil and self._state_data.omniscience_t == nil then
            return
        end

        if previoustime == nil and self._state_data.omniscience_t then -- Delay prior to initial poll
            managers.ehi_buff:AddBuff("standstill_omniscience_initial", tweak_data.player.omniscience.start_t)
        elseif previoustime ~= self._state_data.omniscience_t then
            -- Subsequent poll (called once every second)
            local detected = 0
            local tmp = self._state_data.omniscience_units_detected
            if tmp then
                local civilians = managers.enemy:all_civilians()
                local begin_t, end_t = 0, 0
                for key, data in pairs(tmp) do
                    -- Since only expiry times are stored, work backwards to figure out when the start time was, and calculate the
                    -- time the highlight will expire
                    begin_t = data - target_resense_delay
                    end_t = begin_t + (civilians[key] and computed_duration_civilian or computed_duration_security)
                    if t >= begin_t and t < end_t then
                        detected = detected + 1
                    end
                end
            end

            if detected > 0 then
                if sense_latch then
                    if t >= latch_t then
                        managers.ehi_buff:AddBuff("standstill_omniscience", target_resense_delay)
                        latch_t = t + target_resense_delay
                    end
                else
                    managers.ehi_buff:AddBuff("standstill_omniscience", target_resense_delay)
                    sense_latch = true
                    latch_t = t + target_resense_delay
                end
            end

            managers.ehi_buff:AddGauge("standstill_omniscience_highlighted", detected)
        end
    end
end

if EHI:GetBuffOption("reload") and not WeaponLib then
    Hooks:PostHook(PlayerStandard, "_start_action_reload", "EHI_ReloadBuff_start_action_reload", function(self, t, ...) ---@param t number
        if self._state_data.reload_expire_t then
            managers.ehi_buff:AddBuff("Reload", self._state_data.reload_expire_t - t)
        end
    end)
    Hooks:PreHook(PlayerStandard, "_update_reload_timers", "EHI_ReloadBuff_update_reload_timers", function(self, ...)
        if self._state_data.reload_expire_t and self._queue_reload_interupt then
            managers.ehi_buff:RemoveAndResetBuff("Reload")
        end
    end)
    Hooks:PreHook(PlayerStandard, "_interupt_action_reload", "EHI_ReloadBuff_interupt_action_reload", function(self, ...)
        if self._state_data.reload_expire_t then
            managers.ehi_buff:RemoveAndResetBuff("Reload")
        end
    end)
end

if EHI:GetBuffOption("interact") then
    original._start_action_interact = PlayerStandard._start_action_interact
    function PlayerStandard:_start_action_interact(...)
        original._start_action_interact(self, ...)
        if self._interact_expire_t > 0 then
            managers.ehi_buff:AddBuff("Interact", self._interact_expire_t)
        end
    end
    original._interupt_action_interact = PlayerStandard._interupt_action_interact
    function PlayerStandard:_interupt_action_interact(t, input, complete, ...)
        if not complete then
            managers.ehi_buff:RemoveAndResetBuff("Interact")
        end
        original._interupt_action_interact(self, t, input, complete, ...)
    end
    original._start_action_use_item = PlayerStandard._start_action_use_item
    function PlayerStandard:_start_action_use_item(t, ...)
        original._start_action_use_item(self, t, ...)
        managers.ehi_buff:AddBuff("Interact", self._use_item_expire_t - t)
    end
    original._interupt_action_use_item = PlayerStandard._interupt_action_use_item
    function PlayerStandard:_interupt_action_use_item(...)
        if self._use_item_expire_t then
            managers.ehi_buff:RemoveAndResetBuff("Interact")
        end
        original._interupt_action_use_item(self, ...)
    end
end

if EHI:GetBuffOption("melee_charge") then
    Hooks:PostHook(PlayerStandard, "_start_action_melee", "EHI_MeleeBuff_start_action_melee", function(self, t, input, instant, ...) ---@param t number
        if instant then
            return
        end
        local melee_entry = managers.blackmarket:equipped_melee_weapon()
        local tweak = tweak_data.blackmarket.melee_weapons[melee_entry]
        local max_charge_time = tweak.stats.charge_time
        local t_charge = self._state_data.melee_attack_allowed_t - t + max_charge_time
        managers.ehi_buff:AddBuff("MeleeCharge", t_charge)
    end)
    Hooks:PostHook(PlayerStandard, "_do_melee_damage", "EHI_MeleeBuff_do_melee_damage", function(...)
        managers.ehi_buff:RemoveAndResetBuff("MeleeCharge")
    end)
    Hooks:PreHook(PlayerStandard, "_interupt_action_melee", "EHI_MeleeBuff_interupt_action_melee", function(self, ...)
        if self._state_data.meleeing or self._state_data.melee_expire_t then
            managers.ehi_buff:RemoveAndResetBuff("MeleeCharge")
        end
    end)
end

if EHI:GetBuffOption("weapon_swap") then
    original._start_action_unequip_weapon = PlayerStandard._start_action_unequip_weapon
    function PlayerStandard:_start_action_unequip_weapon(t, data, ...)
        local previous_selected_weapon = self._equipped_unit
        original._start_action_unequip_weapon(self, t, data, ...)
        if self._unequip_weapon_expire_t then
            local next_weapon_equip_t = 0
            local next_previous_weapon_selection = data.selection_wanted
            if data.next then
                local _, selection = self._ext_inventory:get_next_selection()
                next_previous_weapon_selection = selection
            elseif data.previous then
                local _, selection = self._ext_inventory:get_previous_selection()
                next_previous_weapon_selection = selection
            end
            if next_previous_weapon_selection then
                local select_equip = self._ext_inventory:get_selected(next_previous_weapon_selection)
                local weapon_unit = select_equip and select_equip.unit
                if weapon_unit then
                    self._equipped_unit = weapon_unit -- Swap the equipped weapon unit so the function below correctly calculates speed multiplier
                    local speed_multiplier = self:_get_swap_speed_multiplier()
                    local tweak_data = weapon_unit:base():weapon_tweak_data()
                    self._equipped_unit = previous_selected_weapon -- Return back previous weapon so nothing breaks
                    next_weapon_equip_t = (tweak_data.timers.equip or 0.7) / speed_multiplier
                end
            end
            managers.ehi_buff:AddBuff("WeaponSwap", self._unequip_weapon_expire_t - t + next_weapon_equip_t)
        end
    end
end