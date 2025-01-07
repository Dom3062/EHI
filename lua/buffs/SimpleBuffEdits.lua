---@class EHIHealthRegenBuffTracker : EHIBuffTracker
---@field super EHIBuffTracker
EHIHealthRegenBuffTracker = class(EHIBuffTracker)
function EHIHealthRegenBuffTracker:post_init(...)
    local icon = self._icon -- Hostage Taker regen
    self._icon2 = self._panel:bitmap({ -- Muscle regen
        texture = "guis/textures/pd2/specialization/icons_atlas",
        texture_rect = { 4 * 64, 64, 64, 64 },
        color = Color.white,
        x = icon:x(),
        y = icon:y(),
        w = icon:w(),
        h = icon:h()
    })
    self._icon3 = self._panel:bitmap({
        texture = tweak_data.hud_icons.skill_5.texture,
        texture_rect = tweak_data.hud_icons.skill_5.texture_rect,
        color = Color.white,
        x = icon:x(),
        y = icon:y(),
        w = icon:w(),
        h = icon:h()
    })
    self:SetIcon("hostage_taker")
    self._minion_count, self._ai_health_regen, self._max_health, self._healing_reduction = 0, 0, 0, 1
    self._health_format = "+%g"
    self._player_manager = managers.player
    self._perform_update_from_spawn = false
    EHI:AddCallback(EHI.CallbackMessage.OnMinionAdded, function(key, local_peer, peer_id)
        if local_peer then
            self._minion_count = self._minion_count + 1
            if self._minion_count == 1 then
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
                self:SetHintText(string.format(self._health_format, self:GetHealthRegen()))
            end
        elseif boost == "crew_healthy" and self._character_damage and self._perform_update_from_spawn then
            self:AddBuffToUpdate2()
        end
    end)
    EHI:AddCallback("PlayerSpawned", function(character_damage) ---@param character_damage PlayerDamage
        self._character_damage = character_damage
        if self._perform_update_from_spawn then
            self:AddBuffToUpdate2()
        end
    end)
    EHI:AddCallback("PlayerDespawned", function()
        self:RemoveBuffFromUpdate2()
        self._character_damage = nil
        self._max_health = 0
    end)
end

function EHIHealthRegenBuffTracker:update_health_regen(...)
    local new_max_health = self._character_damage:_max_health()
    if self._max_health ~= new_max_health then
        self._max_health = new_max_health
        self:SetHintText(string.format(self._health_format, self:GetHealthRegen(new_max_health)))
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
    return self._parent_class:RoundHealthNumber(hp_to_restore_from_regen + hp_to_restore_from_ai)
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

function EHIHealthRegenBuffTracker:PreUpdateCheck()
    self._healing_reduction = self._player_manager:upgrade_value("player", "healing_reduction", 1)
    self:AddBuffToUpdate2()
    self._perform_update_from_spawn = true
    return true
end

function EHIHealthRegenBuffTracker:AddBuffToUpdate2()
    managers.hud:add_updator(self._id, callback(self, self, "update_health_regen"))
end

function EHIHealthRegenBuffTracker:RemoveBuffFromUpdate2()
    managers.hud:remove_updator(self._id)
end

---@class EHIStaminaBuffTracker : EHIGaugeBuffTracker
---@field super EHIGaugeBuffTracker
EHIStaminaBuffTracker = class(EHIGaugeBuffTracker)
---@param max_stamina number
function EHIStaminaBuffTracker:Spawned(max_stamina)
    self:SetMaxStamina(max_stamina)
    self:PreUpdate()
end

function EHIStaminaBuffTracker:PreUpdate()
    self:SetRatio(self._max_stamina)
    self:Activate()
end

---@param value number
function EHIStaminaBuffTracker:SetMaxStamina(value)
    self._max_stamina = value
end

function EHIStaminaBuffTracker:SetRatio(ratio)
    local value = ratio / self._max_stamina
    local rounded = self._parent_class.RoundNumber(value, 0.01)
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

function EHIStaminaBuffTracker:Deactivate()
    if not self._active then
        return
    end
    self:RemoveVisibleBuff()
    self._panel:stop()
    self._panel:animate(self._hide)
    self._active = false
end

