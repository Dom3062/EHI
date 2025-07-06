local EHI = EHI
if EHI:CheckLoadHook("TimerGui") or not EHI:GetTrackerOrWaypointOption("show_timers", "show_waypoints_timers") then
    return
end

---@class TimerGui
---@field _started boolean
---@field _done boolean
---@field _powered boolean
---@field _unit UnitTimer
---@field _original_colors table?
---@field _current_timer number|string
---@field _time_left number
---@field _timer_multiplier number
---@field _jammed boolean
---@field THEME string
---@field upgrade_colors table
---@field themes table
---@field get_timer_multiplier fun(self: self): number

local Icon = EHI.Icons

TimerGui.__EHI_SHOW_TRACKER, TimerGui.__EHI_SHOW_WAYPOINT = EHI:GetShowTrackerAndWaypoint("show_timers", "show_waypoints_timers")
---@type { [string]: number|MissionDoorTable? }
TimerGui._ehi_MissionDoor = {}

local original =
{
    init = TimerGui.init,
    set_background_icons = TimerGui.set_background_icons,
    _start = TimerGui._start,
    _set_done = TimerGui._set_done,
    _set_powered = TimerGui._set_powered,
    set_visible = TimerGui.set_visible,
    destroy = TimerGui.destroy,
    hide = TimerGui.hide
}

---@param unit UnitTimer
function TimerGui:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = tostring(unit:key())
    local base = unit:base()
    local icon = base.is_drill and Icon.Drill or base.is_hacking_device and Icon.PCHack or base.is_saw and "pd2_generic_saw" or Icon.Wait
    self._ehi_icon = { { icon = icon } }
    self._ehi_hint = icon == Icon.Drill and "drill" or icon == Icon.PCHack and "hack" or icon == "pd2_generic_saw" and "saw" or "process"
    self._ehi_group = icon == Icon.Drill and "drill" or icon == Icon.PCHack and "hack" or icon == "pd2_generic_saw" and "saw" or "process"
    if self.__EHI_SHOW_TRACKER then
        EHI:OptionAndLoadTracker("show_timers")
    end
end

function TimerGui:GetVisibilityData()
    return {
        hint = self._ehi_hint,
        theme = self.THEME,
        icons = self._icons or self._ehi_icon
    }
end

function TimerGui:set_background_icons(...)
    original.set_background_icons(self, ...)
    managers.ehi_timer:SetTimerUpgrades(self)
end

---@return table?, table?
function TimerGui:GetUpgrades()
    local base = self._unit:base()
    if base._disable_upgrades or not (base.is_drill or base.is_saw) or table.ehi_size(self._original_colors) == 0 then
        return nil, nil
    end
    local upgrade_table = nil
    local skills = base.get_skill_upgrades and base:get_skill_upgrades()
    if skills and table.ehi_size(self._original_colors) > 0 then
        upgrade_table = {
            restarter = (skills.auto_repair_level_1 or 0) + (skills.auto_repair_level_2 or 0),
            faster = (skills.speed_upgrade_level or 0),
            silent = (skills.reduced_alert and 1 or 0) + (skills.silent_drill and 1 or 0)
        }
    end
    return upgrade_table, skills
end

function TimerGui:GetAutorepairState()
    return self._unit:base().CanAutorepair and self._unit:base():CanAutorepair()
end

---@param t number
---@param autorepair boolean|string
function TimerGui:AddWaypoint(t, autorepair)
    if self.__EHI_SHOW_WAYPOINT then
        managers.ehi_waypoint:AddWaypoint(self._ehi_key, {
            time = t,
            timer_gui = self,
            icon = self._icons or self._ehi_icon[1].icon,
            position = self._forced_pos or self._unit:interaction() and self._unit:interaction():interact_position() or self._unit:position(),
            autorepair = autorepair,
            class = "EHITimerGuiWaypoint"
        })
    end
end

function TimerGui:PostStartTimer()
    if self._unit:mission_door_device() then
        local data = self._ehi_MissionDoor[tostring(self._unit:position())]
        if data then
            if type(data) == "table" then
                self._restore_vanilla_waypoint_on_done = data.restore
                self._remove_vanilla_waypoint = data.w_id
                if data.restore and data.unit_id then
                    local restore = callback(self, self, "RestoreWaypoint")
                    local m = managers.mission
                    m:add_runned_unit_sequence_trigger(data.unit_id, "explode_door", restore)
                    m:add_runned_unit_sequence_trigger(data.unit_id, "open_door_keycard", restore)
                    m:add_runned_unit_sequence_trigger(data.unit_id, "open_door_ecm", restore)
                    m:add_runned_unit_sequence_trigger(data.unit_id, "open_door", restore) -- In case the drill finishes first host side than client-side
                    -- Drill finish is covered in TimerGui:_set_done()
                end
            elseif type(data) == "number" then
                self._remove_vanilla_waypoint = data
            end
        end
    end
    self:HideWaypoint()
