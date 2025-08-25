---@class EHITimerGuiSharedMaster
---@field new fun(self: self, params: EHITracker.params): self
EHITimerGuiSharedMaster = class()
function EHITimerGuiSharedMaster:init(params)
    self._id = "ehi_" .. params.id
    self._key = params.id
    self._time = params.time
    self._timer_gui = params.timer_gui --[[@as TimerGui]]
    self._callback_function = callback(self, self, "update")
    self:AddToUpdate()
end

---@param dt number
function EHITimerGuiSharedMaster:update(_, dt)
    local dt_mod = self._timer_gui:get_timer_multiplier()
    self._time = self._time - dt / dt_mod
    local t = self._time * dt_mod
    self._parent:UpdateTimer(self._key, t)
end

function EHITimerGuiSharedMaster:AddToUpdate()
    managers.hud:add_updator(self._id, self._callback_function)
end

function EHITimerGuiSharedMaster:RemoveFromUpdate()
    managers.hud:remove_updator(self._id)
end

---@param jammed boolean
function EHITimerGuiSharedMaster:SetJammed(jammed)
    self._jammed = jammed
    self:SetUpdateStatus()
end

---@param powered boolean
function EHITimerGuiSharedMaster:SetPowered(powered)
    self._not_powered = not powered
    self:SetUpdateStatus()
end

function EHITimerGuiSharedMaster:SetRunning()
    self._jammed = false
    self._not_powered = false
    self:SetUpdateStatus()
end

function EHITimerGuiSharedMaster:SetUpdateStatus()
    if self._jammed or self._not_powered then
        self:RemoveFromUpdate()
    else
        self:AddToUpdate()
    end
end

---@class EHITimerGuiGroupSharedMaster : EHITimerGuiSharedMaster
---@field new fun(self: self, params: EHITracker.params): self
---@field super EHITimerGuiSharedMaster
EHITimerGuiGroupSharedMaster = class(EHITimerGuiSharedMaster)
function EHITimerGuiGroupSharedMaster:init(params)
    self._timers = {} ---@type table<string, EHITimerGroupTracker.Timer>
    self._id = "ehi_" .. params.id
    if params.key and params.time then
        self:AddTimer(params.key, params.time, params.timer_gui)
    end
    self._callback_function = callback(self, self, "update")
    self:AddToUpdate()
end

---@param dt number
function EHITimerGuiGroupSharedMaster:update(_, dt)
    for id, timer in pairs(self._timers) do
        if timer.is_running then
            local dt_mod = timer.timer_gui:get_timer_multiplier()
            timer.time = timer.time - dt / dt_mod
            local t = timer.time * dt_mod
            self._parent:UpdateTimer(id, t)
        end
    end
end

---@param id string
---@param t number
---@param timer_gui TimerGui
function EHITimerGuiGroupSharedMaster:AddTimer(id, t, timer_gui)
    self._timers[id] =
    {
        time = t,
        timer_gui = timer_gui,
        is_running = true
    }
end

---@param id string
function EHITimerGuiGroupSharedMaster:RemoveTimer(id)
    self._timers[id] = nil
end

---@param jammed boolean
---@param id string
function EHITimerGuiGroupSharedMaster:SetJammed(jammed, id)
    local timer = self._timers[id]
    if timer then
        timer.jammed = jammed
        self:SetUpdateStatus(timer)
    end
end

---@param powered boolean
---@param id string
function EHITimerGuiGroupSharedMaster:SetPowered(powered, id)
    local timer = self._timers[id]
    if timer then
        timer.not_powered = not powered
        self:SetUpdateStatus(timer)
    end
end

---@param id string
function EHITimerGuiGroupSharedMaster:SetRunning(id)
    local timer = self._timers[id]
    if timer then
        timer.jammed = false
        timer.not_powered = false
        self:SetUpdateStatus(timer)
    end
end

---@param timer EHITimerGroupTracker.Timer
function EHITimerGuiGroupSharedMaster:SetUpdateStatus(timer)
    timer.is_running = not (timer.jammed or timer.not_powered)
end