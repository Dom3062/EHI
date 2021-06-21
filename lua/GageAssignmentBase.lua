local EHI = EHI
if EHI._hooks.GageAssignmentBase then
    return
else
    EHI._hooks.GageAssignmentBase = true
end

if not EHI:GetOption("show_gage_tracker") then
	return
end

local original =
{
    init = GageAssignmentBase.init,
    show_pickup_msg = GageAssignmentBase.show_pickup_msg
}

function GageAssignmentBase:init(unit, ...)
    original.init(self, unit, ...)
    EHI._cache.GagePackages = (EHI._cache.GagePackages or 0) + 1
end

local _f_show_pickup_msg = GageAssignmentBase.show_pickup_msg
function GageAssignmentBase:show_pickup_msg(...)
    _f_show_pickup_msg(self, ...)
    managers.gage_assignment:EHIPresentProgress()
end