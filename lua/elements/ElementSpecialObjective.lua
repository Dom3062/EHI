local EHI = EHI
if EHI:CheckLoadHook("ElementSpecialObjective") or not EHI:GetTrackerOption("show_captain_spawn_chance") then
    return
end

Hooks:PostHook(ElementSpecialObjective, "init", "EHI_ElementSpecialObjective_init", function(self, ...)
    if self._values.so_action == "AI_phalanx" then
        managers.ehi_phalanx:OnSOPhalanxCreated(self)
    end
end)