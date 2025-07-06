local EHI = EHI
if EHI:CheckLoadHook("EnemyManager") then
    return
end

---@alias EnemyManager._civilian_data.Civilian { unit: UnitCivilian, char_tweak: CharacterTweakData._string_.Civilian }
---@alias EnemyManager._civilian_data table<string, EnemyManager._civilian_data.Civilian?>

---@class EnemyManager
---@field _enemy_data table
---@field _civilian_data { unit_data: EnemyManager._civilian_data }
---@field all_civilians fun(self: self): EnemyManager._civilian_data
---@field is_civilian fun(self: self, unit: Unit|UnitEnemy|UnitPlayer|UnitCivilian|UnitTeamAI): boolean
---@field is_enemy fun(self: self, unit: Unit|UnitEnemy|UnitPlayer|UnitCivilian|UnitTeamAI): boolean

---@return number
function EnemyManager:GetNumberOfEnemies()
    return self._enemy_data.nr_units
end

if not (EHI:GetTrackerOption("show_enemy_count_tracker") or EHI:CanShowCivilianCountTracker() or EHI:IsAssaultTrackerEnabledAndOption("show_assault_enemy_count")) then
    return
end

local original = {}

if not tweak_data.levels:IsLevelSafehouse() then
    if EHI:GetOptionAndLoadTracker("show_enemy_count_tracker") then
        local tracker_name = "EnemyCount"
        local enemy_count_blocked = false
        local show_enemy_count_in_assault_tracker = EHI:IsAssaultTrackerEnabledAndOption("show_assault_enemy_count")
        local no_loud_update = EHI:CombineAssaultDelayAndAssaultTime() and show_enemy_count_in_assault_tracker
        original.on_enemy_registered = EnemyManager.on_enemy_registered
        original.on_enemy_unregistered = EnemyManager.on_enemy_unregistered
        if EHI:GetOption("show_enemy_count_show_pagers") then
            local alarm_unit = {}
            function EnemyManager:on_enemy_registered(unit, ...)
                original.on_enemy_registered(self, unit, ...)
                if alarm_unit[unit:base()._tweak_table] then
                    managers.ehi_tracker:CallFunction(tracker_name, "AlarmEnemyRegistered")
                else
                    managers.ehi_tracker:CallFunction(tracker_name, "NormalEnemyRegistered")
                end
            end
            function EnemyManager:on_enemy_unregistered(unit, ...)
                original.on_enemy_unregistered(self, unit, ...)
                if alarm_unit[unit:base()._tweak_table] then
                    managers.ehi_tracker:CallFunction(tracker_name, "AlarmEnemyUnregistered")
                else
                    managers.ehi_tracker:CallFunction(tracker_name, "NormalEnemyUnregistered")
                end
            end
            for name, data in pairs(tweak_data.character) do
                if type(data) == "table" and data.has_alarm_pager then
                    alarm_unit[name] = true
                end
            end
            EHI:AddOnSpawnedCallback(function()
                if enemy_count_blocked then
                    return
                end
                managers.ehi_tracker:AddTracker({
                    id = "EnemyCount",
                    alarm_sounded = EHI.ConditionFunctions.IsLoud(),
                    no_loud_update = no_loud_update,
                    flash_bg = false,
                    class = "EHIEnemyCountTracker"
                })
                local enemy_data = managers.enemy._enemy_data
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
                managers.ehi_tracker:SetCount(tracker_name, self._enemy_data.nr_units)
            end
            function EnemyManager:on_enemy_unregistered(...)
                original.on_enemy_unregistered(self, ...)
                managers.ehi_tracker:SetCount(tracker_name, self._enemy_data.nr_units)
            end
            EHI:AddOnSpawnedCallback(function()
                if enemy_count_blocked then
                    return
                end
                managers.ehi_tracker:AddTracker({
                    id = "EnemyCount",
                    count = managers.enemy:GetNumberOfEnemies(),
                    flash_bg = false,
                    class = "EHIEnemyCountTracker"
                })
            end)
        end
        if no_loud_update then
            local new_tracker_name = managers.ehi_assault.GetTrackerName()
            EHI:AddCallback("AssaultTracker_Enemies", function()
                enemy_count_blocked = true
                tracker_name = new_tracker_name
                managers.ehi_tracker:RemoveTracker("EnemyCount")
            end)
        end
    elseif EHI:IsAssaultTrackerEnabledAndOption("show_assault_enemy_count") then
        local tracker_name = managers.ehi_assault.GetTrackerName()
        original.on_enemy_registered = EnemyManager.on_enemy_registered
        original.on_enemy_unregistered = EnemyManager.on_enemy_unregistered
        function EnemyManager:on_enemy_registered(...)
            original.on_enemy_registered(self, ...)
            managers.ehi_tracker:SetCount(tracker_name, self._enemy_data.nr_units)
        end
        function EnemyManager:on_enemy_unregistered(...)
            original.on_enemy_unregistered(self, ...)
            managers.ehi_tracker:SetCount(tracker_name, self._enemy_data.nr_units)
        end
    end
end

if EHI:CanShowCivilianCountTracker() then
    EHI:LoadTracker("EHICivilianCountTracker")
    ---@param unit_data EnemyManager._civilian_data.Civilian
    ---@param key any Unused
    local function CountCivilian(unit_data, key)
        if not unit_data.unit then
            return false
        end
        if unit_data.unit:base().unintimidateable then
            return false
        end
        if unit_data.unit:character_damage().immortal then -- Husk unit check
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
    local spawned = false
    ---@param count number
    local function CreateTracker(count)
        if spawned then
            managers.ehi_tracker:AddTracker({
                id = "CivilianCount",
                count = count,
                flash_times = 1,
                class = "EHICivilianCountTracker"
            })
        end
    end
    Hooks:PostHook(EnemyManager, "register_civilian", "EHI_EnemyManager_register_civilian", function(self, unit, ...) ---@param unit UnitCivilian
        local unit_data = self._civilian_data.unit_data
        if CountCivilian(unit_data[unit:key()]) and managers.ehi_tracker:CallFunction2("CivilianCount", "IncreaseCount") then
            CreateTracker(1)
        end
    end)
    Hooks:PreHook(EnemyManager, "on_civilian_died", "EHI_EnemyManager_on_civilian_died", function(self, dead_unit, ...) ---@param dead_unit UnitCivilian
        local unit_data = self._civilian_data.unit_data
        local civilian_key = dead_unit:key()
        if CountCivilian(unit_data[civilian_key]) then
            managers.ehi_tracker:DecreaseCount("CivilianCount", civilian_key) ---@diagnostic disable-line
        end
    end)
    Hooks:PreHook(EnemyManager, "on_civilian_destroyed", "EHI_EnemyManager_on_civilian_died", function(self, civilian, ...) ---@param civilian UnitCivilian
        local civilian_data = self._civilian_data.unit_data
        local civilian_key = civilian:key()
        local unit_data = civilian_data[civilian_key]
        if unit_data and CountCivilian(unit_data) then
            managers.ehi_tracker:DecreaseCount("CivilianCount", civilian_key) ---@diagnostic disable-line
        end
    end)
    EHI:AddOnSpawnedCallback(function()
        spawned = true
        local civilian_count = table.count(managers.enemy._civilian_data.unit_data, CountCivilian)
        if civilian_count > 0 then
            CreateTracker(civilian_count)
        end
    end)
end