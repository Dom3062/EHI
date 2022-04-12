local IsOverkillOrBelow = EHI:IsDifficultyOrBelow("overkill")
local Control = Color.white
local Anticipation = Color(255, 186, 204, 28) / 255
if BAI then
    Control = BAI:GetColor("control")
    Anticipation = BAI:GetColor("anticipation")
end
local level_id = Global.game_settings.level_id
local level_data = tweak_data.levels[level_id]
local ai_group = level_data and level_data.group_ai_state or "besiege"
local tweak_values = tweak_data.group_ai[ai_group].assault.delay
local anticipation_values = tweak_data.group_ai[ai_group].assault.hostage_hesitation_delay
EHIAssaultDelayTracker = EHIAssaultDelayTracker or class(EHIWarningTracker)
EHIAssaultDelayTracker.IsClient = EHI._cache.Client
function EHIAssaultDelayTracker:init(panel, params)
    params.icons = { { icon = "assaultbox", color = Control } }
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

function EHIAssaultDelayTracker:AnimateNegative()
    self._text:animate(function(o)
        while true do
            local t = 0
            while t < 1 do
                t = t + coroutine.yield()
                local n = 1 - math.sin(t * 180)
                --local r = math.lerp(1, 0, n)
                local g = math.lerp(1, 0, n)
                o:set_color(Color(g, 1, g))
            end
        end
    end)
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
    local base_delay = math.lerp(tweak_values[difficulty_point_index], tweak_values[difficulty_point_index + 1], difficulty_ramp)
    local anticipation_delay = math.lerp(anticipation_values[difficulty_point_index], anticipation_values[difficulty_point_index + 1], difficulty_ramp)
    return base_delay + anticipation_delay
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