if not EHI:GetOption("show_gage_tracker") then
    return
end

local function CreateTracker()
    local max = tweak_data.gage_assignment:get_num_assignment_units() or 1
    if managers.hud.ehi then
        managers.hud:AddTracker({
            id = "Gage",
            icons = { "gage" },
            max = max,
            class = "EHIProgressTracker"
        })
    else
        EHI._cache.GagePackages = max
    end
end

local _f_client_on_executed = ElementSpawnGageAssignment.client_on_executed
function ElementSpawnGageAssignment:client_on_executed(...)
    _f_client_on_executed(self, ...)
    CreateTracker()
end

local _f_on_executed = ElementSpawnGageAssignment.on_executed
function ElementSpawnGageAssignment:on_executed(instigator)
    _f_on_executed(self, instigator)
    CreateTracker()
end