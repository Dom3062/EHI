local EHI = EHI
local Icon = EHI.Icons
local car = { { icon = Icon.Car, color = Color("1E90FF") } }
local move = { time = 10, id = "MoveVehicle", icons = { Icon.Wait } }
local RoadBlockVehicleIndex1 = 550
local RoadBlockVehicleIndex2 = 950
if managers.job:is_level_christmas("hox_1") then
    RoadBlockVehicleIndex1 = 7150
    RoadBlockVehicleIndex2 = 7350
end
local triggers = {
    [101595] = { time = 6, id = "Wait", icons = { Icon.Wait } },

    [102191] = move, -- First Police Car
    [EHI:GetInstanceElementID(100000, RoadBlockVehicleIndex1)] = move, -- Police Car
    [EHI:GetInstanceElementID(100000, RoadBlockVehicleIndex2)] = move, -- Police Car
    [EHI:GetInstanceElementID(100056, RoadBlockVehicleIndex1)] = move, -- SWAT Van
    [EHI:GetInstanceElementID(100056, RoadBlockVehicleIndex2)] = move, -- SWAT Van

    -- Time for animated car (nothing in the mission script, time was debugged with custom code => using rounded number, which should be accurate enough)
    [102626] = { time = 36.2, id = "CarMoveForward", icons = car },
    [102627] = { time = 34.5, id = "CarMoveLeft", icons = car },
    [102628] = { time = 34.5, id = "CarMoveRight", icons = car },
    -- In Garage
    [101383] = { time = 44.3, id = "CarGoingIntoGarage", icons = car },
    [101397] = { time = 22.6, id = "CarMoveRightFinal", icons = car }
}

EHI:ParseTriggers(triggers)

local tbl =
{
    --levels/instances/unique/hox_breakout_road001
    --units/payday2/equipment/gen_interactable_drill_small/gen_interactable_drill_small
    [EHI:GetInstanceElementID(100058, RoadBlockVehicleIndex1)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100090, RoadBlockVehicleIndex1) },
    [EHI:GetInstanceElementID(100058, RoadBlockVehicleIndex2)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100090, RoadBlockVehicleIndex2) }
}
for i = 1350, 4950, 400 do
    --units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b
    tbl[EHI:GetInstanceElementID(100025, i)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100072, i), restore_waypoint_on_done = true }
end
EHI:UpdateUnits(tbl)