local EHI = EHI
local icons = tweak_data.ehi.icons
---@class EHIWaypointManager
EHIWaypointManager = {}
EHIWaypointManager._font = tweak_data.menu.pd2_large_font_id -- Large font
EHIWaypointManager._timer_font_size = 32
EHIWaypointManager._distance_font_size = tweak_data.hud.default_font_size
EHIWaypointManager._bitmap_w = 32
EHIWaypointManager._bitmap_h = 32
function EHIWaypointManager:new()
    self._t = 0
    self._enabled = EHI:GetOption("show_waypoints") --[[@as boolean]]
    self._present_timer = EHI:GetOption("show_waypoints_present_timer") --[[@as number]]
    self._stored_waypoints = {} ---@type table<string, AddWaypointTable|ElementWaypointTrigger>
    self._waypoints = setmetatable({}, { __mode = "k" }) ---@type table<string, EHIWaypoint?>
    self._waypoints_to_update = setmetatable({}, { __mode = "k" }) ---@type table<string, EHIWaypoint?>
    self._base_waypoint_class = EHI.Waypoints.Base
    return self
end

---@param t number
function EHIWaypointManager:LoadTime(t)
    self._t = t
end

---@param hud HUDManager
function EHIWaypointManager:SetPlayerHUD(hud)
    --[[Hooks:PostHook(hud, "add_waypoint", "EHI_Test_add_waypoint", function(_self, id, ...) ---@param id string|number
        EHI:LogWithCurrentFile("Created waypoint with ID: " .. tostring(id))
    end)]]
    self._hud = hud
    for id, params in pairs(self._stored_waypoints) do
        self:AddWaypoint(id, params)
    end
    self._stored_waypoints = {}
end

---@param id string
---@param params AddWaypointTable|ElementWaypointTrigger
function EHIWaypointManager:AddWaypoint(id, params)
    if not self._enabled then
        return
    elseif not self._hud then
        self._stored_waypoints[id] = params
        return
    elseif self._waypoints[id] then
        self:RemoveWaypoint(id)
    end
    params.id = id
    params.timer = 0
    params.pause_timer = 1
    params.no_sync = true
    params.present_timer = params.present_timer or self._present_timer
    local waypoint = self._hud:AddEHIWaypoint(id, params)
    if not waypoint then
        return
    elseif not (waypoint.bitmap and waypoint.timer_gui) then
        self._enabled = false -- Disable waypoints as they don't have correct fields
        self._hud:remove_waypoint(id)
        return
    end
    self:SetWaypointInitialIcon(waypoint, params)
    if waypoint.distance then
        waypoint.distance:set_font(self._font)
        waypoint.distance:set_font_size(self._distance_font_size)
    end
    waypoint.timer_gui:set_font(self._font)
    waypoint.timer_gui:set_font_size(self._timer_font_size)
    local w = _G[params.class or self._base_waypoint_class]:new(waypoint, params, self) --[[@as EHIWaypoint]]
    if w._needs_update then
        self._waypoints_to_update[id] = w
    end
    self._waypoints[id] = w
    if params.remove_vanilla_waypoint then
        self._hud:SoftRemoveWaypoint2(params.remove_vanilla_waypoint)
    end
end

---@param id string
---@param params AddWaypointTable|ElementWaypointTrigger
function EHIWaypointManager:AddWaypointlessWaypoint(id, params)
    if not self._enabled then
        return
    elseif self._waypoints[id] then
        self:RemoveWaypoint(id)
    end
    params.id = id
    params.no_sync = true
    self._waypoints[id] = _G[params.class or self._base_waypoint_class]:new(nil, params, self) --[[@as EHIWaypoint]]
end

---Only Waypoints should call this. This function creates the waypoint on the HUD
---@param id number
---@param icon string
---@param position Vector3
---@param present_timer number?
---@return Waypoint?
function EHIWaypointManager:_create_waypoint(id, icon, position, present_timer)
    if not self._enabled then
        return
    end
    local params = {} ---@type WaypointInitData
    params.id = id
    params.icon = icon or "pd2_lootdrop"
    params.timer = 0
    params.pause_timer = 1
    params.present_timer = present_timer or self._present_timer
    params.position = position
    local waypoint = self._hud:AddEHIWaypoint(id, params)
    if not waypoint then
        return
    elseif not (waypoint.bitmap and waypoint.timer_gui) then
        self._enabled = false -- Disable waypoints as they don't have correct fields
        self._hud:remove_waypoint(id)
        return
    end
    self:SetWaypointInitialIcon(waypoint, params) ---@diagnostic disable-line
    if waypoint.distance then
        waypoint.distance:set_font(self._font)
        waypoint.distance:set_font_size(self._distance_font_size)
    end
    waypoint.timer_gui:set_font(self._font)
    waypoint.timer_gui:set_font_size(self._timer_font_size)
    --[[if params.remove_vanilla_waypoint then
        self._hud:SoftRemoveWaypoint2(params.remove_vanilla_waypoint)
    end]]
    return waypoint
