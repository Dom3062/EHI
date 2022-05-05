local EHI = EHI
if EHI._hooks.CoreWorldInstanceManager then
    return
else
    EHI._hooks.CoreWorldInstanceManager = true
end
EHI:Init()
local client = Network:is_client()
local debug_instance = false
local debug_unit = false
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers -- Tracker Type
local instance_index = 1
local used_start_indexes = {}
local instances =
{
    ["levels/instances/shared/obj_skm/world"] = -- Hostage in the Holdout mode
    {
        [100032] = { time = 7, id = "HostageRescue", icons = { "pd2_kill" }, class = TT.Warning },
        [100036] = { id = "HostageRescue", special_function = SF.RemoveTracker }
    },
    ["levels/instances/unique/pbr/pbr_mountain_comm_dish/world"] =
    {
        [100008] = { time = 5, id = "SatelliteC4Explosion", icons = { "pd2_c4" } }
    },
    ["levels/instances/unique/pbr/pbr_mountain_comm_dish_huge/world"] =
    {
        [100013] = { time = 5, id = "HugeSatelliteC4Explosion", icons = { "pd2_c4" } }
    },
    ["levels/instances/unique/fex/fex_explosives/world"] =
    {
        [100008] = { time = 60, id = "FexExplosivesTimer", icons = { "equipment_timer" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
        [100007] = { id = "FexExplosivesTimer", special_function = SF.PauseTracker }
    },
    ["levels/instances/unique/sand/sand_helicopter_turret/world"] =
    {
        [100027] = { id = "SandTurretTimer", icons = { EHI.Icons.Heli, "wp_sentry", "faster" }, special_function = SF.GetElementTimerAccurate, element = 100012, sync = true },
        [100024] = { id = "SandTurretTimer", special_function = SF.RemoveTracker }
    }
}

if client then
    instances["levels/instances/unique/sand/sand_helicopter_turret/world"][100027].time = EHI:IsDifficulty("death_sentence") and 90 or 60
    instances["levels/instances/unique/sand/sand_helicopter_turret/world"][100027].random_time = 30
end

local original =
{
    prepare_mission_data = CoreWorldInstanceManager.prepare_mission_data,
    prepare_unit_data = CoreWorldInstanceManager.prepare_unit_data,
    custom_create_instance = CoreWorldInstanceManager.custom_create_instance
}

function CoreWorldInstanceManager:prepare_mission_data(instance, ...)
    local instance_data = original.prepare_mission_data(self, instance, ...)
    local folder = instance.folder
    if instances[folder] then
        local start_index = instance.start_index
        if not used_start_indexes[start_index] then
        -- Don't compute the indexes again if the instance on this start_index has been computed already
        -- start_index is unique for instance in a heist, so this shouldn't break anything
            local instance_elements = instances[folder]
            local continent_data = managers.worlddefinition._continents[instance.continent]
            local triggers = {}
            for id, trigger in pairs(instance_elements) do
                local final_index = EHI:GetInstanceElementID(id, start_index, continent_data.base_id)
                triggers[final_index] = EHI:DeepClone(trigger)
                triggers[final_index].id = triggers[final_index].id .. instance_index
                if trigger.element then
                    triggers[final_index].element = EHI:GetInstanceElementID(trigger.element, start_index, continent_data.base_id)
                end
                if trigger.sync and client then
                    EHI:AddSyncTrigger(final_index, triggers[final_index])
                end
            end
            EHI:AddTriggers(triggers, "Trigger", {})
            used_start_indexes[start_index] = true
        end
        instance_index = instance_index + 1
    end
    if debug_instance then
        EHI:Log("Instance Folder: " .. tostring(folder))
        EHI:Log("Instance Start Index: " .. tostring(instance.start_index))
        EHI:Log("Instance Rotation: " .. tostring(instance.rotation))
    end
    return instance_data
end

if not EHI:GetOption("show_timers") then
    return
end

if not Global.game_settings then
    return
end

local level_id = Global.game_settings.level_id
local units =
{
    ["units/payday2/props/stn_prop_armory_shelf_ammo/stn_prop_armory_shelf_ammo"] = { f = "SetAmmoOffset" },
    ["units/pd2_dlc_spa/props/spa_prop_armory_shelf_ammo/spa_prop_armory_shelf_ammo"] = { f = "SetAmmoOffset" },

    ["units/pd2_dlc_old_hoxton/equipment/stn_interactable_computer_forensics/stn_interactable_computer_forensics"] = { icons = { "equipment_evidence" } },
    ["units/pd2_dlc_old_hoxton/equipment/stn_interactable_computer_security/stn_interactable_computer_security"] = { icons = { "equipment_harddrive" }, remove_vanilla_waypoint = true, waypoint_id = 100019 },
    ["units/pd2_dlc_casino/props/cas_prop_drill/cas_prop_drill"] = { icons = { "pd2_drill" }, ignore_visibility = true },
    ["units/pd2_dlc_chill/props/chl_prop_timer_small/chl_prop_timer_small"] = { icons = { "faster" } },
    ["units/pd2_dlc_help/props/hlp_interactable_controlswitch/hlp_interactable_controlswitch"] = { icons = { "faster" }, warning = true },
    ["units/pd2_dlc_help/props/hlp_interactable_wheel_timer/hlp_interactable_wheel_timer"] = { icons = { "faster" }, icon_on_pause = { "restarter" } },
    ["units/pd2_dlc_chas/equipment/chas_interactable_c4/chas_interactable_c4"] = { icons = { "pd2_c4" }, warning = true },
    ["units/pd2_dlc_chas/equipment/chas_interactable_c4_placeable/chas_interactable_c4_placeable"] = { icons = { "pd2_c4" }, f = "chasC4" },
    ["units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_01"] = { disable_set_visible = true },
    ["units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_02"] = { disable_set_visible = true },
    ["units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_03"] = { disable_set_visible = true },
    ["units/pd2_dlc_sand/equipment/sand_interactable_rotating_code_computer/sand_interactable_rotating_code_computer"] = { remove_on_pause = true, remove_on_alarm = true },
    ["units/pd2_dlc_sand/equipment/sand_interactable_defibrillator/sand_interactable_defibrillator"] = { icons = { "pd2_power" } },
    ["units/pd2_dlc_sand/equipment/sand_interactable_hack_computer/sand_interactable_hack_computer"] = { remove_vanilla_waypoint = true, waypoint_id = 100034 }
}
if level_id == "arm_for" or level_id == "hox_3" then -- Transport: Train Heist or Hoxton Revenge
    local warning = level_id == "hox_3" and true or nil
    local f = level_id == "hox_3" and "hox3Timer" or nil
    local icons = level_id == "arm_for" and { EHI.Icons.Vault } or nil
    units["units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer"] = { icons = icons, remove_on_alarm = true, remove_on_pause = level_id == "hox_3", warning = warning, f = f }
elseif level_id == "mus" then -- The Diamond
    units["units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer"] = { icons = { "faster" }, remove_on_pause = true, warning = true }
    units["units/payday2/props/gen_prop_security_timelock/gen_prop_security_timelock"] = { icons = { EHI.Icons.Keycard } }
    units["units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b"] = { remove_vanilla_waypoint = true, waypoint_id = 100050 }
elseif level_id == "hox_1" then -- Hoxton Breakout Day 1
    units["units/payday2/equipment/gen_interactable_drill_small/gen_interactable_drill_small"] = { remove_vanilla_waypoint = true, waypoint_id = 100090 }
    units["units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b"] = { f = "hox_1" }
elseif level_id == "hox_2" then -- Hoxton Breakout Day 2
    units["units/pd2_dlc_old_hoxton/equipment/stn_interactable_computer_forensics/stn_interactable_computer_forensics"].f = "hox_2_forensics"
elseif level_id == "sah" then -- Shacklethorne Auction
    units["units/payday2/props/gen_prop_security_timelock/gen_prop_security_timelock"] = { icons = { EHI.Icons.Vault } }
elseif level_id == "hvh" then -- Cursed Kill Room
    units["units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer"] = { icons = { EHI.Icons.Vault }, f = "hvhSafeTimer" }
elseif level_id == "nail" then -- Lab Rats
    units["units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer"] = { icons = { EHI.Icons.Vault }, f = "nailSafeTimer" }
elseif level_id == "cane" then -- Santa's Workshop
    -- OVK decided to use one timer for fire and fire recharge
	-- This class ignores them and that timer is implemented
	-- in cane.lua
    units["units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer"] = { icons = { EHI.Icons.Vault }, f = "caneSafeTimer" }
elseif level_id == "pbr" then -- Beneath the Mountain
    units["units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer"] = { icons = { "pd2_c4" } }
elseif level_id == "shoutout_raid" then -- Meltdown
    units["units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer"] = { ignore = true }
elseif level_id == "red2" then -- First World Bank
    units["units/payday2/equipment/gen_interactable_lance_large/gen_interactable_lance_large"] = { remove_vanilla_waypoint = true, waypoint_id = 100014 }
    units["units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b"] = { remove_vanilla_waypoint = true, waypoint_id = 100018 }
elseif level_id == "jolly" then -- Aftershock
    units["units/pd2_dlc_jolly/equipment/gen_interactable_saw/gen_interactable_saw"] = { remove_vanilla_waypoint = true, waypoint_id = 100070 }
elseif level_id == "mex" then -- Border Crossing
    units["units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer"] = { icons = { "pd2_c4" } }
elseif level_id == "chas" then -- Dragon Heist
    units["units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b"] = { remove_vanilla_waypoint = true, waypoint_id = 100017 }
elseif level_id == "sand" then -- Ukrainian Prisoner Heist
    units["units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer"] = { icons = { EHI.Icons.Vault }, remove_on_pause = true, remove_on_alarm = true }
    units["units/payday2/equipment/gen_interactable_drill_small/gen_interactable_drill_small_no_jam"] = { remove_vanilla_waypoint = true, waypoint_id = 100023 }
    -- Also includes a server hack objective (loud only)
    units["units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b"] = { remove_vanilla_waypoint = true, waypoint_id = 100017 }
end

function CoreWorldInstanceManager:prepare_unit_data(instance, continent_data, ...)
    local instance_data = original.prepare_unit_data(self, instance, continent_data, ...)
    for _, entry in ipairs(instance_data.statics or {}) do
        if units[entry.unit_data.name] then
            local unit_data = EHI:DeepClone(units[entry.unit_data.name])
            unit_data.instance = instance
            unit_data.instance_name = instance.name
            unit_data.instance_index = instance.start_index
            unit_data.continent_index = continent_data.base_id
            if unit_data.remove_vanilla_waypoint then
                unit_data.waypoint_id = EHI:GetInstanceElementID(unit_data.waypoint_id, instance.start_index, continent_data.base_id)
            end
            EHI._cache.InstanceUnits[entry.unit_data.unit_id] = unit_data
        end
    end
    return instance_data
end

function CoreWorldInstanceManager:custom_create_instance(instance_name, custom_data, ...)
    original.custom_create_instance(self, instance_name, custom_data, ...)
	local instance = self:get_instance_data_by_name(instance_name)
	if not instance then
		return
	end
    EHI:FinalizeUnits(EHI._cache.InstanceUnits)
end