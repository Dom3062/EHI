local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local LootDropWP = Vector3(0, 0, 152.5)
local vectors =
{
    [4700] = EHI:GetInstanceElementPosition(Vector3(-5091.17, 2221.32, 36.5), LootDropWP, Rotation(0, 0, -0)),
    [4750] = EHI:GetInstanceElementPosition(Vector3(-791.169, -2078.68, 16.5), LootDropWP, Rotation(0, 0, -0)),
    [4800] = EHI:GetInstanceElementPosition(Vector3(-2391.17, 5821.32, 16.5), LootDropWP, Rotation(44.9999, 0, -0)),
    [4850] = EHI:GetInstanceElementPosition(Vector3(-7643.86, 3668.63, 16.5), LootDropWP, Rotation(0, 0, -0))
}
local HeliLootDropWait = { Icon.Heli, Icon.LootDrop, "faster" }
local element_sync_triggers =
{
    [102887] = { time = 1800/30, id = "HeliCage", icons = { Icon.Heli, Icon.LootDrop }, hook_element = 102892 }
}
local triggers = {
    --[100240] = { id = "PAL", special_function = SF.RemoveTracker },
    [102502] = { time = 60, id = "PAL", icons = { Icon.Money }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [102505] = { id = "PAL", special_function = SF.RemoveTracker },
    [102749] = { id = "PAL", special_function = SF.PauseTracker },
    [102738] = { id = "PAL", special_function = SF.PauseTracker },
    [102744] = { id = "PAL", special_function = SF.UnpauseTracker },
    [102826] = { id = "PAL", special_function = SF.RemoveTracker },

    [102301] = { special_function = SF.Trigger, data = { 1023011, 1023012 } },
    [1023011] = { time = 15, id = "Trap", icons = { "pd2_c4" }, class = TT.Warning },
    [1023012] = { id = "pal_3", class = TT.AchievementNotification, condition = EHI:GetOption("show_achievement") and EHI:IsDifficultyOrAbove("overkill") },
    [101566] = { id = "Trap", special_function = SF.RemoveTracker },
    [101976] = { id = "pal_3", special_function = SF.SetAchievementComplete },
    [101571] = { id = "pal_3", special_function = SF.SetAchievementFailed },

    [101230] = { time = 120, id = "Water", icons = { "pd2_water_tap" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
    [101231] = { id = "Water", special_function = SF.PauseTracker }
}

for i = 4700, 4850, 50 do
    triggers[EHI:GetInstanceElementID(100004, i)] = { id = EHI:GetInstanceElementID(100019, i), special_function = SF.ShowWaypoint, data = { icon = Icon.LootDrop, position = vectors[i] } }
end

local heli = { id = "HeliCageDelay", icons = HeliLootDropWait, special_function = SF.ReplaceTrackerWithTracker, data = { id = "HeliCage" }, class = TT.Warning }
local sync_triggers = {
    [EHI:GetInstanceElementID(100013, 4700)] = heli,
    [EHI:GetInstanceElementID(100013, 4750)] = heli,
    [EHI:GetInstanceElementID(100013, 4800)] = heli,
    [EHI:GetInstanceElementID(100013, 4850)] = heli
}
if Network:is_client() then
    local ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists = EHI:GetFreeCustomSpecialFunctionID()
    triggers[102892] = { time = 1800/30 + 120, random_time = 60, id = "HeliCage", icons = { Icon.Heli, Icon.LootDrop }, special_function = SF.AddTrackerIfDoesNotExist }
    triggers[EHI:GetInstanceElementID(100013, 4700)] = { time = 180, random_time = 60, id = "HeliCageDelay", icons = HeliLootDropWait, special_function = ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists, data = { id = "HeliCage" }, class = TT.Warning }
    triggers[EHI:GetInstanceElementID(100013, 4750)] = { time = 180, random_time = 60, id = "HeliCageDelay", icons = HeliLootDropWait, special_function = ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists, data = { id = "HeliCage" }, class = TT.Warning }
    triggers[EHI:GetInstanceElementID(100013, 4800)] = { time = 180, random_time = 60, id = "HeliCageDelay", icons = HeliLootDropWait, special_function = ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists, data = { id = "HeliCage" }, class = TT.Warning }
    triggers[EHI:GetInstanceElementID(100013, 4850)] = { time = 180, random_time = 60, id = "HeliCageDelay", icons = HeliLootDropWait, special_function = ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists, data = { id = "HeliCage" }, class = TT.Warning }
    EHI:SetSyncTriggers(sync_triggers)
    EHI:SetSyncTriggers(element_sync_triggers)
    EHI:RegisterCustomSpecialFunction(ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists, function(id, trigger, ...)
        managers.ehi:RemoveTracker(trigger.data.id)
        if managers.ehi:TrackerDoesNotExist(trigger.id) then
            EHI:CheckCondition(id)
        end
    end)
else
    EHI:AddHostTriggers(sync_triggers, nil, nil, "base")
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end

EHI:ParseTriggers(triggers)
local value_max = tweak_data.achievement.loot_cash_achievements.pal_2.secured.value
local loot_value = managers.money:get_secured_bonus_bag_value("counterfeit_money", 1)
local max = math.ceil(value_max / loot_value)
EHI:ShowAchievementLootCounter({
    achievement = "pal_2",
    max = max,
    exclude_from_sync = true
})

local DisableWaypoints =
{
    -- Defend
    [100912] = true,
    [100913] = true,
    -- Fix
    [100916] = true,
    [100917] = true
}
EHI:DisableWaypoints(DisableWaypoints)

local tbl =
{
    -- Drill
    [102192] = { remove_vanilla_waypoint = true, waypoint_id = 100943 }
}
EHI:UpdateUnits(tbl)