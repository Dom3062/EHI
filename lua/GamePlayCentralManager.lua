local EHI = EHI
if EHI:CheckLoadHook("GamePlayCentralManager") then
    return
end

local original =
{
    load = GamePlayCentralManager.load
}

if EHI.IsHost then
    original.restart_the_game = GamePlayCentralManager.restart_the_game
    function GamePlayCentralManager:restart_the_game(...)
        EHI:RunEndGameCallback(EHI.Const.GameEnd.Restart)
        original.restart_the_game(self, ...)
    end
else
    original.stop_the_game = GamePlayCentralManager.stop_the_game
    function GamePlayCentralManager:stop_the_game(...)
        EHI:RunEndGameCallback(EHI.Const.GameEnd.Restart)
        original.stop_the_game(self, ...)
    end
end

function GamePlayCentralManager:load(...)
    original.load(self, ...)
    managers.ehi_tracking:LoadTime(self._heist_timer.offset_time or 0)
end

---@param id number
function GamePlayCentralManager:IsMissionUnitDisabled(id)
    return self._mission_disabled_units[id]
end

---@param id number
function GamePlayCentralManager:IsMissionUnitEnabled(id)
    return not self:IsMissionUnitDisabled(id)
end