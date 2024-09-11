local EHI = EHI
if EHI:CheckLoadHook("ElementJobValue") then
    return
end

local init = ElementJobValue.init
function ElementJobValue:init(...)
    init(self, ...)
    if self._values.save and self._values.key then
        if table.contains(tweak_data.achievement.collection_achievements.xm20_1.collection, self._values.key) then
            EHI._cache.xm20_1_active = true
        elseif table.contains(tweak_data.achievement.collection_achievements.pent_11.collection, self._values.key) then
            EHI._cache.pent_11_active = true
        end
    end
end