---@class EHIArmorRegenDelayBuffTracker : EHIBuffTracker
---@field super EHIBuffTracker
EHIArmorRegenDelayBuffTracker = class(EHIBuffTracker)
EHIArmorRegenDelayBuffTracker._DELETE_BUFF_AND_CLASS_ON_FALSE_SKILL_CHECK = true
function EHIArmorRegenDelayBuffTracker:SkillCheck()
    return not managers.player:has_category_upgrade("player", "armor_to_health_conversion")
end

---@class EHIBloodthirstBuffTracker : EHIGaugeBuffTracker
---@field super EHIGaugeBuffTracker
EHIBloodthirstBuffTracker = class(EHIGaugeBuffTracker)
EHIBloodthirstBuffTracker._DELETE_BUFF_AND_CLASS_ON_FALSE_SKILL_CHECK = true
function EHIBloodthirstBuffTracker:SkillCheck()
    return managers.player:has_category_upgrade("player", "melee_damage_stacking")
end

function EHIBloodthirstBuffTracker:PreUpdate()
    local upgrade = managers.player:upgrade_value("player", "melee_damage_stacking")
    if upgrade and type(upgrade) ~= "number" then
        self:SetRatio(1 / upgrade.max_multiplier, 1)
    end
    self._parent_class:AddBuffNoUpdate(self._id)
end

---@class EHIHealthRegenBuffTracker : EHIBuffTracker
---@field super EHIBuffTracker
EHIHealthRegenBuffTracker = class(EHIBuffTracker)
function EHIHealthRegenBuffTracker:post_init(...)
    local x, y, w, h = self._icon:shape() -- Hostage Taker regen
    self._icon2 = self._panel:bitmap({ -- Muscle regen
        texture = "guis/textures/pd2/specialization/icons_atlas",
        texture_rect = { 4 * 64, 64, 64, 64 },
        color = Color.white,
        x = x,
        y = y,
        w = w,
        h = h
    })
    self._icon3 = self._panel:bitmap({
        texture = tweak_data.hud_icons.skill_5.texture,
        texture_rect = tweak_data.hud_icons.skill_5.texture_rect,
        color = Color.white,
        x = x,
        y = y,
        w = w,
        h = h
    })
    self:SetIcon("hostage_taker")
    self._minion_count, self._ai_health_regen, self._max_health, self._healing_reduction = 0, 0, 0, 1
    self._player_manager = managers.player
    self._perform_update_from_spawn = false
    EHI:AddCallback(EHI.CallbackMessage.OnMinionAdded, function(unit, local_peer, peer_id)
        if local_peer then
            self._minion_count = self._minion_count + 1
            if self._minion_count == 1 and self._character_damage and self._perform_update_from_spawn then
                self:AddBuffToUpdate2()
            end
        end
    end)
    EHI:AddCallback(EHI.CallbackMessage.OnMinionKilled, function(key, local_peer, peer_id)
        if local_peer then
            self._minion_count = math.max(self._minion_count - 1, 0)
            if self._minion_count == 0 and self._character_damage then
                self:AddBuffToUpdate2()
            end
        end
    end)
    EHI:AddCallback(EHI.CallbackMessage.TeamAISkillChange, function(boost, operation)
        if boost == "crew_regen" then
            self._ai_health_regen = operation == "add" and self._player_manager:upgrade_value("team", "crew_health_regen", 0) or 0
            if self._character_damage and self._perform_update_from_spawn then
                self:SetHintText(string.format("+%g", self:GetHealthRegen()))
            end
        elseif boost == "crew_healthy" and self._character_damage and self._perform_update_from_spawn then
            self:AddBuffToUpdate2()
        end
    end)
    managers.ehi_hook:AddPlayerSpawnedListener(self._id, function(character_damage)
        self._character_damage = character_damage
        if self._perform_update_from_spawn then
            self:AddBuffToUpdate2()
        end
    end)
    managers.ehi_hook:AddPlayerDespawnedListener(self._id, function()
        self:RemoveBuffFromUpdate2()
        self._character_damage = nil
        self._max_health = 0
    end)
end

function EHIHealthRegenBuffTracker:Extend(...)
    EHIHealthRegenBuffTracker.super.Extend(self, ...)
    if self._persistent and not self._update then
        self:AddBuffToUpdate()
        self._update = true
    end
end

