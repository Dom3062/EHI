local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local Status = EHI.Const.Trackers.Achievement.Status
local SecurityTearGasRandomElement = EHI:GetInstanceElementID(100061, 6690)
local element_sync_triggers =
{
    [EHI:GetInstanceElementID(100062, 6690)] = { id = "SecurityOfficeTeargas", icons = { Icon.Teargas }, hook_element = SecurityTearGasRandomElement, hint = Hints.Teargas }, -- 45s
    [EHI:GetInstanceElementID(100063, 6690)] = { id = "SecurityOfficeTeargas", icons = { Icon.Teargas }, hook_element = SecurityTearGasRandomElement, hint = Hints.Teargas }, -- 55s
    [EHI:GetInstanceElementID(100064, 6690)] = { id = "SecurityOfficeTeargas", icons = { Icon.Teargas }, hook_element = SecurityTearGasRandomElement, hint = Hints.Teargas } -- 65s
}
local CheckOkValueHostCheckOnly
if EHI.Mission._SHOW_MISSION_TRACKERS then
    CheckOkValueHostCheckOnly = EHI.Trigger:RegisterCustomSF(function(self, trigger, element, ...) ---@param element ElementCounterFilter
        if EHI.IsHost and not element:_values_ok() then
            return
        elseif self._trackers:Exists(trigger.id) then
            self._trackers:SetProgress(trigger.id, trigger.progress)
        elseif not trigger.dont_create then
            self:CreateTracker()
        end
        self._cache.CurrentHackNumber = trigger.progress
    end)
else
    CheckOkValueHostCheckOnly = EHI.Trigger:RegisterCustomSF(function(self, trigger, element, ...) ---@param element ElementCounterFilter
        if EHI.IsHost and not element:_values_ok() then
            return
        end
        self._cache.CurrentHackNumber = trigger.progress
    end)
end
local hoxton_hack = { "hoxton_character" }
local request = { Icon.PCHack, Icon.Wait }
---@type table<number, Vector3?>
local PCVectors = {}
---@type ParseTriggerTable
local triggers = {
    [102016] = EHI:AddEndlessAssault(7),

    [104509] = { id = "HackRestartWait", icons = { Icon.PCHack, Icon.Loop }, hide_on_delete = true, run = { time = 30 }, special_function = EHI.Trigger:RegisterCustomSF(function(self, trigger, ...)
        if self._mission._SHOW_MISSION_TRACKERS then
            if self._trackers:DoesNotExist(trigger.id) then
                self._trackers:PreloadTracker(trigger)
            end
            self._trackers:RunTracker(trigger.id, trigger.run)
        end
        if trigger.waypoint_f then
            trigger.waypoint_f(self, trigger)
        end
    end), waypoint_f = function(self, trigger)
        local vector = PCVectors[self._cache.CurrentHackNumber or 0]
        if vector then
            self._waypoints:AddWaypoint(trigger.id, {
                time = trigger.run.time,
                icon = Icon.Loop,
                position = vector
            })
            self._waypoints:RemoveWaypoint("HoxtonHack")
            self._waypoints:RemoveWaypoint("HoxtonMaxHacks") -- In case the timer is merged with the progress
            return
        end
        if self._trackers:DoesNotExist(trigger.id) then
            self._trackers:PreloadTracker(trigger)
        end
        self._trackers:RunTrackerIfDoesNotExist(trigger.id, trigger.run)
    end, hint = Hints.Restarting },
    [101935] = { id = "HackRestartWait", special_function = SF.RemoveTracker }, -- Cleanup hidden tracker (if it is created)
    [102189] = EHI:AddCustomCode(function(self)
        self:CallEvent("hox_2_restore_waypoint_hack")
    end),

    [104478] = { id = "HoxtonMaxHacks", max = 4, progress = 1, show_progress_on_finish = true, icons = hoxton_hack, class = TT.Timer.Progress, special_function = CheckOkValueHostCheckOnly, hint = Hints.Hack },
    [104480] = { id = "HoxtonMaxHacks", max = 4, progress = 2, show_progress_on_finish = true, icons = hoxton_hack, class = TT.Timer.Progress, special_function = CheckOkValueHostCheckOnly, hint = Hints.Hack },
    [104481] = { id = "HoxtonMaxHacks", max = 4, progress = 3, show_progress_on_finish = true, icons = hoxton_hack, class = TT.Timer.Progress, special_function = CheckOkValueHostCheckOnly, hint = Hints.Hack },
    [104482] = { id = "HoxtonMaxHacks", max = 4, progress = 4, dont_create = true, icons = hoxton_hack, class = TT.Timer.Progress, special_function = CheckOkValueHostCheckOnly },

    [105113] = { chances = 4, id = "ForensicsMatchChance", icons = { "equipment_evidence" }, class = TT.Timer.Chance, hint = Hints.hox_2_Evidence },
    [102257] = EHI:AddCustomCode(function(self)
        self._trackers:CallFunction("ForensicsMatchChance", "IncreaseChanceIndex")
        self._waypoints:CallFunction("ForensicsMatchChanceWaypoint", "IncreaseChanceIndex") -- If the waypoint has the same ID, it will break the hack in TimerGui
    end),
    [105137] = { special_function = SF.RemoveTracker, data = { "ForensicsMatchChance", "ForensicsMatchChanceWaypoint" } }
}
if EHI.Mission._SHOW_MISSION_TRACKERS then
    triggers[104472] = { id = "HoxtonMaxHacks", max = 4, show_progress_on_finish = true, icons = hoxton_hack, class = TT.Timer.Progress, hint = Hints.Hack }
