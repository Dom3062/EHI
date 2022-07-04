if EHI._hooks.IngameWaitingForRespawnState then
    return
else
    EHI._hooks.IngameWaitingForRespawnState = true
end

local original =
{
    at_enter = IngameWaitingForRespawnState.at_enter,
    finish_trade = IngameWaitingForRespawnState.finish_trade
}

function IngameWaitingForRespawnState:at_enter(...)
    original.at_enter(self, ...)
    EHI:RunOnCustodyCallback(true)
    managers.ehi_buff:RemoveAbilityCooldown()
end

function IngameWaitingForRespawnState:finish_trade(...)
    original.finish_trade(self, ...)
    EHI:RunOnCustodyCallback(false)
end