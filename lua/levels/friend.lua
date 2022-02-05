local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local mayhem_and_up = EHI:IsDifficultyOrAbove("mayhem")
local element_sync_triggers =
{
    [100241] = { time = 662/30, id = "EscapeBoat", icons = Icon.BoatEscape, hook_element = 100216 },
}
local random_car = { time = 18, id = "RandomCar", icons = { Icon.Heli, "pd2_goto" }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "BileArrival" } }
local caddilac = { time = 18, id = "Caddilac", icons = { Icon.Heli, "pd2_goto" } }
local triggers = {
    [100109] = { time = 30 + 1 + 30, id = "FirstAssaultDelay", icons = Icon.FirstAssaultDelay, class = TT.Warning, special_function = SF.RemoveTriggerWhenExecuted },

    [100107] = { time = 901, id = "uno_7", class = "EHIAchievementObtainableTracker", condition = mayhem_and_up and show_achievement, exclude_from_sync = true },
    [102291] = { max = 2, id = "friend_5", class = TT.AchievementProgress },
    [102430] = { time = 780, id = "friend_6", class = TT.Achievement, condition = mayhem_and_up and show_achievement, exclude_from_sync = true },

    [100103] = { time = 15 + 5, random_time = 10, id = "BileArrival", icons = { Icon.Heli } },

    [100238] = random_car,
    [100249] = random_car,
    [100310] = random_car,
    [100313] = random_car,
    [100314] = random_car,

    [102231] = { time = 20, id = "BileDropCar", icons = { Icon.Heli, Icon.Car, "pd2_goto" } },

    [100718] = caddilac,
    [100720] = caddilac,
    [100732] = caddilac,
    [100733] = caddilac,
    [100734] = caddilac,

    [102253] = { time = 11, id = "BileDropCaddilac", icons = { Icon.Heli, { icon = Icon.Car, color = Color("FFFF00") }, "pd2_goto" } },

    [100213] = { time = 450/30, id = "EscapeCar1", icons = Icon.CarEscape },
    [100214] = { time = 160/30, id = "EscapeCar2", icons = Icon.CarEscape },

    [102814] = { time = 180, id = "Safe", icons = { "equipment_winch_hook" }, special_function = SF.UnpauseTrackerIfExists, class = TT.Pausable },
    [102815] = { id = "Safe", special_function = SF.PauseTracker },

    [102280] = { id = "friend_5", special_function = SF.IncreaseProgress }
}
if Network:is_client() then
    triggers[100216] = { time = 662/30, random_time = 10, id = "EscapeBoat", icons = Icon.BoatEscape, special_function = SF.AddTrackerIfDoesNotExist }
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end

EHI:ParseTriggers(triggers)
EHI:ShowLootCounter(16)