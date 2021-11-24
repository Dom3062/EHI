local EHI = EHI
if EHI._hooks.CoreWorldInstanceManager then
    return
else
    EHI._hooks.CoreWorldInstanceManager = true
end
local client = Network:is_client()
local debug_instance = false
local debug_unit = false
local SF = EHI.SpecialFunctions
local TT = -- Tracker Type
{
    MallcrasherMoney = "EHIMoneyCounterTracker",
    Warning = "EHIWarningTracker",
    Pausable = "EHIPausableTracker",
    Chance = "EHIChanceTracker",
    Progress = "EHIProgressTracker",
    Achievement = "EHIAchievementTracker",
    AchievementProgress = "EHIAchievementProgressTracker",
    AchievementNotification = "EHIAchievementNotificationTracker",
    Inaccurate = "EHIInaccurateTracker",
    InaccurateWarning = "EHIInaccurateWarningTracker"
}
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
        [100027] = { id = "TurretTimer", icons = { EHI.Icons.Heli, "wp_sentry", "faster" }, special_function = SF.GetElementTimerAccurate, element = 100012, sync = true },
        [100024] = { id = "TurretTimer", special_function = SF.RemoveTracker }
    }
}

if client then
    instances["levels/instances/unique/sand/sand_helicopter_turret/world"].time = Global.game_settings and EHI:DifficultyToIndex(Global.game_settings.difficulty) == 6 and 90 or 60
    instances["levels/instances/unique/sand/sand_helicopter_turret/world"].random_time = 30
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
    ["units/pd2_dlc_old_hoxton/equipment/stn_interactable_computer_forensics/stn_interactable_computer_forensics"] = { icons = { "equipment_evidence" } },
    ["units/pd2_dlc_old_hoxton/equipment/stn_interactable_computer_security/stn_interactable_computer_security"] = { icons = { "equipment_harddrive" } },
    ["units/pd2_dlc_casino/props/cas_prop_drill/cas_prop_drill"] = { icons = { "pd2_drill" } },
    ["units/pd2_dlc_chill/props/chl_prop_timer_small/chl_prop_timer_small"] = { icons = { "faster" } },
    ["units/pd2_dlc_help/props/hlp_interactable_controlswitch/hlp_interactable_controlswitch"] = { icons = { "faster" }, class = "EHIWarningTracker" },
    ["units/pd2_dlc_help/props/hlp_interactable_wheel_timer/hlp_interactable_wheel_timer"] = { icons = { "faster" }, icon_on_pause = { "restarter" } },
    ["units/pd2_dlc_chas/equipment/chas_interactable_c4/chas_interactable_c4"] = { icons = { "pd2_c4" }, warning = true },
    ["units/pd2_dlc_chas/equipment/chas_interactable_c4_placeable/chas_interactable_c4_placeable"] = { icons = { "pd2_c4" }, f = "chasC4" },
    ["units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_01"] = { disable_set_visible = true },
    ["units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_02"] = { disable_set_visible = true },
    ["units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_03"] = { disable_set_visible = true },
    ["units/pd2_dlc_sand/equipment/sand_interactable_rotating_code_computer/sand_interactable_rotating_code_computer"] = { remove_on_pause = true, remove_on_alarm = true },
    ["units/pd2_dlc_sand/equipment/sand_interactable_defibrillator/sand_interactable_defibrillator"] = { icons = { "pd2_power" } }
}
if level_id == "arm_for" or level_id == "hox_3" then -- Transport: Train Heist or Hoxton Revenge
    local class = level_id == "hox_3" and "EHIWarningTracker" or nil
    local f = level_id == "hox_3" and "hox3Timer" or nil
    local icons = level_id == "arm_for" and { EHI.Icons.Vault } or nil
    units["units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer"] = { icons = icons, remove_on_alarm = true, remove_on_pause = level_id == "hox_3", class = class, f = f }
elseif level_id == "mus" then -- The Diamond
    units["units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer"] = { icons = { "faster" }, remove_on_pause = true }
    units["units/payday2/props/gen_prop_security_timelock/gen_prop_security_timelock"] = { icons = { EHI.Icons.Keycard } }
elseif level_id == "sah" then -- Shacklethorne Auction
    units["units/payday2/props/gen_prop_security_timelock/gen_prop_security_timelock"] = { icons = { EHI.Icons.Vault } }
elseif level_id == "hvh" then -- Cursed Kill Room
    units["units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer"] = { icons = { EHI.Icons.Vault }, f = "hvhSafeTimer" }
elseif level_id == "nail" then -- Lab Rats
    units["units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer"] = { icons = { EHI.Icons.Vault }, f = "nailSafeTimer" }
elseif level_id == "cane" then -- Santa's Workshop
    -- OVK decided to use one timer for fire and fire recharge
	-- This class ignores them and that timer is implemented
	-- in MissionScriptElement.lua
    units["units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer"] = { icons = { EHI.Icons.Vault }, f = "caneSafeTimer" }
elseif level_id == "pbr" then -- Beneath the Mountain
    units["units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer"] = { icons = { "pd2_c4" } }
elseif level_id == "shoutout_raid" then -- Meltdown
    units["units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer"] = { ignore = true }
elseif level_id == "sand" then -- Dragon Heist
    units["units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer"] = { icons = { EHI.Icons.Vault }, remove_on_pause = true, remove_on_alarm = true }
end

local chasC4 = {}

function CoreWorldInstanceManager:prepare_unit_data(instance, continent_data, ...)
    local instance_data = original.prepare_unit_data(self, instance, continent_data, ...)
    for _, entry in ipairs(instance_data.statics or {}) do
        if units[entry.unit_data.name] then
            local unit_data = EHI:DeepClone(units[entry.unit_data.name])
            unit_data.instance = instance
            unit_data.instance_name = instance.name
            unit_data.instance_index = instance.start_index
            unit_data.continent_index = continent_data.base_id
            EHI._cache.InstanceUnits[entry.unit_data.unit_id] = unit_data
        end
    end
    return instance_data
