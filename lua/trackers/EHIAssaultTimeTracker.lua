local EHI = EHI
local lerp = math.lerp
local Color = Color
local Captain = Color(255, 255, 128, 0) / 255
local Build = Color.yellow
local Sustain = Color(255, 237, 127, 127) / 255
local Fade = Color(255, 0, 255, 255) / 255
local State =
{
    build = 1,
    sustain = 2,
    fade = 3,
    endless = 4
}
local assault_values = tweak_data.group_ai[tweak_data.levels:GetGroupAIState()].assault
---@class EHIAssaultTimeTracker : EHIWarningTracker
---@field super EHIWarningTracker
---@field _cs_assault_extender boolean
---@field _cs_max_hostages number
---@field _cs_duration number
---@field _cs_deduction number
EHIAssaultTimeTracker = class(EHIWarningTracker)
EHIAssaultTimeTracker._forced_icons = { { icon = "assaultbox", color = Build } }
EHIAssaultTimeTracker._forced_hint_text = "assault_time"
EHIAssaultTimeTracker._is_client = EHI:IsClient()
EHIAssaultTimeTracker._paused_color = EHIPausableTracker._paused_color
EHIAssaultTimeTracker._show_completion_color = true
---@param panel Panel
---@param params EHITracker.params
---@param parent_class EHITrackerManager
function EHIAssaultTimeTracker:init(panel, params, parent_class)
    self._refresh_on_delete = true
    self:CalculateDifficultyRamp(params.diff)
    params.time = self:CalculateAssaultTime()
    EHIAssaultTimeTracker.super.init(self, panel, params, parent_class)
    self.update_normal = self.update
    self._state = State.build
    if self._cs_assault_extender then
        self:SetHook()
        self.update = self.update_cs
    end
end

---@param dt number
function EHIAssaultTimeTracker:update(dt)
    EHIAssaultTimeTracker.super.update(self, dt)
    if self._to_sustain_t then
        self._to_sustain_t = self._to_sustain_t - dt
        if self._to_sustain_t <= 0 then
            self:SetState(State.sustain)
            if self._recalculate_on_sustain then
                self:RecalculateAssaultTime(self._new_diff)
                self._new_diff = nil
                self._recalculate_on_sustain = nil
            end
            self._to_sustain_t = nil
        end
    end
    if self._to_fade_t then
        self._to_fade_t = self._to_fade_t - dt
        if self._to_fade_t <= 0 then
            self._to_fade_t = nil
            self:SetState(State.fade)
        end
    end
end

---@param dt number
function EHIAssaultTimeTracker:update_cs(dt)
    EHIAssaultTimeTracker.super.update(self, dt)
    self._assault_t = self._assault_t - dt
    if self._to_sustain_t then
        self._to_sustain_t = self._to_sustain_t - dt
        if self._to_sustain_t <= 0 then
            self:SetState(State.sustain)
            if self._recalculate_on_sustain then
                self:RecalculateAssaultTime(self._new_diff)
                self._new_diff = nil
                self._recalculate_on_sustain = nil
            end
            self._to_sustain_t = nil
        end
    end
    if self._to_fade_t then
        self._to_fade_t = self._to_fade_t - dt
        if self._to_fade_t <= 0 then
            self._to_fade_t = nil
            self:SetState(State.fade)
        end
    end
end

---@param dt number
function EHIAssaultTimeTracker:update_negative(dt)
    self._time = self._time + dt
    self._text:set_text("+" .. self:Format())
end

---@param diff number
function EHIAssaultTimeTracker:CalculateDifficultyRamp(diff)
    local ramp = tweak_data.group_ai.difficulty_curve_points
    local i = 1
    while (ramp[i] or 1) < diff do
        i = i + 1
    end
    self._difficulty_point_index = i
    self._difficulty_ramp = (diff - (ramp[i - 1] or 0)) / ((ramp[i] or 1) - (ramp[i - 1] or 0))
    self._diff = diff
end

function EHIAssaultTimeTracker:CalculateDifficultyDependentValue(values)
    return lerp(values[self._difficulty_point_index], values[self._difficulty_point_index + 1], self._difficulty_ramp)
end

---@return number
function EHIAssaultTimeTracker:CalculateAssaultTime()
    local build = assault_values.build_duration
    local sustain = lerp(self:CalculateDifficultyDependentValue(assault_values.sustain_duration_min), self:CalculateDifficultyDependentValue(assault_values.sustain_duration_max), math.random()) * managers.groupai:state():_get_balancing_multiplier(assault_values.sustain_duration_balance_mul)
    local fade = assault_values.fade_duration
    if self._is_client then
        self._to_sustain_t = build
    end
    self._assault_t = build + sustain
    self._sustain_original_t = sustain
    if self._cs_assault_extender then
        sustain = self:CalculateCSSustainTime(sustain)
    end
    self._to_fade_t = build + sustain
    return build + sustain + fade
end

---@param diff number
function EHIAssaultTimeTracker:RecalculateAssaultTime(diff)
    self:CalculateDifficultyRamp(diff)
    local t = self:CalculateAssaultTime()
    local build = assault_values.build_duration
    local fade = assault_values.fade_duration
    self._assault_t = t - build - fade
    self._to_fade_t = t - build - fade
    self._time = t - build
end

---@param sustain number
---@param n_of_hostages number?
function EHIAssaultTimeTracker:CalculateCSSustainTime(sustain, n_of_hostages)
    n_of_hostages = n_of_hostages or managers.groupai:state():hostage_count()
    local n_of_jokers = managers.groupai:state():get_amount_enemies_converted_to_criminals()
    local n = math.min(n_of_hostages + n_of_jokers, self._cs_max_hostages)
    local new_sustain = sustain + self._sustain_original_t * (self._cs_duration - (self._cs_deduction * n))
    return new_sustain
