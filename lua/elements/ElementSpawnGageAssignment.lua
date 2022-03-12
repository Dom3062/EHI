local EHI = rawget(_G, "EHI")
if not EHI:GetOption("show_gage_tracker") or EHI:GetOption("gage_tracker_panel") ~= 1 then
    return
end

if EHI._hooks.ElementSpawnGageAssignment then -- Don't hook multiple times, pls
    return
else
    EHI._hooks.ElementSpawnGageAssignment = true
end

local function CreateTracker()
    local max = tweak_data.gage_assignment:get_num_assignment_units() or 1
    managers.ehi:AddTracker({
        id = "Gage",
        icons = { "gage" },
        max = max,
        class = "EHIProgressTracker"
    })
end

local _f_client_on_executed = ElementSpawnGageAssignment.client_on_executed
function ElementSpawnGageAssignment:client_on_executed(...)
    _f_client_on_executed(self, ...)
    CreateTracker()
end

local _f_on_executed = ElementSpawnGageAssignment.on_executed
function ElementSpawnGageAssignment:on_executed(...)
    _f_on_executed(self, ...)
    CreateTracker()
end