if EHI._hooks.GamePlayCentralManager then
	return
else
	EHI._hooks.GamePlayCentralManager = true
end

local original =
{
    sync_heist_time = GamePlayCentralManager.sync_heist_time,
    load = GamePlayCentralManager.load
}

function GamePlayCentralManager:sync_heist_time(heist_time, ...)
    original.sync_heist_time(self, heist_time, ...)
end

function GamePlayCentralManager:load(data, ...)
    original.load(self, data, ...)
	local state = data.GamePlayCentralManager
    managers.ehi:LoadTime(state.heist_timer or 0)
end