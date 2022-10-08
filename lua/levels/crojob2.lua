local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local start_index = { 1100, 1400, 1700, 2000, 2300, 2600, 2900, 3500, 3800, 4100, 4400, 4700 }
local interact = { id = "MethlabInteract", icons = { Icon.Methlab, Icon.Loop } }
local element_sync_triggers = {}
for _, index in pairs(start_index) do
    for i = 100169, 100172, 1 do
        local element_id = EHI:GetInstanceElementID(i, index)
        element_sync_triggers[element_id] = EHI:DeepClone(interact)
        element_sync_triggers[element_id].hook_element = EHI:GetInstanceElementID(100168, index)
    end
end
local chopper_delay = 25 + 1 + 2.5
local triggers = {
    [102120] = { time = 5400/30, id = "ShipMove", icons = { Icon.Boat, Icon.Wait }, special_function = SF.RemoveTriggerWhenExecuted },

    [101545] = { time = 100 + chopper_delay, id = "C4FasterPilot", icons = Icon.HeliDropC4 },
    [101749] = { time = 160 + chopper_delay, id = "C4", icons = Icon.HeliDropC4 },

    [106295] = { time = 705/30, id = "VanEscape", icons = Icon.CarEscape, special_function = SF.ExecuteIfElementIsEnabled },
    [106294] = { time = 1200/30, id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.ExecuteIfElementIsEnabled },
    [100339] = { time = 0.2 + 450/30, id = "BoatEscape", icons = Icon.BoatEscape, special_function = SF.ExecuteIfElementIsEnabled }
}
for _, index in pairs(start_index) do
    triggers[EHI:GetInstanceElementID(100118, index)] = { time = 1, id = "MethlabRestart", icons = { Icon.Methlab, Icon.Loop } }
    triggers[EHI:GetInstanceElementID(100152, index)] = { time = 5, id = "MethlabPickUp", icons = { Icon.Methlab, Icon.Interact } }
end
if EHI:IsClient() then
    local random_time = { id = "MethlabInteract", icons = { Icon.Methlab, Icon.Loop }, class = TT.Inaccurate, special_function = SF.SetRandomTime, data = { 25, 35, 45, 65 } }
    for _, index in pairs(start_index) do
        triggers[EHI:GetInstanceElementID(100149, index)] = random_time
        triggers[EHI:GetInstanceElementID(100150, index)] = random_time
        triggers[EHI:GetInstanceElementID(100184, index)] = { id = "MethlabInteract", special_function = SF.RemoveTracker }
    end
    EHI:SetSyncTriggers(element_sync_triggers)
else
    EHI:AddHostTriggers(element_sync_triggers, nil, nil, "element")
end

local achievements =
{
    [104086] = { id = "cow_10", status = "defend", class = TT.AchievementStatus },
    [102480] = { id = "cow_10", special_function = SF.SetAchievementFailed },
    [106581] = { id = "cow_10", special_function = SF.SetAchievementComplete },

    [101737] = { time = 60, id = "cow_11", class = TT.Achievement },
    [102466] = { id = "cow_11", special_function = SF.RemoveTracker },
    [102479] = { id = "cow_11", special_function = SF.SetAchievementComplete }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
EHI:ShowAchievementLootCounter({
    achievement = "voff_2",
    max = 2,
    counter =
    {
        check_type = EHI.LootCounter.CheckType.OneTypeOfLoot,
        loot_type = "meth"
    }
})