local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local Hints = EHI.Hints
local inspect = 30
local escape = 23 + 7
local triggers = {
    [103132] = { time = 210 + 90 + 30 + 240, id = "HeliArrival", icons = Icon.HeliLootDrop, hint = Hints.Loot }, -- Includes heli refuel (330s)
    [103130] = { time = 90 + 30 + 240, id = "HeliArrival", icons = Icon.HeliLootDrop, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.Loot },
    [103133] = { time = 30 + 240, id = "HeliArrival", icons = Icon.HeliLootDrop, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.Loot },
    [103630] = { time = 240, id = "HeliArrival", icons = Icon.HeliLootDrop, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.Loot },
    [100372] = { time = 150, id = "HeliArrival", icons = Icon.HeliLootDrop, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.Loot },
    [100371] = { time = 120, id = "HeliArrival", icons = Icon.HeliLootDrop, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.Loot },
    [100363] = { time = 90, id = "HeliArrival", icons = Icon.HeliLootDrop, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.Loot },
    [100355] = { time = 60, id = "HeliArrival", icons = Icon.HeliLootDrop, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.Loot },

    [103355] = { time = inspect, id = "Inspect", icons = { Icon.Wait }, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.Wait },
    [100266] = { time = 30 + inspect, id = "Inspect", icons = { Icon.Wait }, special_function = SF.SetTimeOrCreateTracker, hint = Hints.Wait },
    [100271] = { time = 45 + inspect, id = "Inspect", icons = { Icon.Wait }, special_function = SF.SetTimeOrCreateTracker, hint = Hints.Wait },
    [100273] = { time = 60 + inspect, id = "Inspect", icons = { Icon.Wait }, special_function = SF.SetTimeOrCreateTracker, hint = Hints.Wait },
    [103319] = { time = 75 + inspect, id = "Inspect", icons = { Icon.Wait }, special_function = SF.SetTimeOrCreateTracker, hint = Hints.Wait },
    [100265] = { time = 45 + 75 + inspect, id = "Inspect", icons = { Icon.Wait }, hint = Hints.Wait, class = EHI.Trackers.TimePreSync },

    -- Heli escape
    [100898] = { time = 15 + escape, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, hint = Hints.Escape, waypoint = { icon = Icon.Escape, position_from_element = 100896 } },
    [100902] = { time = 30 + escape, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, hint = Hints.Escape, waypoint = { icon = Icon.Escape, position_from_element = 100896 } },
    [100904] = { time = 45 + escape, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, hint = Hints.Escape, waypoint = { icon = Icon.Escape, position_from_element = 100896 } },
    [100905] = { time = 60 + escape, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, hint = Hints.Escape, waypoint = { icon = Icon.Escape, position_from_element = 100896 } }
}
if EHI:GetWaypointOption("show_waypoints_mission") then
    if EHI:IsDifficultyOrAbove(EHI.Difficulties.Mayhem) then -- ´disable_2nd_helicopter´ ElementFilter 104393
        local SetWaypoints = EHI.Trigger:RegisterCustomSF(function(self, trigger, ...)
            if self._cache.wttj2_flare_set then
                return
            end
            local element_vector = self._mission:GetElementPositionOrDefault(trigger.element)
            local EngineLootDropWP = { icon = Icon.LootDrop, position = element_vector }
            self:AddWaypointToTrigger(103132, EngineLootDropWP)
            self:AddWaypointToTrigger(103130, EngineLootDropWP)
            self:AddWaypointToTrigger(103133, EngineLootDropWP)
            self:AddWaypointToTrigger(103630, EngineLootDropWP)
            self:AddWaypointToTrigger(100372, EngineLootDropWP)
            self:AddWaypointToTrigger(100371, EngineLootDropWP)
            self:AddWaypointToTrigger(100363, EngineLootDropWP)
            self:AddWaypointToTrigger(100355, EngineLootDropWP)
            local InspectWP = { position = element_vector }
            self:AddWaypointToTrigger(103355, InspectWP)
            self:AddWaypointToTrigger(100266, InspectWP)
            self:AddWaypointToTrigger(100271, InspectWP)
            self:AddWaypointToTrigger(100273, InspectWP)
            self:AddWaypointToTrigger(103319, InspectWP)
            self:AddWaypointToTrigger(100265, InspectWP)
            self._cache.wttj2_flare_set = true
        end)
        triggers[100005] = { special_function = SetWaypoints, element = 100001 }
        triggers[104416] = { special_function = SetWaypoints, element = 104408 }
        if EHI.IsClient then
            triggers[104423] = { special_function = SetWaypoints, element = 100001 }
            triggers[100014] = { special_function = SetWaypoints, element = 104408 }
        end
        EHI.Trigger:AddLoadSyncFunction(function(self)
            if managers.environment_effects._mission_effects[100014] then
                self:RunTrigger(100005)
            elseif managers.environment_effects._mission_effects[104423] then
                self:RunTrigger(104416)
            end
        end)
    else
        local EngineLootDropWP = { icon = Icon.LootDrop, position_from_element = 100001 }
        triggers[103132].waypoint = deep_clone(EngineLootDropWP)
        triggers[103130].waypoint = deep_clone(EngineLootDropWP)
        triggers[103133].waypoint = deep_clone(EngineLootDropWP)
        triggers[103630].waypoint = deep_clone(EngineLootDropWP)
        triggers[100372].waypoint = deep_clone(EngineLootDropWP)
        triggers[100371].waypoint = deep_clone(EngineLootDropWP)
        triggers[100363].waypoint = deep_clone(EngineLootDropWP)
        triggers[100355].waypoint = deep_clone(EngineLootDropWP)
        local InspectWP = { position_from_element = 100001 }
        triggers[103355].waypoint = deep_clone(InspectWP)
        triggers[100266].waypoint = deep_clone(InspectWP)
        triggers[100271].waypoint = deep_clone(InspectWP)
        triggers[100273].waypoint = deep_clone(InspectWP)
        triggers[103319].waypoint = deep_clone(InspectWP)
        triggers[100265].waypoint = deep_clone(InspectWP)
    end
