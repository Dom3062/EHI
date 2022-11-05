local lerp = math.lerp
local Color = Color
local IsOverkillOrBelow = EHI:IsDifficultyOrBelow(EHI.Difficulties.OVERKILL)
local Control = Color.white
local Anticipation = Color(255, 186, 204, 28) / 255
if BAI then
    Control = BAI:GetColor("control")
    Anticipation = BAI:GetColor("anticipation")
    BAI:AddEvent(BAI.EventList.Update, function()
        Control = BAI:GetColor("control")
        Anticipation = BAI:GetColor("anticipation")
        EHIAssaultDelayTracker._forced_icons[1].color = Control
    end)
end
local level_id = Global.game_settings and Global.game_settings.level_id or "branchbank"
local level_data = tweak_data.levels[level_id]
local ai_group = level_data and level_data.group_ai_state or "besiege"
local tweak_values = tweak_data.group_ai[ai_group].assault.delay
EHIAssaultDelayTracker = class(EHIWarningTracker)
EHIAssaultDelayTracker._forced_icons = { { icon = "assaultbox", color = Control } }
EHIAssaultDelayTracker.AnimateNegative = EHITimerTracker.AnimateCompletion
EHIAssaultDelayTracker.IsClient = EHI:IsClient()
function EHIAssaultDelayTracker:init(panel, params)
    if params.compute_time then
        params.time = self:CalculateBreakTime(params.diff) + (2 * math.random())
    end
    EHIAssaultDelayTracker.super.init(self, panel, params)
    self._update = not params.stop_counting
    self.update_normal = self.update
    self:CheckIfHostageIsPresent()
end

function EHIAssaultDelayTracker:update_negative(t, dt)
    self._time = self._time + dt
    self._text:set_text("+" .. self:Format())
end

function EHIAssaultDelayTracker:SyncAnticipationColor()
    self._text:stop()
    self:SetTextColor(Color.white)
    self:SetIconColor(Anticipation)
    self._time_warning = nil
    self.update = self.update_normal
    self._hostage_delay_disabled = true
end

function EHIAssaultDelayTracker:SyncAnticipation(t)
    self._time = t - (2 * math.random())
    self:SyncAnticipationColor()
end

function EHIAssaultDelayTracker:CheckIfHostageIsPresent()
    local group_ai = managers.groupai:state()
    if not group_ai._hostage_headcount or group_ai._hostage_headcount == 0 then
        return
    end
    self:UpdateTime(IsOverkillOrBelow and 30 or 10)
    self._hostages_found = true
end

function EHIAssaultDelayTracker:CalculateBreakTime(diff)
    local ramp = tweak_data.group_ai.difficulty_curve_points
    local i = 1
    while (ramp[i] or 1) < diff do
        i = i + 1
    end
    local difficulty_point_index = i
    local difficulty_ramp = (diff - (ramp[i - 1] or 0)) / ((ramp[i] or 1) - (ramp[i - 1] or 0))
    local base_delay = lerp(tweak_values[difficulty_point_index], tweak_values[difficulty_point_index + 1], difficulty_ramp)
    return base_delay + 30
end

function EHIAssaultDelayTracker:SetHostages(has_hostages)
    if self._hostage_delay_disabled then
        return
    end
    if has_hostages and not self._hostages_found then
        self._hostages_found = true
        self:UpdateTime(IsOverkillOrBelow and 30 or 10)
    elseif self._hostages_found and not has_hostages then
        self._hostages_found = false
        self:UpdateTime(IsOverkillOrBelow and -30 or -10)
    end
end

function EHIAssaultDelayTracker:UpdateTime(t)
    self._time = self._time + t
    if not self._update then
        self._text:set_text(self:Format())
    end
end

function EHIAssaultDelayTracker:StartAnticipation(t)
    self._hostage_delay_disabled = true
    self._time = t
    if not self._update then
        self:AddTrackerToUpdate()
    end
end

function EHIAssaultDelayTracker:UpdateDiff(diff)
    if self._hostage_delay_disabled then
        return
    end
    if diff > 0 then
        self._time = self:CalculateBreakTime(diff)
        self:AddTrackerToUpdate()
    else
        self:RemoveTrackerFromUpdate()
        self._text:stop()
        self:SetTextColor(Color.white)
    end
end

function EHIAssaultDelayTracker:delete()
    if self._time <= 0 then
        self.update = self.update_negative
        self._time = -self._time
        self._text:stop()
        self:SetTextColor(Color.white)
        self:AnimateNegative()
        return
    end
    EHIAssaultDelayTracker.super.delete(self)
end