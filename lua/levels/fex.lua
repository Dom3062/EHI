local Icon = EHI.Icons
local SF = EHI.SpecialFunctions

local HeliEscape = { Icon.Heli, Icon.Escape, Icon.LootDrop }
local CarEscape = { Icon.Car, Icon.Escape, Icon.LootDrop }

local triggers = {
    -- Van Escape, 2 possible car escape scenarions here, the longer is here, the shorter is in WankerCar
    [101638] = { time = 1 + 60 + 900/30 + 5, id = "CarEscape", icons = CarEscape },
    [EHI:GetInstanceElementID(100358, 10130)] = { time = 1 + 210/30, id = "MayanDoorOpen", icons = { "pd2_door" } },

    [EHI:GetInstanceElementID(100016, 26980)] = { time = 180 + 2, id = "HeliEscape", icons = HeliEscape },

    [EHI:GetInstanceElementID(100007, 25580)] = { time = 6, id = "ThermiteWineCellarDoor1", icons = { Icon.Fire } },
    [EHI:GetInstanceElementID(100007, 25780)] = { time = 6, id = "ThermiteWineCellarDoor2", icons = { Icon.Fire } },

    -- Wanker car
    [EHI:GetInstanceElementID(100029, 27580)] = { time = 610/30 + 2, id = "CarEscape", icons = CarEscape, special_function = SF.SetTimeOrCreateTracker },

    [EHI:GetInstanceElementID(100026, 24580)] = { time = 26.5 + 5, id = "CarBurn", icons = { "pd2_car", "pd2_fire" } },

    [EHI:GetInstanceElementID(100049, 5200)] = { time = 6, id = "ThermiteFrontGate", icons = { "pd2_fire" } },

    [EHI:GetInstanceElementID(100016, 23480)] = { time = 45, id = "SafeHackStealth", icons = { Icon.Vault } }
}
if Network:is_client() then
    triggers[EHI:GetInstanceElementID(100024, 26980)] = { time = 60 + 2, id = "HeliEscape", icons = HeliEscape, special_function = SF.SetTimeOrCreateTracker }
    triggers[EHI:GetInstanceElementID(100030, 26980)] = { time = 25 + 2, id = "HeliEscape", icons = HeliEscape, special_function = SF.SetTimeOrCreateTracker }
    triggers[EHI:GetInstanceElementID(100035, 26980)] = { time = 38 + 2, id = "HeliEscape", icons = HeliEscape, special_function = SF.SetTimeOrCreateTracker }
    triggers[EHI:GetInstanceElementID(100036, 26980)] = { time = 120 + 2, id = "HeliEscape", icons = HeliEscape, special_function = SF.SetTimeOrCreateTracker }
end
local DisableWaypoints =
{
    -- fex_saw_reinforced_door
    [EHI:GetInstanceElementID(100015, 27280)] = true, -- Defend
    [EHI:GetInstanceElementID(100068, 27280)] = true, -- Fix
    -- fex_safe
    [EHI:GetInstanceElementID(100029, 23480)] = true, -- Defend
    [EHI:GetInstanceElementID(100022, 23480)] = true -- Fix
}

EHI:ParseTriggers(triggers)
EHI:DisableWaypoints(DisableWaypoints)