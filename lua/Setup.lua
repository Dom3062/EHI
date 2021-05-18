if EHI._hooks.Setup then
	return
else
	EHI._hooks.Setup = true
end

local original =
{
    init_managers = Setup.init_managers,
    destroy = Setup.destroy
}

function Setup:init_managers(managers)
    original.init_managers(self, managers)
    managers.ehi = EHIManager:new()
end

function Setup:destroy()
    original.destroy(self)
    managers.ehi:destroy()
end