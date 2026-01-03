---@class EHIMissionElementOverride
local EHIMissionElementOverride = {}
EHIMissionElementOverride._elements = {} ---@type table<number, { on_executed: fun(self: MissionScriptElement, ...), operation_remove: fun(self: MissionScriptElement), waypoint_id: string }>
EHIMissionElementOverride._overrides = {} ---@type table<number, boolean>
EHIMissionElementOverride._waypoint_override_cache = {} ---@type table<string, number>
function EHIMissionElementOverride:OverrideElements()
    local scripts = managers.mission._scripts or {}
    for id, tbl_f in pairs(self._elements) do
        if math.within(id, 100000, 999999) then
            for _, script in pairs(scripts) do
                local element = script:element(id) --[[@as ElementWaypoint?]]
                if element then
                    element.__ehi_original_on_executed = element.on_executed
                    element.on_executed = tbl_f.on_executed
                    managers.ehi_hook:PrehookElement(element, tbl_f.operation_remove, "operation_remove")
                    self._elements[id] = nil
                    self._overrides[id] = true
                    self._waypoint_override_cache[tbl_f.waypoint_id] = nil
                    --[[
                        On client, the element may not be found in the first check
                        This is because the element is from an instance that is mission placed
                        Mission Placed instances are preloaded and all elements are not cached until
                        ElementInstancePoint is called
                        These instances are synced when you join
                        Delay the hook until the sync is complete (see: EHI.Trigger:SyncLoad())
                    ]]
                end
            end
        end
    end
end

---@param id number
---@param on_executed fun(element: MissionScriptElement, ...)
---@param operation_remove fun(element: MissionScriptElement)
---@param waypoint_id string?
function EHIMissionElementOverride:AddElementToOverride(id, on_executed, operation_remove, waypoint_id)
    if self._elements[id] or self._overrides[id] then
        EHI:Log("Element Override already exists! ID: " .. tostring(id))
        return
    end
    self._elements[id] = { on_executed = on_executed, operation_remove = operation_remove, waypoint_id = waypoint_id or "" }
end

---@param id number
---@param waypoint_id string
function EHIMissionElementOverride:AddWaypointToOverride(id, waypoint_id)
    if self._waypoint_override_cache[waypoint_id] then
        local cache = self._elements[self._waypoint_override_cache[waypoint_id] or 0]
        if cache then -- Reuse already created function for the same waypoint if it exists
            self:AddElementToOverride(id, cache.on_executed, cache.operation_remove)
            return
        end
    end
    ---@param element ElementWaypoint
    ---@param instigator UnitPlayer
    local function on_executed(element, instigator, ...)
        if not element._values.enabled then
            return
        elseif element._values.only_on_instigator and instigator ~= managers.player:player_unit() then
            ElementWaypoint.super.on_executed(element, instigator, ...)
            return
        elseif not element._values.only_in_civilian or managers.player:current_state() == "civilian" then
            local text = managers.localization:text(element._values.text_id)
            if managers.ehi_waypoint:WaypointExists(waypoint_id) then
                managers.hud:AddWaypointSoft(element._id, {
                    distance = true,
                    state = "sneak_present",
                    present_timer = 0,
                    text = text,
                    icon = element._values.icon,
                    position = element._values.position
                })
                managers.ehi_waypoint:CallFunction(waypoint_id, "CreateWaypoint", element._id, element._values.icon, element._values.position)
            else
                managers.hud:add_waypoint(element._id, {
                    distance = true,
                    state = "sneak_present",
                    present_timer = 0,
                    text = text,
                    icon = element._values.icon,
                    position = element._values.position
                })
            end
        elseif managers.hud:get_waypoint_data(element._id) then
            managers.hud:remove_waypoint(element._id)
        end
        ElementWaypoint.super.on_executed(element, instigator, ...)
    end
    ---@param element ElementWaypoint
    local function operation_remove(element)
        managers.ehi_waypoint:CallFunction(waypoint_id, "RemoveWaypoint")
    end
    self:AddElementToOverride(id, on_executed, operation_remove, waypoint_id)
    self._waypoint_override_cache[waypoint_id] = id
end

return EHIMissionElementOverride