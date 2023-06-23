local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local delay = 17 + 30 + 450/30 -- Boat escape; Van escape is 100215 and 100216
local triggers = {
    [100259] = { time = 120 + delay },
    [100258] = { time = 100 + delay },
    [100257] = { time = 80 + delay },
    [100209] = { time = 60 + delay },

    [100214] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position_by_element = 100233 } },
    [100215] = { special_function = SF.Trigger, data = { 1002151, 1002152 } },
    [1002151] = { time = 674/30, special_function = SF.SetTimeOrCreateTracker },
    [1002152] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100008 } },
    [100216] = { special_function = SF.Trigger, data = { 1002161, 1002162 } },
    [1002161] = { time = 543/30, special_function = SF.SetTimeOrCreateTracker },
    [1002162] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100020 } }
}
local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 30 + 30 })
}
if EHI:GetOption("show_escape_chance") then
    other[104800] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi_escape:AddEscapeChanceTracker(dropin, 15)
    end)
end
--[[if EHI:GetOption("show_loot_counter") then
    local trucks =
    {
        100006, 100007, 100021, 100022, 100023, 100024, 100025, 100097, 100100, 100101, 100226, 100227
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
        local wd = managers.worlddefinition
        for _, truck_id in ipairs(trucks) do
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
    other[100238] = { special_function = SF.CustomCode, f = LootCounter, arg = 1 }
    other[104891] = { special_function = SF.CustomCode, f = LootCounter, arg = 2 }
    other[104892] = { special_function = SF.CustomCode, f = LootCounter, arg = 3 }
    other[104893] = { special_function = SF.CustomCode, f = LootCounter, arg = 4 }
end]]

EHI:ParseTriggers({ mission = triggers, other = other }, "Escape", { Icon.Escape, Icon.LootDrop })
EHI:AddXPBreakdown({
    objective =
    {
        escape = 12000
    },
    loot_all = 1000
})