end

function TimerGui:HideWaypoint()
    if self.__EHI_SHOW_WAYPOINT then
        if self._remove_vanilla_waypoint then
            managers.hud:RemoveTimerWaypoint(self._remove_vanilla_waypoint)
        elseif self._remove_vanilla_waypoint_overriden then
            if managers.ehi_waypoint:CallFunction2(self._remove_vanilla_waypoint_overriden.waypoint, "RemoveWaypoint") then
                managers.hud:RemoveTimerWaypoint(self._remove_vanilla_waypoint_overriden.id)
            end
        end
    end
end

function TimerGui:_start(...)
    original._start(self, ...)
    if self._ignore then
        return
    elseif self._tracker_merge_id and managers.ehi_tracker:Exists(self._tracker_merge_id) then
        self._ehi_key = self._tracker_merge_id
        self.__ehi_merge = true
        self._tracker_merge_id = nil
    end
    if managers.ehi_timer:TimerExists(self._ehi_key) then
        if (self.__ehi_merge and managers.ehi_timer:IsTimerMergeRunning(self._ehi_key)) or not self.__ehi_merge then
            managers.ehi_timer:SetRunning(self._ehi_key)
            return
        end
    end
    local autorepair = self:GetAutorepairState()
    -- In case the conversion fails, fallback to "self._time_left" which is a number
    local t = tonumber(self._current_timer) or self._time_left
    if self.__EHI_SHOW_TRACKER then
        if self.__ehi_merge then
            managers.ehi_tracker:CallFunction(self._ehi_key, "SetTimerGui", self)
            managers.ehi_tracker:CallFunction(self._ehi_key, "StartTimer", t)
        else
            local upgrades, skills = self:GetUpgrades()
            managers.ehi_timer:StartTimer({
                id = self._ehi_key,
                key = self._ehi_key,
                time = t,
                timer_gui = self,
                icons = self._icons or self._ehi_icon,
                theme = self.THEME,
                class = "EHITimerGuiTracker",
                hint = self._ehi_hint,
                group = self._ehi_group,
                upgrades = upgrades,
                skills = skills,
                autorepair = autorepair
            })
        end
    end
    self:AddWaypoint(t, autorepair)
    self:PostStartTimer()
end

function TimerGui:_set_done(...)
    self:RemoveTracker()
    original._set_done(self, ...)
    self:RestoreWaypoint()
    for _, unit in ipairs(self.__ehi_child_units or {}) do
        local base = unit and unit:base()
        if base and base.SetCountThisUnit then
            base:SetCountThisUnit()
        end
    end
end

function TimerGui:RestoreWaypoint()
    if self._restore_vanilla_waypoint_on_done then
        if self._remove_vanilla_waypoint then
            managers.hud:RestoreTimerWaypoint(self._remove_vanilla_waypoint)
        elseif self._remove_vanilla_waypoint_overriden then
            local override = self._remove_vanilla_waypoint_overriden
            if managers.ehi_waypoint:CallFunction2(override.waypoint, "RestoreWaypoint", override.id) then
                managers.hud:RestoreTimerWaypoint(override.id)
            end
        end
    end
end

Hooks:PreHook(TimerGui, "_set_jammed", "EHI_TimerGui_set_jammed", function(self, jammed, ...) ---@param jammed boolean
    if jammed == true and self._power_status_override then
        managers.ehi_timer:SetPowered(self._ehi_key, true)
    end
    managers.ehi_timer:SetJammed(self._ehi_key, jammed)
end)

---@param powered boolean
function TimerGui:_set_powered(powered, ...)
    if powered == false and self._remove_on_power_off then
        self:RemoveTracker()
    end
    managers.ehi_timer:SetPowered(self._ehi_key, powered)
    original._set_powered(self, powered, ...)
end

---@param visible boolean
function TimerGui:set_visible(visible, ...)
    original.set_visible(self, visible, ...)
    if self._ignore_visibility then
        return
    elseif visible == false then
        self:RemoveTracker()
    end
end

function TimerGui:hide(...)
    self:RemoveTracker()
    original.hide(self, ...)
end

function TimerGui:destroy(...)
    self:RemoveTracker(true)
    original.destroy(self, ...)
end

