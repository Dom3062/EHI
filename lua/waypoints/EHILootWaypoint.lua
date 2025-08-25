---@alias EHILootWaypoint.Waypoint { gui: Text, bitmap: Bitmap, arrow: Bitmap, bitmap_world: Bitmap }

---@class EHILootWaypoint : EHIWaypointLessWaypoint
---@field super EHIWaypointLessWaypoint
EHILootWaypoint = class(EHIWaypointLessWaypoint)
EHILootWaypoint.update = EHILootWaypoint.update_fade
EHILootWaypoint._needs_update = false
function EHILootWaypoint:init(waypoint, params)
    EHILootWaypoint.super.init(self, waypoint, params)
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
        self._waypoints = self._waypoints or {} ---@type table<number, EHILootWaypoint.Waypoint>
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
    if wp and self._parent_class._waypoints_to_update[self._id] then -- If the Waypoint is in the point to be deleted (players secured all possible loot bags), just color them to default color again to restore them)
        for _, object in pairs(wp) do
            object:set_color(EHILootWaypoint.super._default_color)
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
    for id, _ in pairs(self._waypoints or {}) do
        managers.ehi_loot:_restore_waypoint(id)
    end
    self._parent_class:RemoveWaypoint(self._id)
end

---@class EHITimedLootWaypoint : EHILootWaypoint, EHIWarningWaypoint
---@field super EHILootWaypoint
EHITimedLootWaypoint = class(EHILootWaypoint)
EHITimedLootWaypoint._anim_warning = EHIWarningWaypoint._anim_warning
EHITimedLootWaypoint._check_anim_progress = false
EHITimedLootWaypoint._warning_color = EHIWarningWaypoint._warning_color
function EHITimedLootWaypoint:update(dt)
    self._time = self._time - dt
    local text = string.format(self._format, self:Format(), self._text or "")
    for _, wp in pairs(self._waypoints or {}) do
        wp.gui:set_text(text)
    end
    if self._time <= 10 and not self._anim_started then
        self:AnimateColor(self._check_anim_progress)
        self._anim_started = true
    elseif self._time <= 0 then
        if self._no_delete_after_time_out then
            self:RemoveWaypointFromUpdate()
            self._anim_started = false
        else
            self:delete()
        end
        return
    end
    if self._loot_time then
        self._loot_time = self._loot_time - dt
        if self._loot_time <= 0 then
            self._format = "%s%s"
            self._loot_time = nil
            self._text = nil
        end
    end
end

---@param check_progress boolean?
---@param color Color?
---@param default_color Color?
---@param waypoint EHILootWaypoint.Waypoint?
function EHITimedLootWaypoint:AnimateColor(check_progress, color, default_color, waypoint)
    local start_t = check_progress and (1 - math.min(math.ehi_round(self._time, 0.1) - math.floor(self._time), 0.99)) or 1
    for _, wp in pairs(waypoint and { waypoint } or self._waypoints or {}) do
        if wp.gui and alive(wp.gui) then
            wp.gui:animate(self._anim_warning, default_color or self._default_color, color or self._warning_color, wp.bitmap, wp.arrow, wp.bitmap_world, start_t)
        end
    end
end

---Has to return `false` to not create `EHIWarningWaypoint` -> see `ukrainian_job.lua`
---@param t number
---@param no_delete boolean
function EHITimedLootWaypoint:StartTimer(t, no_delete)
    self._time = t
    self._timer_started = true
    self._no_delete_after_time_out = no_delete
    self._format = "%s (%s)"
    self:AddWaypointToUpdate()
    local waypoints = self._parent_class._hud._hud.waypoints or {}
    for id, _ in pairs(self._waypoints or {}) do
        local wp = waypoints[id]
        if wp then
            self:CreateWaypoint(id, wp.init_data.icon, wp.init_data.position)
        end
    end
    return false
end

function EHITimedLootWaypoint:CreateWaypoint(id, ...)
    EHITimedLootWaypoint.super.CreateWaypoint(self, id, ...)
    local waypoint = self._waypoints[id]
    if waypoint and self._anim_started then
        self:AnimateColor(true, nil, nil, waypoint)
    end
end

function EHITimedLootWaypoint:SetCompleted(random_loot_present)
    EHITimedLootWaypoint.super.SetCompleted(self, random_loot_present)
    if not random_loot_present then
        if self._timer_started then
            self._loot_time = 5
            self._no_delete_after_time_out = nil
        else
            self.update = self.update_fade
        end
    end
end

EHILootCountWaypoint = class(EHILootWaypoint)