local persistent = false
local player_manager
local DODGE_INIT = tweak_data.player.damage.DODGE_INIT or 0
local function show(o)
    local t = 0
    local total = 0.15
    while t < total do
        t = t + coroutine.yield()
        o:set_alpha(t / total)
    end
    o:set_alpha(1)
end
local function hide(o)
    local t = 0
    local total = 0.15
    while t < total do
        t = t + coroutine.yield()
        o:set_alpha(1 - (t / total))
    end
    o:set_alpha(0)
end
EHIDodgeChanceTracker = class(EHIGaugeBuffTracker)
function EHIDodgeChanceTracker:init(panel, params)
    EHIDodgeChanceTracker.super.init(self, panel, params)
    self._time = 1
    self._dodge = 0
    if persistent then
        self:Activate()
    end
end

function EHIDodgeChanceTracker:UpdateDodge()
    local player_movement = player_manager:player_unit()
    if player_movement == nil then
        return
    end
    player_movement = player_movement:movement()
    if player_movement == nil then
        return
    end
    local armorchance = player_manager:body_armor_value("dodge")
    local skillchance = player_manager:skill_dodge_chance(player_movement:running(), player_movement:crouching(), player_movement:zipline_unit())
    local total = DODGE_INIT + armorchance + skillchance
    if self._dodge == total then
        return
    end
    if persistent or total > 0 then
        self:SetRatio(total)
        self:Activate()
    else
        self:Deactivate()
    end
    self._dodge = total
end

function EHIDodgeChanceTracker:ForceUpdate()
    self:UpdateDodge()
    self._time = 1
end

function EHIDodgeChanceTracker:PreUpdate()
    player_manager = managers.player
    local function f(state)
        self:SetCustody(state)
    end
    EHI:AddOnCustodyCallback(f)
    local function update()
        self:UpdateDodge()
        self._time = 1
    end
    EHI:HookWithID(PlayerStandard, "_start_action_zipline", "EHI_DodgeBuff_start_action_zipline", update)
    EHI:HookWithID(PlayerStandard, "_end_action_zipline", "EHI_DodgeBuff_end_action_zipline", update)
    EHI:HookWithID(PlayerStandard, "_start_action_ducking", "EHI_DodgeBuff_start_action_ducking", update)
    EHI:HookWithID(PlayerStandard, "_end_action_ducking", "EHI_DodgeBuff_end_action_ducking", update)
end

function EHIDodgeChanceTracker:SetCustody(state)
    if state then
        self._parent_class:RemoveBuffFromUpdate(self._id)
        self._dodge = 0
        self:Deactivate()
    else
        self._time = 1
        self._parent_class:AddBuffToUpdate(self._id, self)
    end
end

function EHIDodgeChanceTracker:update(t, dt)
    self._time = self._time - dt
    if self._time <= 0 then
        self:UpdateDodge()
        self._time = 1
    end
end

function EHIDodgeChanceTracker:Activate()
    if self._active then
        return
    end
    self._active = true
    self._panel:stop()
    self._panel:animate(show)
    self._parent_class:AddVisibleBuff(self._id)
end

function EHIDodgeChanceTracker:Deactivate()
    if not self._active then
        return
    end
    self._parent_class:RemoveVisibleBuff(self._id, self._pos)
    self._panel:stop()
    self._panel:animate(hide)
    self._active = false
end