function EHIHealthRegenBuffTracker:Deactivate()
    if self._persistent then
        self:RemoveBuffFromUpdate()
        self._update = false
        return
    end
    EHIHealthRegenBuffTracker.super.Deactivate(self)
end

function EHIHealthRegenBuffTracker:update_health_regen(...)
    local new_max_health = self._character_damage:_max_health()
    if self._max_health ~= new_max_health then
        self._max_health = new_max_health
        self:SetHintText(string.format("+%g", self:GetHealthRegen(new_max_health)))
        self:RemoveBuffFromUpdate2()
    end
end

---@param max_health number?
function EHIHealthRegenBuffTracker:GetHealthRegen(max_health)
    local regen
    if self._minion_count <= 0 then
        local ai_state = managers.groupai:state()
        local original_hostage_count = ai_state:hostage_count()
        ai_state._hostage_headcount = ai_state._hostage_headcount + 1 -- Temporarily increase hostage count to get health regen
        regen = self._player_manager:health_regen()
        ai_state._hostage_headcount = original_hostage_count -- Set original hostage count to restore the original value
    else
        regen = self._player_manager:health_regen()
    end
    max_health = max_health or self._character_damage:_max_health() -- Max health does not get updated immediately for some reason, update it next frame or after (see -> :update_health_regen())
    local hp_to_restore_from_regen = max_health * regen * self._healing_reduction -- Health regen is not static, it needs to be scaled down by your max hp
    local hp_to_restore_from_ai = self._ai_health_regen * self._healing_reduction -- AI Regen is static, no scaling from max hp
    return math.ehi_round_health(hp_to_restore_from_regen + hp_to_restore_from_ai)
end

---@param buff string
function EHIHealthRegenBuffTracker:SetIcon(buff)
    if self._buff == buff then
        return
    elseif buff == "hostage_taker" then
        self._icon:set_visible(true)
        self._icon2:set_visible(false)
        self._icon3:set_visible(false)
    elseif buff == "muscle" then
        self._icon2:set_visible(true)
        self._icon:set_visible(false)
        self._icon3:set_visible(false)
    else -- AIRegen
        self._icon3:set_visible(true)
        self._icon2:set_visible(false)
        self._icon:set_visible(false)
    end
    self._buff = buff
end

function EHIHealthRegenBuffTracker:PreUpdate()
    self._healing_reduction = self._player_manager:upgrade_value("player", "healing_reduction", 1)
    if self._character_damage then
        self:AddBuffToUpdate2()
    end
    self._perform_update_from_spawn = true
    if self._persistent then
        self:ActivateSoft()
        self._active = true
    end
end

function EHIHealthRegenBuffTracker:AddBuffToUpdate2()
    managers.hud:add_updator(self._id, callback(self, self, "update_health_regen"))
end

function EHIHealthRegenBuffTracker:RemoveBuffFromUpdate2()
    managers.hud:remove_updator(self._id)
end

function EHIHealthRegenBuffTracker:SetPersistent()
    self._persistent = true
    self._text:set_text("0")
end

function EHIHealthRegenBuffTracker:delete()
    managers.ehi_hook:RemovePlayerSpawnedListener(self._id)
    managers.ehi_hook:RemovePlayerDespawnedListener(self._id)
    self:RemoveBuffFromUpdate2()
    self._character_damage = nil
    EHIHealthRegenBuffTracker.super.delete(self)
end

---@class EHIStaminaBuffTracker : EHIGaugeBuffTracker
---@field super EHIGaugeBuffTracker
EHIStaminaBuffTracker = class(EHIGaugeBuffTracker)
---@param max_stamina number
function EHIStaminaBuffTracker:Spawned(max_stamina)
    self:SetMaxStamina(max_stamina)
    self:SetRatio(self._max_stamina)
    self:Activate()
end

---@param value number
function EHIStaminaBuffTracker:SetMaxStamina(value)
    self._max_stamina = value
end

function EHIStaminaBuffTracker:SetRatio(ratio)
    local value = ratio / self._max_stamina
    local rounded = math.ehi_round(value, 0.01)
    EHIStaminaBuffTracker.super.SetRatio(self, value, rounded)
end

function EHIStaminaBuffTracker:Activate()
    if self._active then
        return
    end
    self._active = true
    self._panel:stop()
    self._panel:animate(self._show)
    self:AddVisibleBuff()
