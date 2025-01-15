local EHI = EHI
if EHI:CheckLoadHook("GamePlayCentralManager") then
    return
end

---@class GamePlayCentralManager
---@field _heist_timer { offset_time: number? }
---@field _mission_disabled_units table<number, boolean>
---@field get_heist_timer fun(self: self): number

local original =
{
    load = GamePlayCentralManager.load
}

if EHI.IsHost then
    original.restart_the_game = GamePlayCentralManager.restart_the_game
    function GamePlayCentralManager:restart_the_game(...)
        EHI:CallCallbackOnce(EHI.CallbackMessage.GameRestart)
        original.restart_the_game(self, ...)
    end
else
    original.stop_the_game = GamePlayCentralManager.stop_the_game
    function GamePlayCentralManager:stop_the_game(...)
        EHI:CallCallbackOnce(EHI.CallbackMessage.GameRestart)
        original.stop_the_game(self, ...)
    end
end

function GamePlayCentralManager:load(...)
    original.load(self, ...)
    managers.ehi_manager:LoadTime(self._heist_timer.offset_time or 0)
end

---@param id number
function GamePlayCentralManager:IsMissionUnitDisabled(id)
    return self._mission_disabled_units[id]
end

---@param id number
function GamePlayCentralManager:IsMissionUnitEnabled(id)
    return not self:IsMissionUnitDisabled(id)
end