end

---@param id string
function EHIWaypointManager:RemoveWaypoint(id)
    local wp = table.remove_key(self._waypoints, id)
    if wp then
        wp:destroy()
        self._waypoints_to_update[id] = nil
        self._hud:remove_waypoint(id)
    end
end

---@param id number
function EHIWaypointManager:RestoreVanillaWaypoint(id)
    if id then
        self._hud:RestoreWaypoint2(id)
    end
end

---@param id string
---@param new_id string
function EHIWaypointManager:UpdateWaypointID(id, new_id)
    local wp = self._waypoints[id]
    if self._waypoints[new_id] or not wp then
        return
    end
    wp._id = new_id
    self._waypoints[id] = nil
    self._waypoints[new_id] = wp
    if self._waypoints_to_update[id] then
        self._waypoints_to_update[id] = nil
        self._waypoints_to_update[new_id] = wp
    end
end

---@param wp Waypoint
---@param params AddWaypointTable|ElementWaypointTrigger
function EHIWaypointManager:SetWaypointInitialIcon(wp, params)
    local bitmap = wp.bitmap
    local bitmap_world = wp.bitmap_world -- VR
    local icon, texture_rect
    if params.texture then
        icon = params.texture
        texture_rect = params.text_rect
    else
        local _icon = type(params.icon) == "table" and params.icon[1] or params.icon --[[@as string]]
        if icons[_icon] then
            icon = icons[_icon].texture
            texture_rect = icons[_icon].texture_rect
        else
            icon, texture_rect = tweak_data.hud_icons:get_icon_or(_icon, icons.default.texture, icons.default.texture_rect)
        end
    end
    if texture_rect then
        bitmap:set_image(icon, unpack(texture_rect))
    else
        bitmap:set_image(icon)
    end
    bitmap:set_size(self._bitmap_w, self._bitmap_h)
    wp.size = Vector3(self._bitmap_w, self._bitmap_h, 0)
    if bitmap_world then
        if texture_rect then
            bitmap_world:set_image(icon, unpack(texture_rect))
        else
            bitmap_world:set_image(icon)
        end
        bitmap_world:set_size(self._bitmap_w, self._bitmap_h)
    end
end

---@param id string
---@param new_icon string
function EHIWaypointManager:SetWaypointIcon(id, new_icon)
    if id and self._waypoints[id] then
        local wp = self._hud:get_waypoint_data(id)
        if wp then
            self:SetWaypointInitialIcon(wp, { icon = new_icon })
        end
    end
end

---@param id string
---@param pos Vector3
function EHIWaypointManager:SetWaypointPosition(id, pos)
    if self:WaypointExists(id) then
        local wp = self._hud:get_waypoint_data(id)
        if wp and pos then
            wp.position = pos
            wp.init_data.position = pos
        end
    end
end

---@param id string
function EHIWaypointManager:WaypointExists(id)
    return id and self._waypoints[id] ~= nil or false
end

---@param id string
function EHIWaypointManager:WaypointDoesNotExist(id)
    return not self:WaypointExists(id)
end

---@param id string
---@param time number
function EHIWaypointManager:SetTime(id, time)
    local wp = self._waypoints[id]
    if wp then
        wp:SetTime(time)
    end
end

---@param id string
---@param jammed boolean
function EHIWaypointManager:SetTimerWaypointJammed(id, jammed)
    local wp = self._waypoints[id] --[[@as EHITimerWaypoint]]
    if wp and wp.SetJammed then
        wp:SetJammed(jammed)
    end
end

---@param id string
---@param powered boolean
function EHIWaypointManager:SetTimerWaypointPowered(id, powered)
    local wp = self._waypoints[id] --[[@as EHITimerWaypoint]]
    if wp and wp.SetPowered then
        wp:SetPowered(powered)
    end
end

---@param id string
function EHIWaypointManager:SetTimerWaypointRunning(id)
    local wp = self._waypoints[id] --[[@as EHITimerWaypoint]]
    if wp and wp.SetRunning then
        wp:SetRunning()
    end
end