end

---@class EHIForceUpdateParentBuffTracker : EHIBuffTracker
---@field super EHIBuffTracker
EHIForceUpdateParentBuffTracker = class(EHIBuffTracker)
function EHIForceUpdateParentBuffTracker:post_init(params)
    self._parent_buff = params.parent_buff
end

function EHIForceUpdateParentBuffTracker:Activate(...)
    EHIForceUpdateParentBuffTracker.super.Activate(self, ...)
    self._parent_class:CallFunction(self._parent_buff, "ForceUpdate")
end

function EHIForceUpdateParentBuffTracker:Deactivate()
    EHIForceUpdateParentBuffTracker.super.Deactivate(self)
    self._parent_class:CallFunction(self._parent_buff, "ForceUpdate")
end

---@class EHIExPresidentBuffTracker : EHIGaugeBuffTracker
---@field super EHIGaugeBuffTracker
EHIExPresidentBuffTracker = class(EHIGaugeBuffTracker)
EHIExPresidentBuffTracker._DELETE_BUFF_AND_CLASS_ON_FALSE_SKILL_CHECK = true
function EHIExPresidentBuffTracker:SkillCheck()
    return managers.player:has_category_upgrade("player", "armor_health_store_amount")
end

function EHIExPresidentBuffTracker:PreUpdate()
    local buff, original = self, {}
    original.update_armor_stored_health = PlayerDamage.update_armor_stored_health
    function PlayerDamage:update_armor_stored_health(...)
        original.update_armor_stored_health(self, ...)
        buff:SetStoredHealthMaxAndUpdateRatio(self:max_armor_stored_health(), self._armor_stored_health)
    end
    original.add_armor_stored_health = PlayerDamage.add_armor_stored_health
    function PlayerDamage:add_armor_stored_health(...)
        local previous = self._armor_stored_health
        original.add_armor_stored_health(self, ...)
        if previous ~= self._armor_stored_health and not self._check_berserker_done then
            buff:SetRatio(nil, self._armor_stored_health)
        end
    end
    original.clear_armor_stored_health = PlayerDamage.clear_armor_stored_health
    function PlayerDamage:clear_armor_stored_health(...)
        original.clear_armor_stored_health(self, ...)
        buff:SetRatio(nil, self._armor_stored_health)
    end
    local player_unit = managers.player:player_unit()
    local character_damage = player_unit and player_unit:character_damage() ---@cast character_damage -HuskPlayerDamage
    self:SetStoredHealthMaxAndUpdateRatio(character_damage and character_damage:max_armor_stored_health() or 0, 0)
    self._parent_class:AddBuffNoUpdate(self._id)
end

---@param max number
---@param ratio number
function EHIExPresidentBuffTracker:SetStoredHealthMaxAndUpdateRatio(max, ratio)
    self._stored_health_max = max
    self:SetRatio(nil, ratio)
end

---@param ratio nil
---@param custom_value number
function EHIExPresidentBuffTracker:SetRatio(ratio, custom_value)
    ratio = custom_value / self._stored_health_max
    EHIExPresidentBuffTracker.super.SetRatio(self, ratio, custom_value)
end

---@class EHIManiacBuffTracker : EHIGaugeBuffTracker
---@field super EHIGaugeBuffTracker
EHIManiacBuffTracker = class(EHIGaugeBuffTracker)
EHIManiacBuffTracker._stack_convert_levels = tweak_data.upgrades.cocaine_stacks_convert_levels or {}
EHIManiacBuffTracker._stack_dmg_absorption_value = tweak_data.upgrades.cocaine_stacks_dmg_absorption_value or 0.1
EHIManiacBuffTracker._max_stacks = tweak_data.upgrades.max_total_cocaine_stacks or 2047
EHIManiacBuffTracker._DELETE_BUFF_AND_CLASS_ON_FALSE_SKILL_CHECK = true
function EHIManiacBuffTracker:SkillCheck()
    return managers.player:has_category_upgrade("player", "cocaine_stacking")
end

function EHIManiacBuffTracker:PreUpdate()
    self._cocaine_stack_convert_level = managers.player:upgrade_value("player", "sync_cocaine_upgrade_level", 1)
    local power_level = managers.player:upgrade_level("player", "cocaine_stack_absorption_multiplier", 0)
    self._cocaine_stack_multiplier = managers.player:upgrade_value_by_level("player", "cocaine_stack_absorption_multiplier", power_level or 0, 1)
    self._parent_class:AddBuffNoUpdate(self._id)
