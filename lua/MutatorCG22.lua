local EHI = EHI
if EHI:CheckLoadHook("MutatorCG22") or EHI:IsXPTrackerHidden() then
    return
end

local original =
{
    sync_load = MutatorCG22.sync_load,
    sync_present_sledded = MutatorCG22.sync_present_sledded
}

function MutatorCG22:sync_load(...)
    original.sync_load(self, ...)
    self:RefreshXPCollected()
end

function MutatorCG22:sync_present_sledded(...)
	original.sync_present_sledded(self, ...)
    self:RefreshXPCollected()
end

function MutatorCG22:RefreshXPCollected()
    local xp_collected = self:get_xp_collected()
    managers.experience:SetCG22EventXPCollected(xp_collected)
end