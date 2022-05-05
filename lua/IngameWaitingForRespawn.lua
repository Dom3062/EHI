if EHI._hooks.IngameWaitingForRespawnState then
    return
else
    EHI._hooks.IngameWaitingForRespawnState = true
end

local original =
{
    at_enter = IngameWaitingForRespawnState.at_enter,
    at_exit = IngameWaitingForRespawnState.at_exit
}

function IngameWaitingForRespawnState:at_enter()
    original.at_enter(self)
    EHI:RunOnCustodyCallback(true)
    managers.ehi_buff:RemoveAbilityCooldown()
end

function IngameWaitingForRespawnState:at_exit()
    original.at_exit(self)
    EHI:RunOnCustodyCallback(false)
end