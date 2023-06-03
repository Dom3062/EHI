local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local SecurityTearGasRandomElement = EHI:GetInstanceElementID(100061, 6690)
local element_sync_triggers =
{
    [EHI:GetInstanceElementID(100062, 6690)] = { id = "SecurityOfficeTeargas", icons = { Icon.Teargas }, hook_element = SecurityTearGasRandomElement }, -- 45s
    [EHI:GetInstanceElementID(100063, 6690)] = { id = "SecurityOfficeTeargas", icons = { Icon.Teargas }, hook_element = SecurityTearGasRandomElement }, -- 55s
    [EHI:GetInstanceElementID(100064, 6690)] = { id = "SecurityOfficeTeargas", icons = { Icon.Teargas }, hook_element = SecurityTearGasRandomElement } -- 65s
}
local request = { Icon.PCHack, Icon.Wait }
local hoxton_hack = { "hoxton_character" }
local CheckOkValueHostCheckOnly = EHI:GetFreeCustomSpecialFunctionID()
local PCHackWaypoint = { icon = Icon.Wait, position = Vector3(9, 4680, -2.2694) }
local triggers = {
    [102016] = { time = 7, id = "Endless", icons = Icon.EndlessAssault, class = TT.Warning },

    [104579] = { time = 15, id = "Request", icons = request, waypoint = deep_clone(PCHackWaypoint) },
    [104580] = { time = 25, id = "Request", icons = request, waypoint = deep_clone(PCHackWaypoint) },
    [104581] = { time = 20, id = "Request", icons = request, waypoint = deep_clone(PCHackWaypoint) },
    [104582] = { time = 30, id = "Request", icons = request, waypoint = deep_clone(PCHackWaypoint) }, -- Disabled in the mission script

    [104509] = { time = 30, id = "HackRestartWait", icons = { Icon.PCHack, Icon.Loop } },

    [104314] = { max = 4, id = "RequestCounter", icons = { Icon.PCHack }, class = TT.Progress, special_function = SF.AddTrackerIfDoesNotExist },

    [104599] = { id = "RequestCounter", special_function = SF.RemoveTracker },

    [104591] = { id = "RequestCounter", special_function = SF.IncreaseProgress },

    [104472] = { max = 4, id = "HoxtonMaxHacks", icons = hoxton_hack, class = TT.Progress },
    [104478] = { max = 4, id = "HoxtonMaxHacks", icons = hoxton_hack, class = TT.Progress, special_function = CheckOkValueHostCheckOnly, data = { progress = 1 } },
    [104480] = { max = 4, id = "HoxtonMaxHacks", icons = hoxton_hack, class = TT.Progress, special_function = CheckOkValueHostCheckOnly, data = { progress = 2 } },
    [104481] = { max = 4, id = "HoxtonMaxHacks", icons = hoxton_hack, class = TT.Progress, special_function = CheckOkValueHostCheckOnly, data = { progress = 3 } },
    [104482] = { max = 4, id = "HoxtonMaxHacks", icons = hoxton_hack, class = TT.Progress, special_function = CheckOkValueHostCheckOnly, data = { progress = 4, dont_create = true } },

    [105113] = { chance = 25, id = "ForensicsMatchChance", icons = { "equipment_evidence" }, class = TT.Chance },
    [102257] = { amount = 25, id = "ForensicsMatchChance", special_function = SF.IncreaseChance },
    [105137] = { id = "ForensicsMatchChance", special_function = SF.RemoveTracker }
}
if EHI:IsClient() then
    triggers[EHI:GetInstanceElementID(100055, 6690)] = { id = "SecurityOfficeTeargas", icons = { Icon.Teargas }, class = TT.Inaccurate, special_function = SF.SetRandomTime, data = { 45, 55, 65 } }
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
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
            [100107] = { class = TT.AchievementStatus },
            [100256] = { special_function = SF.SetAchievementFailed },
            [100258] = { special_function = SF.SetAchievementComplete }
        },
        load_sync = function(self)
            if self._trackers:IsMissionElementEnabled(100270) then -- No keycard achievement
                self._trackers:AddAchievementStatusTracker("slakt_3")
            end
        end
    },
    cac_26 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100107] = { status = "objective", class = TT.AchievementStatus },
            [104485] = { status = "defend", special_function = SF.SetAchievementStatus },
            [104520] = { status = "objective", special_function = SF.SetAchievementStatus },
            [101884] = { status = "finish", special_function = SF.SetAchievementStatus },
            [100320] = { special_function = SF.SetAchievementComplete },
            [100322] = { special_function = SF.SetAchievementFailed }
        }
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 30 })
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:RegisterCustomSpecialFunction(CheckOkValueHostCheckOnly, function(self, trigger, element, ...)
    local continue = false
    if EHI:IsHost() then
        continue = element:_values_ok()
    else
        continue = true
    end
    if continue then
        if self._trackers:TrackerExists(trigger.id) then
            self._trackers:SetTrackerProgress(trigger.id, trigger.data.progress)
        elseif not trigger.data.dont_create then
            self:CheckCondition(trigger)
            self._trackers:SetTrackerProgress(trigger.id, trigger.data.progress)
        end
    end
end)
EHI:AddLoadSyncFunction(function(self)
    local pc = managers.worlddefinition:get_unit(104418) -- 1
    local pc2 = managers.worlddefinition:get_unit(102413) -- 2
    local pc3 = managers.worlddefinition:get_unit(102414) -- 3
    local pc4 = managers.worlddefinition:get_unit(102415) -- 4
    if pc and pc2 and pc3 and pc4 then
        local timer = pc:timer_gui()
        local timer2 = pc2:timer_gui()
        local timer3 = pc3:timer_gui()
        local timer4 = pc4:timer_gui()
        if (timer._started or timer._done) and not (timer2._started or timer2._done) then
            self:Trigger(104478)
        elseif (timer2._started or timer2._done) and not (timer3._started or timer3._done) then
            self:Trigger(104480)
        elseif (timer3._started or timer3._done) and not (timer4._started or timer4._done) then
            self:Trigger(104481)
        end
        -- Pointless to query the last PC
    else -- Just in case, but the PCs should exist
        return
    end
end)

