local Color = Color
---@class EHIWarningTracker : EHITracker
---@field super EHITracker
EHIWarningTracker = class(EHITracker)
EHIWarningTracker._warning_color = EHI:GetColorFromOption("tracker_waypoint", "warning")
EHIWarningTracker._completion_color = EHI:GetColorFromOption("tracker_waypoint", "completion")
EHIWarningTracker._check_anim_progress = false
EHIWarningTracker._show_completion_color = false
---@param o Text
---@param old_color Color
---@param color Color
---@param start_t number
---@param class EHIWarningTracker
EHIWarningTracker._anim_warning = function(o, old_color, color, start_t, class)
    local c = Color(old_color.r, old_color.g, old_color.b)
    local t = start_t
    while true do
        while t > 0 do
            t = t - coroutine.yield()
            local n = math.sin(t * 180)
            c.r = math.lerp(old_color.r, color.r, n)
            c.g = math.lerp(old_color.g, color.g, n)
            c.b = math.lerp(old_color.b, color.b, n)
            o:set_color(c)
        end
        t = 1
    end
end

function EHIWarningTracker:update(dt)
    EHIWarningTracker.super.update(self, dt)
    if self._time <= 10 and not self._time_warning then
        self._time_warning = true
        self:AnimateColor(self._check_anim_progress)
    end
end

---@param check_progress boolean?
---@param color Color?
---@param text_color Color?
function EHIWarningTracker:AnimateColor(check_progress, color, text_color)
    if self._text and alive(self._text) then
        local start_t = check_progress and (1 - math.min(math.ehi_round(self._time, 0.1) - math.floor(self._time), 0.99)) or 1
        self._text:animate(self._anim_warning, text_color or self._text_color, color or (self._show_completion_color and self._completion_color or self._warning_color), start_t, self)
    end
end

---@param time number
function EHIWarningTracker:SetTimeNoAnim(time)
    self._time_warning = false
    self._text:stop()
    self._check_anim_progress = time <= 10
    EHIWarningTracker.super.SetTimeNoAnim(self, time)
end