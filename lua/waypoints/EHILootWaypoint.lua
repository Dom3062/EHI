---@class EHILootWaypoint : EHIWaypoint
---@field super EHIWaypoint
EHILootWaypoint = class(EHIWaypoint)
EHILootWaypoint.update = EHILootWaypoint.update_fade
EHILootWaypoint._needs_update = false
function EHILootWaypoint:init(waypoint, params, parent_class)
    self._id = params.id --[[@as string]]
    self._parent_class = parent_class
    if params.max_xp_bags > 0 then
        self._forced_color = Color.yellow
    elseif params.max == 0 and params.max_random > 0 then
        self._forced_color = Color.green
    end
end

---@param present_timer number|table<number, number?>
function EHILootWaypoint:SetPresentTimerForWaypoints(present_timer)
    if type(present_timer) == "number" then
        self._present_timer = present_timer
    else
        self._present_timers = deep_clone(present_timer)
    end
end

---@param color Color?
function EHILootWaypoint:SetColor(color)
    if self._waypoints then
        local c = color or self._forced_color or self._default_color
        for _, waypoint in pairs(self._waypoints) do
            for _, object in pairs(waypoint) do
                object:set_color(c)
            end
        end
    end
end

---@param id number
---@param icon string
---@param position Vector3
function EHILootWaypoint:CreateWaypoint(id, icon, position)
    local waypoint = self._parent_class:_create_waypoint(id, icon, position, self._present_timers and self._present_timers[id] or self._present_timer)
    if waypoint then
        local data = {}
        data.gui = waypoint.timer_gui
        data.bitmap = waypoint.bitmap
        data.arrow = waypoint.arrow
        data.bitmap_world = waypoint.bitmap_world
        data.gui:set_text(self._text or "")
        if self._forced_color then
            for _, object in pairs(data) do
                object:set_color(self._forced_color)
            end
        end
        self._waypoints = self._waypoints or {} ---@type table<number, { gui: PanelText, bitmap: PanelBitmap, arrow: PanelBitmap, bitmap_world: PanelBitmap }>
        self._waypoints[id] = data
    end
end

---@param id number
function EHILootWaypoint:RemoveWaypoint(id)
    if self._removal_disabled then
        return
    end
    local wp = table.remove_key(self._waypoints or {}, id)
    if wp then
        self._parent_class._hud:remove_waypoint(id)
    end
end

---@param id number
function EHILootWaypoint:ReplaceWaypoint(id)
    local wp = table.remove_key(self._waypoints or {}, id)
    if wp then
        if self._parent_class._waypoints_to_update[self._id] then -- If the Waypoint is in the point to be deleted (players secured all possible loot bags), just color them to default color again to restore them)
            for _, object in pairs(wp) do
                object:set_color(EHILootWaypoint.super._default_color)
            end
        end
    end
end

---@param text string
function EHILootWaypoint:SetText(text, silent_update)
    self._text = text
    for _, wp in pairs(self._waypoints or {}) do
        wp.gui:set_text(text)
    end
end

---@param random_loot_present boolean
function EHILootWaypoint:SetCompleted(random_loot_present)
    self:SetColor(Color.green)
    if not random_loot_present then
        self:AddWaypointToUpdate()
    end
end

function EHILootWaypoint:MaxNoLongerLimited()
    self._forced_color = nil
    self:SetColor()
end

function EHILootWaypoint:DisableWaypointRemoval()
    self._removal_disabled = true
end

function EHILootWaypoint:delete()
    while next(self._waypoints or {}) do
        local id, _ = next(self._waypoints) ---@cast id -?
        managers.ehi_loot:_restore_waypoint(id)
        self._waypoints[id] = nil
    end
    self._parent_class:RemoveWaypoint(self._id)
end