end
if EHI.Mission._SHOW_MISSION_WAYPOINTS then
    triggers[105113].waypoint_f = function(self, trigger) ---@param self EHIMissionElementTrigger
        self._waypoints:AddWaypointlessWaypoint("ForensicsMatchChanceWaypoint", {
            chances = trigger.chances,
            class = self.Waypoints.Less.Chance
        })
    end
    EHI.Element:AddWaypointToOverride(101559, "ForensicsMatchChanceWaypoint")
end

local PCHackWaypoint = { icon = Icon.Wait, position = Vector3(9, 4680, -2.2694) }
local tracker_merge =
{
    RequestCounter =
    {
        elements =
        {
            [104314] = { max = 4, icons = { Icon.PCHack }, class = TT.Timed.Progress, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.hox_2_Request },
            [104591] = { special_function = SF.IncreaseProgress },
            [104599] = { special_function = SF.RemoveTracker },
            [104579] = { time = 15, id = "RequestDelay", icons = request, waypoint = deep_clone(PCHackWaypoint), hint = Hints.Wait },
            [104580] = { time = 25, id = "RequestDelay", icons = request, waypoint = deep_clone(PCHackWaypoint), hint = Hints.Wait },
            [104581] = { time = 20, id = "RequestDelay", icons = request, waypoint = deep_clone(PCHackWaypoint), hint = Hints.Wait },
            [104582] = { time = 30, id = "RequestDelay", icons = request, waypoint = deep_clone(PCHackWaypoint), hint = Hints.Wait }, -- Disabled in the mission script
        }
    }
}
if EHI.IsClient then
    triggers[EHI:GetInstanceElementID(100055, 6690)] = { id = "SecurityOfficeTeargas", icons = { Icon.Teargas }, special_function = SF.SetRandomTime, data = { 45, 55, 65 }, hint = Hints.Teargas }
end

