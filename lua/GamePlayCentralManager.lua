if EHI._hooks.GamePlayCentralManager then
	return
else
	EHI._hooks.GamePlayCentralManager = true
end

local original =
{
    load = GamePlayCentralManager.load
}

function GamePlayCentralManager:load(data, ...)
    original.load(self, data, ...)
	local state = data.GamePlayCentralManager
    local heist_timer = state.heist_timer or 0
    managers.ehi:LoadTime(heist_timer)
    managers.ehi_waypoint:LoadTime(heist_timer)
end