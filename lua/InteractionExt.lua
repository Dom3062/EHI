local EHI = EHI
if EHI._hooks.InteractionExt then
    return
else
    EHI._hooks.InteractionExt = true
end

EHI:Hook(IntimitateInteractionExt, "set_tweak_data", function(self, id)
    if id == "corpse_alarm_pager" and not self._pager_has_run then
        managers.ehi:AddPagerTracker({
            id = "pager_" .. tostring(self._unit:key()),
            class = "EHIPagerTracker"
        })
        self._pager_has_run = true
    end
end)

EHI:Hook(IntimitateInteractionExt, "interact", function(self, player)
    if not self:can_interact(player) then
		return
	end
    if self.tweak_data == "corpse_alarm_pager" then
        managers.ehi:RemoveTracker("pager_" .. tostring(self._unit:key()))
    end
end)

EHI:Hook(IntimitateInteractionExt, "_at_interact_start", function(self, player, timer)
    if self.tweak_data == "corpse_alarm_pager" then
		if Network:is_server() then
			return
		end
        managers.ehi:CallFunction("pager_" .. tostring(self._unit:key()), "SetAnswered")
	end
end)

EHI:Hook(IntimitateInteractionExt, "sync_interacted", function(self, peer, player, status, skip_alive_check)
    if self.tweak_data == "corpse_alarm_pager" then
        local id = "pager_" .. tostring(self._unit:key())
        if status == "started" or status == 1 then
            managers.ehi:CallFunction(id, "SetAnswered")
        else
            managers.ehi:RemoveTracker(id)
        end
    end
end)

if not EHI:GetOption("show_equipment_tracker") then
    return
end

local function init(self, unit)
    self._ehi_key = unit:base():GetEHIKey()
end

local function set_active(self, ...)
    self._ehi_active = self._active
end

if EHI:GetOption("show_equipment_ammobag") then
    EHI:PreHook(AmmoBagInteractionExt, "init", init)

    EHI:PreHook(AmmoBagInteractionExt, "set_active", set_active)

    EHI:Hook(AmmoBagInteractionExt, "set_active", function(self, active, ...)
        if self._ehi_active ~= self._active then
            if self._active then -- Active
                if self._unit:base():GetRealAmount() > 0 then -- The unit is active now, load it from cache and show it on screen
                    managers.ehi:LoadFromDeployableCache("AmmoBags", self._ehi_key)
                end
            else -- Not Active
                if self._unit:base():GetRealAmount() > 0 then -- There is some ammo in the unit, let's cache the unit
                    managers.ehi:AddToDeployableCache("AmmoBags", self._ehi_key, self._unit)
                end
            end
            self._ehi_active = self._active
        end
    end)

    EHI:Hook(AmmoBagInteractionExt, "destroy", function(self)
        managers.ehi:RemoveFromDeployableCache("AmmoBags", self._ehi_key)
    end)
end

if EHI:GetOption("show_equipment_bodybags") then
    EHI:PreHook(BodyBagsBagInteractionExt, "init", init)

    EHI:PreHook(BodyBagsBagInteractionExt, "set_active", set_active)

    EHI:Hook(BodyBagsBagInteractionExt, "set_active", function(self, active, ...)
        if self._ehi_active ~= self._active then
            if self._active then -- Active
                if self._unit:base():GetRealAmount() > 0 and managers.groupai:state():whisper_mode() then -- The unit is active now, load it from cache and show it on screen
                    managers.ehi:LoadFromDeployableCache("BodyBags", self._ehi_key)
                end
            else -- Not Active
                if self._unit:base():GetRealAmount() > 0 then -- There are some body bags in the unit, let's cache the unit
                    managers.ehi:AddToDeployableCache("BodyBags", self._ehi_key, self._unit)
                end
            end
            self._ehi_active = self._active
        end
    end)

    EHI:Hook(BodyBagsBagInteractionExt, "destroy", function(self)
        managers.ehi:RemoveFromDeployableCache("BodyBags", self._ehi_key)
    end)
end

if EHI:GetOption("show_equipment_doctorbag") or EHI:GetOption("show_equipment_firstaidkit") then
    local aggregate = EHI:GetOption("show_equipment_aggregate_health")
    EHI:PreHook(DoctorBagBaseInteractionExt, "init", function (self, unit)
        self._ehi_key = unit:base():GetEHIKey()
        self._ehi_tweak = self.tweak_data == "first_aid_kit" and "FirstAidKits" or "DoctorBags"
        self._ehi_unit_tweak = self.tweak_data == "first_aid_kit" and "first_aid_kit" or "doctor_bag"
        self._tracker_id = aggregate and "Health" or self._ehi_tweak
    end)

    EHI:PreHook(DoctorBagBaseInteractionExt, "set_active", set_active)

    EHI:Hook(DoctorBagBaseInteractionExt, "set_active", function(self, active, ...)
        if self._ehi_active ~= self._active then
            if self._active then -- Active
                if self._unit:base():GetRealAmount() > 0 then -- The unit is active now, load it from cache and show it on screen
                    managers.ehi:LoadFromDeployableCache(self._tracker_id, self._ehi_key)
                end
            else -- Not Active
                if self._unit:base():GetRealAmount() > 0 then -- There are some charges left in the unit, let's cache the unit
                    if aggregate then
                        managers.ehi:AddToDeployableCache("Health", self._ehi_key, self._unit, self._ehi_unit_tweak)
                    else
                        managers.ehi:AddToDeployableCache(self._ehi_tweak, self._ehi_key, self._unit)
                    end
                end
            end
            self._ehi_active = self._active
        end
    end)

    EHI:Hook(DoctorBagBaseInteractionExt, "destroy", function(self)
        managers.ehi:RemoveFromDeployableCache(self._tracker_id, self._ehi_key)
    end)
end