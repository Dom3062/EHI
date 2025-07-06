---@class EHIPhalanxChanceTracker : EHITimedChanceTracker
---@field super EHITimedChanceTracker
EHIPhalanxChanceTracker = class(EHITimedChanceTracker)
EHIPhalanxChanceTracker._forced_icons = { "buff_shield" }
EHIPhalanxChanceTracker._paused_color = EHIPausableTracker._paused_color
EHIPhalanxChanceTracker._forced_hint_text = "phalanx_chance"
EHIPhalanxChanceTracker._sync_fade_state = "EHI_EHIPhalanxChanceTracker_sync_fade_state"
EHIPhalanxChanceTracker.IsHost = EHI.IsHost
function EHIPhalanxChanceTracker:pre_init(params)
    if params.first_assault then
        self:SetFirstAssault(params)
    end
    params.start_opened = not self._first_assault
    EHIPhalanxChanceTracker.super.pre_init(self, params)
end

function EHIPhalanxChanceTracker:post_init(params)
    if not self._first_assault then
        if managers.ehi_assault._internal.is_assault then
            if self.IsHost then
                local ai_state = managers.groupai:state()
                if ai_state._task_data and ai_state._task_data.assault and ai_state._task_data.assault.phase == "fade" then -- Captain got activated during Fade state, pretend it is the first assault
                    self:SetFirstAssault(params)
                    params.start_opened = false
                end
            end -- Not possible to check data on client...
        else -- Captain got activated during Control/Anticipation state, pretend it is the first assault
            self:SetFirstAssault(params)
            params.start_opened = false
        end
    end
    EHIPhalanxChanceTracker.super.post_init(self, params)
    self._t_refresh = params.time
    self._chance_increase = params.chance_increase
    if params.assault_extender then
        self.update = EHIPhalanxChanceTracker.super.update
        self._assault_time_blocked = true
        if self.IsHost then
            self._assault_state = ""
            Hooks:PostHook(GroupAIStateBesiege, "_upd_assault_task", "EHI_EHIPhalanxChanceTracker_upd_assault_task", function(state, ...)
                local phase = state._task_data.assault.phase
                if phase and phase ~= "anticipation" and self._assault_state ~= phase then
                    if phase == "fade" then
                        self._color_lock = true
                        self._chance_increase_enabled = false
                        self:SetTextColor(self._paused_color, self._chance_text)
                        managers.ehi_sync:SyncData(self._sync_fade_state, "true")
                    end
                    self._assault_state = phase
                end
            end)
            local state = managers.groupai:state()
            local phase = state and state._task_data.assault and state._task_data.assault.phase
            if not phase or phase == "fade" then
                self:SetTextColor(self._paused_color, self._chance_text)
            end
        else
            managers.ehi_sync:AddReceiveHook(self._sync_fade_state, function(data, sender)
                self._color_lock = true
                self._chance_increase_enabled = false
                self:SetTextColor(self._paused_color, self._chance_text)
            end)
        end
    elseif managers.ehi_assault._internal.is_assault then
        self:ComputeAssaultTime(true)
    else
        self._assault_t = 0
    end
end

---@param params EHITracker.params
function EHIPhalanxChanceTracker:SetFirstAssault(params)
    self._first_assault = true
    self._captain_start_chance = params.chance or 0
    params.chance = 0
end

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
    if self._assault_time_blocked then
        return
    elseif self.IsHost then
        local sustain_t = managers.ehi_assault._internal.sustain_t
        if from_create and sustain_t then
            local sustain_app_t = managers.ehi_assault._internal.sustain_app_t
            local current_app_t = managers.game_play_central:get_heist_timer()
            local t = current_app_t - sustain_app_t
            self._assault_t = sustain_t - t
        else
            self._assault_t = 45 -- Will get accurate in `EHIPhalanxChanceTracker:OnEnterSustain()`
        end
    else
        self._assault_t = 35 + 180 -- Will get accurate in `EHIPhalanxChanceTracker:OnEnterSustain()` (synced from EHI Host)
    end
end

function EHIPhalanxChanceTracker:AssaultStart()
    if self._first_assault then
        self:StartTimer(self._t_refresh)
        self:SetChance(self._captain_start_chance or 0)
        self._captain_start_chance = nil
        self._increase_chance_at_next_assault = nil
        self._first_assault = nil
    elseif self._increase_chance_at_next_assault then
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
end

function EHIPhalanxChanceTracker:AssaultEnd()
    self._chance_increase_enabled = false
end

---@param state boolean
function EHIPhalanxChanceTracker:SetEndlessAssault(state)
    self._endless_assault = state
    if self._increase_chance_at_next_assault then
        self:SetTimeNoAnim(self._t_refresh)
        if not self._first_assault then
            self:IncreaseChance(self._chance_increase)
        end
        self._increase_chance_at_next_assault = nil
    end
    if self._color_lock then
        self._chance_increase_enabled = true
        self:SetTextColor(Color.white, self._chance_text)
    end
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

function EHIPhalanxChanceTracker:pre_destroy()
    Hooks:RemovePostHook("EHI_EHIPhalanxChanceTracker_upd_assault_task")
    managers.ehi_sync:RemoveReceiveHook(self._sync_fade_state)
end