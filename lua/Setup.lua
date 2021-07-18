if EHI._hooks.Setup then
	return
else
	EHI._hooks.Setup = true
end

local original =
{
    init_managers = Setup.init_managers,
    init_finalize = Setup.init_finalize,
    destroy = Setup.destroy
}

function Setup:init_managers(managers, ...)
    original.init_managers(self, managers, ...)
    managers.ehi = EHIManager:new()
    if managers.player.SetInfamyBonus then
        managers.player:SetInfamyBonus()
    end
end

function Setup:init_finalize(...)
    original.init_finalize(self, ...)
    managers.ehi:init_finalize()
end

function Setup:destroy(...)
    original.destroy(self, ...)
    managers.ehi:destroy()
end