---@param id string
---@param pause boolean
function EHIWaypointManager:SetPaused(id, pause)
    local wp = self._waypoints[id] --[[@as EHIPausableWaypoint]]
    if wp and wp.SetPause then
        wp:SetPause(pause)
    end
end

---@param id string
---@param t number
function EHIWaypointManager:SetAccurate(id, t)
    local wp = id and self._waypoints[id] --[[@as EHIInaccurateWaypoint]]
    if wp and wp.SetAccurate then
        wp:SetAccurate(t)
    end
end

---@param id string
---@param progress number
function EHIWaypointManager:SetProgress(id, progress)
    local wp = id and self._waypoints[id] --[[@as EHIProgressWaypoint]]
    if wp and wp.SetProgress then
        wp:SetProgress(progress)
    end
end

---@param id string
function EHIWaypointManager:IncreaseProgress(id)
    local wp = id and self._waypoints[id] --[[@as EHIProgressWaypoint]]
    if wp and wp.IncreaseProgress then
        wp:IncreaseProgress()
    end
end

---@param id string
---@param max number?
function EHIWaypointManager:IncreaseProgressMax(id, max)
    local wp = id and self._waypoints[id] --[[@as EHIProgressWaypoint]]
    if wp and wp.IncreaseProgressMax then
        wp:IncreaseProgressMax(max)
    end
end

---@param id string
---@param max number?
function EHIWaypointManager:DecreaseProgressMax(id, max)
    local wp = id and self._waypoints[id] --[[@as EHIProgressWaypoint]]
    if wp and wp.DecreaseProgressMax then
        wp:DecreaseProgressMax(max)
    end
end

---@param id string
---@param amount number
function EHIWaypointManager:IncreaseChance(id, amount)
    local wp = id and self._waypoints[id] --[[@as EHIChanceWaypoint]]
    if wp and wp.IncreaseChance then
        wp:IncreaseChance(amount)
    end
end

function EHIWaypointManager:SwitchToLoudMode()
    for _, waypoint in pairs(self._waypoints) do
        waypoint:SwitchToLoudMode()
    end
end

---@param wp EHIWaypoint
function EHIWaypointManager:_add_waypoint_to_update(wp)
    self._waypoints_to_update[wp._id] = wp
end

---@param id string
function EHIWaypointManager:_remove_waypoint_from_update(id)
    self._waypoints_to_update[id] = nil
end

---@param dt number
function EHIWaypointManager:update(dt)
    for _, waypoint in pairs(self._waypoints_to_update) do
        waypoint:update(dt)
    end
end

---@param dt number
function EHIWaypointManager:update2(t, dt)
    for _, waypoint in pairs(self._waypoints_to_update) do
        waypoint:update(dt)
    end
end

---@param t number
function EHIWaypointManager:update_client(t)
    local dt = t - self._t
    self._t = t
    self:update(dt)
end

function EHIWaypointManager:destroy()
    for key, _ in pairs(self._waypoints) do
        self._waypoints[key] = nil
    end
end

---@param id string
---@param f string
---@param ... any
function EHIWaypointManager:CallFunction(id, f, ...)
    local wp = self._waypoints[id]
    if wp and wp[f] then
        wp[f](wp, ...)
    end
end

---Returns `true` if the waypoint does not exist
---@param id string
---@param f string
---@param ... any
function EHIWaypointManager:CallFunction2(id, f, ...)
    local wp = id and self._waypoints[id]
    if not wp then
        return true
    elseif wp[f] then
        wp[f](wp, ...)
    end
end

do
    local path = EHI.LuaPath .. "waypoints/"
    dofile(path .. "EHIWaypoint.lua")
    dofile(path .. "EHIWarningWaypoint.lua")
    dofile(path .. "EHIPausableWaypoint.lua")
    dofile(path .. "EHITimerWaypoint.lua")
    dofile(path .. "EHIProgressWaypoint.lua")
    dofile(path .. "EHIChanceWaypoint.lua")
    dofile(path .. "EHIInaccurateWaypoints.lua")
    if EHI:GetWaypointOption("show_waypoints_loot_counter") then
        dofile(path .. "EHILootWaypoint.lua")
    end
end

if _G.IS_VR then
    return
elseif VoidUI and VoidUI.options.enable_waypoints then
    dofile(EHI.LuaPath .. "hud/waypoint/void_ui.lua")
elseif restoration and restoration.Options and restoration.Options:GetValue("HUD/Waypoints") then
    dofile(EHI.LuaPath .. "hud/waypoint/restoration_mod.lua")
end