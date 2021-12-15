if EHI._hooks.MissionDoor then
    return
else
    EHI._hooks.MissionDoor = true
end

local function StartC4Sequence(unit)
    local key = tostring(unit:key())
    managers.ehi:AddTracker({
        id = key,
        time = 5,
        icons = { "pd2_c4" },
        exclude_from_sync = true
    })
    managers.ehi_waypoint:AddWaypoint(key, {
        time = 5,
        icon = "pd2_c4",
        position = unit:position()
    })
end

if Network:is_server() then
    local _f_initiate_c4_sequence = MissionDoor._initiate_c4_sequence
    function MissionDoor:_initiate_c4_sequence(...)
        _f_initiate_c4_sequence(self, ...)
        StartC4Sequence(self._unit)
    end
else
    local run_mission_door_device_sequence = MissionDoor.run_mission_door_device_sequence
    function MissionDoor.run_mission_door_device_sequence(unit, sequence_name, ...)
        if sequence_name == "activate_explode_sequence" and unit:damage():has_sequence(sequence_name) then
            StartC4Sequence(unit)
        end
        run_mission_door_device_sequence(unit, sequence_name, ...)
    end
end