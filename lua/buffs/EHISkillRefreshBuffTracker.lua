---@class EHISkillRefreshBuffTracker : EHIGaugeBuffTracker
---@field super EHIGaugeBuffTracker
---@field _refresh_option string?
---@field _deck_refresh_option { deck: string, option: string }?
EHISkillRefreshBuffTracker = class(EHIGaugeBuffTracker)
function EHISkillRefreshBuffTracker:post_init(...)
    self._skill_value = 0
    if self._deck_refresh_option then
        self._refresh_time = 1 / EHI:GetBuffDeckOption(self._deck_refresh_option.deck, self._deck_refresh_option.option)
    elseif self._refresh_option then
        self._refresh_time = 1 / EHI:GetBuffOption(self._refresh_option)
    else
        self._refresh_time = 1
    end
    self._time = self._refresh_time
    EHISkillRefreshBuffTracker.super.post_init(self, ...)
end

function EHISkillRefreshBuffTracker:EnableInLoud()
    self._enable_in_loud = true
    self._update_loop_in_pre_update = true
end

function EHISkillRefreshBuffTracker:PreUpdate()
    self._player_manager = managers.player
    self:SetRatio(0)
    if not self._enable_in_loud then
        self:PreUpdate2()
        if self._update_loop_in_pre_update then
            self:AddBuffToUpdate()
        end
    end
end

function EHISkillRefreshBuffTracker:SetCustodyState(state)
    if state then
        self:RemoveBuffFromUpdate()
        self._skill_value = -1
        self:Deactivate()
    else
        self._time = self._refresh_time
        self:AddBuffToUpdate()
    end
end

function EHISkillRefreshBuffTracker:SwitchToLoudMode()
    if self:SwitchToLoudModeEnabled() then
        self:PreUpdate2()
        self:AddBuffToUpdate()
    else
        self._enable_in_loud = nil -- In case "SwitchToLoudMode" is called first before "PreUpdate" has a chance to init variables => mission started in loud mode in the briefing screen
    end
end

function EHISkillRefreshBuffTracker:SwitchToLoudModeEnabled()
    return self._player_manager and self._enable_in_loud
end

-- Hooks functions after alarm has been raised
function EHISkillRefreshBuffTracker:PreUpdate2()
end

function EHISkillRefreshBuffTracker:update(dt)
    if self._next_frame_visibility_update then
        self._next_frame_visibility_update = false
        if self._next_frame_visibility_active then
            self._next_frame_visibility_active = false
            self:Activate()
        else
            self._next_frame_visibility_not_active = false
            self:Deactivate()
        end
    end
    self._time = self._time - dt
    if self._time <= 0 then
        self:UpdateValue()
        self._time = self._refresh_time
    end
end

function EHISkillRefreshBuffTracker:UpdateValue()
end

function EHISkillRefreshBuffTracker:Activate()
    if self._active then
        return
    end
    self._active = true
    self._panel:stop()
    self._panel:animate(self._show)
    self:AddVisibleBuff()
end

function EHISkillRefreshBuffTracker:ActivateNextFrame()
    if self._active then
        return
    end
    self._next_frame_visibility_update = true
    self._next_frame_visibility_active = true
    self._next_frame_visibility_not_active = false
end

function EHISkillRefreshBuffTracker:Deactivate()
    if not self._active then
        return
    end
    self:RemoveVisibleBuff()
    self._panel:stop()
    self._panel:animate(self._hide)
    self._active = false
end

function EHISkillRefreshBuffTracker:DeactivateNextFrame()
    if not self._active then
        return
    end
    self._next_frame_visibility_update = true
    self._next_frame_visibility_not_active = true
    self._next_frame_visibility_active = false
end

---@class EHIDodgeChanceBuffTracker : EHISkillRefreshBuffTracker
---@field super EHISkillRefreshBuffTracker
EHIDodgeChanceBuffTracker = class(EHISkillRefreshBuffTracker)
EHIDodgeChanceBuffTracker._DODGE_INIT = tweak_data.player.damage.DODGE_INIT or 0
EHIDodgeChanceBuffTracker._refresh_option = "dodge_refresh"
function EHIDodgeChanceBuffTracker:init(...)
    EHIDodgeChanceBuffTracker.super.init(self, ...)
    self._update_disabled = true
    self:EnableInLoud()
end

