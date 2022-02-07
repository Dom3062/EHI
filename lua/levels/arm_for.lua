-- MissionDoor class; figure out a solution
--[[if EHI:ShouldDisableWaypoints() then
    local vault_ids = {
        [0] = { waypoint_id = 0 }
    }
    for _, vault_id in pairs(vault_ids) do
        managers.mission:add_runned_unit_sequence_trigger(vault_id, "drill_placed", function(unit)
            for _, waypoint_id in pairs(waypoint_ids) do
                managers.hud:SoftRemoveWaypoint(waypoint_id)
                EHI._cache.IgnoreWaypoints[waypoint_id] = true
            end
        end)
    end
end]]

local Icon = EHI.Icons
local TT = EHI.Trackers
local SF = EHI.SpecialFunctions
local truck_delay = 524/30
local boat_delay = 450/30
local triggers = {
    [104082] = { time = 30 + 24 + 3, id = "HeliThermalDrill", icons = Icon.HeliDropDrill },

    -- Boat
    [103273] = { time = boat_delay, id = "BoatSecureTurret", icons = { Icon.Boat, Icon.LootDrop } },
    [103041] = { time = 30 + boat_delay, id = "BoatSecureAmmo", icons = { Icon.Boat, Icon.LootDrop } },

    -- Truck
    [105055] = { time = 15 + truck_delay, id = "TruckSecureTurret", icons = { Icon.Car, Icon.LootDrop } },
    [105183] = { time = 30 + 524/30, id = "TruckSecureAmmo", icons = { Icon.Car, Icon.LootDrop } },

    [104716] = { id = "armored_6", class = TT.AchievementNotification },
    [103311] = { id = "armored_6", special_function = SF.SetAchievementFailed }
}

EHI:ParseTriggers(triggers)
if EHI:GetOption("show_achievement") then
    EHI:ShowAchievementLootCounter({
        achievement = "armored_1",
        max = 20,
        exclude_from_sync = true,
        counter =
        {
            check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
            loot_type = "ammo"
        }
    })
    if managers.ehi:TrackerExists("armored_1") then
        EHI:ShowLootCounter(3, EHI.LootCounter.CheckType.OneTypeOfLoot, "turret")
    else
        EHI:ShowLootCounter(23)
    end
else
    EHI:ShowLootCounter(23)
end