local tbl =
{
    --units/pd2_dlc_old_hoxton/equipment/stn_interactable_computer_director/stn_interactable_computer_director
    [102104] = { remove_vanilla_waypoint = 104571, restore_waypoint_on_done = true },

    --levels/instances/unique/hox_fbi_forensic_device
    --units/pd2_dlc_old_hoxton/equipment/stn_interactable_computer_forensics/stn_interactable_computer_forensics
    [EHI:GetInstanceUnitID(100018, 2650)] = { icons = { "equipment_evidence" }, remove_vanilla_waypoint = 101559, restore_waypoint_on_done = true },

    --levels/instances/unique/hox_fbi_security_office
    --units/pd2_dlc_old_hoxton/equipment/stn_interactable_computer_security/stn_interactable_computer_security
    [EHI:GetInstanceUnitID(100068, 6690)] = { icons = { "equipment_harddrive" }, remove_vanilla_waypoint = EHI:GetInstanceElementID(100019, 6690) },

    --levels/instances/unique/hox_fbi_armory
    --units/pd2_dlc2/architecture/gov_d_int/gov_d_int_door_b/001
    [EHI:GetInstanceUnitID(100003, 6840)] = { f = function(...)
        local units = {}
        local n = 1
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
            Vector3(1816.87, 3664.57, 17.2887), -- Keycard
            Vector3(1817.05, 3659.48, 45.4985), -- ECM

            -- Lower
            Vector3(-2216.87, 2410.43, -382.711), -- Keycard
            Vector3(-2217.05, 2415.52, -354.502) -- ECM
        }
        local playing, enabled = true, true
        EHI:HookWithID(MissionDoorDeviceInteractionExt, "set_active", "EHI_100003_6840_set_active", function(self, active, ...)
            if playing and active == false and enabled then
                local u_pos = tostring(self._unit:position())
                for _, unit_pos in ipairs(pos) do
                    if tostring(unit_pos) == u_pos then
                        for _, _unit in ipairs(units) do
                            if _unit:base() and _unit:base().SetCountThisUnit then
                                _unit:base():SetCountThisUnit()
                            end
                        end
                        break
                    end
                end
                enabled = false
            end
        end)
        EHI:PreHookWithID(MissionDoorDeviceInteractionExt, "destroy", "EHI_100003_6840_destroy", function(...)
            playing = false
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
---@type MissionDoorTable
local MissionDoor =
{
    -- Evidence
    [Vector3(-1552.84, 816.472, -9.11819)] = 101562,

    -- Basement (Escape)
    [Vector3(-744.305, 5042.19, -409.118)] = 102017,

    -- Archives
    [Vector3(817.472, 2884.84, -809.118)] = 101345,

    -- Security Office
    [Vector3(-1207.53, 4234.84, -409.118)] = SecurityOffice,
    [Vector3(807.528, 4265.16, -9.11819)] = SecurityOffice
}
EHI:SetMissionDoorPosAndIndex(MissionDoor)
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