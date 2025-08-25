local EHI = EHI
local Icon = EHI.Icons

---@class EHIMissionUnit
local EHIMissionUnit = {}
EHIMissionUnit._option_check = EHI:GetTrackerOrWaypointOption("show_timers", "show_waypoints_timers")
EHIMissionUnit._world = {} ---@type table<number, UnitUpdateDefinition>
EHIMissionUnit._mission = {} ---@type table<number, UnitUpdateDefinition>
EHIMissionUnit._instance = {} ---@type table<number, UnitUpdateDefinition>
EHIMissionUnit._instance_mission = {} ---@type table<number, UnitUpdateDefinition>

-- Broken units to be "fixed" during mission load
---@type table<string, UnitUpdateDefinition>
EHIMissionUnit._units =
{
    -- Doctor Bags
    ["units/payday2/props/stn_prop_medic_firstaid_box/stn_prop_medic_firstaid_box"] = { f = "SetDeployableOffset" }, -- CustomDoctorBagBase / cabinet 1
    ["units/pd2_dlc_casino/props/cas_prop_medic_firstaid_box/cas_prop_medic_firstaid_box"] = { f = "SetDeployableOffset" }, -- CustomDoctorBagBase / cabinet 2
    -- Ammo
    ["units/payday2/props/stn_prop_armory_shelf_ammo/stn_prop_armory_shelf_ammo"] = { f = "SetDeployableOffset" },
    ["units/pd2_dlc_spa/props/spa_prop_armory_shelf_ammo/spa_prop_armory_shelf_ammo"] = { f = "SetDeployableOffset" },
    ["units/pd2_dlc_hvh/props/hvh_prop_armory_shelf_ammo/hvh_prop_armory_shelf_ammo"] = { f = "SetDeployableOffset" },

    ["units/pd2_dlc_chas/equipment/chas_interactable_c4/chas_interactable_c4"] = { icons = { Icon.C4 }, warning = true, hint = EHI.Hints.Explosion },
    ["units/pd2_dlc_chas/equipment/chas_interactable_c4_placeable/chas_interactable_c4_placeable"] = { icons = { Icon.C4 }, f = "chasC4" },
    ["units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_01"] = { ignore_visibility = true },
    ["units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_02"] = { ignore_visibility = true },
    ["units/pd2_dlc_vit/props/vit_interactable_computer_monitor/vit_interactable_hack_gui_03"] = { ignore_visibility = true },

    ["units/world/props/suburbia_hackbox/suburbia_hackbox"] = { icons = { Icon.Tablet } },
    ["units/pd2_dlc_dah/props/dah_prop_hack_box/dah_prop_hack_ipad_unit"] = { icons = { Icon.Tablet } },
    ["units/pd2_dlc_sah/props/sah_interactable_hackbox/sah_interactable_hackbox"] = { icons = { Icon.Tablet } },
    ["units/pd2_dlc_vit/props/vit_prop_hacking_device/vit_prop_hacking_device"] = { icons = { Icon.Tablet } },
    ["units/pd2_dlc_pent/props/pent_prop_hacking_device/pent_prop_hacking_device"] = { icons = { Icon.Tablet } },
    ["units/pd2_dlc_trai/props/trai_int_prop_hacking_device/trai_int_prop_hacking_device"] = { icons = { Icon.Tablet } }
}
---@param tbl table<number, UnitUpdateDefinition>
function EHIMissionUnit:FinalizeUnits(tbl)
    local wd = managers.worlddefinition
    for id, unit_data in pairs(tbl) do
        local unit = wd:get_unit(id) --[[@as UnitTimer|UnitDigitalTimer?]]
        if unit then
            if unit_data.f then
                if type(unit_data.f) == "string" then
                    self[unit_data.f](self, id, unit_data, unit)
                else
                    unit_data.f(id, unit_data, unit)
                end
            else
                local timer_gui = unit:timer_gui()
                if timer_gui and timer_gui._ehi_key then
                    if unit_data.child_units then
                        timer_gui:SetChildUnits(unit_data.child_units, wd)
                    end
                    timer_gui:SetIcons(unit_data.icons)
                    timer_gui:SetRemoveOnPowerOff(unit_data.remove_on_power_off)
                    if unit_data.remove_on_alarm then
                        timer_gui:SetOnAlarm()
                    end
                    if unit_data.remove_vanilla_waypoint then
                        timer_gui:RemoveVanillaWaypoint(unit_data.remove_vanilla_waypoint, unit_data.restore_waypoint_on_done)
                    end
                    if unit_data.remove_vanilla_waypoint_overriden then
                        timer_gui:RemoveVanillaWaypointOverriden(unit_data.remove_vanilla_waypoint_overriden, unit_data.restore_waypoint_on_done)
                    end
                    if unit_data.ignore_visibility then
                        timer_gui:SetIgnoreVisibility()
                    end
                    if unit_data.set_custom_id then
                        timer_gui:SetCustomID(unit_data.set_custom_id)
                    end
                    if unit_data.tracker_merge_id then
                        timer_gui:SetTrackerMergeID(unit_data.tracker_merge_id, unit_data.destroy_tracker_merge_on_done)
                    end
                    if unit_data.custom_callback then
                        timer_gui:SetCustomCallback(unit_data.custom_callback.id, unit_data.custom_callback.f)
                    end
                    if unit_data.power_off_override then
                        timer_gui:SetJammedStatusOverridePoweredStatus()
                    end
                    if unit_data.hint then
                        timer_gui:SetHint(unit_data.hint)
                    end
                    timer_gui:SetWaypointPosition(unit_data.position)
                    timer_gui:Finalize()
                end
                local digital_gui = unit:digital_gui()
                if digital_gui and digital_gui._ehi_key then
                    if unit_data.ignore then
                        digital_gui:SetIgnore()
                    else
                        digital_gui:SetIcons(unit_data.icons)
                        digital_gui:SetRemoveOnPause(unit_data.remove_on_pause)
                        digital_gui:SetWarning(unit_data.warning)
                        digital_gui:SetCompletion(unit_data.completion)
                        if unit_data.remove_on_alarm then
                            digital_gui:SetOnAlarm()
                        end
                        if unit_data.custom_callback then
                            digital_gui:SetCustomCallback(unit_data.custom_callback.id, unit_data.custom_callback.f)
                        end
                        if unit_data.icon_on_pause then
                            digital_gui:SetIconOnPause(unit_data.icon_on_pause)
                        end
                        if unit_data.remove_vanilla_waypoint then
                            digital_gui:RemoveVanillaWaypoint(unit_data.remove_vanilla_waypoint)
                        end
                        if unit_data.ignore_visibility then
                            digital_gui:SetIgnoreVisibility()
                        end
                        if unit_data.hint then
                            digital_gui:SetHint(unit_data.hint)
                        end
                        if unit_data.ignore_waypoint then
                            digital_gui:SetIgnoreWaypoint()
                        end
                    end
                    digital_gui:Finalize()
                end
            end
            -- Clear configured unit from the table
            tbl[id] = nil
        end
    end
