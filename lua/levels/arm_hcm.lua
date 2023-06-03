local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local van_delay = 363/30
local triggers = {
    [100215] = { time = 120 + van_delay },
    [100216] = { time = 100 + van_delay },
    [100218] = { time = 80 + van_delay },
    [100219] = { time = 60 + van_delay },

    -- Heli
    [102200] = { special_function = SF.Trigger, data = { 1022001, 1022002 } },
    [1022001] = { time = 23, special_function = SF.SetTimeOrCreateTracker },
    [1022002] = { special_function = SF.ShowWaypoint, data = { icon = Icon.LootDrop, position_by_element = 102650 } },

    [100214] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100233 } }
}
local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 30 + 30 })
}
if EHI:GetOption("show_escape_chance") then
    other[101620] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement, trigger_times = 1 }
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi_tracker:AddEscapeChanceTracker(dropin, 10)
    end)
end
--[[if EHI:GetOption("show_loot_counter") then
    -- [ID of disabled unit when truck is visible] = truck ID
    local trucks =
    {
        [100668] = 100006, -- 1
        [102552] = 100007, -- 2
        [102053] = 100097, -- 8
        [102384] = 100100, -- 9
        [102559] = 100101, -- 10
        [102261] = 100226, -- 11
        [102592] = 100227 -- 12
    }
    local trucks_body =
    {
        100021, 100022, 100023, 100024, 100025
    }
    local exploded = {}
    local function UsedC4(truck)
        exploded[truck] = true
    end
    local function GarbageFound()
        managers.ehi_tracker:CallFunction("LootCounter", "RandomLootDeclined")
    end
    local function LootFound()
        managers.ehi_tracker:CallFunction("LootCounter", "RandomLootSpawned")
    end
    local function LootFoundExplosionCheck(truck)
        if exploded[truck] then
            GarbageFound()
            return
        end
        managers.ehi_tracker:CallFunction("LootCounter", "RandomLootSpawned")
    end
    local function LootCounter(count)
        EHI:ShowLootCounterNoCheck({ max_random = count * 9 })
        local truck = 0
        local loot = { "gold", "money", "art" }
        for disabled_unit_id, truck_id in pairs(trucks) do
            if managers.game_play_central:GetMissionDisabledUnit(disabled_unit_id) then
                truck = truck + 1
                managers.mission:add_runned_unit_sequence_trigger(truck_id, "set_exploded", function(...)
                    UsedC4(truck_id)
                end)
                local function _lootcheck(...)
                    LootFoundExplosionCheck(truck_id)
                end
                for _, _loot in ipairs(loot) do
                    for i = 1, 9, 1 do
                        if i <= 2 then -- Explosion can disable this loot
                            managers.mission:add_runned_unit_sequence_trigger(truck_id, "spawn_loot_" .. _loot .. "_" .. tostring(i), _lootcheck)
                        else
                            managers.mission:add_runned_unit_sequence_trigger(truck_id, "spawn_loot_" .. _loot .. "_" .. tostring(i), LootFound)
                        end
                    end
                end
                for i = 1, 9, 1 do
                    managers.mission:add_runned_unit_sequence_trigger(truck_id, "spawn_loot_empty_" .. tostring(i), GarbageFound)
                end
                if truck == count then
                    break
                end
            end
        end
        if truck ~= count then
            local wd = managers.worlddefinition
            for _, truck_id in ipairs(trucks_body) do
                local unit = wd:get_unit(truck_id)
                if unit and unit:damage() and unit:damage()._state and unit:damage()._state.graphic_group and unit:damage()._state.graphic_group.grp_truck then
                    local state = unit:damage()._state.graphic_group.grp_truck
                    if state[1] == "set_visibility" and state[2] then
                        truck = truck + 1
                        managers.mission:add_runned_unit_sequence_trigger(truck_id, "set_exploded", function(...)
                            UsedC4(truck_id)
                        end)
                        local function _lootcheck(...)
                            LootFoundExplosionCheck(truck_id)
                        end
                        for _, _loot in ipairs(loot) do
                            for i = 1, 9, 1 do
                                if i <= 2 then -- Explosion can disable this loot
                                    managers.mission:add_runned_unit_sequence_trigger(truck_id, "spawn_loot_" .. _loot .. "_" .. tostring(i), _lootcheck)
                                else
                                    managers.mission:add_runned_unit_sequence_trigger(truck_id, "spawn_loot_" .. _loot .. "_" .. tostring(i), LootFound)
                                end
                            end
                        end
                        for i = 1, 9, 1 do
                            managers.mission:add_runned_unit_sequence_trigger(truck_id, "spawn_loot_empty_" .. tostring(i), GarbageFound)
                        end
                        if truck == count then
                            break
                        end
                    end
                end
            end
        end
    end
    other[100238] = { special_function = SF.CustomCode, f = LootCounter, arg = 1 }
    other[101197] = { special_function = SF.CustomCode, f = LootCounter, arg = 2 }
    other[101199] = { special_function = SF.CustomCode, f = LootCounter, arg = 3 }
    other[101204] = { special_function = SF.CustomCode, f = LootCounter, arg = 4 }
end]]

EHI:ParseTriggers({ mission = triggers, other = other }, "Escape", { Icon.Escape, Icon.LootDrop })
EHI:AddXPBreakdown({
    objective =
    {
        escape = 12000
    },
    loot_all = 1000
})