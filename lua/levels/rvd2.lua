local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local element_sync_triggers =
{
    [101374] = { id = "VaultTeargas", icons = { Icon.Teargas }, hook_element = 101377 }
}
---@type ParseTriggerTable
local triggers = {
    [100903] = { time = 120, id = "LiquidNitrogen", icons = { Icon.LiquidNitrogen }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1009031 }, waypoint = { position_by_element = 100941 } },
    [1009031] = { time = 63 + 6 + 4 + 30 + 24 + 3, id = "HeliC4", icons = Icon.HeliDropC4, waypoint = { icon = Icon.C4, position_by_element = 100943 } },

    [100699] = { time = 8 + 25 + 13, id = "ObjectiveWait", icons = { Icon.Wait } },

    [100939] = { time = 5, id = "C4Vault", icons = { Icon.C4 }, waypoint = { position_by_element = 100941 } },
    [EHI:GetInstanceElementID(100020, 6700)] = { time = 5, id = "C4Escape", icons = { Icon.C4 }, waypoint = { position_by_unit = EHI:GetInstanceUnitID(100008, 6700) } }
}
if EHI:IsClient() then
    EHI:SetSyncTriggers(element_sync_triggers)
    ---@param self EHIManager
    ---@param trigger ElementTrigger
    local function WP(self, trigger)
        if self._waypoints:WaypointDoesNotExist("LiquidNitrogen") then
            self._waypoints:AddWaypoint("LiquidNitrogen", {
                time = trigger.time - 10,
                icon = Icon.LiquidNitrogen,
                position = EHI:GetElementPosition(100941) or Vector3(),
            })
        end
        if self._waypoints:WaypointDoesNotExist("HeliC4") then
            self._waypoints:AddWaypoint("HeliC4", {
                time = trigger.time,
                icon = Icon.C4,
                position = EHI:GetElementPosition(100943) or Vector3()
            })
        end
    end
    triggers[101366] = { additional_time = 5 + 40, random_time = 10, id = "VaultTeargas", icons = { Icon.Teargas } }
    local LiquidNitrogen = EHI:RegisterCustomSpecialFunction(function(self, trigger, ...)
        if self._trackers:TrackerDoesNotExist("LiquidNitrogen") then
            local t = trigger.time - 10
            self._trackers:AddTracker({
                id = "LiquidNitrogen",
                time = t,
                icons = { Icon.LiquidNitrogen }
            })
        end
        if self._trackers:TrackerDoesNotExist("HeliC4") then
            self._trackers:AddTracker({
                id = "HeliC4",
                time = trigger.time,
                icons = Icon.HeliDropC4
            })
        end
    end)
    triggers[101498] = { time = 6 + 4 + 30 + 24 + 3, special_function = LiquidNitrogen, waypoint_f = WP }
    triggers[100035] = { time = 4 + 30 + 24 + 3, special_function = LiquidNitrogen, waypoint_f = WP }
    triggers[101630] = { time = 30 + 24 + 3, special_function = LiquidNitrogen, waypoint_f = WP }
    triggers[101629] = { time = 24 + 3, special_function = LiquidNitrogen, waypoint_f = WP }
else
    EHI:AddHostTriggers(element_sync_triggers, "element")
end
local other =
{
    [100109] = EHI:AddAssaultDelay({ time = 30 + 30 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100015] = { chance = 10, time = 1 + 10 + 25, on_fail_refresh_t = 25, on_success_refresh_t = 20 + 10 + 25, id = "Snipers", class = TT.Sniper.Loop, trigger_times = 1 }
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({ mission = triggers, other = other })
EHI:ShowAchievementLootCounter({
    achievement = "rvd_11",
    max = 19,
    counter =
    {
        check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
        loot_type = { "diamonds_dah", "diamonds" }
    }
})

local DisableWaypoints =
{
    [101768] = true, -- Defend PC
    [101765] = true -- Fix PC

    -- levels/instances/unique/rvd/rvd_hackbox/world
    -- Handled in CoreWorldInstanceManager.lua
}
EHI:DisableWaypoints(DisableWaypoints)
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 6000, name = "rvd2_hacking_done" },
        { amount = 2000, name = "vault_drills_done" },
        { amount = 4000, name = "rvd2_vault_frozen" },
        { amount = 2000, name = "c4_set_up" },
        { escape = 1000 }
    },
    loot_all = 500,
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                -- max = 19 diamond bags, 3 money bags in the safes (random), 3 bags in GenSec transport
                loot_all = { min = 6, max = 25 }
            }
        }
    }
})