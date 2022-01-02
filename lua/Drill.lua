local _f_set_autorepair = Drill.set_autorepair
function Drill:set_autorepair(state, ...)
    _f_set_autorepair(self, state, ...)
    if self._autorepair == nil then
        return
    end
    local key = tostring(self._unit:key())
    managers.ehi:CallFunction(key, "SetAutorepair", self._autorepair)
    managers.ehi_waypoint:SetWaypointColor(key, tweak_data.ehi.color.DrillAutorepair, true)
end

if Network:is_client() then
    local  _f_on_autorepair = Drill.on_autorepair
    function Drill:on_autorepair(...)
        _f_on_autorepair(self, ...)
        local key = tostring(self._unit:key())
        managers.ehi:CallFunction(key, "SetAutorepair", true)
        managers.ehi_waypoint:SetWaypointColor(key, tweak_data.ehi.color.DrillAutorepair, true)
    end
end