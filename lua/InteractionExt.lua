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