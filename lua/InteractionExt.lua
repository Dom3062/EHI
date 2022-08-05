local EHI = EHI
if EHI._hooks.InteractionExt then
    return
else
    EHI._hooks.InteractionExt = true
end

local server = Network:is_server()

if EHI:GetOption("show_pager_callback") then
    local show_waypoint = EHI:GetWaypointOption("show_waypoints_pager")
    local show_waypoint_only = show_waypoint and EHI:GetWaypointOption("show_waypoints_only")
    EHI:HookWithID(IntimitateInteractionExt, "init", "PagerInit", function(self, unit, ...)
        self._ehi_key = "pager_" .. tostring(unit:key())
    end)

    EHI:Hook(IntimitateInteractionExt, "set_tweak_data", function(self, id)
        if id == "corpse_alarm_pager" and not self._pager_has_run then
            if not show_waypoint_only then
                managers.ehi:AddPagerTracker(self._ehi_key)
            end
            if show_waypoint then
                managers.ehi_waypoint:AddWaypoint(self._ehi_key, {
                    time = 12,
                    texture = "guis/textures/pd2/specialization/icons_atlas",
                    text_rect = {64, 256, 64, 64},
                    type = "pager_timer",
                    position = self._unit:position(),
                    warning = true
                })
            end
            self._pager_has_run = true
        end
    end)

    EHI:Hook(IntimitateInteractionExt, "interact", function(self, player)
        if not self:can_interact(player) then
            return
        end
        if self.tweak_data == "corpse_alarm_pager" then
            managers.ehi:RemoveTracker(self._ehi_key)
            managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
        end
    end)

    EHI:Hook(IntimitateInteractionExt, "_at_interact_start", function(self, player, timer)
        if self.tweak_data == "corpse_alarm_pager" then
            if server then
                return
            end
            managers.ehi:CallFunction(self._ehi_key, "SetAnswered")
            managers.ehi_waypoint:SetPagerWaypointAnswered(self._ehi_key)
        end
    end)

    EHI:Hook(IntimitateInteractionExt, "sync_interacted", function(self, peer, player, status, skip_alive_check)
        if self.tweak_data == "corpse_alarm_pager" then
            if status == "started" or status == 1 then
                managers.ehi:CallFunction(self._ehi_key, "SetAnswered")
                managers.ehi_waypoint:SetPagerWaypointAnswered(self._ehi_key)
            else
                managers.ehi:RemoveTracker(self._ehi_key)
                managers.ehi_waypoint:RemoveWaypoint(self._ehi_key)
            end
        end
    end)

    EHI:AddOnAlarmCallback(function()
        EHI:Unhook("PagerInit")
        EHI:Unhook("set_tweak_data")
        EHI:Unhook("interact")
        EHI:Unhook("_at_interact_start")
        EHI:Unhook("sync_interacted")
    end)
end

if not EHI:GetOption("show_equipment_tracker") then
    return
end

local all = EHI:GetOption("show_equipment_aggregate_all")

local function set_active(self, ...)
    self._ehi_active = self._active
end

if EHI:GetOption("show_equipment_ammobag") then
    EHI:PreHook(AmmoBagInteractionExt, "init", function(self, unit, ...)
        self._ehi_key = unit:base():GetEHIKey()
        self._tracker_id = all and "Deployables" or "AmmoBags"
    end)

    EHI:PreHook(AmmoBagInteractionExt, "set_active", set_active)

    EHI:Hook(AmmoBagInteractionExt, "set_active", function(self, ...)
        if self._ehi_active ~= self._active then
            if self._active then -- Active
                if self._unit:base():GetRealAmount() > 0 then -- The unit is active now, load it from cache and show it on screen
                    managers.ehi:LoadFromDeployableCache(self._tracker_id, self._ehi_key)
                end
            else -- Not Active
                if self._unit:base():GetRealAmount() > 0 then -- There is some ammo in the unit, let's cache the unit
                    if all then
                        managers.ehi:AddToDeployableCache(self._tracker_id, self._ehi_key, self._unit, "ammo_bag")
                    else
                        managers.ehi:AddToDeployableCache(self._tracker_id, self._ehi_key, self._unit)
                    end
                end
            end
            self._ehi_active = self._active
        end
    end)

    EHI:Hook(AmmoBagInteractionExt, "destroy", function(self, ...)
        managers.ehi:RemoveFromDeployableCache(self._tracker_id, self._ehi_key)
    end)
