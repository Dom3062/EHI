local EHI = EHI
if EHI:CheckLoadHook("HUDManager") then
    return
end

local original =
{
    set_waypoint_timer_pause = HUDManager.set_waypoint_timer_pause,
    save = HUDManager.save,
    load = HUDManager.load
}

---@class HUDManager
---@field new fun(): self
---@field _hud { waypoints: table<string|number, Waypoint>, ehi_removed_waypoints: table<string, true>, stored_waypoints: table<string|number, WaypointInitData> }
---@field _hud_hint table HUDHint class
---@field _hud_heist_timer HUDHeistTimer
---@field _hud_mission_briefing HUDMissionBriefing
---@field PLAYER_PANEL number
---@field add_waypoint fun(self: self, id: number|string, params: table)
---@field remove_waypoint fun(self: self, id: number|string)
---@field get_waypoint_data fun(self: self, id: number|string): Waypoint?
---@field add_updator fun(self: self, id: string, cb: function)
---@field remove_updator fun(self: self, id: string)
---@field script fun(self: self, name: string): { panel: Panel }
---@field custom_ingame_popup_text fun(self: self, title: string?, text: string, icon_id: string?)
---@field show_hint fun(self: self, params: table)
---@field make_fine_text fun(self: self, text: Text)
---@field show_interaction_bar fun(self: self, current: number, total: number)
---@field set_interaction_bar_width fun(self: self, current: number, total: number)
---@field hide_interaction_bar fun(self: self, complete: boolean?)

---@param id number
---@return WaypointInitData?
function HUDManager:GetStoredWaypointData(id)
    return self._hud.stored_waypoints[id]
end

---@param id number|string
---@param params WaypointInitData
---@return Waypoint?
function HUDManager:AddEHIWaypoint(id, params)
    self:add_waypoint(id, params)
    return self:get_waypoint_data(id)
end

---@param id string
---@param params table
function HUDManager:AddWaypointFromTrigger(id, params)
    if params.icon_redirect then
        local wp = self:AddEHIWaypoint(id, params)
        if wp and wp.bitmap then
            managers.ehi_waypoint:SetWaypointInitialIcon(wp, params)
        else -- Remove the waypoint as it does not have bitmap
            self:remove_waypoint(id)
        end
    else
        self:add_waypoint(id, params)
    end
end

---@param id number
---@param data WaypointInitData
function HUDManager:AddWaypointSoft(id, data)
    self._hud.stored_waypoints[id] = data
    self._hud.ehi_removed_waypoints = self._hud.ehi_removed_waypoints or {}
    self._hud.ehi_removed_waypoints[id] = true
end

---@param id number
function HUDManager:SoftRemoveWaypoint(id)
    local init_data = self._hud.waypoints[id] and self._hud.waypoints[id].init_data
    if init_data then
        self:remove_waypoint(id)
        self:AddWaypointSoft(id, init_data)
    end
end

---@param id number
function HUDManager:SoftRemoveWaypoint2(id)
    self:SoftRemoveWaypoint(id)
    EHI:DisableElementWaypoint(id)
end

---@param id number
---@param no_add boolean?
function HUDManager:RestoreWaypoint(id, no_add)
    local wp_data = table.remove_key(self._hud.stored_waypoints, id)
    if wp_data and not no_add then
        self:add_waypoint(id, wp_data)
    end
    if self._hud.ehi_removed_waypoints then
        self._hud.ehi_removed_waypoints[id] = nil
    end
end

---@param id number
function HUDManager:RestoreWaypoint2(id)
    self:RestoreWaypoint(id)
    EHI:RestoreElementWaypoint(id)
end

---@param id number
function HUDManager:RemoveTimerWaypoint(id)
    self:SoftRemoveWaypoint(id)
    EHI._cache.IgnoreWaypoints[id] = true
    EHI:DisableElementWaypoint(id)
end

---@param id number
function HUDManager:RestoreTimerWaypoint(id)
    EHI._cache.IgnoreWaypoints[id] = nil
    self:RestoreWaypoint(id)
    EHI:RestoreElementWaypoint(id)
end

---@param id string
function HUDManager:set_waypoint_timer_pause(id, ...)
    if id and managers.ehi_waypoint:WaypointExists(id) then -- Block attempts of pausing waypoints created in EHIWaypointManager
        return
    end
    original.set_waypoint_timer_pause(self, id, ...)
end

function HUDManager:save(data, ...)
    original.save(self, data, ...)
    local state = data.HUDManager
    -- Sync hidden waypoints to ensure that unmodified clients will see them correctly
    for id, _ in pairs(self._hud.ehi_removed_waypoints or {}) do
        if self._hud.stored_waypoints[id] then
            state.waypoints[id] = self._hud.stored_waypoints[id]
        end
    end
end

function HUDManager:load(data, ...)
    local state = data.HUDManager
    managers.ehi_assault:SetCurrentAssaultNumber(state.assault_number or 1, state.in_assault)
    managers.ehi_loot:pre_load(state.waypoints)
    original.load(self, data, ...)
    for id, _ in pairs(self._hud.waypoints or {}) do ---@cast id -string
        if EHI._cache.IgnoreWaypoints[id] then
            self:SoftRemoveWaypoint(id)
        end
    end
end