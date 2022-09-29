local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local escape_delay = 18
local triggers = {
    [102873] = { time = 36 + 5 + 3 + 60 + 30 + 38 + 7, id = "VanPickupLoot", icons = Icon.CarLootDrop },

    [101256] = { time = 3 + 28 + 10 + 10, id = "CarEscape", icons = Icon.CarEscapeNoLoot },

    [101218] = { time = 60 + 60 + 30 + 30 + escape_delay, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot },
    [101219] = { time = 60 + 30 + 30 + escape_delay, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot },
    [101221] = { time = 30 + 30 + escape_delay, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot }
}

-- Not possible to include Van location waypoint as this is selected randomly
-- See ´LootVehicleArrived´ MissionScriptElement 100658

if Network:is_client() then
    triggers[101307] = { time = 5 + 3 + 60 + 30 + 38 + 7, id = "VanPickupLoot", icons = Icon.CarLootDrop, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101308] = { time = 5 + 3 + 60 + 30 + 38 + 7, id = "VanPickupLoot", icons = Icon.CarLootDrop, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101309] = { time = 5 + 3 + 60 + 30 + 38 + 7, id = "VanPickupLoot", icons = Icon.CarLootDrop, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[100944] = { time = 3 + 60 + 30 + 38 + 7, id = "VanPickupLoot", icons = Icon.CarLootDrop, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101008] = { time = 60 + 30 + 38 + 7, id = "VanPickupLoot", icons = Icon.CarLootDrop, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101072] = { time = 30 + 38 + 7, id = "VanPickupLoot", icons = Icon.CarLootDrop, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101073] = { time = 38 + 7, id = "VanPickupLoot", icons = Icon.CarLootDrop, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[100658] = { time = 7, id = "VanPickupLoot", icons = Icon.CarLootDrop, special_function = SF.AddTrackerIfDoesNotExist }

    triggers[103300] = { time = 60 + 30 + 30 + escape_delay, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[103301] = { time = 30 + 30 + escape_delay, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[103302] = { time = 30 + escape_delay, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[101223] = { time = escape_delay, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = SF.AddTrackerIfDoesNotExist }
end

local achievements =
{
    [101137] = { id = "hot_wheels", status = "finish", class = TT.AchievementStatus },
    [102487] = { id = "hot_wheels", special_function = SF.SetAchievementFailed },
    [102470] = { id = "hot_wheels", special_function = SF.SetAchievementComplete }
}

local condition = EHI:GetOption("show_assault_delay_tracker")
local other =
{
    [101244] = { time = 60 + 30, id = "AssaultDelay", class = TT.AssaultDelay, condition = condition },
    [101245] = { time = 45 + 30, id = "AssaultDelay", class = TT.AssaultDelay, condition = condition },
    [101249] = { time = 50 + 30, id = "AssaultDelay", class = TT.AssaultDelay, condition = condition }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
local max = 8
if EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard) then
    max = 12
end
EHI:ShowLootCounter({ max = max })