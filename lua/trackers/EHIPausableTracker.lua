---@class EHIPausableTracker : EHITracker
---@field super EHITracker
EHIPausableTracker = class(EHITracker)
EHIPausableTracker._paused_color = EHI:GetColorFromOption("tracker_waypoint", "pause")
function EHIPausableTracker:post_init(params)
    self._needs_update = not params.paused
    self:_set_pause(not self._needs_update)
end

---@param pause boolean
function EHIPausableTracker:SetPause(pause)
    self:_set_pause(pause)
    if pause then
        self:RemoveTrackerFromUpdate()
    else
        self:AddTrackerToUpdate()
    end
end

---@param pause boolean
function EHIPausableTracker:_set_pause(pause)
    self._paused = pause
    self:SetTextColor()
end

function EHIPausableTracker:SetTextColor(color)
    self._text:set_color(self._paused and self._paused_color or (color or self._text_color))
end