function EHIDodgeChanceBuffTracker:UpdateValue()
    local player = self._player_manager:player_unit()
    local player_movement = player and player:movement() ---@cast player_movement -HuskPlayerMovement
    if player_movement == nil then
        return
    end
    local armorchance = self._player_manager:body_armor_value("dodge") --[[@as number]]
    local skillchance = self._player_manager:skill_dodge_chance(player_movement:running(), player_movement:crouching(), player_movement:zipline_unit() --[[@as boolean]])
    local base_total = self._DODGE_INIT + armorchance + skillchance
    local max_smoke_dodge = 0
    for _, smoke_screen in ipairs(self._player_manager._smoke_screen_effects or {}) do
        if smoke_screen:is_in_smoke(player) then
            max_smoke_dodge = tweak_data.projectiles.smoke_screen_grenade.dodge_chance
            break
        end
    end
    local total = 1 - (1 - base_total) * (1 - max_smoke_dodge)
    if self._skill_value == total then
        return
    elseif self._persistent or total > 0 then
        self:SetRatio(total)
        self:ActivateNextFrame()
    else
        self:DeactivateNextFrame()
    end
    self._skill_value = total
end

function EHIDodgeChanceBuffTracker:ForceUpdate()
    if self._update_disabled then
        return
    end
    self._time = 0.01 -- Activate next frame or the buff will be stuck in the buff that forced an update
end

function EHIDodgeChanceBuffTracker:PreUpdate2()
    local function update()
        self._time = 0.01 -- Activate next frame or the buff will be stuck in the buff that forced an update
    end
    Hooks:PostHook(PlayerStandard, "_start_action_zipline", "EHI_DodgeBuff_start_action_zipline", update)
    Hooks:PostHook(PlayerStandard, "_end_action_zipline", "EHI_DodgeBuff_end_action_zipline", update)
    Hooks:PostHook(PlayerStandard, "_start_action_ducking", "EHI_DodgeBuff_start_action_ducking", update)
    Hooks:PostHook(PlayerStandard, "_end_action_ducking", "EHI_DodgeBuff_end_action_ducking", update)
    self._update_disabled = false
end

function EHIDodgeChanceBuffTracker:SetCustodyState(state)
    EHIDodgeChanceBuffTracker.super.SetCustodyState(self, state)
    self._update_disabled = state
end

function EHIDodgeChanceBuffTracker:SwitchToLoudMode()
    if self:SwitchToLoudModeEnabled() then
        self._update_disabled = false
    end
    EHIDodgeChanceBuffTracker.super.SwitchToLoudMode(self)
end

---@class EHICritChanceBuffTracker : EHISkillRefreshBuffTracker
---@field super EHISkillRefreshBuffTracker
EHICritChanceBuffTracker = class(EHISkillRefreshBuffTracker)
EHICritChanceBuffTracker.ForceUpdate = EHIDodgeChanceBuffTracker.ForceUpdate
EHICritChanceBuffTracker._refresh_option = "crit_refresh"
function EHICritChanceBuffTracker:init(...)
    EHICritChanceBuffTracker.super.init(self, ...)
    self._update_disabled = true
    self:EnableInLoud()
end

function EHICritChanceBuffTracker:UpdateValue()
    local total = self._player_manager:critical_hit_chance(self._detection_risk)
    if self._skill_value == total then
        return
    elseif self._persistent or total > 0 then
        self:SetRatio(total)
        self:ActivateNextFrame()
    else
        self:DeactivateNextFrame()
    end
    self._skill_value = total
end

function EHICritChanceBuffTracker:PreUpdate()
    EHICritChanceBuffTracker.super.PreUpdate(self)
    self._detection_risk = managers.blackmarket:get_suspicion_offset_of_local(tweak_data.player.SUSPICION_OFFSET_LERP or 0.75)
    self._detection_risk = math.round(self._detection_risk * 100)
end

function EHICritChanceBuffTracker:PreUpdate2()
    self._update_disabled = false
end

---@param new_detection_risk number?
function EHICritChanceBuffTracker:UpdateDetectionRisk(new_detection_risk)
    self._detection_risk = new_detection_risk or self._detection_risk
end

function EHICritChanceBuffTracker:SetCustodyState(state)
    EHICritChanceBuffTracker.super.SetCustodyState(self, state)
    self._update_disabled = state
end

