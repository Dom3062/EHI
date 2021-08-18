local EHI = EHI
if EHI._hooks.VehicleDrivingExt then
    return
else
    EHI._hooks.VehicleDrivingExt = true
end

if not EHI:GetOption("show_trade_delay") then
    return
end

if EHI:GetOption("show_trade_delay_option") == 2 then
    return
end

local _f_detect_npc_collisions = VehicleDrivingExt._detect_npc_collisions
function VehicleDrivingExt:_detect_npc_collisions(...)
	local vel = self._vehicle:velocity()
	if vel:length() < 150 then
		return
	end
	local oobb = self._unit:oobb()
	local slotmask = managers.slot:get_mask("flesh")
	local units = World:find_units("intersect", "obb", oobb:center(), oobb:x(), oobb:y(), oobb:z(), slotmask)
	for _, unit in pairs(units) do
		if not unit:in_slot(managers.slot:get_mask("all_criminals")) and unit:character_damage() and not unit:character_damage():dead() and unit:base():has_tag("civilian") then
            EHI:Log("Unit found: " .. tostring(unit))
            local attacker_unit = nil
            if self._seats.driver.occupant ~= managers.player:local_player() then
				attacker_unit = self._seats.driver.occupant
			end
			unit:character_damage():_on_car_damage_received(attacker_unit)
		end
	end
    _f_detect_npc_collisions(self, ...)
end