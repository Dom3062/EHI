local Color = Color
---@class EHIWarningWaypoint : EHIWaypoint
---@field super EHIWaypoint
EHIWarningWaypoint = class(EHIWaypoint)
EHIWarningWaypoint._check_anim_progress = false
EHIWarningWaypoint._warning_color = EHI:GetColorFromOption("tracker_waypoint", "warning")
---@param o PanelText
---@param old_color Color
---@param color Color
---@param icon PanelBitmap
---@param arrow PanelBitmap
---@param bitmap_world PanelBitmap?
---@param start_t number
EHIWarningWaypoint._anim_warning = function(o, old_color, color, icon, arrow, bitmap_world, start_t)
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
            icon:set_color(c)
            arrow:set_color(c)
            if bitmap_world then
                bitmap_world:set_color(c)
            end
        end
        t = 1
    end
end

function EHIWarningWaypoint:update(dt)
    EHIWarningWaypoint.super.update(self, dt)
    if self._time <= 10 and not self._anim_started then
        self:AnimateColor(self._check_anim_progress)
        self._anim_started = true
    end
end

---@param check_progress boolean?
---@param color Color?
---@param default_color Color?
function EHIWarningWaypoint:AnimateColor(check_progress, color, default_color)
    if self._gui and alive(self._gui) then
        local start_t = check_progress and (1 - math.min(math.ehi_round(self._time, 0.1) - math.floor(self._time), 0.99)) or 1
        self._gui:animate(self._anim_warning, default_color or self._default_color, color or self._warning_color, self._bitmap, self._arrow, self._bitmap_world, start_t)
    end
end

function EHIWarningWaypoint:SetTime(t)
    self._anim_started = false
    self._gui:stop()
    self._check_anim_progress = t <= 10
    EHIWarningWaypoint.super.SetTime(self, t)
end