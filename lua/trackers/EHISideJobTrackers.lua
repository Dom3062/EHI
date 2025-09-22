---@generic T: table
---@param super T? A base achievement class
---@return T
function _G.ehi_sidejob_class(super)
    local klass = class(super)
    klass._forced_icon_color = EHISideJobTracker._forced_icon_color
    klass._show_started = EHISideJobTracker._show_started
    klass._show_failed = EHISideJobTracker._show_failed
    klass._show_desc = EHISideJobTracker._show_desc
    klass.PrepareHint = EHISideJobTracker.PrepareHint
    klass.ShowStartedPopup = klass.ShowStartedPopup or EHISideJobTracker.ShowStartedPopup
    klass.ShowFailedPopup = klass.ShowFailedPopup or EHISideJobTracker.ShowFailedPopup
    klass.ShowUnlockableDescription = klass.ShowUnlockableDescription or EHISideJobTracker.ShowUnlockableDescription
    klass._ShowStartedPopup = EHISideJobTracker._ShowStartedPopup
    klass._ShowFailedPopup = EHISideJobTracker._ShowFailedPopup
    klass._ShowUnlockableDescription = EHISideJobTracker._ShowUnlockableDescription
    return klass
end

---@class EHISideJobTracker : EHIAchievementTracker
---@field super EHIAchievementTracker
EHISideJobTracker = class(EHIAchievementTracker)
EHISideJobTracker._forced_icon_color = { EHI:GetColorFromOption("unlockables", "sidejob") }
EHISideJobTracker._show_started = EHI:GetUnlockableOption("show_daily_started_popup")
EHISideJobTracker._show_failed = EHI:GetUnlockableOption("show_daily_failed_popup")
EHISideJobTracker._show_desc = EHI:GetUnlockableOption("show_daily_description")
function EHISideJobTracker:post_init(params)
    self._daily_job = params.daily_job
    EHISideJobTracker.super.post_init(self, params)
end

function EHISideJobTracker:PrepareHint(params)
    local id = self._id or params.id
    params.hint = params.desc or (params.daily_job and ("menu_challenge_" .. id) or id)
    self._desc = params.desc
    self._hint_vanilla_localization = true
end

function EHISideJobTracker:_ShowStartedPopup()
    managers.hud:ShowSideJobStartedPopup(self._id, self._daily_job, self._desc)
end

function EHISideJobTracker:_ShowFailedPopup()
    managers.hud:ShowSideJobFailedPopup(self._id, self._daily_job, self._desc)
end

function EHISideJobTracker:_ShowUnlockableDescription()
    managers.hud:ShowSideJobDescription(self._id, self._daily_job)
end

---@class EHISideJobProgressTracker : EHIAchievementProgressTracker
---@field super EHIAchievementProgressTracker
EHISideJobProgressTracker = ehi_sidejob_class(EHIAchievementProgressTracker)
function EHISideJobProgressTracker:pre_init(params)
    self._daily_job = params.daily_job
    EHISideJobProgressTracker.super.pre_init(self, params)
end