function EHICritChanceBuffTracker:SwitchToLoudMode()
    if self:SwitchToLoudModeEnabled() then
        self._update_disabled = false
    end
    EHICritChanceBuffTracker.super.SwitchToLoudMode(self)
end

---@class EHIDamageAbsorptionBuffTracker : EHISkillRefreshBuffTracker
---@field super EHISkillRefreshBuffTracker
EHIDamageAbsorptionBuffTracker = class(EHISkillRefreshBuffTracker)
EHIDamageAbsorptionBuffTracker._refresh_option = "damage_absorption_refresh"
function EHIDamageAbsorptionBuffTracker:post_init(...)
    self:EnableInLoud()
    EHIDamageAbsorptionBuffTracker.super.post_init(self, ...)
end

function EHIDamageAbsorptionBuffTracker:UpdateValue()
    local absorption = self._player_manager:damage_absorption()
    if self._skill_value == absorption then
        return
    elseif self._persistent or absorption > 0 then
        local total = 0
        local player_unit = self._player_manager:player_unit()
        if alive(player_unit) then
            local damage = player_unit:character_damage() ---@cast damage -HuskPlayerDamage
            if damage then
                local max_health = damage:_max_health()
                total = absorption / max_health
            end
        end
        self:SetRatio(total, absorption * 10)
        self:ActivateNextFrame()
    else
        self:DeactivateNextFrame()
    end
    self._skill_value = absorption
end

---@class EHIDamageReductionBuffTracker : EHISkillRefreshBuffTracker
---@field super EHISkillRefreshBuffTracker
EHIDamageReductionBuffTracker = class(EHISkillRefreshBuffTracker)
EHIDamageReductionBuffTracker._refresh_option = "damage_reduction_refresh"
function EHIDamageReductionBuffTracker:post_init(...)
    self:EnableInLoud()
    EHIDamageReductionBuffTracker.super.post_init(self, ...)
end

function EHIDamageReductionBuffTracker:UpdateValue()
    if not self._player_manager:player_unit() then
        return
    end
    local reduction = 1 - self._player_manager:damage_reduction_skill_multiplier("bullet")
    if self._skill_value == reduction then
        return
    elseif self._persistent or reduction > 0 then
        self:SetRatio(reduction)
        self:ActivateNextFrame()
    else
        self:DeactivateNextFrame()
    end
    self._skill_value = reduction
end

function EHIDamageReductionBuffTracker:Format(value)
    return string.format("%d%%", math.floor(self._ratio * 100))
end

---@class EHIBerserkerBuffTracker : EHISkillRefreshBuffTracker
---@field super EHISkillRefreshBuffTracker
EHIBerserkerBuffTracker = class(EHISkillRefreshBuffTracker)
EHIBerserkerBuffTracker._refresh_option = "berserker_refresh"
EHIBerserkerBuffTracker._THRESHOLD = tweak_data.upgrades.player_damage_health_ratio_threshold or 0.5
function EHIBerserkerBuffTracker:post_init(...)
    self._damage_multiplier = 0
    self._melee_damage_multiplier = 0
    self._current_damage_multiplier = 1
    self._current_melee_damage_multiplier = 1
    local text_format = EHI:GetBuffOption("berserker_text_format")
    if text_format == 1 then
        self._text_format = "$dmg;$postfix; $mle;$postfix;"
        self:SetMultiGroup("weapon_damage_increase", "melee_damage_increase")
    elseif text_format == 2 then
        self._text_format = "$mle;$postfix; $dmg;$postfix;"
        self:SetMultiGroup("melee_damage_increase", "weapon_damage_increase")
    elseif text_format == 3 then
        self._text_format = "$dmg;$postfix;"
        self:SetHintText("ehi_buffs_hint_damage_increase", true)
        self:SetGroup("weapon_damage_increase")
    else -- 4
        self._text_format = "$mle;$postfix;"
        self:SetHintText("ehi_buffs_hint_melee_damage_increase", true)
        self:SetGroup("melee_damage_increase")
    end
    self._text_format_macros = { postfix = EHI:GetBuffOption("berserker_format") == 1 and "x" or "%" }
    managers.ehi_hook:AddPlayerSpawnedListener(self._id, function(character_damage)
        self._character_damage = character_damage
        self:CanActivateUpdateLoop()
    end)
    managers.ehi_hook:AddPlayerDespawnedListener(self._id, function()
        self:RemoveBuffFromUpdate()
        self._character_damage = nil
    end)
    EHIBerserkerBuffTracker.super.post_init(self, ...)
