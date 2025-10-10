---@class EHITrophyTracker : EHIUnlockableTracker
---@field super EHIUnlockableTracker
EHITrophyTracker = class(EHIUnlockableTracker)
EHITrophyTracker._hint_vanilla_localization = true
EHITrophyTracker._forced_icon_color = { EHI:GetColorFromOption("unlockables", "trophy") }
EHITrophyTracker._show_started = EHI:GetUnlockableOption("show_trophy_started_popup")
EHITrophyTracker._show_failed = EHI:GetUnlockableOption("show_trophy_failed_popup")
EHITrophyTracker._show_desc = EHI:GetUnlockableOption("show_trophy_description")
function EHITrophyTracker:PrepareHint(params)
    params.hint = self._id or params.id
end

function EHITrophyTracker:_ShowStartedPopup()
    managers.hud:ShowTrophyStartedPopup(self._id)
end

function EHITrophyTracker:_ShowFailedPopup()
    managers.hud:ShowTrophyFailedPopup(self._id)
end

function EHITrophyTracker:_ShowUnlockableDescription()
    managers.hud:ShowTrophyDescription(self._id)
end