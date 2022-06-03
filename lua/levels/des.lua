local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove("overkill")
local triggers = {
    [100296] = { max = 2, id = "uno_5", class = TT.AchievementProgress, condition = show_achievement and ovk_and_up },
    [103391] = { id = "uno_5", special_function = SF.IncreaseProgress },
    [103395] = { id = "uno_5", special_function = SF.SetAchievementFailed },

    [100107] = { id = "des_9", status = "push", class = TT.AchievementNotification, condition = show_achievement and ovk_and_up },
    [102480] = { special_function = SF.Trigger, data = { 1024801, 1024802 } },
    [1024801] = { id = "des_9", status = "finish", special_function = SF.SetAchievementStatus },
    [1024802] = { special_function = SF.RemoveTriggers, data = { 102486 } },
    [102710] = { id = "des_9", special_function = SF.SetAchievementComplete },
    [102486] = { id = "des_9", special_function = SF.SetAchievementFailed },

    [108538] = { time = 60, id = "Gas", icons = { Icon.Teargas } },

    [103025] = { special_function = SF.Trigger, data = { 1030251, 1030252 } },
    [1030251] = { time = 3, id = "des_11", class = TT.Achievement },
    [1030252] = { special_function = SF.RemoveTriggers, data = { 103025 } },
    [102822] = { id = "des_11", special_function = SF.SetAchievementComplete },
    [100716] = { time = 30, id = "ChemLabThermite", icons = { Icon.Fire } },

    [100423] = { time = 60 + 25 + 3, id = "EscapeHeli", icons = Icon.HeliEscape },
    -- 60s delay after flare has been placed
    -- 25s to land
    -- 3s to open the heli doors

    [102593] = { time = 30, id = "ChemSetReset", icons = { Icon.Methlab, "restarter" } },
    [101217] = { time = 30, id = "ChemSetInterrupted", icons = { Icon.Methlab, "restarter" }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "ChemSetCooking" } },
    [102595] = { time = 30, id = "ChemSetCooking", icons = { Icon.Methlab } },

    [102009] = { time = 60, id = "Crane", icons = { "equipment_winch_hook" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [101702] = { id = "Crane", special_function = SF.PauseTracker }
}
if Network:is_client() then
    triggers[100564] = { time = 25 + 3, id = "EscapeHeli", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist }
    -- Not worth adding the 3s delay here
end

local DisableWaypoints =
{
    -- Hackboxes at the start
    [EHI:GetInstanceElementID(100007, 11000)] = true, -- Defend
    [EHI:GetInstanceElementID(100008, 11000)] = true, -- Fix
    [EHI:GetInstanceElementID(100007, 11500)] = true, -- Defend
    [EHI:GetInstanceElementID(100008, 11500)] = true, -- Fix

    -- Archaeology
    [EHI:GetInstanceElementID(100008, 21000)] = true, -- Defend
    -- Interact is disabled in CoreWorldInstanceManager.lua

    -- Turret charging computer
    [101122] = true, -- Defend
    [103191] = true, -- Fix

    -- Outside hack turret box
    [102901] = true, -- Defend
    [102902] = true, -- Fix
    [102926] = true, -- Defend
    [102927] = true -- Fix
}

EHI:ParseTriggers(triggers)
EHI:DisableWaypoints(DisableWaypoints)

local tbl =
{
    --units/pd2_dlc_des/props/des_prop_inter_hack_computer/des_inter_hack_computer
    [103009] = { icons = { Icon.Power } },

    --units/pd2_dlc_dah/props/dah_prop_hack_box/dah_prop_hack_ipad_unit
    [101323] = { remove_on_power_off = true },
    [101324] = { remove_on_power_off = true },

    --levels/instances/unique/des/des_drill
    --units/payday2/equipment/gen_interactable_drill_small/gen_interactable_drill_small_no_jam
    [EHI:GetInstanceElementID(100030, 21000)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100009, 21000) }
}
EHI:UpdateUnits(tbl)