end

function EHIBerserkerBuffTracker:PreUpdate()
    EHIBerserkerBuffTracker.super.PreUpdate(self)
    if not ((self._player_manager:has_category_upgrade("player", "melee_damage_health_ratio_multiplier") or self._player_manager:has_category_upgrade("player", "damage_health_ratio_multiplier")) and self._player_manager:get_damage_health_ratio(0) > 0) then
        self:delete_with_class()
        return
    end
    self._damage_multiplier = self._player_manager:upgrade_value("player", "damage_health_ratio_multiplier", 0) --[[@as number]]
    if self._text_format == "$mle;$postfix;" and self._damage_multiplier == 0 then
        self:delete_with_class()
        return
    end
    self._melee_damage_multiplier = self._player_manager:upgrade_value("player", "melee_damage_health_ratio_multiplier", 0) --[[@as number]]
    if self._text_format == "$dmg;$postfix;" and self._melee_damage_multiplier == 0 then
        self:delete_with_class()
        return
    end
    self.__pre_update = true
    self:SetPersistent()
    self:CanActivateUpdateLoop()
end

function EHIBerserkerBuffTracker:CanActivateUpdateLoop()
    if self._character_damage and self.__pre_update then
        self:Activate()
        self._time = self._refresh_time
        self:AddBuffToUpdate()
    end
end

function EHIBerserkerBuffTracker:SetCustodyState(state)
end

function EHIBerserkerBuffTracker:UpdateValue()
    local health_ratio = self._character_damage:health_ratio()
    if self._persistent or health_ratio <= self._THRESHOLD then
        local damage_ratio = 1 - (health_ratio / math.max(0.01, self._THRESHOLD))
        self._current_melee_damage_multiplier = 1 + self._melee_damage_multiplier * damage_ratio
        self._current_damage_multiplier = 1 + self._damage_multiplier * damage_ratio
        if self._persistent or (self._current_damage_multiplier > 1 or self._current_melee_damage_multiplier > 1) then
            self:ActivateSoft()
            self:SetRatio(damage_ratio)
        else
            self:DeactivateSoft()
        end
    else
        self:DeactivateSoft()
    end
end

function EHIBerserkerBuffTracker:Activate()
    self._active = true
end

function EHIBerserkerBuffTracker:Deactivate()
    if not self._active then
        return
    end
    self:DeactivateSoft()
    self._active = false
    self._progress_bar.red = 0 -- No need to animate this because the panel is no longer visible
    self._progress:set_color(self._progress_bar)
end

function EHIBerserkerBuffTracker:SetPersistent()
    self._persistent = true
end

if EHI:GetBuffOption("berserker_format") == 1 then
    function EHIBerserkerBuffTracker:Format()
        self._text_format_macros.dmg = self._current_damage_multiplier > 1 and math.ehi_round(self._current_damage_multiplier, 0.01) or 1
        self._text_format_macros.mle = self._current_melee_damage_multiplier > 1 and math.ehi_round(self._current_melee_damage_multiplier, 0.01) or 1
        return managers.localization:_text_macroize(self._text_format, self._text_format_macros)
    end
else
    function EHIBerserkerBuffTracker:Format()
        self._text_format_macros.dmg = self._current_damage_multiplier > 1 and math.ehi_round_chance(self._current_damage_multiplier - 1) or 0
        self._text_format_macros.mle = self._current_melee_damage_multiplier > 1 and math.ehi_round_chance(self._current_melee_damage_multiplier - 1) or 0
        return managers.localization:_text_macroize(self._text_format, self._text_format_macros)
    end
end

function EHIBerserkerBuffTracker:delete_with_class()
    managers.ehi_hook:RemovePlayerSpawnedListener(self._id)
    managers.ehi_hook:RemovePlayerDespawnedListener(self._id)
    self._character_damage = nil
    EHIBerserkerBuffTracker.super.delete_with_class(self)
end