end

---@param amount number
function EHIManiacBuffTracker:UpdateStack(amount)
    if (self._previous_amount or 0) ~= amount then
        self._previous_amount = amount
        local ratio = amount / self._max_stacks
        self:SetRatio(ratio, math.floor(amount))
        local absorption = amount / (self._stack_convert_levels[self._cocaine_stack_convert_level or 1] or 20) * self._stack_dmg_absorption_value
        self:SetHintText(tostring(math.floor(absorption * (self._cocaine_stack_multiplier or 1) * 10)))
    end
end

---@class EHIAbilityBuffTracker : EHIBuffTracker
---@field super EHIBuffTracker
---@field _ABILITY_COOLDOWN boolean
EHIAbilityBuffTracker = class(EHIBuffTracker)
EHIAbilityBuffTracker._DELETE_BUFF_ON_FALSE_SKILL_CHECK = true
EHIAbilityBuffTracker._ABILITY_AS_A_GRENADE =
{
    smoke_screen_grenade = true
}
EHIAbilityBuffTracker._AUTOFAIL_SKILL_CHECK_ON_NOT_ABILITY_COOLDOWN =
{
    pocket_ecm_jammer = true
}
function EHIAbilityBuffTracker:post_init(params)
    self._ehi_options = params.options
    self._ehi_options_permanent = params.options_permanent
end

function EHIAbilityBuffTracker:Activate(t, ...)
    EHIAbilityBuffTracker.super.Activate(self, self._duration_override or t, ...)
end

function EHIAbilityBuffTracker:Extend(t)
    EHIAbilityBuffTracker.super.Extend(self, self._duration_override or t)
    if self._persistent and not self._update then
        self:AddBuffToUpdate()
        self._update = true
    end
end

---@param t number
---@param max number
function EHIAbilityBuffTracker:AddTimeCeil(t, max)
    self._time = math.min(self._time + t, max)
end

function EHIAbilityBuffTracker:Deactivate()
    if self._persistent then
        self:RemoveBuffFromUpdate()
        self._update = false
        self._text:set_text("0")
        return
    end
    EHIAbilityBuffTracker.super.Deactivate(self)
end

---@param ability string
function EHIAbilityBuffTracker:SetAbilityIcon(ability)
    local projectile = tweak_data.blackmarket.projectiles[ability] or {}
    local icon_params =
    {
        deck = true,
        folder = projectile.texture_bundle_folder
    }
    if ability == "damage_control" then
        if self._ABILITY_COOLDOWN then
            icon_params.y = 1
        elseif managers.player:has_category_upgrade("player", "damage_control_auto_shrug") then
            icon_params.x = 2 -- 128px
            self._duration_override = managers.player:upgrade_value("player", "damage_control_auto_shrug") --[[@as number]]
        end
    elseif ability == "tag_team" and not self._ABILITY_COOLDOWN then
        icon_params.y = 1
    end
    self:UpdateIcon(tweak_data.ehi.default.buff.get_icon(icon_params))
end

function EHIAbilityBuffTracker:SkillCheck()
    local ability = managers.blackmarket:equipped_grenade()
    if not (managers.blackmarket:has_equipped_ability() or self._ABILITY_AS_A_GRENADE[ability]) then
        return false
    elseif (self._AUTOFAIL_SKILL_CHECK_ON_NOT_ABILITY_COOLDOWN[ability] and not self._ABILITY_COOLDOWN) or (self._ehi_options and not self._ehi_options[ability]) then
        return false
    elseif self._ehi_options_permanent and self._ehi_options_permanent[ability] then
        self:SetAbilityIcon(ability)
        self:SetPersistent()
        return true
    end
    self:SetAbilityIcon(ability)
    return true
end

function EHIAbilityBuffTracker:SetCustodyState(state)
    if state and self._active then
        self:DeactivateAndReset()
    end
end

function EHIAbilityBuffTracker:SetPersistent()
    self._text:set_text("0")
    self._persistent = true
    self._active = true
    self:ActivateSoft()
end

function EHIAbilityBuffTracker:delete()
    self._parent_class:_remove_buff_redirect(self._id)
    EHIAbilityBuffTracker.super.delete(self)
