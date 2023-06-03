local EHI = EHI
if EHI:CheckLoadHook("TimerGui") or not EHI:GetOption("show_timers") then
    return
end

local Icon = EHI.Icons

local show_waypoint, show_waypoint_only = EHI:GetWaypointOptionWithOnly("show_waypoints_timers")
---@type MissionDoorTable
local MissionDoor = {}

---@param tbl MissionDoorTable
function TimerGui.SetMissionDoorPosAndIndex(tbl)
    for vector, value in pairs(tbl) do
        MissionDoor[tostring(vector)] = value
    end
end

local original =
{
    init = TimerGui.init,
    set_background_icons = TimerGui.set_background_icons,
    _start = TimerGui._start,
    update = TimerGui.update,
    _set_done = TimerGui._set_done,
    _set_jammed = TimerGui._set_jammed,
    _set_powered = TimerGui._set_powered,
    set_visible = TimerGui.set_visible,
    destroy = TimerGui.destroy,
    hide = TimerGui.hide
}

function TimerGui:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = tostring(unit:key())
    local icon = unit:base().is_drill and Icon.Drill or unit:base().is_hacking_device and Icon.PCHack or unit:base().is_saw and "pd2_generic_saw" or Icon.Wait
    self._ehi_icon = { { icon = icon } }
end

function TimerGui:set_background_icons(...)
    original.set_background_icons(self, ...)
    managers.ehi_tracker:CallFunction(self._ehi_key, "SetUpgrades", self:GetUpgrades())
end

function TimerGui:GetUpgrades()
    if self._unit:base()._disable_upgrades or not (self._unit:base().is_drill or self._unit:base().is_saw) or table.size(self._original_colors or {}) == 0 then
        return nil
    end
    local upgrade_table = nil
    local skills = self._unit:base().get_skill_upgrades and self._unit:base():get_skill_upgrades()
    if skills and table.size(self._original_colors or {}) > 0 then
        upgrade_table = {
            restarter = (skills.auto_repair_level_1 or 0) + (skills.auto_repair_level_2 or 0),
            faster = (skills.speed_upgrade_level or 0),
            silent = (skills.reduced_alert and 1 or 0) + (skills.silent_drill and 1 or 0)
        }
    end
    return upgrade_table
end

function TimerGui:StartTimer()
    if managers.ehi_manager:Exists(self._ehi_key) then
        managers.ehi_manager:SetTimerRunning(self._ehi_key)
    else
        local autorepair = self._unit:base()._autorepair or self._unit:base()._autorepair_client
        -- In case the conversion fails, fallback to "self._time_left" which is a number
        local t = tonumber(self._current_timer) or self._time_left
        if not show_waypoint_only then
            managers.ehi_tracker:AddTracker({
                id = self._ehi_key,
                time = t,
                icons = self._icons or self._ehi_icon,
                theme = self.THEME,
                class = "EHITimerTracker",
                upgrades = self:GetUpgrades(),
                autorepair = autorepair
            })
        end
        if show_waypoint then
            managers.ehi_waypoint:AddWaypoint(self._ehi_key, {
                time = t,
                icon = self._icons or self._ehi_icon[1].icon,
                position = self._forced_pos or self._unit:interaction() and self._unit:interaction():interact_position() or self._unit:position(),
                autorepair = autorepair,
                class = "EHITimerWaypoint"
            })
        end
        self:PostStartTimer()
    end
end

function TimerGui:PostStartTimer()
    if self._unit:mission_door_device() then
        local data = MissionDoor[tostring(self._unit:position())]
        if data then
            if type(data) == "table" then
                self._restore_vanilla_waypoint_on_done = data.restore
                self._remove_vanilla_waypoint = data.w_id
                if data.restore and data.unit_id then
                    local restore = callback(self, self, "RestoreWaypoint")
                    local m = managers.mission
                    local add_trigger = m.add_runned_unit_sequence_trigger
                    add_trigger(m, data.unit_id, "explode_door", restore)
                    add_trigger(m, data.unit_id, "open_door_keycard", restore)
                    add_trigger(m, data.unit_id, "open_door_ecm", restore)
                    add_trigger(m, data.unit_id, "open_door", restore) -- In case the drill finishes first host side than client-side
                    -- Drill finish is covered in TimerGui:_set_done()
                end
            else -- Assume provided waypoint is a number
                self._remove_vanilla_waypoint = data
            end
        end
    end
    self:HideWaypoint()
end

function TimerGui:HideWaypoint()
    if self._remove_vanilla_waypoint and show_waypoint then
        self:_HideWaypoint(self._remove_vanilla_waypoint)
    end
end

function TimerGui:_HideWaypoint(waypoint)
    managers.hud:SoftRemoveWaypoint(waypoint)
    EHI._cache.IgnoreWaypoints[waypoint] = true
    EHI:DisableElementWaypoint(waypoint)
