local EHI = EHI
if EHI:CheckLoadHook("ModifierLessPagers") or not EHI:GetTrackerOption("show_pager_tracker") then
    return
end

Hooks:PostHook(ModifierLessPagers, "init", "EHI_ModifierLessPagers_init", function(self, ...)
    managers.ehi_tracker:CallFunction("Pagers", "DecreaseProgressMaxIfProgress", 4, self:value()) -- Works on drop-ins (for players who play from start (synced before a level is loaded) it won't work and HUDManager will do it instead)
end)