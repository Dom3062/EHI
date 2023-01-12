local EHI = EHI
if EHI:CheckLoadHook("MutatorCG22") then
    return
end

--[[local function RefreshXPCollected(self)
    if managers.experience.SetCG22EventXPCollected then
        local xp_collected = self:get_xp_collected()
        managers.experience:SetCG22EventXPCollected(xp_collected)
    end
end

local sync_load = MutatorCG22.sync_load
function MutatorCG22:sync_load(...)
    sync_load(self, ...)
    RefreshXPCollected(self)
end

local sync_present_sledded = MutatorCG22.sync_present_sledded
function MutatorCG22:sync_present_sledded(...)
	sync_present_sledded(self, ...)
    RefreshXPCollected(self)
end]]