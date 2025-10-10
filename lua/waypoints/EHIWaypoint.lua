---@class EHIWaypoint
---@field new fun(self: self, waypoint: Waypoint?, params: table): self
---@field _parent_class EHIWaypointManager Added when `EHIWaypointManager` class is created
---@field _force_format boolean Forces formatting (some waypoints need it and will force it)
---@field _forced_time number? Forces specific time in the waypoint
EHIWaypoint = class()
EHIWaypoint._needs_update = true
EHIWaypoint._fade_time = 5
EHIWaypoint._default_color = Color.white
---@param waypoint Waypoint
---@param params table
function EHIWaypoint:init(waypoint, params)
    self:pre_init(params)
    self._id = params.id --[[@as string]]
    self._time = self._forced_time or params.time or 0
    self._gui = waypoint.timer_gui
    self._bitmap = waypoint.bitmap
    self._arrow = waypoint.arrow
    self._bitmap_world = waypoint.bitmap_world -- VR
    self._remove_on_alarm = params.remove_on_alarm -- Removes waypoint when alarm sounds
    if self._force_format then
        self._gui:set_text(self:Format())
    end
    if params.remove_vanilla_waypoint and params.restore_on_done then
        self._vanilla_waypoint = params.remove_vanilla_waypoint
    end
    self:post_init(params)
end

function EHIWaypoint:pre_init(params)
end

function EHIWaypoint:post_init(params)
end

if EHI:GetOption("time_format") == 1 then
    EHIWaypoint.Format = tweak_data.ehi.functions.FormatSecondsOnly
    EHIWaypoint.FormatTime = tweak_data.ehi.functions.ReturnSecondsOnly
else
    EHIWaypoint.Format = tweak_data.ehi.functions.FormatMinutesAndSeconds
    EHIWaypoint.FormatTime = tweak_data.ehi.functions.ReturnMinutesAndSeconds
end

---@param dt number
function EHIWaypoint:update(dt)
    self._time = self._time - dt
    self._gui:set_text(self:Format())
    if self._time <= 0 then
        self:delete()
    end
end

---@param dt number
function EHIWaypoint:update_fade(dt)
    self._fade_time = self._fade_time - dt
    if self._fade_time <= 0 then
        self:delete()
    end
end

---@param t number
function EHIWaypoint:SetTime(t)
    self._time = t
    self._gui:set_text(self:Format())
end

---@param color Color?
function EHIWaypoint:SetColor(color)
    local c = color or self._default_color
    self._gui:set_color(c)
    self._bitmap:set_color(c)
    self._arrow:set_color(c)
end

---@param color Color?
function EHIWaypoint:StopAndSetColor(color)
    self._gui:stop()
    self:SetColor(color)
end

function EHIWaypoint:AddWaypointToUpdate()
    self._parent_class:_add_waypoint_to_update(self)
end

function EHIWaypoint:RemoveWaypointFromUpdate()
    self._parent_class:_remove_waypoint_from_update(self._id)
end

function EHIWaypoint:SwitchToLoudMode()
    if self._remove_on_alarm then
        self:delete()
    end
end

function EHIWaypoint:delete()
    self._parent_class:RemoveWaypoint(self._id)
end

function EHIWaypoint:destroy()
    if self._vanilla_waypoint then
        self._parent_class:RestoreVanillaWaypoint(self._vanilla_waypoint)
    end
end

if _G.IS_VR then
    EHIWaypointVR = EHIWaypoint
    EHIWaypointVR.old_SetColor = EHIWaypoint.SetColor
    ---@param color Color?
    function EHIWaypointVR:SetColor(color)
        self:old_SetColor(color)
        self._bitmap_world:set_color(color or self._default_color)
    end
end

---@class EHIWaypointLessWaypoint : EHIWaypoint
---@field super EHIWaypoint
EHIWaypointLessWaypoint = class(EHIWaypoint)
function EHIWaypointLessWaypoint:init(waypoint, params)
    self:pre_init(params)
    self._id = params.id --[[@as string]]
    self._remove_on_alarm = params.remove_on_alarm -- Removes waypoint when alarm sounds
    self:post_init(params)
end

---@param id number
---@param icon string
---@param position Vector3
function EHIWaypointLessWaypoint:CreateWaypoint(id, icon, position)
    local waypoint = self._parent_class:_create_vanilla_waypoint(id, icon, position)
    if waypoint then
        self._waypoint_id = id
        self._gui = waypoint.timer_gui
        self._gui:set_text(self:Format())
        self._bitmap = waypoint.bitmap
        self._arrow = waypoint.arrow
        self._bitmap_world = waypoint.bitmap_world
    end
end

---@param id number
function EHIWaypointLessWaypoint:RestoreWaypoint(id)
    local init_data = managers.hud:GetStoredWaypointData(id)
    if init_data then
        self:CreateWaypoint(id, init_data.icon, init_data.position)
    end
end

function EHIWaypointLessWaypoint:RemoveWaypoint()
    if self._waypoint_id then
        local init_data = managers.hud:GetStoredWaypointData(self._waypoint_id)
        managers.hud:remove_waypoint(self._waypoint_id)
        managers.hud:AddWaypointSoft(self._waypoint_id, init_data) ---@diagnostic disable-line
        self._waypoint_id = nil
        self._gui = nil
        self._bitmap = nil
        self._arrow = nil
        self._bitmap_world = nil
    end
end

function EHIWaypointLessWaypoint:destroy()
    if self._waypoint_id then
        managers.hud:remove_waypoint(self._waypoint_id)
    end
    EHIWaypointLessWaypoint.super.destroy(self)
end

---@class EHIWaypointsLessWaypoint : EHIWaypointLessWaypoint
---@field super EHIWaypointLessWaypoint
EHIWaypointsLessWaypoint = class(EHIWaypointLessWaypoint)
function EHIWaypointsLessWaypoint:init(...)
    self._waypoints = {} ---@type table<number, { gui: Text, bitmap: Bitmap, bitmap_world: Bitmap, arrow: Bitmap }>
    EHIWaypointsLessWaypoint.super.init(self, ...)
end

function EHIWaypointsLessWaypoint:CreateWaypoint(id, icon, position, ...)
    local waypoint = self._parent_class:_create_vanilla_waypoint(id, icon, position)
    if waypoint then
        local data = {}
        data.gui = waypoint.timer_gui
        data.gui:set_text(self:Format())
        data.bitmap = waypoint.bitmap
        data.arrow = waypoint.arrow
        data.bitmap_world = waypoint.bitmap_world
        self:WaypointCreated(data, ...)
        self._waypoints[id] = data
    end
end

---Called when a waypoint is created on the screen with additional parameters passed
---@param waypoint { gui: Text, bitmap: Bitmap, bitmap_world: Bitmap, arrow: Bitmap }
function EHIWaypointsLessWaypoint:WaypointCreated(waypoint, ...)
end

---@param id number
function EHIWaypointsLessWaypoint:RemoveWaypoint(id)
    if table.remove_key(self._waypoints, id) then
        local init_data = managers.hud:GetStoredWaypointData(id)
        managers.hud:remove_waypoint(id)
        managers.hud:AddWaypointSoft(id, init_data) ---@diagnostic disable-line
    end
end

function EHIWaypointsLessWaypoint:destroy()
    for id, _ in pairs(self._waypoints) do
        managers.hud:remove_waypoint(id)
    end
    EHIWaypointsLessWaypoint.super.super.destroy(self)
end