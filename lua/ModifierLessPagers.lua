local EHI = EHI
if EHI:CheckLoadHook("ModifierLessPagers") or not EHI:GetOption("show_pager_tracker") then
    return
end

local original = ModifierLessPagers.init
function ModifierLessPagers:init(...)
    original(self, ...)
    if managers.ehi_tracker then
        managers.ehi_tracker:CallFunction("Pagers", "DecreaseProgressMaxIfProgress", 4, self:value())
    end
end