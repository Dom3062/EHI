local EHI = EHI
if EHI:CheckLoadHook("ElementExperience") then
    return
end

local original = ElementExperience.init
function ElementExperience:init(...)
    original(self, ...)
    if self._values.amount and self._values.amount > 0 then
        EHI._cache.XPElement = EHI._cache.XPElement + 1
    end
end