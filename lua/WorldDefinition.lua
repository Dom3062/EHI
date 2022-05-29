local EHI = EHI
if EHI._hooks.WorldDefinition then
    return
else
    EHI._hooks.WorldDefinition = true
end

local original =
{
    init_done = WorldDefinition.init_done,
    create = WorldDefinition.create
}

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
                if type(unit_data.f) == "string" then
                    wd[unit_data.f](wd, unit_data.instance, id, unit_data, unit)
                else
                    unit_data.f(unit_data.instance, id, unit_data, unit)
                end
            else
                if unit:timer_gui() and unit:timer_gui()._ehi_key then
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
                        if unit_data.restore_waypoint_on_done then
                            unit:timer_gui():SetRestoreVanillaWaypointOnDone()
                        end
                    end
                    if unit_data.ignore_visibility then
                        unit:timer_gui():SetIgnoreVisibility()
                    end
                    unit:timer_gui():Finalize()
                end
                if unit:digital_gui() and unit:digital_gui()._ehi_key then
                    unit:digital_gui():SetIcons(unit_data.icons)
                    unit:digital_gui():SetIgnore(unit_data.ignore)
                    unit:digital_gui():SetRemoveOnPause(unit_data.remove_on_pause)
                    unit:digital_gui():SetWarning(unit_data.warning)
                    unit:digital_gui():SetCompletion(unit_data.completion)
                    if unit_data.remove_on_alarm then
                        unit:digital_gui():SetOnAlarm()
                    end
                    if unit_data.custom_callback then
                        unit:digital_gui():SetCustomCallback(unit_data.custom_callback.id, unit_data.custom_callback.f)
                    end
                    if unit_data.icon_on_pause then
                        unit:digital_gui():SetIconOnPause(unit_data.icon_on_pause[1])
                    end
                    if unit_data.ignore_visibility then
                        unit:digital_gui():SetIgnoreVisibility()
                    end
                    unit:digital_gui():Finalize()
                end
            end
            tbl[id] = nil
        end
    end
end

local Icon = EHI.Icons
local units =
{
    -- Copied from CoreWorldInstanceManager.lua
    ["units/payday2/props/stn_prop_armory_shelf_ammo/stn_prop_armory_shelf_ammo"] = { f = "SetAmmoOffset" },
    ["units/pd2_dlc_spa/props/spa_prop_armory_shelf_ammo/spa_prop_armory_shelf_ammo"] = { f = "SetAmmoOffset" },

    ["units/pd2_dlc_casino/props/cas_prop_drill/cas_prop_drill"] = { icons = { Icon.Drill }, ignore_visibility = true },
    ["units/pd2_dlc_chill/props/chl_prop_timer_small/chl_prop_timer_small"] = { icons = { Icon.Wait } },
    ["units/pd2_dlc_help/props/hlp_interactable_controlswitch/hlp_interactable_controlswitch"] = { icons = { Icon.Wait }, warning = true },
    ["units/pd2_dlc_help/props/hlp_interactable_wheel_timer/hlp_interactable_wheel_timer"] = { icons = { Icon.Wait }, icon_on_pause = { "restarter" } },
    ["units/pd2_dlc_chas/equipment/chas_interactable_c4/chas_interactable_c4"] = { icons = { Icon.C4 }, warning = true },
    ["units/pd2_dlc_chas/equipment/chas_interactable_c4_placeable/chas_interactable_c4_placeable"] = { icons = { Icon.C4 }, f = "chasC4" },
    ["units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_01"] = { disable_set_visible = true },
    ["units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_02"] = { disable_set_visible = true },
    ["units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_03"] = { disable_set_visible = true },
    ["units/pd2_dlc_sand/equipment/sand_interactable_rotating_code_computer/sand_interactable_rotating_code_computer"] = { remove_on_pause = true, remove_on_alarm = true },
    ["units/pd2_dlc_sand/equipment/sand_interactable_defibrillator/sand_interactable_defibrillator"] = { icons = { Icon.Power } },
    ["units/pd2_dlc_sand/equipment/sand_interactable_hack_computer/sand_interactable_hack_computer"] = { remove_vanilla_waypoint = true, waypoint_id = 100034 }
}

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

function WorldDefinition:init_done(...)
    EHI:FinalizeUnits(EHI._cache.MissionUnits)
    EHI:FinalizeUnits(EHI._cache.InstanceUnits)
    original.init_done(self, ...)
end

function WorldDefinition:SetAmmoOffset(instance, unit_id, unit_data, unit)
    if unit:base().SetOffset then
        unit:base():SetOffset(1)
    end
end

if not EHI:ShouldDisableWaypoints() then
    return
end

