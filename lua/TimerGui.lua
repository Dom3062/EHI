local EHI = EHI
if EHI._hooks.TimerGui then
	return
else
	EHI._hooks.TimerGui = true
end

if not EHI:GetOption("show_timers") then
    return
end

local show_waypoint = EHI:GetWaypointOption("show_waypoints_timers")
local show_waypoint_only = show_waypoint and EHI:GetWaypointOption("show_waypoints_only")
local level_id = Global.game_settings.level_id
-- [index] = Vector3(x, y, z)
local MissionDoorPositions = {}
-- [index] = { w_id = "Waypoint ID", restore = "If the waypoint should be restored when the drill finishes" }
---- See MissionDoor class how to get Drill position
---- Indexes must match or it won't work
local MissionDoorIndex = {}
if level_id == "framing_frame_1" or level_id == "gallery" then -- Framing Frame Day 1 / Art Gallery
    MissionDoorPositions =
    {
        -- Security doors
        [1] = Vector3(-827.08, 115.886, 92.4429),
        [2] = Vector3(-60.1138, 802.08, 92.4429),
        [3] = Vector3(-140.886, -852.08, 92.4429)
    }
    MissionDoorIndex =
    {
        [1] = { w_id = 103191 },
        [2] = { w_id = 103188 },
        [3] = { w_id = 103202 }
    }
elseif level_id == "arm_for" then -- Transport: Train Heist
    MissionDoorPositions =
    {
        -- Vaults
        [1] = Vector3(-150, -1100, 685),
        [2] = Vector3(-1750, -1200, 685),
        [3] = Vector3(750, -1200, 685),
        [4] = Vector3(2350, -1100, 685),
        [5] = Vector3(-2650, -1100, 685),
        [6] = Vector3(3250, -1200, 685)
    }
    MissionDoorIndex =
    {
        [1] = { w_id = 100835 },
        [2] = { w_id = 100253 },
        [3] = { w_id = 100838 },
        [4] = { w_id = 100840 },
        [5] = { w_id = 102288 },
        [6] = { w_id = 102593 }
    }
elseif level_id == "hox_2" then -- Hoxton Breakout Day 2
    local SecurityOffice = { w_id = EHI:GetInstanceElementID(100026, 6690) }
    MissionDoorPositions =
    {
        -- Evidence
        [1] = Vector3(-1552.84, 816.472, -9.11819),

        -- Basement (Escape)
        [2] = Vector3(-744.305, 5042.19, -409.118),

        -- Archives
        [3] = Vector3(817.472, 2884.84, -809.118),

        -- Security Office
        [4] = Vector3(-1207.53, 4234.84, -409.118),
        [5] = Vector3(807.528, 4265.16, -9.11819)
    }
    MissionDoorIndex =
    {
        [1] = { w_id = 101562 },
        [2] = { w_id = 102017 },
        [3] = { w_id = 101345 },
        [4] = SecurityOffice,
        [5] = SecurityOffice
    }
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
    self._ehi_icon = unit:base().is_drill and "pd2_drill" or unit:base().is_hacking_device and "wp_hack" or unit:base().is_saw and "pd2_generic_saw" or "faster"
end

function TimerGui:set_background_icons(background_icons, ...)
    original.set_background_icons(self, background_icons, ...)
    managers.ehi:SetTimerUpgrades(self._ehi_key, self:GetUpgrades())
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
    if managers.ehi:TrackerExists(self._ehi_key) then
        managers.ehi:SetTimerJammed(self._ehi_key, false)
        managers.ehi:SetTimerPowered(self._ehi_key, true)
        managers.ehi_waypoint:SetTimerWaypointJammed(self._ehi_key, false)
        managers.ehi_waypoint:SetTimerWaypointPowered(self._ehi_key, true)
    else
        local autorepair = self._unit:base()._autorepair
        if not show_waypoint_only then
            managers.ehi:AddTracker({
                id = self._ehi_key,
                time = self._current_timer,
                icons = self._icons or { { icon = self._ehi_icon } },
                theme = self.THEME,
                exclude_from_sync = true,
                class = "EHITimerTracker",
                upgrades = self:GetUpgrades(),
                autorepair = autorepair
            })
        end
        if show_waypoint then
            managers.ehi_waypoint:AddWaypoint(self._ehi_key, {
                time = self._current_timer,
                icon = self._icons or self._ehi_icon,
                pause_timer = 1,
                type = "timer",
                position = self._unit:interaction() and self._unit:interaction():interact_position() or self._unit:position(),
                color = autorepair and tweak_data.ehi.color.DrillAutorepair or Color.white
            })
        end
        self:PostStartTimer()
    end
