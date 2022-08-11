local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local element_sync_triggers = {
    [100209] = { time = 5, id = "LoudEscape", icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist, client_on_executed = SF.RemoveTriggerWhenExecuted, hook_element = 100602, remove_trigger_when_executed = true },
    [100883] = { time = 12.5, id = "HeliArrivesWithDrill", icons = Icon.HeliDropDrill, hook_element = 102453, remove_trigger_when_executed = true }
}
local triggers = {
    [EHI:GetInstanceElementID(100017, 11325)] = { id = "Gas", special_function = SF.RemoveTracker },

    [102863] = { time = 41.5, id = "TramArrivesWithDrill", icons = { "pd2_question", Icon.Drill, "pd2_goto" } },
    [101660] = { time = 120, id = "Gas", icons = { Icon.Teargas } }
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
    [EHI:GetInstanceElementID(100030, 5950)] = true, -- Fix
    -- chas_auction_room_door_hack
    [EHI:GetInstanceElementID(100031, 5550)] = true, -- Defend
    [EHI:GetInstanceElementID(100056, 5550)] = true, -- Fix
    [EHI:GetInstanceElementID(100031, 11900)] = true, -- Defend
    [EHI:GetInstanceElementID(100056, 11900)] = true -- Fix
}

local achievements =
{
    [100107] = { special_function = SF.Trigger, data = { 1001071, 1001072, 1001073 } },
    [1001071] = { max = 15, id = "chas_10", class = TT.AchievementProgress, remove_after_reaching_target = false, exclude_from_sync = true, difficulty_pass = ovk_and_up },
    [1001072] = { special_function = SF.CustomCode, f = function ()
        if managers.ehi:TrackerExists("chas_10") then
            EHI:AddAchievementToCounter({
                achievement = "chas_10"
            })
        end
    end },
    [1001073] = { time = 360, id = "chas_11", class = TT.Achievement, difficulty_pass = ovk_and_up },

    [100781] = { id = "chas_9", class = TT.AchievementStatus },
    [100907] = { id = "chas_9", special_function = SF.SetAchievementFailed },
    [100906] = { id = "chas_9", special_function = SF.SetAchievementComplete }
}

EHI:ParseTriggers(triggers, achievements)
EHI:DisableWaypoints(DisableWaypoints)
if EHI:GetOption("show_achievement") and ovk_and_up then
    EHI:AddLoadSyncFunction(function(self)
        if EHI.ConditionFunctions.IsStealth() then
            EHI:ShowAchievementLootCounter({
                achievement = "chas_10",
                max = 15,
                exclude_from_sync = true,
                remove_after_reaching_target = false
            })
            self:SetTrackerProgress("chas_10", managers.loot:GetSecuredBagsAmount())
        end
        self:AddTimedAchievementTracker("chas_11", 360)
    end)
    EHI:AddOnAlarmCallback(function()
        managers.ehi:SetAchievementFailed("chas_10")
    end)
end
EHI:ShowLootCounter({ max = 15 })

local tbl =
{
    --levels/instances/unique/chas/chas_store_computer
    --units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b
    [EHI:GetInstanceElementID(100037, 10675)] = { remove_vanilla_waypoint = true, waypoint_id = EHI:GetInstanceElementID(100017, 10675) },

    --levels/instances/unique/chas/chas_vault_door
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    [EHI:GetInstanceElementID(100065, 5950)] = { icons = { Icon.Vault }, remove_on_pause = true }
}
EHI:UpdateUnits(tbl)