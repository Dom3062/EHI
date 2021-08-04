local EHI = EHI
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
		[100008] = { time = 60, id = "ExplosivesTimer", icons = { "equipment_timer" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists },
		[100007] = { id = "ExplosivesTimer", special_function = SF.PauseTracker }
	}
}

local _f_prepare_mission_data = CoreWorldInstanceManager.prepare_mission_data
function CoreWorldInstanceManager:prepare_mission_data(instance, ...)
	local instance_data = _f_prepare_mission_data(self, instance, ...)
	local folder = instance.folder
	if instances[folder] then
		local instance_elements = instances[folder]
		local start_index = instance.start_index
		local continent_data = managers.worlddefinition._continents[instance.continent]
		local triggers = {}
		for id, trigger in pairs(instance_elements) do
			local final_index = EHI:GetInstanceElementID(id, start_index, continent_data.base_id)
			triggers[final_index] = EHI:DeepClone(trigger)
			triggers[final_index].id = triggers[final_index].id .. final_index
		end
		EHI:AddTriggers(triggers, "Trigger", {})
	end
	return instance_data
end