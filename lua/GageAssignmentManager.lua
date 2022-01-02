if EHI._hooks.GageAssignmentManager then
	return
else
	EHI._hooks.GageAssignmentManager = true
end

local original =
{
	sync_load = GageAssignmentManager.sync_load,
	present_progress = GageAssignmentManager.present_progress
}

local function GetGageXPRatio(self, picked_up, max_units)
	if picked_up > 0 then
		local ratio = 1 - (max_units - picked_up) / max_units
		local final_ratio = self._tweak_data:get_experience_multiplier(ratio)
		return final_ratio
	else
		return 1
	end
end

local function UpdateTracker(self, client_sync_load)
	local max_units = self:count_all_units()
	local remaining = self:count_active_units() - 1
	local picked_up = max_units - remaining
	if client_sync_load then
		if not Global.statistics_manager.playing_from_start then
			picked_up = picked_up - 1
			if picked_up < 0 then
				picked_up = 0
			end
			EHI._cache.GagePackagesProgress = picked_up
		end
	end
	managers.ehi:SetTrackerProgress("Gage", picked_up)
	if managers.experience.SetGagePackageBonus then
		managers.experience:SetGagePackageBonus(GetGageXPRatio(self, picked_up, max_units)) -- Don't use in-game function because it is inaccurate by one package
	end
end

function GageAssignmentManager:present_progress(assignment, peer_name, ...)
	original.present_progress(self, assignment, peer_name, ...)
	UpdateTracker(self)
end

function GageAssignmentManager:sync_load(...)
	original.sync_load(self, ...)
	UpdateTracker(self, true)
end