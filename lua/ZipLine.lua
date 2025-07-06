---@class ZipLine
---@field _attached_bag Unit?
---@field _current_time number
---@field _sled_data { object: Unit? }
---@field _unit UnitZipline
---@field ziplines UnitZipline[]
---@field is_usage_type_bag fun(self: self): boolean
---@field is_usage_type_person fun(self: self): boolean
---@field total_time fun(self: self): number

local EHI = EHI
if EHI:CheckLoadHook("ZipLine") or not EHI:GetTrackerOrWaypointOption("show_zipline_timer", "show_waypoints_zipline") then
    return
end

local show_tracker, show_waypoint = EHI:GetShowTrackerAndWaypoint("show_zipline_timer", "show_waypoints_zipline")
local original =
{
    init = ZipLine.init,
    update = ZipLine.update,
    release_bag = ZipLine.release_bag,
    set_usage_type = ZipLine.set_usage_type,
    attach_bag = ZipLine.attach_bag,
    set_user = ZipLine.set_user,
    sync_set_user = ZipLine.sync_set_user,
    destroy = ZipLine.destroy
}

function ZipLine:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = tostring(unit:key())
    if show_tracker then
        if managers.ehi_tracker:CallFunction2("ZipLineBag", "AddUnit") then
            managers.ehi_tracker:PreloadTracker({
                id = "ZipLineBag",
                icons = { "zipline_bag" },
                unit = true,
                hint = "zipline_bag",
                class = EHI.Trackers.Group.Base
            })
        end
        if managers.ehi_tracker:CallFunction2("ZipLineUser", "AddUnit") then
            managers.ehi_tracker:PreloadTracker({
                id = "ZipLineUser",
                icons = { "Other_H_Any_DidntSee" }, -- gage3_13 achievement icon
                unit = true,
                hint = "zipline_person",
                class = EHI.Trackers.Group.Base
            })
        end
    end
    if self:is_usage_type_bag() then
        self:HookUpdateLoop()
    end
end

function ZipLine:HookUpdateLoop()
    if self.__ehi_update_hooked then
        return
    end
    self.update = function(line, ...) ---@param line ZipLine
        original.update(line, ...)
        if line.__ehi_bag_attached and not line._attached_bag then
            line.__ehi_bag_attached = nil
            local t = line:total_time() * line._current_time
            managers.ehi_tracker:CallFunction("ZipLineBag", "SetTimeNoAnim", t, line._ehi_key)
            managers.ehi_waypoint:SetTime(line._ehi_key, t)
        end
    end
    self.__ehi_update_hooked = true
end

function ZipLine:UnhookUpdateLoop()
    if self.__ehi_update_hooked then
        self.update = original.update
        self.__ehi_update_hooked = nil
    end
end

function ZipLine:set_usage_type(...)
    original.set_usage_type(self, ...)
    if self:is_usage_type_bag() then
        self:HookUpdateLoop()
    else
        self:UnhookUpdateLoop()
    end
end

function ZipLine:release_bag(...)
    original.release_bag(self, ...)
    self.__ehi_bag_attached = nil
end

function ZipLine:GetMovingObject()
    return self._sled_data.object or self._unit
end

function ZipLine:attach_bag(...)
    original.attach_bag(self, ...)
    local total_time = self:total_time() * 2
    managers.ehi_tracker:RunTracker("ZipLineBag", { id = self._ehi_key, time = total_time })
    if show_waypoint then
        managers.ehi_waypoint:AddWaypoint(self._ehi_key, {
            time = total_time,
            icon = "zipline_bag",
            unit = self:GetMovingObject()
        })
    end
    self.__ehi_bag_attached = true
end

---@param self ZipLine
---@param unit C_Unit?
local function AddUserZipline(self, unit)
    if not unit then
        return
    end
    local t = self:total_time()
    local total_time = t * 2
    managers.ehi_tracker:RunTracker("ZipLineUser", { id = self._ehi_key, time = total_time })
    if show_waypoint then
        local local_unit = unit == managers.player:player_unit()
        managers.ehi_waypoint:AddWaypoint(self._ehi_key, {
            time = total_time,
            present_timer = local_unit and t, ---@diagnostic disable-line
            icon = "Other_H_Any_DidntSee",
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
    managers.ehi_tracking:RemoveUnit("ZipLineUser", self._ehi_key, true)
    managers.ehi_tracking:RemoveUnit("ZipLineBag", self._ehi_key, true)
    original.destroy(self, ...)
end