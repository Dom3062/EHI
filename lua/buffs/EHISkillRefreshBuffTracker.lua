---@class EHISkillRefreshBuffTracker : EHIGaugeBuffTracker
---@field super EHIGaugeBuffTracker
---@field _refresh_option string?
EHISkillRefreshBuffTracker = class(EHIGaugeBuffTracker)
function EHISkillRefreshBuffTracker:init(...)
    EHISkillRefreshBuffTracker.super.init(self, ...)
    self._skill_value = 0
    self._refresh_time = self._refresh_option and (1 / EHI:GetBuffOption(self._refresh_option)) or 1
    self._time = self._refresh_time
end

function EHISkillRefreshBuffTracker:PreUpdate()
    self._player_manager = managers.player
    self:SetRatio(0)
end

---@param state boolean
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

---@param dt number
function EHISkillRefreshBuffTracker:update(dt)
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

function EHISkillRefreshBuffTracker:Deactivate()
    if not self._active then
        return
    end
    self:RemoveVisibleBuff()
    self._panel:stop()
    self._panel:animate(self._hide)
    self._active = false
end

---@class EHIDodgeChanceBuffTracker : EHISkillRefreshBuffTracker
---@field super EHISkillRefreshBuffTracker
EHIDodgeChanceBuffTracker = class(EHISkillRefreshBuffTracker)
EHIDodgeChanceBuffTracker._DODGE_INIT = tweak_data.player.damage.DODGE_INIT or 0
EHIDodgeChanceBuffTracker._refresh_option = "dodge_refresh"
function EHIDodgeChanceBuffTracker:UpdateValue()
    local player = self._player_manager:player_unit()
    if player == nil then
        return
    end
    local player_movement = player:movement() ---@cast player_movement -HuskPlayerMovement
    if player_movement == nil then
        return
    end
    local armorchance = self._player_manager:body_armor_value("dodge") --[[@as number]]
    local skillchance = self._player_manager:skill_dodge_chance(player_movement:running(), player_movement:crouching(), player_movement:zipline_unit() --[[@as boolean]])
    local total = self._DODGE_INIT + armorchance + skillchance
    if self._skill_value == total then
        return
    elseif self._persistent or total > 0 then
        self:SetRatio(total)
        self:Activate()
    else
        self:Deactivate()
    end
    self._skill_value = total
end

function EHIDodgeChanceBuffTracker:ForceUpdate()
    self:UpdateValue()
    self._time = self._refresh_time
end

function EHIDodgeChanceBuffTracker:PreUpdate()
    EHIDodgeChanceBuffTracker.super.PreUpdate(self)
    local function update()
        self:UpdateValue()
        self._time = self._refresh_time
    end
    EHI:HookWithID(PlayerStandard, "_start_action_zipline", "EHI_DodgeBuff_start_action_zipline", update)
    EHI:HookWithID(PlayerStandard, "_end_action_zipline", "EHI_DodgeBuff_end_action_zipline", update)
    EHI:HookWithID(PlayerStandard, "_start_action_ducking", "EHI_DodgeBuff_start_action_ducking", update)
    EHI:HookWithID(PlayerStandard, "_end_action_ducking", "EHI_DodgeBuff_end_action_ducking", update)
end

---@class EHICritChanceBuffTracker : EHISkillRefreshBuffTracker
---@field super EHISkillRefreshBuffTracker
EHICritChanceBuffTracker = class(EHISkillRefreshBuffTracker)
EHICritChanceBuffTracker._refresh_option = "crit_refresh"
function EHICritChanceBuffTracker:init(...)
    EHICritChanceBuffTracker.super.init(self, ...)
    self._update_disabled = true
end

function EHICritChanceBuffTracker:UpdateValue()
    local total = self._player_manager:critical_hit_chance(self._detection_risk)
    if self._skill_value == total then
        return
    elseif self._persistent or total > 0 then
        self:SetRatio(total)
        self:Activate()
    else
        self:Deactivate()
    end
    self._skill_value = total
end

function EHICritChanceBuffTracker:ForceUpdate()
    if self._update_disabled then
        return
    end
    self:UpdateValue()
    self._time = self._refresh_time
end

function EHICritChanceBuffTracker:PreUpdate()
    EHICritChanceBuffTracker.super.PreUpdate(self)
    self._detection_risk = managers.blackmarket:get_suspicion_offset_of_local(tweak_data.player.SUSPICION_OFFSET_LERP or 0.75)
    self._detection_risk = math.round(self._detection_risk * 100)
    self._update_disabled = false
end

---@param new_detection_risk number?
function EHICritChanceBuffTracker:UpdateDetectionRisk(new_detection_risk)
    self._detection_risk = new_detection_risk or self._detection_risk
end

---@param state boolean
function EHICritChanceBuffTracker:SetCustodyState(state)
    EHICritChanceBuffTracker.super.SetCustodyState(self, state)
    self._update_disabled = state
end

---@class EHIDamageAbsorptionBuffTracker : EHISkillRefreshBuffTracker
EHIDamageAbsorptionBuffTracker = class(EHISkillRefreshBuffTracker)
EHIDamageAbsorptionBuffTracker._refresh_option = "damage_absorption_refresh"
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
        self:Activate()
    else
        self:Deactivate()
    end
    self._skill_value = absorption
end

---@class EHIDamageReductionBuffTracker : EHISkillRefreshBuffTracker
EHIDamageReductionBuffTracker = class(EHISkillRefreshBuffTracker)
EHIDamageReductionBuffTracker._refresh_option = "damage_reduction_refresh"
function EHIDamageReductionBuffTracker:UpdateValue()
    local reduction = 1 - self._player_manager:damage_reduction_skill_multiplier("bullet")
    if self._skill_value == reduction then
        return
    elseif self._persistent or reduction > 0 then
        self:SetRatio(reduction)
        self:Activate()
    else
        self:Deactivate()
    end
    self._skill_value = reduction
end