end

---@class EHIAbilityRefreshBuffTracker : EHIAbilityBuffTracker
---@field super EHIAbilityBuffTracker
EHIAbilityRefreshBuffTracker = class(EHIAbilityBuffTracker)
EHIAbilityRefreshBuffTracker._ABILITY_COOLDOWN = true
EHIAbilityRefreshBuffTracker.delete = EHIAbilityRefreshBuffTracker.super.super.delete
function EHIAbilityRefreshBuffTracker:post_init(params)
    self._ehi_options = params.options
    self._ehi_options_permanent = params.options_permanent
    self._replenish_count_running = 0
    self._hint:hide()
end

---@param add_to_replenish boolean?
function EHIAbilityRefreshBuffTracker:ReplenishCountChanged(add_to_replenish)
    self._replenish_count_running = add_to_replenish and (self._replenish_count_running + 1) or math.max(0, self._replenish_count_running - 1)
    self:SetHintText(self._replenish_count_running)
    self._hint:set_visible(self._replenish_count_running >= 2)
end

function EHIAbilityRefreshBuffTracker:SetAbilityIcon(ability)
    EHIAbilityRefreshBuffTracker.super.SetAbilityIcon(self, ability)
    Hooks:PreHook(PlayerManager, "speed_up_grenade_cooldown", "EHI_AbilityRefreshBuff_speed_up_grenade_cooldown", function(pm, time, ...) ---@param time number
        if pm._timers.replenish_grenades then
            self._time = self._time - time
        end
    end)
    local projectile = tweak_data.blackmarket.projectiles[ability] or {}
    if (projectile.max_amount or 0) > 1 then
        Hooks:PreHook(PlayerManager, "add_grenade_amount", "EHI_Replenish_Throwable", function(pm, amount, ...) ---@param amount number
            if amount ~= 0 then
                self:ReplenishCountChanged(amount < 0)
            end
        end)
    end
end

---@class EHIHealthBuffTracker : EHIGaugeBuffTracker
---@field super EHIGaugeBuffTracker
EHIHealthBuffTracker = class(EHIGaugeBuffTracker)
EHIHealthBuffTracker._CHECK_SNIPER_DAMAGE = EHI:GetBuffOption("health_check_sniper_damage")
EHIHealthBuffTracker._CHECK_HEAVY_SWAT_DS_DAMAGE = EHI:IsDifficulty(EHI.Difficulties.DeathSentence) and EHI:GetBuffOption("health_check_heavy_swat_ds_damage")
EHIHealthBuffTracker._CHECK_ENEMY_DAMAGE = EHIHealthBuffTracker._CHECK_SNIPER_DAMAGE or EHIHealthBuffTracker._CHECK_HEAVY_SWAT_DS_DAMAGE
function EHIHealthBuffTracker:post_init(params)
    if not self._CHECK_ENEMY_DAMAGE then
        return
    end
    self._icon_visible, self._armor_value = 1, 0
    local function refresh_max_armor(character_damage) ---@param character_damage PlayerDamage
        self._armor_value = character_damage:_max_armor()
    end
    managers.ehi_hook:AddPlayerSpawnedListener(self._id, refresh_max_armor)
    EHI:AddOnSpawnedCallback(function()
        local damage_reduction = managers.player:upgrade_value("player", "health_damage_reduction", 1) -- Frenzy
        if self._HIGHEST_HEAVY_SWAT_DAMAGE then
            self._HIGHEST_HEAVY_SWAT_DAMAGE = self._HIGHEST_HEAVY_SWAT_DAMAGE * damage_reduction
        elseif self._HIGHEST_SNIPER_DAMAGE then
            self._HIGHEST_SNIPER_DAMAGE = self._HIGHEST_SNIPER_DAMAGE * damage_reduction
        end
    end)
    EHI:AddCallback(EHI.CallbackMessage.Player.ArmorKitUsed, refresh_max_armor)
    local tweak = tweak_data.ehi
    local texture_rect = self:_get_texture_rect()
    local x, y, w, h = self._icon:shape()
    local ix, iy, iw, ih = self._progress:shape()
    local icon_texture, icon_text_rect = tweak.default.buff.get_icon(tweak.buff.Health)
    self._icon_orange = self._panel:bitmap({
        texture = icon_texture,
        texture_rect = icon_text_rect,
        x = x,
        y = y,
        w = w,
        h = h,
        color = tweak:GetIconColorFromTextureColor("orange"),
        visible = false
    })
    self._progress_bar_orange = Color(1, 0, 1, 1)
    self._progress_orange = self._panel:bitmap({
        render_template = "VertexColorTexturedRadial",
        layer = 5,
        x = ix,
        y = iy,
        w = iw,
        h = ih,
        texture = self._get_texture("orange"),
        texture_rect = texture_rect,
        color = self._progress_bar_orange,
        visible = false
    })
    self._icon_red = self._panel:bitmap({
        texture = icon_texture,
        texture_rect = icon_text_rect,
        x = x,
        y = y,
        w = w,
        h = h,
        color = tweak:GetIconColorFromTextureColor("red"),
        visible = false
    })
    self._progress_bar_red = Color(1, 0, 1, 1)
    self._progress_red = self._panel:bitmap({
        render_template = "VertexColorTexturedRadial",
        layer = 5,
        x = ix,
        y = iy,
        w = iw,
        h = ih,
        texture = self._get_texture("red"),
        texture_rect = texture_rect,
        color = self._progress_bar_red,
        visible = false
    })
