local EHI = EHI
if EHI:CheckLoadHook("GamePlayCentralManager") then
    return
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

function GamePlayCentralManager:GetMissionDisabledUnit(id)
    return self._mission_disabled_units[id]
end

function GamePlayCentralManager:GetMissionEnabledUnit(id)
    return not self:GetMissionDisabledUnit(id)
end