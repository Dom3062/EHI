local EHI = EHI
local Icon = EHI.Icons
local Hints = EHI.Hints
local car = { { icon = Icon.Car, color = tweak_data.ehi.colors.CarBlue } }
local triggers = {
    [100562] = { time = 1 + 5, id = "C4", icons = { Icon.C4 }, hint = Hints.Explosion, waypoint = { position_from_unit = 100564 } },

    [101595] = { time = 6, id = "Wait", icons = { Icon.Wait }, hint = Hints.Wait },

    [102191] = { time = 10, id = "MoveVehicle", icons = { Icon.Wait }, hint = Hints.hox_1_VehicleMove, waypoint = { data_from_element = 100432 } }, -- First Police Car

    -- Time for animated car (nothing in the mission script, time was debugged with custom code => using rounded number, which should be accurate enough)
    [102626] = { time = 36.2, id = "CarMoveForward", icons = car, hint = Hints.hox_1_Car },
    [102627] = { time = 34.5, id = "CarMoveLeft", icons = car, hint = Hints.hox_1_Car },
    [102628] = { time = 34.5, id = "CarMoveRight", icons = car, hint = Hints.hox_1_Car },
    -- In Garage
    [101383] = { time = 44.3, id = "CarGoingIntoGarage", icons = car, hint = Hints.hox_1_Car },
    [101397] = { time = 22.6, id = "CarMoveRightFinal", icons = car, hint = Hints.hox_1_Car }
}
local other =
{
    [100332] = EHI:AddSniperSpawnedPopup(true, true)
}
tweak_data.ehi.functions.eng_X("eng_4", "eng_4_stats") -- "The one who declared himself the hero" achievement

EHI.Mission:ParseTriggers({ mission = triggers, other = other, assault = { diff = 1 } })

local tbl = {}
if EHI:GetWaypointOption("show_waypoints_mission") then
    --units/payday2/vehicles/anim_vehicle_pickup_sportcab_armored/anim_vehicle_pickup_sportcab_armored/the_car
    tbl[102482] = { f = function(id, unit_data, unit)
        local t = { unit = unit }
        for _, index in ipairs({ 102626, 102627, 102628, 101383, 101397, 101595 }) do
            EHI.Trigger:AddWaypointToTrigger(index, t)
        end
    end}
end
EHI.Unit:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 3000, name = "hox1_first_corner" },
        { amount = 4000, name = "hox1_second_corner" },
        { amount = 200, name = "hox1_blockade_cleared" },
        { amount = 2000, name = "hox1_parking_gate_open" },
        { amount = 4000, name = "hox1_parking_car_reached_garages" },
        { amount = 3000, name = "pc_hack" },
        { escape = 2000 }
    },
    total_xp_override =
    {
        objectives =
        {
            hox1_blockade_cleared = { times = 2 }
        }
    }
})