end

if EHI:GetOption("show_equipment_bodybags") then
    EHI:PreHook(BodyBagsBagInteractionExt, "init", function(self, unit, ...)
        self._ehi_key = unit:base():GetEHIKey()
        self._tracker_id = all and "Deployables" or "BodyBags"
    end)

    EHI:PreHook(BodyBagsBagInteractionExt, "set_active", set_active)

    EHI:Hook(BodyBagsBagInteractionExt, "set_active", function(self, ...)
        if self._ehi_active ~= self._active then
            if self._active then -- Active
                if self._unit:base():GetRealAmount() > 0 and managers.groupai:state():whisper_mode() then -- The unit is active now, load it from cache and show it on screen
                    managers.ehi:LoadFromDeployableCache(self._tracker_id, self._ehi_key)
                end
            else -- Not Active
                if self._unit:base():GetRealAmount() > 0 then -- There are some body bags in the unit, let's cache the unit
                    if all then
                        managers.ehi:AddToDeployableCache("Deployables", self._ehi_key, self._unit, "bodybags_bag")
                    else
                        managers.ehi:AddToDeployableCache(self._tracker_id, self._ehi_key, self._unit)
                    end
                end
            end
            self._ehi_active = self._active
        end
    end)

    EHI:Hook(BodyBagsBagInteractionExt, "destroy", function(self, ...)
        managers.ehi:RemoveFromDeployableCache(self._tracker_id, self._ehi_key)
    end)
end

if EHI:GetOption("show_equipment_doctorbag") or EHI:GetOption("show_equipment_firstaidkit") then
    local aggregate = EHI:GetOption("show_equipment_aggregate_health")
    EHI:PreHook(DoctorBagBaseInteractionExt, "init", function(self, unit, ...)
        self._ehi_key = unit:base().GetEHIKey and unit:base():GetEHIKey()
        self._ehi_tweak = self.tweak_data == "first_aid_kit" and "FirstAidKits" or "DoctorBags"
        self._ehi_unit_tweak = self.tweak_data == "first_aid_kit" and "first_aid_kit" or "doctor_bag"
        if all then
            self._tracker_id = "Deployables"
        elseif aggregate then
            self._tracker_id = "Health"
        else
            self._tracker_id = self._ehi_tweak
        end
    end)

    EHI:PreHook(DoctorBagBaseInteractionExt, "set_active", set_active)

    EHI:Hook(DoctorBagBaseInteractionExt, "set_active", function(self, ...)
        if self._ehi_active ~= self._active then
            if self._active then -- Active
                if self._unit:base().GetRealAmount and self._unit:base():GetRealAmount() > 0 then -- The unit is active now, load it from cache and show it on screen
                    managers.ehi:LoadFromDeployableCache(self._tracker_id, self._ehi_key)
                end
            else -- Not Active
                if self._unit:base().GetRealAmount and self._unit:base():GetRealAmount() > 0 then -- There are some charges left in the unit, let's cache the unit
                    if aggregate or all then
                        managers.ehi:AddToDeployableCache(self._tracker_id, self._ehi_key, self._unit, self._ehi_unit_tweak)
                    else
                        managers.ehi:AddToDeployableCache(self._ehi_tweak, self._ehi_key, self._unit)
                    end
                end
            end
            self._ehi_active = self._active
        end
    end)

    EHI:Hook(DoctorBagBaseInteractionExt, "destroy", function(self, ...)
        managers.ehi:RemoveFromDeployableCache(self._tracker_id, self._ehi_key)
    end)
end