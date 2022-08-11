local persistent = false
local player_manager
local detection_risk = 0
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
EHICritChanceTracker = class(EHIGaugeBuffTracker)
function EHICritChanceTracker:init(panel, params)
    EHICritChanceTracker.super.init(self, panel, params)
    self._time = 1
    self._crit = 0
    self._update_disabled = true
    if persistent then
        self:Activate()
    end
end

function EHICritChanceTracker:UpdateCrit()
    local total = player_manager:critical_hit_chance(detection_risk)
    if self._crit == total then
        return
    end
    if persistent or total > 0 then
        self:SetRatio(total)
        self:Activate()
    else
        self:Deactivate()
    end
    self._crit = total
end

function EHICritChanceTracker:ForceUpdate()
    if self._update_disabled then
        return
    end
    self:UpdateCrit()
    self._time = 1
end

function EHICritChanceTracker:PreUpdate()
    player_manager = managers.player
    detection_risk = managers.blackmarket:get_suspicion_offset_of_local(tweak_data.player.SUSPICION_OFFSET_LERP or 0.75)
    detection_risk = math.round(detection_risk * 100)
    local function f(state)
        self:SetCustody(state)
    end
    EHI:AddOnCustodyCallback(f)
    self._update_disabled = false
end

function EHICritChanceTracker:SetCustody(state)
    if state then
        self._parent_class:RemoveBuffFromUpdate(self._id)
        self._crit = 0
        self:Deactivate()
    else
        self._time = 1
        self._parent_class:AddBuffToUpdate(self._id, self)
    end
    self._update_disabled = state
end

function EHICritChanceTracker:update(t, dt)
    self._time = self._time - dt
    if self._time <= 0 then
        self:UpdateCrit()
        self._time = 1
    end
end

function EHICritChanceTracker:Activate()
    if self._active then
        return
    end
    self._active = true
    self._panel:stop()
    self._panel:animate(show)
    self._parent_class:AddVisibleBuff(self._id)
end

function EHICritChanceTracker:Deactivate()
    if not self._active then
        return
    end
    self._parent_class:RemoveVisibleBuff(self._id, self._pos)
    self._panel:stop()
    self._panel:animate(hide)
    self._active = false
end