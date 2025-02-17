local EHI = EHI
if EHI:CheckLoadHook("ModifierLessPagers") or not EHI:GetTrackerOption("show_pager_tracker") then
    return
end

Hooks:PostHook(ModifierLessPagers, "init", "EHI_ModifierLessPagers_init", function(self, ...)
    if managers.ehi_tracker then
        managers.ehi_tracker:CallFunction("Pagers", "DecreaseProgressMaxIfProgress", 4, self:value())
    end
end)