---@class EHIStoicBuffTracker : EHIBuffTracker
---@field super EHIBuffTracker
EHIStoicBuffTracker = class(EHIBuffTracker)
function EHIStoicBuffTracker:Activate(t, pos)
    EHIStoicBuffTracker.super.Activate(self, self._auto_shrug or t, pos)
end

function EHIStoicBuffTracker:Extend(t)
    EHIStoicBuffTracker.super.Extend(self, self._auto_shrug or t)
end

---@param t number
function EHIStoicBuffTracker:SetAutoShrug(t)
    self._auto_shrug = t
end

---@class EHIHackerTemporaryDodgeBuffTracker : EHIBuffTracker
---@field super EHIBuffTracker
EHIHackerTemporaryDodgeBuffTracker = class(EHIBuffTracker)
function EHIHackerTemporaryDodgeBuffTracker:Activate(...)
    EHIHackerTemporaryDodgeBuffTracker.super.Activate(self, ...)
    self._parent_class:CallFunction("DodgeChance", "ForceUpdate")
end

function EHIHackerTemporaryDodgeBuffTracker:Deactivate()
    EHIHackerTemporaryDodgeBuffTracker.super.Deactivate(self)
    self._parent_class:CallFunction("DodgeChance", "ForceUpdate")
end

---@class EHIUnseenStrikeBuffTracker : EHIBuffTracker
---@field super EHIBuffTracker
EHIUnseenStrikeBuffTracker = class(EHIBuffTracker)
function EHIUnseenStrikeBuffTracker:Activate(...)
    EHIUnseenStrikeBuffTracker.super.Activate(self, ...)
    self._parent_class:CallFunction("CritChance", "ForceUpdate")
end

function EHIUnseenStrikeBuffTracker:Deactivate()
    EHIUnseenStrikeBuffTracker.super.Deactivate(self)
    self._parent_class:CallFunction("CritChance", "ForceUpdate")
end

---@class EHIExPresidentBuffTracker : EHIGaugeBuffTracker
---@field super EHIGaugeBuffTracker
EHIExPresidentBuffTracker = class(EHIGaugeBuffTracker)
function EHIExPresidentBuffTracker:PreUpdateCheck()
    if managers.player:has_category_upgrade("player", "armor_health_store_amount") then
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
        return true
    else
        self:delete_with_class()
    end
end

function EHIExPresidentBuffTracker:PreUpdate()
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
function EHIManiacBuffTracker:PreUpdateCheck()
    if self._persistent and managers.player:has_category_upgrade("player", "cocaine_stacking") then
        self:ActivateSoft()
    end
end

function EHIManiacBuffTracker:SetPersistent()
    self._persistent = true
end

function EHIManiacBuffTracker:Deactivate()
    if self._persistent then
        self._ratio = 0
        self._progress:stop()
        self._progress:animate(self._anim, 0, self._progress_bar)
        return
    end
    EHIManiacBuffTracker.super.Deactivate(self)
end

---@class EHIReplenishThrowableBuffTracker : EHIBuffTracker
---@field super EHIBuffTracker
EHIReplenishThrowableBuffTracker = class(EHIBuffTracker)
function EHIReplenishThrowableBuffTracker:post_init(...)
    self._replenish_count_running = 0
    self._hint:set_visible(false)
end

function EHIReplenishThrowableBuffTracker:AddToReplenish()
    self._replenish_count_running = self._replenish_count_running + 1
    self:SetHintText(self._replenish_count_running)
    self._hint:set_visible(self._replenish_count_running >= 2)
end

function EHIReplenishThrowableBuffTracker:Replenished()
    self._replenish_count_running = math.max(0, self._replenish_count_running - 1)
    self:SetHintText(self._replenish_count_running)
    self._hint:set_visible(self._replenish_count_running >= 2)
end

function EHIReplenishThrowableBuffTracker:SetCustodyState(state)
    if state and self._active then
        self:Deactivate()
    end
end

---@class EHITagTeamBuffTracker : EHIBuffTracker
EHITagTeamBuffTracker = class(EHIBuffTracker)
---@param t number
---@param max number
function EHITagTeamBuffTracker:AddTimeCeil(t, max)
    self._time = math.min(self._time + t, max)
end