end

function EHIMissionUnit:FinalizeUnitsClient()
    self:FinalizeUnits(self._world)
    self:FinalizeUnits(self._mission)
    self:FinalizeUnits(self._instance)
    self:FinalizeUnits(self._instance_mission)
end

---@param tbl table<number, UnitUpdateDefinition>
function EHIMissionUnit:UpdateUnits(tbl)
    if self._option_check then
        self:UpdateUnitsNoCheck(tbl)
    end
end

---@param tbl table<number, UnitUpdateDefinition>
function EHIMissionUnit:UpdateUnitsNoCheck(tbl)
    self:FinalizeUnits(tbl)
    for id, data in pairs(tbl) do
        self._mission[id] = data
    end
end

---@param tbl table<number, UnitUpdateDefinition>
---@param skip_finalize boolean
function EHIMissionUnit:UpdateInstanceMissionUnits(tbl, skip_finalize)
    if not self._option_check then
        return
    elseif not skip_finalize then
        self:FinalizeUnits(tbl)
    end
    for id, data in pairs(tbl) do
        self._instance_mission[id] = data
    end
end

---@param tbl table<number, UnitUpdateDefinition>
---@param instance_start_index number
---@param instance_continent_index number? Defaults to `100000` if not provided
function EHIMissionUnit:UpdateInstanceUnits(tbl, instance_start_index, instance_continent_index)
    if self._option_check then
        self:UpdateInstanceUnitsNoCheck(tbl, instance_start_index, instance_continent_index)
    end
end

---@param tbl table<number, UnitUpdateDefinition>
---@param instance_start_index number
---@param instance_continent_index number? Defaults to `100000` if not provided
function EHIMissionUnit:UpdateInstanceUnitsNoCheck(tbl, instance_start_index, instance_continent_index)
    local new_tbl = {} ---@type ParseUnitsTable
    instance_continent_index = instance_continent_index or 100000
    for id, data in pairs(tbl) do
        local computed_id = EHI:GetInstanceElementID(id, instance_start_index, instance_continent_index)
        local cloned_data = deep_clone(data)
        if data.remove_vanilla_waypoint then
            cloned_data.remove_vanilla_waypoint = EHI:GetInstanceElementID(data.remove_vanilla_waypoint, instance_start_index, instance_continent_index)
        end
        cloned_data.base_index = id
        new_tbl[computed_id] = cloned_data
    end
    self:FinalizeUnits(new_tbl)
    for id, data in pairs(new_tbl) do
        self._instance[id] = data
    end
end

---@param unit_id number
---@param unit_data UnitUpdateDefinition
---@param unit UnitAmmoDeployable|UnitGrenadeDeployable
function EHIMissionUnit:IgnoreDeployable(unit_id, unit_data, unit)
    local base = unit:base()
    if base and base.SetIgnore then
        base:SetIgnore()
    end
end

---@param unit_id number
---@param unit_data UnitUpdateDefinition
---@param unit UnitAmmoDeployable|UnitGrenadeDeployable
function EHIMissionUnit:IgnoreChildDeployable(unit_id, unit_data, unit)
    local base = unit:base()
    if base and base.SetIgnoreChild then
        base:SetIgnoreChild()
    end
end

---@param unit_id number
---@param unit_data UnitUpdateDefinition
---@param unit UnitAmmoDeployable|UnitDoctorDeployable
function EHIMissionUnit:SetDeployableOffset(unit_id, unit_data, unit)
    local base = unit:base()
    if base and base.SetOffset then
        base:SetOffset(unit_data.offset or 1)
    end
end

---@param unit_id number
---@param unit_data UnitUpdateDefinition
---@param unit UnitDigitalTimer
function EHIMissionUnit:chasC4(unit_id, unit_data, unit)
    local digital = unit:digital_gui()
    if not digital._ehi_key then
        return
    end
    digital:SetHint(Hints.Explosion)
    if not unit_data.instance then
        digital:SetIcons(unit_data.icons)
        return
    end
    if EHI:GetBaseUnitID(unit_id, unit_data.instance.start_index, unit_data.continent_index) == 100054 then
        digital:SetIcons(unit_data.icons)
    else
        digital:SetIgnore()
    end
end

return EHIMissionUnit