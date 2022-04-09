if EHI._hooks.ZipLine then
	return
else
	EHI._hooks.ZipLine = true
end

if not EHI:GetOption("show_zipline_timer") then
    return
end

local show_waypoint = EHI:GetWaypointOption("show_waypoints_zipline")
local show_waypoint_only = show_waypoint and EHI:GetWaypointOption("show_waypoints_only")

local original =
{
    init = ZipLine.init,
    attach_bag = ZipLine.attach_bag,
    set_user = ZipLine.set_user,
    sync_set_user = ZipLine.sync_set_user,
    destroy = ZipLine.destroy
}
local bag_time_correction = 0
--local user_time_correction = 0
local level_id = Global.game_settings.level_id
if level_id == "dah" then
    bag_time_correction = 1
end

function ZipLine:init(unit, ...)
    original.init(self, unit, ...)
    local key = tostring(unit:key())
    self._ehi_key_bag_half = key .. "_bag_drop"
    self._ehi_key_bag_full = key .. "_bag_reset"
    self._ehi_key_user_half = key .. "_person_drop"
    self._ehi_key_user_full = key .. "_person_reset"
end

function ZipLine:GetMovingObject()
    return self._sled_data.object or self._unit
end

function ZipLine:attach_bag(...)
    original.attach_bag(self, ...)
    local total_time = self:total_time()
    local total_time_2 = (total_time * 2) - bag_time_correction
    if not show_waypoint_only then
        managers.ehi:AddTracker({
            id = self._ehi_key_bag_half,
            time = total_time - bag_time_correction,
            icons = { "equipment_winch_hook", "wp_bag", "pd2_goto" }
        })
        managers.ehi:AddTracker({
            id = self._ehi_key_bag_full,
            time = total_time_2,
            icons = { "equipment_winch_hook", "restarter" }
        })
    end
    if show_waypoint then
        managers.ehi_waypoint:AddWaypoint(self._ehi_key_bag_full, {
            time = total_time_2,
            icon = "equipment_winch_hook",
            unit = self:GetMovingObject()
        })
    end
end

local function AddUserZipline(self, unit)
    if not unit then
        return
    end
    local total_time = self:total_time()
    local total_time_2 = total_time * 2
    if not show_waypoint_only then
        managers.ehi:AddTracker({
            id = self._ehi_key_user_half,
            time = total_time,
            icons = { "equipment_winch_hook", "pd2_escape", "pd2_goto" }
        })
        managers.ehi:AddTracker({
            id = self._ehi_key_user_full,
            time = total_time_2,
            icons = { "equipment_winch_hook", "restarter" }
        })
    end
    if show_waypoint then
        local local_unit = unit == managers.player:player_unit()
        managers.ehi_waypoint:AddWaypoint(self._ehi_key_user_full, {
            time = total_time_2,
            present_timer = local_unit and total_time,
            icon = "equipment_winch_hook",
            unit = self:GetMovingObject()
        })
    end
end

function ZipLine:set_user(unit, ...)
    AddUserZipline(self, unit)
    original.set_user(self, unit, ...)
end

function ZipLine:sync_set_user(unit, ...)
    AddUserZipline(self, unit)
    original.sync_set_user(self, unit, ...)
end

function ZipLine:destroy(...)
    managers.ehi:RemoveTracker(self._ehi_key_bag_half)
    managers.ehi:RemoveTracker(self._ehi_key_bag_full)
    managers.ehi:RemoveTracker(self._ehi_key_user_half)
    managers.ehi:RemoveTracker(self._ehi_key_user_full)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key_bag_full)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key_user_full)
    original.destroy(self, ...)
end