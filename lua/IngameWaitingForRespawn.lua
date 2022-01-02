if EHI._hooks.IngameWaitingForRespawnState then
    return
else
    EHI._hooks.IngameWaitingForRespawnState = true
end

if EHI:IsXPTrackerDisabled() then
    return
end

local original =
{
    at_enter = IngameWaitingForRespawnState.at_enter,
    at_exit = IngameWaitingForRespawnState.at_exit
}

function IngameWaitingForRespawnState:at_enter()
    original.at_enter(self)
    managers.experience:SetInCustody(true)
end

function IngameWaitingForRespawnState:at_exit()
    original.at_exit(self)
    managers.experience:SetInCustody(false)
end