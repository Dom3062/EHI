local EHI = rawget(_G, "EHI")
if EHI:CheckLoadHook("ElementSpawnGageAssignment") or _G.ch_settings then
    return
end

Hooks:PostHook(ElementSpawnGageAssignment, "init", "EHI_ElementSpawnGageAssignment_init", function(...)
    EHI.GagePackagesSpawned = true
end)

if not EHI:GetTrackerOption("show_gage_tracker") or EHI:GetOption("gage_tracker_panel") ~= 1 then -- Tracker
    return
end

local original =
{
    client_on_executed = ElementSpawnGageAssignment.client_on_executed,
    on_executed = ElementSpawnGageAssignment.on_executed
}

local function CreateTracker()
    if managers.ehi_tracker:Exists("Gage") or (_G.IS_VR and managers.ehi_tracker:IsLoading()) then
        return
    end
    local max = tweak_data.gage_assignment:get_num_assignment_units()
    if max > 0 then
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
    CreateTracker()
end

function ElementSpawnGageAssignment:on_executed(...)
    original.on_executed(self, ...)
    if not self._values.enabled then
        return
    end
    CreateTracker()
end