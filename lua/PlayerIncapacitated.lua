if EHI:CheckLoadHook("PlayerIncapacitated") or not EHI:GetOption("show_progress_reload") then
    return
end

Hooks:PostHook(PlayerIncapacitated, "enter", "EHI_show_progress_reload_PlayerIncapacitated_enter", function(self, state_data, ...)
    if state_data.ehi_reload_t then
        state_data.ehi_reload_t = nil
        managers.hud:hide_interaction_bar()
    end
end)