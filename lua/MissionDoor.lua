local _f_initiate_c4_sequence = MissionDoor._initiate_c4_sequence
function MissionDoor:_initiate_c4_sequence(...)
    _f_initiate_c4_sequence(self, ...)
    managers.ehi:AddTracker({
        id = tostring(self._unit:key()),
        time = 5,
        icons = { "pd2_c4" },
        exclude_from_sync = true
    })
end