local EHI = EHI
if EHI._hooks.CoreWorldInstanceManager then
    return
else
    EHI._hooks.CoreWorldInstanceManager = true
end
local debug_instance = false
local SF = EHI.SpecialFunctions
local TT = -- Tracker Type
{
    MallcrasherMoney = "EHIMoneyCounterTracker",
    Warning = "EHIWarningTracker",
    Pausable = "EHIPausableTracker",
    Chance = "EHIChanceTracker",
    Progress = "EHIProgressTracker",
    Achievement = "EHIAchievementTracker",
    AchievementProgress = "EHIAchievementProgressTracker",
    AchievementNotification = "EHIAchievementNotificationTracker",
    Inaccurate = "EHIInaccurateTracker",
    InaccurateWarning = "EHIInaccurateWarningTracker"
}
local instance_index = 1
local used_start_indexes = {}
local instances =
{
    ["levels/instances/shared/obj_skm/world"] = -- Hostage in the Holdout mode
    {
        [100032] = { time = 7, id = "HostageRescue", icons = { "pd2_kill" }, class = TT.Warning },
        [100036] = { id = "HostageRescue", special_function = SF.RemoveTracker }
    },
    ["levels/instances/unique/pbr/pbr_mountain_comm_dish/world"] =
    {
        [100008] = { time = 5, id = "SatelliteC4Explosion", icons = { "pd2_c4" } }
    },
    ["levels/instances/unique/pbr/pbr_mountain_comm_dish_huge/world"] =
    {
        [100013] = { time = 5, id = "HugeSatelliteC4Explosion", icons = { "pd2_c4" } }
    },
    ["levels/instances/unique/fex/fex_explosives/world"] =
    {
        [100008] = { time = 60, id = "FexExplosivesTimer", icons = { "equipment_timer" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
        [100007] = { id = "FexExplosivesTimer", special_function = SF.PauseTracker }
    }
}

local _f_prepare_mission_data = CoreWorldInstanceManager.prepare_mission_data
function CoreWorldInstanceManager:prepare_mission_data(instance, ...)
    local instance_data = _f_prepare_mission_data(self, instance, ...)
    local folder = instance.folder
    if instances[folder] then
        local start_index = instance.start_index
        if not used_start_indexes[start_index] then
        -- Don't compute the indexes again if the instance on this start_index has been computed already
        -- start_index is unique for instance in a heist, so this shouldn't break anything
            local instance_elements = instances[folder]
            local continent_data = managers.worlddefinition._continents[instance.continent]
            local triggers = {}
            for id, trigger in pairs(instance_elements) do
                local final_index = EHI:GetInstanceElementID(id, start_index, continent_data.base_id)
                triggers[final_index] = EHI:DeepClone(trigger)
                triggers[final_index].id = triggers[final_index].id .. instance_index
            end
            EHI:AddTriggers(triggers, "Trigger", {})
            used_start_indexes[start_index] = true
        end
        instance_index = instance_index + 1
    end
    if debug_instance then
        EHI:Log("Instance Folder: " .. tostring(folder))
        EHI:Log("Instance Start Index: " .. tostring(instance.start_index))
        EHI:Log("Instance Rotation: " .. tostring(instance.rotation))
    end
    return instance_data
end