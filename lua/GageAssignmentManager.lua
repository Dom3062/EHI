if EHI._hooks.GageAssignmentManager then
	return
else
	EHI._hooks.GageAssignmentManager = true
end

if not EHI:GetOption("show_gage_tracker") then
	return
end

local original =
{
	sync_load = GageAssignmentManager.sync_load
}

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
end

function GageAssignmentManager:EHIPresentProgress()
	UpdateTracker(self)
end

function GageAssignmentManager:sync_load(...)
	original.sync_load(self, ...)
	UpdateTracker(self, true)
end