end

function TimerGui:_start(...)
    original._start(self, ...)
    if self._ignore then
        return
    end
    self:StartTimer()
end

if show_waypoint_only then
    function TimerGui:update(...)
        managers.ehi_waypoint:SetWaypointTime(self._ehi_key, self._time_left)
        original.update(self, ...)
    end
elseif show_waypoint then
    function TimerGui:update(...)
        managers.ehi_manager:UpdateTimer(self._ehi_key, self._time_left)
        original.update(self, ...)
    end
else
    function TimerGui:update(...)
        managers.ehi_tracker:SetTrackerTimeNoAnim(self._ehi_key, self._time_left)
        original.update(self, ...)
    end
end

function TimerGui:_set_done(...)
    self:RemoveTracker()
    original._set_done(self, ...)
    self:RestoreWaypoint()
    if self._parent then
        for _, unit in ipairs(self._child_units or {}) do
            if unit:base() and unit:base().SetCountThisUnit then
                unit:base():SetCountThisUnit()
            end
        end
    end
end

function TimerGui:RestoreWaypoint()
    if self._restore_vanilla_waypoint_on_done and self._remove_vanilla_waypoint then
        EHI._cache.IgnoreWaypoints[self._remove_vanilla_waypoint] = nil
        managers.hud:RestoreWaypoint(self._remove_vanilla_waypoint)
        EHI:RestoreElementWaypoint(self._remove_vanilla_waypoint)
    end
end

function TimerGui:_set_jammed(jammed, ...)
    managers.ehi_manager:SetTimerJammed(self._ehi_key, jammed)
    original._set_jammed(self, jammed, ...)
end

function TimerGui:_set_powered(powered, ...)
    if powered == false and self._remove_on_power_off then
        self:RemoveTracker()
    end
    managers.ehi_manager:SetTimerPowered(self._ehi_key, powered)
    original._set_powered(self, powered, ...)
end

function TimerGui:set_visible(visible, ...)
    original.set_visible(self, visible, ...)
    if self._ignore_visibility then
        return
    end
    if visible == false then
        self:RemoveTracker()
    end
end

function TimerGui:hide(...)
    self:RemoveTracker()
    original.hide(self, ...)
end

function TimerGui:destroy(...)
    self:RemoveTracker()
    original.destroy(self, ...)
end

function TimerGui:RemoveTracker()
    managers.ehi_manager:Remove(self._ehi_key)
end

function TimerGui:OnAlarm()
    self._ignore = true
    self:RemoveTracker()
end

function TimerGui:DisableOnSetVisible()
    self.set_visible = original.set_visible
end

function TimerGui:SetIcons(icons)
    self._icons = icons
end

function TimerGui:SetRemoveOnPowerOff(remove_on_power_off)
	self._remove_on_power_off = remove_on_power_off
end

function TimerGui:SetOnAlarm()
	EHI:AddOnAlarmCallback(callback(self, self, "OnAlarm"))
end

function TimerGui:RemoveVanillaWaypoint(waypoint_id)
    self._remove_vanilla_waypoint = waypoint_id
    if self._started then
        self:HideWaypoint()
    end
end

function TimerGui:SetIgnoreVisibility()
    self._ignore_visibility = true
end

function TimerGui:SetRestoreVanillaWaypointOnDone()
    self._restore_vanilla_waypoint_on_done = true
end

function TimerGui:SetChildUnits(units, wd)
    if self._done then
        for _, unit_id in ipairs(units) do
            local unit = wd:get_unit(unit_id)
            if unit and unit:base() and unit:base().SetCountThisUnit then
                unit:base():SetCountThisUnit()
            else
                EHI:Log("[TimerGui] Cannot find unit with ID " .. tostring(unit_id))
            end
        end
    else
        self._parent = true
        self._child_units = {}
        local n = 1
        for _, unit_id in ipairs(units) do
            local unit = wd:get_unit(unit_id)
            if unit then
                self._child_units[n] = unit
                n = n + 1
            else
                EHI:Log("[TimerGui] Cannot find unit with ID " .. tostring(unit_id))
            end
        end
    end
end

function TimerGui:SetWaypointPosition(pos)
    self._forced_pos = pos
    if self._started and pos then
        managers.ehi_waypoint:SetWaypointPosition(self._ehi_key, pos)
    end
end

function TimerGui:Finalize()
    if self._ignore or (self._remove_on_power_off and not self._powered) then
        self:RemoveTracker()
        return
    elseif self._icons then
        managers.ehi_manager:SetIcon(self._ehi_key, self._icons[1])
	end
    if self._started and not self._done and self._unit:mission_door_device() then
        self:PostStartTimer()
    end
end