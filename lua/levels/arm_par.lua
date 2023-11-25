local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local van_delay = 543/30
local preload =
{
    { hint = EHI.Hints.LootEscape } -- Escape
}
local triggers = {
    [100258] = { run = { time = 120 + van_delay } },
    [100257] = { run = { time = 100 + van_delay } },
    [100209] = { run = { time = 80 + van_delay } },
    [100208] = { run = { time = 60 + van_delay } },

    [1] = { run = { time = van_delay }, special_function = SF.AddTrackerIfDoesNotExist },
    [100214] = { special_function = SF.Trigger, data = { 1, 1002141 } },
    [1002141] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100233 } },
    [100215] = { special_function = SF.Trigger, data = { 1, 1002151 } },
    [1002151] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100008 } },
    [100216] = { special_function = SF.Trigger, data = { 1, 1002161 } },
    [1002161] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100020 } },
}
if EHI:GetOption("show_escape_chance") then
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi_escape:AddEscapeChanceTracker(false, 15)
    end)
end
local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 30 + 30 })
}
if EHI:IsHost() then
    -- [ID of disabled unit when truck is visible] = truck ID
    local trucks =
    {
        [102076] = 100007, -- 2
        [101642] = 100021, -- 3
        [102075] = 100023, -- 5
        [102077] = 100024, -- 6
        [102074] = 100097, -- 8
        [100716] = 100100, -- 9
        [102072] = 100226, -- 11
        [102070] = 100227 -- 12
    }
    local trucks_body = { 100006, 100022, 100025, 100101 }
    ---@param count number
    local function LootCounter(count)
        EHI:ShowLootCounterSynced({ max_random = count * 9 })
        local truck = 0
        local hook_function = tweak_data.ehi.functions.HookArmoredTransportUnit
        for enabled_unit_id, truck_id in pairs(trucks) do
            if managers.game_play_central:GetMissionEnabledUnit(enabled_unit_id) then
                truck = truck + 1
                hook_function(truck_id)
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
                        hook_function(truck_id)
                        if truck == count then
                            break
                        end
                    end
                end
            end
        end
    end
    other[100238] = { special_function = SF.CustomCode, f = LootCounter, arg = 1 }
    other[101189] = { special_function = SF.CustomCode, f = LootCounter, arg = 2 }
    other[101190] = { special_function = SF.CustomCode, f = LootCounter, arg = 3 }
    other[101220] = { special_function = SF.CustomCode, f = LootCounter, arg = 4 }
end

if EHI:IsClient() then
    triggers[102379] = { run = { time = 30 + van_delay }, special_function = SF.AddTrackerIfDoesNotExist }
end

EHI:ParseTriggers({ mission = triggers, preload = preload, other = other }, "Escape", Icon.CarEscape)
EHI:AddXPBreakdown({
    objective =
    {
        escape = 12000
    },
    loot_all = 1000
})