---@class EHIMissionElementWaypoint
local EHIMissionElementWaypoint = {}
EHIMissionElementWaypoint._options =
{
    mission = EHI:GetWaypointOption("show_waypoints_mission"),
    timer = EHI:GetWaypointOption("show_waypoints_timers")
}
EHIMissionElementWaypoint._elements = {} ---@type table<number, ElementWaypoint?>
EHIMissionElementWaypoint._ignore = {} ---@type table<number, boolean>
function EHIMissionElementWaypoint:GameInit()
    for id, _ in pairs(self._disable_on_load or {}) do
        self:DisableElementWaypoint(id)
    end
end

function EHIMissionElementWaypoint:GameInitClient()
    self:DisableTimerWaypoints(self._disable_on_load)
    self:GameInit()
    self._disable_on_load = nil
end

---@param waypoints table<number, boolean>
function EHIMissionElementWaypoint:CacheDisabledWaypoints(waypoints)
    if self._disable_on_load then
        for id, _ in pairs(waypoints) do
            self._disable_on_load[id] = true
        end
    else
        self._disable_on_load = waypoints
    end
    for id, _ in pairs(waypoints) do
        self._ignore[id] = true
    end
end

---@param waypoints table<number, boolean>?
function EHIMissionElementWaypoint:DisableTimerWaypoints(waypoints)
    if not self._options.timer or waypoints == nil then
        return
    end
    self:CacheDisabledWaypoints(waypoints)
end

---@param waypoints table<number, boolean>?
function EHIMissionElementWaypoint:DisableMissionWaypoints(waypoints)
    if not self._options.mission or waypoints == nil then
        return
    end
    self:CacheDisabledWaypoints(waypoints)
end

---@param id number
function EHIMissionElementWaypoint:DisableElementWaypoint(id)
    local element = managers.mission:get_element_by_id(id) ---@cast element ElementWaypoint?
    if not element or self._elements[id] then
        return
    elseif not element.ehi_on_executed then
        EHI:Log(string.format("Provided id %s is not an ElementWaypoint!", tostring(id)))
        return
    end
    element.on_executed = element.ehi_on_executed
    self._elements[id] = element
end

---@param id number
function EHIMissionElementWaypoint:RestoreElementWaypoint(id)
    local element = table.remove_key(self._elements, id)
    if element then
        element.on_executed = element.original_on_executed
    end
end

return EHIMissionElementWaypoint