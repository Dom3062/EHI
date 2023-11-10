local EHI = EHI
local player_manager ---@type PlayerManager
local DODGE_INIT = tweak_data.player.damage.DODGE_INIT or 0
---@class EHIDodgeChanceBuffTracker : EHIGaugeBuffTracker
---@field super EHIGaugeBuffTracker
EHIDodgeChanceBuffTracker = class(EHIGaugeBuffTracker)
EHIDodgeChanceBuffTracker._refresh_time = 1 / EHI:GetBuffOption("dodge_refresh")
function EHIDodgeChanceBuffTracker:init(panel, params)
    EHIDodgeChanceBuffTracker.super.init(self, panel, params)
    self._time = self._refresh_time
    self._dodge = 0
end

function EHIDodgeChanceBuffTracker:UpdateDodge()
    local player = player_manager:player_unit()
    if player == nil then
        return
    end
    local player_movement = player:movement() ---@cast player_movement -HuskPlayerMovement
    if player_movement == nil then
        return
    end
    local armorchance = player_manager:body_armor_value("dodge") --[[@as number]]
    local skillchance = player_manager:skill_dodge_chance(player_movement:running(), player_movement:crouching(), player_movement:zipline_unit() --[[@as boolean]])
    local total = DODGE_INIT + armorchance + skillchance
    if self._dodge == total then
        return
    elseif self._persistent or total > 0 then
        self:SetRatio(total)
        self:Activate()
    else
        self:Deactivate()
    end
    self._dodge = total
end

function EHIDodgeChanceBuffTracker:ForceUpdate()
    self:UpdateDodge()
    self._time = self._refresh_time
end

function EHIDodgeChanceBuffTracker:PreUpdate()
    player_manager = managers.player
    EHI:AddOnCustodyCallback(function(state)
        self:SetCustody(state)
    end)
    local function update()
        self:UpdateDodge()
        self._time = self._refresh_time
    end
    EHI:HookWithID(PlayerStandard, "_start_action_zipline", "EHI_DodgeBuff_start_action_zipline", update)
    EHI:HookWithID(PlayerStandard, "_end_action_zipline", "EHI_DodgeBuff_end_action_zipline", update)
    EHI:HookWithID(PlayerStandard, "_start_action_ducking", "EHI_DodgeBuff_start_action_ducking", update)
    EHI:HookWithID(PlayerStandard, "_end_action_ducking", "EHI_DodgeBuff_end_action_ducking", update)
    self:SetRatio(0)
end

---@param state boolean
function EHIDodgeChanceBuffTracker:SetCustody(state)
    if state then
        self:RemoveBuffFromUpdate()
        self._dodge = 0
        self:Deactivate()
    else
        self._time = self._refresh_time
        self:AddBuffToUpdate()
    end
end

---@param dt number
function EHIDodgeChanceBuffTracker:update(dt)
    self._time = self._time - dt
    if self._time <= 0 then
        self:UpdateDodge()
        self._time = self._refresh_time
    end
end

function EHIDodgeChanceBuffTracker:Activate()
    if self._active then
        return
    end
    self._active = true
    self._panel:stop()
    self._panel:animate(self._show)
    self:AddVisibleBuff()
end

function EHIDodgeChanceBuffTracker:Deactivate()
    if not self._active then
        return
    end
    self:RemoveVisibleBuff()
    self._panel:stop()
    self._panel:animate(self._hide)
    self._active = false
end