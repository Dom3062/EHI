local EHI = EHI
if EHI._hooks.WorldDefinition then
    return
else
    EHI._hooks.WorldDefinition = true
end

function EHI:FinalizeUnitsClient()
    self:FinalizeUnits(self._cache.MissionUnits)
    self:FinalizeUnits(self._cache.InstanceUnits)
end

function EHI:FinalizeUnits(tbl)
    local wd = managers.worlddefinition
    for id, unit_data in pairs(tbl) do
        local unit = wd:get_unit(id)
        if unit then
            if unit_data.f then
                wd[unit_data.f](wd, unit_data.instance, id, unit_data, unit)
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
                    if unit_data.remove_vanilla_waypoint then
                        unit:timer_gui():RemoveVanillaWaypoint(unit_data.waypoint_id)
                    end
                    unit:timer_gui():Finalize()
                end
                if unit:digital_gui() then
                    unit:digital_gui():SetIcons(unit_data.icons)
                    unit:digital_gui():SetIgnore(unit_data.ignore)
                    unit:digital_gui():SetRemoveOnPause(unit_data.remove_on_pause)
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

if not EHI:GetOption("show_timers") then
    return
end

local original =
{
    init_done = WorldDefinition.init_done,
    create = WorldDefinition.create
}

local TT = EHI.Trackers

local chasC4 = {}

local _f_init_done = WorldDefinition.init_done
function WorldDefinition:init_done(...)
    EHI:FinalizeUnits(EHI._cache.MissionUnits)
    EHI:FinalizeUnits(EHI._cache.InstanceUnits)
    _f_init_done(self, ...)
end

local level_id = Global.game_settings.level_id
local units =
{
    ["units/pd2_dlc_dah/props/dah_prop_hack_box/dah_prop_hack_ipad_unit"] = { remove_on_power_off = true },

    -- Copied from CoreWorldInstanceManager.lua
    ["units/pd2_dlc_casino/props/cas_prop_drill/cas_prop_drill"] = { icons = { "pd2_drill" } },
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

if level_id == "firestarter_3" or level_id == "branchbank" or level_id == "branchbank_gold" or level_id == "branchbank_cash" or level_id == "branchbank_deposit" then -- Firestarter Day 3 or Branchbank heist
    units["units/payday2/equipment/gen_interactable_lance_large/gen_interactable_lance_large"] = { f = "firestarter_3_WP" }
elseif level_id == "roberts" then -- GO Bank
    units["units/payday2/equipment/gen_interactable_lance_large/gen_interactable_lance_large"] = { remove_vanilla_waypoint = true, waypoint_id = 102899 }
    units["units/payday2/props/gen_prop_security_timelock/gen_prop_security_timelock"] = { icons = { EHI.Icons.Vault }, remove_on_pause = true }
elseif level_id == "big" then -- The Big Bank
    units["units/payday2/props/gen_prop_security_timelock/gen_prop_security_timelock"] = { icons = { "faster" } }
elseif level_id == "hvh" then -- Cursed Kill Room
    units["units/pd2_dlc_chill/props/chl_prop_timer_large/chl_prop_timer_large"] = { ignore = true }
    units["units/pd2_dlc_chill/props/chl_prop_timer_small/chl_prop_timer_small"] = { icons = { "faster" }, f = "hvhTimer", custom_callback = { id = "hvhCleanUp", f = "remove" } }
elseif level_id == "help" then -- Prison Nightmare
    units["units/pd2_dlc_chill/props/chl_prop_timer_large/chl_prop_timer_large"] = { ignore = true }
end

function WorldDefinition:create(layer, offset, ...)
    local return_data = original.create(self, layer, offset, ...)
    if self._definition.statics then
        for _, values in ipairs(self._definition.statics) do
            if units[values.unit_data.name] and not values.unit_data.instance then
                EHI._cache.MissionUnits[values.unit_data.unit_id] = units[values.unit_data.name]
            end
        end
    end
    for _, continent in pairs(self._continent_definitions) do
        if continent.statics then
            for _, values in ipairs(continent.statics) do
                if units[values.unit_data.name] and not values.unit_data.instance then
                    EHI._cache.MissionUnits[values.unit_data.unit_id] = units[values.unit_data.name]
                end
            end
        end
    end
    return return_data
end

function WorldDefinition:firestarter_3_WP(instance, unit_id, unit_data, unit)
    if unit_id == 104674 then
        unit:timer_gui():RemoveVanillaWaypoint(102633)
    else
        unit:timer_gui():RemoveVanillaWaypoint(102752)
    end
end

function WorldDefinition:chasC4(instance, unit_id, unit_data, unit)
    if EHI:GetBaseUnitID(unit_id, unit_data.instance_index, unit_data.continent_index) == 100054 then
        unit:digital_gui():SetIcons(unit_data.icons)
    else
        unit:digital_gui():SetIgnore(true)
    end
end

function WorldDefinition:chasC4Finalize()
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
            local unit_max = self:get_unit(max)
            if unit_max and unit_max:digital_gui() then
                unit_max:digital_gui():SetIgnore(true)
            end
            local unit_min = self:get_unit(min)
            if unit_min and unit_min:digital_gui() then
                unit_min:digital_gui():SetIgnore(true)
            end
            local unit_middle = self:get_unit(middle)
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

function WorldDefinition:hox3Timer(instance, unit_id, unit_data, unit)
    if EHI:GetBaseUnitID(unit_id, unit_data.instance_index, unit_data.continent_index) == 100090 then -- "hox_estate_panic_room" instance
        unit:digital_gui():SetIcons({ EHI.Icons.Vault })
    else
        unit:digital_gui():SetIcons({ "faster" })
        unit:digital_gui():SetWarning(true)
    end
    unit:digital_gui():SetOnAlarm()
    unit:digital_gui():SetRemoveOnPause(true)
end

function WorldDefinition:hvhTimer(instance, unit_id, unit_data, unit)
    if unit_id == 100029 then
        unit:digital_gui():SetIgnore(true)
    else
        unit:digital_gui():SetIcons(unit_data.icons)
        unit:digital_gui():SetCustomCallback(unit_data.custom_callback.id, unit_data.custom_callback.f)
    end
end

function WorldDefinition:hvhSafeTimer(instance, unit_id, unit_data, unit)
    if EHI:GetBaseUnitID(unit_id, unit_data.instance_index, unit_data.continent_index) == 100029 then
        unit:digital_gui():SetIcons(unit_data.icons)
    else
        unit:digital_gui():SetIgnore(true)
    end
end

function WorldDefinition:nailSafeTimer(instance, unit_id, unit_data, unit)
    if EHI:GetBaseUnitID(unit_id, unit_data.instance_index, unit_data.continent_index) == 100227 then
        unit:digital_gui():SetIcons(unit_data.icons)
        unit:digital_gui():SetRemoveOnPause(true)
    else
        unit:digital_gui():SetIgnore(true)
    end
end

function WorldDefinition:caneSafeTimer(instance, unit_id, unit_data, unit)
    if EHI:GetBaseUnitID(unit_id, unit_data.instance_index, unit_data.continent_index) == 100014 then
        unit:digital_gui():SetIcons(unit_data.icons)
        unit:digital_gui():SetRemoveOnPause(true)
    else
        unit:digital_gui():SetIgnore(true)
    end
end