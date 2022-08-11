local EHI = EHI
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local achievements =
{
    [100003] = { time = 60, id = "slakt_1", class = TT.Achievement },
    [100012] = { id = "bob_8", class = TT.AchievementStatus },
    [101248] = { id = "bob_8", special_function = SF.SetAchievementComplete },
    [100469] = { id = "bob_8", special_function = SF.SetAchievementFailed }
}

EHI:ParseTriggers({}, achievements)

local tbl =
{
    --units/payday2/props/off_prop_eday_shipping_computer/off_prop_eday_shipping_computer
    [101210] = { remove_vanilla_waypoint = true, waypoint_id = 101887, ignore_visibility = true, restore_waypoint_on_done = true },
    [101289] = { remove_vanilla_waypoint = true, waypoint_id = 101910, ignore_visibility = true, restore_waypoint_on_done = true },
    [101316] = { remove_vanilla_waypoint = true, waypoint_id = 101913, ignore_visibility = true, restore_waypoint_on_done = true },
    [101317] = { remove_vanilla_waypoint = true, waypoint_id = 101914, ignore_visibility = true, restore_waypoint_on_done = true },
    [101318] = { remove_vanilla_waypoint = true, waypoint_id = 101922, ignore_visibility = true, restore_waypoint_on_done = true },
    [101320] = { remove_vanilla_waypoint = true, waypoint_id = 101923, ignore_visibility = true, restore_waypoint_on_done = true }
}
EHI:UpdateUnits(tbl)