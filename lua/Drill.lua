local _f_set_autorepair = Drill.set_autorepair
function Drill:set_autorepair(state, ...)
    _f_set_autorepair(self, state, ...)
    if self._autorepair == nil then
        return
    end
    local key = tostring(self._unit:key())
    managers.ehi:CallFunction(key, "SetAutorepair", self._autorepair)
end