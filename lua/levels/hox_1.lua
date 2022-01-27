local Icon = EHI.Icons
local car = { { icon = Icon.Car, color = Color("1E90FF") } }
local move = { time = 10, id = "MoveVehicle", icons = { Icon.Wait } }
local triggers = {
    [101595] = { time = 6, id = "Wait", icons = { Icon.Wait } },

    [102191] = move, -- First Police Car
    [EHI:GetInstanceElementID(100000, 550)] = move, -- Police Car
    [EHI:GetInstanceElementID(100000, 950)] = move, -- Police Car
    [EHI:GetInstanceElementID(100056, 550)] = move, -- SWAT Van
    [EHI:GetInstanceElementID(100056, 950)] = move, -- SWAT Van
    [EHI:GetInstanceElementID(100000, 7150)] = move, -- Police Car (Xmas Version)
    [EHI:GetInstanceElementID(100000, 7150)] = move, -- Police Car (Xmas Version)
    [EHI:GetInstanceElementID(100056, 7350)] = move, -- SWAT Van (Xmas Version)
    [EHI:GetInstanceElementID(100056, 7350)] = move, -- SWAT Van (Xmas Version)

    -- Time for animated car (nothing in the mission script, time was debugged with custom code => using rounded number, which should be accurate enough)
    [102626] = { time = 36.2, id = "CarMoveForward", icons = car },
    [102627] = { time = 34.5, id = "CarMoveLeft", icons = car },
    [102628] = { time = 34.5, id = "CarMoveRight", icons = car },
    -- In Garage
    [101383] = { time = 44.3, id = "CarGoingIntoGarage", icons = car },
    [101397] = { time = 22.6, id = "CarMoveRightFinal", icons = car }
}

EHI:ParseTriggers(triggers)