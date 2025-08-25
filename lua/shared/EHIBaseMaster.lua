---@class EHIBaseMaster
---@field new fun(self: self, params: EHITracker.params): self
EHIBaseMaster = class()
EHIBaseMaster._id = ""
EHIBaseMaster._SHOW_TRACKERS = EHI:GetOption("show_trackers") --[[@as boolean]]
EHIBaseMaster._SHOW_WAYPOINTS = EHI:GetOption("show_waypoints") --[[@as boolean]]
---@param params EHITracker.params
function EHIBaseMaster:init(params)
    self._tracking = params.tracking --[[@as EHITrackingManager]]
end

---@param dt number
function EHIBaseMaster:update(dt)
end

function EHIBaseMaster:AddToUpdate()
    if self._SHOW_TRACKERS then
        self._tracking._trackers:_add_tracker_to_update(self) ---@diagnostic disable-line
    elseif self._SHOW_WAYPOINTS then
        self._tracking._waypoints:_add_waypoint_to_update(self) ---@diagnostic disable-line
    end
end

function EHIBaseMaster:RemoveFromUpdate()
    if self._SHOW_TRACKERS then
        self._tracking._trackers:_remove_tracker_from_update(self._id)
    elseif self._SHOW_WAYPOINTS then
        self._tracking._waypoints:_remove_waypoint_from_update(self._id)
    end
end