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
-- [index] = { w_id = "Waypoint ID", restore = "If the waypoint should be restored when the drill finishes", w_ids = "Table of waypoints and their ID", unit_id = "ID of the door" }
---- See MissionDoor class how to get Drill position
---- Indexes must match or it won't work
---- "w_ids" has a higher priority than "w_id"
local MissionDoorIndex = {}
if level_id == "firestarter_2" then -- Firestarter Day 2
    MissionDoorPositions =
    {
        -- Security doors
        [1] = Vector3(-2357.87, -3621.42, 489.107),
        [2] = Vector3(1221.42, -2957.87, 489.107),
        [3] = Vector3(1342.13, -2621.42, 89.1069), --101867
        [4] = Vector3(-2830.08, 341.886, 492.443) --102199
    }
    MissionDoorIndex =
    {
        [1] = { w_id = 101899 },
        [2] = { w_id = 101834 },
        [3] = { w_id = 101782 },
        [4] = { w_id = 101783 }
    }
elseif level_id == "framing_frame_1" or level_id == "gallery" then -- Framing Frame Day 1 / Art Gallery
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
elseif level_id == "big" then -- Big Bank
    MissionDoorPositions =
    {
        -- Server Room
        [1] = Vector3(733.114, 1096.92, -907.557),
        [2] = Vector3(1419.89, -1897.92, -907.557),
        [3] = Vector3(402.08, -1266.89, -507.56),

        -- Roof
        [4] = Vector3(503.08, 1067.11, 327.432),
        [5] = Vector3(503.08, -1232.89, 327.432),
        [6] = Vector3(3446.92, -1167.11, 327.432),
        [7] = Vector3(3466.11, 1296.92, 327.432)
    }
    MissionDoorIndex =
    {
        [1] = { w_id = 103457, restore = true, unit_id = 104582 },
        [2] = { w_id = 103461, restore = true, unit_id = 104584 },
        [3] = { w_id = 103465, restore = true, unit_id = 104585 },
        [4] = { w_id = 101306, restore = true, unit_id = 100311 },
        [5] = { w_id = 106362, restore = true, unit_id = 103322 },
        [6] = { w_id = 106372, restore = true, unit_id = 105317 },
        [7] = { w_id = 106382, restore = true, unit_id = 106336 },
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
elseif level_id == "born" then -- The Biker Heist Day 1
    MissionDoorPositions =
    {
        -- Workshop
        [1] = Vector3(-3798.92, -1094.9, -6.52779),

        -- Safe with bike mask
        [2] = Vector3(1570.02, -419.693, 185.724)
    }
    MissionDoorIndex =
    {
        [1] = { w_id = 101580 },
        [2] = { w_ids = { EHI:GetInstanceElementID(100007, 4850), EHI:GetInstanceElementID(100007, 5350) } }
    }
elseif level_id == "constantine_smackdown2_lvl" then -- Truck Hustle
    MissionDoorPositions =
    {
        [1] = Vector3(5636.56, 7026.42, -1877.75),
        [2] = Vector3(5743.57, 5743.44, -1877.75),
        [3] = Vector3(5260.62, 5334.95, -1890.75),
        [4] = Vector3(-4420.84, -4693.55, -1877.75),
        [5] = Vector3(-3930.91, -4684.99, -1877.75),
        [6] = Vector3(-4313.83, -5976.53, -1877.75)
    }
    MissionDoorIndex =
    {
        [1] = { w_id = EHI:GetInstanceElementID(100006, 0) },
        [2] = { w_id = EHI:GetInstanceElementID(100006, 250) },
        [3] = { w_id = EHI:GetInstanceElementID(100006, 500) },
        [4] = { w_id = EHI:GetInstanceElementID(100006, 750) },
        [5] = { w_id = EHI:GetInstanceElementID(100006, 1000) },
        [6] = { w_id = EHI:GetInstanceElementID(100006, 1250) }
    }
end

function TimerGui.SetMissionDoorPosAndIndex(pos, index)
    MissionDoorPositions = pos
    MissionDoorIndex = index
    EHI:PrintTable(MissionDoorPositions)
    EHI:PrintTable(MissionDoorIndex)
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
    local icon = unit:base().is_drill and "pd2_drill" or unit:base().is_hacking_device and "wp_hack" or unit:base().is_saw and "pd2_generic_saw" or "faster"
    self._ehi_icon = { { icon = icon } }
end

function TimerGui:set_background_icons(background_icons, ...)
    original.set_background_icons(self, background_icons, ...)
    managers.ehi:CallFunction(self._ehi_key, "SetUpgrades", self:GetUpgrades())
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
    if managers.ehi:TrackerExists(self._ehi_key) or managers.ehi_waypoint:WaypointExists(self._ehi_key) then
        managers.ehi:SetTimerJammed(self._ehi_key, false)
        managers.ehi:SetTimerPowered(self._ehi_key, true)
        managers.ehi_waypoint:SetTimerWaypointJammed(self._ehi_key, false)
        managers.ehi_waypoint:SetTimerWaypointPowered(self._ehi_key, true)
    else
        local autorepair = self._unit:base()._autorepair
        -- In case the conversion fails, fallback to "self._time_left" which is a number
        local t = tonumber(self._current_timer) or self._time_left
        if not show_waypoint_only then
            managers.ehi:AddTracker({
                id = self._ehi_key,
                time = t,
                icons = self._icons or self._ehi_icon,
                theme = self.THEME,
                exclude_from_sync = true,
                class = "EHITimerTracker",
                upgrades = self:GetUpgrades(),
                autorepair = autorepair
            })
        end
        if show_waypoint then
            managers.ehi_waypoint:AddWaypoint(self._ehi_key, {
                time = t,
                icon = self._icons or self._ehi_icon[1].icon,
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
            self._remove_vanilla_waypoint = true
            self._restore_vanilla_waypoint_on_done = data.restore
            if data.w_ids then
                for _, id in ipairs(data.w_ids) do
                    self._waypoint_id = id
                    self:HideWaypoint()
                end
                return
            else
                self._waypoint_id = data.w_id
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
            end
        end
    end
    self:HideWaypoint()
end

function TimerGui:HideWaypoint()
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
    self:RemoveTracker()
    original._set_done(self, ...)
    self:RestoreWaypoint()
end

function TimerGui:RestoreWaypoint()
    if self._restore_vanilla_waypoint_on_done and self._waypoint_id then
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
        self:RemoveTracker()
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
    managers.ehi:RemoveTracker(self._ehi_key)
    managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
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
    self._remove_vanilla_waypoint = true
    self._waypoint_id = waypoint_id
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

function TimerGui:Finalize()
    if self._ignore or (self._remove_on_power_off and not self._powered) then
        self:RemoveTracker()
    elseif self._icons then
		managers.ehi:SetTrackerIcon(self._ehi_key, self._icons[1])
		managers.ehi_waypoint:SetWaypointIcon(self._ehi_key, self._icons[1])
	end
end