end

function EHIAssaultTimeTracker:OnMinionCountChanged()
    if self._state ~= State.fade then
        self:UpdateSustainTime(self:CalculateCSSustainTime(self._assault_t))
    end
end

function EHIAssaultTimeTracker:UpdateSustainTime(new_sustain)
    if new_sustain ~= self._time then
        local time_diff = new_sustain - self._time
        self._to_fade_t = self._to_fade_t + time_diff
        self._time = self._time + time_diff
    end
end

function EHIAssaultTimeTracker:SetHook()
    EHI:HookWithID(HUDManager, "set_control_info", "EHI_AssaultTime_set_control_info", function(hud, data)
        if self._state ~= State.fade then
            self:UpdateSustainTime(self:CalculateCSSustainTime(self._assault_t, data.nr_hostages))
        end
    end)
end

function EHIAssaultTimeTracker:SetTime(t)
end

function EHIAssaultTimeTracker:UpdateDiff(diff)
    if self._is_client and self._state == State.build and self._diff ~= diff then
        self._recalculate_on_sustain = true
        self._new_diff = diff
    end
end

---@param t number
---@param sustain_t number?
---@param already_extended boolean?
function EHIAssaultTimeTracker:OnEnterSustain(t, sustain_t, already_extended)
    if self._captain_arrived or self._state ~= State.build or self._endless_assault then
        return
    end
    sustain_t = sustain_t or t
    self._to_fade_t = sustain_t
    self._assault_t = sustain_t
    self._sustain_original_t = t
    self._time = sustain_t + assault_values.fade_duration
    self:SetState(State.sustain)
    if self._cs_assault_extender and not already_extended then
        self:UpdateSustainTime(self:CalculateCSSustainTime(self._assault_t))
    end
    if self.update == self.update_negative then
        self.update = self.update_normal
    end
end

---@param text_color Color?
function EHIAssaultTimeTracker:StopTextAnim(text_color)
    self._text:stop()
    self:SetTextColor(text_color or Color.white)
end

---@param state number
function EHIAssaultTimeTracker:SetState(state)
    if self._state == state then
        return
    end
    self._state = state
    if state == State.build then
        self:SetIconColor(Build)
    elseif state == State.sustain then
        self:SetIconColor(Sustain)
    elseif state == State.fade then
        self:SetIconColor(Fade)
    else
        self:SetIconColor(Color.red)
    end
end

function EHIAssaultTimeTracker:CaptainArrived()
    self._captain_arrived = true
    self:RemoveTrackerFromUpdate()
    if self._endless_assault then
        self:SetAndFitTheText()
        self:SetTextColor(self._paused_color)
    else
        self:StopTextAnim(self._paused_color)
    end
    self:SetIconColor(Captain)
    self._time_warning = false
end

function EHIAssaultTimeTracker:CaptainDefeated()
    self:PoliceActivityBlocked()
end

---@param state boolean?
function EHIAssaultTimeTracker:SetEndlessAssault(state)
    if self._endless_assault == state then
        return
    end
    self._endless_assault = state
    if state then
        self:RemoveTrackerFromUpdate()
        self._time_warning = false
        self:StopTextAnim(Color.red)
        self:SetState(State.endless)
        self:SetStatusText("endless")
        self:AnimateBG()
    elseif not self._is_client then
        local ai_state = managers.groupai:state()
        local assault_data = ai_state._task_data.assault or {}
        local current_state = assault_data.phase
        if current_state then
            if current_state == "build" then
                local t_correction = assault_values.build_duration - (assault_data.phase_end_t - ai_state._t)
                self._time = self:CalculateAssaultTime() - t_correction
                self._assault_t = self._assault_t - t_correction
                self._to_fade_t = self._to_fade_t - t_correction
                self:SetAndFitTheText()
                self:SetTextColor()
                self:SetState(State.build)
                self:AddTrackerToUpdate()
                self:AnimateBG()
            elseif current_state == "sustain" then
                local end_t = ai_state.assault_phase_end_time and ai_state:assault_phase_end_time()
                if end_t then -- Already takes into account Crime Spree
                    local t = ai_state._t
                    self:SetTextColor()
                    self:OnEnterSustain(assault_data.phase_end_t - t, end_t - t, true)
                    self:SetAndFitTheText()
                    self._check_anim_progress = self._time <= 10
                    self:AddTrackerToUpdate()
                    self:AnimateBG()
                else
                    self:PoliceActivityBlocked() -- Current phase does not have end time, refresh at the next Build state
                end
            else
                self:PoliceActivityBlocked() -- Current phase is not an assault phase or Fade, refresh at the next Build state
            end
        else
            self:PoliceActivityBlocked() -- Current phase does not exist for some reason, refresh at the next Build state
        end
    else
        self:PoliceActivityBlocked() -- Refresh at the next Build state
    end
end

function EHIAssaultTimeTracker:PoliceActivityBlocked()
    self._refresh_on_delete = nil
    self:delete()
end

function EHIAssaultTimeTracker:Refresh()
    self.update = self.update_negative
    self._time = -self._time
end

--- The tracker `NEEDS TO BE DELETED` via `EHITrackerManager:ForceRemoveTracker()`!
function EHIAssaultTimeTracker:delete()
    if self._refresh_on_delete then
        self:Refresh()
    else
        EHI:Unhook("AssaultTime_set_control_info")
        EHIAssaultTimeTracker.super.delete(self)
    end
end