---@class EHIYakuzaBuffTracker : EHISkillRefreshBuffTracker
---@field super EHISkillRefreshBuffTracker
EHIYakuzaBuffTracker = class(EHISkillRefreshBuffTracker)
EHIYakuzaBuffTracker._deck_refresh_option = { deck = "yakuza", option = "irezumi_refresh" }
function EHIYakuzaBuffTracker:post_init(...)
    self._armor_regen_multiplier = 0
    self._movement_multiplier = 0
    self._current_armor_regen_multiplier = 1
    self._current_movement_multiplier = 1
    local text_format = EHI:GetBuffDeckOption("yakuza", "irezumi_text_format")
    if text_format == 1 then
        self._text_format = "$arm;$postfix; $mov;$postfix;"
        self:SetMultiGroup("default", "player_movement_increase")
    elseif text_format == 2 then
        self._text_format = "$mov;$postfix; $arm;$postfix;"
        self:SetMultiGroup("player_movement_increase", "default")
    elseif text_format == 3 then
        self._text_format = "$arm;$postfix;"
    else -- 4
        self._text_format = "$mov;$postfix;"
        self:SetHintText("ehi_buffs_hint_movement_increase", true)
        self:SetGroup("player_movement_increase")
    end
    self._text_format_macros = { postfix = EHI:GetBuffDeckOption("yakuza", "irezumi_format") == 1 and "x" or "%" }
    managers.ehi_hook:AddPlayerSpawnedListener(self._id, function(character_damage)
        self._character_damage = character_damage
        self:CanActivateUpdateLoop()
    end)
    managers.ehi_hook:AddPlayerDespawnedListener(self._id, function()
        self:RemoveBuffFromUpdate()
        self._character_damage = nil
    end)
    EHIYakuzaBuffTracker.super.post_init(self, ...)
end

function EHIYakuzaBuffTracker:PreUpdate()
    EHIYakuzaBuffTracker.super.PreUpdate(self)
    if not (self._player_manager:has_category_upgrade("player", "armor_regen_damage_health_ratio_multiplier") or self._player_manager:has_category_upgrade("player", "movement_speed_damage_health_ratio_multiplier")) then
        self:delete_with_class()
        return
    end
    self._armor_regen_multiplier = self._player_manager:upgrade_value("player", "armor_regen_damage_health_ratio_multiplier", 0) --[[@as number]]
    if self._text_format == "$arm;$postfix;" and self._armor_regen_multiplier == 0 then
        self:delete_with_class()
        return
    end
    self._movement_multiplier = self._player_manager:upgrade_value("player", "movement_speed_damage_health_ratio_multiplier", 0) --[[@as number]]
    if self._text_format == "$mov;$postfix;" and self._movement_multiplier == 0 then
        self:delete_with_class()
        return
    end
    if self._player_manager:has_category_upgrade("player", "armor_regen_damage_health_ratio_threshold_multiplier") or self._player_manager:has_category_upgrade("player", "movement_speed_damage_health_ratio_threshold_multiplier") then -- Yakuza 9/9 deck
        self._THRESHOLD = 0.5
    else
        self._THRESHOLD = 0.25
    end
    self:SetPersistent()
    self:CanActivateUpdateLoop()
end

function EHIYakuzaBuffTracker:CanActivateUpdateLoop()
    if self._character_damage and self._THRESHOLD then
        self:Activate()
        self._time = self._refresh_time
        self:AddBuffToUpdate()
    end
end

function EHIYakuzaBuffTracker:SetCustodyState(state)
end

function EHIYakuzaBuffTracker:UpdateValue()
    local health_ratio = self._character_damage:health_ratio()
    if self._persistent or health_ratio <= self._THRESHOLD then
        local damage_ratio = 1 - (health_ratio / math.max(0.01, self._THRESHOLD))
        self._current_movement_multiplier = 1 + self._movement_multiplier * damage_ratio
        self._current_armor_regen_multiplier = 1 + self._armor_regen_multiplier * damage_ratio
        if self._persistent or (self._current_armor_regen_multiplier > 1 or self._current_movement_multiplier > 1) then
            self:ActivateSoft()
            self:SetRatio(damage_ratio)
        else
            self:DeactivateSoft()
        end
    else
        self:DeactivateSoft()
    end
end

function EHIYakuzaBuffTracker:Activate()
    self._active = true
end

function EHIYakuzaBuffTracker:Deactivate()
    if not self._active then
        return
    end
    self:DeactivateSoft()
    self._active = false
    self._progress_bar.red = 0 -- No need to animate this because the panel is no longer visible
    self._progress:set_color(self._progress_bar)
end

function EHIYakuzaBuffTracker:SetPersistent()
    self._persistent = true
end

