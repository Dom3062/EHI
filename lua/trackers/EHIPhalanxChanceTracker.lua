---@class EHIPhalanxChanceTracker : EHITimedChanceTracker
---@field super EHITimedChanceTracker
EHIPhalanxChanceTracker = class(EHITimedChanceTracker)
EHIPhalanxChanceTracker._forced_icons = { "buff_shield" }
EHIPhalanxChanceTracker._paused_color = EHIPausableTracker._paused_color
EHIPhalanxChanceTracker.IsHost = EHI:IsHost()
---@param params EHITracker.params
function EHIPhalanxChanceTracker:post_init(params)
    self._t_refresh = params.time
    self._chance_increase = params.chance_increase
    self._assault_t = self._parent_class:GetInternalData("assault", "is_assault") and self:ComputeAssaultTime(true) or 0
    self._first_assault = params.first_assault
    EHIPhalanxChanceTracker.super.post_init(self, params)
end

---@param dt number
function EHIPhalanxChanceTracker:update(dt)
    EHIPhalanxChanceTracker.super.update(self, dt)
    self._assault_t = self._assault_t - dt
    if self._assault_t <= 0 and not self._color_lock then
        self._color_lock = true
        if not self._endless_assault then
            self._chance_increase_enabled = false
            self:SetTextColor(self._paused_color, self._chance_text)
        end
    end
end

---@param from_create boolean?
function EHIPhalanxChanceTracker:ComputeAssaultTime(from_create)
    if self.IsHost then
        local sustain_t = self._parent_class:GetInternalData("assault", "sustain_t")
        if from_create and sustain_t then
            local sustain_app_t = self._parent_class:GetInternalData("assault", "sustain_app_t")
            local current_app_t = managers.game_play_central:get_heist_timer()
            local t = current_app_t - sustain_app_t
            self._assault_t = sustain_t - t
        else
            self._assault_t = 45 -- Will get accurate in `EHIPhalanxChanceTracker:OnEnterSustain()`
        end
    else
        self._assault_t = 35 + 180
    end
end

function EHIPhalanxChanceTracker:AssaultStart()
    if self._increase_chance_at_next_assault then
        self:SetTimeNoAnim(self._t_refresh)
        if not self._first_assault then
            self:IncreaseChance(self._chance_increase)
        end
        self._increase_chance_at_next_assault = nil
    end
    self._chance_increase_enabled = true
    self._color_lock = false
    self:SetTextColor(Color.white, self._chance_text)
    self:ComputeAssaultTime()
    self._first_assault = nil
end

function EHIPhalanxChanceTracker:AssaultEnd()
    self._chance_increase_enabled = false
end

---@param state boolean
function EHIPhalanxChanceTracker:SetEndlessAssault(state)
    self._endless_assault = state
end

---@param t number
function EHIPhalanxChanceTracker:OnEnterSustain(t)
    self._assault_t = t
end

function EHIPhalanxChanceTracker:Refresh()
    self:SetTimeNoAnim(self._t_refresh)
    if self._chance_increase_enabled then
        self:IncreaseChance(self._chance_increase)
    else
        self._increase_chance_at_next_assault = true
    end
end