local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
---@type ParseAchievementTable
local achievements =
{
    slakt_3 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100107] = { class = TT.Achievement.Status },
            [101892] = { status = Status.Finish, special_function = SF.SetAchievementStatus },
            [100256] = { special_function = SF.SetAchievementFailed },
            [100258] = { special_function = SF.SetAchievementComplete }
        },
        load_sync = function(self)
            if self._utils:IsMissionElementEnabled(100270) then -- No keycard achievement
                self._unlockable:AddAchievementStatusTracker("slakt_3")
            end
        end
    },
    cac_26 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100107] = { status = Status.Objective, class = TT.Achievement.Status },
            [104485] = { status = Status.Defend, special_function = SF.SetAchievementStatus },
            [104520] = { status = Status.Objective, special_function = SF.SetAchievementStatus },
            [101884] = { status = Status.Finish, special_function = SF.SetAchievementStatus },
            [100320] = { special_function = SF.SetAchievementComplete },
            [100322] = { special_function = SF.SetAchievementFailed }
        }
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({}) -- 30s
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100358] = { chance = 10, time = 1 + 10 + 25, on_fail_refresh_t = 25, on_success_refresh_t = 20 + 10 + 25, id = "Snipers", class = TT.Sniper.Loop, sniper_count = 2 }
    other[100359] = EHI:CopyTrigger(other[100358], { sniper_count = 3 })
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI.Mission:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other,
    pre_parse = { filter_out_not_loaded_trackers = "show_timers" },
    sync_triggers = { element = element_sync_triggers },
    tracker_merge = tracker_merge
})
EHI.Trigger:AddLoadSyncFunction(function(self)
    local pc = managers.worlddefinition:get_unit(104418) --[[@as UnitTimer?]]
    local pc2 = managers.worlddefinition:get_unit(102413) --[[@as UnitTimer?]]
    local pc3 = managers.worlddefinition:get_unit(102414) --[[@as UnitTimer?]]
    local pc4 = managers.worlddefinition:get_unit(102415) --[[@as UnitTimer?]]
    if pc and pc2 and pc3 and pc4 then
        local timer = pc:timer_gui()
        local timer2 = pc2:timer_gui()
        local timer3 = pc3:timer_gui()
        local timer4 = pc4:timer_gui()
        if not timer._started then
            self:RunTrigger(104472)
        elseif (timer._started or timer._done) and not (timer2._started or timer2._done) then
            self:RunTrigger(104478)
        elseif (timer2._started or timer2._done) and not (timer3._started or timer3._done) then
            self:RunTrigger(104480)
        elseif (timer3._started or timer3._done) and not (timer4._started or timer4._done) then
            self:RunTrigger(104481)
        else
            self._cache.CurrentHackNumber = 4
        end -- Pointless to query the last PC
    end
end)

---@param id number
---@param unit_data UnitUpdateDefinition
---@param unit UnitTimer
local function PCPosition(id, unit_data, unit)
    local pos = unit_data.pos --[[@as number]]
    PCVectors[pos] = unit:interaction() and unit:interaction():interact_position() or unit:position()
    unit:timer_gui():SetCustomID("HoxtonHack")
    unit:timer_gui():SetTrackerMergeID("HoxtonMaxHacks", pos == 4)
    unit:timer_gui():SetCustomCallback("hox_2_restore_waypoint_hack", "add_waypoint")