if EHI:GetBuffDeckOption("yakuza", "irezumi_format") == 1 then
    function EHIYakuzaBuffTracker:Format()
        self._text_format_macros.arm = string.format("%.2f", self._current_armor_regen_multiplier > 1 and math.ehi_round(self._current_armor_regen_multiplier, 0.01) or 1)
        self._text_format_macros.mov = string.format("%.2f", self._current_movement_multiplier > 1 and math.ehi_round(self._current_movement_multiplier, 0.01) or 1)
        return managers.localization:_text_macroize(self._text_format, self._text_format_macros)
    end
else
    function EHIYakuzaBuffTracker:Format()
        self._text_format_macros.arm = self._current_armor_regen_multiplier > 1 and math.ehi_round_chance(self._current_armor_regen_multiplier - 1) or 0
        self._text_format_macros.mov = self._current_movement_multiplier > 1 and math.ehi_round_chance(self._current_movement_multiplier - 1) or 0
        return managers.localization:_text_macroize(self._text_format, self._text_format_macros)
    end
end

function EHIYakuzaBuffTracker:delete_with_class()
    managers.ehi_hook:RemovePlayerSpawnedListener(self._id)
    managers.ehi_hook:RemovePlayerDespawnedListener(self._id)
    self._character_damage = nil
    EHIYakuzaBuffTracker.super.delete_with_class(self)
end

---@class EHIUppersRangeBuffTracker : EHISkillRefreshBuffTracker
---@field super EHISkillRefreshBuffTracker
EHIUppersRangeBuffTracker = class(EHISkillRefreshBuffTracker)
EHIUppersRangeBuffTracker._refresh_option = "uppers_range_refresh"
function EHIUppersRangeBuffTracker:post_init(...)
    self._mv3_distance = mvector3.distance
    EHIUppersRangeBuffTracker.super.post_init(self, ...)
end

function EHIUppersRangeBuffTracker:PreUpdate()
    EHIUppersRangeBuffTracker.super.PreUpdate(self)
    local function Check(...)
        if self._in_custody then
            return
        elseif next(FirstAidKitBase.List) then
            self:Activate()
        elseif self._persistent then
            self:DeactivateUpdate()
        else
            self:Deactivate()
        end
    end
    Hooks:PostHook(FirstAidKitBase, "Add", "EHI_UppersRangeBuff_Add", Check)
    Hooks:PostHook(FirstAidKitBase, "Remove", "EHI_UppersRangeBuff_Remove", Check)
    self:SetCustodyState(false)
    if self._persistent then
        self:ActivateSoft()
    end
end

function EHIUppersRangeBuffTracker:Activate()
    if self._active then
        return
    end
    self._active = true
    self:AddBuffToUpdate()
end

function EHIUppersRangeBuffTracker:SetCustodyState(state)
    if state then
        if self._persistent then
            self:DeactivateUpdate()
        else
            self:Deactivate()
        end
    elseif next(FirstAidKitBase.List) then
        self:Activate()
    end
    self._in_custody = state
end

function EHIUppersRangeBuffTracker:Deactivate()
    if not self._active then
        return
    end
    self:DeactivateSoft()
    self:RemoveBuffFromUpdate()
    self._active = false
end

function EHIUppersRangeBuffTracker:DeactivateUpdate()
    if not self._active then
        return
    end
    self:RemoveBuffFromUpdate()
    self._active = false
end

function EHIUppersRangeBuffTracker:UpdateValue()
    local player_unit = self._player_manager:player_unit()
    if alive(player_unit) then
        local found, distance, min_distance = self:GetFirstAidKit(player_unit:position())
        if found then
            local ratio = 1 - (distance / min_distance)
            self._skill_value = distance / 100
            self:ActivateSoft()
            self:SetRatio(ratio)
        elseif not self._persistent then
            self:DeactivateSoft()
        end
    end
end

---@param pos Vector3
---@return boolean, number?, number?
function EHIUppersRangeBuffTracker:GetFirstAidKit(pos)
    for _, o in ipairs(FirstAidKitBase.List) do
        local dst = self._mv3_distance(pos, o.pos)
        if dst <= o.min_distance then
            return true, dst, o.min_distance
        end
    end
    return false
end

function EHIUppersRangeBuffTracker:Format()
    return string.format("%dm", math.floor(self._skill_value))
end

function EHIUppersRangeBuffTracker:SetPersistent()
    self._persistent = true
end