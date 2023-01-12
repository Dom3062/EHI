local EHI = EHI
if EHI:CheckLoadHook("EnemyManager") then
    return
end

function EnemyManager:GetNumberOfEnemies()
    return self._enemy_data.nr_units
end

if not EHI:GetOption("show_enemy_count_tracker") then
    return
end

dofile(EHI.LuaPath .. "trackers/EHIEnemyCountTracker.lua")
local original =
{
    on_enemy_registered = EnemyManager.on_enemy_registered,
    on_enemy_unregistered = EnemyManager.on_enemy_unregistered
}

if EHI:GetOption("show_enemy_count_show_pagers") then
    local alarm_unit = {}
    function EnemyManager:on_enemy_registered(unit, ...)
        original.on_enemy_registered(self, unit, ...)
        if alarm_unit[unit:base()._tweak_table] then
            managers.ehi:CallFunction("EnemyCount", "AlarmEnemyRegistered")
        else
            managers.ehi:CallFunction("EnemyCount", "NormalEnemyRegistered")
        end
    end
    function EnemyManager:on_enemy_unregistered(unit, ...)
        original.on_enemy_unregistered(self, unit, ...)
        if alarm_unit[unit:base()._tweak_table] then
            managers.ehi:CallFunction("EnemyCount", "AlarmEnemyUnregistered")
        else
            managers.ehi:CallFunction("EnemyCount", "NormalEnemyUnregistered")
        end
    end
    EHI:AddOnAlarmCallback(function()
        managers.ehi:CallFunction("EnemyCount", "Alarm")
    end)
    for name, data in pairs(tweak_data.character) do
        if type(data) == "table" and data.has_alarm_pager then
            alarm_unit[name] = true
        end
    end
    EHI:AddCallback(EHI.CallbackMessage.Spawned, function()
        local enemy_data = managers.enemy._enemy_data
        if enemy_data.nr_units == 0 then
            return
        end
        for _, data in pairs(enemy_data.unit_data or {}) do
            if alarm_unit[data.unit:base()._tweak_table] then
                managers.ehi:CallFunction("EnemyCount", "AlarmEnemyRegistered")
            else
                managers.ehi:CallFunction("EnemyCount", "NormalEnemyRegistered")
            end
        end
    end)
else
    function EnemyManager:on_enemy_registered(...)
        original.on_enemy_registered(self, ...)
        managers.ehi:SetTrackerCount("EnemyCount", self._enemy_data.nr_units)
    end
    function EnemyManager:on_enemy_unregistered(...)
        original.on_enemy_unregistered(self, ...)
        managers.ehi:SetTrackerCount("EnemyCount", self._enemy_data.nr_units)
    end
    EHI:AddCallback(EHI.CallbackMessage.Spawned, function()
        managers.ehi:SetTrackerCount("EnemyCount", managers.enemy._enemy_data.nr_units)
    end)
end