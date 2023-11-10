local EHI = EHI
if EHI:CheckLoadHook("EnemyManager") then
    return
end

---@class EnemyManager
---@field _enemy_data table
---@field _civilian_data table
---@field all_civilians fun(self: self): table

---@return number
function EnemyManager:GetNumberOfEnemies()
    return self._enemy_data.nr_units
end

if not (EHI:GetOption("show_enemy_count_tracker") or EHI:CanShowCivilianCountTracker()) then
    return
end

local original = {}

if EHI:GetOption("show_enemy_count_tracker") then
    original.on_enemy_registered = EnemyManager.on_enemy_registered
    original.on_enemy_unregistered = EnemyManager.on_enemy_unregistered
    dofile(EHI.LuaPath .. "trackers/EHIEnemyCountTracker.lua")
    if EHI:GetOption("show_enemy_count_show_pagers") then
        local alarm_unit = {}
        function EnemyManager:on_enemy_registered(unit, ...)
            original.on_enemy_registered(self, unit, ...)
            if alarm_unit[unit:base()._tweak_table] then
                managers.ehi_tracker:CallFunction("EnemyCount", "AlarmEnemyRegistered")
            else
                managers.ehi_tracker:CallFunction("EnemyCount", "NormalEnemyRegistered")
            end
        end
        function EnemyManager:on_enemy_unregistered(unit, ...)
            original.on_enemy_unregistered(self, unit, ...)
            if alarm_unit[unit:base()._tweak_table] then
                managers.ehi_tracker:CallFunction("EnemyCount", "AlarmEnemyUnregistered")
            else
                managers.ehi_tracker:CallFunction("EnemyCount", "NormalEnemyUnregistered")
            end
        end
        for name, data in pairs(tweak_data.character) do
            if type(data) == "table" and data.has_alarm_pager then
                alarm_unit[name] = true
            end
        end
        EHI:AddOnAlarmCallback(function()
            managers.ehi_tracker:CallFunction("EnemyCount", "Alarm")
        end)
        EHI:AddCallback(EHI.CallbackMessage.Spawned, function()
            local enemy_data = managers.enemy._enemy_data
            local enemy_counted = managers.ehi_tracker:ReturnValue("EnemyCount", "GetEnemyCount") or -1
            if enemy_data.nr_units == enemy_counted then
                return
            end
            managers.ehi_tracker:CallFunction("EnemyCount", "ResetCounter")
            for _, data in pairs(enemy_data.unit_data or {}) do
                if alarm_unit[data.unit:base()._tweak_table] then
                    managers.ehi_tracker:CallFunction("EnemyCount", "AlarmEnemyRegistered")
                else
                    managers.ehi_tracker:CallFunction("EnemyCount", "NormalEnemyRegistered")
                end
            end
        end)
    else
        function EnemyManager:on_enemy_registered(...)
            original.on_enemy_registered(self, ...)
            managers.ehi_tracker:SetTrackerCount("EnemyCount", self._enemy_data.nr_units)
        end
        function EnemyManager:on_enemy_unregistered(...)
            original.on_enemy_unregistered(self, ...)
            managers.ehi_tracker:SetTrackerCount("EnemyCount", self._enemy_data.nr_units)
        end
        EHI:AddCallback(EHI.CallbackMessage.Spawned, function()
            managers.ehi_tracker:SetTrackerCount("EnemyCount", managers.enemy:GetNumberOfEnemies())
        end)
    end
end

if EHI:CanShowCivilianCountTracker() then
    ---@param unit_data table
    ---@param key string?
    local function CountCivilian(unit_data, key)
        if not unit_data.unit then
            return false
        end
        if unit_data.unit:base().unintimidateable then
            return false
        end
        if not unit_data.char_tweak then
            return false
        end
        if unit_data.char_tweak.is_escort or not unit_data.char_tweak.intimidateable then
            return false
        end
        return true
    end
    ---@param count number
    local function CreateTracker(count)
        managers.ehi_tracker:AddTracker({
            id = "CivilianCount",
            count = count,
            flash_times = 1,
            icons = { "civilians" },
            hint = "civilians",
            class = EHI.Trackers.Counter
        })
    end
    ---@param civilian_data table
    ---@param from_destroy boolean?
    local function CivilianDied(civilian_data, from_destroy)
        if managers.ehi_tracker:TrackerExists("CivilianCount") then
            local count = managers.ehi_tracker:ReturnValue("CivilianCount", "GetCount")
            if count <= 1 then
                managers.ehi_tracker:RemoveTracker("CivilianCount")
            else
                managers.ehi_tracker:DecreaseTrackerCount("CivilianCount")
            end
        else
            local count = table.count(civilian_data, CountCivilian)
            local civilians_alive = count - (from_destroy and 1 or 0)
            if civilians_alive > 0 then
                CreateTracker(civilians_alive)
            end
        end
    end
    original.register_civilian = EnemyManager.register_civilian
    function EnemyManager:register_civilian(unit, ...)
        original.register_civilian(self, unit, ...)
        if CountCivilian(self._civilian_data.unit_data[unit:key()]) then
            if managers.ehi_tracker:TrackerExists("CivilianCount") then
                managers.ehi_tracker:IncreaseTrackerCount("CivilianCount")
            else
                CreateTracker(table.size(self._civilian_data.unit_data))
            end
        end
    end

    original.on_civilian_died = EnemyManager.on_civilian_died
    function EnemyManager:on_civilian_died(dead_unit, ...)
        local unit_data = self._civilian_data.unit_data
        if CountCivilian(unit_data[dead_unit:key()]) then
            CivilianDied(unit_data)
        end
        original.on_civilian_died(self, dead_unit, ...)
    end

    original.on_civilian_destroyed = EnemyManager.on_civilian_destroyed
    function EnemyManager:on_civilian_destroyed(civilian, ...)
        local unit_data = self._civilian_data.unit_data[civilian:key()]
        if unit_data and CountCivilian(unit_data) then
            CivilianDied(self._civilian_data.unit_data, true)
        end
        original.on_civilian_destroyed(self, civilian, ...)
    end
    EHI:AddCallback(EHI.CallbackMessage.Spawned, function()
        local units = managers.enemy._civilian_data.unit_data
        local count = table.size(units)
        local civilian_count = table.count(units, CountCivilian)
        if count <= 0 or civilian_count <= 0 then
            managers.ehi_tracker:RemoveTracker("CivilianCount")
        elseif managers.ehi_tracker:TrackerExists("CivilianCount") then
            managers.ehi_tracker:CallFunction("CivilianCount", "ResetCounter")
            managers.ehi_tracker:SetTrackerCount("CivilianCount", civilian_count)
        else
            CreateTracker(civilian_count)
        end
    end)
end