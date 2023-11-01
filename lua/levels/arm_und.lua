local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local van_delay = 674/30
local preload =
{
    { hint = EHI.Hints.LootEscape } -- Escape
}
local triggers = {
    [101235] = { run = { time = 120 + van_delay } },
    [100257] = { run = { time = 100 + van_delay } },
    [100209] = { run = { time = 80 + van_delay } },
    [100208] = { run = { time = 60 + van_delay } },

    [1] = { run = { time = van_delay }, special_function = SF.AddTrackerIfDoesNotExist },
    [100214] = { special_function = SF.Trigger, data = { 1, 1002141 } },
    [1002141] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100233 } },
    [100215] = { special_function = SF.Trigger, data = { 1, 1002151 } },
    [1002151] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 101268 } },
    [100216] = { special_function = SF.Trigger, data = { 1, 1002161 } },
    [1002161] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100008 } }
}
local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 60 + 30 })
}
if EHI:GetOption("show_escape_chance") then
    other[100677] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi_escape:AddEscapeChanceTracker(dropin, 10)
    end)
end
--[[if EHI:GetOption("show_loot_counter") then
    -- [ID of disabled unit when truck is visible] = truck ID
    local trucks =
    {
        [100872] = 100007, -- 2/2
        [100874] = 100021, -- 3/3
        [101805] = 100022, -- 4/4
        [100899] = 100023, -- 5/5
        [100900] = 100024, -- 9/6
        [100907] = 100025, -- 6/7
        [100913] = 100097, -- 7/8
        [100905] = 100100 -- 8/9
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
                --EHI:Log("Truck #" .. tostring(truck) .. ":")
                --local unit = managers.worlddefinition:get_unit(truck_id)
                --[[if unit and unit:base() then
                    local run_sequence = unit:base().run_mission_door_device_sequence
                    unit:base().run_mission_door_device_sequence = function(_unit, sequence_name)
                        EHI:Log("Sequence " .. tostring(sequence_name) .. " triggered in Truck ID: " .. tostring(truck_id))
                        run_sequence(_unit, sequence_name)
                    end
                    --[[local unit_element = unit:damage():get_unit_element()
                    if unit_element then
                        EHI:Log(tostring(unit_element))
                        pcall(function()
                            EHI:PrintTable(unit_element)
                        end)
                    end]]
                --end
                --[[if truck == count then
                    break
                end
            end
        end
    end
    other[100238] = { special_function = SF.CustomCode, f = LootCounter, arg = 1 }
    other[101231] = { special_function = SF.CustomCode, f = LootCounter, arg = 2 }
    other[101947] = { special_function = SF.CustomCode, f = LootCounter, arg = 3 }
    other[102037] = { special_function = SF.CustomCode, f = LootCounter, arg = 4 }
end]]

EHI:ParseTriggers({ mission = triggers, other = other, preload = preload }, "Escape", Icon.CarEscape)
EHI:AddXPBreakdown({
    objective =
    {
        escape = 12000
    },
    loot_all = 1000
})