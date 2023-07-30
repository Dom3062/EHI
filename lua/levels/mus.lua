local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local delay = 5
local gas_delay = 0.5
local heli_wp = { icon = Icon.LootDrop, position_by_element = EHI:GetInstanceElementID(100028, 7200) }
local gas_wp = { icon = Icon.Teargas, position_by_element = 100841 }
local triggers = {
    [102442] = { time = 130 + delay, special_function = SF.AddTrackerIfDoesNotExist, waypoint = deep_clone(heli_wp) },
    [102441] = { time = 120 + delay, special_function = SF.AddTrackerIfDoesNotExist, waypoint = deep_clone(heli_wp) },
    [102434] = { time = 110 + delay, special_function = SF.AddTrackerIfDoesNotExist, waypoint = deep_clone(heli_wp) },
    [102433] = { time = 80 + delay, special_function = SF.AddTrackerIfDoesNotExist, waypoint = deep_clone(heli_wp) },

    [102065] = { time = 50 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas }, waypoint = deep_clone(gas_wp) },
    [102067] = { time = 65 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas }, waypoint = deep_clone(gas_wp) },
    [102068] = { time = 80 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas }, waypoint = deep_clone(gas_wp) },
    [102069] = { time = 95 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas }, waypoint = deep_clone(gas_wp) },
    [102070] = { time = 110 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas }, waypoint = deep_clone(gas_wp) },
    [102071] = { time = 125 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas }, waypoint = deep_clone(gas_wp) },
    [102072] = { time = 140 + gas_delay, id = "DiamondChamberGas", icons = { Icon.Teargas }, waypoint = deep_clone(gas_wp) }
}

local DisableWaypoints = {}

for i = 300, 375, 75 do
    DisableWaypoints[EHI:GetInstanceElementID(100033, i)] = true -- Fix
    DisableWaypoints[EHI:GetInstanceElementID(100034, i)] = true -- Defend
end

---@type ParseAchievementTable
local achievements =
{
    bat_4 =
    {
        elements =
        {
            [100840] = { time = 600, class = TT.Achievement },
            [102531] = { special_function = SF.SetAchievementComplete }
        },
        load_sync = function(self)
            self._trackers:AddTimedAchievementTracker("bat_4", 600)
        end
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 35 + 30 })
}
if EHI:IsLootCounterVisible() then
    local ignore_units = {
        [300686] = true,
        [300421] = true,
        [300457] = true
    }
    local function PrintAllInteractions()
        local count = 0
        local interactions = managers.interaction._interactive_units or {}
        for _, unit in ipairs(interactions) do
            if unit:carry_data() and unit:interaction() then
                local unit_id = unit:editor_id()
                if not ignore_units[unit_id] then
                    --[[managers.hud:add_waypoint(unit_id, {
                        icon = Icon.Interact,
                        position = unit:position(),
                        no_sync = true
                    })
                    managers.mission:add_runned_unit_sequence_trigger(unit_id, "interact", function(...)
                        managers.hud:remove_waypoint(unit_id)
                    end)]]
                    EHI:LogFast("Unit is a bag; interaction: " .. tostring(unit:interaction().tweak_data))
                    count = count + 1
                else
                    EHI:LogFast("Unit with ID '" .. tostring(unit_id) .. "' ignored")
                end
            end
        end
        return count
    end

    other[100840] = { special_function = EHI:RegisterCustomSpecialFunction(function(...)
        EHI:ShowLootCounterNoChecks({ max = PrintAllInteractions() + 1 })
    end)}
end
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100015] = { special_function = EHI:RegisterCustomSpecialFunction(function(self, trigger, element, enabled)
        if EHI:IsHost() and element:counter_value() ~= 0 then
            return
        end
        self._trackers:AddTracker({
            id = "Snipers",
            time = 0.05 + 10 + 25,
            chance = 10,
            on_fail_refresh_t = 25,
            on_success_refresh_t = 20 + 10 + 25,
            class = TT.Sniper.Loop
        })
    end) }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
}, "Escape", Icon.HeliEscape)
EHI:DisableWaypoints(DisableWaypoints)
EHI:ShowAchievementLootCounter({
    achievement = "bat_3",
    max = 10,
    show_finish_after_reaching_target = true,
    counter =
    {
        check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
        loot_type = { "mus_artifact_paint", "mus_artifact" }
    }
})

local tbl =
{
    --levels/instances/unique/mus_chamber_controller
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    [EHI:GetInstanceUnitID(100347, 3575)] = { icons = { Icon.Wait }, remove_on_pause = true, warning = true },

    --levels/instances/unique/mus_security_room
    --units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b
    [EHI:GetInstanceUnitID(100041, 6950)] = { remove_vanilla_waypoint = EHI:GetInstanceElementID(100050, 6950) }
}
for i = 300, 375, 75 do
    --levels/instances/unique/mus_security_barrier
    --units/payday2/props/gen_prop_security_timelock/gen_prop_security_timelock
    tbl[EHI:GetInstanceUnitID(100020, i)] = { icons = { Icon.Keycard } }
end
EHI:UpdateUnits(tbl)

---@type MissionDoorTable
local MissionDoor =
{
    -- Diamond Room Hatch
    [Vector3(8638, 193.001, -519)] = 100841
}
EHI:SetMissionDoorPosAndIndex(MissionDoor)
local xp_override =
{
    params =
    {
        min =
        {
            objectives = true
        },
        no_max = true
    }
}
EHI:AddXPBreakdown({
    tactic =
    {
        stealth =
        {
            objectives =
            {
                { amount = 6000, name = "mus_powerboxes" },
                { amount = 2000, name = "mus_first_timelock" },
                { amount = 2000, name = "mus_second_timelock" },
                { amount = 3000, name = "mus_no_gas_trap", optional = true },
                { escape = 4000 }
            },
            loot_all = 1000,
            total_xp_override = xp_override
        },
        loud =
        {
            objectives =
            {
                { amount = 8000, name = "pc_hack" },
                { amount = 5000, name = "mus_first_timelock" },
                { amount = 5000, name = "mus_second_timelock" },
                { amount = 4000, name = "mus_no_gas_trap", optional = true },
                { escape = 6000 }
            },
            loot_all = 1000,
            total_xp_override = xp_override
        }
    }
})