end

if EHIHealthBuffTracker._CHECK_HEAVY_SWAT_DS_DAMAGE then
    EHIHealthBuffTracker._HIGHEST_HEAVY_SWAT_DAMAGE = tweak_data:GetHighestDamageFromEnemyAndWeapon("zeal_heavy_swat", "m4_npc")
    ---@param ratio number
    ---@param custom_value number?
    function EHIHealthBuffTracker:SetRatio(ratio, custom_value)
        if self._ratio == ratio then
            return
        end
        local new_icon = self._HIGHEST_HEAVY_SWAT_DAMAGE <= custom_value and 1 or 2
        if self._icon_visible ~= new_icon then
            self._icon_visible = new_icon
            if new_icon == 1 then
                self._icon:set_visible(true)
                self._progress:set_visible(true)
                self._icon_red:set_visible(false)
                self._progress_red:set_visible(false)
            else
                self._icon_red:set_visible(true)
                self._progress_red:set_visible(true)
                self._icon:set_visible(false)
                self._progress:set_visible(false)
            end
        end
        self._progress_red:stop()
        self._progress_red:animate(self._anim, ratio, self._progress_bar_red)
        EHIHealthBuffTracker.super.SetRatio(self, ratio, custom_value)
    end
elseif EHIHealthBuffTracker._CHECK_SNIPER_DAMAGE then
    EHIHealthBuffTracker._HIGHEST_SNIPER_DAMAGE = tweak_data:GetHighestDamageFromEnemyAndWeapon("sniper", "m14_sniper_npc")
    ---@param ratio number
    ---@param custom_value number?
    function EHIHealthBuffTracker:SetRatio(ratio, custom_value)
        if self._ratio == ratio then
            return
        end
        local new_icon = self._HIGHEST_SNIPER_DAMAGE <= custom_value and 1 or (self._HIGHEST_SNIPER_DAMAGE <= custom_value + self._armor_value) and 2 or 3
        if self._icon_visible ~= new_icon then
            self._icon_visible = new_icon
            if new_icon == 1 then
                self._icon:set_visible(true)
                self._progress:set_visible(true)
                self._icon_orange:set_visible(false)
                self._progress_orange:set_visible(false)
                self._icon_red:set_visible(false)
                self._progress_red:set_visible(false)
            elseif new_icon == 2 then
                self._icon_orange:set_visible(true)
                self._progress_orange:set_visible(true)
                self._icon:set_visible(false)
                self._progress:set_visible(false)
                self._icon_red:set_visible(false)
                self._progress_red:set_visible(false)
            else
                self._icon_red:set_visible(true)
                self._progress_red:set_visible(true)
                self._icon:set_visible(false)
                self._progress:set_visible(false)
                self._icon_orange:set_visible(false)
                self._progress_orange:set_visible(false)
            end
        end
        self._progress_orange:stop()
        self._progress_orange:animate(self._anim, ratio, self._progress_bar_orange)
        self._progress_red:stop()
        self._progress_red:animate(self._anim, ratio, self._progress_bar_red)
        EHIHealthBuffTracker.super.SetRatio(self, ratio, custom_value)
    end
end