---@param destroy boolean?
function TimerGui:RemoveTracker(destroy)
    if self.__ehi_merge and not destroy then
        if self._destroy_tracker_merge_on_done then
            managers.ehi_tracker:RemoveTracker(self._ehi_key)
        else
            managers.ehi_tracker:CallFunction(self._ehi_key, "StopTimer")
        end
        managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
    else
        managers.ehi_timer:RemoveTimer(self._ehi_key)
    end
end

function TimerGui:OnAlarm()
    self._ignore = true
    self:RemoveTracker()
end

---@param icons table?
function TimerGui:SetIcons(icons)
    self._icons = icons or self._icons
end

---@param remove_on_power_off boolean
function TimerGui:SetRemoveOnPowerOff(remove_on_power_off)
	self._remove_on_power_off = remove_on_power_off
end

function TimerGui:SetOnAlarm()
	EHI:AddOnAlarmCallback(callback(self, self, "OnAlarm"))
end

---@param waypoint_id number
---@param restore_waypoint_on_done boolean?
function TimerGui:RemoveVanillaWaypoint(waypoint_id, restore_waypoint_on_done)
    self._remove_vanilla_waypoint = waypoint_id
    self._restore_vanilla_waypoint_on_done = restore_waypoint_on_done
    if self._started then
        self:HideWaypoint()
    end
end

---@param waypoint { id: number, waypoint: string }
---@param restore_waypoint_on_done boolean?
function TimerGui:RemoveVanillaWaypointOverriden(waypoint, restore_waypoint_on_done)
    self._remove_vanilla_waypoint_overriden = waypoint
    self._restore_vanilla_waypoint_on_done = restore_waypoint_on_done
    if self._started then
        self:HideWaypoint()
    end
end

function TimerGui:SetIgnoreVisibility()
    self._ignore_visibility = true
end

function TimerGui:SetJammedStatusOverridePoweredStatus()
    self._power_status_override = true
    if self._started and self._jammed and not self._powered then
        managers.ehi_timer:SetPowered(self._ehi_key, true)
    end
end

---@param units number[]
---@param wd WorldDefinition
function TimerGui:SetChildUnits(units, wd)
    if self._done then
        for _, unit_id in ipairs(units) do
            local unit = wd:get_unit(unit_id) --[[@as UnitAmmoDeployable|UnitGrenadeDeployable]]
            local base = unit and unit:base()
            if base and base.SetCountThisUnit then
                base:SetCountThisUnit()
            else
                EHI:Log("[TimerGui] Cannot find unit with ID " .. tostring(unit_id))
            end
        end
    else
        self.__ehi_child_units = {} ---@type UnitAmmoDeployable[]|UnitGrenadeDeployable[]|false[]
        for i, unit_id in ipairs(units) do
            local unit = wd:get_unit(unit_id) --[[@as UnitAmmoDeployable|UnitGrenadeDeployable]]
            if unit then
                self.__ehi_child_units[i] = unit
            else
                self.__ehi_child_units[i] = false
                EHI:Log("[TimerGui] Cannot find unit with ID " .. tostring(unit_id))
            end
        end
    end
end

---@param pos Vector3
function TimerGui:SetWaypointPosition(pos)
    self._forced_pos = pos
    if self._started and pos then
        managers.ehi_waypoint:SetWaypointPosition(self._ehi_key, pos)
    end
end

---@param id string
---@param operation string
function TimerGui:SetCustomCallback(id, operation)
    if operation == "remove" then
        EHI:AddCallback(id, callback(self, self, "OnAlarm"))
    elseif operation == "add_waypoint" then
        EHI.Trigger:AddEventListener(self._tracker_merge_id and tostring(self._unit:key()) or self._ehi_key, id, function()
            if self._started and not self._done then
                self:AddWaypoint(self._time_left, self:GetAutorepairState())
            end
        end)
    end
end

---@param id string
function TimerGui:SetCustomID(id)
    if not id then
        return
    elseif self._started then
        managers.ehi_tracking:UpdateID(self._ehi_key, id)
    end
    self._ehi_key = id
end

---@param id string
---@param destroy_on_done boolean?
function TimerGui:SetTrackerMergeID(id, destroy_on_done)
    self._tracker_merge_id = id
    self._destroy_tracker_merge_on_done = destroy_on_done
end

---@param hint string
function TimerGui:SetHint(hint)
    self._ehi_hint = hint
    managers.ehi_tracker:UpdateHint(self._ehi_key, hint)
end

function TimerGui:Finalize()
    if self._ignore or (self._remove_on_power_off and not self._powered) then
        self:RemoveTracker()
        return
    elseif self._icons then
        managers.ehi_tracking:SetIcon(self._ehi_key, self._icons[1])
	end
    if self._started and not self._done and self._unit:mission_door_device() then
        self:PostStartTimer()
    end
end