local chasC4 = {}
local level_id = Global.game_settings.level_id
if level_id == "welcome_to_the_jungle_2" then -- Big Oil Day 2
    units["units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b"] = { f = "big_oil_day2_WP" }
elseif level_id == "roberts" then -- GO Bank
    units["units/payday2/equipment/gen_interactable_lance_large/gen_interactable_lance_large"] = { remove_vanilla_waypoint = true, waypoint_id = 102899 }
    units["units/payday2/props/gen_prop_security_timelock/gen_prop_security_timelock"] = { icons = { Icon.Vault }, remove_on_pause = true }
elseif level_id == "election_day_1" then -- Election Day D1
    units["units/payday2/props/off_prop_eday_shipping_computer/off_prop_eday_shipping_computer"] = { f = "election_day_1" }
elseif level_id == "election_day_2" then -- Election Day D2
    units["units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b"] = { f = "election_day_2" }
elseif level_id == "big" then -- The Big Bank
    units["units/payday2/props/gen_prop_security_timelock/gen_prop_security_timelock"] = { icons = { Icon.Wait } }
elseif level_id == "help" then -- Prison Nightmare
    units["units/pd2_dlc_chill/props/chl_prop_timer_large/chl_prop_timer_large"] = { ignore = true }
elseif level_id == "pent" then -- Mountain Master
    units["units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer"] = { f = "pentAchievementTimer" }
end

function WorldDefinition:big_oil_day2_WP(instance, unit_id, unit_data, unit)
    if unit_id == 103320 then
        unit:timer_gui():RemoveVanillaWaypoint(100309)
    elseif unit_id == 101365 then
        unit:timer_gui():RemoveVanillaWaypoint(102499)
    else -- 101863
        unit:timer_gui():RemoveVanillaWaypoint(102498)
    end
end

function WorldDefinition:election_day_1(instance, unit_id, unit_data, unit)
    unit:timer_gui():SetIgnoreVisibility()
    unit:timer_gui():SetRestoreVanillaWaypointOnDone()
    if unit_id == 101210 then
        unit:timer_gui():RemoveVanillaWaypoint(101887)
    elseif unit_id == 101289 then
        unit:timer_gui():RemoveVanillaWaypoint(101910)
    elseif unit_id == 101316 then
        unit:timer_gui():RemoveVanillaWaypoint(101913)
    elseif unit_id == 101317 then
        unit:timer_gui():RemoveVanillaWaypoint(101914)
    elseif unit_id == 101318 then
        unit:timer_gui():RemoveVanillaWaypoint(101922)
    else -- 101320
        unit:timer_gui():RemoveVanillaWaypoint(101923)
    end
end

function WorldDefinition:election_day_2(instance, unit_id, unit_data, unit)
    if unit_id == 103064 then
        unit:timer_gui():RemoveVanillaWaypoint(103082)
    elseif unit_id == 103065 then
        unit:timer_gui():RemoveVanillaWaypoint(103083)
    else -- 103066
        unit:timer_gui():RemoveVanillaWaypoint(103084)
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

function WorldDefinition:hox_1(instance, unit_id, unit_data, unit)
    unit:timer_gui():SetRestoreVanillaWaypointOnDone()
    unit:timer_gui():RemoveVanillaWaypoint(EHI:GetInstanceElementID(100072, unit_data.instance_index, unit_data.continent_index))
end

function WorldDefinition:hox_2(instance, unit_id, unit_data, unit)
    unit:timer_gui():SetRestoreVanillaWaypointOnDone()
    unit:timer_gui():RemoveVanillaWaypoint(104571)
end

function WorldDefinition:hox_2_forensics(instance, unit_id, unit_data, unit)
    unit:timer_gui():SetIcons(unit_data.icons)
    unit:timer_gui():SetRestoreVanillaWaypointOnDone()
    unit:timer_gui():RemoveVanillaWaypoint(101559)
end

function WorldDefinition:hox3Timer(instance, unit_id, unit_data, unit)
    if EHI:GetBaseUnitID(unit_id, unit_data.instance_index, unit_data.continent_index) == 100090 then -- "hox_estate_panic_room" instance
        unit:digital_gui():SetIcons({ EHI.Icons.Vault })
    else
        unit:digital_gui():SetIcons({ Icon.Wait })
        unit:digital_gui():SetWarning(true)
    end
    unit:digital_gui():SetOnAlarm()
    unit:digital_gui():SetRemoveOnPause(true)
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

function WorldDefinition:pentAchievementTimer(instance, unit_id, unit_data, unit)
    if unit_id == 103872 then -- 002
        unit:digital_gui():SetIgnore(true)
    else
        unit:digital_gui():SetIcons(EHI:GetAchievementIcon("pent_10"))
        unit:digital_gui():SetRemoveOnPause(true)
        unit:digital_gui():SetWarning(true)
    end
end