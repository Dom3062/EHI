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
                    if unit_data.remove_vanilla_waypoint then
                        unit:digital_gui():RemoveVanillaWaypoint(unit_data.waypoint_id)
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
    ["units/pd2_dlc_hvh/props/hvh_prop_armory_shelf_ammo/hvh_prop_armory_shelf_ammo"] = { f = "SetAmmoOffset" },

    ["units/pd2_dlc_chas/equipment/chas_interactable_c4/chas_interactable_c4"] = { icons = { Icon.C4 }, warning = true },
    ["units/pd2_dlc_chas/equipment/chas_interactable_c4_placeable/chas_interactable_c4_placeable"] = { icons = { Icon.C4 }, f = "chasC4" },
    ["units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_01"] = { disable_set_visible = true },
    ["units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_02"] = { disable_set_visible = true },
    ["units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_03"] = { disable_set_visible = true }
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
    if unit:base() and unit:base().SetOffset then
        unit:base():SetOffset(1)
    end
end

function WorldDefinition:chasC4(instance, unit_id, unit_data, unit)
    if not unit:digital_gui()._ehi_key then
        return
    end
    if not instance then
        unit:digital_gui():SetIcons(unit_data.icons)
        return
    end
    if EHI:GetBaseUnitID(unit_id, unit_data.instance_index, unit_data.continent_index) == 100054 then
        unit:digital_gui():SetIcons(unit_data.icons)
    else
        unit:digital_gui():SetIgnore(true)
    end
end