end

local other =
{
    [100531] = EHI:AddAssaultDelay({ control = 35 })
}
if EHI:GetLoadSniperTrackers() then
    local max_snipers = 2
    local function Spawn()
        max_snipers = max_snipers - 1
        managers.ehi_tracker:CallFunction("Snipers", "SniperSpawned") -- Counting is done in EHISniperBase
        if max_snipers <= 0 then
            EHISniperBase.unregister_spawn_listener("wttj2")
            managers.ehi_tracker:CallFunction("Snipers", "RequestRemoval")
        end
    end
    other[100537] = EHI:AddCustomCode(function(self)
        self._trackers:AddTracker({
            id = "Snipers",
            time = 90,
            chance = 20,
            on_fail_refresh_t = 30,
            single_sniper = true,
            class = EHI.Trackers.Sniper.Loop
        })
        EHISniperBase.register_spawn_listener("wttj2", Spawn)
    end)
    other[100483] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
end
managers.ehi_hudlist:CallRightListItemFunction("Unit", "EnablePersistentSniperItem")

EHI.Mission:ParseTriggers({ mission = triggers, other = other,
    assault =
    {
        diff_load_sync = function(self, assault_number, in_assault)
            if self.ConditionFunctions.IsStealth() then
                return
            elseif assault_number <= 1 or (assault_number == 2 and in_assault) then
                self._assault:SetDiff(0.5)
            elseif assault_number <= 3 or (assault_number == 4 and in_assault) then
                self._assault:SetDiff(0.75)
            else
                self._assault:SetDiff(1)
            end
        end
    } })
EHI.Unit:UpdateUnits({
    --units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b
    [103320] = { remove_vanilla_waypoint = 100309 },
    [101365] = { remove_vanilla_waypoint = 102499 },
    [101863] = { remove_vanilla_waypoint = 102498 }
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 3000, name = "pc_found" },
        { amount = 6000, name = "pc_hack" },
        { amount = 6000, name = "big_oil2_correct_engine" },
        { escape = 6000 }
    }
})
EHI:SetDeployableIgnorePos("ammo_bag", {
    Vector3(-7350, -3525, 591.541),
    Vector3(-4825, -2175, 1330.36),
    Vector3(-375, 3125, 843.889),
    Vector3(175, 3000, -1216.21),
    Vector3(-1600, -2175, 800),
    Vector3(-2053, -4263, -1046.93),
    Vector3(-5931, 2294, 1394.4),
    Vector3(-5425, 6250, 519.189)
})