end

function TimerGui:PostStartTimer()
    if self._unit:mission_door_device() then
        local data = self:GetMissionDoorData()
        if data then
            self._waypoint_id = data.w_id
            self._remove_vanilla_waypoint = true
            self._restore_vanilla_waypoint_on_done = data.restore
        end
    end
    if self._remove_vanilla_waypoint and show_waypoint then
        managers.hud:SoftRemoveWaypoint(self._waypoint_id)
        EHI._cache.IgnoreWaypoints[self._waypoint_id] = true
        EHI:DisableElementWaypoint(self._waypoint_id)
    end
end

function TimerGui:GetMissionDoorData()
    -- No clue on what I can't compare the vectors directly via == and I have to do string comparison
    -- What changed that the comparison is not valid ? Constellation ? Game had a bad sleep ?
    -- This should be changed in the future...
    -- Saving grace here is that this function only runs when the drill is from MissionDoor class, which heists rarely use.
    local pos = tostring(self._unit:position())
    for i, p in ipairs(MissionDoorPositions) do
        if tostring(p) == pos then
            return MissionDoorIndex[i]
        end
    end
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
        managers.ehi_waypoint:SetTimerWaypointTime(self._ehi_key, self._time_left)
        original.update(self, ...)
    end
elseif show_waypoint then
    function TimerGui:update(...)
        managers.ehi:SetTrackerTimeNoAnim(self._ehi_key, self._time_left)
        managers.ehi_waypoint:SetTimerWaypointTime(self._ehi_key, self._time_left)
        original.update(self, ...)
    end
else
    function TimerGui:update(...)
        managers.ehi:SetTrackerTimeNoAnim(self._ehi_key, self._time_left)
        original.update(self, ...)
    end
end

function TimerGui:_set_done(...)
    managers.ehi:RemoveTracker(self._ehi_key)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
    original._set_done(self, ...)
    if self._restore_vanilla_waypoint_on_done then
        EHI._cache.IgnoreWaypoints[self._waypoint_id] = nil
        managers.hud:RestoreWaypoint(self._waypoint_id)
        EHI:RestoreElementWaypoint(self._waypoint_id)
    end
end

function TimerGui:_set_jammed(jammed, ...)
    managers.ehi:SetTimerJammed(self._ehi_key, jammed)
    managers.ehi_waypoint:SetTimerWaypointJammed(self._ehi_key, jammed)
    original._set_jammed(self, jammed, ...)
end

function TimerGui:_set_powered(powered, ...)
    if powered == false and self._remove_on_power_off then
        managers.ehi:RemoveTracker(self._ehi_key)
        managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
    end
    managers.ehi:SetTimerPowered(self._ehi_key, powered)
    managers.ehi_waypoint:SetTimerWaypointPowered(self._ehi_key, powered)
    original._set_powered(self, powered, ...)
end

function TimerGui:set_visible(visible, ...)
    original.set_visible(self, visible, ...)
    if self._ignore_visibility then
        return
    end
    if visible == false then
        managers.ehi:RemoveTracker(self._ehi_key)
        managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
    end
end

function TimerGui:hide(...)
    managers.ehi:RemoveTracker(self._ehi_key)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
    original.hide(self, ...)
end

function TimerGui:destroy(...)
    managers.ehi:RemoveTracker(self._ehi_key)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
    original.destroy(self, ...)
end

function TimerGui:OnAlarm()
    self._ignore = true
    managers.ehi:RemoveTracker(self._ehi_key)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
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
    self._remove_vanilla_waypoint = true
    self._waypoint_id = waypoint_id
end

function TimerGui:SetIgnoreVisibility()
    self._ignore_visibility = true
end

function TimerGui:SetRestoreVanillaWaypointOnDone()
    self._restore_vanilla_waypoint_on_done = true
end

function TimerGui:Finalize()
    if self._ignore or (self._remove_on_power_off and not self._powered) then
        managers.ehi:RemoveTracker(self._ehi_key)
        managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
    elseif self._icons then
		managers.ehi:SetTrackerIcon(self._ehi_key, self._icons[1])
		managers.ehi_waypoint:SetWaypointIcon(self._ehi_key, self._icons[1])
	end
end