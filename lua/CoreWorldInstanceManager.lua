local EHI = EHI
if EHI._hooks.CoreWorldInstanceManager then
    return
else
    EHI._hooks.CoreWorldInstanceManager = true
end
EHI:Init()
local client = EHI:IsClient()
local debug_instance = false
local debug_unit = false
local Icon = EHI.Icons
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
        [100008] = { time = 5, id = "SatelliteC4Explosion", icons = { Icon.C4 } }
    },
    ["levels/instances/unique/pbr/pbr_mountain_comm_dish_huge/world"] =
    {
        [100013] = { time = 5, id = "HugeSatelliteC4Explosion", icons = { Icon.C4 } }
    },
    ["levels/instances/unique/fex/fex_explosives/world"] =
    {
        [100008] = { time = 60, id = "fexExplosivesTimer", icons = { "equipment_timer" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
        [100007] = { id = "fexExplosivesTimer", special_function = SF.PauseTracker }
    },
    ["levels/instances/unique/sand/sand_helicopter_turret/world"] =
    {
        [100027] = { id = "sandTurretTimer", icons = { Icon.Heli, Icon.Sentry, Icon.Wait }, special_function = SF.GetElementTimerAccurate, element = 100012, sync = true }
    }
}

if client then
    instances["levels/instances/unique/sand/sand_helicopter_turret/world"][100027].time = EHI:IsDifficulty(EHI.Difficulties.DeathSentence) and 90 or 60
    instances["levels/instances/unique/sand/sand_helicopter_turret/world"][100027].random_time = 30
    instances["levels/instances/unique/sand/sand_helicopter_turret/world"][100024] = { id = "sandTurretTimer", special_function = SF.RemoveTracker }
end

if EHI:GetOption("show_waypoints") then
    --instances["levels/instances/shared/obj_skm/world"][100032].waypoint = { position_by_element = 0, warning = true }
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
                if trigger.waypoint and trigger.waypoint.position_by_element then
                    triggers[final_index].waypoint.position_by_element = EHI:GetInstanceElementID(trigger.waypoint.position_by_element, start_index, continent_data.base_id)
                    triggers[final_index].waypoint.position = EHI:AddPositionFromElement(triggers[final_index].waypoint, true)
                end
                if trigger.sync and client then
                    EHI:AddSyncTrigger(final_index, triggers[final_index])
                end
            end
            EHI:ParseMissionTriggers(triggers)
            used_start_indexes[start_index] = true
        end
        instance_index = instance_index + 1
    end
    if debug_instance then
        EHI:Log("---------------SEPARATOR---------------")
        EHI:Log("Instance Folder: " .. tostring(folder))
        EHI:Log("Instance Start Index: " .. tostring(instance.start_index))
        EHI:Log("Instance Rotation: " .. tostring(instance.rotation))
    end
    return instance_data
end

local units =
{
    -- Doctor Bags
    ["units/payday2/props/stn_prop_medic_firstaid_box/stn_prop_medic_firstaid_box"] = { f = "SetDeployableOffset" }, -- CustomDoctorBagBase / cabinet 1
    ["units/pd2_dlc_casino/props/cas_prop_medic_firstaid_box/cas_prop_medic_firstaid_box"] = { f = "SetDeployableOffset" }, -- CustomDoctorBagBase / cabinet 2
    -- Ammo
    ["units/payday2/props/stn_prop_armory_shelf_ammo/stn_prop_armory_shelf_ammo"] = { f = "SetDeployableOffset" },
    ["units/pd2_dlc_spa/props/spa_prop_armory_shelf_ammo/spa_prop_armory_shelf_ammo"] = { f = "SetDeployableOffset" },
    ["units/pd2_dlc_hvh/props/hvh_prop_armory_shelf_ammo/hvh_prop_armory_shelf_ammo"] = { f = "SetDeployableOffset" },

    ["units/pd2_dlc_chas/equipment/chas_interactable_c4/chas_interactable_c4"] = { icons = { Icon.C4 }, warning = true },
    ["units/pd2_dlc_chas/equipment/chas_interactable_c4_placeable/chas_interactable_c4_placeable"] = { icons = { Icon.C4 }, f = "chasC4" },
    ["units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_01"] = { disable_set_visible = true },
    ["units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_02"] = { disable_set_visible = true },
    ["units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_03"] = { disable_set_visible = true }
}

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