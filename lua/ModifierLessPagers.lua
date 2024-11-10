local EHI = EHI
if EHI:CheckLoadHook("ModifierLessPagers") or not EHI:GetOption("show_pager_tracker") then
    return
end

local original = ModifierLessPagers.init
function ModifierLessPagers:init(...)
    original(self, ...)
    if not managers.ehi_tracker then
        return
    end
    local value = self:value()
    if value >= 4 then
        managers.ehi_tracker:RemoveTracker("Pagers")
    else
        managers.ehi_tracker:CallFunction("Pagers", "DecreaseProgressMaxIfProgress", 4, value)
    end
end