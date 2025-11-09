local EHI = EHI
if EHI:CheckLoadHook("MissionEndState") then
    return
end

Hooks:PreHook(MissionEndState, "at_enter", "EHI_Pre_MissionEndState_at_enter", function(self, ...)
    EHI:CallCallbackOnce(EHI.CallbackMessage.MissionEnd, self._success)
    EHI:CallCallbackOnce(EHI.CallbackMessage.HUDVisibilityChanged, false)
end)