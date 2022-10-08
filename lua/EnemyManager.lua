if EHI._hooks.EnemyManager then
	return
else
	EHI._hooks.EnemyManager = true
end

function EnemyManager:GetNumberOfEnemies()
    return self._enemy_data.nr_units
end

if not EHI:GetOption("show_enemy_count_tracker") then
    return
end

local original =
{
    on_enemy_registered = EnemyManager.on_enemy_registered,
    on_enemy_unregistered = EnemyManager.on_enemy_unregistered
}

function EnemyManager:on_enemy_registered(unit, ...)
	original.on_enemy_registered(self, unit, ...)
    managers.ehi:SetTrackerCount("EnemyCount", self._enemy_data.nr_units)
end

function EnemyManager:on_enemy_unregistered(unit, ...)
	original.on_enemy_unregistered(self, unit, ...)
    managers.ehi:SetTrackerCount("EnemyCount", self._enemy_data.nr_units)
end