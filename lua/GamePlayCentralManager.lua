local original =
{
    sync_heist_time = GamePlayCentralManager.sync_heist_time,
    load = GamePlayCentralManager.load
}

function GamePlayCentralManager:sync_heist_time(heist_time)
    original.sync_heist_time(self, heist_time)
    managers.hud:SyncHeistTime(heist_time)
end

function GamePlayCentralManager:load(data)
    original.load(self, data)
	local state = data.GamePlayCentralManager
	if state.heist_timer then
        managers.hud.ehi:Load(state.heist_timer)
	end
end