end
---@type ParseUnitsTable
local tbl =
{
    --units/pd2_dlc_old_hoxton/equipment/stn_interactable_computer_director/stn_interactable_computer_director
    [102104] = { remove_vanilla_waypoint = 104571, restore_waypoint_on_done = true },

    [104418] = { f = PCPosition, pos = 1 },
    [102413] = { f = PCPosition, pos = 2 },
    [102414] = { f = PCPosition, pos = 3 },
    [102415] = { f = PCPosition, pos = 4 },

    --levels/instances/unique/hox_fbi_forensic_device
    --units/pd2_dlc_old_hoxton/equipment/stn_interactable_computer_forensics/stn_interactable_computer_forensics
    [EHI:GetInstanceUnitID(100018, 2650)] = { remove_vanilla_waypoint_overriden = { id = 101559, waypoint = "ForensicsMatchChanceWaypoint" }, restore_waypoint_on_done = true, tracker_merge_id = "ForensicsMatchChance" },

    --levels/instances/unique/hox_fbi_armory
    --units/pd2_dlc2/architecture/gov_d_int/gov_d_int_door_b/001
    [EHI:GetInstanceUnitID(100003, 6840)] = { f = function(...)
        local units, n = {}, 1
        local wd = managers.worlddefinition
        for i = 100004, 100007, 1 do
            local _unit = wd:get_unit(EHI:GetInstanceUnitID(i, 6840))
            if _unit then
                units[n] = _unit
                n = n + 1
            end
        end
        do
            local _unit = wd:get_unit(EHI:GetInstanceUnitID(100019, 6840))
            if _unit then
                units[n] = _unit
                n = n + 1
            end
        end
        do
            local _unit = wd:get_unit(EHI:GetInstanceUnitID(100020, 6840))
            if _unit then
                units[n] = _unit
                n = n + 1
            end
        end
        for i = 100024, 100030, 1 do
            local _unit = wd:get_unit(EHI:GetInstanceUnitID(i, 6840))
            if _unit then
                units[n] = _unit
                n = n + 1
            end
        end
        local pos =
        {
            -- Upper
            tostring(Vector3(1816.87, 3664.57, 17.2887)), -- Keycard
            tostring(Vector3(1817.05, 3659.48, 45.4985)), -- ECM

            -- Lower
            tostring(Vector3(-2216.87, 2410.43, -382.711)), -- Keycard
            tostring(Vector3(-2217.05, 2415.52, -354.502)) -- ECM
        }
        local execute = true
        Hooks:PostHook(MissionDoorDeviceInteractionExt, "set_active", "EHI_100003_6840_set_active", function(self, active, ...)
            if active == false and execute then
                local u_pos = tostring(self._unit:position())
                for _, unit_pos in ipairs(pos) do
                    if unit_pos == u_pos then
                        for _, u in ipairs(units) do
                            if u:base() and u:base().SetCountThisUnit then
                                u:base():SetCountThisUnit()
                            end
                        end
                        execute = false
                        break
                    end
                end
            end
        end)
        Hooks:PreHook(MissionDoorDeviceInteractionExt, "destroy", "EHI_100003_6840_destroy", function(...)
            execute = false
        end)
    end}
}
-- Armory
-- Ammo
for i = 100004, 100007, 1 do
    tbl[EHI:GetInstanceUnitID(i, 6840)] = { f = "IgnoreChildDeployable" }
end
-- Grenades
tbl[EHI:GetInstanceUnitID(100019, 6840)] = { f = "IgnoreChildDeployable" }
tbl[EHI:GetInstanceUnitID(100020, 6840)] = { f = "IgnoreChildDeployable" }
for i = 100024, 100030, 1 do
    tbl[EHI:GetInstanceUnitID(i, 6840)] = { f = "IgnoreChildDeployable" }
end
EHI:UpdateUnits(tbl)

local SecurityOffice = EHI:GetInstanceElementID(100026, 6690)
EHI:SetMissionDoorData({
    -- Evidence
    [Vector3(-1552.84, 816.472, -9.11819)] = 101562,

    -- Basement (Escape)
    [Vector3(-744.305, 5042.19, -409.118)] = 102017,

    -- Archives
    [Vector3(817.472, 2884.84, -809.118)] = 101345,

    -- Security Office
    [Vector3(-1207.53, 4234.84, -409.118)] = SecurityOffice,
    [Vector3(807.528, 4265.16, -9.11819)] = SecurityOffice
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 4000, name = "hox2_reached_server_room" },
        { amount = 8000, name = "hox2_random_obj" },
        { escape = 6000 },
        { amount = 4000, name = "hox2_no_keycard_bonus_xp", optional = true },
    },
    total_xp_override =
    {
        params =
        {
            min =
            {
                objectives = true
            }
        },
        objectives =
        {
            hox2_random_obj = { times = 3 }
        }
    }
})