end

function CoreWorldInstanceManager:chasC4(instance, unit_id, unit_data, unit)
    if EHI:GetBaseUnitID(unit_id, unit_data.instance_index, unit_data.continent_index) == 100054 then
        unit:digital_gui():SetIcons(unit_data.icons)
    else
        unit:digital_gui():SetIgnore(true)
    end
end

function CoreWorldInstanceManager:chasC4Finalize()
    for instance_name, instance_c4 in pairs(chasC4) do
        if table.size(instance_c4) == 3 then
            local max, min, middle, unit_data = -math.huge, math.huge, 0, nil
            for id, u_data in pairs(instance_c4) do
                if max < id then
                    middle = max
                    max = id
                end
                if min > id then
                    min = id
                end
                unit_data = u_data
            end
            local unit_max = managers.worlddefinition:get_unit(max)
            if unit_max and unit_max:digital_gui() then
                unit_max:digital_gui():SetIgnore(true)
            end
            local unit_min = managers.worlddefinition:get_unit(min)
            if unit_min and unit_min:digital_gui() then
                unit_min:digital_gui():SetIgnore(true)
            end
            local unit_middle = managers.worlddefinition:get_unit(middle)
            if unit_middle and unit_middle:digital_gui() then
                unit_middle:digital_gui():SetIcons(unit_data.icons)
            end
            if unit_max and unit_min and unit_middle then
                chasC4[instance_name] = nil
            end
        else
            self:FinalizeUnits(instance_c4)
        end
    end
end

function CoreWorldInstanceManager:hox3Timer(instance, unit_id, unit_data, unit)
    if EHI:GetBaseUnitID(unit_id, unit_data.instance_index, unit_data.continent_index) == 100090 then -- "hox_estate_panic_room" instance
        unit:digital_gui():SetIcons({ EHI.Icons.Vault })
    else
        unit:digital_gui():SetIcons({ "faster" })
        unit:digital_gui():SetClass("EHIWarningTracker")
    end
    unit:digital_gui():SetOnAlarm()
    unit:digital_gui():SetRemoveOnPause(true)
end

function CoreWorldInstanceManager:hvhSafeTimer(instance, unit_id, unit_data, unit)
    if EHI:GetBaseUnitID(unit_id, unit_data.instance_index, unit_data.continent_index) == 100029 then
        unit:digital_gui():SetIcons(unit_data.icons)
    else
        unit:digital_gui():SetIgnore(true)
    end
end

function CoreWorldInstanceManager:nailSafeTimer(instance, unit_id, unit_data, unit)
    if EHI:GetBaseUnitID(unit_id, unit_data.instance_index, unit_data.continent_index) == 100227 then
        unit:digital_gui():SetIcons(unit_data.icons)
        unit:digital_gui():SetRemoveOnPause(true)
    else
        unit:digital_gui():SetIgnore(true)
    end
end

function CoreWorldInstanceManager:caneSafeTimer(instance, unit_id, unit_data, unit)
    if EHI:GetBaseUnitID(unit_id, unit_data.instance_index, unit_data.continent_index) == 100014 then
        unit:digital_gui():SetIcons(unit_data.icons)
        unit:digital_gui():SetRemoveOnPause(true)
        unit:digital_gui():SetIgnoreVisibility(true)
    else
        unit:digital_gui():SetIgnore(true)
    end
end

function CoreWorldInstanceManager:custom_create_instance(instance_name, custom_data, ...)
    original.custom_create_instance(self, instance_name, custom_data, ...)
	local instance = self:get_instance_data_by_name(instance_name)
	if not instance then
		return
	end
    self:Finalize()
end

function CoreWorldInstanceManager:Finalize()
    self:FinalizeUnits(EHI._cache.InstanceUnits)
end

function CoreWorldInstanceManager:FinalizeUnits(tbl)
    -- Finalize found units
    for id, unit_data in pairs(tbl) do
        local unit = managers.worlddefinition:get_unit(id)
        if unit then
            if unit_data.f then
                self[unit_data.f](self, unit_data.instance_name, id, unit_data, unit)
            else
                if unit:timer_gui() then
                    unit:timer_gui():SetIcons(unit_data.icons)
                    unit:timer_gui():SetRemoveOnPowerOff(unit_data.remove_on_power_off)
                    if unit_data.disable_set_visible then
                        unit:timer_gui():DisableOnSetVisible()
                    end
                    if unit_data.remove_on_alarm then
                        unit:timer_gui():SetOnAlarm()
                    end
                    unit:timer_gui():Finalize()
                end
                if unit:digital_gui() then
                    unit:digital_gui():SetIcons(unit_data.icons)
                    unit:digital_gui():SetIgnore(unit_data.ignore)
                    unit:digital_gui():SetRemoveOnPause(unit_data.remove_on_pause)
                    unit:digital_gui():SetClass(unit_data.class)
                    unit:digital_gui():SetWarning(unit_data.warning)
                    if unit_data.remove_on_alarm then
                        unit:digital_gui():SetOnAlarm()
                    end
                    if unit_data.custom_callback then
                        unit:digital_gui():SetCustomCallback(unit_data.custom_callback.id, unit_data.custom_callback.f)
                    end
                    if unit_data.icon_on_pause then
                        unit:digital_gui():SetIconOnPause(unit_data.icon_on_pause[1])
                    end
                    unit:digital_gui():Finalize()
                end
            end
            tbl[id] = nil
        end
    end
end