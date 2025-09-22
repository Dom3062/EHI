---@generic T: table
---@param super T? A base achievement class
---@return T
function _G.ehi_eventjob_class(super)
    local klass = class(super)
    klass._forced_icon_color = EHIEventMissionTracker._forced_icon_color
    klass._show_started = EHIEventMissionTracker._show_started
    klass._show_failed = false
    klass._show_desc = EHIEventMissionTracker._show_desc
    klass.PrepareHint = EHIEventMissionTracker.PrepareHint
    klass.ShowStartedPopup = klass.ShowStartedPopup or EHIEventMissionTracker.ShowStartedPopup
    klass.ShowUnlockableDescription = klass.ShowUnlockableDescription or EHIEventMissionTracker.ShowUnlockableDescription
    klass._ShowStartedPopup = EHIEventMissionTracker._ShowStartedPopup
    klass._ShowUnlockableDescription = EHIEventMissionTracker._ShowUnlockableDescription
    return klass
end

---@class EHIEventMissionTracker : EHIAchievementProgressTracker
---@field super EHIAchievementProgressTracker
EHIEventMissionTracker = class(EHIAchievementProgressTracker)
EHIEventMissionTracker._forced_icon_color = { EHI:GetColorFromOption("unlockables", "event") }
EHIEventMissionTracker._show_started = EHI:GetUnlockableOption("show_event_started_popup")
EHIEventMissionTracker._show_failed = false
EHIEventMissionTracker._show_desc = EHI:GetUnlockableOption("show_event_description")
function EHIEventMissionTracker:PrepareHint(params)
    local id = self._id or params.id
    params.hint = "menu_" .. id
    self._desc = "menu_" .. params.stat
    self._hint_vanilla_localization = true
end

function EHIEventMissionTracker:_ShowStartedPopup()
    managers.hud:ShowEventStartedPopup(self._id)
end

function EHIEventMissionTracker:_ShowUnlockableDescription()
    managers.hud:ShowEventDescription(self._id, self._desc)
end

---@class EHIEventMissionGroupTracker : EHIAchievementProgressGroupTracker
---@field super EHIAchievementProgressGroupTracker
EHIEventMissionGroupTracker = ehi_eventjob_class(EHIAchievementProgressGroupTracker)
function EHIEventMissionGroupTracker:PrepareHint(params)
    local id = self._id or params.id
    params.hint = "menu_" .. id
    if params.counter then
        self._desc1 = "menu_" .. params.counter[1].id
        self._desc2 = "menu_" .. params.counter[2].id
    else
        self._desc1 = ""
        self._desc2 = ""
    end
    self._desc = params.hint
    self._hint_vanilla_localization = true
end

function EHIEventMissionGroupTracker:_ShowUnlockableDescription()
    managers.hud:ShowEventDescription(self._id, self._desc1)
    managers.hud:ShowEventDescription(self._id, self._desc2)
end