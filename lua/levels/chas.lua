local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local show_achievement = EHI:GetOption("show_achievement")
local ovk_and_up = EHI:IsDifficultyOrAbove("overkill")
local element_sync_triggers = {
    [100209] = { time = 5, id = "LoudEscape", icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist, client_on_executed = SF.RemoveTriggerWhenExecuted, hook_element = 100602, remove_trigger_when_executed = true },
    [100883] = { time = 12.5, id = "HeliArrivesWithDrill", icons = Icon.HeliDropDrill, hook_element = 102453, remove_trigger_when_executed = true }
}
local triggers = {
    [100107] = { time = 360, id = "chas_11", class = TT.Achievement, condition = ovk_and_up and show_achievement },
    [EHI:GetInstanceElementID(100017, 11325)] = { id = "Gas", special_function = SF.RemoveTracker },

    [102863] = { time = 41.5, id = "TramArrivesWithDrill", icons = { "pd2_question", "pd2_drill", "pd2_goto" } },
    [101660] = { time = 120, id = "Gas", icons = { "teargas" } },

    [100781] = { id = "chas_9", class = TT.AchievementNotification },
    [100907] = { id = "chas_9", special_function = SF.SetAchievementFailed },
    [100906] = { id = "chas_9", special_function = SF.SetAchievementComplete }
}
if Network:is_client() then
    triggers[100602] = { time = 90 + 5, random_time = 20, id = "LoudEscape", icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[102453] = { time = 60 + 12.5, random_time = 20, id = "HeliArrivesWithDrill", icons = Icon.HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist }
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end
local DisableWaypoints =
{
    -- chas_store_computer
    [EHI:GetInstanceElementID(100018, 10675)] = true, -- Defend
    -- Fix is in CoreWorldInstanceManager.lua
    -- chas_vault_door
    [EHI:GetInstanceElementID(100029, 5950)] = true, -- Defend
    [EHI:GetInstanceElementID(100030, 5950)] = true -- Fix
}

EHI:ParseTriggers(triggers)
EHI:DisableWaypoints(DisableWaypoints)