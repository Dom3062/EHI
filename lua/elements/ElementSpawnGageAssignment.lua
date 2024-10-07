local EHI = rawget(_G, "EHI")
if EHI:CheckLoadHook("ElementSpawnGageAssignment") or not EHI:GetOption("show_gage_tracker") then
    return
end

local original =
{
    init = ElementSpawnGageAssignment.init,
    client_on_executed = ElementSpawnGageAssignment.client_on_executed,
    on_executed = ElementSpawnGageAssignment.on_executed
}

function ElementSpawnGageAssignment:init(...)
    original.init(self, ...)
    EHI.GagePackagesSpawned = true
end

local CreateTracker
if EHI:GetOption("gage_tracker_panel") == 1 then -- Tracker
    CreateTracker = function()
        if managers.ehi_tracker:TrackerExists("Gage") or (_G.IS_VR and managers.ehi_tracker:IsLoading()) then
            return
        end
        local max = tweak_data.gage_assignment:get_num_assignment_units()
        managers.ehi_tracker:AddTracker({
            id = "Gage",
            icons = { "gage" },
            max = max,
            hint = "gage",
            class = EHI.Trackers.Progress
        })
    end
end

function ElementSpawnGageAssignment:client_on_executed(...)
    original.client_on_executed(self, ...)
    if CreateTracker then
        CreateTracker()
    end
end

function ElementSpawnGageAssignment:on_executed(...)
    original.on_executed(self, ...)
    if not self._values.enabled or not CreateTracker then
        return
    end
    CreateTracker()
end