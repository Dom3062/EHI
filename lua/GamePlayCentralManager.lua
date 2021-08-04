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
    managers.ehi:LoadTime(state.heist_timer or 0)
end