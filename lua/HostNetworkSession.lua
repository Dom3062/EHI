if true then
    return
end

local _f_set_game_started = HostNetworkSession.set_game_started
function HostNetworkSession:set_game_started(...)
    _f_set_game_started(self, ...)
    managers.ehi:DisableStartFromBeginning()
end