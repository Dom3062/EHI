if not _G.IS_VR then
    return
end

EHIManagerVR = EHIManager

function EHIManagerVR:CreateWorkspace()
    self._ws = managers.gui_data:create_saferect_workspace("screen", Overlay:gui())
    managers.gui_data:layout_corner_saferect_1280_workspace(self._ws)
    self._ws:hide()
    local panel = self._ws:panel():gui(Idstring("guis/player_info_hud_pd2"), {})
    panel:show()
    self._scale = EHI:GetOption("vr_scale")
    self._hud_panel = panel
end