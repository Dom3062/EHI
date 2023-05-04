local EHI = EHI
EHI._cache.is_vr = _G.IS_VR
if EHI:CheckLoadHook("Setup") then
    return
end

local original =
{
    init_managers = Setup.init_managers,
    init_finalize = Setup.init_finalize,
    destroy = Setup.destroy
}

function Setup:init_managers(managers, ...)
    original.init_managers(self, managers, ...)
    managers.ehi_tracker = EHITrackerManager:new()
    managers.ehi_waypoint = EHIWaypointManager:new()
    managers.ehi_buff = EHIBuffManager:new()
    managers.ehi_manager = EHIManager:new(managers.ehi_tracker, managers.ehi_waypoint)
    EHI:CallCallbackOnce(EHI.CallbackMessage.InitManagers, managers)
end

function Setup:init_finalize(...)
    original.init_finalize(self, ...)
    managers.ehi_tracker:init_finalize()
    managers.ehi_waypoint:init_finalize()
    managers.ehi_manager:init_finalize()
end

function Setup:destroy(...)
    original.destroy(self, ...)
    managers.ehi_tracker:destroy()
end